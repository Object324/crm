<?php



class cls_maxSql extends cls_ComputerSql
{
     public function __construct($detailviewobj)
     {
        parent::__construct($detailviewobj);
        $this->computerfun=' max';
        $this->computertext='最大值：';
        $this->typevalue=$detailviewobj->max_type;
        $this->computertext=$detailviewobj->computerfunText_arr['max'];
        $this->totalcompupterText=$this->computertext;
        $this->computercolumn_arr=$detailviewobj->maxcolumn_arr;
     }
}

?>