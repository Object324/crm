<?php
class Formula_base
{
    protected $rate_captial_obj;
    var $table_content_header='<div style="height: 155px;overflow-y: auto;"><table id="tb_create_dividend_detail" width="100%" border="0" cellspacing="1" cellpadding="0" class="listEntries">';
    var $Hide_table_content_header='<div style="height: 155px;overflow-y: auto;"><table width="100%" border="0" cellspacing="1" cellpadding="0" class="listEntries">';
    var $dividendorder_loopcount;//投资的派息次数
    protected $dividendorder_row_count ;//合同订单创建派息单行数
    protected $float_income;   
    var $htmltable;
    var $hide_htmltable="";
    var $isExistHaveDividendOrder="no";//是否已经派息，no:没有派息
    var $float_income_money;//浮动收益
    var $Investment_Amount;//投资金额
    var $invest_enddate;//投资到期日期
    var $current_row_index=1;//主表个行标示
    var $hide_start_row_index=1;//隐藏表格行标示
    var $old_dividend_money;
    var $adjustment;
    var $maxOperationdate;
    var $dividendorder_dates=array();//派息的时间段
     var  $total_dividendorder_rate;
    var $total_dividendorder_money;
    public static function getFormula_Instance($rate_type_obj)
    {
        
        if($rate_type_obj->dividend_rules['formulamode']=='othermonth'||$rate_type_obj->dividend_rules['formulamode']=='quarterly'||$rate_type_obj->dividend_rules['formulamode']=='semiannual')
        {
            if(!class_exists('Formula_MultiMonth'))
            {
                require('modules/DividendOrder/Formula_MultiMonth.php');
                
            }
            $formula_obj=Formula_MultiMonth::getInstance($rate_type_obj);
        }
        else if($rate_type_obj->dividend_rules['formulamode']=='oneoff')
        {
            if(!class_exists('Formula_oneoff'))
            {
                require('modules/DividendOrder/Formula_oneoff.php');
               
            }
             $formula_obj=new Formula_oneoff();
        }
        else if($rate_type_obj->dividend_rules['formulamode']=='designated')
        {
            if(!class_exists('Formula_designated'))
            {
                require('modules/DividendOrder/Formula_designated.php');
                
            }
            $formula_obj=new Formula_designated($rate_type_obj);
        }
        else if($rate_type_obj->dividend_rules['formulamode']=='monthly')
        {
            if(!class_exists('Formula_monthly'))
            {
                require('modules/DividendOrder/Formula_monthly.php');
                
            }
            $formula_obj=new Formula_monthly($rate_type_obj);
        }
        if($rate_type_obj->dividend_rules['float_switch']=='on')
        {
            $formula_obj->float_income='all';
        }
        $formula_obj->rate_captial_obj=$rate_type_obj;
        return $formula_obj;
    }
    public function init()
    {
         $init_start_date=$this->rate_captial_obj->getStart_Rate_date();//开始计息日期
         $this->init_start_date=$init_start_date;
         $Investment_Amount=$this->rate_captial_obj->getInvestment_Amount();//投资金额
         $this->Investment_Amount=$Investment_Amount;
        $invest_enddate=$this->rate_captial_obj->getInvestment_Enddate();//投资到期日期
        $this->invest_enddate=$invest_enddate;
        $float_start_date=$this->rate_captial_obj->salesorder_focus->column_fields['float_start_date'];//浮动收益开始日期
        $float_rate=$this->rate_captial_obj->salesorder_focus->column_fields['float_rate'];//浮动收益率
        $float_income_money="0.00";
        $diff_days=DateOperation::days_between_date($invest_enddate,$float_start_date)+1;//获取浮动收益天数
        $float_income_money=($this->Investment_Amount*$float_rate/100*$diff_days);//浮动收益金额
        $this->float_income_money=$float_income_money;
        $this->float_income='none';
    }
   
    public function special_Fun()
    {
        
    }
    /**
     * 
     * 获取派息日期数组
     * */
    public function getDividendOrderDates()
    {
        
    }
   public  function getDividendDetail()
    {
       
        $this->init();
        $this->special_Fun();//特殊处理（包括获取表格行数）
        $this->getDividendOrderDates();//获取派息日期数组
        $this->rate_captial_obj->getDividendOrderObjs_dataBase();//获取已存在数据库中的派息单
        if(sizeof($this->rate_captial_obj->dividendOrderObjs_dataBase)>0)
        {
            $this->isExistHaveDividendOrder="yes";
        }
        $this->rate_captial_obj->getHistoryProductFieldObjs();//获取金额变更历史记录
         $this->htmltable.=$this->table_content_header;
         $this->hide_htmltable.=$this->Hide_table_content_header;
         
      
        foreach($this->dividendorder_dates as $startdate=>$enddate)
        {
            $this->old_dividend_money=0;
            $this->adjustment=0;
            $this->total_dividendorder_rate=0;
            $this->total_dividendorder_money=0;
            
            if($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]&&$this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getEndDate()==$enddate)
            {
                if($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getStatus()==DIVIDEND_STATUS)
                {
                    //已派
                     $dividendfieldobj=new DividendField();
                    $dividendfieldobj->setStartDate($startdate);
                    $enddate=$this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getEndDate();
                    $principal=$this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getPrincipal();
                    $dividendfieldobj->setEndDate($enddate);
                    $dividendfieldobj->setDays($this->getDiffDays($startdate,$enddate));
                    $dividendfieldobj->setRate_senddate($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getRate_senddate());
                    $dividendfieldobj->setPrincipal($principal);
                    $dividendfieldobj->setRate_money($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getRate_money());
                    $dividendfieldobj->setFloat_income($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getFloat_income());
                    $dividendfieldobj->setAdjustment($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getAdjustment());
                    $dividendfieldobj->setDividend_money($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getDividend_money());
                    $dividendfieldobj->setOld_Dividend_money($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getDividend_money());
                    $dividendfieldobj->setId($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getId());
                    
                   if($this->current_row_index==$this->dividendorder_loopcount)
                    {
                         $this->htmltable.=$this->createTableContent($dividendfieldobj,'yes','yes');
                         $this->hide_htmltable.=$this->createHideTableDetail($dividendfieldobj,'yes','yes');
                    }
                    else
                    {
                        $this->htmltable.=$this->createTableContent($dividendfieldobj,'no','yes');
                        $this->hide_htmltable.=$this->createHideTableDetail($dividendfieldobj,'no','yes');
                    }
                    continue;
                }
                $this->old_dividend_money=$this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getDividend_money();
                $this->adjustment=$this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getAdjustment();
            }
          //创建有金额变动的隐藏表格
            $this->createHide_HtmlBuyHistory($startdate,$enddate);
            $last_invest="no";
           
            if($this->current_row_index==$this->dividendorder_loopcount)
            {
                $last_invest="yes";
            }
            if(sizeof($this->rate_captial_obj->getHistoryMoney_array($startdate,$enddate))<=0)
            {
               
                    $this->createHideDividendOrder_lasthtml($startdate,$enddate,$last_invest);
            }
            else if($last_invest=="yes")//如果是最后一期投资
            {
                $this->total_dividendorder_money+=$this->Investment_Amount;
                if($this->float_income=='all')
                {
                    $this->total_dividendorder_money+=$this->float_income_money;
                }
               
            }
            $this->createShow_DividendOrderObj($startdate,$enddate,$last_invest);
            
        }
       
        $this->htmltable.='</table></div>';
        $this->hide_htmltable.='</table></div>';
    }
    /**
     * 显示主表格
     * 
     * */
    private function createShow_DividendOrderObj($startdate,$enddate,$last_invest)
    {
        global $adb;
        $currency_obj=new Currency($adb,$this->currency_id);
        $dividendfieldobj=new DividendField();
        $dividendfieldobj->setStartDate($startdate);
        $dividendfieldobj->setEndDate($enddate);
        $dividendfieldobj->setDays($this->getDiffDays($startdate,$enddate));
        $dividendfieldobj->setRate_senddate($this->getRate_SendDate($this->current_row_index));
        $currencyid=$this->rate_captial_obj->getPrev_Princial_Amount($enddate)->currencyid;
        $after_total=$this->rate_captial_obj->getPrev_Princial_Amount($enddate)->after_total;
        if(!empty($currencyid)&&$this->currency_id!=$currencyid)
        {
            $change_currency_obj=new Currency($adb,$currencyid);
            $after_total=$currency_obj->ConvertTothisobj_money($change_currency_obj,$after_total);
        }
        $dividendfieldobj->setPrincipal($after_total);
         $dividendfieldobj->setFloat_income("");
         
        if($this->current_row_index==$this->dividendorder_loopcount)
        {
            //最后一期
             if($this->float_income=='all')
                $dividendfieldobj->setFloat_income($this->float_income_money);
             $dividendfieldobj->setPrincipal($this->Investment_Amount);
        }
        $dividendfieldobj->setRate_money($this->total_dividendorder_rate);
        
       
        $dividendfieldobj->setAdjustment($this->adjustment);
        $dividendfieldobj->setDividend_money($this->total_dividendorder_money+$this->adjustment);
        $dividendfieldobj->setStatus(DIVIDEND_STATUS_NO);
        $dividendfieldobj->setOld_Dividend_money($this->old_dividend_money);
        $this->htmltable.=$this->createTableContent($dividendfieldobj,$last_invest,"no");
        
    }
    private function createHideDividendOrder_lasthtml($startdate,$enddate,$last_invest)
    {
          $dividendfieldobj=new DividendField();
          $dividendfieldobj->setStartDate($startdate);
          $dividendfieldobj->setEndDate($enddate);
          $dividendfieldobj->setDays($this->getDiffDays($startdate,$enddate));
          $dividendfieldobj->setRate_senddate($this->getRate_SendDate($this->current_row_index));
          $capital=$this->rate_captial_obj->getPrev_Princial_Amount($startdate)->after_total;
          
          $dividendfieldobj->setPrincipal($capital);
          $dividendfieldobj->setRate_money($this->getRateMoney($capital,$this->getDiffDays($startdate,$enddate),$dividendfieldobj));
          $rate_money=$dividendfieldobj->getRate_money();
           $dividendmoney=$rate_money;
           $this->total_dividendorder_rate+=$dividendfieldobj->getRate_money();
           $this->total_dividendorder_money+=$rate_money;
            
          if($last_invest=='yes')//最后一期
          {
            $dividendmoney+=$this->Investment_Amount;
            $this->total_dividendorder_money+=$this->Investment_Amount;
            
            if($this->float_income=='all')
            {
                 $this->total_dividendorder_money+=$this->float_income_money;
                 $dividendfieldobj->setFloat_income($this->float_income_money);
                 $dividendmoney+=$this->float_income_money;
            }
            
                
          }
        
          $dividendfieldobj->setDividend_money($dividendmoney);
          $dividendfieldobj->setAdjustment("");
          if($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate])
          {
            $dividendfieldobj->setId($this->rate_captial_obj->dividendOrderObjs_dataBase[$startdate]->getId());
          }
          else
            $dividendfieldobj->setId(0);
        $this->hide_htmltable .=$this->createHideTableDetail($dividendfieldobj,$last_invest,"no");
    }
    public function getRate_SendDate($time_once)
    {
        
    }
   private function createHide_HtmlBuyHistory($start_Date,$enddate)
    {
         global $adb;
       
         $historyfieldobj_array=$this->rate_captial_obj->getHistoryMoney_array($start_Date,$enddate);
         $currency_obj=new Currency($adb,$this->currency_id);
         foreach($historyfieldobj_array as $startdate=>$info)
         {             
                    $dividendfieldobj=new DividendField();
                    $dividendfieldobj->setStartDate($startdate);
                    $enddate=$info['enddate'];
                   $dividendfieldobj->setEndDate($enddate);
                   $diffdays= $this->getDiffDays($startdate,$enddate);
                   $dividendfieldobj->setDays($diffdays);
                  
                   $dividendfieldobj->setRate_senddate($this->getRate_SendDate($this->current_row_index));
                   
                   $captial=$info['after_total'];
                  
                  if($info['currencyid']>0&&$info['currencyid']!=$this->currency_id)
                  {
                        $change_currency_obj=new Currency($adb,$info['currencyid']);
                        
                        $captial=$currency_obj->ConvertTothisobj_money($change_currency_obj,$captial);
                        
                  }
                 
                   $dividendfieldobj->setPrincipal($captial);
                   $rate_money=$this->getRateMoney($captial,$diffdays,$dividendfieldobj);
                   $dividendfieldobj->setRate_money($rate_money);
                   $this->total_dividendorder_rate+=$rate_money;
                   $this->total_dividendorder_money+=$rate_money;
                   $dividend_money=$rate_money;
                   $dividendfieldobj->setDividend_money($dividend_money);
                   $dividendfieldobj->setAdjustment("");
                   $this->hide_htmltable.=$this->createHideTableDetail($dividendfieldobj,$last_invenst,"no");
                   
         }
         
    }
    public  function getdividendFieldObj($startdate,$enddate,$rate_days,$rate_senddate,$prinical,$rate_money,$float_income_money,$adjusctment,$dividend_money,$old_dividend_money)
    {
        
        $dividendfieldobj=new DividendField();
        $dividendfieldobj->setStartDate($startdate);//开始日期
                               
        $dividendfieldobj->setEndDate($enddate);//结束日期
        $dividendfieldobj->setDays($rate_days);//计息天数
        ////利息发放日
        $dividendfieldobj->setRate_senddate($rate_senddate);//利息发放日
        //本金
        $dividendfieldobj->setPrincipal($prinical);//本金
        //利息
        $dividendfieldobj->setRate_money($rate_money);//利息
        //浮动收益  
        $dividendfieldobj->setFloat_income($float_income_money);
        //调整
        $dividendfieldobj->setAdjustment($adjusctment);//调整
       
        //派息金额
        $dividendfieldobj->setDividend_money($dividend_money);//派息金额
        return $dividendfieldobj;
    }
    
     /**
    * $last_invenst:投资的最后一期
    * $status：派息状态
    * */
   public  function  createTableContent($dividendfieldobj,$last_invenst='no', $status='no')
   {
         $row_index=$this->current_row_index;
         $existDividendOrder=$this->isExistHaveDividendOrder;
         $tdwidth=$this->rate_captial_obj->getTableWith();
         $font_color="";
        if($existDividendOrder=='yes'&&round($dividendfieldobj->getOld_Dividend_money(),2)!=round($dividendfieldobj->getDividend_money(),2))
        {
                $font_color=" style='color:red' ";
                $title=" title='".getFixedLabel('DIVIDENDMONEYCHANGESAVE')."'";
        }
          $htmlcontent=" <tr>";
          $htmlcontent.="<td $font_color width='".$tdwidth['sequence']."'>".$row_index."</td>";
            $htmlcontent.=" <td $font_color width='".$tdwidth['startdate']."'$title><input type='hidden' value='".$dividendfieldobj->getStartDate()."' name='".$this->rate_captial_obj->startdate_bol.$row_index."'/>".$dividendfieldobj->getStartDate()."</td>";//开始日期
            $htmlcontent.=" <td $font_color width='".$tdwidth['enddate']."'$title><input type='hidden' value='".$dividendfieldobj->getEndDate()."' name='".$this->rate_captial_obj->enddate_bol.$row_index."'/>".$dividendfieldobj->getEndDate()."</td>";//结束日期
          
            $htmlcontent.=" <td  $font_color width='".$tdwidth['days']."'$title><input type='hidden' value='".$dividendfieldobj->getDays()."' name='".$this->rate_captial_obj->rate_days_bol.$row_index."'/>".$dividendfieldobj->getDays()."</td>";//计息天数
            //利息发放日
            $htmlcontent.=" <td $font_color  width='".$tdwidth['rate_senddate']."'$title><input type='hidden' value='".$dividendfieldobj->getRate_senddate()."' name='".$this->rate_captial_obj->rate_sendday_bol.$row_index."' id='".$this->rate_captial_obj->rate_sendday_bol.$row_index."'/><span>".$dividendfieldobj->getRate_senddate()."</span></td>";//利息发放日
            //本金
            $htmlcontent.=" <td $font_color width='".$tdwidth['capital']."'$title><input type='hidden' value='".$dividendfieldobj->getPrincipal()."' name='".$this->rate_captial_obj->investment_amount_bol.$row_index."'/>".setNumberFormat($dividendfieldobj->getPrincipal(),2)."</td>";//本金
            //利息
            $htmlcontent.=" <td $font_color width='".$tdwidth['rate']."'$title><input type='hidden' id='".$this->rate_captial_obj->rate_hidden_money_bol.$row_index."' name='rate_hidden_money_".$row_index."' value='".$dividendfieldobj->getRate_money()."' />".setNumberFormat($dividendfieldobj->getRate_money())."</td>";//利息
            //浮动收益
            if($last_invenst=="yes")
            {
                
                if(strtolower($this->float_income)=="all")
                    $htmlcontent.=" <td $font_color width='".$tdwidth['float_income']."'$title  tag='float_income_td'><input type='hidden' value='".$dividendfieldobj->getFloat_income()."' name='".$this->float_income_bol.$row_index."' id='".$this->rate_captial_obj->float_income_bol.$row_index."'/>".setNumberFormat($dividendfieldobj->getFloat_income())."</td>";//浮动收益
                else
                    $htmlcontent.=" <td   width='0'$title tag='float_income_td' style='display:none'><input type='hidden' value='".$dividendfieldobj->getFloat_income()."' name='".$this->float_income_bol.$row_index."' id='".$this->rate_captial_obj->float_income_bol.$row_index."'/>".setNumberFormat($dividendfieldobj->getFloat_income())."</td>";//浮动收益
            }
            else
            {
                 if(strtolower($this->float_income)=="all")
                 {
                    $htmlcontent.=" <td $font_color  $title width='".$tdwidth['float_income']."'  tag='float_income_td'><input type='hidden'  name='".$this->rate_captial_obj->float_income_bol.$row_index."' id='".$this->rate_captial_obj->float_income_bol.$row_index."'/></td>";//浮动收益
                 }
                 else
                    $htmlcontent.=" <td  $title width='0' tag='float_income_td' style='display:none'><input type='hidden'  name='".$this->rate_captial_obj->float_income_bol.$row_index."' id='".$this->float_income_bol.$row_index."'/></td>";//浮动收益
            }  
                    
            //调整
           if($status=='no')//已经派息的单据调整不允许录入
             $htmlcontent.=" <td $font_color $title width='".$tdwidth['adjustment']."'><input  $font_color type='text' size='9' id='".$this->rate_captial_obj->txt_row_bol.$row_index."' value='".round($dividendfieldobj->getAdjustment(),2)."' txt_row='".$row_index."' name='".$this->rate_captial_obj->txt_row_bol.$row_index."' onchange='fun_Dividend.getInstance().adjustment(this)' /></td>";//调整
           else
              $htmlcontent.=" <td $font_color $title width='".$tdwidth['adjustment']."'><input  $font_color type='hidden' size='9' id='".$this->rate_captial_obj->txt_row_bol.$row_index."' value='".round($dividendfieldobj->getAdjustment(),2)."' txt_row='".$row_index."' name='".$this->rate_captial_obj->txt_row_bol.$row_index."'/>".round($dividendfieldobj->getAdjustment(),2)."</td>";//调整
              
             if($existDividendOrder=='yes')
             {
                 if(round($dividendfieldobj->getOld_Dividend_money(),2)!=round($dividendfieldobj->getDividend_money(),2))
                   {
                            ////派息金额(新)
                            $htmlcontent.=" <td width='".$tdwidth['dividendmoney']."' $title $font_color tag='yes_dividend'><input type='hidden' value='".$dividendfieldobj->getDividend_money()."' name='".$this->rate_captial_obj->dividend_money_bol.$row_index."' id='".$this->rate_captial_obj->dividend_money_bol.$row_index."'/> <span id='span_dividend_money_".$row_index."'>".setNumberFormat($dividendfieldobj->getDividend_money())." </span></td>";
                            ////派息金额(旧)
                            $htmlcontent.=" <td  width='".$tdwidth['olddividendmoney']."' $title $font_color tag='yes_dividend'><span>".setNumberFormat($dividendfieldobj->getOld_Dividend_money())." </span></td>";
                    }
                    else
                    {
                        ////派息金额(新)
                         $htmlcontent.=" <td width='".$tdwidth['dividendmoney']."' $title tag='yes_dividend'><input type='hidden' value='".$dividendfieldobj->getDividend_money()."' name='".$this->rate_captial_obj->dividend_money_bol.$row_index."' id='".$this->rate_captial_obj->dividend_money_bol.$row_index."'/> <span id='span_dividend_money_".$row_index."'>".setNumberFormat($dividendfieldobj->getDividend_money())." </span></td>";
                         ////派息金额(旧)
                         $htmlcontent.=" <td width='".$tdwidth['olddividendmoney']."' $title tag='yes_dividend'>".setNumberFormat($dividendfieldobj->getDividend_money())." </span></td>";
                     }
             } 
             else   
                  $htmlcontent.=" <td $font_color $title width='".$tdwidth['dividendmoney']."' $title><input type='hidden' value='".$dividendfieldobj->getDividend_money()."' name='".$this->rate_captial_obj->dividend_money_bol.$row_index."' id='".$this->rate_captial_obj->dividend_money_bol.$row_index."'/><span id='span_dividend_money_".$row_index."'>".setNumberFormat($dividendfieldobj->getDividend_money())." </span></td>";//派息金额  
            //状态
         
            if($status=='no')
                $htmlcontent.=" <td $font_color $title width='".$tdwidth['status']."'><input type='hidden'   name='hidden_dividend_status_".$row_index."' value='no'/>".DIVIDEND_STATUS_NO."</td>";//状态
            else
                $htmlcontent.=" <td $font_color $title width='".$tdwidth['status']."'><input type='hidden'   name='hidden_dividend_status_".$row_index."' value='yes'/>".DIVIDEND_STATUS."</td>";//状态
                
         
           if($this->rate_captial_obj->Multi_DividendOrder_Detail=="yes")
           {
                if($this->rate_captial_obj->tr_Multi_DividendOrder_detail=='yes')
                     $htmlcontent.="<td  wdith='".$tdwidth['operation']."'><a class='Anu3_a' href='javascript:void(0);' style='line-height:normal;' href='#' onclick='fun_Dividend.getInstance().showDividendOrderDetail(\"".$dividendfieldobj->getRate_senddate()."\",\"".$dividendfieldobj->getStartDate()."\",\"".$dividendfieldobj->getEndDate()."\")'>".getFixedLabel('VIEW')."</a></td>";
                else
                     $htmlcontent.="<td  wdith='".$tdwidth['operation']."'></td>";

           }
            $htmlcontent.=" </tr>";
             //必须重新定义对象赋值(can))会影响查看按钮(因为对象之间是地址引用)
            $dividendfieldobj_show=new DividendField();
            $dividendfieldobj_show->setStartDate($dividendfieldobj->getStartDate());
            $dividendfieldobj_show->setEndDate($dividendfieldobj->getEndDate());
            $dividendfieldobj_show->setDays($dividendfieldobj->getDays());
            $dividendfieldobj_show->setRate_senddate($dividendfieldobj->getRate_senddate());
            $dividendfieldobj_show->setPrincipal(($dividendfieldobj->getPrincipal()));
            $dividendfieldobj_show->setRate_money(($dividendfieldobj->getRate_money()));
            $dividendfieldobj_show->setFloat_income(($dividendfieldobj->getFloat_income()));
            $dividendfieldobj_show->setAdjustment(($dividendfieldobj->getAdjustment()));
            $dividendfieldobj_show->setDividend_money(($dividendfieldobj->getDividend_money()));
            $dividendfieldobj_show->setOld_Dividend_money($dividendfieldobj->getOld_Dividend_money());
            $dividendfieldobj_show->setStatus($status);
         
            
          $this->rate_captial_obj->show_dividendObjs[]=$dividendfieldobj_show;
          $this->current_row_index++;
         return $htmlcontent;
           
   }
   
   /**
    * 
    * 获取计息天数
    * */
   public function getDiffDays($startDate,$enddate) 
   {
        if($startdate>$enddate)
         {
            $tmp=$startdate;
            $startdate=$enddate;
            $enddate=$tmp;
         }
         $days=DateOperation::days_between_date($enddate,$startDate)+1;
         return $days;
   }
     /**
    * $last_invenst:投资的最后一期
    * $status：派息状态
    * */
   public  function  createHideTableDetail($dividendfieldobj,$last_invenst='no', $status='no')
   {
         $row_index=$this->hide_start_row_index;
         $existDividendOrder=$this->isExistHaveDividendOrder;
          $htmlcontent=" <tr>";
          $htmlcontent.="<td>".$row_index."</td>";
            $htmlcontent.=" <td><input type='hidden' value='".$dividendfieldobj->getStartDate()."' name='hidedetail_".$this->rate_captial_obj->startdate_bol.$row_index."'/>".$dividendfieldobj->getStartDate()."</td>";//开始日期
            $htmlcontent.=" <td><input type='hidden' value='".$dividendfieldobj->getEndDate()."' name='hidedetail_".$this->rate_captial_obj->enddate_bol.$row_index."'/>".$dividendfieldobj->getEndDate()."</td>";//结束日期
          
            $htmlcontent.=" <td ><input type='hidden' value='".$dividendfieldobj->getDays()."' name='hidedetail_".$this->rate_captial_obj->rate_days_bol.$row_index."'/>".$dividendfieldobj->getDays()."</td>";//计息天数
            //利息发放日
            $htmlcontent.=" <td><input type='hidden' value='".$dividendfieldobj->getRate_senddate()."' name='hidedetail_".$this->rate_captial_obj->rate_sendday_bol.$row_index."'/>".$dividendfieldobj->getRate_senddate()."</td>";//利息发放日
            //本金
            $htmlcontent.=" <td><input type='hidden' value='".$dividendfieldobj->getPrincipal()."' name='hidedetail_".$this->rate_captial_obj->investment_amount_bol.$row_index."'/></td>";//本金
            //利息
            $htmlcontent.=" <td width='85'><input type='hidden'  name='hidedetail_rate_hidden_money_".$row_index."' value='".$dividendfieldobj->getRate_money()."'/>".$dividendfieldobj->getRate_money()."</td>";//利息
            //浮动收益
            if($last_invenst=="yes")
            {
                if(strtolower($this->float_income)=="all")
                    $htmlcontent.=" <td><input type='hidden' value='".$dividendfieldobj->getFloat_income()."' name='hidedetail_".$this->rate_captial_obj->float_income_bol.$row_index."'/>".setNumberFormat($dividendfieldobj->getFloat_income())."</td>";//浮动收益
                else
                    $htmlcontent.=" <td  tag='float_income_td' style='display:none'><input type='hidden' value='".$dividendfieldobj->getFloat_income()."' name='hidedetail_".$this->rate_captial_obj->float_income_bol.$row_index."'/></td>";//浮动收益
            }
            else
            {
                 if(strtolower($this->float_income)=="all")
                 {
                    $htmlcontent.=" <td tag='float_income_td'><input type='hidden'  name='".$this->rate_captial_obj->float_income_bol.$row_index."'/></td>";//浮动收益
                 }
                 else
                    $htmlcontent.=" <td tag='float_income_td' style='display:none'><input type='hidden'  name='hidedetail_".$this->rate_captial_obj->float_income_bol.$row_index."'/></td>";//浮动收益
            }  
                    
            //调整
            $htmlcontent.=" <td width='63'><input type='text' size='8'  value='".round($dividendfieldobj->getAdjustment(),2)."'  name='hidedetail_".$this->rate_captial_obj->txt_row_bol.$row_index."' /></td>";//调整
             if($existDividendOrder=='yes')
             {
                 if(round($dividendfieldobj->getOld_Dividend_money(),2)!=round($dividendfieldobj->getDividend_money(),2))
                   {
                            ////派息金额(新)
                            $htmlcontent.=" <td  style='color:red' tag='yes_dividend'><input type='hidden' value='".$dividendfieldobj->getDividend_money()."' name='hidedetail_".$this->rate_captial_obj->dividend_money_bol.$row_index."'/> <span>".setNumberFormat($dividendfieldobj->getDividend_money())." </span></td>";
                            ////派息金额(旧)
                            $htmlcontent.=" <td  style='color:red' tag='yes_dividend'></td>";
                    }
                    else
                    {
                        ////派息金额(新)
                         $htmlcontent.=" <td  tag='hidedetail_yes_dividend'><input type='hidden' value='".$dividendfieldobj->getDividend_money()."' name='hidedetail_".$this->rate_captial_obj->dividend_money_bol.$row_index."'/></td>";
                         ////派息金额(旧)
                         $htmlcontent.=" <td  tag='hidedetail_yes_dividend'>".setNumberFormat($dividendfieldobj->getDividend_money())." </span></td>";
                     }
             } 
             else   
                  $htmlcontent.=" <td><input type='hidden' value='".$dividendfieldobj->getDividend_money()."' name='hidedetail_".$this->rate_captial_obj->dividend_money_bol.$row_index."'/></td>";//派息金额  
            //状态
           
            
            if($status=='no')
                $htmlcontent.=" <td><input type='hidden' name='hidedetail_hidden_dividend_status_".$row_index."' value='no'/>".DIVIDEND_STATUS_NO."</td>";//状态
            else
                $htmlcontent.=" <td><input type='hidden' name='hidedetail_hidden_dividend_status_".$row_index."' value='yes'/>".DIVIDEND_STATUS."</td>";//状态
        //   $this->rate_captial_obj->show_html_table[]=$htmlcontent;
           
            $htmlcontent.=" </tr>";
           // echo $dividendfieldobj->getStartDate().$dividendfieldobj->getPrincipal()."<br>";
            //必须重新定义对象赋值(can))会影响查看按钮
             
            $dividendfieldobj_hide=new DividendField();
            $dividendfieldobj_hide->setStartDate($dividendfieldobj->getStartDate());
            $dividendfieldobj_hide->setEndDate($dividendfieldobj->getEndDate());
            $dividendfieldobj_hide->setDays($dividendfieldobj->getDays());
            $dividendfieldobj_hide->setRate_senddate($dividendfieldobj->getRate_senddate());
            $dividendfieldobj_hide->setPrincipal(setNumberFormat($dividendfieldobj->getPrincipal()));
            $dividendfieldobj_hide->setRate_money(setNumberFormat($dividendfieldobj->getRate_money()));
            $dividendfieldobj_hide->setDividend_money(setNumberFormat($dividendfieldobj->getDividend_money()));
            $dividendfieldobj_hide->setStatus($status);
          
            $this->rate_captial_obj->hide_dividendObjs[]=$dividendfieldobj_hide;
            $this->hide_start_row_index++;
         return $htmlcontent;
           
   }
   /**
    * 利息计算公式
    * $captial：本金
    * $rate_days：利息计算天数
    * */
   protected function getRateMoney($capital,$rate_days,$dividendobj)
   {
        
        $rate_formula=strtolower($this->rate_captial_obj->dividend_rules['formulas']);
        
        $fixed_year_rate=$this->rate_captial_obj->salesorder_focus->column_fields['fixed_rate']/100;
        
        $rate_formula=str_replace('capital',$capital,$rate_formula);
        $rate_formula=str_replace('rate',$this->rate_captial_obj->salesorder_focus->column_fields['fixed_rate']/100,$rate_formula);
        preg_match('/(?i)((\s)*Days(\s)*-(\s)*1(\s)*)/',$rate_formula,$patterns);
        if(sizeof($patterns)>0)//一次性派息
        {
            $rate_formula=preg_replace('/(?i)((\s)*Days(\s)*-(\s)*1(\s)*)/',$rate_days,$rate_formula);
        }
        else
        {
            $rate_formula=str_replace('days',$rate_days,$rate_formula);
        }
        
        $rate_formula=str_replace('fullmonth30',$rate_days,$rate_formula);
        if($dividendobj)
        {
            //必须用enddate获取当月的实际天数，因为开始日期有月结算日期的概念
            $month_days=DateOperation::getMonthDays($dividendobj->getEndDate());
            $rate_formula=str_replace('acmonth',$month_days,$rate_formula);
            
        }
        
       
       $divideny=eval("return $rate_formula;");
       
        return $divideny;
   }
   
 
   
  
}




?>