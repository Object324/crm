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
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user, $currentModule;
global $adb;
$smarty = new lingdangCRM_Smarty();

crm_load_class_file('cls_RolesProfile','modules/Settings');
$getRolesProfileObj = new cls_getRolesProfile($adb,$current_user);

include('modules/Settings/RolesProfileContent.php');

ConvertTojsonString(1, $arr, "success");

?>