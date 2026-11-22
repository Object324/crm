<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once 'modules/lingdang/EditView.php';
//require_once('modules/Approve/Approve.php');
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//$approve=new Approve();
$approve = Approve::getInstance($currentModule);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
    exit();
}

if(isset($_REQUEST['product_id'])&&$_REQUEST['product_id']>0) {
	$smarty->assign("PRODUCTID", vtlib_purify($_REQUEST['product_id']));
    //18625: 工具>产品明细界面：点开一条单据，在产品相关信息栏，创建"客户服务单"，新建，保存后，打开产品明细界面，相关信息栏没有关联记录
    $smarty->assign("RETURN_ID",vtlib_purify($_REQUEST['product_id']));
    $smarty->assign("RETURN_MODULE",'Products');
}

if($_REQUEST['record'] != '') {
    $focus->mode = 'edit';
	//Added to display the ticket comments information
    //bug:0023887 edit:cyb date:2016-08-12
	//$smarty->assign("COMMENT_BLOCK",$focus->getCommentInformation($_REQUEST['record']));
}
if($focus->mode == 'edit') {
	$smarty->assign("OLDSMOWNERID", $focus->column_fields['assigned_user_id']);
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$focus->mode = '';
     $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
    $smarty->assign("SALESORDERID", $focus->column_fields['salesorder_id']);
}
else if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') 
{
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
    $smarty->assign("SALESORDERID", $focus->column_fields['salesorder_id']);
    $focus->mode='edit';
   
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
$smarty->assign('ISADMIN',$current_user->is_admin);
$helpdesk_log=$focus->getHelpDesk_Log();
$smarty->assign('HELPDESKLOG',$helpdesk_log);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
//$smarty->display("salesEditView.tpl");
//模块的级联字段信息
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
/*
*edit:diony
*time:20140909
*reason:呼叫弹屏
**/
if (isset($_REQUEST['accountscallid']) && $_REQUEST['accountscallid'] != '') {
    $accountid = $_REQUEST['accountscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select accountid,accountname from ld_account where accountid=?", array($accountid));
	$accountname = $adb->query_result($result, 0, 'accountname');
    $smarty->assign("ACCOUNTID", $accountid);
    $smarty->assign("ACCOUNTNAME", $accountname);
}
if (isset($_REQUEST['contactscallid']) && $_REQUEST['contactscallid'] != '') {
    $contactsid = $_REQUEST['contactscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select T1.accountid,accountname,T1.contactid,lastname from ld_contactdetails as T1 
    left join ld_account as T2 on T1.accountid = T2.accountid
    where T1.contactid = ?", array($contactsid));
	$accountid = $adb->query_result($result, 0, 'accountid');
    $accountname = $adb->query_result($result, 0, 'accountname');
    $lastname = $adb->query_result($result, 0, 'lastname');
    $smarty->assign("ACCOUNTID", $accountid);
    $smarty->assign("ACCOUNTNAME", $accountname);
    $smarty->assign("CONTACTID", $contactsid);
    $smarty->assign("LASTNAME", $lastname);
}
if(isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0)
{
    $smarty->assign("ACCOUNTID", $_REQUEST['account_id']);
}
if(isset($_REQUEST['contact_id']) && $_REQUEST['contact_id'] > 0)
{
    $smarty->assign("CONTACTID", $_REQUEST['contact_id']);
}
$smarty->assign('MODE',$focus->mode);
/**
 * 编辑、新增页面，增加更多信息左边栏
 * @author Tujt 2014-04-09
 */
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));

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
	$smarty->assign('CALLTYPE',$_REQUEST['calltype']);
    $smarty->assign('CALLDISPLAY','yes');
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}

/* editor:gyq_11 reason:九维呼叫通话记录id date:20160603*/
if(!empty($_REQUEST['jiuweiid'])){
    $smarty->assign('JiuWeiAccount',$_REQUEST['jiuweiid']);
    $smarty->assign('CALLCENTERSWITCH',$_REQUEST['callcenter_switch']);
}
$fromuitype=array();
$arr['tablerelfields']="";
if($_REQUEST['frommodule']&&$_REQUEST['fromid']>0)
{
    $fromuitype=cls_module_uitype::getModuleUitype("HelpDesk",$_REQUEST['frommodule']);
    if(empty($fromuitype))
    {
        $arr['tablerelfields']=array('module'=>$_REQUEST['frommodule'],'fromid'=>$_REQUEST['fromid']);
    }
}
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$trades=getVersionTradeInfo();
$fields['trade']=$trades['trade'];
if($_REQUEST['callfilename11111']||$_REQUEST['callphone111'])
{
    $smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
    $smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
    
    $smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
    $smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
     //布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
     
     
    $smarty->display("DetailView/EditRelated.tpl");
    
}
else
{
    //新增、编辑单据可直接保存并提交审批
    $approveobj=Approve::getInstance($currentModule);
    $approve_arr=[];
    global $weixin_user;
    if($focus->id>0)
    {
        if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
        {
            //审批状态字段隐藏
            $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
            $result=$adb->pquery($sql,array($focus->id));
            $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

        }
        $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
        if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
        {
            $weixin_user->action='default_on_submit';
            $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
        }
    }
    else{
        $weixin_user->action='default_on_new';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

    }
    $smarty->assign("APPROVE_ARR",$approve_arr);

    if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
    {
        $quickcreatestr="##noquickdata##";
    }
    else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
    
    $str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
    $_REQUEST['diony']='diony';
    if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
        require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
        $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
    } else {
        $arr['title'] = getTranstab($currentModule);
    }
    $arr['approve_arr']=$approve_arr;
    //zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
    $settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
    $is_page_setting = "no";
    if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
        $is_page_setting = "yes";
    }
    $arr['is_page_setting'] = $is_page_setting;
    $arr['mainfieldformula']=$focus->fieldobj->getFormula();
    $arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']=$quickcreatestr;
    $arr['allcontent']=$str;
    $arr['fieldname']=$data['fieldname'];
    $arr['datatype']=$data['datatype'];
    $arr['fieldlabel']=$data['fieldlabel'];
    $arr['fields']=$fields['fields'];
    $arr['filejsondata']=$fieldjsondata;
    $arr['isadmin']=$current_user->is_admin;
    $arr['columnfields_value']=$focus->column_fields;
    $arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
    $arr['picklistcontent']=$global_pick_list_values;
    $arr['helpdesk_log']=$helpdesk_log;
	$arr['isduplicate'] = getTabDuplicate($currentModule);
    ///保存判断
    $arr["validatasave"]=getValidataSave($currentModule);
    $arr["validatasaverule"]=getAllRule($currentModule);
    //布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
      
    ConvertTojsonString(1,$arr,"success");
}
?>