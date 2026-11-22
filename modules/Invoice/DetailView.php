<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$currentModule,$theme,$singlepane_view;

$focus = CRMEntity::getInstance($currentModule);

$smarty = new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Invoice");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
    }
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSourceModule = Detail_Edit_View::getInventoryField('entitytype',$focus->id);
  
    /**
     *@edit: andy 
     *@date: 
     *@reason:销售发票获取源单已开票、已收款信息区块 
     *@version: 
     */
    //开始
    $relatedOrderIdStr=getDetailListValName($_REQUEST['record'],$isSourceModule,3);

  //  $relatedinformations=getRelatedOrderInformation($isSourceModule,str_replace('|',',',$relatedOrderIdStr),2);
  //  $smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);
    
      crm_load_class_file("Detail_Edit_View_finance",'include/utils');
      Detail_Edit_View_finance::$pagetype = 'detail';
      $relatedinformations=Detail_Edit_View_finance::getInvoice_SoureInfo($isSourceModule,str_replace('|',',',$relatedOrderIdStr));
         
      
         $smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);
        
    //结束
    
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$isSourceModule,1));      	
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('ISSOURCEMODULE',$isSourceModule);
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


$smarty->assign("MODULE",$currentModule);

//$smarty->assign("UPDATEINFO",updateInfo($focus->id));

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
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
$invoice_no = getModuleSequenceNumber($currentModule,vtlib_purify($_REQUEST['record']));
$smarty->assign("INV_NO",$invoice_no);


$smarty->assign("SINGLE_MOD", 'Invoice');

//if(isPermitted("Invoice","EditView",$_REQUEST['record']) == 'yes')
	//$smarty->assign("EDITVIEW","permitted");
$smarty->assign("CREATEPDF","permitted");
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html
$tabid = getTabid("Invoice");

$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
// Record Change Notification
$focus->markAsViewed($current_user->id);
// END
//打印模板列表
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

if(!empty($_REQUEST['Create']) && $_REQUEST['Create'] == 'true'){
	$smarty->assign("CREATE",'yes');
}

if(isPermitted("PaymentPlan","EditView",'') == 'yes'&&vtlib_isModuleActive('PaymentPlan'))
{
    $smarty->assign("PAYMENTPLANEDIT","permitted");
    $smarty->assign("PAYMENTPLANCREATE","permitted");
    
}
/**
 * reason:销售发票新增保存后是否立即弹出创建回款计划
 */
$deployarray=getSys_deploy(146);
$deployvalue = $deployarray['deploy_value'];

$smarty->assign('DEPLOYVALUE',$deployvalue);

////andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
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