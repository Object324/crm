<?php

/**
 * 按月派息
 * 
 * */
class Formula_monthly extends Formula_base
{
    
    private $deaddate_bol="32";//月末标示
    var $interval_month=1;
    function special_Fun()
    {
       if($this->rate_captial_obj->dividend_rules['float_switch']=='on')
       {
        $this->float_income='all';
       } 
        $loopcount=DateOperation::months_between_date($this->invest_enddate,$this->init_start_date)+1;
        $this->dividendorder_loopcount=$loopcount;
        $this->dividendorder_row_count=$this->dividendorder_loopcount;
         
        $this->hide_start_row_index=1;//表格行标示
        $this->current_row_index=1;//序号 
    }
    public function getDividendOrderDates()
    {
        for($i=0;$i<$this->dividendorder_loopcount;$i++)
        {
                  $add_year_month_day= DateOperation::addMonths($this->init_start_date,$i);
                  $add_year_month=date("Y-m",strtotime(DateOperation::addMonths($this->init_start_date,$i)));
                    
                 $days = DateOperation::getMonthDays($add_year_month_day);//获取月份的天数
                 if($i==0)
                 {
                    $startdate=$this->init_start_date;
                    $enddate=date("Y-m-d",strtotime($add_year_month.'-'.$days));//月末
                  
                        if($this->rate_captial_obj->dividend_rules['deadline']!=$this->deaddate_bol)
                        {
                            $enddate=date("Y-m-d",strtotime($add_year_month.'-'.$this->rate_captial_obj->dividend_rules['deadline']));//月末
                        }
                       $first_start_year_month=$add_year_month;//记录第一期(年月)
                       if($enddate<$startdate)
                       {
                            continue;
                       }
                    
                 }
                 else
                 {
                    $startdate=date("Y-m-d",strtotime($add_year_month.'-01'));//月初
                 
                    if($i==1)//没有派息(第二期)，添加这个判断的原因是因为已经派息也会调用该函数
                    {
                        //月结算截止日期
                        if($this->rate_captial_obj->dividend_rules['deadline']!=$this->deaddate_bol)
                        {
                            $deadline=$this->rate_captial_obj->dividend_rules['deadline']+1;
                            $startdate=date("Y-m-d",strtotime($first_start_year_month.'-'.$deadline));//第二期的开始日期
                            if($startdate<$this->init_start_date)
                            {
                                //021825: （金融账套）合同订单明细界面，进入【创建派息单】点击【派息规则】：更改“月结算截止日”保存后“计息起始日”更改
                                $startdate=$this->init_start_date;
                            }
                        }
                    }
                    
                    $enddate=date("Y-m-d",strtotime($add_year_month.'-'.$days));//月末
                 }
                 if($i==($this->dividendorder_loopcount-1))
                 {
                    $enddate=$this->invest_enddate;
                 }
            $this->dividendorder_dates[$startdate]=$enddate;
            
        }
    }
    
    
  
    public function getDiffDays($startdate,$enddate)
    {
         if($startdate>$enddate)
         {
            $tmp=$startdate;
            $startdate=$enddate;
            $enddate=$tmp;
         }
        $start_day=date("d",strtotime($startdate));
        $end_day=date("d",strtotime($enddate));
        $month_days=DateOperation::getMonthDays($startdate);
       
        if(($start_day=="1"||$start_day=="01")&&$end_day==$month_days&&stripos($this->rate_captial_obj->dividend_rules['formulas'],'Capital*Rate*FullMonth30/')!==false)
        {
            return "30";
        }
        else
        {
            return  parent::getDiffDays($startdate,$enddate);
        }
    }
   
   /**
     * 获取利息发放日期
     * */
     public function getRate_SendDate($time_once)
     {
        //修改原因：22414: （金融账套）产品派息规则：按月派息，设置“月结算截止日”为25日，结果：“利息发放日”显示错误。
        $time_once=$time_once-1;
        $start_date_keys=array_keys($this->dividendorder_dates);
        $start_date=$start_date_keys[$time_once];
        $end_date=$this->dividendorder_dates[$start_date];
        $end_date=date("Y-m",strtotime($end_date))."-01";
        
         switch($this->rate_captial_obj->dividend_rules['grantdate_switch'])
        {
            case "nextmonth":
                $rate_year_month=DateOperation::getNextMonth($end_date);
                
                break;
            case "thismonth":
                $rate_year_month=date("Y-m",strtotime($end_date));
                break;
        }
        
         if($this->rate_captial_obj->dividend_rules['grantdate']==32)//月末
        {
            
            $rate_date=date("Y-m",strtotime($rate_year_month)).'-'.DateOperation::getMonthDays($rate_year_month);
        }
        else
        {
              $rate_date=date("Y-m",strtotime($rate_year_month)).'-'.$this->rate_captial_obj->dividend_rules['grantdate'];
        }
         if($this->current_row_index==$this->dividendorder_loopcount)
        {
            //最后一期
            if($rate_date>$this->invest_enddate)
            {
                $rate_date=$this->invest_enddate;
            }
        }
        else if($rate_date>$this->invest_enddate)
        {
            $rate_date=$this->invest_enddate;
        }
        $rate_date=date("Y-m-d",strtotime($rate_date));
        return $rate_date;
       /* $init_date=date("Y-m",strtotime($this->init_start_date))."-01";
        
        $nowdate=DateOperation::addMonths($init_date,$time_once);
       
        switch($this->rate_captial_obj->dividend_rules['grantdate_switch'])
        {
            case "nextmonth":
                $rate_year_month=DateOperation::getNextMonth($nowdate);
                
                break;
            case "thismonth":
                $rate_year_month=$nowdate;
                break;
        }
       
        if($this->rate_captial_obj->dividend_rules['grantdate']==32)//月末
        {
            
            $rate_date=date("Y-m",strtotime($rate_year_month)).'-'.DateOperation::getMonthDays($rate_year_month);
        }
        else
        {
              $rate_date=date("Y-m",strtotime($rate_year_month)).'-'.$this->rate_captial_obj->dividend_rules['grantdate'];
        }
         if($this->current_row_index==$this->dividendorder_loopcount)
        {
            //最后一期
            if($rate_date>$this->invest_enddate)
            {
                $rate_date=$this->invest_enddate;
            }
        }
        else if($rate_date>$this->invest_enddate)
        {
            $rate_date=$this->invest_enddate;
        }
        $rate_date=date("Y-m-d",strtotime($rate_date));
        
        return $rate_date;*/
     }
   
}


?>