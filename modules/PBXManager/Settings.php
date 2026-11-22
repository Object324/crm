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
require_once ('include/utils/utils.php');
require_once ('Smarty_setup.php');
global $app_strings;
global $mod_strings;
global $adb;
global $currentModule;
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
global $current_language;

$smarty = new lingdangCRM_Smarty;

$smarty->assign("THEME", $theme);
$smarty->assign("APP", $app_strings);
$smarty->assign("IMAGE_PATH", $image_path);

$result = $adb->pquery("select * from ld_asterisk", array ());
if($adb->num_rows($result) > 0){
	$asterisk_server_ip = $adb->query_result($result, 0, 'server');
	$asterisk_port = $adb->query_result($result, 0, 'port');
	$asterisk_username = $adb->query_result($result, 0, 'username');
	$asterisk_password = $adb->query_result($result, 0, 'password');
	$asterisk_version = $adb->query_result($result, 0, 'version');
}

$smarty->assign("ASTERISK_SERVER_IP", $asterisk_server_ip);
$smarty->assign("ASTERISK_PORT", $asterisk_port);
$smarty->assign("ASTERISK_USERNAME", $asterisk_username);
$smarty->assign("ASTERISK_PASSWORD", $asterisk_password);
$smarty->assign("ASTERISK_VERSION", $asterisk_version);

$smarty->display(vtlib_getModuleTemplate('PBXManager', 'Settings.tpl'));
?>