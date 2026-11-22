<?php
/**
 * 采购订单关联创建入库单   合同订单关联创建出库单
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
if(isset($_REQUEST['recordid'])){
	if(isset($_REQUEST['type'])){
		//出库、入库严格参照原单：0是 1否
		$deployarray=getSys_deploy(10);
		if($deployarray['deploy_value']== 1){
			echo "###success###";exit();
		}else{
			if($_REQUEST['type'] == 1){
				$query = 'select stockpresence,balancepurchasecount as num from ld_purchaseorderdetail
					LEFT JOIN ld_purchaseorder on ld_purchaseorder.purchaseorderid = ld_purchaseorderdetail.id
					where ld_purchaseorder.purchaseorderid = ?';
			}else{
				$query = 'select stockpresence,balanceoutproductcount as num from ld_salesorderdetail
					LEFT JOIN ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id
					where ld_salesorder.salesorderid = ?';
			}
			$result = $adb->pquery($query,array($_REQUEST['recordid']));
			$num_rows = $adb->num_rows($result);
			$balance_num = 0;//可出、入库的数量
			for($i = 0; $i<$num_rows; $i++){
				$stockpresence = $adb->query_result($result,$i,'stockpresence');	//出入库状态
				$num = $adb->query_result($result,$i,'num');
				$balance_num += $num;
			}
			if($balance_num < 0){
				echo "###error###";exit();
			}
		}
	}
}
?>