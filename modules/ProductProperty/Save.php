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
 * $Header: /cvsroot/lingdangcrm/lingdang_crm/modules/SalesOrder/Save.php,v 1.1 2005/12/16 04:13:15 mangai Exp $
 * Description:  Saves an Account record and then redirects the browser to the
 * defined return URL.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus =CRMEntity::getInstance($currentModule);
$search = $_REQUEST['search_url'];
$_REQUEST['total'] = 0;
if (isset($_REQUEST['record']) && $_REQUEST['record'] > 0) {
    $focus->id = $_REQUEST['record'];
    $currency_id = $focus->column_fields['currency_id'];
    $currency_id = $focus->column_fields['currency_id'];
    $focus->mode='edit';
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
}
setObjectValuesFromRequest($focus);

if ($currency_id != $_REQUEST['currency_id'])
    $focus->currency_status = true;
else
    $focus->currency_status = false;
if ($focus->currency_status === true) {
    $currencyobj = Currency::getInstance($adb, $_REQUEST['currency_id']);
    $focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
    $focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
}
$focus->column_fields['currency_id'] = $_REQUEST['currency_id'];
$focus->save($currentModule);

$return_id = $focus->id;
$parenttab = getParentTab();
if (isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = $currentModule;
if (isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if (isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if ($return_module == $currentModule && $return_action != 'DetailView') {
    $return_action .= '&query_session=1';
}

//code added for returning back to the current view after edit from list view
$return_viewname = '';
if ($_REQUEST['return_viewname'] != '') {
    $return_viewname = '&viewname=' . vtlib_purify($_REQUEST['return_viewname']);
}
$page = '';
if (!empty($_REQUEST['pagenumber'])) {
    $page = '&start=' . vtlib_purify($_REQUEST['pagenumber']);
}
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 11:09
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    $focus->ReturnAfterSave($before_columnfieldvalue);
}
if ((isset($_REQUEST['Create']) && ($_REQUEST['Create'] == 'true' || $_REQUEST['Create'] == 'yes')) || $_REQUEST['isDuplicate'] == 'true') {
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&" .
        "record=$return_id$return_viewname$page" . $search . "&salestype=yes");
} else {
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&" .
        "record=$return_id$return_viewname$page" . $search);
}

?>