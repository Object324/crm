<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

require_once('modules/LoanApply/LoanApply.php');

$focus = new LoanApply();
//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);

global $current_user;
if($focus->mode == 'edit' || $_REQUEST['mode'] == 'edit')
{
    $focus->id = $_REQUEST['record'];
    $currency_id = $focus->column_fields['currency_id'];
}
setObjectValuesFromRequest($focus);

if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//chj:如果币种改变，则更改单据中原单的币种类型 和 汇率
if($currency_id != $_REQUEST['currency_id'])
    $focus->currency_status = true;
else
    $focus->currency_status = false;

if($focus->currency_status === true)
{
    $focus->column_fields['currency_id'] = $_REQUEST['currency_id'];
	$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
	$before_columnfieldvalue=$focus->column_fields;
}
$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计
$focus->save("LoanApply");
$pot_id = $return_id = $focus->id;

$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "LoanApply";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);


if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
//传用户以前的负责人id
$assign_user_id = $focus->smoldOwnerID;
if($_REQUEST['SearchScope']!='')     $SearchScope=$_REQUEST['SearchScope'];
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
      /* $arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
	$focus->ReturnAfterSave($before_columnfieldvalue);
        
 }
else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&Create=true&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}
else
{
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}

?>