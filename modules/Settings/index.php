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

global $mod_strings;
global $app_strings;
global $app_list_strings;

global $theme, $adb;

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//是否启用了审批管理
require_once('modules/Approve/Approve.php');
$approve=new Approve();
$startapprove=$approve->startBlocksApprove();
$sqlH_P="SELECT 1 FROM ld_tab WHERE (NAME = 'HelpDesk' OR NAME = 'ProjectTask') AND presence<>5 and presence<>1;";
    $H_P_result = $adb->pquery($sqlH_P, array());
    $H_P_rowCount = $adb->num_rows($H_P_result);
if($H_P_rowCount>0){
    $query="update ld_settings_field set active=0 where name='LBL_SERVICE_PERFORMANCE_PARAMETERS'";
    $adb->query($query);
}else{
    $query="update ld_settings_field set active=1 where name='LBL_SERVICE_PERFORMANCE_PARAMETERS'";
    $adb->query($query);
}
    
if(empty($startapprove)){
    $query="update ld_settings_field set active=1 where name='LBL_APPROVE'";
    $adb->query($query);
}
else{
    $query="update ld_settings_field set active=0 where name='LBL_APPROVE'";
    $adb->query($query);
}
$smarty = new lingdangCRM_Smarty;
$smarty->assign("APP", $app_strings);
$smarty->assign("MODULE", 'Settings');
$smarty->assign("CATEGORY", 'Settings');
$smarty->assign("MOD", $mod_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("IMAGES", "themes/images/");
$smarty->assign("BLOCKS", getSettingsBlocks());
$SettingsFields = getSettingsFields();
$smarty->assign("languageType", $languageType);
$smarty->assign("FIELDS", $SettingsFields);
$smarty->assign("NUMBER_OF_COLUMNS", 4);	//this is the number of columns in the settings page

$smarty->display("Settings.tpl");
?>