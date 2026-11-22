<?php
/**
* @edit:dong
* @data:2020/7/8
* @reason: 社交推广外部访问 阅读次数自增
* @description:
*/

require_once ('ExternalAccessRequire.php');
$record = intval(vtlib_purify($_REQUEST['record']));
$userid = intval(vtlib_purify($_REQUEST['uid']));
// @edit:dong @date:2020/07/16 @reason: 插入访问记录表
$sql = 'INSERT INTO ld_socialpromotionformviewlist(`socialpromotionid`,`shareuserid`,`viewtime`) VALUES (?,?,?);';
$adb->pquery($sql,array($record,$userid,date('Y-m-d H:i:s')));
$id = $adb->getLastInsertID();
// @edit:dong @date:2020/07/16 @reason: 更新单据表 的访问统计字段
if($id){
    $upSql = 'UPDATE ld_socialpromotion SET activityviews = activityviews+1 where socialpromotionid = ?';
    $adb->pquery($upSql,array($record));
}
ConvertTojsonString(1,array('num'=>$id),'success');