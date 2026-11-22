<?php
/**
* reason:TimeSheet提交情况统计表
* eidt:xiaoshun
* date:2016-09-01
**/

global $adb,$theme;
global $current_user;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";


$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);

$MergeSmowner["OtherInfo"]['SmOwner_Search_All'] = array(getFixedLabel('ALL')=>'selected');
$user_arr=get_user_array(FALSE, "Active");
$users_combo = get_select_options_array($user_arr);

$MergeSmowner['UserCombo'] = $users_combo;
$searchscope = 'SmOwner_Search_All';
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


//开始日期、结束日期
$date_sql ="select startdate as startdate ,closingdate as closingdate from ld_campaign where expectedresponse=? order by startdate  limit 1";
$date_result = $adb->pquery($date_sql,array('未结算'));

$date_num_rows = $adb->num_rows($date_result);

if($date_num_rows > 0){//日期区间默认取最早未结算状态单据的起止日期
    $fday = $adb->query_result($date_result,0,'startdate');
    $lday = $adb->query_result($date_result,0,'closingdate');
}else{//没有未结算状态记录，日期区间取本月第一天到当前日期
    $fday = date('Y-m-01',time());
    $lday = date('Y-m-d',time());
}

$begin_createdate =  $fday;
$begin_end_date = $lday;

//后续可能会改成日期区间可修改，这里预先做处理
if(!empty($_REQUEST["begin_createdate"])){
    $begin_createdate = $_REQUEST["begin_createdate"];
}
if(!empty($_REQUEST["begin_end_date"])){
    $begin_end_date = $_REQUEST["begin_end_date"];
}

$smarty->assign("begin_createdate", $begin_createdate);
$smarty->assign("begin_end_date", $begin_end_date);

//人员范围
if(isset($_REQUEST['SmOwnerSearchScope']) && !empty($_REQUEST['SmOwnerSearchScope'])){
    $searchscope = $_REQUEST['SmOwnerSearchScope'];
}
//获取用户id拼接的字符串，放入sql语句中
if($searchscope == 'SmOwner_Search_All'){
    $userid = implode(',',array_keys($user_arr));
}else{
    $userid = $searchscope;
}

$reportfilterhtml = getTimeSheetSubCaseReport($begin_createdate,$begin_end_date,$userid,$searchscope);

$smarty->assign('REPORTFILTERHTML',$reportfilterhtml);

$smarty->assign('SmOwnerSearchScope',$searchscope);//人员范围
$smarty->display('TimeSheetSubCaseReport.tpl');


//TimeSheet提交情况统计表
function getTimeSheetSubCaseReport($start_date,$end_date,$userid,$scope){
    global $adb;
    
    //开始日期与结束日期之间天数
    $dates = DateOperation::days_between_date($start_date, $end_date) + 1;

    $query = "SELECT
                	ld_users.last_name AS lastname,
                	timesheet.workdate AS workdate
                FROM
                	ld_users 
                LEFT JOIN(
                	select distinct ld_timesheetdetail.workdate,ld_timesheet.smownerid from ld_timesheet
                	LEFT JOIN ld_timesheetdetail on ld_timesheetdetail.timesheet_id = ld_timesheet.timesheet_id
                	where ld_timesheet.deleted = 0 and
                	 (
                		ld_timesheet.approvestatus NOT IN ('已驳回', '已拒绝')
                		OR ld_timesheet.approvestatus IS NULL
                	)
                	AND ld_timesheetdetail.workdate BETWEEN ? AND ?
                    and ld_timesheet.smownerid in(".$userid.")
                ) as timesheet on timesheet.smownerid = ld_users.id
                ORDER BY
                	lastname,
                	timesheet.workdate;";
                    
    $result = $adb->pquery($query,array($start_date,$end_date));
    $num_rows = $adb->num_rows($result);
    for($i = 0; $i<$num_rows; $i++){
        $lastname = $adb->query_result($result,$i,'lastname');
        $workdate = $adb->query_result($result,$i,'workdate');
        if($scope == 'SmOwner_Search_All' || getUserFullName($userid)==$lastname ){//人员范围为全部或为所选用户
            $subCaseInfo[$lastname][] = DateOperation::days_between_date($start_date,$workdate); 
        }
    }
    
    $table = '<table class="rptTable TableOften" cellspacing="0" cellpadding="0" width="100%">';
    
    //第一行(日期)
    $table .='<tr style="background:#ADADAD;">';
    $table .='<td align="center">##</td>';
    for($i = 0; $i<$dates; $i++){
        $date = date('d/m', strtotime ("+$i day", strtotime(''.$start_date.'')));
        $table .='<td style="color:#2B2B2B">' . $date . '</td>';
    }
    $table .='</tr>';
    
    //$subCaseInfo  key:lastname  val:$workdate-$startdate
    foreach($subCaseInfo as $key=>$val){
        $table .= '<tr>';
        $table .= '<td style="color:#2B2B2B">'.$key.'</td>';
        
        for($i=0;$i<$dates;$i++){
            $weekday = DateOperation::getWeekBol(date('y-m-d', strtotime ("+$i day", strtotime(''.$start_date.''))));
            if($weekday == 6 || $weekday == 0){//判断日期是否为周末
                $weekend = true;
            }else{
                $weekend = false;
            }
            if(in_array($i,$val) && !$weekend){//工作日提交
                $table .= '<td align="center" style="font-weight:bold;color:#43CD80">√</td>';
            }else if(!in_array($i,$val) && !$weekend){//工作日未提交
                $table .= '<td align="center" style="font-weight:bold;color:#EE2C2C">×</td>';
            }else if(in_array($i,$val) && $weekend){//周末提交
                $table .= '<td align="center" style="font-weight:bold;color:#43CD80;background:#DBDBDB">√</td>';
            }else if(!in_array($i,$val && $weekend)){//周末未提交
                $table .= '<td align="center" style="font-weight:bold;color:#EE2C2C;background:#DBDBDB">×</td>';
            }
        }
        $table .= '</tr>';
    }
    
    $table .= '<table>';
    return $table;
}

exit();
?>