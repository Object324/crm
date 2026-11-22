<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
global $adb;
if($_REQUEST['swiperid'] && $_REQUEST['swiperid'] > 0){
    $selectsql = 'select type from ld_loginsettingsinfo where id = ?;';
    $result = $adb->pquery($selectsql,array($_REQUEST['swiperid']));
    $type = $adb->query_result($result,0,'type');
    if($type == 'default'){
        $sql = "update ld_loginsettingsinfo set isedit = 'no' where id = ?;";
        $adb->pquery($sql,array($_REQUEST['swiperid']));
    }else{
        $sql = 'DELETE from ld_loginsettingsinfo where id = ?;';
        $adb->pquery($sql,array($_REQUEST['swiperid']));
    }
}

ConvertTojsonString(1,array(),"success");
?>