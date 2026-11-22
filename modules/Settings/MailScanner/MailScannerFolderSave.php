<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/
require_once('modules/Settings/MailScanner/core/MailScannerInfo.php');
require_once('Smarty_setup.php');

$scannername = $_REQUEST['scannername'];
$scannerinfo = new lingdang_MailScannerInfo($scannername);

$folderinfo = Array();
foreach($_REQUEST as $key=>$value) {
	$matches = Array();
	if(preg_match("/folder_([0-9]+)/", $key, $matches)) {
		$folderinfo[$value] = Array('folderid'=>$matches[1], 'enabled'=>1);
	}
}
$scannerinfo->enableFoldersForScan($folderinfo);

include('modules/Settings/MailScanner/MailScannerInfo.php');

?>