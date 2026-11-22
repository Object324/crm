<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global  $current_language, $currentModule, $theme,$current_user;
global $adb;
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);
if($currentModule=='Accounts')
{
    include(globalStatic::$root_directory.'modules/Accounts/getExportAccountCount.php');
	crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
	$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
}
elseif($currentModule=='Vendors')
{
	include(globalStatic::$root_directory."modules/lingdang/getInventoryExportsCount.php");
	crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
	$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
}
elseif(get_file_address($currentModule,'ProductDetails'))
{
   
    include(globalStatic::$root_directory."modules/lingdang/getInventoryExportsCount.php");
	crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
	$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
    $controller->module=$currentModule;
}
elseif(get_file_address($currentModule,$currentModule.'DetailFieldsHtml'))
{
	include(globalStatic::$root_directory."modules/lingdang/getExporttabDetailsCount.php");
	crm_load_class_file('TabDetailListViewController','include/ListView','TabDetailListViewController'); 
	$controller = new TabDetailListViewController($adb, $current_user, $queryGenerator,$currentModule);
	$controller->getModuleFields();
}
else
{
    include(globalStatic::$root_directory."modules/lingdang/getExportSingleCount.php");
	$controller = new ListViewController($adb, $current_user, $queryGenerator);
	$controller->getModuleFields();
    
}
//引用小计、合计类
crm_load_class_file('clsTotal_List','include/ListView');
//实例化类
if($currentModule=='ServiceCharge')
{
    crm_load_class_file('cls_servicecharge_totalList','modules/ServiceCharge');
     $clstotalobj=new cls_servicecharge_totalList($controller);
}
else
    $clstotalobj=new clsTotal_List($controller);
//获取合计的数据
$thistotal=$clstotalobj->getAllTotalColumnData();

//调用生成合计html格式

$totalhtml=$clstotalobj->getAllTotalRow_html($thistotal,'list');
$_REQUEST['diony']='yes';
$arr['content']=$totalhtml;
ConvertTojsonString(1,$arr,'success');
?>