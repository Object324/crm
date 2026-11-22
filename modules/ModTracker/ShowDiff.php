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
global $app_strings, $mod_strings, $current_language, $currentModule, $theme;
global $list_max_entries_per_page_new,$adb,$current_user;

require_once('Smarty_setup.php');

include_once dirname(__FILE__) . '/core/ModTracker_Basic.php';

$smarty = new lingdangCRM_Smarty();


// Identify this module as custom module.
$smarty->assign('CUSTOM_MODULE', true);

$smarty->assign('MOD', $mod_strings);
$smarty->assign('APP', $app_strings);
$smarty->assign('MODULE', $currentModule);
$smarty->assign('SINGLE_MOD', $currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('THEME', $theme);

$reqid = vtlib_purify($_REQUEST['id']);

$atpoint = vtlib_purify($_REQUEST['atpoint']);

$frommod = getEntitySetype($reqid);//获取setype字段方法 tujt 2014-07-31
$smarty->assign('LOGMODULE', $frommod);

 $field_obj=Field::getInstance($frommod,$adb);

$smarty->assign('ARRFIELDLABEL',$field_obj->getFieldLables());
// Calculate the paging before hand
$prevAtPoint = ($atpoint + 1);
$nextAtPoint = ($atpoint - 1);

$trackrecord = false;
//var_dump($_REQUEST['mode']);
if($_REQUEST['mode'] == 'history') {
	// Retrieve the track record at required point
    //var_dump($reqid);echo "<br>";
     //var_dump($atpoint);
	$trackrecord = ModTracker_Basic::getByCRMId($reqid, $atpoint);
    //var_dump($trackrecord);//var_dump($atpoint);
	// If there is no more older records, show the last record itself
    //echo $atpoint;
	if($trackrecord === false && $atpoint > 0) {
		$atpoint = $atpoint - 1;
		$prevAtPoint = $atpoint; // Singal no more previous
		$trackrecord = ModTracker_Basic::getByCRMId($reqid, $atpoint);
	}
    //edit:can reason:11465: 修改日志功能异常 ,other:获取日志记录数目
    $smarty->assign('SHOWHISTORYCOUNT',ModTracker_Basic::gethistorylistCount($reqid));
} else {
   
	$trackrecord = ModTracker_Basic::getById($reqid);
  
}
  
if($trackrecord === false || !$trackrecord->exists()) 
{
    $smarty->assign('TRACKRECORD', $trackrecord);
	$smarty->display(vtlib_getModuleTemplate($currentModule, 'ShowDiffNotExist.tpl'));//$currentModule="ModTracker";
} 
else 
{
	if ($trackrecord && $trackrecord->isViewPermitted()) 
    {
        //$smarty->assign("HISTORYCOUNT", $trackrecord->getlistCount());
        $smarty->assign('TRACKRECORD', $trackrecord);
		$smarty->assign("ATPOINT", $atpoint);
		$smarty->assign("ATPOINT_PREV", $prevAtPoint);
		$smarty->assign("ATPOINT_NEXT", $nextAtPoint);
		$smarty->display(vtlib_getModuleTemplate($currentModule, 'ShowDiff.tpl'));
	} 
    else{
		$smarty->display(vtlib_getModuleTemplate($currentModule, 'ShowDiffDenied.tpl'));
	}
}
?>