<?php
crm_load_class_file('TabDetailQueryGenerator','include/QueryGenerator');
crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Report_TabDetailQueryGenerator  extends TabDetailQueryGenerator{
    public $scopeModule;
    public $page_list_query;
    public $dataRangehomeBoardobj;
    public function setScopeModule($scopeModule){
        $this->scopeModule = $scopeModule;
    }
    public function setSmOwnerSearchSql(){
        if($this->scopeModule!=$this->module){
            $this->getSmOwnerSearchSql =  '';//获取授权范围、共享、查看自己创建的单据的sql条件
            $this->smownerScope = '';
            $this->scope_sql = [];//授权范围SQL
        }
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
    public function getScopeOfAuthority_obj($db,$module){
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
}

?>