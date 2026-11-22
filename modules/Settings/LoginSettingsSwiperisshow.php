<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
global $adb;
if($_REQUEST['swiperid'] && $_REQUEST['swiperid'] > 0){

    $select = "select COUNT(id) as num from ld_loginsettingsinfo where `name` = 'loginswiper' and isshow = 'yes' and isedit = 'yes';";
    $result = $adb->pquery($select,array());
    $num = $adb->query_result($result,0,'num');
    if($num <= 1){
        ConvertTojsonString(2,array(),"success");
    }else{
        $sql = 'update ld_loginsettingsinfo set isshow = ? where id = ?;';
        $adb->pquery($sql,array($_REQUEST['isshow'],$_REQUEST['swiperid']));
    }

}

ConvertTojsonString(1,array(),"success");
?>