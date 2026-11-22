<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include('include/ReportLog/CommonReportLog.php');
global $adb;

$CommonLog=new CommonReportLog();
 $smcreatorid=$_REQUEST['smCreatorId'];
 $startdate=$_REQUEST['StartDate'];
 $enddate=$_REQUEST['EndDate'];
 $createTime=date("Y-m-d H:i:s");
 $status=$_REQUEST['status'];
$ReportLogId=$_REQUEST['ReportLogId'];
$yearBol=$CommonLog->getYear($enddate);
 $submitTime=date("Y-m-d H:i:s");
 $delayDays='';
 $submitdate=date('Y-m-d',strtotime($submitTime));

//日报保存
if(isset($_REQUEST['ReportLogType']) && $_REQUEST['ReportLogType']==0)
{    
    $dailysummary=fck_from_html($_POST['DailySummary']);    
    $tomrrowplan=fck_from_html($_POST['TomrrowPlan']);    
    $year=$CommonLog->getYear($startdate);
    $month=$CommonLog->getMonthOfYear($startdate);
    $day=$CommonLog->getDay($startdate);
    $week=$CommonLog->getWeekBol($startdate);
    if($_REQUEST['status']==1){
        $sql="select dailyreminddate from ld_workremindset";
        $result=$adb->pquery($sql,array());
        $dailyreminddate=$adb->query_result($result,0,0);
        if($dailyreminddate!='不提醒'){
             $delayDays=$CommonLog->getdiffdate($startdate,$submitdate);
        }
        else{
            $delayDays=0;
        }   
    }
    if($ReportLogId>0){
        $sql="update ld_dailyreport set worksummary=?,tomorrowplan=?";        
        $sql .=" ,submitdate=?,delaydays=? ,dstatus=?";        
        $sql .=" where dailyid=?";      
        $adb->pquery($sql,array($dailysummary,$tomrrowplan,$submitTime,$delayDays,$status,$ReportLogId));
    }
    else{
         
        $maxid= $adb->getUniqueID("ld_dailyreport");
        $query="insert into ld_dailyreport(dailyid,worksummary,tomorrowplan,dstatus,startdate,submitdate,smcreatorid,
                createdtime,delaydays,dyear,dmonth,dday,dweek) ";
        $query .="values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
      
        $adb->pquery($query,array($maxid,$dailysummary,$tomrrowplan,$status,$startdate,$submitTime,
        $smcreatorid,$createTime,$delayDays,$year,$month,$day,$week));
    }
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
    //header("Location:index.php?module=ReportLog&action=DailyReportLog&reporttype=".$_REQUEST['reporttype']."&EndDate=".$startdate."&StartDate=".$startdate);
    //exit();
}


///周报保存
if(isset($_REQUEST['ReportLogType']) && $_REQUEST['ReportLogType']==1)
{
  
   
   $MonthOfYear=$CommonLog->getMonthOfYear($enddate);
   $weekOfYear=$CommonLog->getWeeksofYear($enddate);
  
    if($_REQUEST['status']==1)
    {
        $sql="select weekreminddate from ld_workremindset";
        $result=$adb->pquery($sql,array());
        $weekreminddate=$adb->query_result($result,0,0);
        
        $weekBol=$CommonLog->getWeekBol(date('Y-m-d'));
        if($weekreminddate!='不提醒'){
            $delayDays=$CommonLog->getdiffdate($enddate,$submitdate);
        }
        else{
            $delayDays=0;
        }
        
    }
    $workSummary=fck_from_html($_POST['WorkSummary']);
    $nextWeekPlan=fck_from_html($_POST['NextWeekPlan']);
     /*$sql="select 1 from ld_WeekReport 
                where yearBol=$yearBol and monthofyear=$MonthOfYear
                        and weekofyear=$weekOfYear and smcreatorid=$smcreatorid";
     $result=$adb->pquery($sql,array());*/
    if($ReportLogId>0)//更新
    {
        $sql="update ld_weekreport set worksummary=?,nextweekplan=?";
        
        $sql .=" ,submitdate=?,delaydays=? ,status=?";
        
        $sql .=" where weekreportid=?";
        $adb->pquery($sql,array($workSummary,$nextWeekPlan,$submitTime,$delayDays,$status,$ReportLogId));
    }
    else//插入
    {

        $maxid= $adb->getUniqueID("ld_weekreport");
      
        $sql="insert into ld_weekreport(weekreportID,worksummary,nextweekplan,status,startdate,enddate,createdtime,smcreatorid, yearbol,monthofyear,weeksofyear,submitdate,delaydays)";
       $sql .="values(?,?,?,?,?,?,?,?,?,?,?,?,?)";

       $adb->pquery($sql,array($maxid,$workSummary,$nextWeekPlan,$status,
                                        $startdate,$enddate,$createTime,$smcreatorid,
                                        $yearBol,$MonthOfYear,$weekOfYear,$submitTime,$delayDays));

                                              
    }
    $_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
    //header("Location:index.php?module=ReportLog&action=WeekReportLog&EndDate=".$enddate."&StartDate=".$startdate);
    //exit();
                        
}


///月报保存
if(isset($_REQUEST['ReportLogType']) && $_REQUEST['ReportLogType']==2)
{
    $MonthOfYear=$CommonLog->getMonthOfYear($enddate);

     $workSummary=fck_from_html($_POST['WorkSummary']);
    $nextMonthPlan=fck_from_html($_POST['NextMonthPlan']);
    $status=$_REQUEST['status'];
     $sql="select monthreminddate from ld_workremindset";
     $result=$adb->pquery($sql,array());
     $monthreminddate=$adb->query_result($result,0,0);
    
     if($monthreminddate==40)
     $monthreminddate=date('t');
     $MonthDays=$CommonLog->getMonthDays($enddate);//本月最大天数
     $RealAwokeDays=$monthreminddate;//提醒时间
     $nowDay=date("d",$submitTime);//提交日期几号
     if($status==1){
        if($monthreminddate!='不提醒'){
            if($monthreminddate<10){//下月提醒
            $reminddate=date('Y-m-d',strtotime($enddate.$monthreminddate.'days'));
             }
             elseif($monthreminddate>10){
                $reminddate=date('Y-m-d',strtotime($enddate));
             }
                         
             $delayDays=$CommonLog->getdiffdate($reminddate,$submitdate);
        }
        else{
            $delayDays=0;
        }
        
     }
     
     
     /*if($monthreminddate<10)//下月提醒
     {
        $RealAwokeDays=$MonthDays+$monthreminddate;
     }
     else if($MonthDays==date('t'))//代表“月末"
     {
        $RealAwokeDays=$MonthDays;
     }
     if($nowDay<$RealAwokeDays)
     {
        $delayDays=$RealAwokeDays-$nowDay;
     }*/
     $monthId=$adb->getUniqueID("ld_monthreport");
     if($ReportLogId>0)
     {
          $sql="update ld_monthreport set worksummary=?,nextmonthplan=?";
          $sql .=" ,submitdate=?,delaydays=? ,status=?";
          $sql .=" where monthreportid=?";
          $adb->pquery($sql,array($workSummary,$nextMonthPlan,$submitTime,$delayDays,$status,$ReportLogId));
     }
     else 
     {
		
		
        $sql="Insert into ld_monthreport(monthreportid,worksummary,nextmonthplan,submitDate,delaydays,
                                         createdtime,smcreatorid,yearbol,monthofyear,startdate,enddate,status) ";
        $sql .=" values(?,?,?,?,?,?,?,?,?,?,?,?)";
        $adb->pquery($sql,array($monthId,$workSummary,$nextMonthPlan,$submitTime,$delayDays,$createTime,$smcreatorid,
                                $yearBol,$MonthOfYear,$startdate,$enddate,$status));
        
     }
    $_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
     //header("Location:index.php?module=ReportLog&action=MonthReportLog&StartDate=$startdate&EndDate=$enddate&monthOpt=".$MonthOfYear);
     // exit();
    
}

?>