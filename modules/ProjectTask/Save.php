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

//checkFileAccessForInclusion("modules/$currentModule/$currentModule.php");
//require_once("modules/$currentModule/$currentModule.php");

$focus = CRMEntity::getInstance($currentModule);
if($_REQUEST['record']>0)
{
    $focus->mode='edit';
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
}
setObjectValuesFromRequest($focus);

$mode = $_REQUEST['mode'];
$record=$_REQUEST['record'];

if($mode) $focus->mode = $mode;
if($record)$focus->id  = $record;
//在项目计划模块中，编辑操作时，确保已用费用和已用工时字段值正确.
$focus->updateProjecTaskHas($record);
if($_REQUEST['assigntype'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
$SQL = "SELECT trade FROM ld_version;";
    $result = $adb->pquery($SQL, array());
    $trade = $adb->query_result($result, 0, 'trade');
if($trade=='qiaiju'){
    $projectid = $focus->column_fields['projectid'];
    $totalcost = $focus->column_fields['totalcost'];
    if($mode==''){
        $SQL = "UPDATE ld_project SET realprojectcost=realprojectcost+$totalcost WHERE projectid=$projectid";
        $adb->pquery($SQL, array());
    }elseif($mode=='edit'){
        $SQL = "SELECT totalcost,projectid FROM ld_projecttask WHERE projecttaskid=$record";
        $result = $adb->pquery($SQL, array());
        $projectidnow = $adb->query_result($result, 0, 'projectid');
        $totalcostnow = $adb->query_result($result, 0, 'totalcost');
        if($projectidnow==$projectid){
            $SQL = "UPDATE ld_project SET realprojectcost=realprojectcost+($totalcost-$totalcostnow) WHERE projectid=$projectid";
            $adb->pquery($SQL, array());
        }else{
            $SQL = "UPDATE ld_project SET realprojectcost=realprojectcost+$totalcost WHERE projectid=$projectid";
            $adb->pquery($SQL, array());
            $SQL = "UPDATE ld_project SET realprojectcost=realprojectcost-$totalcostnow WHERE projectid=$projectidnow";
            $adb->pquery($SQL, array());
        }
    }
}
$focus->save($currentModule);
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
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
/**
* reason:项目计划保存时，反写项目模块 字段--"已完成项目计划数"。
* edit：cyb
* date：2015-11-13
**/ 
if($focus->mode=='' || $focus->mode=='create'){//新建项目计划。
   $record=$focus->id;  
}
if(!empty($record)){
	$sql1='';
	$sql1 .='select projectid from ld_projecttask';     
	$sql1 .=' where projecttaskid='.$record;
	$result = $adb->pquery($sql1);
    if($adb->num_rows($result)>0)
	   $projectid=$adb->query_result($result,'projectid');  
	if(!empty($projectid))  //判断项目计划是否有关联项目。
	{                
		$sql2='select count(1) from ld_projecttask where projectid='.$projectid.' and deleted=0';
		$sql3='select count(1) from ld_projecttask where projectid='.$projectid.' and deleted=0 and projecttaskstatus=\'已完成\'';
		$result2 = $adb->pquery($sql2);
		$result3 = $adb->pquery($sql3);
		$sql4='';
		$sql4 .='update ld_project SET completetask=\''.$adb->query_result($result3,0,0).'/'.$adb->query_result($result2,0,0).'\'';
		$sql4 .=' where projectid='.$projectid;         
		$adb->pquery($sql4); 
	}
}

$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    //$arr['fieldhrefname']=$focus->list_link_field;
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