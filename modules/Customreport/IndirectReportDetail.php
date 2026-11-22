<?php
/**
* reason:工时Indirect项目汇总表
* eidt:Liver
* date:2016-10-08
**/

global $adb,$theme;
global $current_user;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";
$reportname='IndirectReportDetail';

$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);

$smarty->assign('REPORTNAME',$reportname);
/*
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

**/
$fday = date('Y-m-01',time());
$lday = date('Y-m-d',time());

$new_begindate = $_REQUEST['new_begindate'];
$new_enddate = $_REQUEST['new_enddate'];

if(!empty($new_begindate)){
    $begin_createdate = $new_begindate;
}else{
    $begin_createdate =  $fday;
}
if(!empty($new_enddate)){
    $begin_end_date = $new_enddate;
}else{
    $begin_end_date =  $lday;
}

//后续可能会改成日期区间可修改，这里预先做处理
if(!empty($_REQUEST["begin_createdate"])){
    $begin_createdate = $_REQUEST["begin_createdate"];
}
if(!empty($_REQUEST["begin_end_date"])){
    $begin_end_date = $_REQUEST["begin_end_date"];
}

$smarty->assign("begin_createdate", $begin_createdate);
$smarty->assign("begin_end_date", $begin_end_date);

/*//人员范围
if(isset($_REQUEST['SmOwnerSearchScope']) && !empty($_REQUEST['SmOwnerSearchScope'])){
    $searchscope = $_REQUEST['SmOwnerSearchScope'];
}
//获取用户id拼接的字符串，放入sql语句中
if($searchscope == 'SmOwner_Search_All'){
    $userid = implode(',',array_keys($user_arr));
}else{
    $userid = $searchscope;
}**/
crm_load_class_file('cls_Report_Sql','modules/Customreport');
$query = cls_Report_Sql::getInDirectReportDetail();
$result=$adb->pquery($query,array($begin_createdate,$begin_end_date,$begin_createdate,$begin_end_date));
$num_rows=$adb->num_rows($result);
$baobiao=array();
for($i = 0; $i<$num_rows; $i++){
	$baobiao[$i]['expensedetailid'] = $adb->query_result($result,$i,'expensedetailid');
	$baobiao[$i]['last_name'] = $adb->query_result($result,$i,'last_name');
	$baobiao[$i]['Startdate'] = $adb->query_result($result,$i,'startdate');
	$baobiao[$i]['indirect'] = $adb->query_result($result,$i,'indirect');
	$baobiao[$i]['expensetype'] = $adb->query_result($result,$i,'expensetype');
	$baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
	$baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
	$baobiao[$i]['usercategory'] = $adb->query_result($result,$i,'usercategory');
	$baobiao[$i]['subjectcode2'] = $adb->query_result($result,$i,'subjectcode2');
	$baobiao[$i]['subjectsummary2'] = $adb->query_result($result,$i,'subjectsummary2');
	$baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
}
$smarty->assign('REPORTFILTERHTML',$baobiao);


$smarty->assign("TOGGLE_MODINFO",$baobiao);
//$smarty->assign('SmOwnerSearchScope',$searchscope);//人员范围
$smarty->display('IndirectReportDetail.tpl');
exit();
?>