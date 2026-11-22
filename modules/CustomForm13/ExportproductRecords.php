<?php
/*********************************************************************************

 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

global  $list_max_entries_per_page_new, $currentModule, $theme, $current_language, $current_user;

$type = 0;
$focus=CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$category = getParentTab();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
require_once('modules/lingdang/layout_utils.php');
unset($_SESSION[$currentModule][$current_user->id]['export']);
$idstring = getSelectedRecords($_REQUEST,$currentModule,$_REQUEST['idstring'],$_REQUEST['excludedRecords']);
$idstring = trim(join(',',$idstring),',');
include(globalStatic::$root_directory."modules/lingdang/getInventoryExportsCount.php");
global $adb;
//$list_query:在文件：getInventoryExportsCount赋值
$result=$adb->pquery($list_query,array());
$allrows=$adb->num_rows($result);
$smarty->assign('ALLROWS',$allrows);
$smarty->assign("SELECTEDROWS",0);
if(!empty($idstring))
{
    $list_query.=' and '.$focus->table_name.'.'.$focus->table_index.' in('.$idstring. ')';
 
    $result=$adb->pquery($list_query,array());
    $selectedrows=$adb->num_rows($result);
    $smarty->assign("SELECTEDROWS",$selectedrows);
    
}
if($_REQUEST['type'] == 'Con Accounts')
{
    $type = 1;
}
$smarty->assign('AccountType',$type);
$smarty->assign("SESSION_WHERE",$_SESSION['export_where']);
$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign("THEME", $theme_path);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("CATEGORY",$category);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("MODULELABEL",getTranstab($currentModule));
$smarty->assign("IDSTRING",$idstring);
$smarty->assign("PERPAGE",$list_max_entries_per_page_new);

if(!is_admin($current_user) && (isPermitted($currentModule, 'Export') != 'yes')) {	
	$smarty->display(vtlib_getModuleTemplate('lingdang','OperationNotPermitted.tpl'));	
} else {
	$smarty->display('ExportRecords.tpl');
}


?>