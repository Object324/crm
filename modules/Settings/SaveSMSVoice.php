<?php
global $adb;
//组合模板
$templateId = $_REQUEST['templateId'];
$templateName = $_REQUEST['templateName'];
if(empty($templateId)||empty($templateName)){
    ConvertTojsonString(-1,array(),"语音模板至少需要保存一个！");
}
$templateId = explode(',',$templateId);
$templateName = explode(',',$templateName);

$para_content_arr = array_combine($templateId,$templateName);

$para_content_str = ldcrm_json_encode($para_content_arr);
$SecretId = $_REQUEST['SecretId'];
$SecretKey = $_REQUEST['SecretKey'];
$SDKAppId = $_REQUEST['SDKAppId'];
$query="update ld_wx_config set  para_content=?,para_one='$SecretId',para_two='$SecretKey',para_three='$SDKAppId' where `name` ='tencentcloud_sms_voice'";
$res = $adb->pquery($query,array($para_content_str));
$rows = $adb->getAffectedRowCount($res);
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array($rows),"success");