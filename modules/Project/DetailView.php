<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $current_user, $theme, $singlepane_view;
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);
global $projectstatus_old;

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Project");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
    
    
}
$projectstatus_old=$focus->column_fields['projectstatus'];
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片


$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史

$smarty->assign("EDITSTATUS","yes");
if($isedit != 0)
{
    $smarty->assign("EDITSTATUS","no");
}


$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$tabid = getTabid($currentModule);
$category = getParentTab($currentModule);
if($record != '') {
	$sourceModuleInfo = $focus->getSourceField('entitytype',$record);
    $isSourceModule=$sourceModuleInfo['module'];
	$smarty->assign('LASTVALINFO',getDetailListValName($record,$isSourceModule,1)); 
	$focus->id = $record;
	$focus->retrieve_entity_info($record, $currentModule);
    $smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
    $smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
}
$smarty->assign('ISSOURCEMODULE',$isSourceModule);
if($isduplicate == 'true') $focus->id = '';
// Identify this module as custom module.
$smarty->assign('CUSTOM_MODULE', true);

$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);
$smarty->assign('MODULE', $currentModule);
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule); 
$smarty->assign('CATEGORY', $category);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('THEME', $theme);
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);

$recordName = $focus->column_fields[$focus->list_link_field];
$smarty->assign('NAME', $recordName);


$validationArray =$focus->fieldobj->split_validationdataArray();
$smarty->assign('VALIDATION_DATA_FIELDNAME',$validationArray['fieldname']);
$smarty->assign('VALIDATION_DATA_FIELDDATATYPE',$validationArray['datatype']);
$smarty->assign('VALIDATION_DATA_FIELDLABEL',$validationArray['fieldlabel']);

$smarty->assign('CHECK', $tool_buttons);
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
    //crm_load_function_file('VT_detailViewNavigation','include/utils','DetailViewUtils');
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
/*
if (isPermitted('ProjectMilestone','Create','')=='yes'&&vtlib_isModuleActive('ProjectMilestone'))
{
    $smarty->assign("PROJECTMILESTONECREATE",'permitted');
}
if (isPermitted('ProjectTask','Create','')=='yes'&&vtlib_isModuleActive('ProjectTask'))
{
    $smarty->assign("PROJECTTASKCREATE",'permitted');
}*/

/***
更新操作
edit:cdw
date:20131216
reason:项目增加创建提醒
***/
if(isPermitted('Reminds','Create','')=='yes' && vtlib_isModuleActive('Reminds')){
    $smarty->assign("REMINDS",'permitted');
}
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign('SinglePane_View', $singlepane_view);

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign('DETAILVIEW_AJAX_EDIT', 1);
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

//if(isPermitted('Documents','Create','')=='yes' && vtlib_isModuleActive('Documents'))
//{
   // $DocumentsEditView='yes';
//}
$smarty->assign("POTENTIALID",$focus->column_fields['potential_id']);
$smarty->assign("SALESORDERID",$focus->column_fields['salesorder_id']);
$smarty->assign("DocumentsEditView",$DocumentsEditView);
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
/*if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
	$smarty->assign("CREATEATTACHMENT","permitted");
 if(isPermitted("ContactRecords","Create",'') == 'yes' && vtlib_isModuleActive('ContactRecords'))
	$smarty->assign("CREATECONTACTRECORDS","permitted");*/
//$smarty->display('DetailView.tpl');

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());


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
//$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));

include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
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

DetailViewReturn($currentModule,$focus,$smarty);
?>