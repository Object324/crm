<?php
global $adb,$current_user;
//东贸特殊开发
if(!empty($_REQUEST['record']) && !empty($_REQUEST['peoples'])){
	$record = $_REQUEST['record'];
	$query = "select ifnull(cf_4652,0) from ld_customform21scf where customform21id = ?";
	$result = $adb->pquery($query,array($record));
	$db_peoples = $adb->query_result($result,0,0);
	if($db_peoples != $_REQUEST['peoples']){
		$query = "update ld_customform21scf set cf_4652 = ? where customform21id =?";
		$adb->pquery($query,array($_REQUEST['peoples'],$record));
		$time = date('Y-m-d H:i:s',time());$status = 0;
		$id = $adb->getUniqueID('ld_modtracker_basic');
		$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
							values(?,?,?,?,?,?);';
        $adb->pquery($query,array($id,$record,$_REQUEST['module'],$current_user->id,$time,$status));
		$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
		$adb->pquery($query,array($id,'cf_4652',$db_peoples,$_REQUEST['peoples']));
	}
	//实际到达人数修改后默认提交审批
	$fld_module = $_REQUEST['module'];
	$focus = CRMEntity::getInstance($fld_module);
	$approve = new Approve();
	$notapprove = array(constant('D_A_S_REJECTED') => 1,constant('D_A_S_APPROVALOF') => 1,constant('D_A_S_APPROVED') => 1);
	$sql = 'select approvestatus from ' . $focus->table_name . ' where ' . $focus->table_index . '=?';
	$result = $adb->pquery($sql, array($record));
	$approvestatus = $adb->query_result($result, 0, 'approvestatus');
	$issubmit = 'yes';
	if (array_key_exists($approvestatus, $notapprove))
		$issubmit = 'no';
	$lastapproveinfo = $approve->getlastapproveinfo($record, $fld_module);
	if ($lastapproveinfo['stepid'] == -1 && $lastapproveinfo['approveresult'] == 1) {
		$issubmit = 'no';
	}
	if ($lastapproveinfo['approveresult'] == 2) {
		//已经审批成功
		$issubmit = 'no';
	}
	//查看界面提交保存
	if ($issubmit == 'yes') {
		$tabid = getTabid($fld_module);
		$approveinfo = $approve->submitApprove($tabid);
		$nextStepInfo_arr = $approve->getApproveStepInfo($approveinfo[0]['approveid'], $record);
		if(empty($nextStepInfo_arr[0]['augmentsinger']))$nextStepInfo_arr[0]['augmentsinger'] = 'no';
		$_REQUEST['approvevalue'] = $approveinfo[0]['approveid'];
		$_REQUEST['idstring'] = $record;
		$_REQUEST['fld_module'] = $fld_module;
		$_REQUEST['concurrentidStepCount'] = 1;
		$_REQUEST['cmb_span_optiontext_approvevalue'] = $approveinfo[0]['approvename'];
		$_REQUEST['nextstepname_0'] = $nextStepInfo_arr[0]['nextstepname'];
		$_REQUEST['nextstep_0'] = $nextStepInfo_arr[0]['stepid'];
		$_REQUEST['stepseq_0'] = 0;
		$_REQUEST['nextstep_countersigner_0'] = $nextStepInfo_arr[0]['countersigner'];
		$_REQUEST['nextstep_augmentsinger_0'] = $nextStepInfo_arr[0]['augmentsinger'];
		$_REQUEST['userid_0'] = $nextStepInfo_arr[0]['stepuserids'];
		$approveid = $_REQUEST['approvevalue'];
		$approve->ApproveSubmit($fld_module, $record, $approveid);
	}
	ConvertTojsonString(1, array(), 'success');
}
?>