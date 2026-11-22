<?php

include_once('config.php');


// Account is used to store ld_account information.
class PurchaseInvoice extends CRMEntity {
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['PurchaseInvoice']='PurchaseInvoice';
        if(empty(globalStatic::$arr_module_require['Accounts']))
        {
                globalStatic::$arr_module_require['Accounts']='Accounts';
                include("modules/Accounts/Accounts.php");   
        }
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
         {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");    
         }
    }
	var $log;
	var $db;
    var $Detail_table="ld_purchaseinvoicedetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_purchaseinvoicedetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = "ld_purchaseinvoice";
	var $table_index= 'purchaseinvoiceid';
    var $table_code='purchaseinvoice_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_purchaseinvoice','ld_purchaseinvoicecf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_purchaseinvoice'=>'purchaseinvoiceid','ld_purchaseinvoicecf'=>'purchaseinvoiceid');
    var $relatedtab=array('purchaseinvoice'=>'','vendors'=>'','users'=>'','purchaseorder'=>'','products'=>'','company'=>'','vendorcontact'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_purchaseinvoicecf', 'purchaseinvoiceid');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "PurchaseInvoice";
	var $new_schema = true;

	var $column_fields = Array();
    var $module_name='PurchaseInvoice';
	var $sortby_fields = Array('purchaseinvoice_no','wareid','createdate','purchaseorder_id','smownerid','vendor_id','presence');    // 查询 排序

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	// This is the list of ld_fields that are in the lists.
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('purchaseinvoice'=>'purchaseinvoice_no'),
				'Subject'=>Array('purchaseinvoice'=>'subject'),
				'Vendor Name'=>Array('purchaseinvoice'=>'vendor_id')
				);

	var $search_fields_name = Array(
					'Order No'=>'purchaseinvoice_no',
				        'Subject'=>'subject',
				        'Vendor Name'=>'vendor_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'purchaseinvoiceid';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'purchaseinvoice_no';
   
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('PurchaseInvoice');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('PurchaseInvoice',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PurchaseInvoice');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        // //   //25906: pc端 合同订单 订单编号 SO11-15626 新建合同订单 币种选择欧元 。关联创建发票 发票金额253.
		if($this->currency_status == true)
		{
			$update_query = "update ld_purchaseinvoice set currency_id=?, conversion_rate=?,currency_symbol=? where purchaseinvoiceid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		} 
		if($_REQUEST['action'] != 'PurchaseInvoiceAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			//合同订单明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'PurchaseInvoice');
		}

	    //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
        //编辑单据反写付款单明细字段
        $sendfocus = CRMEntity::getInstance('SendCashBill');
        $sendfocus->updateSourceInfo($this->id,'PurchaseInvoice');
	}
    function massChangeOrder_after($module,$ids)
    {
        if(is_array($ids))
        {
            
        }
        else
        {
            $ids=explode(',',$ids);
        }
        if(sizeof($ids)>0)
        {
             crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
            foreach($ids as $Id)
            {
                cls_Source_InverseCompute::Source_InveverseCompute('PurchaseInvoice',$Id);
            }
        }
        
    }
     public function restore($module, $id)
    {
        global $adb;
        parent::restore($module,$id);
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute('PurchaseInvoice',$id);
    }
	 function trash($module,$id)
    {
        parent::trash($module,$id);
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute('PurchaseInvoice',$id);
        
    }



	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Calendar" =>array("ld_seactivityrel"=>array("crmid","activityid"),"ld_salesorder"=>"salesorderid"),
			"Invoice" =>array("ld_invoice"=>array("salesorderid","invoiceid"),"ld_salesorder"=>"salesorderid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_salesorder"=>"salesorderid"),
		);
		return $rel_tables[$secmodule];
	}
    /**
     * edit:can
     * date:20140913
     * reason:获取原单
     * */
     function getSourceField($fieldname,$recordid)
     {
        global $adb;
       $detailtable=$this->Detail_table;
        $sql = "select entitytype,entitytypeid from $detailtable where id = ?";
       
        $result = $adb->pquery($sql,array($recordid));
        $sourceModuleInfo['module']= $adb->query_result($result,0,'entitytype');
        $sourceModuleInfo['sourceid']= $adb->query_result($result,0,'entitytypeid');
        return $sourceModuleInfo;
     }
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	public function getJoinClause($tableName) {
		if (strtolower($tableName) == 'ld_invoice_recurring_info') {
			return 'LEFT JOIN';
		}
		return parent::getJoinClause($tableName);
	}

	//审批完成
	public function successApprove($id)
	{
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
		cls_Source_InverseCompute::Source_InveverseCompute($this->moduleName,$id);//更新发票的源单已开票和未开票数量
	}
	//反审批
	public function rejectApproved($id)
    {
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
		cls_Source_InverseCompute::Source_InveverseCompute($this->moduleName,$id);//更新发票的源单已开票和未开票数量
	}
}
PurchaseInvoice::require_file();
?>