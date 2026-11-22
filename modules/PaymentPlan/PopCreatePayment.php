<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*新增合同订单后立即创建回款计划页面*/


//require_once("Smarty_setup.php");
global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;

$paymentresult=$adb->pquery($sql,array());
$sqlsalesorder='select ld_account.accountname,salesorder_no,total,subtotal,ld_account.accountid from ld_salesorder left join ld_account on ld_salesorder.accountid=ld_account.accountid
                where ld_salesorder.salesorderid= '.$_REQUEST['salesorderid'];
$saleorderresult=$adb->pquery($sqlsalesorder,array());
$accountid=$adb->query_result($saleorderresult,0,"accountid");
$salesorderamount=$adb->query_result($saleorderresult,0,"total");
$smarty->assign("ACCOUNTID",$accountid);
$smarty->assign("SALESORDERAMOUNT",$salesorderamount);
$smarty->assign("PLANDATE",date("Y-m-d"));
$smarty->assign("SALESORDERID",$_REQUEST['salesorderid']);
$smarty->assign("CURUSERID",$current_user->id);
echo "####:###";
$smarty->assign('IMMEDIATELYCREATE',$_REQUEST['Immediatelycreate']);
$smarty->display("modules/CashBill/PopCreatePayment.tpl");
unset($adb);
unset($current_user);
exit();

?>