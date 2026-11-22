<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $theme,$current_user;

include('include/ReportLog/CommonReportLog.php');
$CommonLog=new CommonReportLog();
$userid=$current_user->id;
$date=date('Y-m-d');
if(isset($_REQUEST['sdate'])&&$_REQUEST['sdate']){
    $sdate=$_REQUEST['sdate'];
}
else{
    $sdate=$date;
}
if(isset($_REQUEST['edate'])&&$_REQUEST['edate']){
    $edate=$_REQUEST['edate'];
}
else{
    $edate=$date;
}
$smarty=new lingdangCRM_Smarty();

if(isset($_REQUEST['searchOwner'])&&$_REQUEST['searchOwner']!='')
{
    $userid=$_REQUEST['searchOwner'];
    if($userid=="SmOwner_Search_Me")
    {
        $userid=$current_user->id;
        $smarty->assign('SmOwner_Search_Me','SmOwner_Search_Me');
    }
    if(file_exists("user_privileges/user_privileges_".$userid.".php"))
    {
        require_once("user_privileges/user_privileges_".$userid.".php");
        $username=$user_info['last_name'];
    }
        
    else
    {
        //20776: 首页>组件视图>日/周/月报：点击汇总日报，页面跳转到查看某用户日报汇总界面。创建人选择Junmilyg，点击【查看汇总】，结果：报错。
            $sql='select last_name from ld_users where id=?';
            $user_result=$adb->pquery($sql,array($userid));
            $username=$adb->query_result($user_result,0,0);
    }
    
    $smarty->assign('SearchOwner',$userid);
   
}
else
{
   $smarty->assign('SearchOwner','SmOwner_Search_Me');  
}

$type=0;

if(isset($_REQUEST['type'])&&$_REQUEST['type']!=''){
    $type=$_REQUEST['type'];
}

$smarty->assign('TYPE',$type);
$smarty->assign('SEARCHSCOPE',$userid);

$MergeSmowner=getCurSmOwnerSearchScope($currentModule);

 unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
 unset($MergeSmowner["OtherInfo"]['SmOwner_Search_All']);//全部
 unset($MergeSmowner["OtherInfo"]['SmOwner_Search_SubRole']);//我下属的
 unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']); //SmOwner_Search_Create
 
 if(isset($MergeSmowner["OtherInfo"]['smowner_search_senior']))
	unset($MergeSmowner["OtherInfo"]['smowner_search_senior']); //去掉高级选项
if(isset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']))
	unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']); //去掉共享给我的
if(isset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']))
	unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']); //去掉我共享的
 $smarty->assign('MERGESMOWNER',$MergeSmowner);
 $smarty->assign("THEME", $theme);

 $smarty->assign('SDATE',$sdate);
 $smarty->assign('EDATE',$edate);

 //日程安排
$calendar=$CommonLog->getDailyCalendar($sdate,$edate,$userid);

$smarty->assign('CALENDAR',$calendar);
//联系记录
$contactrecords=$CommonLog->getDailyRelationRecord($sdate,$edate,$userid);

$smarty->assign('CONTACTRECORDS',$contactrecords);
//新增客户

$account=$CommonLog->getDailyAccount($sdate,$edate,$userid);
$smarty->assign('ACCOUNT',$account);
//销售机会

$potential=$CommonLog->getDailyPotential($sdate,$edate,$userid);
$smarty->assign('POTENTIAL',$potential);
//报价单——合计
$quotes=$CommonLog->getDailyQuotes($sdate,$edate,$userid);
$smarty->assign('QUOTESTOTAL',$quotes[0][1].setNumberFormat($quotes[0][0]));
$smarty->assign('QUOTES',$quotes[1]);
//合同订单——合计
$salesorder=$CommonLog->getDailySalesOrder($sdate,$edate,$userid);
$smarty->assign('SALESORDERTOTAL',$salesorder[0][1] . setNumberFormat($salesorder[0][0]));
$smarty->assign('SALESORDER',$salesorder[1]);
/*
edit:kara
date:2013-06-19
reason:收款单-合计
*/
//收款单——合计
$cashbill=$CommonLog->getDailyCallBill($sdate,$edate,$userid);
$smarty->assign('CASHBILLTOTAL',$cashbill[0][1] . setNumberFormat($cashbill[0][0]));
$smarty->assign('CASHBILL',$cashbill[1]);
//发票——合计
$invoice=$CommonLog->getDailyInvoice($sdate,$edate,$userid);
$smarty->assign('INVOICETOTAL',$invoice[0][1] . setNumberFormat($invoice[0][0]));
$smarty->assign('INVOICE',$invoice[1]);
//服务单
$troubletickets=$CommonLog->getDailyTroubleTickets($sdate,$edate,$userid);
$smarty->assign('TROUBLETICKETS',$troubletickets);

$query="select * from ld_dailyreport as T1 left join (select ld_reportcomments.commentcontent,ld_reportcomments.commentdate,
ld_reportcomments.reportid,ld_reportcomments.type,ld_users.last_name as commentor from ld_reportcomments left JOIN
ld_users on ld_reportcomments.commentatorid=ld_users.id
where type=0) as T2 on T1.dailyid= T2.reportid 
where T1.dstatus=1 and T1.startdate between '".$sdate."' and '".$edate."' and T1.smcreatorid='".$userid."' 
ORDER BY startdate asc, dailyid ASC,commentdate DESC";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);


$reportcomments=array();
$reportinfo=array(); 
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $reportid=$adb->query_result($result,$i,'dailyid');       
        $worksummary=$adb->query_result($result,$i,'worksummary');
        $worksummary=decode_html($worksummary);
    
    
        $tomorrowplan=$adb->query_result($result,$i,'tomorrowplan');
        $tomorrowplan=decode_html($tomorrowplan);
        
        $startdate=$adb->query_result($result,$i,'startdate');
        
       
        $submitdate=$adb->query_result($result,$i,'submitdate');
        $commentcontent=$adb->query_result($result,$i,'commentcontent');
        $commentdate=$adb->query_result($result,$i,'commentdate');
        $commentor=$adb->query_result($result,$i,'commentor');
        if(!array_key_exists($reportid,$reportinfo)){ 
            $reportinfo[$reportid]=array('worksummary'=>$worksummary,
        'tomorrowplan'=>$tomorrowplan,
        'startdate'=>$startdate,
        'week'=>$CommonLog->EnghlishWeekToLongChinese(date('l',strtotime($startdate))),
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
setGLobalURLSmarty($smarty);//js,css的加载url
if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'yes'){
	$smarty->display('ReportLog/DailySummary_entries.tpl');
}else{
	$smarty->display('ReportLog/DailySummary.tpl');
}

?>