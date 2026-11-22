<?php
global $adb;
//chj 2022/8/11 维修内容产品严格参照源单，即选热线单后，自动判断是否有报损单，如无报损单或报损单无产品，则没有产品明细也可保存；如有产品，则维修内容产品及数量与报损单完全一致（选择CCF单后自动带出报损单和对应的产品），不允许变更。 产品新增图标也去掉。
if(!empty($_REQUEST['record'])){
	$query = "select GROUP_CONCAT(lineitem_id),quoteid,quote_no from ld_quotes 
	LEFT JOIN ld_quotesdetail on ld_quotes.quoteid = ld_quotesdetail.id 
	where potentialid = ? and deleted = 0";
	$result = $adb->pquery($query,array($_REQUEST['record']));
	if($adb->num_rows($result) >= 1){
		$arr['limeiten_ids'] = $adb->query_result($result,0,0);
		$arr['quoteid'] = $adb->query_result($result,0,'quoteid');
		$arr['quote_no'] = $adb->query_result($result,0,'quote_no');
	}
}
$_REQUEST['diony'] = 'yes';
ConvertTojsonString(1,$arr,"success");

?>