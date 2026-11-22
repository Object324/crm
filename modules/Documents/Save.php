<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Documents/Documents.php');
require_once('include/upload_file.php');
global $root_directory;
global $currentModule;
$focus =CRMEntity::getInstance($module);
//added to fix 4600
setObjectValuesFromRequest($focus);
$search=vtlib_purify($_REQUEST['search_url']);

if(isset($_REQUEST['notecontent']) && $_REQUEST['notecontent'] != "")
	$_REQUEST['notecontent'] = fck_from_html($_REQUEST['notecontent']);

if (!isset($_REQUEST['date_due_flag'])) $focus->date_due_flag = 'off';

if(isset($_REQUEST['parentid']) && $_REQUEST['parentid'] != '')
	$focus->parentid = $_REQUEST['parentid'];
if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//28031: 客户查看明细界面：相关信息-知识管理：编辑知识管理单据保存后，没有返回到客户明细界面
$return_module=$_REQUEST['return_module'];
$return_id=$_REQUEST['return_id'];


$focus->save($currentModule);
//28031: 客户查看明细界面：相关信息-知识管理：编辑知识管理单据保存后，没有返回到客户明细界面
$_REQUEST['return_module']=$return_module;
$_REQUEST['return_id']=$return_id;
$return_id = $focus->id;
$note_id = $return_id;

$parenttab = getParentTab();

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Documents";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


//$local_log->debug("Saved record with id of ".$return_id);

//Redirect to EditView if the given file is not valid.
if($file_upload_error)
{
	$return_module = 'Documents';
	$return_action = 'EditView';
	$return_id = $note_id.'&upload_error=true&return_module='.$return_module.'&return_action='.$return_action.'&return_id='.$return_id;
}

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    $focus->setRefreshListModules(array("Documents"));
    $focus->setRefreshDetailModules(array("Documents"));
    $focus->ReturnAfterSave($before_columnfieldvalue);
     //  $arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{

   header("Location: index.php?action=$return_action&Create=true&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);


}
else
{

     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}



?>