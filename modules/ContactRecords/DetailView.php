<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


global $app_list_strings;
global  $currentModule, $singlepane_view;

$focus = CRMEntity::getInstance($currentModule);

/*
 * edit:yangliu
 * date:2014-07-28
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings); 

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"ContactRecords");
     $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
    }
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
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
global $detail_column_fields_value;
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);


$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);

//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'ContactRecords');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

if(useInternalMailer() == 1)
        $smarty->assign("INT_MAILER","true");


$tabid = getTabid("ContactRecords");
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);

$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));
//
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}

//更多信息
$is_rel_list = array();
$is_rel_list = isPresentRelatedLists($currentModule);

if(get_callLinkDisplay() == 'no'){
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $callrecordobj = new cls_CallRecord($currentModule);
    if($callrecordobj->getModuleCallRecordStatus() == 'no'){
        unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
    }
}
$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));


$smarty->assign("SinglePane_View", $singlepane_view);

// Record Change Notification
$focus->markAsViewed($current_user->id);
// END
if(isPermitted('Documents','Create','')=='yes' && vtlib_isModuleActive('Documents'))
{
$DocumentsEditView='yes';
}
$smarty->assign("DocumentsEditView",$DocumentsEditView);
//include_once('vtlib/lingdang/Link.php');
//$customlink_params = Array('MODULE'=>$currentModule, 'RECORD'=>$focus->id, 'ACTION'=>vtlib_purify($_REQUEST['action']));

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));


$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
/*审批结束*/
 if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
	$smarty->assign("CREATEATTACHMENT","permitted");

if(isPermitted("Reminds","Create",'')=='yes'&& vtlib_isModuleActive('Reminds'))
    $smarty->assign('REMINDSACTION','permitted');
    

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());

//获取客户和联系人区块信息
//$block_info = getBlockDisplayInfo('AccountContacts');
//
//$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
// 
//if($block_info['is_display'] == 0)
//    $smarty->assign('BESTATUS','YES');
//else
//    $smarty->assign('BESTATUS','NO');

$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);

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
        
        $sqlUpdate = "update ld_callbutler set contactrecordsid = ?,description = ? where id = ? ";
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
        0,0,0,0,0,$_REQUEST['record'],0,$callButlerRemarks));
    }
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}

crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
//$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
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
/*
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

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