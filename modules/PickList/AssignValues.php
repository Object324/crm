<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
require_once 'include/utils/utils.php';
require_once 'modules/PickList/PickListUtils.php';
require_once 'Smarty_setup.php';

global $adb, $current_user, $app_strings, $current_language, $theme;

$smarty = new lingdangCRM_Smarty;
$smarty->assign("IMAGE_PATH",$image_path);

$fieldName = vtlib_purify($_REQUEST["fieldname"]);
$fieldLabel = vtlib_purify($_REQUEST['fieldlabel']);
$moduleName = vtlib_purify($_REQUEST["moduleName"]);
$roleid = vtlib_purify($_REQUEST['roleid']);
if(!empty($roleid)){
	$roleName = getProfileName($roleid);
}



if(!empty($fieldName)){
	foreach (getAllPickListValues($fieldName,$temp_module_strings) as $key => $value) {
		$values[htmlentities($value,ENT_QUOTES,'UTF-8')] = $value;
	}
}

foreach (getAssignedPicklistValues($fieldName, $roleid, $adb, $temp_module_strings) as $key => $value) {
		$assignedValues[htmlentities($value,ENT_QUOTES,'UTF-8')] = $value;
}

$smarty->assign("THEME",$theme);
$smarty->assign("FIELDNAME",$fieldName);
$smarty->assign("FIELDLABEL", $fieldLabel);
$smarty->assign("MODULE",$moduleName);
$smarty->assign("PICKVAL",$values);
$smarty->assign("ASSIGNED_VALUES",$assignedValues);
$smarty->assign("ROLEID",$roleid);
$smarty->assign("ROLENAME", $roleName);
$smarty->assign("MOD", return_module_language($current_language,'PickList'));
$smarty->assign("APP",$app_strings);

$data = $smarty->fetch("modules/PickList/AssignPicklistValues.tpl");
echo $data;

?>