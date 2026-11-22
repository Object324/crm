<?php

//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


global $adb,$currentModule;
$focus =CRMEntity::getInstance($currentModule);
//added to fix 4600
if($_REQUEST['record']>0)
{
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
    $focus->mode='edit';
    
}
$search=vtlib_purify($_REQUEST['search_url']);

setObjectValuesFromRequest($focus);

$focus->save($currentModule);
$return_id = $focus->id;

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = $currentModule;
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
  /*  $arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
    $focus->ReturnAfterSave($before_columnfieldvalue);
    
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&Create=true&activity_mode=$activitymode&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}
else
{
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&activity_mode=$activitymode&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}

?>