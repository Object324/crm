<?php
global $adb,$current_user;
$recordid=$_REQUEST['recordid'];
$sql="SELECT 1 FROM ld_cashbill where cashbillid=$recordid and checkoutstatus='已审核'";
$result=$adb->pquery($sql,array());
$rowCount = $adb->num_rows($result);
        if($rowCount==0){
            echo "#####:error";
        }else{
            echo "#####:success";
        }
?>