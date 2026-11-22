<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 * 新增自定义报表	2016-03-01

 * Description:  Chj To be written.

 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.

 * All Rights Reserved.

 * Contributor(s): ______________________________________..

 ********************************************************************************/
global $currentModule,$adb,$default_language;
$smarty = new lingdangCRM_Smarty();

$report_folder_id = $_REQUEST['folder_id'];

$query = 'SELECT folder_id,report_id,report_name from ld_customreport_info where presence=5 and presence <> 1 and folder_id =? ';

$result = $adb->pquery($query,array($report_folder_id));
$nums = $adb->num_rows($result);
for($i = 0; $i<$nums; $i++){
    $report_folder[$i]['report_id'] = $adb->query_result($result,$i,'report_id');
	$report_folder[$i]['report_name'] = $adb->query_result($result,$i,'report_name');
}


$smarty->assign('REPORT_FOLDER',$report_folder);
$smarty->assign('MODULE',$currentModule);
$smarty->display("modules/Customreport/showReport.tpl");
?>
