<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/


global $adb;


global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);

$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == "DETAILVIEW")
{
	$crmid = $_REQUEST["recordid"];
	$tablename = $_REQUEST["tableName"];
	$fieldname = $_REQUEST["fldName"];
	$fieldvalue = $_REQUEST["fieldValue"];
	if($crmid != "")
	{
		$modObj->retrieve_entity_info($crmid,"Emails");
		$modObj->column_fields[$fieldname] = $fieldvalue;
		$modObj->id = $crmid;
		$modObj->mode = "edit";
		$modObj->save("Emails");
		if($modObj->id != "")
		{
			echo ":#:SUCCESS";
		}else
		{
			echo ":#:FAILURE";
		}   
	}else
	{
		echo ":#:FAILURE";
	}
} elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE") {
	require_once 'include/ListView/RelatedListViewContents.php';
}
elseif($_REQUEST['file'] == 'GroupEmail')
{
        require_once('GroupEmail.php');
}
elseif($_REQUEST['file'] == 'qcreate')
{
        require_once('quickcreate.php');
}
else
{
        require_once('include/Ajax/CommonAjax.php');
}
?>