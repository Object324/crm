<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$theme,$currentModule,$singlepane_view;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj; 
$smarty = new lingdangCRM_Smarty;

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"PurchaseOrder");
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
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$isSourceModule,1));	
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


$smarty->assign('ISSUBMIT',$issubmit);
$smarty->assign('ISAPPROVE',$isapprove);
$smarty->assign('ISCANCEL',$iscancel);
//$smarty->assign('APPROVE',$approvelog);
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETE',$isdelete);

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
$smarty->assign("VENDOR_ID", $focus->column_fields['vendor_id']);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE",$currentModule);
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
//
$smarty->assign("VENDORID",$focus->column_fields['vendor_id']);
$smarty->assign('KISERROR',$_SESSION['kiserror']);

/**
 * @edit:chj
 * @date:2014-9-12
 * @reason: 采购订单创建付款计划 ,新增按钮
 * @description:
 */
if($record != '')
{
    $deployarray=getSys_deploy(20); //在采购订单模块创建付款计划时是否控制付款计划总额必须等于订单
    $sql = "select total,sum(ifnull(amount,0)) as amount from ld_purchaseorder
            left join ld_sendpayment on ld_purchaseorder.purchaseorderid = ld_sendpayment.Purchaseorder_id 
            where purchaseorderid = ? group by ld_sendpayment.Purchaseorder_id  ";
    $query = $adb->pquery($sql,array($_REQUEST['record']));
    if($adb->query_result($query,0,'total') > $adb->query_result($query,0,'amount') || $deployarray['deploy_value'] == 0)
    {
        $smarty->assign("isCreateSendPayment", 'yes');
    }
    
    
}
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
//$purchaseorder_no = getModuleSequenceNumber($currentModule,vtlib_purify($_REQUEST['record']));
//$smarty->assign("PO_NO",$purchaseorder_no);


$smarty->assign("SINGLE_MOD", 'PurchaseOrder');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);


$smarty->assign("CREATEPDF","permitted");

$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细

 $tabid = getTabid("PurchaseOrder");

 $data =$fieldobj->split_validationdataArray();

 $smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
 $smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
 $smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//if( $check_button['moduleSettings'] == 'yes'){
    //$list_buttons_moreD['moduleSettings'] = getFixedLabel('LBL_PAGE_SET');
//}

$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);

///if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

if(isPermitted("SendPayment","EditView",'') == 'yes'&&vtlib_isModuleActive('SendPayment'))
{
    $smarty->assign("SENDPAYMENTEDIT","permitted");
   	$smarty->assign("SENDPAYMENTCREATE","permitted");
   
}
if(isset($_REQUEST['purchasetype']) &&$_REQUEST['purchasetype']=='yes' &&!isset($_REQUEST['autocreate']) )
{
    
    $smarty->assign("CREATE","yes");
    $isCreate = 'yes';
}

    
if(isPermitted("SendCashBill","EditView",'') == 'yes'&&vtlib_isModuleActive('SendCashBill'))
	$smarty->assign("SENDCASHBILLEDIT","permitted");
    
$deployarray=getSys_deploy(15);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign('DEPLOYVALUE',$deployvalue);
 if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
	$smarty->assign("CREATEATTACHMENT","permitted");
    
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);

//源美特殊控制
if($version_info['account'] == 'yuanmei'){
	$smarty->assign('ordertype_onclick',$focus->getOrdertypeByField());
}
//andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);

//$smarty->assign('actions_arr_userd',$actions_arr_userd);
//print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
if(isPermitted("PurchaseBack","index",$_REQUEST['record']) == 'yes'&&vtlib_isModuleActive('PurchaseBack'))
{
    $smarty->assign("PURCHASEBACKCREATE","permitted");
}
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
//
//$_SESSION['kiserror']='';
?>