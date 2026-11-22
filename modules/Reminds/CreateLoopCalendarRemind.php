<?php
error_reporting(E_ALL^E_NOTICE^E_WARNING);
$root_dir= dirname(dirname(dirname(__FILE__)));
date_default_timezone_set('Asia/Shanghai');
global $adb;

require_once($root_dir.'/includefile.php');
if(!$adb)
{
    $adb=PearDatabase::getInstance();
}
$focus = CRMEntity::getInstance('Calendar');

$startdate = $curdate = date("Y-m-d");
$enddate = date("Y-m-d")." 23:59:59";

//移动端参数设置是否接收消息提醒暂时不判断(后面业务如果需要判断,再循环的单据的时候再判断负责人是否要接收即可,已沟通)
//这里需要解析的提醒单据 全都是设置为重复提醒的单据
$eventstatus_where = '';
if (array_key_exists('eventstatus',$focus->fieldobj->getModuleAllPreseneceFields())) {
    $eventstatus_where = " AND ld_activity.eventstatus <> '已执行' ";
}
$sql = "SELECT 
	ld_activity.`subject`,
	ld_activity.date_start,
	ld_activity.smownerid,
    ld_loopcalendar_reminds.*
FROM
	ld_activity
INNER JOIN ld_loopcalendar_reminds  ON ld_loopcalendar_reminds.activityid = ld_activity.activityid
WHERE
	ld_activity.deleted = 0
AND ld_activity.activitytype <> 'emails'
$eventstatus_where
AND ifnull(ld_loopcalendar_reminds.reminder_setting,'') <> ''
AND ifnull(ld_loopcalendar_reminds.loop_type, 'norepeat') <> 'norepeat'
AND ld_activity.date_start <= ?  
AND (
	ifnull(ld_loopcalendar_reminds.expiredate, '') = '' 
	OR ld_loopcalendar_reminds.expiredate >= ? 
) 
AND NOT EXISTS(SELECT 1 FROM ld_sys_event WHERE type='LoopCalendarCreateRemind' AND DATE(eventdate) = CURDATE());
";
$result = $adb->pquery($sql,array($enddate,$curdate));

$adb->pquery("update ld_sys_event set eventdate=NOW() where type='LoopCalendarCreateRemind'");
$focus->parseLoopCalendarRemindsResult($result,$startdate,$enddate);








?>