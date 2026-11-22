<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_113 reason:新增知识管理模块  2019/5/20 16:26 
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
global $currentModule;
$mobj = new cls_DetailViewWX($currentModule);
$details = $mobj->common_getInfo();
echo $details;

?>