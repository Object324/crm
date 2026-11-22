<?php
//BUG0066294	已分派	功能需求	正常处理	周晓梅
//公司自用报表收款业绩统计报增加一列最终客户
 
class ldorderReportSQL
{
    static function getPerformancestatisticscollection($where,$startdate,$enddate,$userids,$accountname)
    {
        if($_REQUEST['basicotherfindsapp']&&$_REQUEST['basicotherfindsapp'] == 'true'){
            $where_expense =" and a.approvestatus='".constant('D_A_S_APPROVED')."'";
            $where_commission =" and a.approvestatus='".constant('D_A_S_APPROVED')."'";
        }
        //Edit by luyx 2017-04-18
        $check_cashbill = ReportSQL::getCashBillApproveWhere();	//已收金额计算时是否统计未审核的收款单  0 是 1 否
        //echo $check_cashbill;

        global $adb;

        // @edit:dong @date:2020/08/10 @reason: bug0041038 报表>常用报表>收款业绩统计表：显示列能否增加“收款方式”字 字段名称paymentmethod
        $dateperid=' between  \''.$startdate.'\' and \''.$enddate.'\'';
        if(empty($accountname)==true){
            $name_account='';
        }else{
            $name_account=" AND ld_account.accountname like '%".$accountname."%'";
        };

        //zxm 2022-0328 合同跟踪表  合同类型条件
        $contracttype_str = '';
        $contracttype_arr = [];
        $servicecontract_contracttype_select = $_REQUEST['servicecontract_contracttype_select'];
        if(!empty($servicecontract_contracttype_select)&&$servicecontract_contracttype_select!='null'&&$servicecontract_contracttype_select!='undefined'){
            $contracttype_arr[] = $servicecontract_contracttype_select;
        }
        $salesorder_contracttype_select = $_REQUEST['salesorder_contracttype_select'];
        if(!empty($salesorder_contracttype_select)&&$salesorder_contracttype_select!='null'&&$salesorder_contracttype_select!='undefined'){
            $contracttype_arr[] = $salesorder_contracttype_select;
        }
        if(!empty($contracttype_arr)){
            $contracttype_str = ' where find_in_set(b.contracttype,"'.  implode(',',$contracttype_arr).'")';
        }
        $leftjointable = " LEFT JOIN  ld_account AS ld_account2 ON ld_account2.accountid = a.end_accountid ";
        //$vw_cashbilldetail1：收款明细信息：如果收款单有调整，计在收款分录中第一条记录上
        $vw_cashbilldetail1="(
        SELECT
        	cashbillid,
        	sum(amount) AS amount,
        	entitytype,
        	entitytypeid,
        	description
        FROM (
        	SELECT
        		a.smownerid,
        		a.cashbillid,
        		a.cashbill_no,
        		a.cashbilldate,
        		a.accountid,
        		a.currency_symbol,
        		a.conversion_rate,
        		CASE 
        			WHEN b.entitytype='PaymentPlan' THEN
        				(SELECT entitytype FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        			ELSE b.entitytype
        		END AS entitytype,
        		CASE 
        			WHEN b.entitytype='PaymentPlan' THEN
        				(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        			ELSE b.entitytypeid
        		END AS entitytypeid,
        		CASE
        			WHEN b.CashBillID>0 THEN  b.amount
        			ELSE a.Total
        		END AS amount,
        		a.description
        	FROM ld_cashbill a
        	LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid = b.CashBillID
        	WHERE a.deleted=0 $check_cashbill 
 	            AND ifnull(a.approvestatus,'') <> '已拒绝'
 	            AND ifnull(a.paymentmethod ,'') <> '其他'
        		AND a.cashbilldate $dateperid 
        		AND a.smownerid in ($userids)
        ) a
        GROUP BY cashbillid,entitytypeid)";


        //$vw_cashbilldetail2：收款明细情况
        //如果源单类型是回款计划则entitytypeid取对应的订单id，如果不是回款计划则直接取对应订单的id
        $vw_cashbilldetail2="(
        SELECT
        	a.smownerid,
        	d.last_name,
            d.wx_userid as report_wx_userid,
			ld_group.groupname,
            ld_group.groupid as report_wx_groupid,
        	e.last_name AS creator,
        	a.cashbill_no,
        	CASE 
        		WHEN b.entitytype='PaymentPlan' THEN
        			(SELECT entitytype FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        		ELSE b.entitytype
        	END AS entitytype,
        	CASE 
        		WHEN b.entitytype='PaymentPlan' THEN
        			(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        		ELSE b.entitytypeid
        	END AS entitytypeid,
        	a.currency_id,
        	a.currency_symbol,
        	a.conversion_rate,
        	b.amount,
        	a.cashbilldate,
        	ld_account.accountname,
        	a.accountid,
        	ld_account2.accountname as end_accountidname,
        	a.description,
        	a.paymentmethod,
        	a.cashbillid
        FROM ld_cashbill a
        LEFT JOIN $vw_cashbilldetail1 b ON a.cashbillid=b.CashBillID
        LEFT JOIN ld_account ON ld_account.accountid=a.accountid
        $leftjointable
        LEFT JOIN ld_users d ON d.id=a.smownerid
        LEFT JOIN ld_users e ON e.id=a.smcreatorid
		LEFT JOIN (
			select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc ) as groupname,
            GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc ) as groupid,
            ld_users2group.userid from ld_users2group
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
			GROUP BY ld_users2group.userid
		) as ld_group on ld_group.userid = a.smownerid
        WHERE a.deleted=0 $name_account $check_cashbill 
            AND a.cashbilldate $dateperid 
           	AND ifnull(a.approvestatus,'') <> '已拒绝'
           	AND ifnull(a.paymentmethod ,'') <> '其他'
            AND a.smownerid in ($userids)            
        )";
        //echo "SQL=<br/>".$vw_cashbilldetail2."<br/>";

        //$vw_cashbilldetail3：收款明细数据整理
        //如果同一个收款单多条分录关联了同一个源单（回款计划转化为对应合同），按照源单汇总统计。
        $vw_cashbilldetail3="(
        SELECT
        	smownerid,
        	last_name,
            report_wx_userid,
			groupname,
            report_wx_groupid,
            
        	creator,
        	cashbill_no,
        	entitytype,
        	entitytypeid,
        	currency_id,
        	currency_symbol,
        	conversion_rate,
        	sum(ifnull(amount,0)) AS amount,
        	cashbilldate,
        	accountname,
        	accountid,
        	end_accountidname,
        	description,
        	paymentmethod,
        	cashbillid
        FROM $vw_cashbilldetail2 a
        GROUP BY cashbillid,entitytypeid)";

        //$vw_cashbilldetail:收款业绩统计，包括对应源单、费用、佣金、产品成本等信息
        $vw_cashbilldetail="(
        SELECT
        	1 AS report_seq,
            1 AS report_seq2,
        	a.last_name AS statistical_one,
            a.report_wx_userid,
        	a.cashbill_no AS statistical_two,
        	b.order_no AS statistical_three,
        	a.last_name AS OftenUseReport_lastname,
        	a.last_name AS OftenUseReport_lastname2,
			a.groupname AS OftenUseReport_groupname,
            a.report_wx_groupid,
        	a.creator AS OftenUseReport_lastname3,
        	a.cashbill_no AS CashBill_cashbill_no,
        	a.cashbilldate AS CashBill_cashbilldate,
        	IFNULL(b.received_amount,0)/(IFNULL(b.conversion_rate,1)) OftenUseReport_Atotal,
        	a.currency_id AS CashBill_Curid,
        	a.conversion_rate AS CashBill_Rate,
        	a.currency_symbol AS CashBill_Symbol,
        	a.accountname AS Accounts_accountname,
        	a.accountid AS Accounts_accountid,
        	a.end_accountidname AS Accounts_end_accountidname,
        	b.`subject` AS SalesOrder_subject,
        	b.currency_id AS SalesOrder_Curid,
        	b.conversion_rate AS SalesOrder_Rate,
        	b.currency_symbol AS SalesOrder_Symbol,
        	e.currency_id AS Expense_Curid,
        	e.conversion_rate AS Expense_Rate,
        	e.currency_symbol AS Expense_Symbol,
        	d.currency_id AS Comm_Curid,
        	d.conversion_rate AS Comm_Rate,
        	d.currency_symbol AS Comm_Symbol,
        	b.order_no AS OftenUseReport_salesorder_no,
        	b.contracttype AS OftenUseReport_contracttype,
        	IFNULL(b.total,0) AS OftenUseReport_ssubtotal,
        	a.amount AS OftenUseReport_pamount,
        	CASE
        		WHEN f.first_cashid=a.cashbillid THEN ROUND(IFNULL(g.productcost/IFNULL(b.conversion_rate,1),0),2)
        		ELSE 0
        	END AS OftenUseReport_productcost,
        	CASE
        		WHEN j.peridmin_cashid=a.cashbillid THEN IFNULL(e.fytotal,0)
        		ELSE 0
        	END AS OftenUseReport_etotal,
        	CASE
        		WHEN j.peridmin_cashid=a.cashbillid THEN 
        			a.amount/IFNULL(a.conversion_rate,1)-IFNULL(g.productcost/IFNULL(b.conversion_rate,1),0)-IFNULL(e.fytotal,0)-IFNULL(d.yjtotal,0)
        		ELSE a.amount
        	END AS OftenUseReport_productgp,
        	c.product_no AS Products_product_no,
        	c.productname AS Products_productname,
        	c.productsheet AS Products_productsheet,
        	c.usageunit AS Products_usageunit,
        	IFNULL(c.unit_price,0) AS Products_unit_price,
        	CASE
        		WHEN j.peridmin_cashid=a.cashbillid THEN IFNULL(d.yjtotal,0)
        		ELSE 0
        	END AS OftenUseReport_CommissionTotal,
        	c.quantity AS OftenUseReport_quantity,
        	CASE
        		WHEN f.first_cashid=a.cashbillid THEN ROUND(IFNULL(c.productcost/IFNULL(b.conversion_rate,1),0),2)
        		ELSE 0
        	END AS Products_costprice,
        	c.discount_amount/(IFNULL(b.conversion_rate,1)) AS OftenUseReport_discountamount,
        	a.smownerid AS CashBill_smownerid,
        	a.entitytypeid AS CashBill_salesorderid,
        	a.description AS CashBill_description,
        	a.paymentmethod AS CashBill_paymentmethod,
        	a.cashbillid AS LBL_ACTION,
        	b.order_id
        FROM $vw_cashbilldetail3 a
        LEFT JOIN (
        	SELECT salesorderid AS order_id,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,salesorder_no AS order_no,contracttype  FROM ld_salesorder
        	UNION ALL 
        	SELECT servicecontractsid,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,contract_no,contract_type as contracttype FROM ld_servicecontracts
        	UNION ALL 
        	SELECT invoiceid,currency_id,conversion_rate,currency_symbol,total,received_amount,`subject`,invoice_no,'' as contracttype FROM ld_invoice
        	UNION ALL 
        	SELECT out_id,currency_id,conversion_rate,currency_symbol,total,received_amount,'',out_no,'' as contracttype FROM ld_outboundorder
        ) b ON a.entitytypeid=b.order_id
        LEFT JOIN (
       
            	select tmpdetailinfo.id,
                ld_products.productname,
                ld_products.product_no,
                ld_products.productsheet,
                ld_products.usageunit,
                ld_products.unit_price,
                tmpdetailinfo.quantity,
                CASE
                    				WHEN EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
                    					IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost)
                    				ELSE
                    					tmpdetailinfo.quantity*IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost) 
                    END AS productcost,
                 tmpdetailinfo.discount_amount 
                 from 
                (
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_invoicedetail      
                    union ALL
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_outboundorderdetail 
                    union ALL
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_servicecontractsdetail   
                    union ALL
                    select id,quantity,productcost,discount_amount,productid,lineitem_id from ld_salesorderdetail 
                ) as tmpdetailinfo 
                	 
                LEFT JOIN ld_products   on ld_products.productid=tmpdetailinfo.productid
                GROUP BY tmpdetailinfo.id,ld_products.productid,tmpdetailinfo.lineitem_id

        ) c ON c.id=b.order_id
        LEFT JOIN (
        	SELECT
        		a.currency_id,
        		a.currency_symbol,
        		a.conversion_rate,
        		b.entitytypeid,
        		sum(b.amount/ifnull(a.conversion_rate,1)) AS yjtotal
        	FROM
        		ld_commission a
        	LEFT JOIN ld_commission2payment b ON a.commission_id = b.commission_id
        	LEFT JOIN ld_commission2paymentscf c ON c.commission2payment_id = b.commission2payment_id
        	WHERE a.deleted = 0 $where_commission 
                AND a.expensedate $dateperid
                AND b.entitytypeid > 0
        		AND ifnull(a.approvestatus,'') <> '已拒绝'
        	GROUP BY b.entitytypeid
        ) d ON d.entitytypeid=b.order_id
        LEFT JOIN (
        	SELECT
        		b.entitytypeid,
        		c.currency_id,
        		c.conversion_rate,
        		c.currency_symbol,
        		sum(c.rmb_total) AS fytotal
        	FROM
        		ld_expense a 
        	LEFT JOIN ld_expensedetail b ON a.expenseid = b.expenseid
        	LEFT JOIN ld_expensedetailscf c ON c.expensedetailid = b.expensedetailid
        	WHERE a.deleted = 0 $where_expense
                AND a.expensedate $dateperid
                AND b.entitytypeid > 0
        		AND ifnull(a.approvestatus,'') <> '已拒绝'
        	GROUP BY b.entitytypeid
        ) e ON e.entitytypeid=b.order_id
        LEFT JOIN (
			SELECT
				entitytypeid,
				cashbillid AS first_cashid
			FROM (
				SELECT
					a.cashbillid,
					a.cashbilldate,
					b.entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				WHERE a.deleted=0 $check_cashbill
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND ifnull(a.paymentmethod ,'') <> '其他'
					AND b.entitytypeid>0
					ORDER BY a.cashbilldate,a.cashbillid
			) a GROUP BY entitytypeid      
    	) f ON f.entitytypeid=b.order_id      
 		LEFT JOIN (
			SELECT
				entitytypeid,
				cashbillid AS peridmin_cashid
			FROM (
				SELECT
					a.cashbillid,
					a.cashbilldate,
					CASE 
        		WHEN b.entitytype='PaymentPlan' THEN
        			(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=b.entitytypeid)
        		ELSE b.entitytypeid
        	END AS entitytypeid
				FROM ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
				WHERE a.deleted=0 $check_cashbill
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND ifnull(a.paymentmethod ,'') <> '其他'
					AND b.entitytypeid>0
					AND a.cashbilldate $dateperid
					ORDER BY a.cashbilldate,a.cashbillid
			) a GROUP BY entitytypeid
		) j ON j.entitytypeid=b.order_id       
        LEFT JOIN (
            SELECT 
                tmpdetailinfo.id AS order_id,
                CASE
                    WHEN EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung' AND account='lingdang') THEN
                        SUM(1*IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost))
                ELSE
   					SUM(tmpdetailinfo.quantity*IF((ifnull(tmpdetailinfo.productcost,0)=0),ifnull(ld_products.costprice,0),tmpdetailinfo.productcost)) 
                END AS productcost
            FROM (
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_invoicedetail      
                UNION ALL
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_outboundorderdetail 
                UNION ALL
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_servicecontractsdetail     
                UNION ALL
                SELECT id,quantity,productcost,productid,lineitem_id FROM ld_salesorderdetail 
            ) AS tmpdetailinfo  
            LEFT JOIN ld_products ON ld_products.productid=tmpdetailinfo.productid
            GROUP BY tmpdetailinfo.id
        ) g ON g.order_id=b.order_id
        ".$contracttype_str."
        )";
//    echo $vw_cashbilldetail."<br/>";die;

        //$vw_fycost1：费用和佣金支出，有关联客户但是当前期间内源单没有收款记录的费用和佣金在报表中单独列示
        $vw_fycost1="(
        SELECT
        	'feiyong' AS type,
        	a.accountid,
        	a.expensedate,
        	a.expenseid AS order_id,
        	a.expense_no AS order_no,
        	b.entitytypeid,
        	a.approvestatus,
        	a.currency_id,
        	a.currency_symbol,
        	b.Money AS amount,
        	c.rmb_total AS total,
        	a.deleted,
        	a.smcreatorid,
        	a.smownerid,
        	a.description
        FROM ld_expense a
        LEFT JOIN ld_expensedetail b ON a.expenseid = b.expenseid 
        LEFT JOIN ld_expensedetailscf c ON c.expensedetailid = b.expensedetailid
        LEFT JOIN ld_account ON a.accountid=ld_account.accountid $name_account   
        WHERE a.deleted=0 $name_account $where_expense
            AND a.expensedate $dateperid 
            AND a.accountid>0
            AND IFNULL(a.approvestatus,'') <> '已拒绝'
            AND a.smownerid in ($userids)  
        )
        UNION ALL (
        SELECT
        	'yongjin' AS type,
        	a.accountid,
        	a.expensedate,
        	a.commission_id AS order_id,
        	a.commission_no AS order_no,
        	e.entitytypeid,
        	a.approvestatus,
        	a.currency_id,
        	a.currency_symbol,
        	e.amount AS amount,
        	e.amount/a.conversion_rate AS total,
        	a.deleted,
        	a.smcreatorid,
        	a.smownerid,
        	a.description
        FROM ld_commission a
        LEFT JOIN ld_commission2payment e ON a.commission_id = e.commission_id
        LEFT JOIN ld_commission2paymentscf f ON f.commission2payment_id = e.commission2payment_id
        LEFT JOIN ld_account ON a.accountid=ld_account.accountid
        WHERE a.deleted=0 $name_account $where_commission 
            AND a.expensedate $dateperid 
            AND a.accountid>0
            AND IFNULL(a.approvestatus,'') <> '已拒绝'
            AND a.smownerid in ($userids) 
        )";
        //echo $vw_fycost1."<br/>";

        //$vw_fycost1:按照用户和时间范围过滤
        $vw_fycost2="(SELECT * FROM ($vw_fycost1) a)";
        //echo $vw_fycost2;die;

        //$vw_fycost：费用和佣金支出，按照合同订单汇总统计，并按照查询期间过滤
        $vw_fycost="(
        SELECT
        	1 AS report_seq,
            2 AS report_seq2,
        	c.last_name AS statistical_one,
            c.wx_userid as report_wx_userid,
        	a.order_no AS statistical_two,
        	'' AS statistical_three,
        	c.last_name AS OftenUseReport_lastname,
        	c.last_name AS OftenUseReport_lastname2,
			ld_group.groupname AS OftenUseReport_groupname,
            ld_group.groupid as report_wx_groupid,
        	d.last_name AS OftenUseReport_lastname3,
        	a.order_no AS CashBill_cashbill_no,
        	a.expensedate AS CashBill_cashbilldate,
        	0 AS OftenUseReport_Atotal,
        	'' AS CashBill_Curid,
        	'' AS CashBill_Rate,
        	'' AS CashBill_Symbol,
        	ld_account.accountname AS Accounts_accountname,
        	a.accountid AS Accounts_accountid,
        	'' as Accounts_end_accountidname,
        	'' AS SalesOrder_subject,
        	'' AS SalesOrder_Curid,
        	'' AS SalesOrder_Rate,
        	'' AS SalesOrder_Symbol,
        	CASE
        		WHEN a.type = 'feiyong' THEN a.currency_id
        		ELSE ''
        	END AS Expense_Curid,
        	CASE
        		WHEN a.type = 'feiyong' THEN a.expensedate
        		ELSE ''
        	END AS Expense_Rate,
        	CASE
        		WHEN a.type = 'feiyong' THEN a.currency_symbol
        		ELSE ''
        	END AS Expense_Symbol,
        	CASE
        		WHEN a.type = 'yongjin' THEN a.currency_id
        		ELSE ''
        	END AS Comm_Curid,
        	CASE
        		WHEN a.type = 'yongjin' THEN a.expensedate
        		ELSE ''
        	END AS Comm_Rate,
        	CASE
        		WHEN a.type = 'yongjin' THEN a.currency_symbol
        		ELSE ''
        	END AS Comm_Symbol,
        	'' AS OftenUseReport_salesorder_no,
        	'' AS OftenUseReport_contracttype,
        	0 AS OftenUseReport_ssubtotal,
        	0 AS OftenUseReport_pamount,
        	0 AS OftenUseReport_productcost,
        	CASE
        	WHEN a.type = 'feiyong' THEN SUM(a.total)
        	ELSE 0
        	END AS OftenUseReport_etotal,
        	0 - sum(a.total) AS OftenUseReport_productgp,
        	'' AS Products_product_no,
        	'' AS Products_productname,
        	'' AS Products_productsheet,
        	'' AS Products_usageunit,
        	0 AS Products_unit_price,
        	CASE
        		WHEN a.type = 'yongjin' THEN SUM(a.total)
        		ELSE 0
        	END AS OftenUseReport_CommissionTotal,
        	0 AS OftenUseReport_quantity,
        	0 AS Products_costprice,
        	0 AS OftenUseReport_discountamount,
        	a.smownerid AS CashBill_smownerid,
        	'' AS CashBill_salesorderid,
        	a.description CashBill_description,
        	'' AS CashBill_paymentmethod,
        	a.order_id AS LBL_ACTION,
        	a.order_id
        FROM $vw_fycost2 a
        LEFT JOIN ld_account ON a.accountid = ld_account.accountid
        LEFT JOIN ld_users c ON a.smownerid = c.id
        LEFT JOIN ld_users d ON a.smcreatorid = d.id
		LEFT JOIN (
			select GROUP_CONCAT(ld_groups.groupname) as groupname,
            GROUP_CONCAT(ld_groups.groupid) as groupid,
            ld_users2group.userid from ld_users2group
			LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
			GROUP BY ld_users2group.userid
		) as ld_group on ld_group.userid = a.smownerid
        WHERE a.entitytypeid NOT IN (
        		SELECT DISTINCT
        			CASE
        				WHEN ld_cashbill2paymentplan.entitytype='PaymentPlan' THEN
        					(SELECT entitytypeid FROM ld_paymentplan WHERE paymentplanid=ld_cashbill2paymentplan.entitytypeid)
        				ELSE ld_cashbill2paymentplan.entitytypeid
        			END AS entitytypeid
        		FROM ld_cashbill a
        		LEFT JOIN ld_cashbill2paymentplan ON a.cashbillid = ld_cashbill2paymentplan.CashBillID
        		LEFT JOIN ld_account ON ld_account.accountid=a.accountid
        		WHERE a.deleted = 0 $name_account $check_cashbill
                    AND a.cashbilldate $dateperid
                    AND a.smownerid in ($userids)
                    AND ifnull(a.paymentmethod ,'') <> '其他'
        			AND ld_cashbill2paymentplan.entitytypeid > 0
            )
        GROUP BY a.order_id)";

        //$sql_report: 收款业绩统计表数据SQL
        $sql_report="($vw_cashbilldetail UNION ALL $vw_fycost)";
        //echo $sql_report."<br><br>";die;

        $temp_table1="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable1` IGNORE (
            SELECT * from $sql_report tmp
            );";
//   echo $temp_table1."<br><br>";
//    dump($temp_table1);
        $adb->query($temp_table1);


        $temp_table2="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable2` IGNORE (
            SELECT * from temptable1
            );";
        $temp_table3="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable3` IGNORE (
            SELECT * from temptable1
            );";
        $temp_table31="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable31` IGNORE (
            SELECT * from temptable1
            );";

//    echo $temp_table2."<br><br>";
//    echo $temp_table3."<br><br>";
//     echo $temp_table31     ."<br><br>";
        $adb->query($temp_table2);
        $adb->query($temp_table3);
        $adb->query($temp_table31);

        //$sql_subtotal：收款业绩统计表小计SQL
        $sql_subtotal="(
        SELECT
        	1 AS report_seq,
            3 AS report_seq2,
        	'小计' AS statistical_one,
           
        	'小计' AS statistical_two,
        	'小计' AS statistical_three,
        	CONCAT(t1.OftenUseReport_lastname,'-','".getFixedLabel('SUBTOTAL')."') AS OftenUseReport_lastname,
            CONCAT(t1.OftenUseReport_lastname,'-','".getFixedLabel('SUBTOTAL')."')  as report_wx_userid,
        	CONCAT(t1.OftenUseReport_lastname,' :小计') AS OftenUseReport_lastname2,
			'' OftenUseReport_groupname,
            '' as report_wx_groupid,
        	'' OftenUseReport_lastname3,
        	'' AS CashBill_cashbill_no,
        	'' AS CashBill_cashbilldate,
        	IFNULL(t3.OftenUseReport_Atotal,0) AS OftenUseReport_Atotal,
        	'' CashBill_Curid,
        	'' CashBill_Rate,
        	'' CashBill_Symbol,
        	'' AS Accounts_accountname,
        	'' AS Accounts_accountid,
        	'' AS Accounts_end_accountidname,
        	'' SalesOrder_subject,
        	'' SalesOrder_Curid,
        	'' SalesOrder_Rate,
        	'' SalesOrder_Symbol,
        	'' Expense_Curid,
        	'' Expense_Rate,
        	'' Expense_Symbol,
        	'' Comm_Curid,
        	'' Comm_Rate,
        	'' Comm_Symbol,
        	'' OftenUseReport_salesorder_no,
        	'' OftenUseReport_contracttype,
        	IFNULL(t4.OftenUseReport_ssubtotal,0) AS OftenUseReport_ssubtotal,
        	IFNULL(t2.OftenUseReport_pamount,0) AS OftenUseReport_pamount,
        	IFNULL(t1.OftenUseReport_productcost,0) AS OftenUseReport_productcost,
        	IFNULL(t3.OftenUseReport_etotal,0) AS OftenUseReport_etotal,
        	IFNULL(t3.OftenUseReport_productgp,0) AS OftenUseReport_productgp,
        	'' Products_product_no,
        	'' Products_productname,
        	'' Products_productsheet,
        	'' Products_usageunit,
        	'' Products_unit_price,
        	IFNULL(t3.OftenUseReport_CommissionTotal,0) AS OftenUseReport_CommissionTotal,
        	IFNULL(t1.OftenUseReport_quantity,0) AS OftenUseReport_quantity,
        	IFNULL(t1.OftenUseReport_productcost,0) AS Products_costprice,
        	IFNULL(t3.OftenUseReport_discountamount,0) AS OftenUseReport_discountamount,
        	'' AS CashBill_smownerid,
        	'' AS CashBill_salesorderid,
        	'' CashBill_description,
        	'' AS CashBill_paymentmethod,
        	'' AS LBL_ACTION,
        	'' AS order_id
        FROM (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(Products_costprice) AS OftenUseReport_productcost,
       			SUM(OftenUseReport_quantity) AS OftenUseReport_quantity
        	FROM temptable1
        	GROUP BY OftenUseReport_lastname
        ) t1
        LEFT JOIN (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(OftenUseReport_pamount) AS OftenUseReport_pamount
        	FROM (
        		SELECT
        			OftenUseReport_lastname,
        			LBL_ACTION,
        			OftenUseReport_pamount/IFNULL(CashBill_Rate,1) AS OftenUseReport_pamount,
        			OftenUseReport_Atotal
        		FROM temptable2
        		GROUP BY LBL_ACTION,order_id
        	) temp
            GROUP BY OftenUseReport_lastname
        ) t2 ON t1.OftenUseReport_lastname=t2.OftenUseReport_lastname
        LEFT JOIN (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(OftenUseReport_ssubtotal) AS OftenUseReport_ssubtotal
        	FROM
        		(
        			SELECT
        				OftenUseReport_lastname,
        				OftenUseReport_ssubtotal / IFNULL(SalesOrder_Rate, 1) AS OftenUseReport_ssubtotal
        			FROM temptable31
        			GROUP BY order_id
        		) tmp
        	GROUP BY OftenUseReport_lastname
        ) t4 ON t4.OftenUseReport_lastname = t1.OftenUseReport_lastname
        LEFT JOIN (
        	SELECT
        		OftenUseReport_lastname,
        		SUM(OftenUseReport_ssubtotal) AS OftenUseReport_ssubtotal,
        		SUM(OftenUseReport_Atotal) AS OftenUseReport_Atotal,
        		SUM(OftenUseReport_productgp) AS OftenUseReport_productgp,
        		SUM(OftenUseReport_etotal) AS OftenUseReport_etotal,
        		SUM(OftenUseReport_CommissionTotal) AS OftenUseReport_CommissionTotal,
        		SUM(OftenUseReport_discountamount) AS OftenUseReport_discountamount
        	FROM (
        		SELECT
        			OftenUseReport_lastname,
        			order_id,
        			OftenUseReport_ssubtotal/IFNULL(SalesOrder_Rate,1) AS OftenUseReport_ssubtotal,
        			OftenUseReport_Atotal,
        			OftenUseReport_productgp,
        			OftenUseReport_etotal,
        			OftenUseReport_CommissionTotal,
        			OftenUseReport_discountamount
        		FROM temptable3
        		GROUP BY lbl_action, order_id
        	) tmp
            GROUP BY OftenUseReport_lastname
        ) t3 ON t3.OftenUseReport_lastname=t1.OftenUseReport_lastname)";


        $temp_table4="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable4` IGNORE (
        SELECT * from $sql_subtotal tmp
        );";
//        echo $temp_table4     ."<br><br>";
        $adb->query($temp_table4);


        //$sql_total：收款业绩统计表合计SQL
        $sql_total="(
        SELECT
        	3 AS report_seq,
            1 AS report_seq2,
        	'合计' as statistical_one,
            
        	'合计' as statistical_two,
        	'合计' as statistical_three, 
        	'".getFixedLabel('TOTAL')."' as OftenUseReport_lastname,
            '".getFixedLabel('TOTAL')."' as report_wx_userid,
        	'合计' as OftenUseReport_lastname2,
			'' AS OftenUseReport_groupname,
            '' as report_wx_groupid,
        	'' AS OftenUseReport_lastname3,
        	'' AS CashBill_cashbill_no, 
        	'' AS CashBill_cashbilldate,
        	SUM(OftenUseReport_Atotal) as OftenUseReport_Atotal,
        	'' CashBill_Curid,
        	'' CashBill_Rate,
        	'' CashBill_Symbol, 
        	'' as Accounts_accountname,
        	'' as Accounts_accountid,
        	'' as Accounts_end_accountidname,
        	'' SalesOrder_subject,
        	'' SalesOrder_Curid,
        	'' SalesOrder_Rate,
        	'' SalesOrder_Symbol,
        	'' Expense_Curid,
        	'' Expense_Rate,
        	'' Expense_Symbol,
        	'' Comm_Curid,
        	'' Comm_Rate,
        	'' Comm_Symbol,
        	'' OftenUseReport_salesorder_no,
        	'' OftenUseReport_contracttype,
        	SUM(OftenUseReport_ssubtotal) AS OftenUseReport_ssubtotal,
        	SUM(OftenUseReport_pamount) AS OftenUseReport_pamount,
        	SUM(OftenUseReport_productcost) AS OftenUseReport_productcost,
        	SUM(OftenUseReport_etotal) AS OftenUseReport_etotal,
        	SUM(OftenUseReport_productgp) AS OftenUseReport_productgp,
        	'' Products_product_no,
        	'' Products_productname,
        	'' Products_productsheet,
        	'' Products_usageunit, 
        	'' as Products_unit_price,
        	SUM(OftenUseReport_CommissionTotal) AS OftenUseReport_CommissionTotal,
        	SUM(OftenUseReport_quantity) AS OftenUseReport_quantity,
        	SUM(Products_costprice) Products_costprice, 
        	SUM(OftenUseReport_discountamount) OftenUseReport_discountamount, 
        	'' as CashBill_smownerid,
        	'' as CashBill_salesorderid,
        	'' CashBill_description,
        	'' CashBill_paymentmethod,
        	'' as LBL_ACTION,
        	'' AS order_id
        FROM temptable4 tmp)";
        //echo $sql_total;

        $temp_table5="CREATE TEMPORARY TABLE IF NOT EXISTS `temptable5` IGNORE (
            SELECT * from $sql_total tmp
            );";
//    echo $temp_table5;
        $adb->query($temp_table5);
        //  echo $temp_table5."<br><br>";
        // dump('wwww');
        //   dump('www');

        //收款业绩统计表查询SQL
        $SQL="SELECT *  
        FROM (
            SELECT * FROM temptable3 
            UNION ALL 
            SELECT * FROM temptable4 
            UNION ALL  
            SELECT * FROM temptable5
            ) t
        ORDER BY report_seq,
            CONVERT(OftenUseReport_lastname2 USING gbk),
            report_seq2,
            CashBill_cashbilldate,
            CashBill_cashbill_no,
            OftenUseReport_salesorder_no";
//        echo $SQL."</br></br>";die;
        return $SQL;
    }
}