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
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
	
global $adb;
$record = vtlib_purify($_REQUEST['record']);
$pricebook_id = vtlib_purify($_REQUEST['pricebook_id']);
$product_id = vtlib_purify($_REQUEST['product_id']);
$listprice = vtlib_purify($_REQUEST['list_price']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$return_module = vtlib_purify($_REQUEST['return_module']);

$query = "update ld_pricebookproductrel set listprice=? where pricebookid=? and productid=?";
$adb->pquery($query, array($listprice, $pricebook_id, $product_id)); 
header("Location: index.php?module=$return_module&action=".$return_module.
		"Ajax&file=$return_action&ajax=true&record=$record");
?>