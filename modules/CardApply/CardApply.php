<?php
class CardApply extends CRMEntity
{
    
   var $table_name = "ld_cardapply";
	var $table_index= 'cardapplyid';
    var $table_code='cardapply_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_cardapply','ld_cardapplyscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_cardapply'=>'cardapplyid','ld_cardapplyscf'=>'cardapplyid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_cardapplyscf', 'cardapplyid');
    //	//关联模块
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','cardapply'=>'');
	var $column_fields = Array();
     var $module_name='CardApply';
     var $moduleName='CardApply';
	//Pavani: Assign value to entity_table
        var $entity_table = "ld_crmentity";

	var $sortby_fields = Array();


	var $list_link_field= 'cardapply_no';

    var $required_fields =  array();

	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime');
        var $default_order_by = 'cardapply_no';
        var $default_sort_order = 'DESC';

	
	var $def_basicsearch_col = 'cardapply_no';
	function __construct()
	{
	
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance($this->module_name,$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      

        $entityname=getEntitynameByModulename($this->module_name);
        $this->list_link_field=$entityname['fieldname'];
	}
    function save_module($module)
	{
    }
}
?>