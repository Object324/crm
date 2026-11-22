<?php
/***************************************************************
*{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:20130417
**DESPRITION:明细界面对某个字段进行编辑
***************************************************************/

require_once('modules/Reminds/Reminds.php');
require_once('modules/Calendar/Activity.php');
global $adb,$mod_strings;
global $current_user;


global $currentModule;
$focus =CRMEntity::getInstance('Events');

$ajaxaction = $_REQUEST["ajxaction"];

if($ajaxaction == "DETAILVIEW")
{
    crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
}elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}
?>
