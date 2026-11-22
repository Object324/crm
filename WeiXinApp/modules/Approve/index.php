<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$actionname = $_REQUEST['action'];
include(globalStatic::$root_directory . 'WeiXinApp/modules/'.$currentModule.'/'.$actionname.'.php');
?>