<?php

global $adb;

$type = $_REQUEST['type'];
$record = $_REQUEST['record'];

$sql_havebackamount = "select total from ld_salesback where salesbackid=?";

$result_havebackamount = $adb->pquery($sql_havebackamount, array($record));
$havebackamount = $adb->query_result($result_havebackamount,0,'total');

$sql_total = "select sum(total) as total from ld_cashback where ld_cashback.deleted = 0 and salesbackid=?";
$result_total = $adb->pquery($sql_total, array($record));
$total = $adb->query_result($result_total,0,'total');
if($total=='')
{
    $total = '0.00';
}
echo '#####SUCCESS#####';
echo '<div class=divContent style="margin-left:10px;">'.getFixedLabel('Thetotalamountofrefund').'：'.getDecimalTwoVal($havebackamount).'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.getFixedLabel('Refunded').'：'.setNumberFormat($total).'</div>';

exit();
?>