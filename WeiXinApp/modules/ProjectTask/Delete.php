<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);
$focus->id = $_REQUEST['record'];
$focus->retrieve_entity_info($focus->id, $currentModule);

if(!empty($focus->column_fields['projectid'])){
    InsertProjectabstract($focus->column_fields['projectid'],$_REQUEST['record'],$_REQUEST['module'],'delete');
}
//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
if(Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    ConvertTojsonString('-1',null,$srt1);
}else{
    $arr = DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'',"yes");
}
if(array_key_exists("projectid",$focus->column_fields))
{
    $projectids=array($focus->column_fields['projectid']);
    $focus->updateRelated_Project($projectids);
}
ConvertTojsonString('1',$arr,'');