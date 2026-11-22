<?php



// Account is used to store ld_account information.
class PurchaseInquiryOrder extends CRMEntity {
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['PurchaseInquiryOrder']='PurchaseInquiryOrder';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $Detail_table="ld_purchaseinquiryorderdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_purchaseinquiryorderdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
    var $module_name='PurchaseInquiryOrder';
	var $table_name = "ld_purchaseinquiryorder";
	var $table_index= 'purchaseinquiryorderid';
    var $table_code='purchaseinquiryorder_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_purchaseinquiryorder','ld_purchaseinquiryordercf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_purchaseinquiryorder'=>'purchaseinquiryorderid','ld_purchaseinquiryordercf'=>'purchaseinquiryorderid');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_purchaseinquiryordercf','purchaseinquiryorderid');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "PurchaseInquiryOrder";
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('purchaseinquiryorder_no','vendorid','contactid','smownerid');    // 查询 排序
    var $relatedtab=array('purchaseinquiryorder'=>'','vendors'=>'','users'=>'','company'=>'','products'=>'','vendorcontact'=>'');
	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );


	var $list_link_field= 'subject';

	var $search_fields = Array();

	var $search_fields_name = Array();

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'purchaseinquiryorderid';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'purchaseinquiryorder_no';
    
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('OutboundOrder');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('PurchaseInquiryOrder',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PurchaseInquiryOrder');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
	   	// Update the currency id and the conversion rate for the sales order
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        // //25906: pc端 合同订单 订单编号 SO11-15626 新建合同订单 币种选择欧元 。关联创建发票 发票金额253.80欧元到合同订单已开票金额那边看
		if($this->currency_status === true)
		{
			$update_query = "update ld_purchaseinquiryorder set currency_id=?, conversion_rate=?,currency_symbol=? where purchaseinquiryorderid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		if($_REQUEST['action'] != 'PurchaseInquiryOrderAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			//合同订单明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'PurchaseInquiryOrder');
		}
	}	

	//克莱门特：重复发货一定要避免，即发货单源单不能重复
	function haveInvenotryOrder($frommodule,$fromid,$record = 0){
		global $adb;
		if(!empty($frommodule) && !empty($fromid)){
			$query = 'select purchaseinquiryorderid from ld_purchaseinquiryorder 
				LEFT JOIN ld_purchaseinquiryorderdetail on ld_purchaseinquiryorderdetail.id = ld_purchaseinquiryorderdetail.purchaseinquiryorderid 
				where ld_purchaseinquiryorderdetail.entitytype = ? and ld_purchaseinquiryorderdetail.entitytypeid = ? and ld_purchaseinquiryorder.deleted <> 1';
			if($record > 0){
				$query .= ' and purchaseinquiryorderid != ' . $record;
			}
			$result = $adb->pquery($query,array($frommodule,$fromid));
			if($adb->num_rows($result) >= 1){
				return 'no';
			}
		}
		return 'yes';
	}
}
PurchaseInquiryOrder::require_file();
?>