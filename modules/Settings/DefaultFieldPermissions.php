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

//require_once('include/utils/UserInfoUtil.php');
//require_once('include/utils/utils.php');

global $mod_strings;
global $app_strings;
global $app_list_strings;

$smarty = new lingdangCRM_Smarty;


global $adb;
global $theme;
global $theme_path;
global $image_path;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

//$field_module = Array('Leads','Accounts','Contacts','Potentials','HelpDesk','Products','Notes','Calendar','Events','Vendors','PriceBooks','Quotes','PurchaseOrder','SalesOrder','Invoice','Campaigns','Faq');

$field_module=getFieldModuleAccessArray();
$allfields=Array();
unset($field_module['SMSNotifier']);
unset($field_module['PBXManager']);
unset($field_module['BankAccountSet']);
unset($field_module['PublicAnnouncement']);
/**
 * edit:chj
 * date:2014-9-9
 * reason:控制面板 字段权限不显示服务收费字段
 * description:0011155: 服务收费需求中说明字段权限中不应该有"服务收费"模块
 * */
unset($field_module['ServiceCharge']);
foreach($field_module as $fld_module=>$mod_name)
{
	$fieldListResult = getDefOrgFieldList($fld_module);
	$noofrows = $adb->num_rows($fieldListResult);
	//$language_strings = return_module_language($current_language,$fld_module);
    //print_r($noofrows);
	$allfields[$fld_module] = getStdOutput($fieldListResult, $noofrows, '',$profileid);
    
}

if($_REQUEST['fld_module'] != '')
	$smarty->assign("DEF_MODULE",vtlib_purify($_REQUEST['fld_module']));
else
	$smarty->assign("DEF_MODULE",'Accounts');

/** Function to get the field label/permission array to construct the default orgnization field UI for the specified profile 
  * @param $fieldListResult -- mysql query result that contains the field label and uitype:: Type array
  * @param $lang_strings -- i18n language mod strings array:: Type array
  * @param $profileid -- profile id:: Type integer
  * @returns $standCustFld -- field label/permission array :: Type varchar
  *
 */	
function getStdOutput($fieldListResult, $noofrows, $lang_strings,$profileid)
{
	global $adb;
	global $image_path,$theme;
	$standCustFld = Array();
    for($i=0; $i<$noofrows; $i++)
	{
		$uitype = $adb->query_result($fieldListResult,$i,"uitype");
		$fieldlabel = $adb->query_result($fieldListResult,$i,"fieldlabel");
		$typeofdata = $adb->query_result($fieldListResult,$i,"typeofdata");
		$fieldtype = explode("~",$typeofdata);
        		
	
	   $standCustFld []= $fieldlabel;
			
		
		if($adb->query_result($fieldListResult,$i,"visible") == 0 || ($uitype == 117 && $fieldtype[1] == "M"))
		{
			$visible ="<img src='" . lingdang_imageurl('prvPrfSelectedTick.gif', $theme) . "'>";
		}
		else
		{
			$visible = "<img src='" . lingdang_imageurl('no.gif', $theme) . "'>";
		}	
		$standCustFld []= $visible;
	}
	$standCustFld=array_chunk($standCustFld,2);	
	$standCustFld=array_chunk($standCustFld,4);	
	return $standCustFld;
}
$smarty->assign("FIELD_INFO",$field_module);
$smarty->assign("FIELD_LISTS",$allfields);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("MODE",'view');                    

require_once('SetmenuControl.php');                    
$smarty->display("FieldAccess.tpl");
?>