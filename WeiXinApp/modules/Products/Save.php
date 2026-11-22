<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');

class cls_Products_SaveWX extends cls_SaveWX{
    //对冲提醒
}
//价格信息保存
foreach($_REQUEST['wx_taxInfo'] as $key=>$val){
    $taxname = $val['taxname'];
    $_REQUEST[$taxname]=$val['percentage'];
    $_REQUEST[$taxname.'_check']=$val['check_value'];
}
$mobj = new cls_Products_SaveWX('Products');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
