<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

/**
 * edit:kevin
 * date:2013-06-25
 * reason:短信模板list界面
 */ 
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

require_once('Smarty_setup.php'); 
require_once('include/database/PearDatabase.php');

global $adb;
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;

$sql = "select * from ld_smstemplates where platform =? order by FIELD(deleted, 0, 1),templateid DESC";//启用的先排前面
$result = $adb->pquery($sql, array($platform));
$temprow = $adb->fetch_array($result);
   
$edit="Edit  ";
$del="Del  ";
$bar="  | ";
$cnt=1;

require_once('include/utils/UserInfoUtil.php');
global $app_strings;
global $app_list_strings;
global $mod_strings;
global $theme,$default_charset;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
$smarty->assign("UMOD", $mod_strings);
global $current_language;

$smarty->assign("APP", $app_strings);
//echo $module;
$smarty->assign("MODULE", $module);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PARENTTAB", getParentTab());

$return_data=array();
if ($temprow != null)
{
do
{
	$templatearray=array();
	$templatearray['templatename'] = $temprow["templatename"];
	$templatearray['templateid'] = $temprow["templateid"];
	$templatearray['body'] = $temprow["body"];
	$templatearray['deleted'] = $temprow["deleted"];

    $template_type = $temprow["template_type"];
    if ($platform == 'tencent') {
        if($template_type == 'ordinary'){
            $templatearray['template_type'] = getFixedLabel('plainsms');
        }else{
            $templatearray['template_type'] = getFixedLabel('SMS_Marketing');
        }
    } elseif ($platform == 'aliyun') {
        $templatearray['template_type']  = $cls_Send_MassSms->get_template_type($template_type);
    }

	$templatearray['foldername'] = $temprow["foldername"];
	$return_data[]=$templatearray;
	$cnt++;
}while($temprow = $adb->fetch_array($result));
}

$smarty->assign("TEMPLATES",$return_data);
$smarty->assign("PLATFORM",$platform);

if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'true'){
	$smarty->display("ListSMSTemplatesEntries.tpl");
}else{
	$smarty->display("ListSMSTemplates.tpl");
}


?>