<?php
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['voucherdate']) && !empty($_REQUEST['single_userid'])){
	global $adb;
	crm_load_class_file('cls_SaveVoucher','modules/Customreport');
	$voucherdate = $_REQUEST['voucherdate'];	//业务日期
	$single_userid = $_REQUEST['single_userid'];	//制单人
	$mer_type = $_REQUEST['mer_type'];	//MER
	$startdate = $_REQUEST['startdate'];	//开始日期
	$enddate = $_REQUEST['enddate'];	//结束日期
	$mode = $_REQUEST['mode'];	//操作类型 create新增 edit编辑
	$date = date('Y-m',strtotime($voucherdate));
	$cls_SaveVoucher = new cls_SaveVoucher($voucherdate,$single_userid,$mer_type,$startdate,$enddate);
	if($mode == 'create'){
		//新增
		$query = 'select 1 from ld_voucher_log where voucher_date like "%'.$date.'%" and voucher_type= ? ';
		$result = $adb->pquery($query,array($mer_type));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$smarty->assign('CONFIG',1);
			echo "ERROR&&&&&&&&&&&&//B/";
			$smarty->display("modules/Customreport/VoucherPop.tpl");
		}else{
			$cls_SaveVoucher->save($mode);
		}
	}else{
		//更新
		$cls_SaveVoucher->save($mode);
	}
}
exit();

?>