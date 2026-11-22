
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


$smarty = new lingdangCRM_Smarty();
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
$tradeInfo = getVersionTradeInfo();
$smarty->assign('accountinfo',$tradeInfo['account']);
//unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
$nowyear = date('Y');
$UserArr = $MergeSmowner['UserCombo'];

//获取最近一次查询的日期
crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
SalesGoalOperation::getSearchHistory();

if(isset($_REQUEST['viewrangeone_year']) && isset($_REQUEST['viewrangeone_month'])
    && isset($_REQUEST['viewrangetwo_year']) && isset($_REQUEST['viewrangetwo_month']))
{
    $year_start = (float)$_REQUEST['viewrangeone_year'];
    $year_end = (float)$_REQUEST['viewrangetwo_year'];
    $month_start = (float)$_REQUEST['viewrangeone_month'];
    $month_end = (float)$_REQUEST['viewrangetwo_month'];
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
if(isset($_REQUEST['targetid']))
    $targetid=$_REQUEST['targetid'];
$smarty->assign('ALLUSERID',$users_str);


//import('modules.SalesGoal.staticSalesGoal','class');

$modstatic = new SalesGoalNew();

$PermitSalesgoalInfo = $modstatic->getPermitSalesGoal($targetid);

$smarty->assign('PermitSalesgoalInfo',$PermitSalesgoalInfo);
$default_arr = [];
if(!empty($targetid)){
    foreach ($PermitSalesgoalInfo as $tmp_info){
        if($tmp_info['selected'] == 'yes'){
            $default_arr = $tmp_info;
            break;
        }
    }
}
if(sizeof($default_arr)==0){
    if(sizeof($PermitSalesgoalInfo)>0){
        $default_arr = reset($PermitSalesgoalInfo);
    }else{
        $default_arr = [];
    }
}
$targetid = $default_arr['targetid'];
$scopetype = $default_arr['scope']; //目标范围类型
$modulename = $default_arr['modulename'];
$datatype = $default_arr['datatype'];
if($datatype == 'num'){
    $decimal = 0;
}else{
    $decimal = SalesGoalNew::getAmountDecimal();
}


$smarty->assign('decimal',$decimal);
$smarty->assign('default_arr',$default_arr);

$scope = '';
if(isset($_REQUEST['SmOwnerSearchScope'])){
    $scope = $_REQUEST['SmOwnerSearchScope'];
}

$record_info = $modstatic->GetRecordInfo($default_arr,$scope);
$usersGroup = $modstatic->getUserGroup($record_info,$targetid);

$smarty->assign('modulename',$modulename);
$smarty->assign('record_str',implode(',',array_keys($record_info)));
$smarty->assign('groupid_str',implode(',',array_keys($usersGroup)));
$smarty->assign('modulename',$modulename);
$smarty->assign('modulelabel',getTranstab($modulename));
$smarty->assign('usersGroup',$usersGroup);
$smarty->assign('isshowgroup',$modstatic->IsShowGroupTarget($targetid));

if($_REQUEST['query']){
    $mode = 'edit';
}else{
    $mode = 'detail';
}
$salesgoalInfo = $modstatic->getSalesGoalInfo($record_info,$yearmouth,$targetid,$usersGroup,$mode);

$smarty->assign('SALESGOALINFO',$salesgoalInfo);
$getsalesgoalsum = $modstatic->getSalesGoalSum($datatype,$mode);

$permit_arr = $modstatic->getAllPermitArr();

$smarty->assign('PERMITARR',$permit_arr);
$smarty->assign('RowHeaderArr',$modstatic->row_head_arr);
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

$smarty->assign('TABLEWIDTH',100);
$languageType = getLanguageType($current_user);
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

$smarty->assign('RECORDINFO',$record_info);

$smarty->assign('NOWYEAR',$nowyear);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('ACTIONNAME','ListView_edit_new');

//hzx 20231215 列表页面页签优化
$Navbarlist = SalesGoalNew::getSalesGoalListViewNavbar();
$smarty->assign('ListViewNavbarcur',3);
$smarty->assign('ListViewNavbarlist',json_encode($Navbarlist));

if($_REQUEST['query'] == 'yes'||$_REQUEST['ajax'] == 'yes'){
    $_REQUEST['diony']='yes';
    $smarty->assign('EDITRESULT','true');
    $tmparr['modulename'] = $modulename;
    $tmparr['content']=$smarty->fetch('modules/SalesGoal/SalesGoalSettingAjaxNew.tpl');
    ConvertTojsonString(1,$tmparr,'success');

}else{
    $smarty->display('modules/SalesGoal/SalesGoalListView_edit_new.tpl');
}

?>