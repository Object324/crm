<?php
//editor:gyq_86 reason:产品批次 2018/11/2 11:01

class ModelBatch
{
    public $colspan;
    protected $adb;

    protected $listHeaderWidthArr;//列头字段对应宽度数组
    protected $frommodule;

    public function setParams($params)
    {
        $this->adb = $params['adb'];
    }

    //获取单个产品批次信息
    public function getbatchList()
    {
        $this->colspan = 6;
        return $this->getSelectMultibatchList();
//        global $list_max_entries_per_page_new;//列表每页显示的记录数目
//        global $adb;
//        $productid=$_REQUEST['productid'];
//        $warehouseid=$_REQUEST['wareid'];
//        $tmparr = array();
//        $focus=CRMEntity::getInstance("Products");
//        $fieldObj=$focus->fieldobj;
//        $productdatelabel=$fieldObj->getFieldInfoBykeyValue("columnname","productdate",'fieldlabel');
//        $protectqualitydate=$fieldObj->getFieldInfoBykeyValue("columnname","protectqualitydate",'fieldlabel');
//        $this->colspan=5;
//        if($protectqualitydate==''&&$productdatelabel=='')
//        {
//            $this->colspan=3;
//        }
//        else if($protectqualitydate==''||$productdatelabel=='')
//        {
//            $this->colspan=4;
//        }
//        $warehouselabel=getFixedlabel('WAREHOUSE');
//        $batchlabel=getFixedLabel("BATCH");
//        $quantitylabel=getFixedLabel("QUANTITY");
//        $tmparr['title'][]=array('batch'=>$batchlabel,'warehoursename'=>$warehouselabel,'quantity'=>$quantitylabel, 'productdate'=>$productdatelabel,'protectqualitydate'=>$protectqualitydate);
//		crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
//		$tmpproductqtys= getProductQtySaveOrCheck($productid,$warehouseid,"");
//		$deployarray=getSys_deploy(49);
//        $lengthdecimaldigits=$deployarray['deploy_value'];
//		foreach($tmpproductqtys as $prodcutid => $pro_arr){
//			foreach($pro_arr[$warehouseid] as $batchtext => $qty){
//				if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'OutboundOrder'){
//					if($qty <= 0)continue;
//				}
//				if($batchtext == DEFAULTBATCHTEXT)continue;
//				$lastqty=number_format($qty,$lengthdecimaldigits,".","");
//				$tmparr['content'][]=array(
//					'batch'=>$batchtext,	//批次
//					"warehoursename"=>$tmpproductqtys[$prodcutid.'_warehousename'],	//仓库
//					'productdate'=>$tmpproductqtys[$prodcutid.'_productdate'],	//生产日期
//					'protectqualitydate'=>$tmpproductqtys[$prodcutid.'_protectqualitydate'],	//保质期
//					'quantity'=>$lastqty
//				);
//			}
//		}
//
//        return $tmparr;
    }


    /**
     * 多选批次（出库单）
     * // @edit:dong @date:2020/08/07 @reason:tapd ID1000934 库存报表和选择批次中增加“失效日期”列
     * */
    public function getSelectMultibatchList()
    {
        global $list_max_entries_per_page_new;//列表每页显示的记录数目
        global $adb, $current_user;
        $productid = $_REQUEST['productid'];
        $warehouseid = $_REQUEST['wareid'];
        $tmparr = array();
        $focus = CRMEntity::getInstance("Products");
        $fieldObj = $focus->fieldobj;
        $productnamelabel = $fieldObj->getFieldInfoBykeyValue("columnname", "productname", 'fieldlabel');
        $productsheetlabel = $fieldObj->getFieldInfoBykeyValue('columnname', 'productsheet', 'fieldlabel');

        $productdatelabel = $fieldObj->getFieldInfoBykeyValue("columnname", "productdate", 'fieldlabel');
        $protectqualitydate = $fieldObj->getFieldInfoBykeyValue("columnname", "protectqualitydate", 'fieldlabel');
        $tmplist = array_filter(array($protectqualitydate, $productdatelabel));//过滤空值
        if($this->colspan != ''){
            //入库单和盘点单 弹出的最大列为6
            $this->colspan = $this->colspan - (2 - sizeof($tmplist));//9：最大列数
        }else{
            //多选的最大列为9
            $this->colspan = 9 - (2 - sizeof($tmplist));//9：最大列数
        }

        $warehouselabel = getFixedlabel('WAREHOUSE');
        $batchlabel = getFixedLabel("BATCH");
        $quantitylabel = getFixedLabel("QUANTITY");
        $expiry_dateLang = getFixedLabel("ExpiryDate");
        $tmparr_one['productnamelabel'] = $productnamelabel;
        if ($productsheetlabel != '') {
            $tmparr_one['productsheetlabel'] = $productsheetlabel;
        }
        $tmparr_two = array('warehoursename' => $warehouselabel, 'batch' => $batchlabel,
            'quantity' => $quantitylabel, 'productdate' => $productdatelabel,
            'protectqualitydate' => $protectqualitydate, 'expiry_date' => $expiry_dateLang);
        $tmparr['title'][0] = array_merge($tmparr_one, $tmparr_two);

        crm_load_function_file('getProductQtySaveOrCheck', 'include/Stock', 'CommonStock');
        $sql = getProductQtySaveOrCheckSql($productid, $warehouseid, "", array('productsheet'));
        if ($_REQUEST['searchbatchtext'] != '') {
            $searchbatchtext = $_REQUEST['searchbatchtext'];
            $sql = " select * from (" . $sql . " ) as tmp where batchtext like '%$searchbatchtext%'";

        }

        if (empty($warehouseid)) {
            $warehouseid = 0;
            if (!is_admin($current_user)) {
                $wareidlists = trim(getWareidAll($current_user->id), ',');
                if (empty($wareidlists)) {
                    $sql = " select * from (" . $sql . " ) as tmp where 1>2";
                } else {
                    $sql = " select * from (" . $sql . " ) as tmp where wareid in( " . $wareidlists . ')';
                }
            }
        }

        $result = $adb->pquery($sql, array());

        if ($adb->num_rows($result) > 0) {
            $rows = $adb->num_rows($result);
            for ($i = 0; $i < $rows; $i++) {
                $inventory_qty = $adb->query_result($result, $i, 'inventory_qty');
                $tmp_wareid = $adb->query_result($result, $i, 'wareid');
                $productsheet = $adb->query_result($result, $i, 'productsheet');

                $tmp_batchtext = $adb->query_result($result, $i, 'batchtext');
                $tmp_productid = $adb->query_result($result, $i, 'productid');
                $productname = $adb->query_result($result, $i, 'productname');
                $productdate = $adb->query_result($result, $i, 'productdate');
                $protectqualitydate = $adb->query_result($result, $i, 'protectqualitydate');
                $tmp_warehousename = $adb->query_result($result, $i, 'warehousename');
                $expiry_date = $adb->query_result($result, $i, 'expiry_date'); //失效日期
                if ($tmp_batchtext == '') {
                    $tmp_batchtext = DEFAULTBATCHTEXT;
                }
                $arr[$i]['batchtext'] = $tmp_batchtext;
                $arr[$i]['inventory_qty'] = $inventory_qty;
                $arr[$i]['wareid'] = $tmp_wareid;
                $arr[$i]['productid'] = $tmp_productid;
                $arr[$i]['productsheet'] = $productsheet;
                $arr[$i]['productname'] = $productname;
                $arr[$i]['productdate'] = $productdate;
                $arr[$i]['protectqualitydate'] = $protectqualitydate;
                $arr[$i]['warehousename'] = $tmp_warehousename;
                $arr[$i]['expiry_date'] = $expiry_date == 0 ? '' : $expiry_date;
            }

        }

        $tmpproductqtys = $arr;

        $deployarray = getSys_deploy(49);
        $lengthdecimaldigits = $deployarray['deploy_value'];

        foreach ($tmpproductqtys as $key => $proArr) {
            if (!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'OutboundOrder') {
                if ($proArr['inventory_qty'] <= 0) continue;
            }
            if ($proArr['batchtext'] == DEFAULTBATCHTEXT && $proArr['batchtext'] != "0") {
                continue;
            }
            $proArr['inventory_qty'] = number_format($proArr['inventory_qty'], $lengthdecimaldigits, ".", "");
            $tmparr['content'][] = array(
                'productname' => $proArr['productname'],
                'productsheet' => $proArr['productsheet'],
                "warehoursename" => $proArr['warehousename'],    //仓库名称
                'wareid' => $proArr['wareid'],    //仓库
                'batch' => $proArr['batchtext'],    //批次
                'productdate' => $proArr['productdate'],    //生产日期
                'protectqualitydate' => $proArr['protectqualitydate'],    //保质期
                'quantity' => $proArr['inventory_qty'],  //库存
                'expiry_date' => $proArr['expiry_date']  //结束日期
            );

        }
        return $tmparr;
    }

    public function getListHeader()
    {
        $columnsArr = array('productname'=>'ld_products:productname:productname:Products:2',
            'productsheet'=>'ld_products:productsheet:productsheet:Products:1',
            'productdate'=>'ld_products:productdate:productdate:Products:5',
            'expiry_date'=>'ld_products:expiry_date:expiry_date:Products:5',
            'quantity'=>'ld_stockdetail:quantity:quantity:Stock:10',
            'protectqualitydate'=>'ld_products:protectqualitydate:protectqualitydate:Products:5',
            'wareid'=>'ld_stock:wareid:wareid:Stock:151',
            'batchtext'=>'ld_stockdetail:batchtext:batchtext:Stock:729'
        );
        return $columnsArr;
    }

    public function getListHeaderWidth(){
        if (is_array($this->listHeaderWidthArr) && sizeof($this->listHeaderWidthArr) > 0){
            return $this->listHeaderWidthArr;
        }
        $columnsArr = $this->getListHeader();
        $list_header_width = getCvColumnListWidth($this->frommodule,'SelectBatchPopup',0);
        $listHeaderWidthArr = [];
        crm_load_function_file('getModuleFieldProportion', 'include/utils', 'ListViewUtils');
        foreach ($columnsArr as $columnname => $columns){
            if (isset($list_header_width[$columns])){
                $listHeaderWidthArr[$columnname] = $list_header_width[$columns].'setting';
            }else{
                $uitype = explode(':',$columns)[4];
                $listHeaderWidthArr[$columnname] = getModuleFieldProportion($uitype);
            }
            unset($fieldinfo);
        }
        $columnnameArr = array_keys($columnsArr);
        $product_focus = CRMEntity::getInstance('Products');
        $listHeaderWidthArr = getModuleWidth($product_focus,$listHeaderWidthArr,'Products');
        $this->listHeaderWidthArr = [];
        foreach($columnnameArr as $key => $columnname){
            $this->listHeaderWidthArr[$columnname] = $listHeaderWidthArr[$key];
        }
        if ($this->frommodule == 'OutboundOrder'){
            $this->listHeaderWidthArr['checkbox'] = $list_header_width['checkbox'] ?? 40;
        }
        unset($listHeaderWidthArr,$columnsArr,$tmp_columnsArr,$list_header_width,$product_focus,$columnnameArr);
        return $this->listHeaderWidthArr;
    }

    public function setFromModule($frommodule)
    {
        $this->frommodule = $frommodule;
    }
}