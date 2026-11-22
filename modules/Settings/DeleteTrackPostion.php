<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$trackpostion_id=$_REQUEST['trackpostion_id'];
$deletequery="DELETE  from ld_trackpostion where trackpostion_id=$trackpostion_id";
$adb->pquery($deletequery);
$update_sql = 'update ld_users set trackgroupid = 0 where  trackgroupid = ?';
$adb->pquery($update_sql,[$trackpostion_id]);
ConvertTojsonString(1,[],"success");
exit();
?>