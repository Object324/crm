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
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once(globalStatic::$root_directory.'include/utils/UserInfoUtil.php');
global $mod_strings;
global $app_strings;
global $app_list_strings;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty; 
$defSharingPermissionData = getDefaultSharingEditAction();
$row=1;
$entries = Array();
foreach($defSharingPermissionData as $tab_id => $def_perr)
{
	$entity_name = getTabname($tab_id);
    $entity_name=getTranstab($entity_name);
//    ls 2021-08-05 0047367: https://81mis.com/kfbcrm [^]，模块共享规则-签到-无规则可修改(无模块共享规则的不显示)
    if(empty($entity_name) || $tab_id == 142)
    {
        continue;
    }
	$defActionArr=getModuleSharingActionArray($tab_id);
        
	$entries[] = $entity_name;
	
	if($tab_id != 6)
	{
		$output = '<select class="detailedViewTextBox" id="'.$tab_id.'_perm_combo" name="'.$tab_id.'_per">';
	}
	else
	{
		$output = '<select class="detailedViewTextBox" id="'.$tab_id.'_perm_combo" name="'.$tab_id.'_per" onchange="OrgSharingDetailView.checkAccessPermission(this.value)">';
	}
	$entries[] = $tab_id;
	
	foreach($defActionArr as $shareActId=>$shareActName)
	{
		$selected='';
		if($shareActId == $def_perr)
		{
			$selected='selected';
		}
		$output .= '<option value="'.$shareActId.'" '.$selected. '>'.getFixedLabel($shareActName).'</option>';
			
	}


	$output .= '</select>';
	$entries[] = $output;
	$row++;
}
//当客户访问权为私有时: 销售机会、客户服务单、报价单、合同订单、销售发票 访问权限必须设为私有
$smodule = array('Potentials','HelpDesk','Quotes','SalesOrder','Invoice');
foreach($smodule as $module){
	if(vtlib_isModuleActive($module)){
		$module_label[] = getTranstab($module);
	}
}
$smarty->assign('ALLMODULELABEL',implode('、',$module_label));
$list_entries=array_chunk($entries,3);
$smarty->assign("ORGINFO",$list_entries);

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('EDIT');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("OrgSharingEditView.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>