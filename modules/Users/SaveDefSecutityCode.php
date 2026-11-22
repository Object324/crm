<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * edit:kevin
 * date:2013-06-04
 * reason:读文件写文件
 */ 
global $adb;
$query="select status from ld_code";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows){
    $status=$adb->query_result($result,0,'status');
    $query="update ld_code set status=?";
    if($status==0){
        $adb->pquery($query,array(1));
    }
    else{
        $adb->pquery($query,array(0));
    }
}
?>

