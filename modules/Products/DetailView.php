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
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule, $current_user, $theme, $singlepane_view;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;

$smarty = new lingdangCRM_Smarty();

$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$tabid = getTabid($currentModule);

if($record != '') {
	//Display the error message
	if($_SESSION['image_type_error'] != '')
	{
	   unset($_SESSION['image_type_error']);
		echo '<font color="red">'.$_SESSION['image_type_error'].'</font>';
		
	}
	$focus->id = $record;
	$focus->retrieve_entity_info($record, $currentModule);
}
if($isduplicate == 'true') $focus->id = '';


require_once(globalStatic::$root_directory.'modules/Calendar/TemplateCalendar/cls_templateCalendar.php');

$template = new TemplateCalendar();
$data = $template->getUrl($_SERVER['HTTP_REFERER']);
$modulelist = $template->getAvailableModule();
if(isset($data['action']) && $data['action']=='EditView'){
    if(array_key_exists(getTabid($currentModule),$modulelist)){
        $smarty->assign('AUTOEXEC','yes');
    }
}



/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();

$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
// Identify this module as custom module.
$smarty->assign('CUSTOM_MODULE', true);


$smarty->assign('MODULE', $currentModule);
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'Product');
$smarty->assign('CATEGORY', $category);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('THEME', $theme);
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('VENDOR_ID',$focus->column_fields['vendor_id']);
$recordName = $focus->column_fields[$focus->list_link_field];
$smarty->assign('NAME', $recordName);
//$smarty->assign('UPDATEINFO',updateInfo($focus->id));

$smarty->assign("CUSTOMFIELD", $cust_fld);

$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
crm_load_function_file('getTaxDetailsForProduct','include/utils','InventoryUtils');
$tax_details = (array)getTaxDetailsForProduct($focus->id);

for($i=0;$i<count($tax_details);$i++)
{
	$tax_details[$i]['percentage'] = getProductTaxPercentage($tax_details[$i]['taxname'],$focus->id);
}
$smarty->assign("TAX_DETAILS", $tax_details);

$price_details = getPriceDetailsForProduct($focus->id, $focus->unit_price, 'available_associated',$currentModule);
$smarty->assign("PRICE_DETAILS", $price_details);

$validationArray =$fieldobj->split_validationdataArray();
$smarty->assign('VALIDATION_DATA_FIELDNAME',$validationArray['fieldname']);
$smarty->assign('VALIDATION_DATA_FIELDDATATYPE',$validationArray['datatype']);
$smarty->assign('VALIDATION_DATA_FIELDLABEL',$validationArray['fieldlabel']);

$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign('IS_REL_LIST', $is_rel_list);
$smarty->assign('SinglePane_View', $singlepane_view);

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));

//金蝶云星空库存
$stock_view = getErpStockView();
//wyt 221124 BUG0058960 产品明细界面，总库存数量，看ERP库存时，如果没有配置，点击页面不加载内容，必须刷新，建议给出提示
if(file_exists(globalStatic::$root_directory."user_privileges/Config_ERP_Api.php")){
    crm_load_class_file('Config_ERP_Api','user_privileges');
    $is_url_exsit=Config_ERP_Api::$product_type;
    if(empty($is_url_exsit)){
        $ERPVIEW='no';
    }else{
        $ERPVIEW='yes';
        $smarty->assign("ERPPRODUCTTYPE",$is_url_exsit);
    }
}else if(!file_exists(globalStatic::$root_directory."user_privileges/Config_ERP_Api.php")){
    $ERPVIEW='no';
}
$smarty->assign("ERPVIEW",$ERPVIEW);
$smarty->assign("STOCKVIEW",$stock_view);
$smarty->assign('KISERROR',$_SESSION['kiserror']);
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$arr = [];
$ContainShopDetail = isset($_REQUEST['ContainShopDetail'])?$_REQUEST['ContainShopDetail']:'no';
if(vtlib_isModuleActive('ShoppingMall') && $ContainShopDetail=='yes'){
    //这个判断是判断产品详情上方的那个图片轮播区域是否显示--订货商城开启 且 是从订货商城或者购物车打开才需要显示这块区域
    $ContainShopDetail = 'yes';
}else{
    $ContainShopDetail = 'no';
}
//$sys_485 = getSys_deploy(485);
//改成判断订货商城模块是否激活
//if($sys_485['deploy_value'] == 'yes') {
//if(vtlib_isModuleActive('ShoppingMall') && $ContainShopDetail=='yes') {
//属性状态开启 且产品属性字段有值
    if (isset($focus->column_fields['property_status'])
        && $focus->column_fields['property_status'] == 1
        && isset($focus->column_fields['propertyids'])
        && !empty($focus->column_fields['propertyids'])) {
        $params_arr = $_REQUEST;
        $params_arr['focus'] = $focus;
        $params_arr['productid'] = $focus->id;
        $params_arr['productpropertyid'] = '';

        //关联选择单据 选产品属性的值
        $params_arr['productpropertyid'] = $focus->column_fields['propertyids'];


        crm_load_class_file('ProductPropertyUtils', 'modules/Products');
        $ProductPropertyUtilsObj = new ProductPropertyUtils($params_arr);
        $arr['restBlocks'] = $ProductPropertyUtilsObj->getProductPropertyBlock();
        //分录附件信息
        $detailfilejsondata = array();
        if ($focus->id > 0) {
            $detailfilejsondata = getAllDetailFile_imageInfo($focus->id, 'Products');
        }
        $arr['detailfilejsondata'] = $detailfilejsondata;
    } else {
        $arr['restBlocks'] = array();
    }
    //服务合同 合同订单是否授权
    $modulename_arr = array(
        array('module' => 'SalesOrder', 'label' => getTranstab('SalesOrder'), 'tabid' => getTabid('SalesOrder')),
        array('module' => 'ServiceContracts', 'label' => getTranstab('ServiceContracts'), 'tabid' => getTabid('ServiceContracts')),
    );
    foreach ($modulename_arr as $key => $tmpmoduleinfo) {
        if (!vtlib_isModuleActive($tmpmoduleinfo['module']) || isPermitted($tmpmoduleinfo['module'], 'Create') != 'yes') {
            unset($modulename_arr[$key]);
        }
    }
    $arr['restBlocks']['createModuleArr'] = $modulename_arr;//可以下单的 模块
    $system_deploy_49 = getSys_deploy(49);
    $QuantityDecimal = $system_deploy_49['deploy_value'];//数量小数位
    $system_deploy_93 = getSys_deploy(93);
    $PriceDecimal = $system_deploy_93['deploy_value'];//单价小数位
    $arr['restBlocks']['QuantityDecimal'] = $QuantityDecimal;
    $arr['restBlocks']['PriceDecimal'] = $PriceDecimal;
    $arr['restBlocks']['ContainShopDetail'] = $ContainShopDetail;
//}
DetailViewReturn($currentModule,$focus,$smarty,$arr);
?>