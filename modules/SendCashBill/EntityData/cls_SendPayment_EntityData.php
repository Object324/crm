<?php

class cls_SendPayment_EntityData extends cls_SendCashBill_Parent_EntityData
{
     public function __construct($record,$sourceids,$pageType)
    {
         $this->sourceModule='SendPayment';
         parent::__construct($record,$sourceids,$pageType);
       crm_load_class_file('cls_Common_Sql','include/utils');
       $this->invoiceSql=' left join ( ' .cls_Common_Sql::getPurchaseInvoice_date_amount().') as tmp_invoice on tmp_invoice.entitytypeid=contract_tmp.purchaseorderid  ';
       
    }
    
     public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid,ld_sendpayment.currency_symbol ,ld_sendpayment.conversion_rate , ld_sendpayment.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                sendpaymentid as selectsourceid,ld_sendpayment.actualamount as pay_amount,
                plandate as billdate,ld_sendpayment.amount as total,ld_sendpayment.pay_balance as now_sendcashbill_money,
                ld_sendpayment.cpperiodtime,ld_sendpayment.plandate,
                contract_tmp.purchaseorder_no as contractinfo,contract_tmp.total as contractamount,contract_tmp.currency_id as contract_currency_id,
            	contract_tmp.currency_symbol as contract_currency_symbol,contract_tmp.purchaseorderid as contractid,
                contract_tmp.conversion_rate as contractid_conversion_rate,
                contract_tmp.pay_amount as contract_pay_amount,
                contract_tmp.sendcashbilldate as lastsendcashbilldate,tmp_invoice.invoicedate,tmp_invoice.invoicetotal
         from ld_sendpayment 
         left join ld_purchaseorder  as  contract_tmp on contract_tmp.purchaseorderid=ld_sendpayment.purchaseorder_id '.$this->invoiceSql.'
        where ld_sendpayment.sendpaymentid in( '.$this->sourceids.' )';
         
        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select sendcashbill2payment_id as detailid,ld_sendpayment.currency_symbol ,ld_sendpayment.conversion_rate , ld_sendpayment.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                ld_sendpayment.sendpaymentid as selectsourceid,ld_sendpayment.actualamount as pay_amount,
                ld_sendpayment.plandate,ld_sendpayment.plandate as billdate,ld_sendpayment.amount as  total,
                ld_sendpayment.cpperiodtime,
				contract_tmp.purchaseorder_no as contractinfo,contract_tmp.total as contractamount,
                contract_tmp.currency_id as contract_currency_id,
			  contract_tmp.currency_symbol as contract_currency_symbol,
              contract_tmp.conversion_rate as contractid_conversion_rate,
              contract_tmp.pay_amount as contract_pay_amount,
			 ld_sendcashbill2payment.amount as now_sendcashbill_money,contract_tmp.purchaseorderid as contractid,
             contract_tmp.sendcashbilldate as lastsendcashbilldate,tmp_invoice.invoicedate,tmp_invoice.invoicetotal
            from ld_sendcashbill2payment 
                INNER JOIN ld_sendpayment on ld_sendpayment.sendpaymentid=ld_sendcashbill2payment.entitytypeid 
                left join ld_purchaseorder as contract_tmp on contract_tmp.purchaseorderid=ld_sendpayment.purchaseorder_id '.$this->invoiceSql.'

                where sendcashbillid='.$this->record.'  order by sequence';

         return $sql;
    }
    /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
        $sql='select sendcashbill2payment_id as detailid,ld_sendpayment.currency_symbol ,ld_sendpayment.conversion_rate , ld_sendpayment.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                ld_sendpayment.sendpaymentid as selectsourceid,ld_sendpayment.actualamount as pay_amount,
                ld_sendpayment.plandate,ld_sendpayment.plandate as billdate,ld_sendpayment.amount as  total,
                ld_sendpayment.cpperiodtime,
				contract_tmp.purchaseorder_no as contractinfo,contract_tmp.total as contractamount,
                contract_tmp.currency_id as contract_currency_id,
			  contract_tmp.currency_symbol as contract_currency_symbol,
              contract_tmp.conversion_rate as contractid_conversion_rate,
              contract_tmp.pay_amount as contract_pay_amount,
			 ld_sendcashbill2payment.amount as now_sendcashbill_money,contract_tmp.purchaseorderid as contractid,
             contract_tmp.sendcashbilldate as lastsendcashbilldate,tmp_invoice.invoicedate,tmp_invoice.invoicetotal
            from ld_sendcashbill2payment 
                INNER JOIN ld_sendpayment on ld_sendpayment.sendpaymentid=ld_sendcashbill2payment.entitytypeid 
                left join ld_purchaseorder as contract_tmp on contract_tmp.purchaseorderid=ld_sendpayment.purchaseorder_id '.$this->invoiceSql.'

                where sendcashbill2payment_id='.$this->record.'  order by sequence';
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
        global $adb;
        return $adb->query_result($result,$i,'contractamount');
    }
    public function getContractPay_Amount($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'contract_pay_amount');
    }
    public function getContractCurrencyInfo($result,$i) 
    {
        global $adb;
        $currencyid=$adb->query_result($result,$i,'contract_currency_id');
        $currency_symbol=$adb->query_result($result,$i,'contract_currency_symbol');
        $conversion_rate=$adb->query_result($result,$i,'contract_conversion_rate');
        $currecyinfo['id']=$currencyid;
        $currecyinfo['bol']=$currency_symbol;
        $currecyinfo['rate']=$conversion_rate;
        return $currecyinfo;
    }
    public function getPeriodtime($result,$i)
    {
        
       global $adb;
        return $adb->query_result($result,$i,'cpperiodtime');
    }
    public function getPlandate($result,$i)
    {
        global $adb;
		$plandate = $adb->query_result($result,$i,'plandate');
		if($plandate == '0000-00-00')$plandate = '';
        return $plandate;
    }
    
    public function getContractid($result,$i)
    {
        global $adb;
        return  $adb->query_result($result,$i,'contractid');
        
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