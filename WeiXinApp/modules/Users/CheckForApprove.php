<?php
/**
 * 出库单或入库单更新库存流水记录的触发点：审核
 * 出库单入库单审批/审核时，要判断产品数量超过产品总库存数量
 * 
 */
$module = $_REQUEST['frommodule'];
if($module == 'OutboundOrder'){
    include globalStatic::$root_directory.'modules/OutboundOrder/OutboundOrderForApprove.php';
}elseif($module == 'Stock'){
    include globalStatic::$root_directory.'modules/Stock/StockForApprove.php';
}elseif($module == 'CashBill'){
    include globalStatic::$root_directory.'modules/CashBill/BankConfirm.php';
}elseif($module == 'SendCashBill'){
    include globalStatic::$root_directory.'modules/SendCashBill/BankConfirm.php';
}

?>
