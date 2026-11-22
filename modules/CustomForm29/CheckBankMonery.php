<?php
global $adb,$current_user;
$bankid = vtlib_purify($_REQUEST['bankid']);
$monery = str_replace(',','',vtlib_purify($_REQUEST['monery']));
$recordid = vtlib_purify($_REQUEST['recordid']);
$modules = vtlib_purify($_REQUEST['modules']);
if($recordid==''){$recordid='aa';}
if($recordid<>'aa'&&$modules=='PutCash'){
    $sql='SELECT Outaccount FROM ld_PutCash WHERE putcashid='.$recordid;
    $result=$adb->pquery($sql,array());
    $Outaccount = $adb->query_result($result, 0, 'Outaccount');
    if($monery>$Outaccount){
       $monery = $monery-$Outaccount;
    }
}elseif($recordid<>'aa'&&($modules=='CashDeposit'||$modules=='PutCash')){
    $sql='SELECT cashmoney FROM ld_'.$modules.' WHERE '.$modules.'id='.$recordid;
    $result=$adb->pquery($sql,array());
    $cashmoney = $adb->query_result($result, 0, 'cashmoney');
    if($monery>$cashmoney){
       $monery = $monery-$cashmoney;
    }
}elseif($recordid<>'aa'&&($modules=='SendCashBill'||$modules=='Expense')){
    $sql='SELECT total FROM ld_'.$modules.' WHERE '.$modules.'id='.$recordid;
    $result=$adb->pquery($sql,array());
    $total = $adb->query_result($result, 0, 'total');
    if($monery>$total){
       $monery = $monery-$total;
    }
}elseif($recordid<>'aa'&&$modules=='CustomForm29'){
    $sql='SELECT total FROM ld_'.$modules.' WHERE '.$modules.'_id='.$recordid;
    //echo $sql;die();
    $result=$adb->pquery($sql,array());
    $total = $adb->query_result($result, 0, 'total');
    if($monery>$total){
       $monery = $monery-$total;
    }
}

$sql = 'SELECT curbalancemoney FROM ld_bankaccountset WHERE Bankaccountsetid='.$bankid;
$result=$adb->pquery($sql,array());
$curbalancemoney = $adb->query_result($result, 0, 'curbalancemoney');

if($curbalancemoney-$monery>=0){
            echo "SUCCESS";
            exit();
        }else{
            echo "ERROR";
            exit();
        }
	exit();	
?>