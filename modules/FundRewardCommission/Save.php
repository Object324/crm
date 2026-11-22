<?php


//require_once('include/logging.php');
//require_once('include/database/PearDatabase.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$search=vtlib_purify($_REQUEST['search_url']);

global $currentModule;
$focus =CRMEntity::getInstance($currentModule);
global $current_user,$adb,$currentModule;

if(isset($_REQUEST['record']))
{
	$focus->id = $_REQUEST['record'];
}

if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}


setObjectValuesFromRequest($focus);


$focus->save("FundRewardCommission");//调用公用的save方法保存

$return_id = $focus->id;

$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "FundRewardCommission";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
//$local_log->debug("Saved record with id of ".$return_id);

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);
if($_REQUEST['SearchScope']!='')     $SearchScope=$_REQUEST['SearchScope'];



if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&Create=true&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
else
{
    $_REQUEST['id']=$return_id;
    $_REQUEST['sendSms']=$assign_user_id;
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&id=$return_id&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}

?>