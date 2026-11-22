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
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
if(isset($_REQUEST['currencyid']) && isset($_REQUEST['cur_type']))
{
	if($_REQUEST['cur_type'] == 'INACTIVATE')
		$cur_type = 'Inactive';
	else
		$cur_type = 'Active';
	$sql = "update ld_currency_info set currency_status=? where id =?";
	$adb->pquery($sql, array($cur_type,$_REQUEST['currencyid']));
}
/*$del_id = $_REQUEST['delete_currency_id'];
$tran_id = $_REQUEST['transfer_currency_id'];

// Transfer all the data refering to currency $del_id to currency $tran_id
transferCurrency($del_id, $tran_id);

// Mark Currency as deleted
$sql = "update ld_currency_info set deleted=1 where id =?";
$adb->pquery($sql, array($del_id));*/

header("Location: index.php?action=SettingsAjax&module=Settings&file=CurrencyListView&ajax=true1");

?>
