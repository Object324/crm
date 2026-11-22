<?php

/**
 * 
 * 指定派息日期
 * */
class Formula_designated extends Formula_base
{
    var $Invest_Amount;
    var $invest_enddate;
    var $rate_senddates=array();
    var $total_dividendorder_rate;
    var $total_dividendorder_money;
    var $buy_result;
    function Formula_designated($rate_type_obj)
    {
        $this->rate_captial_obj=$rate_type_obj;
       
        $this->rate_senddates=explode('$##$',$this->rate_captial_obj->dividend_rules['grantdate_designated']);
        $this->rate_senddates=array_filter($this->rate_senddates);//过滤空格
        $this->rate_senddates=implode(",",$this->rate_senddates);
        $this->rate_senddates=explode(",",$this->rate_senddates);//重组数组
        
        
    }
    function special_Fun()
    {
    
        $this->float_income='none';
      
        $this->hide_start_row_index=1;//表格行标示
        $this->current_row_index=1;//序号 
    }
    public function getDividendOrderDates()
    {
        
        sort($this->rate_senddates);
       $rate_senddates=$this->rate_senddates;
        $k=0;
        foreach($rate_senddates as $date)
        {
             
            if($date>$this->invest_enddate)//剔除大于投资到期日期的利息发放日
            {
                array_slice($rate_senddates,0,$k);
                break;
            }
            $k++;
        }
       
        if(!in_array($this->init_start_date,$rate_senddates))//添加开始计息日期
        {
            $one_zero[]=$this->init_start_date;
        }
       
        if(!in_array($this->invest_enddate,$rate_senddates))//添加投资到期日期
        {
            $rate_senddates[]=$this->invest_enddate;
        }
        $rate_senddates=array_merge($one_zero,$rate_senddates);
        $this->dividendorder_loopcount=sizeof($rate_senddates)-1;
        $this->dividendorder_row_count=$this->dividendorder_loopcount;
        $this->rate_senddates=$rate_senddates;
        
        for($i=0;$i<sizeof($rate_senddates)-1;$i++)
        {
            $startdate=$rate_senddates[$i];
            if($i>0)
            {
                $startdate=DateOperation::addDays($startdate,"1");
            }
            $enddate=$rate_senddates[$i+1];
            $this->dividendorder_dates[$startdate]=$enddate;
        }
        
    }
    
    public function getRate_SendDate($time_once)
    {
        return $this->rate_senddates[$time_once];
    }
}


?>