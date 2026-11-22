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

require_once 'include/utils/utils.php';
require_once 'modules/Reports/ScheduledReports.php';

global $theme,$current_user;
global $adb;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty;
$log = LoggerManager::getLogger('report_type');

$smarty->assign("MOD", return_module_language($current_language,'Reports'));
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);

$availableUsersHTML = VTScheduledReport::getAvailableUsersHTML();
$availableGroupsHTML = VTScheduledReport::getAvailableGroupsHTML();
$availableRolesHTML = VTScheduledReport::getAvailableRolesHTML();
$availableRolesAndSubHTML = VTScheduledReport::getAvailableRolesAndSubordinatesHTML();

$smarty->assign("AVAILABLE_USERS", $availableUsersHTML);
$smarty->assign("AVAILABLE_GROUPS", $availableGroupsHTML);
$smarty->assign("AVAILABLE_ROLES", $availableRolesHTML);
$smarty->assign("AVAILABLE_ROLESANDSUB", $availableRolesAndSubHTML);

$reportid = vtlib_purify($_REQUEST["record"]);

$scheduledReport = new VTScheduledReport($adb, $current_user, $reportid);
$scheduledReport->getReportScheduleInfo();

$smarty->assign('IS_SCHEDULED', $scheduledReport->isScheduled);
$smarty->assign('REPORT_FORMAT', $scheduledReport->scheduledFormat);

$selectedRecipientsHTML = $scheduledReport->getSelectedRecipientsHTML();
$smarty->assign("SELECTED_RECIPIENTS", $selectedRecipientsHTML);

$smarty->assign("schtypeid",$scheduledReport->scheduledInterval['scheduletype']);
$smarty->assign("schtime",$scheduledReport->scheduledInterval['time']);
$smarty->assign("schday",$scheduledReport->scheduledInterval['date']);
$smarty->assign("schweek",$scheduledReport->scheduledInterval['day']);
$smarty->assign("schmonth",$scheduledReport->scheduledInterval['month']);

$smarty->display("ReportsScheduleEmail.tpl");

?>