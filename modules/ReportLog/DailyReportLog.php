<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $adb,$current_user,$theme,$app_strings,$mod_strings;

include('include/ReportLog/CommonReportLog.php');
$CommonLog=new CommonReportLog();
if(isset($_REQUEST['StartDate'])&&$_REQUEST['StartDate']!='')
$selectday=$_REQUEST['StartDate'];
else{
   $selectday=date('Y-m-d',time()); 
}
/*
andrew
20140224
看日报添加<<查看前一天日报
看日报添加>>查看后一天日报
*/
if($_REQUEST['modetype']=='suchday'){
    //echo $_REQUEST['modetype'];exit();
    $selectday=date('Y-m-d', strtotime ("-1 day", strtotime($_REQUEST['StartDate'])));
}
if($_REQUEST['modetype']=='tsuchday'){
    //echo $_REQUEST['modetype'];exit();
    $selectday=date('Y-m-d', strtotime ("+1 day", strtotime($_REQUEST['StartDate'])));
}
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

$smarty=new lingdangCRM_Smarty();
//获取明日日程
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']!=''){
    echo "#####";  
    $query="select T1.subject,T1.due_date,T1.date_start,T3.accountname,T4.lastname,T4.mobile from ld_activity as T1 left join ld_crmentity as T2 on T1.activityid=T2.crmid
 left join ld_account as T3 on T1.accountid=T3.accountid left join ld_contactdetails as T4 on
  T1.contactid=T4.contactid where T1.deleted=0 and DATE_FORMAT(T1.date_start,'%Y-%m-%d')<='".date('Y-m-d',strtotime($selectday.'1 days'))."' and
  DATE_FORMAT(T1.due_date,'%Y-%m-%d')>='".date('Y-m-d',strtotime($selectday.'1 days'))."' and T1.smownerid=".$current_user->id;
//echo $query;exit();
  $result=$adb->query($query);
  $num_rows=$adb->num_rows($result);
 
  if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $subject=$adb->query_result($result,$i,'subject');
        $lastname=$adb->query_result($result,$i,'lastname');
        $mobile=$adb->query_result($result,$i,'mobile');
        $accountname=$adb->query_result($result,$i,'accountname');
        $date_start=date('Y-m-d H:i',strtotime($adb->query_result($result,$i,'date_start')));
        $due_date=date('Y-m-d H:i',strtotime($adb->query_result($result,$i,'due_date')));
        $calendar .=$subject."[".$lastname."&nbsp;".$mobile."&nbsp;".$accountname."]"."&nbsp;(".$date_start."~".$due_date.")<br/>";
    }
  }
  echo $calendar;
    exit();
}
$smarty->assign("THEME", $theme);
 $query="select * from ld_dailyreport where dyear=? and dmonth=? and dday=? and smcreatorid=?";
$result=$adb->pquery($query,array(date('Y',strtotime($selectday)),date('m',strtotime($selectday)),date('d',strtotime($selectday)),$userid));
$num_rows=$adb->num_rows($result);
$dailycontent=array();
if($num_rows){
    $dstatus=$adb->query_result($result,0,'dstatus');
    $worksummary=$adb->query_result($result,0,'worksummary');
    $worksummary=decode_html($worksummary);

   
    $tomorrowplan=$adb->query_result($result,0,'tomorrowplan');
    $tomorrowplan=decode_html($tomorrowplan);
    
    $dailycontent['worksummary']=$worksummary;
    $dailycontent['tomorrowplan']=$tomorrowplan;
    $ReportLogId=$adb->query_result($result,0,'dailyid');
    if($dstatus==0){
        $dailyReportstatu=getFixedLabel('Temporary_unpaid');
        $dstatus=0;
    }elseif($dstatus==1){
        $dailyReportstatu=getFixedLabel('HAVETOPAY');
        $dstatus=1;
    }
	if($current_user->id == $userid){
		$smarty->assign('DELSTATUS','yes');
	}
}
else{
    $dailyReportstatu=getFixedLabel('Not_write');
    $dstatus=0;
}

$yesterdayarr=explode('-',$selectday);
$yesterday=mktime(0,0,0,$yesterdayarr[1],$yesterdayarr[2]-1,$yesterdayarr[0]);
$yesterday=date('Y-m-d',$yesterday);
$query="select tomorrowplan from ld_dailyreport where dyear=? and dmonth=? and dday=? and smcreatorid=?";
$result=$adb->pquery($query,array(date('Y',strtotime($yesterday)),date('m',strtotime($yesterday)),date('d',strtotime($yesterday)),$userid));
$num_rows=$adb->num_rows($result);
if($num_rows){    
    $yesterdaycontent=$adb->query_result($result,0,'tomorrowplan');  
   $yesterdaycontent=decode_html($yesterdaycontent);
    $dailycontent['yesterdaycontent']=$yesterdaycontent;
}
/*edit:andrew
*20140107
将日报今日总结和计划合并
*/

/*edit:cxl
*20150427
从数据库中读取默认的日报模板  
*/
if($dailycontent['worksummary']==''){
    
           $sql='select dailyreporttemplet from ld_users where id=? limit 1;';
            $result=$adb->pquery($sql,array($userid));
             $num_rows=$adb->num_rows($result);
              $dailytemplet=$adb->query_result($result,0,'dailyreporttemplet');
               $dailytemplet = htmlspecialchars_decode($dailytemplet);
                $dailycontent['worksummary'] = $dailytemplet; 
    
}
$smarty->assign('DAILYCONTENT',$dailycontent);
$smarty->assign('DAILYREPORTSTATU',$dailyReportstatu);
$smarty->assign('WEEK',EnghlishWeekToLongChinese(date('l',strtotime($selectday))));
$smarty->assign('STARTDATE',$selectday);
$smarty->assign('ENDDATE',$selectday);
$smarty->assign('REPORTLOGTYPE',0);
$smarty->assign('STATUS',$dstatus);
$dd=strtotime(date("Y-m-d"));
$smarty->assign('NOWDATE',$dd);
$smarty->assign('SDATE',strtotime($selectday));
$smarty->assign('REPORTLOGID',$ReportLogId);
$smarty->assign('USERID',$current_user->id);

//日程安排
$calendar=$CommonLog->getDailyCalendar($selectday,$selectday,$userid);

$smarty->assign('CALENDAR',$calendar);
//联系记录
$contactrecords=$CommonLog->getDailyRelationRecord($selectday,$selectday,$userid);

$smarty->assign('CONTACTRECORDS',$contactrecords);
//新增客户

$account=$CommonLog->getDailyAccount($selectday,$selectday,$userid);
$smarty->assign('ACCOUNT',$account);
//销售机会

$potential=$CommonLog->getDailyPotential($selectday,$selectday,$userid);
$smarty->assign('POTENTIAL',$potential);
//报价单——合计
$quotes=$CommonLog->getDailyQuotes($selectday,$selectday,$userid);
$smarty->assign('QUOTESTOTAL',$quotes[0][1] . setNumberFormat($quotes[0][0]));
//CurrencyField::appendCurrencySymbol(CurrencyField::convertToUserFormat($quotes[0][0]),$quotes[0][1])
$smarty->assign('QUOTES',$quotes[1]);
//合同订单——合计
$salesorder=$CommonLog->getDailySalesOrder($selectday,$selectday,$userid);
$smarty->assign('SALESORDERTOTAL',$salesorder[0][1] . setNumberFormat($salesorder[0][0]));
//CurrencyField::appendCurrencySymbol(CurrencyField::convertToUserFormat($salesorder[0][0]),$salesorder[0][1])
$smarty->assign('SALESORDER',$salesorder[1]);
/*
edit:kara
date:2013-06-19
reason:收款单-合计
*/
//收款单——合计
$cashbill=$CommonLog->getDailyCallBill($selectday,$selectday,$userid);
$smarty->assign('CASHBILLTOTAL',$cashbill[0][1] . setNumberFormat($cashbill[0][0]));
//CurrencyField::appendCurrencySymbol(CurrencyField::convertToUserFormat($cashbill[0][0]),$cashbill[0][1])
$smarty->assign('CASHBILL',$cashbill[1]);

//发票——合计
$invoice=$CommonLog->getDailyInvoice($selectday,$selectday,$userid);
$smarty->assign('INVOICETOTAL',$invoice[0][1] . setNumberFormat($invoice[0][0]));
//CurrencyField::appendCurrencySymbol(CurrencyField::convertToUserFormat($invoice[0][0]),$invoice[0][1])
$smarty->assign('INVOICE',$invoice[1]);
//服务单
$troubletickets=$CommonLog->getDailyTroubleTickets($selectday,$selectday,$userid);

$smarty->assign('TROUBLETICKETS',$troubletickets);


//过去五天日期
 function getLastFiveDay($selectday = ''){
    global $adb,$current_user;
	if(empty($selectday)) $selectday = date('Y-m-d',time());
   $CommonLog=new CommonReportLog();
    $days=array();
    for($i=4;$i>=0;$i--){
        //$s=0-$i;
		$s = strtotime($selectday) - 3600*24*$i;
        $query="select dstatus from ld_dailyreport where dyear=? and dmonth=? and dday=? and smcreatorid=?";
        $result=$adb->pquery($query,array(date('Y',$s),date('m',$s),date('d',$s),$current_user->id));
        $num_rows=$adb->num_rows($result);
        if($num_rows){
            $dstatus=$adb->query_result($result,0,'dstatus');
            if($dstatus==0){
                $dailystatu=getFixedLabel('Pay');
                $look="submit";
            }
            elseif($dstatus==1){
                $dailystatu=getFixedLabel('LOOK');
                $look="look";
            }
        }
        else
        {
            $dailystatu=getFixedLabel('WRITE');
            $look="write";
        }
        $days[]=array('shortdaily'=>date('d',$s),
        'longdaily'=>date('Y-m-d',$s),
        'shortweek'=>$CommonLog->EnghlishWeekToShortChinese(date('l',$s)),
        'dailystatu'=>$dailystatu,
        'look'=>$look        
        );        
    }
    //当天日期
    return $days;
 }
 
 function EnghlishWeekToLongChinese($week){
    
    return getFixedLabel($week);
    switch($week){
        case 'Monday':
        return 'Monday';breack;
        case 'Tuesday':
        return 'Tuesday';breack;
        case 'Wednesday':
        return 'Wednesday';breack;
        case 'Thursday':
        return 'Thursday';breack;
        case 'Friday':
        return 'Friday';breack;
        case 'Saturday':
        return 'Saturday';breack;
        case 'Sunday':
        return 'Sunday';breack;
    }
 }

 $smarty->assign('DAILY',getLastFiveDay($selectday));
 //$smarty->assign('CREATER',$current_user->last_name);

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
 $smarty->assign("SEARCHSCOPE",$SearchScope);
 $smarty->assign("SelectedOwner2",$SearchScope);
 $smarty->assign('MERGESMOWNER',$MergeSmowner);

 $smarty->assign("USERNAME",$username);

 $smarty->assign("USERID",$userid);
 
 $smarty->assign('STATUS'.$dstatus);
 
 $str=$CommonLog->getCommentContent($ReportLogId,0);

//按钮要判断新增权限（客户、日程、联系记录、合同订单、收款单）
$judge_Calendar = 'no';
$judge_Accounts = 'no';
$judge_ContactRecords = 'no';
$judge_SalesOrder = 'no';
$judge_CashBill = 'no';

$judge_Calendar_e = 'no';
$judge_Accounts_e = 'no';
$judge_ContactRecords_e = 'no';
$judge_SalesOrder_e = 'no';
$judge_CashBill_e = 'no';
 if(isPermitted('Calendar','Create','') == 'yes')
 {
    $judge_Calendar = 'yes';
 }
 if(isPermitted('Accounts','Create','') == 'yes')
 {
    $judge_Accounts = 'yes'; 
 }
 if(isPermitted('ContactRecords','Create','') == 'yes')
 {
    $judge_ContactRecords = 'yes'; 
 }
  if(isPermitted('SalesOrder','Create','') == 'yes')
 {
    $judge_SalesOrder = 'yes';  
 }   
 if(isPermitted('CashBill','Create','') == 'yes')
 {
    $judge_CashBill = 'yes'; 
 }
 //判断编辑权限权限
  if(isPermitted('Calendar','EditView','') == 'yes')
 {
    $judge_Calendar_e = 'yes';
 }
 if(isPermitted('Accounts','EditView','') == 'yes')
 {
    $judge_Accounts_e = 'yes'; 
 }
 if(isPermitted('ContactRecords','EditView','') == 'yes')
 {
    $judge_ContactRecords_e = 'yes'; 
 }
  if(isPermitted('SalesOrder','EditView','') == 'yes')
 {
    $judge_SalesOrder_e = 'yes';  
 }   
 if(isPermitted('CashBill','EditView','') == 'yes')
 {
    $judge_CashBill_e = 'yes'; 
 }
 
 $smarty->assign("judge_Calendar",$judge_Calendar);
 $smarty->assign("judge_Accounts",$judge_Accounts);
 $smarty->assign("judge_ContactRecords",$judge_ContactRecords);
 $smarty->assign("judge_SalesOrder",$judge_SalesOrder);
 $smarty->assign("judge_CashBill",$judge_CashBill);
 
 $smarty->assign("judge_Calendar_e",$judge_Calendar_e);
 $smarty->assign("judge_Accounts_e",$judge_Accounts_e);
 $smarty->assign("judge_ContactRecords_e",$judge_ContactRecords_e);
 $smarty->assign("judge_SalesOrder_e",$judge_SalesOrder_e);
 $smarty->assign("judge_CashBill_e",$judge_CashBill_e);
 
 
 $smarty->assign('OEM_CRM',$common_version['oem_crm']);
 $smarty->assign('MODCOMMENTS',$str);
 $smarty->assign('APP',$app_strings);
 $smarty->assign('MOD',$mod_strings);
 $smarty->assign('LOOK',$_REQUEST['Look']);
$smarty->assign('DISPLAY',true);
setGLobalURLSmarty($smarty);//js,css的加载url
 if(isset($_REQUEST['mode']) && $_REQUEST['mode']!='')
 {
	 if(isset($_REQUEST['look']) && 'look' == $_REQUEST['look']){
		 $smarty->assign('REPORTTYPE',$_REQUEST['look']);
		 if(empty($_REQUEST['modetype'])){
			echo "#####Success:::";
		 }
		$smarty->display("ReportLog/LookDailyReport.tpl");
		exit();
	 }else{
		$smarty->assign('REPORTTYPE',$_REQUEST['reporttype']);
		echo "#####Success:::";
		$smarty->display("ReportLog/WriteDailyReport.tpl");
		exit();
	 }
 }
 
 if(isset($_REQUEST['reporttype']) && $_REQUEST['reporttype']!='')
 {
    $smarty->assign('REPORTTYPE',$_REQUEST['reporttype']);
 } 
 
 if(isset($_REQUEST['look'])&&$_REQUEST['look']=='look')
 {
    $smarty->display("ReportLog/LookDailyReport.tpl");
 }
 else
 {    
    $smarty->display("ReportLog/WriteDailyReport.tpl");
 }
 
?>