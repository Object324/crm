<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 


include('include/ReportLog/CommonReportLog.php');
include('include/ReportLog/ReadDataReportLog.php');

global $currentModule,$default_charset;
global $app_strings;
global $app_list_strings;
global $current_user;
global $adb;
$CommonLog=new CommonReportLog();
$smarty=new lingdangCRM_Smarty();

$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
if(isset($_REQUEST['StartDate'])&&isset($_REQUEST['EndDate']))
{
    $WeekRange['sdate']=$_REQUEST['StartDate'];
    $WeekRange['edate']=$_REQUEST['EndDate'];
    
}
else 
{
    //获取周日期范围
    $WeekRange=$CommonLog->getWeekRange(date('Y-m-d'));

    
}
if(isset($_REQUEST['AHref'])&& $_REQUEST['AHref']=='prev')
{
    $WeekRange=$CommonLog->getPrevWeekRange( $WeekRange['sdate']);
    
}
if(isset($_REQUEST['AHref'])&& $_REQUEST['AHref']=='next')
{
    $WeekRange=$CommonLog->getNextWeekRange($WeekRange['sdate']);
   
}
$detailDays=$CommonLog->getWeekDetailDays($WeekRange['sdate']);
$username=$current_user->last_name;
$userid=$current_user->id;
if(isset($_REQUEST['SearchScope']))
{
    $userid=$_REQUEST['SearchScope'];
    if($userid=="SmOwner_Search_Me")//如果查询范围选择是”我的“，则转换为当前用的ID
    {
        $userid=$current_user->id;
        $username=$current_user->column_fields['last_name'];
    }
    else 
    {
         if(file_exists("user_privileges/user_privileges_".$userid.".php"))
         {
            require_once("user_privileges/user_privileges_".$userid.".php");
            $username=$user_info['last_name'];
         }
         else
         {
            $sql='select  last_name from ld_users where id=?';
            $userresult=$adb->pquery($sql,array($userid));
            $username=$adb->query_result($userresult,0,0);
            
         }
    }
}


$MergeSmowner=getCurSmOwnerSearchScope($currentModule);

//unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_All']);//全部
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_SubRole']);//我下属的
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']); //SmOwner_Search_Create
/**
 * 去掉高级、共享等查看范围选项
 * @reason 0014526: 首页>日/周/月报组件：看下级日周月报，查看范围选择【高级】，结果没有打开查看范围弹出层
 * @author Tujt 2015-04-28
 */
if(isset($MergeSmowner["OtherInfo"]['smowner_search_senior']))
	unset($MergeSmowner["OtherInfo"]['smowner_search_senior']); //去掉高级选项
if(isset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']))
	unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']); //去掉共享给我的
if(isset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']))
	unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']); //去掉我共享的

$SearchScope="";
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}
else 
{
    $SearchScope='SmOwner_Search_Me';//默认是”我的“
}
$smarty->assign("SelectedOwner2",$SearchScope);
$smarty->assign("USERNAME",$username);
$smarty->assign("USERID",$userid);
$smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
 $smarty->assign('MERGESMOWNER',$MergeSmowner);
$smarty->assign("WEEKRANGE",$WeekRange['sdate'].'～'.$WeekRange['edate']);
$smarty->assign("STARTDATE",$WeekRange['sdate']);
$smarty->assign("ENDDATE",$WeekRange['edate']);
$smarty->assign("DETAILDAYS",$detailDays);
$nowWeekRange=$CommonLog->getWeekRange(date('Y-m-d'));
$smarty->assign("NOWDATE",$nowWeekRange['edate']);

$yearBol=$CommonLog->getYear($WeekRange['edate']);
$MonthOfYear=$CommonLog->getMonthOfYear($WeekRange['edate']);
$weekOfYear=$CommonLog->getWeeksofYear($WeekRange['edate']);

$prevWeek=$CommonLog->getPrevWeekRange($WeekRange['sdate']);//获取查询日期上周日期范围

$prevYearBol=$CommonLog->getYear($prevWeek['edate']);
$prevMonthOfyear=$CommonLog->getMonthOfYear($prevWeek['edate']);
$prevWeekOfYear=$CommonLog->getWeeksofYear($WeekRange['sdate']);


$workSummary="";
$nextWeekPlan="";
$weekReportId=-1;
$status=0;
$sql="select weekreportId,status,worksummary,nextweekplan from ld_weekreport 
                where yearBol=$yearBol and monthofyear='$MonthOfYear'
                        and weeksofyear='$weekOfYear' and smcreatorid=$userid";
                      
$result=$adb->pquery($sql,array());

if($adb->num_rows($result)>0)
{
    $workSummary=$adb->query_result($result,0,2);
    $nextWeekPlan=$adb->query_result($result,0,3);
    $weekReportId=$adb->query_result($result,0,0);
    $status=$adb->query_result($result,0,1);
    if($current_user->id == $userid){
		$smarty->assign('DELSTATUS','yes');
	}
}

//获取上周-1
$prevWeekOfYearTo = $prevWeekOfYear -1;
//获取本周计划
$sql="select nextweekplan from ld_weekreport 
                where yearBol=$prevYearBol and monthofyear='$prevMonthOfyear'
                        and weeksofyear='$prevWeekOfYearTo' and smcreatorid=$userid and status=1";

$result=$adb->pquery($sql,array());
$CurWeekPlan="";
/**
 * edit:kevin
 * date:2013-06-07
 * reason:4123
 */ 
 if($adb->num_rows($result)>0)
 {    
    $CurWeekPlan=$adb->query_result($result,0,0);//本周计划
    $CurWeekPlan=decode_html($CurWeekPlan);
 } 

 $smarty->assign("CURWEEKPLAN",$CurWeekPlan); 
 $smarty->assign("PREVWEEKOFYEAR",$prevWeekOfYear); 
$workSummary=decode_html($workSummary);
/*edie:andrew
*20140107
*合并本周计划和总结
*/
/*edit:cxl
*20150427
从数据库中读取默认的周报模板  
*/
$nextWeekPlan=decode_html($nextWeekPlan);
 if($workSummary==""){
   $sql='select weekreporttemplet from ld_users where id=? limit 1;';
            $result=$adb->pquery($sql,array($userid));
             $num_rows=$adb->num_rows($result);
              $weekreporttemplet=$adb->query_result($result,0,'weekreporttemplet');
               $weekreporttemplet = htmlspecialchars_decode($weekreporttemplet);
                $workSummary = $weekreporttemplet; 
 
     
}
$smarty->assign("WORKSUMMARY",$workSummary);
$smarty->assign("NEXTWEEKPLAN",$nextWeekPlan);
$smarty->assign("REPORTLOGID",$weekReportId);
$smarty->assign("STATUS",$status);
$smarty->assign("REPORTLOGTYPE",1);
$writehtml="";
$startdate=$WeekRange['sdate'];
$enddate=$WeekRange['edate'];

 //获取日报列表
 $DailyReporList=ReadDataReportLog::createDailyForWeekList($userid,$startdate,$enddate);
 $smarty->assign("DAILYREPORTLIST",$DailyReporList);
 
 //获取客户信息
 $accountid="all";
 if($_REQUEST['AccountId'])
 {
    $accountid=$_REQUEST['AccountId'];
   
 }
 $smarty->assign("ACCOUNTID",$accountid);
 
 $smarty->assign("ACCOUNTOPTIONS",ReadDataReportLog::getAccountOptions($userid,$accountid,$startdate,$enddate));
  
   //获取日程列表信息
   $CalendarStatus='allcategor';
 if($_REQUEST['CalendarStatus'])
 {
     $CalendarStatus=$_REQUEST['CalendarStatus'];
 }
 $smarty->assign("CALENDARSTATUS",$CalendarStatus);


 $Calendartr=ReadDataReportLog::createCalendarForWeekList($userid,$startdate,$enddate,$accountid,$CalendarStatus);
 $smarty->assign("CALENDARTR",$Calendartr[0]);
 
 if($status==0 && $userid==$current_user->id)
{
  $writehtml=" <a class='text' href='index.php?module=ReportLog&action=WeekReportLog&StartDate=$startdate&EndDate=$enddate&reporttype=".$_REQUEST['reporttype']."&AccountId=$accountid&CalendarStatus=$CalendarStatus'>写周报</a>";
}
 $smarty->assign("WRITEHTML",$writehtml);


$str=$CommonLog->getCommentContent($weekReportId,1);

 $smarty->assign('MODCOMMENTS',$str);
 $smarty->assign('OEM_CRM',$common_version['oem_crm']);


if(isset($_REQUEST['mode']) && $_REQUEST['mode']=="write")
{
    echo "#####Success:::";
    
    $smarty->display("ReportLog/WeekReportList.tpl");
    exit();
}
if($_REQUEST['mode']!=='ajax'){
     $smarty->assign('NONEMODE',1);
}
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='ajax')
{
    //查询范围变更
      
    echo "#####Success:::";
    
    $smarty->display("ReportLog/LookWeekReport.tpl");
    exit();
}
//获取当前周几
//先定义一个数组
$weekarray=array("日","一","二","三","四","五","六"); 
$week = "周".$weekarray[date("w")];
$smarty->assign("WEEKNOW",$week);

 if(isset($_REQUEST['reporttype']) && $_REQUEST['reporttype']!='')
 {
    $smarty->assign('REPORTTYPE',$_REQUEST['reporttype']);
 }
setGLobalURLSmarty($smarty);//js,css的加载url
/**
 * 更新操作
 * edit:can
 * date:20131202
 * reason:5953: “周报”、“月报”暂存后，结果无法编辑，希望修正。(注：只有提交的周报、月报才不允许修改)
 * */
if(isset($_REQUEST['Look']))
{
    //周报查看界面
    $smarty->display("ReportLog/LookWeekReport.tpl");
}
else if($weekReportId>0 &&($status=="1"||$userid!=$current_user->id||isset($_REQUEST['Look'])))
{
    //周报查看界面
    $smarty->display("ReportLog/LookWeekReport.tpl");
}
else
{
  
    //写周报界面
    $smarty->display("ReportLog/WriteWeekReport.tpl");
    //exit();
}

?>