<?php
crm_load_class_file('ProductQueryGenerator','include/QueryGenerator');
crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
class cls_Report_ProductQueryGenerator  extends ProductQueryGenerator{

    public $scopeModule;
    public $page_list_query;
    private $dataRangehomeBoardobj;
    public function setScopeModule($scopeModule){
        $this->scopeModule = $scopeModule;
    }
    public function setDataRangeHomeBoardObj($dataRangeHomeBoardobj)
    {
        $this->dataRangehomeBoardobj=$dataRangeHomeBoardobj;

    }
    public function getTotalGroupBy()
    {
        if($this->dataRangehomeBoardobj)
        {
            return    $this->dataRangehomeBoardobj->getTotalGroupBy();
        }
        else
            return  $this->moduleobj->table_name.'.'.$this->moduleobj->table_index;

    }
    public function setSmOwnerSearchSql(){
        if($this->scopeModule!=$this->module){
            $this->getSmOwnerSearchSql =  '';//获取授权范围、共享、查看自己创建的单据的sql条件
            $this->smownerScope = '';
            $this->scope_sql = [];//授权范围SQL

        }
    }
    public function getScopeOfAuthority_obj($db,$module)
    {
        $this->scopeobj = new cls_ScopOfAuthority($db,$module);
    }
    public function setParams($page_list_query){
        $this->page_list_query = $page_list_query;
    }
    public function getQueryRow_Count($popuptype='',$type='1')
    {
        $basetablename=$this->moduleobj->table_name;
        $basettableindex=$this->moduleobj->table_index;
        $page_list_query = $this->page_list_query;
        $pos=stripos($page_list_query,'from');
        if($type==1)
        {
            $page_list_query="select count(distinct $basetablename.$basettableindex)  as countrow ".substr($page_list_query,$pos);
        }
        else
        {
            $page_list_query="select ( $basetablename.$basettableindex)    ".substr($page_list_query,$pos);
            $page_list_query="select count($basettableindex) as countrow from ($page_list_query) as tmpsum ";
        }

        return $page_list_query;
    }
    public function getFromProductTable(){
        $producttable=parent::getFromProductTable();
        $ld_inventoryproductrel=$this->moduleobj->Detail_table;
        if(sizeof($this->ProductTableColumn)>0||sizeof($this->whereProductTable)>0)
        {
            
        }
        else{
            unset($producttable[$ld_inventoryproductrel]);

        }
        return $producttable;



    }
}

?>