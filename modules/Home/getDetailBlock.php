<?php
global $currentModule;
$modulename = $_REQUEST['modulename'];
$record = $_REQUEST['recordid'];
$currentModule = $modulename;
$tabid = getTabid($currentModule);
$setype = $_REQUEST['setype'];
switch($setype){
    case 'ModComments':
        $customlink_params = Array('MODULE'=>$currentModule, 'RECORD'=>$record, 'ACTION'=>'DetailView');
		$custom_links = lingdang_Link::getAllByType($tabid, Array('DETAILVIEWBASIC','DETAILVIEW','DETAILVIEWWIDGET'), $customlink_params);
		$smarty = new lingdangCRM_Smarty;
		$smarty->assign('CUSTOM_LINKS',$custom_links);
		$smarty->assign('ID',$record);
        setGLobalURLSmarty($smarty);//设置js,css等访问路径
		$smarty->display("modules/ModComments/modCommentList.tpl");exit();
        break;
    case 'Recordsofoperation':
        $focus = CRMEntity::getInstance('Accounts');
		$publicaccount_log = $focus->getPublicAccountLog($record);
		echo $publicaccount_log;exit();
        break;
	case 'Approvelog':
		
	    $approve = new Approve();
		$approveinfo = $approve->approveStatus($record);
		$approvelog = $approve->approveLog($approveinfo['approveid'],$record);
		if(!empty($approvelog)){
			$smarty = new lingdangCRM_Smarty;
            setGLobalURLSmarty($smarty);//设置js,css等访问路径
			$smarty->assign('APPROVE',$approvelog);
			$smarty->display("Approve/ApproveLogEntries.tpl");exit();
		}else{
			echo '';exit();
		}
	    break;
}
exit();
?>