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
require_once('Smarty_setup.php');

global $mod_strings,$app_strings,$theme,$adb;
$smarty = new lingdangCRM_Smarty;

$module = vtlib_purify($_REQUEST['formodule']);

$menu_array = Array();

$menu_array['CustomFields']['location'] = 'index.php?module=Settings&action=CustomFieldList&parenttab=Settings&formodule='.$module;
$menu_array['CustomFields']['image_src'] = lingdang_imageurl('orgshar.gif', $theme);
$menu_array['CustomFields']['desc'] = getTranslatedString('LBL_USER_CUSTOMFIELDS_DESCRIPTION','Users');
$menu_array['CustomFields']['label'] = getTranslatedString('LBL_USER_CUSTOMFIELDS','Users');

//add blanks for 3-column layout
$count = count($menu_array)%3;
if($count>0) {
	for($i=0;$i<3-$count;$i++) {
		$menu_array[] = array();
	}
}

$smarty->assign("MOD",$mod_strings);
$smarty->assign("APP",$app_strings);
$smarty->assign("IMAGE_PATH", "themes/$theme/images/");
$smarty->assign('MODULE',$module);
$smarty->assign('MODULE_LBL',getTranslatedString($module));
$smarty->assign('MENU_ARRAY', $menu_array);

$smarty->display(vtlib_getModuleTemplate('lingdang','Settings.tpl'));

?>