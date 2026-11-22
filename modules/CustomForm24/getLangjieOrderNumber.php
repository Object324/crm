<?php
/**
 * User: Administrator
 * Project: crm
 * Date: 2020/5/21 15:08
 * Description:
 */

global $adb,$currentModule,$current_user;

$time = strtotime($_REQUEST['time']);  //航班时间
$rowcnt = $_REQUEST['rowcnt'];  //行数
$prefix ='HLV';
$query = "select MAX(sf169) from ld_customform24detailscf WHERE sf169 like ? ";
$wherelike = $prefix.date("ymd",$time).'%';
$result = $adb->pquery($query,array($wherelike));
$rownum = $adb->num_rows($result);
if($rownum != 0){
    $row = $adb->fetch_row($result);
    $sf169 = $row['0'];
    $number = intval(substr($sf169,9));
    $number++;
}else{
    $number = 1;
}
$orderNumber =$prefix.date("ymd",$time).formatNum( $number);

$tmparr['rowcnt'] = $rowcnt;
$tmparr['before'] = $prefix.date("ymd",$time);
$tmparr['prefix'] =$prefix;
$tmparr['time'] =  $time;
$tmparr['number']=$number;
$tmparr['ordernumber'] = $orderNumber;
$_REQUEST['diony'] ='diony';
ConvertTojsonString(1,$tmparr,'success');


function formatNum($number){
    if($number<1000){
        $number = sprintf("%03d", $number);
    }
    return $number;
}