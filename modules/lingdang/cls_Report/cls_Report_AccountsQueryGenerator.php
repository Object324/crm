<?php
crm_load_class_file('AccountsQueryGenerator','include/QueryGenerator');
crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
class cls_Report_AccountsQueryGenerator  extends AccountsQueryGenerator{
    public $scopeModule;
    public $page_list_query;
    public function __construct($module, $user,$customerview ,$productDetails,$scopeModule) {

        $this->scopeModule=$scopeModule;
        parent::__construct($module, $user,$customerview ,$productDetails);
            
    
    }
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
         if($this->scopeModule==$this->module){
            crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
            $cls_PublicAccounts = new cls_PublicAccounts($module);
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
            $this->scopeobj = new UnAssignedAccountsAuthority('ALLACCOUNT',$public_account);
        }
        
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