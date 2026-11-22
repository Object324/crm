<?php


// Account is used to store lingdang_account information.
class PurchaseOrder extends CRMEntity {
     static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['PurchaseOrder']='PurchaseOrder';
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $Detail_table="ld_purchaseorderdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_purchaseorderdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
    var $module_name='PurchaseOrder';
	var $table_name = "ld_purchaseorder";
	var $table_index= 'purchaseorderid';
    var $table_code='purchaseorder_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_purchaseorder','ld_purchaseordercf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_purchaseorder'=>'purchaseorderid','ld_purchaseordercf'=>'purchaseorderid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_purchaseordercf', 'purchaseorderid');
	var $entity_table = "ld_crmentity";

	var $billadr_table = "ld_pobillads";
	var $object_name = 'PurchaseOrder';
	var $column_fields = Array();

	var $sortby_fields = Array('subject','tracking_no','smownerid','lastname');
    var $list_link_field= 'subject';
	// This is used to retrieve related lingdang_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );
    /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('vendors'=>'','purchaseorder'=>'','users'=>'','products'=>'','company'=>'','salesorder'=>'','vendorcontactrecords'=>'','vendorcontact'=>'');
	
	var $def_basicsearch_col = 'subject';
	public $update_prod_stock;
    
	//var $groupTable = Array('lingdang_pogrouprelation','purchaseorderid');
	/** Constructor Function for Order class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of Order class.
	 */
	function __construct() {
	//	$this->log =LoggerManager::getLogger('PurchaseOrder');
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('PurchaseOrder',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
       
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PurchaseOrder');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
        $this->moduleName='PurchaseOrder';
        
	}

	function save_module($module)
	{
		global $adb;

		//in ajax save we should not call this function, because this will delete all the existing product values
		if($_REQUEST['action'] != 'PurchaseOrderAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
			saveInventoryProductDetails($this, 'PurchaseOrder', $this->update_prod_stock);
		}
        
        //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
        
		//In Ajax edit, if the status changed to Received Shipment then we have to update the product stock
		if($_REQUEST['action'] == 'PurchaseOrderAjax' && $this->update_prod_stock == 'true')
		{
		  $detailtable=$this->Detail_table;
			$inventory_res = $this->db->pquery(" select productid, quantity from $detailtable where id=? ",array($this->id));
			$noofproducts = $this->db->num_rows($inventory_res);

			//We have to update the stock for all the products in this PO
			for($prod_count=0;$prod_count<$noofproducts;$prod_count++)
			{
				$productid = $this->db->query_result($inventory_res,$prod_count,'productid');
				$quantity = $this->db->query_result($inventory_res,$prod_count,'quantity');
				$this->db->println("Stock is going to be updated for the productid - $productid with quantity - $quantity");

				addToProductStock($productid,$quantity);
			}
		}
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_purchaseorder set currency_id=?, conversion_rate=?,currency_symbol=? where purchaseorderid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'],$this->id);
			$this->db->pquery($update_query, $update_params);
		}
        //编辑单据反写付款单明细表字段
        $sendfocus = CRMEntity::getInstance('SendCashBill');
        $sendfocus->updateSourceInfo($this->id,'PurchaseOrder');
		
		$update_query = "update ld_purchaseorder set triggercount=triggercount+1 where purchaseorderid=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
	}
 
       

	 public function addComboxIntoDataBase($table_name='')
    { 
		 global $adb;
                if(!array_key_exists("postatus",$this->column_fields))
                {
                    return ;
                }
				$history_field_array = Array(
					"PurchaseOrder" => "postatus"
				
				);

				$inventory_module = "PurchaseOrder";
   
				if ($_REQUEST['ajxaction'] == 'DETAILVIEW') {//if we use ajax edit
				
						$relatedname = getModuleHref('Accounts',$this->column_fields['account_id']);

					    $total = $this->column_fields['hdnGrandTotal'];
				}
				else {//using edit button and save
				
						$relatedname = $_REQUEST["account_name"];

					$total = $_REQUEST['total'];
				}

				if ($this->column_fields["$history_field_array[$inventory_module]"] == $app_strings['LBL_NOT_ACCESSIBLE']) {

					//If the value in the request is Not Accessible for a picklist, the existing value will be replaced instead of Not Accessible value.
					$his_col = $history_field_array[$inventory_module];
					$his_sql = "select $his_col from  $this->table_name where " . $this->table_index . "=?";
					$his_res = $adb->pquery($his_sql, array($this->id));
					$status_value = $adb->query_result($his_res, 0, $his_col);
					$stat_value = $status_value;
				} else {
					$stat_value = $this->column_fields["$history_field_array[$inventory_module]"];
				}
				$oldvalue = getSingleFieldValue($this->table_name, $history_field_array[$inventory_module], $this->table_index, $this->id);
				if ($this->column_fields["$history_field_array[$inventory_module]"] != '' && $oldvalue != $stat_value) {
					crm_load_function_file('addInventoryHistory','include/utils','InventoryUtils');
					addInventoryHistory($inventory_module, $this->id, $relatedname, $total, $stat_value);
				}
    }

	

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Calendar" =>array("ld_seactivityrel"=>array("crmid","activityid"),"ld_purchaseorder"=>"purchaseorderid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_purchaseorder"=>"purchaseorderid"),
			"Contacts" => array("ld_purchaseorder"=>array("purchaseorderid","contactid")),
		);
		return $rel_tables[$secmodule];
	}
     public function restore($module, $id)
    {
        global $adb;
        parent::restore($module,$id);
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$id);
    }
     public function trash($module,$id)
     {
          global $adb;
            
             
    		 //0022339: 采购订单序时簿界面：删除单据，回收站没有显示被删除的单据
    		  parent::trash($module,$id);
         
            crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
            cls_Source_InverseCompute::Source_InveverseCompute($module,$id);
            
         
     }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Vendors') {
			$sql_req ='UPDATE ld_crmentity SET deleted = 1 WHERE crmid= ?';
			$this->db->pquery($sql_req, array($id));
		} elseif($return_module == 'Contacts') {
			$sql_req ='UPDATE ld_purchaseorder SET contactid=? WHERE purchaseorderid = ?';
			$this->db->pquery($sql_req, array(null, $id));
		}elseif($return_module == 'SalesOrder')
        {
			$this->trash('PurchaseOrder',$id);
        }
         else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}
    

    
    
    
  
    
    function getSalesOrderList($list,$pagetype,$rowCnt){
        global $adb;
        $Rand = 0;
        foreach($list as $key => $var)
        {
            $keyVal = explode(',', $key);
            if($keyVal[0] == $Rand)
            {
               $cnt = 0;
               foreach($list[$key] as $keysec => $val)
               {
                    if($cnt <= 4)
                    {
                        $list[$key][$keysec] = '&&';
                    }
                    $cnt++;
               }
            }
            $Rand = $keyVal[0];
        }
        return $list;
    }
    
    /**
     * 审批已拒绝执行操作函数
     * edit:andy
     * date:20140701
     * verson:v5.34
     */
     public function failedApproved($record)
     {
        global $adb;
        $SendPaymentID_str=getSendPaymentID($record);
        //删除关联付款计划
        if($SendPaymentID_str != ''){
            $sql='delete from ld_sendpayment where sendpaymentid in ('.$SendPaymentID_str.')';
            $adb->pquery($sql);
            $SendPaymentID_str.=','.$record;
        }
        else
        {
            $SendPaymentID_str.=$record;
        }
        //删除相关提醒
        $sql='delete from ld_reminds where related_to in ('.$SendPaymentID_str.') and ifnull(remindstype,"") != \'Approve\'';
        $adb->pquery($sql);

        
        //删除相关自动提醒
        //print_r($SendPaymentID_str);exit;
        $sql_autoRemind='delete from ld_tmpreminder where  related_to in ('.$SendPaymentID_str.')';
        $adb->pquery($sql);
     }

	 //源美特殊控制，判断明细表体字段“暂定价价格”、“点价价格”、“点价期限/时间”是否启用
	function getOrdertypeByField(){
		global $currentModule;
		$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
		$productfiled = $ProductDetailsData->presenceToolField;
		$col_array = array('tempprice','clickprice','clicktime');
		$res = 'no';
		if(!empty($productfiled)){
			$presence_num = 0;
			foreach($productfiled as $pro_field){
				$columnname = $pro_field->getColumnName();
				if(in_array($columnname,$col_array) && $pro_field->getPresence() <> 1){
					$presence_num++;
				}
			}
			if(sizeOf($col_array) == $presence_num){
				$res = 'yes';
			}
		}
		return $res;
	}

	function getPurchaseOrderList($list,$pagetype,$rowCnt){
        global $adb;
        $Rand = 0;
		if(empty($list)) return '';
        foreach($list as $key => $var)
        {
            $keyVal = explode(',', $key);
            if($keyVal[0] == $Rand)
            {
               $cnt = 0;
               foreach($list[$key] as $keysec => $val)
               {
                    if($cnt <= 7)
                    {
                        $list[$key][$keysec] = '&&';
                    }
                    $cnt++;
               }
            }
            $Rand = $keyVal[0];
        }
        return $list;
    }

	public function successApprove($crmid){
		//杨锻客户，erp对接特殊判断
		global $adb;
		$deployarray=getSys_deploy(92);
		if(isset($deployarray['deploy_value']) && $deployarray['deploy_value'] == 0){
			if(get_versiontrade() == 'yangduan'){
				crm_load_class_file('cls_interface_yadon','include/InterfaceClass');
				$cls_interface_yadon = new cls_interface_yadon();
                $detailtable=$this->Detail_table;
                $detailtablescf=$this->Detail_table_scf;
                
				$_SESSION['kiserror'] = $cls_interface_yadon->PurchaseOrder_Synchronous($crmid,'PurchaseOrder');
				//杨锻客户特殊处理：订单下推销售确认单,当销售确认单审批通过时,需要将销售确认单中产品分录字段"销售确认时间"反写到关联的订单产品分录中对应产品的"实际销售确认时间"字段中.
				$query = " select parent_lineitem_id,entitytype,entitytypeid,sf3723 from $detailtable
					LEFT JOIN $detailtablescf on $detailtablescf.lineitem_id = $detailtable.lineitem_id 
					where id = ? ";
				$result = $adb->pquery($query,array($crmid));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					for($i = 0; $i < $num_rows; $i++){
						$parent_lineitem_id = $adb->query_result($result,$i,'parent_lineitem_id');
						$entitytype = $adb->query_result($result,$i,'entitytype');
						$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
						$sf3723 = $adb->query_result($result,$i,'sf3723');	//销售确认时间
						if($parent_lineitem_id > 0 && $entitytype == 'SalesOrder' && $entitytypeid > 0){
							$update_salesorder_date = 'update ld_salesorderdetailscf set sf3723 = ? where lineitem_id = ?';
							$adb->pquery($update_salesorder_date,array($sf3723,$parent_lineitem_id));
						}
					}
				}
			}
		}
	}
}
PurchaseOrder::require_file();
?>