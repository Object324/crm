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
require_once globalStatic::$root_directory.'weixinmp/include/cls_MP_CommonFun.php';
$smarty=new lingdangCRM_Smarty();

$focus = CRMEntity::getInstance($currentModule);
global $current_user;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) 
{
    $focus->retrieve_entity_info($_REQUEST['record'],"HelpDesk");
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

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史

//include('user_privileges/user_language_'.$current_user->id.'.php');
//if(isset($focus->logic->approvebtn['info'])){//有审批
	//$approvestatus = $focus->logic->approvebtn['info']['approvestatus'];
	//if(empty($approvestatus)) $approvestatus = 0;
	//if($languageType=='en'){
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'_en.png');
	//}else{
		//$smarty->assign('APPROVESTATUS','approveresult'.$approvestatus.'.png');
	//}
//}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
        $focus->id = "";
}

//Added code for Error display in sending mail to assigned to user when ticket is created or updated.
if($_REQUEST['mail_error'] != '')
{
    require_once("modules/Emails/mail.php");
	$ticket_owner = getUserFullName($focus->column_fields['assigned_user_id']);
    $error_msg = strip_tags(parseEmailErrorString($_REQUEST['mail_error']));
	$error_msg = getFixedLabel('EMAILCANOTSENDUSER'). ' ' . $ticket_owner. '. ' .getFixedLabel('PLEASECHECKSERVERSETTINGS');
	echo getFixedLabel('SENDEMAILSTATES').' <b><font class="warning">'.$error_msg.'</font></b>';
}

global $currentModule, $singlepane_view;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";




if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
//是否显示服务显示
$smarty->assign('SELECTSERVICEDETAIL',$current_user->select_servicedetail);
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//
$smarty->assign("TICKETID", vtlib_purify($_REQUEST['record']));
$smarty->assign('HELPDESKLOG',$focus->getHelpDesk_Log());
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("SINGLE_MOD", 'HelpDesk');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

if(isPermitted("Faq","Create",'') == 'yes'&& vtlib_isModuleActive('Faq'))
	$smarty->assign("CONVERTASFAQ","permitted");
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

$fieldobj=Field::getInstance($currentModule,$adb);
$mod_seq_field = $fieldobj->FieldInfoListByKeyValue('uitype',4);

if ($mod_seq_field != null) {
	$mod_seq_id = $focus->column_fields[$mod_seq_field['name']];
} else {
	$mod_seq_id = $focus->id;
}
$smarty->assign('MOD_SEQ_ID', $mod_seq_id);
// END

$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);

$tabid = getTabid("HelpDesk");

$data =$fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//Added to display the ticket comments information
//$smarty->assign("COMMENT_BLOCK",$focus->getCommentInformation($_REQUEST['record']));

$smarty->assign("MODULE",$currentModule);

//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

//print_r($isPresentRelatedListsNewArray);


//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//获取客户和联系人区块信息


if(isset($_REQUEST['record']) && $_REQUEST['record'] != ''){
    $salesorderid=$focus->column_fields['salesorder_id'];
    $accountid= $focus->column_fields['account_id'];
    $contactid= $focus->column_fields['contact_id'];
    $BeModuleFields = getTabid('Accounts') .',' . $accountid . '|' . getTabid('Contacts') .',' . $contactid;
    $smarty->assign('BEMODULEFIELDS',$BeModuleFields);
    if($accountid != ""){
        $smarty->assign('ACCOUNTID',$accountid);
    }
    if($contactid != ""){
        $smarty->assign('CONTACTID',$contactid);
    }
    if($salesorderid != ""){
        $smarty->assign('SALESORDERID',$salesorderid);
    }
}
$smarty->assign("SinglePane_View", $singlepane_view);

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
 if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
	$smarty->assign("CREATEATTACHMENT","permitted");

 if(isPermitted("ContactRecords","Create",'') == 'yes' && vtlib_isModuleActive('ContactRecords'))
	$smarty->assign("CREATECONTACTRECORDS","permitted");
//$smarty->display("DetailView.tpl");
/**
 * 增加更多信息左边栏
 * @author Tujt 2014-04-09
 */
 
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

 //andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
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
    $smarty->assign('CALLDISPLAY','yes');
    
    $callButlerRemarks = "";
    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlername);    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
    
    $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$two_callfilename' ";
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
    if($adb->num_rows($callbutlerGetResult))
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');        
        
        $sqlUpdate = "update ld_callbutler set ticketid = ?,description = ? where id = ? ";
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
        $insertresult=$adb->pquery($sqlInsert,array('','','接通',null,null,'',$one_filenames,$current_user->id,
        $_REQUEST['record'],0,0,0,0,0,0,$callButlerRemarks));
    }
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}

/**
 * edit:yangliu
 * date:2015-01-16
 * reason:短信账户是否设置
 */
$SMSarray = GetSMSAutograph();
$smsName = $SMSarray['account_name'];//账号
if($smsName == ""){
    $smarty->assign('SMS_ISSET','NO');
}else{
    $smarty->assign('SMS_ISSET','YES');
}
if(isset($_REQUEST['sendtype'])) {
    $sendtype = $_REQUEST['sendtype'];
    $smarty->assign('SENDTYPE',$sendtype);
}
//客户服务单分配时是否发送短信或邮件通知客户首要联系人
$deployarray=getSys_deploy(167);
$smarty->assign('IS_SEND',$deployarray['deploy_value']);
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//editor:gyq_123 reason:判断是否有服务小程序权限,且已配置  2019/6/18 14:12 ID1000512
if(cls_MP_CommonFun::check_self_help_reg('service')){
    $smarty->assign("COMMUNICATE",1);
}
//$smarty->assign("COMMUNICATE",1);
//editor:gyq_127 reason:服务小程序增加评价  2019/6/26 11:46
if(cls_MP_CommonFun::check_evaluate()){
    $smarty->assign("EVALUATE",1);
}
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