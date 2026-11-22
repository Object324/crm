
<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global $app_strings, $mod_strings, $currentModule,$theme,$current_user;
require_once("modules/$currentModule/$currentModule.php");
require_once('include/home.php');
$is_admin=is_admin($current_user);

//$_SESSION['SalesGoal']=array();
/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求
*/
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户

$smarty = new lingdangCRM_Smarty();
$tradeInfo = getVersionTradeInfo();
$smarty->assign('accountinfo',$tradeInfo['account']);
$nowyear = date('Y');
$UserArr = $MergeSmowner['UserCombo'];
//----------------------
if(isset($_REQUEST['viewrangeone_year']) && isset($_REQUEST['viewrangeone_month'])
&& isset($_REQUEST['viewrangetwo_year']) && isset($_REQUEST['viewrangetwo_month']) && isset($_REQUEST['module_look']))
{
    $year_start=$_REQUEST['viewrangeone_year'];
    $year_end=$_REQUEST['viewrangetwo_year'];
    $month_start=$_REQUEST['viewrangeone_month'];
    $month_end=$_REQUEST['viewrangetwo_month'];
    if($year_start == $year_end){
        //$month_count=$month_end-$month_start+1;
        for($i=$month_start;$i<=$month_end;$i++)
        {
            $mouth[]=$i;
            $yearmouth[] = $year_start . '-' . $i;
        }
        $querydate1=$year_start.'-'.$month_start;
        $querydate2=$year_start.'-'.$month_end;
    }else{
        for($i=$month_start;$i<=12;$i++)
        {
            $mouth[]=$i;
            $yearmouth[] = $year_start . '-' . $i;
        }
        $num = $year_end - $year_start;
        if( $num > 1){
            for($i = 1; $i<$num;$i++)
            {
                for($j=1;$j<=12;$j++)
                {
                    $mouth[]=$j;
                    $yearmouth[] = $year_start + $i . '-' . $j;
                }
            }
        }
        for($i=1;$i<=$month_end;$i++)
        {
            $mouth[]=$i;
            $yearmouth[] = $year_end . '-' . $i;
        }
        $querydate1=$year_start.'-'.$month_start;
        $querydate2=$year_end.'-'.$month_end;
    }
    $smarty->assign('QUERYDATE1',$querydate1);
    $smarty->assign('QUERYDATE2',$querydate2);
}
else
{
    //默认显示
    for($i = 1; $i<=12; $i++)
    {
        $mouth[] = $i;
        $yearmouth[] = $nowyear . '-' . $i;
    }
    $year_start = $nowyear;
    $querydate1=$nowyear.'-'.'1';
    $querydate2=$nowyear.'-'.'12';
}
if(isPermitted($currentModule,'DetailView','') == 'yes'){
	$smarty->assign('DETAILVIEW',1);
}else{
	$smarty->assign('DETAILVIEW',2);
}
if(isset($_REQUEST['module_look']))
    $module_look=$_REQUEST['module_look'];
else
{
    //edit:can 20210128 销售目标功能优化，目标查看界面去掉目标为0的记录
    $sql="select * from ld_systems_deploy where deploy_type=269";
    $result=$adb->pquery($sql,array());
   
    $module_look=$adb->query_result($result,0,'deploy_value');
}


/**
 * 销售目标速度优化
 * @author Tujt 2015-07-01
 */
$scope = '';
if(!empty($_REQUEST['SmOwnerSearchScope'])){
	if($_REQUEST['SmOwnerSearchScope'] == 'SmOwner_Search_Me'){
		$users_str = $current_user->id;
	}else if($_REQUEST['SmOwnerSearchScope'] == 'smowner_search_senior'){
		$users_str = $_REQUEST['senioruserid'];
	}else{
		$users_str = $_REQUEST['SmOwnerSearchScope'];
	}

    $_SESSION['SalesGoal']['listview_chart_user_str']=$users_str;
    $_SESSION['SalesGoal']['listview_chart_SearchScope']=$_REQUEST['SmOwnerSearchScope'];
}


else if ($_SESSION['SalesGoal']['listview_chart_user_str'])
{
    $users_str=$_SESSION['SalesGoal']['listview_chart_user_str'];
    $_REQUEST['SmOwnerSearchScope']=$_SESSION['SalesGoal']['listview_chart_SearchScope'];

    if($_REQUEST['SmOwnerSearchScope']=='smowner_search_senior')
    {
        $_REQUEST['senioruserid']=$users_str;
    }
}
$smarty->assign('ALLUSERID',$users_str);
$scope=$_REQUEST['SmOwnerSearchScope'];
import('modules.SalesGoal.staticSalesGoal','class');
$modstatic = new staticSalesGoal();
$users = $modstatic->getUserInfo($scope);//获取用户数
$usersGroup = $modstatic->getUserGroup($users);
$usersalesgoal = $modstatic->getUserSalesGoalInfo($users,$yearmouth,$module_look,$usersGroup);
$smarty->assign('USERSALESGOAL',$usersalesgoal);//销售目标、完成、达标率列表

$monthtotal = $modstatic->getMonthTotal();
$smarty->assign('MONTHTOTAL',$monthtotal);//销售目标、完成  合计
$usersalesgoalsum = $modstatic->getUserSalesGoalSum($usersGroup);
$smarty->assign('USERSALESGOALSUM',$usersalesgoalsum);//销售目标、完成、达标率列表

$usersalesgoalsumall = $modstatic->getUserSalesGoalSum_All();
$smarty->assign('USERSALESGOALSUMALL',$usersalesgoalsumall);
if($usersalesgoalsumall['tolook']!=0)
{
    $total_complete=sprintf('%.2f',$usersalesgoalsumall['complete']/$usersalesgoalsumall['tolook']*100).'%';

}
else
{
    $total_complete='0%';
}
$smarty->assign("total_complete",$total_complete);//总目标完成率

if(isset($month_end))
    $smarty->assign('SECONDMOUTH',$month_end);
else
    $smarty->assign('SECONDMOUTH',12);
if(isset($month_start))
    $smarty->assign('ONEMOUTH',$month_start);
else
    $smarty->assign('ONEMOUTH',1);
if(!isset($year_end))
    $year_end=$nowyear;

$smarty->assign('YEARSTART',$year_start);
$smarty->assign('MODULELOOK',$module_look);
$smarty->assign('YEAREND',$year_end);
$smarty->assign('YEARMOUTH',$yearmouth);
$smarty->assign('MOUTH',$mouth);
$smarty->assign('QUERYDATE1',$querydate1);
$smarty->assign('QUERYDATE2',$querydate2);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//默认列数
if(count($mouth) <= 5)
    $smarty->assign('TABLEWIDTH',100);
else
    $smarty->assign('TABLEWIDTH',count($mouth)*30);
//默认年份
for($i = 0; $i<=5; $i++)
{
    $lastyear[] = $nowyear + $i;
    $lastyear[] = $nowyear - $i;
}
$lastyear=array_unique($lastyear);
natsort($lastyear);

//默认月份
for($i = 1; $i<=12; $i++)
{
    $mouthall[] = $i;
}
if($is_admin == true)
    $smarty->assign('ISADMIN',1);
else
    $smarty->assign('ISADMIN',2);
//-----------------------
$homeObj=new Homestuff;
if(!isset($_REQUEST['SmOwnerSearchScope']))
    $owner = 'SmOwner_Search_All';
else
    $owner = $_REQUEST['SmOwnerSearchScope'];
//$homestuff_values=$homeObj->getHomePageStuff(4,'SalesOrder',$owner);
if(!vtlib_isModuleActive('OutboundOrder')){
	$smarty->assign('OUTBOUNDORDERSTATUS','no');
}else{
	$smarty->assign('OUTBOUNDORDERSTATUS','yes');
}
if(!vtlib_isModuleActive('Invoice')){
	$smarty->assign('INVOICESTATUS','no');
}else{
	$smarty->assign('INVOICESTATUS','yes');
}

//2020-5-9 start 新图表代码
$highChartValue = $modstatic->newGetSalesGoalReport();

$smarty->assign('highChartValue',json_encode($highChartValue));
$chartHtml = $smarty->fetch('SalesGoalListViewAjax_chart.tpl');
$smarty->assign("chartHtml",$chartHtml);

//2020-5-9 end 新图表代码
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
$smarty->assign('MOUTH_ALL',$mouthall);
$smarty->assign('LASTYEAR',$lastyear);
$smarty->assign('SELECTEDSCOPE',$_REQUEST['SmOwnerSearchScope']);
$smarty->assign('USERS',$users);
$smarty->assign('USERSGROUP',$usersGroup);
$smarty->assign('NOWYEAR',$nowyear);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('ACTIONNAME','ListView');
if($_REQUEST['ajax']=='yes'){
    $_REQUEST['diony']='yes';
    $tmparr['content']= $smarty->fetch('SalesGoalListViewAjax_chart.tpl');
    ConvertTojsonString(1,$tmparr,'success');
}
else
$smarty->display('SalesGoalListView_chart.tpl');



function getScopeUserName($type,$userid,$userarr)
{
    global $current_user;
	if($type == 'senior'){
		$userid = explode(',',$userarr);
		foreach($userid as $key=>$val)
		{
			$user[$val] = getOwnerName($val);
		}
	}
	else
	{
		foreach($userarr as $key=>$val)
		{
			if($type == 'All')
			{
				$user[$key] = getOwnerName($key);
			}
			else
			{
				if($userid == $key)
					$user[$key] = getOwnerName($key);
			}
		}
		if($type == 'All' || $userid == $current_user->id)
			$user[$current_user->id] = getOwnerName($current_user->id);
	}
    return $user;
}
function getSalesGoalAllMonth($yearmouth,$scope,$targettype,$users)
{
    global $currentModule,$current_user,$adb;
    require("user_privileges/user_privileges_".$current_user->id.".php");
    foreach($users as $key => $val)
    {
        $userarr[] =$key;
    }
    $useridall = implode(',', $userarr);
    for($i = 0; $i<count($yearmouth); $i++)
    {
        $query = "select sum($targettype) as number from ld_salestarget";
        $yearinfo = explode('-',$yearmouth[$i]);
        $query .= " where targetyear = $yearinfo[0] and targetmouth = $yearinfo[1] ";
        switch($scope)
        {
            case 'SmOwner_Search_All':
                $Smownerids= getCurSmOwnerSearchScope($modulename);
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
                $query .= " and  ld_salestarget.userid in ( ".$SearchScope.")";
                break;
            case 'SmOwner_Search_Me':
                $query .=" and ld_salestarget.userid=".$current_user->id;
                break;
            case 'SmOwner_Search_Group':
                $query=" and ld_crmEntity.SmOwnerID in (select groupid from ld_Groups )";
                break;
            case 'SmOwner_Search_Create':
                $query .=" and ld_salestarget.userid=".$current_user->id;
                break;
            case 'smowner_search_senior':
                $query .=" and ld_salestarget.userid in (".$_REQUEST['senioruserid'].")";
                break;
            default:
                $query .= " and ld_salestarget.userid=".$scope;
        }
        $result = $adb->pquery($query);
        if($adb->query_result($result,0,0) > 0)
            $targetval = $adb->query_result($result,0,0);
        else
            $targetval = 0;
        //目标
        $lastentries[$i] = array(
            0 => 1,
            1 => $targetval,
            2 => $yearmouth[$i],
        );
        //完成
        if($yearinfo[1] < 10)
            $date = $yearinfo[0] . '-'. '0'.$yearinfo[1];
        else
            $date = $yearmouth[$i];
        $nowentries[$i] = array(
            0 => 1,
            1 => getSalesGoalTotalInfo_total($useridall,$date,'',$targettype,1),
            2 => $yearmouth[$i],
        );
    }
    $values=Array('ModuleName'=>'CompanyAllMonth'.$currentModule,'Entries'=>$nowentries,'LastEntries'=>$lastentries);
    $resultValue = array('Maxentries'=>12,'Details'=>$values,'type' =>'chart');
    return $resultValue;
}
/**
 * 得到合计完成任务合计值
 * andy
 * 20140330
 */
function getSalesGoalTotalInfo_total($userid,$date1,$date2,$type,$cstys='')
{
    global $adb;
    $tradeInfo = getVersionTradeInfo();
    $sostatus_cancel = '已作废';
    //zxm 2022-6-16 四川中兴  合同订单已作废的值改成了 已作废（Voided）  //史文龙讲了只改合同订单的
    if($tradeInfo['account']=='sczhongxing'){
        $sostatus_cancel = '已作废（Voided）';
    }
    if($date2 != '')
        $between = 'between "'.$date1.'-1" and "'.$date2.'-31"';
    else
        $between = ' like "%'.$date1.'%"';
    switch($type)
    {
        case 'paymentamount':
            $sql = 'SELECT sum(if(ld_cashbill.currency_id > 1,ld_cashbill.Total/ld_cashbill.conversion_rate,ld_cashbill.Total)) as total from ld_cashbill where ld_cashbill.smownerid in ('.$userid.') AND ld_cashbill.deleted=0 and ld_cashbill.cashbilldate '.$between.' AND ld_cashbill.`cashbillid` > 0 LIMIT 1;';
            break;
        case 'contractamount':
            $sql = 'SELECT sum(if(ld_salesorder.currency_id > 1,ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total)) as total from ld_salesorder where ld_salesorder.smownerid in ('.$userid.') AND  ld_salesorder.sostatus != "'.$sostatus_cancel.'"  AND ld_salesorder.deleted=0 and ld_salesorder.signed_data '.$between.' AND ld_salesorder.salesorderid > 0 LIMIT 1;';
            break;
        case 'accountsnumber':
            $sql = 'SELECT count(ld_account.accountid) from ld_account where ld_account.smownerid in ('.$userid.') AND ld_account.deleted=0 and ld_account.createdtime '.$between.' AND ld_account.accountid > 0 LIMIT 1; ';
            break;
    }
    if($type == 'contractamount'){
        $query = 'SELECT sum(if(ld_servicecontracts.currency_id > 1,ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total)) as total from ld_servicecontracts 
			where ld_servicecontracts.smownerid in ('.$userid.') AND  ld_servicecontracts.contract_status != "已作废"  
			AND ld_servicecontracts.deleted=0 and ld_servicecontracts.due_date '.$between.' AND ld_servicecontracts.servicecontractsid > 0 LIMIT 1;';
    }
    $result = $adb->pquery($sql,array());
    $resultService = $adb->pquery($query,array());
    if($type == 'contractamount'){
        if($adb->query_result($result,0,0) > 0 || $adb->query_result($resultService,0,0) > 0)
            if($cstys != '')
                return $adb->query_result($result,0,0) + $adb->query_result($resultService,0,0);
            else
                return setNumberFormat($adb->query_result($result,0,0) + $adb->query_result($resultService,0,0));
        else
            return 0.00;
    }else{
        if($adb->query_result($result,0,0) > 0)
            if($cstys != '')
                return $adb->query_result($result,0,0);
            else
                return setNumberFormat($adb->query_result($result,0,0));
        else
            return 0.00;
    }
}
/**
 *andy
 * 20140330
 * 得到完成的任务
 */
function getSalesGoalOverInfo($userid,$year,$type)
{
    global $adb;
    $tradeInfo = getVersionTradeInfo();
    $sostatus_cancel = '已作废';
    //zxm 2022-6-16 四川中兴  合同订单已作废的值改成了 已作废（Voided）  //史文龙讲了只改合同订单的
    if($tradeInfo['account']=='sczhongxing'){
        $sostatus_cancel = '已作废（Voided）';
    }
    static $salesgoal_static_num;
    $key = 'getSalesGoalOverInfo_'.$userid.'_'.$year.'_'.$type;
    if(isset($salesgoal_static_num[$key])){
        return $salesgoal_static_num[$key];
    }
    $date1=$year.'-1';
    $date2=$year.'-31';
    switch($type)
    {
        case 'paymentamount':
            $sql = 'SELECT sum(if(ld_cashbill.currency_id > 1,ld_cashbill.Total/ld_cashbill.conversion_rate,ld_cashbill.Total)) as total from ld_cashbill where ld_cashbill.smownerid='.$userid.' AND ld_cashbill.deleted=0 and ld_cashbill.cashbilldate between "'.$date1.'" and "'.$date2.'" AND ld_cashbill.`cashbillid` > 0 LIMIT 1;';
            break;
        case 'contractamount':
            $sql = 'SELECT sum(if(ld_salesorder.currency_id > 1,ld_salesorder.total/ld_salesorder.conversion_rate,ld_salesorder.total)) as total from ld_salesorder where ld_salesorder.smownerid='.$userid.' AND ld_salesorder.sostatus != "'.$sostatus_cancel.'"  AND ld_salesorder.deleted=0 and ld_salesorder.signed_data between "'.$date1.'" and "'.$date2.'" AND ld_salesorder.salesorderid > 0 LIMIT 1;';
            break;
        case 'accountsnumber':
            $sql = 'SELECT count(ld_account.accountid) from ld_account where ld_account.smownerid='.$userid.' AND ld_account.deleted=0 and ld_account.createdtime between "'.$date1.'" and "'.$date2.'" AND ld_account.accountid > 0 LIMIT 1;';
            break;
    }
    if($type == 'contractamount'){
        $query = 'SELECT sum(if(ld_servicecontracts.currency_id > 1,ld_servicecontracts.total/ld_servicecontracts.conversion_rate,ld_servicecontracts.total)) as total from ld_servicecontracts 
			where ld_servicecontracts.smownerid in ('.$userid.') AND  ld_servicecontracts.contract_status != "已作废"  
			AND ld_servicecontracts.deleted=0 and ld_servicecontracts.due_date between "'.$date1.'" and "'.$date2.'" AND ld_servicecontracts.servicecontractsid > 0 LIMIT 1;';
    }
    $result = $adb->pquery($sql,array());
    $resultService = $adb->pquery($query,array());
    if($type == 'contractamount'){
        if($adb->num_rows($result) > 0 || $adb->query_result($resultService,0,0) > 0)
            $goal = $adb->query_result($result,0,0) + $adb->query_result($resultService,0,0);
        else
            $goal = 0.00;
    }else{
        if($adb->num_rows($result) > 0){
            $goal = $adb->query_result($result,0,0);
            //$goal = setNumberFormat($goal);
        }
        else
            $goal = 0.00;
    }
    $salesgoal_static_num[$key] = $goal;
    return $goal;
}
function getSalesGoalTotalPercent_total($userid,$date1,$date2,$type)
{
    $target_todo=getSalesGoalPercentInfo_total($userid,$date1,$date2,$type,1);
    if(!$target_todo || 0 == $target_todo) return '0%';
    $over_do=getSalesGoalTotalInfo_total($userid,$date1,$date2,$type,1);
    return setNumberFormat(round($over_do/$target_todo*100,2)).'%';
}
/**
 * by andy
 * 20140330
 * 计算完成百分比
 */
/*
edit:andrew
20140918
getSalesGoalPercentInfo中调用该函数计算的时候已经格式化的会出错
*/
function getSalesGoalPercentInfo($userid,$year,$type)
{
    $target= getSalesGoalToLook($userid,$year,$type,1);
    if(!$target || 0 == $target) return '0%';
    $overtodo=getSalesGoalOverInfo($userid,$year,$type);

    return setNumberFormat(round($overtodo/$target*100,0)).'%';
}
/**
 * andy
 * 20140330
 * 得到目标值
 */
function getSalesGoalToLook($userid,$year,$type,$cstys=''){
    //global $adb;
    ////print_r($year);
    //$arr=explode('-',$year);
    //$sql = "select $type from ld_salestarget where userid = $userid and targetyear =$arr[0] and targetmouth = $arr[1]";
    ////echo $sql;exit;
    //$result = $adb->pquery($sql);
    //if($adb->query_result($result,0,0) > 0){
    //$goal = $adb->query_result($result,0,0);
    //if($cstys!==''){
    //return $goal;
    //}else{
    //return setNumberFormat($goal);
    //}
    //}
    //else
    //return '0.00';
    static $static_salestarget_info;
    if(!$static_salestarget_info || empty($static_salestarget_info)){
        global $adb;
        $query = 'SELECT userid,targetyear,targetmouth,paymentamount,contractamount,accountsnumber 
					FROM ld_salestarget ORDER BY id;';
        $result = $adb->query($query);
        $rows = $adb->num_rows($result);
        $static_salestarget_info = array();
        if($rows > 0){
            for($i=0;$i<$rows;++ $i){
                $userid = $adb->query_result($result,$i,'userid');
                $targetyear = $adb->query_result($result,$i,'targetyear');
                $targetmouth = $adb->query_result($result,$i,'targetmouth');
                $paymentamount = $adb->query_result($result,$i,'paymentamount');
                $contractamount = $adb->query_result($result,$i,'contractamount');
                $accountsnumber = $adb->query_result($result,$i,'accountsnumber');
                $static_salestarget_info[$userid][$targetyear.'-'.$targetmouth]['paymentamount'] = $paymentamount;
                $static_salestarget_info[$userid][$targetyear.'-'.$targetmouth]['contractamount'] = $contractamount;
                $static_salestarget_info[$userid][$targetyear.'-'.$targetmouth]['accountsnumber'] = $accountsnumber;
            }
        }
    }
    $goal = 0;
    if(!empty($static_salestarget_info)){
        if(isset($static_salestarget_info[$userid][$year][$type])){
            $goal = $static_salestarget_info[$userid][$year][$type];
        }
    }
    if(empty($cstys)){
        $goal = setNumberFormat($goal);
    }
    return $goal;
}
/**
 * andy
 * 20140330
 * 得到合计目标值
 */
function getSalesGoalPercentInfo_total($userid,$date1,$date2,$type,$cstys='')
{
    global $adb;
    $arr1=explode('-',$date1);
    $arr2=explode('-',$date2);
    if($arr1[0]-$arr2[0]==0)
    {
        $sql="SELECT sum($type) from ld_salestarget 
            where targetyear= $arr1[0] AND  targetmouth >= $arr1[1] and
            targetmouth <= $arr2[1] and userid =$userid ";
        //echo $sql;
        $result = $adb->pquery($sql);
        if($adb->query_result($result,0,0) > 0)
            $total= $adb->query_result($result,0,0);
        else
            $total = 0;
    }
    elseif($arr2[0]-$arr1[0] >= 1){

        $num = $arr2[0]-$arr1[0] + 1;
        for($j = 1; $j<=$num; $j++)
        {
            if($j == 1) //第一年
            {
                $between = "between $arr1[1] and 12";
                $targetyear = $arr1[0];
            }
            else if($j == $num) //最后一年
            {
                $between = "between 1 and $arr2[1]";
                $targetyear = $arr2[0];
            }
            else{
                $between = "between 1 and 12";
                $targetyear = $arr1[0] + $j - 1;
            }
            $sql="SELECT sum($type) from ld_salestarget 
                where targetyear = $targetyear and targetmouth  $between and userid= $userid";

            $result = $adb->pquery($sql);
            $total += $adb->query_result($result,0,0);
            //echo $sql."<br>";
        }
    }
    if($cstys != '')
        return $total;
    else
        return setNumberFormat($total);
}
function getSalesGoalUserInfo($userid,$year,$type)
{
    global $adb;
    switch($type)
    {
        case 1:
            $sqlname = 'paymentamount';
            break;
        case 2:
            $sqlname = 'contractamount';
            break;
        case 3:
            $sqlname = 'accountsnumber';
            break;
    }
    //print_r($year);
    $arr=explode('-',$year);
    $sql = "select $sqlname from ld_salestarget where userid = ? and targetyear = ? and targetmouth = ?";
    //echo $sql;exit;
    $result = $adb->pquery($sql,array($userid,$arr[0],$arr[1]));
    if($adb->query_result($result,0,0) > 0)
        $res= $adb->query_result($result,0,0);
    else
        $res= '0.00';
    if(!isset($_REQUEST['query'])) $res = setNumberFormat($res);
    return $res;
}
?>