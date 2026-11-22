<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance('Ambassador','Save');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>