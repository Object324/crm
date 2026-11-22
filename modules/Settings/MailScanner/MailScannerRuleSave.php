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
require_once('modules/Settings/MailScanner/core/MailScannerRule.php');
require_once('modules/Settings/MailScanner/core/MailScannerAction.php');
require_once('Smarty_setup.php');

global $app_strings, $mod_strings, $currentModule, $theme, $current_language;

$scannername = $_REQUEST['scannername'];
$scannerruleid= $_REQUEST['ruleid'];
$scanneractionid=$_REQUEST['actionid'];

$scannerinfo = new lingdang_MailScannerInfo($scannername);
$scannerrule = new lingdang_MailScannerRule($scannerruleid);

$scannerrule->scannerid   = $scannerinfo->scannerid;
$scannerrule->fromaddress = $_REQUEST['rule_from'];
$scannerrule->toaddress = $_REQUEST['rule_to'];
$scannerrule->subjectop = $_REQUEST['rule_subjectop'];
$scannerrule->subject   = $_REQUEST['rule_subject'];
$scannerrule->bodyop    = $_REQUEST['rule_bodyop'];
$scannerrule->body      = $_REQUEST['rule_body'];
$scannerrule->matchusing= $_REQUEST['rule_matchusing'];

$scannerrule->update();

$scannerrule->updateAction($scanneractionid, $_REQUEST['rule_actiontext']);

include('modules/Settings/MailScanner/MailScannerRule.php');

?>