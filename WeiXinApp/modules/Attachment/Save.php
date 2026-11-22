<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$adb;
$mobj = cls_Instance::get_moduleAction_Instance('Attachment','Save');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
if(!empty($_REQUEST['related_to'])){
    $reltab = getSalesEntityType($_REQUEST['related_to']);
}
$mobj->common_save();

$sql='update ld_attachmentsforbills set reltab=?,creator=? where attachmentsid=?';
$adb->pquery($sql,array($reltab,$current_user->id,$mobj->focus->id));
$mobj->ConvertTojsonStringInSave();
?>