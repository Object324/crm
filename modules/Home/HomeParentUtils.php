<?php

//zxm 20230731 首页默认组件的类
//重要的参数 $scopeType $senioruserid $search_date $stuffid $boardid $boardstuffid  $approve_value
class HomeParentUtils{
    public $boardid;//看板id
    public $system_deploy_351 = 2;//单据分录明细金额字段和单据头货币字段小数位数
    public $daterangsql;
    public $scopeType;//数据范围下拉框选中值
    public $senioruserid;//选中的用户ID  逗号分隔
    public $search_date;//时间
    public $approve_value;//审批的值

    public $stuffid;//组件id
    public $boardstuffid;//ld_homeboard_plate_stuff表的主键ID
    public $datarangesqlArr;
    public $params;//参数 所有的参数
    public $boarddatarangmoduleArr ;
    public $DefaultdatarangmoduleArr;

    public $timefieldname;//时间字段
    public static $defaultstuffArr;//预制的组件的配置信息
    public $filterArr;
    public $pathInfo;
    public $totalPathInfo;

    static public function getInstance(){

    }
    public function __construct($boardid)
    {
        $this->boardid = $boardid;

        $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
        if(is_numeric($system_351['deploy_value'])){
            $this->system_deploy_351 = $system_351['deploy_value'];
        }

    }
    public function initParam($params){
        global $adb;
        $this->scopeType = $params['scopeType'];
        // edit: xll 2024/09/24 BUG20240924-18 首页选择指定成员，目标完成率没数据
        if(!empty($params['selectuserid'])) {
            $this->senioruserid = $params['selectuserid'];
        }
        else {
            $this->senioruserid = $params['senioruserid'];
        }
        if($this->scopeType === 'SmOwner_Search_All'){
            crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
            $scopeobj = new cls_ScopOfAuthority($adb, 'Home');
            $this->senioruserid = $scopeobj->getHomeScopeUser();
        }
        $this->search_date = $params['search_date'];
        $this->approve_value = $params['approve_value'];


        $this->params = $params;
    }
    public function getPlateSetting($stuffid){
        global $adb;
        static $plateSettingArr;
        if(isset($plateSettingArr[$stuffid])&&!empty($plateSettingArr[$stuffid])){
            return $plateSettingArr[$stuffid];
        }
        $sql = "select * from ld_homeboard_plate_setting where boardid=? ";
        $res = $adb->pquery($sql,array($this->boardid));
        $nums = $adb->num_rows($res);
        $plateSettingArr = [];
        if($nums > 0) {
            for ($i = 0; $i < $nums; $i ++) {
                $tmpstuffid = $adb->query_result($res,$i,'stuffid');
                $type = $adb->query_result($res,$i,'type');
                $setvlaue = $adb->query_result($res,$i,'setvalue');
                $plateSettingArr[$tmpstuffid][$type] = $setvlaue;
            }
        }
        return $plateSettingArr[$stuffid];
    }
    public function setCanPenetrate(){
        $can_penetrate = 'yes';
        $platesetting =  $this->getPlateSetting($this->stuffid);
        if(!isset($platesetting['can_penetrate'])){
            //默认可以穿透
            $can_penetrate = 'yes';
        }else{
            $can_penetrate = $platesetting['can_penetrate'];
        }
        return $can_penetrate;
    }
    public function setStuffid($stuffid,$boardstuffid){
        global $adb;
        $this->stuffid = $stuffid;
        if(empty($boardstuffid)){
            $boardstuffsql = "select boardstuffid from ld_homeboard_plate_stuff where boardid=? and stuffid=?";
            $boardstuffres = $adb->pquery($boardstuffsql,array($this->boardid,$stuffid));
            $boardstuffnums = $adb->num_rows($boardstuffres);
            if($boardstuffnums>0){
                $this->boardstuffid = $adb->query_result($boardstuffres,0,0);
            }
        }else{
            $this->boardstuffid = $boardstuffid;
        }
        if(!isset(self::$defaultstuffArr[$stuffid])){

            $stuffsql = "select * from ld_stuff where stuffid=?";
            $stuffres = $adb->pquery($stuffsql,array($stuffid));
            $stuffnums = $adb->num_rows($stuffres);
            if($stuffnums>0){
                self::$defaultstuffArr[$stuffid] = $adb->query_result_rowdata($stuffres,0);
            }
        }

    }

    public function getDateRange(){
        //根据stuffid 时间条件也不一致
        switch ($this->stuffid){
            case 1://公司最近6个月销售情况
            case 9://个人最近6个月销售情况
                $nowmax=date('t');
                $endMonthDate=date("Y-m")."-$nowmax 23:59:59";
                $startMonthDate=date("Y-m",strtotime(date('Y-m')." -5 month"));
                $startMonthDate.="-01 00:00:00";
                $date = " between '$startMonthDate' and '$endMonthDate' " ;
                break;
            case 4://签约额 同比
            case 5://收款额月度同比
            case 41://开票额月度同比
            case 42://出库额月度同比
                $nowdate = date("Y")."-12-31 23:59:59";//本年结束时间
                $Lastdate = date("Y",strtotime("-1 year"))."-01-01 00:00:00";//上年开始时间//更新 bug 0006933: 销售提：外网首页“回款额月度同比”查不出数据 lmx
                $date = " between '$Lastdate' and '$nowdate' " ;
                break;
            case 10:
                //过去7天日程
                $endDateTime=date('Y-m-d').' '.'23:59:59';
                $startDateTime=date('Y-m-d',strtotime("$endDateTime -6 day")).' '.'00:00:00';
                $date = " between '$startDateTime' and '$endDateTime' " ;
                break;
            case 11:
                $dbStartDateTime = date('Y-m-d').' 00:00:00';
                $endDateTime=date('Y-m-d').' 23:59:59';
                $endDateTime=date('Y-m-d H:i:s',strtotime("$endDateTime +6 day"));
                $date = " between '$dbStartDateTime' and '$endDateTime' " ;
                break;
            case 12:
            case 115:
                $date = '';
                break;
            case 13:
                //今日待联系客户
                $startDateTime=date("Y-m-d");
                $date = " between '$startDateTime 00:00:00' and '$startDateTime 23:59:59' ";
                break;
            default :
                $date = getHomeDateScope($this->search_date);
                break;
        }
        return $date;
    }
    public function getStuffData(){
        $stuffid = $this->stuffid;
        $home_values=[];
        //是否设置穿透 等信息
        $platesetting =  $this->getPlateSetting($stuffid);
        if(!isset($platesetting['can_penetrate'])){
            //默认是可穿透的
            $platesetting['can_penetrate'] = 'yes';
        }
        $boardstuffid = $this->boardstuffid;
        $this->getDataRangeSql();
        if($boardstuffid>0){
            $datarangemodule = $this->boarddatarangmoduleArr[$boardstuffid];
        }else{
            $datarangemodule = $this->DefaultdatarangmoduleArr['defaultstuff_'.$stuffid];
        }
        if($stuffid==31){
            //现金银行流水账
            $home_values=$this->getNewBankCash();
        }else if($stuffid==32){
            //首页：公告
            $home_values=$this->getPublicAnnouncement();
        }else if($stuffid==33){
            //首页组件：销售排行榜
            $home_values=$this->getContractnumberandamount($platesetting);
        }else if($stuffid==34){
            //首页组件：交易
            $home_values=$this->getTransaction();
        }else if($stuffid==39){
            //首页组件 待审批
            $home_values=$this->getPendingApproval();
        }else if($stuffid==57){
            //跟进频次排行榜
            $home_values=$this->getContactTimesRanking($platesetting);
        }else if($stuffid==60){
            //产品销售排行榜
            $home_values=$this->getProductsSalesRanking($platesetting);
        }else if($stuffid==66){
            $home_values=$this->getServiceKanban();

        }else if($stuffid==100||($stuffid>=102&&$stuffid<=107)){
            $funname = 'getStuffDetailData'.$stuffid;

            if(method_exists($this,$funname)){
                $home_values=$this->$funname($datarangemodule);
            }
        }else{
            //107以上用stufftitle动态获取组件详情
            $funname = 'get'.self::$defaultstuffArr[$stuffid]['stufftitle'];

                if(method_exists($this,$funname)){
                $home_values=$this->$funname($datarangemodule);
            }
        }

        if($stuffid=='57'||$stuffid=='100'){
            $home_values['PlateSetting'] = $platesetting;
        }
        return $home_values;
    }
    public function getDataRangeSql(){
        $this->daterangsql = $this->getDateRange();

        /**新的条件解析 兼容了旧的看板start */
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        $this->addOtherCondition($DataRangeHomeboardObj);//112 这个组件额外的条件 级联字段
        $DataRangeHomeboardObj->getDataRangeSql($this->stuffid,$this->boardstuffid,$this->scopeType,$this->senioruserid,$this->daterangsql,$this->approve_value);
        $this->datarangesqlArr = $DataRangeHomeboardObj->datarangesqlArr;//带inner join 的sql 数组  键是 datarangesql_模块名称

        $this->filterArr = $DataRangeHomeboardObj->filterArr;
        $this->boarddatarangmoduleArr = $DataRangeHomeboardObj->boarddatarangmoduleArr;
        $this->DefaultdatarangmoduleArr = $DataRangeHomeboardObj->DefaultdatarangmoduleArr;
        return $DataRangeHomeboardObj;
        /**新的条件解析 兼容了旧的看板end */
    }
    public function addOtherCondition ($DataRangeHomeboardObj){
        if($this->stuffid==112){
            //上级字段的值
            $boardselect_stage_value = $this->params['boardselect_stage_value'];

            if(!empty($boardselect_stage_value)){
                crm_load_class_file('ModuleUtils','modules/lingdang');
                $ModuleUtilsObj = new ModuleUtils();
                $sourcefield = $ModuleUtilsObj->getPrevAdvanceFieldname('Potentials','sales_stage');
                $tmpfocus = CRMEntity::getInstance('Potentials');
                $moduleAllPreseneceFields = $tmpfocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
                $tmpfields = $moduleAllPreseneceFields[$sourcefield];
                $advft_criteria[] = ['groupid'=>1,
                    'columnname'=>$tmpfields->getTableName().':'.$tmpfields->getColumnName().':'.$tmpfields->getFieldName().':Potentials_fieldlabel:V',
                    'comparator'=>'e',
                    'value'=>$boardselect_stage_value,
                    'columncondition'=>''
                ];
                $advft['advft_criteria'] = json_encode($advft_criteria);
                $advft['advft_criteria_groups'] = '[null,{"groupcondition":""}]';
                $advft['searchtype'] = 'advance';
                $DataRangeHomeboardObj->setCustomEchartHighSearchParam($advft);
            }
        }
    }
    //表格类组件的表头  获取的方法
    public function getTableStuffHeader($headerNameArr){
        $thhtmlArr = [];
        if(!empty($headerNameArr)){
            foreach($headerNameArr as $headername){
                $thhtmlArr[] = '<span title="'.$headername.'">' . $headername . '</span>';
            }
        }
        return $thhtmlArr;
    }
    //edit: xll 2023/08/31 XUQIU1001645 PC端增加销售龙虎榜，pc端龙虎榜获取数据的方法
    public function getStuffDetailData100(){
        $StuffParams = $this->params;
        $StuffParams['boardid'] = $this->boardid;
        $StuffParams['stuffid'] = $this->stuffid;
//        crm_load_class_file('DragonTigerList','modules/Home/HomeBoardNew');
//        $DragonTigerListObj= DragonTigerList::getInstance($this->boardid);
//        $DragonTigerListObj->setStuffId($this->stuffid);
//        $home_values = $DragonTigerListObj->getStuffDetailData($StuffParams);
        //获取数据统一改到homestuffdetailutils中去  方便与简报的部分代码整合
        $home_values = $this->getDragonTigerListData($StuffParams);
        return $home_values;
    }
    public function getStuffDetailData102(){
        $this->params['data_type'] = 'dragontiger_NewSignContractCount';
        $data = $this->getStuffDetailData100();
        $data['can_penetrate'] = $this->setCanPenetrate();
        return $data;
    }
    public function getStuffDetailData103(){
        $this->params['data_type'] = 'dragontiger_NewSignContractAmount';
        $data = $this->getStuffDetailData100();
        $data['can_penetrate'] = $this->setCanPenetrate();
        return $data;
    }
    public function getStuffDetailData104(){
        $this->params['data_type'] = 'dragontiger_NewCashBillAmount';
        $data = $this->getStuffDetailData100();
        $data['can_penetrate'] = $this->setCanPenetrate();
        return $data;
    }
    //edit: xll 2023/11/13 线索漏斗--本来是想放在HomeChartUtils中  但是发现线索分析也用到这个了
    public function getLeadsFunnel($datarangemodule){
        global $adb;
        $stuffid = $this->stuffid;
        $fieldname = 'leadsource';
        $grouptable = 'ld_leads';
        $countType = 'count';
        if($_REQUEST['classifyField'] && $_REQUEST['countType']) {
            $fieldname = explode(':',$_REQUEST['classifyField'])[2];
            $grouptable = explode(':',$_REQUEST['classifyField'])[0];
            $countType = $_REQUEST['countType'];
        }
        else{
            crm_load_class_file('Homeboard','modules/Home');
            $PlateSetting = Homeboard::getPlateSetting($this->boardid,$stuffid);
            if(isset($PlateSetting['classifyField']) && isset($PlateSetting['classifyField'])){
                $fieldname = explode(':',$PlateSetting['classifyField'])[2];
                $grouptable = explode(':',$PlateSetting['classifyField'])[0];
                $countType = $PlateSetting['countType'];
            }
        }

        $module_arr = explode(',',$datarangemodule);
        $module_path = [
            'start' => $module_arr[0],
            'path' => $module_arr,
        ];
        $sql = $this->getLeadsFunnelSQL($module_path,$fieldname,$grouptable);
        $result = $adb->pquery($sql);
        $num = $adb->num_rows($result);
        $res_data = [];
        $total_data = [
            'leads_num' => 0,
        ];
        $col_list = ['leads_type','leads_num','accounts_num','potentials_num','unique_potentials_num','potentials_total',
            'salesorder_num','unique_salesorder_num','salesorder_total','cashbill_total'];
        foreach ($col_list as $colname) {
            if(!isset($total_data[$colname]))
                $total_data[$colname] = 0;
        }
        if($num > 0) {
            $system_351 = getSys_deploy(351);
            $system_deploy_351 = is_numeric($system_351['deploy_value']) ? $system_351['deploy_value'] : 2;
            $count_list = [
                'leads_to_accounts' => ['leads_num','accounts_num'],
                'accounts_to_potentials' => ['accounts_num','potentials_num'],
                'potentials_to_salesorder' => ['potentials_num','salesorder_num'],
            ];
            //唯一计数取另一值
            if($countType === 'distinct_count') {
                $count_list['accounts_to_potentials'] = ['accounts_num','unique_potentials_num'];
                $count_list['potentials_to_salesorder'] = ['potentials_num','unique_salesorder_num'];
            }
            for ($i = 0;$i < $num ;$i ++) {
                foreach ($col_list as $colname) {
                    $col_value = $adb->query_result($result, $i, $colname);
                    $res_data[$i][$colname] = $col_value;
                    if(!isset($total_data[$colname]))
                        $total_data[$colname] = 0;
                    $total_data[$colname] += (int)$col_value;
                }
                $res_data[$i]['salesorder_total'] = (float)setNumberFormatEmptySeperator($res_data[$i]['salesorder_total'],$system_deploy_351);
                $res_data[$i]['cashbill_total'] = (float)setNumberFormatEmptySeperator($res_data[$i]['cashbill_total'],$system_deploy_351);
                foreach ($count_list as $colname => $count_info) {
                    $mol_name = $count_info[1];
                    $mol_value = $res_data[$i][$mol_name];
                    $den_name = $count_info[0];
                    $den_value = $res_data[$i][$den_name];
                    $res_data[$i][$colname] = ($den_value == 0) ? 0 : ($mol_value / $den_value);
                }
            }
            $total_data['salesorder_total'] = (float)setNumberFormatEmptySeperator($total_data['salesorder_total'],$system_deploy_351);
            $total_data['cashbill_total'] = (float)setNumberFormatEmptySeperator($total_data['cashbill_total'],$system_deploy_351);
            foreach ($count_list as $colname => $count_info) {
                $mol_name = $count_info[1];
                $mol_value = $total_data[$mol_name];
                $den_name = $count_info[0];
                $den_value = $total_data[$den_name];
                $total_data[$colname] = ($den_value == 0) ? 0 : ($mol_value / $den_value);
            }
        }
        $total_data['leads_type'] = getFixedLabel('TOTAL');//'总计';
        return array('res_data'=>$res_data,'pathInfo'=>$this->pathInfo,'totalPathInfo'=>$this->totalPathInfo,
            'total_data'=>$total_data,'modulePath'=>$module_arr);
    }


    public function getLeadsFunnelSQL($module_path,$fieldname,$grouptable){
        $start_module = $module_path['start'];
        $start_focus = CRMEntity::getInstance($start_module);
        $start_table = $start_focus->table_name;
        $start_field =  $grouptable . '.' . $fieldname;
        $path = $module_path['path'];
        $pathInfo = [];
        $start_fieldlabel = $start_focus->fieldobj->getFieldInfoBykeyValue('fieldname',$fieldname,'fieldlabel');

        $module_name = strtolower($start_module);
        array_push($pathInfo,['label'=>$start_fieldlabel,'col_name'=>$module_name . '_type',]);
        array_push($pathInfo,[
            'label'=>getTranstab($start_module),
            'col_name'=>$module_name.'_num',
            'module'=>$start_module,
            'calc_method'=>'value',
        ]);
        $sql_head = 'SELECT ' . $start_field . ' AS ' . $module_name . '_type, count(1) AS ' . $module_name . '_num ';

        $sql_body = ' FROM ' . $start_table . ' left join '.$start_focus->customFieldTable[0].' on '.$start_table.'.'.$start_focus->table_index.'='.$start_focus->customFieldTable[0].'.'.$start_focus->customFieldTable[1] . $this->datarangesqlArr['datarangesql_'.$start_module];

        $sql_tail = ' GROUP BY ' . $start_field;

        for ($i = 1; $i < count($path); $i ++) {
            $tmp_module = $path[$i];
            $before_module = $path[$i - 1];
            //$tmp_label = getTranstab($before_module) . ' -> ' . getTranstab($tmp_module);
            array_push($pathInfo,[
                'label'=>' -> ',
                'calc_method'=>'value_rate',
                'col_name'=>strtolower($before_module).'_to_'.strtolower($tmp_module),
                'can_penetrate'=>'no',
            ]);
            array_push($pathInfo,[
                'label'=>getTranstab($tmp_module),
                'module'=>$tmp_module,
                //'table_col_label'=>$tmp_label,
                'calc_method'=>'value',
                'col_name'=>strtolower($tmp_module).'_num',
            ]);
            $tmp_sql_arr = $this->getLeadsFunnelSQLModule($tmp_module,$before_module);
            $sql_head .= $tmp_sql_arr['head'] . ' ';
            $sql_body .= $tmp_sql_arr['body'] . ' ';
        }
        $last_module = $path[count($path) - 1];
        $lastpre_module = $path[count($path) - 2];
        $total_trans_rate = [];
        for ($i = 1; $i < count($path) - 1; $i ++) {
            $tmp_module = $path[$i];
            $before_module = $path[$i - 1];
            $tmp_col_name = strtolower($before_module) . '_to_' . strtolower($tmp_module);
            array_push($total_trans_rate,$tmp_col_name);
        }
        $trans_label = getFixedLabel('TransitionRate');
        $amount_label = getTranstab($lastpre_module).getFixedLabel('AMOUNT');
        $recieve_label = getTranstab($last_module).getFixedLabel('AMOUNT');
        $totalPathInfo = [
            [
                'label'=>$trans_label,//'转换率',
                'table_col_label'=>$trans_label,//'转换率',
                'col_name'=>$total_trans_rate,
                'calc_method'=>'multiply_rate',
                'can_penetrate'=>'no',
            ],
            [
                'label'=>$amount_label,//'销售订单金额',
                'table_col_label'=>$amount_label,//'销售订单金额',
                'col_name'=>strtolower($lastpre_module).'_total',
                'calc_method'=>'value',
                'module'=>$lastpre_module,
            ],
            [
                'label'=>$recieve_label,//'已回款金额',
                'table_col_label'=>$recieve_label,//'已回款金额',
                'col_name'=>strtolower($last_module).'_total',
                'calc_method'=>'value',
                'module'=>$last_module,
            ],
        ];
        $this->pathInfo = $pathInfo;
        $this->totalPathInfo = $totalPathInfo;
        return $sql_head.$sql_body.$sql_tail;
    }
    public $new_table_name = ['Leads' => 'l','Accounts' => 'a','Potentials' => 'p','SalesOrder' => 'sp','CashBill' => 'sc'];
    public function getLeadsFunnelSQLModule($module,$before_module){
        $fun_name = 'getLeadsFunnelSQL_' . $module;
        $focus = CRMEntity::getInstance($module);
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        $new_table_name = $this->new_table_name[$module];
        $new_field = $new_table_name . '.' . $focus->table_index;
        $field = $table_name . '.' . $focus->table_index;
        $unique_num = $new_table_name . '.unique_num';

        $params = [
            'module' => $module,
            'table_name' => $table_name,
            'new_table_name' => $new_table_name,
            'table_index' => $table_index,
            'new_field' => $new_field,
            'field' => $field,
            'unique_num' => $unique_num,
            'num_field' => strtolower($module) . '_num',
            'where' => $this->datarangesqlArr['datarangesql_'.$module],
        ];
        return $this->$fun_name($params);
    }
    public function getLeadsFunnelSQL_Accounts($params){
        $new_field = $params['new_field'];
        return [
            'head' => ' ,IFNULL(count('. $new_field . '), 0) AS ' . $params['num_field'] . ' ',
            'body' => ' LEFT JOIN (
                            SELECT
                                ' . $params['field'] . '
                            FROM
                                ' . $params['table_name'] . '
                            ' . $params['where'] . '
                            WHERE
                                deleted = 0
                        ) ' . $params['new_table_name'] . ' ON '. $params['new_field'] . ' = ld_leads.upgradeaccountid ',
        ];
    }
    public function getLeadsFunnelSQL_Potentials($params){
        $new_field = $params['new_field'];
        $groupBy = ' GROUP BY ' . $params['table_name'] . '.accountid ';
        $groupBy_col = ' ,count(1) AS unique_num , 
                        sum(ld_potential.total) AS unique_sum ,
                        CASE WHEN COUNT(sp.salesorderid) = 0 THEN NULL ELSE COUNT(sp.salesorderid) END AS sp_unique_num,
                        SUM(sp.unique_num) AS sp_num,
                        SUM(sp.unique_sum) AS sp_sum,
                        SUM(sc.unique_sum) AS sc_sum ';
        if($this->getSQLType === 'Chuantou') {
            return [
                'head' => ' ,IFNULL(count(' . $new_field . '), 0) AS unique_potentials_num
                        ,IFNULL(sum(' . $params['new_table_name'] . '.unique_sum), 0) AS potentials_total
                        ,IFNULL(sum(' . $params['unique_num'] . '), 0) AS ' . $params['num_field'] . ' ',
                'body' => ' LEFT JOIN (
                            SELECT
                                ' . $params['field'] . ',
                                ld_potential.accountid
                            FROM
                                ' . $params['table_name'] . '
                            ' . $params['where'] . '
                            WHERE
                                deleted = 0
                        ) ' . $params['new_table_name'] . ' ON ' . $params['new_table_name'] . '.accountid = a.accountid ',
            ];
        }
        if($this->stuffid == '116') {
            $calType = 'count';
        }
        else {
            $calType = 'sum';
        }
        $sourceListCol = $this->getSalesOrderSourceList();

        return [
            'head' => ' ,IFNULL(count(' . $new_field . '), 0) AS unique_potentials_num
                        ,IFNULL(sum(' . $params['new_table_name'] . '.unique_sum), 0) AS potentials_total
                        ,IFNULL(sum(' . $params['unique_num'] . '), 0) AS ' . $params['num_field'] . ' 
                        ,IFNULL(' . $calType . '(p.sp_unique_num), 0) AS unique_salesorder_num
                        ,IFNULL(sum(p.sp_num), 0) AS salesorder_num
                        ,IFNULL(sum(p.sp_sum), 0) AS salesorder_total
                        ,IFNULL(sum(p.sc_sum), 0) AS cashbill_total',
            'body' => ' LEFT JOIN (
                            SELECT
                                ' . $params['field'] . ',
                                ld_potential.accountid
                                ' . $groupBy_col . '
                            FROM
                                ' . $params['table_name'] . '
                            ' . $params['where'] . '
                            LEFT JOIN (
                                SELECT
                                    ld_salesorder.salesorderid,
                                    ld_salesorder.potentialid,
                                    ld_salesorder.'.$sourceListCol.',
                                    ld_salesorder.total,
                                    count(1) AS unique_num,
                                    sum(
                                        ld_salesorder.total / IFNULL(
                                            ld_salesorder.conversion_rate,
                                            1
                                        )
                                    ) AS unique_sum
                                FROM
                                    ld_salesorder
                                ' . $this->datarangesqlArr['datarangesql_SalesOrder'] . '
                                WHERE
                                    ld_salesorder.deleted = 0
                                GROUP BY
                                    ld_salesorder.potentialid
                            ) sp ON sp.potentialid = ld_potential.potentialid
                            LEFT JOIN (
                                SELECT
                                    ld_salesorder.salesorderid,
                                    ld_salesorder.potentialid,
                                    ld_salesorder.deleted,
                                    c.cashbillid,
                                    sum(c.total / c.conversion_rate) AS unique_sum
                                FROM
                                    ld_salesorder
                                LEFT JOIN (
                                    SELECT
                                        ld_cashbill.cashbillid,
                                        ld_cashbill.total,
                                        IFNULL(
                                            ld_cashbill.conversion_rate,
                                            1
                                        ) AS conversion_rate,
                                        ld_cashbill.source_list,
                                        ld_paymentplan.entitytypeid AS paymentplan_salesorderid
                                    FROM
                                        ld_cashbill
                                    ' . $this->datarangesqlArr['datarangesql_CashBill'] . '
                                    LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID
                                    AND ld_cashbill2paymentplan.entitytype = \'PaymentPlan\'
                                    LEFT JOIN ld_paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid
                                    AND ld_paymentplan.entitytype = \'SalesOrder\'
                                    WHERE
                                        ld_cashbill.deleted = 0
                                ) c ON FIND_IN_SET(
                                    ld_salesorder.salesorderid,
                                    c.source_list
                                )
                                OR c.paymentplan_salesorderid = ld_salesorder.salesorderid
                                ' . $this->datarangesqlArr['datarangesql_SalesOrder'] . '
                                WHERE
                                    ld_salesorder.deleted = 0
                                GROUP BY
                                    ld_salesorder.potentialid
                            ) sc ON sc.potentialid = ld_potential.potentialid
                            WHERE
                                ld_potential.deleted = 0
                            ' . $groupBy . '
                        ) ' . $params['new_table_name'] . ' ON ' . $params['new_table_name'] . '.accountid = a.accountid ',
        ];
    }
    var $salesOrderSourceList;
    public function getSalesOrderSourceList() {
        if(!empty($this->salesOrderSourceList)) {
            return $this->salesOrderSourceList;
        }
        $module = 'SalesOrder';
        $focus = CRMEntity::getInstance($module);
        $sourceCol = 'source_list';
        $quoteCol = 'quoteid';
        $fieldObj = $focus->fieldobj->getFieldInfoobjBykey('columnname', $sourceCol);
        if(empty($fieldObj)) {
            $fieldObj = $focus->fieldobj->getFieldInfoobjBykey('columnname', $quoteCol);
        }
        if(!empty($fieldObj)) {
            $this->salesOrderSourceList = $fieldObj->getColumnName();
        }
        // 若字段关闭直接从数据查取
        else {
            global $adb;
            $sql = "SELECT * FROM ld_field LEFT JOIN ld_tab ON ld_tab.tabid = ld_field.tabid WHERE ld_tab.`name` = ? AND ld_field.columnname = ?;";
            $result = $adb->pquery($sql, [$module, $sourceCol]);
            if($adb->num_rows($result) > 0) {
                $this->salesOrderSourceList = $sourceCol;
            }
            else {
                $result = $adb->pquery($sql, [$module, $quoteCol]);
                if($adb->num_rows($result) > 0) {
                    $this->salesOrderSourceList = $quoteCol;
                }
            }
        }
        return $this->salesOrderSourceList;
    }
    public function getLeadsFunnelSQL_SalesOrder($params){
        $new_field = $params['new_field'];
        $groupBy = ' GROUP BY ' . $params['table_name'] . '.potentialid ';
        $groupBy_col = ' , '.'count(1) AS unique_num,
                                sum(
                                    ld_salesorder.total / IFNULL(
                                        ld_salesorder.conversion_rate,
                                        1
                                    )
                                ) AS unique_sum ';
        $sourceListCol = $this->getSalesOrderSourceList();
        if($this->getSQLType === 'Chuantou') {
            $groupBy = '';
            $groupBy_col = '';
            return [
                'head' => ' ,IFNULL(count(' . $new_field . '), 0) AS unique_salesorder_num
                        ,IFNULL(sum(' . $params['unique_num'] . '), 0) AS salesorder_num
                        ,IFNULL(sum(sp.unique_sum), 0) AS salesorder_total ',
                'body' => ' LEFT JOIN (
                            SELECT
                                ' . $params['field'] . ',
                                ld_salesorder.potentialid,
                                ld_salesorder.'.$sourceListCol.',
                                ld_salesorder.total
                                ' . $groupBy_col . '
                            FROM
                                ' . $params['table_name'] . '
                            ' . $params['where'] . '
                            WHERE
                                ld_salesorder.deleted = 0
                            ' . $groupBy . '
                        ) ' . $params['new_table_name'] . ' ON ' . $params['new_table_name'] . '.potentialid = p.potentialid or FIND_IN_SET(p.potentialid,sp.'.$sourceListCol.')',
            ];
        }
        return ['head' => '', 'body' => ''];
    }
    public function getLeadsFunnelSQL_CashBill($params){
        $new_field = $params['new_field'];
        $groupBy = ' GROUP BY ld_salesorder.potentialid ';
        $groupBy_col = ' , '.'sum(c.total / c.conversion_rate) AS unique_sum ';
        if($this->getSQLType === 'Chuantou') {
            $groupBy = '';
            $groupBy_col = '';
            return [
                'head' => ' ,IFNULL(sum(sc.unique_sum), 0) AS cashbill_total ',
                'body' => ' LEFT JOIN (
                            SELECT
                                ld_salesorder.salesorderid,
                                ld_salesorder.potentialid,
                                ld_salesorder.deleted,
                                c.cashbillid
                                ' . $groupBy_col . '
                            FROM
                                ld_salesorder
                            LEFT JOIN (
                                SELECT
                                    ld_cashbill.cashbillid,
                                    ld_cashbill.total,
                                    IFNULL(
                                        ld_cashbill.conversion_rate,
                                        1
                                    ) AS conversion_rate,
                                    ld_cashbill.source_list,
                                    ld_paymentplan.entitytypeid AS paymentplan_salesorderid,
                                    ld_cashbill.deleted
                                FROM
                                    ' . $params['table_name'] . '
                                ' . $params['where'] . '
                                LEFT JOIN ld_cashbill2paymentplan ON ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID AND ld_cashbill2paymentplan.entitytype = \'PaymentPlan\'
                                LEFT JOIN ld_paymentplan ON ld_paymentplan.paymentplanid = ld_cashbill2paymentplan.entitytypeid AND ld_paymentplan.entitytype = \'SalesOrder\'
                                WHERE
                                    ld_cashbill.deleted = 0
                            ) c ON FIND_IN_SET(ld_salesorder.salesorderid,c.source_list) 
                            OR c.paymentplan_salesorderid = ld_salesorder.salesorderid
                            ' . $this->datarangesqlArr["datarangesql_SalesOrder"] . '
                            WHERE
                                ld_salesorder.deleted = 0
                            ' . $groupBy . '
                        ) sc ON sc.potentialid = p.potentialid ',
            ];
        }
        return ['head' => '', 'body' => ''];
    }
    public function setGetSQLType($type){
        $this->getSQLType = $type;
    }
}


