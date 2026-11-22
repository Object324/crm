<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $adb;
if($_REQUEST['idlist'])//批量删除
{
    $idlist = vtlib_purify($_REQUEST['idlist']);
    
    $returnmodule = vtlib_purify($_REQUEST['return_module']);
    $return_action = vtlib_purify($_REQUEST['return_action']);
    $excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
    $rstart='';
    //Added to fix 4600
    $url = getBasic_Advance_SearchURL();
    //split the string and store in an array
    $storearray = getSelectedRecords($_REQUEST,'PaymentPlan',$idlist,$excludedRecords);
    $storearray = array_filter($storearray);
    $ids=implode(",",$storearray);   
    $sql="select 1 from ld_paymentplan where (paymentstatus='部分已收' or paymentstatus='已收') and paymentplanid in($ids)";   
  
}
else if($_REQUEST['delrecord'])//单个删除
{
   
    $sql="select 1 from ld_paymentplan where (paymentstatus='部分已收' or paymentstatus='已收') and paymentplanid=".$_REQUEST['delrecord']."";
  
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
//exit();
?>