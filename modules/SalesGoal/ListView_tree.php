
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
//拼接树表所需要的时间，
$querydate1_start = $querydate1 .'-1';
$querydate2_end = $querydate2 .'-'.DateOperation::getMonthDays($querydate2.'-01');
$search_date = $querydate1_start.'~'.$querydate2_end;
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
    
    $_SESSION['SalesGoal']['listview_tree_user_str']=$users_str;
    $_SESSION['SalesGoal']['listview_tree_SearchScope']=$_REQUEST['SmOwnerSearchScope'];
}

else if ($_SESSION['SalesGoal']['listview_tree_user_str'])
{
    $users_str=$_SESSION['SalesGoal']['listview_tree_user_str'];
    $_REQUEST['SmOwnerSearchScope']=$_SESSION['SalesGoal']['listview_tree_SearchScope'];
   
    if($_REQUEST['SmOwnerSearchScope']=='smowner_search_senior')
    {
        $_REQUEST['senioruserid']=$users_str;
    }
}
$smarty->assign('ALLUSERID',$users_str);
$scope=$_REQUEST['SmOwnerSearchScope'];
import('modules.SalesGoal.staticSalesGoal','class');
$modstatic = new staticSalesGoal();

//start 开始判断所有用户的目标值 如果都为空跳转到目标设置
////bug0041428  废弃
//$users = $modstatic->getUserInfo('SmOwner_Search_All');//获取用户数
//$usersGroup = $modstatic->getUserGroup($users);
//$usersalesgoal = $modstatic->getUserSalesGoalInfo($users,$yearmouth,$module_look,$usersGroup);
//$usersalesgoalsum = $modstatic->getUserSalesGoalSum($usersGroup);
//$usersalesgoalsumall = $modstatic->getUserSalesGoalSum_All();
//if($usersalesgoalsumall['tolook'] ==0){
//    //总目标为零的时候跳转到目标设置页面
//    include("ListView_edit.php");
//    exit();
//}
////end


$users = $modstatic->getUserInfo($scope);//获取用户数
$usersGroup = $modstatic->getUserGroup($users);
$usersalesgoal = $modstatic->getUserSalesGoalInfo($users,$yearmouth,$module_look,$usersGroup);

$monthtotal = $modstatic->getMonthTotal();
$usersalesgoalsum = $modstatic->getUserSalesGoalSum($usersGroup);
$usersalesgoalsumall = $modstatic->getUserSalesGoalSum_All();

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
if(!vtlib_isModuleActive('CashBill')){
	$smarty->assign('CASHBILLSTATUS','no');
}else{
	$smarty->assign('CASHBILLSTATUS','yes');
}
$treeValue =$modstatic->getGetSalesGoalTree($users,$usersGroup,$search_date,$module_look);

$smarty->assign("treeValue",$treeValue);
$treeHtml = $smarty->fetch('SalesGoalListViewAjax_tree.tpl');
$smarty->assign("treeHtml",$treeHtml);

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
    $tmparr['content']= $smarty->fetch('SalesGoalListViewAjax_tree.tpl');
    ConvertTojsonString(1,$tmparr,'success');
}
else
$smarty->display('SalesGoalListView_tree.tpl');



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

?>