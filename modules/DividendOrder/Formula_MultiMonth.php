<?php

/**
 * 按季度派息
 * 半年派息
 * */
class Formula_MultiMonth extends Formula_base
{
    var $init_start_date;//开始计息日期
    var $buy_result;
    var $Investment_Amount;
    var $invest_enddate;
    var $total_dividend_money;
    var $total_dividend_rate;
    public function special_Fun()
    {
    
        $this->float_income='none';
     /// echo $this->invest_enddate."<br>";
      //echo $this->init_start_date;
     // echo DateOperation::months_between_date($this->invest_enddate,$this->init_start_date)/$this->interval_month;
       DateOperation::months_between_date($this->invest_enddate,$this->init_start_date);
         //获取计息日期到投资到期日的间隔的月份数
        $real_loopcount=DateOperation::months_between_date($this->invest_enddate,$this->init_start_date)/$this->interval_month;
        $loopcount=floor(DateOperation::months_between_date($this->invest_enddate,$this->init_start_date)/$this->interval_month);
       $end_days=DateOperation::getDay($this->invest_enddate);
      
       /**
        * 开始计息日期为月初，红利返回日期为月末，要添加一个月
        * */
        if(DateOperation::getDay($this->init_start_date)==1&&$end_days==DateOperation::getMonthDays($this->invest_enddate))
        {
            $loopcount+=1;
        }
  
      if($this->rate_captial_obj->dividend_rules['grantdate']==1)//计息起始日+{6/3*n月}
        {
            //26743: 派息单隔月派息算法修改
            if(DateOperation::addMonths($this->init_start_date,$this->interval_month*$loopcount)>DateOperation::addDays($this->invest_enddate,"3"))
            {
                $loopcount=$loopcount-1;
            }
        }
        else if($this->rate_captial_obj->dividend_rules['grantdate']==2)//计息起始日+{6/3*n月}-{1日}
        {
             if(DateOperation::addMonths($this->init_start_date,$this->interval_month*$loopcount)>DateOperation::addDays($this->invest_enddate,"1"))
            {
                $loopcount=$loopcount-1;
            }
             
        }
      
        
         $this->dividendorder_loopcount=$loopcount;
        $this->dividendorder_row_count=$this->dividendorder_loopcount;
        $this->hide_start_row_index=1;//表格行标示
        $this->current_row_index=1;//序号 
    }
     public function getDividendOrderDates()
    {
      
        for($i=0;$i<$this->dividendorder_loopcount;$i++)
        {
             $startdate=$this->getStartDate($i+1);
             $enddate=$this->getEnddate($i+1);
             if($enddate>$this->invest_enddate)
                $enddate=$this->invest_enddate;
             $this->dividendorder_dates[$startdate]=$enddate;
        }
    }
    static $formula_obj;
    public static function getInstance($rate_type_obj)
    {
        
         if($rate_type_obj->dividend_rules['formulamode']=='quarterly')
        {
           
            if(!class_exists('Formula_quarterly'))
            {
                require('modules/DividendOrder/Formula_quarterly.php');
            }
             Formula_MultiMonth::$formula_obj=new Formula_quarterly();
        }
        else if($rate_type_obj->dividend_rules['formulamode']=='semiannual')
        {
            if(!class_exists('Formula_semiannual'))
            {
                require('modules/DividendOrder/Formula_semiannual.php');
            }
            Formula_MultiMonth::$formula_obj=new Formula_semiannual();
        }
        else if($rate_type_obj->dividend_rules['formulamode']=='othermonth')
        {
            if(!class_exists('Formula_othermonth'))
            {
                require('modules/DividendOrder/Formula_othermonth.php');
            }
            Formula_MultiMonth::$formula_obj=new Formula_othermonth();
        }
        return Formula_MultiMonth::$formula_obj;
    }
  
    
    public function  getDividendDetail()
    {
        parent::getDividendDetail();
    }
    
     /**
     * 获取利息发放日期
     * */
     public function getRate_SendDate($time_once)
     {
       return $this->getEnddate($time_once);
     }
    /**
     * 获取结束日期
     * $time_once:表示次数
     * */
    public  function getEnddate($time_once)
    {
        $time_once=$time_once-1;
        if($this->rate_captial_obj->dividend_rules['grantdate']==1)//计息起始日+{3*n月}
        {
            $enddate=DateOperation::addMonths($this->init_start_date,($time_once+1)*$this->interval_month);
        }
        else if($this->rate_captial_obj->dividend_rules['grantdate']==2)//计息起始日+{3*n月}-{1日}
        {
             $enddate=DateOperation::addMonths($this->init_start_date,($time_once+1)*$this->interval_month);
             $enddate=DateOperation::addDays($enddate,"-1");
        }
        if(date("Y-m",strtotime($enddate))>date("Y-m",strtotime($this->invest_enddate)))
        {
            return $this->invest_enddate;
        }
        return $enddate;
    }
    /**
     * 获取开始日期
     * $time_once:表示次数
     * */
    public  function getStartDate($time_once)
    {
        $time_once=$time_once-1;
         if($time_once==0)
         {
            return $this->init_start_date;
         }
         if($this->rate_captial_obj->dividend_rules['grantdate']==1)//计息起始日+{6/3*n月}
        {
            $startdate=DateOperation::addMonths($this->init_start_date,($time_once)*$this->interval_month);
            $startdate=DateOperation::addDays($startdate,"1");
        }
        else if($this->rate_captial_obj->dividend_rules['grantdate']==2)//计息起始日+{6/3*n月}-{1日}
        {
             $startdate=DateOperation::addMonths($this->init_start_date,($time_once)*$this->interval_month);
             
        }
        return $startdate;
    }
    
  
   
}


?>