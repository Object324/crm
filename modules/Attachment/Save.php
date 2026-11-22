<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//require_once('modules/Attachment/Attachment.php');

require_once('include/upload_file.php');
require_once("include/upload/UploadFile.class.php");
global $currentModule,$current_user,$root_directory;
$focus = CRMEntity::getInstance($currentModule);
//added to fix 4600
if($_REQUEST['record']>0)
{
    $focus->mode='edit';
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
}
setObjectValuesFromRequest($focus);
if($_REQUEST['reltab']!="")
{
    //32799: 用管理明细界面：相关信息--附件管理，新建弹出层保存，结果相关模块、相关对象值保存错误
    $_REQUEST['related_to_type']=$_REQUEST['reltab'];
    
}
$focus->column_fields['reltab']=$_REQUEST['related_to_type'];
$focus->column_fields['related_to']=$_REQUEST['related_to'];
$search=vtlib_purify($_REQUEST['search_url']);

if (!isset($_REQUEST['date_due_flag'])) $focus->date_due_flag = 'off';

if(isset($_REQUEST['parentid']) && $_REQUEST['parentid'] != '')
	$focus->parentid = $_REQUEST['parentid'];
if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}

/*
* 新增操作，by andy，编辑，创建相关模块附件 20131227
*/

if($_REQUEST['related_to']>0&&$_REQUEST['related_to']!=''&&$_REQUEST['related_to_type']!='Users')
{
    //相关对象和相关对象内容所属模块不一样的判断（can)
    $settype_sql = "select setype from ld_crmentity where crmid = ".$_REQUEST['related_to'];
    $settype_result=$adb->pquery($settype_sql,array());
    if($adb->num_rows($settype_result)>0)
     {
        $_REQUEST['related_to_type']  =$adb->query_result($settype_result,0,0);
        $_REQUEST['reltab']=$adb->query_result($settype_result,0,0);
        
     }   
     
}

$focus->save($currentModule);


if(!empty($_REQUEST['filename-file_num'])){
	for($i = 1; $i<=$_REQUEST['filename-file_num']; $i++){
		$file_name = !empty($_REQUEST['filename-file_name_'.$i])?$_REQUEST['filename-file_name_'.$i]:'';
		$file_name=str_replace(" ","_",$file_name);
	//	$file_name=mysql_real_escape_string($file_name);
	}
}
$return_id = $focus->id;
//创建时增加提醒
if($focus->mode == 'edit')
	AddReminds($current_user->last_name.getFixedLabel('EDITANNEX').$file_name);
else
	AddReminds($current_user->last_name.getFixedLabel('NEWANNEX').$file_name);

/*
*更新操作
*edit:diony
*time:2013-12-20
*reson:附件新增保存成功或者删除附件成功后，执行判断：若当前操作人与当前资料的“负责人”不是同一个人，则生成提醒
*/
function AddReminds($RemindsContent)
{
    //$path = decideFilePath();
    global $adb,$current_user;
    

    $record = $_REQUEST['att_record'];
    $related_to=$_REQUEST['related_to'];
    if($related_to > 0 &&$record!='')
    {
        $smownersql = "select setype from ld_crmentity where crmid = ".$related_to;
        $smownerresult = $adb->query($smownersql);
      
        $setype = $adb->query_result($smownerresult,0,'setype');
		if(!empty($setype)){
			$relatefocus =  CRMEntity::getInstance($setype);
			$sql='select smownerid from '.$relatefocus->table_name.' where '.$relatefocus->table_index.'='.$related_to;
			$smownerresult=$adb->pquery($sql,array());
			if($adb->num_rows($smownerresult)>0)
			{
				$smownerid=$adb->query_result($smownerresult,0,0);
			}
		}
       
    }
}

//$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Attachment";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);



//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
     /*$arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
    $focus->column_fields['modifiedtime']=date("Y-m-d H:i:s");
    
    $focus->setRefreshListModules(array($currentModule));
    $focus->ReturnAfterSave($before_columnfieldvalue);
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{  if($_REQUEST['user_id']>0){//用户详情页附件 zyh
    $user_id = $_REQUEST['user_id'];
    header("location: index.php?module=Attachment&action=DetailView&record=$return_id&user_id=$user_id");
    }else{
    header("Location: index.php?action=$return_action&Create=true&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
    }
}
else
{  
/*
zyh
用户详情页增加附件编辑保存之后返回详情页
PROT197 
20150420
*/
    if($_REQUEST['user_id']>0){
        $user_id = $_REQUEST['user_id'];
        if($current_user->is_admin == 'on'){
            header("Location: index.php?module=Users&action=DetailView&parenttab=Settings&record=$user_id");
        }else{
            header("Location: index.php?module=Users&action=DetailView&record=$user_id&modechk=prefview");
        }
    }else{
        header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
    } 
}

?>