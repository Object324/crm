<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
$mobj = new cls_SaveWX($currentModule);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
//editor:gyq_20191010 reason:参考PC传值
//0038216: （落落计划）企业微信>灵当CRM>合同订单明细界面>相关创建回款计划>进入刚才创建的回款计划明细界面：源单号显示为【0】
if(empty($_REQUEST['salesorder_id']))
    $_REQUEST['salesorder_id'] = $_REQUEST['selectlistval'];
$_REQUEST['entitytypeid'] = $_REQUEST['salesorder_id'];
$_REQUEST['selectsource'] = getSalesEntityType($_REQUEST['salesorder_id']);
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>