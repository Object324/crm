<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 


global $adb;
if($_REQUEST['record'])
{
   
    $sql="select 1 from ld_sendpayment where ( cpstatus='已付') and sendpaymentid=".$_REQUEST['record']."";
  
}
$result=$adb->pquery($sql,array());

if($adb->num_rows($result)>0)
{
    echo "#####:error";
}
else 
{
    echo "#####:success";
}
?>