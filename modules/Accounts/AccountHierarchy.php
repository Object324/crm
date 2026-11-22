<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 *The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

global $app_strings, $default_charset, $currentModule, $current_user, $theme;

$smarty = new lingdangCRM_Smarty;
if (!isset($where)) $where = "";

$parent_tab=getParentTab();
$smarty->assign("CATEGORY",$parent_tab);

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("MODULE",$currentModule);

//$check_button = Button_Check($currentModule); 
//$check_button['Import'] = 'no'; 
//$check_button['Export'] = 'no';
//$check_button['moduleSettings'] = 'no';
//$smarty->assign("CHECK", $check_button);

$focus = CRMEntity::getInstance($currentModule);
$accountid = vtlib_purify($_REQUEST['accountid']);
if (!empty($accountid)) {
	$hierarchy = $focus->getAccountHierarchy($accountid);
}
$smarty->assign('ACCOUNTID',$accountid);
$smarty->assign("ACCOUNT_HIERARCHY",$hierarchy);
$smarty->display("AccountHierarchy.tpl");
	
?>