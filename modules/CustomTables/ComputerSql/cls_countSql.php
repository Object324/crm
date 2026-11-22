<?php

class cls_countSql extends cls_ComputerSql
{
    public function __construct($detailviewobj)
     {
        parent::__construct($detailviewobj);
        $this->computerfun=' count';
        $this->computertext=getFixedLabel('COUNT').'：';
        $this->typevalue=$detailviewobj->count_type;
        $this->computertext=$detailviewobj->computerfunText_arr[$this->typevalue];
        $this->totalcompupterText=getFixedLabel('TotalCount').'：';
        $this->computercolumn_arr=$detailviewobj->countcolumn_arr;
     }
}


?>