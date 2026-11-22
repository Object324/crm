<?php

global $adb, $current_user, $currentModule,$weixin_user;

$type = $_REQUEST['type'];
$record = $_REQUEST['record'];
//editor:gyq_20191225 reason:移动端，增加新增采购退货单前的判断
if ($_REQUEST['ajaxmode'] == 'check') {
    //办理退货
    $deployarray = getSys_deploy(132);
    $deployvalue = $deployarray['deploy_value'];
    if ($deployvalue == 1) {
        if($weixin_user->environment_weixin){
            ConvertTojsonString(1,array('string'=>'allow'),'success');
        }else{
            echo "###SUCCESS###allow";
            exit();
        }
    }
    $purchaseorder_id = $_REQUEST['purchaseorder_id'];
    $salestotal = 0;
    $backtotal = 0;//合同金额、退货金额
    $query = 'select ifnull(havepurchasecount,0) as havepurchasecount,ld_purchaseorder.stockpresence from ld_purchaseorderdetail 
	LEFT JOIN ld_purchaseorder on ld_purchaseorder.purchaseorderid = ld_purchaseorderdetail.id where id = ?;';
    $result = $adb->pquery($query, array($purchaseorder_id));

    for ($i = 0; $i < $adb->num_rows($result); $i++) {
        $stockpresence = $adb->query_result($result, $i, 'stockpresence');
        //zkt 20220930 BUG0057315采购订单相关信息已有采购退货单时，系统参数设置未入库的采购订单不允许退货后，采购订单再次点击采购退货单【新建】按钮时，应该弹出提示信息“当前系统参数设置未入库订单不允许退货，该采购订单还未入库，不允许办理退货！”目前是进入退货单新建界面，但并未带出产品分录
        if ($adb->query_result($result, $i, 'havepurchasecount') > 0.0001&&$stockpresence != '未入库') {
            if($weixin_user->environment_weixin){
                ConvertTojsonString(1,array('string'=>'allow'),'success');
            }else{
                echo '###SUCCESS###allow';
                exit();
            }
        }
    }
    $errorMsg = '';
    if ($stockpresence == '未入库')
        $errorMsg = 'no_stock';    //该采购订单还未入库，不允许办理退货！
    else if ($stockpresence == '生成入库单')
        $errorMsg = 'nocheck_stock';    //该单据已入库数量为零，请审核入库单
    else
        $errorMsg = 'all_stock';
    if($weixin_user->environment_weixin){
        $errorMsgLabel = array('no_stock'=>'PURCHASEORDEROUTNOALLOWRETURN',
            'nocheck_stock'=>'THISDOCUMENTHASBEENSHIPPEDTOZERO',
            'all_stock'=>'PURCHASEORDERFULLYOUTNOALLOWRETURN'
        );
        ConvertTojsonString(-1,array(),getFixedLabel($errorMsgLabel[$errorMsg]));
    }else{
        echo $errorMsg;
        exit();
    }
}

if ($type == 'outstock' || $type == 'cancelstock') {
    if ($type == 'outstock') {
        $purchasebackstatus = '已出库';
        $typename = '退货出库';
    } else {
        $purchasebackstatus = '未出库';
        $typename = '撤销退货';
    }
    //判断采购退货单产品明细下的产品数量是否大于对应采购订单下的产品已入库数量
    $sql = "select quantity,parent_lineitem_id,entitytypeid,ld_purchaseback.wareid,productid,lineitem_id,batchtext from ld_purchaseback 
    inner join ld_purchasebackdetail on id=purchasebackid where purchasebackid = ? ";

    $result = $adb->pquery($sql, array($record));
    $num_rows = $adb->num_rows($result);

    //更改采购退货单的状态
    $update_query = "update ld_purchaseback set purchasebackstatus=? where purchasebackid=?";
    $adb->pquery($update_query, array($purchasebackstatus, $record));
    crm_load_function_file("insertCondtion", 'include/Stock', 'CommonStock');
    crm_load_class_file('cls_Source_InverseCompute', 'include/OptionModule');
    for ($i = 0; $i < $num_rows; $i++) {
        $productid = $adb->query_result($result, $i, 'productid');
        $qty = $adb->query_result($result, $i, 'quantity');
        $entitytypeid = $adb->query_result($result, $i, 'entitytypeid');
        $parent_lineitem_id = $adb->query_result($result, $i, 'parent_lineitem_id');
        $lineitem_id = $adb->query_result($result, $i, 'lineitem_id');
        $wareid = $adb->query_result($result, $i, 'wareid');
        $batchtext = $adb->query_result($result, $i, 'batchtext');
        insertCondtion($batchtext, $record, $typename, $wareid, $productid, $currentModule, $current_user->id, 0, 0, $parent_lineitem_id, $lineitem_id);


    }

    //更新采购订单未入库和入出库数量
    cls_Source_InverseCompute::Source_InveverseCompute("PurchaseBack", $record);
} else if ($type == 'endstock') {
    $end = $_REQUEST['end'];
    if ($end == 'out') {
        $update_query = "update ld_purchaseback set purchasebackstatus='结束' where purchasebackid=?";
    } else {
        $update_query = "update ld_purchaseback set purchasebackstatus='中止' where purchasebackid=?";
    }
    $adb->pquery($update_query, array($record));
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}

/*if ($_REQUEST['ajaxmode'] == 'cashbackcheck') {

    $purchaseback_id = $_REQUEST['purchaseback_id'];

    $sql = 'select productid,SUM(ifnull(quantity,0)) as quantity from ld_purchasecashback
	INNER JOIN ld_purchasecashbackdetail 
		on ld_purchasecashbackdetail.id = ld_purchasecashback.purchasecashbackid
	where purchaseback_id=? and ld_purchasecashback.deleted = 0 
    and ld_purchasecashback.purchasecashbackid > 0 group by productid';
    //$sql = "SELECT productid,SUM(ifnull(quantity,0)) as quantity from ld_inventoryproductrel left join ld_crmentity on crmid = id where ld_crmentity.deleted = 0 and id in (SELECT purchasebackid from ld_purchaseback where purchaseorder_id=".$_REQUEST['purchaseorder_id'].") and  group by productid";
    $result = $adb->pquery($sql, array($purchaseback_id));
    $rowCounts = $adb->num_rows($result);
    if ($rowCounts > 0) {
        for ($i = 0; $i < $rowCounts; $i++) {
            $productid = $adb->query_result($result, $i, 'productid');
            $product_list[$productid] = $adb->query_result($result, $i, 'quantity');
        }
    } else {
        echo "###SUCCESS###";
        exit();
    }


    //采购退货单总金额
    $sqlBackTotal = 'select subtotal from ld_purchaseback where purchasebackid = ?';
    $resultBackTotal = $adb->pquery($sqlBackTotal, array($purchaseback_id));
    $backTotal = $adb->query_result($resultBackTotal, 0, 'subtotal');
    //采购退货单对应采购退款单总金额
    $sqlCashBackTotal = 'select sum(IFNULL(subtotal,0)) as subtotal from ld_purchasecashback where purchaseback_id = ? and deleted = 0';
    $resultCashBackTotal = $adb->pquery($sqlCashBackTotal, array($purchaseback_id));
    $cashBackTotal = $adb->query_result($resultCashBackTotal, 0, 'subtotal');
    if ($backTotal <= $cashBackTotal) {
        echo "###ERROR###";
        exit();
    }

    $sql = "SELECT productid,SUM(ifnull(quantity,0)) as quantity from ld_purchasebackdetail where id =? group by productid";
    $result = $adb->pquery($sql, array($purchaseback_id));
    $rowCount = $adb->num_rows($result);
    $productids = '';
    for ($i = 0; $i < $rowCount; $i++) {
        $productid = $adb->query_result($result, $i, 'productid');
        $backproduct_list[$productid] = $adb->query_result($result, $i, 'quantity');
        $productids .= $productid . ',';
    }
    $productids = trim($productids, ',');

    $sql = 'select productid,SUM(ifnull(quantity,0)) as quantity from ld_purchasecashback
	INNER JOIN ld_purchasecashbackdetail 
		on ld_purchasecashbackdetail.id = ld_purchasecashback.purchasecashbackid
	where purchaseback_id=? and ld_purchasecashbackdetail.productid in (?) and ld_purchasecashback.deleted = 0 
    and ld_purchasecashback.purchasecashbackid > 0 group by productid';
    //$sql = "SELECT productid,SUM(ifnull(quantity,0)) as quantity from ld_inventoryproductrel left join ld_crmentity on crmid = id where ld_crmentity.deleted = 0 and id in (SELECT purchasebackid from ld_purchaseback where purchaseorder_id=".$_REQUEST['purchaseorder_id'].") and  group by productid";
    $result = $adb->pquery($sql, array($purchaseback_id, $productids));
    $rowCounts = $adb->num_rows($result);
    if ($rowCounts > 0) {
        for ($i = 0; $i < $rowCounts; $i++) {
            $productid = $adb->query_result($result, $i, 'productid');
            $product_list[$productid] = $adb->query_result($result, $i, 'quantity');
        }
    }

    $isback = false;
    if (count($backproduct_list) > count($product_list)) {
        echo "###SUCCESS###";
        exit();
    }
    foreach ($backproduct_list as $key => $arr) {
        if (isset($product_list[$key]) && $product_list[$key] < $arr) {
            $isback = true;
            break;
        }
    }
    if ($isback) {
        echo "###SUCCESS###";
        exit();
    } else {
        echo "###ERROR###";
        exit();
    }
}*/


/*if ($_REQUEST['type'] == 'savecheck') {
    $deployarray = getSys_deploy(132);
    $deployvalue = $deployarray['deploy_value'];
    if ($deployvalue == 1) {
        echo "###SUCCESS###";
        exit();
    }

    //采购退货单ID
    if ($_REQUEST['purchasebackid'] && $_REQUEST['purchasebackid'] > 0)
        $purchasebackid = $_REQUEST['purchasebackid'];
    else
        $purchasebackid = 0;

    $record = $_REQUEST['record'];

    $sql = 'select productid,quantity,listprice,lineitem_id,havepurchasecount from ld_purchaseorderdetail
    inner join ld_purchaseorder on ld_purchaseorderdetail.id = ld_purchaseorder.purchaseorderid
    inner join ld_crmentity on ld_purchaseorder.purchaseorderid = ld_crmentity.crmid
    where ld_purchaseorder.deleted = 0 and ld_purchaseorder.purchaseorderid = ? ';
    $result = $adb->pquery($sql, array($record));
    for ($i = 0; $i < $adb->num_rows($result); $i++) {
        $lineitem_id = $adb->query_result($result, $i, 'lineitem_id');
        $purchasepro[$lineitem_id] = array(
            'productid' => $adb->query_result($result, $i, 'productid'),
            'quantity' => $adb->query_result($result, $i, 'quantity'),
            'listprice' => $adb->query_result($result, $i, 'listprice'),
            'lineitem_id' => $adb->query_result($result, $i, 'lineitem_id'),
            'havepurchasecount' => $adb->query_result($result, $i, 'havepurchasecount'),
        );
    }
    //$_REQUEST['idstring']  产品ID+产品数量+产品金额+产品行原单ID
    $ispro = explode(',', $_REQUEST['idstring']);
    foreach ($purchasepro as $lineitem_id => $pro_info) {
        for ($k = 0; $k < count($ispro); $k++) {
            $isPorduct = explode('-', $ispro[$k]);
            if ($lineitem_id == $isPorduct[3]) {
                $isBack = selPurchaseBackQuantity($record, $isPorduct[3], $purchasebackid); //已退货数量
                $isBackTotal = selPurchaseBackTotal($record, $isPorduct[0]); //已退货金额
                if ($isPorduct[1] > $pro_info['havepurchasecount']) {
                    echo "###ERROR###50";//采购退货和销售退货返回不能一样，因为二者的判断用的同一个函数
                    exit();
                }
            }
        }
    }
    echo "###SUCCESS###";
    exit();
}*/

/*if ($_REQUEST['type'] == 'savecashcheck') {

    if ($_REQUEST['purchasecashbackid'] && $_REQUEST['purchasecashbackid'] > 0) {
        $purchasecashbackidold = $_REQUEST['purchasecashbackid'];
        $sql = 'select productid,quantity,listprice from ld_purchasecashbackdetail
        inner join ld_purchasecashback on ld_purchasecashbackdetail.id = ld_purchasecashback.purchasecashbackid
        where ld_purchasecashback.deleted = 0 and ld_purchasecashback.purchasecashbackid = ? group by productid ';
        $result = $adb->pquery($sql, array($purchasecashbackidold));
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $productid = $adb->query_result($result, $i, 'productid');
            $quantity = $adb->query_result($result, $i, 'quantity');
            $listprice = $adb->query_result($result, $i, 'listprice');
            $purchasecashbackoldQ[$productid] = $quantity;
            $purchasecashbackoldL[$productid] = $listprice;
        }
    }

    $record = $_REQUEST['record'];

    $sql = 'select productid,quantity,listprice,lineitem_id,havepurchasecount from ld_purchasebackdetail
inner join ld_purchaseback on ld_purchasebackdetail.id = ld_purchaseback.purchasebackid
inner join ld_crmentity on ld_purchaseback.purchasebackid = ld_crmentity.crmid
where ld_purchaseback.deleted = 0 and ld_purchaseback.purchasebackid = ?';
    $result = $adb->pquery($sql, array($record));
    for ($i = 0; $i < $adb->num_rows($result); $i++) {
        $purchasepro[$i] = array(
            'productid' => $adb->query_result($result, $i, 'productid'),
            'quantity' => $adb->query_result($result, $i, 'quantity'),
            'listprice' => $adb->query_result($result, $i, 'listprice'),
            'lineitem_id' => $adb->query_result($result, $i, 'lineitem_id'),
            'havepurchasecount' => $adb->query_result($result, $i, 'havepurchasecount'),
        );
    }
    $ispro = explode(',', $_REQUEST['idstring']);
    for ($i = 0; $i < count($purchasepro); $i++) {
        for ($k = 0; $k < count($ispro); $k++) {
            $isPorduct = explode('-', $ispro[$k]);
            if ($purchasepro[$i]['lineitem_id'] == $isPorduct[3]) {
                $isBack = selPurchaseCaseBackQuantity($record, $isPorduct[0]); //已退款数量
                $isBackTotal = selPurchaseCaseBackTotal($record, $isPorduct[0]); //已退款金额

                if ($_REQUEST['purchasecashbackid'] && $_REQUEST['purchasecashbackid'] > 0) {
                    $quantityOld = $purchasecashbackoldQ[$isPorduct[0]];
                    $listpriceOld = $purchasecashbackoldL[$isPorduct[0]];
                    if ($isBack + $isPorduct[1] - $quantityOld > $purchasepro[$i]['quantity']) {
                        echo "###ERROR###2";
                        exit();
                    }
                    $isPorductNew = $isPorduct[2] * $isPorduct[1];
                    $isPorductOld = $quantityOld * $listpriceOld;
                    $isPorductAll = $purchasepro[$i]['listprice'] * $purchasepro[$i]['quantity'];
                    if ($isBackTotal + $isPorductNew - $isPorductOld > $isPorductAll) {
                        echo "###ERROR###3";
                        exit();

                    }
                } else {
                    if ($isBack + $isPorduct[1] > $purchasepro[$i]['quantity']) {
                        echo "###ERROR###2";
                        exit();
                    }
                    if ($isBackTotal + $isPorduct[2] * $isPorduct[1] > $purchasepro[$i]['listprice'] * $purchasepro[$i]['quantity']) {
                        echo "###ERROR###3";
                        exit();

                    }
                }


            }
        }
    }
    echo "###SUCCESS###";
    exit();
}*/
/**
 * @edit:chj
 * @date:2014-10-14
 * @reason:获取采购订单内该产品的已采购数量
 * @description:
 *
 * function getHavePurchaseNum($entitytype_id,$parent_lineitem_id)
 * {
 * global $adb;
 * $query = 'select ifnull(havepurchasecount,0) as havepurchasecount  from ld_inventoryproductrel where id = ? and lineitem_id = ? limit 1';
 * $result = $adb->pquery($query,array($entitytype_id,$parent_lineitem_id));
 *
 * return $adb->query_result($result,0,0);
 * }*/
function selPurchaseBackQuantity($purchaseorderid, $parent_lineitem_id, $purchasebackid)
{
    global $adb;
    $sql = "SELECT
				sum(ifnull(quantity, 0)) AS quantity
			FROM
				ld_purchasebackdetail
			INNER JOIN ld_purchaseback ON ld_purchaseback.purchasebackid = ld_purchasebackdetail.id
			WHERE
				ld_purchaseback.deleted = 0
			AND ld_purchasebackdetail.entitytypeid = ? and ld_purchasebackdetail.parent_lineitem_id = ? 
			AND ld_purchaseback.purchasebackstatus ='已出库'";
    if ($purchasebackid > 0) {
        $sql .= ' and ld_purchaseback.purchasebackid != ' . $purchasebackid;
    }
    $result = $adb->pquery($sql, array($purchaseorderid, $parent_lineitem_id));
    return $adb->query_result($result, 0, 0);
}

function selPurchaseBackTotal($purchaseorderid, $productid)
{
    global $adb;
    $sql = "select sum(ifnull(quantity,0))*ifnull(sum(listprice),0) as total from ld_purchasebackdetail
    inner join ld_purchaseback on ld_purchaseback.purchasebackid = ld_purchasebackdetail.id
    where ld_purchaseback.deleted = 0 and ld_purchaseback.purchaseorder_id = ? and ld_purchasebackdetail.productid = ?";
    $result = $adb->pquery($sql, array($purchaseorderid, $productid));
    return $adb->query_result($result, 0, 0);
}

function selPurchaseCaseBackQuantity($purchasebackid, $productid)
{
    global $adb;
    $sql = "select sum(ifnull(quantity,0)) as quantity from ld_purchasecashbackdetail
    inner join ld_purchasecashback on ld_purchasecashback.purchasecashbackid = ld_purchasecashbackdetail.id
    where ld_purchasecashback.deleted = 0 and ld_purchasecashback.purchaseback_id = ? and ld_purchasecashbackdetail.productid = ?";
    $result = $adb->pquery($sql, array($purchasebackid, $productid));
    return $adb->query_result($result, 0, 0);
}


function selPurchaseCaseBackTotal($purchasebackid, $productid)
{
    global $adb;
    $sql = "select sum(ifnull(quantity,0))*ifnull(sum(listprice),0) as total from ld_purchasecashbackdetail
    inner join ld_purchasecashback on ld_purchasecashback.purchasecashbackid = ld_purchasecashbackdetail.id
    where ld_purchasecashback.deleted = 0 and ld_purchasecashback.purchaseback_id = ? and ld_purchasecashbackdetail.productid = ?";
    $result = $adb->pquery($sql, array($purchasebackid, $productid));
    return $adb->query_result($result, 0, 0);
}

echo '#####SUCCESS#####';
unset($adb);
exit();

?>