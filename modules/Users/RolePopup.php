<?php 
/*+******************************************************************************* 
*{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0 
* ("License"); You may not use this file except in compliance with the License 
* The Original Code is: lingdang CRM Open Source 
* The Initial Developer of the Original Code is lingdang. 
* Portions created by lingdang are Copyright (C) lingdang. 
* All Rights Reserved. 
********************************************************************************/ 

require_once('include/utils/UserInfoUtil.php'); 
require_once('Smarty_setup.php'); 
$smarty = new lingdangCRM_Smarty; 

global $mod_strings; 
global $app_strings; 
global $app_list_strings; 
global $adb; 
global $theme; 
$theme_path="themes/".$theme."/"; 
$image_path=$theme_path."images/"; 
$del_profileid = $_REQUEST['maskid']; 
$query = 'select profilename,profileid from ld_profile order by profileid asc'; 
$result = $adb->pquery($query); 
$num_rows = $adb->num_rows($result); 
$roleout = '<ul class="uil" id="profiletree" style="display:block;list-style-type:none;">'; 
$roleout .= '<li><img src="' . lingdang_imageurl('menu_root.gif', $theme) .'" id="img_'.$roleid.'" border="0" alt="'.$app_strings['LBL_ROOT'].'" title="'.$app_strings['LBL_ROOT'].'" align="absmiddle">&nbsp;<b class="font14 lineheight16 greyFont8 fontbold">'.getFixedLabel('Organizational_Structure').'</b></li>'; 
for($i = 0; $i<$num_rows; $i++){ 
	$profileid = $adb->query_result($result,$i,'profileid'); 
	$profilename = $adb->query_result($result,$i,'profilename'); 

	$roleout .= '<li >'; 
	if($del_profileid != $profileid){ 
		$roleout .='&nbsp;<a href="javascript:loadValue(\'user_'.$profileid.'\',\''.$profileid.'\');" class="x" id="user_'.$profileid.'">'.$profilename.'</a>'; 
	} 
	else{ 
		$roleout .= '&nbsp;<b class="font14 lineheight16 greyFont8 fontbold">'.$profilename.'</b>'; 
	} 
	$roleout .= '</li>'; 
} 
$roleout .='</ul>'; 

$smarty->assign("THEME",$theme_path); 
$smarty->assign("THEME", $theme); 
$smarty->assign("IMAGE_PATH",$image_path); 
$smarty->assign("APP", $app_strings); 
$smarty->assign("CMOD", $mod_strings); 
$smarty->assign("ROLETREE", $roleout); 
$smarty->display("RolePopup.tpl"); 
?>