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
require_once('vtlib/lingdang/Cron.php');

global $app_strings, $mod_strings, $currentModule, $theme, $current_language;
global $application_unique_key; // defined in config.inc.php

$smarty = new lingdangCRM_Smarty;
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH","themes/$theme/images/");

$scanners = lingdang_MailScannerInfo::listAll();

$smarty->assign("SCANNERS", $scanners);
$smarty->assign("APP_KEY", $application_unique_key);
$smarty->assign("CRON_TASK", lingdang_Cron::getInstance('MailScanner'));

$smarty->display('MailScanner/MailScannerInfo.tpl');

?>