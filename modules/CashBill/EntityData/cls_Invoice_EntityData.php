<?php
class cls_invoice_EntityData extends cls_CashBill_Parent_EnitytData
{
    public function __construct($record,$sourceids,$pageType)
    {
         $this->sourceModule='Invoice';
         parent::__construct($record,$sourceids,$pageType);
       
    }
    
    
     public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid , ld_invoice.currency_symbol ,ld_invoice.conversion_rate , ld_invoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                invoiceid as selectsourceid,ld_invoice.received_amount,
                invoicedate as billdate,ld_invoice.total,receivable_balance as now_cashbill_money
         from ld_invoice 
         INNER JOIN ld_invoicedetail on ld_invoicedetail.id =ld_invoice.invoiceid
        
        where ld_invoicedetail.lineitem_id in( '.$this->sourceids.' ) group by id';
        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select ld_invoice.currency_symbol ,ld_invoice.conversion_rate , ld_invoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                invoiceid as selectsourceid,ld_invoice.received_amount,
                invoicedate as billdate,ld_invoice.total,cashbill2paymentplan_id as detailid,
			 ld_cashbill2paymentplan.amount as now_cashbill_money
            from ld_cashbill2paymentplan 
                INNER JOIN ld_invoice on ld_invoice.invoiceid=ld_cashbill2paymentplan.entitytypeid 

                where cashbillid='.$this->record.'  order by sequence';
         return $sql;
    }
      /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
       $sql='select ld_invoice.currency_symbol ,ld_invoice.conversion_rate , ld_invoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                invoiceid as selectsourceid,ld_invoice.received_amount,
                invoicedate as billdate,ld_invoice.total,cashbill2paymentplan_id as detailid,
			 ld_cashbill2paymentplan.amount as now_cashbill_money
            from ld_cashbill2paymentplan 
                INNER JOIN ld_invoice on ld_invoice.invoiceid=ld_cashbill2paymentplan.entitytypeid 

                where ld_cashbill2paymentplan.cashbill2paymentplan_id='.$this->record;
         return $sql;
     }
     public function getrelated_createSql()
     {
        $sql='select \'0\' as detailid ,ld_invoice.currency_symbol ,ld_invoice.conversion_rate , ld_invoice.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                invoiceid as selectsourceid,ld_invoice.received_amount,
                invoicedate as billdate,ld_invoice.total,receivable_balance as now_cashbill_money
         from ld_invoice 
        INNER JOIN ld_invoicedetail on ld_invoicedetail.id =ld_invoice.invoiceid
        
        where ld_invoicedetail.lineitem_id in( '.$this->sourceids.' ) group by id';
        return $sql;
     }
    public function getContractinfo($result,$i)
    {
        return '';
        
        /*global $adb;
        return $adb->query_result($result,$i,'contractinfo');*/
    }
    public function getContractAmount($result,$i)
    {
        return '';
       /* global $adb;
        return $adb->query_result($result,$i,'contractamount');*/
    }
     public function getContract_Receive_Amount($result,$i)
    {
        return '';
        /*global $adb;
        return $adb->query_result($result,$i,'contract_receive_amount');*/
    }
    public function getContractCurrencyInfo($result,$i)
    {
        return array();
       /* global $adb;
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