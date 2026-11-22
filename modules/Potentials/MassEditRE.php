<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $current_user,$adb;
$nowdate = date('Y-m-d H:i:s',time());
    $record = $_REQUEST["record"];
    $amount = $_REQUEST["amount1"];
    $potentialamount = $_REQUEST["potentialamount"];
    $receivablesforecastdate = $_REQUEST["plandate1"];
    $receivablesforecastid = $_REQUEST["receivablesforecastid"];
    $currency_id = $_REQUEST['currency_id'];
    //print_r($_REQUEST);die();
    $query = 'select 1 from ld_receivablesforecast where receivablesforecastid = ? and currency_id = ? limt 1';
    $result = $adb->pquery($query,array($receivablesforecastid,$currency_id));
    $num_rows = $adb->num_rows($result);
    //echo $receivablesforecastid;die;
    //判断币种是否更改
    if($num_rows <= 0)
    {
		$currencyobj=Currency::getInstance($adb,$currency_id);
		$conversion_rate = $currencyobj->getCurrencyRate();
		$currency_symbol = decode_html($currencyobj->getCurrencySymbol());
        $adb->pquery('update ld_receivablesforecast set currency_id = ?,conversion_rate=?,currency_symbol=? where receivablesforecastid = ?',
        array($currency_id,$conversion_rate,$currency_symbol,$receivablesforecastid));
    }
    $adb->pquery("update ld_receivablesforecast set total='$potentialamount',amount='$amount',receivablesforecastdate='$receivablesforecastdate',
    modifiedby='$current_user->id',modifiedtime='$nowdate' where receivablesforecastid=$receivablesforecastid;",array());

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");

?>