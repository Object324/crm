<?php

// Account is used to store ld_account information.
class Productbom extends CRMEntity {
	var $log;
	var $db;
	 var $Detail_table="ld_productbomdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_productbomdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = "ld_productbom";
	var $table_index= 'productbomid';
    var $table_code='productbom_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_productbom','ld_productbomcf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_productbom'=>'productbomid','ld_productbomcf'=>'productbomid');
    var $relatedtab=array('productbom'=>'','vendors'=>'','users'=>'','purchaseorder'=>'','products'=>'','company'=>'','vendorcontact'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_productbomcf', 'productbomid');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "Productbom";
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('productbom_no','wareid','createdate','purchaseorder_id','smownerid','vendor_id','presence');    // 查询 排序

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	// This is the list of ld_fields that are in the lists.
	var $list_link_field= 'subject';

	var $search_fields = Array(
				'Order No'=>Array('productbom'=>'productbom_no'),
				'Subject'=>Array('productbom'=>'subject'),
				);

	var $search_fields_name = Array(
					'Order No'=>'productbom_no',
				        'Subject'=>'subject',
				        'Vendor Name'=>'vendor_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'productbomid';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'productbom_no';
     /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? ) and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','Productbom'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('Productbom');
		$this->db = PearDatabase::getInstance();
		//$this->column_fields = getColumnFields('Productbom');
		$this->fieldobj = Field::getInstance('Productbom',$this->db);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Productbom');
        $this->list_link_field=$entityname['fieldname'];
		//chj 2021/3/4 44591: （61mis.com/kfbcrm）分录关联单选功能；工具-产品套餐；产品套餐分录中，关联了合同订单和自定义表单01；添加时界面一直转圈缓冲
		crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance('Productbom');
	}

	function save_module($module)
	{
		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'ProductbomAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
		  crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'Productbom');
		}
		// Update the currency id and the conversion rate for the sales order
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status == true)
		{
			/*$update_query = "update ld_productbom set currency_id=?, conversion_rate=?,currency_symbol=? where productbomid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);*/
            
		}      
        
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
    
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	public function getJoinClause($tableName) {
		if (strtolower($tableName) == 'ld_invoice_recurring_info') {
			return 'LEFT JOIN';
		}
		return parent::getJoinClause($tableName);
	}
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
		if($return_module == 'Products') {
			$this->trash('Productbom', $id);
		}
	}
    
    function getListQuery()
    {
        $query="select ld_productbom.*,ld_productbom.productbomid as crmid from ld_productbom
               left join  ld_productbomcf on ld_productbomcf.productbomid=ld_productbom.productbomid
            LEFT JOIN ld_users on  ld_productbom.smownerid=ld_users.id where ld_productbom.deleted=0";
            return $query;
    }
}

?>