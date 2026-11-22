<?php
global $adb;
if($_REQUEST['idstring'])
{
  //  $ids=$_REQUEST['idstring'];
    $customtype=$_REQUEST['customtype'];
   // $storearray=explode(";",$ids);
   $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
   $storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
    $storearray = array_filter($storearray);
    $ids=implode(",",$storearray);
    
    if($customtype==1)//由普通转为公海
    {
        $sql='select 1 from ld_account  where publicaccount=0 and accountid in('.$ids.")";
        
    }
    elseif($customtype==0)//由公海转为普通
    {
         $sql='select 1 from ld_account  where publicaccount>0 and accountid in('.$ids.")";
    }
    $result=$adb->pquery($sql,array());
    echo $sql;
    if($adb->num_rows($result)>0)
    {
       
    }
    else
    {
         echo "###error###";
         echo $sql;
    }
    exit();
}


?>