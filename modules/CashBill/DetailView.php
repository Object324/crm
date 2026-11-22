<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


global  $currentModule, $current_user, $theme;
crm_load_class_file('cls_CashBill_EntityHtml','modules/CashBill/EntityData');
$focus = CRMEntity::getInstance($currentModule);

 
$smarty = new lingdangCRM_Smarty;
$languageType= getLanguageType($current_user);
$smarty->assign("LANGUAGETYPE",$languageType);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CashBill");
     $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];
    $isSourceModule = $focus->getSourceField('entitytype',$_REQUEST['record']);
    $focus->mode = 'Details';
	$obj_entity=new cls_CashBill_EntityHtml( $_REQUEST['record'],'',$isSourceModule,'detail');
    $obj_entity->Detailobj->frommdouleFocus = $focus;
    $obj_entity->Detailobj->productdetail_mode = 'details';
    if($obj_entity->getSourceWithDetail($isSourceModule)=='yes'){
        $smarty->assign('ASSOCIATED_PRODUCTS',$obj_entity->createHtml());//收款信息明细html
        $ProductDetailsHtml = $obj_entity->Detailobj->DetailsHtmlobj;
    }
    else{
        $smarty->assign('TREXPENSE',$obj_entity->createHtml());//收款信息明细html
    }
    
    
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$isSourceModule,1));
    //开始
    $isSourceModule=$focus->getSourceField('entitytype',$focus->id);
    $relatedOrderIdStr=getDetailListValName($_REQUEST['record'],$isSourceModule,3);
    //echo $isSourceModule.'==='.str_replace('|',',',$relatedOrderIdStr).'<br>';
   // $relatedinformations=getRelatedOrderInformation($isSourceModule,str_replace('|',',',$relatedOrderIdStr),2);
    //$smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);
     crm_load_class_file("Detail_Edit_View_finance",'include/utils');
    // $relatedinformations=Detail_Edit_View_finance::getCashbill_SoureceInfo($isSourceModule,str_replace('|',',',$relatedOrderIdStr));
    // $smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);//原单信息
     
      $smarty->assign("RELATEDORDERIDSTRING", str_replace('|',',',$relatedOrderIdStr));//源单id
    //结束
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) 
    $smarty->assign("NAME", $focus->name);
else 
    $smarty->assign("NAME", "");

//获取表单
global $detail_column_fields_value;
$smarty->assign('CashBillType',$focus->column_fields['cashtype']);
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);

$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
$totalfieldobj=$focus->fieldobj->getFieldInfoobjBykey("columnname",'total');
$smarty->assign("UsedAmountDetail",'');
//dump($focus->column_fields[$totalfieldobj->getFieldName()]);
if($focus->column_fields['cashtype']=='debuction'){
    //预收单显示历史核销记录
    crm_load_class_file("cls_DebuctionInfo",'modules/CashBill');
 
    
    $debuctioninfoobj=new cls_DebuctionInfo($focus->id,$focus);
    $tmphtml=$debuctioninfoobj->getDebuctionListHtml($focus->column_fields[$totalfieldobj->getFieldName()]);
    $smarty->assign("UsedAmountDetail",$tmphtml);
    
}

//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'CashBill');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);
/*
add:kara EDITVIEW two lines 
date:2013-05-30
reason:create/eidt button authority
*/   
$tabid = getTabid("CashBill");
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
//获取审批状态
$checkoutstatus = $focus->column_fields['checkoutstatus'];
if($checkoutstatus=='已审核'){
    $smarty->assign("EDITSTATUS", 'no');
    $checkoutstatu=1;
}else{
    $checkoutstatu=2;
}
//收款单是否启用审批流程
$deployarray=getSys_deploy(133);
$cashbill_approvestatusw = $deployarray['deploy_value'];
//判断收款的审批是否启用，是：不显示审核状态图标，显示审批图标
if($cashbill_approvestatusw == 1){	//不启用时，显示审核状态
	//审核状态图片
	if($languageType=='en'){
		$smarty->assign('CHECKOUTSTATU','checked'.$checkoutstatu.'_en.png');
	}else{
		$smarty->assign('CHECKOUTSTATU','checked'.$checkoutstatu.'.png');
	}
	$smarty->assign("CHECKOUTSTATUS", $checkoutstatus);
}else{
	$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
	$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
}
//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

$smarty->assign("MODULE",$currentModule);


//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//更多信息

$is_rel_list=isPresentRelatedLists($currentModule);

$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);
/*
edit:can
date:20130409
reason:0003668: 给普通用户授予所有权限(不包括联系人权限),用该用户登录后，结果该用户无法批量修改、删除任何单据
other:待办任务模块已删除，默认给权限

*/
$smarty->assign("EVENT_PERMISSION",'true');

$smarty->assign("SinglePane_View", $singlepane_view);

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
$paymentplan_field_obj=Field::getInstance('PaymentPlan',$adb);
$arrpaymentLabel=$paymentplan_field_obj->getFieldLables();
//收款信息界面 合并行
if(vtlib_isModuleActive('PaymentPlan') == false)
    $smarty->assign('TABLECOSPLAN',6);
else
    $smarty->assign('TABLECOSPLAN',11);
$smarty->assign('ARRFIELDLABEL',$arrpaymentLabel);

$smarty->assign('ISSOURCEMODULE',$isSourceModule);

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */    

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
//获取客户和联系人区块信息
//$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
//$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
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

if(!empty($isSourceModule)&&$obj_entity->getSourceWithDetail($isSourceModule)=='yes'){
    DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);
}
else
    DetailViewWidthTabDetail($currentModule,$focus,$smarty);

?>