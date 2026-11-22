<?php
//首页，销售机会
crm_load_class_file('clsTotal_List','include/ListView');
class cls_TotalList_KanBan extends clsTotal_List
{
    public $conditionQuery ='';
    public function __construct($controller)
    {
        parent::__construct($controller);
    }
    public function setallTotal_pageList_query($conditionQuery)
    {
        $this->conditionQuery = $conditionQuery;
    }
    public function getallTotal_pageList_query()
    {
        //拼装好的条件子查询sql 不带inner join 和on的
        return  $this->conditionQuery;
    }
    public function isusepagelistquery()
    {
        return 'yes';
    }
    public function getTotalFldCount($page_list_query,$result,$rows) {

        $totalhtml='';
        $thistotal=$this->getTotalColumnData($page_list_query,$result,$rows);
        $alltotal = $this->getAllTotalColumnData();

        if(is_array($thistotal))
        {

            $totalhtml.=$this->getTotalRow_html($thistotal,'cur');
            $totalhtml.=$this->getAllTotalRow_html($alltotal,'all');
        }
        return $totalhtml;
    }
}