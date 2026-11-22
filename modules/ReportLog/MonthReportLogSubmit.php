<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 


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

$smarty->assign('REPORTLOGTYPE',2);
$action_link=array();
$action_link[]=array('action'=>'MonthReportLogSubmit','item'=>'View_monyh_status');
$action_link[]=array('action'=>'WeekReportLogSubmit','item'=>'View_weekly_status');
$action_link[]=array('action'=>'DailyReportLogSubmit','item'=>'View_daily_status');
$smarty->assign('ACTIONLINK',$action_link);

$month=array();
for($i=1;$i<13;$i++){
    $month[]=$i;
}

$smarty->assign('MONTHHEAD',$month);

$query="select t1.id,t1.last_name,t2.delaydays,t2.yearbol,t2.monthofyear as year from ld_users as t1 left join 
(select * from ld_monthreport where yearbol=? and status=1 and smcreatorid".$CommonLog->getLookScope($current_user->id).") as t2 on t1.id=t2.smcreatorid
  ORDER BY t1.user_name,yearbol,Monthofyear,delaydays";

$result=$adb->pquery($query,array($y));
$num_rows=$adb->num_rows($result);
$contents=array();
$query="select * from ld_users where id ".$CommonLog->getLookScope($current_user->id);   
    $userresult=$adb->query($query);
    $user_num_rows=$adb->num_rows($userresult);
if($user_num_rows){    
    for($i=0;$i<$user_num_rows;$i++){
        $username=$adb->query_result($userresult,$i,'last_name');     
        $monthcontent=array();        
        $monthcontent[]=$username;
        $delaycontent=array();             
        for($j=1;$j<=12;$j++){ 
            $count=0;
            for($z=0;$z<$num_rows;$z++){
                $monthsofyear=$adb->query_result($result,$z,'year');
                $delaydays=$adb->query_result($result,$z,'delaydays');
                $user=$adb->query_result($result,$z,'last_name');                                           
                if($username==$user && $monthsofyear==$j){
                    if($delaydays==0)
                    $delaycontent[]="<font color='44cc00'>√</font>";
                    else
                    $delaycontent[]="+$delaydays";
                    $count++;
                }
            }            
            if(!$count)
             $delaycontent[]="";                                
        }
        $monthcontent[]=$delaycontent; 
         $contents[]=$monthcontent;
       }      
}

$smarty->assign('MONTHCONTENT',$contents);

$smarty->display('ReportLog/ReportLogSubmit.tpl');
?>