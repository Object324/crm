<?php
require_once("modules/SendCashBill/SendCashBill.php");
$focus=new SendCashBill();
$focus->MassSave("SendCashBill","");
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
//header("Location:index.php?module=SendPayment&action=index&SearchScope=".$_REQUEST['SearchScope']."&query_session=1");
?>