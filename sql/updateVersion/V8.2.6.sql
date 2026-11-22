DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

CALL AddColumn('ld_customform26','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform27','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform28','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform29','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform30','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform31','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform32','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform33','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform34','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform35','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform36','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform37','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform38','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform39','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform40','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform41','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform42','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform43','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform44','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform45','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform46','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform47','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform48','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform49','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform50','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform51','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform52','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform53','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform54','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform55','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform56','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform57','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform58','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform59','advance_stage','VARCHAR','100','');
CALL AddColumn('ld_customform60','advance_stage','VARCHAR','100','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAPSWITCH','地图切换','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MAPSWITCH' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAPSWITCH','Map switch','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MAPSWITCH' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHINA','中国','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CHINA' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHINA','China','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CHINA' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GLOBAL','全球','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GLOBAL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GLOBAL','Global','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GLOBAL' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATASCREENING','数据总览','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DATASCREENING' and Labeltype='jsonp' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATASCREENING','Data screening','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DATASCREENING' and Labeltype='jsonp' and languagetype='en');
delimiter;


update ld_desk set fieldlabel='Reminder content Settings' where labelbol='reminder_content_settings' and languagetype='en';
delimiter;
-- 2020-09-30

UPDATE ld_tranlabel SET fieldlabel=REPLACE(fieldlabel,'回款计划','收款计划') WHERE fieldlabel LIKE '%回款计划%';
UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'回款计划','收款计划') WHERE fieldlabel LIKE '%回款计划%';

UPDATE ld_tranlabel SET fieldlabel='计划收款日期' WHERE fieldlabel='计划回款日期' AND trantable='ld_field';
UPDATE ld_tranlabel SET fieldlabel='收款时项目状态' WHERE fieldlabel='回款时项目状态' AND trantable='ld_field';
UPDATE ld_tranlabel SET fieldlabel=REPLACE(fieldlabel,'回款预测','收款预测') WHERE Relateid=54 AND tabid=54 AND trantable='ld_systems_deploy';

UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'回款','收款') WHERE fieldlabel LIKE '%回款%';
UPDATE ld_customreport_info SET report_name=REPLACE(report_name,'回款','收款') WHERE report_name LIKE '%回款%';
UPDATE ld_approve SET `name`=REPLACE(`name`,'回款','收款') WHERE `name` LIKE '%回款%';
UPDATE ld_templateprint SET templateprintname=REPLACE(templateprintname,'回款','收款') WHERE templateprintname LIKE '%回款%';

UPDATE ld_desk SET fieldlabel='定价策略' WHERE fieldlabel='价格策略';
UPDATE ld_paymentplan SET paymenttype='计划收款日期' WHERE paymenttype='计划回款日期';

UPDATE ld_picklist_set a
LEFT JOIN ld_picklist_values b ON b.listid=a.listid
SET  b.listvalue='计划收款日期'
WHERE a.listname='paymenttype'
	AND b.listvalue='计划回款日期';

UPDATE ld_usereportcolumns SET realcolumns=REPLACE(realcolumns,'回款','收款') WHERE realcolumns LIKE '%回款%';
-- 2020-10-09

UPDATE ld_desk SET fieldlabel='多人审批方式“会签”（所有审批人通过才能通过审批步骤）' WHERE labelbol='MultipleCountersignature' AND languagetype='zh';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterthecategoryyouarelookingfor','请输入要查找的栏目','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='pleaseenterthecategoryyouarelookingfor' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterthecategoryyouarelookingfor','Please enter the category you are looking for','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='pleaseenterthecategoryyouarelookingfor' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterthecategoryyouarelookingformodule','请输入要查找的模块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='pleaseenterthecategoryyouarelookingformodule' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterthecategoryyouarelookingformodule','Please enter the category you are looking for','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='pleaseenterthecategoryyouarelookingformodule' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterthecategoryyouarelookingforfield','请输入要查找的字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='pleaseenterthecategoryyouarelookingforfield' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterthecategoryyouarelookingforfield','Please enter the category you are looking for','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='pleaseenterthecategoryyouarelookingforfield' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_userreport_commissionrule` (
	`id` INT (11) UNSIGNED AUTO_INCREMENT COMMENT '自增ID',
	`start` DECIMAL(10,2) COMMENT '开始计算区间',
	`end` DECIMAL(10,2) COMMENT "结束计算区间",
	`unit` VARCHAR(10) COMMENT '单位 %或者万元',
	`commission_rate` DECIMAL(10,2) COMMENT '提成',
	`commission_unit` VARCHAR(10) COMMENT '提成单位 % 或者元等其他单位 目前只用到%',
	`currency_id` INT(11) COMMENT '币种',
	`order` TINYINT(4) COMMENT '排序',
	`bytype` VARCHAR(20) COMMENT '按合同，按收款',
	`is_on` VARCHAR(10) COMMENT '是否启用 yes no',
	PRIMARY KEY (`id`)
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

SELECT
	usereportid INTO @usereportid
FROM
	ld_usereport
WHERE
	NAME = 'SalesReport';

SELECT
	sequence INTO @sequence
FROM
	ld_usereport
WHERE
	NAME = 'SalesReport';

INSERT INTO ld_usereport (
	NAME,
	reportlabel,
	tabids,
	basicfilter,
	advfilter,
	Setcolumns,
	Parent_id,
	sequence,
	reporttype,
	pagewidthpercent,
	setype
) SELECT
	'SalesCommissionsByOrder',
	'销售提成报表_按{$SalesOrder}统计',
	22,
	1,
	0,
	1 ,@usereportid ,@sequence - 1,
	61,
	110,
	'SalesOrder,ServiceContracts'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereport
		WHERE
			NAME = 'SalesCommissionsByOrder'
	);
SELECT
	usereportid INTO @usereportid
FROM
	ld_usereport
WHERE
	NAME = 'SalesReport';

SELECT
	sequence INTO @sequence
FROM
	ld_usereport
WHERE
	NAME = 'SalesReport';

INSERT INTO ld_usereport (
	NAME,
	reportlabel,
	tabids,
	basicfilter,
	advfilter,
	Setcolumns,
	Parent_id,
	sequence,
	reporttype,
	pagewidthpercent,
	setype
) SELECT
	'SalesCommissionsByCash',
	'销售提成报表_按{$CashBill}统计',
	22,
	1,
	0,
	1 ,@usereportid ,@sequence - 1,
	62,
	110,
	'CashBill'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereport
		WHERE
			NAME = 'SalesCommissionsByCash'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'SalesCommissionsByOrder',
	'销售提成报表_按合同统计',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'SalesCommissionsByOrder'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'SalesCommissionsByCash',
	'销售提成报表_按收款统计',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'SalesCommissionsByCash'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'onlyshowapprovecontactandservice',
	'只统计审批通过的合同订单和服务订单',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'onlyshowapprovecontactandservice'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'onlyshowapprovefeeandcommissions',
	'只统计审批通过的费用和佣金单',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'onlyshowapprovefeeandcommissions'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

SELECT
	usereportid INTO @usereportid
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';
update ld_usereportbasic
set sequence=sequence+1;

INSERT INTO ld_usereportbasic (
	Usereportid,
	`columns`,
	Defaultvalue,
	Sequence
) SELECT
	@usereportid,
	'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D',
	'thisstartmonth~thisendmonth',
	1
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportbasic
		WHERE
			Usereportid = @usereportid
		AND `columns` = 'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D'
	);


SELECT
	usereportid INTO @usereportid
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';
update ld_usereportbasic
set sequence=sequence+1;

INSERT INTO ld_usereportbasic (
	Usereportid,
	`columns`,
	Defaultvalue,
	Sequence
) SELECT
	@usereportid,
	'ld_cashbill:cashbill_date:cashbill_date:CashBill_cashbill_date:D',
	'thisstartmonth~thisendmonth',
	1
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportbasic
		WHERE
			Usereportid = @usereportid
		AND `columns` = 'ld_cashbill:cashbill_date:cashbill_date:CashBill_cashbill_date:D'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_cashbill:smownerid:assigned_user_id:CashBill_assigned_user_id:V',
	1,
	1,
	'ld_cashbill:smownerid:assigned_user_id:CashBill_业务员:V',
	'ld_cashbill:smownerid:assigned_user_id:CashBill_business_manager:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_cashbill:smownerid:assigned_user_id:CashBill_业务员:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_cashbill:cashbill_no:cashbill_no:CashBill_cashbill_no:V',
	1,
	1,
	'ld_cashbill:cashbill_no:cashbill_no:CashBill_收款编号:V',
	'ld_cashbill:cashbill_no:cashbill_no:CashBill_cashbill_no:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_cashbill:cashbill_no:cashbill_no:CashBill_收款编号:V'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D',
	1,
	1,
	'ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D',
	'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_cashbill:accountid:account_id:CashBill_account_id:V',
	1,
	1,
	'ld_cashbill:accountid:account_id:CashBill_客户名称:V',
	'ld_cashbill:accountid:account_id:CashBill_account_id:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_cashbill:accountid:account_id:CashBill_客户名称:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_cashbill:total:hdnGrandTotal:CashBill_hdnGrandTotal:N',
	1,
	1,
	'ld_cashbill:total:hdnGrandTotal:CashBill_本次收款金额:N',
	'ld_cashbill:total:hdnGrandTotal:CashBill_hdnGrandTotal:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_cashbill:total:hdnGrandTotal:CashBill_本次收款金额:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_cashbill:source_list:selectlistval:CashBill_selectlistval:V',
	1,
	1,
	'ld_cashbill:source_list:selectlistval:CashBill_源单:V',
	'ld_cashbill:source_list:selectlistval:CashBill_selectlistval:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_cashbill:source_list:selectlistval:CashBill_源单:V'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:source_displaytotal:source_displaytotal:CashBill_source_displaytotal:N',
	1,
	1,
	'ld_oftenusereport:source_displaytotal:source_displaytotal:CashBill_源单金额:N',
	'ld_oftenusereport:source_displaytotal:source_displaytotal:CashBill_source_displaytotal:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:source_displaytotal:source_displaytotal:CashBill_源单金额:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_source_displayreceived:V',
	1,
	1,
	'ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_源单已收总金额:V',
	'ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_source_displayreceived:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_源单已收总金额:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:total_fy:total_fy:CashBill_source_total_fy:N',
	1,
	1,
	'ld_oftenusereport:total_fy:total_fy:CashBill_费用合计:N',
	'ld_oftenusereport:total_fy:total_fy:CashBill_source_total_fy:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:total_fy:total_fy:CashBill_费用合计:N'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:total_yj:total_yj:CashBill_total_yj:N',
	1,
	1,
	'ld_oftenusereport:total_yj:total_yj:CashBill_佣金合计:N',
	'ld_oftenusereport:total_yj:total_yj:CashBill_total_yj:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:total_yj:total_yj:CashBill_佣金合计:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:total_cost:total_cost:CashBill_total_cost:N',
	1,
	1,
	'ld_oftenusereport:total_cost:total_cost:CashBill_产品成本合计:N',
	'ld_oftenusereport:total_cost:total_cost:CashBill_total_cost:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:total_cost:total_cost:CashBill_产品成本合计:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:yeji:yeji:CashBill_yeji:N',
	1,
	1,
	'ld_oftenusereport:yeji:yeji:CashBill_销售业绩:N',
	'ld_oftenusereport:yeji:yeji:CashBill_yeji:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:yeji:yeji:CashBill_销售业绩:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:ticheng:ticheng:CashBill_ticheng:N',
	1,
	1,
	'ld_oftenusereport:ticheng:ticheng:CashBill_业绩提成:N',
	'ld_oftenusereport:ticheng:ticheng:CashBill_ticheng:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:ticheng:ticheng:CashBill_业绩提成:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V',
	1,
	1,
	'ld_salesorder:smownerid:assigned_user_id:SalesOrder_业务员:V',
	'ld_salesorder:smownerid:assigned_user_id:SalesOrder_business_manager:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_业务员:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V',
	1,
	1,
	'ld_salesorder:smownerid:assigned_user_id:SalesOrder_业务员:V',
	'ld_salesorder:smownerid:assigned_user_id:SalesOrder_business_manager:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_业务员:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V',
	1,
	1,
	'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V',
	'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:stockpresence:stockpresence:SalesOrder_stockpresence:V',
	1,
	1,
	'ld_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V',
	'ld_salesorder:stockpresence:stockpresence:SalesOrder_stockpresence:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D',
	1,
	1,
	'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D',
	'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:account_id:account_id:SalesOrder_account_id:V',
	1,
	1,
	'ld_salesorder:account_id:account_id:SalesOrder_客户名称:V',
	'ld_salesorder:account_id:account_id:SalesOrder_account_id:V'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:account_id:account_id:SalesOrder_客户名称:V'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_salesorder:total:hdnGrandTotal:SalesOrder_hdnGrandTotal:N',
	1,
	1,
	'ld_salesorder:total:hdnGrandTotal:SalesOrder_合同金额:N',
	'ld_salesorder:total:hdnGrandTotal:SalesOrder_hdnGrandTotal:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合同金额:N'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:total_fy:total_fy:OftenUseReport_total_fy:N',
	1,
	1,
	'ld_oftenusereport:total_fy:total_fy:OftenUseReport_费用合计:N',
	'ld_oftenusereport:total_fy:total_fy:OftenUseReport_total_fy:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:total_fy:total_fy:OftenUseReport_费用合计:N'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:total_yj:total_yj:OftenUseReport_total_yj:N',
	1,
	1,
	'ld_oftenusereport:total_yj:total_yj:OftenUseReport_佣金合计:N',
	'ld_oftenusereport:total_yj:total_yj:OftenUseReport_total_yj:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:total_yj:total_yj:OftenUseReport_佣金合计:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:total_cost:total_cost:OftenUseReport_total_cost:N',
	1,
	1,
	'ld_oftenusereport:total_cost:total_cost:OftenUseReport_产品成本合计:N',
	'ld_oftenusereport:total_cost:total_cost:OftenUseReport_total_cost:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:total_cost:total_cost:OftenUseReport_产品成本合计:N'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:yeji:yeji:OftenUseReport_yeji:N',
	1,
	1,
	'ld_oftenusereport:yeji:yeji:OftenUseReport_销售业绩:N',
	'ld_oftenusereport:yeji:yeji:OftenUseReport_yeji:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:yeji:yeji:OftenUseReport_销售业绩:N'
	);


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:ticheng:ticheng:OftenUseReport_ticheng:N',
	1,
	1,
	'ld_oftenusereport:ticheng:ticheng:OftenUseReport_业绩提成:N',
	'ld_oftenusereport:ticheng:ticheng:OftenUseReport_ticheng:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:ticheng:ticheng:OftenUseReport_业绩提成:N'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'rewardRule',
	'提成规则',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'rewardRule'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'setCommissionRule',
	'设置业绩提成规则',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'setCommissionRule'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'CommissionRate',
	'提成比例',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'CommissionRate'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'Million',
	'万元',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'Million'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);
delimiter;

UPDATE ld_usereportcolumns SET realcolumns='ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_收款计划编号:I' 
WHERE `columns` LIKE 'ld_paymentplan:paymentplan_no:paymentplan_no%'
	AND realcolumns LIKE '%PaymentPlan_收款单编号%';
    
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','allowtopushback','允许回推（管理员自动拥有此权限）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='allowtopushback' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','allowtopushback','Allow to push back(Administrators automatically have this permission)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='allowtopushback' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_settings_advance','pushback','varchar','20',null);
delimiter;

update ld_settings_advance set pushback = 'yes' where pushback is NULL;
delimiter;

call AddColumn('ld_systems','smtp_ssl','varchar','10','no');
delimiter;
update ld_systems set smtp_ssl='no' where smtp_ssl='' or smtp_ssl is null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approvalrequired','审批必填','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='approvalrequired' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approvalrequired','Approval required','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='approvalrequired' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','settherequiredfieldsofapprover','设置审批人必填字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='settherequiredfieldsofapprover' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','settherequiredfieldsofapprover','Set the required fields of approver','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='settherequiredfieldsofapprover' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_approvestep','module_field','text','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','youwanttofillintherequiredfields','审批流程中设置的有审批人必填字段，是否立即填写？','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='youwanttofillintherequiredfields' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','youwanttofillintherequiredfields','you want to fill in the required fields of approver set in the approval process?','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='youwanttofillintherequiredfields' and Labeltype='fixedstr' and languagetype='en');
delimiter;


SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N',
	1,
	1,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N',
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N'
	);



SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N',
	1,
	1,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N',
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N'
	);


INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N',
	1,
	1,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N',
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N'
	);




INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N',
	1,
	1,
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N',
	'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_ticheng_rate:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:ticheng_rate:ticheng_rate:OftenUseReport_提成比例（%）:N'
	);


INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:source_rmbtotal:source_rmbtotal:OftenUseReport_source_rmbtotal:N',
	1,
	1,
	'ld_oftenusereport:source_rmbtotal:source_rmbtotal:OftenUseReport_源单金额:N',
	'ld_oftenusereport:source_rmbtotal:source_rmbtotal:OftenUseReport_source_rmbtotal:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:source_rmbtotal:source_rmbtotal:OftenUseReport_源单金额:N'
	);


delete from ld_usereportcolumns where realcolumns="ld_oftenusereport:source_displaytotal:source_displaytotal:CashBill_源单金额:N";
delimiter;
-- 2020-10-12

INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'StatisticsPotentialsBySalesPersonAndSalesStage',
	'商机统计图_按负责人和销售阶段统计',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'StatisticsPotentialsBySalesPersonAndSalesStage'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);
INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'en',
	'StatisticsPotentialsBySalesPersonAndSalesStage',
	'Statistics Table of Potentials _ by salesperson and sales stage',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'StatisticsPotentialsBySalesPersonAndSalesStage'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'en'
	);
INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'zh',
	'StatisticalPotentialsByTheAccountIndustryAndSalesStage',
	'商机统计图_按客户所属行业和销售阶段统计',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'StatisticalPotentialsByTheAccountIndustryAndSalesStage'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'zh'
	);
INSERT INTO ld_desk (
	languagetype,
	labelbol,
	fieldlabel,
	labeltype
) SELECT
	'en',
	'StatisticalPotentialsByTheAccountIndustryAndSalesStage',
	'Statistical Table of Potentials _ by the account industry and sales stage',
	'fixedstr'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_desk
		WHERE
			labelbol = 'StatisticalPotentialsByTheAccountIndustryAndSalesStage'
		AND Labeltype = 'fixedstr'
		AND languagetype = 'en'
	);
delimiter;

update ld_desk set fieldlabel="提成规则设置" where labelbol="rewardRule";

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','costCounting','成本计算方法','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='costCounting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','costCounting','Cost calculation method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='costCounting' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chooseCost','取成本价或参考成本价','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','chooseCost','Take cost price or reference cost price','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseCost' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','choosePurchaseCost','取订单产品的采购成本','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='choosePurchaseCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','choosePurchaseCost','Take the purchase cost of the order product','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='approvalrequired' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chooseAvgCost','取产品的采购平均均价','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseAvgCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','chooseAvgCost','Take the average purchase price of the product','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseAvgCost' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chooseOutBoundCost','取订单产品的出库价格','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseOutBoundCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','chooseOutBoundCost','Take the delivery price of the order product','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseOutBoundCost' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','awardCounting','业绩计算方法','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='awardCounting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','awardCounting','Performance calculation method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='awardCounting' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deductionFyAndYj','扣除费用和佣金','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndYj' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deductionFyAndYj','Deduction of fees and commissions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndYj' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deductionFyAndCost','扣除费用佣金和产品成本','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deductionFyAndCost','Deducting fees, commissions and product costs','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndCost' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel="提成规则设置" where labelbol="rewardRule";


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','costCounting','成本计算方法','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='costCounting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','costCounting','Cost calculation method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='costCounting' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chooseCost','取成本价或参考成本价','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','chooseCost','Take cost price or reference cost price','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseCost' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','choosePurchaseCost','取订单产品的采购成本','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='choosePurchaseCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','choosePurchaseCost','Take the purchase cost of the order product','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='approvalrequired' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chooseAvgCost','取产品的采购平均均价','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseAvgCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','chooseAvgCost','Take the average purchase price of the product','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseAvgCost' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chooseOutBoundCost','取订单产品的出库价格','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseOutBoundCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','chooseOutBoundCost','Take the delivery price of the order product','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='chooseOutBoundCost' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','awardCounting','业绩计算方法','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='awardCounting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','awardCounting','Performance calculation method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='awardCounting' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deductionFyAndYj','扣除费用和佣金','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndYj' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deductionFyAndYj','Deduction of fees and commissions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndYj' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deductionFyAndCost','扣除费用佣金和产品成本','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndCost' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deductionFyAndCost','Deducting fees, commissions and product costs','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deductionFyAndCost' and Labeltype='fixedstr' and languagetype='en');

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:done_rate:done_rate:OftenUseReport_done_rate:N',
	1,
	1,
	'ld_oftenusereport:done_rate:done_rate:OftenUseReport_目标完成率(%):N',
	'ld_oftenusereport:done_rate:done_rate:OftenUseReport_done_rate:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:done_rate:done_rate:OftenUseReport_目标完成率(%):N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:done_rate:done_rate:OftenUseReport_done_rate:N',
	1,
	1,
	'ld_oftenusereport:done_rate:done_rate:OftenUseReport_目标完成率(%):N',
	'ld_oftenusereport:done_rate:done_rate:OftenUseReport_done_rate:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:done_rate:done_rate:OftenUseReport_目标完成率(%):N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByCash';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:target:target:OftenUseReport_target:N',
	1,
	1,
	'ld_oftenusereport:target:target:OftenUseReport_目标额:N',
	'ld_oftenusereport:target:target:OftenUseReport_target:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:target:target:OftenUseReport_目标额:N'
	);

SELECT
	usereportid INTO @id
FROM
	ld_usereport
WHERE
	NAME = 'SalesCommissionsByOrder';

INSERT INTO ld_usereportcolumns (
	id,
	Usereportid,
	columns,
	Sequence,
	columnshow,
	realcolumns,
	realencolumns
) SELECT
	'',
	@id,
	'ld_oftenusereport:target:target:OftenUseReport_target:N',
	1,
	1,
	'ld_oftenusereport:target:target:OftenUseReport_目标额:N',
	'ld_oftenusereport:target:target:OftenUseReport_target:N'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_usereportcolumns
		WHERE
			Usereportid =@id
		AND realcolumns = 'ld_oftenusereport:target:target:OftenUseReport_目标额:N'
	);
delimiter;

DROP PROCEDURE IF EXISTS `reset_advance_stage_20201013`;
delimiter ||
CREATE  PROCEDURE `reset_advance_stage_20201013`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_columnname VARCHAR(200) DEFAULT '';
	DECLARE tmp_tablename VARCHAR(200) DEFAULT '';
	DECLARE tmp_tablename_main VARCHAR(200) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR 
										SELECT 
											a.tabid,
											b.columnname,
											LOWER(b.tablename) AS tablename,
											(SELECT LOWER(tablename) FROM ld_field WHERE tabid=a.tabid AND columnname='smownerid' LIMIT 1) AS tablename_main
										FROM ld_settings_advance a	
										LEFT JOIN ld_field b ON b.tabid=a.tabid AND b.fieldname=a.module_field
										WHERE a.method='field' 
											AND a.`enable`='yes' 
											AND IFNULL(b.columnname,'')<>''
											AND IFNULL(b.tablename,'')<>''
											AND (SELECT tablename FROM ld_field WHERE tabid=a.tabid AND columnname='smownerid' LIMIT 1)<>''
										ORDER BY a.tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;


	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_columnname,tmp_tablename,tmp_tablename_main;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @this_sql=NULL;
        CALL AddColumn(tmp_tablename,'advance_stage','VARCHAR','100','');
		IF tmp_tablename=tmp_tablename_main THEN
			SET @this_sql=CONCAT('UPDATE ',tmp_tablename,' SET advance_stage = ',tmp_columnname);
		ELSE
			SET @this_keyid=(SELECT entityidfield FROM ld_entityname WHERE tabid=tmp_tabid LIMIT 1);
			IF IFNULL(@this_keyid,'')<>'' THEN
				SET @this_sql=CONCAT('UPDATE ',tmp_tablename_main,' a LEFT JOIN ',tmp_tablename,' b ON b.',@this_keyid,'=a.',@this_keyid,' SET a.advance_stage = b.',tmp_columnname);
			END IF;
		END IF;

		IF IFNULL(@this_sql,'')<>'' THEN
			SET @disable_triggers=1;
			PREPARE stalter FROM @this_sql;
			EXECUTE stalter;
			DROP PREPARE stalter;
			SET @disable_triggers=NULL;
		END IF;

		FETCH MYCUSOR INTO tmp_tabid,tmp_columnname,tmp_tablename,tmp_tablename_main;
	END WHILE;
	CLOSE MYCUSOR;


end ||
delimiter;

CALL reset_advance_stage_20201013();
DROP PROCEDURE IF EXISTS `reset_advance_stage_20201013`;

SET @reportid=(SELECT usereportid FROM ld_usereport WHERE `name`='SalesCommissionsByCash' LIMIT 1);
SET @i=0;
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_cashbill:smownerid%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_cashbill:cashbill_no%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_cashbill:cashbilldate%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_cashbill:accountid%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_cashbill:source_list%';

UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:source_rmbtotal%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:source_displayreceived%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_cashbill:total%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:total_fy%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:yeji:yeji%';

UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:total_cost%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:total_yj%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:target%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:done_rate%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:ticheng_rate%';

UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:ticheng:ticheng%';
delimiter;

SET @reportid=(SELECT usereportid FROM ld_usereport WHERE `name`='SalesCommissionsByOrder' LIMIT 1);
SET @i=0;
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_salesorder:smownerid%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_salesorder:salesorder_no%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_salesorder:account_id:account_id%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_salesorder:stockpresence%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_salesorder:signed_data%';

UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_salesorder:total:hdnGrandTotal%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:total_fy:total_fy%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:total_yj:total_yj%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:total_cost:total_cost%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:yeji:yeji%';

UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:target:target%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:done_rate:done_rate%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:ticheng_rate:ticheng_rate%';
UPDATE ld_usereportcolumns SET Sequence=(@i:=@i+1) WHERE Usereportid=@reportid AND `columns` LIKE 'ld_oftenusereport:ticheng:ticheng%';
delimiter;
-- 2020-10-13

SET @disable_triggers=NULL;
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

UPDATE ld_version SET old_version='V8.2.6',current_version='V8.2.6',remark='V8.2.6-20201012',wx_version='V8.2.3.2';
delimiter;