<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

global $adb;

if($_REQUEST['idstring'] != '')
	$idlist = $_REQUEST['idstring'];
elseif($_REQUEST['idlist'] != '')
	$idlist = $_REQUEST['idlist'];

$selected_array = explode(";",$idlist);
foreach($selected_array as $account_id) {
	if($account_id != '') 	{
		$query = "update ld_mail_accounts set status=0 where account_id=?";
		$adb->pquery($query, array($account_id));
	}
}

header("Location:index.php?module=Settings&action=ListMailAccount");

?>