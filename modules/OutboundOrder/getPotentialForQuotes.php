<?php
	global $adb;
	$data = array();
	if(!empty($_REQUEST['record'])){
		$query = 'select lineitem_id from ld_quotes
		LEFT JOIN ld_quotesdetail on ld_quotesdetail.id = ld_quotes.quoteid 
		where potentialid = ? and deleted <> 1';
		$result = $adb->pquery($query,array($_REQUEST['record']));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i< $num_rows; $i++){
				$data[] = $adb->query_result($result,$i,'lineitem_id');
			}
		}
	}
	echo implode(',',$data);exit();
?>