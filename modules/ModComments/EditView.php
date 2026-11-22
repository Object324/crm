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
global $app_strings, $mod_strings, $current_language, $currentModule, $theme;
//require_once('Smarty_setup.php');

// Forcefully disable Editing For Any User
/*if (!empty($_REQUEST['record']) && vtlib_purify($_REQUEST['isDuplicate']) != 'true') {
	$smarty = new lingdangCRM_Smarty;
	$smarty->assign("MOD",$mod_strings);
	$smarty->assign("APP",$app_strings);
	$smarty->assign("THEME", "$theme");
	$smarty->assign("IMAGE_PATH", "themes/$theme/images/");

	$smarty->display(vtlib_getModuleTemplate('lingdang','OperationNotPermitted.tpl'));
	exit;
}	*/
// END


global $adb;

require_once('modules/Calendar/CalendarCommon.php');

if($currentModule == 'Calendar'){
    $currentModule='Events';
}

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty();

$category = getParentTab($currentModule);
$record = $_REQUEST['record'];

$TopicType='comments';
if($_REQUEST['topictype'])
{
    $TopicType=$_REQUEST['topictype'];
}

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
//added to fix the issue4600
global $global_pick_list_values;
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
}
if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
    $focus->column_fields['topictype']=$TopicType;
    //1000066  评论功能优化（界面显示和评论内容，回复）--回复-获取相关评论或相关回复
    if($TopicType == 'reply'&&!empty($_REQUEST['reply_id'])){
        
        $sql = 'select parent_reply,parent_comments,topictype from '.$focus->table_name.' where '.$focus->table_index.'=? ';
        $result = $adb->pquery($sql,array($_REQUEST['reply_id']));
        if($adb->num_rows($result)>0){
            $tmptopictype = $adb->query_result($result,0,'topictype');
            $tmpparent_comments = $adb->query_result($result,0,'parent_comments');
            $tmpparent_reply = $adb->query_result($result,0,'parent_reply');
            if($tmptopictype == 'reply'){
                //被回复单据是回复类型，设置相关回复和相关评论
                $focus->column_fields['parent_comments']=$tmpparent_comments;
                $focus->column_fields['parent_reply']=$_REQUEST['reply_id'];
            }
            else{
                //被回复单据是回复类型，仅设置相关回复
                $focus->column_fields['parent_comments']=$_REQUEST['reply_id'];
            }
        }
    }
}

$disp_view = getView($focus->mode);



if(isset($_REQUEST['return_module']))   
{
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
  
} 
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

$smarty->assign('BLOCKS', getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields, 'BAS'));
	//$smarty->assign('ADVBLOCKS',getBlocks($currentModule,$disp_view,$mode,$focus->column_fields,'ADV'));

$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);

$smarty->assign('MODULE', $currentModule);

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
$smarty->assign('ISADMIN',$current_user->is_admin);
//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
	//$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);
$validationArray =$fieldobj->split_validationdataArray();

global $adb;

crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
//if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
//   $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]= getAttachmentsTableInfo($focus->id,$currentModule);
//if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
//   $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= getImageFileInfo($focus->id,$currentModule);
//
//
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
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes') ||$_REQUEST['isDuplicate']=='true'))
{
  
    $smarty->assign('CREATE','true');
}
else
{
  
     $smarty->assign('CREATE','false');
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
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
$data = $focus->fieldobj->split_validationdataArray();
$fields=$focus->fieldobj->getFieldListArray();
// ls 2022-03-22 0050558: （没有外网）（千思跃）其他费用模块（原评论模块）中新建时字段显示错误(关联选择单据字段没显示出来)
//选择模块的字段
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';
//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);

$arr['picklistcontent']=$global_pick_list_values;
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
//$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;

//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);
ConvertTojsonString(1,$arr,"success");
?>