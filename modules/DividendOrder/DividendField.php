<?php

class DividendField
{
    public  $id;
    public $startdate;
    public $enddate;
    public $dividendorderid;
    public $days;
    public $rate_senddate;
    public $float_income;
    public $adjustment;
    public $rate_money;//利息
    public $principal;//本金
    public $dividend_money;//派息金额(新)
    public $old_dividend_money;
    public $status;
    
    public function setStatus($status)
    {
        $this->status=$status;
    }
    public function getStatus()
    {
        return $this->status;
    }
   
    public function setOld_Dividend_money($old_dividend_money)
    {
        $this->old_dividend_money=$old_dividend_money;
    }
    public function getOld_Dividend_money()
    {
        return $this->old_dividend_money;
    }
    
    public function setDividend_money($dividend_money)
    {
        $this->dividend_money=$dividend_money;
    }
    public function getDividend_money()
    {
        return $this->dividend_money;
    }
    public function setId($id)
    {
        $this->id=$id;
    }
    
    public function setStartDate($startdate)
    {
        $this->startdate=$startdate;
    }
    public function setEndDate($enddate)
    {
        $this->enddate=$enddate;
    }
    
    public function setDividendOrderId($diviendorderid)
    {
        $this->dividendorderid=$diviendorderid;
    }
    public function setDays($days)
    {
        $this->days=$days;
    }
    public function setRate_senddate($rate_senddate)
    {
        $this->rate_senddate=$rate_senddate;
    }
    
    public function setFloat_income($float_income)
    {
        $this->float_income=$float_income;
    }
    public function setAdjustment($adjustment)
    {
        $this->adjustment=$adjustment;
    }
    /**
     * 派息金额
     * */
    public function setRate_money($rate_money)
    {
        $this->rate_money=$rate_money;
    }
    /**
     * 本金
     * */
    public function setPrincipal($principal)
    {
        $this->principal=$principal;
    }
    
    
     public function getId()
    {
        return $this->id;
    }
    
    public function getStartDate()
    {
        return $this->startdate;
    }
    public function getEndDate()
    {
       return  $this->enddate;
    }
    
    public function getDividendOrderId()
    {
        return $this->dividendorderid;
    }
    public function getDays()
    {
       return  $this->days;
    }
    public function getRate_senddate()
    {
        return $this->rate_senddate;
    }
    
    public function getFloat_income()
    {
        return $this->float_income;
    }
    public function getAdjustment()
    {
       return  $this->adjustment;
    }
    
    public function getRate_money()
    {
        return $this->rate_money;
    }
    
    public function getPrincipal()
    {
        return $this->principal;
    }
}


?>