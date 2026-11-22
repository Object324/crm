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


global $mod_strings;
global $app_strings;
global $app_list_strings;

$smarty = new lingdangCRM_Smarty;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$sql="select * from ld_organizationdetails";
$result = $adb->pquery($sql, array());
$organization_name = str_replace('"','&quot;',$adb->query_result($result,0,'organizationname'));
$organization_address= $adb->query_result($result,0,'address');
$organization_city = $adb->query_result($result,0,'city');
$organization_state = $adb->query_result($result,0,'state');
$organization_code = $adb->query_result($result,0,'code');
$organization_country = $adb->query_result($result,0,'country');
$organization_phone = $adb->query_result($result,0,'phone');
$organization_fax = $adb->query_result($result,0,'fax');
$organization_website = $adb->query_result($result,0,'website');
$organization_logoname = $adb->query_result($result,0,'logoname');
$organization_small_logoname = $adb->query_result($result,0,'small_logoname');
$organization_crm_address = $adb->query_result($result,0,'crm_address');
//wym 原先存在ld_organizationdetails表中,现在修改成在ld_module_setting_byuser表里,如果新表没数据则取老表的数据
$menustyle = getUsersettingByLabel('notbymodule',$current_user->id,'Menustyle');
if($menustyle){
    if($menustyle=='custom')
        $menufont=getUsersettingByLabel('notbymodule',$current_user->id,'Menufont_color');
}else{
    $menustyle = decode_html($adb->query_result($result,0,'menustyle'));
}
if(empty($organization_small_logoname)){
    //浅色菜单模式
    if($menustyle == 'lightcolour' || $menufont=='black'){
	   $organization_small_logoname = 'logo_mini_light_0721.png';
    }
    else{
        $organization_small_logoname = 'logo_mini_dark_0721.png';
    }
}
if(empty($organization_logoname)){
    //浅色菜单模式
    if($menustyle == 'lightcolour' || $menufont=='black'){
	   $organization_logoname = 'logo_big_light_0721.png';
    }
    else{
       $organization_logoname = 'logo_big_dark_0721.png';
    }
}
if (isset($organization_name))
	$smarty->assign("ORGANIZATIONNAME",$organization_name);
if (isset($organization_address))
	$smarty->assign("ORGANIZATIONADDRESS",$organization_address);
if (isset($organization_city))
	$smarty->assign("ORGANIZATIONCITY",$organization_city);
if (isset($organization_state))
	$smarty->assign("ORGANIZATIONSTATE",$organization_state);
if (isset($organization_code))
	$smarty->assign("ORGANIZATIONCODE",$organization_code);
if (isset($organization_country))
	$smarty->assign("ORGANIZATIONCOUNTRY",$organization_country);
if (isset($organization_phone))
	$smarty->assign("ORGANIZATIONPHONE",$organization_phone);
if (isset($organization_fax))
	$smarty->assign("ORGANIZATIONFAX",$organization_fax);
if (isset($organization_website))
	$smarty->assign("ORGANIZATIONWEBSITE",$organization_website);
if ($organization_logoname == '') 
	$organization_logoname = vtlib_purify($_REQUEST['prev_name']);
if (isset($organization_logoname)) 
	$smarty->assign("ORGANIZATIONLOGONAME",$organization_logoname);
if ($organization_small_logoname == '') 
	$organization_small_logoname = vtlib_purify($_REQUEST['prev_name']);
if (isset($organization_small_logoname)) 
	$smarty->assign("ORGANIZATIONSMAILLLOGONAME",$organization_small_logoname);
if (isset($organization_crm_address))
    $smarty->assign("ORGANIZATIONCRMADDRESS",$organization_crm_address);

//0024242: 控制面板>公司信息：点击【公司信息】报错Fatal error
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign('RANDNUM',strtotime(date("Y-m-d H:i:s")).rand(1000,9999));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
 $_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('EDIT');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/EditCompanyInfo.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>