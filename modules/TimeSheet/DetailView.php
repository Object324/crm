<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule, $singlepane_view;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$focus = CRMEntity::getInstance($currentModule);
include ($root_directory.'modules/TimeSheet/TimeSheetDetailFieldsHtml.php');
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);

    $focus->id = $_REQUEST['record'];
}
$smarty = new lingdangCRM_Smarty;

/* ����ҳ��ť begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//����״̬ͼƬ
$smarty->assign('APPROVEMOD','1');//����ģ�飬�Ƿ����������ʷ
/* ����ҳ��ť end */
//$smarty->assign('APPROVEMOD','1');//����ģ�飬�Ƿ����������ʷ
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
        $focus->id = "";
}

//editor:gyqX160802 Bug:0023871: 工时-查看明细界面：结果左边相关信息上面没有显示工时编号
//if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
if (isset($focus->column_fields[$focus->list_link_field]))
    $smarty->assign("NAME", $focus->column_fields[$focus->list_link_field]);
else $smarty->assign("NAME", "");

global $detail_column_fields_value;
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
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
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

$smarty->assign("SinglePane_View", $singlepane_view);

if(!$isedit)
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$focus->mode = 'Details';
$smarty->assign('MODE',$focus->mode);
$smarty->assign('FORMATTOTAL',number_format($focus->column_fields['hdnGrandTotal']??0,2));
$TimeSheetDetailFieldsHtml = new TimeSheetDetailFieldsHtml($focus,$currentModule);
//echo $ExpenseDetailFieldsHtml->getTabDetailFieldsHtml();echo '<br><br>';
$smarty->assign('TREXPENSE',$TimeSheetDetailFieldsHtml->getTabDetailFieldsHtml());
//$smarty->assign('TREXPENSE',$trExpense);    
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
//if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");

/* �������� begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* �������� end */
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
//$smarty->display("DetailView/DetailRelated.tpl");
DetailViewWidthTabDetail($currentModule,$focus,$smarty);
?>