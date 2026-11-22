<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
$advft_criteria = array();

//销售目标点击跳转
global $current_user,$languageType;
$targetid = $_REQUEST['targetid'];
$record_str = $_REQUEST['record_str'];
//判断是否有该模块权限，若无权限则不跳转对应模块
$search_date_value =$_REQUEST['search_date_value'];
$date = explode('~',$search_date_value);
$comparator='bw';
if(sizeof($date) < 2){
    $data_start= $search_date_value.'-01';
    $data_end =$search_date_value.'-'.DateOperation::getMonthDays($search_date_value.'-01');
    $date_value=$data_start.','.$data_end;
}else{
    $date_value=$date[0].','.$date[1];
}
crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');

$modstatic = new SalesGoalNew();
$SalesGoalinfo = $modstatic->getSalesGolaInfoByid($targetid);
$modulename = $SalesGoalinfo['modulename'];
$record_arr = explode(',',$record_str);
if($modulename == 'Users'){
    $type = 'user';
}else{
    $type = $modulename;
}
$record_info = SalesGoalOperation::getEntitynameByid($type,$record_arr);

$detailinfo = $SalesGoalinfo['detailinfo'];
$module_arr = [];
foreach ($detailinfo as $tmp_detail){
    $entitytype = $tmp_detail['entitytype'];
    if(!isPermitted($entitytype,'ListVieww')){
        continue;
    }
    if($entitytype == 'Accounts' || $entitytype == 'Leads'){
        resetPublicSession();
    }

    $tmp_arr = $modstatic->getListViewCondition($tmp_detail,$date_value,$record_str,$record_info,$modulename);
    if(count($tmp_arr) == 0)continue;
    $module_arr[] = $entitytype;
    $_SESSION['LiveViewSearch'][$entitytype]['input'] = $tmp_arr;
    //清空当前模块的搜索条件
    $_SESSION['lvs'][$entitytype] = array();
    $_SESSION['lvs'][$entitytype]['SearchScope'] = 'SmOwner_Search_All';
}

$arr['modulearr'] = $module_arr;
$arr['remindstr'] = getFixedLabel('UNABLETOVIEWTARGETDETAILS');
//zkt 20220424 【ID1002776】【销售目标的超链接只跳转到销售合同模块】
ConvertTojsonString(1,$arr,'success');
//exit();
?>