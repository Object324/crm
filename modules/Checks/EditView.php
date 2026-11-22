<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
global   $theme, $currentModule, $current_user, $adb;

require('user_privileges/user_language_'.$current_user->id.'.php');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val') {
		//Updating the Selected Quote Value in Edit Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != '') {
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}

		$quoteid = $focus->column_fields['quote_id'];
		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
		$quote_focus = CRMEntity::getInstance('Quotes');
		$quote_focus->id = $quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->name=$focus->column_fields[$focus->list_link_field];
	} else {
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->retrieve_entity_info($_REQUEST['record'], "Checks");
         $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
         if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
         {
          
                crm_load_class_file('cls_CurUserDataScope','include/ListView');
                $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
                $datascopeobj->isMyViewData($_REQUEST['record']);
         }
		$focus->name=$focus->column_fields[$focus->list_link_field];
        //require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
        
        
	}
} else {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val') {
		//Updating the Select Quote Value in Create Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != '') {
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}
		$quoteid = $focus->column_fields['quote_id'];
		$quote_focus = CRMEntity::getInstance('Quotes');;
		$quote_focus->id = $quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
		$smarty->assign("MODE", $quote_focus->mode);
	}
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}
if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
}
// Get Account address if lingdang_account is given
if ((isset ($_REQUEST['account_id'])) && ($_REQUEST['record'] == '') && ($_REQUEST['account_id'] != '') && ($_REQUEST['convertmode'] != 'update_quote_val')) {

	$acct_focus =CRMEntity::getInstance('Accounts');
	$acct_focus->retrieve_entity_info($_REQUEST['account_id'], "Accounts");
	$focus->column_fields['bill_city'] = $acct_focus->column_fields['bill_city'];
	$focus->column_fields['ship_city'] = $acct_focus->column_fields['ship_city'];
	//added to fix the issue 4526
	$focus->column_fields['bill_pobox'] = $acct_focus->column_fields['bill_pobox'];
	$focus->column_fields['ship_pobox'] = $acct_focus->column_fields['ship_pobox'];
	$focus->column_fields['bill_street'] = $acct_focus->column_fields['bill_street'];
	$focus->column_fields['ship_street'] = $acct_focus->column_fields['ship_street'];
	$focus->column_fields['bill_state'] = $acct_focus->column_fields['bill_state'];
	$focus->column_fields['ship_state'] = $acct_focus->column_fields['ship_state'];
	$focus->column_fields['bill_code'] = $acct_focus->column_fields['bill_code'];
	$focus->column_fields['ship_code'] = $acct_focus->column_fields['ship_code'];
	$focus->column_fields['bill_country'] = $acct_focus->column_fields['bill_country'];
	$focus->column_fields['ship_country'] = $acct_focus->column_fields['ship_country'];

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
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
	$focus->id = "";
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
//	$focus->column_fields['assigned_user_id'] = $current_user->id;
}
/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['checks_no'] = $value;
}
global $global_pick_list_values;
global $edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
   /**
    * 更新操作
    * edit:can
    * date:20131223
    * reason:添加富文本框
    * */
    $richText=$act_data['RichText'];
    unset($act_data['RichText']);
	if(!empty($richText)){
		$smarty->assign('RICHTEXTBOX',implode(',',$richText));
		$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
	} else {
		$smarty->assign('RICHTEXTBOX','');
		$smarty->assign('RICHTEXTCOUNT',0);
	}
	$smarty->assign("BLOCKS", $act_data);

$smarty->assign("OP_MODE", $disp_view);
$smarty->assign("SINGLE_MOD", 'Checks');


//$category = getParentTab();
//$smarty->assign("CATEGORY", $category);
//

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
if($focus->id > 0){
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
}else{
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
}
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
$smarty->assign("MODE", $focus->mode);
if (isset ($cust_fld)) {
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
if (isset ($_REQUEST['return_module']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "Checks");
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
$smarty->assign("MODULE", "Checks");
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);

//$smarty->assign("CHECKSPRODUCTINFO",getChecksProductInfo($focus->id,1,selCheckInfo($focus->id,2)));
$tabid = getTabid("Checks");

$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);

global $adb;
/*---仓库信息---*/
$wareresult = selWareAll();
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
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
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
//$smarty->assign('RELATEDORDERINFORMATION',$obj_entity->showSourceHtml());//收款信息明细html
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));

//相关信息日期高级查询
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
//editor:gyq_161 reason:带分录模块弹出层   2019/11/14 11:09
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>