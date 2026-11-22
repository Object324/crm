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
require_once('include/database/PearDatabase.php');

$id=$_REQUEST['record'];

$sql = "delete from ld_seattachmentsrel where attachmentsid =?";
$adb->pquery($sql, array($id));

$sql = "delete from ld_attachments where attachmentsid =?";
$adb->pquery($sql, array($id));

header("Location:index.php?module=".vtlib_purify($_REQUEST['return_module'])."&action=".vtlib_purify($_REQUEST['return_action'])."&record=".vtlib_purify($_REQUEST['return_id'])."&parenttab=".getParentTab());


?>