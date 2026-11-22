<?php


/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*新增合同订单后立即创建回款计划页面*/


//require_once("Smarty_setup.php");
global $adb,$currentModule;
global $current_user;
$smarty = new lingdangCRM_Smarty;
$smarty->assign('MODULE',$currentModule);
$paymentresult=$adb->pquery($sql,array());
$sqlsalesorder='select ld_vendor.vendorname,vendor_no,total,subtotal,ld_vendor.vendorid from ld_purchaseorder left join ld_vendor on ld_purchaseorder.vendorid=ld_vendor.vendorid
                where purchaseorderid= '.$_REQUEST['purchaseorderid'];
$saleorderresult=$adb->pquery($sqlsalesorder,array());
$accountid=$adb->query_result($saleorderresult,0,"vendorid");
$salesorderamount=$adb->query_result($saleorderresult,0,"total");
$smarty->assign("VENDORID",$accountid);
if(!isset($salesorderamount))
{
    $salesorderamount=0;
}
$smarty->assign("PURCHASEORDERAMOUNT",$salesorderamount);
$smarty->assign("PLANDATE",date("Y-m-d"));
$smarty->assign("PURCHASEORDERID",$_REQUEST['purchaseorderid']);
$smarty->assign("CURUSERID",$current_user->id);
echo "####:###";
$smarty->assign('IMMEDIATELYCREATE',$_REQUEST['Immediatelycreate']);
$smarty->display("modules/SendPayment/PopCreateSendPayment.tpl");
unset($adb);
unset($current_user);
exit();
?>