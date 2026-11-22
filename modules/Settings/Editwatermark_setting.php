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
/*
edit:yby
2022.12.10
*/
global $app_list_strings;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_user;

$smarty = new lingdangCRM_Smarty;


$sql="select * from ld_watermark_setting where id=1";
$result = $adb->pquery($sql, array());
$ld_watermark_display = $adb->query_result($result,0,'watermark_display');
$ld_presence = $adb->query_result($result,0,'presence');
$ld_custom_content = $adb->query_result($result,0,'custom_content');
$smarty->assign("presence",$ld_presence );//$smarty->assign（"presence",$ld_presence）冒号里的传到tpl作为变量
$smarty->assign("watermark_display",$ld_watermark_display);
$smarty->assign("custom_content",$ld_custom_content);

if ($ld_watermark_display =='username') {
    $watermark_hint= getFixedLabel('loginusername_hint');
}
else if($ld_watermark_display =='username_date'){
    $watermark_hint = getFixedLabel('username_date_hint'); 
}
else if($ld_watermark_display =='username_phone'){
  $watermark_hint = getFixedLabel('username_phone_hint'); 
}
else if($ld_watermark_display =='Companyname_username'){
  $watermark_hint = getFixedLabel('Companyname_username_hint'); 
}
else if($ld_watermark_display =='Companyname_username_phone'){
  $watermark_hint = getFixedLabel('Companyname_username_phone_hint'); 
}
else if($ld_watermark_display =='companyname_username_date'){
  $watermark_hint = getFixedLabel('companyname_username_date_hint'); 
}
else{
  $watermark_hint = getFixedLabel('Custom_content_hint'); 
}


$smarty->assign("watermark_hint",$watermark_hint);


$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/Editwatermark_setting.tpl');
$arr['title']=getFixedLabel("EDIT");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
?>