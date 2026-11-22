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

global $adb,$current_user;

$cfmid=vtlib_purify($_REQUEST['cfmid']);

$deleteSql="DELETE FROM ld_convertleadmapping WHERE cfmid=?";
$result=$adb->pquery($deleteSql,array($cfmid));

$listURL='index.php?action=CustomFieldList&module=Settings&parenttab=Settings';
header(sprintf("Location: %s",$listURL));

?>