<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
global $current_user;
//释放
if(!empty($_REQUEST['record'])){
    $record = $_REQUEST['record'];
    crm_load_class_file("cls_ReleaseLeads", 'modules/Leads');
    $cls_ReleaseAccount = new cls_ReleaseLeads($record,'Leads');
    $releaseAccountReasons = $_REQUEST['releaseAccountReasons'];	//释放原因
    $cls_ReleaseAccount->setReleaseAccount($releaseAccountReasons);
}

ConvertTojsonString(1,array(),'success');
?>