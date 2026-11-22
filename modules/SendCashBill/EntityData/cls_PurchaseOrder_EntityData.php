<?php

class cls_PurchaseOrder_EntityData extends cls_SendCashBill_Parent_EntityData
{
    public function __construct($record,$sourceids,$pageType)
    {
         $this->sourceModule='PurchaseOrder';
        crm_load_class_file('cls_Common_Sql','include/utils');
       $this->invoiceSql=' left join ( ' .cls_Common_Sql::getPurchaseInvoice_date_amount().') as tmp_invoice on tmp_invoice.entitytypeid=ld_purchaseorder.purchaseorderid  ';
       
       parent::__construct($record,$sourceids,$pageType);
       
        
    }
    public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid,currency_symbol ,conversion_rate , ld_purchaseorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
        purchaseorderid as selectsourceid,signed_data as billdate,total,pay_balance as now_sendcashbill_money,
        pay_amount,ld_purchaseorder.total,ld_purchaseorder.sendcashbilldate as lastsendcashbilldate,tmp_invoice.invoicedate,tmp_invoice.invoicetotal from ld_purchaseorder '.$this->invoiceSql.'
         where purchaseorderid in( '.$this->sourceids.' )';
       
        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select sendcashbill2payment_id as detailid,ld_purchaseorder.currency_symbol,ld_purchaseorder.currency_id,ld_purchaseorder.conversion_rate,
                     ld_sendcashbill2payment.amount as now_sendcashbill_money,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,ld_purchaseorder.purchaseorderid  as selectsourceid,
                    signed_data  as billdate,ld_purchaseorder.pay_amount,ld_purchaseorder.total ,ld_purchaseorder.sendcashbilldate as lastsendcashbilldate,tmp_invoice.invoicedate,tmp_invoice.invoicetotal from ld_sendcashbill2payment 
                INNER JOIN ld_purchaseorder on ld_purchaseorder.purchaseorderid=ld_sendcashbill2payment.entitytypeid  '.$this->invoiceSql.' where sendcashbillid='.$this->record.'  order by sequence';
        
         return $sql;
    }
     /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
         $sql='select sendcashbill2payment_id as detailid,ld_purchaseorder.currency_symbol,ld_purchaseorder.currency_id,ld_purchaseorder.conversion_rate,
                     ld_sendcashbill2payment.amount as now_sendcashbill_money,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,ld_purchaseorder.purchaseorderid  as selectsourceid,
                    signed_data  as billdate,ld_purchaseorder.pay_amount,ld_purchaseorder.total ,ld_purchaseorder.sendcashbilldate as lastsendcashbilldate,tmp_invoice.invoicedate,tmp_invoice.invoicetotal from ld_sendcashbill2payment 
                INNER JOIN ld_purchaseorder on ld_purchaseorder.purchaseorderid=ld_sendcashbill2payment.entitytypeid  '.$this->invoiceSql.' where sendcashbill2payment_id='.$this->record;
         return $sql;
     }
     public function getrelated_createSql()
     {
        return $this->getselect_source_Sql();
     }
    public function getContractinfo($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'href_columnname');
    }
    public function getContractAmount($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'total');
    }
    /**
     * 已付总额
     * */
    public function getContractPay_Amount($result,$i)
    {
          global $adb;
        return $adb->query_result($result,$i,'pay_amount');
    }
    public function getContractCurrencyInfo($result,$i)
    {
        global $adb;
        $currencyid=$adb->query_result($result,$i,'currency_id');
        $currency_symbol=$adb->query_result($result,$i,'currency_symbol');
        $conversion_rate=$adb->query_result($result,$i,'conversion_rate');
        $currecyinfo['id']=$currencyid;
        $currecyinfo['bol']=$currency_symbol;
        $currecyinfo['rate']=$conversion_rate;
        return $currecyinfo;
    }
   /**
     * 最近开票日期
     * */
    public function getInvoiceDate($result,$i)
    {
        global $adb;
        $invoicedate= $adb->query_result($result,$i,'invoicedate');
        if($invoicedate<='1600-01-01'||$invoicedate=='00:00:00')
        {
            $invoicedate='';
        }
        return $invoicedate;
    }
    public function getsendCashBillDate($result,$i)
    {
        global $adb;
        $sendcashbilldate= $adb->query_result($result,$i,'lastsendcashbilldate');
        if($sendcashbilldate<='1600-01-01'||$sendcashbilldate=='00:00:00')
        {
            $sendcashbilldate='';
        }
        return $sendcashbilldate;
    }
    /**
     * 已开票总额
     * */
    public function getInvoicetotal($result,$i)
    {
        global $adb;
        $contractcurrencyinfo=$this->getContractCurrencyInfo($result,$i);
        $invoicetotal=$adb->query_result($result,$i,'invoicetotal');//已开票总额币种为人民币
        if($contractcurrencyinfo['id']!=1)
        {
            $currencyobj=new Currency($adb,$contractcurrencyinfo['id']);
            $chaned_currencyobj=new Currency($adb,1);
           $invoicetotal= $currencyobj->ConvertTothisobj_money($chaned_currencyobj,$invoicetotal);
            
        }
        return $invoicetotal;
    }
}

?>