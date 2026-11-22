<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $app_list_strings;
global  $currentModule, $current_user;
crm_load_class_file('cls_SendCashBill_EntityHtml','modules/SendCashBill/EntityData');
$smarty = new lingdangCRM_Smarty;
$focus = CRMEntity::getInstance($currentModule);

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"SendCashBill");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];	
	 /**
	  * sendcashbillno 修改为 sendcashbill_no
	  * @author Tujt 2014-04-11
	  */
	$selectSourceModuleName =  $focus->getSourceField('entitytype',$_REQUEST['record']);
    
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$selectSourceModuleName,1));
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

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
//$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'CashBill');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);

$tabid = getTabid("SendCashBill");

$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
      


$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}
//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign("SinglePane_View", $singlepane_view);
$currency_info = getModuleCurrencyInfo($_REQUEST['record'],$currentModule);//获取当前单据的币种信息
$smarty->assign('CURRENCY_SYMBOL',$currency_info['symbol']);

//付款单是否启用审批流程
$deployarray=getSys_deploy(134);
$sendcashbill_approvestatusw = $deployarray['deploy_value'];
//判断收款的审批是否启用，是：不显示审核状态图标，显示审批图标
if($sendcashbill_approvestatusw == 1){	//不启用时，显示审核状态
	$checkoutstatus = $focus->column_fields['checkoutstatus'];
	$smarty->assign("CHECKOUTSTATUS", $checkoutstatus);
	if($checkoutstatus=='已审核'){
		$smarty->assign("EDITSTATUS", 'no');
		$checkoutstatu=1;
	}else{
		$checkoutstatu=2;
	}
	if($languageType=='en'){
		$smarty->assign('CHECKOUTSTATU','checked'.$checkoutstatu.'_en.png');
	}else{
		$smarty->assign('CHECKOUTSTATU','checked'.$checkoutstatu.'.png');
	}  
}else{
	$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
	$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
}


$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$sourcemodules=getSourceModule($currentModule);

foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $selectSourceModuleName = $val['entitytype'];
    }
}
$default_selectSourceModule=$selectSourceModuleName;
$selectSourceModuleName = $focus->getSourceField('entitytype',$focus->id);


$focus->mode = 'Details';
$obj_entity=new cls_SendCashBill_EntityHtml($focus->id,'',$selectSourceModuleName,'detail');
$obj_entity->Detailobj->frommdouleFocus = $focus;
$obj_entity->Detailobj->productdetail_mode = 'details';
$trPayment=$obj_entity->createHtml();//付款信息明细html

//$smarty->assign("RELATEDORDERINFORMATION", $obj_entity->showSourceHtml());//原单信息
if($obj_entity->getSourceWithDetail($selectSourceModuleName)=='yes'){
    $smarty->assign('ASSOCIATED_PRODUCTS',$trPayment);//收款信息明细html
    $ProductDetailsHtml = $obj_entity->Detailobj->DetailsHtmlobj;
}
else{
    $smarty->assign('TREXPENSE',$trPayment);//收款信息明细html
}

/**
 * edit:can
 * date:20140107
 * reason:控制面板页面设置可以修改字段标签
 * */
$sendPayment_field_obj=Field::getInstance('SendPayment',$adb);
$arrpaymentLabel=$sendPayment_field_obj->getFieldLables();

$tablecosplan = 2;


//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
$smarty->assign('ISSOURCEMODULE',$selectSourceModuleName);

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

/*布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$smarty->display("DetailView/DetailRelated.tpl");*/


if(!empty($selectSourceModuleName)&&$obj_entity->getSourceWithDetail($selectSourceModuleName)=='yes'){
    DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);
}
else
    DetailViewWidthTabDetail($currentModule,$focus,$smarty);

?>