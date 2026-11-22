<?php
//editor:gyq_79 reason:系统右上角呼叫中心报表优化 2018/9/5 16:51
global $list_max_entries_per_page_new;
global $currentModule, $current_user;

global $theme,$adb;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$deployarray = getSys_deploy(55);//获取系统参数设定
$deValue = $deployarray['deploy_value']??'';
//$deValue = '汉天EC2';
$callcenter_type = $deValue;
if ($deValue == '苏州九维') {
    $tablename = 'ld_jiuweiak_phonerecord';
    $type = 'type';
    $sql_select = 'select T1.id,T1.userid,T1.type,T1.caller,T1.callee,T1.indexid,T1.modulename,T1.recordnum,T1.starttime,
 T1.deadline, T1.talktime,T2.last_name as username from ld_jiuweiak_phonerecord T1 
 left join ld_users as T2 on T1.userid = T2.id where 1=1 ';
//计算总时长
    $totalquery="select sum(talktime) from ld_jiuweiak_phonerecord T1 where 1=1 ";
}elseif ($deValue == '苏州思孚') {
    $tablename = 'ld_sopho_phonerecord';
    $type = 'switch';
    $sql_select = 'select T1.id,T1.userid,T1.switch,T1.caller,T1.callee,T1.indexid,T1.modulename,T1.recordname,T1.starttime,
 T1.endtime, T2.last_name as username from ld_sopho_phonerecord T1
 left join ld_users as T2 on T1.userid = T2.id where 1=1 ';
    //计算总时长
    $totalquery="select sum(endtime-starttime) from ld_sopho_phonerecord T1 where 1=1 ";
}elseif($deValue == '汉天EC2'){
    $tablename = 'ld_hantian_phonerecord';
    $type = 'type';
    $sql_select = 'select T1.id,T1.userid,T1.type,T1.caller,T1.callee,T1.indexid,T1.modulename,T1.recordnum,T1.starttime,
 T1.deadline, T1.talktime, T1.bridging,T2.last_name as username from ld_hantian_phonerecord T1 
 left join ld_users as T2 on T1.userid = T2.id where 1=1 ';
//计算总时长
    $totalquery="select sum(talktime) from ld_hantian_phonerecord T1 where 1=1 ";
}
$module_id_transfer = array(
    'Accounts'=>array('table'=>'ld_account','index'=>'accountid','name'=>'accountname indexname','listkey1'=>'AccountID','listkey2'=>'AccountName'),
    'Contacts'=>array('accountid'=>1,'table'=>'ld_contactdetails T1 left join ld_account T2 on T1.accountid=T2.accountid',
        'index'=>'T1.contactid','name'=>'T1.lastname indexname','listkey1'=>'ContactID','listkey2'=>'ContactName'),
    'ContactRecords'=>array('accountid'=>1,'contactid'=>1,'table'=>'ld_contactrecords T1 left join ld_account T2 on T1.accountid=T2.accountid 
        left join ld_contactdetails T3 on T1.contactid=T3.contactid',
        'index'=>'T1.contactrecordid','name'=>'T1.Subject indexname','listkey1'=>'ContactrecordID','listkey2'=>'ContactSubject'),
    'Potentials'=>array('accountid'=>1,'contactid'=>1,'table'=>'ld_potential T1 left join ld_account T2 on T1.accountid=T2.accountid 
        left join ld_contactdetails T3 on T1.contactid=T3.contactid',
        'index'=>'T1.potentialid','name'=>'T1.potentialname indexname','listkey1'=>'PotentialID','listkey2'=>'PotentialNo'),
    'HelpDesk'=>array('accountid'=>1,'contactid'=>1,'table'=>'ld_troubletickets T1 left join ld_account T2 on T1.accountid=T2.accountid 
        left join ld_contactdetails T3 on T1.contactid=T3.contactid',
        'index'=>'T1.ticketid','name'=>'T1.ticket_no indexname','listkey1'=>'TicketID','listkey2'=>'TicketNo'),
    'Vendors'=>array('table'=>'ld_vendor','index'=>'vendorid','name'=>'vendorname indexname','listkey1'=>'VendorID','listkey2'=>'VendorName'),
    'VendorContact'=>array('vendorid'=>1,'table'=>'ld_vendorcontacts T1 left join ld_vendor T2 on T1.vendorid=T2.vendorid'
    ,'index'=>'T1.vendorcontactsid','name'=>'T1.Lastname indexname','listkey1'=>'VendorcontactsID','listkey2'=>'VendorcontactsName'),
    'VendorContactRecords'=>array('vendorid'=>1,'contactid'=>1,'table'=>'ld_vendorcontactrecords T1 left join ld_vendor T2 on T1.vendorid=T2.vendorid 
        left join ld_vendorcontacts T3 on T1.contactid=T3.vendorcontactsid'
    ,'index'=>'T1.contactRecordsid','T1.name'=>'Subject indexname','listkey1'=>'VendorContactRecordsID','listkey2'=>'VendorContactrSubject')
);

$smarty=new lingdangCRM_Smarty();
//选择热线单
if(!empty($_REQUEST['getPotentials']) && $_REQUEST['getPotentials'] =='yes' && !empty($_REQUEST['idlist'])){
	$ids = explode(';',rtrim($_REQUEST['idlist'],';'));
	$query = "select GROUP_CONCAT(potentialname),GROUP_CONCAT(potentialid) from ld_potential where potentialid in (".implode(',',$ids).");";
	$result = $adb->pquery($query,array());
	if($adb->num_rows($result) >= 1){
		$arr['potentialname'] = $adb->query_result($result,0,0);
		$arr['potentialid'] = $adb->query_result($result,0,1);
	}
	 $_REQUEST['diony'] = 'yes';
	 ConvertTojsonString(1,$arr,"success");
}
//关联单据按钮弹出层
if(isset($_REQUEST['ajax_action'])&&$_REQUEST['ajax_action']=='connect_record'){
    $module_options = array();
    //客户、联系人、销售机会、跟进记录、客户服务单、供应商、供应商联系人、供应商跟进记录
    $module_options_key = 0;
    foreach ($module_id_transfer as $modulename=>$value){
        if (vtlib_isModuleActive($modulename)) {
            $modulepermit = isPermitted($modulename, 'index', "");
            if ($modulepermit != 'yes') {
                continue;
            }else{
                $module_options[$module_options_key]['label'] = getTranstab($modulename);
                $module_options[$module_options_key]['module'] = $modulename;
                $module_options_key++;
            }
        }
    }
    $smarty->assign('MODULEOPTIONS',$module_options);
    $str=$smarty->fetch("modules/CallButler/ConnectRecord.tpl");
    $arr['title'] = getFixedLabel('CALLBUTLERCONNECTRECORD');
    $arr['oktext'] = getFixedLabel('CONFIRMED');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    $arr['content'] = $str;
    $_REQUEST['diony'] = 'yes';
    ConvertTojsonString(1,$arr,"success");
}
//关联单据弹出层保存
if(isset($_REQUEST['ajax_action'])&&$_REQUEST['ajax_action']=='save_connect_record'){
    $sql = 'update '.$tablename.' set indexid=?,modulename=? where id=?';
    $result = $adb->pquery($sql,array($_REQUEST['r_record'],$_REQUEST['r_module'],$_REQUEST['r_id']));
    $_REQUEST['diony'] = 'yes';
    ConvertTojsonString(1,array($_REQUEST['r_record'],$_REQUEST['r_module'],$_REQUEST['r_id']),"success");
}

$todayselect=  date('Y-m-d',time());

//查找传值
//时间区间
$whereSQL = '';
if(isset($_REQUEST['passCallDate']) && $_REQUEST['passCallDate'] != '')
{
    $callDate = $_REQUEST['passCallDate'];
    $passBeginDate = substr($callDate, 0, 11)." 00:00:00";
    $passEndDate = substr($callDate, strlen($callDate)-11, 11)." 23:59:59";
    $whereSQL .= " and (T1.starttime between '$passBeginDate' and '$passEndDate') ";
}else{
    $passBeginDate = substr($todayselect, 0, 11)." 00:00:00";
    $passEndDate = substr($todayselect,  0, 11)." 23:59:59";
    $whereSQL .= " and (T1.starttime between '$passBeginDate' and '$passEndDate') ";//默认查询本日
}
//来电去电  呼出type=1  呼入type=2
if(isset($_REQUEST['passCallType']) && $_REQUEST['passCallType'] != '')
{
    $passCallType = $_REQUEST['passCallType'];
    if($passCallType==1)
    {
        $whereSQL .= " and T1.".$type." = '2' ";
    }
    elseif($passCallType == 2)
    {
        $whereSQL .= " and T1.".$type." = '1' ";
    }
}
$calltype_transfer = array('1'=>getFixedLabel('CALLOUTBANG'),'2'=>getFixedLabel('CALLINBANG'));

//筛选_客户名称
if(isset($_REQUEST['passCustName']) && $_REQUEST['passCustName'] != '')
{
    $passCustName = $_REQUEST['passCustName'];
    $account_arr = array();
    $sql_account = 'select ld_account.accountid,ld_contactrecords.contactrecordID,
  ld_contactdetails.contactid,ld_potential.potentialid,ld_troubletickets.ticketid 
  from ld_account
  left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid
  left join ld_contactrecords on ld_contactrecords.accountid=ld_account.accountid
  left join ld_potential on ld_potential.accountid=ld_account.accountid
  left join ld_troubletickets on ld_troubletickets.accountid=ld_account.accountid
  where ld_account.accountname=\''.$passCustName.'\'';
    $sql_account_result = $adb->pquery($sql_account,array());
    $num_rows = $adb->num_rows($sql_account_result);
    for($i=0;$i<$num_rows;$i++){
        $accountid = $adb->query_result($sql_account_result,$i,'accountid');
        $contactrecordID = $adb->query_result($sql_account_result,$i,'contactrecordid');
        $contactid = $adb->query_result($sql_account_result,$i,'contactid');
        $potentialid = $adb->query_result($sql_account_result,$i,'potentialid');
        $ticketid = $adb->query_result($sql_account_result,$i,'ticketid');
        $account_arr[$accountid] = $accountid;
        $account_arr[$contactrecordID] = $contactrecordID;
        $account_arr[$contactid] = $contactid;
        $account_arr[$potentialid] = $potentialid;
        $account_arr[$ticketid] = $ticketid;
    }
    $account_arr_true = implode(',',array_filter($account_arr)) ;
    $whereSQL .= ' and T1.indexid in ('.$account_arr_true.') ';
}
//筛选_电话
if(isset($_REQUEST['passPhone']) && $_REQUEST['passPhone'] != '')
{
    $passPhone = $_REQUEST['passPhone'];
    $whereSQL .= " and (T1.caller = '$passPhone' or T1.callee = '$passPhone') ";
}
//筛选_通话时间
if(isset($_REQUEST['passBeginTime']) && $_REQUEST['passBeginTime'] != '' 
&& isset($_REQUEST['passEndTime']) && $_REQUEST['passEndTime'] != '')
{
    $passBeginTime = $_REQUEST['passBeginTime'];
    $passEndTime = $_REQUEST['passEndTime'];
    //editor:gyq_20190906 reason:正官庄汉天呼叫中心报表，时长筛选无效 7.8.5版本
    if($deValue == '汉天EC2'){
        $whereSQL .= " and (T1.talktime between $passBeginTime and $passEndTime) ";
    }else{
        $whereSQL .= " and (T1.starttime between $passBeginTime and $passEndTime) ";
    }
}
//查找范围_用户
if($_REQUEST['searchscope']=='SmOwner_Search_All'){
    unset($_REQUEST['searchscope']);
}
$useridlist=getuseridlist($_REQUEST['searchscope']);//查询范围用户id字串
if($useridlist != 0)
{
    $whereSQL .= ' and T1.userid in ('.$useridlist.')';
}

$orderby .= ' order by starttime desc ';

//计算总时长
$totalquery .= $whereSQL;
$totalresult=$adb->pquery($totalquery,array());
$totaltime=0;
if($adb->num_rows($totalresult)>0)
    $totaltime=$adb->query_result($totalresult,0,0);

$list_query =$sql_select. $whereSQL;

$in_list_query = $list_query . " and T1.".$type." = '2' ";
$out_list_query = $list_query . " and T1.".$type." = '1' ";
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
$count_result = $adb->query( mkCountQuery($list_query));
if($adb->num_rows($count_result)>0){
	$noofrows = $adb->query_result($count_result,0,"count");
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, '', $queryMode);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);

$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

if( $adb->dbType == "pgsql")
    $final_sql  = $list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new";
else
    $final_sql = $list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new";
$list_result = $adb->pquery($final_sql, array());

$num_rows=$adb->num_rows($list_result);

//查询结果，含录音文件
$select_result_arr=array();
$select_indexid_arr = array();
$deployarray = getSys_deploy(121);//获取系统参数设定
$deValue = $deployarray['deploy_value'];
$php52 = explode(':',$deValue);
//editor:gyq_20190329 reason:临时增加录音文件地址
$record_file_url = '';
$sql = 'select para_one from ld_wx_config where name=?';
$result = $adb->pquery($sql,array('record_file_url'));
if($adb->num_rows($result)>0){
    $record_file_url = $adb->query_result($result,0,'para_one');
}
if(empty($record_file_url)){
    $recordings_pre = $php52[0].':'.$php52[1].'/recordings/' ;
}else{
    $recordings_pre = $record_file_url.'/recordings/';
}

crm_load_class_file('fieldValueUitype','include/fields');
$subtotaltime=0;
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $cell_arr = array();
        $orign_id = $adb->query_result($list_result,$i,'id');
        $userid = $adb->query_result($list_result,$i,'userid');
        $type = $adb->query_result($list_result,$i,'type');
        $caller = $adb->query_result($list_result,$i,'caller');
        $callee = $adb->query_result($list_result,$i,'callee');
        $modulename = $adb->query_result($list_result,$i,'modulename');
        $indexid = $adb->query_result($list_result,$i,'indexid');
        $starttime = $adb->query_result($list_result,$i,'starttime');
        //editor:gyq_20190107 reason:记录未接通来电
        $bridging = $adb->query_result($list_result,$i,'bridging');
        if($tablename=='ld_sopho_phonerecord'){
            $endtime = $adb->query_result($list_result,$i,'endtime');
            $talktime = $endtime-$starttime;
            $starttime = date('Y-m-d H:i:s',$starttime);
            $recordnum =$recordings_pre.$adb->query_result($list_result,$i,'recordname');
        }else{
            $deadline = $adb->query_result($list_result,$i,'deadline');
            $talktime = $adb->query_result($list_result,$i,'talktime');
            $recordnum =$recordings_pre.$adb->query_result($list_result,$i,'recordnum');
        }
        $username = $adb->query_result($list_result,$i,'username');
        //来电去电  呼出type=1  呼入type=2
        if($type==1)
            $phone = $callee ;
        else
            $phone = $caller ;
        $cell_arr['indexid'] = $indexid;
        $cell_arr['orign_id'] = $orign_id;
        $cell_arr['UserName'] = $username;
        $cell_arr['BeginTime'] = $starttime;
        if($bridging=='fail'){
            $calltype_preheader = getFixedLabel('HANTIANPHONEMISSED') ;
        }else{
            $calltype_preheader = getFixedLabel('HANTIANPHONERECEIVED') ;
        }
        $cell_arr['CallType'] = $calltype_preheader.$calltype_transfer[$type] ;
        $cell_arr['Phone'] = fieldValueUitype::setReportMobileStyle($phone);
        $cell_arr['Time'] = $talktime;
        $cell_arr['SoundrecordingfileNew'] = $recordnum;
        $select_indexid_arr[$modulename][] = $indexid;
        if(empty($indexid)){
            $indexid = $i;
        }
        $select_result_arr[$modulename][$orign_id] = $cell_arr;
        $subtotaltime+=$talktime;

    }
}
//将通话记录对应的源单翻译成对应单据名
$href_list_arr = array();
foreach ($select_result_arr as $modulename=>$value){
    if(empty($modulename)) continue;
    $module_ids = implode(',',array_filter($select_indexid_arr[$modulename]));
    if(isset($module_id_transfer[$modulename]['accountid'])){
        $columns = $module_id_transfer[$modulename]['name'].','.$module_id_transfer[$modulename]['index']
            .',T2.accountid,T2.accountname';
        if(isset($module_id_transfer[$modulename]['contactid'])){
            $columns .= ',T3.contactid,T3.lastname';
        }
    }elseif(isset($module_id_transfer[$modulename]['vendorid'])){
        $columns = $module_id_transfer[$modulename]['name'].','.$module_id_transfer[$modulename]['index']
            .',T2.vendorid,T2.vendorname';
        if(isset($module_id_transfer[$modulename]['contactid'])){
            $columns .= ',T3.vendorcontactsid,T3.lastname';
        }
    }else{
        $columns = $module_id_transfer[$modulename]['name'].','.$module_id_transfer[$modulename]['index'];
    }

    $module_detail_sql = 'select '.$columns. ' from '.$module_id_transfer[$modulename]['table']
        .' where '.$module_id_transfer[$modulename]['index'].' in ('.$module_ids.')';
    $module_detail_result = $adb->pquery($module_detail_sql, array());
    $module_detail_rows=$adb->num_rows($module_detail_result);

    for ($i=0;$i<$module_detail_rows;$i++){
        //$name = $adb->query_result($module_detail_result,$i,str_replace('T1.','',$module_id_transfer[$modulename]['name']));
        $name = $adb->query_result($module_detail_result,$i,'indexname');
        $index = $adb->query_result($module_detail_result,$i,str_replace('T1.','',$module_id_transfer[$modulename]['index']));
        $href_list_arr[$index][$module_id_transfer[$modulename]['listkey1']] =$index;
        $href_list_arr[$index][$module_id_transfer[$modulename]['listkey2']] =$name;

        if(isset($module_id_transfer[$modulename]['accountid'])){
            $accountid = $adb->query_result($module_detail_result,$i,'accountid');
            $accountname = $adb->query_result($module_detail_result,$i,'accountname');
            $href_list_arr[$index]['AccountID'] =$accountid;
            $href_list_arr[$index]['AccountName'] =$accountname;
            if(isset($module_id_transfer[$modulename]['contactid'])){
                $href_list_arr[$index]['ContactID'] =$adb->query_result($module_detail_result,$i,'contactid');
                $href_list_arr[$index]['ContactName'] = $adb->query_result($module_detail_result,$i,'lastname');
            }
        }elseif(isset($module_id_transfer[$modulename]['vendorid'])){
            $vendorid = $adb->query_result($module_detail_result,$i,'vendorid');
            $vendorname = $adb->query_result($module_detail_result,$i,'vendorname');
            $href_list_arr[$index]['VendorID'] =$vendorid;
            $href_list_arr[$index]['VendorName'] =$vendorname;
            if(isset($module_id_transfer[$modulename]['contactid'])){
                $href_list_arr[$index]['VendorcontactsID'] =$adb->query_result($module_detail_result,$i,'vendorcontactsid');
                $href_list_arr[$index]['VendorcontactsName'] = $adb->query_result($module_detail_result,$i,'lastname');
            }
        }/*else{
            $columns = $module_id_transfer[$modulename]['name'].','.$module_id_transfer[$modulename]['index'];
        }*/
    }
}
//editor:gyq_20181224	0035849: （徐燕南问题：http://101.132.182.242/climaveneta [^]）电话小管家报表：条件显示7条，而实际明细只显示6条
//将单据名放入序时簿数组中
foreach ($select_result_arr as $module=>$content){
	if($module == 'Potentials'){
		foreach($content as $key=>$value){
			if(!empty($value['indexid'])){
				$potential_arr = getPotentialInfo($value['indexid']);
				$select_result_arr[$module][$key]['PotentialID'] = $potential_arr['potentials_id'];
				$select_result_arr[$module][$key]['PotentialNo'] = $potential_arr['potentialnames'];
				$select_result_arr[$module][$key]['AccountID'] = $potential_arr['AccountID'];
				$select_result_arr[$module][$key]['AccountName'] = $potential_arr['accountnames'];
				$select_result_arr[$module][$key]['ContactID'] = $potential_arr['ContactID'];
				$select_result_arr[$module][$key]['ContactName'] = $potential_arr['lastnames'];
			}
				
		}
	}else{
		foreach($content as $key=>$value){
			if(!empty($href_list_arr[$value['indexid']]))
				$select_result_arr[$module][$key] = array_merge($href_list_arr[$value['indexid']] ,$value);
		}
	}
}

//去除一级模块名键，降低数组维度
$select_result_arr_final = array();
foreach ($select_result_arr as $modulename=>$content){
    $select_result_arr_final = array_merge($select_result_arr_final,$content);
}
//讲此数组按开始时间倒叙排列
$select_result_arr_final_sort = multi_array_sort($select_result_arr_final,'BeginTime');

$in_list_result = $adb->pquery($in_list_query, array());
$in_num_rows=$adb->num_rows($in_list_result)    ;
$out_list_result = $adb->pquery($out_list_query, array());
$out_lnum_rows=$adb->num_rows($out_list_result);

$smarty->assign("RESULTLIST", $select_result_arr_final_sort);
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
$smarty->assign("CENTERTYPE", $callcenter_type);

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
function multi_array_sort($arr,$shortKey,$short=SORT_DESC,$shortType=SORT_REGULAR)
{
    foreach ($arr as $key => $data){
        $name[$key] = $data[$shortKey];
    }
    array_multisort($name,$shortType,$short,$arr);
    return $arr;
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

function getPotentialInfo($ids){
	global $adb;
	$data = array('potentialnames'=>'','accountnames'=>'','lastnames'=>'');
	if(!empty($ids)){
		$query = "select potentialname,accountname,lastname from ld_potential 
		left join ld_account on ld_account.accountid = ld_potential.accountid 
		LEFT JOIN ld_contactdetails on ld_potential.contactid = ld_contactdetails.contactid
		where ld_potential.potentialid in ($ids) and ld_potential.deleted = 0";
		$result = $adb->pquery($query,array());
		if($adb->num_rows($result) >= 1){
			for($i = 0; $i < $adb->num_rows($result); $i++){
				$potentialnames[] = $adb->query_result($result,$i,'potentialname');
				$accountname[] = $adb->query_result($result,$i,'accountname');
				$lastname[] = $adb->query_result($result,$i,'lastname');
			}
			$data = array(
				'potentialnames' => implode('<br>',$potentialnames),
				'accountnames' => implode('<br>',$accountname),
				'lastnames' => implode('<br>',$lastname)	
			);
		}
	}
	return $data;
}
?>