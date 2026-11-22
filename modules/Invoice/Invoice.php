<?php


// Account is used to store ld_account information.
class Invoice extends CRMEntity {
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['Invoice']='Invoice';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $Detail_table="ld_invoicedetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_invoicedetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = "ld_invoice";
	var $table_index= 'invoiceid';
    var $table_code='invoice_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_invoice','ld_invoicecf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_invoice'=>'invoiceid','ld_invoicecf'=>'invoiceid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_invoicecf', 'invoiceid');
    //和主表关联的模块
    var $relatedtab=array('salesorder'=>'','users'=>'','accounts'=>'','products'=>'','company'=>'','invoice'=>'');
	var $column_fields = Array();
     var $module_name='Invoice';
	var $update_product_array = Array();

	var $sortby_fields = Array('subject','invoice_no','invoicestatus','smownerid','accountname','lastname');

	// This is used to retrieve related lingdang_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );


	var $list_link_field= 'subject';

	var $search_fields = Array(
				//'Invoice No'=>Array('crmentity'=>'crmid'),
				'Invoice No'=>Array('invoice'=>'invoice_no'),
				'Subject'=>Array('purchaseorder'=>'subject'),
				);

	var $search_fields_name = Array(
				        'Invoice No'=>'',
				        'Subject'=>'subject',
				      );

	// This is the list of lingdang_fields that are required.
	var $required_fields =  array("accountname"=>1);

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'invoiceid';
	var $default_sort_order = 'ASC';
    
	//var $groupTable = Array('lingdang_invoicegrouprelation','invoiceid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');
	var $_salesorderid;
	var $_recurring_mode;

	// For Alphabetical search
	var $def_basicsearch_col = 'subject';
  
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct(){
	   //list_fields
       /**
        * edit:kevin
        * date:2013-10-11
        * reason:保存失败
        */ 
		//return LoggerManager::getLogger('Invoice');
       // $this->log =LoggerManager::getLogger('Invoice');
    
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('Invoice',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
       
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Invoice');
        $this->list_link_field=$entityname['fieldname'];
        
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}


	/** Function to handle the module specific save operations

	*/

	function save_module($module)
	{
	   global $adb;
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
		// Update the currency id and the conversion rate for the invoice
		if($this->currency_status === true)
		{
			$update_query = "update ld_invoice set currency_id=?, conversion_rate=?,currency_symbol=?,triggercount=triggercount+1 where invoiceid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		if($this->column_fields["salesorder_id"] != '')
		{
        		$so_id = $this->column_fields["salesorder_id"];
              
        		$query1 = "update ld_salesorder set sostatus='已审核' where salesorderid=?";
        		$this->db->pquery($query1, array($so_id));
		}
        /* if(isset($_REQUEST['issourcemodule']))
        {
            $query= 'update ld_invoice set entitytype = ? where invoiceid = ?';
            $this->db->pquery($query,array($_REQUEST['issourcemodule'],$this->id));
            先注释，没有看出有什么用
        }*/
		//in ajax save we should not call this function, because this will delete all the existing product values
		if(isset($this->_recurring_mode) && $this->_recurring_mode == 'recurringinvoice_from_so' && isset($this->_salesorderid) && $this->_salesorderid!='') {
			// We are getting called from the RecurringInvoice cron service!
			$this->createRecurringInvoiceFromSO();

		} else if(isset($_REQUEST)) {
			if($_REQUEST['action'] != 'InvoiceAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
					&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
			{
				//Based on the total Number of rows we will save the product relationship with this entity
				crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
                saveInventoryProductDetails($this, 'Invoice');
			}
		}


		$update_query="update ld_invoice set triggercount=triggercount+1 where invoiceid=?";
		$update_params = array($this->id);	
		$this->db->pquery($update_query,$update_params);

	    //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
        //编辑单据反写收款单明细字段
        $sendfocus = CRMEntity::getInstance('CashBill');
        $sendfocus->updateSourceInfo($this->id,'Invoice');

        //editor:gyq_70 reason:有赞微商城  2018/6/27 18:23
        //34480: （1.6登录）销售发票批量编辑：勾选多条单据点击更多中的批量编辑按钮编辑数据保存时保存不了
        require_once globalStatic::$root_directory.'appCommon/modules/Invoice/Invoice.php';
        sync_express_youzan();
        
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='zhongde'&&$_REQUEST['selectsourcename']=='CustomForm41' )
        {
            //获取负数应收单
            // @edit:dong @date:2023/10/24 @reason:  再次关联应收单 获取负应收对应的正应收 用于更新detailmincustomform41id
            $sql="select   ld_customform41.customform41id,ld_customform41detail.productid ,ld_customform41detail.lineitem_id,b.customform41id as zysid
             from ld_customform41  INNER JOIN 

                        ld_customform41detail on ld_customform41detail.id=ld_customform41.customform41id
                        inner  join   (
                         select  ld_customform41.salesorder_01,ld_invoicedetail.id,ld_invoicedetail.productid  from
                        ld_invoice 
                                            INNER JOIN   ld_invoicedetail on ld_invoice.invoiceid=ld_invoicedetail.id
                        INNER JOIN ld_customform41 on ld_customform41.customform41id=ld_invoicedetail.entitytypeid
                        where ld_invoicedetail.id=? )
                        as tmp on tmp.productid=ld_customform41detail.productid  and 
                        tmp.salesorder_01=ld_customform41.salesorder_01
						left join  ld_customform41 b on  b.salesorder_01 = ld_customform41.salesorder_01 
                        where ld_customform41.deleted=0  and ld_customform41detail.quantity<=0  group by ld_customform41.customform41id";
            $result= $adb->pquery($sql,array($this->id));

            if($adb->num_rows($result)>0)
            {
                $rows=$adb->num_rows($result);
                $customform41id_arr=[];
                for($i=0;$i<$rows;$i++)
                {
                    $productid=$adb->query_result($result,$i,'productid');
                    $customform41id=$adb->query_result($result,$i,'customform41id');
                    $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
                    $zysid=$adb->query_result($result,$i,'zysid');

                    $adb->pquery('update ld_invoicedetail set detailmincustomform41id=? where id=? and entitytypeid=? and  productid=?',array($lineitem_id,$this->id,$zysid,$productid));
                    $customform41id_arr[]=$customform41id;

                }

                $adb->pquery('set @disable_triggers ="aa"',array());
                $adb->pquery("update ld_invoice set mincustomform41id =? where invoiceid=? ",array(implode(",",$customform41id_arr),$this->id));

            }



        }
        
        
                          
	}

	/**	function used to get the name of the current object
	 *	@return string $this->name - name of the current object
	 */
	function get_summary_text()
	{
	
		return $this->name;
	}





	 public function addComboxIntoDataBase($table_name='')
    { 
         global $adb;
            //如果发票状态字段没有，则不用添加历史17386: （复地的数据库）销售发票>编辑：保存报错。
            if(!array_key_exists("invoicestatus",$this->column_fields))
            {
                    return ;
            }
		   $history_field_array = Array(
				
					"Invoice" => "invoicestatus"
				);

				$inventory_module = "Invoice";
   
				if ($_REQUEST['ajxaction'] == 'DETAILVIEW') {//if we use ajax edit
				
						$relatedname = getModuleHref('Accounts',$this->column_fields['account_id']);

					    $total = $this->column_fields['hdnGrandTotal'];
				}
				else {//using edit button and save
				
						$relatedname = $_REQUEST["account_name"];

					$total = $_REQUEST['total'];
				}
                
				if ($this->column_fields["invoicestatus"] == $app_strings['LBL_NOT_ACCESSIBLE']) {

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
			"Calendar" =>array("ld_seactivityrel"=>array("crmid","activityid"),"ld_invoice"=>"invoiceid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_invoice"=>"invoiceid"),
			"Accounts" => array("ld_invoice"=>array("invoiceid","accountid")),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'SalesOrder' || $return_module == 'Accounts' || $return_module == 'Contacts' || $return_module == 'ServiceContracts') {
			$this->trash('Invoice',$id);
		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}
    
     function trash($module,$id)
    {
        parent::trash($module,$id);
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$id);
        
    }
  
   	function restore($module, $id) {
      
      parent::restore($module,$id); 
      crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
      cls_Source_InverseCompute::Source_InveverseCompute('Invoice',$id);
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
                cls_Source_InverseCompute::Source_InveverseCompute('Invoice',$Id);
            }
        }
        
    }
    /**
     * edit:can
     * date:20140913
     * reason:获取原单
     * */
     function getSourceField($fieldname,$recordid)
     {
        global $adb;
     
        $sql = "select entitytype,entitytypeid from ld_invoicedetail where lineitem_id = ?";
       
        $result = $adb->pquery($sql,array($recordid));
        $sourceModuleInfo['module']= $adb->query_result($result,0,'entitytype');
        $sourceModuleInfo['sourceid']= $adb->query_result($result,0,'entitytypeid');
        return $sourceModuleInfo;
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
Invoice::require_file();
?>