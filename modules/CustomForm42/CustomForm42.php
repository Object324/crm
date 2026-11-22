<?php

require_once(globalStatic::$root_directory.'include/upload/FileUtil.php');
// Account is used to store ld_account information.

class CustomForm42 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm42']='CustomForm42';
            if(empty(globalStatic::$arr_module_require['Accounts']))
            {
                globalStatic::$arr_module_require['Accounts']='Accounts';
                include(globalStatic::$root_directory.'modules/Accounts/Accounts.php');
                
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            }

    }
    var $Detail_table="ld_customform42detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform42detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
  
	var $log;
	var $db;
    var $module_name='CustomForm42';
	var $table_name = "ld_customform42";
	var $table_index= 'customform42id';
    var $table_code='customform42_no';
	var $tab_name = Array('ld_crmentity','ld_customform42','ld_customform42scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform42'=>'customform42id','ld_customform42scf'=>'customform42id');//'ld_invoice_recurring_info'=>'CustomForm42id'

    var $relatedtab=array('customform42'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform42'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform42scf', 'customform42id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm42";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm42'=>'CustomForm42_no'),
				'Subject'=>Array('CustomForm42'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm42'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm42_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm42id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm42 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm42 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm42',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:超链接字段动态化
         * */
        $entityname=getEntitynameByModulename('CustomForm42');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm42';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	
	}
    
	function save_module($module)
	{
	  
        global $adb,$current_user;
        $languageType= getLanguageType($current_user);
        
        	// Update the currency id and the conversion rate for the sales order

		if($this->currency_status === true)
		{
			$update_query = "update ld_customform42 set currency_id=?, conversion_rate=?,currency_symbol=? where customform42id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm42Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		     
             
			//保存明细
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm42');
          
          
		}
         
        
    }

	
	 
    
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('CustomForm42',$id);
  }
 

}
CustomForm42::require_file();
?>