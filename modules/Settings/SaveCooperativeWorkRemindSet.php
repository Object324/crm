<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 
 * DESCRIPTION:保存工作汇报提醒设置
 */ 
global $adb;
$dailyvalue=vtlib_purify($_REQUEST['daily']);
$weekvalue=vtlib_purify($_REQUEST['week']);
$monthvalue=vtlib_purify($_REQUEST['month']);
function ChineseWeek($week){
    switch($week){
        case '周一':
            return 1;
            break;
        case '周二':
            return 2;
            break;
        case '周三':
            return 3;
            break;
        case '周四':
            return 4;
            break;
        case '周五':
            return 5;
            break;
        case '周六':
            return 6;
            break;
        case '周日':
            return 7;
            break;
        case '不提醒':
            return 'no';
            break;
    }
 }
 
 function ChineseMonth($month){

    switch($month){
        case '20号':
            return 20;
            break;
        case '25号':
            return 25;
            break;
        case '28号':
            return 28;
            break;
        case '月末':
            return 40;
            break;
        case '下月1号':
            return 1;
            break;
        case '下月2号':
            return 2;
            break;
        case '下月3号':
            return 3;
            break;
        case '下月4号':
            return 4;
            break;
        case '下月5号':
            return 5;
            break;
        case '不提醒':
            return 'no';
            break;
    }
 }
 //BUG20240521-03 ls 240521 移动端工作汇报每日的17.06会自动提醒人(设置了不提醒)
if ($dailyvalue == getFixedLabel('DontRemind')) {
    $dailyvalue = 'no';
}
$weekvalue=ChineseWeek($weekvalue);
$monthvalue=ChineseMonth($monthvalue);
$query="select * from ld_workremindset";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows){
    $query="update ld_workremindset set cooperativeworkdaily=?,cooperativeworkweek=?,cooperativeworkmonth=?";
    //echo $query;
    //dump(array($dailyvalue,$weekvalue,$monthvalue));
    $adb->pquery($query,array($dailyvalue,$weekvalue,$monthvalue));
    
    echo "@#UPDATE@#";
}
else{
   $query="insert into ld_workremindset(cooperativeworkdaily,cooperativeworkweek,cooperativeworkmoth) values(?,?,?)";
    $adb->pquery($query,array($dailyvalue,$weekvalue,$monthvalue));



echo "@#SUCCESE@#"; 
}
$sql='update ld_sys_event set eventdate=? where type=? or type=? or type=?';
$adb->pquery($sql,array('1600-01-01 00:00:00','task_cooperativeworkdaily_eventreminder','task_cooperativeworkmonth_eventreminder','task_cooperativeworkweek_eventreminder'));



?>