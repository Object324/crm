<?php
/**
 * 一次性派息
 * */
class Formula_oneoff extends Formula_base
{
     var $init_start_date;//开始计息日期
     var $invest_enddate;//投资到期日
     var $total_dividend_money=0;
     var $total_dividend_rate=0;
     var $buy_result;
     
     
     function special_Fun()
    {
    
        $this->float_income='none';
      
        $this->dividendorder_loopcount=1;
        $this->dividendorder_row_count=1;
        $this->hide_start_row_index=1;//表格行标示
        $this->current_row_index=1;//序号 
    }
     public function getDividendOrderDates()
    {
    
             $this->dividendorder_dates[$this->init_start_date]=$this->invest_enddate;
        
    }
    
     /**
     * 获取利息发放日期
     * */
     public function getRate_SendDate($nowdate)
     {
         return $this->invest_enddate;
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
         $days=DateOperation::days_between_date($enddate,$startDate);
         return $days;
   }

}

?>