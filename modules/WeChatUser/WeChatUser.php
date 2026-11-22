<?php



class WeChatUser extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['WeChatUser']='WeChatUser';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='WeChatUser';
	var $table_name = "ld_wechatuser";
	var $table_index= 'wechatuserid';
	var $tab_name = Array('ld_crmentity','ld_wechatuser','ld_wechatuserscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_wechatuser'=>'wechatuserid','ld_wechatuserscf'=>'wechatuserid',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_wechatuserscf', 'wechatuserid');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','mobile','smownerid');

	var $list_link_field= 'wechatuser_no';
    var $relatedtab=array('accounts'=>'','customform01'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='wechatuser_no';//审批中链接字段
	var $search_fields = Array();

	var $search_fields_name = Array();

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('lastname','mobile');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('WeChatUser',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('WeChatUser');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
              
	}
	
	function restore($module, $id) {
		//调用帮我吧接口
		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

	
 

}
WeChatUser::require_file();
?>