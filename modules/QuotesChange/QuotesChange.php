<?php
class QuotesChange extends CRMEntity{
        var $Detail_table="ld_quoteschangedetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_quoteschangedetailscf";//明细scf表
    var $Detail_table_index="id";//明细表和主表关联的字段
    var $table_name = "ld_quoteschange";
	var $table_index= 'quoteschangeid';//主表主键
    var $table_code='quoteschange_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_quoteschange','ld_quoteschangescf');
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_quoteschange'=>'quoteschangeid','ld_quoteschangescf'=>'quoteschangeid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_quoteschangescf', 'quoteschangeid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    
	var $column_fields = Array();
	public  $module_name='QuotesChange';
 //和主表关联的模块
    //打印管理模块
    var $relatedtab=array('quotes'=>'', 'quoteschange'=>'', 'users'=>'','potential'=>'','contacts'=>'','accounts'=>'','products'=>'','company'=>'');
    

	var $sortby_fields = Array('quoteschange_no','smownerid');
    
	
	var $list_link_field= 'quoteschange_no';

	var $search_fields = Array(
			'Quoteschange No'=>array('ld_quoteschange'=>'quoteschange_no')
			);

	var $search_fields_name = Array(
			'Account Name'=>'accountname',
		
			'Assigned To'=>'assigned_user_id',
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'accountname');

	//Default Fields for Email Templates -- Pavani
//	var $emailTemplate_defaultFields = array('accountname','account_type','industry','annualrevenue','phone','email1','rating','website','fax');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'leads_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'quoteschange_no';
    var $popup_fields=Array();
    var $detailfieldobj;//明细表字段对象
    function __construct() {
		//$this->log =LoggerManager::getLogger('Expense');
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('QuotesChange',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      
             /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('QuotesChange');
        $this->list_link_field=$entityname['fieldname'];
        
        $this->popup_fields=Array($this->list_link_field);
        $this->module_name='QuotesChange';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}
  
   
    function  save_module($module) 
    { 
		if($this->currency_status === true)
		{
			$update_query = "update ld_quoteschange set currency_id=?, conversion_rate=?,currency_symbol=? where quoteschangeid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		if($_REQUEST['action'] != 'QuotesChangeAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'QuotesChange');
		}
		if(!empty($_REQUEST['quote_id']) && !empty($_REQUEST['change_type'])){
			$quote_id = $_REQUEST['quote_id'];
			if($_REQUEST['change_type'] == 'add'){
				$change_type = '追加';
			}else if($_REQUEST['change_type'] == 'edit'){
				$change_type = '修改';
			}else{
				$change_type = '更换';
			}
			$so_module = getSalesEntityType($quote_id);
			$so_focus = CRMEntity::getInstance($so_module);
			$so_focus->mode = 'edit';
			$so_focus->id = $quote_id;
			$so_focus->retrieve_entity_info($quote_id,$so_module);
			$query = 'update ld_quoteschange set change_type = ?,accountid = ?,quoteid = ? where quoteschangeid = ?';
			$this->db->pquery($query,array($change_type,$so_focus->column_fields['account_id'],$quote_id,$this->id));
		}
    }
    
    //获取报价单和报价变更单(追加)产品明细信息
	function getInventoryProducts_info($quote_id){
		global $adb;
		$from_focus=CRMEntity::getInstance('Quotes');
		$approve_demand= $from_focus->get_approve_demand_byModule('QuotesChange');	// 审批要求 0 无  1已批准
		if($approve_demand == 1){
			$approve_sql = ' and approvestatus = "'.constant('D_A_S_APPROVED').'"';
		}
		$query = 'select ld_products.productid,ld_products.productname,lineitem_id,change_type,parent_lineitem_id,tp.approvestatus,sum(quantity) as quantity  from (
			select ld_quotesdetail.productid,lineitem_id,\'追加\' as change_type,parent_lineitem_id,ld_quotes.approvestatus,quantity from ld_quotesdetail
			LEFT JOIN ld_quotes on ld_quotes.quoteid = ld_quotesdetail.id where ld_quotes.deleted = 0 and  id = ? '. $approve_sql.' 
			UNION
			select ld_quotesdetail.productid,lineitem_id,ld_quoteschange.change_type,parent_lineitem_id,ld_quoteschange.approvestatus,quantity from ld_quotesdetail
			LEFT JOIN ld_quoteschange on ld_quotesdetail.id = ld_quoteschange.quoteschangeid
			where ld_quoteschange.deleted = 0 and  ld_quoteschange.quoteid = ? '. $approve_sql.' 
			UNION
			SELECT
					(
						SELECT
							productid
						FROM
							ld_quotesdetail
						WHERE
							lineitem_id = b.parent_lineitem_id
					) AS productid,
				b.parent_lineitem_id as lineitem_id,
				ld_quoteschange.change_type,
				b.parent_lineitem_id,
				ld_quoteschange.approvestatus,
				-b.quantity
				FROM
					ld_quoteschange
				LEFT JOIN ld_quoteschangedetail b ON ld_quoteschange.quoteschangeid = b.id
				WHERE
					ld_quoteschange.deleted = 0
				AND ld_quoteschange.change_type = \'更换\'
				AND ld_quoteschange.quoteid = ? '.$approve_sql.'
		) as tp LEFT JOIN ld_products on ld_products.productid = tp.productid GROUP BY lineitem_id ORDER BY tp.lineitem_id asc';
		$result = $adb->pquery($query,array($quote_id,$quote_id,$quote_id));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i< $num_rows; $i++){
				$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
				$quantity =  $adb->query_result($result,$i,'quantity');
				if($quantity > 0){
					$inven_data[$lineitem_id] = array(
						'productid' => $adb->query_result($result,$i,'productid'),
						'productname' => $adb->query_result($result,$i,'productname'),
						'change_type' => $adb->query_result($result,$i,'change_type'),
						'parent_lineitem_id' => $adb->query_result($result,$i,'parent_lineitem_id'),
						'lineitem_id' => $adb->query_result($result,$i,'lineitem_id'),
						'approvestatus' => $adb->query_result($result,$i,'approvestatus'),
						'quantity' => $quantity,
					);
				}
				$parent_lineitem_id_array[$lineitem_id] = $adb->query_result($result,$i,'parent_lineitem_id');
			}
			foreach($inven_data as $lineitem_id => $infos){
				//if(!in_array($lineitem_id,$parent_lineitem_id_array)){
					
						$data[] = $infos;
				
					
				//}
			}
		}
		return $data;
	}
	
	//根据parent_lineitem_id获取当前明细行产品的信息
	function getProductFor_Parent_lineitemid($parent_lineitem_id){
		global $adb;
		if(!empty($parent_lineitem_id)){
			$query = 'select ld_products.productid,ld_products.productname,lineitem_id,id from ld_quotesdetail
				LEFT JOIN ld_products on ld_products.productid = ld_quotesdetail.productid
				where ld_quotesdetail.lineitem_id = ?';
			$result = $adb->pquery($query,array($parent_lineitem_id));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$data = array(
					'productid' => $adb->query_result($result,0,'productid'),
					'productname' => $adb->query_result($result,0,'productname'),
					'lineitem_id' => $adb->query_result($result,0,'lineitem_id'),
					'id' => $adb->query_result($result,0,'id'),
				);
			}
		}
		return $data;
	}
	function getChangeType($change_type){
		switch($change_type){
		   case '更换':
		       return 'replace';
		       break;
		   case '修改':
		       return 'edit';
		       break;
		  default:
		       return 'add';
		}
	}

   	function unlinkRelationship($id, $return_module, $return_id)
    {
		$this->trash('QuotesChange',$id);
    }
   
}
?>