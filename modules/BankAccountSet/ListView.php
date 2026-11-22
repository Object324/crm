<?php
global  $adb;



$sql="UPDATE ld_bankaccountset a
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_cashbill a
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=83 AND deploy_value=0) THEN 1=1
				ELSE a.approvestatus='已批准'
			END)
	GROUP BY a.bankaccountsetid
) s1 ON a.Bankaccountsetid=s1.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS Total
	FROM ld_sendcashbill a
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=84 AND deploy_value=0) THEN 1=1
				ELSE a.approvestatus='已批准'
			END)
	GROUP BY a.bankaccountsetid
) z1 ON a.Bankaccountsetid=z1.bankaccountsetid
LEFT JOIN (
	SELECT
		a.inaccount,
		SUM(a.cashmoney) AS total
	FROM ld_cashdeposit a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.inaccount
) s2 ON a.Bankaccountsetid=s2.inaccount
LEFT JOIN (
	SELECT
		a.Outaccount,
		SUM(a.cashmoney) AS total
	FROM ld_cashdeposit a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.Outaccount
) z2 ON a.Bankaccountsetid=z2.Outaccount
LEFT JOIN (
	SELECT
		a.inaccount,
		SUM(a.cashmoney) AS total
	FROM ld_putcash a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.inaccount
) s3 ON a.Bankaccountsetid=s3.inaccount
LEFT JOIN (
	SELECT
		a.Outaccount,
		SUM(a.cashmoney) AS total
	FROM ld_putcash a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.Outaccount
) z3 ON a.Bankaccountsetid=z3.Outaccount
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_purchasecashback a
	WHERE a.deleted=0
	GROUP BY a.bankaccountsetid
) s4 ON a.Bankaccountsetid=s4.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_cashback a
	WHERE a.deleted=0
	GROUP BY a.bankaccountsetid
) z4 ON a.Bankaccountsetid=z4.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_expense a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.bankaccountsetid
) z5 ON a.Bankaccountsetid=z5.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_commission a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.bankaccountsetid
) z6 ON a.Bankaccountsetid=z6.bankaccountsetid
SET a.curbalancemoney=IFNULL(a.InitMoney,0)+IFNULL(s1.total,0)+IFNULL(s2.total,0)+IFNULL(s3.total,0)
+IFNULL(s4.total,0)-IFNULL(z1.total,0)-IFNULL(z2.total,0)-IFNULL(z3.total,0)
-IFNULL(z4.total,0)-IFNULL(z5.total,0)-IFNULL(z6.total,0) ";
 $adb->pquery(html_entity_decode($sql),array());
 

 
require_once('modules/lingdang/ListView.php');

?>