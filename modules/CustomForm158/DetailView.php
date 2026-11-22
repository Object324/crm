<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');


global $currentModule;
global $theme;
$focus = CRMEntity::getInstance($currentModule);
$fieldObj=$focus->fieldobj;
$moduleFields=$fieldObj->getModuleFields();

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}
if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
        

        $focus->id=$_REQUEST['record'];
        $focus->retrieve_entity_info($_REQUEST['record'],'CustomForm158');
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
        

}

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;


/* 详情页按按钮begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
//$smarty->assign("UPDATEINFO",updateInfo($focus->id));

if(useInternalMailer() == 1) 
	$smarty->assign("INT_MAILER","true");


global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));

$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", 'CustomForm158');

$smarty->assign("ID", $_REQUEST['record']);

//Security check for related list
$category = getParentTab();
$smarty->assign("CATEGORY",$category);



$tabid = getTabid("CustomForm158");

$data = $fieldObj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$smarty->assign("MODULE",$currentModule);

//更多信息
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));

//$sql = $adb->pquery('select accountid from ld_contactdetails where contactid=?', array($focus->id));
//$accountid = $adb->query_result($sql,0,'accountid');
//if($accountid == 0) $accountid='';
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);

//快捷链接操作时用到的变量
//$smarty->assign("TODO_PERMISSION",CheckFieldPermission('parent_id','Calendar'));
//$smarty->assign("CONTACT_PERMISSION",CheckFieldPermission('contact_id','Calendar'));
//if(isPermitted("Calendar","Create",'') == 'yes' && vtlib_isModuleActive('Calendar'))
 //   $smarty->assign("EVENT_PERMISSION",CheckFieldPermission('parent_id','Events'));
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));


$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
//$sql_con="SELECT presence from ld_field where tabid=4 and columnname='parentid'";
//$sql_res = $adb->query($sql_con);
//$forshow=$adb->query_result($sql_res,0,presence);


$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
////andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
    
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
$smarty->assign("HAVEMODCOMMENTS",'no');
setGLobalURLSmarty($smarty);

$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);

//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));
//
//$smarty->display("DetailView/DetailRelated.tpl");
?>