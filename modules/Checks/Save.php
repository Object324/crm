<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
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
 * $Header: /cvsroot/lingdangcrm/lingdang_crm/modules/SalesOrder/Save.php,v 1.1 2005/12/16 04:13:15 mangai Exp $
 * Description:  Saves an Account record and then redirects the browser to the 
 * defined return URL.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/

//require_once('modules/Checks/Checks.php');
//require_once('include/logging.php');
//require_once('include/database/PearDatabase.php');
//include("modules/Emails/mail.php");

global $currentModule;

$focus =CRMEntity::getInstance($currentModule);
//added to fix 4600
$search=$_REQUEST['search_url'];
if($_REQUEST['record']>0)
{
    $focus->id=$_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $focus->mode='edit';
    $before_columnfieldvalue=$focus->column_fields;
}

setObjectValuesFromRequest($focus);
$focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];
$currencyobj=Currency::getInstance($adb,$_REQUEST['inventory_currency']);
$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();

$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计
$focus->save("Checks");

$return_id = $focus->id;


/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

//code added for returning back to the current view after edit from list view
$return_viewname='';
if($_REQUEST['return_viewname'] != '') {
	$return_viewname='&viewname='.vtlib_purify($_REQUEST['return_viewname']);
}
$page = '';
if(!empty($_REQUEST['pagenumber'])){
	$page = '&start='.vtlib_purify($_REQUEST['pagenumber']);
}
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 17:49
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
    $focus->ReturnAfterSave($before_columnfieldvalue);
    
}

?>