<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

require_once('database/DatabaseConnection.php');


global $app_strings, $app_list_strings, $current_language, $currentModule, $theme, $current_user;

if($current_user->getHaveSetProfile("Settings")!="yes"){
	echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
				<tr>
					<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) . "' ></td>
					<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>".getFixedLabel('NOPERMITTEDEXECUTE')."</span></td>
				</tr>
				<tr>
					<td class='small' align='right' nowrap='nowrap'>
						<a href='javascript:window.history.back();'>".getFixedLabel('RETURN')."</a><br>
					</td>
				</tr>
			</table>
		</div>";
	echo "</td></tr></table>";
	die;
}
crm_load_function_file('getPickListModules','modules/PickList','PickListUtils');
$modules = getPickListModules();

global $picklistmodule;
if(!empty($_REQUEST['moduleName'])) {
	$picklistmodule = $fld_module = vtlib_purify($_REQUEST['moduleName']);
}else {
	$module = array_keys($modules);
	$picklistmodule = $fld_module = $module[0];
}

if(!empty($_REQUEST['roleid'])) {
	$roleid = vtlib_purify($_REQUEST['roleid']);
}else {
    /*
    andrew
    20140225
    H2可以删除，所以改成直接搜索数据库获取roleid
    */
    	global $adb;    
    $sql= "select  roleid from ld_role where depth=1 limit 0,1";
    $result = $adb->pquery($sql, array());
    $roleid = $adb->query_result($result,0,"roleid");	        
    
//	$roleid = 'H2';		//set default to CEO
}

if(!empty($_REQUEST['uitype'])) {
	$uitype = vtlib_purify($_REQUEST['uitype']);
}

$smarty = new lingdangCRM_Smarty;

if((sizeof($picklists_entries) %3) != 0) {
	$value = (sizeof($picklists_entries) + 3 - (sizeof($picklists_entries))%3);
}else {
	$value = sizeof($picklists_entries);
}


$picklists_entries = getUserFldArray($fld_module,$roleid);

$available_module_picklist = array();
$picklist_fields = array();

if(!empty($picklists_entries)) {
	$available_module_picklist = get_available_module_picklist($picklists_entries);
  
	$picklist_fields = array_chunk(array_pad($picklists_entries,$value,''),3);
    
}
/**
 *by andy
 *reason 0009257: 控制面板 > 下拉框编辑界面：选择模块选择附件管理，点击添加项目、删除项目、重命名项目按钮没有反应 v5.3
 *预期结果：附件管理没有下拉框可编辑，建议选择模块下拉框中去掉附件管理
 *date 20140604
 */  
unset($modules[array_search("Attachment",$modules)]);

$smarty->assign("MODULE_LISTS",$modules);
//$smarty->assign("ROLE_LISTS",getrole2picklist());
$smarty->assign("ALL_LISTS",$available_module_picklist);

$smarty->assign("APP", $app_strings);		//the include language files
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));	//the settings module language file
//$smarty->assign("MOD_PICKLIST", return_module_language($current_language,'PickList'));	//the picklist module language files
$smarty->assign("TEMP_MOD", $temp_module_strings);	//the selected modules' language file

$smarty->assign("MODULE",$fld_module);

$smarty->assign("PICKLIST_VALUES",$picklist_fields);


$smarty->assign("THEME",$theme);
$smarty->assign("UITYPE", $uitype);
$smarty->assign("SEL_ROLEID",$roleid);
require_once('modules/Settings/SetmenuControl.php');

if($_REQUEST['directmode'] != 'ajax') {
	$smarty->display("modules/PickList/PickList.tpl");
}else {
	$smarty->display("modules/PickList/PickListContents.tpl");
}

?>