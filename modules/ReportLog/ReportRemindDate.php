<?php
/**
 * AUTHOR:BY LD KEVIN
 * DATE:2013-05-01
 * DESCRIPTION:根据工作报告提醒设置算出提醒范围
 */ 
 global $adb;
 function getReportRemindScope(){
    $query="select * from ld_workremindset";
    $result=$adb->query($query);
    $num_rows=$adb->num_rows($result);
    $datevalue=array();
    $reminddate=array();
    if($num_rows){
        foreach($datevalue as $value){
            switch($value['type']){
                case '0':
                $reminddate['daily']=getDailyScope($value['reminddate']);breack;
                case '1':
                $reminddate['week']=getWeekScope($value['reminddate']);breack;
                case '2':
                $reminddate['month']=getMonthScope($value['reminddate']);breack;
            }
        }
    }
    return $reminddate;
 }
 
 function getDailyScope($time){
    $daily=array($time,'23:59');
    return $daily;
 }

 function getWeekScope($week){
    $nowdate=date('Y-m-d');
    $nowweek=date('l');
    $dayofweek=ChineseWeek($week);
    $nowdayofweek=EnghlishWeek($nowweek);
    $days=$dayofweek-$nowdayofweek-1;
    $edays=7-$nowdayofweek;
    $sdate=date('Y-m-d 00:00:00',strtotime("$days day"));//提醒开始日期
    $edate=date('Y-m-d 23:59:59',strtotime("$edays day"));//提醒结束日期
    $week=array($sdate,$edate);
 }

 function getMonthScope($month){
    $day=(int)date('d');//当天是本月第几天
    $nowdate=date('Y-m-d');
    $daycount=ChineseMonth($month)-(int)date('d')-3;
    $sdate=date('Y-m-d 00:00:00',strtotime("$daycount day"));
    $month=array($sdate);
    return $month;
 }
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
    }
 }
 function EnghlishWeek($week){
    switch($week){
        case 'Monday':
        return 1;breack;
        case 'Tuesday':
        return 2;breack;
        case 'Wednesday':
        return 3;breack;
        case 'Thursday':
        return 4;breack;
        case 'Friday':
        return 5;breack;
        case 'Saturday':
        return 6;breack;
        case 'Sunday':
        return 7;breack;
    }
 }
 
 function EnghlishWeekToShortChinese($week){
    switch($week){
        case 'Monday':
        return '一';breack;
        case 'Tuesday':
        return '二';breack;
        case 'Wednesday':
        return '三';breack;
        case 'Thursday':
        return '四';breack;
        case 'Friday':
        return '五';breack;
        case 'Saturday':
        return '六';breack;
        case 'Sunday':
        return '日';breack;
    }
 }
 
 function ChineseMonth($month){
    $max=date('t');//本月最大天数
    switch($month){
        case '20号':
        return 20;breack;
        case '25号':
        return 25;breack;
        case '28号':
        return 28;breack;
        case '月末':
        return $max;breack;
        case '下月1号':
        return $max+1;breack;
        case '下月2号':
        return $max+2;breack;
        case '下月3号':
        return $max+3;breack;
        case '下月4号':
        return $max+4;breack;
        case '下月5号':
        return $max+5;breack;
    }
 }
 
 function getToday(){
    $today=date('Y-m-d');
    return $today;
 }
//本周日期范围
 function getThisWeekDateScope(){
    $nowweek=date('l');
    $todaynum=EnghlishWeek($nowweek);//当天是本周第几天
    $firstnum=1-$todaynum;
    $lastnum=7-$todaynum;
    $sdate=date('Y-m-d 00:00:00',strtotime("$firstnum day"));
    $edate=date('Y-m-d 23:59:59',strtotime("$lastnum day"));
    $weekdatescope=array($sdate,$edate);
    return $weekdatescope;
 }
 //上周日期范围
 function getLastWeekDateScope($i=1){
    $nowweek=date('l');
    $todaynum=EnghlishWeek($nowweek);//当天是本周第几天
    $firstnum=1-$todaynum-7*$i;
    $lastnum=$firstnum+6;
    $sdate=date('Y-m-d 00:00:00',strtotime("$firstnum day"));
    $edate=date('Y-m-d 23:59:59',strtotime("$lastnum day"));
    $lastweekdatescope=array('sdate'=>$sdate,'edate'=>$edate);
  
    return $lastweekdatescope;
 }
//下周日期范围
 function getNextWeekDateScope($i=1){
    $nowweek=date('l');
    $todaynum=EnghlishWeek($nowweek);//当天是本周第几天
    $firstnum=7*$i-$todaynum+1; 
    $lastnum=$firstnum+6;
    $sdate=date('Y-m-d 00:00:00',strtotime("$firstnum day"));
    $edate=date('Y-m-d 23:59:59',strtotime("$lastnum day"));
    $nextweekdatescope=array('sdate'=>$sdate,'edate'=>$edate);
    return $nextweekdatescope;
 }
//过去五天日期
 function getLastFiveDay(){
    $days=array();    
    for($i=1;$i<6;$i++){
        $s=0-$i;
        $days[]=array('daily'=>date('d',strtotime("$s day")),
        'week'=>EnghlishWeekToShortChinese(date('l',strtotime("$s day")))
        );        
    }
    return $days;
 }

 //本年52个周时间范围
 function getWeekOfYearDate(){
    $nowweekofyear=date('W');//本周是第几周
    $weekdate=array();
    //本周之前
    for($i=$nowweekofyear-1;$i>0;$i--){
        $week=getLastWeekDateScope($i);        
        $weekdate[date('W',strtotime($week['sdate']))]=$week;
    }  
    //本周
    $week=getThisWeekDateScope();
    $weekdate[$nowweekofyear]=$week;
    for($i=1;$i<53-$nowweekofyear;$i++){
        $week=getNextWeekDateScope($i);
       
        $weekdate[date('W',strtotime($week['sdate']))]=$week;
    }
    return $weekdate;
 }
 
 /*//获取本月日期周
 function getThisMonthWeek(){
    $nowweek=date('l');
    $nowday=date('d');
    $maxday=date('t');    
    $monthweekdate=array();
    for($i=$nowday;$i>=1;$i--){
        $kday=1-$i;
        $monthweekdate[date('d',strtotime("$kday day"))]=EnghlishWeekToShortChinese(date('l',strtotime(date('Y-m-d',strtotime("$kday day")))));
    }   
    for($j=1;$j<=$maxday-$nowday;$j++){        
        $monthweekdate[date('d',strtotime("$j day"))]=EnghlishWeekToShortChinese(date('l',strtotime(date('Y-m-d',strtotime("$j day")))));      
    }

 }*/

 /**
  * @param $i=0为当前月 $i>0为未来的月（如$i=1 下个月）； $i<0为过去的月（如$i=-1 上个月）
  * 月份（几号，星期）
  */ 
 function getMonthWeek($i=1){
    $date=date('Y-m-d',strtotime("0 days,$i month,0 year"));//上个月的今天
    $week=date('l',strtotime($date));
    $day=date('d',strtotime($date));
    $maxday=date('t',strtotime($date));
    $monthweekdate=array();
     for($i=$day;$i>=1;$i--){
        $kday=1-$i;
        $monthweekdate[date('d',strtotime("$kday days,$i month,0 year"))]=EnghlishWeekToShortChinese(date('l',strtotime(date('Y-m-d',strtotime("$kday days,$i month,0 year")))));
    }   
    
    for($j=1;$j<=$maxday-$day;$j++){        
        $monthweekdate[date('d',strtotime("$j days,$i month,0 year"))]=EnghlishWeekToShortChinese(date('l',strtotime(date('Y-m-d',strtotime("$j days,$i month,0 year")))));      
    }   
    return $monthweekdate;
 }
?>
