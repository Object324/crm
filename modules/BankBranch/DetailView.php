<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $mod_strings, $app_strings, $currentModule, $current_user, $theme, $singlepane_view;
$smarty = new lingdangCRM_Smarty();
$focus = CRMEntity::getInstance($currentModule);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"BankBranch");
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];  
}
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
//$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */
//审批流程按钮传值begin
$smarty->assign('ISSUBMIT',$issubmit);
//$smarty->assign('ISAPPROVE',$isapprove);
$smarty->assign('ISCANCEL',$iscancel);
//$smarty->assign('APPROVE',$approvelog);
//$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETE',$isdelete);
//审批流程按钮传值end
//审批过程中小编辑控制
//$smarty->assign("EDITSTATUS","yes");
//if($isedit != 0)
//{
//    $smarty->assign("EDITSTATUS","no");
//}
$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$tabid = getTabid($currentModule);
$category = getParentTab($currentModule);

if($record != '') {
	$focus->id = $record;
	$focus->retrieve_entity_info($record, $currentModule);
}
if($isduplicate == 'true') $focus->id = '';
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
if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
  //  crm_load_function_file('VT_detailViewNavigation','include/utils','DetailViewUtils');
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign('IS_REL_LIST', $is_rel_list);
$smarty->assign('SinglePane_View', $singlepane_view);
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

if(isPermitted('Documents','Create','')=='yes' && vtlib_isModuleActive('Documents'))
{
    $DocumentsEditView='yes';
}
$smarty->assign("DocumentsEditView",$DocumentsEditView);
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
 //if(isPermitted("ContactRecords","Create",'') == 'yes' && vtlib_isModuleActive('ContactRecords'))
//	$smarty->assign("CREATECONTACTRECORDS","permitted");
    /* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);

/*布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',$fieldruleobj->getAllFieldNameSetChangeEvent());//获取所有的触发字段

$smarty->display("DetailView/DetailRelated.tpl");*/

?>