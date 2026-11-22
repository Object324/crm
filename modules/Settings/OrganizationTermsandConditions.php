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

require_once('include/database/PearDatabase.php');
require_once('Smarty_setup.php');

global $mod_strings;
global $app_strings;
global $app_list_strings;

global $adb;
global $theme;

/*$sqlgetproname="select ld_tab.tabid,ld_tab.tablabel,ld_languagepackage.chinesename as tabname,
ld_languagepackage.newchinesename as newtabname from ld_tab left join ld_languagepackage on 
ld_tab.tablabel=ld_languagepackage.tablabel
 where ld_tab.presence=0 and ld_tab.tabid not in(1,7,27,28,29,30,33,35,44,51,52,61)
 and ld_tab.tablabel='Quotes' or ld_tab.tablabel='Invoice' or ld_tab.tablabel='SalesOrder' or ld_tab.tablabel='PurchaseOrder';";
$pronameresult=$adb->pquery($sqlgetproname,array());
$proname1 = $adb->query_result($pronameresult,0,"newtabname");
$proname2 = $adb->query_result($pronameresult,1,"newtabname");
$proname3 = $adb->query_result($pronameresult,2,"newtabname");
$proname4 = $adb->query_result($pronameresult,3,"newtabname");*/
//$MODFE = return_module_language($current_language,'Settings');
//$MODFE['LBL_INVEN_TANDC_DESC']='指定模块（'.$proname1.'、'.$proname2.'、'.$proname3.'和'.$proname4.'）的条款和条件';

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
$sql="select * from ld_inventory_tandc";
$result = $adb->pquery($sql, array());
$inventory_id = $adb->query_result($result,0,'id');
$inventory_type = $adb->query_result($result,0,'type');
$inventory_tandc = $adb->query_result($result,0,'tandc');

if(!isset($_REQUEST['inv_terms_mode']))
	$inventory_tandc = nl2br($inventory_tandc);
	
if (isset($inventory_tandc))
        $smarty->assign("INV_TERMSANDCONDITIONS",$inventory_tandc);
if(isset($_REQUEST['inv_terms_mode']) && $_REQUEST['inv_terms_mode'] != '')
	$smarty->assign("INV_TERMS_MODE",vtlib_purify($_REQUEST['inv_terms_mode']));
else
	$smarty->assign("INV_TERMS_MODE",'view');
	
$smarty->assign("MOD", $MODFE);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
require_once('SetmenuControl.php');
$smarty->display("Settings/InventoryTerms.tpl");
?>