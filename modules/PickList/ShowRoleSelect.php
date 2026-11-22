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

require_once 'modules/PickList/PickListUtils.php';
require_once 'include/utils/utils.php';
require_once('Smarty_setup.php');

global $mod_strings, $current_language,$adb;

$roleid = $_REQUEST['roleid'];
if(empty($roleid)){
	echo "role id cannot be empty";
	exit;
}

$otherRoles = getrole2picklist();
$otherRoles = array_diff($otherRoles, array($roleid=>getProfileName($roleid)));

$smarty = new lingdangCRM_Smarty;
$smarty->assign("ROLES",$otherRoles);
$smarty->assign("MOD", return_module_language($current_language,'PickList'));
$smarty->assign("APP",$app_strings);

$str = $smarty->fetch("modules/PickList/ShowRoleSelect.tpl");
echo $str;
?>