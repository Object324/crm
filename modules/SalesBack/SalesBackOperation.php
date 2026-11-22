<?php

global $adb, $current_user, $currentModule,$weixin_user;
require_once(globalStatic::$root_directory.'include/Stock/CommonStock.php');
$type = $_REQUEST['type'];
$record = $_REQUEST['record'];
//editor:gyq_20191225 reason:移动端，增加新增销售退货单前的判断
//0039008_kfbcrm）移动端，合同订单关联创建“销售退货单”，没有带出产品明细
if ($_REQUEST['ajaxmode'] == 'check') {
    //合同订单直接退货

    //办理退货
    $deployarray = getSys_deploy(85);
    $deployvalue = $deployarray['deploy_value'];
    if ($deployvalue == 1) {
        if($weixin_user->environment_weixin){
            ConvertTojsonString(1,array('string'=>'allow'),'success');
        }else{
            echo "###SUCCESS###allow";
            exit();
        }
    }
    $pronum = 1;//不可以退货
    $so_id = $_REQUEST['salesorder_id'];//合同订单ID
    $saleslist = array();
    $backlist = array();//合同、退货产品结果集
    $salestotal = 0;
    $backtotal = 0;//合同金额、退货金额
    $query = 'select ifnull(haveoutproductcount,0) as haveoutproductcount,ld_salesorder.stockpresence from ld_salesorderdetail 
	LEFT JOIN ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id where id = ?;';
    $result = $adb->pquery($query, array($so_id));
    $errorMsg = '';
    echo '###SUCCESS###';
    for ($i = 0; $i < $adb->num_rows($result); $i++) {
        $stockpresence = $adb->query_result($result, $i, 'stockpresence');
        if ($adb->query_result($result, $i, 'haveoutproductcount') > 0.0001) {
            if($weixin_user->environment_weixin){
                ConvertTojsonString(1,array('string'=>'allow'),'success');
            }else{
                echo 'allow';
                exit();
            }
        }
    }
    if ($stockpresence == SALESORDERNOTOUTSTOCK){
        $errorMsg = 'no_outboundorder';
    }else if ($stockpresence == SALESORDERCREATETOUTSTOCK){
        $errorMsg = 'nocheck_outboundorder';
    } else{
        $errorMsg = 'all_outboundorder';
    }
    if($weixin_user->environment_weixin){
        $errorMsgLabel = array('no_outboundorder'=>'ORDEROUTNOALLOWRETURN',
            'nocheck_outboundorder'=>'OUTBOUNDCOUNTEQUALZERO',
            'all_outboundorder'=>'ORDERFULLYOUTNOALLOWRETURN'
        );
        ConvertTojsonString(-1,array(),getFixedLabel($errorMsgLabel[$errorMsg]));
    }else{
        echo $errorMsg;
        exit();
    }
}

if ($type == 'instock' || $type == 'cancelstock') {
    if ($type == 'instock') {
        $salesbackstatus = '已入库';
        $typename = '退货入库';
    } else {
        $salesbackstatus = '未入库';
        $typename = '撤销退货';
    }
    $deployarray = getSys_deploy(85);
    $deployvalue = $deployarray['deploy_value'];
    $sql = "select productid,quantity,parent_lineitem_id,entitytypeid,wareid,lineitem_id,batchtext from ld_salesback 
		inner join ld_salesbackdetail on id=salesbackid where salesbackid = ?";
    $results = $adb->pquery($sql, array($record));
    $num_rows = $adb->num_rows($results);

    if ($type == 'instock' && $deployvalue == 0) {
        //判断产品的数量是否大于该产品的已出库数量
        //回撤时不需要判断产品数量是否大于该产品的已出库数量

        for ($i = 0; $i < $num_rows; $i++) {
            $entitytypeid = $adb->query_result($results, $i, 'entitytypeid');
            $parent_lineitem_id = $adb->query_result($results, $i, 'parent_lineitem_id');
            if (!empty($entitytypeid)) {
                $query = 'select sum(ifnull(quantity,0)) as quantity from ld_outboundorderdetail 
                        INNER JOIN ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id 
					where entitytypeid = ? and parent_lineitem_id = ?';
                $result = $adb->pquery($query, array($entitytypeid, $parent_lineitem_id));
                $isOutnum = $adb->query_result($result, 0, 0);


                $query = 'select sum(ifnull(quantity,0)) as quantity from ld_salesbackdetail 
							INNER JOIN ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id 
							where entitytypeid = ? and parent_lineitem_id = ? and ld_salesback.salesbackstatus = \'已入库\';';
                $result = $adb->pquery($query, array($entitytypeid, $parent_lineitem_id));
                $isbacknum = $adb->query_result($result, 0, 0);
                if ($isbacknum >= $isOutnum) {
                    echo "###ERROR###2";
                    exit();
                }

            }
        }
    }

    //更改销售退货单的状态
    $update_query = "update ld_salesback set salesbackstatus= ? where salesbackid=?";
    $adb->pquery($update_query, array($salesbackstatus, $record));
    crm_load_function_file("insertCondtion", 'include/Stock', 'CommonStock');
    for ($i = 0; $i < $num_rows; $i++) {
        $productid = $adb->query_result($results, $i, 'productid');

        $qty = $adb->query_result($results, $i, 'quantity');
        $entitytypeid = $adb->query_result($results, $i, 'entitytypeid');
        $parent_lineitem_id = $adb->query_result($results, $i, 'parent_lineitem_id');
        $wareid = $adb->query_result($results, $i, 'wareid');
        $lineitem_id = $adb->query_result($results, $i, 'lineitem_id');
        $batchtext = $adb->query_result($results, $i, 'batchtext');
        insertCondtion($batchtext, $record, $typename, $wareid, $productid, $currentModule, $current_user->id, 0, 0, $parent_lineitem_id, $lineitem_id);


    }

    //反写合同订单已入库和未入库数量
    crm_load_class_file("cls_Source_InverseCompute", "include/OptionModule");
    cls_Source_InverseCompute::Source_InveverseCompute("SalesBack", $record);

} else if ($type == 'endstock') {
    $end = $_REQUEST['end'];
    if ($end == 'in') {
        $update_query = "update ld_salesback set salesbackstatus='结束' where salesbackid=?";
    } else {
        $update_query = "update ld_salesback set salesbackstatus='中止' where salesbackid=?";
    }
    $adb->pquery($update_query, array($record));
}
if ($_REQUEST['type'] == 'savecheck') {
    $deployarray = getSys_deploy(85);
    $deployvalue = $deployarray['deploy_value'];
    if ($deployvalue == 1) {
        echo "###SUCCESS###";
        exit();
    }
    if ($_REQUEST['salesbackid'] && $_REQUEST['salesbackid'] > 0) {
        $salesbackid = $_REQUEST['salesbackid'];
        $sql = 'select productid,quantity,listprice from ld_salesbackdetail
        inner join ld_salesback on ld_salesbackdetail.id = ld_salesback.salesbackid
        where ld_salesback.deleted = 0 and ld_salesback.salesbackid = ? group by productid ';
        $result = $adb->pquery($sql, array($salesbackid));
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $productid = $adb->query_result($result, $i, 'productid');
            $quantity = $adb->query_result($result, $i, 'quantity');
            $listprice = $adb->query_result($result, $i, 'listprice');
            $purchasecashbackoldQ[$productid] = $quantity;
            $purchasecashbackoldL[$productid] = $listprice;
        }
    } else
        $salesbackid = 0;
    //原单合同订单ID
    $record = $_REQUEST['record'];
    $sql = 'select productid,quantity,if(ld_salesorder.currency_id > 1,listprice/ld_salesorder.conversion_rate,listprice) as listprice
            ,lineitem_id,haveoutproductcount,balanceoutproductcount from ld_salesorderdetail
            inner join ld_salesorder on ld_salesorderdetail.id = ld_salesorder.salesorderid
            inner join ld_crmentity on ld_salesorder.salesorderid = ld_crmentity.crmid
            where ld_salesorder.deleted = 0 and ld_salesorder.salesorderid = ?';
    $result = $adb->pquery($sql, array($record));
    //echo $result->sql;echo '<br><br>';
    for ($i = 0; $i < $adb->num_rows($result); $i++) {
        $salesorderpro[$i] = array(
            'productid' => $adb->query_result($result, $i, 'productid'),
            'quantity' => $adb->query_result($result, $i, 'quantity'),
            'listprice' => $adb->query_result($result, $i, 'listprice'),
            'lineitem_id' => $adb->query_result($result, $i, 'lineitem_id'),
            'haveoutproductcount' => $adb->query_result($result, $i, 'haveoutproductcount'),
            'balanceoutproductcount' => $adb->query_result($result, $i, 'balanceoutproductcount'),
        );
    }
    //$_REQUEST['idstring']  产品ID+产品数量+产品金额+产品行原单ID
    $ispro = explode(',', $_REQUEST['idstring']);
    for ($i = 0; $i < count($salesorderpro); $i++) {
        for ($k = 0; $k < count($ispro); $k++) {
            $isPorduct = explode('-', $ispro[$k]);
            if ($_REQUEST['currency_id'] > 1) {
                $currencyobj = Currency::getInstance($adb, $_REQUEST['currency_id']);
                $currencyRate = $currencyobj->getCurrencyRate();

                $isPorduct[2] = $isPorduct[2] / $currencyRate;
            }
            if ($salesorderpro[$i]['lineitem_id'] == $isPorduct[3]) {
                //36935: 销售退货单编辑无法保存，提示:退货数量不能超过源单的已出库产品数量
                $isBack = selSalesBackQuantity($record, $isPorduct[3], $salesbackid); //获取当前单据当前产品的已退货数量
                if (empty($isBack)) $isBack = 0;
                $isBackTotal = selSalesBackTotal($record, $isPorduct[0]); //已退货金额
                $quantityOld = $purchasecashbackoldQ[$isPorduct[0]];
                $listpriceOld = $purchasecashbackoldL[$isPorduct[0]];
                //$isPorduct[1]:界面输入的退货数量
                //$salesorderpro[$i]['haveoutproductcount']:原单已出库数量
                //36935: 销售退货单编辑无法保存，提示:退货数量不能超过源单的已出库产品数量

                if ($isPorduct[1] > $salesorderpro[$i]['haveoutproductcount'] + $isBack) {
                    echo "###ERROR###2";
                    exit();
                }

                /*$isBackAllTotal = $isBackTotal+$isPorduct[2]*$isPorduct[1];
               $salesAllTotal = $salesorderpro[$i]['listprice']*$salesorderpro[$i]['haveoutproductcount'];
               if(intval($isBackAllTotal) > intval($salesAllTotal))
               {
                   echo "###ERROR###3";
                   exit();

               }*/

            }
        }
    }
    echo "###SUCCESS###";
    exit();
}
if ($_REQUEST['type'] == 'savecashcheck') {
    if ($_REQUEST['cashbackid'] && $_REQUEST['cashbackid'] > 0) {
        $cashbackidold = $_REQUEST['cashbackid'];
        $sql = 'select productid,quantity,listprice,total from ld_cashbackdetail
        inner join ld_cashback on ld_cashbackdetail.id = ld_cashback.cashbackid
        where ld_cashback.deleted = 0 and ld_cashback.cashbackid = ? group by productid ';
        $result = $adb->pquery($sql, array($cashbackidold));
        $numrows = $adb->num_rows($result);
        for ($i = 0; $i < $numrows; $i++) {
            $productid = $adb->query_result($result, $i, 'productid');
            $quantity = $adb->query_result($result, $i, 'quantity');
            $listprice = $adb->query_result($result, $i, 'listprice');
            $old_total = $adb->query_result($result, $i, 'total');
            $cashbackoldQ[$productid] = $quantity;
            $cashbackoldL[$productid] = $listprice;
        }
    }

    $record = $_REQUEST['record'];

    $sql = 'select productid,quantity,listprice,lineitem_id,haveoutproductcount,tax_amount from ld_salesbackdetail
inner join ld_salesback on ld_salesbackdetail.id = ld_salesback.salesbackid
inner join ld_crmentity on ld_salesback.salesbackid = ld_crmentity.crmid
where ld_salesback.deleted = 0 and ld_salesback.salesbackid = ?';
    $result = $adb->pquery($sql, array($record));
    for ($i = 0; $i < $adb->num_rows($result); $i++) {
        $purchasepro[$i] = array(
            'productid' => $adb->query_result($result, $i, 'productid'),
            'quantity' => $adb->query_result($result, $i, 'quantity'),
            'tax_amount' => $adb->query_result($result, $i, 'tax_amount'),
            'lineitem_id' => $adb->query_result($result, $i, 'lineitem_id'),
            'haveoutproductcount' => $adb->query_result($result, $i, 'haveoutproductcount'),
        );
    }
    $query = 'select total from ld_salesback where  salesbackid = ? and deleted = 0 limit 1';
    $result = $adb->pquery($query, array($record));
    $salesback_total = $adb->query_result($result, 0, 0);
    $ispro = explode(',', $_REQUEST['idstring']);

    for ($i = 0; $i < count($purchasepro); $i++) {
        for ($k = 0; $k < count($ispro); $k++) {
            $isPorduct = explode('-', $ispro[$k]);
            if ($purchasepro[$i]['lineitem_id'] == $isPorduct[3]) {
                $isBack = selCaseBackQuantity($record, $isPorduct[0]); //已退款数量
                $isBackTotal = selCaseBackTotal($record, $isPorduct[0]); //已退款金额

                if ($_REQUEST['cashbackid'] && $_REQUEST['cashbackid'] > 0 && $numrows > 0) {
                    $quantityOld = $cashbackoldQ[$isPorduct[0]];
                    $listpriceOld = $cashbackoldL[$isPorduct[0]];
                    if ($isBack + $isPorduct[1] - $quantityOld > $purchasepro[$i]['quantity']) {
                        echo "###ERROR###2";
                        exit();
                    }
                    $isPorductNew = $isPorduct[2];
                    $isPorductOld = $quantityOld * $listpriceOld;
                    $isPorductAll = $purchasepro[$i]['tax_amount'];
                    if ($isBackTotal + $isPorductNew - $old_total > $isPorductAll) {
                        echo "###ERROR###3";
                        exit();

                    }
                } else {
                    if ($isBack + $isPorduct[1] > $purchasepro[$i]['quantity']) {
                        echo "###ERROR###2";
                        exit();
                    }
                    if ($isBackTotal + $isPorduct[2] > $salesback_total) {
                        echo "###ERROR###3";
                        exit();

                    }
                }


            }
        }
    }
    echo "###SUCCESS###";
    exit();
}
/**
 * @edit:chj
 * @date:2014-10-14
 * @reason:获取退货单原单为该合同订单的当前产品的已退货数量
 * @description:
 */
function selSalesBackQuantity($salesorderid, $parent_lineitem_id, $salesbackid)
{
    global $adb;
    $sql = "select sum(ifnull(quantity,0)) as quantity from ld_salesbackdetail
    inner join ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id
    where ld_salesback.deleted = 0 and ld_salesbackdetail.entitytypeid = ? 
    and ld_salesbackdetail.parent_lineitem_id = ? and ld_salesback.salesbackstatus not in ('未入库','中止','结束')";
    //36935: 销售退货单编辑无法保存，提示:退货数量不能超过源单的已出库产品数量
    $sql .= " and ld_salesback.salesbackid = $salesbackid";


    $result = $adb->pquery($sql, array($salesorderid, $parent_lineitem_id));
    return $adb->query_result($result, 0, 0);
}

function selSalesBackTotal($salesorderid, $productid)
{
    global $adb;
    $sql = "select sum(ifnull(quantity,0))*sum(if(currency_id > 1,ifnull(listprice,0)/conversion_rate,ifnull(listprice,0))) as total from ld_salesbackdetail
    inner join ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id
    where ld_salesback.deleted = 0 and ld_salesback.salesorderid = ? and ld_salesbackdetail.productid = ? and ld_salesback.salesbackstatus not in ('未入库','中止','结束')";
    $result = $adb->pquery($sql, array($salesorderid, $productid));
    return $adb->query_result($result, 0, 0);
}

function selCaseBackQuantity($salesbackid, $productid)
{
    global $adb;
    $sql = "select ifnull(sum(quantity),0) as quantity from ld_cashbackdetail
    inner join ld_cashback on ld_cashback.cashbackid = ld_cashbackdetail.id
    where ld_cashback.deleted = 0 and ld_cashback.salesbackid = ? and ld_cashbackdetail.productid = ?";
    $result = $adb->pquery($sql, array($salesbackid, $productid));
    return $adb->query_result($result, 0, 0);
}

/**
 * @edit:chj
 * @date:2014-10-14
 * @reason:获取合同订单下该产品的未出库数量
 * @description:
 *
 * function getBalanceOutNum($entitytypeid,$parent_lineitem_id)
 * {
 * global $adb;
 * $query = "select ifnull(balanceoutproductcount,0) as balanceoutproductcount from
 * ld_salesorderdetail where id = ? and lineitem_id = ? limit 1";
 * $result = $adb->pquery($query,array($entitytypeid,$parent_lineitem_id));
 * return $adb->query_result($result,0,0);
 * } */
function selCaseBackTotal($salesbackid, $productid)
{
    global $adb;
    $sql = "select sum(ifnull(total,0)) as total from ld_cashbackdetail
    inner join ld_cashback on ld_cashback.cashbackid = ld_cashbackdetail.id
    where ld_cashback.deleted = 0 and ld_cashback.salesbackid = ? and ld_cashbackdetail.productid = ?";

    $result = $adb->pquery($sql, array($salesbackid, $productid));
    return $adb->query_result($result, 0, 0);
}

if ($_REQUEST['ajaxmode'] == 'cashbackcheck') {
    $pronum = 1;
    $sql = "SELECT productid,SUM(ifnull(quantity,0)) as quantity from ld_cashbackdetail where 
    id in (SELECT cashbackid from ld_cashback where salesbackid=" . $_REQUEST['salesback_id'] . " and ld_cashback.deleted = 0 ) 
    group by productid";
    $result = $adb->pquery($sql, array());
    $rowCounts = $adb->num_rows($result);
    for ($i = 0; $i < $rowCounts; $i++) {
        $product_list[$i][productid] = $adb->query_result($result, $i, 'productid');
        $product_list[$i][quantity] = $adb->query_result($result, $i, 'quantity');
    }
    $sql = "SELECT productid,SUM(ifnull(quantity,0)) as quantity from ld_salesbackdetail where id =" . $_REQUEST['salesback_id'] . " group by productid";
    $result = $adb->pquery($sql, array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $oproduct_list[$i][productid] = $adb->query_result($result, $i, 'productid');
        $oproduct_list[$i][quantity] = $adb->query_result($result, $i, 'quantity');
    }
    if (count($product_list)) {
        foreach ($product_list as $key => $arr) {
            foreach ($oproduct_list as $key2 => $arr2) {
                if ($arr[productid] == $arr2[productid]) {
                    if (($arr2[quantity] - $arr[quantity]) <= 0) {
                        $product_list[$key2][quantity] = 0;
                    } else {
                        $product_list[$key2][quantity] = $arr2[quantity] - $arr[quantity];
                        $pronum++;
                    }
                }
            }
        }
    }
    if ($rowCount > $rowCounts) {
        $pronum = 0;
    }
    if ($rowCounts == 0) {
        $pronum = 0;
    }
    echo "###SUCCESS### " . $pronum;
    exit();
}
echo '#####SUCCESS#####';


?>