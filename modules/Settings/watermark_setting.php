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
/*
edit:杨彬阳
2022.12.10
*/
$smarty = new lingdangCRM_Smarty;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


$sql="select * from ld_watermark_setting where id=1";
$result = $adb->pquery($sql, array());
$presence = $adb->query_result($result,0,'presence');
$watermark_display = $adb->query_result($result,0,'watermark_display');
$custom_content = $adb->query_result($result,0,'custom_content');


if ($watermark_display =='username') {
	$watermark_display_comments = getFixedLabel('loginusername');
}
else if($watermark_display =='username_date'){
	$watermark_display_comments = getFixedLabel('username_date'); 
}
else if($watermark_display =='username_phone'){
	$watermark_display_comments = getFixedLabel('username_phone'); 
}
else if($watermark_display =='Companyname_username'){
	$watermark_display_comments = getFixedLabel('Companyname_username'); 
}
else if($watermark_display =='Companyname_username_phone'){
	$watermark_display_comments = getFixedLabel('Companyname_username_phone'); 
}
else if($watermark_display =='companyname_username_date'){
	$watermark_display_comments = getFixedLabel('companyname_username_date'); 
}
else{
    //edit: xll BUG0061395 水印设置显示特殊字符错误
	$watermark_display_comments = html_entity_decode($custom_content); 
}
$smarty->assign("presence",$presence);
$smarty->assign("watermark_display_comments",$watermark_display_comments);


$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('EDIT');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/watermark_setting.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success"); // * reason:把数组转换成json字符串* $str 可以传递数组和字符串

?>