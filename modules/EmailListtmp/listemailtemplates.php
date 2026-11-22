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
require_once('include/database/PearDatabase.php');

global $adb;
global $current_user;

//	0019737: 营销>邮件模板>新增>文件夹选择私有-保存，可是其他用户还是可以编辑和使用
$sql = "select * from ld_emailtemplates";
if($current_user->is_admin == 'off'){
	$sql .=" where foldername = 'Public' or smcreatorid = '".$current_user->id."'";
}
$sql .=" order by templateid DESC";
$result = $adb->pquery($sql, array());
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
  $templatearray['description'] = $temprow["description"];
  $templatearray['foldername'] = $temprow["foldername"];
  $return_data[]=$templatearray;
  $cnt++;
}while($temprow = $adb->fetch_array($result));
}


$smarty->assign("TEMPLATES",$return_data);

require_once("modules/Settings/SetmenuControl.php");
$smarty->display("ListEmailTemplates.tpl");

?>