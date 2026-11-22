<?php
crm_load_class_file('cls_servicecharge_totalList','modules/ServiceCharge');
class cls_servicecharge_exporttotal extends cls_servicecharge_totalList
{
    public $page_list_query;
    public function getTotalCurPage_Sql($page_list_query)
    {
           $sql['main_sql']='';
           $sql['detail_sql']='';
           return $sql;
        
    }
    public function getallTotal_pageList_query()
    {
        return $this->page_list_query;
    }
    public function getTotalFldCount($page_list_query,$result,$rows) {
        $this->page_list_query=$page_list_query;
        $thistotal=$this->getTotalColumnData($page_list_query,$result,$rows);
        $formatvalues=$this->getFormatValue($thistotal['all']);//数字的格式化
       
        $listviewfields=$this->listviewcontroller->getListViewFields($this->queryGenerator->module);
       
        foreach($listviewfields as $key=>$fieldname)
        {
             $columnname=$this->listviewcontroller->getColumnName($key,$fieldname);
             $fldobj=$this->listviewcontroller->getListViewFieldobj($key,$fieldname);
             if(array_key_exists($columnname,$thistotal['all']))
             {
                if(empty($startkey))
                    $startkey=$key;
                if($fldobj->istotalFldMoneyField())
                    $total[$key]=$formatvalues[$columnname];
                else
                {
                     
                     $total[$key]=$formatvalues[$columnname];
                }
                    
             }
        }
        if($startkey)
            $total[$startkey-1]="∑ ".getFixedLabel('TOTALALL');
  
        return $total;
        
        
    }
     public function getTotalColumnData($page_list_query,$result,$rows)
     {
        //excel导出只求合计行
           

        return parent::getTotalColumnData($page_list_query,$result,100000000);
     }
}


?>