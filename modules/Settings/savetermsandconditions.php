<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
require_once('include/utils/utils.php');

$inv_type='Inventory';
$inv_tandc=from_html($_REQUEST['inventory_tandc']);

$sql="select * from ld_inventory_tandc where type=?";
$result = $adb->pquery($sql, array($inv_type));
$inv_id = $adb->query_result($result,0,'id');
if($inv_id == '')
{
	$inv_id=$adb->getUniqueID('ld_inventory_tandc');
    $sql="insert into ld_inventory_tandc values(?,?,?)";
	$params = array($inv_id, $inv_type, $inv_tandc);
}
else
{
	$sql="update ld_inventory_tandc set type = ?, tandc = ? where id = ?";
	$params = array($inv_type, $inv_tandc, $inv_id);
}
$adb->pquery($sql, $params);

header("Location: index.php?module=Settings&action=OrganizationTermsandConditions&parenttab=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
?>