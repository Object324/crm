<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 * 出库单  审核、反审核操作
 ********************************************************************************/
global $adb;
if (!empty($_REQUEST['record']) && !empty($_REQUEST['persence'])) {
    //presence 1:审核  2:未审核
    global $adb, $PlatformMC;
    //获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
    $deployarray = getSys_deploy(48);
    if ($deployarray['deploy_value'] == 1) {
        if ($_REQUEST['stype'] == 'check') {
            require_once(globalStatic::$root_directory . 'include/Stock/CommonStock.php');
            updateOutPresence($_REQUEST['record']);
        }
        if (empty($PlatformMC)) {
            $data['code'] = 1;
            //edit:can 20210714 46895: （http://47.100.192.59/crm [^]）客户问题（邹钰明），出库单（编号：CK7843）审批选择“ 审批成功，结束流程”点击【确认】点不动
            //require_once('./include/Zend/Json.php');
            $json = new Zend_Json();
            $jsonentity = $json->encode($data);
            echo $jsonentity;
            die;
        } else {
            ConvertTojsonString(1, array(), '');
        }

    }
    //设置是否允许负库存出库
    $deployarray_141 = getSys_deploy(141);
    if ($deployarray_141['deploy_value'] != 1 && $_REQUEST['persence'] == 1) {
        $err_info = '';
        $err_subject = getFixedLabel('PRODUCTSQUANTITYEXCESS') . ',' . getFixedLabel('USERSAVEFAIL');
        $query = 'select ld_products.productid,quantity,qtyinstock,productname,ld_products.product_no from ld_outboundorderdetail
				LEFT JOIN ld_products on ld_products.productid =ld_outboundorderdetail.productid where id = ?';
        $result = $adb->pquery($query, array($_REQUEST['record']));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            $k = 0;
            $sysdeploy = getSys_deploy(49);
            if (isset($sysdeploy['deploy_value']))
                $lengthdecimaldigits = $sysdeploy['deploy_value'];
            else
                $lengthdecimaldigits = 2;
            for ($i = 0; $i < $num_rows; $i++) {
                $quantity = $adb->query_result($result, $i, 'quantity');
                $product_no = $adb->query_result($result, $i, 'product_no');
                $productname = $adb->query_result($result, $i, 'productname');
                $qtyinstock = $adb->query_result($result, $i, 'qtyinstock');
                $qtyinstock = sprintf('%.' . $lengthdecimaldigits . 'f', $qtyinstock);
                //如果产品出库数大于产品的总库存数量，则审核失败，给予提示
                if ($quantity > $qtyinstock) {
                    $k++;
                    $productname = '<span style="color: #0070ba;">' . $productname . '</span>' . '（' . $product_no . '）';
                    //echo $products_qty[$productid] . '--' . $qtyinstock;echo '<br><br>';
                    $err_info .= $k . '、' . $productname . '　' . getFixedLabel('productquantity') . ': ' . sprintf('%.' . $lengthdecimaldigits . 'f', $quantity) . '　' . getFixedLabel('QTYINSTOCK') . ': ' . $qtyinstock . '<br>';

                }
            }
        }
        if (!empty($err_info)) {
            if (empty($PlatformMC)) {
                $data['code'] = -2;
                $data['err_subject'] = $err_subject;
                $data['err_info'] = $err_info;
                //	require_once('./include/Zend/Json.php');
                $json = new Zend_Json();
                $jsonentity = $json->encode($data);
                echo $jsonentity;
                die;
            } else {
                $wx_err = '<div style="text-align: left;">' . $err_subject . '<br>' . $err_info . '</div>';
                ConvertTojsonString(-2, array(), $wx_err);
            }

        }
    }
    require_once(globalStatic::$root_directory . 'include/Stock/CommonStock.php');

    $tmps = getMinZero_Batchtext_whenApprove('OutboundOrder', $_REQUEST['record']);
    if (is_array($tmps) && sizeof($tmps) > 0) {
        foreach ($tmps as $index => $content) {
            $productname = $content['productname'];
            $errorinfo .= str_replace('{productname}', '"' . $productname . '"', getFixedLabel('QUANTITYMORTHANCURRENTROWBATCH')) . "\n";
        }
        ConvertTojsonString(-3, array(), $errorinfo);
    }
    $presence = $_REQUEST['persence'];
    $record = $_REQUEST['record'];
    $deploy_values = getSys_deploy(10);//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否
    /*if($presence == 1&&$deploy_values['deploy_value']==0){
        $query = 'select parent_lineitem_id,entitytype,entitytypeid,productid,quantity from ld_outboundorderdetail where id = ?';
        $result = $adb->pquery($query,array($record));
        for($i = 0; $i<$adb->num_rows($result); $i++){
            $parent_lineitem_id = $adb->query_result($result,$i,'parent_lineitem_id');
            $entitytypeid = $adb->query_result($result,$i,'entitytypeid');
            $productid = $adb->query_result($result,$i,'productid');
            $quantity = $adb->query_result($result,$i,'quantity');
            $entitytype=$adb->query_result($result,$i,'entitytype');

            if($productid > 0 && $entitytypeid > 0 && $parent_lineitem_id > 0&&!empty($entitytype)){
             $source_focus=CRMEntity::getInstance($entitytype);
             $source_detail_table=$source_focus->Detail_table;
                $query = " SELECT
                    balanceoutproductcount,haveoutproductcount,ld_products.productname
                FROM
                    $source_detail_table
                LEFT JOIN ld_products on ld_products.productid = $source_detail_table.productid
                WHERE
                    $source_detail_table.id = ?
                AND $source_detail_table.productid = ?
                AND $source_detail_table.lineitem_id = ? ";
                $sresult = $adb->pquery($query,array($entitytypeid,$productid,$parent_lineitem_id));
                $num_rows = $adb->num_rows($sresult);
                if($num_rows >= 1){
                    $productname = $adb->query_result($sresult,0,'productname');
                    $balanceoutproductcount = $adb->query_result($sresult,0,'balanceoutproductcount');
                    $haveoutproductcount = $adb->query_result($sresult,0,'haveoutproductcount');
                    //判断产品出库数是否大于源单的未出库数量
                    if($quantity > $balanceoutproductcount){
                        $error[$parent_lineitem_id] = array(
                            'productname' => $productname,
                            'haveoutproductcount' =>  sprintf('%.2f',$haveoutproductcount),
                            'balanceoutproductcount' => sprintf('%.2f',$balanceoutproductcount)
                        );
                    }
                }
            }
        }
    }*/

    if (!empty($error)) {
        if (empty($PlatformMC)) {
            $data['code'] = -1;
            $data['err_info'] = $error;
            //	require_once('./include/Zend/Json.php');
            $json = new Zend_Json();
            $jsonentity = $json->encode($data);
            echo $jsonentity;
            die;
        } else {
            $j = 1;
            $err_info = '';
            foreach ($error as $val) {
                $productname = '<span style="color: #0070ba;">' . $val['productname'] . '</span>';
                $err_info .= $j . '、' . $productname . '　累计出库数量: ' . setNumberFormat($val['haveoutproductcount']) . '　可出库数量: ' . setNumberFormat($val['balanceoutproductcount']) . '<br>';
                $j++;
            }
            $err_subject = '产品累计出库数量超过可出库数量,审核失败!';
            $wx_err = '<div style="text-align: left;">' . $err_subject . '<br>' . $err_info . '</div>';
            ConvertTojsonString(-1, array(), $wx_err);
        }

    } else {
        if ($_REQUEST['stype'] == 'check') {
            require_once(globalStatic::$root_directory . 'include/Stock/CommonStock.php');
            updateOutPresence($_REQUEST['record']);
        }
        if (empty($PlatformMC)) {
            $data['code'] = 1;
            //	require_once('./include/Zend/Json.php');
            $json = new Zend_Json();
            $jsonentity = $json->encode($data);
            echo $jsonentity;
            die;
        } else {
            ConvertTojsonString(1, array(), '');
        }

    }
} else {
    //chj 2020/12/24 43906: （https://61mis.com/kfbcrm/ [^]）>系统设置-库存参数-设置不允许负库存出库，新建出库单，以产品菠萝蜜111为例，它是负库存，仍然可以新建出库单
    if (!empty($_REQUEST['outbound_delivery']) && $_REQUEST['outbound_delivery'] == 'yes') {
        $_REQUEST['diony'] = 'diony';
        //设置是否允许负库存出库 0否 1是
        $deployarray_141 = getSys_deploy(141);
        //获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
        $deployarray_48 = getSys_deploy(48);
        $sysdeploy = getSys_deploy(49);
        if ($deployarray_141['deploy_value'] != 1 && $deployarray_48['deploy_value'] == 1 && !empty($_REQUEST['productids'])) {
            $db_product_quantitys = [];
            if (!empty($_REQUEST['record'])) {
                //处理分录中存在一样的产品情况
                $query = 'select ld_outboundorderdetail.productid,sum(quantity) as qty 
                from ld_outboundorderdetail where id = ? group by ld_outboundorderdetail.productid';
                $result = $adb->pquery($query, array($_REQUEST['record']));
                $num_rows = $adb->num_rows($result);

                for ($i = 0; $i < $num_rows; $i++) {
                    $productid = $adb->query_result($result, $i, 'productid');
                    $qty = $adb->query_result($result, $i, 'qty');
                    $db_product_quantitys[$productid] = $qty;
                }
            }

            $qty_arr = explode(',', $_REQUEST['quantitys']);
            $productid_arr = explode(",", $_REQUEST['productids']);
            $qtys = [];
            foreach ($qty_arr as $qtyindex => $tmpqty) {
                $qtys[$productid_arr[$qtyindex]] = $tmpqty;
            }
            $err_info = '';
            $err_subject = getFixedLabel('PRODUCTSQUANTITYEXCESS') . ',' . getFixedLabel('USERSAVEFAIL');
            $query = 'select ld_products.productid,qtyinstock,productname,
            ld_products.product_no from ld_products where productid in (' . $_REQUEST['productids'] . ')';
            $result = $adb->pquery($query, array());
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0) {
                $k = 0;
                if (isset($sysdeploy['deploy_value']))
                    $lengthdecimaldigits = $sysdeploy['deploy_value'];
                else
                    $lengthdecimaldigits = 2;

                for ($i = 0; $i < $num_rows; $i++) {
                    $productid = $adb->query_result($result, $i, 'productid');
                    $product_no = $adb->query_result($result, $i, 'product_no');
                    $productname = $adb->query_result($result, $i, 'productname');
                    $qtyinstock = $adb->query_result($result, $i, 'qtyinstock');
                    if (!empty($_REQUEST['record']) && isset($db_product_quantitys[$productid])) {
                        $qtyinstock += $db_product_quantitys[$productid];
                    }
                    //如果产品出库数大于产品的总库存数量，则审核失败，给予提示
                    //edit:can 46709: （http://lanniaofire.vicp.io:9085/ [^] ）客户问题（陈修宏），出库单新建界面，产品【录入数量】没有超过【总库存数量】保存时，提示保存失败
                    //数据库存的是0.99 界面是0.1
                    $qtyinstock = sprintf('%.' . $lengthdecimaldigits . 'f', $qtyinstock);
                    if ($qtys[$productid] > $qtyinstock) {
                        $k++;
                        $qtyinstock = sprintf('%.' . $lengthdecimaldigits . 'f', $qtyinstock);
                        $productname = '<span style="color: #0070ba;">' . $productname . '</span>' . '（' . $product_no . '）';
                        //echo $products_qty[$productid] . '--' . $qtyinstock;echo '<br><br>';
                        $err_info .= $k . '、' . $productname . '　' . getFixedLabel('productquantity') . ': ' . sprintf('%.' . $lengthdecimaldigits . 'f', $qtys[$productid]) . '　' . getFixedLabel('QTYINSTOCK') . ': ' . $qtyinstock . '<br>';

                    }
                }

                if (!empty($err_info)) {
                    $wx_err = '<div style="text-align: left;">' . $err_subject . '<br>' . $err_info . '</div>';
                    ConvertTojsonString(-2, array(), $wx_err);
                }
            }
        }
        ConvertTojsonString(1, array(), '');

    }
}

?>