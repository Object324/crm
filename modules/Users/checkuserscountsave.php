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

$user_type = 'crm';
if($_REQUEST['user_type'] && !empty($_REQUEST['user_type'])){
    $user_type = $_REQUEST['user_type'];
}

$reg=RegOp::getInstance();
if($user_type == 'crm'){
    $user_query="select 1 from ld_users where status='active' and crm_user_type = 'crm'";
    $result=$adb->pquery($user_query);
    $strUsingCount=$adb->num_rows($result);
    $regCount=$reg->GetUserCount();
}
else{
    $user_query="select 1 from ld_users where status='active' and crm_user_type = 'prm'";
    $result=$adb->pquery($user_query);
    $strUsingCount=$adb->num_rows($result);
    $regCount=$reg->getPrmUserCount();
}

if($reg->compareCount($regCount,$strUsingCount+1) <= 0){
    ConvertTojsonString(1,array(),"success"); //需要提示
}
else{
    ConvertTojsonString(2,array(),"success");
}

?>