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

require_once('modules/Settings/MailScanner/core/MailScannerRule.php');

$mode = $_REQUEST['mode'];
$targetruleid = $_REQUEST['targetruleid'];
$ruleid = $_REQUEST['ruleid'];
	
if($mode == 'rulemove_up') {
	lingdang_MailScannerRule::resetSequence($ruleid, $targetruleid);
} else if($mode == 'rulemove_down') {
	lingdang_MailScannerRule::resetSequence($ruleid, $targetruleid);
}

include('modules/Settings/MailScanner/MailScannerRule.php');

?>