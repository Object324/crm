<?php

class cls_sendPaymentTableDetail extends cls_ParentTableDetail
{
    public function cls_sendPaymentTableDetail($ids)
    {
        if(!$this->focus)
       {
        $this->focus=CRMEntity::getInstance('SendCashBill');
       }
        $this->ids=$ids;
    }
    
     public function getListData()
    {
      
        if(empty($this->ids))
        {
            return array();
        }
        global $adb;
        $data=array();
        $ids=$this->ids;
        $ids=explode(',',$ids);
       $ids= array_unique($ids);
       $ids=array_filter($ids);
       $ids=implode(",",$ids);
      
       
        $sql="select ld_purchaseorder.purchaseorderid,ld_purchaseorder.total,ld_purchaseorder.purchaseorder_no,
                    ld_purchaseorder.currency_id as purchase_currency_id,ld_purchaseorder.currency_symbol as purchase_currency_symbol,
                    ld_purchaseorder.conversion_rate as purchase_conversion_rate,ld_sendpayment.sendpaymentid,
                    ld_sendpayment.currency_id,ld_sendpayment.currency_symbol,ld_sendpayment.conversion_rate,
                    ld_sendpayment.plandate,ld_sendpayment.cpperiodtime,ld_sendpayment.amount,ifnull(ld_sendpayment.actualamount,0) as actualamount,
                    ld_sendpayment.sendpayment_no,totalsum,purchaseinvoicenum,purchaseinvoicedate
                    from ld_sendpayment  inner join  ld_purchaseorder on ld_purchaseorder.purchaseorderid=ld_sendpayment.purchaseorder_id
                 $this->invoice_sql where ld_sendpayment.sendpaymentid in($ids)    order by ld_sendpayment.cpperiodtime asc ";

      $explode_id=explode(",",$ids);
      $result=$adb->pquery($sql,array());
      foreach($explode_id as $sendpayment_id)
      {
           
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                if($adb->query_result($result,$i,'sendpaymentid')==$sendpayment_id)
                {
                    break;
                }
            }
            $purchaseorderid=$adb->query_result($result,$i,'purchaseorderid');
            $total=$adb->query_result($result,$i,'total');
            $purchase_href=$adb->query_result($result,$i,'purchaseorder_no');
            $currency_id=$adb->query_result($result,$i,'currency_id');//付款计划币种
            $conversion_rate=$adb->query_result($result,$i,'conversion_rate');//付款计划币种汇率
            $currency_symbol=$adb->query_result($result,$i,'currency_symbol');//
            $purchase_currency_id=$adb->query_result($result,$i,'purchase_currency_id');//采购订单币种id
            $purchase_conversion_rate=$adb->query_result($result,$i,'purchase_conversin_rate');//采购订单币种汇率
            $purchase_currency_symbol=$adb->query_result($result,$i,'purchase_currency_symbol');//
            $totalsum=$adb->query_result($result,$i,'totalsum');//开票总额
            if($purchase_currency_id!=1)
            {
                $totalsum=$totalsum*$purchase_conversion_rate;
            }
            $invoice_num=$adb->query_result($result,$i,'purchaseinvoicenum');//发票号码
            $invoice_date=$adb->query_result($result,$i,'purchaseinvoicedate');//最新开票日期
            
            $sendpaymentid=$adb->query_result($result,$i,'sendpaymentid');
            $sendpayment_no=$adb->query_result($result,$i,'sendpayment_no');//
            $sendpayment_plandate=$adb->query_result($result,$i,'plandate');
            $sendpayment_periodtime=$adb->query_result($result,$i,'cpperiodtime');
            $amount=$adb->query_result($result,$i,'amount');//金额
            $actualammount=$adb->query_result($result,$i,'actualamount');//实际收款金额
            $data[]=array('purchaseorderid'=>$purchaseorderid,'purchase_total'=>$total,'purchase_currency_symbol'=>$purchase_currency_symbol,
                        'purchase_href'=>$purchase_href,'sendpaymentid'=>$sendpaymentid, 'sendpayment_no'=>$sendpayment_no,
                         'sendpayment_plandate'=>$sendpayment_plandate,'sendpayment_periodtime'=>$sendpayment_periodtime,
                          'amount'=>$amount,'actualamount'=>$actualammount, 'sendpayment_currency_id'=>$currency_id,
                        'sendpayment_conversion_rate'=>$conversion_rate,'sendpayment_currency_symbol'=>$currency_symbol,
                        'invoice_num'=>$invoice_num,'invoice_date'=>$invoice_date,'invoce_amount'=>$totalsum,'cur_amount'=>$amount-$actualammount);
            
      }
      $this->table_data=$data;
      return $data;  
    }
    /**
     * 根据业务规则选择付款计划不需要考虑获取数据库已经付款的单据
     * */
    private function getData_inDataBase()
    {
        
    }
}

?>