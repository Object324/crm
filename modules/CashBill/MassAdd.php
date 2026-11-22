<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once("modules/CashBill/CashBill.php");


$focus=new CashBill();
$focus->MassSave("CashBill","");
//header("Location:index.php?module=PaymentPlan&action=index&SearchScope=".$_REQUEST['SearchScope']."&query_session=1");
//

$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>