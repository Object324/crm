<?php
crm_load_class_file('QueryGenerator','include/QueryGenerator');
crm_load_class_file('cls_ScopOfAuthority','modules/lingdang/cls_Report');
class cls_Report_QueryGenerator  extends QueryGenerator{
    public $scopeModule;
    public $page_list_query;
    private $dataRangehomeBoardobj;

	public function __construct($module, $user,$customerview='',$productDetailsobj=''){
		parent::__construct($module, $user,$customerview,$productDetailsobj);
    }
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
	public function getLeftOrderBy($tableList){
		return '';
	}
    //重写父类方法 getScopeOfAuthority_obj 获取公海页签的
    public function getScopeOfAuthority_obj($db,$module){
        if($module=='Leads') {
            crm_load_class_file('UnAssigned'.$module.'Authority','include/ScopOfAuthority');
            crm_load_class_file('cls_Public'.$module, 'modules/'.$module);
            $cls_PublicAccounts = new cls_PublicLeads($module);
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
            $this->scopeobj = new UnAssignedLeadsAuthority('ALLACCOUNT',$public_account);
        }else{

            //edit:can 20230804 普通用户登录穿透列表没有数据
            $this->scopeobj = new cls_ScopOfAuthority($db,$module);
        }
    }
    public function setParams($page_list_query){
        $this->page_list_query = $page_list_query;
    }
    /**
     * @param $popuptype
     * @param $type
     * @param $page_list_query  //父类中这个sql是直接调用$queryGenerator->getQuery('','groupby');得到,我改成直接传参过来,因为这个方法在调用这个方法之前已经调过
     * @return string
     *重写父类方法  获取本页条数的方法
     */
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