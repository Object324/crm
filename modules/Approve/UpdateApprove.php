<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
global $adb,$current_user;
$smarty=new lingdangCRM_Smarty;
if(isset($_REQUEST['save']) && $_RE)
if(isset($_REQUEST['fld_module']) && !empty($_REQUEST['fld_module'])){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 11:25
	crm_load_class_file("cls_PickList", 'modules/PickList');
	$objpinklist = new cls_PickList();
    $approvestatus = $objpinklist->getPickListValues('approvestatus','',array(),'id');

	/*$query = 'select id,approvestatus from ld_approvestatus order by id asc';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	for($i=0; $i<$num_rows; $i++){
		$approveid = $adb->query_result($result,$i,'id');
		$approvestatus[$approveid] = $adb->query_result($result,$i,'approvestatus');
	}*/
	$smarty->assign('APPROVESTATUS',$approvestatus);
}
//$smarty->assign('',);
echo '###SUCCESS###';
$smarty->display('Approve/UpdateApprove.tpl');
exit();
?>