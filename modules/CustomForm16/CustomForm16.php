<?php


class CustomForm16 extends CRMEntity {
    
    
    
    static  function require_file($requiremodules='')
    {
         
        
            globalStatic::$arr_module_require['CustomForm16']='CustomForm16';
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
      var $Detail_table="ld_customform16detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform16detailscf";//自定义明细表
     var $Detail_table_index="id";//明细表和主表关联字段
     
   
	var $log;
	var $db;
    var $module_name='CustomForm16';
	var $table_name = "ld_customform16";
	var $table_index= 'customform16id';
    var $table_code='customform16_no';//鐞涖劎绱崣宄扮摟濞?鐎光剝澹掓稉顓炵妇)
	var $tab_name = Array('ld_crmentity','ld_customform16','ld_customform16scf');//'ld_invoice_recurring_info'
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform16'=>'customform16id','ld_customform16scf'=>'customform16id');//'ld_invoice_recurring_info'=>'CustomForm16id'
	/*
    edit:can
    date:20131024
    reason:閹垫挸宓冮崗瀹犱粓濡€虫健
    */
    var $relatedtab=array('customform16'=>'','accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','products'=>'','company'=>'','customform16'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform16scf', 'customform16id');
	var $entity_table = "ld_crmentity";


	var $object_name = "CustomForm16";

	var $new_schema = true;

	var $update_product_array = Array();

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('CustomForm16'=>'CustomForm16_no'),
				'Subject'=>Array('CustomForm16'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('CustomForm16'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'CustomForm16_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','CustomForm16id');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
    static $mass_before_focus=array();
   
	/** Constructor Function for CustomForm16 class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of CustomForm16 class.
	 */
	function __construct() {
	   
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm16',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:超链接字段动态化
         * */
        $entityname=getEntitynameByModulename('CustomForm16');
      
        $this->list_link_field=$entityname['fieldname'];
        $this->moduleName='CustomForm16';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	
	}
    
	function save_module($module)
	{
	  
        global $adb,$current_user;
        if(file_exists(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php'))
        require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        
        	// Update the currency id and the conversion rate for the sales order
		//缂傛牞绶弮璺哄灲閺傤厼绔电粔宥嗘Ц閸氾附鏁奸崣?this->currency_status  true:閺€鐟板綁閿涘畺alse:濞屸剝鏁奸崣?
        //25906: pc缁?閸氬牆鎮撶拋銏犲礋 鐠併垹宕熺紓鏍у娇 SO11-15626 閺傛澘缂撻崥鍫濇倱鐠併垹宕?鐢胶顫掗柅澶嬪濞喲冨帗 閵嗗倸鍙ч懕鏂垮灡瀵ゅ搫褰傜粊?閸欐垹銈ㄩ柌鎴︻杺253.80濞喲冨帗閸掓澘鎮庨崥宀冾吂閸楁洖鍑″鈧粊銊╁櫨妫版繈鍋呮潏鍦箙閿涘本濡?53.80濞喲冨帗瑜版挻鍨氭禍鐑樼毌鐢焦婀侀幑銏㈢暬閹存劖顑傞崗鍐х啊
		if($this->currency_status === true)
		{
			$update_query = "update ld_customform16 set currency_id=?, conversion_rate=?,currency_symbol=? where customform16id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'CustomForm16Ajax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		     
             
			//保存明细
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'CustomForm16');
          
          
		}
        

		$update_query = "update ld_customform16 set triggercount=triggercount+1 where customform16id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params); 
        
    }

	

   
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('CustomForm16',$id);
  }
 

}
CustomForm16::require_file();
?>