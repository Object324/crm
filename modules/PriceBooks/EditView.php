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
//require_once('include/utils/utils.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$currentModule;

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
	$focus->retrieve_entity_info($_REQUEST['record'],"PriceBooks");
	$focus->name = $focus->column_fields['bookname'];
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
	$focus->column_fields['pricebook_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

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
//$richText=$act_data['RichText'];
//unset($act_data['RichText']);
$smarty->assign("BLOCKS",$act_data);
//$smarty->assign('RICHTEXTBOX',implode(',',$richText));
//$smarty->assign('RICHTEXTCOUNT',sizeof($richText));

$smarty->assign("OP_MODE",$disp_view);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("SINGLE_MOD",'PriceBook');


if(isset($cust_fld))
{
        $smarty->assign("CUSTOMFIELD", $cust_fld);
}

$smarty->assign("ID", $focus->id);
if(isset($focus->name))
        $smarty->assign("NAME", $focus->name);
/*
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));
*/
if($focus->mode == 'edit')
{
	//$smarty->assign("UPDATEINFO",updateInfo($focus->id));
    $smarty->assign("MODE", $focus->mode);
	$currency_id = $focus->column_fields['currency_id'];
}
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

if(isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);


$tabid = getTabid("PriceBooks");

$data = $fieldobj->split_validationdataArray();
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

// Added to set price book active when creating a new pricebook
if($focus->mode != 'edit' && $_REQUEST['isDuplicate'] != 'true'){
	$smarty->assign('PRICE_BOOK_MODE', 'create');
	$currency_id = 1;
}

//$check_button = Button_Check($module);
//$smarty->assign("CHECK", $check_button);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CURRENCYID',$currency_id);
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
global $adb,$global_pick_list_depencyfield;

crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
$fields=$focus->fieldobj->getFieldListArray();
$qcreate_array=$focus->fieldobj->QuickCreate();
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
$smarty->assign("QUICKCREATE", $qcreate_array['form']);

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

$_REQUEST['diony']='diony';

//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);

$arr['picklistcontent']=$global_pick_list_values;
$arr['approve_arr']=$approve_arr;
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
//$arr['columnfields_value']=$focus->column_fields;

//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-11

$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
    
?>