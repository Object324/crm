<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
$tabid = $_REQUEST['tabid'];
$module = getTabname($tabid);
$focus = CRMEntity::getInstance($module);
if(!empty($_REQUEST['workflow_actionid'])){
	$query = "select action_title,query_sql from ld_workflow_actions 
	LEFT JOIN ld_workflow_excutesql on ld_workflow_excutesql.workflow_action_id = ld_workflow_actions.id 
	where ld_workflow_actions.id = ?";
	$result = $adb->pquery($query,array($_REQUEST['workflow_actionid']));
	if($adb->num_rows($result) >= 1){
		$action_title = $adb->query_result($result,0,'action_title');
		$query_sql = $adb->query_result($result,0,'query_sql');
		$smarty->assign('ACTION_TITLE',$action_title);
		$smarty->assign('QUERY_SQL',$query_sql);
	}
	$smarty->assign('workflow_actionid',$_REQUEST['workflow_actionid']);
}
$_REQUEST['diony']='yes';
$smarty->assign('TABID',$tabid);
$smarty->assign('WORDFLOW_ID',$_REQUEST['workflow_id']);
$arr['title'] = getFixedLabel('ADDITION').getFixedLabel('WorkflowActions').'  ->  '.getFixedLabel('ExcuteSQL');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForExcuteSql.tpl');
ConvertTojsonString(1,$arr,"success");
?>