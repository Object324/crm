<?php


class cls_avgSql extends cls_ComputerSql
{
    public function __construct($detailviewobj)
    {
         parent::__construct($detailviewobj);
         $this->computerfun=' avg';
        
         
         $this->typevalue=$detailviewobj->avg_type;
         $this->computertext=$detailviewobj->computerfunText_arr[$this->typevalue];
         $this->totalcompupterText=$this->computertext;
         $this->computercolumn_arr=$detailviewobj->avgcolumn_arr;
    }
}


?>