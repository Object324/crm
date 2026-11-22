<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();

$system = getSys_deploy(15);
if($system['deploy_value']==0&&$_REQUEST['previousAction']=='CreateView'){
    crm_load_class_file('cls_MassAdd','appCommon/modules/SendPayment');
    $massadd = new cls_MassAdd($mobj->focus->id,'PurchaseOrder');
    $massadd->masssave();
}

$mobj->ConvertTojsonStringInSave();
?>