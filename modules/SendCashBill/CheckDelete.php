<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$recordid=$_REQUEST['recordid'];
$sql="SELECT 1 FROM ld_sendcashbill where sendcashbillid=$recordid and checkoutstatus='已审核'";
$result=$adb->pquery($sql,array());
$rowCount = $adb->num_rows($result);
        if($rowCount==0){
            echo "#####:error";
        }else{
            echo "#####:success";
        }
?>