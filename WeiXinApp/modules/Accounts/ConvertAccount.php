<?php
/**
 * 公海客户类型转换
 * User: chj
 * Date: 2018-03-01
 */
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file("cls_ConvertAccount", 'modules/Accounts');
$customtype=$_REQUEST['customtype'];	//公海客户转换类型  0：公海转普通  1：普通转公海 
$pool_id=$_REQUEST['pool_id'];
$cls_ConvertAccount = new cls_ConvertAccount('Accounts',$customtype,$pool_id);
if(isset($_REQUEST['record'])){
	$cls_ConvertAccount->setConvertAccount_more($_REQUEST['record']);
}

ConvertTojsonString(1,array(),'success');
?>