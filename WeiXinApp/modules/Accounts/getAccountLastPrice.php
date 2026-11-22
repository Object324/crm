<?php
/**
 * 
 * date: 2017/6/21
 * reason：选择客户获取最近价格
 */
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include globalStatic::$root_directory.'modules/Accounts/getAccountLastPrice.php';



?>
