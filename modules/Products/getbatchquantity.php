<?php
global $adb; 
if(!empty($_REQUEST['productbatchquantity_string'])){
	$batch_product_arr = array();
	$batch_info = array();
	$error_info = array();
	$productbatchquantity_array = explode('||@@||',$_REQUEST['productbatchquantity_string']);
	foreach($productbatchquantity_array as $batchproduct){
		if(!empty($batchproduct)){
			$arr = explode('||%%||',$batchproduct);
			$rowid = $arr[0];
			$warehouseid = $arr[1];
			$productid = $arr[2];
			$batch_no = $arr[3];
			$quantity = $arr[4];
			if(empty($batch_product_arr[$warehouseid][$productid][$batch_no])){
				$batch_product_arr[$productid][$warehouseid][$batch_no]['quantity'] = $quantity;
			}else{
				$batch_product_arr[$productid][$warehouseid][$batch_no]['quantity'] += $quantity;
			}
			$batch_product_arr[$productid][$warehouseid][$batch_no]['rowid'] = $rowid;
			$batch_info[$warehouseid]['productid'][] = $productid;
			$batch_info[$warehouseid]['batch_no'][] = $batch_no;
		}
	}
	if(!empty($batch_info)){
		crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
		foreach($batch_info as $warehouseid => $arr){
			$productid = implode(',',$arr['productid']);
			$batchtexts = implode('##',$arr['batch_no']);
			$tmpproductqtys[$warehouseid] = getProductQtySaveOrCheck($productid,$warehouseid,$batchtexts);
		}
	}
	$deploy_values=getSys_deploy("48");

	if($deploy_values['deploy_value']==0)
	{
		//出库单或入库单更新库存流水记录触发点 0：审核  1：保存
	}
	else
	{
	   $fromfocus=CRMEntity::getInstance($_REQUEST['frommodule']);
       
		$deployarray=getSys_deploy(49);
		$lengthdecimaldigits=$deployarray['deploy_value'];
		foreach($batch_info as $warehouseid => $arr){
			$productid = implode(',',$arr['productid']);
			$batchtexts = '"'.implode('","',$arr['batch_no']). '"';
            $detailtable=$fromfocus->Detail_table;
			$sql=" select quantity,batchtext,productid from $detailtable where id=? and productid in( ".$productid.') and batchtext in ('.$batchtexts.')';
			$result=$adb->pquery($sql,array($_REQUEST['id']));
			$rows=$adb->num_rows($result);
			for($i=0;$i<$rows;$i++)
			{
				$productid=$adb->query_result($result,$i,'productid');
				$batchtext=$adb->query_result($result,$i,'batchtext');
				$quantity=$adb->query_result($result,$i,'quantity');

				$quantity=number_format($quantity,$lengthdecimaldigits,".","");
				$tmpproductqtys[$warehouseid][$productid][$warehouseid][$batchtext] += $quantity;
			}
		}
	}
   
	if(!empty($tmpproductqtys)){
		foreach($tmpproductqtys as $warehouseid => $batch_pro_quantity){
			foreach($batch_pro_quantity as $productid => $batch_quantity){
				foreach($batch_quantity[$warehouseid] as $barch_no => $quantity){
					if($quantity < $batch_product_arr[$productid][$warehouseid][$barch_no]['quantity']){
						$productname = $batch_pro_quantity[$productid.'_name'];
						$ware_info = getWarehouseInfo($warehouseid);
						$rowid = $batch_product_arr[$productid][$warehouseid][$barch_no]['rowid'];
						if($_REQUEST['frommodule'] == 'OutboundOrder'){
							$error_info[$rowid] = str_replace('{rowid}',$rowid,getFixedLabel('elementrow')).$productname.'('.getFixedLabel('BATCH').':'.$barch_no.')' . str_replace('{warename}','['.$ware_info['name'].']',getFixedLabel('QUANTITYMORTHANCURRENTROWBATCH1'));
						}else{
							$error_info[] = str_replace('{rowid}',$rowid,getFixedLabel('elementrow')).str_replace('{productname}',$productname.'('.getFixedLabel('BATCH').':'.$barch_no.')',getFixedLabel('QUANTITYMORTHANCURRENTROWBATCH'));
						}
						//
						
					}
				}
			}
		}
	}
}
ksort($error_info);
$str = implode('<br />',$error_info);
echo $str;
die;
?>