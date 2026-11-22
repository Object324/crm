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
require_once('Smarty_setup.php');
require_once('data/Tracker.php');
require_once('include/utils/UserInfoUtil.php');
require_once('include/database/PearDatabase.php');
global $adb;

global $mod_strings;
global $app_strings;
global $current_language;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_smarty;

$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("UMOD", $mod_strings);
//$smod_strings = return_module_language($current_language,'Settings');
//$smarty->assign("MOD", $smod_strings);
$smarty->assign("MODULE", 'Settings');
$smarty->assign("IMAGE_PATH", $image_path);

if(isset($_REQUEST['templateid']) && $_REQUEST['templateid']!='')
{
	//$log->info("The templateid is set");
	$tempid = $_REQUEST['templateid'];
	$sql = "select * from ld_documenttemplates where templateid=?";
	$result = $adb->pquery($sql, array($tempid));
	$documenttemplateResult = $adb->fetch_array($result);
}

$smarty->assign("FOLDERNAME", $documenttemplateResult["foldername"]);

$smarty->assign("TEMPLATENAME", $documenttemplateResult["templatename"]);
$smarty->assign("DESCRIPTION", $documenttemplateResult["description"]);
$smarty->assign("TEMPLATEID", $documenttemplateResult["templateid"]);

$smarty->assign("SUBJECT", $documenttemplateResult["subject"]);
$smarty->assign("BODY", decode_html($documenttemplateResult["body"]));

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('VIEW');
$arr['oktext']=getFixedLabel("CONFIRME");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("DetailViewDocumentTemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

?>




