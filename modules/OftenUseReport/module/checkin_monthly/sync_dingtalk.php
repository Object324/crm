<?php
//editor:gyq_155 reason:钉钉考勤同步  2019/10/28 14:31 ID1000624
header('Content-Type:text/html;charset=UTF-8');
date_default_timezone_set("Asia/Shanghai");
global $adb,$current_user;
$_REQUEST['diony'] = 'diony';
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
require_once globalStatic::$root_directory. 'modules/OftenUseReport/module/checkin_monthly/AttendanceDingTalk.php';
include_once globalStatic::$root_directory.'WeiXinApp/dingtalk/lib/TopSdk.php';
$model_api = new AttendanceDingTalk();
//``````````获取系统配置参数
$model_api->init_config();
//`````````````获取打卡接口秘钥
$token = $model_api->gettoken();
//`````````````获取待同步的成员列表
$sql = 'select dingtalk_userid,id,groupid,last_name from ld_users where status=? and deleted=? and ifnull(dingtalk_userid,\'\')<>\'\'';
$result = $adb->pquery($sql,array('Active',0));
$nums  = $adb->num_rows($result);
$useridlist;
for($i=0;$i<$nums;$i++) {
    $useridlist[$i] = $adb->query_result($result, $i, 'dingtalk_userid');
}
//```````````格式化同步时间范围
$attendanceList = array();
if(empty($_REQUEST['startmonth']))
    ConvertTojsonString(-1,array($_REQUEST),'日期参数丢失');
$workDateFrom = $_REQUEST['startmonth'].' 00:00:00';
$workDateTo = $_REQUEST['endmonth'].' 23:59:59';
$model_api->setUserList($useridlist);
//获取指定区间的打卡信息
$attendanceList = $model_api->getAttendanceList($workDateFrom,$workDateTo,$attendanceList);
//批量获取企业考勤组详情
$model_api->getSimpleGroups();
//清除指定区间的旧打卡信息
$sql = 'delete from ld_wx_checkin_dingtalk where userchecktime_date between ? and ?';
$adb->pquery($sql,array($workDateFrom,$workDateTo));
//zxm 20230504
foreach ($attendanceList as $keytwo=>$value){
    //foreach ($content as $keytwo=>$value){
        $sql = 'insert into ld_wx_checkin_dingtalk (id, userid, groupid, planid, recordid, checktype, timeresult, workdate_date,
                                    basechecktime_date, userchecktime_date,workdate, basechecktime, userchecktime,
                                    locationresult, approveid, procinstid, sourceType) value (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
        $adb->pquery($sql, array($value['id'], $value['userId'], $value['groupId'], $value['planId'],
            $value['recordId'], $value['checkType'],$value['timeResult'],
            dateMilliscond($value['workDate']),
            dateMilliscond($value['baseCheckTime']),
            dateMilliscond($value['userCheckTime']),
            $value['workDate'],
            $value['baseCheckTime'],
            $value['userCheckTime'],
            $value['locationResult'],$value['approveId'],$value['procInstId'],$value['sourceType']));
    //}
}
ConvertTojsonString(1,array($attendanceList),'success');