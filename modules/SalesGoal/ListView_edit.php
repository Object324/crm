
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
global $app_strings, $mod_strings, $currentModule, $theme,$current_user;
require_once("modules/$currentModule/$currentModule.php");

require('user_privileges/user_language_'.$current_user->id.'.php');
if(!function_exists("getScopeUserName")){
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
}


$smarty = new lingdangCRM_Smarty();
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
$tradeInfo = getVersionTradeInfo();
$smarty->assign('accountinfo',$tradeInfo['account']);
//unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
$nowyear = date('Y');
$UserArr = $MergeSmowner['UserCombo'];
//----------------------
if(isset($_REQUEST['viewrangeone_year']) && isset($_REQUEST['viewrangeone_month'])
&& isset($_REQUEST['viewrangetwo_year']) && isset($_REQUEST['viewrangetwo_month']))
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
        $smarty->assign('QUERYDATE1',$querydate1);
        $smarty->assign('QUERYDATE2',$querydate2);
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
        $smarty->assign('QUERYDATE1',$querydate1);
        $smarty->assign('QUERYDATE2',$querydate2);
    }
    
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

/**
 * 销售目标速度优化
 * @author Tujt 2015-07-01
 */

//print_r($selUser);

if(!empty($_REQUEST['SmOwnerSearchScope'])){
	if($_REQUEST['SmOwnerSearchScope'] == 'SmOwner_Search_Me'){
		$users_str = $current_user->id;
	}else if($_REQUEST['SmOwnerSearchScope'] == 'smowner_search_senior'){
		$users_str = $_REQUEST['senioruserid'];
	}else{
		$users_str = $_REQUEST['SmOwnerSearchScope'];
	}
    
    $_SESSION['SalesGoal']['listview_edit_user_str']=$users_str;
    $_SESSION['SalesGoal']['listview_edit_SearchScope']=$_REQUEST['SmOwnerSearchScope'];
}

else if ($_SESSION['SalesGoal']['listview_edit_user_str'])
{
    $users_str=$_SESSION['SalesGoal']['listview_edit_user_str'];
    $_REQUEST['SmOwnerSearchScope']=$_SESSION['SalesGoal']['listview_edit_SearchScope'];

    if($_REQUEST['SmOwnerSearchScope']=='smowner_search_senior')
    {
        $_REQUEST['senioruserid']=$users_str;
    }
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
$smarty->assign('ALLUSERID',$users_str);

require_once ('staticSalesGoal.class.php'); //跳转后不能重复
//import('modules.SalesGoal.staticSalesGoal','class');

$modstatic = new staticSalesGoal();
$scope = '';
if(isset($_REQUEST['SmOwnerSearchScope'])){
	$scope = $_REQUEST['SmOwnerSearchScope'];
}
$users = $modstatic->getUserInfo($scope);//获取用户数

if($_REQUEST['query']){
	$salesgoalInfo = $modstatic->getSalesGoalEditInfo($users,$yearmouth,$module_look,$usersGroup);
}else{
	$salesgoalInfo = $modstatic->getSalesGoalInfo($users,$yearmouth,$module_look,$usersGroup);
}
$smarty->assign('SALESGOALINFO',$salesgoalInfo);
$getsalesgoalsum = $modstatic->getSalesGoalSum($module_look);
$smarty->assign('SALESGOALSUM',$getsalesgoalsum);

if(isset($month_end))
    $smarty->assign('SECONDMOUTH',$month_end);
else
    $smarty->assign('SECONDMOUTH',12);
if(!isset($year_end))
    $year_end=$nowyear;
if(isset($month_start))
    $smarty->assign('ONEMOUTH',$month_start);
else
    $smarty->assign('ONEMOUTH',1);
$smarty->assign('YEARSTART',$year_start);
$smarty->assign('YEARMEND',$year_end);
$smarty->assign('ALLYEARMOUTH',implode(',', $yearmouth));
$smarty->assign('YEARMOUTH',$yearmouth);
$smarty->assign('MOUTH',$mouth);
$smarty->assign('QUERYDATE1',$querydate1);
$smarty->assign('QUERYDATE2',$querydate2);
//默认列数
/*if(count($mouth) <= 5)
{
    $smarty->assign('TABLEWIDTH',100);
}
else
{
    $smarty->assign('TABLEWIDTH',count($mouth)*30);
}*/
$smarty->assign('TABLEWIDTH',100);
if($languageType == 'en')
{
    $smarty->assign('TABLEWIDTHAFTER',100);
} 
else
{
    $smarty->assign('TABLEWIDTHAFTER',80);
    if($_REQUEST['action']=='ListView_edit'){
        $smarty->assign('TABLEWIDTHAFTER',100);
    }
    
}
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
if(isPermitted($currentModule,'DetailView','') == 'yes'){
	$smarty->assign('DETAILVIEW',1);
}else{
	$smarty->assign('DETAILVIEW',2);
}
if(isPermitted($currentModule,'EditView','') == 'yes')
    $smarty->assign('ISADMIN',1);
else
    $smarty->assign('ISADMIN',2);
//-----------------------
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
$smarty->assign('MODULELOOK',$module_look);
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
$smarty->assign('NOWYEAR',$nowyear);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('SUMTARGET',getContractCount($users,$querydate1,$querydate2));
$smarty->assign('ACTIONNAME','ListView_edit');

if($_REQUEST['query'] == 'yes'||$_REQUEST['ajax'] == 'yes'){
    $_REQUEST['diony']='yes';
    $smarty->assign('EDITRESULT','true');
    $tmparr['content']=$smarty->fetch('SalesGoalSettingAjax.tpl');
    ConvertTojsonString(1,$tmparr,'success');
    
}else{
    $smarty->display('SalesGoalListView_edit.tpl');
}

function getContractCount($userarr,$date1,$date2)
{
    global $adb;
    $arr1=explode('-',$date1);
    $arr2=explode('-',$date2);
    foreach($userarr as $key =>$val)
    {
        for($i = 1; $i<=3;$i++)
        {
            switch($i)
            {
                case 1:
                    $sqlname = 'contractamount';//签约额
                    break;
                case 2:
                    $sqlname = 'paymentamount';//回款额
                    break;
                case 3:
                    $sqlname = 'accountsnumber';//客户数
                    break;
            }
				//签约额、回款额 默认人民币符号
				if($i<=2)
					$currency_symbol = '¥';
				else
					$currency_symbol = '';
            if($arr1[0]-$arr2[0]==0 && !empty($key))
            {
                $sql="SELECT sum($sqlname) from ld_salestarget 
                    where targetyear= $arr1[0] AND  targetmouth >= $arr1[1] and
                    targetmouth <= $arr2[1] and userid =$key "; 
                $result = $adb->pquery($sql);
                 if($adb->query_result($result,0,0) > 0)
                    $arr[$key][$i] = $currency_symbol . $adb->query_result($result,0,0);
                 else
                    $arr[$key][$i] =  $currency_symbol . '0.00';
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
                    $sql="SELECT sum($sqlname) from ld_salestarget 
                where targetyear = $targetyear and targetmouth  $between and userid= $key";
                    $result = $adb->pquery($sql);
                    $arr[$key][$i] += $currency_symbol . $adb->query_result($result,0,0);
                }
            }
        }
    }
    return $arr;
}
?>