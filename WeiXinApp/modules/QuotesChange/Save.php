<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息

if(!empty($_REQUEST['relatedCreationInfo'])){
    $relateinfo = Zend_Json::decode($_REQUEST['relatedCreationInfo']);
    $_REQUEST['quote_id'] = $relateinfo['fromid'];
}

$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>