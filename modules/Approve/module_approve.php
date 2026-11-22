<?php 
global $adb;
$module = $_REQUEST['module'];
$type = $_REQUEST['type'];
$value = $_REQUEST['value'];
$fromodule_id = $_REQUEST['tabid'];
$fromodule = getTabname($fromodule_id);
$_REQUEST['diony']='yes';
if($type =='module_approve'){
    $sql ="update ld_systems_deploy set deploy_value = ? where setype = ?";
    $adb->pquery($sql,array($value,$fromodule));
    unsetCache('getapprovemoduleinfo');
    unsetCache('cache_startblocksapprove');
    unsetCache('systems_deploy_approve');
	unsetCache('systems_deploy');
    ConvertTojsonString(1,array(),'success');
}elseif($type =='quick_submit'){
    $submit = 'yes';
    if($value ==1) $submit = 'no';
    $sql ="update ld_tab set quicksubmit = ? where tabid = ?";
    $adb->pquery($sql,array($submit,$fromodule_id));
    unsetCache('cache_blocksquicksubmit');
    ConvertTojsonString(1,array(),'success');
}elseif($type == 'again_submit'){
    $againsubmit = 'yes';
    if($value == 1) $againsubmit = 'no';
    $sql ="update ld_tab set againsubmit = ? where tabid = ?";
    $adb->pquery($sql,array($againsubmit,$fromodule_id));
    unsetCache('cache_recordagainsubmit');
    ConvertTojsonString(1,array(),'success');
}elseif($type == 'showdisabledapprove'){
    $showdisabledapprove = 'yes';
    if($value == 1) $showdisabledapprove = 'no';
    $sql ="update ld_tab set showdisabledapprove = ? where tabid = ?";
    $adb->pquery($sql,array($showdisabledapprove,$fromodule_id));
    unsetCache('cache_showdisabledapprove');
    ConvertTojsonString(1,array(),'success');
}elseif($type == 'noapprovalshowempty'){
    $noapprovalshowempty = 'yes';
    if($value == 1) $noapprovalshowempty = 'no';
    $frommodule_name = getTabname($fromodule_id);
    setUsersettingByLabel($frommodule_name,1,'NoApprovalShowEmpty',$noapprovalshowempty);
    unsetCache('cache_showdisabledapprove');
    ConvertTojsonString(1,array(),'success');
}else{
    ConvertTojsonString(-1,array(),'success');   
}

?>