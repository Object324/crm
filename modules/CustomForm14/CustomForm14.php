<?php

require_once(globalStatic::$root_directory.'include/upload/FileUtil.php');
// Account is used to store ld_account information.

class CustomForm14 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm14']='CustomForm14';
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
    var $Detail_table="ld_customform14detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform14detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
    var $echokis='';
	var $log;
	var $db;
    var $module_name='CustomForm14';
	var $table_name = "ld_customform14";
	var $table_index= 'customform14id';
    var $table_code='customform14_no';
	var $tab_name = Array('ld_crmentity','ld_customform14','ld_customform14scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform14'=>'customform14id','ld_customform14scf'=>'customform14id');//'ld_invoice_recurring_info'=>'CustomForm14id'

    var $relatedtab=array('customform14'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform14'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform14scf', 'customform14id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm14";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm14'=>'CustomForm14_no'),
				'Subject'=>Array('CustomForm14'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm14'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm14_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm14id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm14 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm14 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm14',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
       
        $entityname=getEntitynameByModulename('CustomForm14');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm14';
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
			$update_query = "update ld_customform14 set currency_id=?, conversion_rate=?,currency_symbol=? where customform14id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm14Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		     
             
			//保存明细
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm14');
          
          
		}
		
		$update_query = "update ld_customform14 set triggercount=triggercount+1 where customform14id=?";
		$this->db->pquery($update_query,array($this->id));
        
    }

	//浩辰特殊开发  chj  20220530 合同生成页面的合同类别与打印模板绑定，即选择打印模板时，默认显示唯一打印模板，不允许选择
	function getPrintTemplate_haochen($prints,$tabid){
		if(!empty($_REQUEST['module_recordid'])){
			global $adb;
			$query = "select ld_customform14_print_set.print_name,templateprintid from ld_customform14scf 
			LEFT JOIN ld_customform14_print_set on ld_customform14scf.cf_4618 = ld_customform14_print_set.order_type 
			LEFT JOIN ld_templateprint on ld_templateprint.templateprintname = ld_customform14_print_set.print_name 
			where ld_customform14scf.customform14id = ? and ld_templateprint.tabid = ?";
			$result = $adb->pquery($query,array($_REQUEST['module_recordid'],$tabid));
			if($adb->num_rows($result) >= 1){
				for($i = 0; $i < $adb->num_rows($result); $i++){
					$templateprintid = $adb->query_result($result,$i,'templateprintid');
					$print_name = $adb->query_result($result,$i,'print_name');
					$print[$templateprintid][] = $print_name;
					$print[$templateprintid][] = '';
				}
				//$print[] = $adb->query_result($result)
			}
		}
		return $print;
	}
   
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('CustomForm14',$id);
  }
 

}
CustomForm14::require_file();
?>