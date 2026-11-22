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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Accounts/Save.php,v 1.7 2005/03/15 09:55:31 shaw Exp $
 * Description:  Saves an Account record and then redirects the browser to the 
 * defined return URL.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Reminds/Reminds.php');

global $adb;
if(isset($_REQUEST['server_time'])){
    $server_time=date('Y-m-d H:i');
    $date = new DateTimeField($server_time);
    $server_time=$date->getDisplayDateTimeValue();
    echo $server_time;exit;
}

//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
$focus = CRMEntity::getInstance('Reminds');

$focus->saveReminds();

//Changing account address - Ends
$return_id = $focus->id;


$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Reminds";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);
//if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
//else $return_action = "ListView";
$return_action = "ListView";


//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == ''){
   if($return_module=='Reminds')
   $return_viewname='108'; 
   else
   $return_viewname=0;
} 
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
    //wyt 221108 XUQIU1000658  关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮 关联提醒模块特殊
     $focus->setRefreshListModules(array('Reminds'));
     $focus->setRefreshDetailModules(array('Reminds'));
     $focus->ReturnAfterSave($focus->column_fields);
    ConvertTojsonString(1,$arr,"success");
        
 }
 else
header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
/** Function to save Accounts custom field info into database
* @param integer $entity_id - accountid
*/

?>