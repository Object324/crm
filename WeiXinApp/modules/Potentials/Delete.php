<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);
$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
//wym 240528 1000063 合同订单等模块增加有关联单据不允许删除功能（王耀文）
if(Delverify($_REQUEST['module'],$_REQUEST['record'])>0){
    $srt1 = getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED');
    ConvertTojsonString('-1',null,$srt1);
}else{
    $arr = DeleteEntity($_REQUEST['module'],$_REQUEST['module'],$focus,$_REQUEST['record'],'',"yes");
}

if($focus->column_fields['account_id']>0)
{
    $focus->updateRelatedTableInfo('ld_account',array($focus->column_fields['account_id']));

}
ConvertTojsonString('1',$arr,'');
?>