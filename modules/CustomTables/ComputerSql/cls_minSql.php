<?php

class cls_minSql extends cls_ComputerSql
{
    public function __construct($detailviewobj)
     {
        parent::__construct($detailviewobj);
        $this->computerfun=' min';
        $this->computertext='最小值：';
        $this->typevalue=$detailviewobj->min_type;
        $this->computertext=$detailviewobj->computerfunText_arr[$this->typevalue];
        $this->totalcompupterText=$this->computertext;
        $this->computercolumn_arr=$detailviewobj->mincolumn_arr;
     }
}

?>