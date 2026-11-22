<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//require_once('modules/Expense/Expense.php');

//require_once('include/database/PearDatabase.php');

$version_info = getVersionInfo();
global $adb,$currentModule;
$LINGDANG_BULK_SAVE_MODE = false;
$focus = CRMEntity::getInstance($currentModule);
$focus->mode=$_REQUEST['mode'];
$search=$_REQUEST['search_url'];
if(isset($_REQUEST['record']) && $_REQUEST['record'] >0)
{
    $focus->id = $_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $currency_id = $focus->column_fields['currency_id'];

    $before_columnfieldvalue=$focus->column_fields;
    $focus->mode='edit';
}
setObjectValuesFromRequest($focus);

if($_REQUEST['assigned_type'] == 'U') {
    $focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
    $focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}

$focus->save("PricePolicy");

$return_id = $focus->id;
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Expense";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
    $return_action .= '&query_session=1';
}

$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    $focus->ReturnAfterSave($before_columnfieldvalue);
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&Create=true&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
else{
    header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
exit();
?>