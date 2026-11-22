<?php

//require_once('modules/Invoice/Invoice.php');
//
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include_once("modules/Emails/mail.php");

//$local_log = LoggerManager::getLogger('index');
global  $currentModule;
$focus =CRMEntity::getInstance($currentModule);
//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);

global $current_user,$currentModule;

if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}

if($focus->mode=='edit')
{
    //edit:can 43331: 销售发票->美元，保存后复制单据，复制单据保存后，currency_id 有值，但是conversion_rate 没有值
    $focus->id = $_REQUEST['record'];
    $focus->mode='edit';
	$focus->retrieve_entity_info($focus->id,$currentModule);
    $currency_id = $focus->column_fields['currency_id'];
    $before_columnfieldvalue=$focus->column_fields;
}
else{
    
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
    
	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
   
}
$focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];

if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}

if($focus->mode=='create'){
    $focus->column_fields['approvestatus']=0;
    $focus->column_fields['approveby']=0;
}

$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计
$focus->save("Invoice");

$return_id = $focus->id;


if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Invoice";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

//$local_log->debug("Saved record with id of ".$return_id);

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);
if($_REQUEST['SearchScope']!='')     $SearchScope=$_REQUEST['SearchScope'];
//editor:gyq_161 reason:带分录模块弹出层   2019/11/21 14:04 
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    //$arr['fieldhrefname']=$focus->list_link_field;
//    $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
$focus->ReturnAfterSave($before_columnfieldvalue);
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
  
   header("Location: index.php?action=$return_action&module=$return_module&Create=true&parenttab=$parenttab&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);


}
else
{
  
     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}


?>