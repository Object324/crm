<?php
class BudgetChange extends CRMEntity{
        var $Detail_table="ld_budgetchangedetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_budgetchangedetailscf";//明细scf表
    var $Detail_table_index="id";//明细表和主表关联的字段
    var $table_name = "ld_budgetchange";
	var $table_index= 'budgetchangeid';//主表主键
    var $table_code='budgetchange_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_budgetchange','ld_budgetchangescf');
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_budgetchange'=>'budgetchangeid','ld_budgetchangescf'=>'budgetchangeid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_budgetchangescf', 'budgetchangeid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    
	var $column_fields = Array();
	public  $module_name='BudgetChange';
 //和主表关联的模块
    //打印管理模块
    var $relatedtab=array('budget'=>'', 'budgetchange'=>'', 'users'=>'','potential'=>'','contacts'=>'','accounts'=>'','products'=>'','company'=>'');
    

	var $sortby_fields = Array('budgetchange_no','smownerid');
    
	
	var $list_link_field= 'budgetchange_no';

	var $search_fields = Array(
			'Budgetchange No'=>array('ld_budgetchange'=>'budgetchange_no')
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
	var $def_basicsearch_col = 'budgetchange_no';
    var $popup_fields=Array();
    var $detailfieldobj;//明细表字段对象
    function __construct() {
		//$this->log =LoggerManager::getLogger('Expense');
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('BudgetChange',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      
             /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('BudgetChange');
        $this->list_link_field=$entityname['fieldname'];
        
        $this->popup_fields=Array($this->list_link_field);
        $this->module_name='BudgetChange';
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
	}
  
   
    function  save_module($module) 
    { 
        global $adb,$current_user;
		if($this->currency_status === true)
		{
			$update_query = "update ld_budgetchange set currency_id=?, conversion_rate=?,currency_symbol=? where budgetchangeid=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		if($_REQUEST['action'] != 'BudgetChangeAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			//明细保存
            crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'BudgetChange');
		}
		if(!empty($_REQUEST['customform14_id']) && !empty($_REQUEST['change_type'])){
			$customform14_id = $_REQUEST['customform14_id'];
			if($_REQUEST['change_type'] == 'add'){
				$change_type = '追加';
			}else if($_REQUEST['change_type'] == 'edit'){
				$change_type = '修改';
			}else{
				$change_type = '更换';
			}
			$so_module = getSalesEntityType($customform14_id);
			$so_focus = CRMEntity::getInstance($so_module);
			$so_focus->mode = 'edit';
			$so_focus->id = $customform14_id;
			$so_focus->retrieve_entity_info($customform14_id,$so_module);
			$query = 'update ld_budgetchange set change_type = ?,accountid = ?,customform14id = ? where budgetchangeid = ?';
			$this->db->pquery($query,array($change_type,$so_focus->column_fields['account_id'],$customform14_id,$this->id));
            
		}
        
        if(empty($customform14_id))
        {
            $customform14_id = $this->column_fields['customform14id'];
        }
        $query = 'update ld_budgetchangedetail set entitytypeid = ? where id = ?';
        $this->db->pquery($query,array($customform14_id,$this->id));
    }
    
    //获取成本预算单和预算变更单(追加)产品明细信息
	function getInventoryProducts_info($customform14_id){
		global $adb;
		$from_focus=CRMEntity::getInstance('CustomForm14');
		$approve_demand= $from_focus->get_approve_demand_byModule('BudgetChange');	// 审批要求 0 无  1已批准
		if($approve_demand == 1){
			$approve_sql = ' and approvestatus = "'.constant('D_A_S_APPROVED').'"';
		}
		$query = 'select ld_products.productid,ld_products.productname,lineitem_id,change_type,parent_lineitem_id,tp.approvestatus,sum(quantity) as quantity  from (
			select ld_customform14detail.productid,lineitem_id,\'追加\' as change_type,parent_lineitem_id,
            ld_customform14.approvestatus,quantity from ld_customform14detail
			LEFT JOIN ld_customform14 ON ld_customform14.customform14id = ld_customform14detail.id where   id = ? '. $approve_sql.' 
			
		) as tp LEFT JOIN ld_products on ld_products.productid = tp.productid GROUP BY lineitem_id ORDER BY tp.lineitem_id asc';
		$result = $adb->pquery($query,array($customform14_id));
        
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
			$query = 'select ld_products.productid,ld_products.productname,lineitem_id,id from ld_customform14detail
				LEFT JOIN ld_products on ld_products.productid = ld_customform14detail.productid
				where ld_customform14detail.lineitem_id = ?';
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
		$this->trash('BudgetChange',$id);
    }
    
    /**
     * 审批已批准执行操作函数
     * edit:zkt
     * date:20220307
     */
    public function successApprove($record)
    {
        //审批成功后反写分录信息至成本预算清单
        $budgetchange_id = $record;
        $budget_module = 'BudgetChange';
        $budget_focus = CRMEntity::getInstance($budget_module);
        $budget_focus->mode = 'edit';
        $budget_focus->id = $budgetchange_id;
        $budget_focus->retrieve_entity_info($budgetchange_id,$budget_module);
        
        $change_type = $budget_focus->column_fields['change_type'];
        $change_type = $this->getChangeType($change_type);
        $customform14_id = $budget_focus->column_fields['customform14_id'];
        
        
        $so_module = 'CustomForm14';//getSalesEntityType($customform14_id);
        $so_focus = CRMEntity::getInstance($so_module);
        $so_focus->mode = 'edit';
        $so_focus->id = $customform14_id;
        $so_focus->retrieve_entity_info($customform14_id,$so_module);
        
        
        //成本预算单(customform14)-获取已有产品列表
        $oldproductDetailsData =   $this->getmoduleproductdetail($so_focus);
        //获取成本预算单-parent_lineitem_id
        $oldproductparent_lineitem_id = 0;
        if(!empty($oldproductDetailsData))
        {
            //$oldproductparent_lineitem_id = $oldproductDetailsData[0]['parent_lineitem_id'];
        }
        //预算变更单-获取已有产品列表
        $addproductDetailsData =   $this->getmoduleproductdetail($budget_focus);
        //数组合并
        
        $productsdetailarr = array();
        $productidarr = array();
        foreach($producttoolfieldsvaluearr as $productdeatail){
            $productidarr[] = $productdeatail['productid'];
        }
        
        $languageType= getLanguageType($current_user);
        $ProductToolFields = ProductToolFields::getInstance($so_module);   
        $ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
        
        //成本预算单分录保存至数据库字段
        $savecolumnarray = array();
        $savecolumntorequestnamearray = array();
        $savecolumntorequestnamearray['lineitem_id'] = 'before_lineitem_id';
        $savecolumntorequestnamearray['parent_lineitem_id'] = 'lineitem_id';
        $savecolumnarray[]='lineitem_id';
        $savecolumnarray[]='parent_lineitem_id';
        foreach($ProductToolFieldsInfo as $fieldInfo){
        	$columnname = $fieldInfo->getColumnName();
        	$tablename = $fieldInfo->getTableName();
            $fieldname = $fieldInfo->getFieldName();
            
        	//uitype = 70产品名称
        	if($fieldInfo->getUIType() == 70){
                $savecolumnarray[] = 'productid';
                $savecolumntorequestnamearray['productid'] = 'hdnProductId';
        	}
           
        	$typeofdata = explode('~',$fieldInfo->getTypeOfData());
        	//允许编辑和有字段公式的自定义字段都可以保存到数据库里
        	if($fieldInfo->getSaveDataBase() == 'yes' || ($module == 'Checks' && $columnname == 'paperquantity') || $columnname == 'contractid' || $columnname=='lasttaxprice' || $columnname=='lastlistprice' || $columnname=='pro_id'){
        		if(strtolower($tablename) == $so_focus->Detail_table||strtolower($tablename) ==$so_focus->Detail_table_scf){
                    $savecolumnarray[] = $columnname;
                    $savecolumntorequestnamearray[$columnname] = $fieldname;
        		}
        	}
        }
     
        //
        if($change_type == 'add')
        {
            //增加时将分录数组合并
            $productsdetailarr = $oldproductDetailsData;
            foreach($addproductDetailsData as $tmpproductdateinfo)
            {
                //预算变更单 parent_lineitem_id 为成本预算单中的 lineitem_id 
                $tmpproductdateinfo['lineitem_id'] = $tmpproductdateinfo['parent_lineitem_id'];
                $tmpproductdateinfo['parent_lineitem_id'] = $oldproductparent_lineitem_id;
                
                $productsdetailarr[] =$tmpproductdateinfo;
            }
            
        }
        else if($change_type == 'replace')//更换
        {
            //修改时将修改的分录进行修改
            $productsdetailarr = $oldproductDetailsData;
            foreach($addproductDetailsData as $tmpproductdateinfo)
            {
                //预算变更单 parent_lineitem_id 为成本预算单中的 lineitem_id 
                $tmpproductdateinfo['lineitem_id'] = $tmpproductdateinfo['parent_lineitem_id'];
                $tmpnewlineitem_id = $tmpproductdateinfo['parent_lineitem_id'];
                foreach($productsdetailarr as $tmpindex =>$tmpnewprodcutdateinfo)
                {
                    if($tmpnewprodcutdateinfo['lineitem_id'] ==$tmpnewlineitem_id)
                    {
                        foreach($tmpnewprodcutdateinfo as $tmpcolumnname =>$tmpvalue)
                        {
                            if($tmpcolumnname == 'lineitem_id')
                            {
                                continue;
                            }
                            else if($tmpcolumnname == 'parent_lineitem_id')
                            {
                                continue;
                            }
                            else if(isset($tmpproductdateinfo[$tmpcolumnname]))
                            {
                                $tmpnewprodcutdateinfo[$tmpcolumnname] = $tmpproductdateinfo[$tmpcolumnname];
                            }
                            else
                            {
                                unset($tmpnewprodcutdateinfo[$tmpcolumnname]);
                            }
                        }
                        $productsdetailarr[$tmpindex] =$tmpnewprodcutdateinfo;
                        break;
                    }
                    else
                    {
                        continue;
                    }
                }
            }
        }
        else if($change_type == 'edit')//修改
        {
            $productsdetailarr = $oldproductDetailsData;
            foreach($addproductDetailsData as $tmpproductdateinfo)
            {
                //预算变更单 parent_lineitem_id 为成本预算单中的 lineitem_id 
                $tmpproductdateinfo['lineitem_id'] = $tmpproductdateinfo['parent_lineitem_id'];
                $tmpnewlineitem_id = $tmpproductdateinfo['parent_lineitem_id'];
                foreach($productsdetailarr as $tmpindex =>$tmpnewprodcutdateinfo)
                {
                    if($tmpnewprodcutdateinfo['lineitem_id'] ==$tmpnewlineitem_id)
                    {
                        foreach($tmpnewprodcutdateinfo as $tmpcolumnname =>$tmpvalue)
                        {
                            if($tmpcolumnname == 'lineitem_id')
                            {
                                continue;
                            }
                            else if($tmpcolumnname == 'parent_lineitem_id')
                            {
                                continue;
                            }
                            else if(isset($tmpproductdateinfo[$tmpcolumnname]))
                            {
                                $tmpnewprodcutdateinfo[$tmpcolumnname] = $tmpproductdateinfo[$tmpcolumnname];
                            }
                            else
                            {
                                unset($tmpnewprodcutdateinfo[$tmpcolumnname]);
                            }
                        }
                        $productsdetailarr[$tmpindex] =$tmpnewprodcutdateinfo;
                        break;
                    }
                    else
                    {
                        continue;
                    }
                }
            }
        }
        else {
            return ;
        }
        
        $saveproductdetailarr = array();
        $savetotal = 0;
        $savesubtotal = 0;
        foreach($productsdetailarr as $tmpdetailinfo)
        {
            //这里要保证两个模块的对应字段的column相同，不然需要转换
            $tmpsavedetailarr = array();
            foreach($savecolumnarray as $tmpcolumn)
            {
                $tmpsavedetailarr[$tmpcolumn] = $tmpdetailinfo[$tmpcolumn];
            }
            //设置设置合同信息
            if(empty($tmpsavedetailarr['contractid']))
            {
                $tmpsavedetailarr['contractid'] = '0';
            }
            //设置设置预算金额
            if(empty($tmpsavedetailarr['sf2446'])&&!empty($tmpsavedetailarr['actualtaxprice']))
            {
                $tmpsavedetailarr['sf2446'] = (float)$tmpsavedetailarr['actualtaxprice']*(float)$tmpsavedetailarr['quantity'];
            }
            //获取小计、合计
            if(!empty($tmpsavedetailarr['tax_amount']))
            {
                $savesubtotal += (float)$tmpsavedetailarr['tax_amount'];
            }
            $saveproductdetailarr[] =  $tmpsavedetailarr;
            
        }
        
        $savetotal = $savesubtotal;
        
        //设置request值
        $saverowcut = count($saveproductdetailarr);
        $_REQUEST['rowcnt'] = $saverowcut;
        $i = 1;
        foreach($saveproductdetailarr as $tmpdetails)
        {
            foreach($savecolumntorequestnamearray as $tmpcolumn=>$tmpfieldname)
            {
                $_REQUEST[$tmpfieldname.$i] = $tmpdetails[$tmpcolumn];
            }
            $i ++;
        }
        
        $_REQUEST['total'] = $savetotal;
        $_REQUEST['subtotal'] = $savetotal;
           
        
        //明细保存
        crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
        saveInventoryProductDetails($so_focus, 'CustomForm14');
         //dump($_REQUEST);
        
    }
    
    ///获取单据产品分录保存数据库信息
    function getmoduleproductdetail($focus){
        global $adb,$current_user,$weixin_user;
        
        //单据id不能为空
        if(empty($focus->id)){
            return array();
        }
        $record = $focus->id;
        $module = $focus->module_name;
        $tabid = getTabid($module);
        $languageType= getLanguageType($current_user);
        $char = 'V';
        //分录表名和主键
        $Detail_table=$focus->Detail_table;
        $Detail_table_scf=$focus->Detail_table_scf;
        $Detail_table_id=$focus->Detail_table_id;
        $Detail_table_index=$focus->Detail_table_index;
        //分录字段信息
        $ProductToolFields = ProductToolFields::getInstance($module);   
    	$ProductToolFieldsInfo = $ProductToolFields->getModuleProductToolField($tabid,$languageType);
        
        $db_value = array();
        
        foreach($ProductToolFieldsInfo as $fieldInfo){
    		$columnname = $fieldInfo->getColumnName();
    		$tablename = $fieldInfo->getTableName();
            
    		//uitype = 70产品名称
    		if($fieldInfo->getUIType() == 70){
                $productdetail_columns[] = 'productid';
                $productdetail_column_sql[] =  'ld_products.productid';
    		}
           
    		$typeofdata = explode('~',$fieldInfo->getTypeOfData());
    		//允许编辑和有字段公式的自定义字段都可以保存到数据库里
    		if($fieldInfo->getSaveDataBase() == 'yes' || ($module == 'Checks' && $columnname == 'paperquantity')
             || $columnname == 'contractid' || $columnname=='lasttaxprice' || $columnname=='lastlistprice' || $columnname=='pro_id'){
    			if(strtolower($tablename) == $Detail_table||strtolower($tablename) ==$Detail_table_scf){
                    $productdetail_columns[] = $columnname;
                    $productdetail_column_sql[] =  $tablename. '.' . $columnname;
    			}
    		}
    	}
        
        //读取上一版本的数据
        $productdetail_column_sql[] = $focus->table_name.'.total';
        if(!empty($productdetail_column_sql) && $record>0){
    		$productdetail_column_sql[] = $Detail_table.'.'.$Detail_table_id;
            $productdetail_column_sql[] = $Detail_table.'.parent_lineitem_id';
    		$query = 'select ' . implode(',',$productdetail_column_sql) . ' from '.$Detail_table." 
    		LEFT JOIN $Detail_table_scf on $Detail_table_scf.$Detail_table_id = $Detail_table.$Detail_table_id 
    		LEFT JOIN ld_products on ld_products.productid = $Detail_table.productid 
    		LEFT JOIN ld_productcf on ld_productcf.productid = ld_products.productid 
    		LEFT JOIN ".$focus->table_name.' on '.$focus->table_name.'.'.$focus->table_index." = $Detail_table.$Detail_table_index
    		where $Detail_table.$Detail_table_index = ?";
    		$result = $adb->pquery($query,array($record));
            
    		$data_num = $adb->num_rows($result);
            $total = 0;
    		for($i = 0; $i<$data_num; $i++){
                $db_value_line = array();
    			$lineitem_id = $adb->query_result($result,$i,$Detail_table_id);
                $parent_lineitem_id = $adb->query_result($result,$i,'parent_lineitem_id');
                $db_value_line['lineitem_id'] = $lineitem_id;
                $db_value_line['parent_lineitem_id'] = $parent_lineitem_id;
                foreach($productdetail_columns as $columnname){
    			    $value = $adb->query_result($result,$i,$columnname);
                    if($value==0 && $columnname=='entitytypeid'){
                        $value = '';
                    }
                    if($columnname == 'tax_amount'){
                        $total += $value;
                    }
    				$db_value_line[$columnname] = $value;
    			}
                //移动端返回值中缺少entitytypeid,从parent_lineitem_id获取
            	if(!empty($weixin_user)&&$parent_lineitem_id>0&&!empty($db_value[$lineitem_id]['entitytype'])){
            		$info = getLineitemModuleInfo($parent_lineitem_id,$db_value[$lineitem_id]['entitytype']);
            		$db_value_line['entitytypeid'] = $info['id'];
            	}else{
            		$db_value_line['entitytype']='';
                    $db_value_line['entitytypeid']='';
            	}
                $db_value[]=$db_value_line;
    		}
            
                        
    	}
        return $db_value;
    }
   
}
?>