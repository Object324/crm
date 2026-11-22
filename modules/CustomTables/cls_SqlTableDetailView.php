<?php
//SQL报表查看的类
class cls_SqlTableDetailView
{
    public $CustomTablesActionsObj;
    public $limit = 200;
    public $report_id;
    public $params;

    public function __construct($params){
        $report_id = $params['report_id'];
        $this->report_id=$report_id;
        $this->params=$params;
        include_once globalStatic::$root_directory.'modules/CustomTables/CustomTablesActions.php';
        $this->CustomTablesActionsObj = new CustomTablesActions();
    }
    public function index(){
        $report_id = $this->report_id;
        $params = $this->params;
        $this->CustomTablesActionsObj->smarty->assign("report_id",$report_id);
        //报表信息
        $reportInfo = $this->CustomTablesActionsObj->getReportInfo($report_id);
        $this->CustomTablesActionsObj->smarty->assign("report_info",$reportInfo);

        if($params['limitrecord'])
        {
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$params['limitrecord']);
        }
        else{
            $this->CustomTablesActionsObj->smarty->assign("LimitRecord",$this->limit);

        }

        $templatename = 'detailviewsql.tpl';
        //返回变量
        $filterArr = $this->CustomTablesActionsObj->getSqlFilter($report_id);
        $filterArr = $this->setVarDefaultValue($filterArr);//设置变量的默认值
        if($params['frommobile']=='yes'){
            //移动端一行显示一个条件
            $filterArr = array_chunk($filterArr,1);
        }else{
            $filterArr = array_chunk($filterArr,2);
        }

        $this->CustomTablesActionsObj->smarty->assign("filterArr",$filterArr);
        $this->CustomTablesActionsObj->smarty->assign("mode",'detail');
        $this->CustomTablesActionsObj->smarty->assign("iskehu001",isKehu001ServerPc());
        $this->CustomTablesActionsObj->smarty->assign("frommobile",$params['frommobile']);
        if($params['frommobile']=='yes'){
            //移动端查看页
            $corpurl_all = getCorpUrl();
            $corpurl_arr = explode('WeiXinApp',$corpurl_all);

            $this->CustomTablesActionsObj->smarty->assign("JSURL",$corpurl_arr[0]);
            $this->CustomTablesActionsObj->smarty->assign("CSSURL",$corpurl_arr[0]);
            $this->CustomTablesActionsObj->smarty->assign("CRMCOMMONURL",$corpurl_arr[0]);
            //zxm 20230423 app端的判断
            global $PlatformMC;
            if(is_array($PlatformMC) && array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
            {
                $encryptobj=new cls_MyCRMcrypt();
                $this->CustomTablesActionsObj->smarty->assign("wx_userid",$encryptobj->encode($params['userid']));
                $this->CustomTablesActionsObj->smarty->assign("appusertoken",$params['appusertoken']);
            }else{
                $this->CustomTablesActionsObj->smarty->assign("wx_userid",$params['userid']);
            }
            //来自移动端
            global $weixin_user;
            if($weixin_user->environment=='wxwork'||$weixin_user->environment=='weixin'){
                //小程序
                $homefile = "index_mini.php";
            }else if(is_array($PlatformMC) && array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes') {
                //app
                $homefile = "indexnative.php";
            }else{
                //企业微信
                //云之家
                //钉钉
                $homefile = "index.php";
            }
            $this->CustomTablesActionsObj->smarty->assign("homefile",$homefile);
        }
        //edit:duan date:2024/11/16 reason:将审批状态更改为翻译字段，并增加颜色显示
        $approve_list = getHomeApproveList();
        $this->CustomTablesActionsObj->smarty->assign("ApproveList",$approve_list);

        if($params['isAjax']=="no"){
            $this->CustomTablesActionsObj->smarty->assign("isAjax",$params['isAjax']);
            $this->CustomTablesActionsObj->smarty->display('CustomTables/'.$templatename);
        }else{
            $content = $this->CustomTablesActionsObj->smarty->fetch('CustomTables/'.$templatename);
            $params['diony']='diony';
            $res['content'] = $content;
            $res['permit_print'] = isPermitted('ReportAnalysis','Print');
            $res['permit_export'] = isPermitted('ReportAnalysis','Export');
            $res['permit_create'] = isPermitted('ReportAnalysis','Create');
            $res['title'] = $reportInfo['report_name'];
            ConvertTojsonString(1,$res,'success');
        }

    }

    public function setVarDefaultValue($filterArr){
        global $current_user;
        //时间默认值
        foreach($filterArr as $k=>$filterline){
            $tmp_var_type = $filterline['var_type'];
            $filterArr[$k]['default_value_actual'] = $filterline['default_value'];
            //时间
            if($tmp_var_type=='date'||$tmp_var_type=='datetime'){
                $this->setVarDateDefaultValue($filterArr,$k);
            }
            //下拉框
            if($tmp_var_type=='select'||$tmp_var_type=='multiselect'){
                $filterArr[$k]['select_values_arr'] = explode(',',$filterline['selectvalues']);
            }
            //多选框
            if($tmp_var_type=='multiselect'){
                $filterArr[$k]['default_values_arr'] = explode(',',$filterline['default_value']);
            }
            //用户组件
            if($tmp_var_type=='multiuser'){
                $this->setVarMultiuserDefaultValue($filterArr,$k);
            }
            //审批组件的默认值
            if($tmp_var_type=='approvestatus'){
                $this->setVarApprovestatusDefaultValue($filterArr,$k);
            }
            //部门组件
            if($tmp_var_type=='department'){
                //$default_value = $filterline['default_value'];//  这个变量的默认值应该根据用户的数据范围所属的部门id决定 具体判断见方法$filterline
                $groupids_arr = $this->getGroupIds($filterline);
                $filterArr[$k]['default_value'] = $groupids_arr['groupid_str'];
                $filterArr[$k]['groupnames_str'] = empty($groupids_arr['groupname_str'])?'':$groupids_arr['groupname_str'];
            }
            //当前操作员
            if($tmp_var_type=='curroperator'){
                //判断kf001  用真实姓名
                $filterArr[$k]['default_value'] = isKehu001ServerPc()=='yes'?$current_user->real_name:$current_user->last_name;
            }
        }
        return $filterArr;
    }

    public function setVarDateDefaultValue(&$filterArr,$k){
        $filterline = $filterArr[$k];
        $tmp_var_type = $filterline['var_type'];
        $default_value = $filterline['default_value'];
        $default_value_arr = explode(',',$default_value);
        if($default_value_arr[0]=='selfdefined'){
            $filterArr[$k]['default_value_actual'] = $default_value_arr[1];
        }else{
            $filterArr[$k]['default_value_actual'] = $this->CustomTablesActionsObj->getFilterDefaultValue($default_value_arr[0]);
        }
        if($tmp_var_type=='date'){
            $filterArr[$k]['default_value_actual'] = substr( $filterArr[$k]['default_value_actual'],0,10);
        }
    }
    public function setVarMultiuserDefaultValue(&$filterArr,$k){
        $filterline = $filterArr[$k];
        $filterArr[$k]['default_values_arr'] = explode(',',$filterline['default_value']);
        $scopeobj = new ScopOfAuthority($this->CustomTablesActionsObj->adb,$filterline['modulename']);
        $tmp_default_value = $scopeobj->getCurUserScopeIds();
        $filterline['default_value'] = $tmp_default_value;
        $fieldname = 'last_name';
        /**if(isKehu001ServerPc()=='yes'){
        $fieldname = 'real_name';
        }**/
        //用户名称
        $user_sql = "select group_concat(".$fieldname.") as last_name from ld_users where id  in (".$filterline['default_value'].") ";
        $user_res = $this->CustomTablesActionsObj->adb->pquery($user_sql);
        $user_nums = $this->CustomTablesActionsObj->adb->num_rows($user_res);
        if($user_nums>0){
            $usernames_str = $this->CustomTablesActionsObj->adb->query_result($user_res,0,0);
            $filterArr[$k]['default_value'] = $tmp_default_value;
            $filterArr[$k]['usernames_str'] = empty($usernames_str)?'':$usernames_str;
        }
    }
    public function setVarApprovestatusDefaultValue(&$filterArr,$k){
        $filterline = $filterArr[$k];
        $default_value = $filterline['default_value'];
        $filterArr[$k]['approvestatus_default_value_arr'] = explode(',', $default_value);
    }
    //根据 变量设置 获取部门id集合  获取部门名称集合
    public function getGroupIds($filterline){
        global $current_user;
        $default_value = $filterline['default_value'];
        //默认值是不是on  显示所有部门
        if($default_value=='on'||empty($filterline['modulename'])){
            //显示所有部门
            $groupidsql = " SELECT group_concat(DISTINCT groupid)as groupidstr,group_concat(DISTINCT groupname)as groupnamestr FROM ld_groups ";
            $groupidres = $this->CustomTablesActionsObj->adb->pquery($groupidsql,array());
            $groupid_str = '';
            $groupname_str = '';
            if($this->CustomTablesActionsObj->adb->num_rows($groupidres)>0){
                $groupid_str = $this->CustomTablesActionsObj->adb->query_result($groupidres,0,'groupidstr');
                $groupname_str = $this->CustomTablesActionsObj->adb->query_result($groupidres,0,'groupnamestr');
            }
        }else{
            $scopeobj = new ScopOfAuthority($this->CustomTablesActionsObj->adb,$filterline['modulename']);
            $scopeType = $scopeobj->getUserModuleScoperType();

            //按数据范围
            if($scopeType==3){
                //数据范围是按部门的 获取设置的部门数据范围
                $groupidsql = " SELECT group_concat(DISTINCT ld_groups.groupid)as groupidstr,group_concat(DISTINCT ld_groups.groupname)as groupnamestr FROM ld_groups
                inner join (SELECT viewid FROM ld_scoperhigher WHERE modulename=? 
				AND ld_scoperhigher.userid=? 
				AND ld_scoperhigher.scopeauthority = ?)a on a.viewid=ld_groups.groupid ";
                $groupidres = $this->CustomTablesActionsObj->adb->pquery($groupidsql,array($filterline['modulename'],$current_user->id,$scopeType));
                $groupid_str = '';
                $groupname_str = '';
                if($this->CustomTablesActionsObj->adb->num_rows($groupidres)>0){
                    $groupid_str = $this->CustomTablesActionsObj->adb->query_result($groupidres,0,'groupidstr');
                    $groupname_str = $this->CustomTablesActionsObj->adb->query_result($groupidres,0,'groupnamestr');
                }
            }else{
                // 数据范围 按用户 按角色的 获取数据范围内用户所在的部门集合
                $tmp_userids = $scopeobj->getCurUserScopeIds();
                $groupidsql = " SELECT group_concat(DISTINCT ld_groups.groupid)as groupidstr,group_concat(DISTINCT ld_groups.groupname)as groupnamestr FROM ld_groups
                inner join (SELECT  groupid  FROM ld_users2group WHERE find_in_set(userid,?) )a on a.groupid=ld_groups.groupid";
                $groupidres = $this->CustomTablesActionsObj->adb->pquery($groupidsql,array($tmp_userids));
                $groupid_str = '';
                $groupname_str = '';
                if($this->CustomTablesActionsObj->adb->num_rows($groupidres)>0){
                    $groupid_str = $this->CustomTablesActionsObj->adb->query_result($groupidres,0,'groupidstr');
                    $groupname_str = $this->CustomTablesActionsObj->adb->query_result($groupidres,0,'groupnamestr');
                }

            }
        }
        return ['groupid_str'=>$groupid_str,'groupname_str'=>$groupname_str];
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  SQL运行
    public function getSqlDetailData(){
        global $currentModule, $current_user;
        $report_id = $this->report_id;
        $params = $this->params;
        $report_info = $this->CustomTablesActionsObj->getReportInfo($report_id);
        $sqlstr = $report_info['sqlstr'];
        $sqlstr = $this->getSqlVarExchange($sqlstr,$report_id);

        $sqlstr_sign = substr($sqlstr,0,4);
        $sqlstr_sign = strtolower($sqlstr_sign);

        $sqlstr = Zend_Json::json_specialchar($sqlstr);
        $is_procedure = 'no';
        //判断是否是存储过程
        if($sqlstr_sign=='call'){
            $is_procedure='yes';
            //每页条数  第几页的变量处理
        }
        //判断是否是查询sql---查询先去掉
        /*require_once globalStatic::$root_directory. 'sqlparser/vendor/autoload.php';
        $parser = new PhpMyAdmin\SqlParser\Parser($sqlstr);
        if(sizeof($parser->statements)<=0)
        {
            ConvertTojsonString(0,[],'不符合条件的sql！');die;
        }
        $parserArr = $parser->statements;*/

        /*foreach($parserArr as $parserOne) {
            //判断是不是查询语句  要每个都判断 不放过任何一个不是select的语句
            if ($parserOne instanceof PhpMyAdmin\SqlParser\Statements\SelectStatement) {

            }else if($parserOne instanceof  PhpMyAdmin\SqlParser\Statements\CallStatement){
                $is_procedure = 'yes';
            }else{
                ConvertTojsonString(0,[],'不是查询语句！');die;
            }
        }*/
        $columnsArr =$this->getTableHeader();
        $totalnums_sql = $sqlstr;
        if($is_procedure=='yes'){
            //存储过程
            $totalnums_sql = str_replace('{offset}',0,$totalnums_sql);
            $totalnums_sql = str_replace('{limit}',10000000,$totalnums_sql);
        }

        //分页参数
        $pagenum=$params['pagenum'];

        if((!isset($params['totalrows'])||$params['pagenum']<=1) && !empty($totalnums_sql))
        {
            $totalnums_res = $this->CustomTablesActionsObj->adb->pquery($totalnums_sql);
            $totalnums = $this->CustomTablesActionsObj->adb->num_rows($totalnums_res);
            if(!empty($totalnums_res)){
                $totalnums_res->Close();
            }
            $totalrows=$totalnums;
        }
        else{
            $totalrows=$params['totalrows'];
        }

        if(isset($params['limitrecord']))
        {
            $this->limit=$params['limitrecord'];
        }else{
            $this->limit=200;
        }
        if($params['Export']=='true'){
            //导出 导出所有的数据 不分页
            $this->limit=$totalrows;
            if ($params['export_first'] == 'yes') {//第一次导出
                unset($_SESSION[$currentModule][$current_user->id]['exportReport']);
            }
            $startExportRow = $params['startExportRow'];
            $endExportRow = $params['endExportRow'];
            $eachExportCount = $endExportRow - $startExportRow;
            $listCounts = $params['listCounts'];
        }
        $totalpages = ceil($totalrows/$this->limit);
        $sqlstr = trim($sqlstr,';');
        if(!empty($sqlstr)){
            if($is_procedure!='yes'){

                $offset = ($pagenum-1)*$this->limit;
                $offset = $offset<=0?0:$offset;
                if ($params['Export']=='true'){
                    $startExportRow = (!is_numeric($startExportRow) || $startExportRow <=0) ? 0 :$startExportRow;
                    $sqlstr .= " limit $startExportRow, " .  $eachExportCount ;
                }else{
                    $sqlstr .= " limit $offset,".$this->limit ;
                }
                $res = $this->CustomTablesActionsObj->adb->pquery($sqlstr);
                $nums2 = $this->CustomTablesActionsObj->adb->num_rows($res);
            }else{
                $offset = ($pagenum-1)*$this->limit;
                $offset = $offset<=0?0:$offset;
                //存储过程
                if ($params['Export']=='true'){
                    if(strpos($sqlstr,'{offset}')!==false && strpos($sqlstr,'{limit}')!==false){
                        $sqlstr = str_replace('{offset}',$startExportRow,$sqlstr);
                        $sqlstr = str_replace('{limit}',$eachExportCount,$sqlstr);
                    }else{
                        if($this->params['startExportRow'] >0){
                            $this->params['startExportRow'] = $totalrows+1;
                            $this->params['endExportRow'] = $totalrows;
                        }else{
                            $this->params['startExportRow'] = 0;
                            $this->params['endExportRow'] = $totalrows;
                        }
                    }
                }else{
                    $sqlstr = str_replace('{offset}',$offset,$sqlstr);
                    $sqlstr = str_replace('{limit}',$this->limit,$sqlstr);
                }

                $res = $this->CustomTablesActionsObj->adb->pquery($sqlstr);
                $nums2 = $this->CustomTablesActionsObj->adb->num_rows($res);
            }
        }
        $html = '';
        $errormsg = '';
        $returnsql ='';
        if($nums2>0){
            crm_load_class_file('ShowHtmlContent','modules/CustomTables');
            $contentobj=new ShowHtmlContent($this);
            $contentobj->setPageNum($totalrows);
            if($params['Export']=='true'){
                $contentobj->setExport(true);
            }
            $html = $contentobj->getParseSqlContent($res,$columnsArr);
            $mergeColumnValueArr = $contentobj->getMergeColumnValueArr();
        }else{
            //有错误信息才返回错误
            if($this->CustomTablesActionsObj->adb->database->ErrorNo()>0) {
                $errormsg = "ADODB error ->[" . $this->CustomTablesActionsObj->adb->database->ErrorNo() . "]" . $this->CustomTablesActionsObj->adb->database->ErrorMsg();
                $returnsql = $sqlstr;//返回值SQL  SQL报错的时候返回 方便调试
            }
        }

        global  $current_user, $languageType;
        $languageType = getLanguageType($current_user);

        $recordListRangeMsg = '';
        $totalrows = empty($totalrows)?0:$totalrows;
        $totalpages = empty($totalrows)?1:$totalpages;
        if ($languageType == 'zh') {
            $recordListRangeMsg .= ' ' . getFixedLabel('TOTALOF') . " $totalrows" . ' ' . getFixedLabel('RECORDNUMS');
        } else {
            $recordListRangeMsg .= " $totalrows" . ' ' . getFixedLabel('DETAILRECORDNUMS');
        }
        $params['diony']='diony';
        //wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
        if($params['Export']=='true'){
            $return_arr = $this->detailExport($html,$columnsArr,$mergeColumnValueArr);
            ConvertTojsonString($return_arr["code"],$return_arr,'success');die;
        }
        $result = ['rows'=>$totalrows,
            'pagerows'=>$totalrows,
            'totalpages'=>$totalpages,//总页数
            'totaldescription'=>$recordListRangeMsg,
            'content'=>$html,
            'errormsg'=>$errormsg,
            'returnsql'=>$returnsql,
            'columnsArr'=>$columnsArr
        ];
        ConvertTojsonString(1,$result, 'success');die;
    }

    //数字映射EXCEL列值
    public function numberToExcelColumn($number) {
        $column = "";
        while ($number > 0) {
            $mod = ($number - 1) % 26;
            $column = chr(65 + $mod) . $column;
            $number = intdiv($number - 1, 26);
        }
        return $column;
    }

    //获取表头信息--包含表头宽度
    public function getTableHeader(){
        $report_id = $this->report_id;
        $userid = $this->CustomTablesActionsObj->current_user->id;
        $widthresult= $this->CustomTablesActionsObj->adb->pquery("select `columns`,header_width from ld_list_headerwidth where userid=? and relateid=? and module='CustomTables' ",array($userid,$report_id));
        $widthinfo_arr=[];
        for($j=0;$j<$this->CustomTablesActionsObj->adb->num_rows($widthresult);$j++)
        {
            $widthinfo_arr[$this->CustomTablesActionsObj->adb->query_result($widthresult,$j,'columns')]=$this->CustomTablesActionsObj->adb->query_result($widthresult,$j,'header_width');
        }


        $columns_sql = "select * from ld_customtable_columns where report_id=? and visibile<>'no' order by sequence asc ";
        $columns_res = $this->CustomTablesActionsObj->adb->pquery($columns_sql,array($report_id));
        $columns_nums = $this->CustomTablesActionsObj->adb->num_rows($columns_res);
        $columnsArr = [];
        if($columns_nums>0){
            $columnsArr = $this->CustomTablesActionsObj->adb->query_result_all($columns_res);
            foreach($columnsArr as $tmprowindex => $tempcolumn){
                $temp_columnid = $this->CustomTablesActionsObj->adb->query_result($columns_res,$tmprowindex,'id');
                $columnsArr[$tmprowindex]['header_width']  = 200;
                if(isset($widthinfo_arr[$temp_columnid])){
                    $columnsArr[$tmprowindex]['header_width']  = $widthinfo_arr[$temp_columnid];
                }
            }
        }
        return $columnsArr;
    }

    //解析SQL  sqlstr--原SQL  $report_id报表id
    public function getSqlVarExchange($sqlstr,$report_id){
        $params = $this->params;
        //变量替换
        $filterArr = $this->CustomTablesActionsObj->getSqlFilter($report_id);
        if(!empty($filterArr)){
            foreach($filterArr as $filter){
                $var_name = $filter['var_name'];
                $var_name_pre = "sqlvar_".$var_name;//拼接前缀 防止$_REQUEST变量名冲突  比如移动端userid就冲突了
                $tmp_default_value = $filter['default_value'];
                $tmp_default_value = empty($tmp_default_value)?'':$tmp_default_value;
                //默认值
                /*if($filter['var_type']=='date'||$filter['var_type']=='datetime'){
                    $default_value = $filter['default_value'];
                    $default_value_arr = explode(',',$default_value);
                    if($default_value_arr[0]=='selfdefined'){
                        $tmp_default_value = $default_value_arr[0];
                    }else{
                        $tmp_default_value = $this->CustomTablesActionsObj->getFilterDefaultValue($default_value_arr[0]);
                    }

                }*/
                //界面传过来的值---bug BUG20241230-41 自定义SQL报表，筛选数据最少值为0时不显示数据，0.0就可以显示
                if(isset($params[$var_name_pre])){
                    $var_name_value = $params[$var_name_pre];
                    if($filter['var_type']=='multiselect'){
                        $var_name_value = implode(',',$var_name_value);
                    }
                    $tmp_default_value = $var_name_value;
                }
                //审批状态
                if($filter['var_type']=='approvestatus'){
                    //$var_name_value = implode(',',$var_name_value);
                    $tmp_default_value = $this->getApprovestatusValue($filter);
                }
                //日期 日期时间
                if($filter['var_type']=='date'||$filter['var_type']=='datetime'){
                    $tmp_default_value = $this->getDateValue($filter);
                }
                //用户
                if($filter['var_type']=='multiuser'){
                    $tmp_default_value = $this->getMultiuserValue($filter);
                    /*$scopeobj = new ScopOfAuthority($this->CustomTablesActionsObj->adb,$filter['modulename']);
                    $tmp_default_value = $scopeobj->getCurUserScopeIds();
                    $var_value_multiuser = $params[$var_name_pre];
                    if(!empty($var_value_multiuser)){
                        $tmp_default_value = $var_value_multiuser;
                    }*/
                }
                //审批组件的处理
                /*if($filter['var_type']=='approvestatus'){
                    $approvestatus_value = $params[$var_name_pre];
                    if(!empty($var_name_pre)){
                        $tmp_default_value = implode(',',$approvestatus_value);
                    }else{
                        $tmp_default_value = '';
                    }
                    $tmp_default_value = trim($tmp_default_value);
                }*/
                //复选框
                if($filter['var_type']=='checkbox'){
                    $checkbox_value = $params[$var_name_pre];
                    if($checkbox_value=='on'){
                        $tmp_default_value = trim($checkbox_value);
                    }else{
                        $tmp_default_value = '';
                    }
                }
                //部门组件
                if($filter['var_type']=='department'){
                    //先判断是否传值 没传值则取默认值
                    $var_value_department = $params[$var_name_pre];//前段传过来的部门id数据
                    $groupid_arr = $this->getGroupIds($filter);//在数据范围内的部门ID数据
                    if(!empty($var_value_department)){
                        $var_value_department_arr = explode(',',$var_value_department);
                        $groupids_arr = explode(',',$groupid_arr['groupid_str']);
                        $tmp_default_value = trim(implode(',',array_intersect($var_value_department_arr,$groupids_arr)));//取前端传值和有数据范围的成员所属部门id的交集
                    }else{
                        $tmp_default_value = $groupid_arr['groupid_str'];
                    }
                }
                //当前操作员 直接取值当前登录用户id
                if($filter['var_type']=='curroperator'){
                    global $current_user;
                    $tmp_default_value = $current_user->id;
                }
                $sqlstr = str_replace('{'.$var_name.'}',$tmp_default_value,$sqlstr);
            }
        }

        $sqlstr = ltrim($sqlstr);//去除sql左侧的字符
        return $sqlstr;
    }

    /**
     * @param $filter
     * @return string
     * 审批状态的值
     */
    public function getApprovestatusValue($filter){
        $params = $this->params;
        $var_name_pre = "sqlvar_".$filter['var_name'];//变量名 拼接前缀是防止重名
        if(isset($params[$var_name_pre])&&!empty($params[$var_name_pre])){
            $approvestatus_value = $params[$var_name_pre];
            $tmp_default_value = implode(',',$approvestatus_value);
        }else{
            $tmp_default_value = $filter['default_value'];
        }
        $tmp_default_value = trim($tmp_default_value);
        return $tmp_default_value;
    }
    /**
     * @param $modulename
     * @return void
     * 获取用户组件的值
     */
    public function getMultiuserValue($filter){
        $params = $this->params;
        $var_name_pre = "sqlvar_".$filter['var_name'];//变量名 拼接前缀是防止重名
        $var_value_multiuser = $params[$var_name_pre];
        if(!empty($var_value_multiuser)){
            $tmp_default_value = $var_value_multiuser;
        }else{
            $scopeobj = new ScopOfAuthority($this->CustomTablesActionsObj->adb,$filter['modulename']);
            $tmp_default_value = $scopeobj->getCurUserScopeIds();
        }
        return $tmp_default_value;
    }

    /**
     * @param $filter
     * @return mixed
     * 获取日期 日期时间的值
     */
    public function getDateValue($filter){
        $params = $this->params;
        $var_name_pre = "sqlvar_".$filter['var_name'];//变量名 拼接前缀是防止重名
        if(!empty($params[$var_name_pre])) {
            $var_name_value = $params[$var_name_pre];//有传值则取传值
        }else{
            //没有传值则取默认值
            $default_value = $filter['default_value'];
            $default_value_arr = explode(',',$default_value);
            if($default_value_arr[0]=='selfdefined'){
                $tmp_default_value = $default_value_arr[0];
            }else{
                $tmp_default_value = $this->CustomTablesActionsObj->getFilterDefaultValue($default_value_arr[0]);
            }
            $var_name_value = $tmp_default_value;
        }
        return $var_name_value;
    }
    // wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
    public function detailExport($html,$columnsArr,$allmergecolumnvalue_arr){
        global $currentModule, $current_user;
        $params = $this->params;
        $report_name = $params['report_name'];
        $startExportRow = $params['startExportRow'];
        $listCounts = $params['listCounts'];
        $endExportRow = $params['endExportRow'];
        $htmlparseobj = new simple_html_dom();


        $csc = explode("</tr>",$html);
        $csc=array_filter($csc);
        $file_name = $current_user->id.'_'.$report_name . '.xls';
        $file_dir = globalStatic::$root_directory.'storage/';
        require_once( globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
        $session_exportReport = $_SESSION[$currentModule][$current_user->id]['exportReport'];
        if(is_array($session_exportReport) && array_key_exists('objPHPExcel',$session_exportReport)) {
            $objPHPExcel = PHPExcel_IOFactory::load($file_dir . $file_name);
            $prevTotalRows = $_SESSION[$currentModule][$current_user->id]['exportReport']['prevTotalRows'];
        }
        else {
            $objPHPExcel = new PHPExcel();
            $_SESSION[$currentModule][$current_user->id]['exportReport']['objPHPExcel']=serialize($objPHPExcel);
            $prevTotalRows = 2;

        }
        if ($startExportRow <= $listCounts) {
            $objPHPExcel->setActiveSheetIndex(0);
            $activesheet = $objPHPExcel->getActiveSheet();
            crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
            $Header_FromArray = cls_ExportListView::getListHeaderFormArray();
            foreach ($columnsArr as $key => $column) {
                $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
                $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key) . '1', $column['tdheader_label']);
                $activesheet->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(30);
                $mergeArr[] = $column["is_merge"];
            }
            foreach ($csc as $kee => &$arr) {
                $arr = explode("</td>", $arr);
            }

            //处理合并的数据
            /**foreach ($csc as $kee => $tmp_arr) {
                foreach ($tmp_arr as $keyy => $value) {
                    $rowspan = 0;
                    $ismatch = preg_match('/rowspan="(.*?)"/u', $value, $match);
                    if ($ismatch == 1) {
                        $rowspan = $match[1];
                    }

                    if ($rowspan > 0) {

                        for ($k = 1; $k < $rowspan; $k++) {
                            array_splice($csc[$kee + $k], $keyy, 0, '');
                        }
                    }
                }
            }**/


            foreach ($csc as $kee => $tmparr) {
                $cscs = $tmparr;
                $for_i = 0;
                foreach ($cscs as $keyy => $value) {


                    if (stripos($value, '/ww-open-data') !== false) {
                        $htmlparseobj = new simple_html_dom();
                        $htmlparseobj->load($value);
                        $tmphtml_arr = $htmlparseobj->find('ww-open-data');
                        foreach ($tmphtml_arr as $tmpparser) {
                            $type = $tmpparser->type;
                            $openid = $tmpparser->openid;
                            if ($type == 'userName') {
                                $tmpparser->outertext = '$userName=' . $openid . '$';
                            } else if ($openid != '') {
                                $tmpparser->outertext = '$departmentName=' . $openid . '$';
                            }
                        }
                        $value = $htmlparseobj->innertext;

                    }
                    if (stripos($value, 'tag="tr_totalrow"') !== false && $prevTotalRows < $listCounts) { //去除多余的总计数
                        unset($cscs[$kee]);
                        $prevTotalRows --;
                        break;
                    }
                    $value = strip_tags(trim($value));
                    //$value = ltrim($value, '&nbsp;');
                    $value = str_replace('&nbsp;', '', strip_tags($value));;
                    if ($value == '&nbsp;') {
                        $value = '';
                    }
                    $value = str_replace('&yen;', '¥', strip_tags($value));
                    $value = decode_html($value);
                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows, trim($value));

                    //XUQIU1001388zl 对于SQL报表,使用fieldtype判断字段类型
                    foreach ($columnsArr as $tmp => $arr2) {
                        $datatype[] = $columnsArr[$tmp]['fieldtype'];
                    }
                    if ($keyy < sizeof($columnsArr)) {
                        $changetype = $datatype[$keyy];
                    }

                    $tmpvalue = $value;

                    //XUQIU1001388zl 数据类型自定义,无货币类型(后续添加),都转换为自定义,可计算,百分数转换为百分比格式
                    if ($changetype == 'number') {
                        $tmpvalue = str_replace(',', '', strip_tags($tmpvalue));
                    }
                    if ($changetype == 'percent') {
                        $tmpvalue = str_replace('%', '', strip_tags($tmpvalue));
                        $tmpvalue = $tmpvalue / 100;
                    }

                    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows, strip_tags($tmpvalue));

                    if ($changetype == 'number') {
                        //XUQIU1001388zl 判断是否需要取小数位数，导出格式与列表显示一致
                        $decvalue = $tmpvalue;
                        $arr_decimal = explode('.', $decvalue);
                        $tmpdecimal = strlen($arr_decimal[1]);
                        $tmpstr = '0.0000000000000000000';
                        if (is_numeric($tmpdecimal)) {
                            $tmpstr = number_format($tmpstr, (int)$tmpdecimal);
                        } else {
                            $tmpstr = '0.00';
                        }
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows)->getNumberFormat()->setFormatCode($tmpstr);
                    } else if ($changetype == 'percent') {
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows)->getNumberFormat()->setFormatCode('0%');
                    } //XUQIU1001388zl 筛选日期类型字段,修改导出格式为自定义
                    else if ($changetype == 'date') {
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows)->getNumberFormat()->setFormatCode('yyyy-mm-dd');
                    } else if ($changetype == 'datetime') {
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows)->getNumberFormat()->setFormatCode('yyyy-mm-dd hh:mm:ss');
                    } else if ($changetype == 'string') {
                        //duan BUG20240305-05 数字以字符串内容显示时,首位的0会被去掉,改为以excel的文本格式保存
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($for_i) . $prevTotalRows, trim($value), PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                    if (is_array($_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]) && array_key_exists('startRow',$_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])){
                        $startRow = $session_exportReport[$keyy]['startRow'];
                    }else{
                        $startRow = 2;
                    }
                    $tmpcurcolumn = $columnsArr[$keyy]['columns'];//当前列的字段名 别名
                    $tempMerge = $columnsArr[$keyy]['is_merge'];
                    if (is_array($_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]) && array_key_exists('prevValue',$_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy])){
                        $prevValue = $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevValue'];
                    }else{
                        $prevValue= strip_tags(trim($allmergecolumnvalue_arr[0][$tmpcurcolumn]));
                    }

                    $excelColumn = $this->numberToExcelColumn($keyy+1);  //设置数字对应excel列名(0->A  1->B ...)

                    // wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
                    //if ($mergeArr[$keyy] == "yes"){  //判断字段是否合并
                    if (!empty($tempMerge)&&$tempMerge!='no'&&$tempMerge!='noselect'){  //判断字段是否合并
                        $columnValue = strip_tags(trim($cscs[$keyy]));
                        $mergecolumnvalue = $allmergecolumnvalue_arr[$kee][$tmpcurcolumn];
                        if (($mergecolumnvalue != $prevValue && $startRow <= $prevTotalRows - 1) || $prevTotalRows - 1 == $listCounts){
                            if($prevTotalRows - 1 == $listCounts){
                                $endRows = $prevTotalRows; //结束行
                            }else{
                                $endRows = $prevTotalRows - 1; //结束行
                            }
                            if ($startExportRow == $prevTotalRows - 1 || $startRow == $endRows){ //如果起始行等于结束行,更新startRow、currentValue 不合并
                                $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['startRow'] = $prevTotalRows;
                                $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevValue'] = $mergecolumnvalue;
                                ++$for_i;
                                continue;
                            }

                            $activesheet->mergeCells("$excelColumn$startRow:$excelColumn$endRows");
                            // 设置合并后的单元格的值
                            $activesheet->setCellValue("$excelColumn$startRow", $columnValue);
                            $activesheet->getStyle("$excelColumn$startRow:$excelColumn$endRows")->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
                            $activesheet->getStyle("$excelColumn$startRow:$excelColumn$endRows")->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
                            $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['startRow'] = $prevTotalRows;
                            $_SESSION[$currentModule][$current_user->id]['exportReport'][$keyy]['prevValue'] = $mergecolumnvalue;
                        }
                    }
                    ++$for_i;
                }
                ++$prevTotalRows;
            }
            $_SESSION[$currentModule][$current_user->id]['exportReport']['prevTotalRows'] = $prevTotalRows;
            $objPHPExcel->getActiveSheet()->setTitle($report_name);
            $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
            $objWriter->save($file_dir . $file_name);
            $ret_arr1['startExportRow'] = $startExportRow;
            $ret_arr1['endExportRow'] = $endExportRow;
            $ret_arr1['listCount'] = $listCounts;
            $ret_arr1['code'] = 1;
            $ret_arr1['title'] = $report_name . '>' . getFixedLabel('EXPORTDATATITLE');
            return $ret_arr1;
        }
        else {
            $ret_arr2['report_name'] = $report_name;
            $ret_arr2['code'] = 2;
            if (isKehu001ServerPc() == 'yes') {
                require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
                $portobj = new cls_WeixinPort();
                $ret_arr2['pathname'] = $portobj->UploadUserInfoFile(globalStatic::$root_directory . 'storage/' . $file_name, $file_name);
            }
            unset($_SESSION[$currentModule][$current_user->id]['exportReport']);
            return $ret_arr2;
        }
    }

}
?>