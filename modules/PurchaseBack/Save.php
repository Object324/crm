<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//require_once('modules/PurchaseBack/PurchaseBack.php');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$LINGDANG_BULK_SAVE_MODE = true;
//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);

//Ended

global $current_user;

$focus = CRMEntity::getInstance($currentModule);



if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}
if($_REQUEST['record']>0)
{
	$focus->id = $_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $focus->mode='edit';
    $before_columnfieldvalue=$focus->column_fields;
 }
 /*
foreach($focus->column_fields as $fieldname => $val)
{
	if(isset($_REQUEST[$fieldname]))
	{
		if(is_array($_REQUEST[$fieldname]))
			$value = $_REQUEST[$fieldname];
   
		else
			$value = trim($_REQUEST[$fieldname]);
	
		$focus->column_fields[$fieldname] = $value;
	}
}
*/
setObjectValuesFromRequest($focus);


$focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];
$currencyobj=Currency::getInstance($adb,$_REQUEST['inventory_currency']);
$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
//print_r($focus->column_fields);
//负责人
if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}


//Changing account address - Ends
$LINGDANG_BULK_SAVE_MODE = false;
$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计
$focus->save("PurchaseBack");
$return_id = $focus->id;
//
//$parenttab = getParentTab();
//if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
//else $return_module = "PurchaseBack";
//if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
//else $return_action = "DetailView";
//if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);
//

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
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 20:01
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
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
else
{  
     header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}



?>