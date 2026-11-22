<?php

global $adb;

$type = $_REQUEST['type'];
$record = $_REQUEST['record'];

$sql_havebackamount = "select total,purchasebackstatus from ld_purchaseback where purchasebackid=?";

$result_havebackamount = $adb->pquery($sql_havebackamount, array($record));
$havebackamount = $adb->query_result($result_havebackamount,0,'total');
$purchasebackstatus=$adb->query_result($result_havebackamount,0,'purchasebackstatus');
$sql_total = "select sum(total) as total from ld_purchasecashback 
LEFT JOIN ld_crmentity on ld_purchasecashback.purchasecashbackid = ld_crmentity.crmid 
where ld_purchasecashback.deleted = 0 and purchaseback_id=?";
$result_total = $adb->pquery($sql_total, array($record));
$total = $adb->query_result($result_total,0,'total');
if($total=='')
{
    $total = '0.00';
}
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('teotro');
$arr['status']=$purchasebackstatus;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
if($purchasebackstatus == '已出库'){
	$desc = getFixedLabel('PURCHASEENDRETURN1');
	$desc1 = getFixedLabel('ATERASSISTE');
	$desc2 = getFixedLabel('ATRINATRASEAD');
}else{
	$desc = getFixedLabel('PURCHASEENDRETURN2');
	$desc1 = getFixedLabel('ATERASSISTACBCVWCI');
	$desc2 = getFixedLabel('ATRINATRASEAD');
}
$arr['content']='<table class="settingPopTable lasttdbordernon pad10" border="0" cellpadding="0" cellspacing="0" width="100%">
		<input type="hidden" name="record" value="'.$record.'">
		<input type="hidden" name="status" value="'.$purchasebackstatus.'">
      <tr>
        <td>
            <p style="line-height:200%;">
            1.'.$desc.'<br>
            2.'.$desc1.'<br>
            3.'.$desc2.'</p>
            <div id="instockroomEndOperation_div"><div class=divContent>'.getFixedLabel('Thetotalamountofrefund').'：'.getDecimalTwoVal($havebackamount).'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.getFixedLabel('Refunded').'：'.getDecimalTwoVal($total).'</div></div>
        </td>
      </tr>
    </table>';
ConvertTojsonString(1,$arr,"success");
exit();
?>