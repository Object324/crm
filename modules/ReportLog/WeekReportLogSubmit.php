<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

require_once('Smarty_setup.php');
include('include/ReportLog/CommonReportLog.php');
$CommonLog=new CommonReportLog();
$smarty=new lingdangCRM_Smarty();
if(isset($_REQUEST['date'])&&$_REQUEST['date']!=''){
    $y=$_REQUEST['date'];
}
else{
    $date=date('Y-m-d');
    $year=$CommonLog->getYear($date);//当前年
    $y=$year;
}
function getLastYear($year){
    $lastyear=$year-1;
    return $lastyear;
}
function getNextYear($year){
    $nextyear=$year+1;
    return $nextyear;
}

$smarty->assign('LAST',array('last'=>getLastYear($y),'lastname'=>'Previous_year'));
$smarty->assign('NOWMONTH',$y);

if($y<date('Y'))
$smarty->assign('NEXT',array('next'=>getNextYear($y),'nextname'=>'year_later'));

function getMaxWeekofMonth($year){
    $maxWeek=array();
    $firstdayweek=date('W',strtotime("$year-01-01"));
    for($i=1;$i<13;$i++){
        $maxday=date('t',strtotime("$year-$i"));
        $max=0;
        for($j=1;$j<=$maxday;$j++){            
            $week=date('l',strtotime("$year-$i-$j"));           
            if($week=='Sunday'){
                $max++;
            }
        }
        $maxWeek[]=array('week'=>$max,
        'month'=>$i);
    }
    return $maxWeek;
}
$weekhead=array();
for($i=1;$i<53;$i++){
    if($i>9)
    $weekhead[]=array('week'=>$i);
    else
    $weekhead[]=array('week'=>"0".$i);
}
$smarty->assign('MONTHHEAD',getMaxWeekofMonth($y));
$smarty->assign('WEEKHEAD',$weekhead);
$smarty->assign('REPORTLOGTYPE',1);
$action_link=array();
$action_link[]=array('action'=>'WeekReportLogSubmit','item'=>'View_weekly_status');
$action_link[]=array('action'=>'DailyReportLogSubmit','item'=>'View_daily_status');
$action_link[]=array('action'=>'MonthReportLogSubmit','item'=>'View_monyh_status');
$smarty->assign('ACTIONLINK',$action_link);

$query="select t1.id,t1.last_name,t2.delaydays,t2.yearbol,t2.monthofyear,t2.weeksofyear as week from ld_users as t1 left join 
(select * from ld_weekreport where yearbol=? and status=1  and smcreatorid".$CommonLog->getLookScope($current_user->id)." GROUP BY smcreatorid,startdate) as t2 on t1.id=t2.smcreatorid
  ORDER BY t1.user_name,yearbol,monthofyear,delaydays";
$result=$adb->pquery($query,array($y));
$num_rows=$adb->num_rows($result);
$contents=array();
$query="select * from ld_users where id ".$CommonLog->getLookScope($current_user->id);   
    $userresult=$adb->query($query);
    $user_num_rows=$adb->num_rows($userresult);
    for($z=0;$z<$num_rows;$z++){
        $weeksofyear[$z]=$adb->query_result($result,$z,'week');
        $delaydays[$z]=$adb->query_result($result,$z,'delaydays');
        $user[$z]=$adb->query_result($result,$z,'last_name'); 
    }
if($user_num_rows){    
    for($i=0;$i<$user_num_rows;$i++){
        $username=$adb->query_result($userresult,$i,'last_name');     
        $weekcontent=array();        
        $weekcontent[]=$username;
        $delaycontent=array();             
        for($j=1;$j<=52;$j++){ 
            $count=0;
            for($g=0;$g<$num_rows;$g++){                                         
                if($username==$user[$g] && $weeksofyear[$g]==$j){
                    if($delaydays[$g]==0)
                    $delaycontent[]="<font color='44cc00'>√</font>";
                    else
                    $delaycontent[]="+$delaydays[$g]";
                    $count++;
                }
            }            
            if(!$count)
             $delaycontent[]="";                                
        }
        $weekcontent[]=$delaycontent; 
         $contents[]=$weekcontent;
       }      
}

$smarty->assign('WEEKCONTENT',$contents);

$smarty->display('ReportLog/ReportLogSubmit.tpl');
?>