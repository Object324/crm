<?php

global $current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    exit();
}
global $adb;
if(!empty($_REQUEST['mode']) && $_REQUEST['mode'] == 'save'){
	$query = 'select 1 from ld_workflow where id = ?';
	$result = $adb->pquery($query,array($_REQUEST['workflow_id']));
	$num_rows = $adb->num_rows($result);
	if($_REQUEST['workflow_status'] == 'on'){
		$_REQUEST['workflow_status'] = 'Active';
	}else{
		$_REQUEST['workflow_status'] = 'Inactive';
	}
//	BUG0077565 ls 20231225 日程管理的工作流程，不生效
	if($_REQUEST['tabid'] == 9) $_REQUEST['tabid']=16;


	$workflow_approvetime = !empty($_REQUEST['workflow_approvetime'])?implode(',',$_REQUEST['workflow_approvetime']):'';
	if($num_rows >= 1){
		$query = "update ld_workflow set tabid = ?,name = ?,status=?,description = ?,triggertime = ?,repeatmode = ?,approvalnode = ?,advft_criteria = ?,advft_criteria_groups = ? where id = ?";
		$adb->pquery($query,array($_REQUEST['tabid'],$_REQUEST['workflow_name'],$_REQUEST['workflow_status'],$_REQUEST['workflow_description'],$_REQUEST['workflow_triggertime'],$_REQUEST['workflow_triggertype'],$workflow_approvetime,$_REQUEST['advft_criteria'],$_REQUEST['advft_criteria_groups'],$_REQUEST['workflow_id']));
	}else{
		$query = "insert into ld_workflow(id,tabid,`name`,`status`,description,triggertime,repeatmode,approvalnode,createdtime,advft_criteria,advft_criteria_groups) values (?,?,?,?,?,?,?,?,?,?,?)";
	
		$adb->pquery($query,array($_REQUEST['workflow_id'],$_REQUEST['tabid'],$_REQUEST['workflow_name'],$_REQUEST['workflow_status'],$_REQUEST['workflow_description'],$_REQUEST['workflow_triggertime'],$_REQUEST['workflow_triggertype'],$workflow_approvetime,date('Y-m-d H:i:s'),$_REQUEST['advft_criteria'],$_REQUEST['advft_criteria_groups']));
	}
    $workflowactionid_arr=explode(",",$_REQUEST['workflowactionids']);
    $sequence=1;
    foreach($workflowactionid_arr as $workflowactionid)
    {
        $sql='update ld_workflow_actions set sequence=? where id= '.$workflowactionid;
        $adb->pquery($sql,array($sequence++));
        
    }
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,"success");


?>

