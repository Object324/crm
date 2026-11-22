<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
global $adb;

if(isset($_REQUEST['swiperidstr']) && !empty($_REQUEST['swiperidstr'])){
    $sql = "UPDATE ld_loginsettingsinfo SET sequence = CASE ";

    $idarr = explode(',',$_REQUEST['swiperidstr']);

    for($i = 0;$i < count($idarr);$i++){
        $sql .= " WHEN id = ".$idarr[$i]." THEN ".($i+1);
    }
    $sql .= " END WHERE id IN (".$_REQUEST['swiperidstr'].");";
    $adb->pquery($sql,array());
}
ConvertTojsonString(1,$arr,"success");
?>