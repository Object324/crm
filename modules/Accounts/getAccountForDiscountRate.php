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
	if(!empty($_REQUEST['accountid'])){
		$query = 'select discount_rate from ld_account where accountid = ? limit 1';
		$result = $adb->pquery($query,array($_REQUEST['accountid']));
		$discount_rate = $adb->query_result($result,0,0);
		if(empty($discount_rate)){
			echo 0;
		}else{
			echo 100 - $discount_rate;
		}
		exit();
	}
?>