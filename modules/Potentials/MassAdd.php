<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $current_user,$adb;
$columns[]=array();
$i=1;
$nowdate = date('Y-m-d H:i:s',time());
$currency_id = $_REQUEST['currency_id'];//币种ID
$currencyobj=Currency::getInstance($adb,$currency_id);
$conversion_rate = $currencyobj->getCurrencyRate();
$currency_symbol = decode_html($currencyobj->getCurrencySymbol());

while(true)
{
    if(!isset($_REQUEST['plandate'.$i]))
    {
        break;
    }
    $cols=array(
    $_REQUEST["record"],
    $_REQUEST["amount$i"],
    $_REQUEST["potentialamount"],
    $_REQUEST["periodtime$i"],
    $_REQUEST["plandate$i"],
    $current_user->id,
	$current_user->id,
    NULL,
    $nowdate,
    $nowdate,
    $currency_id,
    $conversion_rate,
    $currency_symbol);

    $adb->pquery("INSERT INTO ld_receivablesforecast(potentialsid,amount,
    total,periodtime,receivablesforecastdate,
    smcreatorid,smownerid,modifiedby,modifiedtime,createdtime,currency_id,conversion_rate,currency_symbol) VALUES (
    ?,?,?,?,?,?,?,?,?,?,?,?,?
    );",$cols);
    $i++;
}
unset($_REQUEST['parenttab']);
 $parenttab = getParentTab();
 //echo $parenttab;die();
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>