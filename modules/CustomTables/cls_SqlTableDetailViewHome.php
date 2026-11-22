<?php

crm_load_class_file('cls_SqlTableDetailView','modules/CustomTables/');

//SQL报表查看的类---SQL报表放首页
class cls_SqlTableDetailViewHome extends  cls_SqlTableDetailView
{
    public $boardid;
    public $boardstuffid;
    public $scopeType;
    public $selectuid;
    public $approve_value;
    public $search_date;

    public $filterconditionArr;
    public function __construct($params)
    {
        parent::__construct($params);
        $this->setHomeParams($params);
        //变量替换 --新的方式 按看板按组件设置
        //获取设置好的首页数据范围条件
        include_once globalStatic::$root_directory . 'modules/Home/DataRangeHomeboard.php';
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
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
    //穿透的时候  变量的默认值设置  这时候显示的是首页的时间范围
    public function setVarDateDefaultValue(&$filterArr,$k){
        $filterline = $filterArr[$k];

        $datevalue = $this->getDateValue($filterline);

        $filterArr[$k]['default_value_actual'] = $datevalue;
    }
    //穿透的时候 变量的默认值设置  这时候默认选中的是首页的人员
    public function setVarMultiuserDefaultValue(&$filterArr,$k){
        $filterline = $filterArr[$k];
        $userids = $this->getMultiuserValue($filterline);

        $fieldname = 'last_name';
        /**if(isKehu001ServerPc()=='yes'){
        $fieldname = 'real_name';
        }**/
        //用户名称
        $user_sql = "select group_concat(".$fieldname.") as last_name from ld_users where id  in (".$userids.") ";
        $user_res = $this->CustomTablesActionsObj->adb->pquery($user_sql);
        $user_nums = $this->CustomTablesActionsObj->adb->num_rows($user_res);
        if($user_nums>0){
            $usernames_str = $this->CustomTablesActionsObj->adb->query_result($user_res,0,0);
            $filterArr[$k]['default_value'] = $userids;
            $filterArr[$k]['usernames_str'] = empty($usernames_str)?'':$usernames_str;
        }
    }
    //穿透的页面  变量的默认值设置  这时候默认选中的是首页选中的审批条件
    public function setVarApprovestatusDefaultValue(&$filterArr,$k){
        $filterline = $filterArr[$k];
        $default_value = $this->getApprovestatusValue($filterline);
        $filterArr[$k]['approvestatus_default_value_arr'] = explode(',', $default_value);
    }

    /**
     * @param $filter
     * @return string
     * SQL中变量替换的时候 审批状态的值
     */
    public function getApprovestatusValue($filter){
        $params = $this->params;
        $var_name_pre = "sqlvar_".$filter['var_name'];
        if(!empty($params[$var_name_pre])){
            //变量 传参不为空
            return parent::getApprovestatusValue($filter);
        }
        //设置了审批条件的条件映射   取首页传过来的值
        if(isset($this->filterconditionArr['approvestatuscomponent'])&&$this->filterconditionArr['approvestatuscomponent']['isrelated']=='yes'&&$this->filterconditionArr['approvestatuscomponent']['filters']==$filter['id']) {
            crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
            $approve_value_zh = ReportAnalysisUtils::getSqlReportApprovedValue($this->approve_value);
            return trim($approve_value_zh);
        }else{
            //没有关联首页审批条件  直接取默认值
            return $filter['default_value'];
        }
    }
    /**
     * @param $modulename
     * @return void
     * SQL中变量替换的时候 获取用户组件的值
     */
    public function getMultiuserValue($filter){
        $params = $this->params;
        $var_name_pre = "sqlvar_".$filter['var_name'];
        if(!empty($params[$var_name_pre])){
            //变量 传参不为空
            return parent::getMultiuserValue($filter);
        }
        //设置了人员的条件映射   取首页传过来的值和变量设置的数据范围做交集
        if(isset($this->filterconditionArr['usercomponent'])&&$this->filterconditionArr['usercomponent']['isrelated']=='yes'&&$this->filterconditionArr['usercomponent']['filters']==$filter['id']) {
            $scopeuserids = parent::getMultiuserValue($filter);//设定的数据范围的用户id
            $scopeuserids_arr = explode(',',$scopeuserids);
            $homeuserids = $this->selectuid;//首页传过来的用户id
            $homeuserids_arr = explode(',',$homeuserids);
            $uid_arr = array_intersect($scopeuserids_arr,$homeuserids_arr);//取交集
            return implode(',',$uid_arr);
        }else{
            //取默认值
           return parent::getMultiuserValue($filter);
        }
    }

    /**
     * @param $filter
     * @return mixed
     * SQL中变量替换的时候 获取日期 日期时间的值
     */
    public function getDateValue($filter){


        $params = $this->params;
        $var_name_pre = "sqlvar_".$filter['var_name'];//变量名 拼接前缀是防止重名
        //没有传值则取默认值
        /*$default_value = $filter['default_value'];
        $default_value_arr = explode(',',$default_value);
        if($default_value_arr[0]=='selfdefined'){
            $tmp_default_value = $default_value_arr[0];
        }else{
            $tmp_default_value = $this->CustomTablesActionsObj->getFilterDefaultValue($default_value_arr[0]);
        }
        $var_name_value = $tmp_default_value;*/
        if(!empty($params[$var_name_pre])) {
            //变量 传参不为空
            return parent::getDateValue($filter);
        }

        $date_str = getHomeDateScope($this->search_date,'no','comparatorvalue');
        $date_arr = explode(',',$date_str);
        foreach($this->filterconditionArr as $filterkey=>$filtercondition){

            if($filterkey=='timecomponent1'||$filterkey=='timecomponent2'){
                if($filterkey=='timecomponent1'&&$filtercondition['isrelated']=='yes'&&$filtercondition['filters']==$filter['id']) {
                    if($date_str=='')$date_arr[0]='1600-01-01 00:00:00';
                    if($filter['var_type']=='date') return substr($date_arr[0],0,10);
                    if($filter['var_type']=='datetime') return $date_arr[0];

                }
                if($filterkey=='timecomponent2'&&$filtercondition['isrelated']=='yes'&&$filtercondition['filters']==$filter['id']) {
                    if($date_str=='')$date_arr[1]='2500-12-31 23:59:59';
                    if($filter['var_type']=='date') return substr($date_arr[1],0,10);
                    if($filter['var_type']=='datetime') return $date_arr[1];
                }
            }
        }

    }
}
?>