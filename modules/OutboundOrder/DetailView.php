<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once ('include/Stock/CommonStock.php');
//include($root_directory.'include/ProductDetailsHtml/ProductDetailsHtml.php');
global $mod_strings,$app_strings,$theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty = new lingdangCRM_Smarty;


$focus = CRMEntity::getInstance($currentModule);
checkWarehouseUser();//判断仓库权限 tujt 2014-11-12
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"OutboundOrder");
    $focus->id = $_REQUEST['record'];
	 /**
	  * subject out_no
	  * @author Tujt 
	  */
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSourceModule = Detail_Edit_View::getInventoryField('entitytype',$focus->id);
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$isSourceModule,1));
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";


$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if (isset($focus->name)) 
$smarty->assign("NAME", $focus->name);
else 
$smarty->assign("NAME", "");
//if(selOutInfo($focus->id,1) == 1 || isPermitted($currentModule,"Delete","") == 'no')
//{
    //$isedit = 1;
    //$isdelete = 1;
//}
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;


 crm_load_class_file('ModuleUtils','modules/lingdang');
 $ModuleUtilsObj = new ModuleUtils();
   
$smarty->assign("BLOCKS", $ModuleUtilsObj->getBlocks($currentModule,"detail_view",'',$focus->column_fields));

$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$VersionInfo = getVersionInfo();
if($VersionInfo['trade']=='zhongfu')
{
   $smarty->assign('cf_2444_image',$focus->getcf_2444_Image()) ;
}
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//
$smarty->assign("STOCKID",$focus->id);
//出库单是否启用审批流程
$deployarray=getSys_deploy(135);
$out_approvestatusw = $deployarray['deploy_value'];
//审批不启用时，才显示审核、反审核按钮
if($out_approvestatusw == 0){
	$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
	$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
}else{
	$smarty->assign('APPROVESTATUS',$focus->getOutStatus($focus->id));//审批状态图片
}
//---begin优化
$outinfos=selOutInfo($focus->id);

$smarty->assign("STOCKPRESENCE",$outinfos['presence']);
$smarty->assign("STOCKWARID",$outinfos['wareid']);
$smarty->assign("POWER",UserNationPower('OutboundOrder',$focus->id));
//---end优化,edit:can 
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETE',$isdelete);
$smarty->assign('DELETE','permitted');
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
//$salesorder_no = getModuleSequenceNumber($currentModule,vtlib_purify($_REQUEST['record']));
//$smarty->assign("SO_NO",$salesorder_no);
// 出库
$fieldobj=Field::getInstance($currentModule,$adb);
$mod_seq_field = $fieldobj->FieldInfoListByKeyValue($currentModule,$adb);
if ($mod_seq_field != null) {
	$mod_seq_id = $focus->column_fields[$mod_seq_field['fieldname']];
} else {
	$mod_seq_id = $focus->id;
}
$smarty->assign('MOD_SEQ_ID', $mod_seq_id);
// END
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("SINGLE_MOD", 'OutboundOrder');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
$smarty->assign("CREATEPDF","permitted");
$smarty->assign("MODULE", $currentModule);
$smarty->assign("CONVERTMODE",'sotoinvoice');
//产品明细
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));
$data =$fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

/**
 * 
 * 更新操作
 * edit:diony
 * date:2014-01-10
 * reason:确认出库时是否发送短信通知客户
 */ 
$deployarray=getSys_deploy(21);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign('SENDINFORMDEPLOY',$deployvalue);
if(isset($_REQUEST['sendtype'])) {
    $sendtype = $_REQUEST['sendtype'];
    $smarty->assign('SENDTYPE',$sendtype);
}

/**
 * edit:yangliu
 * date:2015-01-16
 * reason:短信账户是否设置
 */
$SMSarray = GetSMSAutograph();
$smsName = $SMSarray['account_name'];//账号
if($smsName == ""){
    $smarty->assign('SMS_ISSET','NO');
}else{
    $smarty->assign('SMS_ISSET','YES');
}

if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
 $tabid = getTabid("OutboundOrder");
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
// if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
$smarty->assign('KISERROR',$_SESSION['kiserror']);
/* 关联创建 end */

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
//
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