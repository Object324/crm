<?php
crm_load_class_file('cls_CustomTablesDetailView','modules/CustomTables/');
//自定义统计报表查看的类---自定义统计表放首页
class cls_CustomTablesDetailViewHome extends cls_CustomTablesDetailView
{
    public $boardid;//看板ID
    public $boardstuffid;
    public $scopeType;
    public $selectuid;
    public $approve_value;//首页的审批状态参数
    public $search_date;//首页的时间条件参数

    public $filterconditionArr;//设置好的首页数据范围条件映射
    public function __construct($params)
    {
        parent::__construct($params);
        $this->setHomeParams($params);
        //变量替换 --新的方式 按看板按组件设置
        //获取设置好的首页数据范围条件
        include_once globalStatic::$root_directory . 'modules/Home/DataRangeHomeboard.php';
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        $this->DataRangeHomeboardObj = $DataRangeHomeboardObj;
        $this->filterconditionArr = $DataRangeHomeboardObj->boardfilterArr[$this->boardstuffid];
    }
    //设置参数（目前主要用于设置首页参数，用于移动端新看板和pc端看板）
    public function setHomeParams($params) {
        $this->boardid = $params['boardid'];
        $this->boardstuffid = $params['boardstuffid'];
        $this->scopeType = $params['scopeType'];
        if($params['scopeType'] === 'SmOwner_Search_All'){
            global $adb;
            crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
            $scopeobj = new cls_ScopOfAuthority($adb, 'Home');
            $params['selectuid'] = $scopeobj->getHomeScopeUser();
        }

        $this->selectuid = $params['selectuid'];
        if(empty($this->scopeType) && !empty($this->selectuid)) {
            $this->scopeType = 'smowner_search_senior';
        }
        $this->approve_value = $params['approve_value'];
        if($params['search_date'] === 'custom'){
            $this->search_date = $params['date_custom'];
        }else{
            $this->search_date = $params['search_date'];
        }
        //穿透传参的参数名是search_date_custom_value
        if(isset($params['search_date_custom_value'])){
            $this->search_date = $params['search_date_custom_value'];
        }
    }

    //数据范围映射子SQL  如果是管理员/不是管理员返回的SQL不一样
    public function getDataRangeSql($smowneridjoinField,$module){
        //设置了人员的条件映射   取首页传过来的值
        if(isset($this->filterconditionArr['usercomponent_'.$this->mainmodule])&&$this->filterconditionArr['usercomponent_'.$this->mainmodule]['isrelated']=='yes') {
            $filtermodule = $this->filterconditionArr['usercomponent_'.$this->mainmodule]['filtermodule'];
            //管理员
            global $current_user;
            if(is_admin($current_user))
            {
                $where = '';
                if(!empty($this->selectuid)){
                    $where = " where find_in_set(id,'$this->selectuid')";
                }
                return " INNER JOIN (SELECT DISTINCT id as userid FROM ld_users $where ) AS tmp_users ON tmp_users.userid=$smowneridjoinField";
            }else{
                //首页传过来的数据范围  以及设置的数据范围取哪个模块的
                crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
                $datarangesql = ReportAnalysisUtils::getUserIdSql($smowneridjoinField,$filtermodule,$this->selectuid);
                return $datarangesql;
            }
        }else{
            //不控制数据范围
            return '';
            //return parent::getDataRangeSql($smowneridjoinField,$this->mainmodule);
        }
    }
    //主模块审批条件
    public function getMainApprovestatusSql(){
        $mainFocus = CRMEntity::getInstance($this->mainmodule);

        $sql = "  ";
        //关联了首页审批条件
        if(isset($this->filterconditionArr['approvestatuscomponent_'.$this->mainmodule])&&$this->filterconditionArr['approvestatuscomponent_'.$this->mainmodule]['isrelated']=='yes') {
            $moduleAllPreseneceFields = $mainFocus->fieldobj->getModuleAllPreseneceFields();//获取模块所有字段信息 不考虑权限的
            $tablename = $mainFocus->table_name;

            //获取审批是否开启
            $Approvedeploy = getSys_Approvedeploy($mainFocus->module_name);//deploy_value=0是开启 =1是关闭
            $approve_value = $this->approve_value;
            //判断字段存在 再拼接时间条件
            if (is_array($Approvedeploy) && $Approvedeploy['deploy_value'] == 0 && !empty($approve_value) && isset($moduleAllPreseneceFields['approvestatus'])) {

                if (!empty($approve_value)) {
                    if ($approve_value == 'all' || strpos($approve_value, 'all') !== false) {
                        //$query = ' and ifnull('.$tablename.'.approvestatus,"") != \''.D_A_S_REJECTED.'\' ';
                        //zxm 审批状态条件以设置为准,用户在界面勾选什么就判断什么
                        $sql = ' ';
                    } else {
                        $sql = ' and ' . $tablename . '.approvestatus in (' . $approve_value . ')';
                        $sql = str_replace("unapproved", "'" . D_A_S_UNAPPROVED . "'", $sql);
                        $sql = str_replace("approving", "'" . D_A_S_APPROVALOF . "'", $sql);
                        $sql = str_replace("approved", "'" . D_A_S_APPROVED . "'", $sql);
                        $sql = str_replace("rejected", "'" . D_A_S_REJECTED . "'", $sql);
                        $sql = str_replace("dismissed", "'" . D_A_S_DISMISSED . "'", $sql);
                    }
                }
            }
        }
        return $sql;
    }
    //时间条件和高级查找映射  组装成自定义统计表的高级查找格式
    public function setHomeHighSearch(){
        /*$DataRangeHomeboardObj = $this->DataRangeHomeboardObj;
        $mainqueryObj = $DataRangeHomeboardObj->get_query_obj($this->mainmodule);
        $highSearch = 'no';
        //关联了首页时间条件--高级查找
        if(isset($this->filterconditionArr['timecomponent_'.$this->mainmodule])&&$this->filterconditionArr['timecomponent_'.$this->mainmodule]['isrelated']=='yes') {
            $stuffDateRangeArr = $DataRangeHomeboardObj->getHomeDateScope($this->search_date, 'no'); //获取时间范围  返回的是一个数组
            $date_adv = $stuffDateRangeArr['date_adv'];
            $highSearch = 'yes';
            $mainqueryObj->addUserSearchConditions($date_adv);
        }
        //首页高级查找条件
        if(isset($this->filterconditionArr['highsearch_'.$this->mainmodule])&&$this->filterconditionArr['highsearch_'.$this->mainmodule]['isrelated']=='yes') {
            $tmpadvance_demand = $this->filterconditionArr['highsearch_'.$this->mainmodule]['advance_demand'];
            $tmpadvance_demand_groups = $this->filterconditionArr['highsearch_'.$this->mainmodule]['advance_demand_groups'];
            if(!empty($tmpadvance_demand)&&$tmpadvance_demand!=[]){
                $tmpinput['advft_criteria'] = $tmpadvance_demand;
                $tmpinput['advft_criteria_groups'] = $tmpadvance_demand_groups;
                $tmpinput['searchtype'] = 'advance';
                $highSearch = 'yes';
                $mainqueryObj->addUserSearchConditions($tmpinput);
            }
        }
        $highsearchSql = '';
        if($highSearch=='yes'){
            $tmpsql = $mainqueryObj->getQuery();
            $tmpsql2 = $mainqueryObj->getWhereClause();
            $tmpsql3 = $mainqueryObj->getFromMainTable();

            dump($tmpsql);

        }*/

        //关联了首页查询条件 组装成自定义统计表的高级查找格式
        if(isset($this->filterconditionArr['timecomponent_'.$this->mainmodule])&&$this->filterconditionArr['timecomponent_'.$this->mainmodule]['isrelated']=='yes') {

            $this->params['cvadvfilter'][] = $this->filterconditionArr['timecomponent_'.$this->mainmodule]['filters'];
            if($this->params['search_date']=='custom'){
                $this->params['comparator'][] = 'bw';
                $values_arr =  explode('~',$this->params['date_custom']);
                $this->params['value1'][] = $values_arr[0];
                $this->params['value2'][] = $values_arr[1];
            }else if($this->params['search_date']=='all'){
                $this->params['comparator'][] = 'isnotnull';
                $this->params['value1'][] = '';
                $this->params['value2'][] = '';
            }else{
                $this->params['comparator'][] = 'bw';
                $values_str = getHomeDateScope($this->search_date,'no','comparatorvalue');
                $values_arr =  explode(',',$values_str);
                $this->params['value1'][] = $values_arr[0];
                $this->params['value2'][] = $values_arr[1];
            }
            $this->params['columncondition'][] = 'and';
            $tmpgroupid_arr = $this->params['groupid'];

            $tmpgroupid_cnt = count($tmpgroupid_arr);
            if($tmpgroupid_cnt>0) {
                $max_groupid = $tmpgroupid_arr[$tmpgroupid_cnt - 1];
                $next_groupid = $max_groupid + 1;
                $this->params['groupid'][] = $next_groupid;
                //$this->params['group_condition_id'] = array_unique($tmpgroupid_arr);

                /*if($tmpgroupid_cnt>0){
                    $this->params['group_condition_id'][$tmpgroupid_cnt-1] = $max_groupid;
                    $this->params['group_condition'][$tmpgroupid_cnt-1] = '';
                }*/
                $this->params['group_condition_id'][] = $next_groupid;
               // $this->params['group_condition'][] = isset($this->params['group_condition'][$tmpgroupid_cnt - 1]) ? 'and' : '';
                $this->params['group_condition'][] = 'and';
            }else{
                $this->params['groupid'][] = 1;
            }
            //dump($this->params );
        }

        //关联了首页的高级查找条件  也组装成自定义统计表的高级查找方式
        if(isset($this->filterconditionArr['highsearch_'.$this->mainmodule])&&$this->filterconditionArr['highsearch_'.$this->mainmodule]['isrelated']=='yes') {
            $tmpadvance_demand = $this->filterconditionArr['highsearch_'.$this->mainmodule]['advance_demand'];
            $tmpadvance_demand_groups = $this->filterconditionArr['highsearch_'.$this->mainmodule]['advance_demand_groups'];
            if(!empty($tmpadvance_demand)&&$tmpadvance_demand!=[]){
                $tmpadvance_demand_arr = Zend_Json::decode($tmpadvance_demand);
                $tmpadvance_demand_groups_arr = Zend_Json::decode($tmpadvance_demand_groups);
                $pregroupid = 0;
                foreach($tmpadvance_demand_arr as $tmpadv){
                    $curgroupid = $tmpadv['groupid'];

                    $this->params['cvadvfilter'][] = $tmpadv['columnname'];
                    $this->params['comparator'][] = $tmpadv['comparator'];
                    $values_arr =  explode('~',$tmpadv['value']);
                    $this->params['value1'][] = $values_arr[0];
                    $this->params['value2'][] = $values_arr[1];
                    $this->params['columncondition'][] = $tmpadv['columncondition'];

                    $tmpgroupid_arr = $this->params['groupid'];
                    $tmpgroupid_cnt = count($tmpgroupid_arr);
                    $max_groupid = $tmpgroupid_arr[$tmpgroupid_cnt-1];

                    if($curgroupid!==$pregroupid){
                        $next_groupid = $max_groupid+1;
                        $this->params['group_condition_id'][] = $next_groupid;
                        $groupcondition = $tmpadvance_demand_groups_arr[$curgroupid]['groupcondition'];
                        $this->params['group_condition'][] = empty($groupcondition)?'and':$groupcondition;
                        $tmpadvance_demand_groups_arr[$curgroupid]['groupcondition'] = '';
                    }else{
                        $next_groupid = $max_groupid;
                    }
                    $this->params['groupid'][] = $next_groupid;
                    $pregroupid = $tmpadv['groupid'];
                }
            }
        }

    }

}
?>