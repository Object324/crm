<?php



// Account is used to store ld_account information.
class OutboundOrder extends CRMEntity {
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['OutboundOrder']='OutboundOrder';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
    var $Detail_table="ld_outboundorderdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_outboundorderdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
    var $module_name='OutboundOrder';
	var $table_name = "ld_outboundorder";
	var $table_index= 'out_id';
    var $table_code='out_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_outboundorder','ld_outboundordercf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_outboundorder'=>'out_id','ld_outboundordercf'=>'out_id');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_outboundordercf','out_id');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "OutboundOrder";
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('out_no','wareid','outdate','accountid','salesorderid','presence','smownerid');    // 查询 排序
    var $relatedtab=array('outboundorder'=>'','accounts'=>'','users'=>'','company'=>'','products'=>'','contacts'=>'');
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
	var $default_order_by = 'out_id';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'out_no';
    
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('OutboundOrder');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('OutboundOrder',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
          /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('OutboundOrder');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
	   global $adb;
	   	// Update the currency id and the conversion rate for the sales order
		//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        // //25906: pc端 合同订单 订单编号 SO11-15626 新建合同订单 币种选择欧元 。关联创建发票 发票金额253.80欧元到合同订单已开票金额那边看
		if($this->currency_status === true)
		{
			$update_query = "update ld_outboundorder set currency_id=?, conversion_rate=?,currency_symbol=? where out_id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		if($_REQUEST['action'] != 'OutboundOrderAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			//合同订单明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'OutboundOrder');
		}
		
		//放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
     
        //编辑单据反写收款单明细字段
        $sendfocus = CRMEntity::getInstance('CashBill');
        $sendfocus->updateSourceInfo($this->id,'OutboundOrder');
        $deploy_values=getSys_deploy(48);
        //zkt  20230407 审批通过后编辑单据也要更新库存数量 BUG0063982 订单编号：SWXA-SJJ-2303SH0211改合同界面中的已发货金额，和实际发货单中的发货金额不一致，我查了修改日志，有个发货单修改过金额，订单模块没有重算更新
        if($deploy_values['deploy_value']==1||($deploy_values['deploy_value']!=1&&$this->column_fields['approvestatus']==D_A_S_APPROVED))//出库单或入库单更新库存流水记录触发点 0：审核  1：保存
        {
			if($this->mode!='edit'){
				//35924: 系统参数设置出库和入库类库单据更新库存数量的触发点 为“保存”，新建入库单 选择选择源单采购订单，保存后 入库单入库状态为“未入库”,采购订单明细界面入库状态为“已入库”，如果系统参数触
				$sql='update ld_outboundorder set presence=? where out_id =?';
				$adb->pquery($sql,array(ALLOUTBOUND,$this->id));
			}
			$this->updateSourceModuleOutboundAmount($this->id);
        }
        /*
         if(isset($_REQUEST['account_id'])){
           $account=CRMEntity::getInstance('Accounts');
              
          $account->updateAccountInfo($module,$_REQUEST['account_id']);
          
        }*/
		
		$update_query = "update ld_outboundorder set triggercount=triggercount+1 where out_id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
	}

	//更新源单的已出库金额、未出库金额、已出库数量、未出库数量，最新出库日期
	public function updateSourceModuleOutboundAmount($record){
		global $adb;
		$sql="select entitytypeid ,entitytype from ld_outboundorderdetail where id=? and entitytypeid>0 group by entitytypeid";
		$result=$adb->pquery($sql,array($record));
		$num_rows=$adb->num_rows($result);
		for($i=0;$i<$num_rows;$i++)
		{
			$entitytypeid=$adb->query_result($result,$i,'entitytypeid');
			$entitytype=$adb->query_result($result,$i,'entitytype');
			$entityids[$entitytypeid]=$entitytype;
		}

		if(is_array($this->before_sourcemodule_info)&&sizeof($this->before_sourcemodule_info)>0)
		{
			foreach($this->before_sourcemodule_info as $index =>$datainfo)
			{
				$entityids[$datainfo['entitytypeid']]=$datainfo['entitytype'];
			}
		}
		crm_load_class_file('cls_OutSale_InverseCompute','include/OptionModule');
		foreach($entityids as $entitytypeid=>$entitytype)
		{
			cls_OutSale_InverseCompute::updateSourceModuleOutboundAmount($entitytypeid,$entitytype);
		}
       
	}
    /**
      * 获取审批状态字段
      * */
      //zkt 20220614 应该没用了，注释掉
     /*public function getApproveStatusColumnName()
     {
        return 'presence';
        
     }
      public function getApproveStatus_label()
     {
        crm_load_function_file('getLineitemModuleInfo','include/Stock','CommonStock');
        return ALLOUTBOUND;
     }*/

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
    public function restore($module, $id)
    {
        global $adb;
        parent::restore($module,$id);
        crm_load_class_file("cls_Source_InverseCompute",'include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$id);
    }
	// Function to unlink an entity with given Id from another entity
	 /**
     * 更新操作
     * edit:can
     * date:20131231
     * reason:6644: 合同订单、采购订单查看界面出库状态、入库状态存在以下问题：
     * other:出入库直接从表中删除数据
    */
    function trash($module,$id)
    {
        global $adb;
        //系统操作日志
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveDeletedRecordInfo($module,[$id]);
		require_once globalStatic::$root_directory."include/Stock/CommonStock.php";
		$sql='delete from ld_crmentity where crmid=?';
		$adb->pquery($sql,array($id));
		$sql='delete from ld_outboundorder where out_id=?';
		
		$adb->pquery($sql,array($id));
		$sql='delete from ld_approvelog where crmid=?';
		$adb->pquery($sql,array($id));
		$detailtable=$this->Detail_table;
		$detailtablescf=$this->Detail_table_scf;
		//删除明细自定义表
		$adb->pquery(" delete from $detailtablescf  where lineitem_id in(select lineitem_id from $detailtable where id=? ) ",array($id));
		//删除明细表
		$adb->pquery(" delete from $detailtable where id = ? ",array($id));
        $logcontent = $_REQUEST;
        $logcontent["deletetype"] = "rassdelete";
        cls_OperationLogs::saveLogs($module,'Delete',$id,$logcontent);
        // $adb->pquery('delete from ld_inventoryproductrelscf where id = ?',array($id));
       	//  $sql='select entitytypeid,entitytype  from ld_inventoryproductrel where id=? group by entitytypeid';
		// $result=$adb->pquery($sql,array($id));
		//批量删除massdelete.php有判断
		/* crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
		for($i=0;$i<$adb->num_rows($result);$i++)
		{
				
			$entitytypeid=$adb->query_result($result,$i,0);
			$entitytype=$adb->query_result($result,$i,1);
		
			//更新合同订单的出库状态、未出库和已出库数量
			cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
			
        }*/
        
    ///   $adb->pquery('delete from ld_inventoryproductrel where id = ?',array($id));
    }
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('OutboundOrder',$id);
  }

	public function getJoinClause($tableName) {
		if (strtolower($tableName) == 'ld_invoice_recurring_info') {
			return 'LEFT JOIN';
		}
		return parent::getJoinClause($tableName);
	}
	
	//审批成功操作
	public function successApprove($record)
	{
		global $adb;
		//出库单审批成功反写出库单的审核状态和审核人  (D_A_S_APPROVED:已批准)
		require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
		updateOutPresence($record,D_A_S_APPROVED);//更新源单出库状态

		//杨锻客户，erp对接特殊判断
		$deployarray=getSys_deploy(92);
		if(isset($deployarray['deploy_value']) && $deployarray['deploy_value'] == 0){
			if(get_versiontrade() == 'yangduan'){
				crm_load_class_file('cls_interface_yadon','include/InterfaceClass');
				$cls_interface_yadon = new cls_interface_yadon();
				$_SESSION['kiserror'] = $cls_interface_yadon->OutboundOrder_Synchronous($record,'OutboundOrder');
				//杨锻客户特殊处理：订单下推销售确认单,当销售确认单审批通过时,需要将销售确认单中产品分录字段"销售确认时间"反写到关联的订单产品分录中对应产品的"实际销售确认时间"字段中.
				$detailtable=$this->Detail_table;
                $query = " select parent_lineitem_id,entitytype,entitytypeid from $detailtable where id = ?";
				$result = $adb->pquery($query,array($record));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					for($i = 0; $i < $num_rows; $i++){
						$parent_lineitem_id = $adb->query_result($result,$i,'parent_lineitem_id');
						$entitytype = $adb->query_result($result,$i,'entitytype');
						$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
						if($parent_lineitem_id > 0 && $entitytype == 'SalesOrder' && $entitytypeid > 0){
							$s_query = "select sf3311,sf2281 from ld_salesorderdetail
								LEFT JOIN ld_salesorderdetailscf on ld_salesorderdetailscf.lineitem_id = ld_salesorderdetail.lineitem_id 
								where ld_salesorderdetail.lineitem_id= ?";
							$s_result = $adb->pquery($s_query,array($parent_lineitem_id));
							if($adb->num_rows($s_result) >= 1){
								$sf3311 = $adb->query_result($s_result,0,0);	//预计交货日期2
								$sf2281 = $adb->query_result($s_result,0,1);	//实际交货日期
								if(!empty($sf3311) && !empty($sf2281)){
									$sf6195 = 0;	//是否延期
									if($sf2281 > $sf3311){
										$sf6195 = 1;
									}
									$update_query = 'update ld_salesorderdetailscf set sf6195 = ? where lineitem_id = ?';
									$adb->pquery($update_query,array($sf6195,$parent_lineitem_id));
								}
							}
						}
					}
				}
			}
		}
		//更新源单的已出库金额、未出库金额、已出库数量、未出库数量，最新出库日期
		$deploy_values=getSys_deploy(48);
        if($deploy_values['deploy_value']!=1)
        {
			$this->updateSourceModuleOutboundAmount($record);
        }
	}
	////反审批操作
    public function rejectApproved($record)
    {
        $this-> Source_InveverseCompute($record,2);
    }
	
	//生成库存流水账，反写源单已出、未出库数量  $stype 1:已拒绝  2:反审核
	private function Source_InveverseCompute($record,$stype){
		global $adb;
		//出库单审批成功反写出库单的审核状态和审核人  (D_A_S_UNAPPROVED:未提交)
		$query = 'select presence,smownerid,ld_outboundorderdetail.productid,entitytypeid,ld_outboundorder.entitytype,
        quantity,parent_lineitem_id,lineitem_id from ld_outboundorder
					LEFT JOIN ld_outboundorderdetail on ld_outboundorderdetail.id = ld_outboundorder.out_id 
					where out_id = ?';
     
     
		//$result = $adb->pquery($query,array($record));
        	require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
		//$deployarray=getSys_deploy(48);
	//if($deployarray['deploy_value']!= 1){
		//	if($adb->query_result($result,0,'presence') == '已出库'){
			
				updateOutPresence($record,D_A_S_UNAPPROVED);
		//	}
		//}
      // 	crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
       //   cls_Source_InverseCompute::Source_InveverseCompute($this->module_name,$record);
	/*	$deployarray=getSys_deploy(48);//获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
		//插入流水账记录
		if($deployarray['deploy_value']== 1){
			crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i < $num_rows; $i++){
			//	$warid = $adb->query_result($result,$i,'wareid');
				$smownerid = $adb->query_result($result,$i,'smownerid');
				$productid = $adb->query_result($result,$i,'productid');
				$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
				$lineitem_id =  $adb->query_result($result,$i,'lineitem_id');
				$quantity =  $adb->query_result($result,$i,'quantity');
				$entitytypeid=$adb->query_result($result,$i,'entitytypeid');//获取出库单的原单
				$entitytype=$adb->query_result($result,$i,'entitytype');
				require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
				if($stype == 1){
					//insertCondtion($record,'审批失败',$warid,$productid,'OutboundOrder',$smownerid,0,$quantity,$parent_lineitem_id,$lineitem_id);
				}else{
					//insertCondtion($record,'审批成功',$warid,$productid,'OutboundOrder',$smownerid,$quantity,0,$parent_lineitem_id,$lineitem_id);
				}
				if($entitytypeid>0&&!in_array($entitytypeid,$exist_entitypeids))
				{
					cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
				}
				$exist_entitypeids[]=$entitytypeid;
			}
		}*/
       
		//更新源单的已出库金额、未出库金额、已出库数量、未出库数量，最新出库日期
		$deploy_values=getSys_deploy(48);
        if($deploy_values['deploy_value']!=1)
        {
			$this->updateSourceModuleOutboundAmount($record);
        }
	}
	//已拒绝
	public function failedApproved($record){
		
		$this-> Source_InveverseCompute($record,1);
	}
	//获取出库单的审核状态
	public function getOutStatus($record){
	   //0035422: 收款单、付款单、出库单、入库单明细界面：当关闭了该模块的审批流程之后，明细界面的审核标签应该不显示。
	   return ;
		global $adb;
		$query = 'select presence from ld_outboundorder where out_id = ? limit 1';
		$result = $adb->pquery($query,array($record));
		$presence = $adb->query_result($result,0,0);
		if($presence == NOTOUTBOUND) {
			return 'themes/images/checked2.png';
		}else{
			return 'themes/images/checked1.png';
		}
	}
	//判断单据的负库存出库
	public function getInventoryProductForWareQty($record){
		global $adb;
        //查找出结果，只有在approve.php中用到该函数2019-04-15
        $detailtable=$this->Detail_table;
		$query = " select productid,quantity from $detailtable where id = ? ";
		$result = $adb->pquery($query,array($record));
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			for($i = 0; $i<$num_rows; $i++){
				$productid = $adb->query_result($result,$i,'productid');
				$quantity = $adb->query_result($result,$i,'quantity');
				$db_productinfos[$productid] = $quantity;
				$productids[] = $productid;
			}
		}
		$query = 'select productid,ifnull(qtyinstock,0) as qtyinstock,productname from ld_products where productid in ('.implode(',',$productids).') and deleted = 0';
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			$err_info = '';
			$k = 1;
			for($i = 0; $i<$num_rows; $i++){
				$productid = $adb->query_result($result,$i,'productid');
				$qtyinstock = $adb->query_result($result,$i,'qtyinstock');
				$productname = $adb->query_result($result,$i,'productname');
				if($db_productinfos[$productid] > $qtyinstock){
					return 'yes';
				}
			}
		}
		return 'no';
	}

	public function  getQuotesForPotentials($potentials_id){
		global $adb;
		if(!empty($potentials_id)){
			$query = '
				select GROUP_CONCAT(ld_quotesdetail.lineitem_id) from ld_quotes
				LEFT JOIN ld_quotesdetail on ld_quotesdetail.id = ld_quotes.quoteid 
				where potentialid = ? and deleted <> 1 limit 1';
			$result = $adb->pquery($query,array($potentials_id));
			return $adb->query_result($result,0,0);
		}
		return 0;
	}
	
	//扫码行业：录入的产品是否有合同订单之前的产品，录入的产品数量（按照产品ID汇总统计）是否超出订单中相应产品的数量。
	public function setSaveForSalesOrderCheck($salesorderid,$productid_str,$quantity_str){
		global $adb;
		//条件1：ld_version.trade='sweepbarcode 
		//条件2：库存参数设置为严格参照源单
		//条件3：关闭出库单现有选择源单字段，新增单选“合同订单”的字段
		//条件4：出库单有选择合同订单
		$versiontrade=getVersionTradeInfo();
		$deployarray=getSys_deploy(10);	//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否
		$focus = CRMEntity::getInstance('OutboundOrder');
		$moduleFields = $focus->fieldobj->getModuleFields();
		$field = $moduleFields['salesorder_id'];
		$error='';
		if($versiontrade['trade'] == 'sweepbarcode' && $deployarray['deploy_value'] != 1 && !empty($moduleFields['salesorder_id']) && empty($moduleFields['selectlistval']) && $salesorderid > 0){
			$quantityarr=explode(',',$quantity_str);
			$productids=$productid_str;
			$productidarr=explode(",",$productids);
			$salesorder_id=$salesorderid;
			foreach($productidarr as $key => $prdid){
				$prd_qty[$prdid] += $quantityarr[$key];
				$sel_prdid[] = $prdid;
			}
			$query = "select productname,productid from ld_products where productid in(".implode(',',$sel_prdid).") and deleted = 0";
			$result=$adb->pquery($query,array());
			$rows=$adb->num_rows($result);
			for($i=0;$i<$rows;$i++)
			{
				$productid=$adb->query_result($result,$i,'productid');
				$dbproductnames[$productid]=$adb->query_result($result,$i,'productname');
			}
			$entityarray = getEntitynameInfo(getTabid('SalesOrder'));
			$tabname = $entityarray['tablename'];//模块主表
			$tabfieldname = $entityarray['fieldname'];//模块链接字段
			$sql="select ld_salesorderdetail.productid,sum(quantity) as qty,$tabname.$tabfieldname,ld_products.productname from ld_salesorderdetail 
			LEFT JOIN ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id
			LEFT JOIN ld_salesordercf on ld_salesordercf.salesorderid = ld_salesorder.salesorderid
			inner join ld_products on ld_products.productid=ld_salesorderdetail.productid 
			where ld_salesorderdetail.id = ? GROUP BY ld_salesorderdetail.productid";
			$result=$adb->pquery($sql,array($salesorder_id));
			$rows=$adb->num_rows($result);
			$db_info=array();
			for($i=0;$i<$rows;$i++)
			{
				$module_linkvalue = $adb->query_result($result,$i,$tabfieldname);
				$productid=$adb->query_result($result,$i,'productid');
				$qty=$adb->query_result($result,$i,'qty');
				$db_info[$productid]=$qty;
				$dbproductnames[$productid]=$adb->query_result($result,$i,'productname');
			}
			foreach($prd_qty as $productid => $quantity){
				if(array_key_exists($productid,$db_info)){
					if($quantity > $db_info[$productid]){
						//$error.='【'.$dbproductnames[$productid].'】数量超出订单【'.$module_linkvalue.'】中的数量！<br>';
                        $error.= sprintf(getFixedLabel('QUANTITYEXCEEDSINORDER'),$dbproductnames[$productid],$module_linkvalue).'<br>';
					}
				}else{
					//$error.='【'.$dbproductnames[$productid].'】在订单【'.$module_linkvalue.'】中不存在！<br>';
                    $error.= sprintf(getFixedLabel('DOESNOTEXISTINORDER'),$dbproductnames[$productid],$module_linkvalue).'<br>';
				}
			}
		}
		
		return $error;
	}
    
    
    /**
     * edit:can 2020-08-27
     * 中孚
     * */
    public function getcf_2444_Image()
    {
        $focus=$this;
        if(empty($this->id))
        {
            return '';
        }
        if($focus->column_fields['cf_2444']=='已签回')//是否签回
        {
            return 'zf_cf_2444_finished.png';
            
        }
        else if($focus->column_fields['cf_2444']=='未签回')
        {
            return 'zf_cf_2444.png';
        }
        
    }

    //lqt 20230531 中孚出库单状态标签
    public function getcf_2444_Tag(){
        $focus=$this;
        if(empty($this->id)) {
            return '';
        }
        if($focus->column_fields['cf_2444']=='已签回') {
            return '<span class="ld-tags tag-red">已签回</span>';
        }
        else if($focus->column_fields['cf_2444']=='未签回') {
            return '<span class="ld-tags tag-black">未签回</span>';
        }
    }    
}
OutboundOrder::require_file();
?>