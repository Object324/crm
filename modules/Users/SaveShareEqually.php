<?php

global $adb;
$smarty=new lingdangCRM_Smarty;
$module = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($module);
$fieldname = $_REQUEST['fieldname'];
$frommodule = $_REQUEST['frommodule'];
if(!empty($fieldname) && !empty($frommodule)){
	//ษ่ึริดตฅ
	if(!empty($_REQUEST['setSourceModule']) && $_REQUEST['setSourceModule'] == 'yes'){
		$sourcemodule_infos = explode('|',$_REQUEST['info']);
		$i = 1;
		foreach($sourcemodule_infos as $infos){
			$array = explode(',',$infos);
			$query = 'update ld_shareequally set `default` = ?,presence = ?,sequence = ? where fieldname = ? and module = ? and entitytype = ?';
			$adb->pquery($query,array($array[2],$array[1],$i,$fieldname,$frommodule,$array[0]));
			$i++;
		}
		echo 'success';exit();
	}
}
?>