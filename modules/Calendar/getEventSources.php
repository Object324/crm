<?php

global $adb;
global $current_user,$currentModule;
$startdate=$_REQUEST['start'];
$enddate=$_REQUEST['end'];

//@edit:liushuai,2021-07-22,reason:【ID1000477】PC端：日程管理日历视图界面增加人员查看范围
$smarty=new lingdangCRM_Smarty();
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
$smarty->assign('Merge_SmOwner',$MergeSmowner);
$smarty->assign('MODULE', $currentModule);
/*
edit:can
date:20130426
reason:记住上次查询范围
*/
$senioruserid = '';
if($_REQUEST['senioruserid']!="")
{
    $_SESSION['lvs'][$currentModule]['senioruserid']=$_REQUEST['senioruserid'];
}
if($_SESSION['lvs'][$currentModule]['senioruserid']!="")
{
    $smarty->assign("senioruserid",$_SESSION['lvs'][$currentModule]['senioruserid']);
    $senioruserid = $_SESSION['lvs'][$currentModule]['senioruserid'];
}

if($_REQUEST['SearchScope'] !=null&&$_REQUEST['SearchScope'] !='')
{
    $SearchScope=$_REQUEST['SearchScope'];
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;

    $smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']);

}
else if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
    $smarty->assign('SelectedOwner2',$_SESSION['lvs'][$currentModule]['SearchScope']);

}
else
{
    //XUQIU20240722-05 悦锦-日程管理查看范围页签需求 日程管理查看范围默认'我的'
    $SearchScope="SmOwner_Search_MeAndShareMe";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2',"SmOwner_Search_MeAndShareMe");
}

//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));

//ljj 20240816 XUQIU20240522-04 日程管理->日历视图，增加“查询分类”和“高级查找”（张宇彦）
/****begin****/
$customView = CustomView::getInstance($currentModule);
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
//获取查询分类
$viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
//查询分类html
$customview_html = $customView->getCustomViewAll($viewid,$currentModule,'');
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
$customview_content=$smarty->fetch("SelectCustomView_Group.tpl");
$customview_content.= '<input name="viewname" id="viewname" type="hidden" value="'.$viewid.'">';
//获取高级查找按钮是否开启
$highbtnstatus = getUsersettingByLabel($currentModule, 1, 'Highersearch');
//高级查找按钮html
$highsearch_content = '';
if ($highbtnstatus != 'no'){
    $highsearch_content = '<div id="highSearchBtn" style="margin-top: 5px;margin-left: 20px"><a href="javascript:void(0);" onclick="HighersearchPopup()">';
    $highsearch_content .= '<b class="icon-categorybtn categoryAdvsear-search tip-items-list" data-tip="{'.getFixedLabel('CUSTOMIZESEARCH').'" data-direction="top" data-type="position"></b></a></div>';
}
//查看范围
$searchscope_content = $smarty->fetch('SearchScope_New.tpl');

$tmp['SearchContent'] = '<div id="SearchContent" style="display: flex"><input type="hidden" id="scope_senioruserids" value="'.$senioruserid.'"/>'.$customview_content.$searchscope_content.$highsearch_content.'</div>';

//加载高级查找
if (isset($_REQUEST['clearHighSearch']) && $_REQUEST['clearHighSearch'] == 'yes'){
    $controller = new ListViewController($adb, $current_user, $queryGenerator);
    $fieldnames = $controller->getAdvancedSearchOptionString();
    $smarty->assign("COLUMNS_BLOCK", $fieldnames);
    $smarty->assign("SOURCE", 'customview');
    $smarty->assign("PAGEMODE", 'list');
    $tmp['highsearchpopup_content'] = $smarty->fetch('AdvanceFilter.tpl');
}

//查询分类查询
if ($viewid != "0") {
    $queryGenerator->initForCustomViewById($viewid);
} else {
    $queryGenerator->initForDefaultCustomView();
}
//高级查找条件
if (isset($_REQUEST['input'])){
    $queryGenerator->addUserSearchConditions($_REQUEST['input']);
}
$query_wheresql = $queryGenerator->getWhereClause();
$query_wheretable = $queryGenerator->whereFieldTables;
/*****end*****/

/*begin*/
//根据内容模版变量组sql获取所有数据的数组
require_once(globalStatic::$root_directory . 'include/Calendar/CalendarDisplayContent.php');
$calendarBolSql=new CalendarDisplayContent('calendar','');
$focus = $calendarBolSql->getFocus();
$maintablename = $focus->table_name;

//zxm 20230614 获取列表页面公共参数并assign到tpl
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file('Inventory','data');
ListViewCommonAssign($currentModule,$smarty,$focus);


$content_sql = 'SELECT DISTINCT ld_activity.activityid,IFNULL(ld_activity.bgcolor,users_assigned_user_id.usercolor) AS backgroundcolor,ld_activity.date_start,ld_activity.due_date,ld_activity.activitytype ';
$frommain = ' FROM ' . $maintablename .' LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_activity.activityid ';

$datewhere=" AND ((ld_activity.date_start >='$startdate' AND ld_activity.due_date <='$enddate') OR (ld_activity.date_start BETWEEN '$startdate' AND '$enddate') OR (ld_activity.due_date BETWEEN '$startdate' AND '$enddate')) and ld_activity.activitytype <>'emails' ";
//查看范围
$scopeobj=new ScopOfAuthority($adb,"Calendar");
$scope_where = $scopeobj->getSmOwnerSearchSql();
$orderby =" order by ld_activity.date_start asc ";
$where = $query_wheresql.' '.$datewhere.' '.$scope_where;
/*end*/

// ljj 20240125 XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅）
//获取内容模版
$CustomDisplayContent=getUsersettingByLabel('Calendar',1,'CustomDisplayContent');
if (empty($CustomDisplayContent)){
    $CustomDisplayContent = '[var.activity_subject_Calendar] [var.activity_account_id_Calendar]|[var.activity_contact_id_Calendar] [var.activity_assigned_user_id_Calendar]|[var.activity_eventstatus_Calendar]';
}
$calendarBolSql->createPrintSQL($CustomDisplayContent);
//BUG20240520-37 ls 240521 	日程管理，自定义显示内容只设置了显示“主题”时，日历视图不显示日程
$tmpFromQuery = $calendarBolSql->getFromQuery();
$tmpPrintColumns = $calendarBolSql->getPrintColumns();
$tmpPrintTables = $calendarBolSql->getTables();
//dump($tmpPrintTables);
if (stripos($tmpFromQuery, 'users_assigned_user_id') === false) {
    $tmpFromQuery .= " LEFT JOIN ld_users as users_assigned_user_id ON users_assigned_user_id.id = ld_activity.smownerid ";
    $tmpPrintTables['users_assigned_user_id'] = '';
}
$colorRuleRelatedTable=[];
$custom_color_status=getUsersettingByLabel($currentModule,1,'CalendarCustomColorStatus');
$colorRuleColumn_str = '';
if ($custom_color_status == 'yes'){
    crm_load_class_file('CalendarColorRule','modules/Calendar');
    $calendarColorRuleobj = new CalendarColorRule();
    $calendarColorRuleobj->getRules();
    $colorRuleColumnWithTable = $calendarColorRuleobj->getAllRuleColumnsTable();//规则高级查找字段
    $colorRuleRelatedTable = $calendarColorRuleobj->getRuleRelatedTable();//规则高级查找连表
    if (!empty($colorRuleRelatedTable)){
        $query_wheretable = array_merge($query_wheretable,$colorRuleRelatedTable);//自定义内容的连表和高级查找查询分类的连表合并

    }
    //设置循环的多余字段
    $calendarColorRuleobj->setLoopCalendarColunmns(['loop_type','loop_month','loop_dayvalue','reminder_setting','expiredate','loop_calendar']);

    $colorRuleColumn_str = implode(',',$colorRuleColumnWithTable);
    if (!empty($colorRuleColumn_str)) {
        $content_sql = $content_sql.','.$colorRuleColumn_str;
    }
}
if (!array_key_exists('ld_loopcalendar_reminds',$query_wheretable)){
    $query_wheretable['ld_loopcalendar_reminds'] = ' ld_loopcalendar_reminds on ld_loopcalendar_reminds.activityid = ld_activity.activityid ';
}
foreach ($query_wheretable as $tmp_table => $tmp_leftjoin){//连表
    $tmp_table = trim($tmp_table);
    if (!array_key_exists($tmp_table,$tmpPrintTables)){
        $tmpFromQuery .= ' left join '.$tmp_leftjoin.' ';
    }
}
$parent_activityid = ',ld_activity.activityid as parent_activityid ';


//拼接查询sql
$sql = $content_sql.$parent_activityid.$calendarBolSql->getVarSelectQuery().$frommain.$tmpFromQuery.$where.$orderby;
$result=$adb->pquery($sql,array());
$calendar_arr=$adb->query_result_all($result);


/*获取待处理的循环数据 begin*/
//ps: 当“事件状态”不启用时，不需要作为where条件（灿）
$eventstatus_where = '';
if (array_key_exists('eventstatus',$focus->fieldobj->getModuleAllPreseneceFields())) {
    $eventstatus_where = " AND ld_activity.eventstatus <> '已执行' ";
}
$loop_select_column = " ,ld_loopcalendar_reminds.loop_type,ld_loopcalendar_reminds.loop_month,ld_loopcalendar_reminds.loop_dayvalue,ld_loopcalendar_reminds.reminder_setting,ld_loopcalendar_reminds.expiredate";
$loop_where=$query_wheresql." AND ld_activity.activitytype <> 'emails' $eventstatus_where $scope_where
AND ifnull(ld_loopcalendar_reminds.loop_type, 'norepeat') <> 'norepeat'
AND ld_activity.date_start <= ?
AND (
	ifnull(ld_loopcalendar_reminds.expiredate, '') = ''
	OR ld_loopcalendar_reminds.expiredate >= ?
) ";
$loop_sql = $content_sql.$loop_select_column.$calendarBolSql->getVarSelectQuery().$frommain.$tmpFromQuery.$loop_where.$orderby;
//dump($loop_where);
$loop_result=$adb->pquery($loop_sql,array($enddate,$startdate));
$loop_calendar_arr=$calendarBolSql->getLoopPendingData($loop_result,$startdate,$enddate);

$calendar_arr = array_merge($calendar_arr,$loop_calendar_arr);
//dump($calendar_arr);
/*获取待处理的循环数据 end*/

// ljj 20240118 XUQIU1000599 日程管理->日历视图，可自定义单据背景色和字体颜色（杨雅媚） 获取所有条件对应的数据id和颜色
if ($custom_color_status == 'yes'){
    $color_arr=$calendarColorRuleobj->getAllColorByRules($calendar_arr,$startdate,$enddate);
}


$noneArr=array('[var.--none--]'=>'','[var.--无--]'=>'');
foreach ($calendar_arr as $key =>$calendararr){
    $title = strtolower($CustomDisplayContent);
    $backgroundcolor = $calendararr['backgroundcolor'];
    $activityid = $calendararr['activityid'];
    $parent_activityid = $calendararr['parent_activityid'];
    $date_start = $calendararr['date_start'];
    $due_date = $calendararr['due_date'];
    $textcolor='#ffffff';
    if(empty($backgroundcolor)){
        $backgroundcolor="#99c9f2";
    }
    if ($custom_color_status == 'yes'){//根据颜色规则获取背景色和字体颜色
        if (array_key_exists($parent_activityid,$color_arr)){
            $backgroundcolor=$color_arr[$parent_activityid]['backgroundcolor'];
            $textcolor=$color_arr[$parent_activityid]['textcolor'];
        }
    }
    //替换内容模版变量
    $title =strtr($title,$calendararr);
    $title =strtr($title,$noneArr);
    if (isset($calendararr['loop_calendar']) && $calendararr['loop_calendar'] == 'yes') {
        $title = "[循环] ".$title;
    }
//    $allDay = date('His', strtotime($date_start)) === date('His', strtotime($due_date));
    $arr[$key]=array( "id"=>$activityid, "start"=>$date_start,'end'=>$due_date,'title'=>$title,'allDay'=>false,"backgroundColor"=>$backgroundcolor,'textColor'=>$textcolor);
}

$_REQUEST['diony']='diony';
$tmp['lst']=$arr;

//zxm 2021-07-01 日历增加消息提醒设置　查询提醒
$remindArr = [
    'ContactRecordsRemind'=>['remindType'=>'ContactRecordsDate','deploy_type'=>10,'module'=>'ContactRecords'],//跟进记录提醒
    'SalesOrderRemind'=>['remindType'=>'SalesOrderDueDate','deploy_type'=>11,'module'=>'SalesOrder'],//交付日期提醒
    'ServiceContractsRemind'=>['remindType'=>'ServiceContractsDueDate','deploy_type'=>12,'module'=>'ServiceContracts'],//服务到期日提醒
    'PaymentPlanRemind'=>['remindType'=>'PaymentPlanPlanDate','deploy_type'=>13,'module'=>'PaymentPlan'],//计划收款日期提醒
    'SendPaymentRemind'=>['remindType'=>'SendPaymentPlanDate','deploy_type'=>14,'module'=>'SendPayment'],//计划付款日期提醒
];
// 先查询是否有不需要显示的提醒
$appsystemSql = "select deploy_type from ld_appsystem where userid=? and deploy_type in (10,11,12,13,14) and is_open=?";
$appsystemRes = $adb->pquery($appsystemSql,array($current_user->id,'no'));
$nums = $adb->num_rows($appsystemRes);
$deployTypeArr = [];
if($nums>0){
    for($i=0;$i<$nums;$i++){
        $deployTypeArr[] = $adb->query_result($appsystemRes,$i,'deploy_type');
    }
}
$remindTypeArr = [];
foreach($remindArr as $k=>$v){
    if(!in_array($v['deploy_type'],$deployTypeArr)&&vtlib_isModuleActive($v['module'])){
        $remindTypeArr[] = $v['remindType'];
    }
}


if(!empty($remindTypeArr)){
    $remindTypeArr = implode('","',$remindTypeArr);
    $remindTypeArr = '"'.$remindTypeArr.'"';
    //时间date_time 在当天  且remindtype在$remindTypeArr中
    $todayStart = date('Y-m-d').' 00:00:00';
    $todayEnd = date('Y-m-d').' 23:59:59';
    $remindSql = 'SELECT content,date_time,related_to,reltab FROM
        ld_reminds
    WHERE
        deleted = 0
    AND recieverid = ? 
    AND is_del_rec = 0
    AND remindstype in ('.$remindTypeArr.') and status_rmd =?
    AND remindsid > 0';
    $remindSql .=' union all SELECT content,date_time,related_to,reltab FROM
        ld_reminds_accepted
    WHERE
        deleted = 0
    AND recieverid = ? 
    AND is_del_rec = 0
    AND remindstype in ('.$remindTypeArr.') and status_rmd =?
    AND remindsid > 0';
    $remindRes = $adb->pquery($remindSql,array($current_user->id,"未读",$current_user->id,"未读"));
    $remindNums = $adb->num_rows($remindRes);
    $remindList = [];
    if($remindNums>0){
        for($j=0;$j<$remindNums;$j++){
            $date_time = $adb->query_result($remindRes,$j,'date_time');
            $remindList[$j]['content'] = $adb->query_result($remindRes,$j,'content')."\r\n".getFixedLabel('operatoroertime').':'.$date_time;
            $remindList[$j]['start'] = $date_time;
            $remindList[$j]['end'] = $date_time;
            $remindList[$j]['backgroundColor'] = '#99c9f2';
            $remindList[$j]['record'] = $adb->query_result($remindRes,$j,'related_to');
            $remindList[$j]['module'] = $adb->query_result($remindRes,$j,'reltab');
        }
        $tmp['listRemind'] = $remindList;
    }else{
        $tmp['listRemind'] = [];
    }
}else{
    $tmp['listRemind'] = [];
}

ConvertTojsonString(1,$tmp,"success");
?>