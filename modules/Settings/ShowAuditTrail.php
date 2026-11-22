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
require_once('data/Tracker.php');
require_once('modules/Settings/AuditTrail.php');
require_once('modules/Users/Users.php');
require_once('include/logging.php');
require_once('include/utils/utils.php');

global $app_strings;
global $mod_strings;
global $app_list_strings;
global $current_language, $current_user, $adb;
//$current_module_strings = return_module_language($current_language, 'Settings');

global $list_max_entries_per_page_new;
global $urlPrefix;

$log = LoggerManager::getLogger('audit_trial');

global $currentModule;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$focus = new AuditTrail();

$smarty = new lingdangCRM_Smarty;

$category = getParenttab();

$userid = vtlib_purify($_REQUEST['userid']);
$qry = "select * from ld_audit_trial where userid = ? ";
$qry_result = $adb->pquery($qry, array($userid));
$no_of_rows = $adb->num_rows($qry_result);
//Retreiving the start value from request
/*
date:2013-11-04
edit:chj
reson:个人设置  查看操作日志  BUG 0003359 修复
*/
if(isset($pagenum) && $pagenum != '')
{
    $start = $pagenum;
}
else if(isset($_REQUEST['start']) && $_REQUEST['start'] != ''){
	$start = vtlib_purify($_REQUEST['start']);
}else
{
    $start=1;   
}

//Retreive the Navigation array
$navigation_array = getNavigationValues($start, $no_of_rows, '100');

$start_rec = $navigation_array['start'];
$end_rec = $navigation_array['end_val'];
/**
 * edit:kevin
 * date:2013-05-30
 * reason:3994
 */
$record_string= getFixedLabel('SHOWINGRECORDS')." " .$start_rec." - ".$end_rec." " .getFixedLabel('TOTALOF') ." ".$no_of_rows." ".getFixedLabel('RECORDNUMS');

$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"Settings","ShowAuditTrail",'');

//$smarty->assign("MOD", $current_module_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign("LIST_HEADER",$focus->getAuditTrailHeader());
$smarty->assign("LIST_ENTRIES",$focus->getAuditTrailEntries($userid, $navigation_array, $sorder, $sortby));

$smarty->assign("PAGENUM",$pagenum);

$smarty->assign("USERID", $userid);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("CATEGORY",$category);

if($_REQUEST['ajax'] !='')
	$smarty->display("ShowAuditTrailContents.tpl");
else	
	$smarty->display("ShowAuditTrail.tpl");

?>