<?php
/**
* edit: chj
* reason: 删除公海池
* date: 2021/1/11
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
//删除公海池后，将该公海池中的公海客户全部转移到所选公海池的“公海未分配”页签中
//$_REQUEST['pool_id'] 需要删除的公海池
if(!empty($_REQUEST['pool_id']) && !empty($_REQUEST['selected_pool_id'])){
	$_REQUEST['diony']='diony';
	//跟着释放功能走
	$query = "select leadsid from ld_leads where pool_id = ?";
	$result = $adb->pquery($query,array($_REQUEST['pool_id']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$query="update ld_leads set protectdate=null,protectstartdate=null,allocatedate=null,publicaccount=1,completed=null where pool_id = ?";
		$adb->pquery($query,array($_REQUEST['pool_id']));
		$query = "update ld_leads set pool_id = ? where pool_id = ?";
		$adb->pquery($query,array($_REQUEST['selected_pool_id'],$_REQUEST['pool_id']));
		$focus = CRMEntity::getInstance('Leads');
		$focus->getModuleStatic('ModTracker');//字段修改日志/变更销售负责人
		for($i = 0; $i < $num_rows; $i++){
			$leadsid = $adb->query_result($result,$i,'leadsid');
			$focus->modstatic->saveFieldLogOne('Leads','pool_id',$leadsid,$_REQUEST['pool_id'],$_REQUEST['selected_pool_id']);
		}
	}
	$query = "update ld_leads_public_pool set deleted = 1 where id = ?";
	$adb->pquery($query,array($_REQUEST['pool_id']));
	unsetCache('public_leads_pool');
	ConvertTojsonString(1,array(),"success");
}
crm_load_class_file('cls_PublicLeads', 'modules/Leads');
$cls_PublicAccounts = new cls_PublicLeads('Leads');
$public_account = $cls_PublicAccounts->getPublicAccountConfig();
$account_pool = [];
$delete_pool_name = '';
if(!empty($public_account['public_account_pool'])){
	foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
		if($pool_id == $_REQUEST['pool_id']){
			$delete_pool_name = $pool_info['pool_name'];
		}else{
			$account_pool[$pool_id] = $pool_info['pool_name'];
		}
	}
}
$smarty->assign('DELETE_POOL_ID',$_REQUEST['pool_id']);	//需要删除的公海池id
$smarty->assign('DELETE_POOL_NAME',$delete_pool_name);
$smarty->assign('DATA',$account_pool);
$_REQUEST['diony']='diony';
$content=$smarty->fetch("modules/Leads/deletePublicLeadsPool.tpl");
$arr['title']=getFixedLabel("deletetheunassignedpool");
$arr['oktext']=getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");

?>