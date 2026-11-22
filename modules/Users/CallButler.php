<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

global $list_max_entries_per_page_new;
global $currentModule, $current_user;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty=new lingdangCRM_Smarty();
$todayselect=  date('Y-m-d',time());

//查找传值
//时间区间
$whereSQL = '';
if(isset($_REQUEST['passCallDate']) && $_REQUEST['passCallDate'] != '')
{
    $callDate = $_REQUEST['passCallDate'];
    $passBeginDate = substr($callDate, 0, 11)." 00:00:00";
    $passEndDate = substr($callDate, strlen($callDate)-11, 11)." 23:59:59";
    $whereSQL .= " and (T1.begintime between '$passBeginDate' and '$passEndDate') ";
}else{
    $whereSQL .= " and (T1.begintime between '$todayselect' and '$todayselect') ";//默认查询本日
}
//来电去电  呼出type=1  呼入type=2
if(isset($_REQUEST['passCallType']) && $_REQUEST['passCallType'] != '')
{
    $passCallType = $_REQUEST['passCallType'];
    if($passCallType==1)
    {
        $whereSQL .= " and T1.calltype = '来电' ";
    }
    elseif($passCallType == 2)
    {
        $whereSQL .= " and T1.calltype = '去电' ";
    }
    
}
//接通未接通 ，仅记录接通
if(isset($_REQUEST['passStatus']) && $_REQUEST['passStatus'] != '')
{
    $passStatus = $_REQUEST['passStatus'];
    if($passStatus==1)
    {
        $whereSQL .= " and T1.`status` = '接通' ";
    }
    elseif($passStatus == 2)
    {
        $whereSQL .= " and T1.`status` = '未接通' ";
    }
}
//筛选_客户名称
if(isset($_REQUEST['passCustName']) && $_REQUEST['passCustName'] != '')
{
    $passCustName = $_REQUEST['passCustName'];
    $whereSQL .= " and T3.accountname = '$passCustName' ";
}
//筛选_电话
if(isset($_REQUEST['passPhone']) && $_REQUEST['passPhone'] != '')
{
    $passPhone = $_REQUEST['passPhone'];
    $whereSQL .= " and T1.phone = '$passPhone' ";
}
//筛选_通话时间
if(isset($_REQUEST['passBeginTime']) && $_REQUEST['passBeginTime'] != '' 
&& isset($_REQUEST['passEndTime']) && $_REQUEST['passEndTime'] != '')
{
    $passBeginTime = $_REQUEST['passBeginTime'];
    $passEndTime = $_REQUEST['passEndTime'];
    $whereSQL .= " and (T1.time between $passBeginTime and $passEndTime) ";
}
//查找范围_用户
$useridlist=getuseridlist($_REQUEST['searchscope']);//查询范围用户id字串
if($useridlist != 0)
{
    $whereSQL .= ' and T1.userid in ('.$useridlist.')';
}

$orderby .= ' order by begintime desc ';
$columns="T2.last_name as username,T1.begintime,T3.accountid,T3.accountname,
T4.contactid,T4.lastname as contactname,T5.ticketid,T5.ticket_no, 
T6.vendorid,T6.vendorname,T7.vendorcontactsid,T7.Lastname as vendorcontactsname,
T8.contactrecordid,T8.`Subject` as contactsubject,
T9.contactRecordsid as vendorcontactRecordsid,T9.`Subject` as vendorcontactrsubject,
T10.potentialid as potentialid,T10.`potential_no` as potential_no,
T1.calltype,T1.phone,T1.time,T1.soundrecordingfile,T1.`status` ";

$list_query_from = " 
from ld_callbutler as T1
left join ld_users as T2 on T1.userid = T2.id
left join ld_account as T3 on  T1.accountid = T3.accountid 
left join ld_contactdetails as T4 on  T1.contactid = T4.contactid 
left join ld_troubletickets as T5 on  T1.ticketid = T5.ticketid 
left join ld_vendor as T6 on  T1.vendorid = T6.vendorid 
left join ld_vendorcontacts as T7 on  T1.vendorcontactid = T7.vendorcontactsid 
left join ld_contactrecords as T8 on  T1.contactrecordsid = T8.contactrecordID 
left join ld_vendorcontactrecords as T9 on  T1.vendorcontactrecordsid = T9.contactRecordsid 
left join ld_potential as T10 on  T1.potentialid = T10.potentialid 
where 1=1 
";
//计算总时长
$totalquery="select sum(time) ".$list_query_from.$whereSQL;
$totalresult=$adb->pquery($totalquery,array());
$totaltime=0;
if($adb->num_rows($totalresult)>0)
    $totaltime=$adb->query_result($totalresult,0,0);
    
$list_query ="select ".$columns.$list_query_from. $whereSQL;
$in_list_query = $list_query . " and T1.calltype = '来电' ";
$out_list_query = $list_query . " and T1.calltype = '去电' ";
//没看懂
if(!$_SESSION['lvs'][$currentModule]) {
	unset($_SESSION['lvs']);
	$modObj = new ListViewSession();
	$modObj->sorder = $sorder;
	$modObj->sortby = $order_by;
	$_SESSION['lvs'][$currentModule] = get_object_vars($modObj);
}
$list_query .= $orderby;
//没看懂
if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true){
	$count_result = $adb->query( mkCountQuery($list_query));
	$noofrows = $adb->query_result($count_result,0,"count");
}else{
	$noofrows = null;
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, '', $queryMode);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

if( $adb->dbType == "pgsql")
	$list_result = $adb->pquery($list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new", array());
else
	$list_result = $adb->pquery($list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new", array());

$num_rows=$adb->num_rows($list_result);
//查询结果，含录音文件
$arr=array();
crm_load_class_file('fieldValueUitype','include/fields');
$subtotaltime=0;
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        
        $soundrecordingfile = $adb->query_result($list_result,$i,'soundrecordingfile');
        $soundrecordingfilenew = str_replace("\\","/",$soundrecordingfile);
        $subtotaltime+=$adb->query_result($list_result,$i,'time');
        $arr[]=array(
        'UserName'=> $adb->query_result($list_result,$i,'username'),
        'BeginTime'=> $adb->query_result($list_result,$i,'begintime'),
        'AccountID'=> $adb->query_result($list_result,$i,'accountid'),
        'AccountName'=> $adb->query_result($list_result,$i,'accountname'),
        'ContactID'=> $adb->query_result($list_result,$i,'contactid'),
        'ContactName'=> $adb->query_result($list_result,$i,'contactname'),
            'ContactrecordID'=> $adb->query_result($list_result,$i,'contactrecordid'),
            'ContactSubject'=> $adb->query_result($list_result,$i,'contactsubject'),
            'PotentialID'=> $adb->query_result($list_result,$i,'potentialid'),
            'PotentialNo'=> $adb->query_result($list_result,$i,'potential_no'),
        'TicketID'=> $adb->query_result($list_result,$i,'ticketid'),
        'TicketNo'=> $adb->query_result($list_result,$i,'ticket_no'),
        'VendorID'=> $adb->query_result($list_result,$i,'vendorid'),
        'VendorName'=> $adb->query_result($list_result,$i,'vendorname'),
        'VendorcontactsID'=> $adb->query_result($list_result,$i,'vendorcontactsid'),
        'VendorcontactsName'=> $adb->query_result($list_result,$i,'vendorcontactsname'),
        'VendorContactRecordsID'=> $adb->query_result($list_result,$i,'vendorcontactRecordsid'),
        'VendorContactrSubject'=> $adb->query_result($list_result,$i,'vendorcontactrsubject'),
        'CallType'=> $adb->query_result($list_result,$i,'calltype'),
        'Status'=> $adb->query_result($list_result,$i,'status'),
        'Phone'=> fieldValueUitype::setReportMobileStyle($adb->query_result($list_result,$i,'phone')),
        'Time'=> $adb->query_result($list_result,$i,'time'),
        'Soundrecordingfile'=> $soundrecordingfile,
        'SoundrecordingfileNew'=> $soundrecordingfilenew
                );
    }
}
$in_list_result = $adb->pquery($in_list_query, array());
$in_num_rows=$adb->num_rows($in_list_result);
$out_list_result = $adb->pquery($out_list_query, array());
$out_lnum_rows=$adb->num_rows($out_list_result);

$smarty->assign("RESULTLIST", $arr);
$smarty->assign("INCOUNT", $in_num_rows);
$smarty->assign("OUTCOUNT", $out_lnum_rows);


$smarty->assign("TOTALTIME",$totaltime);
$smarty->assign("SUBTOTALTIME",$subtotaltime);


$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"Users","CallButler",'',$pagenum);
$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
$smarty->assign('recordListRange',$recordListRangeMsg);
$smarty->assign("NAVIGATION", $navigationOutput);
/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求
*/
$MergeSmowner=getCurSmOwnerSearchScope('Accounts');
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
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

//本日
$todayselect=  date('Y-m-d',time());
//昨日
$yesterdayselect=  date("Y-m-d",time()-24*60*60); 
//本周
$week_begin =  date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
$week_end =  date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));  
//本月
$month_begin=date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));    
$month_end = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
//本年
$begin_this_year=date('Y-01-01');
$end_this_year=date('Y-12-31');

$smarty->assign('TODAY',$todayselect);
$smarty->assign('YESTERDAY',$yesterdayselect);
$smarty->assign('WEEKBEGIN',$week_begin);
$smarty->assign('WEEKEND',$week_end);
$smarty->assign('MONTHBEGIN',$month_begin);
$smarty->assign('MONTHEND',$month_end);
$smarty->assign('YEARBEGIN',$begin_this_year);
$smarty->assign('YEAREND',$end_this_year);
$smarty->assign('CallButler','CallButler');

if($_REQUEST['SearchScope'] !=null&&$_REQUEST['SearchScope'] !='')
{
    
     $SearchScope=$_REQUEST['SearchScope'];
     $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']);
    
} 
else if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
   
    $smarty->assign('SelectedOwner2',$_SESSION['lvs'][$currentModule]['SearchScope']);
}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2',"SmOwner_Search_All");
}

//链接地址
if(file_exists('modules/CallButler/download.txt'))
{
    $fileread=fopen("modules/CallButler/download.txt","r");
    $linkstr=fgets($fileread);
}
$smarty->assign("LINKSTRING", $linkstr);
//editor:gyq_20180917 为了与CallButler_MultiCenter区分开来
$deployarray=getSys_deploy(55);//呼叫中心类型
$smarty->assign("CENTERTYPE", $deployarray['deploy_value']??'');

if(isset($_REQUEST['paging'])&&$_REQUEST['paging']=='1')
{
    echo "#########:#";
    
    $smarty->display("modules/CallButler/CallButlerlist.tpl");
    exit();
}
else
{
    
    $smarty->display("modules/CallButler/CallButler.tpl");
}

function getuseridlist($scopeType)
{
    global $current_user;
    $Smownerids= getCurSmOwnerSearchScope('Accounts');
    switch($scopeType)
    {
        case 'SmOwner_Search_All':
                $SearchScope="";
                foreach($Smownerids['UserCombo']as $userid=>$userinfo)
                {
                     if($SearchScope == "")
                    {
                        $SearchScope .=$userid; 
                    }
                    else
                    {
                        $SearchScope .=",".$userid; 
                    }	
                    
                }
                 break;
        
        case 'SmOwner_Search_Me':
           $SearchScope=$current_user->id;
        break;
        case 'SmOwner_Search_Create':
            $SearchScope = $current_user->id;
        break;
        default:
          $SearchScope = $scopeType;
    }
    if(!empty($SearchScope))
    {
        return $SearchScope;
    }else{
        return 0;
    }
}


?>