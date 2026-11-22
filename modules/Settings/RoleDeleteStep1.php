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

require_once('modules/Users/Profile.class.php');

$delete_profileid_id = vtlib_purify($_REQUEST['profileid']);
global $app_strings;
global $app_list_strings;
global $mod_strings;
global $adb;

$smarty=new lingdangCRM_Smarty;
$smarty->assign("APP", $app_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("CMOD", $mod_strings);
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("IMAGE_PATH",$image_path);

//获取权限信息
$profile = new Profile();
$profileinfo = $profile->getProfileinfo($delete_profileid_id);
$smarty->assign("PROFILEID", $delete_profileid_id);
$smarty->assign("PROFILE_NAME", $profileinfo['profilename']);

$query = 'select profilename,profileid from ld_profile where profileid != ? order by profileid asc';
$result = $adb->pquery($query,array($delete_profileid_id));
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
	$proinfo[$i]['profileid'] = $adb->query_result($result,$i,'profileid');
	$proinfo[$i]['profilename'] = $adb->query_result($result,$i,'profilename');
}
$smarty->assign('PROINFO',$proinfo);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('DELETEPROFILE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("DeleteRole.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>