<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$currentModule,$current_user,$default_charset;
$tabid = getTabid($currentModule);
crm_load_class_file('cls_rule_validata','include/utils');
$cls_interface_yaoji = new cls_rule_validata($tabid);
if(get_versiontrade() == 'aode') {
    $data = $cls_interface_yaoji->getForAode();
}
$data = $cls_interface_yaoji->get();
if(!empty($data))
	ConvertTojsonString(-1,$data,array());
else
	ConvertTojsonString(1,array('rule_result'=>''),array());
?>