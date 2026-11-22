<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//公海销售线索转公海
crm_load_class_file("cls_ConvertLeads", 'modules/Leads');
$customtype=$_REQUEST['customtype'];	//公海客户转换类型  0：公海转普通  1：普通转公海
$pool_id=$_REQUEST['pool_id'];
$cls_ConvertAccount = new cls_ConvertLeads('Leads',$customtype,$pool_id);
if(isset($_REQUEST['record'])){
    $cls_ConvertAccount->setConvertAccount_more($_REQUEST['record']);
}

ConvertTojsonString(1,array(),'success');
?>