<?php
//editor:gyq_109 reason:日程管理模块  2019/4/30 13:59
//WeiXinApp/index.php?userid=admin&module=Users&action=yan_shi&yan_shi=3600&record=48180
$yan_shi = $_REQUEST['yan_shi'];
$record = $_REQUEST['record'];
global $adb;
$sql = 'select date_start,due_date from ld_activity where activityid=?';
$result = $adb->pquery($sql,array($record));
if($adb->num_rows($result) > 0){
    $date_start = $adb->query_result($result,0,'date_start');
    $due_date = $adb->query_result($result,0,'due_date');
    $new_date_start = date('Y-m-d H:i:s',strtotime($date_start)+$yan_shi);
    $new_due_date = date('Y-m-d H:i:s',strtotime($due_date)+$yan_shi);
    $sql = 'update ld_activity set date_start=?,due_date=? where activityid=?';
    $adb->pquery($sql,array($new_date_start,$new_due_date,$record));
}
ConvertTojsonString(1,array(),'');
