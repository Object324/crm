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
 * $Header: /cvsroot/lingdangcrm/lingdang_crm/modules/Quotes/Save.php,v 1.10 2005/12/14 18:51:30 jerrydgeorge Exp $
 * Description:  Saves an Account record and then redirects the browser to the 
 * defined return URL.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/

//require_once('modules/Quotes/Quotes.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include("modules/Emails/mail.php");


global $adb,$currentModule;
$focus = CRMEntity::getInstance($currentModule);
if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}
//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
if($focus->mode == 'edit')
{
    //获取单据在DB中的币种ID
	$focus->id = $_REQUEST['record'];
	$focus->retrieve_entity_info($focus->id,"Quotes");
    $before_columnfieldvalue=$focus->column_fields;
    $currency_id = $focus->column_fields['currency_id'];
	$query = 'select accountid from ld_quotes where quoteid = ?';
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$before_accountid = $adb->query_result($result,0,0);
}
setObjectValuesFromRequest($focus);
//chj:如果币种改变，则更改单据中原单的币种类型 和 汇率
if($currency_id != $_REQUEST['inventory_currency'])
    $focus->currency_status = true;
else
    $focus->currency_status = false;
if($focus->currency_status === true)
{
	$currencyobj=Currency::getInstance($adb,$_REQUEST['inventory_currency']);
	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
}
$focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];

if($_REQUEST['assigntype'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
$focus->save("Quotes");

//更新客户的最新报价日期
if($focus->mode == 'edit')
{
	if($before_accountid != $focus->column_fields['account_id']){
		$focus->updateAccountsLastQuotesDate($before_accountid);
		$focus->updateAccountsLastQuotesDate($focus->column_fields['account_id']);
	}
}
$return_id = $focus->id;

//$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Quotes";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
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
    $arr['haigesavetip']=$_SESSION[$currentModule.'haigesavetip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
    $focus->ReturnAfterSave($before_columnfieldvalue);
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
  
  header("Location: index.php?action=$return_action&module=$return_module&Create=true&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);


}
else
{
  
    header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}


?>