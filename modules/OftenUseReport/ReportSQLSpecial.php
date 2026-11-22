<?php
/*
 * 客户报表特殊开发
 *
 * */
class ReportSQLSpecial
{
    //应收款统计表_按出库统计
    static function getCashBillSum_Outboundorder_Zhongwu($where,$whereServiceContracts,$wherePaymentBalance)
    {
        //echo $wherePaymentBalance;
        global $adb;
        $SQL="CREATE TEMPORARY TABLE
            IF NOT EXISTS temptable6 IGNORE (
			SELECT 
        DISTINCT ld_usersOutboundOrder.last_name AS OutboundOrder_smownerid,
		ld_usersOutboundOrder.last_name AS OutboundOrder_smownerid2,
		ld_group.groupname AS OutboundOrder_groupname,
		ld_group.groupid AS report_wx_groupid,
		ld_usersOutboundOrder.wx_userid AS report_wx_userid,
		ld_outboundorder.out_no AS OutboundOrder_out_no,
		ld_outboundorder.outdate AS OutboundOrder_outdate,
		ld_outboundorder.createdtime AS OutboundOrder_CreatedTime,
		ld_accountoutboundorder.accountname AS OutboundOrder_accountid,
        ld_accountoutboundorder.accountid AS OutboundOrder_accountid_id,
		ld_outboundorder.presence AS 'OutboundOrder_presence',
		ld_outboundorder.total AS 'OutboundOrder_Total',
        ld_outboundorder.currency_id AS OutboundOrder_Curid,
		ld_outboundorder.conversion_rate AS OutboundOrder_Rate,
		ld_outboundorder.currency_symbol AS OutboundOrder_Symbol,
        ld_outboundorder.out_id as id,
        ROUND(SUM(CASE WHEN ld_customform01.approvestatus = '已批准' AND ld_customform01.deleted = 0 THEN ld_customform01scf.cf_4411 ELSE 0 END),10) AS OutboundOrder_cf_4411,
		concat(ld_outboundorder.out_id,'C') AS LBL_ACTION
        FROM
		ld_outboundorder
	LEFT JOIN ld_account AS ld_accountoutboundorder ON ld_accountoutboundorder.accountid = ld_outboundorder.accountid
	LEFT JOIN ld_users AS ld_usersOutboundOrder ON ld_usersOutboundOrder.id = ld_outboundorder.smownerid
	LEFT JOIN ld_customform01 ON ld_outboundorder.out_id = ld_customform01.outboundorder_id
	LEFT JOIN ld_customform01scf ON ld_customform01.customform01id = ld_customform01scf.customform01id
	LEFT JOIN (
		select GROUP_CONCAT(ld_groups.groupname) as groupname,GROUP_CONCAT(ld_groups.groupid) as groupid,ld_users2group.userid from ld_users2group
		LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
		GROUP BY ld_users2group.userid
	) as ld_group on ld_group.userid = ld_outboundorder.smownerid
	WHERE
		ld_outboundorder.out_id > 0
	       AND ld_outboundorder.approvestatus != '已拒绝' 
	       AND ld_outboundorder.deleted = 0 ".str_replace('%s', 'ld_outboundorder', $where).
            " GROUP BY ld_outboundorder.out_id ORDER BY
		      OutboundOrder_smownerid ASC,
		      OutboundOrder_CreatedTime ASC
            );";
        $adb->query($SQL);
//        echo $SQL.'<br><br>';
        $SQL="CREATE TEMPORARY TABLE
                IF NOT EXISTS temptable IGNORE (
                SELECT * FROM (SELECT * FROM temptable6) as f2
            );";
        $adb->query($SQL);
        // echo $SQL.'<br><br>';

        $SQL="CREATE TEMPORARY TABLE IF NOT EXISTS temptable1 IGNORE (
                    SELECT
                    	*
                    FROM (
                    	SELECT
                    		out_id,
                    		received_amount AS total
                    	FROM
                    		ld_outboundorder
						LEFT JOIN ld_account AS ld_accountoutboundorder ON ld_accountoutboundorder.accountid = ld_outboundorder.accountid
                    	WHERE
                    		ld_outboundorder.deleted = 0 and ld_outboundorder.approvestatus != '已拒绝' 
	       AND ld_outboundorder.deleted = 0 ".str_replace('%s', 'ld_outboundorder', $where).")a);";
        $adb->query($SQL);
        //echo $SQL.'<br><br>';

        $SQL="Create TEMPORARY table IF NOT EXISTS temptable2 ignore( 	SELECT
            		OutboundOrder_smownerid,
            		OutboundOrder_smownerid2,
					OutboundOrder_groupname,
					report_wx_groupid,
					report_wx_userid,
            		OutboundOrder_out_no,
            		OutboundOrder_accountid,
                    OutboundOrder_accountid_id,
            		OutboundOrder_presence,
            		OutboundOrder_outdate,
            		OutboundOrder_CreatedTime,
            		OutboundOrder_Total AS OutboundOrder_Total,
                    OutboundOrder_Curid,
                    OutboundOrder_Rate,
                    OutboundOrder_Symbol,
            		IFNULL(temptable1.total, 0) AS oftenusereport_CashBillamount,
            		(
                    if(OutboundOrder_Curid > 1,IFNULL(OutboundOrder_Total, 0)/OutboundOrder_Rate,IFNULL(OutboundOrder_Total, 0))
            			 - IFNULL(temptable1.total, 0) + IFNULL(OutboundOrder_cf_4411,0)
            		) AS oftenusereport_PaymentBalance,
            		OutboundOrder_cf_4411 AS OutboundOrder_cf_4411,
            		LBL_ACTION
            	FROM
            		temptable
            	LEFT JOIN temptable1 ON temptable.id = temptable1.out_id
            	GROUP BY
            		OutboundOrder_smownerid,
            		OutboundOrder_out_no,
            		OutboundOrder_accountid,
                    OutboundOrder_accountid_id,
            		OutboundOrder_presence,
            		OutboundOrder_CreatedTime,
            		OutboundOrder_Total,
                    OutboundOrder_Curid,
                    OutboundOrder_Rate,
                    OutboundOrder_Symbol
                $wherePaymentBalance);
                    ";
        $adb->query($SQL);
        //  echo $SQL.'<br><br>';
        $SQL="Create TEMPORARY table IF NOT EXISTS temptable3 ignore( SELECT '".getFixedLabel('SUBTOTAL')."' OutboundOrder_smownerid,concat(OutboundOrder_smownerid,' :小计') OutboundOrder_smownerid2,'' OutboundOrder_groupname, '' report_wx_groupid,'' report_wx_userid,'' OutboundOrder_out_no,'' OutboundOrder_accountid,'' OutboundOrder_accountid_id,'' OutboundOrder_presence,
                    null OutboundOrder_outdate,null OutboundOrder_CreatedTime, sum(if(OutboundOrder_Curid > 1,OutboundOrder_Total/OutboundOrder_Rate,OutboundOrder_Total)) OutboundOrder_Total,OutboundOrder_Curid,OutboundOrder_Rate,OutboundOrder_Symbol,sum(oftenusereport_CashBillamount) oftenusereport_CashBillamount,sum(oftenusereport_PaymentBalance) oftenusereport_PaymentBalance,sum(OutboundOrder_cf_4411) OutboundOrder_cf_4411,
                    null LBL_ACTION FROM temptable2 
                    group by OutboundOrder_smownerid );";
        $adb->query($SQL);
        // echo $SQL.'<br><br>';
        $SQL=" create TEMPORARY table IF NOT EXISTS temptable4 ignore( select * from (select * from temptable2 union select * from temptable3 order by OutboundOrder_smownerid2,OutboundOrder_outdate) as temp);";
        $adb->query($SQL);
        // echo $SQL.'<br><br>';
        $SQL=" select OutboundOrder_smownerid,OutboundOrder_smownerid2,OutboundOrder_groupname,report_wx_groupid,
					report_wx_userid,OutboundOrder_out_no,OutboundOrder_outdate,OutboundOrder_CreatedTime,OutboundOrder_accountid,OutboundOrder_accountid_id,
            OutboundOrder_presence, OutboundOrder_Total ,OutboundOrder_Curid,OutboundOrder_Rate,OutboundOrder_Symbol,oftenusereport_PaymentBalance ,
            oftenusereport_CashBillamount ,OutboundOrder_cf_4411,LBL_ACTION from temptable4 union 
            select '".getFixedLabel('TOTAL')."','合计','','','','','','','','','',sum(if(OutboundOrder_Curid > 1,OutboundOrder_Total/OutboundOrder_Rate,OutboundOrder_Total)) OutboundOrder_Total,'','','¥',
           sum(oftenusereport_PaymentBalance) oftenusereport_PaymentBalance,sum(oftenusereport_CashBillamount) oftenusereport_CashBillamount,sum(OutboundOrder_cf_4411) OutboundOrder_cf_4411,'' 
            from temptable2;";
        //echo $SQL.'<br><br>';
        return $SQL;
    }
}