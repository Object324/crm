<?php
global $adb;
//反写字段公式
$reversefieldtype=$_REQUEST['reversefieldtype'];
$reversefieldid=$_REQUEST['reversefieldid'];

$reversetable=$_REQUEST['reversetable'];
$reverseparentid=$_REQUEST['reverseparentid'];
$tabid=$_REQUEST['reversetabid'];
$sql='update ld_reverseformula set activatestatus=? where reversetabid=? and reversetable=? and
       reversefieldtype=? ';

$adb->pquery($sql,array("yes",$tabid,$reversetable,$reversefieldtype));
    
$sql='update ld_reverseformula set activatestatus=? where reversetabid=? and reversetable=? and
       ifnull(reversefieldtype,"")<>? ';
$adb->pquery($sql,array("no",$tabid,$reversetable,$reversefieldtype));

$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');


?>