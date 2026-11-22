<?php

class  cls_Rate_havetotal extends DividendParent
{
       
    
    
   
   private $init_start_rate=''; //开始计息日期
   /**
     * 获取金额改变历史数组（在给定的日期内）
     * 
     * */
   public function getHistoryMoney_array($startdate,$enddate)
   {
      
       $start_index=0;
       foreach($this->historyProductFieldObjs as $one_startdate=>$historyfieldobj)
       {
          
         if($startdate<$historyfieldobj->operationtime&&$historyfieldobj->operationtime<$enddate)
         {
              $historyproductfieldobj=new HistoryProductField();
              $historyproductfieldobj->id=$historyfieldobj->id;
              $historyproductfieldobj->after_total=$historyfieldobj->after_total;
              $historyproductfieldobj->currencyid=$historyfieldobj->currencyid;
              $historyproductfieldobj->operationtime=$historyfieldobj->operationtime;
              if($startdate==$this->init_start_rate&&$start_index==0&&$startdate<$historyproductfieldobj->operationtime)
              {
                //计息起始日期小于第一次投资金额日期
                //这个时候：$historyproductfieldobj->operationtime的值就是第一次投资金额日期
                $historyproductfieldobj->operationtime=DateOperation::addDays($historyproductfieldobj->operationtime,"-1");
               
              }
               $start_index++;
              $one_historymoney_obj[]=$historyproductfieldobj;
             
         }
       }
     
      if(sizeof($one_historymoney_obj)<=0)
        return array();
       $i=0;
    
      
       if($one_historymoney_obj[0]->operationtime!=$startdate||sizeof($one_historymoney_obj)<=0)
       {
       
             $prev_field_obj=$this->getPrev_Princial_Amount($startdate);
            $historyproductfieldobj=new HistoryProductField();
           
            $historyproductfieldobj->id=$prev_field_obj->id;
            $historyproductfieldobj->after_total=$prev_field_obj->after_total;
            $historyproductfieldobj->currencyid=$prev_field_obj->currencyid;
            $historyproductfieldobj->operationtime=$startdate;
            $two_historymoney_obj[]=$historyproductfieldobj;
       }
       if(is_array($two_historymoney_obj))
             $one_historymoney_obj=array_merge( $two_historymoney_obj,$one_historymoney_obj);
      
       if($one_historymoney_obj[sizeof($one_historymoney_obj)-1]->operationtime!=$enddate||sizeof($one_historymoney_obj)<=1)
       {  
             $prev_field_obj=$this->getPrev_Princial_Amount($enddate);
            $historyproductfieldobj=new HistoryProductField();
            $historyproductfieldobj->id=$prev_field_obj->id;
            $historyproductfieldobj->after_total=$prev_field_obj->after_total;
            $historyproductfieldobj->currencyid=$prev_field_obj->currencyid;
            $historyproductfieldobj->operationtime=$enddate;
            $three_historymoney_obj[]=$historyproductfieldobj;
       }
       if(is_array($three_historymoney_obj))
        $one_historymoney_obj=array_merge($one_historymoney_obj,$three_historymoney_obj);
      
       for($i=0;$i<sizeof($one_historymoney_obj)-1;$i++)
       {
            $one_startdate=$one_historymoney_obj[$i]->operationtime;
            if($i>0)
                $one_startdate=DateOperation::addDays($one_startdate,"1");
             $historymoney_obj[$one_startdate]=array('enddate'=>$one_historymoney_obj[$i+1]->operationtime,'after_total'=>$one_historymoney_obj[$i]->after_total,
                        'currencyid'=>$one_historymoney_obj[$i]->currencyid);
        
       }
      
        return $historymoney_obj;
   }
   /**
    * 
    * 获取金额改变历史记录
    * */
    public function getHistoryProductFieldObjs()
    {
        global $adb;
         $this->get_account_product_id();
    
         $sql="select * from ld_buyproducthistory where accountid=? and productid=?  order by operationtime asc  ";
         $result=$adb->pquery($sql,array($this->accountid,$this->productid));
         for($i=0;$i<$adb->num_rows($result);$i++)
         {
            $id=$adb->query_result($result,$i,'id');
            $historyproductfieldobj=new HistoryProductField();
            $historyproductfieldobj->id=$id;
            $historyproductfieldobj->accountid=$this->accountid;
            $historyproductfieldobj->productid=$this->productid;
            $after_total=$adb->query_result($result,$i,'after_total');
            $currencyid=$adb->query_result($result,$i,'currencyid');
            $changetype=$adb->query_result($result,$i,'changetype');
            $operationtime=$adb->query_result($result,$i,'operationtime');
            $operationtime=date("Y-m-d",strtotime($operationtime));
            $historyproductfieldobj->after_total=$after_total;
            $historyproductfieldobj->currencyid=$currencyid;
            $historyproductfieldobj->changetype=$changetype;
            $historyproductfieldobj->operationtime=$operationtime;
            $this->historyProductFieldObjs[$operationtime]=$historyproductfieldobj;
            
         }
       
    }
    /**
     * 获取数据库已经存在的派息单
     * 
     * */
    public function getDividendOrderObjs_dataBase()
    {
        global $adb;
        $this->get_account_product_id();
        $sql='select * from ld_dividendorder where accountid=? and product_id=? and deleted=0 order by createdtime asc ';
        $result=$adb->pquery($sql,array($this->accountid,$this->productid));
    
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
    /**
     * 获取相关信息sql语句
     * 
     * */
    public function getRelatedInfo_Sql($query)
    {
        $this->get_account_product_id();
        
        $query.='  and  ld_dividendorder.accountid='.$this->accountid.' and ld_dividendorder.product_id='.$this->productid;
        return $query;
    }
    /**
     * 获取开始计息日期
     * 
     * */
    public function getStart_Rate_date()
    {
         global $adb;
         if( !empty($this->init_start_rate))
         {
            return  $this->init_start_rate;
         }
        $sql='select min(ifnull(start_date,\'1970-01-01\')) from ld_salesorder inner join ld_salesorderdetail 
                 on ld_salesorder.salesorderid=ld_salesorderdetail.id where accountid=? and productid=?
                  AND ld_salesorder.deleted = 0 and ld_salesorder.sostatus<>\'已作废\' 
                            and ld_salesorder.sostatus not like  \'%已退%\'  and start_date is not null and start_date<>\'\'  ';
      $productinfoobj=$this->salesorder_productdetail_obj[0]['productid'];
      $result=$adb->pquery($sql,array($this->salesorder_focus->column_fields['account_id'],$productinfoobj->getColumn_Value()));
       $init_start_date=$adb->query_result($result,0,0);
       $this->init_start_rate=$init_start_date;
       return $init_start_date;
    }
    
 
  /**
     * 获取给定日期前一次的投资金额
     * 
     * */
    public function getPrev_Princial_Amount($date)
    {
        $keys=array_keys($this->historyProductFieldObjs );
     
        if($date<$this->historyProductFieldObjs[$keys[0]]->operationtime)
        {
            //开始计息日期小于第一次投资金额日期
            $prev_field_obj=new HistoryProductField();
            $prev_field_obj->after_total=0;
            $prev_field_obj->operationtime=$this->historyProductFieldObjs[$keys[0]]->operationtime;
            return $prev_field_obj;
        }
        foreach($this->historyProductFieldObjs  as $fieldobj)
        {
             
             if($fieldobj->operationtime>$date)
             {
                break;
             }
             $prev_field_obj=$fieldobj;
        }
        if(!isset($prev_field_obj))
        {
           
             if($date<=$this->historyProductFieldObjs[$keys[0]])
            
                $prev_field_obj=$this->historyProductFieldObjs[$keys[0]];
            else
                $prev_field_obj=$this->historyProductFieldObjs[$keys[sizeof($keys)-1]];
        }
        return $prev_field_obj;
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
                (select dividendorderid from ld_dividendorder where accountid=? and product_id=? and status=?)';
              
       $adb->pquery($sql,array($this->accountid,$this->productid,DIVIDEND_STATUS_NO));
       $sql='delete  from ld_dividendorder where accountid=? and product_id=? and status=?';
       
       $adb->pquery($sql,array($this->accountid,$this->productid,DIVIDEND_STATUS_NO));
    }
    /**
     * 重算删除所有记录
     * */
    public  function Recalculate_delete_all_dividendorder()
    {
        global $adb;
       $this->get_account_product_id();//获取客户和产品ID
       $sql='delete from  ld_dividendorderdetail  where dividendorderid in
                (select dividendorderid from ld_dividendorder where accountid=? and product_id=? )';
                
      
       $adb->pquery($sql,array($this->accountid,$this->productid));
       $sql='delete  from ld_dividendorder where accountid=? and product_id=? ';
       $adb->pquery($sql,array($this->accountid,$this->productid));
    }
    
     public function getDividendDetail()
     {
        $htmltable=$this->createTable('yes');
        $formula_obj= Formula_base::getFormula_Instance($this);
        //ob_clean();
        $this->formula_obj=$formula_obj;
     
        $formula_obj->getDividendDetail();
         
        $this->htmltable=$this->createTable($formula_obj->isExistHaveDividendOrder);
        $this->htmltable.=$formula_obj->htmltable;
        $this->hide_htmltable=$formula_obj->hide_htmltable;
      // echo json_encode($this->hide_dividendObjs,true);
      // exit();
        foreach($this->show_dividendObjs as $dividendobj)
        {
            $count=0;
            $start_date=$dividendobj->getStartDate();
            $end_date=$dividendobj->getEndDate();
            
            foreach($this->hide_dividendObjs  as $hidedividendobj)
            {
                 $hide_start_date=$hidedividendobj->getStartDate();
                 $hide_end_date=$hidedividendobj->getEndDate();
                  
                if($hidedividendobj->getRate_senddate()==$dividendobj->getRate_senddate()&&$hide_start_date>=$start_date&&$hide_end_date<=$end_date)
                {
                    
                    $count++;
                }
                else  if($this->Is_Multi_DividendorderDetail($dividendobj)=='yes')
                {
                    $count++;
                }
                if($count>1)
                {
                    break;
                }
            }
            if($count>1)
            {
                break;
            }
        }
        if($count>1)//如果有明细
        {
            $this->Multi_DividendOrder_Detail="yes";
            $this->htmltable=$this->createTable($formula_obj->isExistHaveDividendOrder);
             $this->htmltable.=$formula_obj->table_content_header;
             $formula_obj->current_row_index=1;
             $count=sizeof($this->show_dividendObjs);
             $i=0;
           $len_end= (sizeof($this->show_dividendObjs)-1);
           $tmp_dividendobjs=$this->show_dividendObjs;
           $this->show_dividendObjs=array();
            foreach($tmp_dividendobjs as $dividendobj)
            {
                
                if($i==$len_end)
                {
                   
                    $last_invest="yes";
                }
                $count=0;
                $start_date=$dividendobj->getStartDate();
                $end_date=$dividendobj->getEndDate();
                $this->tr_Multi_DividendOrder_detail='no';
               
                foreach($this->hide_dividendObjs as $hide_obj)
                {
                     $hide_start_date=$hide_obj->getStartDate();
                     $hide_end_date=$hide_obj->getEndDate();
                    if($hide_obj->getRate_senddate()==$dividendobj->getRate_senddate()&&$hide_start_date>=$start_date&&$hide_end_date<=$end_date)
                    {
                        $count++;
                    }
                }
                if($count>1)
                {
                    $this->tr_Multi_DividendOrder_detail="yes";
                }
                
                $this->htmltable.=$formula_obj->createTableContent($dividendobj,$last_invest);
                $i++;
            }
            
             $this->htmltable.='</table></div>';
        }
        return $this->htmltable;
     }
   
   /**
    * 获取负责人
    * 
    * */
    public function getSmownerid()
    {
        
        if($this->smownerid>0)
            return $this->smownerid;
            
        global $adb,$current_user;
        $this->get_account_product_id();//获取客户和产品ID
  		$account_id =$this->accountid;
        $productid =  $this->productid;
        $sql='select smownerid from ld_dividendorder where accountid=? and product_id=?  and deleted=0  order by enddate desc limit 1  ';
        
        $result=$adb->pquery($sql,array($account_id,$productid));
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
     * 获取投资到期日
     * 
     * */
    public function getInvestment_Enddate()
    {
        global $adb;
        if(!empty($this->invenst_enddate))
        {
            return $this->invenst_enddate;
        }
        $this->get_account_product_id();//获取客户和产品ID
  		$account_id =$this->accountid;
        $productid =  $this->productid;
        $sql='select max(ld_salesorder.end_date)  from ld_salesorder inner join ld_salesorderdetail
                on ld_salesorder.salesorderid=ld_salesorderdetail.id
                 where ld_salesorder.accountid=? and ld_salesorderdetail.productid=?  and ld_salesorder.deleted=0 ';
        $result=$adb->pquery($sql,array($account_id,$productid));
        if($adb->num_rows($result)>0)
        {
            $maxdate=$adb->query_result($result,0,0);
            $this->invenst_enddate=$maxdate;
            return $maxdate;
        }
        else
        {
            
            return '';
        }
        
    }
     public function getCurrencyId()
     {
        return $this->currency_id;
     }
    /**
     * 获取投资金额
     * 
     * */
    public function getInvestment_Amount()
    {
        	global $adb;
        	$AccountByProductTotal = 0.00;
           $this->get_account_product_id();//获取客户和产品ID
      		$account_id =$this->accountid;
            $productid =  $this->productid;
       			$query = 'SELECT
        						 ld_salesorder.currency_id, 
                                total,ifnull(ld_salesorder.conversion_rate,1)  as conversion_rate
        					FROM
        						ld_salesorderdetail
        					inner JOIN ld_salesorder ON ld_salesorder.salesorderid = ld_salesorderdetail.id
        					WHERE
        						ld_salesorder.accountid = ?
        					AND ld_salesorderdetail.productid = ? 
        					AND ld_salesorder.deleted = 0 and ld_salesorder.sostatus<>\'已作废\' 
                            and ld_salesorder.sostatus not like  \'%已退%\' ';
                            
                  
        			$result = $adb->pquery($query,array($account_id,$productid));
                    $AccountByProductTotal=0;
                    $convertcurrency='no';
                    for($i=0;$i<$adb->num_rows($result);$i++)
                    {
                        $currency_id=$adb->query_result($result,$i,'currency_id');
                        //判断投资金额是否需要转换为人民币金额，如果该客户，产品所对应的合同订单有和当前合同订单币种不一样的则需要转换
                        if($this->salesorder_focus->column_fields['currency_id']!=$adb->query_result($result,$i,'currency_id'))
                        {
                          
                            $this->currency_id=1;
                            $convertcurrency='yes';
                            break;
                        }
                        //$AccountByProductTotal
                    }
                     
                    for($i=0;$i<$adb->num_rows($result);$i++)
                    {
                        $currency_id=$adb->query_result($result,$i,'currency_id');
                        $conversion_rate=$adb->query_result($result,$i,'conversion_rate');
                        $total=$adb->query_result($result,$i,'total');
                        if($convertcurrency=='yes')
                        {
                          
                            if($currency_id>1)//非人民币
                            {
                                $AccountByProductTotal+=$total/$conversion_rate;
                                
                            }
                            else
                            {
                                $AccountByProductTotal+=$total;
                            }
                        }
                        else
                        {
                            $this->currency_id=$this->salesorder_focus->column_fields['currency_id'];
                            
                            $AccountByProductTotal+=$total;
                        }
                        
                    }
                    
                    $this->Investment_Amount=$AccountByProductTotal;
                return $AccountByProductTotal;
        	
    }
      public function Computer_Principal()
       {
            $principal=$this->diviendField_obj->getPrincipal();//本金
            
       }
       /**
        * 派息单是否有多行派息
        * yes:有
        * */
   public function Is_Multi_DividendorderDetail($dividendorderobj)
   {
       global $adb;
      $dividendorderid=$dividendorderobj->getId();
      if(empty($dividendorderid)||!isset($dividendorderid))
      {
        return "no";
      }
      else if($this->formula_obj->isExistHaveDividendOrder=='yes')
      {
         $sql='select  dividendorderid from ld_dividendorderdetail where dividendorderid=?';
         $result=$adb->pquery($sql,array($dividendorderid));
         if($adb->num_rows($result)>1)
         {
            return 'yes';
         }
         else
         {
            return 'no';
         }
        
      }
      else 
      {
        return 'no';
      }
   }
      
      
}


?>