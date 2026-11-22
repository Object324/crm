<?php



class CustomForm137 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm137']='CustomForm137';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm137';
	var $table_name = "ld_customform137";
	var $table_index= 'customform137id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform137','ld_customform137scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform137'=>'customform137id','ld_customform137scf'=>'customform137id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform137scf', 'customform137id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform137'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform137_no';
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('CustomForm137',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm137');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
              
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

	
 

}
CustomForm137::require_file();
?>