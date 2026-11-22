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
require_once('user_privileges/audit_trail.php');
require_once('Smarty_setup.php');
global $app_strings;
global $mod_strings;
global $currentModule;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_language;

$smarty = new lingdangCRM_Smarty;

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
//$smarty->assign("USERLIST",getUserslist());
$smarty->assign("USERLIST",getUserslistSearch());

if($audit_trail == 'true')
	$server = 'enabled';
else
	$server = 'disabled';

$smarty->assign("AuditStatus", $server);

require_once('SetmenuControl.php');  
$smarty->display('AuditTrailList.tpl');


?>