<?php

require_once(globalStatic::$root_directory.'include/upload/FileUtil.php');
// Account is used to store ld_account information.

class CustomForm176 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm176']='CustomForm176';
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
    var $Detail_table="ld_customform176detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform176detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
  
	var $log;
	var $db;
    var $module_name='CustomForm176';
	var $table_name = "ld_customform176";
	var $table_index= 'customform176id';
    var $table_code='customform176_no';//鐞涖劎绱崣宄扮摟濞?鐎光剝澹掓稉顓炵妇)
	var $tab_name = Array('ld_crmentity','ld_customform176','ld_customform176scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform176'=>'customform176id','ld_customform176scf'=>'customform176id');//'ld_invoice_recurring_info'=>'CustomForm176id'
	/*
    edit:can
    date:20131024
    reason:閹垫挸宓冮崗瀹犱粓濡€虫健
    */
    var $relatedtab=array('customform176'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform176'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform176scf', 'customform176id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm176";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm176'=>'CustomForm176_no'),
				'Subject'=>Array('CustomForm176'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm176'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm176_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm176id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm176 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm176 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm176',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:超链接字段动态化
         * */
        $entityname=getEntitynameByModulename('CustomForm176');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm176';
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
			$update_query = "update ld_customform176 set currency_id=?, conversion_rate=?,currency_symbol=? where customform176id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm176Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm176');
		}
         
        
		$update_query = "update ld_customform176 set triggercount=triggercount+1 where customform176id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
		
    }

	
	 
    
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('CustomForm176',$id);
  }
 

}
CustomForm176::require_file();
?>