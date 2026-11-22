<?php
crm_load_class_file("ReportTableCustomView",'modules/CustomTables/Query');

class ReportTableWhere
{
    public $module;
    public $querygeneratoryobj;
    public $groupid;
    public $wherecolumn;
    public $comparator;
    public $searchtext;
    public $advfilter_arr;
    public $advfiltergroup_arr;
    public function __construct($module)
    {
        global $current_user;
        $this->module=$module;
        $this->advfilter_arr=[];
        $this->advfiltergroup_arr=[];
        
        $customview=new ReportTableCustomView($module);
        if(get_file_address($module,$module.'DetailFieldsHtml'))
        {
            crm_load_class_file("ReportTabDetailView",'modules/CustomTables/Query');
            $productview=new ReportTabDetailView($module);
        }
        else
        {
             crm_load_class_file("ReportTableProductView",'modules/CustomTables/Query');
                $productview=new ReportTableProductView($module);
        }
        $this->querygeneratoryobj=QueryGenerator::getInstance($module, $current_user,$customview,$productview,'no');
        
        $this->querygeneratoryobj->reset();
    }
    
    public function setGroupid($groupid)
    {
        $this->groupid=$groupid;
        $this->getAdvFilter_arr();
    }
    public function setWhereColumn($wherecolumn)
    {
        $this->wherecolumn=$wherecolumn;
        $this->getAdvFilter_arr();
    }
    public function setComparator($comparator)
    {
        $this->comparator=$comparator;
        $this->getAdvFilter_arr();
        
    }
    public function setSearchText($searchtext)
    {
        $this->searchtext=$searchtext;
        $this->getAdvFilter_arr();
        
    }
    public function setcolumncondition($columncondition)
    {
        $this->columncondition=$columncondition;
        $this->getAdvFilter_arr();
    }
    
    public function getAdvFilter_arr()
    {
        $this->advfilter_arr[0]['groupid']=0;
        $this->advfilter_arr[0]['columnname']=$this->wherecolumn;
        $this->advfilter_arr[0]['comparator']=$this->comparator;
        $this->advfilter_arr[0]['value']=$this->searchtext;
        $this->advfilter_arr[0]['columncondition']='';
       $this->advfiltergroup_arr=array(null,null,array("groupcondition"=>""));
        
    }
    public function setcvadvFilter_arr()
    {
        
    }
    
    public function getWhere(){
        $input=[];
      
        $input['advft_criteria']=ldcrm_json_encode($this->advfilter_arr);
        $input['advft_criteria_groups']=ldcrm_json_encode($this->advfiltergroup_arr);
        $input['searchtype']='advance';
       
        $this->querygeneratoryobj->addUserSearchConditions($input);
        $this->querygeneratoryobj->wheretablePrefix=$this->module;
       $this->querygeneratoryobj->groupInfo='(0)';
       $this->querygeneratoryobj->getWhereClause();
       $where=$this->querygeneratoryobj->wherecondition;
   
        //括号带空格的 去除括号的时候没有去除成功
//        $where=trim($where,')');
//       $where =trim($where,'(');
       return $where;
       //dump($this->querygeneratoryobj->whereMainTable);
       
       //$this->querygeneratoryobj->whereDetailTable;
       // dump($where);
    }
}

?>