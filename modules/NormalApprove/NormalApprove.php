<?php
class NormalApprove extends CRMEntity
{
    
   var $table_name = "ld_normalapprove";
	var $table_index= 'normalapproveid';
    var $table_code='normalapprove_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_normalapprove','ld_normalapprovescf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_normalapprove'=>'normalapproveid','ld_normalapprovescf'=>'normalapproveid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_normalapprovescf', 'normalapproveid');
    //	//关联模块
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','normalapprove'=>'','contacts'=>'');
	var $column_fields = Array();
     var $module_name='NormalApprove';
     var $moduleName='NormalApprove';
	//Pavani: Assign value to entity_table
        var $entity_table = "ld_crmentity";

	var $sortby_fields = Array();


	var $list_link_field= 'normalapprove_no';

    var $required_fields =  array();

	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime');
        var $default_order_by = 'normalapprove_no';
        var $default_sort_order = 'DESC';

	
	var $def_basicsearch_col = 'normalapprove_no';
	function __construct()
	{
	
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('NormalApprove',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      

        $entityname=getEntitynameByModulename('NormalApprove');
        $this->list_link_field=$entityname['fieldname'];
	}
    function save_module($module)
	{
    }
}
?>