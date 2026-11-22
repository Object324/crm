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
global $current_user, $currentModule,$ServiceContractsPreremind;
$deployarray=getSys_deploy(24);
$ServiceContractsPreremind = $deployarray['deploy_value'];
//checkFileAccessForInclusion("modules/$currentModule/$currentModule.php");
//require_once("modules/$currentModule/$currentModule.php");

$focus = CRMEntity::getInstance($currentModule);
if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}
if($focus->mode == 'edit')
{
	//获取单据在DB中的币种ID
	$focus->id = $_REQUEST['record'];
	$focus->retrieve_entity_info($focus->id,$currentModule);
    $currency_id = $focus->column_fields['currency_id'];
    $before_columnfieldvalue=$focus->column_fields;
    /*$account=CRMEntity::getInstance("Accounts");
    $account->updateAccountInfo($currentModule,'',1,$focus->id);*/
    $focus->mode='edit';

}
setObjectValuesFromRequest($focus);
$mode = $_REQUEST['mode'];
$record=$_REQUEST['record'];
if($mode) $focus->mode = $mode;
if($record)$focus->id  = $record;
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
edit:chj
date:2014-6-23
reason:教育 学员更多信息创建课程
*/
if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] >0 && getEduType('Edu') == true)
{
    $sql = "insert into ld_lessionplanorg(accountid,otherid,type) values (?,?,?)";
    $adb->pquery($sql,array($_REQUEST['accountid'],$focus->id,2));
}
/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    $salestype = "&salestype=yes";
}else{
    $salestype = '';
}
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 17:49
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no') {
    //if($this->module_name=='ServiceContracts')
//        {
//            $refreshdetailmodules[]='Accounts';
//            $refreshdetailmodules[]='ServieCharge';//最晚服务到期日
//            $refreshlistmodules[]='Accounts';
//            $refreshlistmodules[]='ServieCharge';
//        }
        $focus->setRefreshListModules(array('Accounts','ServieCharge'));
        $focus->setRefreshDetailModules(array('Accounts','ServieCharge'));
        
    $focus->ReturnAfterSave($before_columnfieldvalue);
    /*
    $arr['fieldhrefname'] = $focus->list_link_field;
    $arr['fieldvalue'] = $focus->column_fields;
    $arr['fieldvalue']['maintable_id'] = $focus->id;
    $arr['modulebillnotip'] = $_SESSION[$currentModule . '_modulebillnotip'];
    $_SESSION[$currentModule . '_modulebillnotip'] = 'no';
    ConvertTojsonString(1, $arr, "success");*/
}
header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&parenttab=$parenttab&start=".vtlib_purify($_REQUEST['pagenumber']).$search.$salestype);
?>