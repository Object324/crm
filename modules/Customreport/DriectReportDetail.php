<?php
/**
* reason:工时Direct项目汇总表
* eidt:Liver
* date:2016-10-08
**/

global $adb,$theme;
global $current_user;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";
$reportname='DriectReportDetail';

$smarty->assign('REPORTNAME',$reportname);
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);
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

$reportfilterhtml = getDirectReportDetail($begin_createdate,$begin_end_date);

$smarty->assign('REPORTFILTERHTML',$reportfilterhtml);

$smarty->assign('SmOwnerSearchScope',$searchscope);//人员范围
$smarty->display('DriectReportDetail.tpl');


//TimeSheet提交情况统计表
function getDirectReportDetail($start_date,$end_date){
    global $adb;

    crm_load_class_file('cls_Report_Sql','modules/Customreport');
	$query = cls_Report_Sql::getDirectReportDetail();

    $result = $adb->pquery($query,array($start_date,$end_date));
    $num_rows = $adb->num_rows($result);
    $baobiao=array(); // 报表数据
    for($i = 0; $i<$num_rows; $i++){
        
        $baobiao[$i]['last_name'] = $adb->query_result($result,$i,'last_name');
        $baobiao[$i]['Startdate'] = $adb->query_result($result,$i,'startdate');
        $baobiao[$i]['po_no'] = $adb->query_result($result,$i,'po_no');
        $baobiao[$i]['expensetype'] = $adb->query_result($result,$i,'expensetype');
        $baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
        $baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
        $baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
		$baobiao[$i]['expenseid'] = $adb->query_result($result,$i,'expensedetailid');
    }
   
    $table = '<table class="ControlTable1 listEntries fir-center" cellspacing="1" cellpadding="0" width="100%">';
    
    //第一行(日期)
    $table .='<tr style="background:#99CCFF;">';
    $table .='<td align="center" style="width:80px;"><b>Name</b></td>';
    $table .='<td align="center"><b>Date</b></td>';
    $table .='<td align="center"><b>PO#</b></td>';
    $table .='<td align="center"><b>Business Reason</b></td>';
    $table .='<td align="center" style="width:120px;"><b>对应会计科目</b></td>';
    $table .='<td align="center" style="width:120px;"><b>对应科目摘要</b></td>';
    $table .='<td align="center" style="background:#CC99FF;"><b>Total (in RMB)</b></td>';
	$table .='<td align="center" style="background:#CC99FF;width:120px;"><b>Action</b></td>';
    $table .='</tr>';
    //$subCaseInfo  key:lastname  val:$workdate-$startdate
        foreach($baobiao as $key =>$values){
            $table .= '<tr id="setting_0" class="lvtColData" onmouseout="listOnMouseOut(ld(this),\'on\');" onmouseover="listOnMouseOver(ld(this));">';
            if($key % 2 != 0){
				$style = 'style="background:#F8F8F8"';
            }else{
				$style = '';
            }
			$row = $key + 1;
			$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['last_name'].'</td>';
			$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['Startdate'].'</td>';
			$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['po_no'].'</td>';
			$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['expensetype'].'</td>';
			$table .= '<td align="center" '.$style.'>'."<span id='span_subjectcode_".$row."' class='modulecontrollspan' tag='".$baobiao[$key]['expenseid']."' title='".$baobiao[$key]['subjectcode']."'>".$baobiao[$key]['subjectcode']."</span>
			<div id='div_subjectcode_".$row."' style='display:none;' class='modulecontrolldiv'>
	            <input id='subjectcode_".$row."' class='detailedViewTextBox' style='width:100px;display:inline-block;' type='text' value='".$baobiao[$key]['subjectcode']."' maxlength='100' name='modulename' onblur=\"this.className='detailedViewTextBox'\" onfocus=\"this.className=\'commonDetailedTextBox gwidth70 bgcolordh'\">
            </div></td>";
			//$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['subjectcode'].'</td>';
			//$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['subjectsummary'].'</td>';

			$table .= '<td align="center" '.$style.'>'."<span id='span_subjectsummary_".$row."' class='modulecontrollspan' tag='".$baobiao[$key]['expenseid']."' title='".$baobiao[$key]['subjectsummary']."'>".$baobiao[$key]['subjectsummary']."</span>
			<div id='div_subjectsummary_".$row."' style='display:none;' class='modulecontrolldiv'>
	            <input id='subjectsummary_".$row."' class='detailedViewTextBox' style='width:100px;display:inline-block;' type='text' value='".$baobiao[$key]['subjectsummary']."' maxlength='100' name='modulename' onblur=\"this.className='detailedViewTextBox'\" onfocus=\"this.className=\'commonDetailedTextBox gwidth70 bgcolordh'\">
            </div></td>";
			$table .= '<td align="center" '.$style.'>'.$baobiao[$key]['rmb_tota'].'</td>';
			$table .="<td align='center'><div id='btn_edit_".$row."' style='display:;'><a  class='Anu3_a' href='javascript:void(0);' onclick=\"vtlib_direct_showeditinput(event,".$row.");\" >".getFixedLabel('EDIT')."</a></div>
            <div id='btn_save_".$row."' style='display:none;'>
                <a class='Anu3_a' href='javascript:void(0);' onclick=\"vtlib_direct_savemodulename(".$row.")\">".getFixedLabel('SAVE')."</a>
                <a class='Anu3_a' href='javascript:void(0);' onclick=\"vtlib_direct_cancelmodulename(".$row.")\" >".getFixedLabel('CANCEL')."</a>
            </div></td>";
        }
        $table .= '</tr>';
    $table .= '<table>';
    return $table;
}

exit();
?>