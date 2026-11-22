<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if(!empty($_REQUEST['record'])){
	$record = $_REQUEST['record'];
	crm_load_class_file("cls_DelayAccount", 'modules/Accounts');
	$cls_DelayAccount = new cls_DelayAccount($record,'Accounts');
	$txtdelay = $_REQUEST['txtdelay'];	//延期天数
	$cls_DelayAccount->setDelayAccount($txtdelay);
	
}

ConvertTojsonString(1,array(),'success');
?>