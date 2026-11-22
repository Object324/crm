<?php


class CustomForm18 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm18']='CustomForm18';
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
   var $Detail_table="ld_customform18detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform18detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
    var $echokis='';//闁叉垼婢忛崥灞绢劄闁挎瑨顕ゆ穱鈩冧紖
	var $log;
	var $db;
    var $module_name='CustomForm18';
	var $table_name = "ld_customform18";
	var $table_index= 'customform18id';
    var $table_code='customform18_no';//鐞涖劎绱崣宄扮摟濞?鐎光剝澹掓稉顓炵妇)
	var $tab_name = Array('ld_crmentity','ld_customform18','ld_customform18scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform18'=>'customform18id','ld_customform18scf'=>'customform18id');//'ld_invoice_recurring_info'=>'CustomForm18id'
	/*
    edit:can
    date:20131024
    reason:閹垫挸宓冮崗瀹犱粓濡€虫健
    */
    var $relatedtab=array('customform18'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform18'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform18scf', 'customform18id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm18";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm18'=>'CustomForm18_no'),
				'Subject'=>Array('CustomForm18'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm18'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm18_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm18id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm18 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm18 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm18',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:閸斻劍鈧礁鍨卞鍝勭碍閺冨墎缈辩搾鍛存懠閹?
         * */
        $entityname=getEntitynameByModulename('CustomForm18');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm18';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	
	}
    
	function save_module($module)
	{
	  
        global $adb,$current_user;
        //if(file_exists(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php'))
        //require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        
        
		if($this->currency_status === true)
		{
			$update_query = "update ld_customform18 set currency_id=?, conversion_rate=?,currency_symbol=? where customform18id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm18Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		     
             
			//
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm18');
          
          
		}
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='langjie')
        {
            crm_load_class_file("cls_updateExpenseStatus",'include/LangJie');//朗jie更新费用状态
            $updateExpenseStatusobj=new cls_updateExpenseStatus($this->id,'receive');
            $updateExpenseStatusobj->update();
        }

		$update_query = "update ld_customform18 set triggercount=triggercount+1 where customform18id=?";
		$this->db->pquery($update_query,array($this->id)); 
        
    }
    public function trash($module,$id)
    {
        parent::trash($module,$id);
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='langjie')
        {
            global $adb;
            $sql='select customform27_id,customform23_id,customform24_id,customform21_id,customform22_id,commission_id 
            from ld_customform18 where customform18id=?';
            $result=$adb->pquery($sql,array($id));
            $_REQUEST['customform27_id']=$adb->query_result($result,0,'customform27_id');
            $_REQUEST['customform23_id']=$adb->query_result($result,0,'customform23_id');
            $_REQUEST['customform24_id']=$adb->query_result($result,0,'customform24_id');
            $_REQUEST['customform21_id']=$adb->query_result($result,0,'customform21_id');
            $_REQUEST['customform22_id']=$adb->query_result($result,0,'customform22_id');
            $_REQUEST['commission_id']=$adb->query_result($result,0,'commission_id');
            crm_load_class_file("cls_updateExpenseStatus",'include/LangJie');//朗jie更新费用状态
            $updateExpenseStatusobj=new cls_updateExpenseStatus($id,'receive');
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
        
         $this->trash('CustomForm18',$id);
  }
 

}
CustomForm18::require_file();
?>