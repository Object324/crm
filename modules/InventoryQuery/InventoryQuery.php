<?php



// Account is used to store ld_account information.
class InventoryQuery extends CRMEntity {
	var $log;
	var $db;

	var $table_name = "ld_warehouse2products";
	var $table_index= 'warehouseid';
	var $tab_name = Array('ld_warehouse2products','ld_products');  //查询
	var $tab_name_index = Array('ld_warehouse2products'=>'warehouseid','ld_products'=>'productid');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_stockcf', 'stockid');//自定义
	var $entity_table = "ld_products";
	var $object_name = "InventoryAccount";
    var $module_name='InventoryAccount';
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('ld_products.productname','smownerid','accountname','lastname');    // 查询 排序

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );
	var $list_link_field= 'subject';
    
	var $search_fields = Array(
				'Order No'=>Array('salesorder'=>'salesorder_no'),
				'Subject'=>Array('salesorder'=>'subject'),
				'Account Name'=>Array('account'=>'accountid'),
				'Quote Name'=>Array('salesorder'=>'quoteid')
				);

	var $search_fields_name = Array(
					'Order No'=>'salesorder_no',
				        'Subject'=>'subject',
				        'Account Name'=>'account_id',
				        'Quote Name'=>'quote_id'
				      );

	// This is the list of ld_fields that are required.
	var $required_fields =  array("accountname"=>1);
    var $header_search = array('productname' => '产品名称','product_no' => '产品编号','productsheet'=>'型号','unit_price'=>'单价',
 'productqty'=>'库存数量','qtyearly'=>'预警数量');
    var $header_search_en = array('productname' => 'Product Name','product_no' => 'Part Number','productsheet'=>'Specification','unit_price'=>'Unit Price',
 'productqty'=>'Stock Number','qtyearly'=>'Warning Counter');
	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'ld_products.productname';
     /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
        global $adb;
        $array = array();
        $sql = "select fieldid,width from ld_relatedlists_lable where tabid = 22 and presence = 1 order by sequence asc";
        $result = $adb->pquery($sql);
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $SqlField = "select tablename,fieldname,fieldlabel from ld_field where fieldid = " . $adb->query_result($result,$i,'fieldid');
            $FieldArraty = $adb->pquery($SqlField);
            for($j = 0; $j<$adb->num_rows($FieldArraty); $j++)
            {
                if($Type == 1)
                {
                    $array[$adb->query_result($FieldArraty,$j,'fieldlabel')] = array(
                        "".$adb->query_result($FieldArraty,$j,'tablename')."" => "".$adb->query_result($FieldArraty,$j,'fieldname')."",
                    );
                }
                else
                {
                   $array[$adb->query_result($FieldArraty,$j,'fieldlabel')]= "".$adb->query_result($FieldArraty,$j,'fieldname')."";
                }
            }
        }
        return $array;
    }*/
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
	//	$this->log =LoggerManager::getLogger('InventoryQuery');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=new Field('InventoryQuery',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
	}

	function save_module($module)
	{
		
	}
	 public function getEntityDeletedQuery(){
	
      
      
            return 1;
        
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

	public function getJoinClause($tableName) {
		if (strtolower($tableName) == 'ld_invoice_recurring_info') {
			return 'LEFT JOIN';
		}
		return parent::getJoinClause($tableName);
	}    
    
   /**
	 * Create query to export the records.
	 */
	function create_export_query($where){
		global $current_user;
		$thismodule = $_REQUEST['module'];

		include("include/utils/ExportUtils.php");
        $sysdeploy = getSys_deploy(49);
        if(isset($sysdeploy['deploy_value']))
			$lengthdecimaldigits = $sysdeploy['deploy_value'];
		else
			$lengthdecimaldigits  = 2;
		//To get the Permitted fields query and the permitted fields list
		$sql = getPermittedFieldsQuery($thismodule, "detail_view");
		$fields_list = getFieldsListFromQuery($sql);
		$fields_list = strtr($fields_list,array('ld_warehousecondtions.warehouseid'=>'ld_warehouse.name'));
        $fields_list = strtr($fields_list,array('ld_products.qtyearly'=>'FORMAT(ld_products.qtyearly,'.$lengthdecimaldigits.')'));

		$query = "SELECT $fields_list 
					FROM ld_warehouse2products 
						left join ld_products 
							ON ld_warehouse2products.productid = ld_products.productid 
						inner join ld_warehouse 
							on ld_warehouse.id = ld_warehouse2products.warehouseid ";

		$query .= $this->getNonAdminAccessControlQuery($thismodule,$current_user);
		$where_auto = "  ld_warehouse2products.productid > 0 and ld_warehouse2products.warehouseid > 0 ";

		if($where != '') $query .= " WHERE ($where) AND $where_auto";
		else $query .= " WHERE $where_auto";
		return $query;
	}
}

?>