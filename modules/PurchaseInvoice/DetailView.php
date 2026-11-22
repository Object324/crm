<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty = new lingdangCRM_Smarty;

$focus = CRMEntity::getInstance($currentModule);

if(isset($_REQUEST['record']) && $_REQUEST['record']!= '') {
    $focus->retrieve_entity_info($_REQUEST['record'],"PurchaseInvoice");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
    
    $contactid= $focus->column_fields['contact_id'];
    $potentialid= $focus->column_fields['potential_id'];
    $quote_id= $focus->column_fields['quote_id'];
    //print_r($focus->column_fields);
    if($contactid != 0){
        $smarty->assign('CONTACTID',$contactid);
    } 
    if($potentialid != 0){
        $smarty->assign('POTENTIALID',$potentialid);
    } 
    if($quote_id != 0){
        $smarty->assign('QUOTEID',$quote_id);
    }
    
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

//include('user_privileges/user_language_'.$current_user->id.'.php');
////审批状态图片
//if(isset($focus->logic->approvebtn['info'])){//有审批
	//$approvestatus = $focus->logic->approvebtn['info']['approvestatus'];
	//if(empty($approvestatus)) $approvestatus = 0;
	//if($languageType=='en'){
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'_en.png');
	//}else{
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'.png');
	//}
//}

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"PurchaseInvoice");
    $focus->id = $_REQUEST['record'];
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSourceModule = Detail_Edit_View::getInventoryField('entitytype',$focus->id);
    
    $relatedOrderIdStr=getDetailListValName($_REQUEST['record'],$isSourceModule,3);

  //  $relatedinformations=getRelatedOrderInformation($isSourceModule,str_replace('|',',',$relatedOrderIdStr),2);
  //  $smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);
    
    crm_load_class_file("Detail_Edit_View_finance",'include/utils');
    Detail_Edit_View_finance::$pagetype = 'detail';
    $relatedinformations=Detail_Edit_View_finance::getPurchaseInvoice_SoureInfo($isSourceModule,str_replace('|',',',$relatedOrderIdStr));
    $smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$isSourceModule,1));
	$smarty->assign('VENDOR_ID',$focus->column_fields['vendor_id']);
    
}
if($_REQUEST['power'] == 'false')
{
    echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
		<tbody><tr>
		<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) ."' ></td>
		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span clas
		s='genHeaderSmall'>".getFixedLabel('INSUFFICIENTWAREHOUSE')."</span></td>
		</tr>
		<tr>
		<td class='small' align='right' nowrap='nowrap'>
		<a href='index.php?module=Home&action=index&parenttab=My Home Page'>".getFixedLabel('RETURN')."</a><br>
		</td>
		</tr>
		</tbody></table>
		</div>";
	echo "</td></tr></table>";
	exit;
}
if(isset($_REQUEST['setpurchaseinvoice']) && $_REQUEST['setpurchaseinvoice'] == true)
{
    return updatePurchaseInvoicePresence($focus->id);
}
include('user_privileges/user_language_'.$current_user->id.'.php');


if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("POTENTIALID",$focus->column_fields['potential_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
//$TabArray = array();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";



$smarty->assign('ISSUBMIT',$issubmit);
$smarty->assign('ISAPPROVE',$isapprove);
$smarty->assign('ISCANCEL',$iscancel);
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('APPROVE',$approvelog);
$smarty->assign('DELETE','permitted');

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if (isset($focus->name)) 
$smarty->assign("NAME", $focus->name);
else 
$smarty->assign("NAME", "");
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//
$smarty->assign("STOCKID",$focus->id);
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETE',$isdelete);
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("SINGLE_MOD", 'PurchaseInvoice');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);


$smarty->assign("CREATEPDF","permitted");
//确认入库按钮
$smarty->assign("PAYMENTPLANCREATE","wareSubmit");

$smarty->assign("MODULE", $currentModule);
$smarty->assign("CONVERTMODE",'sotoinvoice');
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html

$tabid = getTabid("PurchaseInvoice");
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);

$sourceModuleInfo = $focus->getSourceField('entitytype',$record);
$isSourceModule=$sourceModuleInfo['module'];
$smarty->assign('ISSOURCEMODULE',$isSourceModule);
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
// if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
//if(get_file_address($module,'ProductDetails') == 'true' && getDatainterface('using_inventory') == '1'){
   //$list_buttons_moreD['synchronousinventory'] = getFixedLabel('SYNCHRONOUSINVENTORY');
//}

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
if(!empty($_REQUEST['salestype']) && $_REQUEST['salestype'] == 'yes'){
	$smarty->assign("CREATE",'yes');
}

//if(isPermitted("SendPayment","EditView",'') == 'yes'&&vtlib_isModuleActive('SendPayment'))
//{
//    $smarty->assign("PAYMENTPLANEDIT","permitted");
//    $smarty->assign("PAYMENTPLANCREATE","permitted");
//    
//}
/**
 * reason:销售发票新增保存后是否立即弹出创建回款计划
 */
$deployarray=getSys_deploy(148);
$deployvalue = $deployarray['deploy_value'];

$smarty->assign('DEPLOYVALUE',$deployvalue);
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);
//布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//
//$smarty->display("DetailView/InventoryDetailRelated.tpl");
?>