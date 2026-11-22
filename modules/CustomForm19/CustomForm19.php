<?php

require_once(globalStatic::$root_directory.'include/upload/FileUtil.php');
// Account is used to store ld_account information.

class CustomForm19 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm19']='CustomForm19';
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
     var $Detail_table="ld_customform19detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform19detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
    var $echokis='';
	var $log;
	var $db;
    var $module_name='CustomForm19';
	var $table_name = "ld_customform19";
	var $table_index= 'customform19id';
    var $table_code='customform19_no';
	var $tab_name = Array('ld_crmentity','ld_customform19','ld_customform19scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform19'=>'customform19id','ld_customform19scf'=>'customform19id');//'ld_invoice_recurring_info'=>'CustomForm19id'
    var $relatedtab=array('customform19'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform19'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform19scf', 'customform19id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm19";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm19'=>'CustomForm19_no'),
				'Subject'=>Array('CustomForm19'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm19'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm19_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm19id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm19 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm19 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm19',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm19');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm19';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	
	}
    
	function save_module($module)
	{
	  
        global $adb,$current_user;
     //   if(file_exists(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php'))
      //  require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        
        
		if($this->currency_status === true)
		{
			$update_query = "update ld_customform19 set currency_id=?, conversion_rate=?,currency_symbol=? where customform19id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm19Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		     
             
			//
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm19');
          
          
		}
         $versioninfo=getVersionInfo();
        if($versioninfo['account']=='langjie')
        {
           
            crm_load_class_file("cls_updateExpenseStatus",'include/LangJie');//朗jie更新费用状态
            $updateExpenseStatusobj=new cls_updateExpenseStatus($this->id,'payment');
            $updateExpenseStatusobj->update();
            
        }
		
		$update_query = "update ld_customform19 set triggercount=triggercount+1 where customform19id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params); 
    }

	
     public function trash($module,$id)
    {
        parent::trash($module,$id);
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='langjie')
        {
            global $adb;
            $sql='select customform28_id,customform02_id,customform24_id,customform21_id,customform22_id,commission_id from ld_customform19 where customform19id=?';
            $result=$adb->pquery($sql,array($id));
            $_REQUEST['customform28_id']=$adb->query_result($result,0,'customform28_id');
            $_REQUEST['customform02_id']=$adb->query_result($result,0,'customform02_id');
            $_REQUEST['customform24_id']=$adb->query_result($result,0,'customform24_id');
            $_REQUEST['customform21_id']=$adb->query_result($result,0,'customform21_id');
            $_REQUEST['customform22_id']=$adb->query_result($result,0,'customform22_id');
            $_REQUEST['commission_id']=$adb->query_result($result,0,'commission_id');
            crm_load_class_file("cls_updateExpenseStatus",'include/LangJie');//朗jie更新费用状态
            $updateExpenseStatusobj=new cls_updateExpenseStatus($id,'payment');
            $updateExpenseStatusobj->SetOperationType('delete');
            $updateExpenseStatusobj->update();
        }
    }
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('CustomForm19',$id);
  }
 

}
CustomForm19::require_file();
?>