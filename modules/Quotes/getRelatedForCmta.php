<?php
global $current_user,$currentModule,$theme,$singlepane_view;
$_REQUEST['diony'] = 'yes';
if(!empty($_REQUEST['fromid'])){
	$query = 'select 1 from ld_customform45 where quoteid = ? and deleted = 0';
	$result = $adb->pquery($query,array($_REQUEST['fromid']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		ConvertTojsonString(-1,array(),'success');
	}else{
		ConvertTojsonString(1,array(),'success');
	}
}
ConvertTojsonString(-1,array(),'success');
?>