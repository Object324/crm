<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('CommonStock','include/Stock');

$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
  
}
$mobj->common_save();

$system = getSys_deploy(146);
if($system['deploy_value']==1&&$_REQUEST['previousAction']=='CreateView'){
    crm_load_class_file('cls_MassAdd','appCommon/modules/Payment');
    $massadd = new cls_MassAdd($mobj->focus->id,'Invoice');
    $massadd->masssave();
}
$mobj->ConvertTojsonStringInSave();
?>