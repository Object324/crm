<?php
//editor:gyq_86 reason:库存报表 2018/11/22 15:50
//库存台账
class ReportSqlInventoryLedger
{
    public $cls_adb;
    public  function getInventoryLedgerFirst($r_startmouth,$r_endmouth,$r_cangku,$r_pici,$r_productname,$r_shenpi){
        //第一段，首先查询期间内有没有出、入库、盘点、调拨、退货、库存初始化等业务
        global $languageType,$adb;
		$advsearch = '';
		crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
		$queryGenerator = new cls_QueryGenerator($currentModule, $current_user,'');
		$queryGenerator->addUserSearchConditions($_REQUEST);
		$where = $queryGenerator->getWhere('InventoryLedger');
		if(!empty($where)){
			if(strpos($where,'bill_date') !== false){ 
				
			}else{
				$r_startmouth = '1600-01-01';
				$r_endmouth = date('Y-m-d');
			}
			$advsearch = ' and ' . str_replace("%s","b",$where);
		}
        if(empty($r_shenpi))
            $r_shenpi = 'all';
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

		//editor:gyq_20190528 reason:去除ld_inventoryproductrel 0037175
        //0037175: （http://xiaoshou360.com/KH/churun [^]）常用报表>库存台账>查找日期调制为【2018-5-28-2019-5-28】>审批状态为全部：查找不出任何数据。
        //editor:gyq_140 reason:库存报表优化，增加显示库存数量为0的记录的条件和显示列产地,made_in/productdate  2019/8/30 11:17
        $sql = "SELECT
  a.productid,ld_products.productname,ld_products.usageunit,ld_products.product_no,ld_products.made_in,
  ld_products.productdate
FROM (
       SELECT
         'Prdtnums' AS billtype,
         0 AS billseq,
         a.id AS bill_id,
         DATE_FORMAT(a.operationtime,'%Y-%m-%d') AS bill_date,
         a.id AS bill_no,
         a.warehouseid AS wareid,
         1 AS currency_id,
         a.productid,
		 c.productname,
         IFNULL(a.batchtext,'') AS batchtext,
         GREATEST(IFNULL(c.unit_price,0),IFNULL(c.costprice,0)) AS income_price,
         a.lastqty AS income_qty,
         GREATEST(IFNULL(c.unit_price,0),IFNULL(c.costprice,0))*a.lastqty AS income_amount,
         0 AS sendout_price,
         0 AS sendout_qty,
         0 AS sendout_amount,
         1 AS sequence_no
       FROM ld_warehousecondtions a
       LEFT JOIN ld_products c ON c.productid=a.productid
       WHERE a.modulename='库存初始化'
             AND a.type='确认初始库存'
             AND IFNULL(a.lastqty,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',c.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',a.batchtext)>0
               END)
             AND a.warehouseid $allsql
       UNION ALL
       SELECT
         'Stock' AS billtype,
         1 AS billseq,
         a.stock_id AS bill_id,
         a.createdate AS bill_date,
         a.ware_stock_no AS bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         c.taxprice AS income_price,
         c.quantity AS income_qty,
         c.tax_amount AS income_amount,
         0 AS sendout_price,
         0 AS sendout_qty,
         0 AS sendout_amount,
         c.sequence_no
       FROM ld_stock a
       LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
       LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND IFNULL(c.quantity,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         'SalesBack',
         2,
         a.salesbackid AS bill_id,
         a.salesbackdate AS bill_date,
         a.salesback_no AS bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         0,
         0,
         0,
         c.sequence_no
       FROM ld_salesback a
         LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.salesbackstatus<>'中止'
             AND IFNULL(c.quantity,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.salesbackstatus IN ('结束','已入库')
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         'OutboundOrder',
         3,
         a.out_id AS bill_id,
         a.outdate AS bill_date,
         a.out_no AS bill_no,
         c.wareid,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         0,
         0,
         0,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         c.sequence_no
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
          LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
          LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND IFNULL(c.quantity,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
             AND c.wareid $allsql
       UNION ALL
       SELECT
         'PurchaseBack' AS billtype,
         4,
         a.purchasebackid AS bill_id,
         a.purchasebackdate AS bill_date,
         a.purchaseback_no AS bill_no,
         a.wareid,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         0,
         0,
         0,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         c.sequence_no
       FROM ld_purchaseback a
        LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.purchasebackstatus<>'中止'
             AND IFNULL(c.quantity,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.purchasebackstatus='已出库'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         'WareHouseTransfer',
         5,
         a.warehousetransferid,
         a.transferdate,
         a.transferdate_no,
         a.inwarehouse,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         0,
         0,
         0,
         c.sequence_no
       FROM ld_warehousetransfer a
      LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
       LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND IFNULL(c.quantity,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.transferstatus='已审核'
               END)
             AND a.inwarehouse $allsql
       UNION ALL
       SELECT
         'WareHouseTransfer',
         6,
         a.warehousetransferid,
         a.transferdate,
         a.transferdate_no,
         a.outwarehouse,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         0,
         0,
         0,
         c.taxprice,
         c.quantity,
         c.tax_amount,
         c.sequence_no
       FROM ld_warehousetransfer a
       LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
       LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND IFNULL(c.quantity,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.transferstatus='已审核'
               END)
             AND a.outwarehouse $allsql
       UNION ALL
       SELECT
         'Checks',
         7,
         a.id,
         a.checksdate,
         a.checks_no,
         a.wareid,
         a.currency_id,
         c.productid,
		 p.productname,
         IFNULL(c.batchtext,'') AS batchtext,
         0,
         CASE
            WHEN c.profitloss>0 THEN c.profitloss
            ELSE 0
         END,
         0,
         0,
         CASE
            WHEN c.profitloss<0 THEN ABS(c.profitloss)
            ELSE 0
         END,
         0,
         c.sequence_no
       FROM ld_checks a
         LEFT JOIN ld_checksdetail c ON c.id=a.id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND IFNULL(c.profitloss,0)<>0
             AND (
               CASE
               WHEN '$r_productname'='' THEN 1=1
               ELSE LOCATE('$r_productname',p.productname)>0
               END)
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.presence='盘点结束'
               END)
             AND a.wareid $allsql
     ) a left join ld_products on ld_products.productid=a.productid 
       left join ld_productcf on ld_products.productid = ld_productcf.productid
       where 1=1 $advsearch ";
    //editor:gyq_122 reason:增加left join ld_productcf on ld_products.produ...  2019/6/14 14:16
	if(!empty($r_startmouth) && !empty($r_endmouth)){
		$sql .= " and a.bill_date BETWEEN '$r_startmouth' AND '$r_endmouth' ";
	}
	$sql .=" GROUP BY a.productid ORDER BY a.bill_date";
        //echo $sql;
		//die;
        return $sql;
    }
    public function getInventoryLedgerSecond($r_startmouth,$r_endmouth,$r_cangku,$r_pici,$r_productid,$r_shenpi){
        global $languageType,$adb;
        $sql_i = 0;
        if(empty($r_shenpi))
            $r_shenpi = 'all';
        $sSQL1="drop TEMPORARY  table if exists mytemptable1;";
        $sSQL2="drop TEMPORARY  table if exists mytemptable2;";
        $sSQL3="drop TEMPORARY  table if exists mytemptable3;";
        $sSQL4="drop TEMPORARY  table if exists mytemptable4;";
        $sSQL5="drop TEMPORARY  table if exists mytemptable5;";
        $adb->query($sSQL1);
        $adb->query($sSQL2);
        $adb->query($sSQL3);
        $adb->query($sSQL4);
        $adb->query($sSQL5);

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

        //第二段，过下面的SQL先判断产品期初库存是否有数据
        $product_sql = "SELECT
  'Initialdeposit' AS billtype,
  a.productid,
  IFNULL(a.batchtext,'') AS batchtext,
  SUM(inventoryqty) AS inventoryqty
FROM (
       SELECT
         a.warehouseid,
         a.productid,
         a.batchtext,
         a.lastqty AS inventoryqty
       FROM ld_warehousecondtions a
       LEFT JOIN ld_products c ON c.productid=a.productid
       WHERE a.modulename='库存初始化'
             AND a.type='确认初始库存'
             AND DATE_FORMAT(a.operationtime,'%Y-%m-%d')<'$r_startmouth'
             AND a.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',a.batchtext)>0
               END)
             AND a.warehouseid $allsql
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.quantity AS inventoryqty
       FROM ld_stock a
       LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND a.createdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.quantity AS inventoryqty
       FROM ld_salesback a
         LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
       WHERE a.deleted=0
             AND a.salesbackstatus<>'中止'
             AND a.salesbackdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.salesbackstatus IN ('结束','已入库')
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         c.wareid,
         c.productid,
         c.batchtext,
         0-c.quantity AS inventoryqty
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
         LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
         LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND a.outdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
             AND c.wareid $allsql
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         0-c.quantity AS inventoryqty
       FROM ld_purchaseback a
         LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
       WHERE a.deleted=0
             AND a.purchasebackstatus<>'中止'
             AND a.purchasebackdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.purchasebackstatus='已出库'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         a.inwarehouse,
         c.productid,
         c.batchtext,
         c.quantity AS inventoryqty
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
       WHERE a.deleted=0
             AND a.transferdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.transferstatus='已审核'
               END)
             AND a.inwarehouse $allsql
       UNION ALL
       SELECT
         a.outwarehouse,
         c.productid,
         c.batchtext,
         0-IFNULL(c.quantity,0) AS inventoryqty
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
       WHERE a.deleted=0
             AND a.transferdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.transferstatus='已审核'
               END)
             AND a.outwarehouse $allsql
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.profitloss AS inventoryqty
       FROM ld_checks a
       LEFT JOIN ld_checksdetail c ON c.id=a.id
       WHERE a.deleted=0
             AND a.checksdate<'$r_startmouth'
             AND c.productid='$r_productid'
             AND (
               CASE
               WHEN '$r_pici'='' THEN 1=1
               ELSE LOCATE('$r_pici',c.batchtext)>0
               END)
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.presence='盘点结束'
               END)
             AND a.wareid $allsql
     ) a
GROUP BY a.productid,IFNULL(a.batchtext,'')
ORDER BY a.batchtext";

        //echo $product_sql;die;

        /*有数据*/
        $youdata_sql = "CREATE TEMPORARY TABLE IF NOT EXISTS mytemptable1 (
  SELECT
    (@i:=@i+1) AS sequence,
    t.*
  FROM (
         (SELECT
            0 AS typeseq,
            100 AS billseq,
            DATE_FORMAT('$r_startmouth','%Y-%m-%d') AS bill_date,
            CASE
            WHEN '$languageType'='zh' THEN '期初结存'
            ELSE 'Initialdeposit'
            END AS billtype_label,
            p.product_no,
            p.productname,
            p.productsheet,
            p.usageunit,
            IFNULL(a.batchtext,'') AS batchtext,
            IFNULL(MAX(a.expiry_date),'') AS expiry_date,
            0 as wareid,
            '' AS bill_no,
            0 AS bill_id,
            '' AS billtype,
            0 AS income_price,
            SUM(inventoryqty) AS income_qty,
            0 AS income_amount,
            0 AS sendout_price,
            0 AS sendout_qty,
            0 AS sendout_amount,
            GREATEST(IFNULL(p.unit_price,0),IFNULL(p.costprice,0)) AS balance_price,
            SUM(inventoryqty) AS balance_qty,
            GREATEST(IFNULL(p.unit_price,0),IFNULL(p.costprice,0))*SUM(inventoryqty) AS balance_amount,
			DATE_FORMAT('$r_startmouth','%Y-%m-%d %H:%i:%s') AS createdtime
          FROM (
                 SELECT
                   a.warehouseid as wareid,
                   a.productid,
                   a.batchtext,
                   a.lastqty AS inventoryqty,
                   '' AS expiry_date
                 FROM ld_warehousecondtions a
                   LEFT JOIN ld_products c ON c.productid=a.productid
                 WHERE a.modulename='库存初始化'
                       AND a.type='确认初始库存'
                       AND DATE_FORMAT(a.operationtime,'%Y-%m-%d')<'$r_startmouth'
                       AND a.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',a.batchtext)>0
                         END)
                       AND a.warehouseid $allsql
                 UNION ALL
                 SELECT
                   a.wareid,
                   c.productid,
                   c.batchtext,
                   c.quantity AS inventoryqty,
                   f.expiry_date
                 FROM ld_stock a
                   LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
                   LEFT JOIN ld_stockdetailscf f ON f.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.approvestatus<>'已拒绝'
                       AND a.createdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.approvestatus='已批准'
                         END)
                       AND a.wareid $allsql
                 UNION ALL
                 SELECT
                   a.wareid,
                   c.productid,
                   c.batchtext,
                   c.quantity AS inventoryqty,
                   f.expiry_date
                 FROM ld_salesback a
                   LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
                   LEFT JOIN ld_salesbackdetailscf f ON f.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.salesbackstatus<>'中止'
                       AND a.salesbackdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.salesbackstatus IN ('结束','已入库')
                         END)
                       AND a.wareid $allsql
                 UNION ALL
                 SELECT
                   c.wareid,
                   c.productid,
                   c.batchtext,
                   0-c.quantity AS inventoryqty,
                   d.expiry_date
                 FROM ld_outboundorder a
                   LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
                   LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
                   LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.approvestatus<>'已拒绝'
                       AND a.outdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.approvestatus='已批准'
                         END)
                       AND c.wareid $allsql
                 UNION ALL
                 SELECT
                   a.wareid,
                   c.productid,
                   c.batchtext,
                   0-c.quantity AS inventoryqty,
                   f.expiry_date
                 FROM ld_purchaseback a
                   LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
                   LEFT JOIN ld_purchasebackdetailscf f ON f.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.purchasebackstatus<>'中止'
                       AND a.purchasebackdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.purchasebackstatus='已出库'
                         END)
                       AND a.wareid $allsql
                 UNION ALL
                 SELECT
                   a.inwarehouse,
                   c.productid,
                   c.batchtext,
                   c.quantity AS inventoryqty,
                   f.expiry_date
                 FROM ld_warehousetransfer a
                   LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                   LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.transferdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.transferstatus='已审核'
                         END)
                       AND a.inwarehouse $allsql
                 UNION ALL
                 SELECT
                   a.outwarehouse,
                   c.productid,
                   c.batchtext,
                   0-IFNULL(c.quantity,0) AS inventoryqty,
                   f.expiry_date
                 FROM ld_warehousetransfer a
                   LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                   LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.transferdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.transferstatus='已审核'
                         END)
                       AND a.outwarehouse $allsql
                 UNION ALL
                 SELECT
                   a.wareid,
                   c.productid,
                   c.batchtext,
                   c.profitloss AS inventoryqty,
                   f.expiry_date
                 FROM ld_checks a
                   LEFT JOIN ld_checksdetail c ON c.id=a.id
                   LEFT JOIN ld_checksdetailscf f ON f.lineitem_id=c.lineitem_id
                 WHERE a.deleted=0
                       AND a.checksdate<'$r_startmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.presence='盘点结束'
                         END)
                       AND a.wareid $allsql
               ) a
            LEFT JOIN ld_products p ON p.productid=a.productid
          GROUP BY a.productid,IFNULL(a.batchtext,''))
         UNION ALL
         (SELECT
            1 AS type_seq,
            a.billseq,
            a.bill_date,
            b.fieldlabel AS billtype_label,
            p.product_no,
            p.productname,
            p.productsheet,
            p.usageunit,
            a.batchtext,
            IFNULL(a.expiry_date,'') AS expiry_date,
            a.wareid,
            a.bill_no,
            a.bill_id,
            a.billtype,
            a.income_price,
            a.income_qty,
            a.income_amount,
            a.sendout_price,
            a.sendout_qty,
            a.sendout_amount,
            GREATEST(IFNULL(p.unit_price,0),IFNULL(p.costprice,0)) AS balance_price,
            0 AS balance_qty,
            GREATEST(IFNULL(p.unit_price,0),IFNULL(p.costprice,0))*0 AS balance_amount,
			a.createdtime
          FROM (
                 SELECT
                   'Prdtnums' AS billtype,
                   0 AS billseq,
                   a.id AS bill_id,
                   date_format(a.operationtime, '%Y-%m-%d') AS bill_date,
                   a.id AS bill_no,
                   a.warehouseid AS wareid,
                   1 AS currency_id,
                   a.productid,
                   a.batchtext,
                   GREATEST(IFNULL(c.unit_price,0),IFNULL(c.costprice,0)) AS income_price,
                   a.lastqty AS income_qty,
                   GREATEST(IFNULL(c.unit_price,0),IFNULL(c.costprice,0))*a.lastqty AS income_amount,
                   0 AS sendout_price,
                   0 AS sendout_qty,
                   0 AS sendout_amount,
                   1 AS sequence_no,
				   a.operationtime AS createdtime,
				    '' as expiry_date
                 FROM ld_warehousecondtions a
                 LEFT JOIN ld_products c ON c.productid=a.productid
                 WHERE a.modulename='库存初始化'
                       AND a.type='确认初始库存'
                       AND IFNULL(a.lastqty,0)<>0
                       AND DATE_FORMAT(a.operationtime,'%Y-%m-%d') BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND a.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',a.batchtext)>0
                         END)
                       AND a.warehouseid $allsql
                 UNION ALL
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_stock a
                   LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
                   LEFT JOIN ld_stockdetailscf f ON f.lineitem_id=c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.approvestatus<>'已拒绝'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.createdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.approvestatus='已批准'
                         END)
                       AND a.wareid $allsql
                 UNION ALL
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_salesback a
                 LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
                 LEFT JOIN ld_salesbackdetailscf f ON f.lineitem_id=c.lineitem_id
                 LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.salesbackstatus<>'中止'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.salesbackdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.salesbackstatus IN ('结束','已入库')
                         END)
                       AND a.wareid $allsql
                 UNION ALL
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
				   a.createdtime,
				   d.expiry_date
                 FROM ld_outboundorder a
                 LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
                 LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
                 LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
                 LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.approvestatus<>'已拒绝'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.outdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.approvestatus='已批准'
                         END)
                       AND c.wareid $allsql
                 UNION ALL
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_purchaseback a
                 LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
                 LEFT JOIN ld_purchasebackdetailscf f ON f.lineitem_id=c.lineitem_id
                 LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.purchasebackstatus<>'中止'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.purchasebackdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.purchasebackstatus='已出库'
                         END)
                       AND a.wareid $allsql
                 UNION ALL
                 SELECT
                   'WareHouseTransfer',
                   5,
                   a.warehousetransferid,
                   a.transferdate,
                   a.transferdate_no,
                   a.inwarehouse as wareid,
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_warehousetransfer a
                   LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                   LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id=c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND IFNULL(c.quantity,0)<>0
                       AND a.transferdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.transferstatus='已审核'
                         END)
                       AND a.inwarehouse $allsql
                 UNION ALL
                 SELECT
                   'WareHouseTransfer',
                   6,
                   a.warehousetransferid,
                   a.transferdate,
                   a.transferdate_no,
                   a.outwarehouse as wareid,
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_warehousetransfer a
                   LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                   LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id=c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND IFNULL(c.quantity,0)<>0
                       AND a.transferdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.transferstatus='已审核'
                         END)
                       AND a.outwarehouse $allsql
                 UNION ALL
                 SELECT
                   'Checks',
                    CASE
                        WHEN c.profitloss>0 THEN 7
                        ELSE 8
                    END,
                   a.id,
                   a.checksdate,
                   a.checks_no,
                   a.wareid,
                   a.currency_id,
                   c.productid,
                   c.batchtext,
                   0,
                   CASE
                    WHEN c.profitloss>0 THEN c.profitloss
                    ELSE 0
                   END,
                   0,
                   0,
                   CASE
					WHEN c.profitloss<0 THEN ABS(c.profitloss)
					ELSE 0
                   END,
                   0,
                   c.sequence_no,
				   a.createdtime,
				   f.expiry_date
                 FROM ld_checks a
                 LEFT JOIN ld_checksdetail c ON c.id=a.id
                 LEFT JOIN ld_checksdetailscf f ON f.lineitem_id=c.lineitem_id
                 LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND IFNULL(c.profitloss,0)<>0
                       AND a.checksdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.presence='盘点结束'
                         END)
                       AND a.wareid $allsql
               ) a
            LEFT JOIN ld_products p ON p.productid=a.productid
            LEFT JOIN (
                        SELECT
                          a.name AS tabname,
                          b.fieldlabel
                        FROM ld_tab a
                          LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab'
                        WHERE 1=1
                              AND a.name IN ('Prdtnums','OutboundOrder','Stock','WareHouseTransfer','Checks','SalesBack','PurchaseBack')
                              AND (
                                CASE
                                WHEN '$languageType'='en' THEN b.languagetype='en'
                                ELSE b.languagetype='zh'
                                END)
                        GROUP BY a.tabid
                      ) b ON b.tabname=a.billtype)
       ) t
  ORDER BY t.typeseq,t.bill_date,t.createdtime,t.billseq,t.batchtext
)";
//echo $youdata_sql;echo '<br><br>';die;
        $wudata_sql = "CREATE TEMPORARY  TABLE IF NOT EXISTS mytemptable1 (
  SELECT
    (@i:=@i+1) AS sequence,
    t.*
  FROM (
         (SELECT
            0 AS typeseq,
            100 AS billseq,
            DATE_FORMAT('$r_startmouth','%Y-%m-%d') AS bill_date,
            CASE
            WHEN '$languageType'='zh' THEN '期初结存'
            ELSE 'Initialdeposit'
            END AS billtype_label, 
            (SELECT product_no FROM ld_products WHERE productid='$r_productid') AS product_no,
            (SELECT productname FROM ld_products WHERE productid='$r_productid') AS productname,
            (SELECT productsheet FROM ld_products WHERE productid='$r_productid') AS productsheet,
            (SELECT usageunit FROM ld_products WHERE productid='$r_productid') AS usageunit,
            NULL AS batchtext,
            NULL AS expiry_date,
            0 AS wareid,
            '' AS bill_no,
            0 AS bill_id,
            '' AS billtype,
            0 AS income_price,
            0 AS income_qty,
            0 AS income_amount,
            0 AS sendout_price,
            0 AS sendout_qty,
            0 AS sendout_amount,
            0 AS balance_price,
            0 AS balance_qty,
            0 AS balance_amount,
			DATE_FORMAT('$r_startmouth','%Y-%m-%d %H:%i:%s') AS createdtime)
         UNION ALL
         (SELECT
            1 AS type_seq,
            a.billseq,
            a.bill_date,
            b.fieldlabel AS billtype_label,
            p.product_no,
            p.productname,
            p.productsheet,
            p.usageunit,
            a.batchtext,
            a.expiry_date,
            a.wareid,
            a.bill_no,
            a.bill_id,
            a.billtype,
            a.income_price,
            a.income_qty,
            a.income_amount,
            a.sendout_price,
            a.sendout_qty,
            a.sendout_amount,
            GREATEST(IFNULL(p.unit_price,0),IFNULL(p.costprice,0)) AS balance_price,
            0 AS balance_qty,
            GREATEST(IFNULL(p.unit_price,0),IFNULL(p.costprice,0))*0 AS balance_amount,
			a.createdtime
          FROM (
                 SELECT
                   'Prdtnums' AS billtype,
                   0 AS billseq,
                   a.id AS bill_id,
                   date_format(a.operationtime, '%Y-%m-%d') AS bill_date,
                   a.id AS bill_no,
                   a.warehouseid AS wareid,
                   1 AS currency_id,
                   a.productid,
                   a.batchtext,
                   GREATEST(IFNULL(c.unit_price,0),IFNULL(c.costprice,0)) AS income_price,
                   a.lastqty AS income_qty,
                   GREATEST(IFNULL(c.unit_price,0),IFNULL(c.costprice,0))*a.lastqty AS income_amount,
                   0 AS sendout_price,
                   0 AS sendout_qty,
                   0 AS sendout_amount,
                   1 AS sequence_no,
				   a.operationtime AS createdtime,
				   '' as expiry_date
                 FROM ld_warehousecondtions a
                   LEFT JOIN ld_products c ON c.productid=a.productid
                 WHERE a.modulename='库存初始化'
                       AND a.type='确认初始库存'
                       AND IFNULL(a.lastqty ,0)<>0
                       AND DATE_FORMAT(a.operationtime,'%Y-%m-%d') BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND a.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',a.batchtext)>0
                         END)
                       AND a.warehouseid $allsql
                 UNION ALL
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_stock a
                   LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
                   LEFT JOIN ld_stockdetailscf f ON f.lineitem_id =c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.approvestatus<>'已拒绝'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.createdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.approvestatus='已批准'
                         END)
                       AND a.wareid $allsql
                 UNION ALL
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_salesback a
                   LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
                   LEFT JOIN ld_salesbackdetailscf f ON f.lineitem_id =c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.salesbackstatus<>'中止'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.salesbackdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.salesbackstatus IN ('结束','已入库')
                         END)
                       AND a.wareid $allsql
                 UNION ALL
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
				   a.createdtime,
				   d.expiry_date
                 FROM ld_outboundorder a
                   LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
                   LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
                   LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.approvestatus<>'已拒绝'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.outdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.approvestatus='已批准'
                         END)
                       AND c.wareid $allsql
                 UNION ALL
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_purchaseback a
                   LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
                   LEFT JOIN ld_purchasebackdetailscf f ON f.lineitem_id =c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND a.purchasebackstatus<>'中止'
                       AND IFNULL(c.quantity,0)<>0
                       AND a.purchasebackdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.purchasebackstatus='已出库'
                         END)
                       AND a.wareid $allsql
                 UNION ALL
                 SELECT
                   'WareHouseTransfer',
                   5,
                   a.warehousetransferid,
                   a.transferdate,
                   a.transferdate_no,
                   a.inwarehouse as wareid,
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_warehousetransfer a
                   LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                   LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND IFNULL(c.quantity,0)<>0
                       AND a.transferdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.transferstatus='已审核'
                         END)
                       AND a.inwarehouse $allsql
                 UNION ALL
                 SELECT
                   'WareHouseTransfer',
                   6,
                   a.warehousetransferid,
                   a.transferdate,
                   a.transferdate_no,
                   a.outwarehouse as wareid,
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
				   a.createdtime,
				   f.expiry_date
                 FROM ld_warehousetransfer a
                   LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                   LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND IFNULL(c.quantity,0)<>0
                       AND a.transferdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.transferstatus='已审核'
                         END)
                       AND a.outwarehouse $allsql
                 UNION ALL
                 SELECT
                   'Checks',
                    CASE
                   WHEN c.profitloss>0 THEN 7
                   ELSE 8
                   END,
                   a.id,
                   a.checksdate,
                   a.checks_no,
                   a.wareid,
                   a.currency_id,
                   c.productid,
                   c.batchtext,
                   0,
                   CASE
                    WHEN c.profitloss>0 THEN c.profitloss
                    ELSE 0
                   END,
                   0,
                   0,
                   CASE
                    WHEN c.profitloss<0 THEN ABS(c.profitloss)
                    ELSE 0
                   END,
                   0,
                   c.sequence_no,
				   a.createdtime,
				   f.expiry_date
                 FROM ld_checks a
                   LEFT JOIN ld_checksdetail c ON c.id=a.id
                   LEFT JOIN ld_checksdetailscf f ON f.lineitem_id =c.lineitem_id
                   LEFT JOIN ld_products p ON p.productid=c.productid
                 WHERE a.deleted=0
                       AND IFNULL(c.profitloss,0)<>0
                       AND a.checksdate BETWEEN '$r_startmouth' AND '$r_endmouth'
                       AND c.productid='$r_productid'
                       AND (
                         CASE
                         WHEN '$r_pici'='' THEN 1=1
                         ELSE LOCATE('$r_pici',c.batchtext)>0
                         END)
                       AND (
                         CASE
                         WHEN '$r_shenpi'='all' THEN 1=1
                         ELSE a.presence='盘点结束'
                         END)
                       AND a.wareid $allsql
               ) a
            LEFT JOIN ld_products p ON p.productid=a.productid
            LEFT JOIN (
                        SELECT
                          a.name AS tabname,
                          b.fieldlabel
                        FROM ld_tab a
                          LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab'
                        WHERE 1=1
                              AND a.name IN ('Prdtnums','OutboundOrder','Stock','WareHouseTransfer','Checks','SalesBack','PurchaseBack')
                              AND (
                                CASE
                                WHEN '$languageType'='en' THEN b.languagetype='en'
                                ELSE b.languagetype='zh'
                                END)
                        GROUP BY a.tabid
                      ) b ON b.tabname=a.billtype)
       ) t
  ORDER BY t.typeseq,t.bill_date,t.createdtime,t.billseq,t.batchtext
)";
        $final_sql = "SELECT
          a.productname,
          a.typeseq,
          a.billseq,
          a.bill_date,
          a.billtype,
          a.billtype_label,
          a.product_no,
          a.productsheet,
          a.usageunit,
          a.batchtext,
          a.expiry_date,
          a.wareid,
          a.bill_no,
          a.bill_id,
          a.income_price,
		  
		  CASE 
			WHEN a.typeseq=0 THEN 0
			ELSE a.income_qty
		  END AS income_qty,
          a.income_amount,
		  
          a.sendout_price,
          a.sendout_qty,
          a.sendout_amount,
		  
          a.balance_price,
          CASE
			WHEN a.typeseq=0 THEN a.balance_qty
			ELSE (SELECT SUM(IFNULL(income_qty,0)-IFNULL(sendout_qty,0)) FROM mytemptable2 WHERE sequence<=a.sequence AND IFNULL(batchtext,'')=IFNULL(a.batchtext,''))
          END AS balance_qty,
          CASE
          WHEN a.typeseq=0 THEN a.balance_price*a.balance_qty
          ELSE a.balance_price*(SELECT SUM(IFNULL(income_qty,0)-IFNULL(sendout_qty,0)) FROM mytemptable3 WHERE sequence<=a.sequence AND IFNULL(batchtext,'')=IFNULL(a.batchtext,''))
          END AS balance_amount
        FROM mytemptable1 a
        UNION ALL
        (SELECT
        	a.productname,
        	3 AS typeseq,
        	101 AS billseq,
        	'' AS bill_date,
        	'' AS billtype,
        	'".getFixedLabel('TOTAL')."' AS billtype_label,
        	'' AS product_no,
        	'' AS productsheet,
        	'' AS usageunit,
        	'' AS batchtext,
        	'' AS expiry_date,
        	0 AS wareid,
        	'' AS bill_no,
        	'' AS bill_id,
			
            SUM(CASE WHEN a.typeseq=0 THEN 0 ELSE a.income_qty END)/SUM(a.income_qty) AS income_price,
            SUM(CASE WHEN a.typeseq=0 THEN 0 ELSE a.income_qty END) AS income_qty,
            SUM(a.income_amount) AS income_amount,
			
            SUM(a.sendout_amount)/SUM(a.sendout_qty) AS sendout_price,
        	SUM(a.sendout_qty) AS sendout_qty,
            SUM(a.sendout_amount) AS sendout_amount,
			
            MAX(a.balance_price) AS balance_price,
            SUM(a.income_qty)-SUM(a.sendout_qty) AS balance_qty,
            MAX(a.balance_price)*(SUM(a.income_qty)-SUM(a.sendout_qty)) AS balance_amount
        FROM mytemptable4 a)
        UNION ALL
        (
        SELECT
            *
        FROM (
            SELECT
            	a.productname,
            	4 AS typeseq,
            	102 AS billseq,
            	'' AS bill_date,
            	'' AS billtype,
            	'".getFixedLabel('ENDINGBALANCE')."' AS  billtype_label,
            	'' AS product_no,
            	'' AS productsheet,
            	'' AS usageunit,
            	a.batchtext,
            	'' AS expiry_date,
            	0 as wareid,
            	'' AS bill_no,
            	'' AS bill_id,
				
                SUM(CASE WHEN a.typeseq=0 THEN 0 ELSE a.income_qty END)/SUM(a.income_qty) AS income_price,
                SUM(CASE WHEN a.typeseq=0 THEN 0 ELSE a.income_qty END) AS income_qty,
                SUM(a.income_amount) AS income_amount,
				
                SUM(a.sendout_amount)/SUM(a.sendout_qty) AS sendout_price,
            	SUM(a.sendout_qty) AS sendout_qty,
                SUM(a.sendout_amount) AS sendout_amount,
				
                MAX(a.balance_price) AS balance_price,
                SUM(a.income_qty)-SUM(a.sendout_qty) AS balance_qty,
                MAX(a.balance_price)*(SUM(a.income_qty)-SUM(a.sendout_qty)) AS balance_amount
             FROM mytemptable5 a
             GROUP BY IFNULL(a.batchtext,'')
        ) a
        ORDER BY batchtext)";
        //editor:gyq_122 reason:三个库存报表增加'仓库'列,以及增加'高级查找'范围  2019/6/14 16:00
        // @edit:dong @date:2020/08/11 @reason: bug004231 库存台账、库存流水账、即时库存查询，显示列设置中没有失效日期字段
        $temp2_sql = "CREATE TEMPORARY TABLE IF NOT EXISTS mytemptable2 (SELECT * FROM mytemptable1)";
        $temp3_sql = "CREATE TEMPORARY TABLE IF NOT EXISTS mytemptable3 (SELECT * FROM mytemptable1)";
        $temp4_sql = "CREATE TEMPORARY TABLE IF NOT EXISTS mytemptable4 (SELECT * FROM mytemptable1)";
        $temp5_sql = "CREATE TEMPORARY TABLE IF NOT EXISTS mytemptable5 (SELECT * FROM mytemptable1)";
        
        $product_result = $adb->pquery($product_sql,array());

        $product_num_rows = $adb->num_rows($product_result);
        if($product_num_rows > 0){
            $adb->pquery(" select 0 into  @i ;",array());
            $adb->pquery($youdata_sql,array());
            $adb->pquery($temp2_sql,array());
            $adb->pquery($temp3_sql,array());
            $adb->pquery($temp4_sql,array());
            $adb->pquery($temp5_sql,array());
            $this->cls_adb = $adb;
            return $final_sql;
        }else{
            $adb->pquery(" select 0 into  @i ;",array());
            $adb->pquery($wudata_sql,array());
            $adb->pquery($temp2_sql,array());
            $adb->pquery($temp3_sql,array());
            $adb->pquery($temp4_sql,array());
            $adb->pquery($temp5_sql,array());
            $this->cls_adb = $adb;
            return $final_sql;
        }
    }
}