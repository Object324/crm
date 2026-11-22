<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global   $theme, $currentModule, $current_user, $adb;

$languageType= getLanguageType($current_user);
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
$sourcemodules=getSourceModule($currentModule);
if(sizeof($sourcemodules)>0)
{
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $isSelectModule = $val['entitytype'];
    }
}
if(isset($_REQUEST['record']) && $_REQUEST['record'] != ''){
	crm_load_class_file("Detail_Edit_View",'include/utils');
	$isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    
	setObjectValuesFromRequest($focus);
}

//产品关联创建
//@edit:liushuai,2021-03-16,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
{
    $_REQUEST['product_id']=$_REQUEST['fromid'];
}
if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
}
$smarty->assign('ISADMIN',$current_user->is_admin);
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$disp_view = getView($focus->mode);
$mode = $focus->mode;

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	if(!empty($_REQUEST['quote_id']) && get_versiontrade() == 'yangduan'){
		$query = 'select accountid from ld_quotes where quoteid = ?';
		$result = $adb->pquery($query,array($_REQUEST['quote_id']));
		$accountid = $adb->query_result($result,0,0);
		$focus->column_fields['account_id'] = $accountid;
	}
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
	$focus->id = "";
	$focus->mode = '';
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['purchaseinquiryorder_no'] = $value;
}

$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

$smarty->assign("SINGLE_MOD", $currentModule);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$category = getParentTab();
$smarty->assign("CATEGORY", $category);
$VersionInfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");

if (isset ($_REQUEST['convertmode']) && ($_REQUEST['convertmode'] == 'quotetoso' || $_REQUEST['convertmode'] == 'update_quote_val')) {
	$txtTax = (($quote_focus->column_fields['txtTax'] != '') ? $quote_focus->column_fields['txtTax'] : '0.000');
	$txtAdj = (($quote_focus->column_fields['txtAdjustment'] != '') ? $quote_focus->column_fields['txtAdjustment'] : '0.000');
}
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
}
//43585: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），采购询价单选择源单字段新增源单类型自定义表单，自定义表单单据查看详情界面相关信息中关联创建“采购询价单”时，没有带出产品分录明细（需要补丁）
if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])){
	if(get_file_address($_REQUEST['frommodule'],'ProductDetails'))
	{
		$quoteid = $_REQUEST['fromid'];
		$quote_focus = CRMEntity::getInstance($_REQUEST['frommodule']);
		
		$detailtable=$quote_focus->Detail_table;
		$productsql=" select lineitem_id from $detailtable where id=? ";
		$productresult=$adb->pquery($productsql,array($quoteid));
		for($i=0;$i<$adb->num_rows($productresult);$i++){
			$_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
		}
	}
	$_REQUEST['selectsourcename'] = $_REQUEST['frommodule'];
  
}

if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{
    $isSelectModule = $_REQUEST['selectsourcename'];
    $so_focus = CRMEntity::getInstance($isSelectModule);
    $so_focus->id=$quoteid;
    $so_focus->lineitemIds = rtrim($_REQUEST['listval'], ",");
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
	//原单的单据名字
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,$isSelectModule));
    //22703: 出库单编辑界面：删除原来的合同订单，重新选择一个合同订单保存，结果报错
    $smarty->assign("ID", $focus->id);
    $smarty->assign("RELATEDORDERIDSTRING", $_REQUEST['entityid']);//源单id
    $fieldinfo=$focus->getSourceFieldInfo();//获取原单字段信息
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
}else{
	if($focus->mode == 'edit'){
		$setListVal = 1;
		//原单的单据名字
		$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
	}
	if($focus->id > 0){
		$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	}else{
		$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
	}
}
//38337: （1.6）合同订单明细界面>相关创建采购询价单：产品带出了，但是没有把源单字段带出来 。（需要补丁）
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));

$richText=$act_data['RichText'];
unset($act_data['RichText']);
if(!empty($richText))
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
else
	$smarty->assign('RICHTEXTBOX','');
//$smarty->assign('RICHTEXTBOX',implode(',',$richText));
$smarty->assign('RICHTEXTCOUNT',is_array($richText)?sizeof($richText):0);
$smarty->assign("BLOCKS", $act_data);
$smarty->assign("OP_MODE", $disp_view);

$productFields['fields']=$ProductDetailsData->moduleProductToolField;
//0044349: 自用系统（kfbcrm）系统设置-系统参数设置-设置单据分录明细最后一行录入产品后是否自动新增行：失效
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;	//单据分录明细中录入价税合计重算的字段
$systemmethod = $ProductDetailsData->getSystemMethod();
$versiontrade=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];

$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);//计算公式中基准字段
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
	$focus->id = "";
	$focus->mode = '';
}
$smarty->assign('LISTALLVAL',$setListVal);


$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
$smarty->assign("MODE", $focus->mode);
if (isset ($cust_fld)) {
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
if (isset ($_REQUEST['return_module']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", $currentModule);
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
$smarty->assign("MODULE", $currentModule);
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);

$data =$focus->fieldobj->split_validationdataArray();
/*---仓库信息---*/
require_once ('include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
////克莱门特：重复发货一定要避免，即发货单源单不能重复
if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'Quotes' && $_REQUEST['fromid'] > 0 && $VersionInfo['account'] == 'climaveneta'){
	$haveInvenotryOrder = $focus->haveInvenotryOrder('Quotes',$_REQUEST['fromid'],$focus->id);
	$smarty->assign('haveInvenotryOrder',$haveInvenotryOrder);
}
if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'QuotesChange' && $_REQUEST['fromid'] > 0 && $VersionInfo['account'] == 'climaveneta'){
	$haveInvenotryOrder = $focus->haveInvenotryOrder('QuotesChange',$_REQUEST['fromid'],$focus->id);
	$smarty->assign('haveInvenotryOrder',$haveInvenotryOrder);
}
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
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-10
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
$smarty->assign('FROMID',$_REQUEST['fromid']);
///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));
setGLobalURLSmarty($smarty);//设置js,css等访问路径


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:44
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>