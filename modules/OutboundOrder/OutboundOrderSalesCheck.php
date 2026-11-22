<?php
global $adb;
if(!$adb){
    exit();
}
//扫码行业：录入的产品是否有合同订单之前的产品，录入的产品数量（按照产品ID汇总统计）是否超出订单中相应产品的数量。
$focus = CRMEntity::getInstance('OutboundOrder');
$msg = $focus->setSaveForSalesOrderCheck($_REQUEST['salesorder_id'],$_REQUEST['productids'],$_REQUEST['quantitys']);
$_REQUEST['diony']='yes';
if(empty($msg)){
	ConvertTojsonString(1,array(),$msg);
}else{
	ConvertTojsonString(-1,array(),$msg);
}
?>