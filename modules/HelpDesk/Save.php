<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/lingdangcrm/modules/HelpDesk/Save.php,v 1.8 2005/04/25 05:21:46 Mickie Exp $
 * Description:  Saves an Account record and then redirects the browser to the 
 * defined return URL.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/

//require_once('modules/HelpDesk/HelpDesk.php');

//require_once('include/database/PearDatabase.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus =CRMEntity::getInstance($currentModule);


//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
if($_REQUEST['record']>0)
{
    $focus->mode = 'edit';
}

// editor:gyq date:20180724 reason:0034663: （客户自助服务平台PC端登录）PC端编辑小程序中新增的单据保存时，单据来源字段值更换为CRM中新建的单据了
if($focus->mode == 'edit')
{
    $focus->id = $_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,"HelpDesk");
    $before_columnfieldvalue=$focus->column_fields;
}

setObjectValuesFromRequest($focus);
global $adb,$mod_strings;
//Added to update the ticket history
//Before save we have to construct the update log. 
$mode = $_REQUEST['mode'];

$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];

//$fldvalue = $focus->constructUpdateLog($focus, $mode, $grp_name, $_REQUEST['assigntype']);
//$fldvalue = from_html($fldvalue,($mode == 'edit')?true:false);
if($focus->mode == 'edit'){
	$query = 'select servicecontractsid from ld_troubletickets where ticketid = ? ';
	$result = $adb->pquery($query,array($focus->id));
	$before_servicecontractsid =$adb->query_result($result,0,0);
	/*
	andrew
	20140226
	服务合同添加服务单，增加已服务次数 	
	*/
	if($focus->column_fields['servicecontractsid'] != $before_servicecontractsid  && $before_servicecontractsid > 0){
		$query = 'select count(1) as cnt from ld_troubletickets where servicecontractsid = ? and deleted = 0';
		$result = $adb->pquery($query,array($before_servicecontractsid));
		$num_rows = $adb->num_rows($result);
		if(empty($num_rows))$num_rows = 0;

		$adb->pquery('update ld_servicecontracts set service_units=? where servicecontractsid=?',array($num_rows - 1,$before_servicecontractsid));
	}
}
$focus->save("HelpDesk");

//After save the record, we should update the log
//$adb->pquery("update ld_troubletickets set update_log=? where ticketid=?", array($fldvalue,$focus->id));

$return_id = $focus->id;
$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "HelpDesk";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

$_REQUEST['return_id'] = $return_id;

if($_REQUEST['return_module'] == 'Products' & $_REQUEST['product_id'] != '' &&  $focus->id != '')
	$return_id = vtlib_purify($_REQUEST['product_id']);

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
       // $arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
$focus->setRefreshDetailModules(array($currentModule));
$focus->ReturnAfterSave($before_columnfieldvalue);
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    header("Location: index.php?action=$return_action&Create=true&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
else
{
  
    header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}


//header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&$mail_error_status&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
?>