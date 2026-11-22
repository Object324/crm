<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $adb,$current_user;

include('include/ReportLog/CommonReportLog.php');

$CommonLog=new CommonReportLog();
$smarty=new lingdangCRM_Smarty();
$userid=$current_user->id;
require("user_privileges/user_privileges_".$userid.".php");
$languageType= getLanguageType($current_user);
$usersinfo=array();


$userList=$current_user->getUserOfUsers('ReportLog');//获取当前用户的所能查看到的用户


$profileobj=new Profile();
$profileList=$profileobj->getAllProfileList();//获取所有权限列表
$userids=array_keys($userList);
$userids=implode(',',$userids);
$sql="select profileid,id,last_name from ld_users where id in($userids)";

$result=$adb->pquery($sql,array());
for($i=0;$i<$adb->num_rows($result);$i++)
{
     $userid=$adb->query_result($result,$i,'id');
     $username=$adb->query_result($result,$i,'last_name');
     $profileid=$adb->query_result($result,$i,'profileid');
     $rolename=$profileList[$profileid]['profilename'];
     $userRoleInfo[]=array(
			'userid'=>$userid,
			'username'=>$username,
			'rolename'=>$rolename
			);
}
$count=sizeof($userRoleInfo);

$usersinfo[]=array($profileList,$userRoleInfo,$count);

$smarty->assign('USERINFO',$usersinfo);
$smarty->assign('ROLEINFO',$profileList);


$type=1;
if(isset($_REQUEST['type'])&&$_REQUEST['type']!=''){
    $type=$_REQUEST['type'];
}


$date=date('Y-m-d');
//周
$weekofyear=date('W',strtotime($date));
$weekscope=$CommonLog->getWeekRange($date);
$edate=$weekscope['edate'];
$sdate=date('Y-m-d',strtotime($edate.'-41 days'));
if(isset($_REQUEST['date'])&&$_REQUEST['date']){
    $enddate=$_REQUEST['date'];
    $sdate=date('Y-m-d',strtotime($enddate.'-41 days'));
    $edate=$enddate;
    
} 

$syear=$CommonLog->getYear($sdate);
$eyear=$CommonLog->getYear($edate);
$start=$CommonLog->getWeeksofYear($sdate);
$end=$CommonLog->getWeeksofYear($edate);
$last=date('Y-m-d',strtotime($sdate. '-1 days'));
$next=date('Y-m-d',strtotime($edate. '+42 days')); 


$smarty->assign('NEXT',$next);
$smarty->assign('LAST',$last);
$smarty->assign('SYEAR',$syear);
$smarty->assign('EYEAR',$eyear);
$smarty->assign('START',$start);
$smarty->assign('END',$end);
$weekhead=array();
for($i=0;$i<6;$i++){
    $d=$i*7;
    $timestamp=strtotime($edate.'-'.$d.'days');
    $date=date('Y-m-d',$timestamp);
    $sd=date("m-d",strtotime("-6 day",$timestamp));
    $ed=date('m-d',$timestamp);
    $y=$CommonLog->getYear($date);
    $m=$CommonLog->getWeeksofYear($date);
    $weekhead[]=array('year'=>$y,'ofyear'=>$m,'ed'=>$sd,'sd'=>$ed);
}


$smarty->assign('WEEKHEAD',$weekhead);
//月
$date=date('Y-m-d');
$medate=date('Y-m',strtotime($date));

$msdate=date('Y-m',strtotime($medate.'-01'.'0 days -5 month 0 year'));
if(isset($_REQUEST['monthdate'])&&$_REQUEST['monthdate']){
    $medate=$_REQUEST['monthdate'];
    $msdate=date('Y-m-d',strtotime($medate.'-01'.'0 days -5 month 0 year'));
    $msdate=date('Y-m',strtotime($msdate));
    $medate=$medate;
    
}
$msyear=$CommonLog->getYear($msdate);
$meyear=$CommonLog->getYear($medate);

function getMonth($date){
    $montharr=explode('-',$date);
    
    return $montharr[1];
}
$msmonth=getMonth($msdate);

$memonth=getMonth($medate);
$mlast=date('Y-m',strtotime($msdate.'-01'.'0 days -1 month 0 year'));
$mnext=date('Y-m',strtotime($medate.'-01'.'0 days +6 month 0 year'));

$monthhead=array();

for($i=0;$i<6;$i++){
    $timestamp=strtotime($medate.'-01 0 days -'.$i.' month 0year');
    $date=date('Y-m-d',$timestamp);
    $sd=date("m-d",strtotime('-1 day',strtotime("+1 month",$timestamp)));
    $ed=date('m-d',$timestamp);
    $y=$CommonLog->getYear($date);
    $m=getMonth($date);
    $monthhead[]=array('year'=>$y,'ofyear'=>$m,'ed'=>$ed,'sd'=>$sd);
}

$smarty->assign('MONTHHEAD',$monthhead);

$smarty->assign('MONTHNEXT',$mnext);
$smarty->assign('MONTHLAST',$mlast);
$smarty->assign('MONTHSYEAR',$msyear);
$smarty->assign('MONTHEYEAR',$meyear);
$smarty->assign('MONTHSTART',$msmonth);
$smarty->assign('MONTHEND',$memonth);
//
if($type==1){
    if(($end<date('W',strtotime(date('Y-m-d')))||$end>date('W',strtotime(date('Y-m-d'))))  && $syear<=date('Y'))
    $smarty->assign('DISPLAYEND',1);
}
else{
   
    if(($memonth<date('m',strtotime(date('Y-m-d'))) && $meyear<=date('Y'))||($memonth>=date('m',strtotime(date('Y-m-d'))) && $meyear<date('Y')))
    $smarty->assign('DISPLAYEND',1);
}


//查看汇总按钮ajax传值
if(isset($_REQUEST['start'])&&$_REQUEST['start']!='')
$start=$_REQUEST['start'];
if(isset($_REQUEST['end'])&&$_REQUEST['end']!='')
$end=$_REQUEST['end'];

if(isset($_REQUEST['syear'])&&$_REQUEST['syear']!='')
$syear=$_REQUEST['syear'];
if(isset($_REQUEST['eyear'])&&$_REQUEST['eyear']!='')
$eyear=$_REQUEST['eyear'];

if(isset($_REQUEST['userids'])&&$_REQUEST['userids']!='')
$selectuserids=$_REQUEST['userids'];
$selectuserids=substr($selectuserids,0,strlen($selectuserids)-1);

if($type==1){
    $tablename='ld_weekreport';
    $module='Week';
    //$ofyear='weeksofyear';
    $nextplan='nextweekplan';
    $id='weekreportid';
    $tmpofyear="weeksofyear";
    //周查询条件
//$where="where yearbol BETWEEN $syear and $eyear";
    $where=" where 1=1  ";
}
else{
   $tablename='ld_monthreport';
   $module='Month';
 
   $tmpofyear='monthofyear';
   $nextplan='nextmonthplan';
   $id='monthreportid';
   //月查询条件
   $where="where yearbol BETWEEN $msyear and $meyear";
}


if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']!='')
$ajax=$_REQUEST['ajax'];



if($ajax=='true'){
    $str=''; 
    if($start>$end){//跨年的时候
        if($type==1&&$start<=52){//周报
            for($i=0;$i<=52-$start;$i++){
                //$str .=$start+$i.",";
              
               if($end<=0&$i==(52-$start))
               {
                 $str.= ' ( weeksofyear='.($start+$i)." and yearbol=".$msyear.")  ";
               }
               else
               {
                 $str.= ' ( weeksofyear='.($start+$i)." and yearbol=".$msyear.") or ";
               }
            }       
            for($i=1;$i<=$end;$i++){
                
                 $str.= ' ( weeksofyear='.$i." and yearbol=".$meyear.")  ";
                 if($i!=$end)
                 {
                    $str.=" or ";
                    
                 }
            }
        
            $str="(".$str.")";
            
          //  $str=substr($str,0,strlen($str)-1);
            //$str=" in (".$str.")";
        }
        elseif($type==2&&$start<=12){//月报查看汇总
        $ym='';
      
            for($i=0;$i<=12-$start;$i++){
                $dt=$start+$i;
                $str .=$dt.",";
                $ym .="'".$syear."-".$dt."'".",";
            }
   
            for($i=1;$i<=$end;$i++){
                $str .=$i.",";
                if($i>9)
                $ym .="'".$eyear."-".$i."'".",";
                else
                $ym .="'".$eyear."-0".$i."'".",";
            }
            $str=substr($str,0,strlen($str)-1);
            $ym=substr($ym,0,strlen($ym)-1);
            $str=" monthofyear in (".$str.") and date_format(Startdate,'%Y-%m') in (".$ym.")"; 
        }
    }else
    {
       if($type==1)
            $str=" weeksofyear  BETWEEN ".$start." and ".$end.'  and yearbol='.$meyear; 
       else{
        if($msmonth>$memonth&&$msmonth<=12){
            $ym='';
            for($i=0;$i<=12-$msmonth;$i++){
                $dt=$msmonth+$i;
                $str .=$dt.",";
                $ym .="'".$msyear."-".$dt."'".",";
            }
   
            for($i=1;$i<=$memonth;$i++){
                $str .=$i.",";
                if($i>9)
                $ym .="'".$meyear."-".$i."'".",";
                else
                $ym .="'".$meyear."-0".$i."'".",";
            }
            $str=substr($str,0,strlen($str)-1);
            $ym=substr($ym,0,strlen($ym)-1);
            $str=" monthofyear in (".$str.") and date_format(startdate,'%Y-%m') in (".$ym.")";                
        }
        else{
            $str=" BETWEEN ".$msmonth." and ".$memonth;
        }
       }
       
    }
}



 $query="select ".$tablename.".startdate as startdate,".$tablename.".enddate as enddate,worksummary,".$tablename.".status,".$nextplan.",".$tmpofyear." 
,$tablename.smcreatorid,ld_users.last_name as last_name,T1.commentcontent as 
commentcontent,T1.commentdate as commentdate, T1.last_name as commentor,yearbol from ".$tablename." left JOIN 
ld_users ON ".$tablename.".smcreatorid=ld_users.id 
left join (select * from ld_reportcomments left join ld_users on ld_users.id=ld_reportcomments.commentatorid) as T1
on ".$tablename.".".$id."=T1.reportid 

".$where." and ".$ofyear." $str
and $tablename.smcreatorid in ($selectuserids) and ".$tablename.".status=1 order by yearbol DESC,".$tmpofyear." DESC";

$result=$adb->query($query);
$num_rows=$adb->num_rows($result);

$allcontents=array();

$query="select last_name from ld_users where id in ($selectuserids)";
$userresult=$adb->query($query);
$user_num_rows=$adb->num_rows($userresult);
$reportcomments=array();
if($user_num_rows){
    for($i=0;$i<$user_num_rows;$i++){
        $username=$adb->query_result($userresult,$i,'last_name');
        $contents=array();
        $contents[]=$username;
        $weekcontent=array();
        //$j=$end;$j>=$start;$j--
        $arr=array();
        if($type==1)
        $arr=$weekhead;
        else
        $arr=$monthhead;
        foreach($arr as $a){
            $j=$a['ofyear'];
            
            $count=0;            
            for($z=0;$z<$num_rows;$z++){
                //$reportid=$adb->query_result($result,$z,$id);
                $startdate=$adb->query_result($result,$z,'startdate');
                $enddate=$adb->query_result($result,$z,'enddate');
                $userid=$adb->query_result($result,$z,'smcreatorid');
                $yearopt=$adb->query_result($result,$z,'yearbol');
                $monthopt=$adb->query_result($result,$z,'monthofyear');                                
                
                $worksummary ="<b>".getFixedLabel('Work_Summary').":</b>";
                $worksummary .=$adb->query_result($result,$z,'worksummary');                
                $worksummary=decode_html($worksummary);
                
                $nextworkplan ="<b>".getFixedLabel('PLANS').":</b>";        
                $nextworkplan .=$adb->query_result($result,$z,$nextplan);
                // <img border='0' title='点此查看更多' alt='点此查看更多' src='themes/images/reportdetail.jpg'>
                
                $nextworkplan=decode_html($nextworkplan);
                
                $weeksofyear=$adb->query_result($result,$z,$tmpofyear);
                //0025673: 首页 组件视图 点击月报汇总 点击查看详情 跳转的是11月份的月报 而不是当月写的月报
              $url="[<a target='_blank' href='index.php?module=ReportLog&action=".$module.
                "ReportLog&Look=look&SearchScope=".$userid."&StartDate=".$startdate."&EndDate=".$enddate."&yearOpt=".$yearopt."&monthOpt=".$monthopt."'>
                       ".getFixedLabel("VIEWDETAIL")."..
            </a>]";
                $user=$adb->query_result($result,$z,'last_name');          
                if($username==$user && $j==$weeksofyear){
                    if(!array_key_exists($j,$weekcontent)){
                        $weekcontent[$j]=array(//'id'=>$reportid,
                                    'worksummary'=>$worksummary,
                                    'nextworkplan'=>$nextworkplan,
                                    'weeksofyear'=>$weeksofyear,
                                    'url'=>$url);
                                    $count++;
                        $reportcomments[$j]=array();
                    }
                    $commentcontent=$adb->query_result($result,$z,'commentcontent');
                $commentdate=$adb->query_result($result,$z,'commentdate');
                $commentor=$adb->query_result($result,$z,'commentor');
                
                    if($commentcontent!='')
                    {
                        $comment=$commentcontent."&nbsp;&nbsp;作者:".$commentor."&nbsp;&nbsp;添加于:".$commentdate."<br />";
                        $reportcomments[$j][]=array('commentcontent'=>$comment);
                    }
                    else{
                        $reportcomments[$j]=array();
                    }          
                }
            }
            if(!$count)
            {
                $weekcontent[$j]="";  
                $reportcomments[$j]=array();
                $url="";
            }            
                        
        }
        $contents[]=$weekcontent;
       $allcontent=array();
       $allcontent[]=$contents;
       $allcontent[]=$reportcomments;
       $allcontents[]=$allcontent;
   }
        
}

$smarty->assign('ALLCONTENTS',$allcontents);
$smarty->assign('languageType',$languageType);



$smarty->assign('TYPE',$type);
setGLobalURLSmarty($smarty);//js,css的加载url


if($ajax=='true'){
    echo '#####';
    if($type==1)
    $smarty->display('ReportLog/WeekSummaryDetail.tpl');//周报汇总界面
    else
    $smarty->display('ReportLog/MonthSummaryDetail.tpl');//月报汇总界面
    exit();
}
$smarty->display('ReportLog/WeekAndMonthSummary.tpl');
?>