<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/


class PriceBooks extends CRMEntity {
	var $log;
	var $db;
	var $table_name = "ld_pricebook";
	var $table_index= 'pricebookid';
    var $table_code='pricebook_no';
	var $tab_name = Array('ld_crmentity','ld_pricebook','ld_pricebookcf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_pricebook'=>'pricebookid','ld_pricebookcf'=>'pricebookid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_pricebookcf', 'pricebookid');
    var $relatedtab=array('users'=>'','products'=>'','company'=>'','pricebooks'=>'');
	var $column_fields = Array();

	var $sortby_fields = Array('bookname');

     
	var $list_link_field= 'bookname';

	var $search_fields = Array(
                                'Price Book Name'=>Array('pricebook'=>'bookname')
                                );
	var $search_fields_name = Array(
                                        'Price Book Name'=>'bookname',
                                     );

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'bookname';
	var $default_sort_order = 'ASC';

	var $mandatory_fields = Array('bookname','currency_id','pricebook_no','createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'bookname';
   
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		$this->db = PearDatabase::getInstance();
		$this->fieldobj = Field::getInstance('PriceBooks',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
           /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('PriceBooks');
        $this->list_link_field=$entityname['fieldname'];
	}

	function save_module($module)
	{
		global $adb;
		// Update the list prices in the price book with the unit price, if the Currency has been changed
		$this->updateListPrices();
		//chj: 编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        if($this->currency_status === true)
        {
            $update_query = "update ld_pricebook set currency_id=?, conversion_rate=?,currency_symbol=? where pricebookid=?";
    		$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
    		$adb->pquery($update_query, $update_params);
        }
	}

	/* Function to Update the List prices for all the products of a current price book
	   with its Unit price, if the Currency for Price book has changed. */
	function updateListPrices() {
		global  $adb;
		$pricebook_currency = $this->column_fields['currency_id'];
		$prod_res = $adb->pquery("select * from ld_pricebookproductrel where pricebookid=? AND usedcurrency != ?",
							array($this->id, $pricebook_currency));
		$numRows = $adb->num_rows($prod_res);

		for($i=0;$i<$numRows;$i++) {
			$product_id = $adb->query_result($prod_res,$i,'productid');
			$list_price = $adb->query_result($prod_res,$i,'listprice');
			$used_currency = $adb->query_result($prod_res,$i,'usedcurrency');
			$currencyobj=Currency::getInstance($adb,$used_currency);
			$product_conv_rate = $currencyobj->getCurrencyRate();
			$currencyobj=Currency::getInstance($adb,$pricebook_currency);
			$pb_conv_rate = $currencyobj->getCurrencyRate();
			$conversion_rate = $pb_conv_rate / $product_conv_rate;
			$computed_list_price = $list_price * $conversion_rate;

			$query = "update ld_pricebookproductrel set listprice=?, usedcurrency=? where pricebookid=? and productid=?";
			$params = array($computed_list_price, $pricebook_currency, $this->id, $product_id);
			$adb->pquery($query, $params);
		}
	
	}

	

	/*
	 * Function to get the primary query part of a report
	 * @param - $module Primary module name
	 * returns the query string formed on fetching the related data for report for primary module
	 **/
    function get_pricebook_products($record,$actions,$start,$searchinfo,$tmp_related_left_type,$order_by=''){
        global $current_user,$adb,$list_max_entries_per_page_new_more,$related_left_type;
        $related_left_type = 0;
        $module = 'PriceBooks';
        $relatedmodule = 'Products';
        $relatedfocus = CRMEntity::getInstance($relatedmodule);
        $this->id = $record;
        $this->retrieve_entity_info($record, $module);
        $version = getVersionTradeInfo();//获取数据库行业版本
//        $version['account'] = 'haige';
        $dataArr = [];
        $header = [];//列头
        $navigation = [];//翻页数据
        $priceBookEditPermit = isPermitted("PriceBooks","EditView","");


        $query = '';
        $customview = new CustomView($relatedmodule);
        $queryGenerator = new QueryGenerator($relatedmodule,$current_user,$customview);
        $controller = new ListViewController($adb,$current_user,$queryGenerator);
        if (!empty($searchinfo) && is_array($searchinfo)){
            $queryGenerator->addUserSearchConditions($searchinfo);
        }
        if (is_array($version) && $version['account'] == 'haige'){
            $query .= 'SELECT ld_products.productid,ld_products.product_no as productname,ld_pricebookproductrel.listprice,ld_currencies.description,
                ld_products.usageunit,ld_crmentity.crmid,ld_pricebookproductrel.description as descp 
				FROM ld_products 
				INNER JOIN ld_pricebookproductrel ON ld_products.productid = ld_pricebookproductrel.productid 
				INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_products.productid 
				INNER JOIN ld_pricebook ON ld_pricebook.pricebookid = ld_pricebookproductrel.pricebookid 
				LEFT JOIN ld_users ON ld_users.id = ld_products.smownerid 
				LEFT JOIN ld_currency_info on ld_currency_info.id = ld_pricebook.currency_id 
				LEFT JOIN ld_currencies on ld_currencies.currency_name = ld_currency_info.currency_name 
				LEFT JOIN ( SELECT DISTINCT crmid FROM ld_tabshare) AS ld_tabshare ON ld_tabshare.crmid = ld_products.productid ';
                $query .= $queryGenerator->getWhereClause();
                $query .= ' AND ld_pricebook.pricebookid = ? ';
        }
        else{
            $viewid = $customview->getViewIdByName('All',$relatedmodule);//获取“全部”查询分类id
            $customview->setCvid($viewid);
            $queryGenerator->initForCustomViewById($viewid);
            $tmp_query = $queryGenerator->getQuery('',2);
            $selectcolumn = $queryGenerator->getSelectClauseColumnSQL();
            $tmp_query_arr = explode($selectcolumn,$tmp_query);
            $query .= $tmp_query_arr[0].' '.$selectcolumn.',ld_pricebookproductrel.listprice '.$tmp_query_arr[1];
            $query .= ' INNER JOIN ld_pricebookproductrel ON ld_products.productid = ld_pricebookproductrel.productid';
            $query .= ' INNER JOIN ld_crmentity ON ld_crmentity.crmid = ld_products.productid';
            $query .= ' INNER JOIN ld_pricebook ON ld_pricebook.pricebookid = ld_pricebookproductrel.pricebookid';
            $query .= ' LEFT JOIN ld_users ON ld_users.id=ld_products.smownerid';
            $query .= ' LEFT JOIN (select distinct crmid from ld_tabshare) as ld_tabshare on ld_tabshare.crmid = ld_products.productid';
            $query .= $queryGenerator->getWhereClause();
            $query .= ' and ld_pricebook.pricebookid = ? ';
        }
        //全部数量
        $noofrows_result = $adb->pquery(mkCountQuery($query),array($record));
        $noofrows = $adb->query_result($noofrows_result,0,'count');
        if (!empty($order_by)){
            $query .= ' order by '.$order_by;
        }
        $start = ($start == 'last' && $noofrows > 0) ? ceil($noofrows/$list_max_entries_per_page_new_more) : $start ;
        $start = !is_numeric($start) ? 1 : $start;
        $start = $start < 1 ? 1 : $start;
        $limit_start_sql = ($start-1) * $list_max_entries_per_page_new_more;
        $query .= $adb->dbType == "pgsql"? ' OFFSET '.$limit_start_sql.' LIMIT '.$list_max_entries_per_page_new_more : ' LIMIT '.$limit_start_sql.','.$list_max_entries_per_page_new_more;
        $result = $adb->pquery($query,array($record));
        //数据
        $sys_delpoy_93 = getSys_deploy(93);//单价小数位数
        $num_rows = $adb->num_rows($result);
        $listentriesArr = [];
        if ($num_rows > 0){
            if (!is_array($version) || $version['account'] != 'haige'){
                $listentriesArr = $controller->getListViewEntries($relatedfocus,$relatedmodule,$result,$navigation_array,true);
                $last_array = end($listentriesArr);
                $end_key = sizeof($last_array) - 1;
            }
            for ($i = 0;$i < $num_rows;$i++){
                $productid  = $adb->query_result($result,$i,'productid');
                $entries = [];
                $listprice  = $adb->query_result($result,$i,'listprice');
                $listprice = empty($listprice) ? 0 : setNumberFormat($listprice,$sys_delpoy_93['deploy_value']);
                //操作类按钮
                $action = '';
                if ($priceBookEditPermit == 'yes'){
                    $action = '<a class="Anu3_a" onclick="editProductListPrice('.$productid.','.$record.',\''.$listprice.'\')">'.getFixedLabel('EDIT').'</a>';
                    $action .= '<a class="Anu3_a" onclick="deletePriceBookProductRel('.$productid.','.$record.')">'.getFixedLabel('CANCELTHEASSOCIATED').'</a>';
                }
                //列表数据
                if (is_array($version) && $version['account'] == 'haige'){//海格特殊开发
                    $entries[] = textlength_check($adb->query_result($result,$i,"productname"));
                    $entries[] = $listprice;
                    $entries[] = $adb->query_result($result,$i,"description");
                    $entries[] = $adb->query_result($result,$i,"usageunit");
                    $entries[] =  $adb->query_result($result,$i,"descp");;
                    $entries[] = $action;
                    $listentriesArr[] = $entries;
                }
                else{
                    $listentriesArr[$productid][$end_key] = $listprice;
                    if ($priceBookEditPermit == 'yes'){
                        $listentriesArr[$productid][$end_key+1] = $action;
                    }
                }
            }
        }

        //列表上方按钮和查找
        if (!empty($actions)){
            $actions_arr = explode(',',strtoupper($actions));
            $detailview_permit = isPermitted($relatedmodule,'DetailView', '');
            $pricebook_currency = $this->column_fields['currency_id'];
            $button_html = '';
            if (is_array($actions_arr) && in_array('SELECT',$actions_arr) && $detailview_permit == 'yes'){
                $surl = 'module='.$relatedmodule.'&action='.$relatedmodule.'Ajax&file=AddProductsToPriceBook&return_module='.$module;
                $surl .= '&return_action=PriceBookDetailView&Create=&popup=yes&page_popup=yes&pricebook_id='.$record.'&currency_id='.$pricebook_currency;
                $button_html .= '<a href="javascript:;" onclick="CrmPopupWindow(\''.$module.'\',\''.$surl.'\',\''.$relatedmodule.'\')">';
                $button_html .= '<b class="icon-homeimg icon-selectbtn"></b><span>'.getFixedLabel('SELECT').'</span>';
                $button_html .= '</a>';
            }
            if (is_array($actions_arr) && in_array('IMPORT',$actions_arr) && $detailview_permit == 'yes'){
                $button_html .= '<a href="javascript:;" onclick="cls_PricebooksImportProduct.getInstance(\''.$module.'\').firstimport();return false;">';
                $button_html .= '<b class="icon-homeimg icon-plus"></b><span>'.getFixedLabel('IMPORT').'</span>';
                $button_html .= '</a>';
            }

            if (is_array($version) && $version['account'] == 'haige'){
                $btn_value = getFixedLabel('IMPORT') . getTransTab('Products');
                $button_html .= '<input type="button" style="border:none;margin-left:10px" name="Button" class="createauto" value="'.$btn_value.'" ';
                $button_html .= 'onclick="cls_XlsImportRelatedNew_HaiGe.getInstance(\''.$module.'\',\''.$relatedmodule.'\',\''.$record.'\').firstimport()">';
                $fieldlabel=$relatedfocus->fieldobj->getFieldInfoBykeyValue("columnname","product_no","fieldlabel");
                $button_html .= '<a name="basicSearchNewDiv" id="basicSearchNewDiv" href="javascript:;">';
                $button_html .= '<input type="hidden" name="search_field" id="search_field" value="product_no">';
                $button_html .= '<input draggable="false" type="text" name="search_text" placeholder="请输入'.$fieldlabel.'按回车进行查询"  value="" size="30px" 
                 style="border-radius:4px;border:1px solid #C5C5C5;height:25px;margin-left:10px" onkeypress="fun_ProductPriceBooks.getInstance().searchRelatedProductsByEnter(this,event)">';
                $button_html .= '</a>';
            }
        }

        //翻页
        $related_left_type = $tmp_related_left_type;
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
        $navigation_array =  VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new_more,$noofrows);
        $navigation[] = getRecordRangeMessage($result, $limit_start_sql,$noofrows);
        $navigation[] = getRelatedTableHeaderNavigation($navigation_array, '',$module,$relatedmodule,$record);
        //列头
        if (is_array($version) && $version['account'] == 'haige'){//海格特殊开发
            $header = array('物料编码','价格','币种','单位','价格单位');
        }else{
            $header = $controller->getListViewHeader($relatedfocus,$relatedmodule);//获取全部数据范围下字段设置的宽度
            $header_keys = array_keys($header);
            $last_header_key = end($header_keys);
            $header[$last_header_key] = getFixedLabel('LISTPRICE');
        }
        if($priceBookEditPermit == 'yes' || isPermitted("PriceBooks","Delete","") == 'yes'){
            $header[]=getFixedLabel('OPERATING');
        }
        $dataArr['header'] = $header;
        $dataArr['entries'] = $listentriesArr;
        $dataArr['noofrows'] = $noofrows;
        $dataArr['CUSTOM_BUTTON'] = $button_html;
        $dataArr['navigation'] = $navigation;
        if (!is_array($version) || $version['account'] != 'haige'){
            $fieldname_width = $controller->getModuleViewFieldsWidth();
            foreach ($fieldname_width as $tmp_key => $tmp_width){
                if (is_string($tmp_width) && strpos($tmp_width,'setting') !== false){

                }else{
                    $fieldname_width[$tmp_key] = ((int)$tmp_width * 100).'setting';
                }
            }
            $fieldwidth = getModuleWidth($relatedfocus,$fieldname_width,$relatedmodule);
            $fieldwidth[] = 100;//单价字段宽度
            $dataArr['fieldwidth'] = $fieldwidth;
            $dataArr['basicSearchField'] = $controller->getBasicSearchFieldInfoList();
            $dataArr['showBasicSearchBtn'] = 'yes';
            $dataArr['fiexedIndex'] = $end_key;
            unset($fieldwidth);
        }

        //数组对象unset
        unset($navigation_array,$result,$relatedfocus,$controller,$queryGenerator,$customview,$listentriesArr,$header,$version,$entries,$sys_delpoy_93);

        return $dataArr;
    }



	function getNonAdminAccessControlQuery($module, $user, $scope = '') {
		global $related_header,$adb;
		$focus = CRMEntity::getInstance($module);
        //产品共享给多个人后在价格表中选择该产品后相关信息显示错误，can
		$query .= " LEFT JOIN (select distinct crmid from  ld_tabshare) as ld_tabshare on ld_tabshare.crmid = $focus->table_name.$focus->table_index ";
		return $query;
	}
	

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Products" => array("ld_pricebookproductrel"=>array("pricebookid","productid"),"ld_pricebook"=>"pricebookid"),
			"Services" => array("ld_pricebookproductrel"=>array("pricebookid","productid"),"ld_pricebook"=>"pricebookid"),
		);
		return $rel_tables[$secmodule];
	}
	
	
    function getListQuery($module, $where = '') {
    $customview=CustomView::getInstance($module);
    $moduleobj=$this;
	
	$table_name = $moduleobj->table_name;

    $viewid=$customview->getViewId($module);
    $columnlist=$customview->getColumnsListByCvid($viewid);
   
    $fromclause="";
	$ismodtable = array('ld_crmentity'=>'1','ld_accountbillads'=>'1',
		'ld_accountshipads'=>'1','ld_contactaddress'=>'1','ld_contactsubdetails'=>'1');

    foreach($columnlist as $colmn)
    {
         $arrcolumn=explode(":",$colmn);
	   if(isset($ismodtable[strtolower($arrcolumn[0])])){
				$arrcolumn[0] = $table_name;
			 }
        $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
    }
    $query = "SELECT ld_pricebook.pricebookid  as crmid ".$fromclause .
		",ld_pricebook.* FROM 	ld_pricebook
			INNER JOIN ld_pricebookcf
				ON ld_pricebook.pricebookid = ld_pricebookcf.pricebookid
			LEFT JOIN ld_currency_info
				ON ld_pricebook.currency_id = ld_currency_info.id 
                LEFT JOIN ld_users on ld_users.id=ld_pricebook.smownerid ";
                
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_pricebook.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_pricebook.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .=" WHERE ld_pricebook.deleted = 0 " . $where;
       return $query;
    }
}
?>