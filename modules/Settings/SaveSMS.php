<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$sms_platform = trim($_REQUEST['sms_platform']);
//敏感信息加密
$sms_username = encryptStringByLabel(trim($_REQUEST['sms_username']),'sms_username'.$sms_platform);
$sms_password = encryptStringByLabel(trim($_REQUEST['sms_password']),'sms_password'.$sms_platform);

$adb->pquery("update ld_communicationaccount set status=?",array('no'));
$select_result = $adb->pquery("select * from ld_communicationaccount where platform=? limit 1", array($sms_platform));

if ($adb->num_rows($select_result) > 0) {
    $query="update ld_communicationaccount set account_name=? , account_pwd=? , autograph=?,service_tel=?,status=? where platform=?";
    $adb->pquery($query,array($sms_username,$sms_password,$_REQUEST['sms_autograph'],$_REQUEST['service_tel'],"yes",$sms_platform));
}else{
    $query="insert into ld_communicationaccount(account_name,account_pwd,autograph,service_tel,status,platform)
    value(?,?,?,?,?,?)";
    $adb->pquery($query,array($sms_username,$sms_password,$_REQUEST['sms_autograph'],$_REQUEST['service_tel'],'yes',$sms_platform));
}


$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),"success");
?>