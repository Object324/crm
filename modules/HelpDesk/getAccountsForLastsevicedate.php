<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/
$focus = CRMEntity::getInstance('HelpDesk');
if(!empty($_REQUEST['record']) && !empty($_REQUEST['frommodule'])){
	$record = vtlib_purify($_REQUEST['record']);
	$frommodule = vtlib_purify($_REQUEST['frommodule']);
	if(!empty($record) && !empty($frommodule)){
		echo $focus->getAccountsForLastservicedate($record,$frommodule);
	}
}else{
	$data = array(
		'account_id' => $_REQUEST['account_id'],
		'contact_id' => $_REQUEST['contact_id'],
		'salesorder_id' => $_REQUEST['salesorder_id'],
		'servicecontractsid' => $_REQUEST['servicecontractsid'],
		'product_id' => $_REQUEST['product_id'],
		'projectid' => $_REQUEST['projectid']
	);

	foreach($data as $column => $record){
		if(!empty($record)){
			$res = $focus->getAccountsForLastservicedate($record,'');
			if($res == 'error'){
				break;
			}
		}
	}
	echo $res;
}
exit();
?>