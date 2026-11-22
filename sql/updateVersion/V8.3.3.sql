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

UPDATE ld_desk SET fieldlabel='PC端启用进度跟踪' WHERE labelbol= 'Enableprogresstracking' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Enable progress tracking on PC' WHERE labelbol= 'Enableprogresstracking' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

ALTER TABLE ld_userreport_commissionrule MODIFY COLUMN bytype VARCHAR(50);

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE NAME = 'SalesReport';
SELECT sequence INTO @sequence FROM ld_usereport WHERE NAME = 'SalesReport';
update ld_usereport set sequence=sequence+1 where Parent_id=1 and sequence>1;
INSERT INTO ld_usereport (NAME,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent,setype) SELECT 'ServiceChargeBonusByOrder', '服务收费奖金_按{$SalesOrder}统计', 22, 1, 0, 1 ,@usereportid ,@sequence, 63, 110, 'ServiceContracts'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder');

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE NAME = 'SalesReport';
SELECT sequence INTO @sequence FROM ld_usereport WHERE NAME = 'SalesReport';

INSERT INTO ld_usereport (NAME,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent,setype
) SELECT 'ServiceChargeBonusByCash','服务收费奖金_按{$CashBill}统计',22,1,0,1 ,@usereportid ,@sequence,64,110,'CashBill'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash');

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','ServiceChargeBonusByOrder','服务收费奖金_按合同统计','fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'ServiceChargeBonusByOrder' AND Labeltype = 'fixedstr' AND languagetype = 'zh');
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'ServiceChargeBonusByOrder', 'Service charge bonus_ by Service Contracts', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'ServiceChargeBonusByOrder' AND Labeltype = 'fixedstr' AND languagetype = 'en');
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'ServiceChargeBonusByCash', '服务收费奖金_按收款统计', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'ServiceChargeBonusByCash' AND Labeltype = 'fixedstr' AND languagetype = 'zh');
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'ServiceChargeBonusByCash', 'Service charge bonus_ by Receipt', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'ServiceChargeBonusByCash' AND Labeltype = 'fixedstr' AND languagetype = 'en');


SELECT usereportid INTO @usereportid FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportbasic ( Usereportid, `columns`, Defaultvalue, Sequence
) SELECT @usereportid, 'ld_servicecontracts:due_date:due_date:ServiceContracts_due_date:D', 'thisstartmonth~thisendmonth', 1
FROM DUAL WHERE NOT EXISTS (select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_servicecontracts:due_date:due_date:ServiceContracts_due_date:D');

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportbasic ( Usereportid, `columns`, Defaultvalue, Sequence
) SELECT @usereportid, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D', 'thisstartmonth~thisendmonth', 1 FROM DUAL WHERE NOT EXISTS (select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D');


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'rewardServiceRule', '奖金池比例规则设置', 'fixedstr'
FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'rewardServiceRule' AND Labeltype = 'fixedstr' AND languagetype = 'zh');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'rewardServiceRule', 'The bonus pool ratio rule setting', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'rewardServiceRule' AND Labeltype = 'fixedstr' AND languagetype = 'en');
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'setRewardServiceRule', '设置奖金池比例规则', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'setRewardServiceRule' AND Labeltype = 'fixedstr' AND languagetype = 'zh');
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'setRewardServiceRule', 'Set the bonus pool ratio rule', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'setRewardServiceRule' AND Labeltype = 'fixedstr' AND languagetype = 'en' );


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 1, 1, 'ld_users:last_name:last_name:Users_负责人:V', 'ld_users:last_name:last_name:Users_business_manager:V'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_users:last_name:last_name:Users_负责人:V' );


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N', 1, 1, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N', 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N');


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_pool_rate:N', 1, 1, 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_奖金池比例(%):N', 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_pool_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_奖金池比例(%):N');



SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:pool_money:pool_money:ServiceContracts_pool_money:N', 1, 1,'ld_servicecontracts:pool_money:pool_money:ServiceContracts_奖金池:N','ld_servicecontracts:pool_money:pool_money:ServiceContracts_pool_money:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_servicecontracts:pool_money:pool_money:ServiceContracts_奖金池:N');


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_yeji_geren:N', 1, 1, 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_个人服务业绩:N', 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_yeji_geren:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_个人服务业绩:N');


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_yeji_total:N', 1, 1, 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_部门总服务业绩:N', 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_yeji_total:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_部门总服务业绩:N'
	);


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N', 1, 1, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N', 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N'
	);


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_jiangjin:N', 1, 1, 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_服务奖金:N', 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_jiangjin:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_服务奖金:N'
    );


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 1, 1, 'ld_users:last_name:last_name:Users_负责人:V', 'ld_users:last_name:last_name:Users_business_manager:V'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_users:last_name:last_name:Users_负责人:V'
	);

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N', 1, 1, 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N', 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_totalmoney:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N'
	);

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_pool_rate:N', 1, 1, 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_奖金池比例(%):N', 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_pool_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:pool_rate:pool_rate:ServiceContracts_奖金池比例(%):N'
	);

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:pool_money:pool_money:ServiceContracts_pool_money:N', 1, 1, 'ld_servicecontracts:pool_money:pool_money:ServiceContracts_奖金池:N', 'ld_servicecontracts:pool_money:pool_money:ServiceContracts_pool_money:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:pool_money:pool_money:ServiceContracts_奖金池:N'
	);


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_yeji_geren:N', 1, 1, 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_个人服务业绩:N', 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_yeji_geren:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_geren:yeji_geren:ServiceContracts_个人服务业绩:N'
	);


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_yeji_total:N', 1, 1, 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_部门总服务业绩:N', 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_yeji_total:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_total:yeji_total:ServiceContracts_部门总服务业绩:N'
	);

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N', 1, 1, 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N', 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_yeji_rate:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N'
	);


SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
INSERT INTO ld_usereportcolumns ( id, Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns
) SELECT '', @id, 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_jiangjin:N', 1, 1, 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_服务奖金:N', 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_jiangjin:N'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_usereportcolumns WHERE
			Usereportid =@id AND realcolumns = 'ld_servicecontracts:jiangjin:jiangjin:ServiceContracts_服务奖金:N'
	);


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'onlyshowapproveservicecontract', '只统计审批通过的服务合同', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'onlyshowapproveservicecontract' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
	);


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'onlyshowapproveservicecontract', 'Only count the approved Service Contracts', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'onlyshowapproveservicecontract' AND Labeltype = 'fixedstr' AND languagetype = 'en'
	);


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'onlyshowapprovecashbill', '只统计审批通过的收款单', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'onlyshowapprovecashbill' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
	);
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'onlyshowapprovecashbill', 'Only count the approved Receipt', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
			1 FROM
			ld_desk WHERE
			labelbol = 'onlyshowapprovecashbill' AND Labeltype = 'fixedstr' AND languagetype = 'en'
	);


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'zh', 'onlyshowapproveservicebill', '只统计审批通过的客户服务单', 'fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol = 'onlyshowapproveservicebill' AND Labeltype = 'fixedstr' AND languagetype = 'zh');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'en', 'onlyshowapproveservicebill', 'Only count the approved Account Trouble Tickets', 'fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM  ld_desk WHERE labelbol = 'onlyshowapproveservicebill' AND Labeltype = 'fixedstr' AND languagetype = 'en');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'en', 'Theamountofdepartmentalservicecontractfrom', 'The amount of departmental service contract from', 'fixedstr' FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'Theamountofdepartmentalservicecontractfrom' AND Labeltype = 'fixedstr' AND languagetype = 'en');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'zh', 'Theamountofdepartmentalservicecontractfrom', '部门服务合同金额从', 'fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol = 'Theamountofdepartmentalservicecontractfrom' AND Labeltype = 'fixedstr' AND languagetype = 'zh');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'en', 'Theamountofdepartmentalservicecontractto', 'The amount of departmental service contract to', 'fixedstr' FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'Theamountofdepartmentalservicecontractto' AND Labeltype = 'fixedstr' AND languagetype = 'en');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'zh', 'Theamountofdepartmentalservicecontractto', '部门服务合同金额到', 'fixedstr' FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'Theamountofdepartmentalservicecontractto' AND Labeltype = 'fixedstr' AND languagetype = 'zh');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'en', 'Proportionofbonuspool', 'Proportion of bonus pool ', 'fixedstr' FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'Proportionofbonuspool' AND Labeltype = 'fixedstr' AND languagetype = 'en');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) 
SELECT 'zh', 'Proportionofbonuspool', '奖金池比例', 'fixedstr' FROM DUAL
WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'Proportionofbonuspool' AND Labeltype = 'fixedstr' AND languagetype = 'zh');
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByOrder';
update ld_usereportcolumns set realcolumns="ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N" where Usereportid=@id and realcolumns="ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N";

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
update ld_usereportcolumns set realcolumns="ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（%）:N" where Usereportid=@id and realcolumns="ld_servicecontracts:yeji_rate:yeji_rate:ServiceContracts_服务绩效占比（10%）:N";

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ServiceChargeBonusByCash';
update ld_usereportcolumns set realcolumns="ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同收款金额:N" where Usereportid=@id and realcolumns="ld_servicecontracts:totalmoney:totalmoney:ServiceContracts_部门服务合同金额:N";
delimiter;

select max(tabid) into @maxtabid from ld_tab;
SET @i=IFNULL((select tabsequence from ld_tab where `name` = 'PublicAnnouncement'),0);
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'WechatSession',0,(@i:=@i+1),'WechatSession',1 from dual
where not EXISTS(select 1 from ld_tab where name='WechatSession');
delimiter;

select tabid into @tabid from ld_tab  where name='WechatSession';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'会话存档' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'WechatSession' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WechatSession';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,3,0 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
delimiter;

CALL AddColumn ( "ld_wechatsession", 'session_type', 'varchar', '25', 'internal' );
ALTER TABLE ld_wechatsession MODIFY COLUMN session_type VARCHAR ( 25 ) DEFAULT 'internal' COMMENT '会话类型:内部internal,外部external';
delimiter;

CALL AddColumn ( "ld_wechatsession", 'roomname', 'varchar', '50', NULL );
ALTER TABLE ld_wechatsession MODIFY COLUMN roomname VARCHAR (50) DEFAULT NULL COMMENT '群聊名称';
delimiter;

insert into ld_wx_config (name,description,para_one,para_two,para_three) select 'wechatsession_setting','企业微信会话存档','','','' from dual where not exists(select 1 from ld_wx_config where name='wechatsession_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RetrieveByMember','根据成员检索','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RetrieveByMember' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RetrieveByMember','Retrieve based on members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RetrieveByMember' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RetrieveByAccount','根据客户检索','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RetrieveByAccount' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RetrieveByAccount','Retrieve based on accounts','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RetrieveByAccount' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MemberList','成员列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MemberList' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MemberList','Member list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MemberList' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SessionList','会话列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SessionList' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SessionList','Session list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SessionList' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchMembers','搜索成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchMembers' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchMembers','Search members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchMembers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchSessions','搜索会话人员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchSessions' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchSessions','Search contact customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchSessions' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchSessionContent','搜索会话内容','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchSessionContent' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchSessionContent','Search session content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchSessionContent' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Singlechat','单聊','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Singlechat' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Singlechat','Single chat','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Singlechat' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Groupchat','群聊','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Groupchat' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Groupchat','Group chat','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Groupchat' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VOICE','语音','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VOICE' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VOICE','voice','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VOICE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIDEO','视频','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VIDEO' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIDEO','video','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VIDEO' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomerList','客户列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomerList' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomerList','Customer list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomerList' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchCustomers','搜索客户','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchCustomers' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchCustomers','Search customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SearchCustomers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RelatedRecords','条相关记录','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RelatedRecords' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RelatedRecords','related records','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RelatedRecords' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ViewContext','查看上下文','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ViewContext' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ViewContext','View context','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ViewContext' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoRecordsFound','没有找到相关记录','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoRecordsFound' and labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoRecordsFound','No records were found','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoRecordsFound' and labeltype='fixedstr' and languagetype='en');
delimiter;


SET @i=0;
SET @tabsequence=(SELECT tabsequence FROM ld_tab WHERE `name`='Contacts' LIMIT 1);
UPDATE ld_tab SET tabsequence=tabsequence+1 WHERE tabsequence>@tabsequence;
UPDATE ld_tab SET tabsequence=@tabsequence+1 WHERE `name`='WechatSession';
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;
delimiter;

SET @i=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WechatSession' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=3 AND tabid=4 LIMIT 1);
UPDATE ld_parenttabrel SET sequence=sequence+2 WHERE sequence>@seq AND parenttabid=3;
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
SELECT 3,@tabid,@seq+1,'ld_tab' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=3 AND tabid=@tabid);

UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=3 ORDER BY sequence;
delimiter;

update ld_desk set fieldlabel="只统计审批通过的{$CashBill.CashBill}" where labelbol = 'onlyshowapprovecashbill' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
update ld_desk set fieldlabel="只统计审批通过的{$HelpDesk.HelpDesk}" where  labelbol = 'onlyshowapproveservicebill' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
update ld_desk set fieldlabel="只统计审批通过的{$ServiceContracts.ServiceContracts}" where  labelbol = 'onlyshowapproveservicecontract' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;
-- 2020-11-27



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

UPDATE ld_version SET old_version='V8.3.3',current_version='V8.3.3',remark='V8.3.3-20201127',wx_version='V8.3.3';
delimiter;