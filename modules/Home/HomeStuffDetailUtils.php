<?php
require_once globalStatic::$root_directory.'modules/Home/HomeParentUtils.php';
//zxm 20230731 首页默认组件的类---这是ld_homestuffdetail的组件
//重要的参数 $scopeType $senioruserid $search_date $stuffid $boardid $boardstuffid  $approve_value
class HomeStuffDetailUtils extends HomeParentUtils{
    public $sum_compute_type_arr = ['sum','max','min','avg'];
    public $count_compute_type_arr = ['count','ucount'];
    static public function getInstance(){

    }
    public function __construct($boardid)
    {
        parent::__construct($boardid);
    }

    //获取ld_homestuffdetail结果集  按看板按组件
    public function getHomeStuffDetailResult(){
        global $adb,$languageType;
        //新的看板
        if($this->boardid>0 || $this->boardid==-1) {
            $sql=" select ld_homestuffdetail.*,tmp.sequence from ld_homestuffdetail inner join ( 
                    select ld_homestuffdetail.stufflabel,ld_homestuffsaleskit2board.sequence from ld_homestuffdetail
                    inner join ld_homestuffsaleskit2board on ld_homestuffsaleskit2board.homestuffdetailid=ld_homestuffdetail.id
                        
                    where ld_homestuffdetail.stuffid=? and boardid=?
                    group by ld_homestuffdetail.stufflabel
                    ORDER BY boardid asc,ld_homestuffsaleskit2board.sequence asc,ld_homestuffdetail.stuffid asc)
                    as tmp on tmp.stufflabel=ld_homestuffdetail.stufflabel order by tmp.sequence asc";
            $result=$adb->pquery($sql,array($this->stuffid,$this->boardid));
        }else{
            $sql=" select * from ld_homestuffdetail
            where ld_homestuffdetail.presence='yes' and ld_homestuffdetail.stuffid=?
            ORDER BY ld_homestuffdetail.sequence asc,stufflabel asc;";
            $result=$adb->pquery($sql,array($this->stuffid));
        }
        return $result;
    }
    //获取简报数据
    public function getSalesKit(){
        global $adb,$languageType;
        $result = $this->getHomeStuffDetailResult();//获取ld_homestuffdetail结果集  按看板按组件
        $rows = $adb->num_rows($result);
        $saleskitlists = [];
        require_once(globalStatic::$root_directory."modules/Home/DataRangeHomeboard.php");
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        $param = [
            'boardid' => $this->boardid,
            'stuffid' => $this->stuffid,
            'boardstuffid' => $this->boardstuffid,
        ];
        $EqualDuration = (self::getSaleskitLayout($param))['EqualDuration'];

        $stuffDetailDateRangeArr = $DataRangeHomeboardObj->getHomeDateScope($this->search_date,$EqualDuration); //获取时间范围  返回的是一个数组
        for($i=0;$i<$rows;$i++) {
            $stufflabel = $adb->query_result($result, $i, 'stufflabel');
            $stufflabel_zh = $adb->query_result($result, $i, 'stufflabel_zh');
            $stufflabel_en = $adb->query_result($result, $i, 'stufflabel_en');
            $stufflabeltype = $adb->query_result($result, $i, 'stufflabeltype');
            $cssname = $adb->query_result($result, $i, 'cssname');
            $pageurl = $adb->query_result($result, $i, 'pageurl');
            $icon = $adb->query_result($result, $i, 'icon');
            $compute_columns=$adb->query_result($result,$i,'compute_columns');
            $compute_type=$adb->query_result($result,$i,'compute_type');
            $compute_module=$adb->query_result($result,$i,'compute_module');
            $viewrange = $adb->query_result($result, $i, 'viewrange');
            $daterange = $adb->query_result($result, $i, 'daterange');
            $advance_demand=$adb->query_result($result,$i,'advance_demand');
            //edit: xll 2023/08/17 BUG0071167 销售简报“线索升级到客户”、“线索升级到客户和销售机会”数据丢失
            $stufflabel_arr = ['LeadUgradeToPotentials','LeadUgradeToCustomerCount'];
            if(!empty($advance_demand) && in_array($stufflabel,$stufflabel_arr)) {
                crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
                $advance_demand = SalesKitEditSetting::getKis_no_FixedLabel($stufflabel,$advance_demand);
            }

            $advance_demand_groups=$adb->query_result($result,$i,'advance_demand_groups');
            $columns=explode('.',$compute_columns);
            //判断$compute_module为空的情况
            if(empty($compute_module)){
                //这个情况很少  直接写sql没多大影响
                $tmptablename =$columns[0];
                $tmpsql = 'select  `name` from ld_tab where main_tablename=? limit 1 ;';
                $tmpres = $adb->pquery($tmpsql,array($tmptablename));
                if($adb->num_rows($tmpres)>0){
                    $compute_module = $adb->query_result($tmpres,0,0);
                }
            }
            if(!vtlib_isModuleActive($compute_module)){
                //zxm 20230823 模块未激活 则这个简报不显示
                continue;
            }
            $saleskit_params = [
                'stuffid'=>$this->stuffid,
                'compute_module'=>$compute_module,//计算模块
                'scopeType'=>$this->scopeType,//查询范围类型
                'senioruserid'=>$this->senioruserid,//人员ID
                'date_adv'=>$stuffDetailDateRangeArr['date_adv'],//时间范围关键字
                'date_advbefore'=>$stuffDetailDateRangeArr['date_advbefore'],//时间范围关键字
                'datewhere'=>$stuffDetailDateRangeArr['datewhere'],//本期时间
                'before_datewhere'=>$stuffDetailDateRangeArr['before_datewhere'],//上期时间
                'approve_value'=> $this->approve_value,//审批条件
                'advance_demand'=>$advance_demand,
                'compute_columns'=>$compute_columns,
                'advance_demand_groups'=>$advance_demand_groups,
                'viewrange'=>$viewrange,//查看范围限制字段
                'daterange'=>$daterange,//日期字段限制字段
                'searchtype'=>'all',
            ];

            $DataRangeHomeboardObj->getDataRangeSqlSalesKit($saleskit_params);
            //inner join 子查询条件
            $where = $DataRangeHomeboardObj->datarangesqlArr['cur'];
            $before_where = $DataRangeHomeboardObj->datarangesqlArr['prev'];
            $before_where = empty($before_where)?$where:$before_where;
            if($prev_stufflabel!=$stufflabel){
                $totalvalue=0;
                $before_totalvalue=0;
                $totalvalue_echart =0 ;
                $before_totalvalue_echart = 0 ;
                $activemodules = [];
                $stufflabelurls = [];
            }
            $activemodules[] = $compute_module;
            $stufflabelurls[] = $pageurl;

            $currency_symbol = '';//金额字段需要加币种符号
            $from = $this->getFromClause($compute_module,$compute_columns);//获取from 表名
            $totalcolumn = $this->getTotalColumn($compute_module,$compute_columns,$compute_type,$currency_symbol);


            $query=" select $totalcolumn ".$from.$where;
            $before_query=" select $totalcolumn ".$from.$before_where;


            try {
                // 尝试执行可能会抛出异常的操作
                $total_result= $adb->pquery($query,array());
                $before_totalresult=$adb->pquery($before_query,array());
            } catch (Exception $e) {
                // 捕捉到异常，打印错误信息（或进行其他错误处理）
                $errorinfo =  $stufflabel_zh.": " . $e->getMessage() . "\n";
                $ret_data[$stufflabel] = array(
                    'value'=>0,
                    'formatValueInt'=>"0",//整数部分
                    'formatValueDecimal'=>"",//小数部分
                    'beforevalue'=>"0",
                    'percent'=>0,
                    'label'=>$stufflabel,
                    'stufflabel'=>$stufflabel,
                    'module'=>implode(",",$activemodules),
                    'css'=>$cssname,
                    'search_date'=>$this->search_date
                );
                // 继续下一个循环迭代
                continue;
            }
            if($adb->num_rows($total_result)>0){
                $totalvalue_echart = $totalvalue_echart + $adb->query_result($total_result,0,'totalvalue');
            }

            if($adb->num_rows($before_totalresult)>0){
                $before_totalvalue_echart = $before_totalvalue_echart + $adb->query_result($before_totalresult,0,'totalvalue');
            }

            if($stufflabel_zh=='')
            {
                $stufflabel_zh=getFixedLabel($stufflabel);

            }
            if($stufflabel_en=='')
            {
                $stufflabel_en=getFixedLabel($stufflabel);
            }
            if($languageType=='zh'){
                $label=$stufflabel_zh;
            }elseif($languageType=='en'){
                $label=$stufflabel_en;
            }

            $percent='100%';
            $percentstatus='red';
            if(!empty($before_totalvalue_echart)){

                $tmppercent=round(($totalvalue_echart-$before_totalvalue_echart)/$before_totalvalue_echart*100);

                $percent=$tmppercent . '%';
                if($totalvalue_echart<$before_totalvalue_echart){
                    $percentstatus='green';
                }elseif($totalvalue_echart==$before_totalvalue_echart){
                    $percentstatus='equation';
                }
            }
            if(empty($before_totalvalue_echart)&&empty($totalvalue_echart)){
                $percent='0%';
                $percentstatus='equation';

            }
            //返回两个变量 一个是整数部分 一个是小数部分 $tmpformatValueInt $tmpformatValueDecimal
            //edit: xll 2024/03/19 BUG20240318-50 求和非金额字段时无需小数位数
            if(in_array($compute_type,$this->sum_compute_type_arr) && !empty($currency_symbol)){
                $totalvalue=$currency_symbol.setNumberFormat($totalvalue_echart,$this->system_deploy_351);
                $before_totalvalue=$currency_symbol.setNumberFormat($before_totalvalue_echart,$this->system_deploy_351);

                $totalvalue_arr = explode('.',$totalvalue);
                $tmpformatValueInt = $totalvalue_arr[0];
                $tmpformatValueDecimal = empty($totalvalue_arr[1])?'':$totalvalue_arr[1];
            }else{
                $totalvalue=$totalvalue_echart;
                $before_totalvalue=$before_totalvalue_echart;

                $tmpformatValueInt = $totalvalue;
                $tmpformatValueDecimal = "";
                if(in_array($compute_type,$this->sum_compute_type_arr)){
                    //BUG20240724-05 zxm 20240724 首页->数据简报，“销售订单金额”组件的小数位数字的大小与其他组件小数位数字大小不一致（小数位数小一点为准）
                    //求和 但是没币种符号的
                    $totalvalue_arr = explode('.',$totalvalue);
                    $tmpformatValueInt = $totalvalue_arr[0];
                    $tmpformatValueDecimal = empty($totalvalue_arr[1])?'':$totalvalue_arr[1];
                }
            }

            $cssname = empty($cssname)?"item-ico-amount_one":$cssname;//小图标没值的话 给个默认值
            $icon = empty($icon)?"crm_SalesOrder.png":$icon;//小图标没值的话 给个默认值
            $ret_data[$stufflabel] = array(
                'value'=>$totalvalue,
                'formatValueInt'=>$tmpformatValueInt,//整数部分
                'formatValueDecimal'=>$tmpformatValueDecimal,//小数部分
                'beforevalue'=>$before_totalvalue,
                'percent'=>$percent,
                'percentstatus'=>$percentstatus,
                'stufflabel'=>$stufflabel,
                'beforelabel'=>$stuffDetailDateRangeArr['beforelabel'],
                'curlabel'=>$stuffDetailDateRangeArr['curlabel'],
                'module'=>implode(",",$activemodules),
                'css'=>$cssname,
                'label'=>html_entity_decode($label),
                'urls'=>implode(",",array_unique($stufflabelurls)),
                'icon'=>$icon,
                'totalvalue_echart'=>$totalvalue_echart,
                'before_totalvalue_echart'=>$before_totalvalue_echart,
                'search_date'=>$this->search_date
            );
            $prev_stufflabel = $stufflabel;
        }
        return $ret_data;
    }

    //获取简报数据--新增简报的时候，还未保存 需要从前端传值过来计算
    public function getSalesKitCreate($stuffdetailInfo){
        global $adb,$languageType;
        $computeinfo_arr = $stuffdetailInfo['computeinfo'];
        $saleskitlists = [];
        require_once(globalStatic::$root_directory."modules/Home/DataRangeHomeboard.php");
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        $param = [
            'boardid' => $this->boardid,
            'stuffid' => $this->stuffid,
            'boardstuffid' => $this->boardstuffid,
        ];
        $EqualDuration = (self::getSaleskitLayout($param))['EqualDuration'];

        $stuffDetailDateRangeArr = $DataRangeHomeboardObj->getHomeDateScope($this->search_date,$EqualDuration); //获取时间范围  返回的是一个数组
        foreach($computeinfo_arr as $computeinfo){
            $stufflabel = $stuffdetailInfo['stufflabel'];
            $stufflabel_zh = $stuffdetailInfo['zh'];
            $stufflabel_en = $stuffdetailInfo['en'];

            $cssname = $stuffdetailInfo['css'];
            $icon = $stuffdetailInfo['icon'];
            $compute_columns=$computeinfo['computecolumns'];
            $compute_type=$computeinfo['computetype'];
            $compute_module=$computeinfo['computemodule'];
            $viewrange = $computeinfo['viewrange_isrelated']==true?$computeinfo['viewrange']:"";
            $daterange = $computeinfo['daterange_isrelated']==true?$computeinfo['daterange']:"";
            $advance_demand=$computeinfo['advance_demand'];
            $advance_demand_groups=$computeinfo['advance_demand_groups'];

            $saleskit_params = [
                'stuffid'=>$this->stuffid,
                'compute_module'=>$compute_module,//计算模块
                'scopeType'=>$this->scopeType,//查询范围类型
                'senioruserid'=>$this->senioruserid,//人员ID
                'date_adv'=>$stuffDetailDateRangeArr['date_adv'],//时间范围关键字
                'date_advbefore'=>$stuffDetailDateRangeArr['date_advbefore'],//时间范围关键字
                'datewhere'=>$stuffDetailDateRangeArr['datewhere'],//本期时间
                'before_datewhere'=>$stuffDetailDateRangeArr['before_datewhere'],//上期时间
                'approve_value'=> $this->approve_value,//审批条件
                'advance_demand'=>$advance_demand,
                'compute_columns'=>$compute_columns,
                'advance_demand_groups'=>$advance_demand_groups,
                'viewrange'=>$viewrange,//查看范围限制字段
                'daterange'=>$daterange,//日期字段限制字段
                'searchtype'=>'all',
            ];

            $DataRangeHomeboardObj->getDataRangeSqlSalesKit($saleskit_params);
            //inner join 子查询条件
            $where = $DataRangeHomeboardObj->datarangesqlArr['cur'];
            $before_where = $DataRangeHomeboardObj->datarangesqlArr['prev'];
            $before_where = empty($before_where)?$where:$before_where;
            if($prev_stufflabel!=$stufflabel){
                $totalvalue=0;
                $before_totalvalue=0;
                $totalvalue_echart =0 ;
                $before_totalvalue_echart = 0 ;
                $activemodules = [];
                $stufflabelurls = [];
            }
            $activemodules[] = $compute_module;

            $currency_symbol = '';//金额字段需要加币种符号
            $from = $this->getFromClause($compute_module,$compute_columns);//获取from 表名
            $totalcolumn = $this->getTotalColumn($compute_module,$compute_columns,$compute_type,$currency_symbol);
            $query=" select $totalcolumn ".$from.$where;
            $before_query=" select $totalcolumn ".$from.$before_where;


            try {
                // 尝试执行可能会抛出异常的操作
                $total_result= $adb->pquery($query,array());
                $before_totalresult=$adb->pquery($before_query,array());
            } catch (Exception $e) {
                // 捕捉到异常，打印错误信息（或进行其他错误处理）
                $errorinfo =  $stufflabel_zh.": " . $e->getMessage() . "\n";
                $ret_data[$stufflabel] = array(
                    'value'=>0,
                    'label'=>$errorinfo
                );
                // 继续下一个循环迭代
                continue;
            }


            if($adb->num_rows($total_result)>0){
                $totalvalue_echart = $totalvalue_echart + $adb->query_result($total_result,0,'totalvalue');
            }
            if($adb->num_rows($before_totalresult)>0){
                $before_totalvalue_echart = $before_totalvalue_echart + $adb->query_result($before_totalresult,0,'totalvalue');
            }

            if($stufflabel_zh=='')
            {
                $stufflabel_zh=getFixedLabel($stufflabel);

            }
            if($stufflabel_en=='')
            {
                $stufflabel_en=getFixedLabel($stufflabel);
            }
            if($languageType=='zh'){
                $label=$stufflabel_zh;
            }elseif($languageType=='en'){
                $label=$stufflabel_en;
            }

            $percent='100%';
            $percentstatus='red';
            if(!empty($before_totalvalue_echart)){

                $tmppercent=round(($totalvalue_echart-$before_totalvalue_echart)/$before_totalvalue_echart*100);

                $percent=$tmppercent . '%';
                if($totalvalue_echart<$before_totalvalue_echart){
                    $percentstatus='green';
                }elseif($totalvalue_echart==$before_totalvalue_echart){
                    $percentstatus='equation';
                }
            }
            if(empty($before_totalvalue_echart)&&empty($totalvalue_echart)){
                $percent='0%';
                $percentstatus='zero';

            }
            //返回两个变量 一个是整数部分 一个是小数部分 $tmpformatValueInt $tmpformatValueDecimal
            //edit: xll 2024/03/19 BUG20240318-50 求和非金额字段时无需小数位数
            if($compute_type=='sum' && !empty($currency_symbol)){
                $totalvalue=$currency_symbol.setNumberFormat($totalvalue_echart,$this->system_deploy_351);
                $before_totalvalue=$currency_symbol.setNumberFormat($before_totalvalue_echart,$this->system_deploy_351);
                $totalvalue_arr = explode('.',$totalvalue);
                $tmpformatValueInt = $totalvalue_arr[0];
                $tmpformatValueDecimal = empty($totalvalue_arr[1])?'':$totalvalue_arr[1];
            }else{
                $totalvalue=$totalvalue_echart;
                $before_totalvalue=$before_totalvalue_echart;
                $tmpformatValueInt = $totalvalue;
                $tmpformatValueDecimal = "";
                if($compute_type=='sum'){
                    //BUG20240724-05 zxm 20240724 首页->数据简报，“销售订单金额”组件的小数位数字的大小与其他组件小数位数字大小不一致（小数位数小一点为准）
                    //求和 但是没币种符号的
                    $totalvalue_arr = explode('.',$totalvalue);
                    $tmpformatValueInt = $totalvalue_arr[0];
                    $tmpformatValueDecimal = empty($totalvalue_arr[1])?'':$totalvalue_arr[1];
                }
            }

            $cssname = empty($cssname)?"item-ico-amount_one":$cssname;//小图标没值的话 给个默认值
            $icon = empty($icon)?"crm_SalesOrder.png":$icon;//小图标没值的话 给个默认值
            $ret_data[$stufflabel] = array(
                'value'=>$totalvalue,
                'formatValueInt'=>$tmpformatValueInt,//整数部分
                'formatValueDecimal'=>$tmpformatValueDecimal,//小数部分
                'beforevalue'=>$before_totalvalue,
                'percent'=>$percent,
                'percentstatus'=>$percentstatus,
                'stufflabel'=>$stufflabel,
                'beforelabel'=>$stuffDetailDateRangeArr['beforelabel'],
                'curlabel'=>$stuffDetailDateRangeArr['curlabel'],
                'module'=>implode(",",$activemodules),
                'css'=>$cssname,
                'label'=>html_entity_decode($label),
                'urls'=>implode(",",array_unique($stufflabelurls)),
                'icon'=>$icon,
                'totalvalue_echart'=>$totalvalue_echart,
                'before_totalvalue_echart'=>$before_totalvalue_echart,
                'search_date'=>$this->search_date
            );
            $prev_stufflabel = $stufflabel;
        }
        return $ret_data;
    }

    //龙虎榜数据查询方法，用于echarts展示
    public function getDragonTigerListData($StuffParams)
    {
        global $adb,$languageType;
        //单据分录明细金额字段和单据头货币字段小数位数
        $system_deploy_351 = $this->system_deploy_351;

        $StuffDetailLabel = $StuffParams['data_type'];
        setUsersettingByLabel('Home','','DragonTigerList_PageTab',$StuffDetailLabel);
        $stuffid = $StuffParams['stuffid'];
        $boardid = $StuffParams['boardid'];
        $scopeType = $StuffParams['scopeType'];
        $senioruserid = $StuffParams['senioruserid'];
        $search_date = $StuffParams['search_date'];
        $approve_value = $StuffParams['approve_value'];
        $datewhere = getHomeDateScope($search_date);

        $sql = ' select * from ld_homestuffdetail
            where stuffid=? and ld_homestuffdetail.stufflabel = ?;';

        $result=$adb->pquery($sql,array($stuffid,$StuffDetailLabel));
        $rows=$adb->num_rows($result);
        crm_load_class_file('DataRangeHomeboard','modules/Home/');

        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
        $stuffDetailDateRangeArr = $DataRangeHomeboardObj->getHomeDateScope($search_date,'no');
        $StuffDetailColumnnameArr = ['id','stufflabel','stufflabel_zh','stufflabel_en','stufflabeltype','cssname',
            'pageurl','icon','compute_columns','compute_type','compute_module','viewrange','daterange',
            'is_default','advance_demand','advance_demand_groups','topnumber','groupby'];
        $totalvalue = [];
        $totalvalue_echart = [] ;
        $activemodules = [];

        $sqlSet = "select type,setvalue from ld_homestuffdetail_setting where homestuffdetailid=?;";

        $platesetting =  $this->getPlateSetting($stuffid);//看板其他设置
        $datalabel = $platesetting['datalabel'];
        $datalabel = empty($datalabel)?'inside':$datalabel;//没设置过  那就是居中显示

        for($i=0;$i<$rows;$i++) {
            $StuffDetailParams = [];
            $StuffDetailParams['SetValue'] = ['showZero'=>false,'can_penetrate'=>true];

            foreach ($StuffDetailColumnnameArr as $columnname){
                $StuffDetailParams[$columnname] = $adb->query_result($result, $i, $columnname);
            }

            $setValRes = $adb->pquery($sqlSet,[$StuffDetailParams['id']]);
            for ($j = 0; $j < $adb->num_rows($setValRes); $j ++) {
                $setType = $adb->query_result($setValRes, $j, 'type');
                $setVal = $adb->query_result($setValRes, $j, 'setvalue');
                $StuffDetailParams['SetValue'][$setType] = $setVal;
            }

            $compute_columns = $StuffDetailParams['compute_columns'];
            $compute_module = $StuffDetailParams['compute_module'];

            //模块激活判断
            if(!vtlib_isModuleActive($compute_module)){
                continue;
            }


            $viewrange = $StuffDetailParams['viewrange'];
            $pageurl = $StuffDetailParams['pageurl'];
            $compute_type = $StuffDetailParams['compute_type'];
            $stufflabel_zh = $StuffDetailParams['stufflabel_zh'];
            $stufflabel_en = $StuffDetailParams['stufflabel_en'];
            $topnumber = $StuffDetailParams['topnumber'];
            $advance_demand = $StuffDetailParams['advance_demand'];
            $showZero = $StuffDetailParams['SetValue']['showZero'];
            $can_penetrate = $StuffDetailParams['SetValue']['can_penetrate'];
            $groupby = $StuffDetailParams['groupby'];
            //edit: xll 2023/08/17 BUG0071167 销售简报“线索升级到客户”、“线索升级到客户和销售机会”数据丢失
            $stufflabel_arr = ['dragontiger_NewLeadUgradeToCustomerCount'];
            if(!empty($advance_demand) && in_array($StuffDetailLabel,$stufflabel_arr)) {
                crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
                $advance_demand = SalesKitEditSetting::getKis_no_FixedLabel($StuffDetailLabel,$advance_demand);
            }
            $columns=explode('.',$compute_columns);
            //判断$compute_module为空的情况
            if(empty($compute_module)){
                //这个情况很少  直接写sql没多大影响
                $tmptablename =$columns[0];
                $tmpsql = 'select  `name` from ld_tab where main_tablename=? limit 1 ;';
                $tmpres = $adb->pquery($tmpsql,array($tmptablename));
                if($adb->num_rows($tmpres)>0){
                    $compute_module = $adb->query_result($tmpres,0,0);
                }
            }

            $tmp_focus =  CRMEntity::getInstance($compute_module);
            $moduleAllPreseneceFields_main = $tmp_focus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
            $moduleAllPreseneceFields_detail = [];
            if($tmp_focus->detailfieldobj){
                $moduleAllPreseneceFields_detail= $tmp_focus->detailfieldobj->getModuleAllPreseneceFields();
            }
            $moduleAllPreseneceFields = array_merge($moduleAllPreseneceFields_main,$moduleAllPreseneceFields_detail);

            $DataRangeParams = [
                'stuffid'=>$stuffid,
                'compute_module'=>$compute_module,//计算模块
                'compute_columns'=>$compute_columns,
                'scopeType'=>$scopeType,//查询范围类型
                'senioruserid'=>$senioruserid,//人员ID
                'date_adv'=>$stuffDetailDateRangeArr['date_adv'],//时间范围关键字
                'datewhere'=>$datewhere,//本期时间
                'approve_value'=>$approve_value,//审批条件
                'advance_demand'=>$advance_demand,
                'advance_demand_groups'=>$StuffDetailParams['advance_demand_groups'],
                'viewrange'=>$StuffDetailParams['viewrange'],//查看范围限制字段
                'daterange'=>$StuffDetailParams['daterange'],//日期字段限制字段
                'searchtype'=>'now',
            ];
            if($stuffid==100){
                //数据龙虎榜  数据范围跟着ld_homestuffdetail来
                $whereSql = $DataRangeHomeboardObj->getDataRangeSqlSalesKit($DataRangeParams)['cur'];
                $where = $DataRangeHomeboardObj->datarangesqlArr['cur'];
            }else{
                //zxm 20231115 102 103 104 数据范围根据ld_homeboard_plate_filter来
                //$report_id,$boardstuffid,$scopeType,$senioruserid,$date_search,$_REQUEST['approve_value'],'customreport'
                $whereArr = $DataRangeHomeboardObj->getDataRangeSql($stuffid,0,$scopeType,$senioruserid,$datewhere,$approve_value,'defaultstuff');
                $whereSql = is_array($whereArr[$compute_module])?$whereArr[$compute_module]['cur']:'';
                $where = $DataRangeHomeboardObj->datarangesqlArr['datarangesql_'.$compute_module];
            }
            $currency_symbol = '';//金额字段需要加币种符号
            $totalCol = $this->getTotalColumn($compute_module,$compute_columns,$compute_type,$currency_symbol);
            $smowneridcolumnname=$tmp_focus->getSmownerColumName();
            $smowneridtablename = $tmp_focus->table_name;
            $otherColArr = [];
            //分组字段--统计维度
            if(!empty($groupby)){
                $groupby_arr = explode(':',$groupby);
                //判断该字段是否存在 是否删除--todo --
                if(isset($moduleAllPreseneceFields[$groupby_arr[2]])) {
                    $smowneridcolumnname = $groupby_arr[1];
                    $smowneridtablename = $groupby_arr[0];
                    array_push($otherColArr, $groupby);
                }
            }

            $from = $this->getFromClause($compute_module,$compute_columns, $otherColArr);

            $groupBysql = ' GROUP BY '.$smowneridcolumnname;

            $activemodules[] = $compute_module;

            $userCol = 'userid';
            $othercolumnname = ", $smowneridtablename.$smowneridcolumnname ";
            $query="select $totalCol $othercolumnname $from $where $groupBysql";

            $query_str = "select 
	ifnull(sales.totalvalue,0)as totalvalue,
	ld_users.id AS userid,
	ld_users.last_name,
	ld_users.real_name,
	tmp_users2groups.groupnamestr
from ld_users 
LEFT JOIN (
	SELECT
		ld_users2group.userid,
		GROUP_CONCAT(groupname SEPARATOR ',') AS groupnamestr,
		GROUP_CONCAT(realgroupname SEPARATOR ',') AS realgroupnamestr
	FROM
		ld_users2group
	LEFT JOIN ld_groups ON ld_users2group.groupid = ld_groups.groupid
	GROUP BY
		ld_users2group.userid
	ORDER BY
		ld_users2group.userid
) tmp_users2groups ON tmp_users2groups.userid = ld_users.id
left join(".$query.")sales on sales.$smowneridcolumnname=ld_users.id ";
            $query_str .= " where 1=1 ";
            if($showZero!='yes'){
                $query_str .= " and sales.totalvalue>0 ";
            }
            // 龙虎榜的Y轴刻度没有根据筛选器的选择来显示
            if(!empty($senioruserid)&&!empty($viewrange)){
                $query_str .= " and find_in_set(ld_users.id,'$senioruserid') ";
            }
            $query_str .= "ORDER BY
                totalvalue DESC ";
            //edit: xll 2024/07/19 BUG20240718-60 龙虎榜排序问题
            //LIMIT ".$topnumber;

            //zxm 20240425 按统计值为0修改 SQL的格式为 select from ld_users 连用户部门表子查询 连统计值查询子查询 where 统计值是否大于0 order by 统计值 limit
            try {
                // 尝试执行可能会抛出异常的操作
                $total_result= $adb->pquery($query_str,array());
            } catch (Exception $e) {
                // 捕捉到异常，打印错误信息（或进行其他错误处理）
                $errorinfo =  $stufflabel_zh.": " . $e->getMessage() . "\n";
                $ret_data[$StuffDetailLabel] = array(
                    'value'=>0,
                     'label'=>$errorinfo
                );
                // 继续下一个循环迭代
                continue;
            }

            $num_rows = $adb->num_rows($total_result);
            if($num_rows>0){
                for ($k = 0; $k < $num_rows; $k++){
                    $userid =  $adb->query_result($total_result,$k,$userCol);
                    $totalvalue_echart[$userid] = isset($totalvalue_echart[$userid]) ? $totalvalue_echart[$userid] : 0;
                    $totalvalue[$userid] = $totalvalue_echart[$userid] + $adb->query_result($total_result,$k,'totalvalue');
                    $groupnameKey = (isKehu001ServerPc() == 'yes') ? 'realgroupnamestr':'groupnamestr';//kehu001 获取真实部门名称
                    $groupname_arr[$userid] = $adb->query_result($total_result,$k,$groupnameKey);
                    $username_arr[$userid]['last_name'] = $adb->query_result($total_result,$k,'last_name');
                    $username_arr[$userid]['real_name'] = $adb->query_result($total_result,$k,'real_name');
                    $totalvalue_echart[$userid]=$totalvalue[$userid];

                    if($compute_type=='sum'){
                        $totalvalue[$userid]='￥'.setNumberFormat($totalvalue[$userid],$system_deploy_351);
                    }
                }
            }


            $stufflabel_zh = (empty($stufflabel_zh)) ? getFixedLabel($StuffDetailLabel) : '';
            $stufflabel_en = (empty($stufflabel_en)) ? getFixedLabel($StuffDetailLabel) : '';
            $label = ($languageType=='zh') ? $stufflabel_zh : $stufflabel_en;

            $ret_data[$StuffDetailLabel] = array(
                'value'=>$totalvalue,
                'stufflabel'=>$StuffDetailLabel,
                'module'=>implode(",",$activemodules),
                'label'=>$label,
                'totalvalue_echart'=>$totalvalue_echart,
                'groupname_arr'=>$groupname_arr,
                'username_arr'=>$username_arr,
                'topnumber'=>$topnumber,
                'search_date'=>$search_date
            );
        }
        if($rows >= 1)
            arsort($totalvalue_echart,SORT_NUMERIC);
        //edit: xll 2024/07/19 BUG20240718-60 龙虎榜排序问题
        $UserInfo = [];
        $UseridArr = [];
        $UserdataArr = [];
        $UserdataStringArr = [];//千分位格式化的值  用来显示的 zxm 20240628
        $user_groupname_arr = $ret_data[$StuffDetailLabel]['groupname_arr'];
        $user_username_arr = $ret_data[$StuffDetailLabel]['username_arr'];
        $usernameKey = (isKehu001ServerPc() == 'yes') ? 'real_name':'last_name';
        $icon_dir_file = getGlobalImageUrl().'themes/icon2024/topIcon/';

        $count = 1;
        foreach ($totalvalue_echart as $user_id => &$user_data){
            if($count > $topnumber)
                break;
            $UserInfo[$user_id]['groupname'] = $user_groupname_arr[$user_id];
            $UserInfo[$user_id]['username'] = $user_username_arr[$user_id][$usernameKey];
            //暂时只有前十有图片
            if($count <= 10)
                $UserInfo['icon'][] = $icon_dir_file.$count.'.png';
            $count++;
            $UseridArr['id'][] = $user_id;
            if($compute_type=='sum') {
                $user_data = round($user_data,$system_deploy_351);
                $UserdataStringArr[] = number_format($user_data, $system_deploy_351);
            }
            else {
                $UserdataStringArr[] = number_format($user_data, 0);
            }
            $UserdataArr[] = $user_data;
        }
        //数据不足成员数量$topnumber，则填充空值
        $number = !empty($UseridArr['id'])?count($UseridArr['id']):0;
        for ($number; $number < $topnumber; $number++){
            $UseridArr['empty'][] = '';
        }
        $UserInfo['sortIcon']['path'] = 'path://M600.436364 60.509091v907.636364c0 27.927273 18.618182 46.545455 46.545454 46.545454s46.545455-18.618182
         46.545455-46.545454V158.254545l116.363636 93.09091c18.618182 18.618182 51.2 13.963636 65.163636-4.654546 18.618182-18.618182
          13.963636-51.2-4.654545-65.163636L679.563636 23.272727c-32.581818-27.927273-79.127273-4.654545-79.127272 37.236364zM377.018182
           9.309091c-27.927273 0-46.545455 18.618182-46.545455 46.545454v809.89091l-116.363636-93.09091c-18.618182-18.618182-51.2-13.963636-65.163636
            4.654546-18.618182 18.618182-13.963636 51.2 4.654545 65.163636l190.836364 158.254546c32.581818 23.272727 74.472727 4.654545
             74.472727-37.236364V55.854545c4.654545-23.272727-18.618182-46.545455-41.890909-46.545454z';
        $UserInfo['sortIcon']['fill'] = '#31394C';
        if(isset($StuffDetailParams['showIcon'])&&$StuffDetailParams['showIcon']=='no'){
            //移动端不返回图标数据
            unset($UserInfo['icon']);
            unset($UserInfo['sortIcon']);
        }
        $ret_data[$StuffDetailLabel]['totalvalue_echart'] = $totalvalue_echart;
        $ret_data[$StuffDetailLabel]['ChartRowHeight'] = 52;
        $ret_data[$StuffDetailLabel]['userinfo'] = $UserInfo;
        $ret_data[$StuffDetailLabel]['userid_arr'] = $UseridArr;
        $ret_data[$StuffDetailLabel]['userdata_arr'] = $UserdataArr;
        $ret_data[$StuffDetailLabel]['UserdataStringArr'] = $UserdataStringArr;

        $ret_data[$StuffDetailLabel]['can_penetrate'] = $can_penetrate;
        $ret_data[$StuffDetailLabel]['datalabel'] = $datalabel;
        return $ret_data[$StuffDetailLabel];
    }

    //根据统计模块 统计字段 拼接 from 字符串
    public function getFromClause($compute_module,$compute_columns, $otherColArr = []){
        $tmp_focus = CRMEntity::getInstance($compute_module);
        $from = ' from ' . $tmp_focus->table_name;

        $tmptablename = explode('.',$compute_columns)[0]; //$compute_columns格式是ld_salesorder.salesorder_no
        $leftjoinsql_arr[] = $this->getLeftJoinFrom($compute_module,$tmptablename);

        foreach ($otherColArr as $col) {
            $colArr = explode(':',$col);
            $tmpModule = explode('_',$colArr[3])[0];
            $tmpTable = $colArr[0];
            $leftjoinsql_arr[] = $this->getLeftJoinFrom($tmpModule,$tmpTable);
        }
        $leftjoinsql = implode(' ' ,array_unique($leftjoinsql_arr));
        $from .= $leftjoinsql;
        return $from;
    }

    public function getLeftJoinFrom($tmpModule,$tmpTable) {
        $leftjoinsql = '';
        $tmp_focus = CRMEntity::getInstance($tmpModule);
        if($tmp_focus->customFieldTable[0]==$tmpTable){
            //统计字段是主表自定义表
            $tmp_scftableleft = ' left join '.$tmp_focus->customFieldTable[0]
                .' on '.$tmp_focus->customFieldTable[0].'.'.$tmp_focus->customFieldTable[1]
                .'='.$tmp_focus->table_name.'.'.$tmp_focus->table_index;
            $leftjoinsql.=$tmp_scftableleft;
        }
        //统计字段是明细表主表或者产品表(引用产品属性)
        else if($tmp_focus->Detail_table==$tmpTable || (in_array($tmpTable,['ld_products','ld_productcf'])&&$tmpModule!='Products')){
            $tmp_detailtableleft = ' left join '.$tmp_focus->Detail_table
                .' on '.$tmp_focus->Detail_table.'.'.$tmp_focus->Detail_table_index
                .'='.$tmp_focus->table_name.'.'.$tmp_focus->table_index;
            $leftjoinsql.=$tmp_detailtableleft;
            //edit: xll 2024/02/22 BUG20240218-29 计数产品名称，需要连接明细表和产品表
            if($tmpTable === 'ld_products') {
                $leftjoinsql .= " LEFT JOIN ld_products ON ld_products.productid = $tmp_focus->Detail_table.productid ";
            }
            if($tmpTable === 'ld_productcf') {
                $leftjoinsql .= " LEFT JOIN ld_productcf ON ld_productcf.productid = $tmp_focus->Detail_table.productid ";
            }
        }
        //统计字段是明细表自定义表
        else if($tmp_focus->Detail_table_scf==$tmpTable){
            $tmp_detailtableleft = ' left join '.$tmp_focus->Detail_table
                .' on '.$tmp_focus->Detail_table.'.'.$tmp_focus->Detail_table_index
                .'='.$tmp_focus->table_name.'.'.$tmp_focus->table_index;
            $tmp_detailscfleft = ' left join '.$tmp_focus->Detail_table_scf.' on '.$tmp_focus->Detail_table_scf.'.'.$tmp_focus->Detail_table_id.'='.$tmp_focus->Detail_table.'.'.$tmp_focus->Detail_table_id;
            $leftjoinsql.=$tmp_detailtableleft;
            $leftjoinsql.=$tmp_detailscfleft;
        }
        return $leftjoinsql;
    }


    //获取统计字段 -- NewSalesOrderReceipts NewServiceContractsReceipts NewPaymentPlanCashBillAmount 这三个之前的判断去掉了 需要特殊测试下
    public function getTotalColumn($compute_module,$compute_columns,$compute_type,&$currency_symbol){
        $totalcolumn = '';
        $tmp_focus = CRMEntity::getInstance($compute_module);
        $columns = explode('.',$compute_columns);//$compute_columns格式是ld_salesorder.salesorder_no
        $tmptablename = $columns[0];

        if(in_array($compute_type,$this->count_compute_type_arr))
        {
            $compute_type_func = $compute_type=='count'? 'count(':'count( distinct ';
            $totalcolumn = $compute_type_func.'ifnull('.$compute_columns.',1) ) as totalvalue ';
        }
        else if(in_array($compute_type,$this->sum_compute_type_arr)){
            if(array_key_exists($tmptablename,$tmp_focus->tab_name_index))
                $fieldinfo=$tmp_focus->fieldobj->getFieldInfoobjBykey("columnname",$columns[1]);
            else{
                //zkt 20240129 BUG20240129-04 数据简报模块乱码
                if(!empty($tmp_focus->detailfieldobj)){
                    $fieldinfo=$tmp_focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columns[1]);
                }
            }
            if($fieldinfo&&($fieldinfo->getBigType()=="currency"||$fieldinfo->getBigType()=='amount')){
                $currency_symbol = '￥';
                if(isHaveCurrrencyColumn($tmp_focus->module_name)=='yes')
                {
                    $totalcolumn = " ifnull($compute_type(if(".$tmp_focus->table_name.".currency_id >1,IFNULL($compute_columns,0)/".$tmp_focus->table_name.
                        ".conversion_rate,IFNULL($compute_columns,0))),0) as totalvalue";
                }else{
                    //zxm 20240702 bigtype是currency或者amount 但是没有币种字段  币种符号取￥，不转换币种
                    $totalcolumn = "$compute_type(IFNULL($compute_columns,0)) as totalvalue ";
                }
            }
            else{
                //edit:can 2020-09-29 42825: 首页组件-销售简报扩展需求：根据字段类型统计，如果是不是货币字段，则不需要再根据币种转换
                $totalcolumn = "$compute_type(IFNULL($compute_columns,0)) as totalvalue ";
            }
        }
        return $totalcolumn;
    }
    public static function getSaleskitLayout($param) {
        crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
        $salesKitSetObj = SalesKitEditSetting::getInstance($param['boardid']);
        $salesKitSetObj->setStuffId($param['stuffid']);
        $salesKitSetObj->setBoardStuffId($param['boardstuffid']);
        return $salesKitSetObj->getSaleskitLayout($param['count']);
    }
}


