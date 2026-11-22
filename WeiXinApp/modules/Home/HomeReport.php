<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_159 reason:获取个人显示的报表列表   2019/11/13 18:12 ID1000638
crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
$obj = new WorkReportControllerWX();
$action = $_REQUEST['action'];
$obj->$action();
?>