<?php

class cls_PurchaseInvoice_EntityData extends cls_SendCashBill_Parent_EntityData
{
    public function __construct($record,$sourceids,$pageType)
    {
         $this->sourceModule='PurchaseInvoice';
         parent::__construct($record,$sourceids,$pageType);
       
    }
   
    
     public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid,ld_purchaseinvoice.currency_symbol ,ld_purchaseinvoice.conversion_rate , ld_purchaseinvoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                purchaseinvoiceid as selectsourceid,ld_purchaseinvoice.pay_amount,
                purchaseinvoicedate as billdate,ld_purchaseinvoice.total,ld_purchaseinvoice.pay_balance as now_sendcashbill_money ';
                /*,
                contract_tmp.purchaseorder_no as  contractinfo,contract_tmp.total as contractamount,contract_tmp.currency_id as contract_currency_id,
            	contract_tmp.currency_symbol as contract_currency_symbol,
                contract_tmp.conversion_rate as contractid_conversion_rate,
                contract_tmp.pay_amount as contract_pay_amount*/
         $sql.=' from ld_purchaseinvoice 
                INNER JOIN ld_purchaseinvoicedetail on ld_purchaseinvoicedetail.id =ld_purchaseinvoice.purchaseinvoiceid 
                 where ld_purchaseinvoicedetail.lineitem_id in( '.$this->sourceids.' ) group by id';
         /*
        left  JOIN ld_purchaseorder
        as  contract_tmp on contract_tmp.purchaseorderid=ld_inventoryproductrel.contractid*/
       
        
        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select sendcashbill2payment_id as detailid,ld_purchaseinvoice.currency_symbol ,ld_purchaseinvoice.conversion_rate , ld_purchaseinvoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                ld_purchaseinvoice.purchaseinvoiceid as selectsourceid,ld_purchaseinvoice.pay_amount,
                purchaseinvoicedate as billdate,ld_purchaseinvoice.total,ld_sendcashbill2payment.amount as now_sendcashbill_money
            from ld_sendcashbill2payment
                INNER JOIN ld_purchaseinvoice on ld_purchaseinvoice.purchaseinvoiceid=ld_sendcashbill2payment.entitytypeid 
               
               
                where sendcashbillid='.$this->record.'  order by ld_sendcashbill2payment.sequence';
      
         return $sql;
    }
     /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
       $sql='select sendcashbill2payment_id as detailid,ld_purchaseinvoice.currency_symbol ,ld_purchaseinvoice.conversion_rate , ld_purchaseinvoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                ld_purchaseinvoice.purchaseinvoiceid as selectsourceid,ld_purchaseinvoice.pay_amount,
                purchaseinvoicedate as billdate,ld_purchaseinvoice.total,ld_sendcashbill2payment.amount as now_sendcashbill_money
            from ld_sendcashbill2payment
                INNER JOIN ld_purchaseinvoice on ld_purchaseinvoice.purchaseinvoiceid=ld_sendcashbill2payment.entitytypeid 
                where sendcashbill2payment_id='.$this->record;
         return $sql;
     }
     
     public function getrelated_createSql()
     {
         return $this->getselect_source_Sql();
     }
    public function getContractinfo($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'contractinfo');
    }
    public function getContractAmount($result,$i)
    {
        return "";
       /* global $adb;
        return $adb->query_result($result,$i,'contractamount');*/
    }
     public function getContractPay_Amount($result,$i)
    {
        return "";
        /*global $adb;
        return $adb->query_result($result,$i,'contract_pay_amount');*/
    }
    public function getContractCurrencyInfo($result,$i)
    {
        return array();
        /*global $adb;
        $currencyid=$adb->query_result($result,$i,'contract_currency_id');
        $currency_symbol=$adb->query_result($result,$i,'contract_currency_symbol');
        $conversion_rate=$adb->query_result($result,$i,'contract_conversion_rate');
        $currecyinfo['id']=$currencyid;
        $currecyinfo['bol']=$currency_symbol;
        $currecyinfo['rate']=$conversion_rate;
        return $currecyinfo;*/
        
    }
}


?>