<?php
/**
*修改编码格式:统一编码：UTF-8
**/ 


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
    //$MonthRange['sdate']=$_REQUEST['StartDate'];
    //$MonthRange['edate']=$_REQUEST['EndDate'];
    $MonthRange=$CommonLog->getMonthRange($_REQUEST['StartDate']);
    
}
else 
{
    //获取月日期范围
   
    $MonthRange=$CommonLog->getMonthRange(date("Y-m-d"));

}



$username=$current_user->last_name;
$userid=$current_user->id;
if(isset($_REQUEST['SearchScope']))
{
    $userid=$_REQUEST['SearchScope'];
    ////如果查询范围选择是”我的“，则转换为当前用的ID
    if($userid=="SmOwner_Search_Me")
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

unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
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
$smarty->assign("NOWDATE",date("Y-m"));
$smarty->assign("YEARMONTH",date("Y-m",strtotime($MonthRange['sdate'])));

$smarty->assign("STARTDATE",$MonthRange['sdate']);
$smarty->assign("ENDDATE",$MonthRange['edate']);

$yearBol=date("Y",strtotime($MonthRange['sdate']));
//echo $MonthRange['sdate'];echo '<br><br>';
$nowyear=date("Y");
$yearOptions=array();
for($j=2000;$j<=$nowyear;$j++)
{
    $yearOptions[$j]=$j;
}
 $MonthOptions=array("1"=>1,"2"=>2,"3"=>3,"4"=>4,"5"=>5,"6"=>6,"7"=>7,"8"=>8,"9"=>9,"10"=>10,"11"=>11,"12"=>12);
 $nowMonth=date("m")+0;//加零是为了转换为数字（01-》1,02->2,03->3)_
if($yearBol==date("Y"))
{
    $MonthOptions=array();
  
   for($i=1;$i<=$nowMonth;$i++)
   {
      $MonthOptions[$i]=$i;
   }
}

$MonthOfYear=$CommonLog->getMonthOfYear($MonthRange['edate']);

$smarty->assign("NOWMONTH",$nowMonth);
$smarty->assign("MONTHOPTIONS",$MonthOptions);
$smarty->assign("YEAROPTIONS",$yearOptions);

//$smarty->assign("YEARBOL",$yearBol);
if(!empty($_REQUEST['yearOpt'])){
	if(!empty($_REQUEST['StartDate'])&&$_REQUEST['StartDate']!='0000-00-00'){
		$startDate  = explode('-',$_REQUEST['StartDate']);
		$smarty->assign("YEARBOL",$startDate[0]);
	}else{
		$smarty->assign("YEARBOL",$_REQUEST['yearOpt']);
	}
	
	$yearBol = $_REQUEST['yearOpt'];
}else{
	$smarty->assign("YEARBOL",date('Y'));
	$yearBol = date('Y');
}

//$smarty->assign("MONTHOFYEAR",$MonthOfYear);
if(!empty($_REQUEST['monthOpt'])){
	if(!empty($_REQUEST['StartDate'])&&$_REQUEST['StartDate']!='0000-00-00'){
		$startDate  = explode('-',$_REQUEST['StartDate']);
		$smarty->assign("MONTHOFYEAR",$startDate[1]);
	}else{
		$smarty->assign("MONTHOFYEAR",$_REQUEST['monthOpt']);
	}
	$MonthOfYear = $_REQUEST['monthOpt'];
}else{
	$smarty->assign("MONTHOFYEAR",date('m'));
	$MonthOfYear = date('m');
}
$smarty->assign("MONTHDAYS",$CommonLog->getMonthDays($MonthRange['edate']));
$sql="select monthreportID ,worksummary,nextmonthplan,status from ld_monthreport 
        where yearbol=$yearBol and monthofyear=$MonthOfYear and smcreatorid=$userid";
	
$result=$adb->pquery($sql,array());
$status=0;
$workSummary="";
$nextMonthPlan="";
$MonthReportID=-1;
/**
 * edit:kevin
 * date:2013-06-07
 * reason:4123
 */ 
if($adb->num_rows($result)>0)
{
    $MonthReportID=$adb->query_result($result,0,0);
    $workSummary=$adb->query_result($result,0,1);
     $workSummary=decode_html($workSummary);

    $nextMonthPlan=$adb->query_result($result,0,2);
    $nextMonthPlan=decode_html($nextMonthPlan);
    $status=$adb->query_result($result,0,3);
    if($current_user->id == $userid){
		$smarty->assign('DELSTATUS','yes');
	}
}

$smarty->assign("REPORTLOGID",$MonthReportID);
//$smarty->assign("WORKSUMMARY",$workSummary);
$smarty->assign("NEXTMONTHPLAN",$nextMonthPlan);
$smarty->assign("STATUS",$status);
$smarty->assign("REPORTLOGTYPE",2);
$prevMonth=$CommonLog->getPrevMonthRange($MonthRange['sdate']);//获取查询日期上月日期范围
$prevYearBol=$CommonLog->getYear($prevMonth['edate']);
$prevMonthOfyear=date("m",strtotime($prevMonth['edate']))+0;//加零是为了转换为数字
//获取本月计划
$sql="select nextmonthplan from ld_MonthReport 
        where yearbol=$prevYearBol and MonthOfyear=$prevMonthOfyear and smcreatorid=$userid";
$result=$adb->pquery($sql,array());

$nowMonthPlan="";
if($adb->num_rows($result)>0)
{
    $nowMonthPlan=$adb->query_result($result,0,0);
   $nowMonthPlan=decode_html($nowMonthPlan);

}
/*edit:andrew
*20140107
将月报今月总结和计划合并
*/
/*edit:cxl
*20150427
从数据库中读取默认的月报模板  
*/
if($workSummary==''){
	$sql='select monthtypetemplet from ld_users where id=? limit 1;';
	$result=$adb->pquery($sql,array($userid));
	$num_rows=$adb->num_rows($result);
	$monthtypetemplet=$adb->query_result($result,0,'monthtypetemplet');
	$monthtypetemplet = htmlspecialchars_decode($monthtypetemplet);
	$workSummary = $monthtypetemplet; 
}
$smarty->assign("WORKSUMMARY",$workSummary);
$smarty->assign("NOWMONTHPLAN",$nowMonthPlan);
$writehtml="";
$startdate=$MonthRange['sdate'];
$enddate=$MonthRange['edate'];
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
 $smarty->assign("CALENDARSTATUS",$CalendarStatus);
 
$detailDays=$CommonLog->getMonthDetailDays($MonthRange['sdate'],$MonthRange['edate']);
$smarty->assign("DETAILDAYS",$detailDays);

 $Calendartr=ReadDataReportLog::createCalenarForMonthList($userid,$detailDays,$accountid,$CalendarStatus);
//print_r(array_chunk($Calendartr,2));
//exit();
$Calendars=array_chunk($Calendartr,2);

/*
foreach($Calendars as $weeks=>$weekscontent)
{
   foreach($weekscontent as $trs =>$tds)
   {
      $tables .=$tds;
   }
}
*/
//exit();

 $smarty->assign("CALENDARTR",$Calendars);
 
 $str=$CommonLog->getCommentContent($MonthReportID,2);
$smarty->assign('LOOK',$_REQUEST['Look']);
 $smarty->assign('MODCOMMENTS',$str);
 $smarty->assign('OEM_CRM',$common_version['oem_crm']);
if($status==0 && $userid==$current_user->id)
{
  $writehtml=" <a class='text' href='index.php?module=ReportLog&action=MonthReportLog&reporttype=write&StartDate=$startdate&EndDate=$enddate&AccountId=$accountid&CalendarStatus=$CalendarStatus&monthOpt=$MonthOfYear'>写月报</a>";
}
$smarty->assign("WRITEHTML",$writehtml);
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=="write")
{
    echo "#####Success:::";
    $smarty->display("ReportLog/MonthReportList.tpl");
    exit();
}
if($_REQUEST['mode']!=='ajax'){
     $smarty->assign('NONEMODE',1);
}
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='ajax')
{
    //查询范围变更
    echo "#####Success:::";
    $smarty->display("ReportLog/LookMonthReport.tpl");
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
 * edit:kevin
 * date:2013-11-26
 * reason:0005762: 本月已经新增月报后，在日期中，选择上个月，结果显示的是查看月报界面。
 */   
 /**
 * 更新操作
 * edit:can
 * date:20131202
 * reason:5953: “周报”、“月报”暂存后，结果无法编辑，希望修正。(注：只有提交的周报、月报才不允许修改)
 * */
if(!empty($_REQUEST['Look']))
{
    //月报查看界面
    $smarty->display("ReportLog/LookMonthReport.tpl");
}
else if($MonthReportID>0 && ($status=="1"||$userid!=$current_user->id||isset($_REQUEST['Look'])))
{
    //月报查看界面
     
    $smarty->display("ReportLog/LookMonthReport.tpl");
}
else
{
   
    
    //写月报界面
    $smarty->display("ReportLog/writeMonthReport.tpl");
}
?>