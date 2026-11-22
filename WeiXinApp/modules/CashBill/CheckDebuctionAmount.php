<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;

if(isset($_REQUEST['jsstr'])){    
    $jsstr=json_decode($_REQUEST['jsstr'],true);
}
else{
    $jsstr='';
}
$record=$_REQUEST['record'];
crm_load_class_file("cls_CheckDebuctionInfo",'modules/CashBill');
$checkobj=new cls_CheckDebuctionInfo($_REQUEST['record'],$jsstr);
$checkobj->Check($_REQUEST['accountid'],$_REQUEST['bankaccountsetid']);
$checkobj->setEcho();
?>