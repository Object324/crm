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

require_once('Smarty_setup.php');
require_once('include/database/PearDatabase.php');

   global $adb;
   $sql = "select templateid, module, description, filename, filesize, filetype from ld_wordtemplates order by filename ASC";
   $result = $adb->pquery($sql, array());

$edit="Edit  ";
$del="Del  ";
$bar="  | ";
$cnt=1;

$return_data = Array();
$num_rows = $adb->num_rows($result);


for($i=0;$i < $num_rows; $i++)
{	
	$wordtemplatearray=array();
	$wordtemplatearray['templateid'] = $adb->query_result($result,$i,'templateid');
	$wordtemplatearray['description'] = $adb->query_result($result,$i,'description');
	$module = $adb->query_result($result,$i,'module');
	$wordtemplatearray['module'] = getTranslatedString($module, $module);
	$wordtemplatearray['filename'] = $adb->query_result($result,$i,'filename');
	$wordtemplatearray['filetype'] = $adb->query_result($result,$i,'filetype');
	$wordtemplatearray['filesize'] = $adb->query_result($result,$i,'filesize');	 
	$return_data []= $wordtemplatearray;	
}
require_once('include/utils/UserInfoUtil.php');
global $app_strings;
global $mod_strings;
global $theme,$default_charset;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
global $current_language;
//$smod_strings = return_module_language($current_language,'Settings');
$smarty->assign("MOD", $smod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("UMOD", $mod_strings);
$smarty->assign("PARENTTAB", getParentTab());
$smarty->assign("IMAGE_PATH",$image_path);

$smarty->assign("WORDTEMPLATES",$return_data);
$smarty->display("ListWordTemplates.tpl");

?>