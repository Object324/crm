<?php
class BusinessApply extends CRMEntity{
    var $table_name = "ld_businessapply";
	var $table_index= 'businessapplyid';//主表主键
    var $table_code='businessapply_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_businessapply','ld_businessapplyscf');
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_businessapply'=>'businessapplyid','ld_businessapplyscf'=>'businessapplyid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_businessapplyscf', 'businessapplyid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
	var $Detail_table="ld_businessapplydetail";//明细表名称
	var $Detail_table_id="lineitem_id";//明细表id
	var $Detail_table_scf = "ld_businessapplydetailscf";//明细scf表
    var $Detail_table_index="id";//明细表和主表关联的字段
    
	var $column_fields = Array();
	public  $module_name='BusinessApply';
 //和主表关联的模块
    var $relatedtab=array('businessapply'=>'','users'=>'','accounts'=>'','company'=>'');
	var $sortby_fields = Array('businessapply_no','smownerid');
    
	
	var $list_link_field= 'businessapply_no';

	var $search_fields = Array(
			'businessapply No'=>array('ld_businessapply'=>'businessapply_no')
			);

	var $search_fields_name = Array(
			'Account Name'=>'accountname',
		
			'Assigned To'=>'assigned_user_id',
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'accountname');

	//Default Fields for Email Templates -- Pavani
//	var $emailTemplate_defaultFields = array('accountname','account_type','industry','annualrevenue','phone','email1','rating','website','fax');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'businessapply_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'businessapply_no';
    var $popup_fields=Array();
    function __construct() {
		//$this->log =LoggerManager::getLogger('Expense');
		$this->db = PearDatabase::getInstance();
        $this->module_name='BusinessApply';
		 $this->fieldobj=Field::getInstance($this->module_name,$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      
             /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename($this->module_name);
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
        
      crm_load_class_file('TabDetailFields','include/TabDetailFields');
       $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
	}
  
   
    function  save_module($module) 
    {
	      crm_load_class_file('cls_save_moduledetail','data');
          $obj=new cls_save_moduledetail($this->module_name,$this->id);
          $obj->Savedetail();
	
                
    }
    
    
   	function unlinkRelationship($id, $return_module, $return_id)
    {
			$this->trash($this->module_name,$id);
		//}
    }
	
   
}
?>