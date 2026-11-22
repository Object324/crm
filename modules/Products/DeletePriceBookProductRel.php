<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb;

$return_id = vtlib_purify($_REQUEST['return_id']);
$record = vtlib_purify($_REQUEST['record']);
$return_module = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);

if($return_action !='' && $return_module == "PriceBooks" && $return_action == "CallRelatedList")
{

	$query = "delete from ld_pricebookproductrel where pricebookid=? and productid=?";
	$adb->pquery($query, array($return_id, $record)); 
}
else
{
//	$log->info("Products :: Deleting Price Book");
	$query = "delete from ld_pricebookproductrel where pricebookid=? and productid=?";
	$adb->pquery($query, array($record, $return_id)); 
}

ConvertTojsonString(1,'','success');

//header("Location: index.php?module=".$return_module."&action=".$return_module.
//		"Ajax&file=$return_action&ajax=true&record=".$return_id);
?>