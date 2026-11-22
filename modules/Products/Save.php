<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user, $currentModule;

//checkFileAccessForInclusion("modules/$currentModule/$currentModule.php");
require_once("modules/$currentModule/$currentModule.php");

$focus = CRMEntity::getInstance($currentModule);
$mode = $_REQUEST['mode'];
$record=$_REQUEST['record'];
if($record>0)
{
    $focus->retrieve_entity_info($record,'Products');
    $focus->id=$before_columnfieldvalue;
    $focus->mode='edit';
}

setObjectValuesFromRequest($focus);

if($mode) $focus->mode = $mode;
if($record)$focus->id  = $record;

$currencyobj=Currency::getInstance($adb);
$currencyid=$currencyobj->getCurrencyId();

if($_REQUEST['imagelist'] != '')
{
	$del_images = array();
	$del_images = explode('###',$_REQUEST['imagelist']);
	$del_image_array = array_slice($del_images,0,count($del_images)-1);
}

//Checking If image is given or not 
$image_lists=array();
$count=0;

$saveimage = "true";
$image_error = "false";
//end of code to retain the pictures from db
	
if($_REQUEST['activity_mode'] != '') $activity_mode = vtlib_purify($_REQUEST['activity_mode']);
if($_REQUEST['return_module'] != '') { 
	$return_module = vtlib_purify($_REQUEST['return_module']);
} else {
	$return_module = $currentModule;
}
if($_REQUEST['return_action'] != '') {
	$return_action = vtlib_purify($_REQUEST['return_action']);
} else {
	$return_action = 'DetailView';
}
if($_REQUEST['return_id'] != '') $return_id = vtlib_purify($_REQUEST['return_id']);

if(isset($_request['activity_mode']))
	$return_action .= '&activity_mode='.$activity_mode;

if($image_error=="true") { //If there is any error in the file upload then moving all the data to EditView.

	//re diverting the page and reassigning the same values as image error occurs
	
	$field_values_passed.="";
	foreach($focus->column_fields as $fieldname => $val) {
		if(isset($_REQUEST[$fieldname])) {
		
			$field_values_passed.="&";
			$value = $_REQUEST[$fieldname];
			$focus->column_fields[$fieldname] = $value;
			$field_values_passed.=$fieldname."=".$value;
		}
	}
	$values_pass=$field_values_passed;
	$encode_field_values=base64_encode($values_pass);

	$error_module = "Products";
	$error_action = "EditView";

	if($mode=="edit")
	{
		$return_id=$_REQUEST['record'];
	}
	header("location: index.php?action=$error_action&module=$error_module&record=$return_id&return_id=$return_id&return_action=$return_action&return_module=$return_module&activity_mode=$activity_mode&return_viewname=$return_viewname&saveimage=$saveimage&error_msg=$errormessage&image_error=$image_error&encode_val=$encode_field_values.$search");
}
if($saveimage=="true")
{
	$image_lists_db=implode("###",$image_lists);
	$focus->column_fields['imagename']=$image_lists_db;
	
}

if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != '' && $_REQUEST['return_id'] != $focus->id)
	$focus->parentid = $_REQUEST['return_id'];
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module']!='')
	$focus->return_module = $_REQUEST['return_module'];
if($_REQUEST['assigntype'] == 'U') {
	$focus->column_fields['prosmownerid'] = $_REQUEST['prosmownerid'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//28031: 客户查看明细界面：相关信息-知识管理：编辑知识管理单据保存后，没有返回到客户明细界面
$return_module=$_REQUEST['return_module'];
$return_id=$_REQUEST['return_id'];
if(empty($return_module))
{
    $return_module='Products';
}
$focus->save($currentModule);
//28031: 客户查看明细界面：相关信息-知识管理：编辑知识管理单据保存后，没有返回到客户明细界面
$_REQUEST['return_module']=$return_module;
if(!empty($return_id))
    $_REQUEST['return_id']=$return_id;
else
$return_id=$focus->id;


$search=vtlib_purify($_REQUEST['search_url']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

//if($_REQUEST['return_id'] != '') $return_id = vtlib_purify($_REQUEST['return_id']);

$parenttab = getParentTab();
//if(isset($_REQUEST['return_module'])&&$_REQUEST['return_module']=='Vendors'&& isset($_REQUEST['return_id']))
//{
//    $return_module="Products";
//     $return_id=$focus->id;
//}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
	/*  $arr['productid']=$focus->id;
     $arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
    $focus->ReturnAfterSave($before_columnfieldvalue);
    
        
 }else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
  
   header("Location: index.php?action=$return_action&module=$return_module&Create=true&record=$return_id&parenttab=$parenttab&start=".vtlib_purify($_REQUEST['pagenumber']).$search);


}
else
{
  
     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}



?>