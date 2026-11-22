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


$scannername = vtlib_purify(trim($_REQUEST['mailboxinfo_scannername']));
if(!empty($scannername) && !validateAlphanumericInput($scannername)) {
	$scannername = '';
}
$server     = vtlib_purify(trim($_REQUEST['mailboxinfo_server']));
if(!empty($server) && !validateServerName($server)) {
	$server = '';
}
$username   = vtlib_purify(trim($_REQUEST['mailboxinfo_username']));
if(!empty($username) && !validateEmailId($username) && !validateAlphanumericInput($username)) {
	$username = '';
}

$newscannerinfo = new lingdang_MailScannerInfo(false, false);
$newscannerinfo->scannername = $scannername;
$newscannerinfo->server     = $server;
$newscannerinfo->protocol   = vtlib_purify(trim($_REQUEST['mailboxinfo_protocol']));
$newscannerinfo->username   = $username;
$newscannerinfo->password   = vtlib_purify(trim($_REQUEST['mailboxinfo_password']));
$newscannerinfo->ssltype    = vtlib_purify(trim($_REQUEST['mailboxinfo_ssltype']));
$newscannerinfo->sslmethod  = vtlib_purify(trim($_REQUEST['mailboxinfo_sslmethod']));
$newscannerinfo->searchfor  = vtlib_purify(trim($_REQUEST['mailboxinfo_searchfor']));
$newscannerinfo->markas     = vtlib_purify(trim($_REQUEST['mailboxinfo_markas']));
$newscannerinfo->isvalid    =($_REQUEST['mailboxinfo_enable'] == 'true')? true : false;

// Rescan all folders on next run?
$rescanfolder = ($_REQUEST['mailboxinfo_rescan_folders'] == 'true')? true : false;

$isconnected = false;

$scannerinfo = new lingdang_MailScannerInfo(trim($_REQUEST['hidden_scannername']));

if(!$scannerinfo->compare($newscannerinfo)) {
	$mailbox = new lingdang_MailBox($newscannerinfo);

	$isconnected = $mailbox->connect();
	if($isconnected) $newscannerinfo->connecturl = $mailbox->_imapurl;

} else {
	$isconnected = true;
	$scannerinfo->isvalid = $newscannerinfo->isvalid; // Copy new value
	$newscannerinfo = $scannerinfo;
}

if(!$isconnected) {
	require_once('Smarty_setup.php');
	global $app_strings, $mod_strings, $currentModule, $theme, $current_language;

	$smarty = new lingdangCRM_Smarty;
	//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
	$smarty->assign("CMOD", $mod_strings);
	$smarty->assign("APP", $app_strings);
	$smarty->assign("THEME", $theme);
	$smarty->assign("IMAGE_PATH","themes/$theme/images/");

	$smarty->assign("SCANNERINFO", $newscannerinfo->getAsMap());
	$smarty->assign("CONNECTFAIL", "Connecting to mailbox failed!");
	$smarty->display('MailScanner/MailScannerEdit.tpl');	
} else {

	$mailServerChanged = $scannerinfo->update($newscannerinfo);
	
	$scannerinfo->updateAllFolderRescan($rescanfolder);

	// Update lastscan on all the available folders.
	if($mailServerChanged && $mailbox) {
		$folders = $mailbox->getFolders();
		foreach($folders as $folder) $scannerinfo->updateLastscan($folder);
	}

	require('modules/Settings/MailScanner/MailScannerInfo.php');
}
?>