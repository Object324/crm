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
require_once('database/DatabaseConnection.php');
require_once('Smarty_setup.php');
//require_once('include/utils/utils.php');
require_once('data/Tracker.php');
require_once('include/utils/UserInfoUtil.php');

global $app_strings;
global $mod_strings;
global $current_language,$default_charset;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//$smod_strings = return_module_language($current_language,'Settings');
//To get Email Template variables -- Pavani
$allOptions=getEmailTemplateVariables();
$smarty = new lingdangCRM_smarty;

$smarty->assign("APP", $app_strings);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH", $theme_path);
//$smarty->assign("UMOD",$mod_strings);
$smarty->assign("PARENTTAB", getParentTab());
$smarty->assign("ALL_VARIABLES", $allOptions);

$smarty->assign("MOD", $smod_strings);
$smarty->assign("MODULE", 'Settings');

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('THEDOCUMENTTEMPLATE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("CreateDocumentsTemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>