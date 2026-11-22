<?php
/* 郎捷：需求
edit:chj
date:2020-06-05
reason:
1.客服下单->运输订单->选择车型之后表体根据“车型”自动带出“合同->运输”中单据分录是对应车型的“分录信息”
	1)合同->运输中的“启运地” 到 运输订单中的“装货地点”
	2)合同->运输中的“目的地” 到 运输订单中的“送货地点”
*/
global $current_user,$currentModule,$adb,$languageType;
$data = array();
if(!empty($_REQUEST['potential_id']) && !empty($_REQUEST['selectedText'])){
	$query = "select sf5371,sf5099,sf5235 from ld_customform13 
	LEFT JOIN ld_customform13detail on ld_customform13detail.id = ld_customform13.customform13id 
	LEFT JOIN ld_customform13detailscf on ld_customform13detailscf.lineitem_id = ld_customform13detail.lineitem_id
	where potentialid = ? and sf5371 = ?";
	$result = $adb->pquery($query,array($_REQUEST['potential_id'],$_REQUEST['selectedText']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$row = 1;
		for($i = 0; $i < $num_rows; $i++){
			$qiyundi = $adb->query_result($result,$i,'sf5099');	//启运地
			$mudidi = $adb->query_result($result,$i,'sf5235');	//目的地
			$data[$row] = array(
				'qiyundi' => $qiyundi,
				'mudidi' => $mudidi
			);
			$row++;
		}
	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$data,"success");
exit();
?>