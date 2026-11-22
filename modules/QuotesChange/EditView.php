<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$currentModule,$current_user;
$languageType= getLanguageType($current_user);
global $adb;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyobj=Currency::getInstance($adb);
$currencyid=$currencyobj->getCurrencyId();
if(isset($_REQUEST['record']) && $_REQUEST['record'] != ''){
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
	 $focus->name=$focus->column_fields[$focus->list_link_field];
	$approve = Approve::getInstance($currentModule);
	if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
		echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
		exit();
	}
}

if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
   
	setObjectValuesFromRequest($focus);
}
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

//创建单据时，编号为自动生成后的编号
if($focus->mode!='edit' || isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['quoteschange_no'] = $value;
}
if($_REQUEST['isDuplicate'] == 'true') {
	$focus->id = '';
	$focus->mode = '';
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
$disp_view = getView($focus->mode);
$mode = $focus->mode;
$smarty->assign("OP_MODE",$disp_view);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("SINGLE_MOD",'QuotesChange');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign('ISADMIN',$current_user->is_admin);

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
if(isset($cust_fld)){
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
}
if($focus->id > 0){
	$_REQUEST['quote_id'] = $focus->column_fields['quote_id'];
	$_REQUEST['change_type'] = $change_type = $focus->getChangeType($focus->column_fields['change_type']);
}else{
	if(empty($_REQUEST['change_type'])){
		$change_type = 'add';
	}else{
		$change_type = $_REQUEST['change_type'];
	}
}
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));

if($focus->id > 0){
	$smarty->assign('QUOTEID',$focus->column_fields['quote_id']);
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));	
}else{
	//报价单关联创建
	if(!empty($_REQUEST['quote_id'])){
		//追加 add 更换 replace
		$isSelectModule = getSalesEntityType($_REQUEST['quote_id']);
		$so_focus = CRMEntity::getInstance($isSelectModule);
		$so_focus->mode = 'edit';
		$so_focus->id = $_REQUEST['quote_id'];
		$so_focus->retrieve_entity_info($_REQUEST['quote_id'],$isSelectModule);
		//带人报价单的条款与条件
		if(array_key_exists('terms_conditions',$focus->column_fields)){
			$focus->column_fields['terms_conditions'] = $so_focus->column_fields['terms_conditions'];
		}
		$smarty->assign('QUOTEID',$_REQUEST['quote_id']);
	}
	if(!empty($_REQUEST['change_type'])){
		$change_type = $_REQUEST['change_type'];
		if($change_type == 'add'){
			$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));		
		}else if($change_type == 'edit'){
			$quote_focus = CRMEntity::getInstance('Quotes');
			$quote_focus->id = $_REQUEST['quote_id'];
			$quote_focus->retrieve_entity_info($_REQUEST['quote_id'], "Quotes");
			$data = $focus->getInventoryProducts_info($_REQUEST['quote_id']);
			foreach($data as $infos){
				$lineitem_id[] = $infos['lineitem_id'];
			}
			$quote_focus->lineitemIds = implode(',',$lineitem_id);
			$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'module_create'));		
		}else{
			$data = $focus->getInventoryProducts_info($_REQUEST['quote_id']);
			foreach($data as $infos){
				$lineitem_id[] = $infos['lineitem_id'];
			}
			$focus->lineitemIds = implode(',',$lineitem_id);
			$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'sourcemodule_create'));	
		}	
	}
}
$VersionInfo = getVersionInfo();
//新增 - 中能
if($focus->mode == '' && empty($_REQUEST['isDuplicate'])){
	$user_focus = CRMEntity::getInstance('Users');
	$user_focus->retrieve_entity_info($current_user->id, 'Users');
	$wareid = $user_focus->column_fields['wareid'];
	$focus->column_fields['wareid'] = $wareid;
}
$smarty->assign('CHANGE_TYPE',$change_type);
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
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
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
$smarty->assign('BLOCKS',$act_data);
/*---仓库信息---*/
require_once ('include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
//自定义字段信息
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

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {//复制
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$currencyid = $inventory_cur_info['currency_id'];
	$focus->id = "";
    $focus->mode = '';
}
$smarty->assign("MODE", $focus->mode);
if(isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else $smarty->assign("RETURN_MODULE","QuotesChange");
if(isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
else $smarty->assign("RETURN_ACTION","index");
if(isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if(isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

if($focus->mode == 'edit') {
	//获取当前单据币种的详细信息：如币种名称、币种编码、币种ID、汇率、符号
	$inventory_cur_info = getInventoryCurrencyInfo('QuotesChange', $focus->id);
	$smarty->assign("INV_CURRENCY_ID", $inventory_cur_info['currency_id']);
} else {
	$smarty->assign("INV_CURRENCY_ID", $currencyid);
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
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
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSIONINFO',$version_info);
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
 //editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:10
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>