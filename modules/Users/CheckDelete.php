<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$module =  $_REQUEST['module'];
$idlist =  $_REQUEST['idlist'];

if($module=='Accounts'){
   $CheckSQL="SELECT 1 FROM $module WHERE accountid in ($idlist) AND approvestatus<>'".constant('D_A_S_APPROVED')."' AND  smownerid=$current_user->id";
   $Checkresult=$adb->pquery($CheckSQL);
   $CheckApproveSQL="SELECT 1 FROM $module WHERE accountid in ($idlist) AND approvestatus<>'".constant('D_A_S_APPROVED')."'";
   $CheckApproveresult=$adb->pquery($CheckApproveSQL);
   $ApproveCount=$adb->num_rows($CheckApproveresult);
   if($ApproveCount<=0){
    echo $adb->num_rows($Checkresult);
   }else{
    echo 0;
   }

}
echo "###CHECKDELETE###";
exit();
?>