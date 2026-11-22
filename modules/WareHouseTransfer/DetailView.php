<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once ('include/Stock/CommonStock.php');
global $theme,$currentModule,$singlepane_view,$current_user,$adb;
include('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$focus = CRMEntity::getInstance($currentModule);
/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"WareHouseTransfer");
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
}
checkWarehouseUser();//判断仓库权限 tujt 2014-11-12
//复制
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty->assign("MODULE", $currentModule);

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

if (isset($focus->name)) 
    $smarty->assign("NAME", $focus->name);
else 
    $smarty->assign("NAME", "");
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$smarty->assign("BLOCKS", getBlocks($currentModule,"detail_view",'',$focus->column_fields));

$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("SINGLE_MOD", 'WareHouseTransfer');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);


$smarty->assign("CREATEPDF","permitted");
//产品明细
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));

$tabid = getTabid($currentModule);
//详情页 - 右边操作栏信息
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);


$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
/*上一条和下一条数据信息*/
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//  
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
	//$smarty->assign("CREATEATTACHMENT","permitted");

//调出库间权限
$smarty->assign('OUTWAREHOUSE',$focus->column_fields['outwarehouse']);
$outwarehouseStatus = getWareHouseUser($current_user->id,$focus->column_fields['outwarehouse']);
$smarty->assign("DETAILVIEW_AJAX_EDIT",true);
//调入库间权限
$smarty->assign('INWAREHOUSE',$focus->column_fields['inwarehouse']);
$inwarehouseStatus = getWareHouseUser($current_user->id,$focus->column_fields['inwarehouse']);
if($outwarehouseStatus == true || $inwarehouseStatus == true)
    $smarty->assign('WAREHOUSEUSER','YES');
else
    $smarty->assign('WAREHOUSEUSER','NO');
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