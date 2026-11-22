<?php

class cls_SalesOrder_EntityData extends cls_CashBill_Parent_EnitytData
{
    public function __construct($record,$sourceids,$pageType)
    {
        
        $this->sourceModule='SalesOrder';
       crm_load_class_file('cls_Common_Sql','include/utils');
       $this->invoiceSql=' left join ( ' .cls_Common_Sql::getInvoice_date_amount().') as tmp_invoice on tmp_invoice.entitytypeid=ld_salesorder.salesorderid  ';
       
       parent::__construct($record,$sourceids,$pageType);
        
        
    }
    public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid ,currency_symbol ,conversion_rate , ld_salesorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,ld_salesorder.salesorderid as selectsourceid,ld_salesorder.received_amount,signed_data as billdate,total,receivable_balance as now_cashbill_money,
            ld_salesorder.cashbilldate as lastcashbilldate ,tmp_invoice.invoicedate,tmp_invoice.invoicetotal
        from ld_salesorder  ' ;
        if($this->href_table_name!='ld_salesorder')
         {
            $sql.= ' left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid ';
         }
        $sql.=  ' '.$this->invoiceSql.'  where ld_salesorder.salesorderid in( '.$this->sourceids.' )';

        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select ld_salesorder.total,ld_salesorder.currency_symbol,ld_salesorder.currency_id,ld_salesorder.conversion_rate, ld_cashbill2paymentplan.amount as now_cashbill_money,
                    '.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,ld_salesorder.salesorderid  as selectsourceid,ld_salesorder.received_amount,
                    signed_data  as billdate,ld_salesorder.cashbilldate as lastcashbilldate ,cashbill2paymentplan_id as detailid
                    ,tmp_invoice.invoicedate,tmp_invoice.invoicetotal from ld_cashbill2paymentplan 
                INNER JOIN ld_salesorder on ld_salesorder.salesorderid=ld_cashbill2paymentplan.entitytypeid ';
         if($this->href_table_name!='ld_salesorder')
         {
            $sql.= ' left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid ';
         }
              $sql.=    $this->invoiceSql.' where cashbillid='.$this->record.'  order by sequence';
         
         return $sql;
    }
    
     /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
       $sql='select ld_salesorder.total,ld_salesorder.currency_symbol,ld_salesorder.currency_id,ld_salesorder.conversion_rate, ld_cashbill2paymentplan.amount as now_cashbill_money,
                    '.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,ld_salesorder.salesorderid  as selectsourceid,ld_salesorder.received_amount,
                    signed_data  as billdate,ld_salesorder.cashbilldate as lastcashbilldate ,cashbill2paymentplan_id as detailid
                    ,tmp_invoice.invoicedate,tmp_invoice.invoicetotal from ld_cashbill2paymentplan 
                INNER JOIN ld_salesorder on ld_salesorder.salesorderid=ld_cashbill2paymentplan.entitytypeid 
                left join ld_salesordercf on ld_salesordercf.salesorderid=ld_salesorder.salesorderid
                 ' .$this->invoiceSql.' where ld_cashbill2paymentplan.cashbill2paymentplan_id='.$this->record.'  order by sequence';
     
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
    public function getContract_Receive_Amount($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'received_amount');
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
    public function getCashBillDate($result,$i)
    {
        global $adb;
        $cashbilldate= $adb->query_result($result,$i,'lastcashbilldate');
        if($cashbilldate<='1600-01-01'||$cashbilldate=='00:00:00')
        {
            $cashbilldate='';
        }
        return $cashbilldate;
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