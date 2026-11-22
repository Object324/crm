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
require_once('Smarty_setup.php');
require_once("include/utils/utils.php");
require_once("modules/com_lingdang_workflow/VTWorkflowUtils.php");

global $mod_strings, $app_strings, $theme, $adb;
$smarty = new lingdangCRM_Smarty;
$smarty->assign("MOD",$mod_strings);
$smarty->assign("APP",$app_strings);
$smarty->assign("THEME", "$theme");
$smarty->assign("IMAGE_PATH", "themes/$theme/images/");

// Operation to be restricted for non-admin users.
global $current_user;
if(!is_admin($current_user)) {
	$smarty->display(vtlib_getModuleTemplate('lingdang','OperationNotPermitted.tpl'));
} else {
	$module = vtlib_purify($_REQUEST['formodule']);

	$menu_array = Array();

	if(vtlib_isModuleActive('Tooltip')){
		$sql_result = $adb->pquery("select * from ld_settings_field where name = ? and active=0",array('LBL_TOOLTIP_MANAGEMENT'));
		if($adb->num_rows($sql_result) > 0) {
			$menu_array['Tooltip']['location'] = $adb->query_result($sql_result, 0, 'linkto').'&formodule='.$module;
			$menu_array['Tooltip']['image_src'] = lingdang_imageurl($adb->query_result($sql_result, 0, 'iconpath'), $theme);
			$menu_array['Tooltip']['desc'] = getTranslatedString($adb->query_result($sql_result, 0, 'description'),'Tooltip');
			$menu_array['Tooltip']['label'] = getTranslatedString($adb->query_result($sql_result, 0, 'name'),'Tooltip');
		}
	}

	if(VTWorkflowUtils::checkModuleWorkflow($module)){
		$sql_result = $adb->pquery("SELECT * FROM ld_settings_field WHERE name = ? AND active=0",array('LBL_WORKFLOW_LIST'));
			if($adb->num_rows($sql_result) > 0) {
				$menu_array['Workflow']['location'] = $adb->query_result($sql_result, 0, 'linkto').'&list_module='.$module;
				$menu_array['Workflow']['image_src'] = lingdang_imageurl($adb->query_result($sql_result, 0, 'iconpath'), $theme);
				$menu_array['Workflow']['desc'] = getTranslatedString($adb->query_result($sql_result, 0, 'description'),'com_lingdang_workflow');
				$menu_array['Workflow']['label'] = getTranslatedString($adb->query_result($sql_result, 0, 'name'),'com_lingdang_workflow');
			}
	}
	//add blanks for 3-column layout
	$count = count($menu_array)%3;
	if($count>0) {
		for($i=0;$i<3-$count;$i++) {
			$menu_array[] = array();
		}
	}
    /*
    edit:cdw
    date:20130729
    reason:0004551: 评论列表界面上点击 评论 控制面板 图标，在弹出的界面上将 工作流列表去掉
    */
    $a = $menu_array;
    unset($a[Workflow]);
    $menu_array = $a;
    //print_r($menu_array);
    //end
	$smarty->assign('MODULE',$module);
	$smarty->assign('MODULE_LBL',getTranslatedString($module));
	$smarty->assign('MENU_ARRAY', $menu_array);

	$smarty->display(vtlib_getModuleTemplate('lingdang','Settings.tpl'));
}
?>