<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

/**
 * edit:kevin
 * date:2013-05-17
 * desprition:查看某日全部用户日报
 */
global $adb,$current_user;
require_once('Smarty_setup.php');
include('include/ReportLog/CommonReportLog.php');
$CommonLog=new CommonReportLog();
if(isset($_REQUEST['date'])&&$_REQUEST['date']!=''){
    $startdate=$_REQUEST['date'];
}
$useridlist=$CommonLog->getLookScope($current_user->id);

$smarty=new lingdangCRM_Smarty();
$smarty->assign('STARTDATE',$startdate);
$smarty->assign('WEEK',$CommonLog->EnghlishWeekToLongChinese(date('l',strtotime($startdate))));
$query="select T1.dailyid,T1.smcreatorid,T1.worksummary,T1.tomorrowplan,DATE_FORMAT(T1.submitdate,'%Y-%m-%d %H:%m') as submitdate
,T2.last_name as last_name,T3.commentcontent,T3.commentdate,T3.commentor from ld_dailyreport as T1 left join 
ld_users as T2 on T1.smcreatorid=T2.id left JOIN
(select reportid,commentcontent,commentdate,last_name as commentor from ld_reportcomments left join ld_users on ld_reportcomments.commentatorid=ld_users.id where type=0) as T3 on T1.dailyid=T3.reportid
where  dstatus=1 and T1.startdate='".$startdate."' and T1.smcreatorid ".$useridlist;

$result=$adb->query($query);
//echo $result->sql;echo '<br><br>';
$num_rows=$adb->num_rows($result);


$reportcomments=array();
$reportinfo=array(); 
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $reportid=$adb->query_result($result,$i,'dailyid');
        $username=$adb->query_result($result,$i,'last_name');    
      
        $worksummary=$adb->query_result($result,$i,'worksummary');
        $worksummary=decode_html($worksummary);
    
    
        $tomorrowplan=$adb->query_result($result,$i,'tomorrowplan');
        $tomorrowplan=decode_html($tomorrowplan);
        
        
        
       
        $submitdate=$adb->query_result($result,$i,'submitdate');
        $commentcontent=$adb->query_result($result,$i,'commentcontent');
        $commentdate=$adb->query_result($result,$i,'commentdate');
        $commentor=$adb->query_result($result,$i,'commentor');
        if(!array_key_exists($reportid,$reportinfo)){ 
            $reportinfo[$reportid]=array('username'=>$username,
            'worksummary'=>$worksummary,
        'tomorrowplan'=>$tomorrowplan,
        'submitdate'=>$submitdate);
        $reportcomments[$reportid]=array();
        }
        
        $reportcomments[$reportid][]=array('commentcontent'=>$commentcontent,
        'commentdate'=>$commentdate,
        'commentor'=>$commentor);
         
  
    }
}
  
$smarty->assign('REPORTINFO',$reportinfo);
$smarty->assign('COMMENTS',$reportcomments);

$smarty->display('ReportLog/AllUsersSummary.tpl');

?>