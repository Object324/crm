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
        $focus->retrieve_entity_info($_REQUEST['record'],'CustomForm10');
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
        

}

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;


/* 璇︽儏椤垫寜閽?begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 璇︽儏椤垫寜閽?end */

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
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", 'CustomForm10');

$smarty->assign("ID", $_REQUEST['record']);

//Security check for related list
$category = getParentTab();
$smarty->assign("CATEGORY",$category);



$tabid = getTabid("CustomForm10");

$data = $fieldObj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$smarty->assign("MODULE",$currentModule);

//鏇村淇℃伅
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));

//$sql = $adb->pquery('select accountid from ld_contactdetails where contactid=?', array($focus->id));
//$accountid = $adb->query_result($sql,0,'accountid');
//if($accountid == 0) $accountid='';
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);

//蹇嵎閾炬帴鎿嶄綔鏃剁敤鍒扮殑鍙橀噺
//$smarty->assign("TODO_PERMISSION",CheckFieldPermission('parent_id','Calendar'));
//$smarty->assign("CONTACT_PERMISSION",CheckFieldPermission('contact_id','Calendar'));
//if(isPermitted("Calendar","Create",'') == 'yes' && vtlib_isModuleActive('Calendar'))
 //   $smarty->assign("EVENT_PERMISSION",CheckFieldPermission('parent_id','Events'));
//瀹℃壒涓績涓婁竴鏉″拰涓嬩竴鏉?
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));


$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
//$sql_con="SELECT presence from ld_field where tabid=4 and columnname='parentid'";
//$sql_res = $adb->query($sql_con);
//$forshow=$adb->query_result($sql_res,0,presence);


$smarty->assign('APPROVEMOD','1');//瀹℃壒妯″潡锛屾槸鍚﹀姞杞藉鎵瑰巻鍙?
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//瀹℃壒鐘舵�佸浘鐗?

/* 鍏宠仈鍒涘缓 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 鍏宠仈鍒涘缓 end */
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

///淇濆瓨鍒ゆ柇
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
$smarty->assign("HAVEMODCOMMENTS",'no');//自定义表单不需要评论
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);
//布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//
//$smarty->display("DetailView/DetailRelated.tpl");
?>