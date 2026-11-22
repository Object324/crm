<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');

global $mod_strings;
global $app_strings;
global $currentModule;
global $theme,$adb;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;

$recordid = isset($_REQUEST['record'])?$_REQUEST['record']:'';
if(!empty($recordid)){
    //进详情更新阅读状态
    if (method_exists($focus, 'updatePublicAnnouncementStatus')){
        $focus->updatePublicAnnouncementStatus($recordid,$current_user->id);
    }
}
/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings); 

if(isset($_REQUEST['record']) && $_REQUEST['record']!='') {
        //Display the error message
        if($_SESSION['image_type_error'] != '')
        {
                echo '<font color="red">'.$_SESSION['image_type_error'].'</font>';
                session_unregister('image_type_error');
        }

        $focus->id=$_REQUEST['record'];
        $focus->retrieve_entity_info($_REQUEST['record'],'PublicAnnouncement');
	
	$focus->firstname=$focus->column_fields['firstname'];
        $focus->lastname=$focus->column_fields['lastname'];
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;


/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
//$smarty->assign("UPDATEINFO",updateInfo($focus->id));

$smarty->assign("NAME",$focus->column_fields['subject']);

global $detail_column_fields_value;
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$smarty->assign("BLOCKS", getBlocks($currentModule,"detail_view",'',$focus->column_fields));


$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));


$smarty->assign("ID", $_REQUEST['record']);



//Security check for related list
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);
//

$tabid = getTabid("PublicAnnouncement");

$data = $fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

/**
 * 之前没有上一页下一页的代码，现在加上
 * @reason 0013843: 公告--明细：上一条、下一条按钮失效。
 * @author Tujt 2015-03-04
 */
/*上一条和下一条数据信息*/
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign("DocumentsEditView",$DocumentsEditView);

//include_once('vtlib/lingdang/Link.php');
//$customlink_params = Array('MODULE'=>$currentModule, 'RECORD'=>$focus->id, 'ACTION'=>vtlib_purify($_REQUEST['action']));

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));


/**
 * 增加更多信息左边栏
 * @author Tujt 2014-04-09
 */
//$smarty->display("DetailView.tpl");

//andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
//include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
//$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
//setGLobalURLSmarty($smarty);//设置js,css等访问路径
//$smarty->display("DetailView/DetailRelated.tpl");
DetailViewReturn($currentModule,$focus,$smarty);
?>