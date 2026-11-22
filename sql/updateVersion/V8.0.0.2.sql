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

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
	tabname varchar(50),
	permissions int(19)
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
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

DROP PROCEDURE IF EXISTS `reset_newaccount_20200330`;
delimiter ||
CREATE  PROCEDURE `reset_newaccount_20200330`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=14 AND columnname='productcode' AND presence<>1) THEN 
		IF (SELECT COUNT(1) FROM ld_account WHERE deleted=0)<5 THEN
			UPDATE ld_field SET searchfieldtype=0 WHERE tabid=14 AND columnname='productcode';
		END IF;
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_leads) THEN
		SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
		UPDATE ld_module_mappingfields SET mapping_module='Accounts',mapping_columnname='mobile' WHERE tabid=@my_tabid AND columnname='mobile';
		UPDATE ld_module_mappingfields SET mapping_module='Accounts',mapping_columnname='lastname' WHERE tabid=@my_tabid AND columnname='contactname';
		UPDATE ld_module_mappingfields SET mapping_module='Accounts',mapping_columnname='title' WHERE tabid=@my_tabid AND columnname='contact_job';
	END IF;
 
END ||
delimiter;

CALL reset_newaccount_20200330();
DROP PROCEDURE IF EXISTS `reset_newaccount_20200330`;


SET @my_presence=1;
SET @my_tabid=37;
SET @my_relmodule='OutboundOrder';
SET @my_reltabid=(SELECT tabid FROM ld_tab WHERE `name`=@my_relmodule LIMIT 1);
SET @my_seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@my_tabid);
SET @my_actions='add';
SET @my_reltype='entitytype_datacategory_sql';
SET @my_relcoltable='tmpsourcedetail.id';
SET @my_buttonstatus='yes';

SET @my_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,buttonstatus)
SELECT @my_id+1,@my_tabid,@my_reltabid,CONCAT('get_',LOWER(@my_relmodule)),IFNULL(@my_seq,0)+1,@my_relmodule,@my_presence,@my_actions,0,4,@my_reltype,@my_relcoltable,0,@my_buttonstatus FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@my_tabid AND related_tabid=@my_reltabid);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;
-- 2020-03-30

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','projectsummary','项目汇总','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='projectsummary' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','projectsummary','Project summary','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='projectsummary' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','jobsummary','工单汇总','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='jobsummary' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','jobsummary','Job summary','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='jobsummary' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Engineer','工程师','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Engineer' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Engineer','Engineer','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Engineer' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Prjectnumber','项目编号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Prjectnumber' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Prjectnumber','Prject no','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Prjectnumber' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','customerprojectno','客户项目号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='customerprojectno' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','customerprojectno','Customer project No','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='customerprojectno' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','currentprojectphase','当前项目阶段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='currentprojectphase' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','currentprojectphase','Current project phase','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='currentprojectphase' and Labeltype='fixedstr');
delimiter;



select tabid into @tabid from ld_tab where name='cashbill';
update ld_field  set displaytype=2,presence=2,bigtype='translatefield',uitype=1,allowhide='no' where tabid=@tabid and columnname='cashtype';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CreateCashBill','收款','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateCashBill' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CreateCashBill','Actual receipts','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateCashBill' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CreateDebuction','预收','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateDebuction' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CreateDebuction','Collect in advance','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateDebuction' and labeltype='fixedstr');
delimiter;

SET @disable_triggers=1;
alter table ld_cashbill alter cashtype set default 'cashbill';
update ld_cashbill set cashtype='cashbill' where deleted=0 AND cashtype is null or cashtype='';
SET @disable_triggers=NULL;
delimiter;


CREATE TABLE if not exists `ld_translatefield` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `columnname` varchar(50) DEFAULT NULL,
	`column_Dbvalue` varchar(100) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `labelbol` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'cashtype','CashBill','cashbill','CreateCashBill' from dual 
where not exists(select 1 from ld_translatefield where module='CashBill' and columnname='cashtype' and column_Dbvalue='cashbill');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'cashtype','CashBill','debuction','CreateDebuction' from dual 
where not exists(select 1 from ld_translatefield where module='CashBill' and columnname='cashtype' and column_Dbvalue='debuction');
delimiter;

update ld_tranlabel 
INNER JOIN ld_field on ld_field.fieldid=ld_tranlabel.relateid
and ld_tranlabel.trantable='ld_field'
INNER JOIN ld_tab on ld_tab.tabid=ld_field.tabid
set ld_tranlabel.fieldlabel='实际收款金额'
where ld_tab.name='cashbill' and ld_field.columnname='total' and ld_tranlabel.languagetype='zh' ;
delimiter;

update ld_tranlabel 
INNER JOIN ld_field on ld_field.fieldid=ld_tranlabel.relateid
and ld_tranlabel.trantable='ld_field'
INNER JOIN ld_tab on ld_tab.tabid=ld_field.tabid
set ld_tranlabel.fieldlabel='Actual Receipts'
where ld_tab.name='cashbill' and ld_field.columnname='total' and ld_tranlabel.languagetype='en' ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'ActualReceipts','实际收款金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ActualReceipts' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'ActualReceipts','Actual Receipts','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ActualReceipts' and labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_cashbill','debuctionamount','decimal','20','0');
CALl AddColumn('ld_cashbill','debuctionbalanceamount','decimal','20','0');
delimiter;

alter table ld_cashbill  modify column debuctionamount decimal(22,8);
delimiter;
alter table ld_cashbill  modify column debuctionbalanceamount decimal(22,8);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'DeductedAmount','本次抵扣金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DeductedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'DeductedAmount','deducted amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DeductedAmount' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CanDeductibleAmount','可抵扣金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CanDeductibleAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CanDeductibleAmount','can deductible amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CanDeductibleAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'UsedAmount','核销金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UsedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'UsedAmount','Used Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UsedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'AvailableAmount','余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AvailableAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'AvailableAmount','Available Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AvailableAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'UsedAmountHistory','核销记录','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UsedAmountHistory' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'UsedAmountHistory','Used Amount Detail','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UsedAmountHistory' and labeltype='fixedstr');
delimiter;

CALL getallprofile('CashBill');
CALL fieldprofile('CashBill');
delimiter;

CREATE TABLE if not exists `ld_cashbilldebuctiondetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `cashbillid` int(19) DEFAULT NULL,
	`debuctionid` int(19) DEFAULT NULL,
	`amount` decimal(22,8) default 0,
  `userid` int(11) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @modulename='CashBill';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='cashbill_no' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='cashbill_no' LIMIT 1);
SET @columnname='debuctionamount';
SET @fieldname='debuctionamount';
SET @zh='已核销金额';
SET @en='Used Amount';
SET @uitype=72;
SET @typeofdata='N~O~22,2';
SET @quickcreate=0;
SET @displaytype=2;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


set @relateid=(select fieldid from ld_field where tabid=@tabid and columnname=@columnname);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field' ,@tabid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='zh' and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field' ,@tabid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='en' and trantable='ld_field');

SET @columnname='debuctionbalanceamount';
SET @fieldname='debuctionbalanceamount';
SET @zh='余额';
SET @en='Available Amount';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

set @relateid=(select fieldid from ld_field where tabid=@tabid and columnname=@columnname);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field' ,@tabid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='zh' and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field' ,@tabid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='en' and trantable='ld_field');
delimiter;
-- 2020-03-31

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

UPDATE ld_version SET old_version='V8.0.0.2',current_version='V8.0.0.2',remark='V8.0.0.2-20200331',wx_version='ceshi';
delimiter;