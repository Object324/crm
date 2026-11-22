<?php


class cls_MultiTableDetail extends cls_ParentTableDetail
{
    public function cls_MultiTableDetail($ids)
    {
        $this->ids=$ids;
        
    }
    public function getListData()
    {
		foreach($this->ids as $idinfo)
		{
			foreach($idinfo as $ids){
				if(!empty($ids['sendpayment_id'])){
					$sendpaymentid[] = $ids['sendpayment_id'];
				}else{
					$purchaseorderid[] = $ids['purchaseorder_id'];
				}	
			}
		}
		$sendpaymentids=implode(',',$sendpaymentid);
		$purchaseorderids=implode(',',$purchaseorderid);
		if(!class_exists('cls_purchaseTableDetail')){
			include(globalStatic::$root_directory. 'modules/SendCashBill/cls_purchaseTableDetail.php');
		}
		$purchase_detail_focus= new cls_purchaseTableDetail($purchaseorderids);
		$purchase_table_data=$purchase_detail_focus->getListData();
         
		if(!class_exists('cls_sendPaymentTableDetail')){
			include(globalStatic::$root_directory. 'modules/SendCashBill/cls_sendPaymentTableDetail.php');
		}
		$sendpayment_detail_focus= new cls_sendPaymentTableDetail($sendpaymentids);
		$sendpayment_table_data=$sendpayment_detail_focus->getListData();
		foreach($this->ids as $idinfo){
			 foreach($idinfo as $ids){
				if(!empty($ids['sendpayment_id'])){
					foreach($sendpayment_table_data as $info){
						if($info['sendpaymentid'] == $ids['sendpayment_id']){
							$data[] = $info;
						}
					}
				}else{
					foreach($purchase_table_data as $info){
						if($info['purchaseorderid'] == $ids['purchaseorder_id']){
							$data[] = $info;
						}
					}
				}
			 }
		}
		$this->table_data=$data;
		return $data;  
         
    }
}

?>