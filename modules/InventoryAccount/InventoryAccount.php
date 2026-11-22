<?php

class InventoryAccount extends CRMEntity {
	var $log;
	var $db;

	var $table_name = "ld_warehousecondtions";
	var $table_index= 'entityid';
	var $tab_name = Array('ld_warehousecondtions','ld_products');  //查询
	var $tab_name_index = Array('ld_warehousecondtions'=>'entityid','ld_warehousecondtions'=>'productid','ld_products'=>'productid');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array();//自定义
	var $entity_table = "ld_products";
	var $object_name = "InventoryAccount";
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('subject','smownerid','accountname','lastname');    // 查询 排序

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

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
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
		//$this->log =LoggerManager::getLogger('InventoryAccount');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('InventoryAccount',$this->db);
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
    /*
    function getListQuery($module, $where = '') {

	
			$query = "SELECT distinct ld_warehousecondtions.id as crmid ,ld_warehousecondtions.* ".$fromclause .
				" FROM ld_warehousecondtions 
				
					ON ld_warehousecondtions.productid = ld_products.productid ";
				
				$query .= $where;
			return $query;
    }*/

}

?>