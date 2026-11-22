<?php


class cls_purchaseTableDetail extends cls_ParentTableDetail
{
    public function cls_purchaseTableDetail($ids)
    {
        $this->ids=$ids;
        if(!$this->focus)
       {
        $this->focus=CRMEntity::getInstance('SendCashBill');
       }
    }
   
    public function getListData()
    {
       
        global $adb;
        $data=array();
        $ids=$this->ids;
      
        if(empty($this->ids))
        {
            return array();
        }
        $ids=explode(',',$ids);
        $ids= array_unique($ids);
        $ids=array_filter($ids);
       $ids=implode(",",$ids);
     
       $system_where=$this->focus->get_SendPaymentCheckoutstatusWhere();
	   $actualamount_column = 'sum(
            		 case when ld_sendcashbill.currency_id<>ld_purchaseorder.currency_id
            							then ifnull(
            					ld_sendcashbill2payment.amount,
            					0
            				)/ld_sendcashbill.conversion_rate*ld_purchaseorder.conversion_rate
            		else 
            		ifnull(
            					ld_sendcashbill2payment.amount,
            					0) end 
            				
            	) AS actualamount';
		if(!empty($system_where)){
			$actualamount_column = " sum(if( ld_sendcashbill.checkoutstatus = '已审核',ifnull(ld_sendcashbill2payment.amount,0),0)) AS actualamount";
		}
        $sql="select ld_purchaseorder.total,ld_purchaseorder.currency_id,ld_purchaseorder.currency_symbol,ld_purchaseorder.conversion_rate,purchaseorderid,purchaseorder_no,
                  ld_sendcashbill.currency_id as sendcashbill_currency_id,$actualamount_column,totalsum,
                  ld_sendcashbill.conversion_rate as sendcasbhill_conversion_rate,invoice.purchaseinvoicenum,invoice.purchaseinvoicedate
                 from ld_purchaseorder left join ld_sendcashbill2payment  on ld_sendcashbill2payment.purchaseorder_id=ld_purchaseorder.purchaseorderid
                     left join ld_sendcashbill on ld_sendcashbill.sendcashbillid= ld_sendcashbill2payment.sendcashbillid $system_where 
                    $this->invoice_sql
                    where ld_purchaseorder.purchaseorderid in($ids)  group by ld_purchaseorder.purchaseorderid";
       
      $explode_id=explode(",",$this->ids);
      $result=$adb->pquery($sql,array());
      $rmb_currencyobj=new Currency($adb,1);
      foreach($explode_id as $purchaseorderid)
      {
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                if($adb->query_result($result,$i,'purchaseorderid')==$purchaseorderid)
                {
                    break;
                }
            }
          
            $total=$adb->query_result($result,$i,'total');
            $purchase_href=$adb->query_result($result,$i,'purchaseorder_no');
            $currency_id=$adb->query_result($result,$i,'currency_id');//采购订单币种
            $conversion_rate=$adb->query_result($result,$i,'conversion_rate');//采购订单币种汇率
            $currency_symbol=$adb->query_result($result,$i,'currency_symbol');
            $sendcashbill_currency_id=$adb->query_result($result,$i,'sendcashbill_currency_id');
            $sendcashbill_conversion_rate=$adb->query_result($result,$i,'sendcashbill_conversion_rate');
            $amount=$adb->query_result($result,$i,'actualamount');//已付金额
            $totalsum=$adb->query_result($result,$i,'totalsum');//开票金额
            $invoice_num=$adb->query_result($result,$i,'purchaseinvoicenum');
            $invoice_date=$adb->query_result($result,$i,'purchaseinvoicedate');
            $purchase_amount=$amount;
          
            if($currency_id!=1)
            {
				$purchase_currencyobj=new Currency($adb,$currency_id);
                $totalsum=$purchase_currencyobj->ConvertTothisobj_money($rmb_currencyobj,$totalsum);//开票金额
            }
            $data[]=array('purchaseorderid'=>$purchaseorderid,'purchase_total'=>$total,
                        'purchase_href'=>$purchase_href,'purchase_currency_id'=>$currency_id,
                        'purchase_conversion_rate'=>$conversion_rate,'purchase_currency_symbol'=>$currency_symbol,
                        'invoce_amount'=>$totalsum,'actualamount'=>$purchase_amount,'amount'=>'',
                        'invoice_num'=>$invoice_num,'invoice_date'=>$invoice_date,
                        'sendpaymentid'=>0, 'sendpayment_currency_id'=>'','sendpayment_plandate'=>'',
                        'sendpayment_periodtime'=>'','sendpayment_no'=>'','cur_amount'=>$total-$purchase_amount);
           
      }
      $this->table_data=$data;
      return $data;  
    }
      /**
     * 根据业务规则选择采购订单不需要考虑获取数据库已经付款的单据
     * */
    private function getData_inDataBase()
    {
        
    }
}

?>