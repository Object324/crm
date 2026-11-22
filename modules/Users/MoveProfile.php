<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/Users/Profile.class.php');
global $adb;
//weiyannan 20231120 BUG0075295 角色权限拖拽排序
$type = $_REQUEST['type'];
if ($type == 'saveRolePremissionSort') {
    if (!empty($_REQUEST['profileids'])) {
        $profileids_arr = explode(',', $_REQUEST['profileids']);
        $profileseq = 1;
        foreach ($profileids_arr as $profileid) {
            $adb->pquery('update ld_profile set profileseq = ? where profileid = ?', array($profileseq, $profileid));
            $profileseq++;
        }
        ConvertTojsonString(1,array(),"success");
    }
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
?>