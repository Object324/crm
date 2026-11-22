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
$smarty->assign("MODULE", 'Settings');
$smarty->assign("IMAGE_PATH", $image_path);

if(isset($_REQUEST['templateid']) && $_REQUEST['templateid']!='')
{
	
	$tempid = $_REQUEST['templateid'];
	$sql = "select * from ld_emailtemplates where templateid=?";
	$result = $adb->pquery($sql, array($tempid));
	$emailtemplateResult = $adb->fetch_array($result);
}
 if(isset($_REQUEST['blockidsetting'])&&$_REQUEST['blockidsetting']!=""){
    $blockidsetting=$_REQUEST['blockidsetting'];
 }
 if(isset($_REQUEST['fieldidsetting'])&&$_REQUEST['fieldidsetting']!=""){
    $fieldidsetting=$_REQUEST['fieldidsetting'];
 }
$smarty->assign("FOLDERNAME", $emailtemplateResult["foldername"]);

$smarty->assign("TEMPLATENAME", $emailtemplateResult["templatename"]);
$smarty->assign("DESCRIPTION", $emailtemplateResult["description"]);
$smarty->assign("TEMPLATEID", $emailtemplateResult["templateid"]);
$smarty->assign('BLOCKIDSETTING',$blockidsetting);
$smarty->assign('FIELDIDSETTING',$fieldidsetting);

$smarty->assign("SUBJECT", $emailtemplateResult["subject"]);
$smarty->assign("BODY", decode_html($emailtemplateResult["body"]));

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('VIEW');	//{'EDITEMAILTEMPLAETES'|@getFixedLabel} &quot;{$TEMPLATENAME}&quot;
$arr['oktext']=getFixedLabel("CONFIRME");
$str=$smarty->fetch("DetailViewEmailTemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

?>




