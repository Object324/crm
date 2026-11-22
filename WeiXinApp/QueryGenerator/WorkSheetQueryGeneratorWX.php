<?php
crm_load_class_file('ProductQueryGeneratorWX','WeiXinApp/QueryGenerator');
class WorkSheetQueryGeneratorWX extends ProductQueryGeneratorWX
{
    public $query;
    public $searchcontentwhere;
	public function __construct($module, $user,$customerview='',$productDetails='') {
        parent::__construct($module, $user,$customerview,$productDetails);//gyq_122
        $this->createProductDetailsObj();
    }
   
    public function createProductDetailsObj()
    {
    
        crm_load_class_file("ProductDetailsWX",'WeiXinApp/WeiXin_CustomView');
         $this->productDetails=new ProductDetailsWX($this->module);
         
        $this->productDetails->querygenerator=$this;
    }
    //相关信息
    public function getRelatedQuery(){
        $related_query = '';
        if(!empty($_REQUEST['related_id'])&&!empty($_REQUEST['related_module'])&&!empty($_REQUEST['recordid'])){
            $focus=$this->moduleobj;
            $detailComFun = crm_load_class_obj('cls_DetailView_CommonFun', 'WeiXinApp/include');
            $related_info = $detailComFun->jsongetModuleRelatedDetails($_REQUEST['related_module'],$_REQUEST['recordid'],$_REQUEST['related_id']);
            //$related_query = $related_info['list_query'];
        }
        return $related_info;
    }
    public function getQuery($popup = '', $type = '')
    {
        if(!empty($_REQUEST['related_module'])){
            //editor:gyq_20180813 0034743: （珞落计划企业微信登录）市场活动相关创建销售机会保存时，市场活动相关销售机会列表界面不显示该单据
            unset(self::$_instance_queryGenerator[$this->module]);
           $relate_info = $this->getRelatedQuery();
           $this->whereFieldTables = $relate_info['whereFieldTables'];
           $this->whereFieldTableJoinType = $relate_info['whereFieldTableJoinType'];
       }
    
        $sql = parent::getQuery($popup, $type);
        
        if($type==1){
            if(!empty($this->searchcontentwhere))
                $sql.= ' and '.$this->searchcontentwhere;
            $sql .= $relate_info['list_query'];
            $sql .= $page_query_seaction;
        }
        return $sql;
    }
    
    public function getWhereClause() {
        $module = $this->module;
        $sql = parent::getWhereClause();
        if(isset($_SESSION['lvs'][$module]['worksheet_status']) && $_SESSION['lvs'][$module]['worksheet_status']!="" ){
            $worksheet_status = $_SESSION['lvs'][$module]['worksheet_status'];
            $status_arr = $this->moduleobj->worksheet_status;
            $keyword = $status_arr[$worksheet_status];
            $field_sql = $this->moduleobj->table_name.".".$this->moduleobj->status_columnname;
            if(!empty($keyword) && $worksheet_status!='all'){
                $sql .= " and ".$field_sql." = '".$worksheet_status."' ";
            }
        }

        return $sql;
    }

}


?>