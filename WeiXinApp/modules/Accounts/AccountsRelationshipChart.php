<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule;
$frommodule = $_REQUEST['frommodule'];
$fromrecordid = $_REQUEST['fromrecordid'];
crm_load_class_file('cls_relationshipChart','modules/lingdang');
$cls_relationshipChartobj = cls_relationshipChart::getInstance($currentModule,$fromrecordid,$frommodule);
$arr = $cls_relationshipChartobj->getRelationshipChartAllDataOnMobile();
//释放对象
$cls_relationshipChartobj->clearSelfRelatedObj();
unset($frommodule,$fromrecordid,$cls_relationshipChartobj);

ConvertTojsonString(1,$arr,'success');

?>