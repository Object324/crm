<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
include_once('vtlib/lingdang/Utils.php');

$module_disable = $_REQUEST['module_disable'];
$module_name = $_REQUEST['module_name'];
$module_enable = $_REQUEST['module_enable'];
global $mod_strings,$app_strings,$theme;


$smarty = new lingdangCRM_Smarty();
$smarty->assign("MOD",$mod_strings);
$smarty->assign("ALLMENUS",getAllMenuModules());
$smarty->assign("APP",$app_strings);
$smarty->assign("THEME",$theme);
$smarty->assign("ASSIGNED_VALUES",getTopMenuModules());
if($_REQUEST['ajax'] == true) {
    $smarty->display("Settings/MenuEditorAssign.tpl");
} else {
    $smarty->display('Settings/MenuEditor.tpl');
}
function getTopMenuModules() {
	global $adb;
	global $current_user;
	$resultant_array = Array();

	$query = 'select tabid,name,tablabel,tabsequence,parent from ld_tab where parent is not null and presence in (0,2) and tabsequence != -1 order by tabsequence';
	$result = $adb->pquery($query, array());
	for ($i = 0; $i < $adb->num_rows($result); $i++) {
		$moduleName = $adb->query_result($result, $i, 'name');
		$moduleLabel = $adb->query_result($result, $i, 'tablabel');
		$tabid = $adb->query_result($result, $i, 'tabid');
		$parent = $adb->query_result($result, $i, 'parent');

		if (is_admin($current_user)) {
			$resultant_array[] = Array($moduleName, $moduleLabel, $tabid, $parent);
		}
	}
	return $resultant_array;
}
function getAllMenuModules() {
	global $adb;
	global $current_user;
	$resultant_array = Array();
	$query = 'select tabid,name,tablabel,tabsequence,parent from ld_tab where parent is not null and parent!=" " and presence in (0,2) order by tabsequence';
	$result = $adb->pquery($query, array());
	for ($i = 0; $i < $adb->num_rows($result); $i++) {
		$moduleName = $adb->query_result($result, $i, 'name');
		$moduleLabel = $adb->query_result($result, $i, 'tablabel');
		$tabid = $adb->query_result($result, $i, 'tabid');
		$parent = $adb->query_result($result, $i, 'parent');
        if($current_user->getHaveSetProfile("Settings")=="yes") {
			$resultant_array[] = Array($moduleName, $moduleLabel, $tabid, $parent);
		}
	}
	return $resultant_array;
}
?>