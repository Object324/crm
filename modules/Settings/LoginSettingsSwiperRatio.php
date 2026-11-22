<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
global $adb;

if($_REQUEST['type'] && !empty($_REQUEST['type'])){
    $sql = "update ld_loginsettingsinfo set content = ? where `name` = 'swiperratio';";
    $adb->pquery($sql,array($_REQUEST['type']));
}

ConvertTojsonString(1,array(),"success");
?>