<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$selecteduserid = vtlib_purify($_REQUEST['selecteduserid']);
$trackpostion_id=vtlib_purify($_REQUEST['trackpostion_id']);
$updateoldquery="UPDATE ld_users  set trackgroupid=0 where trackgroupid=$trackpostion_id";
$adb->pquery($updateoldquery);
$updatenewquery="UPDATE ld_users SET trackgroupid=$trackpostion_id WHERE id IN($selecteduserid)";
$adb->pquery($updatenewquery);
ConvertTojsonString(1,[],'success');
?>