<?php

class cls_OutboundOrder_EntityData extends cls_CashBill_Parent_EnitytData
{
    public function __construct($record,$sourceids,$pageType)
    {
        $this->sourceModule='OutboundOrder';
      
       parent::__construct($record,$sourceids,$pageType);
        
        
    }
   public function getmoduleCreateSql()
    {
        $sql='select \'0\' as detailid ,ld_outboundorder.currency_symbol ,ld_outboundorder.conversion_rate , ld_outboundorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                out_id as selectsourceid,ld_outboundorder.received_amount,outdate as billdate,ld_outboundorder.total,receivable_balance as now_cashbill_money
         from ld_outboundorder 
         INNER JOIN ld_outboundorderdetail on ld_outboundorderdetail.id =ld_outboundorder.out_id
       
        where ld_outboundorderdetail.id in( '.$this->sourceids.' ) group by id';
		//echo $sql;echo '<br><br>';
        return $sql;
    }
     public function getselect_source_Sql()
    {
        $sql='select \'0\' as detailid ,ld_outboundorder.currency_symbol ,ld_outboundorder.conversion_rate , ld_outboundorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                out_id as selectsourceid,ld_outboundorder.received_amount,outdate as billdate,ld_outboundorder.total,receivable_balance as now_cashbill_money
         from ld_outboundorder 
         INNER JOIN ld_outboundorderdetail on ld_outboundorderdetail.id =ld_outboundorder.out_id
       
        where ld_outboundorderdetail.lineitem_id in( '.$this->sourceids.' ) group by id';
		//echo $sql;echo '<br><br>';
        return $sql;
    }
    
    public function getdetail_editSql()
    {
         $sql='select ld_outboundorder.currency_symbol ,ld_outboundorder.conversion_rate ,
                 ld_outboundorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                out_id as selectsourceid,ld_outboundorder.received_amount,cashbill2paymentplan_id as detailid,
                outdate as billdate,ld_outboundorder.total,ld_cashbill2paymentplan.amount as now_cashbill_money
            from ld_cashbill2paymentplan 
                INNER JOIN ld_outboundorder on ld_outboundorder.out_id=ld_cashbill2paymentplan.entitytypeid 
               

                where cashbillid='.$this->record.'  order by sequence';
     
         return $sql;
    }
        /**
      * 获取明细行数据
      * */
     public function getrowValueByDetailidSql()
     {
       $sql='select ld_outboundorder.currency_symbol ,ld_outboundorder.conversion_rate ,
                 ld_outboundorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                out_id as selectsourceid,ld_outboundorder.received_amount,cashbill2paymentplan_id as detailid,
                outdate as billdate,ld_outboundorder.total,ld_cashbill2paymentplan.amount as now_cashbill_money
            from ld_cashbill2paymentplan 
                INNER JOIN ld_outboundorder on ld_outboundorder.out_id=ld_cashbill2paymentplan.entitytypeid 
               

                where ld_cashbill2paymentplan.cashbill2paymentplan_id='.$this->record.'  order by sequence';
         return $sql;
     }
     public function getrelated_createSql()
     {
        $sql='select \'0\' as detailid ,ld_outboundorder.currency_symbol ,ld_outboundorder.conversion_rate , ld_outboundorder.currency_id,'.$this->href_table_name.'.'.$this->href_columnname.' as href_columnname,
                out_id as selectsourceid,ld_outboundorder.received_amount,
                outdate as billdate,ld_outboundorder.total,receivable_balance as now_cashbill_money
             
         from ld_outboundorder 
        INNER JOIN ld_outboundorderdetail on ld_outboundorderdetail.id =ld_outboundorder.out_id
       
        where ld_outboundorderdetail.lineitem_id in( '.$this->sourceids.' ) group by id';
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
        /*global $adb;
        return $adb->query_result($result,$i,'total');*/
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
        /*global $adb;
        $currencyid=$adb->query_result($result,$i,'currency_id');
        $currency_symbol=$adb->query_result($result,$i,'currency_symbol');
        $conversion_rate=$adb->query_result($result,$i,'conversion_rate');
        $currecyinfo['id']=$currencyid;
        $currecyinfo['bol']=$currency_symbol;
        $currecyinfo['rate']=$conversion_rate;
        return $currecyinfo;*/
    }
  
}

?>