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

$scannerinfo = new lingdang_MailScannerInfo(trim($_REQUEST['scannername']));

$scannerinfo->delete();

header('Location: index.php?module=Settings&action=MailScanner&parenttab=Settings');

?>