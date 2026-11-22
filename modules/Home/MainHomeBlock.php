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
global $theme,$current_user;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
require_once('include/home.php');
require_once('Smarty_setup.php');

$homeObj=new Homestuff();
$smarty=new lingdangCRM_Smarty;
$smarty->assign("IsAdmin",is_admin($current_user));

$smarty->assign("MOD",$mod_strings);
$smarty->assign("APP",$app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);

//$smarty->assign("HOME_STUFF",$homestuff_values);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->display("Home/MainHomeBlock.tpl");

?>