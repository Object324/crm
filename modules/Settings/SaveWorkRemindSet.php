<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
 * AUTHOR:BY LD KEVIN
 * DATE:2013-05-01
 * DESCRIPTION:保存工作日报提醒设置
 */ 
global $adb;
$dailyvalue=vtlib_purify($_REQUEST['daily']);
$weekvalue=vtlib_purify($_REQUEST['week']);
$monthvalue=vtlib_purify($_REQUEST['month']);
function ChineseWeek($week){
    switch($week){
        case '周一':
        return 1;breack;
        case '周二':
        return 2;breack;
        case '周三':
        return 3;breack;
        case '周四':
        return 4;breack;
        case '周五':
        return 5;breack;
        case '周六':
        return 6;breack;
        case '周日':
        return 7;breack;
        case '不提醒':
        return '不提醒';breack;
    }
 }
 
 function ChineseMonth($month){

    switch($month){
        case '20号':
        return 20;breack;
        case '25号':
        return 25;breack;
        case '28号':
        return 28;breack;
        case '月末':
        return 40;breack;
        case '下月1号':
        return 1;breack;
        case '下月2号':
        return 2;breack;
        case '下月3号':
        return 3;breack;
        case '下月4号':
        return 4;breack;
        case '下月5号':
        return 5;breack;
        case '不提醒':
        return '不提醒';breack;
    }
 }
$weekvalue=ChineseWeek($weekvalue);
$monthvalue=ChineseMonth($monthvalue);
$query="select * from ld_workremindset";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
if($num_rows){
    $query="update ld_workremindset set dailyreminddate=?,weekreminddate=?,monthreminddate=?";
    $adb->pquery($query,array($dailyvalue,$weekvalue,$monthvalue));

    echo "@#UPDATE@#";
}
else{
   $query="insert into ld_workremindset(dailyreminddate,weekreminddate,monthreminddate) values(?,?,?)";
    $adb->pquery($query,array($dailyvalue,$weekvalue,$monthvalue));

echo "@#SUCCESE@#"; 
}



?>