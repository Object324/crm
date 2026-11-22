<?php

//zxm 2021-0715  东方报警 提成报表特殊需求
class DongfangBaojingReport
{
    private $adb;
    private $showcolLists;

    public function __construct($showcolLists)
    {
        global $adb;
        $this->adb = $adb;
        $this->showcolLists = $showcolLists;
    }

    /**
     * @param $data_range  人员范围
     * @return string
     *
     */
    public function ListViewForSalesCommissionOrder($data_range)
    {
        //时间搜索条件
        $start_date = $_REQUEST['startmonth'];
        $end_date = $_REQUEST['endmonth'];
        // 业绩计算方法
        $jititype = isset($_REQUEST['achievement_type']) && $_REQUEST['achievement_type'] >= 1 ? $_REQUEST['achievement_type'] : 1;
        // 成本计算方法
        $costtype = isset($_REQUEST['cost_accounting']) && $_REQUEST['cost_accounting'] >= 1 ? $_REQUEST['cost_accounting'] : 1;
        // 只统计审批通过的费用和佣金单
        if (isset($_REQUEST['onlyshowapprovefeeandcommissions']) && $_REQUEST['onlyshowapprovefeeandcommissions'] == 'yes') {
            $fee_range = "true";
        } else {
            $fee_range = "false";
        }
        // 只统计审批通过的合同订单与服务订单
        if (isset($_REQUEST['onlyshowapprovecontactandservice']) && $_REQUEST['onlyshowapprovecontactandservice'] == 'yes') {
            $order_range = "true";
        } else {
            $order_range = "false";
        }
        $accountname = '';
        $ordernum = '';
        //订单类型
        $OrderClassification = "1";//默认全部
        if(isset($_REQUEST['onlyshowapprovecontactandservice'])){
            $OrderClassification = $_REQUEST['OrderClassification'];
        }

        //查询sql
        $report_sql = $this->getCommissionByOrder($start_date, $end_date, $jititype, $costtype, $fee_range, $order_range, $accountname, $ordernum, $data_range,$OrderClassification);

        $result = $this->adb->pquery($report_sql);
        $html = '';
        $nums = $this->adb->num_rows($result);
        $list = [];
        $subTotal = [];
        $nums_sub = 0;
        if ($nums >= 1) {
            //@edit:liushuai,2020-12-10,reason:43656: （https://61mis.com/WX/kh40954 [^] ）（重庆维普资讯）销售提成报表-业务员的姓名没有正常显示
            $userobj = new Users();
            for ($i = 0; $i < $nums; $i++) {
                $userobj->wx_userid = $this->adb->query_result($result, $i, 'wx_userid');
                $userobj->last_name = $this->adb->query_result($result, $i, 'smownerid');
                $last_name = getUserlastName($userobj);

                $order_id = $this->adb->query_result($result, $i, 'order_id');
                $accountid = $this->adb->query_result($result, $i, 'accountid');
                if (!isset($subTotal[$last_name])) {
                    $nums_sub = 1;
                } else {
                    $nums_sub += 1;
                }

                $list[$i]["order"] = $i;
                $list[$i]["order_id"] = $order_id;
                $list[$i]["accountid"] = $accountid;
                $subTotal[$last_name]["order"] = $i + 0.5;
                $subTotal["合计"]["order"] = $i + 1;
                $subTotal[$last_name]["is_count"] = 1;
                $subTotal['合计']["is_count"] = 1;

                foreach ($this->showcolLists as $fieldName => $v) {
                    $fieldName = explode(':', $fieldName)[0];
                    $start_len = strpos($fieldName, '_') + 1;
                    $fieldName = substr($fieldName, $start_len);

                    if ($fieldName == 'smownerid') {
                        $subTotal[$last_name][$fieldName] = $last_name . '-' . getFixedLabel('SUBTOTAL');
                        $subTotal["合计"][$fieldName] = getFixedLabel('TOTAL');
                        $list[$i][$fieldName] = $last_name;
                    } else {
                        $list[$i][$fieldName] = $this->adb->query_result($result, $i, $fieldName);
                    }

                    if (in_array($fieldName, ['total', 'total_yj', 'total_fy', 'total_cost', 'yeji', 'ticheng','tichengof1','tichengof9','overfloorprice'])) {
                        $subTotal[$last_name][$fieldName] += $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] += $list[$i][$fieldName];
                    }
                    if (in_array($fieldName, ['salesorder_no', 'signed_data', 'account_id', 'stockpresence', 'salesorder_no'])) {
                        $subTotal[$last_name][$fieldName] = '-';
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    if ($fieldName == 'done_rate' || $fieldName == 'target') {
                        $subTotal[$last_name][$fieldName] = $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = '-';
                    }
                    if ($fieldName == 'ticheng_rate') {
                        $subTotal[$last_name][$fieldName] = $list[$i][$fieldName];
                        $subTotal["合计"][$fieldName] = '-';
                    }
                }
            }
            $subTotal = array_values($subTotal);

            $list = array_merge($subTotal, $list);
            $sort = _array_column($list, "order");

            array_multisort($sort, SORT_ASC, $list);
            foreach ($list as $k => $v) {
                $style = '';
                $class = 'lvtColData';
                if($k%2==0){
                    $class = 'lvtColDataBj';
                }
                if ($v['is_count'] == 1) {
                    $style = "style='background-color:#f0f4fc;'";
                }
                $order_id = $v['order_id'];
                $accountid = $v['accountid'];
                $module_order = getSalesEntityType($order_id);
                $a_order = '<a lasturl="" module="' . $module_order . '" record="' . $order_id . '" href="index.php?pageto_module=' . $module_order . '&pageto_action=index&pageto_record=' . $order_id . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $v['salesorder_no'] . '">' . $v['salesorder_no'] . '</a>';
                $a_account = '<a lasturl="" module="Accounts" record="' . $accountid . '" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record=' . $accountid . '" onclick="ListLinkClick(ld(this),event)" add_url_getvalue="" title="' . $v['account_id'] . '">' . $v['account_id'] . '</a>';
                $html .= '<tr id="report_'.$k.'" '.$style.' class="'.$class.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
                foreach ($v as $kk => $vv) {
                    if ($kk != "order" && $kk != "is_count" && $kk != "order_id" && $kk != "accountid") {
                        if ($kk == "salesorder_no") {
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_order . '</a></td>';
                        } else if ($kk == "account_id") {
                            $html .= "<td style='text-align:left' valign='top'><a href=''>" . $a_account . '</a></td>';
                        } else if (in_array($kk, ['total', 'total_yj', 'total_fy', 'total_cost', 'yeji', 'ticheng', 'ticheng_rate','tichengof1','tichengof9','overfloorprice'])) {
                            $html .= "<td style='text-align:right' valign='top'>" . number_format($vv, 2) . '</td>';
                        } else if ($kk == "done_rate" || $kk == "target") {
                            if ($v['is_count'] == 1) {
                                $html .= "<td style='text-align:right' valign='top'>" . $vv . '</td>';
                            } else {
                                $html .= "<td style='text-align:right' valign='top'>-</td>";
                            }
                        } else {
                            $html .= "<td style='text-align:left' valign='top'>" . $vv . '</td>';
                        }
                    }
                }
                $html .= "</tr>";
            }
        } else {

            $html .= "<tr>";
            foreach ($this->showcolLists as $fieldName => $v) {
                $html .= "<td style='text-align:left' valign='top'>-</td>";
            }
            $html .= "</tr>";
        }
        return $html;
    }

    public function getCommissionByOrder($start_date, $end_date, $jititype, $costtype, $fee_range, $order_range, $accountname, $ordernum, $data_range, $account_type = '1')
    {
        // "1" => getFixedLabel("ALL"),//"全部",
        // "2"=>getFixedLabel("DirectOrder"),//"直销订单",
        // "3"=>getFixedLabel("DealerOrder")//"经销商订单",
        $accounttypeWhere = '';
        if ($account_type == 3) {
            $accounttypeWhere = " where (ld_account.account_type='经销商') ";
        } else if ($account_type == 2) {
            $accounttypeWhere = " where ld_account.account_type!='经销商' ";
        }
        return "SELECT last_name as smownerid,wx_userid,
	    CASE
		WHEN order_id>0 THEN order_id
		ELSE '00'
	    END AS order_id,
	    CASE
		WHEN accountid>0 THEN accountid
		ELSE '00'
	    END AS accountid,
	    order_no as salesorder_no,
	    stockpresence,
	    signed_data,
	    accountname  as account_id,
        total_display,
        total_rmb as total,
        total_fy,
        total_yj,tichengof9,tichengof1,overfloorprice,
        total_cost,
        ROUND(contractamount,2) AS target,
        yeji,
        b.done_toal,
        b.done_rate,
        b.ticheng_rate,
        ROUND(a.yeji*b.ticheng_rate*0.01,2) AS ticheng
    FROM (
	    (SELECT
		smownerid,
		wx_userid,
		last_name,
		1 AS order2,
		order_id,
		accountid,account_type,
		order_no,
		stockpresence,
		signed_data,
		accountname,
		CONCAT(currency_symbol,FORMAT(IFNULL(total,0),2)) AS total_display,
		ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2) AS total_rmb,
		ROUND(IFNULL(total_fy,0),2) AS total_fy,
		ROUND(IFNULL(total_yj,0),2) AS total_yj,
		ROUND(IFNULL(total_cost,0),2) AS total_cost,
		CASE
			WHEN '$jititype'='1' THEN	
				ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)
			WHEN '$jititype'='2' THEN	
				ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_fy,0),2)-ROUND(IFNULL(total_yj,0),2)
			WHEN '$jititype'='3' THEN
				ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_fy,0),2)-ROUND(IFNULL(total_yj,0),2)-ROUND(IFNULL(total_cost,0),2)
		END AS yeji,
		CASE
			WHEN '$jititype'='1' THEN	
				ROUND(ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)*'$rate'/100,2)
			WHEN '$jititype'='2' THEN	
				ROUND((ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_fy,0),2)-ROUND(IFNULL(total_yj,0),2))*'$rate'/100,2)
			WHEN '$jititype'='3' THEN
				ROUND((ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_fy,0),2)-ROUND(IFNULL(total_yj,0),2)-ROUND(IFNULL(total_cost,0),2))*'$rate'/100,2)
		END AS ticheng,
		CASE
		    account_type
			WHEN '经销商' THEN	
				ROUND(ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)*0.08*0.9,2)
			ELSE	
				ROUND((ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_fy,0),2)-ROUND(IFNULL(total_yj,0),2)-ROUND(IFNULL(total_cost,0),2))*0.4*0.9,2)
		END AS tichengof9,
		CASE
		    account_type
			WHEN '经销商' THEN	
				ROUND(ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)*0.08*0.1,2)
			ELSE	
				ROUND((ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_fy,0),2)-ROUND(IFNULL(total_yj,0),2)-ROUND(IFNULL(total_cost,0),2))*0.4*0.1,2)
		END AS tichengof1,
		ROUND(IFNULL(total,0)/IFNULL(conversion_rate,1),2)-ROUND(IFNULL(total_cost,0),2) as overfloorprice
	FROM (
		SELECT
			a.smownerid,
			b.last_name,
			b.wx_userid,
			a.order_id,
			a.accountid,
			ld_account.account_type,
			a.order_no,
			a.stockpresence,
			a.signed_data,
			a.total,
			a.currency_symbol,
			a.conversion_rate,
			CASE
				WHEN '$costtype'='1' THEN c.productcost
				WHEN '$costtype'='2' THEN f.total
				WHEN '$costtype'='3' THEN g.total
				WHEN '$costtype'='4' THEN h.total
			END AS total_cost,
			d.rmb_total AS total_fy,
			e.total_yj,
			ld_account.accountname,
			a.deleted,
			a.order_status,
			a.approvestatus	
		FROM (
			SELECT
				smownerid,
				salesorderid AS order_id,
				salesorder_no AS order_no,
				stockpresence,
				signed_data,
				sostatus AS order_status,
				accountid,
				deleted,
				approvestatus,
				currency_symbol,
				conversion_rate,
				total
			FROM ld_salesorder
			WHERE deleted=0
				AND IFNULL(approvestatus,'')<>'已拒绝'
			UNION ALL
			SELECT
				smownerid,
				servicecontractsid,
				contract_no,
				stockpresence,
				due_date,
				contract_status,
				accountid,
				deleted,
				approvestatus,
				currency_symbol,
				conversion_rate,
				total
			FROM ld_servicecontracts
			WHERE deleted=0
				AND IFNULL(approvestatus,'')<>'已拒绝'
		) a
		LEFT JOIN ld_users b ON a.smownerid=b.id
		LEFT JOIN ld_account ON a.accountid=ld_account.accountid
		LEFT JOIN (
			SELECT
				id,	
				SUM(productcost) AS productcost
			FROM (
				SELECT
					a.salesorderid AS id,
					CASE 
						WHEN IFNULL(b.productcost,0)<>0 THEN ROUND(b.quantity*b.productcost,2)/IFNULL(a.conversion_rate,1)
						ELSE ROUND(b.quantity*IFNULL(c.costprice,0),2)
					END AS productcost
				FROM ld_salesorder a
				LEFT JOIN ld_salesorderdetail b ON a.salesorderid=b.id
				LEFT JOIN ld_products c ON c.productid=b.productid 
				WHERE a.deleted=0
					AND a.approvestatus<>'已拒绝'
				UNION ALL
				SELECT
					a.servicecontractsid,
					CASE 
						WHEN IFNULL(b.productcost,0)<>0 THEN ROUND(b.quantity*b.productcost,2)/IFNULL(a.conversion_rate,1)
						ELSE ROUND(b.quantity*IFNULL(c.costprice,0),2)
					END AS productcost
				FROM ld_servicecontracts a
				LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
				LEFT JOIN ld_products c ON c.productid=b.productid 
				WHERE a.deleted=0
					AND a.approvestatus<>'已拒绝'
			) a
			GROUP BY id
		) c ON a.order_id=c.id
		LEFT JOIN (
			SELECT
				b.entitytypeid,
				SUM(c.rmb_total) AS rmb_total
			FROM ld_expense a
			LEFT JOIN ld_expensedetail b ON a.expenseid=b.expenseid
			LEFT JOIN ld_expensedetailscf c ON c.expensedetailid=b.expensedetailid
			WHERE a.deleted=0
				AND b.entitytype in ('SalesOrder','ServiceContracts')
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND (
					CASE
						WHEN '$fee_range'='false' THEN 1=1
						ELSE a.approvestatus='已批准'
					END)
			GROUP BY b.entitytypeid
		) d ON d.entitytypeid=a.order_id
		LEFT JOIN (
			SELECT
				b.entitytypeid,
				SUM(ROUND(b.amount/IFNULL(a.conversion_rate,1),2)) AS total_yj
			FROM ld_commission a
			LEFT JOIN ld_commission2payment b ON a.commission_id=b.commission_id
			WHERE a.deleted=0
				AND b.entitytype in ('SalesOrder','ServiceContracts')
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND (
					CASE
						WHEN '$fee_range'='false' THEN 1=1
						ELSE a.approvestatus='已批准'
					END)
			GROUP BY b.entitytypeid
		) e ON e.entitytypeid=a.order_id
		LEFT JOIN (
			SELECT
				SUM(ROUND(b.tax_amount/IFNULL(a.conversion_rate,1),2)) AS total,
				b.entitytypeid
			FROM ld_purchaseorder a
			LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
			WHERE a.deleted=0
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND IFNULL(a.postatus,'')<>'已作废'
				AND b.entitytypeid>0
			GROUP BY b.entitytypeid
		) f ON f.entitytypeid=a.order_id	
		LEFT JOIN (
			SELECT
				a.orderid,
				SUM(ROUND(a.quantity*IFNULL(b.costprice,0),2)) AS total
			FROM (
				SELECT
					a.salesorderid AS orderid,
					b.productid,
					b.quantity
				FROM ld_salesorder a
				LEFT JOIN ld_salesorderdetail b ON a.salesorderid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
				UNION ALL
				SELECT
					a.servicecontractsid,
					b.productid,
					b.quantity
				FROM ld_servicecontracts a
				LEFT JOIN ld_servicecontractsdetail b ON a.servicecontractsid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
			) a
			LEFT JOIN (
				SELECT
					b.productid,
					SUM(b.tax_amount/IFNULL(a.conversion_rate,1))/SUM(b.quantity) AS costprice
				FROM ld_purchaseorder a
				LEFT JOIN ld_purchaseorderdetail b ON a.purchaseorderid=b.id
				WHERE a.deleted=0
					AND IFNULL(a.approvestatus,'')<>'已拒绝'
					AND IFNULL(a.postatus,'')<>'已作废'
				GROUP BY b.productid
			) b ON b.productid=a.productid
			GROUP BY a.orderid
		) g ON g.orderid=a.order_id
		LEFT JOIN (
			SELECT
				SUM(ROUND(b.tax_amount/IFNULL(a.conversion_rate,1),2)) AS total,
				b.entitytypeid
			FROM ld_outboundorder a
			LEFT JOIN ld_outboundorderdetail b ON a.out_id=b.id
			WHERE a.deleted=0
				AND IFNULL(a.approvestatus,'')<>'已拒绝'
				AND b.entitytypeid>0
			GROUP BY b.entitytypeid
		) h ON h.entitytypeid=a.order_id
		$accounttypeWhere
	) t
	WHERE deleted=0
		AND IFNULL(order_status,'')<>'已作废'
		AND IFNULL(approvestatus,'')<>'已拒绝'
		AND signed_data BETWEEN DATE_FORMAT('$start_date','%Y-%m-%d') AND DATE_FORMAT('$end_date','%Y-%m-%d')
		AND (
			CASE
				WHEN '$order_range'='false' THEN	1=1
				ELSE approvestatus='已批准'		
			END)
		AND (
			CASE
				WHEN '$accountname'='' THEN	1=1
				ELSE accountname like '%$accountname%'		
			END)
		AND (
			CASE
				WHEN '$ordernum'='' THEN	1=1
				ELSE order_no like '%$ordernum%'		
			END)
	) 
	)a
LEFT JOIN (
	SELECT
		smownerid AS ownerid,
		done_toal,
		contractamount,
		done_rate,
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='byOrder') THEN
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='万元' AND bytype='byOrder' AND t.done_toal>=`start`*10000 AND t.done_toal<`end`*10000  ORDER BY `start` LIMIT 1)
			ELSE 
				(SELECT commission_rate FROM ld_userreport_commissionrule WHERE is_on='yes' AND unit='%' AND bytype='byOrder' AND t.done_rate>=`start` AND t.done_rate<`end` ORDER BY `start` LIMIT 1)
		END AS ticheng_rate
	FROM (
		SELECT
			a.smownerid,
			a.done_toal,
			CASE
				WHEN IFNULL(b.contractamount,0)=0 THEN 0
				ELSE b.contractamount
			END AS contractamount,
			CASE
				WHEN IFNULL(b.contractamount,0)=0 THEN 0
				ELSE ROUND(a.done_toal*100/IFNULL(b.contractamount,0),2)
			END AS done_rate
		FROM (
			SELECT
				a.smownerid,
				ROUND(SUM(a.total),2) AS done_toal
			FROM (
				SELECT
					smownerid,
					total/IFNULL(conversion_rate,1) AS total
				FROM ld_salesorder
				WHERE deleted=0
					AND IFNULL(approvestatus,'')<>'已拒绝'
					AND signed_data BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
				UNION ALL
				SELECT
					smownerid,
					total/IFNULL(conversion_rate,1) AS total
				FROM ld_servicecontracts
				WHERE deleted=0
					AND IFNULL(approvestatus,'')<>'已拒绝'
					AND due_date BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
			) a
			GROUP BY a.smownerid
		) a
		LEFT JOIN (
			SELECT
				userid,
				SUM(contractamount) contractamount,
				SUM(paymentamount) AS paymentamount 
			FROM (SELECT * FROM ld_salestarget GROUP BY userid,targetyear,targetmouth) ld_salestarget 
			WHERE DATE_FORMAT(CONCAT(targetyear,'-',targetmouth,'-01'),'%Y-%m-%d') BETWEEN DATE_ADD(DATE_FORMAT('$start_date','%Y-%m-%d'),INTERVAL - DAY('$start_date')+1 DAY) AND LAST_DAY(DATE_FORMAT('$end_date','%Y-%m-%d'))
			GROUP BY userid
		) b ON b.userid=a.smownerid
	) t
) b ON b.ownerid=a.smownerid
WHERE FIND_IN_SET(smownerid,'$data_range')
		AND (
			CASE
				WHEN '$accountname'='' THEN	1=1
				ELSE accountname like '%$accountname%'		
			END)
ORDER BY CONVERT(last_name USING GBK),order2,signed_data,order_no";

    }
}