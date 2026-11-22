<?php

class cls_Payment_EntityData extends cls_CashBill_Parent_EnitytData
{
     public function __construct($record,$sourceids,$pageType)
    {
         $this->sourceModule='PaymentPlan';
         parent::__construct($record,$sourceids,$pageType);
        crm_load_class_file('cls_Common_Sql','include/utils');
       $this->invoiceSql=' left join ( ' .cls_Common_Sql::getInvoice_date_amount().') as tmp_invoice on tmp_invoice.entitytypeid=contract_tmp.contract_id  ';
    }
    
     public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid,ld_paymentplan.currency_symbol ,ld_paymentplan.conversion_rate , ld_paymentplan.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                paymentplanid as selectsourceid,ld_paymentplan.actualamount as received_amount,
                plandate as billdate,ld_paymentplan.amount as total,receivable_balance as now_cashbill_money,
                contract_tmp.contractinfo,contract_tmp.total as contractamount,contract_tmp.currency_id as contract_currency_id,
            	contract_tmp.currency_symbol as contract_currency_symbol,
                contract_tmp.conversion_rate as contractid_conversion_rate,
                ld_paymentplan.periodtime,ld_paymentplan.plandate,
                contract_tmp.received_amount as contract_receive_amount,
                contract_tmp.cashbilldate as lastcashbilldate,contract_tmp.contractmodule,
                tmp_invoice.invoicedate,tmp_invoice.invoicetotal,contract_tmp.contract_id as contractid
         from ld_paymentplan 
        
        left JOIN
        (
          select \'SalesOrder\' as contractmodule, salesorder_no as contractinfo,total,currency_id,currency_symbol,conversion_rate,received_amount,salesorderid as contract_id ,cashbilldate from ld_salesorder
         UNION all select \'ServiceContracts\' as contractmodule, contract_no as contractinfo,total,currency_id,currency_symbol,conversion_rate,received_amount,servicecontractsid as contract_id,cashbilldate from ld_servicecontracts
        )
        as  contract_tmp on contract_tmp.contract_id=ld_paymentplan.entitytypeid '. $this->invoiceSql.'
        
        where ld_paymentplan.paymentplanid in( '.$this->sourceids.' )';
       
        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select ld_paymentplan.currency_symbol ,ld_paymentplan.conversion_rate , ld_paymentplan.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                ld_paymentplan.paymentplanid as selectsourceid,ld_paymentplan.actualamount as received_amount,
                plandate,ld_paymentplan.amount as  total,receivable_balance as now_cashbill_money,
				contract_tmp.contractinfo,contract_tmp.total as contractamount,contract_tmp.currency_id as contract_currency_id,
			  contract_tmp.currency_symbol as contract_currency_symbol,contract_tmp.conversion_rate as contractid_conversion_rate,
			 ld_cashbill2paymentplan.amount as now_cashbill_money,ld_paymentplan.periodtime,cashbill2paymentplan_id as detailid,
             contract_tmp.received_amount as contract_receive_amount,
             contract_tmp.cashbilldate as lastcashbilldate,contract_tmp.contractmodule,
                tmp_invoice.invoicedate,tmp_invoice.invoicetotal,contract_tmp.contract_id as contractid
            from ld_cashbill2paymentplan 
                INNER JOIN ld_paymentplan on ld_paymentplan.paymentplanid=ld_cashbill2paymentplan.entitytypeid 
               
                left JOIN
                (select \'SalesOrder\' as contractmodule, salesorder_no as contractinfo,total,currency_id,currency_symbol,conversion_rate,received_amount,salesorderid as contract_id,cashbilldate from ld_salesorder
                 UNION all select \'ServiceContracts\' as contractmodule, contract_no as contractinfo,total,currency_id,currency_symbol,conversion_rate,received_amount,servicecontractsid as contract_id,cashbilldate from ld_servicecontracts)
                as contract_tmp on contract_tmp.contract_id=ld_paymentplan.entitytypeid'. $this->invoiceSql.'
                
                where cashbillid='.$this->record.'  order by sequence';
			//echo $sql;echo '<br><br>';
         return $sql;
    }
        /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
            $sql='select ld_paymentplan.currency_symbol ,ld_paymentplan.conversion_rate , ld_paymentplan.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                ld_paymentplan.paymentplanid as selectsourceid,ld_paymentplan.actualamount as received_amount,
                plandate,ld_paymentplan.amount as  total,receivable_balance as now_cashbill_money,
				contract_tmp.contractinfo,contract_tmp.total as contractamount,contract_tmp.currency_id as contract_currency_id,
			  contract_tmp.currency_symbol as contract_currency_symbol,contract_tmp.conversion_rate as contractid_conversion_rate,
			 ld_cashbill2paymentplan.amount as now_cashbill_money,ld_paymentplan.periodtime,cashbill2paymentplan_id as detailid,
             contract_tmp.received_amount as contract_receive_amount,
             contract_tmp.cashbilldate as lastcashbilldate,contract_tmp.contractmodule,
                tmp_invoice.invoicedate,tmp_invoice.invoicetotal,contract_tmp.contract_id as contractid
            from ld_cashbill2paymentplan 
                INNER JOIN ld_paymentplan on ld_paymentplan.paymentplanid=ld_cashbill2paymentplan.entitytypeid 
               
                left JOIN
                (select \'SalesOrder\' as contractmodule, salesorder_no as contractinfo,total,currency_id,currency_symbol,conversion_rate,received_amount,salesorderid as contract_id,cashbilldate from ld_salesorder
                 UNION all select \'ServiceContracts\' as contractmodule, contract_no as contractinfo,total,currency_id,currency_symbol,conversion_rate,received_amount,servicecontractsid as contract_id,cashbilldate from ld_servicecontracts)
                as contract_tmp on contract_tmp.contract_id=ld_paymentplan.entitytypeid'. $this->invoiceSql.'
                
                where ld_cashbill2paymentplan.cashbill2paymentplan_id='.$this->record;
             
         return $sql;
     }
     public function getrelated_createSql()
     {
        return $this->getselect_source_Sql();
     }
     public function getContractmodule($result,$i)
     {
        global $adb;
        return $adb->query_result($result,$i,'contractmodule');
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
    public function getContractid($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'contractid');
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
    public function getContractCashBillDate($result,$i)
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
    public function getContract_Receive_Amount($result,$i)
    {
        global $adb;
        return $adb->query_result($result,$i,'contract_receive_amount');
    }
    public function getPeriodtime($result,$i)
    {
        
       global $adb;
        return $adb->query_result($result,$i,'periodtime');
    }
    public function getPlandate($result,$i)
    {
        global $adb;
		$plandate = $adb->query_result($result,$i,'plandate');
		if($plandate == '0000-00-00')$plandate = '';
        return $plandate;
    }
    
    
}


?>