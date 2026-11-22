<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb,$current_user;;
$focus = CRMEntity::getInstance($currentModule);

if(!isset($_REQUEST['record']))
    die($mod_strings['ERR_DELETE_RECORD']);

//工作汇报列表删除
DeleteEntity($_REQUEST['module'],$_REQUEST['return_module'],$focus,$_REQUEST['record'],$_REQUEST['return_id']);

echo '##YES##';
?>