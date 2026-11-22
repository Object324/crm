<?php

class cls_sumSql extends cls_ComputerSql
{
    
    
    public function __construct($detailviewobj)
    {
         parent::__construct($detailviewobj);
         $this->computerfun=' sum';
         $this->computertext='小计：';
         $this->typevalue='sumgroup';
         $this->computertext=$detailviewobj->computerfunText_arr[$this->typevalue];
         $this->totalcompupterText=getFixedLabel('TOTAL').'：';
         $this->computercolumn_arr=$detailviewobj->sumcolumn_arr;
    }
    
    
    
}


?>