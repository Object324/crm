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

//require_once('Smarty_setup.php');
//require_once('include/utils/utils.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$theme,$currentModule;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty();
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends

if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($_REQUEST['record'],"Vendors");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
	$focus->name = $focus->column_fields['vendorname'];
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$focus->id = "";
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$disp_view = getView($focus->mode);

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['vendor_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
$global_pick_list_values;
$act_data=getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);
 /**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:添加富文本框
 * */
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','0');
}
$smarty->assign("BLOCKS",$act_data);

$smarty->assign("OP_MODE",$disp_view);

$smarty->assign("MODULE",$currentModule);
$smarty->assign("SINGLE_MOD",'Vendor');


$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign("ID", $focus->id);
if(isset($focus->name))
        $smarty->assign("NAME", $focus->name);

if(isset($cust_fld))
{
        $smarty->assign("CUSTOMFIELD", $cust_fld);
}
/*
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));*/
if($focus->mode == 'edit')
{
	//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
        $smarty->assign("MODE", $focus->mode);
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if(isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if(isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

$tabid = getTabid("Vendors");

$data = $fieldobj->split_validationdataArray();
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

global $adb;
//// Module Sequence Numbering
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList'); 
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);


// Gather the help information associated with fields
//$smarty->assign('FIELDHELPINFO', vtlib_getFieldHelpInfo($currentModule));
// END

//$smarty->display('Inventory/InventoryEditView.tpl');
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-10
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$is_rel_list = array();
$is_rel_list = isPresentRelatedLists($relmodule);
if(get_callLinkDisplay() == 'no'){
    	unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
}
$smarty->assign("IS_REL_LIST",$is_rel_list);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes') ||$_REQUEST['isDuplicate']=='true'))
{
  
    $smarty->assign('CREATE','true');
}
else
{
  
     $smarty->assign('CREATE','false');
}

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
//工商查询
crm_load_class_file('cls_BusinessInformation', 'modules/Users');
$businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
$smarty->assign('VENDORBUSINESS',1);
if($businessinformationobj->IsEnableBusiness()){
    $smarty->assign('VENDORBUSINESS',0);
}
//工商查询列表
$smarty->assign('VENDORLISTBUS',1);
if($businessinformationobj->IsEnableBusinessfuzzyquery()){
    $smarty->assign('VENDORLISTBUS',0);
}


//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
    /*if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
                $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
            if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
                $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));*/
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
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
$qcreate_array=$focus->fieldobj->QuickCreate();
$smarty->assign("QUICKCREATE", $qcreate_array['form']);
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
if($_REQUEST['callfilename1111']||$_REQUEST['callphone1111'])
{
    $smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
    $smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
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
            $weixin_user->environment='pc';
            $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
        }
    }
    else{
        $weixin_user->action='default_on_new';
        $weixin_user->environment='pc';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

    }
    $smarty->assign("APPROVE_ARR",$approve_arr);

    if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
    {
        $quickcreatestr="##noquickdata##";
    }
    else
        $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
    $data = $focus->fieldobj->split_validationdataArray();
    $fields=$focus->fieldobj->getFieldListArray();
    $str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
    $_REQUEST['diony']='diony';
    if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
        require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
        $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
    } else {
        $arr['title'] = getTranstab($currentModule);
    }
    $arr['approve_arr']=$approve_arr;
    $arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
    //zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
    $settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
    $is_page_setting = "no";
    if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
        $is_page_setting = "yes";
    }
    $arr['is_page_setting'] = $is_page_setting;
    $arr['mainfieldformula']=$focus->fieldobj->getFormula();
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
    $arr['picklistcontent']=$global_pick_list_values;
    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
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