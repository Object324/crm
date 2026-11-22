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
require_once('include/utils/UserInfoUtil.php');
global $adb;
$shareid =  $_REQUEST['shareid'];
deleteSharingRule($shareid);

/** This function is to delete the organisation level sharing rule
  * It takes the following input parameters:
  *     $shareid -- Id of the Sharing Rule to be updated
  */
function deleteSharingRule($shareid)
{
	
	global $adb;
	$query2="select * from ld_datashare_module_rel where shareid=?";
	$res=$adb->pquery($query2, array($shareid));
	$typestr=$adb->query_result($res,0,'relationtype');
	$tabname=getDSTableNameForType($typestr);
	$query3="delete from $tabname where shareid=?";
	$adb->pquery($query3, array($shareid));
	$query4="delete from ld_datashare_module_rel where shareid=?";
	$adb->pquery($query4, array($shareid));

	//deleting the releated module sharing permission
	$query5="delete from ld_datashare_relatedmodule_permission where shareid=?";
	$adb->pquery($query5, array($shareid));
	

}
header("Location: index.php?module=Settings&action=OrgSharingDetailView&parenttab=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
?>