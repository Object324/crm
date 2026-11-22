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
global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);

$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == 'DETAILVIEW')
{
    crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
	//$crmid = $_REQUEST['recordid'];
//	$tablename = $_REQUEST['tableName'];
//	$fieldname = $_REQUEST['fldName'];
//	$fieldvalue = utf8RawUrlDecode($_REQUEST['fieldValue']); 
//	if($crmid != '')
//	{
//		$modObj->retrieve_entity_info($crmid, $currentModule);
//		$modObj->column_fields[$fieldname] = $fieldvalue;
//		$modObj->id = $crmid;
//		$modObj->mode = 'edit';
//		$modObj->save($currentModule);
//		if($modObj->id != '')
//		{
//			echo ':#:SUCCESS';
//		}else
//		{
//			echo ':#:FAILURE';
//		}   
//	}else
//	{
//		echo ':#:FAILURE';
//	}
} elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}
?>