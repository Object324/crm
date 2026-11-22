<?php
//zkt 20231020 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance('CustomForm160','Save');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>