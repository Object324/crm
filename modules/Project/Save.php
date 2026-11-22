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
global $current_user, $currentModule;

checkFileAccessForInclusion("modules/$currentModule/$currentModule.php");
require_once("modules/$currentModule/$currentModule.php");
global $currentModule;
$focus=CRMEntity::getInstance($currentModule);

global $projectstatus_old;
if($_REQUEST['record']>0){
 //  $sqlss = "select projectstatus from ld_project where projectid=".$_REQUEST['record'];
//   $paymentstatusrestu=$adb->pquery($sqlss,array());
//   $projectstatus_old=$adb->query_result($paymentstatusrestu,0,'projectstatus');
   $focus->mode='edit';
   $focus->id=$_REQUEST['record'];
   $focus->retrieve_entity_info($focus->id,$currentModule);
   $projectstatus_old=$focus->column_fields['projectstatus'];
   
   $before_columnfieldvalue=$focus->column_fields;
}
$mode = $_REQUEST['mode'];
$record=$_REQUEST['record'];
$focus = CRMEntity::getInstance($currentModule);
if($record>0)
{
    $focus->retrieve_entity_info($record,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;

    $focus->mode='edit';
    
}
setObjectValuesFromRequest($focus);


if($mode) $focus->mode = $mode;
if($record)$focus->id  = $record;

if($_REQUEST['assigntype'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}

$focus->save($currentModule);
//在项目计划模块中，编辑操作时，确保已用费用和已用工时字段值正确.
$focus->updateProjectHas($record);
$return_id = $focus->id;

$search = vtlib_purify($_REQUEST['search_url']);

$parenttab = getParentTab();
if($_REQUEST['return_module'] != '') {
	$return_module = vtlib_purify($_REQUEST['return_module']);
} else {
	$return_module = $currentModule;
}

if($_REQUEST['return_action'] != '') {
	$return_action = vtlib_purify($_REQUEST['return_action']);
} else {
	$return_action = "DetailView";
}

if($_REQUEST['return_id'] != '') {
	$return_id = vtlib_purify($_REQUEST['return_id']);
}
/**
edit:chj
date:2014-6-23
reason:教育 学员更多信息创建班级
*/
if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] >0 && getEduType('Edu') == true)
{
    $sql = "insert into ld_lessionplanorg(accountid,otherid,type) values (?,?,?)";
    $adb->pquery($sql,array($_REQUEST['accountid'],$focus->id,1));
}
/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
       // $arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
    $focus->ReturnAfterSave($before_columnfieldvalue);
    
        
 }
 else 
header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&parenttab=$parenttab&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

?>