<?php
/* gyq_17 */
class cls_MainReportSQL
{
    //签约数量
    public function Contractnumber($where, $whereServiceContracts)
    {
		if(vtlib_isModuleActive("SalesOrder") && vtlib_isModuleActive("ServiceContracts")){
			$SQL = "
			   SELECT
				  SalesOrder_smownerid as user_last_name,
				  SalesOrder_groupname as groupname,
				  count(1) as cnt,
				  userid,
                  report_wx_groupid,
                  report_wx_userid
			   FROM
				  (
				SELECT
					DISTINCT ld_salesorder.salesorderid AS SalesOrder_ID,
					ld_users.last_name AS 'SalesOrder_smownerid',
                    ld_users.wx_userid as report_wx_userid,
					ld_group.groupname AS SalesOrder_groupname,
                    ld_group.groupid AS  report_wx_groupid,
					ld_salesorder.createdtime AS SalesOrder_Created_Time,
					ld_salesorder.salesorderid AS LBL_ACTION,
					ld_users.id userid
				FROM
					ld_salesorder
				LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_salesorder.currency_id
				LEFT JOIN ld_salesorderdetail AS ld_inventoryproductrelsalesorder ON ld_salesorder.salesorderid = ld_inventoryproductrelsalesorder.id
				LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
				LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
				LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_salesorder.contactid
				LEFT JOIN ld_quotes AS ld_quotessalesorder ON ld_quotessalesorder.quoteid = ld_salesorder.quoteid
				LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
				LEFT JOIN ld_potential AS ld_potentialsalesorder ON ld_potentialsalesorder.potentialid = ld_salesorder.potentialid
				LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_salesorder.salesorderid
				LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_salesorder.smownerid
				LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_salesorder.smownerid
				LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
				LEFT JOIN ld_users AS ld_lastmodifiedbysalesorder ON ld_lastmodifiedbysalesorder.id = ld_salesorder.modifiedby
				LEFT JOIN (
					select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc) as groupname,
                    GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc ) as groupid,
                    ld_users2group.userid from ld_users2group
					LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
					GROUP BY ld_users2group.userid
				) as ld_group on ld_group.userid = ld_salesorder.smownerid
				WHERE
					ld_salesorder.salesorderid > 0
				AND ld_salesorder.deleted = 0 
				AND ld_salesorder.sostatus <> '已作废'  and ld_salesorder.approvestatus<>'已拒绝' " . str_replace('%s', 'ld_salesorder', $where) . "
				UNION  ALL
				SELECT
					DISTINCT ld_servicecontracts.servicecontractsid AS SalesOrder_ID,
					ld_users.last_name AS SalesOrder_smownerid,
                    ld_users.wx_userid as report_wx_userid,
					ld_group.groupname AS SalesOrder_groupname,
                    ld_group.groupid as report_wx_groupid,
					ld_servicecontracts.createdtime AS SalesOrder_Created_Time,
					ld_servicecontracts.servicecontractsid AS LBL_ACTION,
					ld_users.id userid
				FROM
					ld_servicecontracts
				LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_servicecontracts.currency_id
				LEFT JOIN ld_servicecontractsdetail AS ld_inventoryproductrelsalesorder ON ld_servicecontracts.servicecontractsid = ld_inventoryproductrelsalesorder.id
				LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
				LEFT JOIN ld_servicecontractscf ON ld_servicecontracts.servicecontractsid  = ld_servicecontractscf.servicecontractsid
				LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_servicecontracts.contactid
				LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
				LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_servicecontracts.servicecontractsid
				LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_servicecontracts.smownerid
				LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_servicecontracts.smownerid
				LEFT JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid
				LEFT JOIN ld_users AS ld_lastmodifiednysalesorder ON ld_lastmodifiednysalesorder.id = ld_servicecontracts.modifiedby
				LEFT JOIN (
					select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc) as groupname,
                    GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc) as groupid,
                    ld_users2group.userid from ld_users2group
					LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
					GROUP BY ld_users2group.userid
				) as ld_group on ld_group.userid = ld_servicecontracts.smownerid
				WHERE
				ld_servicecontracts.servicecontractsid > 0
				AND ld_servicecontracts.deleted = 0
				AND ld_servicecontracts.contract_status <> '已作废' and ld_servicecontracts.approvestatus<>'已拒绝'
				 " . str_replace('%s', 'ld_servicecontracts', $whereServiceContracts) . "
				ORDER BY
					SalesOrder_smownerid ASC

			  ) AS a
		   GROUP BY
			  a.SalesOrder_smownerid
		   ORDER BY
			  cnt DESC
			";
			//editor:gyq_20190314 0036622: （落落计划）企业微信、微信小程序>灵当CRM>报表>签约金额龙虎榜：排序方式没有按照金额从大到小排列。（需要补丁）
		}else{
			if(vtlib_isModuleActive("SalesOrder")){
				$SQL = "
				   SELECT
					  SalesOrder_smownerid as user_last_name,
					  SalesOrder_groupname as groupname,
					  count(1) as cnt,
					  userid,
                       report_wx_groupid,
                     report_wx_userid
				   FROM
					  (
					SELECT DISTINCT
						DISTINCT ld_salesorder.salesorderid AS 'SalesOrder_ID',
						ld_users.last_name AS 'SalesOrder_smownerid',
                        ld_users.wx_userid as report_wx_userid,
						ld_group.groupname AS 'SalesOrder_groupname',
                        ld_group.groupid AS 'report_wx_groupid',
						ld_salesorder.createdtime AS 'SalesOrder_Created_Time',
						ld_salesorder.salesorderid AS LBL_ACTION,
						ld_users.id userid
					FROM
						ld_salesorder
					LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_salesorder.currency_id
					LEFT JOIN ld_salesorderdetail AS ld_inventoryproductrelsalesorder ON ld_salesorder.salesorderid = ld_inventoryproductrelsalesorder.id
					LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
					LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
					LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_salesorder.contactid
					LEFT JOIN ld_quotes AS ld_quotessalesorder ON ld_quotessalesorder.quoteid = ld_salesorder.quoteid
					LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
					LEFT JOIN ld_potential AS ld_potentialsalesorder ON ld_potentialsalesorder.potentialid = ld_salesorder.potentialid
					LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_salesorder.salesorderid
					LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_salesorder.smownerid
					LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_salesorder.smownerid
					LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
					LEFT JOIN ld_users AS ld_lastmodifiedbysalesorder ON ld_lastmodifiedbysalesorder.id = ld_salesorder.modifiedby
					LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc  ) as groupname,
                        GROUP_CONCAT(ld_groups.groupid  order by ld_groups.groupid asc ) as groupid,
                        ld_users2group.userid from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_salesorder.smownerid
					WHERE
						ld_salesorder.salesorderid > 0
					AND ld_salesorder.deleted = 0
					AND ld_salesorder.sostatus <> '已作废'  and ld_salesorder.approvestatus<>'已拒绝' " . str_replace('%s', 'ld_salesorder', $where) . "
					ORDER BY
						SalesOrder_smownerid ASC

				  ) AS a
			   GROUP BY
				  a.SalesOrder_smownerid
			   ORDER BY
				  cnt DESC
				";
			}else{
				$SQL = "
				   SELECT
					  SalesOrder_smownerid as user_last_name,
					  SalesOrder_groupname as groupname,
					  count(1) as cnt,
					  userid,
                       report_wx_groupid,
                     report_wx_userid
				   FROM
					  (
					SELECT DISTINCT
						DISTINCT ld_servicecontracts.servicecontractsid AS 'SalesOrder_ID',
						ld_users.last_name AS 'SalesOrder_smownerid',
                        ld_users.wx_userid as report_wx_userid,
						ld_group.groupname AS 'SalesOrder_groupname',
                        ld_group.groupid as report_wx_groupid,
						ld_servicecontracts.createdtime AS 'SalesOrder_Created_Time',
						ld_servicecontracts.servicecontractsid AS LBL_ACTION,
						ld_users.id userid
					FROM
						ld_servicecontracts
					LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_servicecontracts.currency_id
					LEFT JOIN ld_servicecontractsdetail AS ld_inventoryproductrelsalesorder ON ld_servicecontracts.servicecontractsid = ld_inventoryproductrelsalesorder.id
					LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
					LEFT JOIN ld_servicecontractscf ON ld_servicecontracts.servicecontractsid  = ld_servicecontractscf.servicecontractsid
					LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_servicecontracts.contactid
					LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
					LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_servicecontracts.servicecontractsid
					LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_servicecontracts.smownerid
					LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_servicecontracts.smownerid
					LEFT JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid
					LEFT JOIN ld_users AS ld_lastmodifiednysalesorder ON ld_lastmodifiednysalesorder.id = ld_servicecontracts.modifiedby
					LEFT JOIN (
						select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc  ) as groupname,
                            GROUP_CONCAT(ld_groups.groupid  order by ld_groups.groupid asc ) as groupid,
                        ld_users2group.userid from ld_users2group
						LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
						GROUP BY ld_users2group.userid
					) as ld_group on ld_group.userid = ld_servicecontracts.smownerid
					WHERE
					ld_servicecontracts.servicecontractsid > 0 
					AND ld_servicecontracts.deleted = 0
					AND ld_servicecontracts.contract_status <> '已作废' and ld_servicecontracts.approvestatus<>'已拒绝'
					 " . str_replace('%s', 'ld_servicecontracts', $whereServiceContracts) . "
					ORDER BY
						SalesOrder_smownerid ASC

				  ) AS a
			   GROUP BY
				  a.SalesOrder_smownerid
			   ORDER BY
				  cnt DESC
				";
			}
		}
        
        return $SQL;
    }

    //签约金额
    public function Contractamount($where, $whereServiceContracts)
    {
		if(vtlib_isModuleActive("SalesOrder") && vtlib_isModuleActive("ServiceContracts")){
			$SQL = "
			   SELECT
				  SalesOrder_smownerid as user_last_name,SalesOrder_groupname as groupname,
				  IFNULL(sum(if(salesorder_curid > 1,SalesOrder_Total/salesorder_rate,SalesOrder_Total)), 0) AS cnt,
				  userid,report_wx_userid,report_wx_groupid
			   FROM
				  (
					 SELECT DISTINCT
					DISTINCT ld_salesorder.salesorderid AS 'SalesOrder_ID',
					ld_group.groupname AS 'SalesOrder_groupname',
					ld_salesorder.currency_id AS salesorder_curid,
					ld_salesorder.conversion_rate AS salesorder_rate,
					ld_salesorder.currency_symbol AS salesorder_symbol,
					ld_salesorder.total AS 'SalesOrder_Total',
					ld_salesorder.createdtime AS 'SalesOrder_Created_Time',
					ld_users.last_name AS 'SalesOrder_smownerid',
					ld_salesorder.salesorderid AS LBL_ACTION,
					ld_users.id userid,
					ld_users.wx_userid as report_wx_userid,
                    ld_group.groupids AS  report_wx_groupid
				FROM
					ld_salesorder
				LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_salesorder.currency_id
				LEFT JOIN ld_salesorderdetail AS ld_inventoryproductrelsalesorder ON ld_salesorder.salesorderid = ld_inventoryproductrelsalesorder.id
				LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
				LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
				LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_salesorder.contactid
				LEFT JOIN ld_quotes AS ld_quotessalesorder ON ld_quotessalesorder.quoteid = ld_salesorder.quoteid
				LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
				LEFT JOIN ld_potential AS ld_potentialsalesorder ON ld_potentialsalesorder.potentialid = ld_salesorder.potentialid
				LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_salesorder.salesorderid
				LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_salesorder.smownerid
				LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_salesorder.smownerid
				LEFT JOIN ld_groups ON ld_groups.groupid = ld_salesorder.smownerid
				LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
				LEFT JOIN ld_users AS ld_lastmodifiedbysalesorder ON ld_lastmodifiedbysalesorder.id = ld_salesorder.modifiedby
				LEFT JOIN (
					select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid,GROUP_CONCAT(ld_groups.groupid) AS groupids  from ld_users2group
					LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
					GROUP BY ld_users2group.userid
				) as ld_group on ld_group.userid = ld_salesorder.smownerid
				WHERE
					ld_salesorder.salesorderid > 0
				AND ld_salesorder.deleted = 0
				AND ld_salesorder.sostatus <> '已作废' and ld_salesorder.approvestatus<>'已拒绝' " . str_replace('%s', 'ld_salesorder', $where) . " 	UNION ALL
				SELECT DISTINCT
					DISTINCT ld_servicecontracts.servicecontractsid AS 'SalesOrder_ID',
					ld_group.groupname AS 'SalesOrder_groupname',
					ld_servicecontracts.currency_id AS salesorder_curid,
					ld_servicecontracts.conversion_rate AS salesorder_rate,
					ld_servicecontracts.currency_symbol AS salesorder_symbol,
					ld_servicecontracts.total AS 'SalesOrder_Total',
					ld_servicecontracts.createdtime AS 'SalesOrder_Created_Time',
					ld_users.last_name AS 'SalesOrder_smownerid',
					ld_servicecontracts.servicecontractsid AS LBL_ACTION,
					ld_users.id,
					ld_users.wx_userid as report_wx_userid,
                    ld_group.groupids AS  report_wx_groupid
				FROM
					ld_servicecontracts
				LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_servicecontracts.currency_id
				LEFT JOIN ld_servicecontractsdetail AS ld_inventoryproductrelsalesorder ON ld_servicecontracts.servicecontractsid = ld_inventoryproductrelsalesorder.id
				LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
				LEFT JOIN ld_servicecontractscf ON ld_servicecontracts.servicecontractsid = ld_servicecontractscf.servicecontractsid
				LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_servicecontracts.contactid
				LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
				LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_servicecontracts.servicecontractsid
				LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_servicecontracts.smownerid
				LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_servicecontracts.smownerid
				LEFT JOIN ld_groups ON ld_groups.groupid = ld_servicecontracts.smownerid
				LEFT JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid
				LEFT JOIN ld_users AS ld_lastmodifiedbysalesorder ON ld_lastmodifiedbysalesorder.id = ld_servicecontracts.modifiedby
				LEFT JOIN (
					select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid,GROUP_CONCAT(ld_groups.groupid) AS groupids from ld_users2group
					LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
					GROUP BY ld_users2group.userid
				) as ld_group on ld_group.userid = ld_servicecontracts.smownerid
				WHERE
					ld_servicecontracts.servicecontractsid > 0
				AND ld_servicecontracts.deleted = 0
				AND ld_servicecontracts.contract_status <> '已作废' and ld_servicecontracts.approvestatus<>'已拒绝' " . str_replace('%s', 'ld_servicecontracts', $whereServiceContracts) . " 	 ORDER BY
					SalesOrder_smownerid ASC
			) AS a
			   GROUP BY
				  a.SalesOrder_smownerid
			   ORDER BY
				  cnt DESC
			";
		}else{
			if(vtlib_isModuleActive("SalesOrder")){
				$SQL = "
				   SELECT
					  SalesOrder_smownerid as user_last_name,SalesOrder_groupname as groupname,
					  IFNULL(sum(if(salesorder_curid > 1,SalesOrder_Total/salesorder_rate,SalesOrder_Total)), 0) AS cnt,
					  userid,report_wx_userid,report_wx_groupid
				   FROM
					  (
						SELECT DISTINCT
							DISTINCT ld_salesorder.salesorderid AS 'SalesOrder_ID',
							ld_group.groupname AS 'SalesOrder_groupname',
							ld_salesorder.currency_id AS salesorder_curid,
							ld_salesorder.conversion_rate AS salesorder_rate,
							ld_salesorder.currency_symbol AS salesorder_symbol,
							ld_salesorder.total AS 'SalesOrder_Total',
							ld_salesorder.createdtime AS 'SalesOrder_Created_Time',
							ld_users.last_name AS 'SalesOrder_smownerid',
							ld_salesorder.salesorderid AS LBL_ACTION,
							ld_users.id userid,
							ld_users.wx_userid as report_wx_userid,
							ld_group.groupids AS  report_wx_groupid
						FROM
							ld_salesorder
						LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_salesorder.currency_id
						LEFT JOIN ld_salesbackdetail AS ld_inventoryproductrelsalesorder ON ld_salesorder.salesorderid = ld_inventoryproductrelsalesorder.id
						LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
						LEFT JOIN ld_salesordercf ON ld_salesorder.salesorderid = ld_salesordercf.salesorderid
						LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_salesorder.contactid
						LEFT JOIN ld_quotes AS ld_quotessalesorder ON ld_quotessalesorder.quoteid = ld_salesorder.quoteid
						LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_salesorder.accountid
						LEFT JOIN ld_potential AS ld_potentialsalesorder ON ld_potentialsalesorder.potentialid = ld_salesorder.potentialid
						LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_salesorder.salesorderid
						LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_salesorder.smownerid
						LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_salesorder.smownerid
						LEFT JOIN ld_groups ON ld_groups.groupid = ld_salesorder.smownerid
						LEFT JOIN ld_users ON ld_users.id = ld_salesorder.smownerid
						LEFT JOIN ld_users AS ld_lastmodifiedbysalesorder ON ld_lastmodifiedbysalesorder.id = ld_salesorder.modifiedby
						LEFT JOIN (
							select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid,GROUP_CONCAT(ld_groups.groupid) AS groupids from ld_users2group
							LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
							GROUP BY ld_users2group.userid
						) as ld_group on ld_group.userid = ld_salesorder.smownerid
						WHERE
							ld_salesorder.salesorderid > 0
						AND ld_salesorder.deleted = 0
						AND ld_salesorder.sostatus <> '已作废' and ld_salesorder.approvestatus<>'已拒绝' " . str_replace('%s', 'ld_salesorder', $where) . "  ORDER BY
							SalesOrder_smownerid ASC
					) AS a
					   GROUP BY
						  a.SalesOrder_smownerid
					   ORDER BY
						  cnt DESC
				";
			}else{
				$SQL = "
				   SELECT
					  SalesOrder_smownerid as user_last_name,SalesOrder_groupname as groupname,
					  IFNULL(sum(if(salesorder_curid > 1,SalesOrder_Total/salesorder_rate,SalesOrder_Total)), 0) AS cnt,
					  userid,report_wx_userid,report_wx_groupid
				   FROM
					  (
						SELECT DISTINCT
							DISTINCT ld_servicecontracts.servicecontractsid AS 'SalesOrder_ID',
							ld_group.groupname AS 'SalesOrder_groupname',
							ld_servicecontracts.currency_id AS salesorder_curid,
							ld_servicecontracts.conversion_rate AS salesorder_rate,
							ld_servicecontracts.currency_symbol AS salesorder_symbol,
							ld_servicecontracts.total AS 'SalesOrder_Total',
							ld_servicecontracts.createdtime AS 'SalesOrder_Created_Time',
							ld_users.last_name AS 'SalesOrder_smownerid',
							ld_servicecontracts.servicecontractsid AS LBL_ACTION,
							ld_users.id,
							ld_users.wx_userid as report_wx_userid,
							ld_group.groupids AS  report_wx_groupid
						FROM
							ld_servicecontracts
						LEFT JOIN ld_currency_info AS ld_currency_infosalesorder ON ld_currency_infosalesorder.id = ld_servicecontracts.currency_id
						LEFT JOIN ld_servicecontractsdetail AS ld_inventoryproductrelsalesorder ON ld_servicecontracts.servicecontractsid = ld_inventoryproductrelsalesorder.id
						LEFT JOIN ld_products AS ld_productssalesorder ON ld_productssalesorder.productid = ld_inventoryproductrelsalesorder.productid
						LEFT JOIN ld_servicecontractscf ON ld_servicecontracts.servicecontractsid = ld_servicecontractscf.servicecontractsid
						LEFT JOIN ld_contactdetails AS ld_contactdetailssalesorder ON ld_contactdetailssalesorder.contactid = ld_servicecontracts.contactid
						LEFT JOIN ld_account AS ld_accountsalesorder ON ld_accountsalesorder.accountid = ld_servicecontracts.accountid
						LEFT JOIN ld_invoice_recurring_info ON ld_invoice_recurring_info.salesorderid = ld_servicecontracts.servicecontractsid
						LEFT JOIN ld_groups AS ld_groupssalesorder ON ld_groupssalesorder.groupid = ld_servicecontracts.smownerid
						LEFT JOIN ld_users AS ld_userssalesorder ON ld_userssalesorder.id = ld_servicecontracts.smownerid
						LEFT JOIN ld_groups ON ld_groups.groupid = ld_servicecontracts.smownerid
						LEFT JOIN ld_users ON ld_users.id = ld_servicecontracts.smownerid
						LEFT JOIN ld_users AS ld_lastmodifiedbysalesorder ON ld_lastmodifiedbysalesorder.id = ld_servicecontracts.modifiedby
						LEFT JOIN (
							select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid,GROUP_CONCAT(ld_groups.groupid) AS groupids from ld_users2group
							LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
							GROUP BY ld_users2group.userid
						) as ld_group on ld_group.userid = ld_servicecontracts.smownerid
						WHERE
							ld_servicecontracts.servicecontractsid > 0
						AND ld_servicecontracts.deleted = 0
						AND ld_servicecontracts.contract_status <> '已作废' and ld_servicecontracts.approvestatus<>'已拒绝' " . str_replace('%s', 'ld_servicecontracts', $whereServiceContracts) . " 	 ORDER BY
							SalesOrder_smownerid ASC
					) AS a
					   GROUP BY
						  a.SalesOrder_smownerid
					   ORDER BY
						  cnt DESC
				";
			}
		}
        return $SQL;
    }

    //回款金额
    public function CashBillamount($where)
    {
		//已收金额计算时是否统计未审核的收款单
		$focus = CRMEntity::getInstance('CashBill');
		$checkoutstatuswhere = $focus->get_CashBillCheckoutstatusWhere();
        $SQL = 'SELECT DISTINCT
           ld_users.last_name as user_last_name,ld_group.groupname AS groupname,
          	sum(
            		if(ld_cashbill.currency_id > 1,ld_cashbill.Total/ld_cashbill.conversion_rate,ld_cashbill.Total)
            	) as cnt,
            	ld_users.id,ld_users.wx_userid as report_wx_userid,ld_group.groupids AS  report_wx_groupid
            FROM
            	ld_cashbill
            LEFT JOIN
            ld_users ON ld_users.id = ld_cashbill.smownerid
			LEFT JOIN (
				select GROUP_CONCAT(ld_groups.groupname) as groupname,ld_users2group.userid,GROUP_CONCAT(ld_groups.groupid) AS groupids from ld_users2group
				LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
				GROUP BY ld_users2group.userid
			) as ld_group on ld_group.userid = ld_cashbill.smownerid
            WHERE
            	ld_cashbill.deleted = 0
            AND ld_cashbill.smownerid > 0' . str_replace('%s', 'ld_cashbill', $where) .
            ' GROUP BY
            	smownerid ORDER BY cnt desc';
		//echo $SQL;echo '<br><br>';
        return $SQL;
    }

	function Invoiceamount($where){
		$SQL = 'SELECT DISTINCT
			ld_users.last_name AS user_last_name,
			ld_group.groupname AS groupname,
			sum(

				IF (
					ld_invoice.currency_id > 1,
					ld_invoice.Total / ld_invoice.conversion_rate,
					ld_invoice.Total
				)
			) AS cnt,
			ld_users.id,ld_users.wx_userid as report_wx_userid,ld_group.groupids AS  report_wx_groupid 
		FROM
			ld_invoice
		LEFT JOIN ld_users ON ld_users.id = ld_invoice.smownerid
		LEFT JOIN (
			SELECT
				GROUP_CONCAT(ld_groups.groupname) AS groupname,
				ld_users2group.userid,GROUP_CONCAT(ld_groups.groupid) AS groupids 
			FROM
				ld_users2group
			LEFT JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
			GROUP BY
				ld_users2group.userid
		) AS ld_group ON ld_group.userid = ld_invoice.smownerid
		WHERE
			ld_invoice.deleted = 0
		AND ld_invoice.smownerid > 0
		'. str_replace('%s', 'ld_invoice', $where) .'
		AND ifnull(
			ld_invoice.approvestatus,
			""
		) <> "已拒绝"
		GROUP BY
			smownerid
		ORDER BY
			cnt DESC';
		return $SQL;
	}

	function OutboundOrderamount($where){
		$SQL = 'SELECT DISTINCT
			ld_users.last_name AS user_last_name,
			ld_group.groupname AS groupname,
			sum(

				IF (
					ld_outboundorder.currency_id > 1,
					ld_outboundorder.Total / ld_outboundorder.conversion_rate,
					ld_outboundorder.Total
				)
			) AS cnt,
			ld_users.id,
			ld_users.wx_userid as report_wx_userid,
			ld_group.groupids as report_wx_groupid
		FROM
			ld_outboundorder
		LEFT JOIN ld_users ON ld_users.id = ld_outboundorder.smownerid
		LEFT JOIN (
			SELECT
				GROUP_CONCAT(ld_groups.groupname) AS groupname,
				ld_users2group.userid,
				GROUP_CONCAT(ld_groups.groupid) AS groupids 
			FROM
				ld_users2group
			LEFT JOIN ld_groups ON ld_groups.groupid = ld_users2group.groupid
			GROUP BY
				ld_users2group.userid
		) AS ld_group ON ld_group.userid = ld_outboundorder.smownerid
		WHERE
			ld_outboundorder.deleted = 0
		AND ld_outboundorder.smownerid > 0
		'. str_replace('%s', 'ld_outboundorder', $where) .'
		AND ifnull(
			ld_outboundorder.approvestatus,
			""
		) <> "已拒绝"
		GROUP BY
			smownerid
		ORDER BY
			cnt DESC';
		return $SQL;
	}

    //费用佣金
    public function expense_commission($where)
    {

        $SQL['expense'] = 'SELECT ld_expense.smownerid,ld_users.last_name,sum(ld_expense.total) sumtotal FROM ld_expense LEFT JOIN ld_users ON ld_users.id=ld_expense.smownerid
                  WHERE ld_expense.smownerid>0 AND ld_expense.deleted=0 ' . str_replace('%s', 'ld_expense', $where) . ' GROUP BY ld_expense.smownerid ORDER BY sumtotal DESC';
        $SQL['commission'] = 'SELECT ld_commission.smownerid,ld_users.last_name,round(sum(ld_commission.total/conversion_rate),2) sumtotal FROM ld_commission LEFT JOIN ld_users ON ld_users.id=ld_commission.smownerid
                  WHERE ld_commission.smownerid>0 AND ld_commission.deleted=0 ' . str_replace('%s', 'ld_commission', $where) . ' GROUP BY ld_commission.smownerid ORDER BY sumtotal DESC';
        return $SQL;
    }

    public function logStatistic($type,$where)
    {
        $type = ' type='.$type.' and ';
        $SQL = 'SELECT
                  ld_workreport.createdtime,
                  ld_workreport.sendlog_workdate,
                  ld_users.last_name username,
                  ld_users.wx_userid ,
                  ld_workreport.smcreatorid,
                  workplan
                FROM ld_workreport LEFT JOIN ld_users on ld_users.id = ld_workreport.smcreatorid
                WHERE '.$type.' entitytype = \'workreport\'
                ' . str_replace('%s', 'ld_workreport', $where) .'
                ORDER BY ld_workreport.sendlog_workdate ASC';
        return $SQL;
    }
}