DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF tmp_defaultvalue='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF tmp_columnlen<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Highseaspool','公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseaspool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Highseaspool','High seas pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseaspool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set Labeltype = 'fixedstr' where  labelbol = 'TOTHEHIGNSEASCUSTOMERERROR1';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder' LIMIT 1);
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='contactid');
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='vendorid');
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'column','vendorid' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
-- 2021-01-15

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Productbom' LIMIT 1);
SET @producttoolfieldid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname='total' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='套餐售价' WHERE trantable='ld_producttoolfield' AND tabid=@tabid AND Relateid=@producttoolfieldid AND languagetype='zh' AND fieldlabel='合计';

UPDATE ld_field SET quickcreate=1 WHERE tablename='ld_contactrecords' AND columnname='location_address';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet');
UPDATE ld_tabdetailfield SET width=30 WHERE tabid=@tabid AND columnname='workdate' AND width<30;
delimiter;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=20 AND columnname='source_list' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='选择源单' WHERE tabid=20 AND Relateid=@fieldid AND languagetype='zh' AND fieldlabel='采购询价单';
UPDATE ld_tranlabel SET fieldlabel='Select Source' WHERE tabid=20 AND Relateid=@fieldid AND languagetype='en' AND fieldlabel='Purchase Inquiry Order';
delimiter;

update ld_desk set fieldlabel="IMPORTRECORDTIP" where labelbol="共%d条记录，明细%d条，覆盖%d条记录，成功导入%d条记录，%s失败%d条记录%s。" and  languagetype="zh";

update ld_desk set fieldlabel="IMPORTRECORDTIP" where labelbol="A total of %d records, detailed %d, covering %d records, successfully imported %d records, %sfailed %d records%s." and  languagetype="en";
delimiter;

DELETE FROM ld_systems_deploy WHERE description='设置移动端单据详情界面是否启用另存为PDF格式功能' AND deploy_type<>268;
SET @roottype=8;
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 1,268,'设置移动端单据详情界面是否启用另存为PDF格式功能',"",@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=268);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',268,268,'设置移动端单据详情界面是否启用另存为PDF格式功能'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 268 and relateid=268);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',268,268,'Sets whether Save as PDF function is enabled in the mobile terminal document detail interface'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 268 and relateid=268);
delimiter;

update ld_desk set fieldlabel="共%d条记录，明细%d条，覆盖%d条记录，成功导入%d条记录，%s失败%d条记录%s。" where labelbol="IMPORTRECORDTIP" and  languagetype="zh";
update ld_desk set fieldlabel="A total of %d records, detailed %d, covering %d records, successfully imported %d records, %sfailed %d records%s." where labelbol="IMPORTRECORDTIP" and  languagetype="en";
delimiter;
-- 2021-01-19

UPDATE ld_workreport_field SET label='点击签到（移动端）' WHERE `name`='signaddress' AND entitytype='workreport' AND label='签到';

UPDATE ld_desk SET fieldlabel='在关键视图中显示' WHERE labelbol='DISPLAYINHOME' AND fieldlabel='在首页关键视图中显示' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Display in the key view' WHERE labelbol='DISPLAYINHOME' AND languagetype='en';

DROP PROCEDURE IF EXISTS `reset_bill_approveinfo_20210120`;
delimiter ||
CREATE  PROCEDURE `reset_bill_approveinfo_20210120`(
)
BEGIN

	DECLARE tmp_tabname VARCHAR(100) DEFAULT '';
	DECLARE MYCUSOR CURSOR FOR 
					SELECT
						b.setype
					FROM (SELECT crmid FROM ld_approvelog GROUP BY crmid) a
					INNER JOIN ld_crmentity b ON b.crmid=a.crmid
					WHERE IFNULL(b.setype,'') NOT IN ('','SalesOrder','Quotes','ServiceContracts','Reminds','Attachment')
					GROUP BY b.setype;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabname = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabname;
	WHILE(tmp_tabname IS NOT NULL) DO
		SET @this_tablename=(SELECT tablename FROM ld_tab a INNER JOIN ld_field b ON b.tabid=a.tabid WHERE a.`name`=tmp_tabname AND b.columnname='smownerid');
		SET @this_tableid=(SELECT entityidfield FROM ld_entityname WHERE modulename=tmp_tabname LIMIT 1);

		SET @this_sql_01="UPDATE ld_servicecontracts
SET 
	currentapprover=NULL,
	currentapprovestepid=NULL
WHERE deleted=0
	AND approvestatus IN ('未提交','已驳回','已批准')";

		SET @this_sql_02="UPDATE ld_servicecontracts
SET 
	currentapprover=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no') THEN
				(SELECT GROUP_CONCAT(nextstepapproveby) FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no')
			ELSE
				(SELECT nextstepapproveby FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid ORDER BY seqtime DESC,id DESC LIMIT 1)
		END),
	currentapprovestepid=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no') THEN
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no' AND nextstepid>0 ORDER BY id DESC LIMIT 1)
			ELSE
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND nextstepid>0 ORDER BY seqtime DESC,id DESC LIMIT 1)
		END)
WHERE deleted=0
	AND approvestatus IN ('审批中')";


		SET @this_execsql_01=REPLACE(@this_sql_01,'ld_servicecontracts',@this_tablename);
		SET @this_execsql_01=REPLACE(@this_execsql_01,'servicecontractsid',@this_tableid);
		SET @this_execsql_02=REPLACE(@this_sql_02,'ld_servicecontracts',@this_tablename);
		SET @this_execsql_02=REPLACE(@this_execsql_02,'servicecontractsid',@this_tableid);

		SET @disable_triggers=1;
		PREPARE this_stmt FROM @this_execsql_01;
		EXECUTE this_stmt;
		DEALLOCATE PREPARE this_stmt;

		PREPARE this_stmt FROM @this_execsql_02;
		EXECUTE this_stmt;
		DEALLOCATE PREPARE this_stmt;
		SET @disable_triggers=NULL;

		FETCH MYCUSOR INTO tmp_tabname;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL reset_bill_approveinfo_20210120();
DROP PROCEDURE IF EXISTS `reset_bill_approveinfo_20210120`;
delimiter;

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewInvoiceAmount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewQuotesCount','fixedstr','ld_quotes.quoteid','count','index.php?pageto_module=Quotes&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesCount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesCount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:createdtime:createdtime:Quotes_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:createdtime:createdtime:Quotes%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:approvestatus:approvestatus:Quotes_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:approvestatus:approvestatus:Quotes%') ;
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewQuotesCount','{$Quotes.Quotes}数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewQuotesCount' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewQuotesCount','New{$Quotes.Quotes}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewQuotesCount' and Labeltype='fixedstr');
delimiter;
UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


select sequence into @sequence from ld_homestuffdetail where stufflabel="NewQuotesCount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewQuotesAmount','fixedstr','ld_quotes.total','sum','index.php?pageto_module=Quotes&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewQuotesAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:createdtime:createdtime:Quotes_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:createdtime:createdtime:Quotes%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_quotes:approvestatus:approvestatus:Quotes_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_quotes:approvestatus:approvestatus:Quotes%') ;
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewQuotesAmount','{$Quotes.Quotes}金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewQuotesAmount' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewQuotesAmount','{$Quotes.Quotes} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewQuotesAmount' and Labeltype='fixedstr');
delimiter;
UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


update ld_homestuffdetail set cssname="item-ico-quotes" where stuffid=35 and stufflabel='NewQuotesAmount';
update ld_homestuffdetail set cssname="item-ico-quotes" where stuffid=35 and stufflabel='NewQuotesCount';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTQRCODE','产品二维码','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTQRCODE','Product bar code','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTQRCODE','产品二维码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTQRCODE','Product bar code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTQRCODETIPS','{$Products.Products}【{$Products.productcode}】字段为空或未启用，请前往【系统设置】→【页面设置】→【{$Products.Products}->页面设置】启用字段，并录入数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODETIPS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTQRCODETIPS','The [{$Products.productcode}] field of {$Products.Products} is empty or not enabled. Please go to [System Settings] → [Page Settings] → [{$Products.Products} -> Page Settings] to enable the field and enter the data','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODETIPS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_tranlabel set fieldlabel="设置移动端是否启用产品扫码功能" where Relateid=211 and tabid=211 and languagetype="zh";
update ld_tranlabel set fieldlabel="Sets whether the mobile terminal enables product scanning function" where Relateid=211 and tabid=211 and languagetype="en";
delimiter;
-- 2021-01-20

UPDATE ld_desk SET fieldlabel='源单类型定制' WHERe labelbol='LBL_Optionalmodule_Customization' AND languagetype='zh' AND fieldlabel='签到源单类型定制';

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if NOT EXISTS (SELECT 1 FROM ld_account_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_normal_rule_beforeremind();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call account_singlerecycle_highsea_rule(tmp_pool_id);
						call account_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;



select sequence into @sequence from ld_homestuffdetail where stufflabel="NewCashBillCount" and stuffid=35;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
set @sequence=@sequence+1;


insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'NewPaymentPlanCashBillAmount','fixedstr','ld_cashbill.total','sum','index.php?pageto_module=CashBill&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:createdtime:createdtime:CashBill_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:createdtime:createdtime:CashBill%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:approvestatus:approvestatus:CashBill%') ;
delimiter;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill2paymentplan:entitytype:entitytype:CashBill_源单类型:V','e','PaymentPlan' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill2paymentplan:entitytype:entitytype:CashBill%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewPaymentPlanCashBillAmount','{$PaymentPlan.PaymentPlan}收款额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewPaymentPlanCashBillAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewPaymentPlanCashBillAmount','{$PaymentPlan.PaymentPlan} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewPaymentPlanCashBillAmount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


update ld_homestuffdetail set cssname="item-ico-cashbill" where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount';
update ld_homestuffdetail set sequence=sequence+1;
set @sequence=0;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'LeadUgradeToCustomerCount','fixedstr','ld_account.accountid','count','index.php?pageto_module=Accounts&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='LeadUgradeToCustomerCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='LeadUgradeToCustomerCount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:createdtime:createdtime:Accounts_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:createdtime:createdtime:Accounts%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:approvestatus:approvestatus:Accounts%') ;
delimiter;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:kis_no:kis_no:Accounts_fieldlabel:V','e','from_leads' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:kis_no:kis_no:Accounts%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LeadUgradeToCustomerCount','线索升级到{$Accounts.Accounts}数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LeadUgradeToCustomerCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LeadUgradeToCustomerCount','The lead upgrade to{$Accounts.Accounts} count','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LeadUgradeToCustomerCount' and Labeltype='fixedstr');
delimiter;

UPDATE ld_homestuffdetail SET sequence=@sequence where id=@homestuffdetailid ;
SET @i=0;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;


update ld_homestuffdetail set cssname="item-ico-account" where stuffid=35 and stufflabel='LeadUgradeToCustomerCount';

SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='kis_no';
SET @fieldname='kis_no';
SET @zh='是否来源销售线索';
SET @en='是否来源销售线索';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='text';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','50','');

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
delimiter;

update ld_homestuffdetail set icon="crm_Accounts.png" where stuffid=35 and stufflabel='LeadUgradeToCustomerCount';

update ld_homestuffdetail set icon="crm_Quotes.png" where stuffid=35 and stufflabel='NewQuotesCount';
update ld_homestuffdetail set icon="crm_Quotes.png" where stuffid=35 and stufflabel='NewQuotesAmount';
update ld_homestuffdetail set icon="crm_CashBill.png" where stuffid=35 and stufflabel='NewPaymentPlanCashBillAmount';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_ADDRESS_INFORMATION' and tabid = @tabid;
update ld_field set presence = 1 where tabid = @tabid and columnname in ('address_street','address_city','address_state','address_postalcode','address_country') and block = @blockid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Documents';
update ld_field set presence = 1 where tabid = @tabid and columnname in ('type','size');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,presence)
select 'contractamount',269,'销售指标默认值',1,100,1 from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=269);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SalesGoalMenuDefault','设置“销售指标”默认值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SalesGoalMenuDefault' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SalesGoalMenuDefault','Set the default value of the sales index','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SalesGoalMenuDefault' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetDefaultValue','设置默认值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetDefaultValue' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetDefaultValue','Set Default Values','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetDefaultValue' and labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_attachmentsforsign','storage_location','varchar','50',0);
delimiter;

CALl AddColumn('ld_attachmentsforsign','cloud_path','varchar','255',0);
delimiter;

update ld_attachmentsforsign set storage_location='local' where storage_location is null or storage_location='';
delimiter;

DROP PROCEDURE IF EXISTS `reset_expensedetail_info_formula`;
delimiter ||
CREATE  PROCEDURE `reset_expensedetail_info_formula`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tablename='ld_expensedetailscf' AND columnname='conversion_rate') THEN
		SET @this_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
		SET @this_tabdetailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='rmb_total');
		IF EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid AND formulastring='a*b*0.01') THEN
			DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid;
			INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
			SELECT @this_tabdetailfieldid,'a/b',"{formulavar:[{'lettervar':'a','column':'rmb_total'},{'lettervar':'b','column':'conversion_rate'}]}",1 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid);
		END IF;

		SET @this_tabdetailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='Rate');
		IF @this_tabdetailfieldid>0 THEN
			DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid;
		END IF;
	END IF;
end ||
delimiter;

CALL reset_expensedetail_info_formula();
DROP PROCEDURE IF EXISTS `reset_expensedetail_info_formula`;
delimiter;

DROP PROCEDURE IF EXISTS `reset_expensedetail_info`;
delimiter ||
CREATE  PROCEDURE `reset_expensedetail_info`(
)
BEGIN


	IF NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tablename='ld_expensedetailscf' AND columnname IN ('conversion_rate','currency_id')) THEN

		SET @tabid1=(SELECT tabid FROM ld_tab WHERE `name`='Expense' LIMIT 1);
		SET @tabid2=(SELECT tabid FROM ld_tab WHERE `name`='Commission' LIMIT 1);
		SET @columnname='source_total';
		SET @tablename='ld_expensedetail';
		SET @zh='源单金额';
		SET @en='Order_total';
		SET @fieldtype='Amount';
		SET @typeofdata='N~O~25,6';
		SET @edit_permission=1;
		SET @trantable='ld_tabdetailfield';

		INSERT INTO ld_tabdetailfield(
			tabid,
			columnname,
			allowhide,
			tablename,
			fieldlabel,

			defaultvalue,
			presence,
			fieldtype,
			typeofdata,
			sequence,

			width,
			edit_permission,
			input_type,
			fieldid,
			selectmodule,
			newline,
			defaultcolumn,
			is_checkimportfield,
			nullfield
			)
		SELECT 
			@tabid1,
			columnname,
			allowhide,
			@tablename,
			@zh,

			NULL,
			1,
			@fieldtype,
			@typeofdata,
			(SELECT MAX(sequence)+1 FROM ld_tabdetailfield WHERE tabid=@tabid1 LIMIT 1),

			20,
			@edit_permission,
			0,
			0,
			NULL,
			0,
			8,
			0,
			0
		FROM ld_tabdetailfield 
		WHERE tabid=@tabid2 AND columnname=@columnname 
			AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid1 AND columnname=@columnname);

		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid1 AND columnname=@columnname LIMIT 1);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid1,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid1 AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid1,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid1 AND relateid=@relateid);



		SET @tabid1=(SELECT tabid FROM ld_tab WHERE `name`='Expense' LIMIT 1);
		SET @tabid2=(SELECT tabid FROM ld_tab WHERE `name`='Commission' LIMIT 1);
		SET @columnname='rate';
		SET @tablename='ld_expensedetail';
		SET @zh='比例(%)';
		SET @en='Rate';
		SET @fieldtype='Num';
		SET @typeofdata='N~O~25,2';
		SET @edit_permission=0;
		SET @trantable='ld_tabdetailfield';

		INSERT INTO ld_tabdetailfield(
			tabid,
			columnname,
			allowhide,
			tablename,
			fieldlabel,

			defaultvalue,
			presence,
			fieldtype,
			typeofdata,
			sequence,

			width,
			edit_permission,
			input_type,
			fieldid,
			selectmodule,
			newline,
			defaultcolumn,
			is_checkimportfield,
			nullfield
			)
		SELECT 
			@tabid1,
			columnname,
			allowhide,
			@tablename,
			@zh,

			NULL,
			1,
			@fieldtype,
			@typeofdata,
			(SELECT MAX(sequence)+1 FROM ld_tabdetailfield WHERE tabid=@tabid1 LIMIT 1),

			20,
			@edit_permission,
			0,
			0,
			NULL,
			0,
			8,
			0,
			0
		FROM ld_tabdetailfield 
		WHERE tabid=@tabid2 AND columnname=@columnname 
			AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid1 AND columnname=@columnname);

		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid1 AND columnname=@columnname LIMIT 1);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid1,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid1 AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid1,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid1 AND relateid=@relateid);

		INSERT INTO ld_select_related_field(module,selectmodule,relatedstring)
		SELECT 'Expense','ServiceContracts','{"detail":[{"table_column_value":"total","fieldname":"source_total"}]}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_select_related_field WHERE module='Expense' AND selectmodule='ServiceContracts');

		INSERT INTO ld_select_related_field(module,selectmodule,relatedstring)
		SELECT 'Expense','SalesOrder','{"detail":[{"table_column_value":"total","fieldname":"source_total"}]}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_select_related_field WHERE module='Expense' AND selectmodule='SalesOrder');

		UPDATE ld_tabdetailfield SET input_type=2 WHERE tabid=@tabid1 AND columnname IN ('rmb_total','rate');
		UPDATE ld_tabdetailfield SET defaultcolumn=1 WHERE tabid=@tabid1 AND columnname IN ('source_total','rate');

		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid1 AND columnname='rmb_total' LIMIT 1);
		DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@relateid;
		INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
		SELECT @relateid,'a*b*0.01',"{formulavar:[{'lettervar':'a','column':'source_total'},{'lettervar':'b','column':'rate'}]}",1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@relateid);

		SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid1 AND columnname='rate' LIMIT 1);
		DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@relateid;
		INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
		SELECT @relateid,'a*100/b',"{formulavar:[{'lettervar':'a','column':'rmb_total'},{'lettervar':'b','column':'source_total'}]}",1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@relateid);

		CALl AddColumn('ld_expensedetail','source_total','VARCHAR','10',NULL);
		CALl AddColumn('ld_expensedetail','rate','VARCHAR','10',NULL);
		ALTER TABLE ld_expensedetail MODIFY COLUMN source_total DECIMAL(25,6);
		ALTER TABLE ld_expensedetail MODIFY COLUMN rate DECIMAL(25,2);
	END IF;
end ||
delimiter;

CALL reset_expensedetail_info();
DROP PROCEDURE IF EXISTS `reset_expensedetail_info`;
delimiter;

call AddColumn('ld_producttoolfield','referencemodule','varchar','50',NULL);
call AddColumn('ld_producttoolfield','datarange','varchar','50',NULL);
call AddColumn('ld_producttoolfield','approve_demand','varchar','50',NULL);
call AddColumn('ld_producttoolfield','maxrowsshow','int','11',0);
call AddColumn('ld_producttoolfield','bigtype','varchar','50',NULL);
call AddColumn('ld_tabdetailfield','referencemodule','varchar','50',NULL);
call AddColumn('ld_tabdetailfield','datarange','varchar','50',NULL);
call AddColumn('ld_tabdetailfield','approve_demand','varchar','50',NULL);
call AddColumn('ld_tabdetailfield','maxrowsshow','int','11',0);
call AddColumn('ld_tabdetailfield','bigtype','varchar','50',NULL);
update ld_tabdetailfield set bigtype = 'selectsource' where fieldtype = 'SelectSource';
delimiter;
-- 2021-02-01

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'MarketingCompareReport', '营销对比报告', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'MarketingCompareReport' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'MarketingCompareReport', 'Marketing Compare Report', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'MarketingCompareReport' AND Labeltype = 'fixedstr' AND languagetype = 'en'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'ProjectCompareReport', '项目对比报告', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'ProjectCompareReport' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'ProjectCompareReport', 'Project Compare Report', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'ProjectCompareReport' AND Labeltype = 'fixedstr' AND languagetype = 'en'
   );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'RankingListReport', '排行榜', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'RankingListReport' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'RankingListReport', 'Ranking List', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'RankingListReport' AND Labeltype = 'fixedstr' AND languagetype = 'en'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'MarketingReport', '营销报告', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'MarketingReport' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'MarketingReport', 'Marketing Report', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'MarketingReport' AND Labeltype = 'fixedstr' AND languagetype = 'en'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'zh', 'ProjectReport', '项目报告', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'ProjectReport' AND Labeltype = 'fixedstr' AND languagetype = 'zh'
   );


INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype
) SELECT 'en', 'ProjectReport', 'Project Report', 'fixedstr'
FROM DUAL
WHERE NOT EXISTS ( SELECT
         1 FROM
         ld_desk WHERE
         labelbol = 'ProjectReport' AND Labeltype = 'fixedstr' AND languagetype = 'en'
   );

UPDATE ld_field SET allowedit='no',allowcreate_presence='no',allowedit_presence='no',allowcreate_presence='no' WHERE displaytype=2;

CALl AddColumn('ld_workachments','storage_location','varchar','50',0);
CALl AddColumn('ld_workachments','cloud_path','varchar','255',0);
delimiter;

update ld_workachments set storage_location='local' where storage_location is null or storage_location='';
delimiter;

alter table ld_workachments alter column storage_location set default 'local';
delimiter;
-- 2021-02-02

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

UPDATE ld_version SET old_version='V8.3.8',current_version='V8.3.8',remark='V8.3.8-20210202',wx_version='V8.3.8';
delimiter;