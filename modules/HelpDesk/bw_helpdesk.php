<?php

	crm_load_class_file('cls_bw_helpdesk','modules/HelpDesk');
	$cls_bw_helpdesk = new cls_bw_helpdesk();
	if(!empty($_REQUEST['is_sync'])){
		$is_sync =  $cls_bw_helpdesk->is_sync_helpdesk();
		echo $is_sync;
	}else{
		$sync_bw_helpdesk = $cls_bw_helpdesk->sync_helpdesk();
		echo $sync_bw_helpdesk;
	}
	exit();
?>