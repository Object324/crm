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
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);
$folderAll = $focus->getHideFolder();
$smarty->assign('REPORT_FOLDER',$folderAll);
$smarty->assign('MODULE',$currentModule);
$smarty->display("modules/Customreport/showFolder.tpl");
?>
