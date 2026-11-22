<?php
//editor:gyq_86 reason:库存报表 2018/11/22 15:53
//即时库存查询
class ReportSqlInventoryQuery
{
    // @edit:dong @date:2020/08/11 @reason: 库存台账、库存流水账、即时库存查询，显示列设置中没有失效日期字段 expiry_date
    public function InventoryQuery($r_cangku,$r_pici,$r_productname,$r_shenpi){
        global $languageType,$adb,$weixin_user;
        $sSQL1="drop TEMPORARY  table if exists Temp_Inventery1;";
        $sSQL2="drop TEMPORARY  table if exists Temp_Inventery2;";
        $sSQL3="drop TEMPORARY  table if exists Temp_Inventery3;";
        $adb->query($sSQL1);
        $adb->query($sSQL2);
        $adb->query($sSQL3);
        //editor:gyq_107 reason:企业微信报表只根据产品ID进行groupby  2019/4/4 14:46
        $pc_groupby = '';
        //editor:gyq_20190930 reason:由于修改了GROUP BY a.productid,IFNULL(a.batchtext,'')$pc_groupby，为避免显示重复的记录，在sql最后增加groupby
        //0036884: 企业微信-报表-即时库存查询：搜索框无法按照库存和批次号进行搜索
        $weixin_groupby = '';
        $inventory_qty = 'inventory_qty,';
        $columns="  $inventory_qty
          IFNULL(p.qtyearly,0) AS qtyearly,
          IFNULL(a.dairu_qty,0) AS dairu_qty,
          IFNULL(a.daichu_qty,0) AS daichu_qty,
          a.inventory_qty-IFNULL(p.qtyearly,0)+IFNULL(a.dairu_qty,0)-IFNULL(a.daichu_qty,0) AS cha_qty, ";
          $out_columns='*';
        if($weixin_user->environment_weixin){
            $weixin_groupby = ' group by p.productid ';
            //editor:gyq_20191121 reason:移动端有额外的group by,那么数量统计应计算合计
            //0038624: （kfbcrm）移动端，即时库存报表，产品总库存数量显示错误
            //$inventory_qty = 'sum(a.inventory_qty) as inventory_qty,';
            //044606: （https://61mis.com/kfbcrm [^]）（深圳市云泰五金机电有限公司）移动端即时库存报表中无法搜索到数据
             $inventory_qty = 'sum(inventory_qty) as inventory_qty ,';
           //edit:can 20210413 45434: 山尖（http://www.xiaoshou360.com/xs/sageplas/ [^]）移动端（企业微信）-即时库存查询表：产品明细显示异常，但是PC端是正常的（详情见附件）
             $out_columns=" made_in,productdate,ordertype,productname,productid,product_no,productsheet,usageunit,unit_price
                ,batchtext, $inventory_qty
                  sum(IFNULL(qtyearly,0)) AS qtyearly,
                  sum(IFNULL(dairu_qty,0)) AS dairu_qty,
                  sum(IFNULL(daichu_qty,0)) AS daichu_qty,
                  sum(inventory_qty) -sum(IFNULL(qtyearly,0))+sum(IFNULL(dairu_qty,0))-sum(IFNULL(daichu_qty,0)) AS cha_qty
                  ,wareid,expiry_date ";
        }else{
            $pc_groupby .= ",IFNULL(a.wareid,'')";
            
        }
		$advsearch = '';
		crm_load_class_file('cls_QueryGenerator','modules/OftenUseReport');
		$queryGenerator = new cls_QueryGenerator('', null,'');
		$queryGenerator->addUserSearchConditions($_REQUEST);
		$where = $queryGenerator->getWhereClause();
		if(!empty($where)){
			$advsearch = '  ' . $where;
		}
		//editor:gyq_140 reason:即时库存查询优化，增加条件:显示库存数量为0的记录  2019/8/28 16:46
        //单据明细中数量小数位数zxm  20221013  ROUND(x,y)
        $sysdeploy = getSys_deploy(49);
        $length_amountdigits = $sysdeploy['deploy_value'];
		if($_REQUEST['show_zero_quantity']=='no'||empty($_REQUEST['show_zero_quantity'])){
		  if(!empty($advsearch))
            $advsearch .= ' and ROUND(inventory_qty,'.$length_amountdigits.')<>0';
            else 
                $advsearch.= '  ROUND(inventory_qty,'.$length_amountdigits.')<>0';
        }
        if(empty($r_shenpi))
            $r_shenpi='all';
        $where='';
        if(!empty($advsearch))
        {
            $where ="where   $advsearch ";
        }

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


		//editor:gyq_20191204 reason:增加left join ld_warehouse house on house.id=a.wareid
        // 0038738: （kfbcrm）即时库存查询报表：高级查询，按仓库等于或包含关键字查询数据时，数据显示不对（需要补丁）
		//库存报表优化，增加显示列产地made_in、productdate  2019/8/29 14:42
        //edit:can 2021-01-12 044228: （61mis.com/kfbcrm）报表-常用报表-即时库存查询；在库存报表界面进行高级查询，条件中设置"安全库存差额”为负数时，提示“安全库存差额0超出范围”；小于0时，提示“指定查询范围中没有相应记录，请重新选择”；库存差额是有负数库存的
        $sql1 = "CREATE TEMPORARY TABLE IF NOT EXISTS Temp_Inventery1 IGNORE (
        select  $out_columns from (
SELECT
  p.made_in,
  p.productdate,
  0 AS ordertype,
  p.productname,
  p.productid,
  p.product_no,
  p.productsheet,
  p.usageunit,
  CASE WHEN IFNULL(p.costprice,0)=0 THEN p.unit_price ELSE p.costprice END AS unit_price,
  a.batchtext,
    $columns
  a.wareid,
  a.expiry_date
FROM ld_products p
  inner JOIN (
              SELECT
                a.wareid,
                a.productid,
                IFNULL(a.batchtext,'') AS batchtext,
                SUM(a.inventory_qty) AS inventory_qty,
                SUM(a.dairu_qty) AS dairu_qty,
                SUM(a.daichu_qty) AS daichu_qty,
                a.expiry_date
              FROM (
                     SELECT
                       a.warehouseid AS wareid,
                       a.productid,
                       a.batchtext,
                       a.lastqty AS inventory_qty,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       '' AS expiry_date
                     FROM ld_warehousecondtions a
                       LEFT JOIN ld_products c ON c.productid=a.productid
                     WHERE a.modulename='库存初始化'
                           AND a.type='确认初始库存'
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
                       a.wareid,
                       c.productid,
                       c.batchtext,
                       c.quantity,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_stock a
                       LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
                       LEFT JOIN ld_stockdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
                           AND a.approvestatus<>'已拒绝'
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
                       a.wareid,
                       c.productid,
                       c.batchtext,
                       c.quantity,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_salesback a
                       LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
                       LEFT JOIN ld_salesbackdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
                           AND a.salesbackstatus<>'中止'
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
                       c.wareid,
                       c.productid,
                       c.batchtext,
                       0-c.quantity,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       d.expiry_date
                     FROM ld_outboundorder a
                       LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
                       LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
                       LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
                           AND a.approvestatus<>'已拒绝'
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
                       a.wareid,
                       c.productid,
                       c.batchtext,
                       0-c.quantity,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_purchaseback a
                       LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
                       LEFT JOIN ld_purchasebackdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
                           AND a.purchasebackstatus<>'中止'
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
                       a.inwarehouse,
                       c.productid,
                       c.batchtext,
                       c.quantity,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_warehousetransfer a
                       LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                       LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
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
                       a.outwarehouse,
                       c.productid,
                       c.batchtext,
                       0-c.quantity,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_warehousetransfer a
                       LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                       LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
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
                       a.wareid,
                       c.productid,
                       c.batchtext,
                       c.profitloss,
                       0 AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_checks a
                       LEFT JOIN ld_checksdetail c ON c.id=a.id
                       LEFT JOIN ld_checksdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
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
                     UNION ALL
                     SELECT
                       a.wareid,
                       c.productid,
                       c.batchtext,
                       0 AS inventory_qty,
                       c.quantity AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_stock a
                       LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
                       LEFT JOIN ld_stockdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
                           AND a.approvestatus<>'已拒绝'
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
                            WHEN '$r_shenpi'='all' THEN 1=0
                             ELSE a.approvestatus<>'已批准'
                             END)
                           AND a.wareid $allsql
                     UNION ALL
                     SELECT
                       c.wareid,
                       c.productid,
                       c.batchtext,
                       0 AS inventory_qty,
                       0 AS dairu_qty,
                       c.quantity AS daichu_qty,
                       d.expiry_date
                     FROM ld_outboundorder a
                       LEFT JOIN ld_outboundordercf b ON b.out_id=a.out_id
                       LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
                       LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
                           AND a.approvestatus<>'已拒绝'
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
                             WHEN '$r_shenpi'='all' THEN 1=0
                             ELSE a.approvestatus<>'已批准'
                             END)
                           AND c.wareid $allsql
                     UNION ALL
                     SELECT
                       a.inwarehouse,
                       c.productid,
                       c.batchtext,
                       0 AS inventory_qty,
                       c.quantity AS dairu_qty,
                       0 AS daichu_qty,
                       f.expiry_date
                     FROM ld_warehousetransfer a
                       LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                       LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
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
                             WHEN '$r_shenpi'='all' THEN 1=0
                             ELSE IFNULL(a.transferstatus,'')<>'已审核'
                             END)
                           AND a.inwarehouse $allsql
                     UNION ALL
                     SELECT
                       a.outwarehouse,
                       c.productid,
                       c.batchtext,
                       0 AS inventory_qty,
                       0 AS dairu_qty,
                       c.quantity AS daichu_qty,
                       f.expiry_date
                     FROM ld_warehousetransfer a
                       LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
                       LEFT JOIN ld_warehousetransferdetailscf f ON f.lineitem_id =c.lineitem_id
                       LEFT JOIN ld_products p ON p.productid=c.productid
                     WHERE a.deleted=0
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
                             WHEN '$r_shenpi'='all' THEN 1=0
                             ELSE IFNULL(a.transferstatus,'')<>'已审核'
                             END)
                           AND a.outwarehouse $allsql
                   ) a
              WHERE a.productid>0 
              GROUP BY a.productid,IFNULL(a.batchtext,'')$pc_groupby
            ) a ON a.productid=p.productid
            left join ld_productcf pcf on pcf.productid=p.productid
            left join ld_warehouse house on house.id=a.wareid
WHERE p.deleted=0 and p.discontinued<>1  and (
  CASE
  WHEN '$r_productname'='' THEN 1=1
  ELSE LOCATE('$r_productname',p.productname)>0
  END) 
) as p $where  $weixin_groupby )";

        //editor:gyq_20200213 reason:增加house.started=0条件
        //editor:gyq_122 reason:增加left join ld_productcf pcf...以支持搜索产品自定义表  2019/6/14 10:40
        //and a.inventory_qty<>0
        //editor:gyq_20190228	 a.inventory_qty<>0 0036233: 即时库存查询报表界面：即时库存查询时，隐藏产品库存为0的数据
        //editor:gyq_20190122  增加条件and p.discontinued<>1 	0036285: 即使库存查询报表界面：禁用的产品应该不显示
        $sql2="CREATE TEMPORARY TABLE IF NOT EXISTS Temp_Inventery2 IGNORE (SELECT * FROM Temp_Inventery1)";
        $sql3="CREATE TEMPORARY TABLE IF NOT EXISTS Temp_Inventery3 IGNORE (
                SELECT
                    made_in,
                    productdate,
                	1 AS ordertype,
                	CONCAT(productname,' - ','".getFixedLabel('SUBTOTAL')."') AS productname,
                	productid,
                	product_no,
                	productsheet,
                	usageunit,
                	unit_price,
                	'' AS batchtext,                	
                  SUM(inventory_qty) AS inventory_qty,
           	      SUM(qtyearly) AS qtyearly,
                  SUM(dairu_qty) AS dairu_qty,
                  SUM(daichu_qty) AS daichu_qty,
                  SUM(inventory_qty-qtyearly+dairu_qty-daichu_qty) AS cha_qty,
                 0 AS wareid,
                 '' AS expiry_date
                FROM Temp_Inventery1
                GROUP BY productid
                HAVING COUNT(productid)>1
         )";
        $adb->query($sql1);
        //editor:gyq_107 reason:企业微信即时库存查询报表,序时簿不显示小计  2019/4/4 13:29
        if($weixin_user->environment_weixin){
            $sql="SELECT made_in,productdate,
            	productname,productid,product_no,productsheet,usageunit,unit_price,batchtext,
            	inventory_qty,qtyearly,dairu_qty,daichu_qty,cha_qty,wareid,expiry_date
            FROM (
            	SELECT * FROM Temp_Inventery1
            ) a
            ORDER BY product_no,productid,ordertype";
        }else{
            $adb->query($sql2);
            $adb->query($sql3);
            $sql="SELECT made_in,productdate,
            	productname,productid,product_no,productsheet,usageunit,unit_price,batchtext,
            	inventory_qty,qtyearly,dairu_qty,daichu_qty,cha_qty,wareid,expiry_date
            FROM (
            	SELECT * FROM Temp_Inventery2
            	UNION ALL
            	SELECT * FROM Temp_Inventery3
            ) a
            ORDER BY product_no,productid,ordertype,batchtext";
        }
        return $sql;
    }
    //editor:gyq_86 reason:库存报表,即时库存查询  待出入库数量 明细  2018/12/3 16:07
    public function ProductDetailQuery($r_cangku,$r_pici,$r_productname,$r_shenpi,$r_productid,$r_churu_type){
        global $languageType,$adb;
        if(empty($r_shenpi))
            $r_shenpi='all';

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

        $sql = "SELECT
  b.fieldlabel,
  a.bill_date,
  a.bill_no,
  a.billid,
  a.billtype,
  a.modifiedtime,
  ld_users.last_name,
  a.presence,
  CASE
  WHEN '$r_churu_type'='dairu_qty' THEN a.dairu_qty
  ELSE a.daichu_qty
  END AS qyt
FROM (
       SELECT
         1 AS bill_seq,
         'Stock' AS billtype,
         'dairu' AS querytype,
         a.createdate AS bill_date,
         a.stock_id AS billid,
         a.ware_stock_no AS bill_no,
         a.wareid,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         c.quantity AS dairu_qty,
         0 AS daichu_qty,
         a.modifiedtime,
        a.smcreatorid,
        a.presence
       FROM ld_stock a
         LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
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
               WHEN '$r_shenpi'='all' THEN 1=0
               ELSE a.approvestatus<>'已批准'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         2 AS bill_seq,
         'OutboundOrder' AS billtype,
         'daichu' AS querytype,
         a.outdate AS bill_date,
         a.out_id,
         a.out_no,
         c.wareid,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         0 AS dairu_qty,
         c.quantity AS daichu_qty,
         a.modifiedtime,
        a.smcreatorid,
        a.presence
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON b.out_id=a.out_id
         LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
         LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
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
                WHEN '$r_shenpi'='all' THEN 1=0
               ELSE a.approvestatus<>'已批准'
               END)
             AND c.wareid $allsql
       UNION ALL
       SELECT
         3 AS bill_seq,
         'WareHouseTransfer' AS billtype,
         'dairu' AS querytype,
         a.transferdate AS bill_date,
         a.warehousetransferid,
         a.transferdate_no,
         a.inwarehouse,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         c.quantity AS dairu_qty,
         0 AS daichu_qty,
         a.modifiedtime,
        a.smcreatorid,
        '' as presence
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
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
               WHEN '$r_shenpi'='all' THEN 1=0
               ELSE IFNULL(a.transferstatus,'')<>'已审核'
               END)
             AND a.inwarehouse $allsql
       UNION ALL
       SELECT
         4 AS bill_seq,
         'WareHouseTransfer' AS billtype,
         'daichu' AS querytype,
         a.transferdate AS bill_date,
         a.warehousetransferid,
         a.transferdate_no,
         a.outwarehouse,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         0 AS dairu_qty,
         c.quantity AS daichu_qty,
         a.modifiedtime,
        a.smcreatorid,
        '' as presence
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
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
               WHEN '$r_shenpi'='all' THEN 1=0
               ELSE IFNULL(a.transferstatus,'')<>'已审核'
               END)
             AND a.outwarehouse $allsql
     ) a
  LEFT JOIN (
              SELECT
                a.name AS tabname,
                b.fieldlabel
              FROM ld_tab a
                LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab'
              WHERE 1=1
                    AND a.name IN ('WareHouseTransfer','OutboundOrder','Stock')
                    AND (
                      CASE
                      WHEN '$languageType'='en' THEN b.languagetype='en'
                      ELSE b.languagetype='zh'
                      END)
              GROUP BY a.tabid
            ) b ON a.billtype=b.tabname
            left join ld_users on ld_users.id=a.smcreatorid
WHERE a.productid='$r_productid'
      AND (
        CASE
        WHEN '$r_churu_type'='dairu_qty' THEN a.querytype='dairu'
        ELSE a.querytype='daichu'
        END) $advsearch 
ORDER BY a.bill_seq,a.bill_date,a.billid";
        return $sql;
    }
    //editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 15:53
    public function ProductDetail($r_productid){
        //editor:gyq_20190517 reason:由于显示列要显示仓库，而产品可以分部在不同仓库中，
        //故需要在最后的GROUP BY中增加warehouse  2019/5/17 16:13
        //0037056: PC端-珞珞计划-产品-材料-总库存数量：查询库存数量分布，界面上“仓库”不正确
        $sql = 'SELECT
  w.name AS warehouse,
  a.batchtext,
  p.product_no,p.productname,p.usageunit,p.productsheet,
  SUM(a.inventory_qty) AS inventory_qty
FROM (
       SELECT
         a.warehouseid AS wareid,
         a.productid,
         a.batchtext,
         a.lastqty AS inventory_qty
       FROM ld_warehousecondtions a
         LEFT JOIN ld_products c ON c.productid=a.productid
       WHERE a.modulename=\'库存初始化\'
             AND a.type=\'确认初始库存\'
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.quantity
       FROM ld_stock a
         LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>\'已拒绝\'
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.approvestatus=\'已批准\'
               END)
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.quantity
       FROM ld_salesback a
         LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.salesbackstatus<>\'中止\'
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.approvestatus=\'已批准\'
               END)
       UNION ALL
       SELECT
         c.wareid,
         c.productid,
         c.batchtext,
         0-c.quantity
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
         LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
         LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>\'已拒绝\'
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.approvestatus=\'已批准\'
               END)
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         0-c.quantity
       FROM ld_purchaseback a
         LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.purchasebackstatus<>\'中止\'
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.purchasebackstatus=\'已出库\'
               END)
       UNION ALL
       SELECT
         a.inwarehouse,
         c.productid,
         c.batchtext,
         c.quantity
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.transferstatus=\'已审核\'
               END)
       UNION ALL
       SELECT
         a.outwarehouse,
         c.productid,
         c.batchtext,
         0-c.quantity
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.transferstatus=\'已审核\'
               END)
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.profitloss
       FROM ld_checks a
         LEFT JOIN ld_checksdetail c ON c.id=a.id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND (
               CASE
               WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
               ELSE a.presence=\'盘点结束\'
               END)
     ) a
  LEFT JOIN ld_products p ON p.productid=a.productid
  LEFT JOIN ld_warehouse w ON w.id=a.wareid
WHERE a.productid='.$r_productid.'
      AND a.inventory_qty<>0
GROUP BY a.productid,IFNULL(a.batchtext,\'\'),warehouse
ORDER BY w.id,a.batchtext';
        return $sql;
    }
    //editor:gyq_20190409 reason:移动端库存分布与PC端的对应功能不一样
    public function ProductDetailWX($r_productid,$r_shenpi,$r_cangku){
        //editor:gyq_20190919 reason:即时库存查询优化，增加条件:显示库存数量为0的记录
        //0038043: （http://51mis.com/demo/panlulu2/ [^]）企业微信端，即时库存查询报表中查询条件“显示库存数量为0的记录”设置为“否”时没有生效
        //editor:gyq_20191012 reason:移动端即时查询，筛选不为零的远项没有任何反应
        global $adb;
        $advsearch = '';
        if($_REQUEST['show_zero_quantity']=='no'){
            $advsearch = ' where inventory_qty<>0';
        }

        // ljj 20231009 XUQIU1001975 库存报表->库存台账、库存流水账、即时库存查询
        //非管理员账号“仓库”查询条件下拉选项中增加显示“全部仓库”，可直接查询显示当前成员有权限查询的所有仓库的库存明细
        if ($r_cangku == 'all'){
            $wareArr=[];
            crm_load_class_file('CommonStock','include/Stock');
            $wareArrresult = selWareAll();
            for ($i = 0; $i < $adb->num_rows($wareArrresult); $i++) {
                $wareArr[]=$adb->query_result($wareArrresult, $i, "id");
            }
            $arr=implode(',',$wareArr);
            $allsql=" IN ($arr) ";
        }else{
            $allsql=" ='$r_cangku' ";
        }
        $sql = "select * from (SELECT
  w.name AS warehouse,
  a.batchtext,
  p.product_no,p.productname,p.usageunit,p.productsheet,
  SUM(a.inventory_qty) AS inventory_qty
FROM (
      SELECT
         a.warehouseid AS wareid,
         a.productid,
         a.batchtext,
         a.lastqty AS inventory_qty,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_warehousecondtions a
         LEFT JOIN ld_products c ON c.productid=a.productid
       WHERE a.modulename='库存初始化'
             AND a.type='确认初始库存'
            AND a.warehouseid $allsql
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         c.quantity,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_stock a
         LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
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
         c.quantity,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_salesback a
         LEFT JOIN ld_salesbackdetail c ON c.id=a.salesbackid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.salesbackstatus<>'中止'
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.approvestatus='已批准'
               END)
            AND a.wareid $allsql
       UNION ALL
       SELECT
         c.wareid,
         c.productid,
         c.batchtext,
         0-c.quantity,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
         LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
         LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
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
         0-c.quantity,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_purchaseback a
         LEFT JOIN ld_purchasebackdetail c ON c.id=a.purchasebackid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.purchasebackstatus<>'中止'
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
         c.quantity,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
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
         0-c.quantity,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
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
         c.profitloss,
         0 AS dairu_qty,
         0 AS daichu_qty
       FROM ld_checks a
         LEFT JOIN ld_checksdetail c ON c.id=a.id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=1
               ELSE a.presence='盘点结束'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         a.wareid,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         c.quantity AS dairu_qty,
         0 AS daichu_qty
       FROM ld_stock a
         LEFT JOIN ld_stockdetail c ON c.id=a.stock_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=0
               ELSE a.approvestatus<>'已批准'
               END)
             AND a.wareid $allsql
       UNION ALL
       SELECT
         c.wareid,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         0 AS dairu_qty,
         c.quantity AS daichu_qty
       FROM ld_outboundorder a
         LEFT JOIN ld_outboundordercf b ON b.out_id=a.out_id
         LEFT JOIN ld_outboundorderdetail c ON c.id=a.out_id
         LEFT JOIN ld_outboundorderdetailscf d ON d.lineitem_id=c.lineitem_id
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND a.approvestatus<>'已拒绝'
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=0
               ELSE a.approvestatus<>'已批准'
               END)
            AND c.wareid $allsql
       UNION ALL
       SELECT
         a.inwarehouse,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         c.quantity AS dairu_qty,
         0 AS daichu_qty
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND (
               CASE
                WHEN '$r_shenpi'='all' THEN 1=0
               ELSE IFNULL(a.transferstatus,'')<>'已审核'
               END)
             AND a.inwarehouse $allsql
       UNION ALL
       SELECT
         a.outwarehouse,
         c.productid,
         c.batchtext,
         0 AS inventory_qty,
         0 AS dairu_qty,
         c.quantity AS daichu_qty
       FROM ld_warehousetransfer a
         LEFT JOIN ld_warehousetransferdetail c ON c.id=a.warehousetransferid
         LEFT JOIN ld_products p ON p.productid=c.productid
       WHERE a.deleted=0
             AND (
               CASE
               WHEN '$r_shenpi'='all' THEN 1=0
               ELSE IFNULL(a.transferstatus,'')<>'已审核'
               END)
            AND a.outwarehouse $allsql
     ) a
  LEFT JOIN ld_products p ON p.productid=a.productid
  LEFT JOIN ld_warehouse w ON w.id=a.wareid
WHERE a.productid=".$r_productid."
GROUP BY a.productid, w.id,IFNULL(a.batchtext,'')
ORDER BY w.id,a.batchtext) a ".$advsearch;
        return $sql;
    }

}