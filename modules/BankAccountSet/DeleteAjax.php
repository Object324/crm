<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $adb;

//todo:数据量大优化，can
$sql="SELECT Bankaccountsetid FROM ld_expense 
UNION 
SELECT bankaccountsetid FROM ld_cashbill
UNION 
SELECT bankaccountsetid FROM ld_sendcashbill
UNION
SELECT Outaccount as bankaccountsetid FROM ld_putcash 
UNION
SELECT inaccount as bankaccountsetid FROM ld_putcash 
UNION
SELECT Outaccount as bankaccountsetid FROM ld_cashdeposit 
UNION
SELECT inaccount as bankaccountsetid FROM ld_cashdeposit ";
$result=$adb->pquery($sql,array());
$rowCount = $adb->num_rows($result);
for ($i = 0; $i < $rowCount; $i++) {
    $id_list[] = $adb->query_result($result, $i, 'bankaccountsetid');
}
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
    $storearray = getSelectedRecords($_REQUEST,$returnmodule,$idlist,$excludedRecords);
    $storearray = array_filter($storearray);
    $nosturat = array_filter(array_intersect($storearray,$id_list));
    //$srt = explode(';',$idlist);
    
    echo "#####:success";
    //$stty = array_intersect($storearray,$id_list);
    foreach($storearray as $key=>$arr){
        if(in_array($arr,$id_list)){
            unset($storearray[$key]);
        }
    }
    echo count($storearray)."-";
   echo  $cc = implode(';',$storearray).';&excludedRecords=';
    exit();
    /*if(!empty($nosturat)){
        $nows=1;
    }else{
       $nows=2; 
    }*/
}
else if($_REQUEST['delrecord'])//单个删除
{
    if(in_array($_REQUEST['delrecord'],$id_list)){
        $nows=1;
    }else{
        $nows=2;
    }
}


if($nows==1)
{
    echo "#####:error";
}
else 
{
    echo "#####:success";
}
//exit();
?>