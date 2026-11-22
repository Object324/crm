<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
 //zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
	$focus->retrieve_entity_info($_REQUEST['record'],"Vendors");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
	$focus->id = $_REQUEST['record'];
	$focus->name = $focus->column_fields['vendorname'];
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
	$focus->id = "";
}
global $theme,$currentModule,$singlepane_view;

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty;


/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

if(isset($focus->name))
	$smarty->assign("NAME", $focus->name);

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);


//if(isPermitted("Vendors","Delete",$_REQUEST['record']) == 'yes'){
	//$smarty->assign("DELETE","permitted");
    //$list_buttons_moreD['del'] = getFixedLabel('DELETE');
 //}


//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));


$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", 'Vendor');



$tabid = getTabid("Vendors");
$data =$fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'Create',$_REQUEST['record']));

/*更多信息
$isPresentRelatedListsArray = array();
$isPresentRelatedListsArray = isPresentRelatedLists($currentModule);
*/

$is_rel_list = array();
$is_rel_list = isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
if(get_callLinkDisplay() == 'no')
{
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $callrecordobj = new cls_CallRecord($currentModule);
    if($callrecordobj->getModuleCallRecordStatus() == 'no'){
        unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
    }
}

$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

//if(isPermitted("PurchaseOrder","Create",'') == 'yes'&&vtlib_isModuleActive('PurchaseOrder'))
    //$smarty->assign("CONVERTPURCHSEORDER","permitted");
//判读VendorContact权限
//if(isPermitted("VendorContact","Create",'') == 'yes'&&vtlib_isModuleActive('VendorContact'))
 //   $smarty->assign("CONVERTVENDORCONTACT","permitted");
    
//判读VendorContactRecords权限
//if(isPermitted("VendorContactRecords","Create",'') == 'yes'&&vtlib_isModuleActive('VendorContactRecords'))
 //   $smarty->assign("CONVERTVENDORCONTACTRECORDS","permitted");

//if(isPermitted('Reminds','Create',$_REQUEST['record'])=="yes"&&vtlib_isModuleActive('Reminds'))
//{
  //  $smarty->assign("RemindsEditView","permitted");
//}

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 //if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
//	$smarty->assign("CREATEATTACHMENT","permitted");

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
$smarty->assign('VENDORBUSINESS',1);
//zkt 20231024 BUG0073893 客户管理--工商查询功能应与角色的编辑权限挂钩，没有编辑权限应不显示工商查询按钮
if(isPermitted($currentModule,'EditView',$focus->id)=='yes') {
    //工商查询
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
    if($businessinformationobj->IsEnableBusiness()){
        $smarty->assign('VENDORBUSINESS',0);
    }
}
//工商查询列表
$deployarray=getSys_deploy(159);
$smarty->assign('VENDORLISTBUS',$deployarray['deploy_value']);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');

//diony 2014-10-15 弹屏新增时自动传值
if(isset($_REQUEST['callphone']) && $_REQUEST['callphone'] != '')
{
    $smarty->assign('CALLPHONE',$_REQUEST['callphone']);
}
if(isset($_REQUEST['callfilename']) && $_REQUEST['callfilename'] != '')
{
      $one_callfiles=explode('\\',$_REQUEST['callfilename']);
     $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
     $callfilenames=explode('_',$two_callfilename);
     $callphone=$callfilenames[0];
     $xinghao_phone= fieldValueUitype::setReportMobileStyle($callphone);
     for($i=0;$i<sizeof($one_callfiles)-1;$i++)
     {
        $filenames.=$one_callfiles[$i].'\\';
     }
    $one_filenames=$filenames.$xinghao_phone.'_'.$callfilenames[1];
    crm_load_class_file('cls_PhoneEncrypt','include');
    $obj=new cls_PhoneEncrypt();
 
    $two_filenames=$filenames.$obj->createToken_Phone($callphone).'_'.$callfilenames[1] ;

    $smarty->assign('CALLFILENAME',$one_filenames);
    $smarty->assign('ENCRYPT_FILENAME',$two_filenames);
    $smarty->assign('CALLFILENAME',$callbutlername);
	$smarty->assign('CALLTYPE',$_REQUEST['calltype']);
    $smarty->assign('CALLDISPLAY','yes');
    
    $callButlerRemarks = "";
    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlername);    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
    
    $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$callbutlernameNew' ";
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
    if($adb->num_rows($callbutlerGetResult))
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
        
        $sqlUpdate = "update ld_callbutler set vendorid = ?,description = ? where id = ? ";
        $updateResult=$adb->pquery($sqlUpdate,array($_REQUEST['record'],$callButlerRemarks,$callButlerID));
        
        
    }
    else
    {
        //不存在
        $sqlInsert = "insert into ld_callbutler 
        (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
         accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
        values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ";
        $callbutlername = str_replace("\\\\","\\",$callbutlername);        
        $insertresult=$adb->pquery($sqlInsert,array('','','接通',null,null,'',$callbutlername,$current_user->id,
        0,0,0,$_REQUEST['record'],0,0,0,$callButlerRemarks));
    }
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}

/*
 *bug 0015129
 *date 20150522
 *edit zyh
 */
$sql="
SELECT 
T1.tabid, 
GROUP_CONCAT(T2.columnname) as columnname
FROM 
( SELECT tabid,tabsequence FROM ld_tab WHERE presence = 0 AND NAME = 'Vendors') AS T1 
LEFT JOIN ( 
SELECT tabid, fieldid,columnname FROM ld_field WHERE uitype IN (11, 1101) AND presence <> 1 and callchecked=1 
) AS T2 ON T1.tabid = T2.tabid 
group by T1.tabid
order by T1.tabsequence";
$list_result = $adb->pquery($sql);
$num_rows=$adb->num_rows($list_result);
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $columnname = $adb->query_result($list_result,$i,'columnname');
    }
}
$smarty->assign("PhoneSteward", $columnname);

//加载审批历史
$smarty->assign('APPROVEMOD','1');
//审批状态图片
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
//$smarty->display("Inventory/InventoryDetailView.tpl");
///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
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
//$smarty->display("DetailView/InventoryDetailRelated.tpl");
?>