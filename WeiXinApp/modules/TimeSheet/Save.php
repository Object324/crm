<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');

class cls_Products_SaveWX extends cls_SaveWX{
    //对冲提醒
}
foreach($_REQUEST['wx_productFieldInfo'] as $key=>$val){
    $_REQUEST[$key] = $val;
}
foreach($_REQUEST['p_total'] as $key=>$val){
    $_REQUEST[$key] = $val['value'];
}
$mobj = new cls_Products_SaveWX('TimeSheet');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息

$mobj->common_save();
$mobj->ConvertTojsonStringInSave();

?>