<?php

class cls_countDistinctSql extends cls_ComputerSql
{
    public function __construct($detailviewobj)
     {
      
        parent::__construct($detailviewobj);
        $this->computerfun=' count';
        $this->computertext='唯一计数：';
        //$this->totalcompupterText=$this->computertext;
       
        $this->typevalue=$detailviewobj->distinctcount_type;
         $this->computertext=$detailviewobj->computerfunText_arr[$this->typevalue];
        $this->computercolumn_arr=$detailviewobj->distinctcountcolumn_arr;
        $this->totalcompupterText=$this->computertext;
        $this->isdistinct='yes';
     }
}

?>