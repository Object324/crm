<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule, $current_user;
$deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
if($deployarray['deploy_value']==0)
{
    include(globalStatic::$root_directory.'modules/Potentials/ProductDetailView.php');
    exit();
}
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings); 

if(isset($_REQUEST['record'])  && $_REQUEST['record']!='') {
    $focus->retrieve_entity_info($_REQUEST['record'],"Potentials");
     $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $sql = "select lastmodified,sales_stage,smownerid from ld_potstagehistory where potentialid = ? order by historyid desc";
    $result = $adb->pquery($sql,array($focus->id));
    $num_rows = $adb->num_rows($result);
    for($i = 0; $i<$num_rows;$i++){
        $potenialsArr[$i] = array(
            'lastmodified' => $adb->query_result($result,$i,'lastmodified'),
            'sales_stage' => $adb->query_result($result,$i,'sales_stage'),
            'smownerid' => getOwnerName($adb->query_result($result,$i,'smownerid'))
        );
    }
    $smarty->assign('POTENIALSARR',$potenialsArr);
    $smarty->assign('NUMROWS',$num_rows);
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);


//$smarty->assign("ACCOUNTID",)
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";




$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);


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
$smarty->assign("CUSTOMFIELD", $cust_fld);
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("SINGLE_MOD", 'Opportunity');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

$tabid = getTabid("Potentials");
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
       
$smarty->assign("CONVERTMODE",'potentoinvoice');

$smarty->assign("MODULE","Potentials");
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);

if(get_callLinkDisplay() == 'no')
{
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $callrecordobj = new cls_CallRecord($currentModule);
    if($callrecordobj->getModuleCallRecordStatus() == 'no'){
        unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
    }
}

$smarty->assign("IS_REL_LIST",$is_rel_list);
$VersionInfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);

//$smarty->assign("TODO_PERMISSION",CheckFieldPermission('parent_id','Calendar'));
//$smarty->assign("EVENT_PERMISSION",CheckFieldPermission('parent_id','Events'));

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}


/**
 * edit:andy
 * reason:Potentials增加审批流程
 * data:20140414
 */

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Potentials");
    $focus->id = $_REQUEST['record'];
}



$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");
    
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
//

if(isset($_REQUEST['salestype']) &&$_REQUEST['salestype']=='yes' &&!isset($_REQUEST['autocreate']) )
{
    
    $smarty->assign("CREATE","yes");
}
/*
if(isPermitted("Potentials","Create","")== 'yes')
{
 
    $smarty->assign("POTENTIALSCREATE","permitted");
    
}*/


//获取客户和联系人区块信息
//$block_info = getBlockDisplayInfo('AccountContacts');
////显示位置
//$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
// //是否显示
//if($block_info['is_display'] == 0)
//    $smarty->assign('BESTATUS','YES');
//else
//    $smarty->assign('BESTATUS','NO');
//global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',getSession($currentModule.'_modulebillnotip'));
setSession($currentModule.'_modulebillnotip','no');


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturn($currentModule,$focus,$smarty);

/*
 //布局规则
 crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
 $fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();////获取所有的触发字段
//$arr['datetimestr']=CommonView::stdFilterDateTimeStr();
$arr['picklistcontent']=$global_pick_list_values;
$arr['validatasave']=getValidataSave($currentModule);
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['picklistdepency']=$picklistDependencyDatasource;
$arr['column_fields_value']=$detail_column_fields_value;
$arr['fields']=$fields['fields'];
$arr['title']=getTranstab($currentModule);
$arr['list_link_field']=$focus->list_link_field;
//$arr['oktext']=getFixedLabel("SAVE");
//$arr['canceltext']=getFixedLabel("CANCEL");
$content=$smarty->fetch("DetailView/PopupDetailRelated.tpl");
$arr['content']=$content;
ConvertTojsonString(1,$arr,'success');*/

?>