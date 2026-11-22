<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $mod_strings,  $theme, $currentModule, $current_user, $adb;
crm_load_function_file("getInventoryCurrencyInfo",'include/utils','InventoryUtils');
require('user_privileges/user_language_'.$current_user->id.'.php');
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty();
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyobj=Currency::getInstance($adb);
$currencyid=$currencyobj->getCurrencyId();
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));

if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '')
{
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($_REQUEST['record'], "Productbom");
	$focus->name = $focus->column_fields['subject'];
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit')
{
	setObjectValuesFromRequest($focus);
}

$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
$disp_view = getView($focus->mode);
$mode = $focus->mode;
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
	$focus->column_fields['productbom_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$focus->id = "";
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
 // //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
//	$focus->column_fields['assigned_user_id'] = $current_user->id;
	$focus->column_fields['subject'] = '';
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['productbom_no'] = $value;
}
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
if(!empty($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate']==true){
    $disp_view = 'create_view' ;
}
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
$smarty->assign("BLOCKS",$act_data);

$smarty->assign("OP_MODE", $disp_view);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", 'Productbom');
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
//$category = getParentTab();
//$smarty->assign("CATEGORY", $category);
if (isset ($focus->name) && !empty($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");

if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$focus->mode = 'edit';
	$focus->id = $_REQUEST['record'];
}
//@edit:liushuai,2021-03-16,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
{
    $_REQUEST['product_id']=$_REQUEST['fromid'];
}
if($focus->id > 0){
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
}else if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));//产品关联创建
	$smarty->assign('FROM_MODULE','Products');//
}else{
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
}
$productFields['fields']=$ProductDetailsData->moduleProductToolField;

$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;	//单据分录明细中录入价税合计重算的字段
$systemmethod = $ProductDetailsData->getSystemMethod();

$versiontrade=getVersionTradeInfo();
//edit:can 2020-12-30 44024: （https://61mis.com/kfbcrm [^]）客户问题（王杰），设置参数“设置单据分录明细最后一行录入产品后是否自动新增行”为是保存后，产品套餐模块没有生效（需要补丁）
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];


$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$smarty->assign("DUPLICATE_FROM", $focus->id);;
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$currencyid = $inventory_cur_info['currency_id'];
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,'PurchaseOrder',2));
	$focus->id = "";
	$focus->mode = '';
	$focus->column_fields['subject'] = '';
}
$smarty->assign("MODE", $focus->mode);
if (isset ($_REQUEST['return_module']) && !isset($_REQUEST['parent_id']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "Productbom");
if (isset ($_REQUEST['return_action']))
	$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
else
	$smarty->assign("RETURN_ACTION", "index");
if (isset ($_REQUEST['return_id']))
	$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset ($_REQUEST['return_viewname']))
	$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE", "Productbom");
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);

$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));
//if create SO, get all available product taxes and shipping & Handling taxes
$tabid = getTabid("Productbom");
$data =$fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
if ($focus->mode == 'edit')
{
    
    
	$inventory_cur_info = getInventoryCurrencyInfo('Productbom', $focus->id);
	$smarty->assign("INV_CURRENCY_ID", $inventory_cur_info['currency_id']);
} else {
	$smarty->assign("INV_CURRENCY_ID", $currencyid);
}
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}
//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-17
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:53
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
if(isset($_REQUEST['adjustselectquantity'])&&$_REQUEST['adjustselectquantity']=='yes')
{
    //选择产品套餐界面的调整按钮
    $arr['oktext']=getFixedLabel('SAVEANDSELECT');
}
ConvertTojsonString(1,$arr,"success");
?>