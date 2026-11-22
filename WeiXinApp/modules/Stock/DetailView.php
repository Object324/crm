<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('CommonStock','include/Stock');
/*$focus = cls_Instance::get_moduleAction_Instance('SalesOrder','DetailView');
$json = $focus->set_relatedCreationInfo('5126',$currentModule);
$_REQUEST['relatedCreationInfo'] = $json;*/
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'DetailView');
$details = $mobj->common_getInfo();
echo $details;

?>