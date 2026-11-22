<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//include($root_directory.'include/ProductDetailsHtml/ProductDetailsHtml.php');

global $app_list_strings;
global  $currentModule, $singlepane_view;

$focus = CRMEntity::getInstance($currentModule);

//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"PurchaseCashBack");
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];

}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;


/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'PurchaseCashBack');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html

$tabid = getTabid("PurchaseCashBack");
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
      
//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
//if( $check_button['moduleSettings'] == 'yes'){
    //$list_buttons_moreD['moduleSettings'] = getFixedLabel('LBL_PAGE_SET');
//}
$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("SinglePane_View", $singlepane_view);


$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
/**
 * 销售退货单没有附件链接
 * @reason 0008469 
 * @author Tujt 2014-04-18
 */
//if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");

$total=$totalhavepaymentamount+$totalnopaymentamount;
$smarty->assign("TOTALPAYMENTAMOUNT",number_format($total,2));
$smarty->assign("TOTALHAVEEPAYMENTAMOUNT",number_format($totalhavepaymentamount,2));
$smarty->assign("TOTALNOPAYMENTAMOUNT",number_format($totalnopaymentamount,2));
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

//andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
//$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
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