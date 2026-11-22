<?php
include(globalStatic::$root_directory."include/RecordEncrypt.php");
$Obj=new RecordEncrypt("Accounts",$_REQUEST['accountid']);
$accountid=  $Obj->decrypt();

if(empty($accountid))
{
    exit();
}

global $adb;
$campaignid=$_REQUEST['campaignid'];

$sql='update ld_campaignaccountrel set campaignaccountrelstatus=? where campaignid=? and accountid=? ';
$adb->pquery($sql,array($_REQUEST['status'],$campaignid,$accountid));

?>