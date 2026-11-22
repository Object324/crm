<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *******************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;

if(!isset($_REQUEST['record']))
	die($mod_strings['ERR_DELETE_RECORD']);

$del_query = 'DELETE FROM ld_portal WHERE portalid=?';
$adb->pquery($del_query, array($_REQUEST['record']));

 //code added for returning back to the current view after delete from list view
header("Location: index.php?action=PortalAjax&module=Portal&file=ListView&mode=ajax&datamode=manage");
?>