<?php
//editor:gyq_86 reason:库存报表 2018/11/22 15:50
//库存流水账
class ReportSqlInventoryAccount
{
    public $cls_adb;

    //editor:gyq_86 reason:产品批次,库存流水账 2018/11/14 11:10
    // @edit:dong @date:2020/08/11 @reason:  库存台账、库存流水账、即时库存查询，显示列设置中没有失效日期字段  expiry_date
    public function InventoryAccount($r_startmouth, $r_endmouth, $r_cangku, $r_pici, $shenpi, $r_productname)
    {
        global $languageType, $adb, $current_user;
        $advsearch = '';
        crm_load_class_file('cls_QueryGenerator', 'modules/OftenUseReport');
        $queryGenerator = new cls_QueryGenerator($currentModule, $current_user, '');
        $queryGenerator->addUserSearchConditions($_REQUEST);
        $where = $queryGenerator->getWhereClause();
        if (!empty($where)) {
            if (strpos($where, 'bill_date') !== false) {

            } else {
                $r_startmouth = '1600-01-01';
                $r_endmouth = date('Y-m-d');
            }
            $advsearch = ' and ' . str_replace("%s", "b", $where);
        }
        $start_date = $r_startmouth;
        $end_date = $r_endmouth;
        if (empty($r_pici))
            $r_pici = '';
        if (empty($r_cangku))
            $r_cangku = 'all';
        if (empty($shenpi))
            $shenpi = 'all';

        // ljj 20231009 XUQIU1001975 库存报表->库存台账、库存流水账、即时库存查询
        //非管理员账号“仓库”查询条件下拉选项中增加显示“全部仓库”，可直接查询显示当前成员有权限查询的所有仓库的库存明细
        if ($r_cangku == 'all'){
            $wareArr=[];
            require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
            $wareArrresult = selWareAll();
            for ($i = 0; $i < $adb->num_rows($wareArrresult); $i++) {
                $wareArr[]=$adb->query_result($wareArrresult, $i, "id");
            }
            $arr=implode(',',$wareArr);
            $allsql=" IN ($arr) ";
        }else{
            $allsql=" ='$r_cangku' ";
        }

        //editor:gyq_140 reason:库存报表优化，增加显示库存数量为0的记录的条件和显示列产地  2019/8/30 11:17 
        $sql = "SELECT
  b.made_in,
  b.productdate,
  a.billtype,
  a.bill_id,
  a.bill_date,
  a.expiry_date,
  a.bill_no,
  d.`name` AS warhouse,
  a.batchtext,
  b.productname,
  b.productsheet,
  b.product_no,
  b.usageunit,
  a.productid,
  CASE
  WHEN '$languageType'='zh' THEN n.description
  ELSE m.currency_name
  END AS currency_name,
  a.income_price,
  a.income_qty,
  a.income_amount,
  a.sendout_price,
  a.sendout_qty,
  a.sendout_amount
FROM (
       SELECT
         'Stock' AS billtype,
         1 AS billseq,
         a.stock_id AS bill_id,
         a.createdate AS bill_date,
         a.ware_stock_no AS bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
         c.batchtext,
         c.taxprice AS income_price,
         c.quantity AS income_qty,
         c.tax_amount AS income_amount,
         0 AS sendout_price,
         0 AS sendout_qty,
         0 AS sendout_amount,
         c.sequence_no,
         f.expiry_date
       FROM ld_stock a
         LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
         LEFT JOIN ld_stockdetailscf f ON f.lineitem_id =c.lineitem_id
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
             AND a.wareid $allsql
       UNION
       SELECT
         'SalesBack',
         2,
         a.salesbackid AS bill_id,
         a.salesbackdate AS bill_date,
         a.salesback_no AS bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
         c.batchtext,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         0,
         0,
         0,
         c.sequence_no,
         f.expiry_date
       FROM ld_salesback a
         LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
         LEFT JOIN ld_salesbackdetailscf f ON f.lineitem_id =c.lineitem_id
       WHERE a.deleted=0
             AND a.salesbackstatus<>'中止'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.salesbackstatus IN ('结束','已入库')
               END)
             AND a.wareid $allsql
       UNION
       SELECT
         'OutboundOrder',
         3,
         a.out_id AS bill_id,
         a.outdate AS bill_date,
         a.out_no AS bill_no,
         c.wareid,
         a.currency_id,
         c.productid,
         c.batchtext,
         0,
         0,
         0,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         c.sequence_no,
         d.expiry_date
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
         LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
         LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
             AND c.wareid $allsql
       UNION
       SELECT
         'PurchaseBack' AS billtype,
         4,
         a.purchasebackid AS bill_id,
         a.purchasebackdate AS bill_date,
         a.purchaseback_no AS bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
         c.batchtext,
         0,
         0,
         0,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         c.sequence_no,
         f.expiry_date
       FROM ld_purchaseback a
         LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
         LEFT JOIN ld_purchasebackdetailscf f ON f.lineitem_id =c.lineitem_id
       WHERE a.deleted=0
             AND a.purchasebackstatus<>'中止'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.purchasebackstatus='已出库'
               END)
             AND a.wareid $allsql
       UNION
       SELECT
         'WareHouseTransfer',
         5,
         a.warehousetransferid,
         a.transferdate AS bill_date,
         a.transferdate_no as bill_no,
         a.inwarehouse,
         a.currency_id,
         c.productid,
         c.batchtext,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         0,
         0,
         0,
         c.sequence_no,
         f.expiry_date
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
       WHERE a.deleted=0
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.transferstatus='已审核'
               END)
             AND a.inwarehouse $allsql
       UNION
       SELECT
         'WareHouseTransfer',
         6,
         a.warehousetransferid,
         a.transferdate as bill_date,
         a.transferdate_no as bill_no,
         a.outwarehouse,
         a.currency_id,
         c.productid,
         c.batchtext,
         0,
         0,
         0,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         c.sequence_no,
         f.expiry_date
       FROM ld_warehousetransfer a
       LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
       LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
       WHERE a.deleted=0
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.transferstatus='已审核'
               END)
             AND a.outwarehouse $allsql
       UNION
       SELECT
         'Checks',
         7,
         a.id,
         a.checksdate as bill_date,
         a.checks_no as bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
         c.batchtext,
         0,
         CASE
            WHEN profitloss>0 THEN profitloss
            ELSE 0
         END,
         0,
         0,
         CASE
            WHEN profitloss<0 THEN 0-profitloss
            ELSE 0
         END,
         0,
         c.sequence_no,
         f.expiry_date
       FROM ld_checks a
       LEFT JOIN ld_checksdetail c ON c.id=a.id
       LEFT JOIN ld_checksdetailscf f ON f.lineitem_id =c.lineitem_id
       WHERE a.deleted=0
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$shenpi'='all' THEN 1=1
               ELSE a.presence='盘点结束'
               END)
             AND a.wareid $allsql
     ) a
  LEFT JOIN ld_products b ON b.productid=a.productid
  LEFT JOIN ld_warehouse d ON d.id=a.wareid
  LEFT JOIN ld_currency_info m ON m.id=a.currency_id
  LEFT JOIN ld_currencies n ON n.currency_name=m.currency_name
  left join ld_productcf pcf on pcf.productid=b.productid
  where (
         CASE
         WHEN '$r_productname'='' THEN 1=1
         ELSE LOCATE('$r_productname',b.productname)>0
         END) $advsearch ";

        //editor:gyq_122 reason:增加left join ld_productcf pcf on pcf.productid=b.productid  2019/6/14 11:29
        if (!empty($start_date) && !empty($end_date)) {
            $sql .= " AND bill_date BETWEEN '$start_date' AND '$end_date' ";
        }
        $sql .= " ORDER BY a.bill_date,a.billseq,a.bill_id,a.sequence_no";

        return $sql;

    }
}