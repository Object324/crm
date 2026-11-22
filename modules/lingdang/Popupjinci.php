<?php
require_once(globalStatic::$root_directory."include/Popup/PopUpListView.php");
include(globalStatic::$root_directory.'data/PopInventory.php');
global $app_strings, $default_charset;
global $currentModule, $current_user,$list_max_entries_per_page_new;
global $theme, $adb;
require('user_privileges/user_language_'.$current_user->id.'.php');
$url_string = '';
$_REQUEST['SearchScope']='SmOwner_Search_All';//037028: 分录中关联选择源单，例如:选产品、或者选合同等，在源单列表做了查询之后，会影响选择这里
$_REQUEST['diony']='yes';

$smarty = new lingdangCRM_Smarty;
if (!isset($where)) $where = "";
//XUQIU1001421 关联选择单据（单选）、关联选择单据（多选）、选择源单、分录选择产品弹出层中，增加“全屏/恢复”图标按钮（郭惠宇）
if($_REQUEST['fullscreen']){
    setUsersettingByLabel('notbymodule', $current_user->id, 'Fullscreen', $_REQUEST['fullscreen']);
    return;
}

$operation = $_REQUEST['operation'];
if ($operation == 'getentryinfo') {
    $frommodule = $_REQUEST['frommodule'];
    $fromfocus = CRMEntity::getInstance($frommodule);
    $selectmodule = $_REQUEST['selectmodule'];
    $recordid = $_REQUEST['recordid'];
    $lineitem_id = $_REQUEST['lineitem_id'];
    $selectfocus = CRMEntity::getInstance($selectmodule);
    if ($frommodule == "Quotes" && $selectmodule == "Quotes") {
        $query = "SELECT ld_quotes.currency_id,ld_quotes.quote_no AS bill_no,ld_quotesdetail.*,ld_quotesdetailscf.*,
           ld_products.product_no,ld_products.productname,ld_products.productsheet,ld_customform03scf.cf_7471 AS customform03_id,ld_products.procostprice,ld_products.usageunit
        FROM ld_quotes
        LEFT JOIN ld_quotesdetail ON ld_quotesdetail.id = ld_quotes.quoteid
        LEFT JOIN ld_quotesdetailscf ON ld_quotesdetail.lineitem_id = ld_quotesdetailscf.lineitem_id
        LEFT JOIN ld_products ON ld_products.productid = ld_quotesdetail.productid
--        LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
        LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
        WHERE ld_quotes.quoteid =? AND ld_quotesdetail.lineitem_id = ? limit 1";
    }else if ($frommodule == "Quotes" && $selectmodule == "SalesOrder"){
        $query = "SELECT ld_salesorder.currency_id,ld_salesorder.salesorder_no AS bill_no,ld_salesorderdetail.*,ld_salesorderdetailscf.*,
           ld_products.product_no,ld_products.productname,ld_products.productsheet,ld_customform03scf.cf_7471 AS customform03_id,ld_products.procostprice,ld_products.usageunit
        FROM ld_salesorder
        LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
        LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
        LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
--        LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
        LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
        WHERE ld_salesorder.salesorderid =? AND ld_salesorderdetail.lineitem_id = ? limit 1";
    }else if ($frommodule == "CustomForm13" && $selectmodule == "CustomForm13"){
        $query = "SELECT ld_customform13.currency_id,ld_customform13.customform13_no AS bill_no,ld_customform13detail.*,ld_customform13detailscf.*,
           ld_products.product_no,ld_products.productname,ld_products.productsheet,ld_customform03scf.cf_7471 AS customform03_id,ld_products.procostprice,ld_products.usageunit
        FROM ld_customform13
        LEFT JOIN ld_customform13detail ON ld_customform13detail.id = ld_customform13.customform13id
        LEFT JOIN ld_customform13detailscf ON ld_customform13detail.lineitem_id = ld_customform13detailscf.lineitem_id
        LEFT JOIN ld_products ON ld_products.productid = ld_customform13detail.productid
--        LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
        LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
        WHERE ld_customform13.customform13id =? AND ld_customform13detail.lineitem_id = ? limit 1";
    }else if ($frommodule == "CustomForm13" && $selectmodule == "SalesOrder"){
        $query = "SELECT ld_salesorder.currency_id,ld_salesorder.salesorder_no AS bill_no,ld_salesorderdetail.*,ld_salesorderdetailscf.*,
           ld_products.product_no,ld_products.productname,ld_products.productsheet,ld_customform03scf.cf_7471 AS customform03_id,ld_products.procostprice,ld_products.usageunit
        FROM ld_salesorder
        LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
        LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
        LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
--        LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
        LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
        WHERE ld_salesorder.salesorderid =? AND ld_salesorderdetail.lineitem_id = ? limit 1";
    }
    else if ($frommodule == "CustomForm35" && $selectmodule == "CustomForm35"){
        $query = "SELECT ld_customform35.customform35_no AS bill_no,ld_customform35detail.*,ld_customform35detailscf.*
        FROM ld_customform35
        LEFT JOIN ld_customform35detail ON ld_customform35detail.id = ld_customform35.customform35id
        LEFT JOIN ld_customform35detailscf ON ld_customform35detail.lineitem_id = ld_customform35detailscf.lineitem_id
        WHERE ld_customform35.customform35id = ? AND ld_customform35detail.lineitem_id = ? limit 1";
    }
    else if ($frommodule == "CustomForm35" && $selectmodule == "SalesOrder"){
        $query = "SELECT ld_salesorder.salesorder_no AS bill_no,ld_products.product_no,ld_products.productsheet,ld_products.customform03_id,ld_customform03scf.cf_7471 AS caizhi,
				ld_salesorderdetail.quantity,ld_salesorderdetail.taxprice
        FROM ld_salesorder
        LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
        LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
        LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
--        LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
        LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
        WHERE ld_salesorder.salesorderid =? AND ld_salesorderdetail.lineitem_id = ? limit 1";
    }
    else if ($frommodule == "CustomForm23" && $selectmodule == "CustomForm23"){
        $query = "SELECT ld_customform23.customform23_no AS bill_no,ld_customform23detail.*,ld_customform23detailscf.*
        FROM ld_customform23
        LEFT JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
        LEFT JOIN ld_customform23detailscf ON ld_customform23detail.lineitem_id = ld_customform23detailscf.lineitem_id
        WHERE ld_customform23.customform23id = ? AND ld_customform23detail.lineitem_id = ? limit 1";
    }
    else if ($frommodule == "CustomForm23" && $selectmodule == "SalesOrder"){
        $query = "SELECT ld_salesorder.salesorder_no AS bill_no,ld_products.productname,ld_productcf.cf_7482 AS wuliao,ld_products.customform03_id,ld_customform03scf.cf_7471 AS caizhi,
				ld_salesorderdetail.quantity,ld_salesorderdetail.taxprice
        FROM ld_salesorder
        LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
        LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
        LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
        LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
        LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
        WHERE ld_salesorder.salesorderid =? AND ld_salesorderdetail.lineitem_id = ? limit 1";
    }
    $result = $adb->pquery($query, array($recordid,$lineitem_id));
    $num_rows = $adb->num_rows($result);
//dump(array($query,$recordid,$lineitem_id));
    $productFieldValue = [];
    if ($num_rows >= 1) {
        $sysdeploy = getSys_deploy(49);
        $lengthdecimaldigits = $sysdeploy['deploy_value'];
        $price_sysdeploy = getSys_deploy(93);//单价小数位控制
        if (isset($price_sysdeploy['deploy_value']))
            $price_lengthdecimaldigits = $price_sysdeploy['deploy_value'];
        else
            $price_lengthdecimaldigits = 2;
        $amount_sysdeploy = getSys_deploy(351);//单据分录金额字段
        $amount_lengthdecimaldigits=2;
        if (isset($amount_sysdeploy['deploy_value']))
            $amount_lengthdecimaldigits = $amount_sysdeploy['deploy_value'];


        if ($frommodule == "Quotes" || $frommodule == "CustomForm13" ) {
            $selectProductToolFields = new ProductToolFields($selectmodule);
            $languageType = getLanguageType($current_user);
            $selectFieldInfo = $selectProductToolFields->getModuleProductToolField(getTabid($selectmodule), $languageType);

            $ProId = $adb->query_result($result, 0, "productid");


            //价格策略
            crm_load_class_file("cls_strategy", 'modules/Products');
            $clsstrategyobj = new cls_strategy();

            $pricestrategy = $clsstrategyobj->getstrategyByProductId($ProId);
            $productFieldValue['pricestrategy'] = $pricestrategy;

            crm_load_function_file('setProductsInfo','include/utils','ListViewUtils');
            //产品税
            crm_load_function_file('getTaxDetailsForProduct', 'include/utils', 'InventoryUtils');
            $tax_details = getTaxDetailsForProduct($ProId);

            if (!empty($tax_details)) {
                foreach ($tax_details as $tax_info) {
                    if (empty($tax_info['percentage'])) $tax_info['percentage'] = 0;
                    $tax_arr[$tax_info['taxname']] = $tax_info['percentage'];
                }
            }


            $related_fieldobj = Field::getInstance('Products', $adb);
            $listpricePresence = 1;//判断当前模块明细的不含税单价字段是否启用
            $product_tax_info = getProductsTaxInfo($ProId);
            $inventory_tax_info = getInventorytaxinfo();


            $productFieldValue["currency_id"] = $adb->query_result($result, 0, "currency_id");
            $productFieldValue['adjustment'] =setNumberFormatEmptySeperator($adb->query_result($result, 0, 'adjustment'),$amount_lengthdecimaldigits);
            $productFieldValue_arr['discount_type'] = $adb->query_result($result, 0, 'discount_type');
            $productFieldValue['maintablefield_discount_amount']=setNumberFormatEmptySeperator($adb->query_result($result, 0, 'discount_amount'),$amount_lengthdecimaldigits);
            $productFieldValue['maintablefield_discount_percent'] = setNumberFormat($adb->query_result($result, 0, 'discount_percent'), $lengthdecimaldigits);
            $productFieldValue['product_no'] = $adb->query_result($result, 0, "product_no");
            $productFieldValue['productname'] = $adb->query_result($result, 0, "productname");

            $productFieldValue['quantity'] = setNumberFormat($adb->query_result($result, 0, "quantity"), $lengthdecimaldigits);
            $productFieldValue['format_num'] = $lengthdecimaldigits;
            $productFieldValue['hdnProductId'] = $productFieldValue['productid'] = $ProId;

            $instance = CRMEntity::getInstance('Products');
            $instance->retrieve_entity_info($productFieldValue['productid'],"Products");

            foreach ($selectFieldInfo as $productToolField) {
                if ($productToolField->getColumnName() == 'lasttaxprice') $faxfree_uitype = $productToolField->getUIType();
                if (in_array($productToolField->getUIType(), array(200, 201, 202, 204))) {
                    continue;
                }

                if (strtolower($productToolField->getTableName()) != 'ld_products'
                    && strtolower($productToolField->getTableName()) != 'ld_productcf'
                    && $productToolField->getUIType() != 51 && $productToolField->getUIType() != 52) {
                    //35282: 合同订单新增界面>产品信息区块：选择产品后不会将选择的产品所设定的税率带过来，显示的还是默认值。
                    if (strpos($productToolField->getColumnName(), 'tax') !== false) {
                        if (!empty($product_tax_info[$productToolField->getColumnName()])) {
                            $productFieldValue[$productToolField->getColumnName()] = $product_tax_info[$productToolField->getColumnName()];
                        } else {
                            $v_val = $productToolField->getDefaultvalue();
                            if ($v_val != '') {
                                $productFieldValue[$productToolField->getColumnName()] = $v_val;
                            } else {
                                $productFieldValue[$productToolField->getColumnName()] = $inventory_tax_info[$productToolField->getColumnName()];
                            }
                        }

                    } else {

                        if ($productToolField->getColumnName() == 'productcost') {
                            //产品参考成本价
                            $productFieldValue['productcost'] = sprintf('%.' . $price_lengthdecimaldigits . 'f', $instance->column_fields['procostprice']);
                            if ($_REQUEST['currency_id'] == 1) {


                            } else {
                                $tmpbol = 'no';
                                $procostpricedetails = getPriceDetailsForProduct($ProId, $lengthdecimaldigits, 'avaiable', "Products", 'procostprice');

                                foreach ($procostpricedetails as $detailindex => $detailcontent) {
                                    if ($detailcontent['curid'] == $_REQUEST['currency_id'] && $detailcontent['check_value'] == 1) {
                                        $productFieldValue[$productToolField->getColumnName()] = $detailcontent['curvalue'];
                                        $tmpbol = 'yes';
                                        break;
                                    }
                                }
                                if ($tmpbol == 'no') {
                                    $currencyobj = new Currency($adb, $_REQUEST['currency_id']);
                                    $changecurrencyobj = new Currency($adb, 1);

                                    $productFieldValue['productcost'] = $currencyobj->ConvertTothisobj_money($changecurrencyobj, $productFieldValue['productcost']);
                                    $productFieldValue['productcost'] = sprintf('%.' . $price_lengthdecimaldigits . 'f', $productFieldValue['productcost']);

                                }
                            }

                        } else if ($productToolField->getinput_type() == 1) {
                            //zkt 20221220 分录产品属性字段修改为可编辑类型(edit_permission:0,tablename)字段,修改columnname就不能带出值
                            $tmpfieldcolumnname = $instance->fieldobj->getFieldInfoBykeyValue('fieldid',$productToolField->getFieldid(),'columnname');
                            if(!empty($tmpfieldcolumnname)){
                                $typeofdata = explode('~', $productToolField->getTypeOfData());
                                $tmp_value = $instance->column_fields[$tmpfieldcolumnname];
                                if ($typeofdata[0] == 'N' || $typeofdata[0] == 'NN'){
                                    $tmpdigitlen_arr=explode(",",$typeofdata[2]);
                                    $tmplen = $tmpdigitlen_arr[1];
                                    if(empty($tmplen))$tmplen = 0;
                                    $productFieldValue[$productToolField->getColumnName()] = sprintf('%.' . $tmplen . 'f', $tmp_value);
                                }else{
                                    $productFieldValue[$productToolField->getColumnName()] = $tmp_value;
                                }
                            }
                            else{
                                $productFieldValue[$productToolField->getColumnName()] = $instance->column_fields[$productToolField->getColumnName()];
                            }
                        } else if($productToolField->getUIType() == 99){
                            /*
                            *edit: chj
                            *date: 2020/8/27
                            *reason: 换算率字段，默认根据单据的币种带出对应的换算率
                            */
                            if(empty($currencyid))$currencyid = 1;
                            $currencyobj=Currency::getInstance($adb,$currencyid);
                            $conversion_rate = $currencyobj->getCurrencyRate();
                            $productFieldValue[$productToolField->getColumnName()] = $conversion_rate;
                        }else if($productToolField->getBigType() == 'reference'){
                            //duan 20320727 修复分录设置了关联选择单据字段的默认值后，选产品带出数字的问题
                            $v_val = $productToolField->getDefaultvalue();
                            if(!empty($v_val)){
                                $productFieldValue[$productToolField->getColumnName()] = $v_val;
                                $entity_value = getEntityName($productToolField->getReferenceModule(),$v_val);
                                $productFieldValue[$productToolField->getColumnName().'_name'] = $entity_value[$v_val];
                            }
                        }
                        else {
                            $v_val = $productToolField->getDefaultvalue();

                            if (!empty($v_val)) {

                                $productFieldValue[$productToolField->getColumnName()] = $productToolField->getDefaultvalue();

                                if($productToolField->getColumnName()=='wareid')
                                {
                                    require_once(globalStatic::$root_directory.'include/Stock/CommonStock.php');

                                    $ware_arr= getWareAllInfo($current_user);

                                    $ware_permit = 'no';
                                    //$haveware_name_arr
                                    foreach($ware_arr as $wareinfo)
                                    {

                                        //edit:can 2020-12-16 43700: （https://61mis.com/kfbcrm [^]）出库单选择产品（产品A），选择批次弹出层中【仓库】下拉选项没有带出产品分录中【仓库】字段默认显示的值
                                        if($wareinfo['name']==$productToolField->getDefaultvalue())
                                        {
                                            $productFieldValue[$productToolField->getColumnName()."_rawvalue"]=$wareinfo['id'];
                                            // $productFieldValue[$productToolField->getColumnName()]=$wareinfo['id'];
                                            $ware_permit = 'yes';
                                            break;
                                        }


                                    }
                                    //duan 如果用户没有仓库的权限，默认值不应该带出仓库
                                    if($ware_permit == 'no'){
                                        $productFieldValue[$productToolField->getColumnName()]='';
                                        $productFieldValue[$productToolField->getColumnName()."_rawvalue"]='';
                                    }
                                }
                            }
                            //zkt 20230621 BUG0067612  kfbcrm-出库单-新建-产品分录-新增产品，第一行仓库字段变为空
                            else{
                                if($productToolField->getColumnName()=='wareid')
                                {
                                    require_once(globalStatic::$root_directory.'include/Stock/CommonStock.php');
                                    $ware_arr= getWareAllInfo($current_user);
                                    foreach($ware_arr as $wareinfo)
                                    {
                                        $productFieldValue[$productToolField->getColumnName()."_rawvalue"]=$wareinfo['id'];
                                        $productFieldValue[$productToolField->getColumnName()]=$wareinfo['name'];
                                        break;


                                    }
                                }
                            }
                        }
                    }

                    //continue;
                }

                if (strtolower($productToolField->getTableName()) == 'ld_products' ||
                    strtolower($productToolField->getTableName()) == 'ld_productcf') {
                    $field = $related_fieldobj->getFieldInfoobjBykey('columnname', $productToolField->getColumnName());
                    if (!empty($field)) {
                        //$productToolField['uitype'] = $field->getUIType();
                        $fieldname = $field->getFieldName();
                        $typeofdata=$field->getTypeOfData();

                    } else {
                        $fieldname = $productToolField->getColumnName();
                        $typeofdata=$productToolField->getTypeOfData();
                    }


                    if ($productToolField->getUIType() == 20) {
                        $stypeofdata = $productToolField->getTypeOfData();
                        $stypes = explode(',', $stypeofdata);
                        $productFieldValue[$productToolField->getColumnName()] = sprintf('%.' . $stypes[1] . 'f', $instance->column_fields[$fieldname]);;
                    } else {

                        $typeofdata = explode('~', $productToolField->getTypeOfData());
                        if ($typeofdata[0] == 'N' || $typeofdata[0] == 'NN') {

                            if ($productToolField->getUIType() == 163) {    //单价
                                $len_digits = $price_lengthdecimaldigits;
                            }
                            //ls 2021-12-29 0049436: 客户问题（新疆润和）：报价单-产品分录-采购价（字段属性-参考成本价）-带不完全产品的参考成本价，不显示小数位
                            else if ($productToolField->getUIType() == 72&&($productToolField->getColumnName()=='unit_price'||$productToolField->getColumnName()=='costprice'))
                            {
                                $len_digits=$price_lengthdecimaldigits;
                            }
                            else if ($productToolField->getUIType() == 7&&($productToolField->getColumnName()=='qtyearly'||$productToolField->getColumnName()=='qtyinstock'))
                            {
                                $len_digits=$lengthdecimaldigits;
                            }

                            else {
                                $tmpdigitlen=explode(",",$typeofdata[2]);

                                $len_digits =$tmpdigitlen[1] ;
                                if($len_digits=='')
                                {
                                    $len_digits=0;
                                    if($productToolField->isAmountorCurrencyField()){
                                        $len_digits=2;
                                    }
                                }
                            }
                            if (empty($instance->column_fields[$fieldname])) {
                                $productfield_value = $productToolField->getDefaultvalue();
                            } else {
                                $productfield_value = $instance->column_fields[$fieldname];
                            }

                            //匠精需求  库存总量对代理商不显示真实数量，而是显示多，少
                            if ($module == 'Quotes' || $module == 'SalesOrder') {
                                if ($fieldname == 'qtyinstock' && $productToolField->getTableName() == 'ld_products' && $productToolField->getinput_type() == 1) {
                                    if ($current_user->is_admin == 'off' && isset($current_user->column_fields['view_quantity']) && $current_user->column_fields['view_quantity'] == 0) {
                                        if ($productfield_value >= 21) {
                                            $productfield_value = getFixedLabel('many');    //多
                                        } else if ($productfield_value <= 20 && $productfield_value > 0) {
                                            $productfield_value = getFixedLabel('less');    //少
                                        } else {
                                            $productfield_value = getFixedLabel('NONE');    //无
                                        }
                                    }
                                }
                            }
                            if (is_numeric($productfield_value)) {
                                if (empty($instance->column_fields[$fieldname])) {
                                    $productFieldValue[$productToolField->getColumnName()] = setNumberFormat($productfield_value, $len_digits);
                                } else {
                                    $productFieldValue[$productToolField->getColumnName()] = sprintf('%.' . $len_digits . 'f', $productfield_value);
                                }
                            } else {
                                $productFieldValue[$productToolField->getColumnName()] = $productfield_value;
                            }
                        } else {
                            if ($productToolField->getFieldDataType() == 'string') {
                                if(!empty($_REQUEST['popup_selectsource']) && $_REQUEST['popup_selectsource'] == 'true')
                                {
                                    //edit:can 20200811 reason 41982: （https://61mis.com/kfbtest/ [^]）出库单新建界面，选择合同订单（已全部出库）“SO177”后，产品名称显示乱码
                                    $val =$instance->column_fields[$fieldname];
                                }
                                else
                                    $val = str_replace('+', '%20', urlencode(vtlib_purify($instance->column_fields[$fieldname])));
                            } else {
                                $val = $instance->column_fields[$fieldname];
                            }
                            if (empty($instance->column_fields[$fieldname])) {
                                $productFieldValue[$productToolField->getColumnName()] = '';
                            } else {
                                $productFieldValue[$productToolField->getColumnName()] = $val;
                            }
                        }
                    }
                    if ($productToolField->getUIType() == 52) {
                        $productFieldValue[$productToolField->getColumnName()] = getOwnerName($instance->column_fields[$fieldname]);
                    }
                    if ($productToolField->getUIType() == 56) {
                        if ($instance->column_fields[$productToolField->getColumnName()] == 1) {
                            $column_value = getFixedLabel('YES');
                        } else {
                            $column_value = getFixedLabel('NO');
                        }

                        if(empty($column_value))
                        {
                            $column_value='';
                        }
                        $productFieldValue[$productToolField->getColumnName()] = $column_value;
                    }
                    if ($productToolField->getUIType() == 53 || $productToolField->getUIType() == 131) {
                        //bug：23290 选择产品“负责人”字段取值没有带出来；edit:cyb 2016-06-29
                        $field = $instance->fieldobj->getFieldInfoobjBykey('columnname', $productToolField->getColumnName());
                        if (!empty($field)) {
                            $fieldname = $field->getFieldName();
                        }
                        $productFieldValue[$productToolField->getColumnName()] = getOwnerName($instance->column_fields[$fieldname]);
                    }
                    if (isset($fldmodulerel[$productToolField->getUIType()]) && constant('REFERENCE_FIELD') == $fldmodulerel[$productToolField->getUIType()]['fieldtype']) {
                        $fld_module = getSalesEntityType($instance->column_fields[$fieldname]);
                        $productFieldValue[$productToolField->getColumnName()] = getModuleHref($fld_module, $instance->column_fields[$fieldname]);
                    }
                    $productFieldValue['product_no'] = $instance->column_fields['product_no'];

                }
                else {
                    /*//报价变更单-变更选择产品时，除产品名称其他一定不带出
                    if (!empty($_REQUEST['change_type']) && $_REQUEST['change_type'] == 'replace' && $module == 'QuotesChange' && strtolower($productToolField->getColumnName()) != 'productname') {
                        continue;
                    }
                    //预算变更单-变更选择产品时，pro_id、prosheet不带出
                    if (!empty($_REQUEST['change_type']) && $_REQUEST['change_type'] == 'replace' && $module == 'BudgetChange' && (strtolower($productToolField->getColumnName()) == 'pro_id'||strtolower($productToolField->getColumnName()=='prosheet'))) {
                        continue;
                    }
                    $fieldname = '';

                    if ($productToolField->getUIType() == 17 || $productToolField->getUIType() == 21) {
                        //zkt 20231017 BUG0073761 销售订单分录字段，“税（销售）”字段，设置小数位数为0，新增销售订单，选择产品后，“税（销售）”字段默认值变成两位小数 （81kfbcrm通用bug）
                        $tmpstypes = explode(',', $productToolField->getTypeOfData());
                        if (empty($tax_arr[$productToolField->getColumnName()])) {
                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormatEmptySeperator($productToolField->getDefaultvalue(),$tmpstypes[1]);
                        } else {
                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormatEmptySeperator($tax_arr[$productToolField->getColumnName()],$tmpstypes[1]);
                        }
                    } else if ($productToolField->getUIType() == 10) {//数量 位数小数位控制

                        if (empty($instance->column_fields[$productToolField->getColumnName()])) {

                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormat($productToolField->getDefaultvalue(), $lengthdecimaldigits);
                        } else {
                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormat($instance->column_fields[$productToolField->getColumnName()], $lengthdecimaldigits);
                        }

                    } else if ($productToolField->getUIType() == 163) {//单价 位数小数位控制
                        $columnname = $productToolField->getColumnName();
                        if($columnname == 'productcost'){
                            $columnname = 'procostprice';
                        }
                        if (empty($instance->column_fields[$columnname])) {


                            $productFieldValue[$columnname] = setNumberFormat($productToolField->getDefaultvalue(), $price_lengthdecimaldigits);
                        } else {

                            $productFieldValue[$columnname] = sprintf('%.' . $price_lengthdecimaldigits . 'f', $instance->column_fields[$columnname]);
                        }
                    } else if ($productToolField->getUIType() == 20 || $productToolField->getUIType() == 15) {//小数位控制
                        $stypeofdata = $productToolField->getTypeOfData();
                        $stypes = explode(',', $stypeofdata);
                        if (empty($instance->column_fields[$productToolField->getColumnName()])) {
                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormat($productToolField->getDefaultvalue(), $stypes[1]);
                        } else {
                            $productFieldValue[$productToolField->getColumnName()] = sprintf('%.' . $stypes[1] . 'f', $instance->column_fields[$productToolField->getColumnName()]);
                        }
                    } else {
                        if (empty($productFieldValue[$productToolField->getColumnName()]) && $productToolField->getColumnName() != 'wareid') {
                            $typeofdata = explode('~', $productToolField->getTypeOfData());
                            if (($typeofdata[0] == 'N' || $typeofdata[0] == 'NN') && $productToolField->getDefaultvalue() == '') {
                                $productFieldValue[$productToolField->getColumnName()] = 0;
                            } else {
                                $productFieldValue[$productToolField->getColumnName()] = $productToolField->getDefaultvalue();

                            }
                            // echo $productToolField->getColumnName().$productToolField->getDefaultvalue()."<br>";
                            if($productToolField->getUIType()==56)
                            {
                                //edti:can 2020-02-22044678: （https://61mis.com/kfbcrm [^]）（江苏丰山集团股份有限公司）在单据分录中有一个复选框字段，pc端选择产品之后没有显示勾选，但是移动端选择产品之后这个复选框自动购选了
                                if($productFieldValue[$productToolField->getColumnName()]==0&&$type=='app')
                                {
                                    $productFieldValue[$productToolField->getColumnName()]='';
                                }
                            }
                        }
                        //chj 2020/12/1 43523: （61mis.com/kfbcrm）销售管理-合同订单-新建（需要补丁）；合同订单产品分录中，设置了日期的默认值，但在选择产品后，日期的默认值消失了
                        if ($productToolField->getUIType() == 51 || $productToolField->getUIType() == 54 || $productToolField->getUIType() == 53 || $productToolField->getUIType() == 52) {
                            $uitype = $productToolField->getUIType();
                            $productFieldValue[$productToolField->getColumnName()] = $Parent_ProductDetailsData->getDateValue($uitype,$productFieldValue[$productToolField->getColumnName()]);
                        }
                        if ($productToolField->isAmountorCurrencyField()) {
                            $stypeofdata = $productToolField->getTypeOfData();
                            $stypes = explode(',', $stypeofdata);
                            $tmptypeofdata_decimal = ($stypes[1] == '')?2:$stypes[1];
                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormatEmptySeperator($productFieldValue[$productToolField->getColumnName()],$tmptypeofdata_decimal);
                        }

                    }
                    //若不启用“不含税单价”字段，则选择产品后“含税单价”字段取产品的“参考价”
                    if ($productToolField->getColumnName() == 'listprice') {
                        $listpricePresence = 0;
                    }*/

                    //新加代码，处理查询出来的单价等小数位数
                    $columnname = $productToolField->getColumnName();
                    $tmp_value = $adb->query_result($result, 0, $columnname);
                    if ($productToolField->getUIType() == 10) {
                    $productFieldValue[$columnname] = setNumberFormat($tmp_value, $lengthdecimaldigits);
                    }
                    else if ($productToolField->getUIType() == 163) {//单价 位数小数位控制
                        $columnname = $productToolField->getColumnName();
                        if($columnname == 'productcost'){
                            $columnname = 'procostprice';
                        }
                        if (empty($tmp_value)) {
                            $productFieldValue[$columnname] = setNumberFormat($tmp_value, $price_lengthdecimaldigits);
                        } else {
                            $productFieldValue[$columnname] = sprintf('%.' . $price_lengthdecimaldigits . 'f', $tmp_value);
                        }
                    }
                    else if ($productToolField->getUIType() == 20 || $productToolField->getUIType() == 15) {//小数位控制
                        $stypeofdata = $productToolField->getTypeOfData();
                        $stypes = explode(',', $stypeofdata);
                        if (empty($tmp_value)) {
                            $productFieldValue[$productToolField->getColumnName()] = setNumberFormat($productToolField->getDefaultvalue(), $stypes[1]);
                        } else {
                            $productFieldValue[$productToolField->getColumnName()] = sprintf('%.' . $stypes[1] . 'f', $tmp_value);
                        }
                    }
                    else{
                        $productFieldValue[$columnname] = $tmp_value;
                    }

                }
            }



            $productFieldValue["sf9303"] = $adb->query_result($result, 0, "bill_no");//选择的单据分录字段sf_9303没有用，需要重新赋值
            $productFieldValue["customform03_id"] = $adb->query_result($result, 0, "customform03_id");//同理 取id对应的超链接字段值而不是id值
            $productFieldValue['rowid'] =  $_REQUEST['rowid'];
        }
        else if($frommodule == "CustomForm35"){
            if ($selectmodule == "SalesOrder") {
                $productFieldValue["sf706"] = $adb->query_result($result, 0, "product_no");//物料号
                $productFieldValue["sf707"] = decode_html($adb->query_result($result, 0, "productsheet"));//图号/版本号
//                $productFieldValue["sf708"] = $adb->query_result($result, 0, "customform03_id");//砂型材质
                $productFieldValue["sf708"] = $adb->query_result($result, 0, "caizhi");//砂型材质 取超链接字段
                $productFieldValue["sf710"] = setNumberFormat($adb->query_result($result, 0, "quantity"),2);//数量
                $productFieldValue["sf712"] = setNumberFormat($adb->query_result($result, 0, "taxprice"), $price_lengthdecimaldigits);//单价

            }
            else {
                /*$fieldlistarray=$fromfocus->detailfieldobj->getFieldListArray();
                foreach($fieldlistarray as $fieldinfo)
                {
                    $columnname =  $fieldinfo['columnname'];
                    if (in_array($columnname,array("amount","total")))
                        continue;

                    $productFieldValue[$columnname] = $adb->query_result($result, 0, $columnname);
                }*/

                foreach($fromfocus->detailfieldobj->getModuleFields() as $tmpfieldname=>$tmpfieldinfo)
                {
                    $columnname =  $tmpfieldinfo->getColumnName();
                    if (in_array($columnname,array("amount","total","source_total","entitytypeid","received_amount","cashbilldate")))
                        continue;//无需赋值

                    if ($tmpfieldinfo->getFieldType() == 'Price') {
                        $productFieldValue[$columnname] = setNumberFormat($adb->query_result($result, 0, $columnname), $price_lengthdecimaldigits);
                    }else if($tmpfieldinfo->getFieldType() == 'Number'){
                        $productFieldValue[$columnname] = setNumberFormat($adb->query_result($result, 0, $columnname), 2);
                    }else{
                        $productFieldValue[$columnname] = $adb->query_result($result, 0, $columnname);
                    }

                }
            }

            $productFieldValue["sf721"] = $adb->query_result($result, 0, "bill_no");//单据编号
            $productFieldValue['rowid'] =  $_REQUEST['rowid'];

        }
        else if($frommodule == "CustomForm23"){
            if ($selectmodule == "SalesOrder") {
                $productFieldValue["sf714"] = $adb->query_result($result, 0, "productname");//产品名称
                $productFieldValue["sf715"] = decode_html($adb->query_result($result, 0, "wuliao"));
                $productFieldValue["sf716"] = $adb->query_result($result, 0, "caizhi");//砂型材质 取超链接字段
                $productFieldValue["sf717"] = setNumberFormat($adb->query_result($result, 0, "quantity"),2);//数量
                $productFieldValue["sf719"] = setNumberFormat($adb->query_result($result, 0, "taxprice"), $price_lengthdecimaldigits);//单价

            }
            else {
                foreach($fromfocus->detailfieldobj->getModuleFields() as $tmpfieldname=>$tmpfieldinfo)
                {
                    $columnname =  $tmpfieldinfo->getColumnName();
                    if (in_array($columnname,array("amount","total","source_total","entitytypeid","received_amount","cashbilldate")))
                        continue;//无需赋值

                    if ($tmpfieldinfo->getFieldType() == 'Price') {
                        $productFieldValue[$columnname] = setNumberFormat($adb->query_result($result, 0, $columnname), $price_lengthdecimaldigits);
                    }else if($tmpfieldinfo->getFieldType() == 'Number'){
                        $productFieldValue[$columnname] = setNumberFormat($adb->query_result($result, 0, $columnname), 2);
                    }else{
                        $productFieldValue[$columnname] = $adb->query_result($result, 0, $columnname);
                    }

                }
            }

            $productFieldValue["sf722"] = $adb->query_result($result, 0, "bill_no");//单据编号
            $productFieldValue['rowid'] =  $_REQUEST['rowid'];

        }
    }


    ConvertTojsonString(1,$productFieldValue,"success");
}


$curr_row = vtlib_purify($_REQUEST['curr_row']);//分录当前行


$popuptype = '';
$fromModule = '';

$smarty->assign("RETURN_ACTION",vtlib_purify($_REQUEST['return_action']));
$smarty->assign('MODULE',$currentModule);

if (isset($_REQUEST['popup']) && $_REQUEST['popup'] == 'yes') {
    switch($currentModule)
    {
        case 'Quotes': //离心铸造报价申请：通过“规格型号“、”材质“字段判断
            $query = "
SELECT DISTINCT
	ld_quotes.quoteid AS crmid,
	ld_quotes.quote_no AS bill_no,
	'Quotes' AS modulename,
	ld_quotescf.cf_7540 AS signed_data,
	ld_quotesdetail.productid,
	ld_products.productname,
	ld_products.productsheet,
	ld_products.customform03_id,
	ld_customform03scf.cf_7471 AS caizhi,
	ld_productcf.cf_7488 AS jiaohuo_status,
	ld_quotesdetail.taxprice,
	ld_quotesdetail.quantity,
	ld_quotes.accountid,
	ld_quotes.smownerid,
	ld_quotes.total,
	ifnull(
		ld_quotesdetail.lineitem_id,
		0
	) AS lineitem_id,
	ld_quotes.currency_id,
	ld_quotes.conversion_rate,
	ld_quotes.currency_symbol
FROM
	ld_quotes
LEFT JOIN ld_quotescf ON ld_quotescf.quoteid = ld_quotes.quoteid
LEFT JOIN ld_quotesdetail ON ld_quotesdetail.id = ld_quotes.quoteid
LEFT JOIN ld_quotesdetailscf ON ld_quotesdetail.lineitem_id = ld_quotesdetailscf.lineitem_id
LEFT JOIN ld_products ON ld_products.productid = ld_quotesdetail.productid
LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
INNER JOIN (
	SELECT DISTINCT
		ld_quotes.quoteid
	FROM
		ld_quotes
	WHERE
		ld_quotes.deleted = 0
	AND ld_quotes.quoteid > 0
	ORDER BY
		ld_quotes.quoteid DESC
) AS temp ON temp.quoteid = ld_quotes.quoteid
WHERE
	ld_quotes.deleted = 0
AND ld_quotes.quoteid > 0
AND ld_quotes.accountid = ?
AND ifnull(
	ld_products.productsheet,
	''
) = ?
AND ifnull(
	ld_customform03scf.cf_7471,
	''
) = ?
GROUP BY
	lineitem_id
UNION
	SELECT DISTINCT
		ld_salesorder.salesorderid AS crmid,
		ld_salesorder.salesorder_no AS bill_no,
		'SalesOrder' AS modulename,
		ld_salesorder.signed_data,
		ld_salesorderdetail.productid,
		ld_products.productname,
		ld_products.productsheet,
		ld_products.customform03_id,
		ld_customform03scf.cf_7471 AS caizhi,
		ld_productcf.cf_7488 AS jiaohuo_status,
		ld_salesorderdetail.taxprice,
		ld_salesorderdetail.quantity,
		ld_salesorder.accountid,
		ld_salesorder.smownerid,
		ld_salesorder.total,
		ifnull(
			ld_salesorderdetail.lineitem_id,
			0
		) AS lineitem_id,
		ld_salesorder.currency_id,
		ld_salesorder.conversion_rate,
		ld_salesorder.currency_symbol
	FROM
		ld_salesorder
	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
	LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
	LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
	LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
	LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
	INNER JOIN (
		SELECT DISTINCT
			ld_salesorder.salesorderid
		FROM
			ld_salesorder
		WHERE
			ld_salesorder.deleted = 0
		AND ld_salesorder.salesorderid > 0
		ORDER BY
			ld_salesorder.salesorderid DESC
	) AS temp ON temp.salesorderid = ld_salesorder.salesorderid
	WHERE
		ld_salesorder.deleted = 0
	AND ld_salesorder.salesorderid > 0
	AND ld_salesorder.accountid = ?
	AND ifnull(
		ld_products.productsheet,
		''
	) = ?
	AND ifnull(
		ld_customform03scf.cf_7471,
		''
	) = ?
	GROUP BY
		lineitem_id
	ORDER BY
		crmid DESC,
		lineitem_id
    ";
            $bind_params_arr = array($_REQUEST['account_id'],trim($_REQUEST['productsheet']),trim($_REQUEST['caizhi']),$_REQUEST['account_id'],trim($_REQUEST['productsheet']),trim($_REQUEST['caizhi']));
            $listview_header = array("单据编号","日期","产品名称","规格型号","材质","交货状态","单价");
            break;
        case 'CustomForm13': //砂型铸造报价申请：通过“产品名称”、“用户物料识别信息”、“材质”字段判断
            $query = "
            SELECT DISTINCT
	ld_customform13.customform13id AS crmid,
	ld_customform13.customform13_no AS bill_no,
	'CustomForm13' AS modulename,
	ld_customform13scf.cf_7556 AS signed_data,
	ld_products.customform03_id,
	ld_customform03scf.cf_7471 AS caizhi,
	ld_productcf.cf_7488 AS jiaohuo_status,
	ld_customform13detail.taxprice,
	ld_customform13detail.productid,
	ld_products.productname,
	ld_customform13detail.quantity,
	ld_customform13.accountid,
	ld_customform13.smownerid,
	ld_customform13.total,
	ifnull(
		ld_customform13detail.lineitem_id,
		0
	) AS lineitem_id,
	ld_customform13.currency_id,
	ld_customform13.conversion_rate,
	ld_customform13.currency_symbol
FROM
	ld_customform13
LEFT JOIN ld_customform13scf ON ld_customform13scf.customform13id = ld_customform13.customform13id
LEFT JOIN ld_customform13detail ON ld_customform13detail.id = ld_customform13.customform13id
LEFT JOIN ld_customform13detailscf ON ld_customform13detailscf.lineitem_id = ld_customform13detailscf.lineitem_id
LEFT JOIN ld_products ON ld_products.productid = ld_customform13detail.productid
LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
INNER JOIN (
	SELECT DISTINCT
		ld_customform13.customform13id
	FROM
		ld_customform13
	WHERE
		ld_customform13.deleted = 0
	AND ld_customform13.customform13id > 0
	ORDER BY
		ld_customform13.customform13id DESC
) AS temp ON temp.customform13id = ld_customform13.customform13id
WHERE
	ld_customform13.deleted = 0
AND ld_customform13.customform13id > 0
AND ld_customform13.accountid = ?
AND ld_products.productname = ?
AND ifnull(ld_productcf.cf_7482, '') = ?
AND ifnull(
	ld_customform03scf.cf_7471,
	''
) = ?
GROUP BY
	lineitem_id
UNION
	SELECT DISTINCT
		ld_salesorder.salesorderid AS crmid,
		ld_salesorder.salesorder_no AS bill_no,
		'SalesOrder' AS modulename,
		ld_salesorder.signed_data,
		ld_products.customform03_id,
		ld_customform03scf.cf_7471 AS caizhi,
		ld_productcf.cf_7488 AS jiaohuo_status,
		ld_salesorderdetail.taxprice,
		ld_salesorderdetail.productid,
		ld_products.productname,
		ld_salesorderdetail.quantity,
		ld_salesorder.accountid,
		ld_salesorder.smownerid,
		ld_salesorder.total,
		ifnull(
			ld_salesorderdetail.lineitem_id,
			0
		) AS lineitem_id,
		ld_salesorder.currency_id,
		ld_salesorder.conversion_rate,
		ld_salesorder.currency_symbol
	FROM
		ld_salesorder
	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
	LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
	LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
	LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
	LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
	INNER JOIN (
		SELECT DISTINCT
			ld_salesorder.salesorderid
		FROM
			ld_salesorder
		WHERE
			ld_salesorder.deleted = 0
		AND ld_salesorder.salesorderid > 0
		ORDER BY
			ld_salesorder.salesorderid DESC
	) AS temp ON temp.salesorderid = ld_salesorder.salesorderid
	WHERE
		ld_salesorder.deleted = 0
	AND ld_salesorder.salesorderid > 0
	AND ld_salesorder.accountid = ?
	AND ld_products.productname = ?
	AND ifnull(ld_productcf.cf_7482, '') = ?
	AND ifnull(
		ld_customform03scf.cf_7471,
		''
	) = ?
	GROUP BY
		lineitem_id
	ORDER BY
		crmid DESC,
		lineitem_id
		";
            $bind_params_arr = array($_REQUEST['account_id'],trim($_REQUEST['productname']),trim($_REQUEST['jiaohuo']),trim($_REQUEST['caizhi']),$_REQUEST['account_id'],trim($_REQUEST['productname']),trim($_REQUEST['jiaohuo']),trim($_REQUEST['caizhi']));
            $listview_header = array("单据编号","日期","产品名称","材质","交货状态","单价");
            break;
        case 'CustomForm35': // 3D砂型报价申请：通过“物料号”字段判断
            $query = "
            SELECT DISTINCT
	ld_customform35.customform35id AS crmid,
	ld_customform35.customform35_no AS bill_no,
	'CustomForm35' AS modulename,
	ld_customform35scf.cf_7438 AS signed_data,
	ld_customform35detailscf.sf712 AS taxprice,
	'' AS productid,
	ld_customform35detailscf.sf706 AS product_no,
	ld_customform35detailscf.sf707 AS productsheet,
	ld_customform35detailscf.sf708 AS caizhi,
	ld_customform35.accountid,
	ld_customform35.smownerid,
	ld_customform35.total,
	ifnull(
		ld_customform35detail.lineitem_id,
		0
	) AS lineitem_id
FROM
	ld_customform35
LEFT JOIN ld_customform35scf ON ld_customform35scf.customform35id = ld_customform35.customform35id
LEFT JOIN ld_customform35detail ON ld_customform35detail.id = ld_customform35.customform35id
LEFT JOIN ld_customform35detailscf ON ld_customform35detailscf.lineitem_id = ld_customform35detail.lineitem_id
INNER JOIN (
	SELECT DISTINCT
		ld_customform35.customform35id
	FROM
		ld_customform35
	WHERE
		ld_customform35.deleted = 0
	AND ld_customform35.customform35id > 0
	ORDER BY
		ld_customform35.customform35id DESC
) AS temp ON temp.customform35id = ld_customform35.customform35id
WHERE
	ld_customform35.deleted = 0
AND ld_customform35.customform35id > 0
AND ld_customform35.accountid = ? 
AND ifnull(
	ld_customform35detailscf.sf706,
	''
) = ? 
GROUP BY
	lineitem_id
UNION
	SELECT DISTINCT
		ld_salesorder.salesorderid AS crmid,
		ld_salesorder.salesorder_no AS bill_no,
		'SalesOrder' AS modulename,
		ld_salesorder.signed_data,
		ld_salesorderdetail.taxprice,
		ld_salesorderdetail.productid,
		ld_products.product_no,
		ld_products.productsheet,
-- 		ld_products.customform03_id AS caizhi,
		ld_customform03scf.cf_7471 AS caizhi,
		ld_salesorder.accountid,
		ld_salesorder.smownerid,
		ld_salesorder.total,
		ifnull(
			ld_salesorderdetail.lineitem_id,
			0
		) AS lineitem_id
	FROM
		ld_salesorder
	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
	LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
	LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
	LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
    LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
	INNER JOIN (
		SELECT DISTINCT
			ld_salesorder.salesorderid
		FROM
			ld_salesorder
		WHERE
			ld_salesorder.deleted = 0
		AND ld_salesorder.salesorderid > 0
		ORDER BY
			ld_salesorder.salesorderid DESC
	) AS temp ON temp.salesorderid = ld_salesorder.salesorderid
	WHERE
		ld_salesorder.deleted = 0
	AND ld_salesorder.salesorderid > 0
	AND ld_salesorder.accountid = ? 
	AND ifnull(
		ld_products.product_no,
		''
	) = ? 
	GROUP BY
		lineitem_id
	ORDER BY
		crmid DESC,
		lineitem_id
		";
            $bind_params_arr = array($_REQUEST['account_id'],trim($_REQUEST['product_no']),$_REQUEST['account_id'],trim($_REQUEST['product_no']));
            $listview_header = array("单据编号","日期","物料号","图号/版本号","砂型材质","单价");
            break;
        case 'CustomForm23': // 3D砂型报价申请：通过“物料号”字段判断
            $query = "
            SELECT DISTINCT
	ld_customform23.customform23id AS crmid,
	ld_customform23.customform23_no AS bill_no,
	'CustomForm23' AS modulename,
	ld_customform23scf.cf_7443 AS signed_data,
	ld_customform23detailscf.sf719 AS taxprice,
	'' AS productid,
	ld_customform23detailscf.sf714 AS productname,
	ld_customform23detailscf.sf715 AS wuliao,
	ld_customform23detailscf.sf716 AS caizhi,
	ld_customform23.accountid,
	ld_customform23.smownerid,
	ld_customform23.total,
	ifnull(
		ld_customform23detail.lineitem_id,
		0
	) AS lineitem_id
FROM
	ld_customform23
LEFT JOIN ld_customform23scf ON ld_customform23scf.customform23id = ld_customform23.customform23id
LEFT JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
LEFT JOIN ld_customform23detailscf ON ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
INNER JOIN (
	SELECT DISTINCT
		ld_customform23.customform23id
	FROM
		ld_customform23
	WHERE
		ld_customform23.deleted = 0
	AND ld_customform23.customform23id > 0
	ORDER BY
		ld_customform23.customform23id DESC
) AS temp ON temp.customform23id = ld_customform23.customform23id
WHERE
	ld_customform23.deleted = 0
AND ld_customform23.customform23id > 0
AND ld_customform23.accountid = ?
AND ifnull(
	ld_customform23detailscf.sf714,
	''
) = ?
AND ifnull(
	ld_customform23detailscf.sf715,
	''
) = ?
AND ifnull(
	ld_customform23detailscf.sf716,
	''
) = ?
GROUP BY
	lineitem_id
UNION
	SELECT DISTINCT
		ld_salesorder.salesorderid AS crmid,
		ld_salesorder.salesorder_no AS bill_no,
		'SalesOrder' AS modulename,
		ld_salesorder.signed_data,
		ld_salesorderdetail.taxprice,
		ld_salesorderdetail.productid,
		ld_products.productname,
		ld_productcf.cf_7482 AS wuliao,
		ld_customform03scf.cf_7471 AS caizhi,
		ld_salesorder.accountid,
		ld_salesorder.smownerid,
		ld_salesorder.total,
		ifnull(
			ld_salesorderdetail.lineitem_id,
			0
		) AS lineitem_id
	FROM
		ld_salesorder
	LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id = ld_salesorder.salesorderid
	LEFT JOIN ld_salesorderdetailscf ON ld_salesorderdetail.lineitem_id = ld_salesorderdetailscf.lineitem_id
	LEFT JOIN ld_products ON ld_products.productid = ld_salesorderdetail.productid
	LEFT JOIN ld_productcf ON ld_products.productid = ld_productcf.productid
	LEFT JOIN ld_customform03scf ON ld_customform03scf.customform03id = ld_products.customform03_id
	INNER JOIN (
		SELECT DISTINCT
			ld_salesorder.salesorderid
		FROM
			ld_salesorder
		WHERE
			ld_salesorder.deleted = 0
		AND ld_salesorder.salesorderid > 0
		ORDER BY
			ld_salesorder.salesorderid DESC
	) AS temp ON temp.salesorderid = ld_salesorder.salesorderid
	WHERE
		ld_salesorder.deleted = 0
	AND ld_salesorder.salesorderid > 0
	AND ld_salesorder.accountid = ?
	AND ld_products.productname = ?
	AND ifnull(ld_productcf.cf_7482, '') = ?
	AND ifnull(
		ld_customform03scf.cf_7471,
		''
	) = ?
	GROUP BY
		lineitem_id
	ORDER BY
		crmid DESC,
		lineitem_id
		";
            $bind_params_arr = array($_REQUEST['account_id'],trim($_REQUEST['productname']),trim($_REQUEST['wuliao']),trim($_REQUEST['caizhi']),$_REQUEST['account_id'],trim($_REQUEST['productname']),trim($_REQUEST['wuliao']),trim($_REQUEST['caizhi']));
            $listview_header = array("单据编号","日期","产品名称","用户物料识别信息","材质","单价");
            break;
        default:
            exit();
    }
}

$smarty->assign("LISTHEADER", $listview_header);//列头字段
$smarty->assign('LISTVIEWTOTALWIDTH','1200');//列头总宽度
$list_result = $adb->pquery($query,$bind_params_arr);
$row_count=$adb->num_rows($list_result);
crm_load_function_file('AlphabeticalSearch','include/utils','ListViewUtils');
$focus = CRMEntity::getInstance($currentModule);

$smarty->assign('POPHTML',createPopWithDetailhtmljinci($list_result,$currentModule,$row_count,count($listview_header),$curr_row));

setGLobalURLSmarty($smarty);//设置js,css等访问路径

$arr['title']=getTransTab($_REQUEST['frommodule']);
$str=$smarty->fetch("PopupLayerjinci.tpl");

$arr['content']=$str;
$arr['curr_row']=$_REQUEST['curr_row'];
ConvertTojsonString(1,$arr,"success");

function createPopWithDetailhtmljinci($list_result,$frommodule,$ROW_COUNT,$HEADERCOUNT,$curr_row)
{
    global $adb,$global_minversin;

    $LISTENTITY = $adb->query_result_all($list_result);

    $pophtml = '';
    if ($ROW_COUNT <= 0) {
        $pophtml .= '<tr align="center">';
        $pophtml .= '<td colspan="' . $HEADERCOUNT . '" bgcolor="#fff" style="height:390px;">';
        $pophtml .= '<div class="warningTableContent" style="z-index:600;">';
        $pophtml .= "<div class='wtc_img'><img src='themes/icon2023/ld-no-records.png?v=".$global_minversin."'></div>";
        $pophtml .= "<div class='wtc_content'>" . getFixedLabel('NOTFOUNDANYRECORD') . "</div>";
        $pophtml .= "<div class='wtc_content'></div>";
        $pophtml .= '</div>';
        $pophtml .= '</td></tr>';
        return trim($pophtml);
    }

    $i = 0;
    if (in_array($frommodule,array("Quotes","CustomForm13"))) {
        foreach ($LISTENTITY as $row) {
            $bill_no = $row['bill_no'];
            $recordid = $row['crmid'];
            $modulename = $row['modulename'];
            $lineitem_id = $row['lineitem_id'];
            $productid = $row['productid'];
            $productname = $row['productname'];

            if ($i % 2 == 0) {
                $pophtml .= '<tr class="lvtColDataBj" record="' . $recordid . '"  id="row_' . $lineitem_id . '" >';
            } else {
                $pophtml .= '<tr class="lvtColData" record="' . $recordid . '"  id="row_' . $lineitem_id . '" >';
            }

            $pophtml .= '<td><a href="javascript:void(0);" onclick="fun_selectproduct.prototype.setEntryInfojinci(\'' . $curr_row . '\',\'' . $modulename . '\',\'' . $recordid . '\',\'' . $lineitem_id . '\')" title="' . $bill_no . '">' . $bill_no . '</a></td>';
//            $pophtml .= '<td><a target="_blank" class="card-link" class="ld_list_href_name tip-items-list" module="'.$modulename.'" record="'.$recordid.'" href="index.php?pageto_module='.$modulename.'&pageto_action=index&pageto_record='.$recordid.'" doubleclick="yes"  title="'.$row['signed_data'].'">'.$row['signed_data'].'</a></td>';
            $pophtml .= '<td><span title="" style="color:#333333">' . $row['signed_data'] . '</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333"><a target="_blank" class="card-link" class="ld_list_href_name tip-items-list" lasturl="" fieldname="productname" module="Products" record="' . $productid . '" href="index.php?pageto_module=Products&pageto_action=index&pageto_record=' . $productid . '" doubleclick="yes"  title="' . $productname . '">' . $productname . '</a></span></td>';
            if ($frommodule == 'Quotes') //列头多一个字段
                $pophtml .= '<td><span title="" style="color:#333333">' . $row['productsheet'] . '</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">' . $row['caizhi'] . '</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">' . $row['jiaohuo_status'] . '</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">' . $row['taxprice'] . '</span></td>';

            $pophtml .= "</tr>";

            $i++;
        }
    }
    elseif($frommodule == "CustomForm35")
    {
        foreach ($LISTENTITY as $row) {
            $bill_no = $row['bill_no'];
            $recordid = $row['crmid'];
            $modulename = $row['modulename'];
            $lineitem_id = $row['lineitem_id'];
            $productid = $row['productid'];
            $product_no = $row['product_no'];


            if ($i % 2 == 0) {
                $pophtml .= '<tr class="lvtColDataBj" record="' . $recordid . '"  id="row_' . $lineitem_id . '" >';
            } else {
                $pophtml .= '<tr class="lvtColData" record="' . $recordid . '"  id="row_' . $lineitem_id . '" >';
            }

            $pophtml .= '<td><a href="javascript:void(0);" onclick="setEntryInfojinci(\''.$curr_row.'\',\''.$modulename.'\',\''.$recordid.'\',\''.$lineitem_id.'\')" title="'.$bill_no.'">'.$bill_no.'</a></td>';
//            $pophtml .= '<td><a target="_blank" class="card-link" class="ld_list_href_name tip-items-list" module="'.$modulename.'" record="'.$recordid.'" href="index.php?pageto_module='.$modulename.'&pageto_action=index&pageto_record='.$recordid.'" doubleclick="yes"  title="'.$row['signed_data'].'">'.$row['signed_data'].'</a></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['signed_data'].'</span></td>';
            if(!empty($productid)){
                $pophtml .= '<td><span title="" style="color:#333333"><a target="_blank" class="card-link" class="ld_list_href_name tip-items-list" lasturl="" fieldname="productname" module="Products" record="'.$productid.'" href="index.php?pageto_module=Products&pageto_action=index&pageto_record='.$productid.'" doubleclick="yes"  title="'.$product_no.'">'.$product_no.'</a></span></td>';
            }else{
                $pophtml .= '<td><span title="" style="color:#333333">'.$product_no.'</span></td>';

            }

            $pophtml .= '<td><span title="" style="color:#333333">'.$row['productsheet'].'</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['caizhi'].'</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['taxprice'].'</span></td>';

            $pophtml .= "</tr>";

            $i++;
        }
    }
    elseif($frommodule == "CustomForm23")
    {
        foreach ($LISTENTITY as $row) {
            $bill_no = $row['bill_no'];
            $recordid = $row['crmid'];
            $modulename = $row['modulename'];
            $lineitem_id = $row['lineitem_id'];
            $productid = $row['productid'];
            $productname = $row['productname'];


            if ($i % 2 == 0) {
                $pophtml .= '<tr class="lvtColDataBj" record="' . $recordid . '"  id="row_' . $lineitem_id . '" >';
            } else {
                $pophtml .= '<tr class="lvtColData" record="' . $recordid . '"  id="row_' . $lineitem_id . '" >';
            }

            $pophtml .= '<td><a href="javascript:void(0);" onclick="setEntryInfojinci(\''.$curr_row.'\',\''.$modulename.'\',\''.$recordid.'\',\''.$lineitem_id.'\')" title="'.$bill_no.'">'.$bill_no.'</a></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['signed_data'].'</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$productname.'</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['wuliao'].'</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['caizhi'].'</span></td>';
            $pophtml .= '<td><span title="" style="color:#333333">'.$row['taxprice'].'</span></td>';

            $pophtml .= "</tr>";

            $i++;
        }
    }

    return trim($pophtml);

}

?>