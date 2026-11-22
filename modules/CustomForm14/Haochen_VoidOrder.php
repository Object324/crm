<?php
global $adb,$current_language,$app_strings,$current_user;
if(!empty($_REQUEST['record']) && !empty($_REQUEST['frommodule'])){
	if($_REQUEST['frommodule'] == 'CustomForm14'){
		$query = "update ld_customform14scf set hetong_zhuangtai = '作废',zuofeiren = ? where customform14id = ?";
		$adb->pquery($query,array($current_user->id,$_REQUEST['record']));
		$query = "update ld_quotescf 
		INNER JOIN ld_quotes on ld_quotes.quoteid = ld_quotescf.quoteid set cf_2796 = '作废',zuofeiren=? where ld_quotes.source_list = ?";
		$adb->pquery($query,array($current_user->id,$_REQUEST['record']));
		$query = "update ld_customform16scf 
		LEFT JOIN ld_customform16 on ld_customform16.customform16id = ld_customform16scf.customform16id 
		set hetong_zhuangtai = '作废' where quote_id in (select quoteid from ld_quotes where source_list = ?)";
		$adb->pquery($query,array($_REQUEST['record']));
	}else if($_REQUEST['frommodule'] == 'Quotes'){
		$query = "update ld_quotescf set cf_2796 = '作废',zuofeiren=? where quoteid = ?";
		$adb->pquery($query,array($current_user->id,$_REQUEST['record']));
		$query = "update ld_customform14scf 
		INNER JOIN ld_quotes on ld_quotes.source_list = ld_customform14scf.customform14id 
		set hetong_zhuangtai = '作废',zuofeiren=? where ld_quotes.quoteid = ?";
		$adb->pquery($query,array($current_user->id,$_REQUEST['record']));
		$query = "update ld_customform16scf 
		LEFT JOIN ld_customform16 on ld_customform16.customform16id = ld_customform16scf.customform16id 
		set hetong_zhuangtai = '作废' where quote_id = ?";
		$adb->pquery($query,array($_REQUEST['record']));
	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>