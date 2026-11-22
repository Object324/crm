<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$focus = CRMEntity::getInstance('Productbom');
$_REQUEST['hdnSubTotal'] = $_REQUEST['commodityTotal'];
$_REQUEST['hdnGrandTotal'] = $_REQUEST['packageTotal'];
$curr_row  = $_REQUEST['curr_row'];
$frommodule = $_REQUEST['frommodule'];
//added to fix 4600
$search=$_REQUEST['search_url'];
setObjectValuesFromRequest($focus);
$focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];
$currencyobj=Currency::getInstance($adb,$_REQUEST['inventory_currency']);
$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
if(isset($_REQUEST['record']) && $_REQUEST['record'] > 0){
	$focus->id = $_REQUEST['record'];
	$focus->mode = $_REQUEST['mode'] = 'edit';
}else{
	$focus->id  = '';
	$focus->mode = '';
}
$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计
$focus->save("Productbom");
require_once(globalStatic::$root_directory.'include/utils/InventoryUtils.php');
//D:\wamp\www\ldcrm\include\utils\InventoryUtils.php
saveInventoryProductDetails($focus, 'Productbom');
echo $focus->id;die;
//header("Location: index.php?module=Products&action=Popup&html=Popup_picker&select=enable&form=HelpDeskEditView&popuptype=inventory_prod&curr_row=".$curr_row."&searchfieldname=productname&searchvalue=&return_module=".$frommodule."&wareid=0&prodbomtag_d=2");
?>