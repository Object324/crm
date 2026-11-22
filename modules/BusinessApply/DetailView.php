<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule, $singlepane_view;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$focus = CRMEntity::getInstance($currentModule);
include ($root_directory.'modules/BusinessApply/BusinessApplyDetailFieldsHtml.php');
//$startapprove=$approve->startBlocksApprove();
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
    $focus->id = $_REQUEST['record'];
	 /**
	  * ticket_title 修改为 expense_no
	  * @author Tujt //ISSOURCEMODULE
	  */
	 $focus->name=$focus->column_fields[$focus->list_link_field];
    
   
}
$smarty = new lingdangCRM_Smarty;

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
/* 详情页按钮 end */
//$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
        $focus->id = "";
}

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign('ISSOURCEMODULE',$isSourceModule);
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", $currentModule);
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
//$smarty->assign("UPDATEINFO",updateInfo($_REQUEST['record']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

$smarty->assign("ID", vtlib_purify($_REQUEST['record']));

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

$tabid = getTabid($currentModule);
$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);


$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign("SinglePane_View", $singlepane_view);

if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$focus->mode = 'Details';
$smarty->assign('FORMATTOTAL',number_format($focus->column_fields['hdnGrandTotal'],2));
$BusinessApplyDetailFieldsHtml = new BusinessApplyDetailFieldsHtml($focus,$currentModule);
//echo $ExpenseDetailFieldsHtml->getTabDetailFieldsHtml();echo '<br><br>';
$smarty->assign('TREXPENSE',$BusinessApplyDetailFieldsHtml->getTabDetailFieldsHtml());
//$smarty->assign('TREXPENSE',$trExpense);    
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');

//联合技术MER特殊控制:根据费用类别控制显示隐藏列
$versioninfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$versioninfo['account']);
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));

//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewWidthTabDetail($currentModule,$focus,$smarty);

/*布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$smarty->display("DetailView/DetailRelated.tpl");*/
?>