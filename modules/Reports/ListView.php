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
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once("data/Tracker.php");
require_once('Smarty_setup.php');
require_once('include/logging.php');
require_once('include/utils/utils.php');
require_once('modules/Reports/Reports.php');


global $app_strings;
global $app_list_strings;
global $mod_strings;
//$current_module_strings = return_module_language($current_language, 'Reports');

global $list_max_entries_per_page_new;
global $urlPrefix,$current_user;

$log = LoggerManager::getLogger('report_list');

global $currentModule;

global $image_path;
global $theme;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
// focus_list is the means of passing data to a ListView.
global $focus_list;

$list_report_form = new lingdangCRM_Smarty;
$list_report_form->assign("MOD", $mod_strings);
$list_report_form->assign("APP", $app_strings);
$list_report_form->assign("APPLIST", $app_list_strings);
$list_report_form->assign("THEME", $theme);
$list_report_form->assign("IMAGE_PATH", $image_path);

$list_report_form->assign("CATEGORY",getParentTab());
$list_report_form->assign("MODULE",$currentModule);
$list_report_form->assign("NEWRPT_BUTTON",$newrpt_button);
$list_report_form->assign("NEWRPT_FLDR_BUTTON",$newrpt_fldr_button);
$repObj = new Reports();
$list_report_form->assign("REPT_FLDR",$repObj->sgetRptFldr('SAVED'));
$cusFldrDtls = Array();
$cusFldrDtls = $repObj->sgetRptFldr('CUSTOMIZED');
$list_report_form->assign("REPT_CUSFLDR",$cusFldrDtls);
foreach($cusFldrDtls as $entries)
{
	$fldrids_lists [] =$entries['id'];
}

if(count($fldrids_lists) > 0)
	$list_report_form->assign("FOLDE_IDS",implode(',',$fldrids_lists));
    /*
    edit:cdw
    date:20130726
    reason:0004543: 建议：建立报表中报表模块下拉框值去掉“日报/周报/月报”
    */
    $arr = getReportsModuleList($repObj);
    unset($arr['ReportLog']);
    //end
//$list_report_form->assign("REPT_MODULES",getReportsModuleList($repObj));
$list_report_form->assign("REPT_MODULES",$arr);
//end
$list_report_form->assign("REPT_FOLDERS",$repObj->sgetRptFldr());

$list_report_form->assign("DEL_DENIED",vtlib_purify($_REQUEST['del_denied']));

$list_report_form->assign('LANGUAGETYPE',$languageType);
if($_REQUEST['mode'] == 'ajax'){
	$list_report_form->display("ReportsCustomize.tpl");
    
}elseif( $_REQUEST['mode'] == 'ajaxdelete' ){
	$list_report_form->display("ReportContents.tpl");
}else{
	$list_report_form->display("Reports.tpl");
}
?>