<?php



// Account is used to store ld_account information.
class Stock extends CRMEntity {
     static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['Stock']='Stock';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
	public $id;
    var $Detail_table="ld_stockdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_stockdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	var $table_name = "ld_stock";
	var $table_index= 'stock_id';
    var $table_code='ware_stock_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_stock','ld_stockcf');  //查询
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_stock'=>'stock_id','ld_stockcf'=>'stock_id');
    var $relatedtab=array('stock'=>'','vendors'=>'','users'=>'','purchaseorder'=>'','products'=>'','company'=>'','vendorcontact'=>'');
    /**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_stockcf', 'stock_id');//自定义
	var $entity_table = "ld_crmentity";
	var $object_name = "Stock";
    var $module_name='Stock';
	var $new_schema = true;

	var $column_fields = Array();

	var $sortby_fields = Array('ware_stock_no','wareid','createdate','purchaseorder_id','smownerid','vendor_id','presence');    // 查询 排序

	// This is used to retrieve related ld_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'smownerid', 'opportunity_id', 'case_id', 'contact_id', 'task_id', 'note_id', 'meeting_id', 'call_id', 'email_id', 'parent_name', 'member_id' );

	// This is the list of ld_fields that are in the lists.
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
	var $default_order_by = 'stock_id';
	var $default_sort_order = 'ASC';
	//var $groupTable = Array('ld_sogrouprelation','salesorderid');

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'ware_stock_no';
    
	/** Constructor Function for SalesOrder class
	 *  This function creates an instance of LoggerManager class using getLogger method
	 *  creates an instance for PearDatabase class and get values for column_fields array of SalesOrder class.
	 */
	function __construct() {
	//	$this->log =LoggerManager::getLogger('Stock');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Stock',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Stock');
        $this->list_link_field=$entityname['fieldname'];
        
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
	   global $adb;
			//编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
             //25906: pc端 合同订单 订单编号 SO11-15626 新建合同订单 币种选择欧元 。关联创建发票 发票金额253.80欧元到合同订单已开票金额那边看
		if($this->currency_status === true)
		{
			$update_query = "update ld_stock set currency_id=?, conversion_rate=?,currency_symbol=? where stock_id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		if($_REQUEST['action'] != 'StockAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//Based on the total Number of rows we will save the product relationship with this entity
			//合同订单明细保存
            crm_load_class_file('saveInventory','include/utils');
            $saveInventoryobj=new saveInventory();
            $saveInventoryobj->save($this, 'Stock');
		}
        
        //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
	    
        //编辑单据反写付款单明细表字段
        $sendfocus = CRMEntity::getInstance('SendCashBill');
        $sendfocus->updateSourceInfo($this->id,'Stock');
        $deploy_values=getSys_deploy(48);
        if($deploy_values['deploy_value']==1&&$focus->mode!='edit')
        {
            //35924: 系统参数设置出库和入库类库单据更新库存数量的触发点 为“保存”，新建入库单 选择选择源单采购订单，保存后 入库单入库状态为“未入库”,采购订单明细界面入库状态为“已入库”，如果系统参数触
            $sql='update ld_stock set presence=? where stock_id =?';
            $adb->pquery($sql,array(ALLINSTOCK,$this->id));
        }
		
		$update_query = "update ld_stock set triggercount=triggercount+1 where stock_id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
		
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
        return ALLINSTOCK;
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

        //BUG20241121-01 ls 241121 入库单Stock单据在页面删除后，数据库中ld_stockcf、ld_stockdetailscf这2个表的数据没有同步删除
        //系统操作日志
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveDeletedRecordInfo($module,[$id]);
        require_once globalStatic::$root_directory."include/Stock/CommonStock.php";
        $sql='delete from ld_crmentity where crmid=?';
        $adb->pquery($sql,array($id));
        $sql='delete from ld_stock where stock_id=?';
        $adb->pquery('delete from ld_stockcf where stock_id=?',array($id));

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
        
    }
    
    function trackUnLinkedInfo($module, $crmid, $with_module, $with_crmid)
    {
        
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
         $this->trash('Stock',$id);        
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
		//入库单审批成功反写入库单的审核状态和审核人  (D_A_S_APPROVED:已批准)
		//require_once ('include/Stock/CommonStock.php');
        crm_load_function_file('updateStockPresence','include/Stock','CommonStock');
		updateStockPresence($record,D_A_S_APPROVED);
	}
	
	//反审批操作
	public function rejectApproved($record){
		global $adb;
		$this->Source_InveverseCompute($record,2);
	}

	//已拒绝
	public function failedApproved($record){
		$this->Source_InveverseCompute($record,1);
	}
    //生成库存流水账，反写源单已入、未入库数量  $stype 1:已拒绝  2:反审批
	private function Source_InveverseCompute($record,$stype){
		global $adb;
		//出库单审批成功反写出库单的审核状态和审核人  (D_A_S_UNAPPROVED:未提交)
		$query = 'select presence,smownerid,ld_stockdetail.productid,entitytypeid,ld_stock.entitytype,quantity,parent_lineitem_id,lineitem_id from ld_stock
					LEFT JOIN ld_stockdetail on ld_stockdetail.id = ld_stock.stock_id 
					where stock_id = ?';
	//	$result = $adb->pquery($query,array($record));
        require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
        	crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
	//	if($adb->query_result($result,0,'presence') == '已入库'){
		//	crm_load_function_file('updateStockPresence','include/Stock','CommonStock');
			updateStockPresence($record,D_A_S_UNAPPROVED);
		//}
        
     //   cls_Source_InverseCompute::Source_InveverseCompute($this->module_name,$record);
		/*$deployarray=getSys_deploy(48);//获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
		//插入流水账记录
		if($deployarray['deploy_value']== 1){
			crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i < $num_rows; $i++){
				//$warid = $adb->query_result($result,$i,'wareid');
				$smownerid = $adb->query_result($result,$i,'smownerid');
				$productid = $adb->query_result($result,$i,'productid');
				$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
				$lineitem_id =  $adb->query_result($result,$i,'lineitem_id');
				$quantity =  $adb->query_result($result,$i,'quantity');
				$entitytypeid=$adb->query_result($result,$i,'entitytypeid');//获取出库单的原单
				$entitytype=$adb->query_result($result,$i,'entitytype');
				require_once ('include/Stock/CommonStock.php');
				if($stype == 1){
					//insertCondtion($record,'审批失败',$warid,$productid,'Stock',$smownerid,0,$quantity,$parent_lineitem_id,$lineitem_id);
				}else{
					//insertCondtion($record,'审批成功',$warid,$productid,'Stock',$smownerid,$quantity,0,$parent_lineitem_id,$lineitem_id);
				}
				if($entitytypeid>0&&!in_array($entitytypeid,$exist_entitypeids))
				{
					cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
				}
				$exist_entitypeids[]=$entitytypeid;
			}
		}*/
        
	}
	//获取出库单的审核状态
	public function getStockStatus($record){
		global $adb;
        //0035422: 收款单、付款单、出库单、入库单明细界面：当关闭了该模块的审批流程之后，明细界面的审核标签应该不显示。
        return '';
		$query = 'select presence from ld_stock where stock_id = ? limit 1';
		$result = $adb->pquery($query,array($record));
		$presence = $adb->query_result($result,0,0);
		if($presence == NOTINSTOCK) {
			return 'themes/images/checked2.png';
		}else{
			return 'themes/images/checked1.png';
		}
	}
	//选择价格表
	function getPriceBooksinfo($module,$productid,$currencyid,$accvenid,$checkaccven,$focus){
		global $adb,$global_minversin;
		//单价小数位控制
		$price_sysdeploy = getSys_deploy(93);
		$price_lengthdecimaldigits  = 2;
		if(isset($price_sysdeploy['deploy_value']))
			$price_lengthdecimaldigits = $price_sysdeploy['deploy_value'];
		//数量小数位控制
		$quantity_sysdeploy = getSys_deploy(49);
		$quantity_lengthdecimaldigits  = 0;
		if(isset($price_sysdeploy['deploy_value']))
			$quantity_lengthdecimaldigits = $quantity_sysdeploy['deploy_value'];
	  
		if(isset($focus->column_fields['createdate'])){
			$datetime = 'createdate';
		}else{
			$datetime = 'createdtime';
		}
		$rowid = $_REQUEST['rowid'];
		$fldname = $_REQUEST['fldname'];
		$basemodule = 'Stock';
		$query = "SELECT
			(
				SELECT
					productname
				FROM
					ld_products
				WHERE
					productid = ".$productid."
			) AS productname,
			listprice / (
				conversion_rate / (
					SELECT
						conversion_rate
					FROM
						ld_currency_info
					WHERE
						id = ".$currencyid."
				)
			) AS trans_listprice,
			".$datetime.",
			listprice,
			ld_stockdetail.quantity,
			ld_stockdetail.comment,
			currency_symbol
		FROM
			ld_stockdetail
		INNER JOIN ld_stock ON ld_stock.stock_id = ld_stockdetail.id
		WHERE
			ld_stockdetail.productid = ".$productid."
		AND approvestatus <> '已拒绝'
		AND deleted = 0
		GROUP BY
			listprice
		ORDER BY " . $datetime . " desc ";
		$query .= " limit 5";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		$table = "";
		//title
		$table.='<div class="D_pop_tit">';
		$table.='<strong class="D_ptita">'.getFixedLabel('PRICEINFORMATION').'</strong>';
		$table.='<a href="javascript:fninvshnew(\'selectpricebokksdiv\');" class="D_ptitc">';
		$table.='<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="'.getFixedLabel('CLOSE').'" title="'.getFixedLabel('CLOSE').'"/>';
		$table.='</a></div>';
		
		$table.='<div class="D_pop_content">';
		$table.= '<p style="margin-bottom:10px;"><b>1.'.getFixedLabel('SELECTHISTORICALPRICE').'</b></p><p></p>';

		//table
		$table.='<table align="center" class="listdata" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody><tr style="background:red">';
		crm_load_class_file('ProductToolFields','include/ProductDetails');
		$productToolFields = new ProductToolFields($module);
		//列头：产品名称、不含税单价、入库日期、数量、描述
		$headers[] = $productToolFields->getModuleProductDetail_ColumnFieldlabel(getTabid($basemodule),'productname');
		$headers[] = $productToolFields->getModuleProductDetail_ColumnFieldlabel(getTabid($basemodule),'listprice');
		if(isset($focus->column_fields['createdate'])){
			$headers[] = gettranslabelfields($basemodule,'createdate');
		}else{
			$headers[] = gettranslabelfields($basemodule,'createdtime');
		}
		$headers[] = $productToolFields->getModuleProductDetail_ColumnFieldlabel(getTabid($basemodule),'quantity');
		$headers[] = $productToolFields->getModuleProductDetail_ColumnFieldlabel(getTabid($basemodule),'comment');
		foreach($headers as $header){
			$table .='<th style="background-color:#efefef"><span title="'.$header.'">' .$header . '</span></th>'; 
		}
		$table .='</tr>';
		
		//content
		if($num_rows > 0){
			for($i=0;$i<$num_rows;$i++){
				$productname = $adb->query_result($result,$i,'productname');
				$translistprice = $adb->query_result($result,$i,'trans_listprice');
				$signdata = $adb->query_result($result,$i,$datetime);
				$listprice = $adb->query_result($result,$i,'listprice');
				$quantity = $adb->query_result($result,$i,'quantity');
				$comment = $adb->query_result($result,$i,'comment');
				$currencysymbol = $adb->query_result($result,$i,'currency_symbol');
				$trans_input = '<input type="hidden" value="'.sprintf('%.'.$price_lengthdecimaldigits.'f',$translistprice).'">';
				$table .= '<tr class="lvtColData">';
				$table .= '<td>'.$productname.'</td>';
				$table .= '<td align="right"> <a onclick="fillRowListPrice(this,\''.$fldname.'\','.$_REQUEST['rowid'].')" style="cursor:pointer;">'.$currencysymbol.sprintf('%.'.$price_lengthdecimaldigits.'f',$listprice).'</a>'.$trans_input.'</td>';
				$table .= '<td><span title="'.$signdata.'">'.$signdata.'</span></td>';
				$table .= '<td align="right">'.sprintf('%.'.$quantity_lengthdecimaldigits.'f',$quantity).'</td>';
				$table .= '<td><span title='.$comment.'>'.$comment.'</span></td>';
				$table .= '</tr>';
			}
		}else{
			if(!empty($checkaccven)&&$checkaccven!='false'){
				$table .='<tr align="center">';
				$table .='<td colspan="3" bgcolor="#efefef">';
				$table .='<div class="warningTableContent" style="z-index:600;width: 50%;margin: 10px auto;">';
				$table .='<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'">';
				$table .='</div>';
				$table .='<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
				$table .='<div class="wtc_btn"></div>';
				$table .='<div></div>';
				$table .='</div>';
				$table .='</td></tr>';
			}else{
				return '$#NONERECORD#$';
			}
		}
		$table .='</tbody></tbody></table>';
			
		//2.
	//	$clickopen = 'fninvshnew(\'selectpricebokksdiv\');window.open("index.php?module=PriceBooks&action=Popup&html=Popup_picker&form=EditView&rowid='.$rowid.'&popuptype=inventory_pb&fldname='.$fldname.'&productid='.$productid.'&currencyid='.$currencyid.'","priceBookWin","width=840,height=565,resizable=1,scrollbars=1,top=150,left=200");';
	   $clickopen='StockpriceBookPickList(this,'.$_REQUEST['rowid'].')';
       	$table .='<p style="margin-top:10px"><b>2.'.getFixedLabel('SELECTPRICEBOOKS').'</b><a onclick='.$clickopen.' style="cursor:pointer;">'.getFixedLabel('VIEWPRICEBOOKS').'</a>'.'</p></div>';
		return $table;
	}
}
Stock::require_file();
?>