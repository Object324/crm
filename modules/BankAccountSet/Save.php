<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//require_once('modules/BankAccountSet/BankAccountSet.php');

//require_once('include/database/PearDatabase.php');
$LINGDANG_BULK_SAVE_MODE = false;
global $adb,$mod_strings,$current_user,$currentModule;
crm_load_class_file("BankAccountSet","modules/BankAccountSet");

$focus = CRMEntity::getInstance($currentModule);
$focus->mode=$_REQUEST['mode'];

$search=$_REQUEST['search_url'];
if($focus->mode == 'edit')
{
    $focus->id = $_REQUEST['record'];
    $currency_id = $focus->column_fields['currency_id'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
}
setObjectValuesFromRequest($focus);
if($_REQUEST['assigned_type'] == 'U') {
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
	$currencySymbol = $currencyobj->getCurrencySymbol();
	$currencyRate = $currencyobj->getCurrencyRate();
    $focus->column_fields['conversion_rate'] = $currencyRate;
    $focus->column_fields['currency_symbol'] = decode_html($currencySymbol);
   
}

$temp_uid = $current_user->id;
$focus->save("BankAccountSet");

$return_id = $focus->id;

// $sql="UPDATE ld_crmentity set smownerid=smcreatorid WHERE crmid=?";
// $adb->pquery($sql,array($return_id));
$sql="INSERT INTO ld_bankaccountprofile (bankaccountsetid,userid) VALUES (?,'-1');";
$adb->pquery($sql,array($return_id));
if($_REQUEST['confirmed']==1){
    $nowdatetime = date('Y-m-d H:i:s',time());  
    //echo   $current_user->id;die();
    $sql="update ld_bankaccountset set confirmed=1,curbalancemoney=initmoney,confirmtime='$nowdatetime',confirmby='$temp_uid' where bankaccountsetid=$return_id";
    $adb->pquery($sql);
}
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "BankAccountSet";
if(isset($_REQUEST[' ']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
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
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    $focus->ReturnAfterSave($before_columnfieldvalue);
     /*$arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
        
 }else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
  
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&Create=true&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}
else
{
  
     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
exit();
?>