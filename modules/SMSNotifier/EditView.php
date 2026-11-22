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
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('Smarty_setup.php');
require_once("include/utils/utils.php");
require_once("modules/com_lingdang_workflow/VTWorkflowUtils.php");

// Operation to be restricted for non-admin users.
global $current_user;
	$smarty->display(vtlib_getModuleTemplate('lingdang','OperationNotPermitted.tpl'));	
?>