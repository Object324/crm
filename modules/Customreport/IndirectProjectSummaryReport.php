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

$reportname='IndirectProjectSummaryReport';
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);
$subjectcode = '5142.02';
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
//开始日期、结束日期
$fday = date('Y-m-01',time());
$lday = date('Y-m-d',time());

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
$smarty->assign('SUBJECTCODE',$subjectcode);

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

$reportfilterhtml = getIndriectReport($begin_createdate,$begin_end_date);

$smarty->assign('REPORTFILTERHTML',$reportfilterhtml);
$smarty->assign('REPORTNAME',$reportname);
//$smarty->assign('SmOwnerSearchScope',$searchscope);//人员范围
$smarty->display('IndirectProjectSummaryReport.tpl');


function getIndriectReport($start_date,$end_date){
    global $adb;
    
	crm_load_class_file('cls_Report_Sql','modules/Customreport');
	$query = cls_Report_Sql::getInDriectProjectSummaryReport();
    $result = $adb->pquery($query,array($start_date,$end_date,$start_date,$end_date));
    //echo $start_date;
    $num_rows = $adb->num_rows($result);
    $baobiao=array(); // 报表数据
    for($i = 0; $i<$num_rows; $i++){
        $baobiao[$i]['expensetype'] = $adb->query_result($result,$i,'expensetype');
        $baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
        $baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
        $baobiao[$i]['usercategory'] = $adb->query_result($result,$i,'usercategory');
        $baobiao[$i]['subjectcode2'] = $adb->query_result($result,$i,'subjectcode2');
        $baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
    }

    $table = '<table class="rptTable TableOften" cellspacing="0" cellpadding="0" width="80%" id="ProjectSummaryReportList" name="ProjectSummaryReportList">';
    $table .="<div align=\"right\" style=\"width:80%\"><input id=\"BasicSearchreput\" class=\"createauto b_radius3\" onclick=\"generateVoucher(this,'".$start_date."','".$end_date."')\" name=\"button\" value=\"生成金蝶凭证\" type=\"button\">　 <input id=\"seldetail\" class=\"createauto b_radius3\" onclick=\"window.open('index.php?module=Customreport&action=IndirectReportDetail&new_begindate=".$start_date."&new_enddate=".$end_date."');\" name=\"seldetail\" value=\"查看明细及修改会计科目\" type=\"button\">"."</div>";
    
    $table .='<tr style="background:#99CCFF;">';
    $table .='<td align="center"><b>Business Reason</b></td>';
    $table .='<td align="center"><b>对应科目代码</b></td>';
    $table .='<td align="center"><b>对应科目摘要</b></td>';
    $table .='<td align="center"><b>人员类别</b></td>';
    $table .='<td align="center"><b>科目二级明细</b></td>';
    $table .='<td align="center" style="background:#CC99FF;"><b>Total (in RMB)</b></td>';
    $table .='</tr>';
    
    //$subCaseInfo  key:lastname  val:$workdate-$startdate
        foreach($baobiao as $key =>$values){
            $table .= '<tr>';
            if($key % 2 != 0){
                $table .= '<td align="center" style="background:#F8F8F8">'.$baobiao[$key]['expensetype'].'</td>';
                $table .= '<td align="center" style="background:#F8F8F8">'.$baobiao[$key]['subjectcode'].'</td>';
                $table .= '<td align="center" style="background:#F8F8F8">'.$baobiao[$key]['subjectsummary'].'</td>';
                $table .= '<td align="center" style="background:#F8F8F8">'.$baobiao[$key]['usercategory'].'</td>';
                $table .= '<td align="center" style="background:#F8F8F8">'.$baobiao[$key]['subjectcode2'].'</td>';
                $table .= '<td align="center" style="background:#F8F8F8">'.$baobiao[$key]['rmb_tota'].'</td>';
            }else{
                $table .= '<td align="center" >'.$baobiao[$key]['expensetype'].'</td>';
                $table .= '<td align="center" >'.$baobiao[$key]['subjectcode'].'</td>';
                $table .= '<td align="center" >'.$baobiao[$key]['subjectsummary'].'</td>';
                $table .= '<td align="center" >'.$baobiao[$key]['usercategory'].'</td>';
                $table .= '<td align="center" >'.$baobiao[$key]['subjectcode2'].'</td>';
                $table .= '<td align="center" >'.$baobiao[$key]['rmb_tota'].'</td>';
            }
        }
        $table .= '</tr>';
    $table .= '<table>';
    return $table;
}

exit();
?>