<?php

require_once(globalStatic::$root_directory.'include/upload/FileUtil.php');
// Account is used to store ld_account information.

class CustomForm11 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm11']='CustomForm11';
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
    var $Detail_table="ld_customform11detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform11detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
    var $echokis='';//閲戣澏鍚屾閿欒淇℃伅
	var $log;
	var $db;
    var $module_name='CustomForm11';
	var $table_name = "ld_customform11";
	var $table_index= 'customform11id';
    var $table_code='customform11_no';//琛ㄧ紪鍙峰瓧娈?瀹℃壒涓績)
	var $tab_name = Array('ld_crmentity','ld_customform11','ld_customform11scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform11'=>'customform11id','ld_customform11scf'=>'customform11id');//'ld_invoice_recurring_info'=>'CustomForm11id'
	/*
    edit:can
    date:20131024
    reason:鎵撳嵃鍏宠仈妯″潡
    */
    var $relatedtab=array('customform11'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform11'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform11scf', 'customform11id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm11";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm11'=>'CustomForm11_no'),
				'Subject'=>Array('CustomForm11'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm11'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm11_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm11id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm11 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm11 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm11',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:鍔ㄦ€佸垱寤哄簭鏃剁翱瓒呴摼鎺?
         * */
        $entityname=getEntitynameByModulename('CustomForm11');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm11';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	
	}
    
	function save_module($module)
	{
	  
        global $adb,$current_user;
        if(file_exists(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php'))
        require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        
		if($this->currency_status === true)
		{
			$update_query = "update ld_customform11 set currency_id=?, conversion_rate=?,currency_symbol=? where customform11id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm11Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm11');
		}
		
		$update_query = "update ld_customform11 set triggercount=triggercount+1 where customform11id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
        
    }

	

    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('CustomForm11',$id);
  }
 

}
CustomForm11::require_file();
?>