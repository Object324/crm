<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
if(!isset($modObj))
{
    $focus = CRMEntity::getInstance($currentModule);
    $focus->id = $_REQUEST['record'];
    $crmid=$focus->id;
}
else 
{
    $focus=$modObj;
}

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
   
    $focus->retrieve_entity_info($crmid,"SendPayment");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
	 /**
	  * ticket_title -> sendpayment_no
	  * name值为空，修改key键
	  * @reason 0008434
	  * @author Tujt 2014-04-17
	  */
    $focus->name=$focus->column_fields[$focus->list_link_field];
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
        $focus->id = "";
}



global $currentModule, $singlepane_view;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);

//源单
$sourceModuleInfo = $focus->getSourceField($focus->id);
$isSourceModule = $sourceModuleInfo['module'];
$smarty->assign('LASTVALINFO',getDetailListValName($_REQUEST['record'],$isSourceModule,1));

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("TICKETID", $crmid);
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", 'SendPayment');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);


$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);



$smarty->assign("ID", $crmid);
//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

$tabid = getTabid("SendPayment");

$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//end

$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$crmid));
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign("SinglePane_View", $singlepane_view);

// Record Change Notification
$focus->markAsViewed($current_user->id);

if(!isset($modObj))
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 $sqlpaymentplan="select 1 from ld_sendpayment where  
                            (cpstatus='部分已付' or cpstatus='已付') 
                            and sendpaymentid=".$crmid;
 $smarty->assign("EDITSTATUS","yes");
$smarty->assign("MERGEBUTTON",'permitted');
if( vtlib_isModuleActive('SendCashBill')&&isPermitted('SendCashBill','Create','')=='yes')
    $smarty->assign("SENDCAHSBILLCREATE",isPermitted("SendCashBill","Create",""));
if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
	$smarty->assign("CREATEATTACHMENT","permitted");
//if( $check_button['moduleSettings'] == 'yes'){
    //$list_buttons_moreD['moduleSettings'] = getFixedLabel('LBL_PAGE_SET');
//}
    
$smarty->assign('SENDCASHBILLMODULE','SendCashBill');
$tabid = getTabid("SendPayment");

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');

//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
    $smarty->assign("SEARCHSCOPE",$_SESSION['lvs'][$currentModule]['SearchScope']);
} 
 $result=$adb->pquery($sqlpaymentplan,array());
 if($adb->num_rows($result)>0)
 {
        $smarty->assign("EDITSTATUS","no");
        if(isset($modObj))
        {
            echo "####::##error";
        }
 }
 else 
 {
     if(isset($modObj))
        {
            echo "####::##success";
        }
 }
 
 $smarty->assign('VENDOR_ID',$focus->column_fields['vendor_id']);
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
*/
if(!isset($modObj))
{
    //$smarty->display("DetailView.tpl");
	// $smarty->display("DetailView/DetailRelated.tpl");
    DetailViewReturn($currentModule,$focus,$smarty);
}
else 
{
    //$smarty->display("DetailTable.tpl");
	 $smarty->display("DetailView/DetailTable.tpl");
}
?>