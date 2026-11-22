<?php
global $adb;     
global $list_max_entries_per_page_new; 
global  $currentModule ; 
$query_all='SELECT workcalender_id,workcalender_name from ld_workcalender';
$result_all=$adb->pquery($query_all);
$noofrows = $adb->num_rows($result_all);
//获取分页
if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
	$start = vtlib_purify($_REQUEST['start']);
	if($start == 'last'){
		if($noofrows > 0){
			$start = ceil($noofrows/$list_max_entries_per_page_new);
		}
	}
	if(!is_numeric($start)) $start = 1;
	elseif($start < 1) $start = 1;
	$start = ceil($start);
}else{
	$start = 1;
}
$limstart=($start-1)*$list_max_entries_per_page_new;  
$sql='SELECT workcalender_id,workcalender_name from ld_workcalender';
$sql.= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new;
$result=$adb->pquery($sql);
$num_rows = $adb->num_rows($result);
if($num_rows > 0)
{
	for($i = 0; $i<$num_rows; $i++)
	{
	   $list_entries[$i]['workcalender_id']=$adb->query_result($result,$i,'workcalender_id');
       $list_entries[$i]['workcalender_name']=$adb->query_result($result,$i,'workcalender_name');
	}
}
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);               
$navigationOutput =  getRecordRangeMessage($result, $limstart,$noofrows); 
$page_scope=getPopTableHeaderNavigation($navigation_array, $url_string, $currentModule, 'index', $viewid); 
$smarty=new lingdangCRM_Smarty;
$smarty->assign('NAVIGATTIONOUTPUT',$navigationOutput);
$smarty->assign('PAGESCOPE',$page_scope);
$smarty->assign("WORKCALINFO", $list_entries);
$smarty->assign("START", $start);
echo '&#&#&#';
$smarty->display("ShowWorkingSpace.tpl");
exit();
?>