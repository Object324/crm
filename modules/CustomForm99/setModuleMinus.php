<?php
/**
* edit: chj
* reason: 东贸特殊控制：适用范围
* date: 2021/9/22
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new,$currentModule;
$smarty=new lingdangCRM_Smarty();
$minus_json = $_REQUEST['minus_json'];
if(!empty($_REQUEST['record'])){
	$query = 'update ld_customform99 set minus_scope = ? where customform99id = ?';
	$adb->pquery($query,array($_REQUEST['minus_json'],$_REQUEST['record']));
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
$minus_data = [];
if(!empty($minus_json)){
	$minus = ldcrm_json_decode($minus_json);
	foreach($minus as $key => $res){
		$exps = explode(',',$res);
		$minus_data[$key] = array('man'=>$exps[0],'jian'=>$exps[1]);
	}
}
$smarty->assign('MINUSDATA',$minus_data);
$smarty->assign('MINUSNUM',sizeOf($minus_data));
$smarty->assign('FIELDNAME',$_REQUEST['fieldname']);
$_REQUEST['diony']='diony';
$content=$smarty->fetch("ModuleMinus.tpl");
$arr['title']=getFixedLabel("LBL_ACCOUNT_SET");
$arr['oktext']=getFixedLabel("CONFIRMED");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");
?>