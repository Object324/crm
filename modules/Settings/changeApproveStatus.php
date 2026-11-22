<?php

global $adb;
$columnname = $_REQUEST['columnname'];

$approve=new Approve();
$approveresult=$approve->approveUsed($_REQUEST['id'],$_REQUEST['blockid']);
if(($approveresult==1 || $approveresult==5)&&$columnname=='status'){
	 $_REQUEST['diony']='diony';
    ConvertTojsonString(2,array(),"error");
	exit();  
}


$status_value = $_REQUEST['status_value'];

$sql="update ld_approve set $columnname=? where id=?";
$adb->pquery($sql,array($status_value,$_REQUEST['id']));
if($status_value=='yes' && ($columnname == 'default_on_new'||$columnname == 'default_on_submit')){
    $sql="update ld_approve set $columnname=? where id<>? and tabid = ?";
    $adb->pquery($sql,array('no',$_REQUEST['id'],$_REQUEST['blockid']));
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,'success');
?>