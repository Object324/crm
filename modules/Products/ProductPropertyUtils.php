<?php

Class ProductPropertyUtils{
    public $params;
    public $price_decimal=2;
    public $quantity_decimal=2;
    public static $static_separator = '|##|';
    public $separator = '|##|';
    public $module = 'Products';
    public $DetailFieldsHtmlObj ;
    public $tabDetailFieldDataObj ;
    public $detailfields_array ;
    public function __construct($params){
        $this->params = $params;

        $sysdeploy_93 = getSys_deploy(93);	// 系统参数控制单价小数位
        $this->price_decimal = $sysdeploy_93['deploy_value'];

        $sysdeploy_49 = getSys_deploy(49);	// 系统参数控制数量小数位
        $this->quantity_decimal = $sysdeploy_49['deploy_value'];

        $focus = CRMEntity::getInstance($this->module);
        crm_load_class_file("cls_TabDetailFieldsHtml",'include/TabDetailFields');
        $this->DetailFieldsHtmlObj = new cls_TabDetailFieldsHtml($focus,$this->module);

        crm_load_class_file("TabDetailFieldsData",'include/TabDetailFields');
        $this->tabDetailFieldDataObj = new TabDetailFieldsData($focus,$this->module);

    }
    public $detailimage_arr = [
        'line_img'=>array(
            "ShowHyperlinks"=> "yes",
            "allowcreate"=>null,
            "allowcreate_presence"=>null,
            "allowedit"=> null,
            "bigtype"=> "image",
            "columnname"=>"line_img",
            "edit_permission"=> "0",
            "editpage"=> null,
            "fieldlabel"=> "产品图片",
            "fieldname"=> "line_img",
            "fieldonly"=> null,
            "fieldplaceholder"=> "",
            "fieldtype"=> "Image",
            "fieldvaluecolor"=> "",
            "relatedmodulefield"=> "no",
            "tablename"=> "ld_productdetail",
            "typeofdata"=>"V~O",
            "uitype"=> 69
        )
    ];//明细字段信息

    //获取产品的默认属性组合--开启属性的才查询  以productid索引
    public static function getDefaultPropertyByProductid($productid_str){
        global $adb;
        $defaultproperty_info = [];
        $selectsql = "select ld_productdetail.productid,ld_productdetail.lineitem_id,ld_productdetail.setdefault,ld_productdetail.sequence 
from ld_productdetail left join ld_products on ld_productdetail.productid=ld_products.productid  
where property_status=1 and find_in_set(ld_productdetail.productid,?)";
        $select_res = $adb->pquery($selectsql,array($productid_str));
        $select_nums = $adb->num_rows($select_res);
        for($i=0;$i<$select_nums;$i++){
            $tmp_productid = $adb->query_result($select_res,$i,'productid');
            $productdetail_lineitem_id = $adb->query_result($select_res,$i,'lineitem_id');
            $setdefault = $adb->query_result($select_res,$i,'setdefault');
            $sequence = $adb->query_result($select_res,$i,'sequence');
            if($setdefault==1){
                $defaultproperty_info[$tmp_productid] = $productdetail_lineitem_id;
            }else if($sequence==1){
                $defaultproperty_info[$tmp_productid] = $productdetail_lineitem_id;
            }
        }
        return $defaultproperty_info;
    }
    //根据传递的productdetail_lineitem_ids数组批量获取属性值信息
    public static function getPropertyInfoByProductDetailId($productdetail_lineitem_id_str){
        global $adb;
        $productproperty_info = [];
        if(empty($productdetail_lineitem_id_str))
        {
            return [];
        }

        $ppsql = " select  concat(p.productproperty_name,':',pdetail.property_value_name,' ') as productproperty,concat(pdetail.property_value_name,'') as productproperty_short,
         p2p.propertydetail_lineitem_id as propertydetail_lineitem_id,
         p2p.productdetail_lineitem_id as productdetail_lineitem_id,
         ld_productdetail.*
 from ld_productdetail2propertydetail p2p 
inner join ld_productdetail on ld_productdetail.lineitem_id=p2p.productdetail_lineitem_id
inner join ld_productpropertydetail pdetail on p2p.propertydetail_lineitem_id=pdetail.lineitem_id
inner join ld_productproperty p on p.productpropertyid=pdetail.id where p2p.productdetail_lineitem_id in ($productdetail_lineitem_id_str)";
        $ppres = $adb->pquery($ppsql);

        $ppnums = $adb->num_rows($ppres);
        if($ppnums>0) {
            for ($j = 0; $j < $ppnums; $j++) {
                $tmpproductdetail_lineitem_id = $tmpkey = $adb->query_result($ppres,$j,'productdetail_lineitem_id');
                $tmpproductproperty = $adb->query_result($ppres,$j,'productproperty');
                $tmpproductproperty_short = $adb->query_result($ppres,$j,'productproperty_short');
                if($tmpkey>0){
                    //line_unit_price,line_procostprice,line_qtyearly,line_productcode
                    if(!isset($productproperty_info[$tmpkey])){
                        $productproperty_info[$tmpkey] = [];
                        $productproperty_info[$tmpkey]['productdetail_lineitem_id'] = $tmpproductdetail_lineitem_id;
                        $productproperty_info[$tmpkey]['line_unit_price'] = $adb->query_result($ppres,$j,'line_unit_price');
                        $productproperty_info[$tmpkey]['line_procostprice'] = $adb->query_result($ppres,$j,'line_procostprice');
                        $productproperty_info[$tmpkey]['line_qtyearly'] = $adb->query_result($ppres,$j,'line_qtyearly');
                        $productproperty_info[$tmpkey]['line_productcode'] = $adb->query_result($ppres,$j,'line_productcode');
                    }
                    $productproperty_info[$tmpkey]['propertydetail_lineitem_id_combin'][] = $adb->query_result($ppres,$j,'propertydetail_lineitem_id');
                    $productproperty_info[$tmpkey]['productdetail_lineitem_id_value'][] = $tmpproductproperty;
                    $productproperty_info[$tmpkey]['productdetail_lineitem_id_value_s'][] = $tmpproductproperty_short;
                }
            }
        }
        return $productproperty_info;
    }
    public static function getPropertyInfoByCartId($cartid_str){
        global $adb;
        $productproperty_info = [];


        $ppsql = " select  concat(p.productproperty_name,':',pdetail.property_value_name,' ') as productproperty,
         p2p.propertydetail_lineitem_id as propertydetail_lineitem_id,
         p2p.productdetail_lineitem_id, 
         ld_productdetail.*
 from ld_shopcartdetails shop 
inner join ld_productdetail on ld_productdetail.lineitem_id=shop.productdetail_lineitem_id
inner join ld_productdetail2propertydetail p2p on p2p.productdetail_lineitem_id=shop.productdetail_lineitem_id
inner join ld_productpropertydetail pdetail on p2p.propertydetail_lineitem_id=pdetail.lineitem_id
inner join ld_productproperty p on p.productpropertyid=pdetail.id where shop.cartid in ($cartid_str) ";
        $ppres = $adb->pquery($ppsql);
        $ppnums = $adb->num_rows($ppres);
        if($ppnums>0) {
            for ($j = 0; $j < $ppnums; $j++) {
                $tmpproductdetail_lineitem_id = $tmpkey = $adb->query_result($ppres,$j,'productdetail_lineitem_id');
                $tmpproductproperty = $adb->query_result($ppres,$j,'productproperty');
                if($tmpkey>0){
                    //line_unit_price,line_procostprice,line_qtyearly,line_productcode
                    if(!isset($productproperty_info[$tmpkey])){
                        $productproperty_info[$tmpkey] = [];
                        $productproperty_info[$tmpkey]['productdetail_lineitem_id'] = $tmpproductdetail_lineitem_id;
                        $productproperty_info[$tmpkey]['line_unit_price'] = $adb->query_result($ppres,$j,'line_unit_price');
                        $productproperty_info[$tmpkey]['line_procostprice'] = $adb->query_result($ppres,$j,'line_procostprice');
                        $productproperty_info[$tmpkey]['line_qtyearly'] = $adb->query_result($ppres,$j,'line_qtyearly');
                        $productproperty_info[$tmpkey]['line_productcode'] = $adb->query_result($ppres,$j,'line_productcode');
                    }
                    $productproperty_info[$tmpkey]['propertydetail_lineitem_id_combin'][] = $adb->query_result($ppres,$j,'propertydetail_lineitem_id');
                    $productproperty_info[$tmpkey]['productdetail_lineitem_id_value'][] = $tmpproductproperty;

                }

            }
        }
        return $productproperty_info;
    }


    //获取选中的产品属性信息
    public function getProductPropertyInfo(){
        global $adb;
        $productid = $this->params['productid'];
        $productproperty_arr = [];

        $productpropertyid_str = $this->params['productpropertyid'];//多个是逗号分隔的
//        /$lineitem_id_str = $this->params['lineitem_id'];//多个是逗号分隔的 用户可能会勾选某几个属性值名称
        $selectquery = " SELECT
	p.productpropertyid,
	p.productproperty_name,
	p.productproperty_no,
	pdetail.lineitem_id,
	pdetail.property_value_name,
	pdetail.property_value_no,
	ifnull(
		tmp.propertydetail_lineitem_id,
		0
	) AS tmppropertydetail_lineitem_id
FROM
	ld_productproperty p
LEFT JOIN ld_productpropertydetail pdetail ON p.productpropertyid = pdetail.id
LEFT JOIN (
	SELECT DISTINCT
		p2p.propertydetail_lineitem_id
	FROM
		ld_productdetail
	INNER JOIN ld_productdetail2propertydetail p2p ON p2p.productdetail_lineitem_id = ld_productdetail.lineitem_id
	WHERE
		ld_productdetail.productid = ?
) tmp ON tmp.propertydetail_lineitem_id = pdetail.lineitem_id
WHERE
	p.deleted=0 and ifnull(property_status, 0) = 0 and find_in_set(p.productpropertyid,?) 
ORDER BY
	productpropertyid ASC,
	pdetail.sequence ASC ";

        $selectres = $adb->pquery($selectquery,array($productid,$productpropertyid_str));
        $selectnums = $adb->num_rows($selectres);
        $productproperty_name_arr = [];
        if($selectnums>0){
            for($i=0;$i<$selectnums;$i++){
                $productpropertyid = $adb->query_result($selectres,$i,'productpropertyid');
                $key = 'pp'.$productpropertyid;//前面加个字符串变成关联数组。JS中方便使用。
                if(!isset($productproperty_arr[$key])){
                    $productproperty_name = $adb->query_result($selectres,$i,'productproperty_name');
                    $productproperty_arr[$key] = [
                        'productpropertyid'=>$productpropertyid,
                        'productproperty_name'=>$productproperty_name,
                        'productproperty_no'=>$adb->query_result($selectres,$i,'productproperty_no'),
                        'details'=>[]
                    ];
                    $productproperty_name_arr[] = $productproperty_name;
                }
                $lineitem_id = $adb->query_result($selectres,$i,'lineitem_id');//产品属性明细的主键ID
                $tmppropertydetail_lineitem_id = $adb->query_result($selectres,$i,'tmppropertydetail_lineitem_id');
                $selected = false;
                if($productid==0){
                    $selected = true;
                }

                if($productid>0&&$tmppropertydetail_lineitem_id>0){
                    $selected = true;
                }
                //编辑页面 产品明细的主键ID大于0 或者新建界面
                $productproperty_arr[$key]['details'][] = [
                    'tmppropertydetail_lineitem_id'=>$tmppropertydetail_lineitem_id,
                    'lineitem_id'=>$lineitem_id,
                    'property_value_name'=>$adb->query_result($selectres,$i,'property_value_name'),
                    'property_value_no'=>$adb->query_result($selectres,$i,'property_value_no'),
                    'selected'=>$selected//是否选中  新建产品的时候直接全部选中。编辑产品的时候，要根据产品表的分录来判断选中哪些
                ];
            }
        }

        $res = $this->resetFieldValueList($productproperty_arr);
        $res['productproperty_arr'] = $productproperty_arr;
        $res['productproperty_name_arr'] = $productproperty_name_arr;
        return $res;
    }
    //购物车修改产品属性 弹框内容数据
    public function getProductPropertyBlockRequest() {
        $params_arr = $this->params;
        $module = 'Products';
        $params_arr['productpropertyid'] = '';
        $tmpfocus = CRMEntity::getInstance($module);
        $tmpfocus->id = $params_arr['productid'];
        $tmpfocus->retrieve_entity_info($params_arr['productid'], $module);
        $arr['columnfields_value']=$tmpfocus->column_fields;

        crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
        $currencyInfo = getInventoryCurrencyInfo($module,$params_arr['productid']);
        $product_base_currency = $currencyInfo['currency_id'];

        //zxm @date:2024/10/16 @reason: 购物车列表 点击修改属性按钮 显示弹框
        if ($tmpfocus->id > 0) {
            //关联选择单据 选产品属性的值
            $this->params['productpropertyid'] = $tmpfocus->column_fields['propertyids'];
        }

        $restBlocks = $this->getProductPropertyBlock();
        $restBlocks['product_base_currency'] = $product_base_currency;
        //分录附件信息
        $detailfilejsondata = array();
        if ($tmpfocus->id > 0) {
            $detailfilejsondata = getAllDetailFile_imageInfo($tmpfocus->id, 'Products');
        }
        $arr['detailfilejsondata'] = $detailfilejsondata;
        $arr['detailfields'] = $restBlocks['detailfields'];
        unset($restBlocks['detailfields']);
        $arr['restBlocks'] = $restBlocks;
        return $arr;
    }
    //获取产品属性区块数据
    public function getProductPropertyBlock() {
        $this->detailfields_array = $this->tabDetailFieldDataObj->TabDetailFields->getFieldListArray();
        $res = $this->getProductPropertyInfo();
        $fieldValueList = $res['fieldValueList'];

        $arr = [
            //这里应该从表里读字段
            'tableHeader' => [
                ['label' => '#', 'width' => '5%','fieldtype'=>'html','fieldname'=>''],
            ],
            'fieldArr'=>['no'],
            //'fieldArr'=>['no','attribute_combination','line_unit_price','line_procostprice','line_qtyearly','line_img','line_status','line_productcode'],
            'detailimage_arr'=>array_values($this->detailimage_arr),//明细字段附件信息
            'fieldValueList'=>$fieldValueList,
            'detailfields'=>$this->detailfields_array,
            'productproperty_arr'=>$res['productproperty_arr'],
            'productproperty_name_arr'=>$res['productproperty_name_arr'],
            'productproperty_name_header_arr'=>$res['productproperty_name_header_arr'],

        ];
        foreach($this->tabDetailFieldDataObj->tabPresenceDetailFields as $columnanme => $field){
            $arr['tableHeader'][] = ['label' => $field->getfieldLabel(), 'width' => $field->getWidth().'%','fieldtype'=>$field->getFieldType(),'fieldname'=>$field->getFieldName()];
            $arr['fieldArr'][] = $field->getFieldName();
        }
        $arr['tableHeader'][] = ['label' => getFixedLabel('OPERATING'), 'width' => '8%','fieldtype'=>'action','fieldname'=>''];//操作列
        $arr['fieldArr'][] = 'action';//操作列

        return $arr;
    }
    //点击生成 生成明细行数组
    public function resetFieldValueListRequest(){
        $productproperty_arr = Zend_Json::decode($this->params['productproperty_arr']);
        return $this->resetFieldValueList($productproperty_arr);
    }
    //产品属性明细行数据
    public function resetFieldValueList($productproperty_arr){
        $productid = $this->params['productid'];
        $productdetail_lineitem_id = $this->params['productdetail_lineitem_id'];
        $productdetail_info = [];
        if($productid>0){
            $productdetail_info = $this->getProductDetailInfo($productid);
        }

        $productpropertyList = [];

        if(sizeof($productproperty_arr)<=1){
            $productpropertyList = array_values($productproperty_arr)[0];

        }else{
            $productproperty_arr = array_values($productproperty_arr);

            //如果数组只有1个属性，不需要调用递归
            $property1 = $productproperty_arr[0];
            $property2 = $productproperty_arr[1];
            $productproperty_arr = array_slice($productproperty_arr,2);

            $this->getPPRecursion($productproperty_arr,$property1,$property2,$productpropertyList);
        }

        $fieldValueList = [];
        $productpropertyid_arr = !empty($productpropertyList['productpropertyid'])?explode($this->separator,$productpropertyList['productpropertyid']):[];//产品属性主表ID
        $productproperty_name_arr = !empty($productpropertyList['productproperty_name'])?explode($this->separator,$productpropertyList['productproperty_name']):[];//产品属性主表name

        $productproperty_name_header_arr = $productproperty_name_arr;

        array_unshift($productproperty_name_header_arr,'产品属性');//弹框表头
        array_unshift($productproperty_name_header_arr,'#');//序号

        $fieldnameArr = ['line_unit_price','line_procostprice'];
        $moreCurrencyList = [];
        if($productid>0){
            //保存到数据库的更多币种价格设置
            $moreCurrencyList = $this->getMoreCurrencyList($productid,$fieldnameArr);
        }
        //启用的币种信息
        $moreCurrencyNewInfo = $this->getMoreCurrencyNewInfo($fieldnameArr);

        foreach($productpropertyList['details'] as $k=>$linePropertyInfo){

            $key = "pdetail";
            $tmpproductdetail_info = [];
            if(isset($productdetail_info[$key.$linePropertyInfo['lineitem_id']])){
                $tmpproductdetail_info = $productdetail_info[$key.$linePropertyInfo['lineitem_id']];
            }

            $tmpfieldValueList = [];
            $tmpfieldValueList['no'] = $k+1;//序号
            $tmpfieldValueList['sequence'] = isset($tmpproductdetail_info['sequence'])?$tmpproductdetail_info['sequence']:$k+1;//排序
            $tmpfieldValueList['lineitem_id'] = isset($tmpproductdetail_info['lineitem_id'])?$tmpproductdetail_info['lineitem_id']:0;//productdetail表的主键ID
            $tmpfieldValueList['propertydetail_lineitem_id_combin'] = $linePropertyInfo['lineitem_id'];
            $tmpfieldValueList['property_value_name_combin'] = isset($tmpproductdetail_info['property_value_name_combin'])?$tmpproductdetail_info['property_value_name_combin']:$linePropertyInfo['property_value_name'];
            $tmpfieldValueList['line_unit_price'] = isset($tmpproductdetail_info['line_unit_price'])?number_format($tmpproductdetail_info['line_unit_price'],$this->price_decimal,'.',''):'0.00';
            $tmpline_unit_price_arr = explode('.',$tmpfieldValueList['line_unit_price']);
            $tmpfieldValueList['line_unit_price_arr'] = array($tmpline_unit_price_arr[0].'.',$tmpline_unit_price_arr[1]);//移动端 要小数整数分开的

            $tmpfieldValueList['line_procostprice'] = isset($tmpproductdetail_info['line_procostprice'])?number_format($tmpproductdetail_info['line_procostprice'],$this->price_decimal,'.',''):'0.00';
            $tmpfieldValueList['line_qtyearly'] = isset($tmpproductdetail_info['line_qtyearly'])?number_format($tmpproductdetail_info['line_qtyearly'],$this->quantity_decimal,'.',''):'0';

            $tmpfieldValueList['line_status'] = isset($tmpproductdetail_info['line_status'])?$tmpproductdetail_info['line_status']:1;
            $tmpfieldValueList['setdefault'] = isset($tmpproductdetail_info['setdefault'])?$tmpproductdetail_info['setdefault']:0;//设为默认
            $tmpfieldValueList['line_productcode'] = isset($tmpproductdetail_info['line_productcode'])?$tmpproductdetail_info['line_productcode']:'';
            //$productid<=0 新建时  $tmpfieldValueList['lineitem_id']>0编辑时且存在数据库的值  $linePropertyInfo['selected']==1重新勾选生成时
            //$tmpfieldValueList['selected'] = ($productid<=0||$tmpfieldValueList['lineitem_id']>0||$linePropertyInfo['selected']==1)?true:false;//创建产品时候:默认选中  编辑产品时候:默认不选中
            $tmpfieldValueList['selected'] = ($tmpfieldValueList['lineitem_id']>0||$linePropertyInfo['selected']==1)?true:false;//创建产品时候:默认选中  编辑产品时候:默认不选中
            $property_lineitem_id_arr = explode($this->separator,$linePropertyInfo['lineitem_id']);

            $property_value_name_arr = explode($this->separator,$linePropertyInfo['property_value_name']);
            $tmpfieldValueList['attribute_combination'] = [];

            foreach($property_lineitem_id_arr as $propertyKey=>$property_lineitem_id){
                $tmpfieldValueList['attribute_combination'][$propertyKey]['productdetail_lineitem_id'] = $tmpproductdetail_info['lineitem_id'];
                $tmpfieldValueList['attribute_combination'][$propertyKey]['propertydetail_lineitem_id'] = $property_lineitem_id;
                $tmpfieldValueList['attribute_combination'][$propertyKey]['propertyid'] = $productpropertyid_arr[$propertyKey];
                $tmpfieldValueList['attribute_combination'][$propertyKey]['productproperty_name'] = $productproperty_name_arr[$propertyKey];
                $tmpfieldValueList['attribute_combination'][$propertyKey]['property_value_name'] = $property_value_name_arr[$propertyKey];
            }

            //价格多币种信息
            foreach($fieldnameArr as $tmpfieldname){
                foreach($moreCurrencyNewInfo[$tmpfieldname] as $tmpcurrency_id=>$tmp_currencyinfo){
                    $tmpfieldValueList[$tmpfieldname.'_morecurrency'][$tmpcurrency_id] = $tmp_currencyinfo;
                    if($productid>0
                        &&isset($moreCurrencyList[$tmpfieldname])
                        &&isset($moreCurrencyList[$tmpfieldname][$tmpfieldValueList['lineitem_id']])
                        &&isset($moreCurrencyList[$tmpfieldname][$tmpfieldValueList['lineitem_id']][$tmpcurrency_id])){
                        $tmpfieldValueList[$tmpfieldname.'_morecurrency'][$tmpcurrency_id] = $moreCurrencyList[$tmpfieldname][$tmpfieldValueList['lineitem_id']][$tmpcurrency_id];
                    }
                }
                $tmpfieldValueList[$tmpfieldname.'_morecurrency'] = array_values($tmpfieldValueList[$tmpfieldname.'_morecurrency']);
            }
            $tmpfieldValueList['detailid'] = $tmpfieldValueList['lineitem_id'];
            $tmpfieldValueList['line_img'] =  $this->DetailFieldsHtmlObj->TabDetailFieldsHtmlTd->getDetailImageHtml($tmpfieldValueList,$k+1,'line_img',$this->tabDetailFieldDataObj->tabPresenceDetailField['line_img']);

            $fieldValueList[$k] = $tmpfieldValueList;
        };
        return [
            'productproperty_name_header_arr'=>$productproperty_name_header_arr,
            'fieldValueList'=>$fieldValueList
        ];
    }
    //从ld_productcurrencyrel表获取产品的价格字段多币种设置
    public function getMoreCurrencyList($productid,$fieldnameArr){
        global $adb;
        $price_All = [];//所有的

        $module = 'Products';
        require_once(globalStatic::$root_directory."include/utils/InventoryUtils.php");
        $product_base_conv_rate = getBaseConversionRateForProduct($productid,'edit',$module);

        $price_decimal = $this->price_decimal;
        $currencyinfo = getInventoryCurrencyInfo($module,$productid);
        $product_currency_id = $currencyinfo['currency_id'];//获取产品基本币种i
        //产品编辑  lineitem_id>
        $query = "select ld_currency_info.*, ld_productcurrencyrel.converted_price, ld_productcurrencyrel.actual_price,ld_productcurrencyrel.lineitem_id,ld_productcurrencyrel.price_type
                from ld_currency_info
                left join ld_productcurrencyrel
                on ld_currency_info.id = ld_productcurrencyrel.currencyid and ld_productcurrencyrel.productid = ? and ld_productcurrencyrel.lineitem_id>0
                where ld_currency_info.currency_status = 'Active' and ld_currency_info.deleted=0 order by ld_currency_info.id";
        $params = array($productid);
        $res = $adb->pquery($query, $params);
        foreach($fieldnameArr as $tmpfieldname) {
            $price_All[$tmpfieldname] = [];
            for ($i = 0; $i < $adb->num_rows($res); $i++) {
                $price_type = $adb->query_result($res, $i, 'price_type');
                if($tmpfieldname==$price_type) {
                    $lineitem_id = $adb->query_result($res, $i, 'lineitem_id');
                    $tmpprice_details['lineitem_id'] = $lineitem_id;
                    $tmpprice_details['productid'] = $productid;
                    $tmpprice_details['currencylabel'] = $adb->query_result($res, $i, 'currency_name');
                    $tmpprice_details['currencycode'] = $adb->query_result($res, $i, 'currency_code');
                    $tmpprice_details['currencysymbol'] = $adb->query_result($res, $i, 'currency_symbol');
                    $currency_id = $adb->query_result($res, $i, 'id');
                    $tmpprice_details['curid'] = $currency_id;
                    $tmpprice_details['curname'] = $tmpfieldname . '_curname' . $currency_id;
                    $cur_value = $adb->query_result($res, $i, 'actual_price');

                    $conversion_rate = $adb->query_result($res, $i, 'conversion_rate');
                    $actual_conversion_rate = $product_base_conv_rate * $conversion_rate;
                    if ($cur_value == null || $cur_value == '') {
                        $tmpprice_details['check_value'] = false;
                    } else {
                        $tmpprice_details['check_value'] = true;
                    }

                    $tmpprice_details['curvalue'] = sprintf('%.' . $price_decimal . 'f', $cur_value);
                    $tmpprice_details['conversionrate'] = $actual_conversion_rate;
                    $tmpprice_details['currencylabelShow'] = getTranslatedCurrencyString($tmpprice_details['currencylabel']);
                    $is_basecurrency = false;
                    if ($currency_id == $product_currency_id) {
                        $is_basecurrency = true;
                    }
                    $tmpprice_details['is_basecurrency'] = $is_basecurrency;
                    $price_All[$tmpfieldname][$lineitem_id][$currency_id] = $tmpprice_details;//按fieldname索引行 按lineitem_id索引列，
                }
            }
        }

        return $price_All;
    }
    //多币种信息
    public function getMoreCurrencyNewInfo($fieldnameArr){
        global $adb;
        $price_All = [];//所有的
        //产品新建
        $currencyobj=Currency::getInstance($adb);
        $user_currency_id = $currencyobj->getCurrencyId();
        $query = "select ld_currency_info.* from ld_currency_info
                        where ld_currency_info.currency_status = 'Active' and ld_currency_info.deleted=0 order by ld_currency_info.id";
        $res = $adb->pquery($query, array());

        $tmpprice_details = [];
        foreach($fieldnameArr as $tmpfieldname) {
            for ($i = 0; $i < $adb->num_rows($res); $i++) {
                $currency_id = $adb->query_result($res, $i, 'id');
                $tmpprice_details[$currency_id]['currencylabel'] = $adb->query_result($res, $i, 'currency_name');
                $tmpprice_details[$currency_id]['currencycode'] = $adb->query_result($res, $i, 'currency_code');
                $tmpprice_details[$currency_id]['currencysymbol'] = $adb->query_result($res, $i, 'currency_symbol');

                $tmpprice_details[$currency_id]['curid'] = $currency_id;
                $conversion_rate = $adb->query_result($res, $i, 'conversion_rate');
                $currencyobj = Currency::getInstance($adb, $user_currency_id);
                $CurrencyRate = $currencyobj->getCurrencyRate();
                $product_base_conv_rate = 1 / $CurrencyRate;
                $actual_conversion_rate = $product_base_conv_rate * $conversion_rate;
                $tmpprice_details[$currency_id]['check_value'] = false;
                $tmpprice_details[$currency_id]['curvalue'] = '0';
                $tmpprice_details[$currency_id]['conversionrate'] = $actual_conversion_rate;

                $is_basecurrency = 0;
                if ($currency_id == $user_currency_id) {
                    $is_basecurrency = 1;
                }
                $tmpprice_details[$currency_id]['currencylabelShow'] = getTranslatedCurrencyString($tmpprice_details[$currency_id]['currencylabel']);
                $tmpprice_details[$currency_id]['is_basecurrency'] = $is_basecurrency;
                $tmpprice_details[$currency_id]['curname'] = $tmpfieldname . '_curname' . $tmpprice_details[$currency_id]['curid'];
            }
            $price_All[$tmpfieldname] = $tmpprice_details;
        }
        return $price_All;
    }

    //获取产品的明细信息
    public function getProductDetailInfo($productid){
        global $adb;
        $productdetails_sql = " select pdetail.lineitem_id,
pdetail.property_value_name_combin,
pdetail.sequence,
pdetail.line_unit_price,
pdetail.line_procostprice,
pdetail.line_qtyearly,
pdetail.line_img,
pdetail.line_status,
pdetail.setdefault,
pdetail.line_productcode,group_concat(pdetail2property.propertydetail_lineitem_id separator '".$this->separator."') as propertydetail_lineitem_id_combin
from ld_productdetail pdetail 
left join ld_productdetail2propertydetail pdetail2property on pdetail.lineitem_id=pdetail2property.productdetail_lineitem_id
where pdetail.productid=? group by pdetail.lineitem_id  ; ";
        $productdetails_res = $adb->pquery($productdetails_sql,array($productid));
        $productdetails_nums = $adb->num_rows($productdetails_res);
        $productdetails_arr = [];
        for($j=0;$j<$productdetails_nums;$j++){
            $propertydetail_lineitem_id_combin = $adb->query_result($productdetails_res,$j,'propertydetail_lineitem_id_combin');
            $key = 'pdetail'.$propertydetail_lineitem_id_combin;
            if(!isset($productdetails_arr[$key])){
                $productdetails_arr[$key] = [
                    'lineitem_id'=>$adb->query_result($productdetails_res,$j,'lineitem_id'),
                    'property_value_name_combin'=>$adb->query_result($productdetails_res,$j,'property_value_name_combin'),
                    'propertydetail_lineitem_id_combin'=>$adb->query_result($productdetails_res,$j,'propertydetail_lineitem_id_combin'),
                    'sequence'=>$adb->query_result($productdetails_res,$j,'sequence'),
                    'line_unit_price'=>$adb->query_result($productdetails_res,$j,'line_unit_price'),
                    'line_procostprice'=>$adb->query_result($productdetails_res,$j,'line_procostprice'),
                    'line_qtyearly'=>$adb->query_result($productdetails_res,$j,'line_qtyearly'),
                    'line_img'=>$adb->query_result($productdetails_res,$j,'line_img'),
                    'setdefault'=>$adb->query_result($productdetails_res,$j,'setdefault'),
                    'line_status'=>$adb->query_result($productdetails_res,$j,'line_status'),
                    'line_productcode'=>$adb->query_result($productdetails_res,$j,'line_productcode'),
                ];
            }
        }

        return $productdetails_arr;
    }
    //获取属性组合
    public function getProductPropertyCombination(){
        $productproperty_info = $this->getProductPropertyInfo();
        $productproperty_arr = array_values($productproperty_info['productproperty_arr']);
        $productpropertyList = [];
        $productproperty_name_header_arr = $productproperty_info['productproperty_name_arr'];
        if(sizeof($productproperty_arr)<=0){
            $productpropertyList = $productproperty_arr;
        }else{
            array_unshift($productproperty_name_header_arr,'产品属性');//弹框表头
            //如果数组只有1个属性，不需要调用递归

            $property1 = $productproperty_arr[0];
            $property2 = $productproperty_arr[1];
            $productproperty_arr = array_slice($productproperty_arr,2);

            $this->getPPRecursion($productproperty_arr,$property1,$property2,$productpropertyList);
        }
        return ['productproperty_name_header_arr'=>$productproperty_name_header_arr,'productpropertyList'=>$productpropertyList];
    }

    /**
     * @param $productproperty_arr //所有的属性 属性数组
     * @param $property1 //属性1
     * @param $property2 //属性2
     * @param $res //结果数组
     * @return void
     */
    public function getPPRecursion($productproperty_arr,$property1,$property2,&$res){
        $separator = $this->separator;

        $newPropertyArr = [
            'productpropertyid'=>$property1['productpropertyid'].$separator.$property2['productpropertyid'],
            'productproperty_name'=>$property1['productproperty_name'].$separator.$property2['productproperty_name'],
            'productproperty_no'=>$property1['productproperty_no'].$separator.$property2['productproperty_no'],
            'details'=>array()
        ];
        //计数 数组1选中的有几个
        $tmp_property1nums=0;
        foreach($property1['details'] as $detailProperty1){
            if($detailProperty1['selected']!=true){
                continue;//未选中 不生成该属性的组合
            }
            $tmp_property1nums++;
            //计数 数组2选中的有几个
            $tmp_property2nums=0;
            foreach($property2['details'] as $detailProperty2){
                if($detailProperty2['selected']!=true){
                    continue;//未选中 不生成该属性的组合
                }
                $tmp_property2nums++;
                $newPropertyArr['details'][]=array(
                    'lineitem_id'=>$detailProperty1['lineitem_id'].$separator.$detailProperty2['lineitem_id'],
                    'property_value_name'=>$detailProperty1['property_value_name'].$separator.$detailProperty2['property_value_name'],
                    'property_value_no'=>$detailProperty1['property_value_no'].$separator.$detailProperty2['property_value_no'],
                    'selected'=>true//是否选中  新建产品的时候直接全部选中。编辑产品的时候，要根据产品表的分录来判断选中哪些
                );
            }
            //如果数组2 一个属性值都没选择  则只需要返回属性值数组1 的数据
            if($tmp_property2nums==0){
                $newPropertyArr['details'][]=array(
                    'lineitem_id'=>$detailProperty1['lineitem_id'],
                    'property_value_name'=>$detailProperty1['property_value_name'],
                    'property_value_no'=>$detailProperty1['property_value_no'],
                    'selected'=>true//是否选中  新建产品的时候直接全部选中。编辑产品的时候，要根据产品表的分录来判断选中哪些
                );
            }
        }
        //如果数组1 一个属性值都没选择 返回空数组
        if($tmp_property1nums==0){
            return array();
        }
        if(sizeof($productproperty_arr)>=1){
            array_unshift($productproperty_arr,$newPropertyArr);
            $productproperty_arr = array_values($productproperty_arr);
            $property1 = $productproperty_arr[0];
            $property2 = $productproperty_arr[1];
            $productproperty_arr = array_slice($productproperty_arr,2);
            $this->getPPRecursion($productproperty_arr,$property1,$property2,$res);
        }else{
            $res = $newPropertyArr;
        }

    }

    public function setProductPropertyIds() {
        if(!empty($this->params['productpropertyid'])) {
            return;
        }
        $productId = $this->params['productid'];
        if(empty($productId)) {
            return ;
        }
        $module = 'Products';
        $tmpFocus = CRMEntity::getInstance($module);
        $tmpFocus->id = $productId;
        $tmpFocus->retrieve_entity_info($productId, $module);
        $this->params['productpropertyid'] = $tmpFocus->column_fields['propertyids'];
    }

    public function getPropertyGroupInfo() {
        $this->setProductPropertyIds();
        $res = $this->getProductPropertyInfo();

        $propertyArr = [];
        $propertyGroupArr = [];
        $defaultIndex = 0;
        foreach ($res['productproperty_arr'] as $index => $propertyInfo) {
            $details = [];
            foreach ($propertyInfo['details'] as $index => $item) {
                array_push($details, [
                    'lineitem_id' => $item['lineitem_id'],
                    'label' => $item['property_value_name'],
                ]);
            }
            array_push($propertyArr, [
                'id' => $propertyInfo['productpropertyid'],
                'label' => $propertyInfo['productproperty_name'],
                'details' => $details,
            ]);
        }
        foreach ($res['fieldValueList'] as $index => $propertyGroupInfo) {
            if($propertyGroupInfo['selected'] === false) {
                continue;
            }
            if($propertyGroupInfo['line_status'] === '0') {
                //($propertyGroupInfo['line_status'] === '1') ? 'yes' : 'no',
                continue;
            }
            $value = [];
            $label = [];
            foreach ($propertyGroupInfo['attribute_combination'] as $index => $item) {
                $value['property_'.$item['propertyid']] = [
                    'id' => $item['propertyid'],
                    'lineitem_id' => $item['propertydetail_lineitem_id'],
                    'label' => $item['property_value_name'],
                ];
                $label[] = $item['productproperty_name'] . ': ' . $item['property_value_name'];
            }
            if($propertyGroupInfo['setdefault'] === '1') {
                $defaultIndex = count($propertyGroupArr);
            }
            $tmpCurrencyInfo = [];
            foreach ($propertyGroupInfo['line_unit_price_morecurrency'] as $index => $info) {
                $tmpCurrencyInfo['currency_'.$info['curid']] = [
                    'id' => $info['curid'],
                    'unit_price' => $info['curvalue'],
                    'procostprice' => $propertyGroupInfo['line_procostprice_morecurrency'][$index]['curvalue'],
                ];
            }
            array_push($propertyGroupArr, [
                'id' => $propertyGroupInfo['lineitem_id'],
                'available' => 'yes',
                'value' => $value,
                'label' => $label,
                'currencyInfo' => $tmpCurrencyInfo,
            ]);
        }
        return [
            'propertyArr' => $propertyArr,
            'propertyGroupArr' => $propertyGroupArr,
            'defaultIndex' => $defaultIndex,
            'theadArr' => $res['productproperty_name_header_arr'],
        ];
    }

}

?>