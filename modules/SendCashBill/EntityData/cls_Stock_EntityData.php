<?php

class cls_Stock_EntityData extends cls_SendCashBill_Parent_EntityData
{
    public function __construct($record,$sourceids,$pageType)
    {
        $this->sourceModule='Stock';
      
       parent::__construct($record,$sourceids,$pageType);
        
        
    }
     public function getmoduleCreateSql()
    {
        $sql='select \'0\' as detailid,ld_stock.currency_symbol ,ld_stock.conversion_rate , ld_stock.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                stock_id as selectsourceid,ld_stock.pay_amount,
                createdate as billdate,ld_stock.total,ld_stock.pay_balance as now_sendcashbill_money
         from ld_stock 
         INNER JOIN ld_stockdetail on ld_stockdetail.id =ld_stock.stock_id
      
        where ld_stockdetail.lineitem_id in( '.$this->sourceids.' ) group by id';
        return $sql;
    }
    
     public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid,ld_stock.currency_symbol ,ld_stock.conversion_rate , ld_stock.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                stock_id as selectsourceid,ld_stock.pay_amount,
                createdate as billdate,ld_stock.total,ld_stock.pay_balance as now_sendcashbill_money
         from ld_stock 
         INNER JOIN ld_stockdetail on ld_stockdetail.id =ld_stock.stock_id
      
        where ld_stockdetail.lineitem_id in( '.$this->sourceids.' ) group by id';
		//echo $sql;echo '<br><br>';
        return $sql;
    }
     public function getrowValueByDetailidSql()
    {
         $sql='select sendcashbill2payment_id as detailid,ld_stock.currency_symbol ,ld_stock.conversion_rate , ld_stock.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                stock_id as selectsourceid,ld_stock.pay_amount,
                createdate as billdate,ld_stock.total,ld_sendcashbill2payment.amount as now_sendcashbill_money
            from ld_sendcashbill2payment 
                INNER JOIN ld_stock on ld_stock.stock_id=ld_sendcashbill2payment.entitytypeid 
               
                where sendcashbill2payment_id='.$this->record.'  order by sequence';
			//echo $sql;echo '<br><br>';
         return $sql;
    }
    public function getdetail_editSql()
    {
         $sql='select sendcashbill2payment_id as detailid,ld_stock.currency_symbol ,ld_stock.conversion_rate , ld_stock.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                stock_id as selectsourceid,ld_stock.pay_amount,
                createdate as billdate,ld_stock.total,ld_sendcashbill2payment.amount as now_sendcashbill_money
            from ld_sendcashbill2payment 
                INNER JOIN ld_stock on ld_stock.stock_id=ld_sendcashbill2payment.entitytypeid 
               
                where sendcashbillid='.$this->record.'  order by sequence';
			//echo $sql;echo '<br><br>';
         return $sql;
    }
     public function getrelated_createSql()
     {
        return $this->getselect_source_Sql();
     }
    public function getContractinfo($result,$i)
    {
        return "";
        global $adb;
        return $adb->query_result($result,$i,'contractinfo');
    }
    public function getContractAmount($result,$i)
    {
        return "";
        global $adb;
        return $adb->query_result($result,$i,'total');
    }
    public function getContractPay_Amount($result,$i)
    {
        return "";
        global $adb;
        return $adb->query_result($result,$i,'contract_pay_amount');
    }
    public function getContractCurrencyInfo($result,$i)
    {
        return array();
        global $adb;
        $currencyid=$adb->query_result($result,$i,'currency_id');
        $currency_symbol=$adb->query_result($result,$i,'currency_symbol');
        $conversion_rate=$adb->query_result($result,$i,'conversion_rate');
        $currecyinfo['id']=$currencyid;
        $currecyinfo['bol']=$currency_symbol;
        $currecyinfo['rate']=$conversion_rate;
        return $currecyinfo;
    }
  
}

?>