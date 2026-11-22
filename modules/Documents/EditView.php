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

//require_once('Smarty_setup.php');
//require_once('data/Tracker.php');
//require_once('include/utils/utils.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_list_strings,$theme,$currentModule;

$module = vtlib_purify($_REQUEST['module']);
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty();

//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);


$smarty->assign("UPLOADSIZE", $upload_maxsize/1000000); //Convert to MB
$smarty->assign("UPLOAD_MAXSIZE",$upload_maxsize);
if($_REQUEST['upload_error'] == true)
{
	echo '<br><b><font color="red"> '.getFixedLabel('DOCNOINVALID').'.</font></b><br>';
}

if(isset($_REQUEST['record']) && $_REQUEST['record'] !='')
{
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($_REQUEST['record'],"Documents");
    $focus->name=$focus->column_fields[$focus->list_link_field];
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$smarty->assign('NOTEID',$_REQUEST['record']);
	$focus->id = '';
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if($focus->mode != 'edit')
{
	if(isset($_REQUEST['parent_id']) && isset($_REQUEST['return_module']))
	{
		$owner = getRecordOwnerId($_REQUEST['parent_id'],$module);
		if(isset($owner['Users']) && $owner['Users'] != '') {
			$permitted_users = get_user_array('true', 'Active',$current_user->id);
			if(!in_array($owner['Users'],$permitted_users)){
				$owner['Users'] = $current_user->id;
			}
			$focus->column_fields['assigntype'] = 'U';
			$focus->column_fields['assigned_user_id'] = $owner['Users'];
		} elseif(isset($owner['Groups']) && $owner['Groups'] != '') {
			$focus->column_fields['assigntype'] = 'T';
			$focus->column_fields['assigned_user_id'] = $owner['Groups'];
		}
	}
}


$record =$_REQUEST['record'];
if($record)
{
    $fileattach ="SELECT ld_seattachmentsrel.crmid,ld_seattachmentsrel.attachmentsid,ld_attachments.name,ld_attachments.type,ld_attachments.path,ld_attachments.size FROM ld_attachments 
    LEFT JOIN ld_seattachmentsrel on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid
    LEFT JOIN ld_notes on ld_notes.notesid=ld_seattachmentsrel.crmid
    where ld_notes.notesid=?";
    $result = $adb->pquery($fileattach,array($record));
    $result_nums = $adb->num_rows($result);

    if($result_nums>0){
        for($i=0;$i<$result_nums;$i++){  
            $attachmentsid = $adb->query_result($result,$i,'crmid');

            $id=$adb->query_result($result,$i,'attachmentsid');
            $recordid = $record;
            $attname = $adb->query_result($result,$i,'name');
            $isenabled = $adb->query_result($result,$i,'isenabled');
            $size = $adb->query_result($result,$i,'size');
            $path = $adb->query_result($result,$i,'path');
            $file_type = $adb->query_result($result,$i,'type');
            $file_info[] = array('file_name'=>$attname,'file_size'=>$size,'file_type'=>$file_type,'file_path'=>$path);
        }
    }

	$json_fileinfo = Zend_Json::encode($file_info);
	$smarty->assign('JSONDATA',$json_fileinfo);
}





if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

if(isset($_REQUEST['parent_id']) && $focus->mode != 'edit') {
	$smarty->assign("PARENTID",vtlib_purify($_REQUEST['parent_id']));
}

$dbQuery="select filename from ld_notes where notesid = ?";
$result=$adb->pquery($dbQuery,array($focus->id));
$filename=$adb->query_result($result,0,'filename');
if(is_null($filename) || $filename == '')
{
	$smarty->assign("FILE_EXIST","no");
}
else
{
	$smarty->assign("FILE_NAME",$filename);
	$smarty->assign("FILE_EXIST","yes");
}

//setting default flag value so due date and time not required
if (!isset($focus->id)) $focus->date_due_flag = 'on';

//needed when creating a new case with default values passed in
if (isset($_REQUEST['contact_name']) && is_null($focus->contact_name)) {
	$focus->contact_name = $_REQUEST['contact_name'];
}
if (isset($_REQUEST['contact_id']) /* && is_null($focus->contact_id) */ ) {
	$focus->contact_id = $_REQUEST['contact_id'];
}
if (isset($_REQUEST['parent_name']) && is_null($focus->parent_name)) {
	$focus->parent_name = $_REQUEST['parent_name'];
}
if (isset($_REQUEST['parent_id']) /* && is_null($focus->parent_id) */ ) {
	$focus->parent_id = $_REQUEST['parent_id'];
}
if (isset($_REQUEST['parent_type'])) {
	$focus->parent_type = $_REQUEST['parent_type'];
}
elseif (!isset($focus->parent_type)) {
	$focus->parent_type = $app_list_strings['record_type_default_key'];
}

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$disp_view = getView($focus->mode);

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
if($disp_view == 'edit_view'){
    $act_data=getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);
//	$smarty->assign("BLOCKS",getBlocks($currentModule,$disp_view,$mode,$focus->column_fields));
}
else
{
	/**
	 * 创建单据时，编号为自动生成后的编号
	 * @project 创建单据时，自动生成编号
	 * @author Tujt 2014-05-13
	 */
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['note_no']=$value;
   $act_data=getBlocks($currentModule,$disp_view,$mode,$focus->column_fields,'BAS');
//	$smarty->assign("BASBLOCKS",getBlocks($currentModule,$disp_view,$mode,$focus->column_fields,'BAS'));
}

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
$smarty->assign("BASBLOCKS",$act_data);

$smarty->assign('BLOCKS',$act_data);

$smarty->assign("OP_MODE",$disp_view);
$category = getParentTab();
$smarty->assign("CATEGORY",$category);



$smarty->assign("MODULE",$currentModule);
$smarty->assign("SINGLE_MOD",'Document');
//Display the RTE or not? -- configure $USE_RTE in config.php
$USE_RTE = vt_hasRTE();

        $USE_RTE = false;

$smarty->assign("USE_RTE",$USE_RTE);

if (isset($focus->name))
$smarty->assign("NAME", $focus->name);
else
$smarty->assign("NAME", "");

if($focus->mode == 'edit')
{
	//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
    $smarty->assign("MODE", $focus->mode);
}
else
{
	$smarty->assign("MODE",'create');
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if (isset($_REQUEST['return_module']))
$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
$smarty->assign("RETURN_MODULE","Documents");
if (isset($_REQUEST['return_action']))
$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
else
$smarty->assign("RETURN_ACTION","DetailView");
if (isset($_REQUEST['return_id']))
$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['email_id']))
$smarty->assign("EMAILID", vtlib_purify($_REQUEST['email_id']));
if (isset($_REQUEST['ticket_id'])) $smarty->assign("TICKETID", vtlib_purify($_REQUEST['ticket_id']));
if (isset($_REQUEST['fileid']))
$smarty->assign("FILEID", vtlib_purify($_REQUEST['fileid']));
if (isset($_REQUEST['record']))
{
         $smarty->assign("CANCELACTION", "DetailView");
}
else
{
         $smarty->assign("CANCELACTION", "index");
}
if (isset($_REQUEST['return_viewname']))
$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
$smarty->assign("OLD_ID", $old_id );
$smarty->assign('ISADMIN',$current_user->is_admin);
if ( empty($focus->filename))
{
        $smarty->assign("FILENAME_TEXT", "");
        $smarty->assign("FILENAME", "");
}
else
{
        $smarty->assign("FILENAME_TEXT", "(".$focus->filename.")");
        $smarty->assign("FILENAME", $focus->filename);
}

if (isset($focus->parent_type) && $focus->parent_type != "") {
        $change_parent_button = "<input title='".$app_strings['LBL_CHANGE_BUTTON_TITLE']."' accessKey='".$app_strings['LBL_CHANGE_BUTTON_KEY']."' lingdang_tabindex='3' type='button' class='button' value='".$app_strings['LBL_CHANGE_BUTTON_LABEL']."' name='button' LANGUAGE=javascript onclick='return window.open(\"index.php?module=\"+ document.EditView.parent_type.value + \"&action=Popup&html=Popup_picker&form=TasksEditView\",\"test\",\"width=600,height=400,resizable=1,scrollbars=1\");'>";
        $smarty->assign("CHANGE_PARENT_BUTTON", $change_parent_button);
}
if ($focus->parent_type == "Account") $smarty->assign("DEFAULT_SEARCH", "&query=true&account_id=$focus->parent_id&account_name=".urlencode($focus->parent_name));

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);


$data = $fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

global $adb;
global $global_pick_list_values;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

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

$fromuitype=array();
////市场活动管理创建联系人和客户等类似功能
$arr['tablerelfields']="";
if($_REQUEST['frommodule']&&$_REQUEST['fromid']>0)
{
    $fromuitype=cls_module_uitype::getModuleUitype("Documents",$_REQUEST['frommodule']);

    if(empty($fromuitype))
    {
        $arr['tablerelfields']=array('module'=>$_REQUEST['frommodule'],'fromid'=>$_REQUEST['fromid']);
    }
    else{
        $tmptabid = getTabid($_REQUEST['frommodule']);
        $tmpresult = $adb->pquery("select * from ld_field where uitye=? and tabid = ?",array($fromuitype,$tmptabid));
        if($adb->num_rows($tmpresult)<=0){
            $arr['tablerelfields']=array('module'=>$_REQUEST['frommodule'],'fromid'=>$_REQUEST['fromid']);
        }
    }
}

if($focus->id<=0||$isduplicate==true)
{
    $qcreate_array=$focus->fieldobj->QuickCreate();
    $smarty->assign("QUICKCREATE", $qcreate_array['form']);
}
else
{
    $qcreate_array=array();
}

//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

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
$data = $focus->fieldobj->split_validationdataArray();
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
//wyt 221118 BUG0058616 知识管理新建界面，没有显示“页面设置”操作按钮
$settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
$is_page_setting = "no";
if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
    $is_page_setting = "yes";
}
$arr['is_page_setting'] = $is_page_setting;

$arr['approve_arr']=$approve_arr;
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
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
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

?>