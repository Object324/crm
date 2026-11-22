alter table `ld_sendcashbill` alter currency_id set default 1;
alter table `ld_sendcashbill` alter conversion_rate set default 1;
alter table `ld_sendcashbill` alter currency_symbol set default '¥';

UPDATE ld_sendcashbill SET currency_id=1,conversion_rate=1,currency_symbol='¥' WHERE IFNULL(currency_id,0) IN (0,'');

UPDATE ld_bankaccountset a
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.Total) AS Total
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
		SUM(a.Total) AS Total
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
SET a.curbalancemoney=IFNULL(a.InitMoney,0)+IFNULL(s1.Total,0)+IFNULL(s2.Total,0)+IFNULL(s3.Total,0)+IFNULL(s4.Total,0)-IFNULL(z1.Total,0)-IFNULL(z2.Total,0)-IFNULL(z3.Total,0)-IFNULL(z4.Total,0)-IFNULL(z5.Total,0)-IFNULL(z6.Total,0);
delimiter;
-- 2020-04-22

UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
UPDATE ld_links_seq SET id=(SELECT MAX(linkid) FROM ld_links);
UPDATE ld_picklist_dependency_seq SET id=(SELECT MAX(id) FROM ld_picklist_dependency);
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) FROM ld_autotask);
UPDATE ld_currency_info_seq SET id=(SELECT MAX(id) FROM ld_currency_info);
UPDATE ld_users_seq SET id=(SELECT MAX(id) FROM ld_users);
UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
UPDATE ld_customreport_info_seq SET id=(SELECT MAX(report_id) FROM ld_customreport_info);
UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V7.9.9.16',current_version='V7.9.9.16',remark='V7.9.9.16-20200422',wx_version='V8.0.0.8';
delimiter;