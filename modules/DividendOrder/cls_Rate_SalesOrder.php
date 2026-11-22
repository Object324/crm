<?php
class cls_Rate_SalesOrder extends DividendParent
{
    public function getHistoryProductFieldObjs()
    {
        global $adb;
        
        $this->historyProductFieldObjs=array();
    }
    /**
     * 获取金额改变历史数组
     * 
     * */
    public function getHistoryMoney_array($startdate,$enddate)
    {
         $historyproductfieldobj=new HistoryProductField();
        $historyproductfieldobj->id=0;
        $historyproductfieldobj->after_total=$this->salesorder_focus->column_fields['hdnGrandTotal'];
        $historyproductfieldobj->currencyid=$this->salesorder_focus->column_fields['currencyid'];
        $historyproductfieldobj->operationtime=$enddate;
        
        $historymoney_obj[$startdate]=array('enddate'=>$enddate,'after_total'=>$historyproductfieldobj->after_total,
        'currencyid'=> $historyproductfieldobj->currencyid);
        return $historymoney_obj;
    }
    public function getPrev_Princial_Amount($date)
    {
        $historyproductfieldobj=new HistoryProductField();
        $historyproductfieldobj->id=0;
        $historyproductfieldobj->after_total=$this->salesorder_focus->column_fields['hdnGrandTotal'];
        $historyproductfieldobj->currencyid=$this->salesorder_focus->column_fields['currencyid'];
        $historyproductfieldobj->operationtime=$date;
        return $historyproductfieldobj;
    }
     public function getDividendOrderObjs_dataBase()
    {
        global $adb;
       
        $sql='select * from ld_dividendorder where salesorderid=?  and deleted=0 order by createdtime asc ';
        $result=$adb->pquery($sql,array($this->salesorder_focus->id));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $startdate=$adb->query_result($result,$i,'startdate');
            $enddate=$adb->query_result($result,$i,'enddate');
            $principal=$adb->query_result($result,$i,'principal');
            $dividendmoney=$adb->query_result($result,$i,'cashmoney');
            $rate_senddate=$adb->query_result($result,$i,'plandividend_date');
            $float_income_money=$adb->query_result($result,$i,'float_income');
            $rate_money=$adb->query_result($result,$i,'rate_money');
            $adjustment=$adb->query_result($result,$i,'adjustment');
            $dividendfieldobj=new DividendField();
            $dividendfieldobj->setStartDate($startdate);
            $dividendfieldobj->setEndDate($enddate);
            $dividendfieldobj->setPrincipal($principal);
            $dividendfieldobj->setDividend_money($dividendmoney);
            $dividendfieldobj->setRate_senddate($rate_senddate);
            $dividendfieldobj->setRate_money($rate_money);
            $dividendfieldobj->setAdjustment($adjustment);
            $dividendfieldobj->setDividendOrderId($adb->query_result($result,$i,'dividendorderid'));
            $dividendfieldobj->setStatus($adb->query_result($result,$i,'status'));
            $this->dividendOrderObjs_dataBase[$startdate]=$dividendfieldobj;
            
        }
    }
     public function getCurrencyId()
     {
       
        return $this->salesorder_focus->column_fields['currency_id'];
     }
     /**
     * 获取相关信息sql语句
     *
     * */
    public function getRelatedInfo_Sql($query)
    {
        $query.=' and  ld_dividendorder.salesorderid='.$this->salesorder_focus->id;
        return $query;
        
    }
    public function getSmownerid()
    {
        global $adb,$current_user;
        if($this->smownerid>0)
            return $this->smownerid;
        $sql='select smownerid from ld_dividendorder where salesorderid=?  and deleted=0  order by enddate desc  limit 1  ';
       
        $result=$adb->pquery($sql,array($this->salesorder_focus->id));
         if($adb->num_rows($result)>0)
         {
            $this->smownerid= $adb->query_result($result,0,0);
         }
         else
         {
             $this->smownerid= $current_user->id;
         }
        return $this->smownerid;
    }
      /**
     * 获取开始计息日期
     * 
     * */
    public function getStart_Rate_date()
    {
         global $adb;
         $start_date=$this->salesorder_focus->column_fields['start_date'];
         return $start_date;
    }
    public function getInvestment_Amount()
    {
        $total=$this->salesorder_focus->column_fields['hdnGrandTotal'];
        $this->currency_id=$this->salesorder_focus->column_fields['currency_id'];
        return $total;
    }
   
    public function getExistDiviend_result($enddate)
    {
        global $adb;
        $sql="select ld_dividendorder.* from ld_dividendorder 
                    where  ld_dividendorder.salesorderid=? and  ld_dividendorder.enddate<=?  and ld_dividendorder.deleted=0 order by  ld_dividendorder.startdate asc ";
      
       $result=$adb->pquery($sql,array($this->salesorder_focus->id,$enddate));
       return $result;
    }
    
   
    
    /**
     * 获取投资到期日
     * 
     * */
    public function getInvestment_Enddate()
    {
        global $adb;
        $this->invenst_enddate=$this->salesorder_focus->column_fields['end_date'];
        return $this->invenst_enddate;
        
    }
   
     /**
     *重算 删除未派记录
     * 
     * */
    public  function Recalculate_delete_no_dividendorder()
    {
         global $adb;
        $this->get_account_product_id();//获取客户和产品ID
       $sql='delete from  ld_dividendorderdetail  where dividendorderid in
                (select dividendorderid from ld_dividendorder where salesorderid=? and status=?)';
                
           
       $adb->pquery($sql,array($this->salesorder_focus->id,DIVIDEND_STATUS_NO));
       $sql='delete  from ld_dividendorder where salesorderid=? and status=?';
       $adb->pquery($sql,array($this->salesorder_focus->id,DIVIDEND_STATUS_NO));
    }
    /**
     * 重算删除所有记录
     * */
    public  function Recalculate_delete_all_dividendorder()
    {
        global $adb;
        $this->get_account_product_id();//获取客户和产品ID
       $sql='delete from  ld_dividendorderdetail  where dividendorderid in
                (select dividendorderid from ld_dividendorder where salesorderid=?)';
                
           
       $adb->pquery($sql,array($this->salesorder_focus->id));
       $sql='delete  from ld_dividendorder where salesorderid=?';
       $adb->pquery($sql,array($this->salesorder_focus->id));
    }
  
    public function getDividendDetail()
     {
       
       $formula_obj= Formula_base::getFormula_Instance($this);
       $this->formula_obj=$formula_obj;
        $formula_obj->getDividendDetail();
        $this->htmltable=$this->createTable($formula_obj->isExistHaveDividendOrder);
        $this->htmltable.=$formula_obj->htmltable;
        $this->hide_htmltable=$formula_obj->hide_htmltable;
      
        return $this->htmltable;
     }
     
}


?>