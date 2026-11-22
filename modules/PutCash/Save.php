<?php

//require_once('modules/PutCash/PutCash.php');


//require_once('include/database/PearDatabase.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$currentModule;
$LINGDANG_BULK_SAVE_MODE = false;
$focus = CRMEntity::getInstance($currentModule);

$focus->mode=$_REQUEST['mode'];
$search=$_REQUEST['search_url'];
if(isset($_REQUEST['record']) && $_REQUEST['record'] >0)
{
	$focus->id = $_REQUEST['record'];
    $currency_id = $focus->column_fields['currency_id'];
    $focus->mode='edit';
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
}
setObjectValuesFromRequest($focus);
if($_REQUEST['assigned_type'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
$focus->save("PutCash");
$return_id = $focus->id;
/**
 * @edit:chj
 * @date:2014-11-24
 * @reason:新增、编辑 更改币种汇率和货币符号
 * @description:
 */
if(isset($_REQUEST['currency_id']))
{
	$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
	$cur_sym_rate['rate'] = $currencyobj->getCurrencyRate();
	$cur_sym_rate['symbol'] = $currencyobj->getCurrencySymbol();
    if($focus->mode == 'edit')
    {
        //编辑：如果币种没有修改，则不修改对应的汇率和货币符号
        if($currency_id != $_REQUEST['currency_id'])
        {
            $query = "update ld_putcash set currency_id = '".$_REQUEST['currency_id']."',
            conversion_rate='".$cur_sym_rate['rate']."',currency_symbol='".decode_html($cur_sym_rate['symbol'])."' where putcashid = " . $focus->id;
            //echo $query;die;
            $adb->pquery($query);
        }
    }
    else
    {
        $adb->pquery('update ld_putcash set conversion_rate=?,currency_symbol=? where putcashid = ?',
        array($cur_sym_rate['rate'],decode_html($cur_sym_rate['symbol']),$focus->id));
    }
}
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "PutCash";
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
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    /*
     $arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
    $focus->ReturnAfterSave($before_columnfieldvalue);
        
 }
else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
  
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&Create=true&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);

}
else
{
  
     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
exit();
?>