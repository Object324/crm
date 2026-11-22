<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//require_once('modules/Expense/Expense.php');

//require_once('include/database/PearDatabase.php');
$version_info = getVersionInfo();
global $adb,$currentModule;
$LINGDANG_BULK_SAVE_MODE = false;
$focus = CRMEntity::getInstance($currentModule);
$focus->mode=$_REQUEST['mode'];
$search=$_REQUEST['search_url'];
if(isset($_REQUEST['record']) && $_REQUEST['record'] >0)
{
	$focus->id = $_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $currency_id = $focus->column_fields['currency_id'];
    
    $before_columnfieldvalue=$focus->column_fields;
    $focus->mode='edit';
}
setObjectValuesFromRequest($focus);
//zkt 20240913 BUG20240912-46 （http://yingtai.a1.luyouxia.net:22933/crm）8643版本，费用申请单Expense，在编辑单据时，修改账户从人民币账户修改到美元账户，此时币种会自动变成美元，但是保存后，币种自动变回了人民币。
//币种字段启用时需要获取conversion_rate,currency_symbol
if(isset($_REQUEST['currency_id'])){
    if($currency_id != $_REQUEST['currency_id'])
        $focus->currency_status = true;
    else
        $focus->currency_status = false;
}
else{
    $_REQUEST['currency_id'] = empty($currency_id)?$currency_id:1;//费用报销默认币种为人民币
    $focus->currency_status = true;
}

if($focus->currency_status === true)
{
	$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
}
$focus->column_fields['currency_id'] = $_REQUEST['currency_id'];

if($_REQUEST['assigned_type'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//ZXM 2020-1209 库博特殊开发 核销区块：费用报销明细中的“合计金额”自动反写“核销”区块中的“合计报销金额“;
if($version_info['account'] == "kubo"){
    //cf_3886 合计报销金额
    $focus->column_fields['cf_3886'] = $_REQUEST['total'];
    $focus->column_fields['cf_3888'] = $_REQUEST['total'] - $_REQUEST['cf_3887'];
}
$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计
$focus->save("Expense");

if(isset($_REQUEST['issourcemodule']))
{
    $query= 'update ld_expense set entitytype = ? where expenseid = ?';
    $adb->pquery($query,array($_REQUEST['issourcemodule'],$focus->id));
}
$return_id = $focus->id;
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Expense";
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
//editor:gyq_161 reason:费用报销保存   2019/11/27 16:10
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    $focus->ReturnAfterSave($before_columnfieldvalue);
    //$arr['fieldhrefname']=$focus->list_link_field;
//    $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{  
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&Create=true&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
else{  
     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
exit();
?>