<?php
class Products extends CRMEntity {
	var $db, $log; // Used in class functions of CRMEntity
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['Products']='Products';
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
        {
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            include("modules/$requiremodules/$requiremodules.php");
        }
    }
	var $table_name = 'ld_products';
    var $Detail_table = 'ld_productdetail';
    var $Detail_table_id = 'lineitem_id';
	var $table_index= 'productid';
	var $Detail_table_index = 'productid';
    var $table_code='product_no';//表编号字段(审批中心)
    var $column_fields = Array();
    var $module_name='Products';
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_productcf','productid');

	var $tab_name = Array('ld_crmentity','ld_products','ld_productcf','ld_shop_productproperty');

	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_products'=>'productid','ld_productcf'=>'productid','ld_seproductsrel'=>'productid','ld_producttaxrel'=>'productid','ld_shop_productproperty'=>'productid');

    //reason:打印关联模块
    var $relatedtab=array('vendors'=>'','users'=>'','company'=>'','products'=>'');

    public $mass_edit_cur;


    /** Function to get image count for a given product
    * @param $id -- product id :: Type integer
    * @returns count -- count:: Type integer
    */

    static  function getImageCount($id)
    {
    	
    	global $adb;
    	$image_lists=array();
    	$query="select imagename from ld_products where productid=?";
    	$result=$adb->pquery($query, array($id));
    	$imagename=$adb->query_result($result,0,'imagename');
    	$image_lists=explode("###",(string)$imagename);
    
    	return count($image_lists);
    
    }
    var $list_link_field= 'productname';

	var $search_fields = Array(
		'Product Name'=>Array('products'=>'productname'),
		'Part Number'=>Array('products'=>'productcode'),
		'Unit Price'=>Array('products'=>'unit_price')
	);
	var $search_fields_name = Array(
		'Product Name'=>'productname',
		'Part Number'=>'productcode',
		'Unit Price'=>'unit_price'
	);

    var $required_fields = Array(
            'productname'=>1
    );

	// Placeholder for sort fields - All the fields will be initialized for Sorting through initSortFields
	var $sortby_fields = Array();
	var $def_basicsearch_col = 'productname';

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'productname';
	var $default_sort_order = 'ASC';

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to lingdang_field.fieldname values.
	var $mandatory_fields = Array('createdtime', 'modifiedtime', 'productname', 'assigned_user_id');
	 // Josh added for importing and exporting -added in patch2
    var $unit_price;
    
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('product');
		//$this->log->debug("Entering Products() method ...");
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Products',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
		$entityname=getEntitynameByModulename('Products');
        $this->list_link_field=$entityname['fieldname'];

        //zxm 20241010 产品属性
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
	}

	function save_module($module)
	{
	   global $adb;
		//Inserting into product_taxrel table
		//$_REQUEST['create_view']App产品保存
		if($_REQUEST['ajxaction'] != 'DETAILVIEW' && $_REQUEST['action'] != 'MassEditSave'
        && $_REQUEST['action'] != 'ProcessDuplicates' && $_REQUEST['create_view']='create_view'
        &&$_REQUEST['file'] != 'MassEditSave')
		{
		  //edit:can 20210702 046674: （81mis.com/kfbcrm）工具-产品管理，先操作编辑产品的税别并保存，然后列表界面批量编辑产品，产品税别成空值了
		  
			$this->insertTaxInformation('ld_producttaxrel', 'Products');
			$this->insertPriceInformation('ld_productcurrencyrel', 'Products');
            //34797: 新建账套-产品管理，使用小编辑功能编辑产品信息，会导致产品图片丢失
            $this->insertIntoAttachment($this->id,'Products');
		}

		// Update unit price value in ld_productcurrencyrel
		//230726 wym XUQIU1000102 批量编辑不调该方法:产品报价添加了更多币种编辑，参考价不需要再更新为产品报价
		if(!$this->mass_edit_cur){
            $this->updateUnitPrice();
        }
		//Inserting into attachments
		

		/**
		 * 判断产品更多信息新增产品时，添加两个产品的关联
		 * @reason 0008464 产品更多信息新增产品未关联
		 * @author Tujt 2014-05-04
		 */
		if($this->mode == '' && $_REQUEST['return_module'] == 'Products' && $_REQUEST['product_id'] > 0){
			$insert = 'insert into ld_seproductsrel(crmid,productid,setype) values('.$this->id.','.$_REQUEST['product_id'].',"Products") ';
			$this->db->query($insert);
			//echo 'create product rel';echo '<br><br>';die;
		}
		$_REQUEST['return_mdoule']="Products";
        $_REQUEST['return_id']=$this->id;
        
        
        /**********判断基金行业并且是凯银数据库时，同步产品 begin************/
        /**
         * edit:diony
         * time:2014-12-05 
         * 凯银同步产品，只有当产品类别为基金时，才会同步，凯银产品类别字段为cf_1387
        */ 
        if(get_versiontrade()=='fund' && get_versionaccount()=='kylin')
        {
            //echo '我进来了';
            //echo '<br>';
            if($this->column_fields['cf_1387'] == '基金')
            {
                include('include/trade/fund/kylin.php');
                project_kylin::products_add($this);
            }
        }
        if(vtlib_isModuleActive("Management")&&array_key_exists("fund_manager",$this->column_fields))
        {
            //基金行业
            $update="update ld_fund_management INNER JOIN ld_products
            on ld_products.productid=ld_fund_management.product_id
            set ld_fund_management.fund_manager=ld_products.fund_manager 
            where ld_products.productid=?";
            
            $adb->pquery($update,array($this->id));
        
        }
        
        if(isset($this->column_fields['productstatus'])){
            $newproductstatus = $this->column_fields['productstatus'];
            $query = "select * from ld_shop_productproperty where productid = ?";
            $result = $adb->pquery($query,array($this->id));
            $oldproductstatus = '';
            $num_rows = $adb->num_rows($result);
            if($num_rows>0){
                $oldproductstatus = $adb->query_result($result,0,'productstatus');
                $upquery = "update ld_shop_productproperty set productstatus = ? ";
                //商品状态由非上架状态变为“上架”，修改上架时间为当前时间
                if($newproductstatus == constant('PUTON_SHELF') && $oldproductstatus != constant('PUTON_SHELF')){
                    $putontime = date('Y-m-d H:i:s',time());
                    $upquery .= " , putontime = ?";
                }
                $upquery .= " where productid = ?";
                if(isset($putontime)&&!empty($putontime)){
                    $adb->pquery($upquery,array($newproductstatus,$putontime,$this->id));
                }
                else{
                    $adb->pquery($upquery,array($newproductstatus,$this->id));
                }
            }
            else{
                //商品状态变为“上架”，修改上架时间为当前时间
                if($newproductstatus == constant('PUTON_SHELF')){
                    $upquery = "insert into ld_shop_productproperty (productid,productstatus,putontime) values (?,?,?)";
                    $putontime = date('Y-m-d H:i:s',time());
                    $adb->pquery($upquery,array($this->id,$newproductstatus,$putontime));
                }
                else{
                    $upquery = "insert into ld_shop_productproperty (productid,productstatus) values (?,?)";
                    $adb->pquery($upquery,array($this->id,$newproductstatus));
                }
                
            }
            
        }

        //exit();
        /**********判断基金行业并且是凯银数据库时，同步产品 end************/

        //保存明细 zxm 20240930
        if(!$this->mass_edit_cur) {
            $this->Savedetail();
        }
	}
    public function Savedetail(){
        global $adb;
        $productsDetail = $_REQUEST['productsDetail'];
        $isDuplicate = $_REQUEST['isDuplicate'];//是否是复制
        $productsDetail_arr = Zend_Json::decode($productsDetail);

        $lineitem_id_arr = [];
        $new_lineitemid = [];

        //ld_productcurrencyrel 价格多币种的数据存储 先删除再insert
        $delete_sql = "delete from ld_productcurrencyrel where productid=? and lineitem_id>0 ";
        $adb->pquery($delete_sql, array($this->id));
        foreach($productsDetail_arr as $k=>$tmpProductDetail) {
            if($tmpProductDetail['selected']==0){
                continue;
            }
            $tmp_lineitem_id = $tmpProductDetail['lineitem_id'];
            $tmp_attribute_combination = $tmpProductDetail['attribute_combination'];//属性组合
            if ($tmp_lineitem_id > 0 && $isDuplicate!= true) {
                //update
                $update_sql = " update ld_productdetail set property_value_name_combin=?,sequence=?,line_unit_price=?,line_procostprice=?,line_qtyearly=?,line_status=?,setdefault=?,line_productcode=? where productid=? and lineitem_id=?";
                $adb->pquery($update_sql, array(
                    $tmpProductDetail['property_value_name_combin'],
                    $tmpProductDetail['sequence'],
                    $tmpProductDetail['line_unit_price'],
                    $tmpProductDetail['line_procostprice'],
                    $tmpProductDetail['line_qtyearly'],
                    $tmpProductDetail['line_status'],
                    $tmpProductDetail['setdefault'],
                    $tmpProductDetail['line_productcode'],
                    $this->id,
                    $tmp_lineitem_id
                ));
                //print_r($update_sql);
                /*print_r(array(
                    $tmpProductDetail['property_value_name_combin'],
                    $tmpProductDetail['sequence'],
                    $tmpProductDetail['line_unit_price'],
                    $tmpProductDetail['line_procostprice'],
                    $tmpProductDetail['line_qtyearly'],
                    $tmpProductDetail['line_status'],
                    $tmpProductDetail['line_productcode'],
                    $this->id,
                    $tmp_lineitem_id
                ));*/
                $delete_p2psql = " delete from ld_productdetail2propertydetail where productdetail_lineitem_id=? ";
                $adb->pquery($delete_p2psql, array($tmp_lineitem_id));

            } else {
                //insert
                $insert_sql = " insert into ld_productdetail (productid,property_value_name_combin,sequence,line_unit_price,line_procostprice,line_qtyearly,line_status,setdefault,line_productcode) values (?,?,?,?,?,?,?,?,?);";
                $insert_params = [
                    $this->id,
                    $tmpProductDetail['property_value_name_combin'],
                    $tmpProductDetail['sequence'],
                    $tmpProductDetail['line_unit_price'],
                    $tmpProductDetail['line_procostprice'],
                    $tmpProductDetail['line_qtyearly'],
                    $tmpProductDetail['line_status'],
                    $tmpProductDetail['setdefault'],
                    $tmpProductDetail['line_productcode'],
                ];
                //print_r($insert_sql);
                //print_r($insert_params);
                $adb->pquery($insert_sql, $insert_params);
                $tmp_lineitem_id = $adb->getLastInsertID();
            }

            $tmp_insertsql_arr = [];
            $tmp_insert_params = [];
            $insert_sql2 = " insert into ld_productdetail2propertydetail (productdetail_lineitem_id,propertydetail_lineitem_id,propertyid,productid) values ";
            foreach ($tmp_attribute_combination as $tmppropertyinfo) {
                $tmp_insertsql_arr[] = '(?,?,?,?)';
                $tmp_insert_params[] = $tmp_lineitem_id;
                $tmp_insert_params[] = $tmppropertyinfo['propertydetail_lineitem_id'];
                $tmp_insert_params[] = $tmppropertyinfo['propertyid'];
                $tmp_insert_params[] = $this->id;
            }
            $insert_sql2 .= implode(',', $tmp_insertsql_arr);
            $adb->pquery($insert_sql2, $tmp_insert_params);



            //价格字段有这两个字段
            $fieldarr = ['line_unit_price', 'line_procostprice'];
            foreach ($fieldarr as $tmpfieldname) {
                $currencyInfo = $tmpProductDetail[$tmpfieldname . '_morecurrency'];

                $insertCurrencySql = " insert into ld_productcurrencyrel (productid,currencyid,converted_price,actual_price,price_type,lineitem_id) values ";
                $insertCurrencyArr = [];
                $insertCurrencyDataArr = [];
                foreach ($currencyInfo as $tmpCurrencyInfo) {
                    if($tmpCurrencyInfo['check_value']==1||$tmpCurrencyInfo['curid']==1){
                        if($tmpCurrencyInfo['curid']==1){
                            $tmpCurrencyInfo['curvalue'] = $tmpProductDetail[$tmpfieldname];
                        }
                        $insertCurrencyArr[] = '(?,?,?,?,?,?)';
                        $insertCurrencyDataArr[] = $this->id;
                        $insertCurrencyDataArr[] = $tmpCurrencyInfo['curid'];
                        $insertCurrencyDataArr[] = $tmpCurrencyInfo['curvalue'];
                        $insertCurrencyDataArr[] = $tmpCurrencyInfo['curvalue'];
                        $insertCurrencyDataArr[] = $tmpfieldname;
                        $insertCurrencyDataArr[] = $tmp_lineitem_id;
                    }
                }
                $insertCurrencySql .= implode(',', $insertCurrencyArr);
                $adb->pquery($insertCurrencySql, $insertCurrencyDataArr);
            }
            $lineitem_id_arr[] = $tmp_lineitem_id;
            $new_lineitemid[$tmpProductDetail['sequence']] = array('new_lineitemid'=>$tmp_lineitem_id,'old_lineitemid'=>$tmp_lineitem_id);
        }
        //保存图片
        $this->insertIntoImage($new_lineitemid);

		if(!empty($lineitem_id_arr)){
			//删除已经不存在的明细
			$delete_sql = " delete from ld_productdetail where productid=? and lineitem_id not in (".implode(',',$lineitem_id_arr).") ";
			$adb->pquery($delete_sql, array($this->id));
			$delete_sql = " delete from ld_productdetail2propertydetail where productid=? and productdetail_lineitem_id not in (".implode(',',$lineitem_id_arr).") ";
			$adb->pquery($delete_sql, array($this->id));
		}

    }
    public function insertIntoImage($new_lineitemid){
        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
        $obj->insertIntoImage($new_lineitemid);
    }

	/**	function to save the product tax information in lingdang_producttaxrel table
	 *	@param string $tablename - lingdang_tablename to save the product tax relationship (producttaxrel)
	 *	@param string $module	 - current module name
	 *	$return void
	*/
	function insertTaxInformation($tablename, $module)
	{
		global $adb;
	    crm_load_function_file('getAllTaxes','include/utils','InventoryUtils');
		$tax_details = getAllTaxes();

		$tax_per = '';
		//Save the Product - tax relationship if corresponding tax check box is enabled
		//Delete the existing tax if any
		if($this->mode == 'edit')
		{
			for($i=0;$i<count($tax_details);$i++)
			{
                $tax_name = $tax_details[$i]['taxname'];
                if (in_array($this->operate_api,['crmapi','link2erp']) && !isset($_REQUEST[$tax_name])) continue;
                $taxid = $tax_details[$i]['taxid'];
				$sql = "delete from ld_producttaxrel where productid=? and taxid=?";
				$adb->pquery($sql, array($this->id,$taxid));
			}
		}
		for($i=0;$i<count($tax_details);$i++)
		{
			$tax_name = $tax_details[$i]['taxname'];
			$tax_checkname = $tax_details[$i]['taxname']."_check";
			if($_REQUEST[$tax_checkname] == 'on' || $_REQUEST[$tax_checkname] == 1 || $_REQUEST[$tax_checkname] == 'true')
			{
				$taxid = getTaxId($tax_name);
				$tax_per = $_REQUEST[$tax_name];
				if($tax_per == '')
				{
					
					$tax_per = getTaxPercentage($tax_name);
				}

				
				$query = "insert into ld_producttaxrel(productid,taxid,taxpercentage) values(?,?,?)";
				$adb->pquery($query, array($this->id,$taxid,$tax_per));
			}
		}

	
	}

	/**	function to save the product price information in ld_productcurrencyrel table
	 *	@param string $tablename - lingdang_tablename to save the product currency relationship (productcurrencyrel)
	 *	@param string $module	 - current module name
	 *	$return void
	*/
	function insertPriceInformation($tablename, $module)
	{
		global $adb,  $current_user;
	
		$currencyobj = Currency::getInstance($adb);
		$currency_details = $currencyobj->getAllCurrencies('all');

		//Delete the existing currency relationship if any

        if(!function_exists('getBaseConversionRateForProduct')){
            crm_load_function_file('getBaseConversionRateForProduct','include/utils','InventoryUtils');
        }
		$product_base_conv_rate = getBaseConversionRateForProduct($this->id, $this->mode);
		$cur_details = array('unit_price','procostprice');
		//Save the Product - Currency relationship if corresponding currency check box is enabled
		foreach($cur_details as $fldname){
            $flag_deletehistory = false;
			for($i=0;$i<count($currency_details);$i++)
			{
				$curid = $currency_details[$i]['curid'];
				$curname = $currency_details[$i]['currencylabel'];
                $base_currency_check = 'base_currency' . $curid;
				$cur_checkname = $fldname . '_cur_' . $curid . '_check';
				$cur_valuename = $fldname . '_curname' . $curid;
				//230726 wym XUQIU1000102 更多币种添加了产品报价，参考成本价不需要由产品报价计算
				$requestPrice = $_REQUEST[$fldname];
                if($this->mass_edit_cur) $requestPrice = $_REQUEST[$fldname.'_mass_edit_check'];
                $actualPrice=$_REQUEST[$cur_valuename];//setNumberFormat

				if($_REQUEST[$cur_checkname] == 'on' || $_REQUEST[$cur_checkname] == 1)
				{
					//230726 wym XUQIU1000102 更多币种添加了产品报价，删除时需要判断删除所需要修改的pricetype
                    if((($this->mode == 'edit' && $_REQUEST['action'] !== 'MassEditSave') || $this->mass_edit_cur ) && !$flag_deletehistory )
                    {
                        $sql = "delete from ld_productcurrencyrel where productid=? and price_type=? ";
                        $adb->pquery($sql, array($this->id,$fldname));
                        $flag_deletehistory = true;
                    }
					$conversion_rate = $currency_details[$i]['conversionrate'];
					$actual_conversion_rate = $product_base_conv_rate * $conversion_rate;
					$converted_price = $actual_conversion_rate * $requestPrice;

					$query = "insert into ld_productcurrencyrel(productid,currencyid,converted_price,actual_price,price_type) values(?,?,?,?,?)";
                    $adb->pquery($query, array($this->id,$curid,$converted_price,$actualPrice,$fldname));
                    // Update the Product information with Base Currency choosen by the User.
					if ($_REQUEST['base_currency'] == $cur_valuename) {
						$adb->pquery("update ld_products set currency_id=?, $fldname=? where productid=?", array($curid, $actualPrice, $this->id));
					}
				}
			}

		}

	}

	function updateUnitPrice() {
		$prod_res = $this->db->pquery("select unit_price, currency_id from ld_products where productid=? ", array($this->id));
		$prod_unit_price = $this->db->query_result($prod_res, 0, 'unit_price');
		$prod_base_currency = $this->db->query_result($prod_res, 0, 'currency_id');

        //zkt 20230920 BUG0072287  采购订单/入库单新建选择产品后，带出的含税单价显示错误。预期结果：应该是产品的“参考成本价”（通用问题）
		$query = "update ld_productcurrencyrel set actual_price=? where productid=? and currencyid=? and price_type = 'unit_price' ";
		$params = array($prod_unit_price, $this->id, $prod_base_currency);
		$this->db->pquery($query, $params);
	}
	/** Function to check if the product is member of other product
	*/
	function ismember_check(){
		global $adb;
		$ismember_query = $adb->pquery(getListQuery("Products")." AND (ld_products.productid IN (SELECT crmid from ld_seproductsrel WHERE ld_seproductsrel.crmid = ? AND ld_seproductsrel.setype='Products'))",array($this->id));
		$ismember = $adb->num_rows($ismember_query);
		return $ismember;
	}

	/**
	 * Move the related records of the specified list of id's to the given record.
	 * @param String This module name
	 * @param Array List of Entity Id's from which related records need to be transfered
	 * @param Integer Id of the the Record to which the related records are to be moved
	 */
	function transferRelatedRecords($module, $transferEntityIds, $entityId) {
		global $adb;
		
		parent::transferRelatedRecords($module, $transferEntityIds, $entityId);

		$rel_table_arr = Array("HelpDesk"=>"ld_troubletickets","Products"=>"ld_seproductsrel","Attachments"=>"ld_seattachmentsrel",
				"Quotes"=>"ld_quotesdetail","PurchaseOrder"=>"ld_purchaseorderdetail","SalesOrder"=>"ld_saleordetail",
				"Invoice"=>"ld_invoicedetail","PriceBooks"=>"ld_pricebookproductrel","Leads"=>"ld_seproductsrel",
				"Accounts"=>"ld_seproductsrel","Potentials"=>"ld_seproductsrel","Contacts"=>"ld_seproductsrel",
				"Documents"=>"ld_senotesrel","Worksheet"=>"ld_worksheetdetail","WorksheetSpeci"=>"ld_worksheetspecialdetail","Shopcart"=>"ld_shopcartdetails");

		$tbl_field_arr = Array("ld_troubletickets"=>"ticketid","ld_seproductsrel"=>"crmid","ld_seattachmentsrel"=>"attachmentsid",
				"ld_invoicedetail"=>"id","ld_pricebookproductrel"=>"pricebookid","ld_seproductsrel"=>"crmid","ld_worksheetdetail"=>"related_productid",
				"ld_senotesrel"=>"notesid","ld_worksheetspecialdetail"=>"worksheetid","ld_shopcartdetails"=>"cartid");

		$entity_tbl_field_arr = Array("ld_troubletickets"=>"product_id","ld_seproductsrel"=>"crmid","ld_seattachmentsrel"=>"crmid",
				"ld_invoicedetail"=>"productid","ld_pricebookproductrel"=>"productid","ld_seproductsrel"=>"productid",
				"ld_senotesrel"=>"crmid","ld_worksheetdetail"=>"productid","ld_worksheetspecialdetail"=>"productid","ld_shopcartdetails"=>"productid");
		
		foreach($transferEntityIds as $transferId) {
			foreach($rel_table_arr as $rel_module=>$rel_table) {
				$id_field = $tbl_field_arr[$rel_table];
				$entity_id_field = $entity_tbl_field_arr[$rel_table];
				// IN clause to avoid duplicate entries
				$sel_result =  $adb->pquery("select $id_field from $rel_table where $entity_id_field=? " .
						" and $id_field not in (select $id_field from $rel_table where $entity_id_field=?)",
						array($transferId,$entityId));
				$res_cnt = $adb->num_rows($sel_result);
				if($res_cnt > 0) {
					for($i=0;$i<$res_cnt;$i++) {
						$id_field_value = $adb->query_result($sel_result,$i,$id_field);
						$adb->pquery("update $rel_table set $entity_id_field=? where $entity_id_field=? and $id_field=?",
							array($entityId,$transferId,$id_field_value));
					}
				}
			}
		}
		foreach($transferEntityIds as $transferId) {
			//1.产品合并后，出库单反审核时，库存结果错误（撤销出库）
			//$query = 'update ld_warehousecondtions set productid = ? where productid = ?';
			//$adb->pquery($query,array($entityId,$transferId));
			//$query = 'update ld_warehouse2products set productid = ? where productid = ?';
			//$adb->pquery($query,array($entityId,$transferId));
		}
		$sql = 'select distinct name from ld_tab';
		$Module_Names = $adb->pquery($sql, array());
		
		$rows = $adb->num_rows($Module_Names);
		$result = [];
		for($i = 0;$i < $rows ;$i++){
			$result[] = $adb->query_result($Module_Names, $i, 'name');
		}
		//find all modules which contains the file called ProductDetails then update database
		$proid_str = implode(',',$transferEntityIds);
		
		foreach($result as $key => $tmp_module){
			if(get_file_address($tmp_module,"ProductDetails")){
				$tmp_focus = CRMEntity::getInstance($tmp_module);
				$sql = 'update '.$tmp_focus->Detail_table.' set productid='.$entityId.' where productid in('.$proid_str.')';
				$adb->pquery($sql, array());
			}
		}

	}

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"HelpDesk" => array("ld_troubletickets"=>array("product_id","ticketid"),"ld_products"=>"productid"),
			"Quotes" => array("ld_quotesdetail"=>array("productid","id"),"ld_products"=>"productid"),
			"PurchaseOrder" => array("ld_purchaseorderdetail"=>array("productid","id"),"ld_products"=>"productid"),
			"SalesOrder" => array("ld_salesorderdetail"=>array("productid","id"),"ld_products"=>"productid"),
			"Invoice" => array("ld_invoicedetail"=>array("productid","id"),"ld_products"=>"productid"),
			"Leads" => array("ld_seproductsrel"=>array("productid","crmid"),"ld_products"=>"productid"),
			"Accounts" => array("ld_seproductsrel"=>array("productid","crmid"),"ld_products"=>"productid"),
			"Contacts" => array("ld_seproductsrel"=>array("productid","crmid"),"ld_products"=>"productid"),
			"Potentials" => array("ld_seproductsrel"=>array("productid","crmid"),"ld_products"=>"productid"),
			"Products" => array("ld_products"=>array("productid","product_id"),"ld_products"=>"productid"),
			"PriceBooks" => array("ld_pricebookproductrel"=>array("productid","pricebookid"),"ld_products"=>"productid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_products"=>"productid"),
		);
		return $rel_tables[$secmodule];
	}

	function deleteProduct2ProductRelation($record,$return_id,$is_parent){
		global $adb;
		if($is_parent==0){
			$sql = "delete from ld_seproductsrel WHERE crmid = ? AND productid = ?";
			$adb->pquery($sql, array($record,$return_id));
		} else {
			$sql = "delete from ld_seproductsrel WHERE crmid = ? AND productid = ?";
			$adb->pquery($sql, array($return_id,$record));
		}
	}

	// Function to unlink all the dependent entities of the given Entity by Id
	function unlinkDependencies($module, $id) {
		
		//Backup Campaigns-Product Relation
		$cmp_q = 'SELECT campaignid FROM ld_campaign WHERE product_id = ?';
		$cmp_res = $this->db->pquery($cmp_q, array($id));
		if ($this->db->num_rows($cmp_res) > 0) {
			$cmp_ids_list = array();
			for($k=0;$k < $this->db->num_rows($cmp_res);$k++)
			{
				$cmp_ids_list[] = $this->db->query_result($cmp_res,$k,"campaignid");
			}
			$params = array($id, RB_RECORD_UPDATED, 'ld_campaign', 'product_id', 'campaignid', implode(",", $cmp_ids_list));
			$this->db->pquery('INSERT INTO ld_relatedlists_rb VALUES (?,?,?,?,?,?)', $params);
		}
		//we have to update the product_id as null for the campaigns which are related to this product
		$this->db->pquery('UPDATE ld_campaign SET product_id=0 WHERE product_id = ?', array($id));

		$this->db->pquery('DELETE from ld_seproductsrel WHERE productid=? or crmid=?',array($id,$id));

		parent::unlinkDependencies($module, $id);
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Calendar') {
			$sql = 'DELETE FROM ld_seactivityrel WHERE crmid = ? AND activityid = ?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Leads' || $return_module == 'Accounts' || $return_module == 'Contacts' || $return_module == 'Potentials'||$return_module=='HelpDesk') {
			$sql = 'DELETE FROM ld_seproductsrel WHERE productid = ? AND crmid = ?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Vendors') {
			$sql = 'UPDATE ld_products SET vendor_id = ? WHERE productid = ?';
			$this->db->pquery($sql, array(null, $id));
		}
       
        else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}

    public function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = PearDatabase::getInstance();

		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Leads' || $with_module == 'Accounts' ||
					$with_module == 'Contacts' || $with_module == 'Potentials' || $with_module == 'Products'){
				$query = $adb->pquery("SELECT * from ld_seproductsrel WHERE crmid=? and productid=?",array($crmid, $with_crmid));
				if($adb->num_rows($query)==0){
					$adb->pquery("insert into ld_seproductsrel values ($with_crmid,$crmid,'$with_module')");
				}
			}
			else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
	}

	//判断产品是否已关联了源单
    public function getProductForSource($productid,$module){
		global $adb;
        $focus=CRMEntity::getInstance($module);
		$detailtable = $focus->Detail_table;
		$detailtable_index = $focus->Detail_table_index;
		$query = " select DISTINCT $detailtable_index,setype from $detailtable INNER JOIN ld_crmentity on ld_crmentity.crmid = $detailtable.$detailtable_index  where $detailtable.productid = ?";
		$result = $adb->pquery($query,array($productid));
		$num_rows = $adb->num_rows($result);
		$label = [];
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$id = $adb->query_result($result,$i,'id');
				$setype = $adb->query_result($result,$i,'setype');
				if(!empty($setype)){
					$entityarray = getEntitynameInfo(getTabid($setype));
					$tabname = $entityarray['tablename'];//模块主表
					$moduleid = $entityarray['entityidfield'];//模块主表ID
					$tabfieldname = $entityarray['fieldname'];//模块链接字段
					$query = "select $tabfieldname from $tabname where $moduleid = ?";
					$result1 = $adb->pquery($query,array($id));
					$linklabel = $adb->query_result($result1,0,0);
					if(!empty($linklabel)){
					   
						$label[] = '<a referencemodule="'.$setype.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$linklabel.'</a>';
					}
				}
			}
		}
		$data['link'] = implode('、 ',$label);
		$data['num_rows'] = $num_rows;
		return $data;
	}

	//审批成功操作
	public function successApprove($record)
	{
		//杨锻客户，erp产品对接特殊判断
		if(get_versiontrade() == 'yangduan'){
			crm_load_class_file('cls_interface_yadon','include/InterfaceClass');
			$cls_interface_yadon = new cls_interface_yadon();
			$_SESSION['kiserror'] = $cls_interface_yadon->Products_Synchronous($record,'Products');
		}
	}
	
	//订货商城  获取产品的图片
	public function getImageUrl($productid,$type){
		global $adb;
		$query = "select CONCAT(path,newfile_name) as img,storage_location,cloud_path from ld_seattachmentsrel 
		LEFT JOIN ld_attachments on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid 
		where crmid = ? order by ld_seattachmentsrel.attachmentsid asc";
		$result = $adb->pquery($query,array($productid));
		if($adb->num_rows($result) >= 1){
			for($i = 0; $i < $adb->num_rows($result); $i++){
				if($adb->query_result($result,$i,'storage_location') == 'cos'){
					$imgs[] = $adb->query_result($result,$i,'cloud_path');
				}
				else{
					$imgs[] = $adb->query_result($result,$i,'img');
				}				
			}
			if($type == 'one'){
				return $imgs[0];
			}
			else{
				return $imgs;
			}
		}
		else{
			if($type == 'one'){
				return 'themes/images/noshopimg.jpg';
			}
			else{
				$imgs[] = 'themes/images/noshopimg.jpg';
				return $imgs;
			}
		}
	}
	public function getShopProPrice($record,$price,$quantity){
		global $adb,$current_user;
		//$tmp=setProductsInfo('SalesOrder',$record,1,0,1,'yes');
		//订货商城增加参数控制显示经销商折扣价
		$salesordersys_value= getSys_deploy(349);
        if($salesordersys_value['deploy_value']==1){
			$query = "select query_sql from ld_related_producttoolfield where modulename = 'SalesOrder'";
			$result = $adb->pquery($query,array());
			if($adb->num_rows($result) >= 1){
				$query_sql = $adb->query_result($result,0,0);
				$query_sql = str_ireplace('{hdnProductId}', $record, $query_sql);
				$query_sql = str_ireplace('{quantity}', 1, $query_sql);
				$query_sql = str_ireplace('{ld_salesorder.accountid}', $current_user->account_id, $query_sql);
				$query_sql = str_ireplace('{ld_salesorder.smownerid}', $current_user->id, $query_sql);
				$query_sql = str_ireplace('{uuid}', $current_user->id, $query_sql);
				
				$result = $adb->pquery($query_sql,array());
				if($adb->num_rows($result) >= 1){
					$discount_percent = $adb->query_result($result,0,'discount_percent');
					$taxprice = $adb->query_result($result,0,'taxprice');
					if(!empty($taxprice)){
						$price = number_format($taxprice,2,".","");
					}
					$version = getVersionInfo();
					//呼博士特殊控制
					if($version['account'] == 'huboshi'){
						$price = $taxprice = $adb->query_result($result,0,'sf2454');
					}
				}
			}else{
				$price = $this->getShopStrategyPrice($record,$price,$quantity);
				
			}
		}else{
			$price = $this->getShopStrategyPrice($record,$price,$quantity);
		}
		return $price;
	}

	public function getShopStrategyPrice($record,$price,$quantity){
		//chj 2022/7/13 订货商城结合定价策略优化
		crm_load_class_file("cls_strategy",'modules/Products');
		$clsstrategyobj=new cls_strategy();
		$pricestrategy_arr= $clsstrategyobj->getstrategyByProductId($record);
		if(empty($pricestrategy_arr['info'])){
			return $price;
		}
		$last_len = sizeOf($pricestrategy_arr['info'][$record]) - 1;
		$lasttype = $pricestrategy_arr['info'][$record][$last_len]['type'];
		if($lasttype == 1){	//固定基数
			foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
				if($temp_proinfo['type'] == 1){
					if($temp_proinfo['count_from'] <= $quantity && $quantity <= $temp_proinfo['count_to']){
						$maxfixedbasemoney = $temp_proinfo['money'];
						break;
					}
				}
			}
			if(empty($maxfixedbasemoney)){
				foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
					if($temp_proinfo['type'] == 1){
						if($quantity <= $temp_proinfo['count_from']){
							$maxfixedbasemoney = $temp_proinfo['money'];
							break;
						}
					}
				}
			}
			$price = sprintf('%.2f', $maxfixedbasemoney/$quantity);
		}else if($lasttype == 2){	//固定基数+固定增量
			
			$maxfixedbasemoney = 0;
			//获取最大值
			$temp_maxfixedbase_arr = [];
			foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
				if($temp_proinfo['type'] == 1){
					$temp_maxfixedbase_arr[] = $temp_proinfo['count_to'];
				}
			}
			$temp_maxfixedbase = max($temp_maxfixedbase_arr);
			if($temp_maxfixedbase >= $quantity){
				foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
					if($temp_proinfo['type'] == 1){
						if($temp_proinfo['count_from'] <= $quantity && $quantity <= $temp_proinfo['count_to']){
							$maxfixedbasemoney = $temp_proinfo['money'];
							break;
						}
					}
				}
				if(empty($maxfixedbasemoney)){
					foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
						if($temp_proinfo['type'] == 1){
							if($quantity <= $temp_proinfo['count_from']){
								$maxfixedbasemoney = $temp_proinfo['money'];
								break;
							}
						}
					}
				}
				$price = sprintf('%.2f', $maxfixedbasemoney/$quantity);
			}else{
				foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
					if($temp_proinfo['type'] == 1 && $temp_proinfo['count_to'] == $temp_maxfixedbase){
						$maxfixedbasemoney = $temp_proinfo['money'];
					}
				}
				$minquantity = $quantity - $temp_maxfixedbase;
				$maxfixedbasemoney = $maxfixedbasemoney + $minquantity*$pricestrategy_arr['info'][$record][$last_len]['money'];
				$price = sprintf('%.2f', $maxfixedbasemoney/$quantity);
			}
		}else if($lasttype == 3){	//固定基数+阶梯增量
			$maxfixedbasemoney = 0;
			//获取最大值
			$temp_maxfixedbase_arr = [];
			foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
				if($temp_proinfo['type'] == 1){
					$temp_maxfixedbase_arr[] = $temp_proinfo['count_to'];
				}
			}
			$temp_maxfixedbase = max($temp_maxfixedbase_arr);
			if($temp_maxfixedbase >= $quantity){
				foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
					if($temp_proinfo['type'] == 1){
						if($temp_proinfo['count_from'] <= $quantity && $quantity <= $temp_proinfo['count_to']){
							$maxfixedbasemoney = $temp_proinfo['money'];
							break;
						}
					}
				}
				if(empty($maxfixedbasemoney)){
					foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
						if($temp_proinfo['type'] == 1){
							if($quantity <= $temp_proinfo['count_from']){
								$maxfixedbasemoney = $temp_proinfo['money'];
								break;
							}
						}
					}
				}
				$price = sprintf('%.2f', $maxfixedbasemoney/$quantity);
			}else{
				$temp_price = 0;
				foreach($pricestrategy_arr['info'][$record] as $temp_proinfo){
					if($temp_proinfo['type'] == 1 && $temp_proinfo['count_to'] == $temp_maxfixedbase){
						$maxfixedbasemoney = $temp_proinfo['money'];
					}
					if($temp_proinfo['type'] == 3){
						if($temp_proinfo['count_from'] <= $quantity && $quantity <= $temp_proinfo['count_to']){
							$temp_price = $temp_proinfo['money'];
							break;
						}
					}
				}
				if(empty($temp_price)){
					$temp_price = $pricestrategy_arr['info'][$record][$last_len]['money'];
					$temp_quantity = $pricestrategy_arr['info'][$record][$last_len]['count_to'];
					$minquantity = $temp_quantity - $temp_maxfixedbase;
					
				}else{
					$minquantity = $quantity - $temp_maxfixedbase;
				}
				$maxfixedbasemoney = $maxfixedbasemoney + $minquantity*$temp_price;
				$price = sprintf('%.2f', $maxfixedbasemoney/$quantity);
			}
		}
		return $price;
		
	}

}
Products::require_file();
?>