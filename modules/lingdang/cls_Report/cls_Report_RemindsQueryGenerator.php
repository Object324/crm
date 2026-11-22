<?php
crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
class cls_Report_RemindsQueryGenerator  extends RemindsQueryGenerator{
    public $scopeModule;
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
    //重写父类方法 getScopeOfAuthority_obj 获取公海页签的
    public function getScopeOfAuthority_obj($db,$module){
        $this->scopeobj = new cls_ScopOfAuthority($db,$module);
    }
    public function setParams($page_list_query){
        $this->page_list_query = $page_list_query;
    }
}

?>