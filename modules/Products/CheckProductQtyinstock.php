<?php
global $adb, $PlatformMC;
$lengthdecimaldigits = getSys_deploy(49);//设置单据分录明细中数量字段小数位数
if (!empty($_REQUEST['productinfo'])) {
    //限制出货控制
    if (!empty($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0) {
        $focus = CRMEntity::getInstance('Accounts');
        $focus->retrieve_entity_info($_REQUEST['account_id'], 'Accounts');
        if (isset($focus->column_fields['allowdelivery_date']) && !empty($focus->column_fields['allowdelivery_date'])) {
            $allowdelivery_date = $focus->column_fields['allowdelivery_date'];
            $now_date = date('Y-m-d');
            //如果小于等于不允许保存。并给出提示信息：该客户在yyyy-mm-dd之后才允许发货，保存失败！
            if ($now_date <= $allowdelivery_date) {
                $err_info = sprintf(getFixedLabel('onlyallowedtodeliverafter'), $allowdelivery_date);
                $data['code'] = -2;
                $data['err_info'] = $err_info;
                require_once(globalStatic::$root_directory . '/include/Zend/Json.php');
                $json = new Zend_Json();
                $jsonentity = $json->encode($data);
                echo $jsonentity;
                die;
            }
        }
    }
    $code = 1;
    //设置是否允许负库存出库	// 1是 0否
    $deployarray = getSys_deploy(141);
    $val = $deployarray['deploy_value'];
    $qtyear_val = "-1";
    if (!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'OutboundOrder') {
        //设置出库单或入库单更新库存流水记录的触发点  1保存  0审核
        $deployarray_48 = getSys_deploy(48);
        //保存时，如果触发点为审核，则不判断产品负库存数量
        if ($_REQUEST['type'] == 'save' && $deployarray_48['deploy_value'] == 0) {
            $val = 1;
        }
    } else if (!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'SalesOrder') {
        //控制合同订单是否需要提示负库存
        $deployarray = getSys_deploy(142);
        if ($deployarray['deploy_value'] == 1) {
            $val = 0;//需要提示
        } else {
            $val = 1;
        }

        $qtyear_deployarray = getSys_deploy(201);//超过安全库存数量

        $qtyear_val = $qtyear_deployarray['deploy_value'];//0:需要提示

    }

    if ($val == 0 || $qtyear_val == 0) {

        $profocus = CRMEntity::getInstance('Products');

        $product_array = explode(',', $_REQUEST['productinfo']);
        foreach ($product_array as $products) {
            if (!empty($products)) {
                $pros = explode('|', $products);
                $productids[] = $pros[0];
                $products_qty[$pros[0]] = $pros[1];
                $db_productinfos[$pros[0]] = 0;
            }
        }
        if (sizeOf($productids) > 0) {
            //当出库单触发点为保存，编辑出库单时，获取出库单明细产品原先在数据库中存储的值
            if (!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'OutboundOrder' && $_REQUEST['mode'] == 'edit' && $_REQUEST['type'] == 'save' && !empty($_REQUEST['record'])) {
                $query = 'select productid,quantity from ld_outboundorderdetail where id = ?';
                $result = $adb->pquery($query, array($_REQUEST['record']));
                $num_rows = $adb->num_rows($result);
                if ($num_rows > 0) {
                    for ($i = 0; $i < $num_rows; $i++) {
                        $productid = $adb->query_result($result, $i, 'productid');
                        $quantity = $adb->query_result($result, $i, 'quantity');
                        $db_productinfos[$productid] = $quantity;
                    }
                }
            }
            $query = 'select productid,ifnull(qtyinstock,0) as qtyinstock,productname,product_no,ifnull(qtyearly,0) as qtyearly from ld_products where productid in (' . implode(',', $productids) . ') and deleted = 0';
            $result = $adb->pquery($query, array());
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0 && $val == 0) {
                if (!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'OutboundOrder') {
                    $err_subject = getFixedLabel('PRODUCTSQUANTITYEXCESS') . ',' . getFixedLabel('USERSAVEFAIL');
                } else {
                    $err_subject = getFixedLabel('PRODUCTSQUANTITYEXCESS') . ',' . getFixedLabel('WHETHERTOCONTINUE');
                }
                $err_info = '';
                $k = 1;
                for ($i = 0; $i < $num_rows; $i++) {
                    $productid = $adb->query_result($result, $i, 'productid');
                    $qtyinstock = $adb->query_result($result, $i, 'qtyinstock');
                    $productname = $adb->query_result($result, $i, 'productname');
                    $product_no = $adb->query_result($result, $i, 'product_no');
                    if ($products_qty[$productid] > $qtyinstock + $db_productinfos[$productid]) {
                        $productname = $productname;
                        //echo $products_qty[$productid] . '--' . $qtyinstock;echo '<br><br>';
                        $err_info .= $k . '、' . $productname . '（' . $product_no . '）' . '　' . getFixedLabel('productquantity') . ': ' . setNumberFormat($products_qty[$productid], $lengthdecimaldigits['deploy_value']) . '　' . getFixedLabel('QTYINSTOCK') . ': ' . setNumberFormat($qtyinstock, $lengthdecimaldigits['deploy_value']) . "\r\n";
                        $k++;
                    }
                }
            }
            if ($qtyear_val == 0 && $err_info == '') {

                //设置合同订单分录明细中数量超过安全库存数量时是否需要提示
                $err_info = '';
                $k = 1;
                $qtyearly_label = $profocus->fieldobj->getFieldInfoBykeyValue('columnname', 'qtyearly', 'fieldlabel');
                $err_subject = getFixedLabel('PRODUCTSMORETHANQTYEARLY') . ',' . $qtyearly_label;
                for ($i = 0; $i < $num_rows; $i++) {
                    $productid = $adb->query_result($result, $i, 'productid');
                    $qtyearly = $adb->query_result($result, $i, 'qtyearly');
                    $productname = $adb->query_result($result, $i, 'productname');
                    $product_no = $adb->query_result($result, $i, 'product_no');
                    if ($products_qty[$productid] > $qtyearly + $db_productinfos[$productid]) {
                        $productname = '' . $productname . '';
                        //echo $products_qty[$productid] . '--' . $qtyinstock;echo '<br><br>';
                        $err_info .= $k . '、' . $productname . '（' . $product_no . '）' . '　' . getFixedLabel('productquantity') . ': ' . setNumberFormat($products_qty[$productid], $lengthdecimaldigits['deploy_value']) . '　'
                            . $qtyearly_label . ': ' . setNumberFormat($qtyearly, $lengthdecimaldigits['deploy_value']) . "\n";
                        $k++;
                    }
                }
            }
        }
        if (!empty($err_info)) $code = -1;
    }
    $data['code'] = $code;
    $data['err_subject'] = $err_subject;
    $data['err_info'] = $err_info;
    require_once(globalStatic::$root_directory . '/include/Zend/Json.php');
    $json = new Zend_Json();
    $jsonentity = $json->encode($data);
    if (!empty($PlatformMC) && $PlatformMC['type'] == 'weixin') {
        if ($code == -1) {
            $wx_err = '<div style="text-align: left;">' . $err_subject . '<br>' . $err_info . '</div>';
            if ($_REQUEST['frommodule'] == 'OutboundOrder') ConvertTojsonString(-1, '', $wx_err);
            else ConvertTojsonString(-2, array(), $wx_err);
        }
        unset($_REQUEST['productinfo']);
        unset($_REQUEST['frommodule']);
        unset($_REQUEST['type']);
    } else {
        echo $jsonentity;
        die;
    }

}
?>