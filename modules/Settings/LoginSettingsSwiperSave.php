<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb;
$swiperid = $_REQUEST['swiperid'];

if($swiperid > 0){
    $sql = 'UPDATE ld_loginsettingsinfo set isshow = ?,content = ?,url = ? where id = ?;';
    $adb->pquery($sql,array($_REQUEST['isshow'],$_REQUEST['content'],$_REQUEST['url'],$swiperid));
}
else{

    $query = "select content from ld_loginsettingsinfo where `name` = 'swiperratio';";
    $result = $adb->pquery($query,array());
    $swiperratio = $adb->query_result($result,0,'content');

    $sql = "select MAX(sequence)+1 as sequence from ld_loginsettingsinfo where `name` = 'loginswiper' and swipertype = ?;";
    $result = $adb->pquery($sql,array($swiperratio));
    $sequence = $adb->query_result($result,0,'sequence');
    $insertsql = "INSERT INTO `ld_loginsettingsinfo` (`name`, `isshow`, `isedit`, `content`, `url`, `type`, `swipertype`, `sequence`) VALUES ('loginswiper', ?, 'yes', ?, ?, 'custome', ?, ?);";
    $adb->pquery($insertsql,array($_REQUEST['isshow'],$_REQUEST['content'],$_REQUEST['url'],$swiperratio,$sequence));
}

ConvertTojsonString(1,array(),'success');

?>