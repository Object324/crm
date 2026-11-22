<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
$mobj = new cls_SaveWX($currentModule);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$_REQUEST['entitytypeid'] = $_REQUEST['salesorder_id'];
$_REQUEST['selectsource'] = getSalesEntityType($_REQUEST['salesorder_id']);
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>