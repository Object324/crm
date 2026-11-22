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

require_once('include/utils/utils.php');
require_once('Smarty_setup.php');
global $adb;

$deletSQL = "DELETE FROM ld_convertleadmapping WHERE editable=1";
$adb->pquery($deletSQL, array());
$insertSQL = "INSERT INTO ld_convertleadmapping(leadfid,accountfid,contactfid,potentialfid) VALUES(?,?,?,?)";
$map = vtlib_purify($_REQUEST['map']);
foreach ($map as $mapping) {
	if (!((empty($mapping['Accounts'])) && (empty($mapping['Contacts'])) && (empty($mapping['Potentials'])))) {

		$adb->pquery($insertSQL, array($mapping['Leads'], $mapping['Accounts'], $mapping['Contacts'], $mapping['Potentials']));
	}
}

header("Location: index.php?action=CustomFieldList&module=Settings&parenttab=Settings");
?>