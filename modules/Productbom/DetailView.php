<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $mod_strings,$app_strings,$theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty = new lingdangCRM_Smarty;
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
if(isset($_REQUEST['record']) && $_REQUEST['record']!= '') {
    $focus->retrieve_entity_info($_REQUEST['record'],"Productbom");
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
}
include('user_privileges/user_language_'.$current_user->id.'.php');

/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);

//$startapprove=$approve->startBlocksApprove();
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Productbom");
    $focus->id = $_REQUEST['record'];
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],'PurchaseOrder',1));
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
if(isset($_REQUEST['setproductbom']) && $_REQUEST['setproductbom'] == true)
{
    return updateProductbomPresence($focus->id);
}
include('user_privileges/user_language_'.$current_user->id.'.php');

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("POTENTIALID",$focus->column_fields['potential_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
//$TabArray = array();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if (isset($focus->name)) 
$smarty->assign("NAME", $focus->name);
else 
$smarty->assign("NAME", "");
global $detail_column_fields_value;
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

$smarty->assign("BLOCKS", getBlocks("Productbom","detail_view",'',$focus->column_fields));
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
$smarty->assign("STOCKID",$focus->id);
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETE',$isdelete);
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("SINGLE_MOD", 'Productbom');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);


$smarty->assign("CREATEPDF","permitted");

$smarty->assign("MODULE", $currentModule);
$smarty->assign("CONVERTMODE",'sotoinvoice');

/**
 * 获取系统参数 表体录入样式配置信息 1:外贸行业
 * @project PROT99 奥特林：产品明细录入改进
 * @author Tujt 2014-10-15
 */
$deployarray_52 = getSys_deploy(52);
global $productsdetailstyle;
$productsdetailstyle = 0;
if(1 == $deployarray_52['deploy_value']){
	$productsdetailstyle = 1;
}
$smarty->assign("PRODUCTSDETAILSTYLE", $productsdetailstyle);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html

$tabid = getTabid("Productbom");
$data =$fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);


//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//
if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
//if(get_file_address($module,'ProductDetails') == 'true' && getDatainterface('using_inventory') == '1'){
   //$list_buttons_moreD['synchronousinventory'] = getFixedLabel('SYNCHRONOUSINVENTORY');
//}
 //andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
//$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');

setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);
//$smarty->display("DetailView/InventoryDetailRelated.tpl");
?>