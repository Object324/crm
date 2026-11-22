<?php
global $adb;
$currentModule='Products';
$productid=$_REQUEST['productid'];
crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
if(!empty($productid))

{
    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
    $currencyInfo = getInventoryCurrencyInfo($currentModule,$productid);
    $product_base_currency = $currencyInfo['currency_id'];
}
else
{
    $currencyobj=Currency::getInstance($adb);
    $product_base_currency=$currencyobj->getCurrencyId();

}

$base_currency_name=$_REQUEST['fldname'];

if($base_currency_name=='unit_price')
{
    $unit_price =$_REQUEST['base_currency_value'];
    $price_details = getPriceDetailsForProduct($productid, $unit_price, 'available',$currentModule,'unit_price');
}
else
{

    //参考成本价 - 价格设定
    $procostprice = $_REQUEST['base_currency_value'];
    $price_details = getPriceDetailsForProduct($productid, $procostprice, 'available',$currentModule,'procostprice');

}
$base_currency = $base_currency_name.'_curname' . $product_base_currency;
$sysdeploy_93 = getSys_deploy(93);	// 系统参数控制单价小数位

$smarty=new lingdangCRM_Smarty();
$smarty->assign("base_currency",$base_currency);
$smarty->assign('price_decimal',$sysdeploy_93['deploy_value']);
$smarty->assign("fldname",$base_currency_name);
$smarty->assign("price_detail",$price_details);
$str=$smarty->fetch("MoreCurrencySet.tpl");
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('PRODUCT_PRICES');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>