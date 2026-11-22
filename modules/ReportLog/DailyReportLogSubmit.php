<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

include('include/ReportLog/CommonReportLog.php');
$CommonLog=new CommonReportLog();
$smarty=new lingdangCRM_Smarty();
if(isset($_REQUEST['date'])&&$_REQUEST['date']!=''){
    $ym=$_REQUEST['date'];
    $arr=explode('-',$ym);
    $year=$arr[0];
    $month=$arr[1];    
}
else{
    $date=date('Y-m-d');
    $year=$CommonLog->getYear($date);//当前年
    $month=$CommonLog->getMonthOfYear($date);//当前月
    $ym="$year-$month";
}

function getLastMonth($year,$month){
    $lastmonth=date('Y-m',mktime(0,0,0,$month-1,1,$year));
    return $lastmonth;
}
function getNextMonth($year,$month){
    $nextmonth=date('Y-m',mktime(0,0,0,$month+1,1,$year));
    return $nextmonth;
}
$daily=$CommonLog->getMonthDate("$ym");
$smarty->assign('DAILYHEAD',$daily);
$smarty->assign('LAST',array('last'=>getLastMonth($year,$month),'lastname'=>'Previous_month'));
$smarty->assign('NOWMONTH',$ym);

if(($month<date('m')&& $year<=date('Y')) || ($month>=date('m')&& $year<date('Y')))
$smarty->assign('NEXT',array('next'=>getNextMonth($year,$month),'nextname'=>'After_month'));

$smarty->assign('REPORTLOGTYPE',0);

$query="select t1.id,t1.last_name,t2.delaydays,t2.dyear,t2.dmonth,t2.dday,t2.dweek from ld_users as t1 left join 
(select * from ld_dailyreport where dyear=? and dmonth=? and dstatus=1 and smcreatorid".$CommonLog->getLookScope($current_user->id).") as t2 on t1.id=t2.smcreatorid  ORDER BY t1.user_name,dyear,dmonth,dday,delaydays";

$result=$adb->pquery($query,array($year,$month));
$num_rows=$adb->num_rows($result);

$max=date('t',strtotime($ym));
$contents=array();
$query="select * from ld_users where id ".$CommonLog->getLookScope($current_user->id);   
    $userresult=$adb->query($query);
    $user_num_rows=$adb->num_rows($userresult);
if($user_num_rows){    
    for($i=0;$i<$user_num_rows;$i++){
        $username=$adb->query_result($userresult,$i,'last_name');     
        $dailycontent=array();        
        $dailycontent[]=$username;
        $delaycontent=array();        
    
        for($j=1;$j<=$max;$j++){ 
            $count=0;
            for($z=0;$z<$num_rows;$z++){
                $dday=$adb->query_result($result,$z,'dday');
                $delaydays=$adb->query_result($result,$z,'delaydays');
                $user=$adb->query_result($result,$z,'last_name');                              
                if($username==$user&&$dday==$j){
                    if($delaydays==0)
                    $delaycontent[$j]="<font color='44cc00'>√</font>";
                    else
                    $delaycontent[$j]="+$delaydays";
                    $count++;
                }
            }            
            if(!$count)
             $delaycontent[]="";                                
        }
        $dailycontent[]=$delaycontent; 
         $contents[]=$dailycontent;
       
    }    
}
$action_link=array();
$action_link[]=array('action'=>'DailyReportLogSubmit','item'=>'View_daily_status');
$action_link[]=array('action'=>'WeekReportLogSubmit','item'=>'View_weekly_status');
$action_link[]=array('action'=>'MonthReportLogSubmit','item'=>'View_monyh_status');
$smarty->assign('ACTIONLINK',$action_link);
$smarty->assign('DAILYCONTENT',$contents);
$smarty->display('ReportLog/ReportLogSubmit.tpl');
?>