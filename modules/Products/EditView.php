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
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $current_language, $currentModule, $theme;


$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$encode_val=vtlib_purify($_REQUEST['encode_val']);
$decode_val=base64_decode((string)$encode_val);

$saveimage=isset($_REQUEST['saveimage'])?vtlib_purify($_REQUEST['saveimage']):"false";
$errormessage=isset($_REQUEST['error_msg'])?vtlib_purify($_REQUEST['error_msg']):"false";
$image_error=isset($_REQUEST['image_error'])?vtlib_purify($_REQUEST['image_error']):"false";

$smarty = new lingdangCRM_Smarty();

// @edit:ls @date:2020-7-8 @reason: 义文机电一键检测需求
$VersionInfo = getVersionInfo();
$smarty->assign("account", $VersionInfo['account']);

$category = getParentTab($currentModule);
$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);

//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends

if($record) {
    $focus->id = $record;
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($record, $currentModule);
    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
	$currencyInfo = getInventoryCurrencyInfo($currentModule,$focus->id);
	$product_base_currency = $currencyInfo['currency_id'];
	/**
	 * @project PROT75 数量小数位数
	 * @author Tujt 2014-08-27
	 
	$sysdeploy = getSys_deploy(49);
	if(isset($sysdeploy['deploy_value']))
		$lengthdecimaldigits = $sysdeploy['deploy_value'];
	else
		$lengthdecimaldigits  = 2;
	$focus->column_fields['qtyearly'] = setNumberFormat($focus->column_fields['qtyearly'],$lengthdecimaldigits);*/
} else {
	$currencyobj=Currency::getInstance($adb);
	$product_base_currency=$currencyobj->getCurrencyId();
}

if($image_error=="true")
{
	$explode_decode_val=explode("&",$decode_val);
	for($i=1;$i<count($explode_decode_val);$i++)
	{
		$test=$explode_decode_val[$i];
		$values=explode("=",$test);
		$field_name_val=$values[0];
		$field_value=$values[1];
		$focus->column_fields[$field_name_val]=$field_value;
	}
}

if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	$focus->column_fields['prosmownerid'] = $current_user->id;
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

//needed when creating a new product with a default lingdang_vendor name to passed
if (isset($_REQUEST['name']) && is_null($focus->name)) {
	$focus->name = $_REQUEST['name'];

}
if (isset($_REQUEST['vendorid']) && is_null($focus->vendorid)) {
	$focus->vendorid = $_REQUEST['vendorid'];
}

$disp_view = getView($focus->mode);

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['product_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);

 /**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:添加富文本框
 * */
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','0');
}
//$richText=$act_data['RichText'];
//unset($act_data['RichText']);
$smarty->assign("BLOCKS",$act_data);
//$smarty->assign('RICHTEXTBOX',implode(',',$richText));
//$smarty->assign('RICHTEXTCOUNT',sizeof($richText));

$smarty->assign('OP_MODE',$disp_view);

$smarty->assign('MODULE', $currentModule);
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'Product');
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
//	$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['return_module']))    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));

// Field Validation Information
$tabid = getTabid($currentModule);

$validationArray =$fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

// In case you have a date field
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);

global $adb;


if($focus->id != '')
	$smarty->assign("ROWCOUNT", products::getImageCount($focus->id));

if(isset($cust_fld))
{
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));
crm_load_function_file('getAllTaxes','include/utils','InventoryUtils');
//Tax handling (get the available taxes only) - starts
if($focus->mode == 'edit')
{
	$retrieve_taxes = true;
	$productid = $focus->id;
	$tax_details = getAllTaxes('available');
   
	//$tax_details = getTaxDetailsForProduct($productid,'available_associated');
}
elseif($_REQUEST['isDuplicate'] == 'true')
{
	$retrieve_taxes = true;
	$productid = $_REQUEST['record'];
	$tax_details = getTaxDetailsForProduct($productid,'available_associated');
}
else
	$tax_details = getAllTaxes('available');

for($i=0;$i<count($tax_details);$i++)
{
	$tax_details[$i]['check_name'] = $tax_details[$i]['taxname'].'_check';
	$tax_details[$i]['check_value'] = 0;
}

//For Edit and Duplicate we have to retrieve the product associated taxes and show them
if($retrieve_taxes)
{
	for($i=0;$i<count($tax_details);$i++)
	{
		$tax_value = getProductTaxPercentage($tax_details[$i]['taxname'],$productid);
		$tax_details[$i]['percentage'] = $tax_value;
		$tax_details[$i]['check_value'] = 1;
		//if the tax is not associated with the product then we should get the default value and unchecked
		if($tax_value == '')
		{
			$tax_details[$i]['check_value'] = 0;
			$tax_details[$i]['percentage'] = getTaxPercentage($tax_details[$i]['taxname']);
		}
	}
}
//print_r($tax_details);
$smarty->assign("TAX_DETAILS", $tax_details);
//Tax handling - ends

//参考价 - 价格设定
$unit_price = $focus->column_fields['unit_price'];
$price_details = getPriceDetailsForProduct($productid, $unit_price, 'available',$currentModule,'unit_price');
$smarty->assign("PRICE_DETAILS", $price_details);
$smarty->assign("PRICE_DETAILS_NUM", sizeOf($price_details));

$base_currency = 'unit_price_curname' . $product_base_currency;
$smarty->assign("BASE_CURRENCY", $base_currency);

//参考成本价 - 价格设定
$procostprice = $focus->column_fields['procostprice'];
$price_details = getPriceDetailsForProduct($productid, $procostprice, 'available',$currentModule,'procostprice');
$smarty->assign("PROCOSTPRICE_DETAILS", $price_details);
$smarty->assign("PROCOSTPRICE_DETAILS_NUM", sizeOf($price_details));

$base_currency = 'procostprice_curname' . $product_base_currency;
$smarty->assign("PROCOSTBASE_CURRENCY", $base_currency);


if($_REQUEST['return_module']=='Products' && isset($_REQUEST['return_action'])){
	$return_name = getModuleHref('Products',$_REQUEST['return_id']);
	$smarty->assign("RETURN_NAME", $return_name);
}

if($errormessage==2)
{
	$msg =$mod_strings['LBL_MAXIMUM_LIMIT_ERROR'];
        $errormessage ="<B><font color='red'>".$msg."</font></B> <br><br>";
}
else if($errormessage==3)
{
        $msg = $mod_strings['LBL_UPLOAD_ERROR'];
        $errormessage ="<B><font color='red'>".$msg."</font></B> <br><br>";

}
else if($errormessage=="image")
{
        $msg = $mod_strings['LBL_IMAGE_ERROR'];
        $errormessage ="<B><font color='red'>".$msg."</font></B> <br><br>";
}
else if($errormessage =="invalid")
{
        $msg = $mod_strings['LBL_INVALID_IMAGE'];
        $errormessage ="<B><font color='red'>".$msg."</font></B> <br><br>";
}
else
{
	$errormessage="";
}
if($errormessage!="")
{
	$smarty->assign("ERROR_MESSAGE",$errormessage);
}

// Added to set product active when creating a new product
$mode=$focus->mode;
if($mode != "edit" && $_REQUEST['isDuplicate'] != "true")
	$smarty->assign("PROD_MODE", "create");
 global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", Zend_Json::encode($picklistDependencyDatasource));

$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields));
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
$sysdeploy_93 = getSys_deploy(93);	// 系统参数控制单价小数位
$smarty->assign('price_decimal',$sysdeploy_93['deploy_value']);
//if($focus->mode == 'edit') {
//	$smarty->display('Inventory/InventoryEditView.tpl');
//} else {
//	$smarty->display('Inventory/InventoryCreateView.tpl');
//}
/**
 * product_id，产品更多信息新增产品时传递过来的值
 * @reason 0008464 产品更多信息新增产品未关联
 * @author Tujt 2014-05-04
 */
$product_id = ($_REQUEST['product_id'] > 0)?$_REQUEST['product_id']:0;
$smarty->assign('PRODUCT_ID',$product_id);
$qcreate_array=$focus->fieldobj->QuickCreate();
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//新增、编辑单据可直接保存并提交审批
$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

$smarty->assign("QUICKCREATE", $qcreate_array['form']);
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
$quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;

if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
$tax_details = getAllTaxes();
//35084: （1.6登录）产品管理查看明细界面：价格信息区块没有显示关于税的所有字段
foreach($tax_details as $taxnameinfo)
{
    $fields['fields'][]=array('fieldname'=>$taxnameinfo['taxname']."_check","uitype"=>56,
        'fieldlabel'=>$taxnameinfo['taxlabel'],'typeofdata'=>"C~O");
    $fields['fields'][]=array('fieldname'=>$taxnameinfo['taxname'],"uitype"=>1,
        'fieldlabel'=>$taxnameinfo['taxlabel'],'typeofdata'=>"V~O");
}

$_REQUEST['diony']='diony';
//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);


$arr['picklistcontent']=$global_pick_list_values;

$arr['approve_arr']=$approve_arr;
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
//$arr['columnfields_value']=$focus->column_fields;
//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

//$sys_485 = getSys_deploy(485);
//改成判断订货商城模块是否激活
//if($sys_485['deploy_value'] == 'yes') {
//if(vtlib_isModuleActive('ShoppingMall')) {
//属性状态开启 且产品属性字段有值
    $restBlocks = [];
//if(isset($focus->column_fields['property_status'])
//    &&$focus->column_fields['property_status']==1
//    &&isset($focus->column_fields['propertyids'])
//    &&!empty($focus->column_fields['propertyids'])) {
    //zxm 20241011 产品增加产品属性功能
    $params_arr = $_REQUEST;
    $params_arr['productid'] = $params_arr['record'];
    $params_arr['productpropertyid'] = '';

    //复制单据的时候不能用$focus  另外建个对象
    $tmpfocus = CRMEntity::getInstance('Products');
    $tmpfocus->id = $params_arr['productid'];
    if ($tmpfocus->id > 0) {
        //关联选择单据 选产品属性的值
        $params_arr['productpropertyid'] = $tmpfocus->column_fields['propertyids'];
    }


    crm_load_class_file('ProductPropertyUtils', 'modules/Products');
    $ProductPropertyUtilsObj = new ProductPropertyUtils($params_arr);
    $restBlocks = $ProductPropertyUtilsObj->getProductPropertyBlock();
    $restBlocks['product_base_currency'] = $product_base_currency;
    //分录附件信息
    $detailfilejsondata = array();
    if ($tmpfocus->id > 0) {
        $detailfilejsondata = getAllDetailFile_imageInfo($tmpfocus->id, 'Products');
    }
    $arr['detailfilejsondata'] = $detailfilejsondata;
    $arr['detailfields'] = $restBlocks['detailfields'];
    unset($restBlocks['detailfields']);
//}


    $system_deploy_49 = getSys_deploy(49);
    $QuantityDecimal = $system_deploy_49['deploy_value'];//数量小数位
    $system_deploy_93 = getSys_deploy(93);
    $PriceDecimal = $system_deploy_93['deploy_value'];//单价小数位
    $restBlocks['QuantityDecimal'] = $QuantityDecimal;
    $restBlocks['PriceDecimal'] = $PriceDecimal;

    $arr['restBlocks'] = $restBlocks;
//}
ConvertTojsonString(1,$arr,"success");
?>