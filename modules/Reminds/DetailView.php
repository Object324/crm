<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $mod_strings;
global $app_strings;
global $app_list_strings;
global  $currentModule, $singlepane_view;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Reminds");
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
    

}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty;

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

global $detail_column_fields_value;
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

$smarty->assign("BLOCKS", getBlocks($currentModule,"detail_view",'',$focus->column_fields));

$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'Reminds');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

if(useInternalMailer() == 1)
        $smarty->assign("INT_MAILER","true");


//if(isPermitted("Accounts","Create",$_REQUEST['record']) == 'yes')
	$smarty->assign("EDIT_DUPLICATE","permitted");

	$smarty->assign("DELETE","permitted");

$tabid = getTabid("Reminds");

$data = $fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'Create',$_REQUEST['record']));

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign("SinglePane_View", $singlepane_view);

// Record Change Notification
$focus->markAsViewed($current_user->id);
// END

//include_once('vtlib/lingdang/Link.php');
//$customlink_params = Array('MODULE'=>$currentModule, 'RECORD'=>$focus->id, 'ACTION'=>vtlib_purify($_REQUEST['action']));

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));





/* 关联创建 begin */
$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
 include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');   
setGLobalURLSmarty($smarty);//设置js,css等访问路径
DetailViewReturn($currentModule,$focus,$smarty);
//$smarty->display("DetailView/DetailRelated.tpl");
?>