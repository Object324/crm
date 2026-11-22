<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 * 新增自定义报表	2016-03-01

 * Description:  Chj To be written.

 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.

 * All Rights Reserved.

 * Contributor(s): ______________________________________..

 ********************************************************************************/
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user,$default_language;
/* gyq_14 */
//$smarty = new lingdangCRM_Smarty();
if(!empty($_REQUEST['report_id'])){
	$userid = '';
	$query = 'select GROUP_CONCAT(cast(userid as char)) as userid,ld_customreport_info.allocatetype from ld_customreport2user 
	INNER JOIN ld_customreport_info on ld_customreport_info.report_id = ld_customreport2user.report_id where ld_customreport2user.report_id = ? GROUP BY ld_customreport2user.report_id';
	$result = $adb->pquery($query,array($_REQUEST['report_id']));
	if($adb->num_rows($result) >= 1){
		//$smarty->assign('USERID',$adb->query_result($result,0,'userid'));
		$userid = $adb->query_result($result,0,'userid');
		//$smarty->assign('allocatetype',$adb->query_result($result,0,'allocatetype'));
	}
	echo ','.$userid;
	//exit;
}
/*$smarty->assign('MODULE',$currentModule);
$smarty->display("modules/Customreport/AllocateCustomreport.tpl");*/
?>
