<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'DetailView');
// 更新消息提醒状态为"已读"
if(!empty($mobj)){
    $focus = CRMEntity::getInstance($currentModule);
    $focus->setStatus($_REQUEST['record'],1);
}
$details = $mobj->common_getInfo();
echo $details;

?>