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
require_once('modules/Settings/MailScanner/core/MailBox.php');
require_once('Smarty_setup.php');

global $app_strings, $mod_strings, $currentModule, $theme, $current_language;

$smarty = new lingdangCRM_Smarty;
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH","themes/$theme/images/");

$scannername = $_REQUEST['scannername'];
$scannerinfo = new lingdang_MailScannerInfo($scannername);

$mailbox = new lingdang_MailBox($scannerinfo);
$isconnected = $mailbox->connect();
if($isconnected) {
	$folders = $mailbox->getFolders();
	$scannerinfo->updateFolderInfo($folders);
}

$smarty->assign("SCANNERINFO", $scannerinfo->getAsMap());
$smarty->assign("FOLDERINFO", $scannerinfo->getFolderInfo());

$smarty->display('MailScanner/MailScannerFolder.tpl');

?>