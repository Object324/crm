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

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOTNEEDTOIMPORTCONTACTS','（如果不需要导入{$Contacts.Contacts}，请将查重字段设置为“--无--”）','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NOTNEEDTOIMPORTCONTACTS' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOTNEEDTOIMPORTCONTACTS','(If you do not need to import {$Contacts.Contacts}, set the lookup field to"--none--")','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NOTNEEDTOIMPORTCONTACTS' and Labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_select_related_field(module,selectmodule,relatedstring)
select 'ServiceContracts','SalesOrder','{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"contactid","fieldname":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'ServiceContracts' and selectmodule = 'SalesOrder');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_sql":[{"sql":"select contactid as input_id,lastname as input_name from ld_contactdetails where accountid = ? and reference = 1 limit 1","input_name":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid and fieldtype = 'main');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_sql":[{"sql":"select contactid as input_id,lastname as input_name from ld_contactdetails where accountid = ? and reference = 1 limit 1","input_name":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid and fieldtype = 'main');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_sql":[{"sql":"select contactid as input_id,lastname as input_name from ld_contactdetails where accountid = ? and reference = 1 limit 1","input_name":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid and fieldtype = 'main');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 16 and columnname = 'accountid';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_sql":[{"sql":"select contactid as input_id,lastname as input_name from ld_contactdetails where accountid = ? and reference = 1 limit 1","input_name":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid and fieldtype = 'main');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_sql":[{"sql":"select contactid as input_id,lastname as input_name from ld_contactdetails where accountid = ? and reference = 1 limit 1","input_name":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid and fieldtype = 'main');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldid,fieldtype,relatedstring)
select @fieldid,'main','{"main_sql":[{"sql":"select contactid as input_id,lastname as input_name from ld_contactdetails where accountid = ? and reference = 1 limit 1","input_name":"contact_id"}]}' from DUAL
where not exists(select 1 from ld_related_field where fieldid = @fieldid and fieldtype = 'main');
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
update ld_relatedlists set related_coltable='accountpotentialrel.potentialid' where tabid=@tabid and name='get_accounts';
delimiter;

alter table ld_cashbill alter column Total set default 0.00;
alter table ld_cashbill alter column NoPaymentplan set default 0.00;
alter table ld_cashbill alter column subtotal set default 0.00;
alter table ld_sendcashbill alter column Total set default 0.00;
alter table ld_sendcashbill alter column nosendpayment set default 0.00;
alter table ld_sendcashbill alter column subtotal set default 0.00;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CRMSYSTEMSYNCHRONIZED','CRM系统的{$Accounts.Accounts}和{$Contacts.Contacts}成功同步到帮我吧系统','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CRMSYSTEMSYNCHRONIZED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CRMSYSTEMSYNCHRONIZED','CRM system {$Accounts.Accounts} and {$Contacts.Contacts} are synchronized to bangwo8 system','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CRMSYSTEMSYNCHRONIZED' and labeltype = 'jspop');
delimiter;
-- 2017-04-19

update ld_desk set fieldlabel='发送邮件并添加附件' where labelbol='Send_Email_Add_PDF' and languagetype='zh';

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CRMSYSTEMTONGBUBANGWOBASYSTEM','CRM系统的{$Accounts.Accounts}和{$Contacts.Contacts}同步到帮我吧系统','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CRMSYSTEMTONGBUBANGWOBASYSTEM' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CRMSYSTEMTONGBUBANGWOBASYSTEM','Synchronization of {$Accounts.Accounts} and {$Contacts.Contacts}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CRMSYSTEMTONGBUBANGWOBASYSTEM' and Labeltype = 'fixedstr');
delimiter;
-- 2017-04-21

select tabid into @tabid from ld_tab where `name`='Commission';
update ld_tabdetailfield set width=25 where tabid=@tabid and columnname='cashbilldate' and width<25;
select tabdetailfieldid into @fieldid from ld_tabdetailfield where tabid=@tabid and columnname='rate';
update ld_tranlabel set fieldlabel='比例(%)' where tabid=@tabid and Relateid=@fieldid and languagetype='zh' 
	and trantable='ld_tabdetailfield' and fieldlabel='比例';
update ld_tranlabel set fieldlabel='Proportion(%)' where tabid=@tabid and Relateid=@fieldid and languagetype='en' 
	and trantable='ld_tabdetailfield' and fieldlabel='Proportion';

update ld_tabdetailfield set typeofdata='V~O' where tabid=@tabid and columnname='remark'
	and not exists (select 1 from ld_commission);
delimiter;

update ld_productcategory set productcategory='产品' where productcategory='KIS迷你版' and not exists (select 1 from ld_products);
update ld_productcategory set productcategory='服务' where productcategory='KIS标准版' and not exists (select 1 from ld_products);

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'fax';
select min(id) into @minid from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid group by fieldid;
delete from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid and id != @minid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'purchaseback_no';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'purchasebackdate';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'purchasebackstatus';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'smownerid';

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);
delimiter;


select tabid into @tabid from ld_tab where name='PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,1,1,1 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='publicannouncement_type';

insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,2,1,0 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='startdate';

insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,3,1,0 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='enddate';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,4,1,0 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='content';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,5,1,0 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='userid';

insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,6,1,0 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';

insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)select @tabid ,@fieldid,0,7,1,0 from DUAL
where not EXISTS(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'subject';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'checksdate';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'wareid';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'presence';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'smownerid';
select fieldid into @fieldid6 from ld_field where tabid = @tabid and columnname = 'subsmownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid6,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'purchasecashback_no';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'total';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'purchasecashbackdate';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'purchaseback_id';
select fieldid into @fieldid6 from ld_field where tabid = @tabid and columnname = 'bankaccountsetid';
select fieldid into @fieldid7 from ld_field where tabid = @tabid and columnname = 'crpaymentmethod';
select fieldid into @fieldid8 from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid6,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid6);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid7,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid7);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid8,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PutCash';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'putcash_no';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'putcashdate';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'outaccount';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'inaccount';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'cashmoney';
select fieldid into @fieldid6 from ld_field where tabid = @tabid and columnname = 'billnumber';
select fieldid into @fieldid7 from ld_field where tabid = @tabid and columnname = 'approvestatus';
select fieldid into @fieldid8 from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid6,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid6);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid7,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid7);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid8,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashDeposit';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'cashdeposit_no';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'cashdepositdate';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'outaccount';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'inaccount';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'cashmoney';
select fieldid into @fieldid6 from ld_field where tabid = @tabid and columnname = 'billnumber';
select fieldid into @fieldid7 from ld_field where tabid = @tabid and columnname = 'approvestatus';
select fieldid into @fieldid8 from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid6,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid6);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid7,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid7);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid8,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankAccountSet';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'accountname';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'discontinued';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'banknum';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'bankname';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'initmoney';
select fieldid into @fieldid6 from ld_field where tabid = @tabid and columnname = 'curbalancemoney';
select fieldid into @fieldid7 from ld_field where tabid = @tabid and columnname = 'currency_id';
select fieldid into @fieldid8 from ld_field where tabid = @tabid and columnname = 'smcreatorid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid6,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid6);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid7,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid7);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid8,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
select fieldid into @fieldid1 from ld_field where tabid = @tabid and columnname = 'commentcontent';
select fieldid into @fieldid2 from ld_field where tabid = @tabid and columnname = 'reltab';
select fieldid into @fieldid3 from ld_field where tabid = @tabid and columnname = 'related_to';
select fieldid into @fieldid4 from ld_field where tabid = @tabid and columnname = 'parent_comments';
select fieldid into @fieldid5 from ld_field where tabid = @tabid and columnname = 'createdtime';
select fieldid into @fieldid6 from ld_field where tabid = @tabid and columnname = 'modifiedtime';
select fieldid into @fieldid7 from ld_field where tabid = @tabid and columnname = 'smownerid';
select fieldid into @fieldid8 from ld_field where tabid = @tabid and columnname = 'smcreatorid';

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid1,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid1);
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid2,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid2);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid3,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid3);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid4,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid4);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid5,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid5);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid6,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid6);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid7,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid7);

insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid8,0,6,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid8);
delimiter;

call AddColumn('ld_relatedlists','wx_presence','int',10,0);
delimiter;

call AddColumn('ld_relatedlists','wx_sequence','int',10,0);
delimiter;

update ld_relatedlists set wx_sequence=sequence,wx_presence=1;
delimiter;

update ld_relatedlists a
LEFT JOIN ld_tab b ON b.tabid=a.tabid
LEFT JOIN ld_tab c ON c.tabid=a.related_tabid
INNER JOIN (SELECT DISTINCT modulename FROM ld_cvcolumnlist_wx) d ON d.modulename=b.`name`
INNER JOIN (SELECT DISTINCT modulename FROM ld_cvcolumnlist_wx) e ON e.modulename=c.`name`
SET a.wx_presence=0
WHERE a.wx_presence=1;

update ld_relatedlists set wx_presence=0 where name = 'get_SharedUsers';
delimiter;

select tabid into @tabid from ld_tab where name='PriceBooks';
update ld_relatedlists set type='pricebookproductrel_datacategory_sql' where tabid=@tabid and name='get_pricebook_products'; 
delimiter;

update ld_systems_deploy set presence=1 where deploy_type = 77;
delimiter;

select tabid into @tabid from ld_tab where name='PriceBooks';
update ld_relatedlists set type='' where tabid=@tabid and  name='get_pricebook_products'; 
delimiter;
-- 2017-04-25

CALL AddColumn('ld_field','allowhide','varchar',10,'');
delimiter;

CALL AddColumn('ld_producttoolfield','allowhide','varchar',10,'');
delimiter;

CALL AddColumn('ld_tabdetailfield','allowhide','varchar',10,'');
delimiter;

ALTER TABLE ld_field CHANGE allowhide allowhide varchar(10) DEFAULT 'yes' AFTER columnname;
ALTER TABLE ld_tabdetailfield CHANGE allowhide allowhide varchar(10) DEFAULT 'yes' AFTER columnname;
ALTER TABLE ld_producttoolfield CHANGE allowhide allowhide varchar(10) DEFAULT 'yes' AFTER columnname;
UPDATE ld_field SET allowhide='yes' WHERE IFNULL(allowhide,'')<>'no';
UPDATE ld_tabdetailfield SET allowhide='yes' WHERE IFNULL(allowhide,'')<>'no';
UPDATE ld_producttoolfield SET allowhide='yes' WHERE IFNULL(allowhide,'')<>'no';
delimiter;

UPDATE ld_field SET allowhide='no' WHERE uitype in (4,53);
UPDATE ld_field SET allowhide='no' WHERE columnname='total';
UPDATE ld_producttoolfield SET allowhide='no' WHERE columnname in ('productname','quantity','taxprice','tax_amount','total');
UPDATE ld_tabdetailfield SET allowhide='no' WHERE columnname='total';
UPDATE ld_tabdetailfield SET allowhide='no' WHERE columnname in ('expensetype','rmb_total') AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
UPDATE ld_tabdetailfield SET allowhide='no' WHERE columnname in ('workdate','costtime') AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet');
UPDATE ld_tabdetailfield SET allowhide='no' WHERE columnname='amount' AND tabid in (SELECT tabid FROM ld_tab WHERE `name` in ('CashBill','SendCashBill'));
UPDATE ld_tabdetailfield SET allowhide='no' WHERE columnname in ('amount','rate') AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
delimiter;
-- 2017-04-27

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
select 'Faq',0,0,'ld_faq:faq_no:faq_no:Faq_常见问题编号:V',2,'蓝色加粗' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Faq' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'Faq',1,0,'ld_faq:category:faqcategories:Faq_问题类别:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Faq' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'Faq',1,1,'ld_faq:faqtype:faqtype:Faq_常见问题:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Faq' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'Faq',1,2,'ld_faq:question:question:Faq_问题:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'Faq' and rownumber=1 AND listnumber=2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Faq';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

update ld_systems_deploy set description = '九维呼叫中心地址' where deploy_type=101;
delimiter;
update ld_systems_deploy set description = '思孚呼叫中心地址' where deploy_type=107;
delimiter;
update ld_systems_deploy set description = '汉天呼叫中心地址' where deploy_type=121;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEINSTALLOPENOFFICE','请安装openoffice组建！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'PLEASEINSTALLOPENOFFICE' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEINSTALLOPENOFFICE','Please install OpenOffice！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'PLEASEINSTALLOPENOFFICE' and labeltype = 'fixedstr');
delimiter;

update ld_producttoolfield SET defaultcolumn = 4 where uitype = 204;
delimiter;

update ld_desk set fieldlabel='应收/应付款' WHERE labelbol='Receivables' and languagetype='zh';
update ld_desk set fieldlabel='Payable  Receivable' WHERE labelbol='Receivables' and languagetype='en';

update ld_desk set fieldlabel='只统计应收款余额不为0的数据' where labelbol='OSDRBISGT0' and languagetype='zh';
update ld_desk set fieldlabel='Only statistical data receivable balance not equal 0' where labelbol='OSDRBISGT0' and languagetype='en';

update ld_customreport_info set setype='CashBill' where report_template in ('default_account_cashbilltop50.mrt','default_account_cashbilltop10.mrt');
update ld_customreport_info set setype='SalesOrder' where report_template in ('default_account_qianyuetop10.mrt','default_account_qianyuetop50.mrt');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CASHBILLNETGROSS','收款毛利','fixedstr' from dual
 where not exists(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='CASHBILLNETGROSS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CASHBILLNETGROSS','收款毛利','fixedstr' from dual
 where not exists(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='CASHBILLNETGROSS' and labeltype='fixedstr');
delimiter;

UPDATE ld_servicecontracts a
INNER JOIN (
	SELECT 
		servicecontractsid,
		count(1) AS cnt 
	FROM ld_troubletickets 
	WHERE servicecontractsid>0 
		AND deleted=0 
		AND IFNULL(approvestatus,'')<>'已拒绝' 
	GROUP BY servicecontractsid
) b ON a.servicecontractsid=b.servicecontractsid
SET a.service_units=b.cnt
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=6 AND columnname='service_units');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Totalproportionhasbeenmorethan100','Total proportion has been more than 100！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Totalproportionhasbeenmorethan100' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Totalproportionhasbeenmorethan100','回款比例合计已经超过100！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Totalproportionhasbeenmorethan100' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Theproportionofthetotalreturnisequalto100','The proportion of the total return is equal to 100！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Theproportionofthetotalreturnisequalto100' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Theproportionofthetotalreturnisequalto100','回款比例合计已经等于100！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Theproportionofthetotalreturnisequalto100' and labeltype = 'jspop');
delimiter;

update ld_relatedlists set type='accountlessionplan_datacategory_sql',related_coltable='lessionplanorg.accountid' where tabid=6 and name='get_LessionPlan';
delimiter;
update ld_field set typeofdata='V~M' where tabid in(select tabid from ld_tab where name='purchaseorder') and columnname='vendorid' and typeofdata='I~M';
update ld_field set typeofdata='V~O' where tabid in(select tabid from ld_tab where name='purchaseorder') and columnname='vendorid' and typeofdata='I~O';
delimiter;

update ld_field set approve_demand=0 where uitype=82;
delimiter;

insert into ld_customreport_folder(folder_name,sequence,systemdefault,visible,description)
select '呼叫中心报表',0,1,0,'呼叫中心报表' from dual 
where not exists (select 1 from ld_customreport_folder where (description='呼叫中心报表' or folder_name='呼叫中心报表') and systemdefault=1);
delimiter;
SELECT id into @id from ld_customreport_folder where description='呼叫中心报表';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'汉天呼叫中心通话记录统计报表','template','default_callcenter_report.mrt',@sequence+1,0,1,0,'OftenUseReport' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_callcenter_report.mrt' and systemdefault=1);
delimiter;
SELECT id into @id from ld_customreport_folder where description='呼叫中心报表';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'汉天呼叫中心通话记录明细表','template','default_callcenter_detail.mrt',@sequence+1,0,1,0,'OftenUseReport' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_callcenter_detail.mrt' and systemdefault=1);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CASHBILLNETGROSS','收款毛利','fixedstr' from dual
 where not exists(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='CASHBILLNETGROSS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CASHBILLNETGROSS','收款毛利','fixedstr' from dual
 where not exists(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='CASHBILLNETGROSS' and labeltype='fixedstr');
delimiter;

update ld_field set typeofdata='V~O' where tabid in(select tabid from ld_tab where name='InventoryAccount') and columnname='entityid';
delimiter;
call AddColumn('ld_relatedlists','trade','varchar',100,'');
delimiter;
update ld_relatedlists set trade='jinrong' where tabid=6 and name='get_buyproduct';
update ld_relatedlists set trade='jijin' where tabid=6 and name='get_buyproductquantity';
delimiter;
-- 2017-05-05

select max(sequence) into @i from ld_field where tabid=4 and block=4;
update ld_field set sequence=(@i:=@i+1) where tabid=4 and block=4 and columnname in ('currentapprover','approvestatus','approveby') and sequence is NULL ORDER BY fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=4 and block=4 and presence<>1 order by sequence;
delimiter;

update ld_field set displaytype=2 where displaytype=1 and columnname='stockpresence' and tablename='ld_purchaseinvoice';

update ld_field set allowhide='no' where tabid=6 and columnname in ('accountname','account_no','smownerid');
update ld_field set allowhide='no' where tabid=4 and columnname in ('lastname','contact_no','smownerid','accountid');

select tabid into @tabid from ld_tab where `name`='ContactRecords';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_contactrecords';
set @columnname='contactrecord_no';
set @fieldname='contactrecord_no';
set @zh='单据编号';
set @en='Contactrecord No';
set @uitype=4;
set @readonly=0;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','100',NULL);
delimiter;

call getallprofile('ContactRecords');
delimiter;
call fieldprofile('ContactRecords');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,UseUserAccount,isallow,prefixtype)
select (select id+1 from ld_modentity_num_seq),'ContactRecords','LXJL',1,1,1,'none',0,0,0 from dual 
where not exists (select 1 from ld_modentity_num where semodule='ContactRecords');

update ld_modentity_num_seq set id=(select max(num_id) from ld_modentity_num);
delimiter;

select tabid into @tabid from ld_tab where `name`='ContactRecords';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_contactdetails);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactdate' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactrecord_no' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactrecordtype' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='accountid' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactid' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='potentialid' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='salesorderid' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='troubleticketid' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='nextcontactdate' and not exists (select 1 from ld_contactdetails);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_contactdetails);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_contactdetails) order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_contactdetails);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_contactdetails);
delimiter;

update ld_entityname set fieldname='contactrecord_no' where modulename='ContactRecords' and not exists (select 1 from ld_contactdetails);
update ld_cvcolumnlist set columnname='ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_fieldlabel:V' 
	where cvid in (select cvid from ld_customview where entitytype='ContactRecords') and columnname like '%ld_contactrecords:subject%'
	and not exists (select 1 from ld_contactdetails);

select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('contactrecord_no','contactdate','smownerid','accountid');

update ld_field set allowhide='no' where tabid=2 and columnname in ('potentialname','potential_no','sales_stage','closingdate','currency_id','amount','smownerid','accountid');

update ld_field set allowhide='no' where tabid=20 and columnname in ('quote_no','quotestage','accountid','smownerid');

update ld_field set presence=1 where tabid=20 and columnname='s_h_amount' and not exists (select 1 from ld_quotes);

select fieldid into @fieldid from ld_field where tabid=20 and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=20 and columnname='subject' and not exists (select 1 from ld_quotes);
update ld_tranlabel set fieldlabel='摘要' where tabid=20 and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_quotes);

select tabid into @tabid from ld_tab where `name`='Quotes';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_quotes);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='accountid' and not exists (select 1 from ld_quotes);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='quote_no' and not exists (select 1 from ld_quotes);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactid' and not exists (select 1 from ld_quotes);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='potentialid' and not exists (select 1 from ld_quotes);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='validtill' and not exists (select 1 from ld_quotes);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='quotestage' and not exists (select 1 from ld_quotes);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_quotes);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_quotes) order by sequence;
delimiter;

update ld_field set allowhide='no' where tabid=22 and columnname in ('salesorder_no','signed_data','sostatus','accountid','smownerid');

select fieldid into @fieldid from ld_field where tabid=22 and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=22 and columnname='subject' and not exists (select 1 from ld_salesorder);
update ld_tranlabel set fieldlabel='摘要' where tabid=22 and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_salesorder);

select tabid into @tabid from ld_tab where `name`='SalesOrder';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_salesorder);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='accountid' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='salesorder_no' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactid' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='parentid' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='potentialid' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='quoteid' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='signed_data' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='duedate' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='sostatus' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_salesorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_salesorder);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_salesorder) order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='SalesBack';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('salesback_no','salesorderid','accountid','wareid','salesbackstatus','smownerid');
delimiter;

set @tabid=37;
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('contract_no','due_date','contract_status','accountid','smownerid');

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_servicecontracts);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_servicecontracts);

select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_servicecontracts);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='accountid' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contract_no' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactid' and not exists (select 1 from ld_servicecontracts);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='potentialid' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='salesorderid' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contract_type' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='due_date' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contract_status' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='total_units' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='service_units' and not exists (select 1 from ld_servicecontracts);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_servicecontracts);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_servicecontracts) order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('accountname','account_no','smownerid','servicecasher');

select tabid into @tabid from ld_tab where `name`='HelpDesk';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('ticket_no','accountid','servicetype','category','status','smownerid');

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='ticket_title';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='ticket_title' and not exists (select 1 from ld_troubletickets);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_troubletickets);

select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_troubletickets);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='accountid' and not exists (select 1 from ld_troubletickets);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='ticket_no' and not exists (select 1 from ld_troubletickets);
update ld_field set sequence=100000 where tabid=@tabid and columnname='ticket_title' and not exists (select 1 from ld_troubletickets);


set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_troubletickets) order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceReturn';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('servicereturn_no','accountid','troubleticketid','smownerid');

select tabid into @tabid from ld_tab where `name`='Project';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('project_no','projectname','projectstatus','accountid','smownerid');

select tabid into @tabid from ld_tab where `name`='ProjectTask';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('projecttask_no','projecttaskname','projecttaskstatus','projectid','smownerid');

select tabid into @tabid from ld_tab where `name`='ProjectMilestone';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('projectmilestone_no','projectmilestonename','projectid','smownerid');

select tabid into @tabid from ld_tab where `name`='Invoice';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('invoice_no','invoicedate','invoicestatus','accountid','smownerid');
update ld_field set allowhide='no' where tabid=@tabid and uitype=202;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_invoice);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_invoice);

select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_invoice);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='accountid' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='invoice_no' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='invoicedate' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='invoice_num' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='invoicetype' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='invoicestatus' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and uitype=202 and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_invoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_invoice);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_invoice) order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('purchaseinvoice_no','purchaseinvoicedate','purchaseinvoicestatus','vendorid','smownerid');
update ld_field set allowhide='no' where tabid=@tabid and uitype=202;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_purchaseinvoice);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_purchaseinvoice);

select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_purchaseinvoice);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='vendorid' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='purchaseinvoice_no' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='purchaseinvoicedate' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='purchaseinvoicenum' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='purchaseinvoicetype' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='purchaseinvoicestatus' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and uitype=202 and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_purchaseinvoice);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_purchaseinvoice);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_purchaseinvoice) order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='CashBill';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('cashbill_no','accountid','cashbilldate','bankaccountsetid','currency_id','smownerid');
update ld_field set allowhide='no' where tabid=@tabid and uitype=202;

select tabid into @tabid from ld_tab where `name`='SendCashBill';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('sendcashbill_no','vendorid','cashbilldate','bankaccountsetid','currency_id','smownerid');
update ld_field set allowhide='no' where tabid=@tabid and uitype=202;


select tabid into @tabid from ld_tab where `name`='Expense';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('expense_no','accountid','bankaccountsetid','smownerid');

select tabid into @tabid from ld_tab where `name`='Commission';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('commission_no','accountid','bankaccountsetid','smownerid','expensedate');

select tabid into @tabid from ld_tab where `name`='PutCash';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('putcash_no','outaccount','inaccount','currency_id','cashmoney','putcashdate','smownerid');

select tabid into @tabid from ld_tab where `name`='CashDeposit';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('cashdeposit_no','outaccount','inaccount','currency_id','cashmoney','cashdepositdate','smownerid');

select tabid into @tabid from ld_tab where `name`='BankAccountSet';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('accountname','discontinued','banknum','bankname','currency_id','initmoney');

select tabid into @tabid from ld_tab where `name`='OutboundOrder';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('outdate','out_no','accountid','wareid','smownerid');
update ld_field set allowhide='no' where tabid=@tabid and uitype=202;

select tabid into @tabid from ld_tab where `name`='Stock';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('createdate','ware_stock_no','vendor_id','wareid','smownerid');
update ld_field set allowhide='no' where tabid=@tabid and uitype=202;

select tabid into @tabid from ld_tab where `name`='WareHouseTransfer';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('transferdate','transferdate_no','outwarehouse','inwarehouse','smownerid');

select tabid into @tabid from ld_tab where `name`='Checks';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_checks';
set @columnname='checks_no';
set @fieldname='checks_no';
set @zh='盘点单编号';
set @en='Checks No';
set @uitype=4;
set @readonly=0;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','100',NULL);
delimiter;

call getallprofile('Checks');
delimiter;
call fieldprofile('Checks');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,UseUserAccount,isallow,prefixtype)
select (select id+1 from ld_modentity_num_seq),'Checks','PD',1,1,1,'none',0,0,0 from dual 
where not exists (select 1 from ld_modentity_num where semodule='Checks');

update ld_modentity_num_seq set id=(select max(num_id) from ld_modentity_num);
delimiter;


select tabid into @tabid from ld_tab where `name`='Checks';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_checks);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='checksdate' and not exists (select 1 from ld_checks);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='checks_no' and not exists (select 1 from ld_checks);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='wareid' and not exists (select 1 from ld_checks);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_checks);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_checks);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_checks) order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_checks);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_checks);
delimiter;


update ld_entityname set fieldname='checks_no' where modulename='Checks' and not exists (select 1 from ld_checks);
update ld_tabwithproductview set `columns`='ld_checks:checks_no:checks_no:Checks_fieldlabel:V' 
	where cvid in (select cvid from ld_customview where entitytype='Checks') and `columns` like '%ld_checks:subject%'
	and not exists (select 1 from ld_checks);

select tabid into @tabid from ld_tab where `name`='Checks';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('checks_no','checksdate','smownerid','wareid');

select tabid into @tabid from ld_tab where `name`='Vendors';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('vendorname','vendor_no','smownerid');


select tabid into @tabid from ld_tab where `name`='Vendors';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('lastname','vendorcontact_no','vendorid','smownerid');

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_vendorcontactrecords';
set @columnname='contactrecord_no';
set @fieldname='contactrecord_no';
set @zh='单据编号';
set @en='Contactrecord No';
set @uitype=4;
set @readonly=0;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','100',NULL);
delimiter;

call getallprofile('VendorContactRecords');
delimiter;
call fieldprofile('VendorContactRecords');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,UseUserAccount,isallow,prefixtype)
select (select id+1 from ld_modentity_num_seq),'VendorContactRecords','GYSLXJL',1,1,1,'none',0,0,0 from dual 
where not exists (select 1 from ld_modentity_num where semodule='VendorContactRecords');

update ld_modentity_num_seq set id=(select max(num_id) from ld_modentity_num);
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_vendorcontactrecords);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactdate' and not exists (select 1 from ld_vendorcontactrecords);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactrecord_no' and not exists (select 1 from ld_vendorcontactrecords);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactrecordtype' and not exists (select 1 from ld_vendorcontactrecords);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_vendorcontactrecords);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='vendorid' and not exists (select 1 from ld_vendorcontactrecords);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactid' and not exists (select 1 from ld_vendorcontactrecords);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_vendorcontactrecords);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_vendorcontactrecords) order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_vendorcontactrecords);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_vendorcontactrecords);
delimiter;

update ld_entityname set fieldname='contactrecord_no' where modulename='VendorContactRecords' and not exists (select 1 from ld_vendorcontactrecords);
update ld_cvcolumnlist set columnname='ld_vendorcontactrecords:contactrecord_no:contactrecord_no:VendorContactRecords_fieldlabel:V' 
	where cvid in (select cvid from ld_customview where entitytype='VendorContactRecords') and columnname like '%ld_vendorcontactrecords:subject%'
	and not exists (select 1 from ld_vendorcontactrecords);

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('contactrecord_no','contactdate','smownerid','accountid');


select tabid into @tabid from ld_tab where `name`='PurchaseOrder';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('purchaseorder_no','signed_data','postatus','vendorid','smownerid');

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subject';
update ld_field set fieldlabel='摘要',typeofdata='V~O' where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_purchaseorder);
update ld_tranlabel set fieldlabel='摘要' where tabid=@tabid and Relateid=@fieldid and trantable='ld_field' and languagetype='zh' and not exists (select 1 from ld_purchaseorder);

select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid and not exists (select 1 from ld_purchaseorder);

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='vendorid' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='purchaseorder_no' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='contactid' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='postatus' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='signed_data' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='duedate' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and uitype=200 and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid' and not exists (select 1 from ld_purchaseorder);
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='subject' and not exists (select 1 from ld_purchaseorder);

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 and not exists (select 1 from ld_purchaseorder) order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseBack';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('purchaseback_no','purchaseorder_id','vendorid','wareid','purchasebackstatus','smownerid');
delimiter;

select tabid into @tabid from ld_tab where `name`='Campaigns';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('campaignname','campaign_no','smownerid');
update ld_entityname set fieldname='campaign_no' where modulename='Campaigns' and not exists (select 1 from ld_campaign);
delimiter;

select tabid into @tabid from ld_tab where `name`='Products';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('productname','product_no','productsheet','discontinued','unit_price','smownerid');
delimiter;

select tabid into @tabid from ld_tab where `name`='PriceBooks';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('bookname','pricebook_no','currency_id','active','smownerid');
delimiter;

select tabid into @tabid from ld_tab where `name`='Users';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('user_name','is_admin','user_password','confirm_password','last_name',
	'profileid','groupid','status','phone_mobile','email1','wx_userid','approvestatus','approveby',
	'accountallview','select_servicedetail','select_due_date','scopeauthority','viewothers','editothers','delothers','viewselfbills','edit_other_mobile',
	'edit_me_mobile','is_mobile_style','login_sms','push_work_reminds','telephone_view','push_news_reminds','trackgroupid');
delimiter;

select tabid into @tabid from ld_tab where `name`='Documents';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('notes_title','folderid','smownerid','note_no');

select tabid into @tabid from ld_tab where `name`='Faq';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('faq_no','question','answer','smownerid');
update ld_entityname set fieldname='faq_no' where modulename='Faq' and not exists (select 1 from ld_faq);

select tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('attachment_no','isenabled','smownerid','filename');

select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @i=0;

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@blockid;

update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='isenabled';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='attachment_no';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='related_to';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and columnname='description';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid and presence<>1 order by sequence;
delimiter;

set @i=0;
update ld_contactrecords set contactrecord_no=concat('LXJL',(@i:=@i+1)) where exists (select 1 from ld_modentity_num where semodule='ContactRecords' and cur_id=1) ORDER BY contactrecordID;
update ld_modentity_num set cur_id=@i+1 where semodule='ContactRecords' AND prefix='LXJL' AND cur_id<@i;
delimiter;

set @i=0;
update ld_vendorcontactrecords set contactrecord_no=concat('GYSLXJL',(@i:=@i+1)) where exists (select 1 from ld_modentity_num where semodule='VendorContactRecords' and cur_id=1) ORDER BY contactRecordsid;
update ld_modentity_num set cur_id=@i+1 where semodule='VendorContactRecords' AND prefix='GYSLXJL' AND cur_id<@i;
delimiter;

set @i=0;
update ld_checks set checks_no=concat('PD',(@i:=@i+1)) where exists (select 1 from ld_modentity_num where semodule='Checks' and cur_id=1) ORDER BY id;
update ld_modentity_num set cur_id=@i+1 where semodule='Checks' AND prefix='PD' AND cur_id<@i;
delimiter;
-- 2017-05-09

select tabid into @tabid from ld_tab where `name`='ContactRecords';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_contactrecords';
set @columnname='product_id';
set @fieldname='product_id';
set @zh='产品名称';
set @en='产品名称';
set @uitype=59;
set @readonly=0;
set @presence=0;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='I~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int','19',0);
delimiter;

call getallprofile('ContactRecords');
delimiter;
call fieldprofile('ContactRecords');
delimiter;

set @tabid=7;
delete from ld_tab where tabid=@tabid;
delete from ld_field where tabid=@tabid;
drop table if exists vtiger_leaddetails;
drop table if exists vtiger_leadaddress;
drop table if exists vtiger_leadsubdetails;
delimiter;

delete from ld_tab where tabid in (24,27,30,31,32,34,36,38,39,40,41,42,43,50,52,54,58,59);
-- 2017-05-10

SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
SELECT concat('数据来源：',GROUP_CONCAT(fieldlabel SEPARATOR '和')) into @report_describe from ld_tranlabel where tabid in (22,37) and languagetype='zh' and trantable='ld_tab';
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,'销售提成表——按合同统计','template','default_performance_byorder.mrt',@sequence+1,0,1,0,'SalesOrder',@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_performance_byorder.mrt' and systemdefault=1);
delimiter;

SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
SELECT concat('数据来源：',GROUP_CONCAT(fieldlabel SEPARATOR '和')) into @report_describe from ld_tranlabel where tabid=(select tabid from ld_tab where `name`='CashBill') and languagetype='zh' and trantable='ld_tab';
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,'销售提成表——按收款统计','template','default_performance_bycashbill.mrt',@sequence+1,0,1,0,'CashBill',@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_performance_bycashbill.mrt' and systemdefault=1);
delimiter;

update ld_cashbill2paymentplan 
LEFT JOIN ld_cashbill on ld_cashbill.cashbillid = ld_cashbill2paymentplan.CashBillID 
set ld_cashbill2paymentplan.amount = ld_cashbill2paymentplan.amount + ld_cashbill.NoPaymentplan,ld_cashbill.NoPaymentplan = 0 
where ld_cashbill.NoPaymentplan <> 0 and ld_cashbill2paymentplan.sequence = 1; 
delimiter;

update ld_sendcashbill2payment 
LEFT JOIN ld_sendcashbill on ld_sendcashbill.sendcashbillid = ld_sendcashbill2payment.sendcashbillid 
set ld_sendcashbill2payment.amount = ld_sendcashbill2payment.amount + ld_sendcashbill.nosendpayment,ld_sendcashbill.nosendpayment = 0 
where ld_sendcashbill.nosendpayment <> 0 and ld_sendcashbill2payment.Sequence = 1; 
delimiter;
-- 2017-05-12

update ld_account LEFT JOIN
(select * from (
select accountid,quoteid,createdtime from ld_quotes where deleted = 0 and accountid > 0 ORDER BY createdtime desc
) as tep GROUP BY tep.accountid) as acc_lastdate on acc_lastdate.accountid = ld_account.accountid set ld_account.lastquotedate = acc_lastdate.createdtime;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATE','不创建','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'NOTCREATE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATE','Not create','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'NOTCREATE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATEAFTERSAVE','新增保存时创建','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CREATEAFTERSAVE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATEAFTERSAVE','Create after new additions','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CREATEAFTERSAVE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATEAFTERAPPROVE','审批通过时创建','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CREATEAFTERAPPROVE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATEAFTERAPPROVE','Create after approved','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CREATEAFTERAPPROVE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',130,130,'{$SalesOrder.SalesOrder}是否自动创建{$ServiceContracts.ServiceContracts}（服务期限为1年，金额为0元）'
from dual where not exists (select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=130);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',130,130,'Whether to create {$ServiceContracts.ServiceContracts} immediately after creating {$SalesOrder.SalesOrder}(service period of 1 years, the amount of 0) '
from dual where not exists (select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=130);
delimiter;

alter table ld_systems_deploy modify deploy_type int(11);
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=56;
update ld_systems_deploy set sequence=sequence+1 where roottype=1 and sequence>=@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,130,'合同订单是否自动创建服务合同（服务期限为1年，金额为0元）',@sequence,1,'select',0,
'[{"value":"0","text":"NOTCREATE"},{"value":"1","text":"CREATEAFTERSAVE"},{"value":"2","text":"CREATEAFTERAPPROVE"},{"sql":""},{"relatedmodule":"SalesOrder,PaymentPlan"}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=130);
delimiter;

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=1 order by sequence;
delimiter;

call AddColumn('ld_related_field','trigger_fieldid','int','11',0);
delimiter;
call AddColumn('ld_related_field','effect_fieldid','int','11',0);
delimiter;
call AddColumn('ld_related_field','fieldtype','varchar','25',null);
delimiter;
call AddColumn('ld_related_field','curmodule_columninfo','text','','');
delimiter;
call AddColumn('ld_related_field','fromvalue_type','varchar','25',null);
delimiter;
call AddColumn('ld_related_field','fromvalue_info','text','','');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @vendorid_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@vendorid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','SELECT {hrefcolumn},ld_vendorcontacts.vendorcontactsid FROM ld_vendorcontacts LEFT JOIN ld_vendorcontactscf on ld_vendorcontacts.vendorcontactsid = ld_vendorcontactscf.vendorcontactsid WHERE vendorid = ? ORDER BY modifiedtime DESC LIMIT 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @vendorid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@vendorid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @vendorid_fieldid and effect_fieldid = @smownerid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@vendorid_fieldid,'vendor_id,vendors_name','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @vendorid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select fieldid into @vendorid_fieldid from ld_field where tabid = @tabid and columnname = 'vendor_id';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@vendorid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','SELECT {hrefcolumn},ld_vendorcontacts.vendorcontactsid FROM ld_vendorcontacts LEFT JOIN ld_vendorcontactscf on ld_vendorcontacts.vendorcontactsid = ld_vendorcontactscf.vendorcontactsid WHERE vendorid = ? ORDER BY modifiedtime DESC LIMIT 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @vendorid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@vendorid_fieldid,'vendor_id,vendors_name','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @vendorid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
select fieldid into @vendorid_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@vendorid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @vendorid_fieldid and effect_fieldid = @smownerid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @smownerid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
select fieldid into @vendorid_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@vendorid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','SELECT {hrefcolumn},ld_vendorcontacts.vendorcontactsid FROM ld_vendorcontacts LEFT JOIN ld_vendorcontactscf on ld_vendorcontacts.vendorcontactsid = ld_vendorcontactscf.vendorcontactsid WHERE vendorid = ? ORDER BY modifiedtime DESC LIMIT 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @vendorid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@vendorid_fieldid,'vendor_id,vendors_name','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @vendorid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @projecttaskid_fieldid from ld_field where tabid = @tabid and columnname = 'projecttaskid';
select fieldid into @projectid_fieldid from ld_field where tabid = @tabid and columnname = 'projectid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projecttaskid_fieldid,@projectid_fieldid,'projectid,projectid_display','column','projectid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projecttaskid_fieldid and effect_fieldid = @projectid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projecttaskid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projecttaskid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projecttaskid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projecttaskid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @salesorderid_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @projectid_fieldid from ld_field where tabid = @tabid and columnname = 'projectid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projectid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projectid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projectid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projectid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @smownerid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@smownerid_fieldid,'','sql','select ld_account.smownerid from ld_potential LEFT JOIN ld_account on ld_account.accountid = ld_potential.accountid and ld_account.deleted = 0 where ld_potential.potentialid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @smownerid_fieldid);
select fieldid into @salesorderid_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@smownerid_fieldid,'','sql','select ld_account.smownerid from ld_salesorder LEFT JOIN ld_account on ld_account.accountid = ld_salesorder.accountid and ld_account.deleted = 0 where ld_salesorder.salesorderid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @smownerid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select fieldid into @accountid_fieldid from ld_field where tabid = 16 and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = 16 and columnname = 'contactid';
select fieldid into @smownerid_fieldid from ld_field where tabid = 16 and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @smownerid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @salesorderid_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @servicecontractsid_fieldid from ld_field where tabid = @tabid and columnname = 'servicecontractsid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@servicecontractsid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @servicecontractsid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@servicecontractsid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @servicecontractsid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @smownerid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@smownerid_fieldid,'assigned_user_id','sql','select ld_account.smownerid from ld_potential LEFT JOIN ld_account on ld_account.accountid = ld_potential.accountid and ld_account.deleted = 0 where ld_potential.potentialid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @smownerid_fieldid);
select fieldid into @quoteid_fieldid from ld_field where tabid = @tabid and columnname = 'quoteid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@quoteid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @quoteid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@quoteid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @quoteid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@quoteid_fieldid,@smownerid_fieldid,'assigned_user_id','sql','select ld_account.smownerid from ld_quotes LEFT JOIN ld_account on ld_account.accountid = ld_quotes.accountid and ld_account.deleted = 0 where quoteid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @quoteid_fieldid and effect_fieldid = @smownerid_fieldid);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select fieldid into @projecttaskid_fieldid from ld_field where tabid = @tabid and columnname = 'projecttaskid';
select fieldid into @projectid_fieldid from ld_field where tabid = @tabid and columnname = 'projectid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projecttaskid_fieldid,@projectid_fieldid,'projectid,projectid_display','column','projectid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projecttaskid_fieldid and effect_fieldid = @projectid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
select fieldid into @projecttaskid_fieldid from ld_field where tabid = @tabid and columnname = 'projecttaskid';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projecttaskid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projecttaskid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projecttaskid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projecttaskid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @troubleticketid_fieldid from ld_field where tabid = @tabid and columnname = 'troubleticketid';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@troubleticketid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @troubleticketid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@troubleticketid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @troubleticketid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @smownerid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid);
select fieldid into @salesorderid_fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@salesorderid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @salesorderid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
select fieldid into @projectid_fieldid from ld_field where tabid = @tabid and columnname = 'projectid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projectid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projectid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@projectid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @projectid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'parentid';
select fieldid into @mailingcountry_fieldid from ld_field where tabid = @tabid and columnname = 'mailingcountry';
select fieldid into @mailingstate_fieldid from ld_field where tabid = @tabid and columnname = 'mailingstate';
select fieldid into @mailingcity_fieldid from ld_field where tabid = @tabid and columnname = 'mailingcity';
select fieldid into @mailingzip_fieldid from ld_field where tabid = @tabid and columnname = 'mailingzip';
select fieldid into @mailingstreet_fieldid from ld_field where tabid = @tabid and columnname = 'mailingstreet';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@accountid_fieldid,'account_id,accounts_name','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@contactid_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @contactid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@mailingcountry_fieldid,'','column','bill_country' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @mailingcountry_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@mailingstate_fieldid,'','column','bill_state' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @mailingstate_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@mailingcity_fieldid,'','column','bill_city' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @mailingcity_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@mailingzip_fieldid,'','column','bill_code' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @mailingzip_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@accountid_fieldid,@mailingstreet_fieldid,'','column','bill_street' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @accountid_fieldid and effect_fieldid = @mailingstreet_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select fieldid into @vendorid_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@contactid_fieldid,@vendorid_fieldid,'vendorid,vendors_name','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @contactid_fieldid and effect_fieldid = @vendorid_fieldid);
select fieldid into @smownerid_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@vendorid_fieldid,@smownerid_fieldid,'assigned_user_id','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @vendorid_fieldid and effect_fieldid = @smownerid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
select fieldid into @potentialid_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@potentialid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @accountid_fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='cashbill';
update ld_tabdetailfield set edit_permission=0,newline=0  where tabid=@tabid and columnname='amount';
delimiter;
select tabid into @tabid from ld_tab where name='sendcashbill';
update ld_tabdetailfield set edit_permission=0,newline=0  where tabid=@tabid and columnname='amount';
delimiter;
-- 2017-05-15

delete from ld_related_field where fieldid>0;

update ld_desk set fieldlabel='新增保存时创建' where labelbol='CREATEAFTERSAVE' and languagetype='zh';
update ld_desk set fieldlabel='Create after new additions' where labelbol='CREATEAFTERSAVE' and languagetype='en';
update ld_desk set fieldlabel='审批通过时创建' where labelbol='CREATEAFTERAPPROVE' and languagetype='zh';
update ld_desk set fieldlabel='Create after approved' where labelbol='CREATEAFTERAPPROVE' and languagetype='en';

delete from ld_profile2field where fieldid not in (select fieldid from ld_field);
update ld_profile2field a
LEFT JOIN ld_field b ON a.fieldid=b.fieldid
SET a.tabid=b.tabid
WHERE IFNULL(a.tabid,0)<>IFNULL(b.tabid,0)
	AND b.fieldid>0;
    
update ld_related_field set fromvalue_info = 'select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by reference desc,ld_contactdetails.contactid desc limit 1'
where fromvalue_info = 'select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by ld_contactdetails.contactid,reference desc limit 1';
delimiter;

CREATE TABLE if not exists `ld_normalapprove` (
  `normalapproveid` int(19) NOT NULL DEFAULT '0',
  `smownerid` int(19) DEFAULT NULL,
  `normalapprove_no` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `currentapprover` varchar(1000) DEFAULT NULL,
  `description` text,
`deleted` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`normalapproveid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_normalapprovescf` (
  `normalapproveid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`normalapproveid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(parenttabid) into @parenttabid from ld_parenttab;
insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible)
select @parenttabid+1,'OAForms',10,0 from dual where not exists(select 1 from ld_parenttab where parenttab_label='OAForms');

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_parenttab',@parenttabid,@parenttabid,'OA表单' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@parenttabid and relateid=@parenttabid and languagetype='zh' and trantable='ld_parenttab');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_parenttab',@parenttabid,@parenttabid,'OA Form' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@parenttabid and relateid=@parenttabid and languagetype='en' and trantable='ld_parenttab');
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'NormalApprove',0,80,'NormalApprove',1 from dual 
where not EXISTS(select 1 from ld_tab where name='NormalApprove');

select tabid into @tabid from ld_tab  where name='NormalApprove';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'普通审批' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'普通审批' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
select tabid into @tabid from ld_tab  where name='NormalApprove';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,1 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
update ld_modentity_num_seq set id=@maxnum_id+1 where not EXISTS(select 1 from ld_modentity_num where semodule='normalApprove');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'NormalApprove','PTSP',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='normalApprove');
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','Save','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'NormalApprove','ld_normalapprove','normalapprove_no','normalapproveid','normalapproveid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='NormalApprove');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_NORMALAPPROVE_BASICINFORMATION' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_NORMALAPPROVE_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_NORMALAPPROVE_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_NORMALAPPROVE_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_NORMALAPPROVE_CONTENT' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_NORMALAPPROVE_CONTENT',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_NORMALAPPROVE_CONTENT' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_NORMALAPPROVE_CONTENT' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'审批内容' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Approve Content' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_NORMALAPPROVE_FILE' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_NORMALAPPROVE_FILE',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_NORMALAPPROVE_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_NORMALAPPROVE_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_NORMALAPPROVE_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smownerid','ld_normalapprove',1,53,'assigned_user_id','申请人',1,0,1,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='normalapprove_no');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'normalapprove_no','ld_normalapprove',1,4,'normalapprove_no','审批编号',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='normalapprove_no');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_normalapprove',1,70,'createdtime','创建时间',1,0,3,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_normalapprove',1,52,'smcreatorid','创建人',1,0,4,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_normalapprove',1,70,'modifiedtime','修改时间',1,0,5,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_normalapprove',1,52,'modifiedby','最新更新人',1,0,6,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approvestatus','ld_normalapprove',1,609,'approvestatus','审批状态',1,0,7,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'currentapprover','ld_normalapprove',1,132,'currentapprover','当前审批人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_normalapprove',1,131,'approveby','上一步审批审批人',1,0,9,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_NORMALAPPROVE_CONTENT';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='description');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'description','ld_normalapprove',1,19,'description','审批事由',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='description');
delimiter;

select tabid into @tabid from ld_tab where name='NormalApprove';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_NORMALAPPROVE_FILE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;

call getallprofile('NormalApprove');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='normalapprove_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'审批事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='NormalApprove';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='NormalApprove' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'NormalApprove',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='NormalApprove' and viewname='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype='NormalApprove' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:smownerid%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:normalapprove_no%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:createdtime%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_normalapprove:smcreatorid:smcreatorid:NormalApprove_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:smcreatorid%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_normalapprove:modifiedtime:modifiedtime:NormalApprove_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:modifiedtime%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_normalapprove:modifiedby:modifiedby:NormalApprove_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:modifiedby%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:approvestatus%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:currentapprover%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,8,'ld_normalapprove:approveby:approveby:NormalApprove_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_normalapprove:approveby%');
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;


call addtabintoprofile('normalapprove',1);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,125,'普通审批是否启用审批流程','NormalApprove',30,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=125) ;
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
 insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

select max(cvid)into @maxcvid  from ld_customview  ;
update ld_customview_seq set id=@maxcvid+1;
delimiter;


CREATE TABLE if not exists `ld_addjobbill` (
  `addjobbillid` int(19) NOT NULL DEFAULT '0',
  `smownerid` int(19) DEFAULT NULL,
  `addjobbill_no` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `currentapprover` varchar(1000) DEFAULT NULL,
`total` decimal(25,6) DEFAULT NULL,
  `description` text,
`deleted` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`addjobbillid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_addjobbillscf` (
  `addjobbillid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`addjobbillid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_addjobbilldetail` (
  `id` int(19) DEFAULT '0',
  `lineitem_id` int(19) NOT NULL AUTO_INCREMENT,
  `sequence` int(11) DEFAULT NULL,
  `starttime` datetime DEFAULT NULL,
  `endtime` datetime DEFAULT NULL,
  `costtime` decimal(20,1) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_addjobbilldetailscf` (
  `lineitem_id` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'AddJobBill',0,80,'AddJobBill',1 from dual 
where not EXISTS(select 1 from ld_tab where name='AddJobBill');

select tabid into @tabid from ld_tab  where name='AddJobBill';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'加班单' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'OverTime Bill' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
select tabid into @tabid from ld_tab  where name='AddJobBill';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,2 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
update ld_modentity_num_seq set id=@maxnum_id+1 where not EXISTS(select 1 from ld_modentity_num where semodule='AddJobBill');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'AddJobBill','JB',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='AddJobBill');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','Save','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'AddJobBill','ld_addjobbill','addjobbill_no','addjobbillid','addjobbillid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='AddJobBill');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_ADDJOBBILL_BASICINFORMATION' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_ADDJOBBILL_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_ADDJOBBILL_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_ADDJOBBILL_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_ADDJOBBILL_FILE' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_ADDJOBBILL_FILE',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_ADDJOBBILL_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_ADDJOBBILL_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ADDJOBBILL_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smownerid','ld_addjobbill',1,53,'assigned_user_id','申请人',1,0,1,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'total','ld_addjobbill',1,72,'hdnGrandTotal','合计',1,0,2,@blockid ,3,'N~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='addjobbill_no');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'addjobbill_no','ld_addjobbill',1,4,'addjobbill_no','单据编号',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='addjobbill_no');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_addjobbill',1,70,'createdtime','创建时间',1,0,3,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_addjobbill',1,52,'smcreatorid','创建人',1,0,4,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_addjobbill',1,70,'modifiedtime','修改时间',1,0,5,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_addjobbill',1,52,'modifiedby','最新更新人',1,0,6,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approvestatus','ld_addjobbill',1,609,'approvestatus','审批状态',1,0,7,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_addjobbill',1,131,'approveby','当前审批人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'currentapprover','ld_addjobbill',1,132,'currentapprover','上一步审批人',1,0,9,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;


select tabid into @tabid from ld_tab where name='AddJobBill';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ADDJOBBILL_FILE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;
call getallprofile('AddJobBill');



select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='addjobbill_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;
select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'合计' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Total' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='AddJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='AddJobBill' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'AddJobBill',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='AddJobBill' and viewname='All');
delimiter;
select tabid into @tabid from ld_tab where name='addjobbill';
select cvid into @cvid from ld_customview where entitytype='AddJobBill' and viewname='All';

insert into ld_tabwithproductview(tabid,cvid,sequence,columns)
select @tabid,@cvid,0,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbill:addjobbill_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbill:smownerid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbill:total%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbill:approvestatus%');
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbill:currentapprover%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_addjobbilldetail:starttime:starttime:addjobbilldetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbilldetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_addjobbilldetail:endtime:endtime:addjobbilldetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbilldetail:endtime%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_addjobbilldetail:costtime:costtime:addjobbilldetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbilldetail:costtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_addjobbilldetail:description:description:addjobbilldetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_addjobbilldetail:description%');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;



call addtabintoprofile('AddJobBill',1);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,126,'加班单是否启用审批流程','AddJobBill',31,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=126) ;
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
 insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;
select tabid into @tabid  from ld_tab where name='addjobbill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-11,4,0,'查看申请人的加班历史' from dual 
where not EXISTS (select 1 from ld_quickactions where tabid=@tabid and related_tabid=-11);
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWADDJOBBILLHISTORY','查看加班历史','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='VIEWADDJOBBILLHISTORY' and LANGUAGEtype='zh' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWADDJOBBILLHISTORY','查看加班历史','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='VIEWADDJOBBILLHISTORY' and LANGUAGEtype='en' and labeltype='fixedstr');
delimiter;
select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'starttime','yes','ld_addjobbilldetail','起始时间','',0,'Date_YmdHms','DT~M',1,40,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='starttime');
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'endtime','yes','ld_addjobbilldetail','截止时间','',0,'Date_YmdHms','DT~M',2,40,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='endtime');
delimiter;
select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'costtime','yes','ld_addjobbilldetail','时长','',0,'Num','N~M~25,1',3,30,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='costtime');
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'description','yes','ld_addjobbilldetail','原因','',0,'TextArea','V~O~200',4,190,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='description');
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'total','yes','ld_addjobbill','合计','',0,'Span','N~O',4,20,0,0,0,1,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='total');
delimiter;


select tabid into @tabid from ld_tab where name='addjobbill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='starttime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'起始时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Start Time' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='endtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'截止时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'End Time' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='addjobbill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='costtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'时长(h)' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'costtime' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;
select tabid into @tabid from ld_tab where name='addjobbill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid ,'合计' from dual 
where not EXISTS(Select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_tabdetailfield' and relateid=@relateid and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid ,'Total' from dual 
where not EXISTS(Select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_tabdetailfield' and relateid=@relateid and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'原因' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Reason' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;
insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDJOBBILLDETAIL','{$AddJobBill.AddJobBill}明细' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ADDJOBBILLDETAIL' and Labeltype='fixedstr');

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDJOBBILLDETAIL','{$AddJobBill.AddJobBill} detail' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ADDJOBBILLDETAIL' and Labeltype='fixedstr');
delimiter;

select max(cvid)into @maxcvid  from ld_customview  ;
update ld_customview_seq set id=@maxcvid+1;
delimiter;

select tabid into @tabid  from ld_tab where name='addjobbill';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'costtime'}]}" ,2 from dual 
where not EXISTS(select 1 from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid);
delimiter;

CREATE TABLE if not exists `ld_minusjobbill` (
  `minusjobbillid` int(19) NOT NULL DEFAULT '0',
  `smownerid` int(19) DEFAULT NULL,
  `minusjobbill_no` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `currentapprover` varchar(1000) DEFAULT NULL,
  `description` text,
`total` decimal(25,6) DEFAULT NULL,
`deleted` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`minusjobbillid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_minusjobbillscf` (
  `minusjobbillid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`minusjobbillid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_minusjobbilldetail` (
  `id` int(19) DEFAULT '0',
   `minusjobtype` varchar(255) DEFAULT null,
  `lineitem_id` int(19) NOT NULL AUTO_INCREMENT,
  `sequence` int(11) DEFAULT NULL,
  `starttime` datetime DEFAULT NULL,
  `endtime` datetime DEFAULT NULL,
  `costtime` decimal(20,1) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_minusjobbilldetailscf` (
  `lineitem_id` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'MinusJobBill',0,80,'MinusJobBill',1 from dual 
where not EXISTS(select 1 from ld_tab where name='MinusJobBill');

select tabid into @tabid from ld_tab  where name='MinusJobBill';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'请假单' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Leave Application' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
select tabid into @tabid from ld_tab  where name='MinusJobBill';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,3 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
update ld_modentity_num_seq set id=@maxnum_id+1 where not EXISTS(select 1 from ld_modentity_num where semodule='MinusJobBill');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'MinusJobBill','QJ',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='MinusJobBill');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','Save','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'MinusJobBill','ld_minusjobbill','minusjobbill_no','minusjobbillid','minusjobbillid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='MinusJobBill');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_MINUSJOBBILL_BASICINFORMATION' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_MINUSJOBBILL_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_MINUSJOBBILL_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_MINUSJOBBILL_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_MINUSJOBBILL_FILE' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_MINUSJOBBILL_FILE',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_MINUSJOBBILL_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_MINUSJOBBILL_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_MINUSJOBBILL_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smownerid','ld_minusjobbill',1,53,'assigned_user_id','申请人',1,0,1,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'total','ld_minusjobbill',1,72,'hdnGrandTotal','合计',1,0,2,@blockid ,3,'N~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='minusjobbill_no');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'minusjobbill_no','ld_minusjobbill',1,4,'minusjobbill_no','单据编号',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='minusjobbill_no');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_minusjobbill',1,70,'createdtime','创建时间',1,0,3,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_minusjobbill',1,52,'smcreatorid','创建人',1,0,4,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_minusjobbill',1,70,'modifiedtime','修改时间',1,0,5,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_minusjobbill',1,52,'modifiedby','最新更新人',1,0,6,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approvestatus','ld_minusjobbill',1,609,'approvestatus','审批状态',1,0,7,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_minusjobbill',1,131,'approveby','当前审批人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'currentapprover','ld_minusjobbill',1,132,'currentapprover','上一步审批人',1,0,9,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_MINUSJOBBILL_FILE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;

call getallprofile('MinusJobBill');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='minusjobbill_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'合计' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Total' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='MinusJobBill';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='MinusJobBill' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'MinusJobBill',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='MinusJobBill' and viewname='All');
delimiter;

select tabid into @tabid from ld_tab where name='minusjobbill';
select cvid into @cvid from ld_customview where entitytype='minusJobBill' and viewname='All';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbill:minusjobbill_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbill:smownerid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbill:total%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbill:approvestatus%');
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid, @cvid,4,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbill:currentapprover%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_minusjobbilldetail:minusjobtype:minusjobtype:minusjobbilldetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbilldetail:minusjobtype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_minusjobbilldetail:starttime:starttime:minusjobbilldetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbilldetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_minusjobbilldetail:endtime:endtime:minusjobbilldetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbilldetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_minusjobbilldetail:costtime:costtime:minusjobbilldetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbilldetail:costtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_minusjobbilldetail:description:description:minusjobbilldetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_minusjobbilldetail:description%');
delimiter;


call addtabintoprofile('MinusJobBill',1);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,127,'请假单是否启用审批流程','MinusJobBill',32,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=127) ;
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
 insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'minusjobtype','yes','ld_minusjobbilldetail','假别','',0,'Select','V~M',1,25,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='minusjobtype');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'starttime','yes','ld_minusjobbilldetail','起始时间','',0,'Date_YmdHms','DT~M',2,40,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='starttime');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'endtime','yes','ld_minusjobbilldetail','截止时间','',0,'Date_YmdHms','DT~M',3,40,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='endtime');
delimiter;
select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'costtime','yes','ld_minusjobbilldetail','时长','',0,'Num','N~M~25,1',4,30,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='costtime');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'description','yes','ld_minusjobbilldetail','原因','',0,'TextArea','V~O',5,160,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='description');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'total','yes','ld_minusjobbill','合计','',0,'Span','N~O',4,20,0,0,0,1,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='total');
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='minusjobtype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'假别' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'假别' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='starttime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'起始时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Start Time' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='endtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'截止时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'End Time' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='costtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'时长(h)' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'costtime' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'原因' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Reason' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='MinusJobBill';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid ,'合计' from dual 
where not EXISTS(Select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_tabdetailfield' and relateid=@relateid and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid ,'Total' from dual 
where not EXISTS(Select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_tabdetailfield' and relateid=@relateid and languagetype='en');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MINUSJOBBILLDETAIL','{$MinusJobBill.MinusJobBill}明细' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MINUSJOBBILLDETAIL' and Labeltype='fixedstr');

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MINUSJOBBILLDETAIL','{$MinusJobBill.MinusJobBill} detail' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MINUSJOBBILLDETAIL' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='minusJobBill';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;

select max(cvid)into @maxcvid  from ld_customview  ;
update ld_customview_seq set id=@maxcvid+1;
delimiter;

CREATE TABLE if not exists `ld_minusjobtype` (
  `minusjobtypeid` int(11) NOT NULL DEFAULT '0',
  `minusjobtype` varchar(255) DEFAULT NULL,
  `presence` int(11) DEFAULT NULL,
  `Picklist_valueid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid) select  '1', '调休', '1', '1281' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='调休');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '2', '年假', '1', '1283' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='年假');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '3', '事假', '1', '1284' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='事假');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '4', '婚假', '1', '1285' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='婚假');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '5', '病假', '1', '1286' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='病假');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '6', '产假', '1', '1287' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='产假');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '7', '丧假', '1', '1288' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='丧假');
INSERT INTO `ld_minusjobtype`(minusjobtypeid,minusjobtype,presence,Picklist_valueid)  select  '8', '特殊报钟', '1', '1289' from dual where not EXISTS(select 1 from ld_minusjobtype where minusjobtype='特殊报钟');
delimiter;

select tabid into @tabid  from ld_tab where name='minusjobbill';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'costtime'}]}" ,2 from dual 
where not EXISTS(select 1 from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid);
delimiter;

CREATE TABLE if not exists `ld_businessapply` (
  `businessapplyid` int(19) NOT NULL DEFAULT '0',
 `accountid` int(19) DEFAULT 0,
 `contactid` int(19) DEFAULT 0,
  `budget` decimal(25,8)  default 0,
 `preparemoney` decimal(25,8) default 0,
  `peer_persons` text default null,
 `businessreason` text default null,
  `smownerid` int(19) DEFAULT NULL,
  `businessapply_no` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `currentapprover` varchar(1000) DEFAULT NULL,
  `description` text,
`total` decimal(25,6) DEFAULT NULL,
`deleted` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`businessapplyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_businessapplyscf` (
  `businessapplyid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`businessapplyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_businessapplydetail` (
  `id` int(19) DEFAULT '0',
   `source` varchar(500) DEFAULT null,
	`destination` varchar(500) DEFAULT NULL,
  `lineitem_id` int(19) NOT NULL AUTO_INCREMENT,
  `sequence` int(11) DEFAULT NULL,
`starttime` datetime DEFAULT NULL,
  `endtime` datetime DEFAULT NULL,
  `traffictype` varchar(255) DEFAULT NULL,
   `days` decimal(20,2) default 0,
  `description` text,
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_businessapplydetailscf` (
  `lineitem_id` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'BusinessApply',0,80,'BusinessApply',1 from dual 
where not EXISTS(select 1 from ld_tab where name='BusinessApply');

select tabid into @tabid from ld_tab  where name='BusinessApply';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'出差申请单' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Business application' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
select tabid into @tabid from ld_tab  where name='BusinessApply';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,4 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
update ld_modentity_num_seq set id=@maxnum_id+1 where not EXISTS(select 1 from ld_modentity_num where semodule='BusinessApply');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'BusinessApply','CC',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='BusinessApply');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','Save','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'BusinessApply','ld_businessapply','businessapply_no','businessapplyid','businessapplyid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='BusinessApply');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_BASICINFORMATION' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_BUSINESSAPPLY_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_REASON' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_BUSINESSAPPLY_REASON',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_REASON' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_REASON' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'出差事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'出差事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_FILE' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_BUSINESSAPPLY_FILE',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_BUSINESSAPPLY_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_BUSINESSAPPLY_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smownerid','ld_businessapply',1,53,'assigned_user_id','申请人',1,0,1,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='businessapply_no');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'businessapply_no','ld_businessapply',1,4,'businessapply_no','单据编号',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='businessapply_no');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='accountid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'accountid','ld_businessapply',1,73,'account_id','客户名称',1,0,3,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='accountid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contactid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'contactid','ld_businessapply',1,57,'contact_id','联系人姓名',1,0,4,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contactid');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'total','ld_businessapply',1,72,'hdnGrandTotal','合计',1,0,2,@blockid ,3,'N~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_businessapply',1,70,'createdtime','创建时间',1,0,5,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_businessapply',1,52,'smcreatorid','创建人',1,0,6,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_businessapply',1,70,'modifiedtime','修改时间',1,0,7,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_businessapply',1,52,'modifiedby','最新更新人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approvestatus','ld_businessapply',1,609,'approvestatus','审批状态',1,0,9,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_businessapply',1,131,'approveby','当前审批人',1,0,10,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'currentapprover','ld_businessapply',1,132,'currentapprover','上一步审批人',1,0,12,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;


select tabid into @tabid from ld_tab where name='BusinessApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_BUSINESSAPPLY_REASON';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='businessreason');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'businessreason','ld_businessapply',1,21,'businessreason','出差事由',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='businessreason');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='peer_persons');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'peer_persons','ld_businessapply',1,154,'peer_persons','同行人',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='peer_persons');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='budget');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'budget','ld_businessapply',1,7,'budget','预算',1,0,3,@blockid ,1,'N~O~25,2',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='budget');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='preparemoney');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'preparemoney','ld_businessapply',1,7,'preparemoney','预支',1,0,4,@blockid ,1,'N~O~25,2',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='preparemoney');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_BUSINESSAPPLY_FILE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;
call getallprofile('BusinessApply');



select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='businessapply_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='accountid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'客户名称' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Customer Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contactid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'联系人姓名' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Contact Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'合计' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Total' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='businessreason';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'出差事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'出差事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='peer_persons';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'同行人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'同行人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='budget';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'预算(元)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'预算(元)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='preparemoney';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'预支(元)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'预支(元)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='BusinessApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'BusinessApply',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='All');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
select cvid into @cvid from ld_customview where entitytype='BusinessApply' and viewname='All';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:businessapply_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:smownerid%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:accountid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:approvestatus%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_businessapplydetail:source:source:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:source%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_businessapplydetail:destination:destination:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:destination%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_businessapplydetail:starttime:starttime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_businessapplydetail:endtime:endtime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_businessapplydetail:traffictype:traffictype:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:traffictype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,10,'ld_businessapplydetail:days:days:businessapplydetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:days%');
delimiter;


select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='已批准');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'已批准',0,0,'BusinessApply',3,1,2 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='已批准');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
select cvid into @cvid from ld_customview where entitytype='BusinessApply' and viewname='已批准';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:businessapply_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:smownerid%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:accountid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:approvestatus%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_businessapplydetail:source:source:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:source%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_businessapplydetail:destination:destination:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:destination%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_businessapplydetail:starttime:starttime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_businessapplydetail:endtime:endtime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_businessapplydetail:traffictype:traffictype:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:traffictype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,10,'ld_businessapplydetail:days:days:businessapplydetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:days%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V','c','已批准',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );

insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='审批中');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'审批中',0,0,'BusinessApply',3,1,3 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='审批中');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select cvid into @cvid from ld_customview where entitytype='BusinessApply' and viewname='审批中';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:businessapply_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:smownerid%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:accountid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:approvestatus%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_businessapplydetail:source:source:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:source%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_businessapplydetail:destination:destination:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:destination%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_businessapplydetail:starttime:starttime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_businessapplydetail:endtime:endtime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_businessapplydetail:traffictype:traffictype:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:traffictype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,10,'ld_businessapplydetail:days:days:businessapplydetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:days%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V','c','审批中',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );

insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='已驳回');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'已驳回',0,0,'BusinessApply',3,1,4 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='已驳回');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
select cvid into @cvid from ld_customview where entitytype='BusinessApply' and viewname='已驳回';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:businessapply_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:smownerid%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:accountid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:approvestatus%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_businessapplydetail:source:source:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:source%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_businessapplydetail:destination:destination:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:destination%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_businessapplydetail:starttime:starttime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_businessapplydetail:endtime:endtime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_businessapplydetail:traffictype:traffictype:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:traffictype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,10,'ld_businessapplydetail:days:days:businessapplydetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:days%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V','c','已驳回',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );

insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='未提交');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'未提交',0,0,'BusinessApply',3,1,4 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='未提交');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select cvid into @cvid from ld_customview where entitytype='BusinessApply' and viewname='未提交';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:businessapply_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:smownerid%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:accountid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:approvestatus%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_businessapplydetail:source:source:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:source%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_businessapplydetail:destination:destination:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:destination%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_businessapplydetail:starttime:starttime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_businessapplydetail:endtime:endtime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_businessapplydetail:traffictype:traffictype:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:traffictype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,10,'ld_businessapplydetail:days:days:businessapplydetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:days%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V','c','未提交',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );

insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='已拒绝');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'已拒绝',0,0,'BusinessApply',3,1,5 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='BusinessApply' and viewname='已拒绝');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
select cvid into @cvid from ld_customview where entitytype='BusinessApply' and viewname='已拒绝';
insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,1,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 0 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:businessapply_no%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,2,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:smownerid%');


insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,3,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:accountid%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,4,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where  tabid=@tabid and cvid=@cvid and columns like '%ld_businessapply:approvestatus%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,5,'ld_businessapplydetail:source:source:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:source%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,6,'ld_businessapplydetail:destination:destination:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:destination%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,7,'ld_businessapplydetail:starttime:starttime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:starttime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,8,'ld_businessapplydetail:endtime:endtime:businessapplydetail_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:endtime%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,9,'ld_businessapplydetail:traffictype:traffictype:businessapplydetail_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:traffictype%');

insert into ld_tabwithproductview(tabid,cvid , sequence,columns)
select @tabid,@cvid,10,'ld_businessapplydetail:days:days:businessapplydetail_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_tabwithproductview where tabid=@tabid and cvid=@cvid and columns like '%ld_businessapplydetail:days%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V','c','已拒绝',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );

insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

call addtabintoprofile('BusinessApply',1);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,128,'出差申请是否启用审批流程','BusinessApply',32,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=128) ;
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
 insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'source','yes','ld_businessapplydetail','出发地','',0,'Text','V~M',1,25,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='source');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'destination','yes','ld_businessapplydetail','目的地','',0,'Text','V~M',2,25,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='destination');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'starttime','yes','ld_businessapplydetail','出发时间','',0,'Date_YmdHms','DT~M',3,40,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='starttime');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'endtime','yes','ld_businessapplydetail','到达时间','',0,'Date_YmdHms','DT~M',4,40,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='endtime');
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'traffictype','yes','ld_businessapplydetail','交通工具','',0,'Select','V~O',5,30,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='traffictype');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'days','yes','ld_businessapplydetail','天数','',0,'Num','N~O~20,2',6,30,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='days');
delimiter;


select tabid into @tabid from ld_tab where name='description';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'description','yes','ld_businessapplydetail','备注','',0,'TextArea','V~O',7,160,0,0,0,0,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='description');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'total','yes','ld_businessapply','合计','',0,'Span','N~O',4,20,0,0,0,1,2 from dual 
where not exists(select 1 from ld_tabdetailfield where tabid=@tabid and columnname='total');

delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='source';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'出发地' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'出发地' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='destination';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'目的地' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'目的地' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='starttime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'出发时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'出发时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='endtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'到达时间' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'End Time' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='traffictype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'交通工具' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Traffic' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='Days';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'天数' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Days' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid,'备注' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid,'Remark' from dual 
where not exists(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_tabdetailfield' and tabid=@tabid and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select tabdetailfieldid into @relateid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@relateid ,'合计' from dual 
where not EXISTS(Select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_tabdetailfield' and relateid=@relateid and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@relateid ,'Total' from dual 
where not EXISTS(Select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_tabdetailfield' and relateid=@relateid and languagetype='en');
delimiter;

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUSINESSAPPLYDETAIL','{$BusinessApply.BusinessApply}明细' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BusinessApply' and Labeltype='fixedstr');

insert into  ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUSINESSAPPLYDETAIL','{$BusinessApply.BusinessApply} detail' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BusinessApply' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;

select max(cvid)into @maxcvid  from ld_customview  ;
update ld_customview_seq set id=@maxcvid+1;
delimiter;

CREATE TABLE if not exists `ld_traffictype` (
  `traffictypeid` int(11) NOT NULL DEFAULT '0',
  `traffictype` varchar(255) DEFAULT NULL,
  `presence` int(11) DEFAULT NULL,
  `Picklist_valueid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO `ld_traffictype`(traffictypeid,traffictype,presence,Picklist_valueid) select  '1', '火车', '1', '1281' from dual where not EXISTS(select 1 from ld_traffictype where traffictype='火车');
INSERT INTO `ld_traffictype`(traffictypeid,traffictype,presence,Picklist_valueid)  select  '2', '飞机', '1', '1283' from dual where not EXISTS(select 1 from ld_traffictype where traffictype='飞机');
INSERT INTO `ld_traffictype`(traffictypeid,traffictype,presence,Picklist_valueid)  select  '3', '汽车', '1', '1284' from dual where not EXISTS(select 1 from ld_traffictype where traffictype='汽车');
INSERT INTO `ld_traffictype`(traffictypeid,traffictype,presence,Picklist_valueid)  select  '4', '轮船', '1', '1285' from dual where not EXISTS(select 1 from ld_traffictype where traffictype='轮船');
INSERT INTO `ld_traffictype`(traffictypeid,traffictype,presence,Picklist_valueid)  select  '5', '其他', '1', '1286' from dual where not EXISTS(select 1 from ld_traffictype where traffictype='其他');
delimiter;

CREATE TABLE if not exists `ld_loanapply` (
  `loanapplyid` int(19) NOT NULL DEFAULT '0',
  `smownerid` int(19) DEFAULT NULL,
  `loanapply_no` varchar(255) DEFAULT NULL,
  `loanmoney` decimal(25,8) default 0,
	`paymentdate` date default null,
	`loanreason` text default null,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `currentapprover` varchar(1000) DEFAULT NULL,
`deleted` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`loanapplyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_loanapplyscf` (
  `loanapplyid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`loanapplyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'LoanApply',0,80,'LoanApply',1 from dual 
where not EXISTS(select 1 from ld_tab where name='LoanApply');

select tabid into @tabid from ld_tab  where name='LoanApply';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'借款申请' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Loan Application' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
select tabid into @tabid from ld_tab  where name='LoanApply';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,5 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
update ld_modentity_num_seq set id=@maxnum_id+1 where not EXISTS(select 1 from ld_modentity_num where semodule='LoanApply');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'LoanApply','JK',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='LoanApply');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','Save','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'LoanApply','ld_loanapply','loanapply_no','loanapplyid','loanapplyid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='LoanApply');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_LOANAPPLY_BASICINFORMATION' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_LOANAPPLY_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_LOANAPPLY_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_LOANAPPLY_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_LOANAPPLY_LOANINFO' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_LOANAPPLY_LOANINFO',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_LOANAPPLY_LOANINFO' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_LOANAPPLY_LOANINFO' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'借款信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'借款信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_LOANAPPLY_FILE' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_LOANAPPLY_FILE',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_LOANAPPLY_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_LOANAPPLY_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LOANAPPLY_BASICINFORMATION';

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smownerid','ld_loanapply',1,53,'assigned_user_id','申请人',1,0,1,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='loanapply_no');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'loanapply_no','ld_loanapply',1,4,'loanapply_no','单据编号',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='loanapply_no');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_loanapply',1,70,'createdtime','创建时间',1,0,3,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_loanapply',1,52,'smcreatorid','创建人',1,0,4,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_loanapply',1,70,'modifiedtime','修改时间',1,0,5,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_loanapply',1,52,'modifiedby','最新更新人',1,0,6,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approvestatus','ld_loanapply',1,609,'approvestatus','审批状态',1,0,7,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_loanapply',1,131,'approveby','当前审批人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');


select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_loanapply',1,131,'approveby','上一步审批人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'currentapprover','ld_loanapply',1,132,'currentapprover','当前审批人',1,0,9,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LOANAPPLY_LOANINFO';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='loanmoney');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'loanmoney','ld_loanapply',1,7,'loanmoney','借款金额',1,0,1,@blockid ,1,'N~M~25,2',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='loanmoney');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='paymentdate');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'paymentdate','ld_loanapply',1,5,'paymentdate','预计还款日期',1,0,2,@blockid ,1,'D~M',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='paymentdate');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='loanreason');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'loanreason','ld_loanapply',1,19,'loanreason','借款事由',1,0,3,@blockid ,1,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='loanreason');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LOANAPPLY_FILE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;

call getallprofile('LoanApply');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='loanapply_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='loanreason';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'借款事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'借款事由' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='loanmoney';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'借款金额' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'借款金额' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='paymentdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'预计还款日期' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'预计还款日期' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='LoanApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='LoanApply' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'LoanApply',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='LoanApply' and viewname='All');
delimiter;
select cvid into @cvid from ld_customview where entitytype='LoanApply' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:loanapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:loanmoney%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_loanapply:loanreason:loanreason:LoanApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:loanreason%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:paymentdate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_loanapply:createdtime:createdtime:LoanApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_loanapply:createdtime%');
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;


call addtabintoprofile('LoanApply',1);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,129,'借款申请是否启用审批流程','LoanApply',30,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=129) ;
delimiter;

select tabid into @tabid from ld_tab where name='LoanApply';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
 insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

select max(cvid)into @maxcvid  from ld_customview  ;
update ld_customview_seq set id=@maxcvid+1;
delimiter;

CREATE TABLE if not exists `ld_cardapply` (
  `cardapplyid` int(19) NOT NULL DEFAULT '0',
	`applydate` date default null,
	`printnum` int(11) default null ,
  `smownerid` int(19) DEFAULT NULL,
  `cardapply_no` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `approvestatus` varchar(50) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `currentapprover` varchar(1000) DEFAULT NULL,
	`zh_companyname` varchar(500) default null,
	`zh_address` varchar(500) default null,
	`zh_name` varchar(200) default null,
	`zh_title` varchar(500) default null,
	`zh_department` varchar(500) default null,
	`zh_phone` varchar(50) default null,
	`zh_fax` varchar(50) default null,
	`zh_email` varchar(200) default null,
	`en_companyname` varchar(500) default null,
	`en_address` varchar(500) default null,
	`en_name` varchar(200) default null,
	`en_title` varchar(500) default null,
	`en_department` varchar(500) default null,
	`en_phone` varchar(50) default null,
	`en_fax` varchar(50) default null,
	`en_email` varchar(200) default null,
  `description` text,
`deleted` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cardapplyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists  `ld_cardapplyscf` (
  `cardapplyid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cardapplyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'CardApply',0,80,'CardApply',1 from dual 
where not EXISTS(select 1 from ld_tab where name='CardApply');

select tabid into @tabid from ld_tab  where name='CardApply';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'名片申请' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Application Card' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='oaforms';
select tabid into @tabid from ld_tab  where name='CardApply';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,6 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
update ld_modentity_num_seq set id=@maxnum_id+1 where not EXISTS(select 1 from ld_modentity_num where semodule='CardApply');
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'CardApply','MP',1,1,1,'none',0,1,0 from dual 
where not EXISTS(select 1 from ld_modentity_num where semodule='CardApply');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','Save','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'CardApply','ld_cardapply','cardapply_no','cardapplyid','cardapplyid' from dual 
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='CardApply');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_BASICINFORMATION' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_CARDAPPLY_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_CARDAPPLY_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_ZH_CONTENT' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_CARDAPPLY_ZH_CONTENT',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_ZH_CONTENT' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_CARDAPPLY_ZH_CONTENT' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'名片内容(中文)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'名片内容(中文)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_EN_CONTENT' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_CARDAPPLY_EN_CONTENT',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_EN_CONTENT' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_CARDAPPLY_EN_CONTENT' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'名片内容(英文)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'名片内容(英文)' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select max(blockid) into @maxblockid from ld_blocks;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_FILE' and tabid=@tabid);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_CARDAPPLY_FILE',3,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBL_CARDAPPLY_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_CARDAPPLY_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachments Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CARDAPPLY_BASICINFORMATION';

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='applydate');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'applydate','ld_cardapply',1,5,'applydate','申请日期',1,0,1,@blockid ,1,'D~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='applydate');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cardapply_no');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'cardapply_no','ld_cardapply',1,4,'cardapply_no','单据编号',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cardapply_no');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='printnum');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'printnum','ld_cardapply',1,7,'printnum','印刷数量(张)',1,0,3,@blockid ,1,'N~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='printnum');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smownerid','ld_cardapply',1,53,'assigned_user_id','申请人',1,0,4,@blockid ,1,'V~M',0,1 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_cardapply',1,70,'createdtime','创建时间',1,0,5,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_cardapply',1,52,'smcreatorid','创建人',1,0,6,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_cardapply',1,70,'modifiedtime','修改时间',1,0,7,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_cardapply',1,52,'modifiedby','最新更新人',1,0,8,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approvestatus','ld_cardapply',1,609,'approvestatus','审批状态',1,0,9,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'approveby','ld_cardapply',1,131,'approveby','当前审批人',1,0,10,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'currentapprover','ld_cardapply',1,132,'currentapprover','上一步审批人',1,0,11,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CARDAPPLY_ZH_CONTENT';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_companyname');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_companyname','ld_cardapply',1,1,'zh_companyname','公司名称',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_companyname');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_address');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_address','ld_cardapply',1,1,'zh_address','地址',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_address');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_name');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_name','ld_cardapply',1,1,'zh_name','姓名',1,0,3,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_name');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_tile');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_title','ld_cardapply',1,1,'zh_title','职务',1,0,4,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_title');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_department');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_department','ld_cardapply',1,1,'zh_department','部门',1,0,6,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_department');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_phone');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_phone','ld_cardapply',1,11,'zh_phone','电话',1,0,7,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_phone');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_fax');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_fax','ld_cardapply',1,1102,'zh_fax','传真',1,0,8,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_fax');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_email');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_email','ld_cardapply',1,13,'zh_email','email',1,0,9,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_email');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CARDAPPLY_EN_CONTENT';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_companyname');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_companyname','ld_cardapply',1,1,'zh_companyname','公司名称',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_companyname');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_address');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_address','ld_cardapply',1,1,'en_address','地址',1,0,2,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_address');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_name');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_name','ld_cardapply',1,1,'en_name','姓名',1,0,3,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_name');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_title');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'zh_title','ld_cardapply',1,1,'en_position','职务',1,0,4,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_title');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_department');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_department','ld_cardapply',1,1,'en_department','部门',1,0,6,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_department');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_phone');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_phone','ld_cardapply',1,11,'en_phone','电话',1,0,7,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_phone');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='zh_fax');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_fax','ld_cardapply',1,1102,'en_fax','传真',1,0,8,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_fax');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_email');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_email','ld_cardapply',1,13,'en_email','email',1,0,9,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_email');
delimiter;

select tabid into @tabid from ld_tab where name='CardApply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CARDAPPLY_FILE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;
call getallprofile('CardApply');

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='applydate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请日期' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请日期' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='printnum';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'印刷数量' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'印刷数量' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;
select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'申请人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='cardapply_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_companyname';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'公司名称' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'公司名称' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_address';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'地址' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'地址' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_name';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'姓名' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'姓名' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_title';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'职务' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'职务' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_department';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'部门' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'部门' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_phone';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'联系电话' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'联系电话' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;
select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_fax';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'传真' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'传真' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='zh_email';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'电子邮箱' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'电子邮箱' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_companyname';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Company Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Company Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_address';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Address' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Address' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_name';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Name' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_title';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Position' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Position' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_department';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Department' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Department' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_phone';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Telephone' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Telephone' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;
select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_fax';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Fax' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Fax' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_email';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Email' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Email' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'CardApply',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='All');
delimiter;
select cvid into @cvid from ld_customview where entitytype='CardApply' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:cardapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:applydate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:printnum%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_cardapply:currentapprover:currentapprover:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:currentapprover%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_cardapply:smcreatorid:smcreatorid:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smcreatorid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_cardapply:createdtime:createdtime:CardApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:createdtime%');
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='已批准');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'已批准',0,0,'CardApply',3,1,2 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='已批准');
delimiter;

select cvid into @cvid from ld_customview where entitytype='CardApply' and viewname='已批准';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:cardapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:applydate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:printnum%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_cardapply:currentapprover:currentapprover:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:currentapprover%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_cardapply:smcreatorid:smcreatorid:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smcreatorid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_cardapply:createdtime:createdtime:CardApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:createdtime%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V','c','已批准',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );
insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='审批中');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'审批中',0,0,'CardApply',3,1,3 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='审批中');
delimiter;

select cvid into @cvid from ld_customview where entitytype='CardApply' and viewname='审批中';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:cardapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:applydate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:printnum%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_cardapply:currentapprover:currentapprover:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:currentapprover%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_cardapply:smcreatorid:smcreatorid:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smcreatorid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_cardapply:createdtime:createdtime:CardApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:createdtime%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V','c','审批中',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );
insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='已驳回');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'已驳回',0,0,'CardApply',3,1,4 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='已驳回');
delimiter;

select cvid into @cvid from ld_customview where entitytype='CardApply' and viewname='已驳回';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:cardapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:applydate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:printnum%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_cardapply:currentapprover:currentapprover:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:currentapprover%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_cardapply:smcreatorid:smcreatorid:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smcreatorid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_cardapply:createdtime:createdtime:CardApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:createdtime%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V','c','已驳回',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );
insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='未提交');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'未提交',0,0,'CardApply',3,1,5 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='未提交');
delimiter;

select cvid into @cvid from ld_customview where entitytype='CardApply' and viewname='未提交';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:cardapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:applydate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:printnum%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_cardapply:currentapprover:currentapprover:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:currentapprover%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_cardapply:smcreatorid:smcreatorid:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smcreatorid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_cardapply:createdtime:createdtime:CardApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:createdtime%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V','c','未提交',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );
insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='已拒绝');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'已拒绝',0,0,'CardApply',3,1,6 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='CardApply' and viewname='已拒绝');
delimiter;

select cvid into @cvid from ld_customview where entitytype='CardApply' and viewname='已拒绝';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:cardapply_no%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:D' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:applydate%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smownerid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:N' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:printnum%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:approvestatus%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_cardapply:currentapprover:currentapprover:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:currentapprover%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_cardapply:smcreatorid:smcreatorid:CardApply_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:smcreatorid%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_cardapply:createdtime:createdtime:CardApply_fieldlabel:DT' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_cardapply:createdtime%');

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid ,0 ,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V','c','已拒绝',1,'' from dual 
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid );
insert into ld_cvadvfilter_grouping(groupid,cvid ,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not EXISTS(select 1 from ld_cvadvfilter_grouping  where cvid=@cvid);
delimiter;

select tabid into @tabid from ld_tab where name='cardapply';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;

call addtabintoprofile('cardapply',1);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,131,'名片申请是否启用审批流程','cardapply',30,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=131);
delimiter;

select tabid into @tabid from ld_tab where name='cardapply';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual 
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
 insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;
select max(cvid)into @maxcvid  from ld_customview  ;
update ld_customview_seq set id=@maxcvid+1;
delimiter;

update ld_field set uitype=112 where columnname='related_to' and tablename='ld_attachmentsforbills';
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='costtime';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'time_diff(a,b,hour)',"{formulavar:[{'lettervar':'a','column':'endtime'},{'lettervar':'b','column':'starttime'}]}",4 from dual 
where not EXISTS(select 1 from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid);
delimiter;

select tabid into @tabid from ld_tab where name='minusjobbill';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='costtime';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'time_diff(a,b,hour)',"{formulavar:[{'lettervar':'a','column':'endtime'},{'lettervar':'b','column':'starttime'}]}",4 from dual 
where not EXISTS(select 1 from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid);
delimiter;

select tabid into @tabid  from ld_tab where name='expense';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'money'}]}" ,2 from dual 
where not EXISTS(select 1 from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid);
delimiter;

update ld_relatedlists set mobile_presence = presence where name = 'get_SharedUsers';
delimiter;

update ld_field set uitype=1109 where tabid in (select tabid from ld_tab where name='normalapprove' ) and columnname='filename';
delimiter;


insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',132,132,'未入库订单是否允许退货'
from dual where not exists (select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=132);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',132,132,'Do not allowed to return the in storaged Purchase Order'
from dual where not exists (select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=132);
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=85;
update ld_systems_deploy set sequence=sequence+2 where roottype=4 and sequence>=@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,132,'未入库订单是否允许退货1：是，0：否',@sequence+1,4,'select',0,
'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=132);
delimiter;
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=4 order by sequence;
delimiter;

update ld_tabdetailfield set newline=0 where tabid in(select tabid from ld_tab where name='cashbill' ) and COLUMNname='entitytype';
delimiter;
update ld_tabdetailfield set newline=0 where tabid in(select tabid from ld_tab where name='sendcashbill' ) and (COLUMNname='entitytype' or columnname='amount' or columnname='entitytypeid');
delimiter;

select tabid into @tabid from ld_tab where name = 'PublicAnnouncement';
delete from ld_profileallpermission where tabid=@tabid and operation=14;
delete from ld_relatedlists where tabid=@tabid and name = 'get_SharedUsers';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THESEDATETIMEOVER8','以下日期的工时超过8小时,是否继续？','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'THESEDATETIMEOVER8' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','THESEDATETIMEOVER8','Do you want to continue working for more than 8 hours on the following dates?','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'THESEDATETIMEOVER8' and labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2017-05-17

set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence,tabid;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
update ld_tranlabel set fieldlabel='常用审批单' where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' and fieldlabel='普通审批';
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select tablename into @tablename from ld_field where tabid=@tabid and columnname='smownerid';
set @columnname='normalapprovetype';
set @fieldname='normalapprovetype';
set @zh='申请类型';
set @en='Application Type';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','100','');
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=sequence+5 where tabid=@tabid and block=@blockid;
update ld_field set sequence=1 where tabid=@tabid and columnname='normalapprovetype';
update ld_field set sequence=2 where tabid=@tabid and columnname='normalapprove_no';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_normalapprovetype` (
  `normalapprovetypeid` int(19) NOT NULL AUTO_INCREMENT,
  `normalapprovetype` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL DEFAULT '1',
  `picklist_valueid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`normalapprovetypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_normalapprovetype_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from ld_picklistvalues_seq;
set @typevalue='付款申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='折扣申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='入职申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='离职申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='转正申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='用车申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='会议室申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='物品领用申请';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select id into @id from ld_picklistvalues_seq;
set @typevalue='其他';
set @i=0;
insert into ld_normalapprovetype(normalapprovetype,presence,picklist_valueid)
select @typevalue,@i:=@i+1,@id+1 from dual 
where not exists (select 1 from ld_normalapprovetype where normalapprovetype=@typevalue);

select ifnull(max(picklist_valueid),0) into @picklist_valueid from ld_normalapprovetype;
update ld_picklistvalues_seq set id=@picklist_valueid where id<@picklist_valueid;
delimiter;

delete from ld_normalapprovetype_seq;
insert into ld_normalapprovetype_seq(id)
select max(normalapprovetypeid) from ld_normalapprovetype;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname in ('description','normalapprovetype');
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('normalapprove_no','smownerid','description','normalapprovetype');
delimiter;

select cvid into @cvid from ld_customview where entitytype='NormalApprove' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';
delimiter;

SET @viewname='已批准';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='审批中';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='未提交';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='付款申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='折扣申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='入职申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='离职申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='转正申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='用车申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='会议室申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='物品领用申请';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='其他';
set @entitytype='NormalApprove';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;
delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:normalapprovetype:normalapprovetype:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:currentapprover:currentapprover:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:description:description:NormalApprove_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,(@i:=@i+1),'ld_attachments:filename:filename:NormalApprove_fieldlabel:V';

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='normalapprovetype';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':normalapprovetype:normalapprovetype:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='付款申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='折扣申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;


select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='入职申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='离职申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='转正申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='用车申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='会议室申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='物品领用申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='NormalApprove';
set @approvename='其他申请流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);

select tabid into @tabid from ld_tab where `name`='Expense';
update ld_tranlabel set fieldlabel='费用报销单' where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' and fieldlabel='费用报销';

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='OAForms';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,(select max(sequence)+1 from ld_parenttabrel where parenttabid=@parenttabid) from dual 
where not exists (select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);

delete from ld_parenttabrel where tabid=@tabid and parenttabid=(select parenttabid from ld_parenttab where parenttab_label='Finacial'); 

select tabid into @tabid from ld_tab where `name`='Commission';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,(select max(sequence)+1 from ld_parenttabrel where parenttabid=@parenttabid) from dual 
where not exists (select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);

delete from ld_parenttabrel where tabid=@tabid and parenttabid=(select parenttabid from ld_parenttab where parenttab_label='Finacial'); 
delimiter;

select tabid into @tabid from ld_tab where `name`='LoanApply';
update ld_tranlabel set fieldlabel='借款申请单' where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' and fieldlabel='借款申请';

select tabid into @tabid from ld_tab where `name`='CardApply';
update ld_tranlabel set fieldlabel='名片申请' where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' and fieldlabel='名片申请';

call getallprofile('NormalApprove');
delimiter;
call fieldprofile('NormalApprove');
delimiter;
-- 2017-05-18

select tabid into @tabid from ld_tab where `name`='AddJobBill';
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width=200;
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('smownerid','addjobbill_no');
delimiter;

SET @viewname='已批准';
set @entitytype='AddJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:starttime:starttime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:endtime:endtime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:costtime:costtime:addjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:description:description:addjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='审批中';
set @entitytype='AddJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:starttime:starttime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:endtime:endtime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:costtime:costtime:addjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:description:description:addjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='未提交';
set @entitytype='AddJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:starttime:starttime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:endtime:endtime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:costtime:costtime:addjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:description:description:addjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='已驳回';
set @entitytype='AddJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:starttime:starttime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:endtime:endtime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:costtime:costtime:addjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:description:description:addjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='已拒绝';
set @entitytype='AddJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:starttime:starttime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:endtime:endtime:addjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:costtime:costtime:addjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_addjobbilldetail:description:description:addjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='AddJobBill';
set @approvename='加班单审批流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width=100;
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('smownerid','minusjobbill_no');
delimiter;

SET @viewname='已批准';
set @entitytype='MinusJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:minusjobtype:minusjobtype:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:starttime:starttime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:endtime:endtime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:costtime:costtime:minusjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:description:description:minusjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width=200;
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('smownerid','minusjobbill_no');
delimiter;

SET @viewname='审批中';
set @entitytype='MinusJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:minusjobtype:minusjobtype:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:starttime:starttime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:endtime:endtime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:costtime:costtime:minusjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:description:description:minusjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width=200;
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('smownerid','minusjobbill_no');
delimiter;

SET @viewname='未提交';
set @entitytype='MinusJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:minusjobtype:minusjobtype:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:starttime:starttime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:endtime:endtime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:costtime:costtime:minusjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:description:description:minusjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width=200;
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('smownerid','minusjobbill_no');
delimiter;

SET @viewname='已驳回';
set @entitytype='MinusJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:minusjobtype:minusjobtype:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:starttime:starttime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:endtime:endtime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:costtime:costtime:minusjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:description:description:minusjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width=200;
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
update ld_field set allowhide='no' where tabid=@tabid and columnname in ('smownerid','minusjobbill_no');
delimiter;

SET @viewname='已拒绝';
set @entitytype='MinusJobBill';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,1,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_tabwithproductview where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:minusjobtype:minusjobtype:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:starttime:starttime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:endtime:endtime:minusjobbilldetail_fieldlabel:DT',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:costtime:costtime:minusjobbilldetail_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_minusjobbilldetail:description:description:minusjobbilldetail_fieldlabel:V',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill';
set @approvename='请假单审批流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

CREATE TABLE if not exists `ld_cashbill2paymentplanscf` (
  `cashbill2paymentplan_id` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cashbill2paymentplan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_sendcashbill2paymentscf` (
  `sendcashbill2payment_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`sendcashbill2payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

update ld_field set allowhide='no' where tabid in(select tabid from ld_tab where name='vendorcontact') and (columnname='lastname' or columnname='vendorid');
update ld_field set allowhide='no' where tabid in(select tabid from ld_tab where name='VendorContactRecords') and ( columnname='vendorid');
delimiter;

delete from ld_profileallpermission where tabid 
in(select tabid from ld_tab where name='loanapply' or name='cardapply' or name='normalapprove' or name='AddJobBill' or name='minusjobbill'  or name='BusinessApply');
delimiter;

select tabid into @tabid from ld_tab where name='loanapply';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','allocate','share','Delete','ChangeCreator','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='cardapply';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','allocate','share','Delete','ChangeCreator','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='AddJobBill';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','allocate','share','Delete','ChangeCreator','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','allocate','share','Delete','ChangeCreator','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','allocate','share','Delete','ChangeCreator','EditView');
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','allocate','share','Delete','ChangeCreator','EditView');
delimiter;

SELECT tabid into @tabid from ld_tab where name='businessapply';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

SELECT tabid into @tabid from ld_tab where name='cardapply';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

SELECT tabid into @tabid from ld_tab where name='loanapply';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

SELECT tabid into @tabid from ld_tab where name='normalapprove';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

SELECT tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

SELECT tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;
select tabid into @tabid from ld_tab where name='normalapprove';
update ld_field set tablename='ld_attachments' where tabid=@tabid and columnname='filename';
delimiter;
update ld_systems_deploy set setype='CardApply' where deploy_type=131;
delimiter;
CALL AddColumn('ld_tab','description','varchar',100,'');
delimiter;
update ld_tab set description='OAFROMS'  where    name='loanapply' or name='cardapply' or name='normalapprove' or name='AddJobBill' or name='minusjobbill'  or name='BusinessApply';
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 50 and roottype = 2;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = 2 and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,133,'收款单是否启用审批流程。1:否，0:是','CashBill',@sequence+1,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=133);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 2 order by sequence asc;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 133 and roottype = 2;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = 2 and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,134,'付款单是否启用审批流程。1:否，0:是','SendCashBill',@sequence+1,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=134);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 2 order by sequence asc;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 31 and roottype = 2;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = 2 and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,135,'出库单是否启用审批流程。1:否，0:是','OutboundOrder',@sequence+1,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=135);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 2 order by sequence asc;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 135 and roottype = 2;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = 2 and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,136,'入库单是否启用审批流程。1:否，0:是','Stock',@sequence+1,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=136);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 2 order by sequence asc;
delimiter;

CALL AddColumn('ld_cashbill','approveby','int','19','0');
CALL AddColumn('ld_cashbill','approvestatus','varchar','200','');
CALL AddColumn('ld_cashbill','currentapprover','varchar','1000',NULL);

alter table ld_cashbill alter approvestatus set default '未提交';

call fieldprofile('CashBill');
delimiter;

call getallprofile('CashBill');
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
select blockid into @blockid from ld_blocks where tabid =@tabid and blocklabel = 'LBL_Cashbill_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_cashbill',131,'approveby','审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_cashbill',130,'approvestatus','审批状态',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currentapprover','ld_cashbill',132,'currentapprover','当前审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('ld_sendcashbill','approveby','int','19','0');
CALL AddColumn('ld_sendcashbill','approvestatus','varchar','200','');
CALL AddColumn('ld_sendcashbill','currentapprover','varchar','1000',NULL);
alter table ld_sendcashbill alter approvestatus set default '未提交';

call fieldprofile('SendCashBill');
delimiter;
call getallprofile('SendCashBill');
delimiter;

select tabid into @tabid from ld_tab where name='SendCashBill';
select blockid into @blockid from ld_blocks where tabid =@tabid and blocklabel = 'LBL_SendCashBill_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_sendcashbill',131,'approveby','审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_sendcashbill',130,'approvestatus','审批状态',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currentapprover','ld_sendcashbill',132,'currentapprover','当前审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='SendCashBill';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('ld_outboundorder','approveby','int','19','0');
CALL AddColumn('ld_outboundorder','approvestatus','varchar','200','');
CALL AddColumn('ld_outboundorder','currentapprover','varchar','1000',NULL);
alter table ld_outboundorder alter approvestatus set default '未提交';
call fieldprofile('OutboundOrder');
delimiter;
call getallprofile('OutboundOrder');
delimiter;

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks where tabid =@tabid and blocklabel = 'LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_outboundorder',131,'approveby','审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_outboundorder',130,'approvestatus','审批状态',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currentapprover','ld_outboundorder',132,'currentapprover','当前审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='OutboundOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('ld_stock','approveby','int','19','0');
CALL AddColumn('ld_stock','approvestatus','varchar','200','');
CALL AddColumn('ld_stock','currentapprover','varchar','1000',NULL);
alter table ld_stock alter approvestatus set default '未提交';
call fieldprofile('Stock');
delimiter;
call getallprofile('Stock');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
select blockid into @blockid from ld_blocks where tabid =@tabid and blocklabel = 'LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_stock',131,'approveby','审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_stock',130,'approvestatus','审批状态',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'currentapprover','ld_stock',132,'currentapprover','当前审批人',@blockid,1,1,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'收款单审批流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='收款单审批流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='收款单审批流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

select tabid into @tabid from ld_tab where name='SendCashBill';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'付款单审批流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='付款单审批流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='付款单审批流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

select tabid into @tabid from ld_tab where name='OutboundOrder';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'出库单审批流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='出库单审批流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='出库单审批流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'入库单审批流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='入库单审批流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='入库单审批流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

update ld_approve_seq set id=(select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
delimiter;

update ld_stock set approveby = subsmownerid where IFNULL(approveby,'')<>IFNULL(subsmownerid,'');
update ld_stock set approvestatus='已批准' where IFNULL(approvestatus,'')<>'已批准' and presence='已入库';
update ld_stock set approvestatus='未提交' where IFNULL(approvestatus,'')<>'未提交' and presence<>'已入库';
delimiter;

update ld_outboundorder set approveby = subsmownerid where IFNULL(approveby,'')<>IFNULL(subsmownerid,'');
update ld_outboundorder set approvestatus='已批准' WHERE IFNULL(approvestatus,'')<>'已批准' and presence='已出库';
update ld_outboundorder set approvestatus='未提交' WHERE IFNULL(approvestatus,'')<>'未提交' and presence<>'已出库';
delimiter;


update ld_cashbill set approveby = checker where IFNULL(approveby,'')<>IFNULL(checker,'');
update ld_cashbill set approvestatus='已批准' where IFNULL(approvestatus,'')<>'已批准' and checkoutstatus='已审核';
update ld_cashbill set approvestatus='未提交' where IFNULL(approvestatus,'')<>'未提交' and checkoutstatus<>'已审核';
delimiter;

update ld_sendcashbill set approveby = checker where IFNULL(approveby,'')<>IFNULL(checker,'');
update ld_sendcashbill set approvestatus='已批准' where IFNULL(approvestatus,'')<>'已批准' and checkoutstatus='已审核';
update ld_sendcashbill set approvestatus='未提交' where IFNULL(approvestatus,'')<>'未提交' and checkoutstatus<>'已审核';
delimiter;

update ld_tab set description='OAFORMS'  where    name='loanapply' or name='cardapply' or 
name='normalapprove' or name='AddJobBill' or name='minusjobbill'  or name='BusinessApply';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OAFORMS','OA表单','fixedstr' from dual where not EXISTS(Select 1 from ld_desk where labelbol='OAFORMS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OAFORMS','OA Form','fixedstr' from dual where not EXISTS(Select 1 from ld_desk where labelbol='OAFORMS' and labeltype='fixedstr' and languagetype='en');
delimiter;

select tabid into @tabid  from ld_tab where name='AddJobBill';
update ld_field set typeofdata='N~O~25,1',uitype=7 where tabid=@tabid and columnname='total';
delimiter;

select tabid into @tabid  from ld_tab where name='minusJobBill';
update ld_field set typeofdata='N~O~25,1',uitype=7 where tabid=@tabid and columnname='total';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_list_headerwidth_default` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `header_type` varchar(255) DEFAULT NULL,
  `uitype` int(19) DEFAULT NULL,
  `width_times` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_list_headerwidth_default(uitype,width_times)
select 2,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 2);
insert into ld_list_headerwidth_default(uitype,width_times)
select 19,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 19);
insert into ld_list_headerwidth_default(uitype,width_times)
select 73,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 73);
insert into ld_list_headerwidth_default(uitype,width_times)
select 102,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 102);
insert into ld_list_headerwidth_default(uitype,width_times)
select 1108,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 1108);
insert into ld_list_headerwidth_default(uitype,width_times)
select 1109,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 1109);
insert into ld_list_headerwidth_default(uitype,width_times)
select 28,2 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 28);
insert into ld_list_headerwidth_default(uitype,width_times)
select 70,1.5 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 70);
insert into ld_list_headerwidth_default(uitype,width_times)
select 86,1.5 from DUAL where not exists(select 1 from ld_list_headerwidth_default where uitype = 86);
delimiter;

update ld_field set typeofdata='N~O~25,0' where columnname='printnum' and tabid in(select tabid from ld_tab where name='cardapply');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_tabdetailfield set defaultcolumn = 2 where columnname in ('entitytype','entitytypeid') and tabid = @tabid;
select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_tabdetailfield set defaultcolumn = 2 where columnname in ('entitytype','entitytypeid') and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @troubleticketid_fieldid from ld_field where tabid = @tabid and columnname = 'troubleticketid';
select fieldid into @contactid_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @accountid_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@troubleticketid_fieldid,@accountid_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @troubleticketid_fieldid and effect_fieldid = @accountid_fieldid);
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@troubleticketid_fieldid,@contactid_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @troubleticketid_fieldid and effect_fieldid = @contactid_fieldid);
delimiter;

select fieldid into @potentialid_fieldid from ld_field where tabid = 22 and columnname = 'potentialid';
select fieldid into @contactid_fieldid from ld_field where tabid = 22 and columnname = 'contactid';
update ld_related_field set curmodule_columninfo = 'contact_id,contacts_name',fromvalue_type='sql',fromvalue_info='select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid LEFT JOIN ld_potential on ld_potential.accountid = ld_contactdetails.accountid where ld_potential.potentialid = ? order by reference desc,ld_contactdetails.contactid desc limit 1' 
where trigger_fieldid = @potentialid_fieldid and effect_fieldid = @contactid_fieldid;
delimiter;

select fieldid into @quoteid_fieldid from ld_field where tabid = 22 and columnname = 'quoteid';
select fieldid into @contactid_fieldid from ld_field where tabid = 22 and columnname = 'contactid';
update ld_related_field set curmodule_columninfo = 'contact_id,contacts_name',fromvalue_type='sql',fromvalue_info='select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid LEFT JOIN ld_quotes on ld_quotes.accountid = ld_contactdetails.accountid where ld_quotes.quoteid = ? order by reference desc,ld_contactdetails.contactid desc limit 1' 
where trigger_fieldid = @quoteid_fieldid and effect_fieldid = @contactid_fieldid;
delimiter;

select tabid into @tabid  from ld_tab where name='businessapply';
update ld_field set uitype=7,typeofdata='N~O~25,1' where tabid=@tabid and columnname='total';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='total';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'days'}]}" ,2 from dual 
where not EXISTS(select 1 from ld_tabdetailfield_formula where tabdetailfieldid=@tabdetailfieldid);
delimiter;

update ld_tabdetailfield  set typeofdata='N~O~20,1' where tabid in (select tabid from ld_tab where name='businessapply') and columnname='days';
delimiter;

update ld_customview set setdefault=1 where entitytype in ('MinusJobBill','AddJobBill','NormalApprove') AND viewname='All';
update ld_customview set setdefault=0 where entitytype in ('MinusJobBill','AddJobBill','NormalApprove') AND viewname<>'All';
--  2017-05-18

UPDATE  ld_tabwithproductview set `columns`=REPLACE(`columns`,'addjobbilldetail_','AddJobBillDetails_') 
where cvid in(select cvid from ld_customview where entitytype='addjobbill');
UPDATE  ld_tabwithproductview set `columns`=REPLACE(`columns`,'minusjobbilldetail_','MinusJobBillDetails_') 
where cvid in(select cvid from ld_customview where entitytype='minusjobbill');
UPDATE  ld_tabwithproductview set `columns`=REPLACE(`columns`,'businessapplydetail_','BusinessApplyDetails_') 
where cvid in(select cvid from ld_customview where entitytype='businessapply');
delimiter;

update ld_desk set fieldlabel = '该单据已出库数量为零，请审核出库单！' where labelbol = 'OUTBOUNDCOUNTEQUALZERO' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The bill has been shipped out to zero, please check the OutboundOrder！' where labelbol = 'OUTBOUNDCOUNTEQUALZERO' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel = '产品累计出库数量超过可出库数量' where labelbol = 'THETOTALOUTBOUNDQUANTITY' and languagetype = 'zh' and Labeltype='jspop';
update ld_desk set fieldlabel = 'The total Outbound quantity of products is greater than the allowable quantity' where labelbol = 'THETOTALOUTBOUNDQUANTITY' and languagetype = 'en' and Labeltype='jspop';
delimiter;
update ld_desk set fieldlabel = '产品累计入库数量超过可入库数量' where labelbol = 'THETOTALSTOCKQUANTITY' and languagetype = 'zh' and Labeltype='jspop';
update ld_desk set fieldlabel = 'The total stock quantity of products is greater than the allowable quantity' where labelbol = 'THETOTALSTOCKQUANTITY' and languagetype = 'en' and Labeltype='jspop';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKFAIL','审核失败','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labeltype = 'jspop' and labelbol = 'CHECKFAIL');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKFAIL','Check Failure','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labeltype = 'jspop' and labelbol = 'CHECKFAIL');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEFAIL','审批失败','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labeltype = 'jspop' and labelbol = 'APPROVEFAIL');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEFAIL','Approve Failure','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labeltype = 'jspop' and labelbol = 'APPROVEFAIL');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_tabdetailfield set defaultcolumn = 6 where columnname in ('entitytype','entitytypeid','source_total','received_amount','amount') and tabid = @tabid;
update ld_tabdetailfield set width = 45 where columnname in ('source_total','received_amount','amount') and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_tabdetailfield set defaultcolumn = 6 where columnname in ('entitytype','entitytypeid','source_total','pay_amount','amount') and tabid = @tabid;
update ld_tabdetailfield set width = 45 where columnname in ('source_total','pay_amount','amount') and tabid = @tabid;
delimiter;

update ld_desk set fieldlabel = '该单据已出库产品，已经创建{$SalesBack.SalesBack}，不允许再办理退货！'  where labelbol = 'ORDERFULLYOUTNOALLOWRETURN' and languagetype ='zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'The document has been out of the library and the product has been created {$SalesBack.SalesBack} and no return is allowed!'  where labelbol = 'ORDERFULLYOUTNOALLOWRETURN' and languagetype ='en' and Labeltype = 'jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SYSTEMPARAMETERS','系统参数','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labeltype = 'fixedstr' and labelbol = 'SYSTEMPARAMETERS');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SYSTEMPARAMETERS','System Parameters','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labeltype = 'fixedstr' and labelbol = 'SYSTEMPARAMETERS');
delimiter;

select tabid into @tabid from ld_tab where name='sendcashbill';
select fieldid into @trigger_fieldid from ld_field where tabid=@tabid and uitype=202;
select fieldid into @effect_fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'assigned_user_id','column','smownerid' from dual 
where not exists(select 1 from ld_related_field where trigger_fieldid=@trigger_fieldid and effect_fieldid=@effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='sendcashbill';
select fieldid into @trigger_fieldid from ld_field where tabid=@tabid and uitype=202;
select fieldid into @effect_fieldid from ld_field where tabid=@tabid and columnname='vendorid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'vendor_id','column','vendorid' from dual 
where not exists(select 1 from ld_related_field where trigger_fieldid=@trigger_fieldid and effect_fieldid=@effect_fieldid);
delimiter;
-- 2017-05-23

SELECT concat('数据来源：',GROUP_CONCAT(fieldlabel SEPARATOR '和')) into @report_describe1 from ld_tranlabel where tabid in (22,37) and languagetype='zh' and trantable='ld_tab';
SELECT concat('查看范围绑定模块：',(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_tab' and languagetype='zh' and Relateid=(SELECT tabid FROM ld_tab WHERE `name`='OftenUseReport'))) into @report_describe2;
update ld_customreport_info set report_describe=CONCAT(IFNULL(@report_describe1,''),'，',IFNULL(@report_describe2,'')) where report_type='template' and systemdefault=1 and report_template='default_performance_byorder.mrt';

SELECT concat('数据来源：',GROUP_CONCAT(fieldlabel SEPARATOR '和')) into @report_describe1 from ld_tranlabel where tabid=(select tabid from ld_tab where `name`='CashBill') and languagetype='zh' and trantable='ld_tab';
update ld_customreport_info set report_describe=CONCAT(IFNULL(@report_describe1,''),'，',IFNULL(@report_describe2,'')) where report_type='template' and systemdefault=1 and report_template='default_performance_bycashbill.mrt';

SELECT parenttabid into @parenttabid FROM ld_parenttab WHERE parenttab_label='OAForms';
SELECT tabid into @tabid FROM ld_tab WHERE `name`='Expense';
UPDATE ld_parenttabrel set sequence=1000 WHERE parenttabid=@parenttabid AND tabid=@tabid;

SET @i=0;
UPDATE ld_parenttabrel set sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;

SET @tabid=18;
SET @blocklabel='LBL_BANKACCOUNT_INFORMATION';
SET @zh='银行账户';
SET @en='Bank Account';
SELECT max(blockid) into @maxblockid from ld_blocks;
SELECT max(sequence) into @seq FROM ld_blocks WHERE tabid=@tabid;

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,@blocklabel,@seq+1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel=@blocklabel and tabid=@tabid);

select blockid into @blockid from ld_blocks where blocklabel=@blocklabel and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

set @modulename='Vendors'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_vendor';
set @columnname='bank_accountname';
set @fieldname='bank_accountname';
set @zh='收款人姓名';
set @en='Bank Account Name';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;


set @modulename='Vendors'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_vendor';
set @columnname='bank_accountnum';
set @fieldname='bank_accountnum';
set @zh='收款账号';
set @en='Bank Account Number';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

set @modulename='Vendors'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_vendor';
set @columnname='bank_opening';
set @fieldname='bank_opening';
set @zh='开户行';
set @en='Opening Bank';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

set @modulename='Vendors'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_vendor';
set @columnname='corporatename';
set @fieldname='corporatename';
set @zh='公司名称';
set @en='Corporate name';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;
call fieldprofile('Vendors');
delimiter;
call getallprofile('Vendors');
delimiter;

select tabid into @tabid from ld_tab where `name`='SendCashBill';
SET @blocklabel='LBL_BANKACCOUNT_INFORMATION';
SET @zh='银行账户';
SET @en='Bank Account';
SELECT max(blockid) into @maxblockid from ld_blocks;
SELECT max(sequence) into @seq FROM ld_blocks WHERE tabid=@tabid;

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,@blocklabel,@seq+1,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel=@blocklabel and tabid=@tabid);

select blockid into @blockid from ld_blocks where blocklabel=@blocklabel and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

set @modulename='SendCashBill'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_sendcashbill';
set @columnname='bank_accountname';
set @fieldname='bank_accountname';
set @zh='收款人姓名';
set @en='Bank Account Name';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;


set @modulename='SendCashBill'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_sendcashbill';
set @columnname='bank_accountnum';
set @fieldname='bank_accountnum';
set @zh='收款账号';
set @en='Bank Account Number';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

set @modulename='SendCashBill'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_sendcashbill';
set @columnname='bank_opening';
set @fieldname='bank_opening';
set @zh='开户行';
set @en='Opening Bank';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

set @modulename='SendCashBill'; 
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_BANKACCOUNT_INFORMATION';
set @tablename='ld_sendcashbill';
set @columnname='corporatename';
set @fieldname='corporatename';
set @zh='公司名称';
set @en='Corporate name';
set @uitype=1;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;
call fieldprofile('SendCashBill');
delimiter;
call getallprofile('SendCashBill');
delimiter;

set @tabid=18;
set @i=0;
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='SendCashBill';
set @i=0;
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_blocks_seq set id=(select max(blockid) from ld_blocks);

select tabid into @tabid from ld_tab where `name`='SendCashBill';
select fieldid into @fieldid1 from ld_field where tabid=@tabid and columnname='vendorid';
select fieldid into @fieldid2 from ld_field where tabid=@tabid and columnname='bank_accountname';

insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@fieldid1,@fieldid2,'','column','bank_accountname' from dual 
where not exists (select 1 from ld_related_field where trigger_fieldid=@fieldid1 and effect_fieldid=@fieldid2);

select fieldid into @fieldid2 from ld_field where tabid=@tabid and columnname='bank_accountnum';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@fieldid1,@fieldid2,'','column','bank_accountnum' from dual 
where not exists (select 1 from ld_related_field where trigger_fieldid=@fieldid1 and effect_fieldid=@fieldid2);

select fieldid into @fieldid2 from ld_field where tabid=@tabid and columnname='bank_opening';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@fieldid1,@fieldid2,'','column','bank_opening' from dual 
where not exists (select 1 from ld_related_field where trigger_fieldid=@fieldid1 and effect_fieldid=@fieldid2);

select fieldid into @fieldid2 from ld_field where tabid=@tabid and columnname='corporatename';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@fieldid1,@fieldid2,'','column','corporatename' from dual 
where not exists (select 1 from ld_related_field where trigger_fieldid=@fieldid1 and effect_fieldid=@fieldid2);
delimiter;
-- 2017-05-23

select tabid into @tabid from ld_tab where `name`='BusinessApply';
set @approvename='出差申请单审批流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='LoanApply';
set @approvename='借款申请单审批流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

SET @viewname='已批准';
set @entitytype='LoanApply';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,0,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanreason:loanreason:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:D',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:createdtime:createdtime:LoanApply_fieldlabel:DT',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='审批中';
set @entitytype='LoanApply';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,0,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanreason:loanreason:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:D',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:createdtime:createdtime:LoanApply_fieldlabel:DT',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='未提交';
set @entitytype='LoanApply';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,0,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanreason:loanreason:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:D',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:createdtime:createdtime:LoanApply_fieldlabel:DT',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='已驳回';
set @entitytype='LoanApply';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,0,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanreason:loanreason:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:D',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:createdtime:createdtime:LoanApply_fieldlabel:DT',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

SET @viewname='已拒绝';
set @entitytype='LoanApply';
select max(cvid) into @maxcvid  from ld_customview;
select max(sequence) into @seq from ld_customview where entitytype=@entitytype;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,@viewname,0,0,@entitytype,3,1,@seq+1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype=@entitytype and viewname=@viewname);

select tabid into @tabid from ld_tab where `name`=@entitytype;
select cvid into @cvid from ld_customview where entitytype=@entitytype and viewname=@viewname;

delete from ld_cvcolumnlist where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_list_headerwidth where relateid=@cvid;
set @i=0;
insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:N',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:loanreason:loanreason:LoanApply_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:D',(@i:=@i+1),@cvid;

insert into ld_cvcolumnlist(columnname,columnindex,cvid)
select 'ld_loanapply:createdtime:createdtime:LoanApply_fieldlabel:DT',(@i:=@i+1),@cvid;

select tabid into @tabid from ld_tab where `name`=@entitytype;
select tablename into @tablename from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0 ,concat(@tablename,':approvestatus:approvestatus:',@entitytype,'_fieldlabel:V'),'e',@viewname,1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
delimiter;

update ld_customview_seq set id = (select max(cvid) from ld_customview);

select tabid into @tabid from ld_tab where `name`='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='printnum';
update ld_field set typeofdata='N~M~25,0' where tabid=@tabid and columnname='printnum';
update ld_field set defaultvalue='thistoday' where tabid=@tabid and columnname='applydate';
update ld_tranlabel set fieldlabel='印刷数量(张)' where tabid=@tabid and trantable='ld_field' and Relateid=@fieldid and fieldlabel='印刷数量';
delimiter;
-- 2017-05-24

set @modulename='NormalApprove';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @printfilename=concat(@modulename,'Default.html');
select concat(fieldlabel,'预置模板') into @templateprintname from ld_tranlabel where languagetype='zh' and Relateid=@tabid and trantable='ld_tab';

insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select @printfilename,@tabid,1,@templateprintname,1,0 from dual 
where not exists (select 1 from ld_templateprint where printfilename=@printfilename and tabid=@tabid and systemdefault=1);
delimiter;

set @modulename='AddJobBill';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @printfilename=concat(@modulename,'Default.html');
select concat(fieldlabel,'预置模板') into @templateprintname from ld_tranlabel where languagetype='zh' and Relateid=@tabid and trantable='ld_tab';

insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select @printfilename,@tabid,1,@templateprintname,1,0 from dual 
where not exists (select 1 from ld_templateprint where printfilename=@printfilename and tabid=@tabid and systemdefault=1);
delimiter;

set @modulename='MinusJobBill';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @printfilename=concat(@modulename,'Default.html');
select concat(fieldlabel,'预置模板') into @templateprintname from ld_tranlabel where languagetype='zh' and Relateid=@tabid and trantable='ld_tab';

insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select @printfilename,@tabid,1,@templateprintname,1,0 from dual 
where not exists (select 1 from ld_templateprint where printfilename=@printfilename and tabid=@tabid and systemdefault=1);
delimiter;

set @modulename='BusinessApply';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @printfilename=concat(@modulename,'Default.html');
select concat(fieldlabel,'预置模板') into @templateprintname from ld_tranlabel where languagetype='zh' and Relateid=@tabid and trantable='ld_tab';

insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select @printfilename,@tabid,1,@templateprintname,1,0 from dual 
where not exists (select 1 from ld_templateprint where printfilename=@printfilename and tabid=@tabid and systemdefault=1);
delimiter;

set @modulename='LoanApply';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @printfilename=concat(@modulename,'Default.html');
select concat(fieldlabel,'预置模板') into @templateprintname from ld_tranlabel where languagetype='zh' and Relateid=@tabid and trantable='ld_tab';

insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select @printfilename,@tabid,1,@templateprintname,1,0 from dual 
where not exists (select 1 from ld_templateprint where printfilename=@printfilename and tabid=@tabid and systemdefault=1);
delimiter;

set @modulename='CardApply';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @printfilename=concat(@modulename,'Default.html');
select concat(fieldlabel,'预置模板') into @templateprintname from ld_tranlabel where languagetype='zh' and Relateid=@tabid and trantable='ld_tab';

insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select @printfilename,@tabid,1,@templateprintname,1,0 from dual 
where not exists (select 1 from ld_templateprint where printfilename=@printfilename and tabid=@tabid and systemdefault=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'NormalApprove',0,0,'ld_normalapprove:normalapprove_no:normalapprove_no:NormalApprove_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'NormalApprove' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'NormalApprove',0,1,'ld_normalapprove:createdtime:createdtime:NormalApprove_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'NormalApprove' and rownumber=0 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'NormalApprove',1,0,'ld_normalapprove:smownerid:assigned_user_id:NormalApprove_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'NormalApprove' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'NormalApprove',1,1,'ld_normalapprove:approvestatus:approvestatus:NormalApprove_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'NormalApprove' and rownumber=1 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'NormalApprove',1,2,'ld_normalapprove:description:description:NormalApprove_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'NormalApprove' and rownumber=1 AND listnumber=2);
delimiter;

select tabid into @tabid from ld_tab where name = 'NormalApprove';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'AddJobBill',0,0,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'AddJobBill' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'AddJobBill',0,1,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'AddJobBill' and rownumber=0 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'AddJobBill',1,0,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'AddJobBill' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'AddJobBill',1,1,'ld_addjobbill:total:hdnGrandTotal:AddJobBill_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'AddJobBill' and rownumber=1 AND listnumber=1);
delimiter;

select tabid into @tabid from ld_tab where name = 'AddJobBill';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'MinusJobBill',0,0,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'MinusJobBill' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'MinusJobBill',0,1,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'MinusJobBill' and rownumber=0 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'MinusJobBill',1,0,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'MinusJobBill' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'MinusJobBill',1,1,'ld_minusjobbill:total:hdnGrandTotal:MinusJobBill_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'MinusJobBill' and rownumber=1 AND listnumber=1);
delimiter;

select tabid into @tabid from ld_tab where name = 'MinusJobBill';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'BusinessApply',0,0,'ld_businessapply:businessapply_no:businessapply_no:BusinessApply_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'BusinessApply' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'BusinessApply',0,1,'ld_businessapply:accountid:account_id:BusinessApply_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'BusinessApply' and rownumber=0 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'BusinessApply',1,0,'ld_businessapply:smownerid:assigned_user_id:BusinessApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'BusinessApply' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'BusinessApply',1,1,'ld_businessapply:approvestatus:approvestatus:BusinessApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'BusinessApply' and rownumber=1 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'BusinessApply',1,2,'ld_businessapply:createdtime:createdtime:BusinessApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'BusinessApply' and rownumber=1 AND listnumber=2);
delimiter;

select tabid into @tabid from ld_tab where name = 'BusinessApply';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'LoanApply',0,0,'ld_loanapply:loanapply_no:loanapply_no:LoanApply_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'LoanApply' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'LoanApply',0,1,'ld_loanapply:paymentdate:paymentdate:LoanApply_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'LoanApply' and rownumber=0 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'LoanApply',1,0,'ld_loanapply:loanmoney:loanmoney:LoanApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'LoanApply' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'LoanApply',1,1,'ld_loanapply:smownerid:assigned_user_id:LoanApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'LoanApply' and rownumber=1 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'LoanApply',1,2,'ld_loanapply:approvestatus:approvestatus:LoanApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'LoanApply' and rownumber=1 AND listnumber=2);
delimiter;

select tabid into @tabid from ld_tab where name = 'LoanApply';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'CardApply',0,0,'ld_cardapply:cardapply_no:cardapply_no:CardApply_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'CardApply' and rownumber=0 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
select 'CardApply',0,1,'ld_cardapply:applydate:applydate:CardApply_fieldlabel:V',2 from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'CardApply' and rownumber=0 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'CardApply',1,0,'ld_cardapply:printnum:printnum:CardApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'CardApply' and rownumber=1 AND listnumber=0);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'CardApply',1,1,'ld_cardapply:smownerid:assigned_user_id:CardApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'CardApply' and rownumber=1 AND listnumber=1);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
select 'CardApply',1,2,'ld_cardapply:approvestatus:approvestatus:CardApply_fieldlabel:V' from dual
where not exists(select 1 from ld_cvcolumnlist_wx
where modulename = 'CardApply' and rownumber=1 AND listnumber=2);
delimiter;

select tabid into @tabid from ld_tab where name = 'CardApply';
update ld_relatedlists set wx_presence=0 where related_tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set columnname = 'vendorid' where tabid = @tabid and columnname = 'vendor_id';
call AddColumn('ld_stock','vendorid','int','11',0);
update ld_stock set vendorid = vendor_id;
update ld_tabwithproductview set `columns` = 'ld_stock:vendorid:vendor_id:Stock_fieldlabel:V' where `columns` like '%ld_stock:vendor_id:vendor_id:Stock%';

update ld_field set approve_demand=0 where uitype=102;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
update ld_related_field set curmodule_columninfo = '' where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid;
delimiter;

update ld_desk set fieldlabel = '该单据已出库产品已经创建{$SalesBack.SalesBack}，不允许再办理退货！' 
where labelbol = 'ORDERFULLYOUTNOALLOWRETURN' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_tabdetailfield set width = 45 where columnname in ('entitytype','entitytypeid') and tabid = @tabid;
delimiter;

select tabid into @tabid  from ld_tab  where name='cardapply';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CARDAPPLY_EN_CONTENT';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_title');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_title','ld_cardapply',1,1,'en_title','职务',1,0,4,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_title');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_title');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'en_department','ld_cardapply',1,1,'en_department','部门',1,0,6,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='en_department');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_title';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Position' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Position' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='CardApply';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='en_department';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'Department' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Department' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid  from ld_tab  where name='CardApply';
update ld_field set fieldname='en_companyname' where tabid =@tabid and columnname='en_companyname';
delimiter;

call getallprofile('CardApply');
delimiter;
call fieldprofile('CardApply');
delimiter;

select tabid into @tabid  from ld_tab  where name='CardApply';
update ld_tranlabel set fieldlabel='名片申请单' where Relateid=@tabid and trantable='ld_tab' and languagetype='zh' and fieldlabel='名片申请';
update ld_field set presence=1 where tabid=@tabid and columnname in ('en_phone','en_email','en_fax');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BusinessApply';
set @fromvalue_info="select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.accountid = ? and deleted = 0 order by reference desc,ld_contactdetails.contactid desc limit 1";
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'contact_id,contacts_name','sql',@fromvalue_info from dual 
where not exists(select 1 from ld_related_field where trigger_fieldid=@trigger_fieldid and effect_fieldid=@effect_fieldid);
delimiter;

update ld_desk set fieldlabel = '该{$SalesOrder.SalesOrder}已经全部出库，不允许创建{$OutboundOrder.OutboundOrder}！',Labeltype='jspop' 
where languagetype = 'zh' and labelbol = 'THEDOCUMENTSHAVEALLOUT';
update ld_desk set fieldlabel = 'The {$SalesOrder.SalesOrder} has all been shipped out, not allowed to create a {$OutboundOrder.OutboundOrder}!',Labeltype='jspop' 
where languagetype = 'en' and labelbol = 'THEDOCUMENTSHAVEALLOUT';
delimiter;

update ld_desk set fieldlabel = '该{$PurchaseOrder.PurchaseOrder}已经全部入库，不允许创建{$Stock.Stock}！',Labeltype='jspop' 
where languagetype = 'zh' and labelbol = 'THEDOCUEMNTSHAVEBEENPUTINSTORAGE';
update ld_desk set fieldlabel = 'The {$SalesOrder.SalesOrder} has all been shipped out, not allowed to create a {$Stock.Stock}!',Labeltype='jspop' 
where languagetype = 'en' and labelbol = 'THEDOCUEMNTSHAVEBEENPUTINSTORAGE';
delimiter;
-- 2017-05-25

update ld_producttoolfield set allowhide='no' where columnname='entitytypeid' 
	and tabid in (select tabid from ld_tab where `name` in ('PurchaseOrder','OutboundOrder','Stock','Invoice','PurchaseInvoice'));
    
select tabid into @tabid from ld_tab where `name`='AddJobBill'; 
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width='190';
delimiter;

select tabid into @tabid from ld_tab where `name`='MinusJobBill'; 
update ld_tabdetailfield set width=100 where tabid=@tabid and columnname='description' and width='160';
delimiter;

select tabid into @tabid from ld_tab where name='normalapprove';
insert into ld_modtracker_tabs (tabid,visible)
select @tabid ,1 from dual where not exists(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='addjobbill';
insert into ld_modtracker_tabs (tabid,visible)
select @tabid ,1 from dual where not exists(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='minusjobbill';
insert into ld_modtracker_tabs (tabid,visible)
select @tabid ,1 from dual where not exists(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='BusinessApply';
insert into ld_modtracker_tabs (tabid,visible)
select @tabid ,1 from dual where not exists(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;
select tabid into @tabid from ld_tab where name='loanapply';
insert into ld_modtracker_tabs (tabid,visible)
select @tabid ,1 from dual where not exists(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='cardapply';
insert into ld_modtracker_tabs (tabid,visible)
select @tabid ,1 from dual where not exists(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','sql','select ld_account.smownerid from ld_contactdetails LEFT JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.contactid = ? ' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set defaultcolumn = 2 where columnname in ('source_total','due_date','received_amount','cashbilldate') and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
-- 2017-05-26

set @tabid=29;
select block into @blockid from ld_field where tabid=@tabid and columnname='user_name';
set @tablename='ld_users';
set @columnname='hire_date';
set @fieldname='hire_date';
set @zh='入职日期';
set @en='Hire Date';
set @uitype=5;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='D~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'date','',NULL);
delimiter;

call getallprofile('Users');
delimiter;
call fieldprofile('Users');
delimiter;

SET @report_name='员工考勤统计表——OA表单';
SET @report_template='oa_attendance_statistics.mrt';
SET @setype='AddJobBill';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SELECT tabid into @tabid1 FROM ld_tab WHERE `name`='AddJobBill';
SELECT tabid into @tabid2 FROM ld_tab WHERE `name`='MinusJobBill';

SELECT concat('数据来源：',GROUP_CONCAT(fieldlabel SEPARATOR '和')) into @report_describe1 from ld_tranlabel where tabid in (@tabid1,@tabid2) and languagetype='zh' and trantable='ld_tab';
SELECT concat('查看范围绑定模块：',(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_tab' and languagetype='zh' and Relateid=(SELECT tabid FROM ld_tab WHERE `name`='OftenUseReport'))) into @report_describe2;
SET @report_describe=concat(@report_describe1,'，',@report_describe2);

SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,'template',@report_template,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);
delimiter;

CREATE OR REPLACE VIEW vw_oa_attendance AS
SELECT
	YEAR(b.starttime) AS nian,
	MONTH(b.starttime) AS yue,
	a.smownerid,
	DATE_FORMAT(b.starttime,'%Y-%m-%d') AS workdate,
	b.starttime,
	b.endtime,
	IFNULL(a.approvestatus,'') AS approvestatus,
	'加班' AS timetype,
	costtime,
	b.description
FROM ld_addjobbill a
LEFT JOIN ld_addjobbilldetail b ON a.addjobbillid=b.id
WHERE a.deleted=0
	AND IFNULL(a.approvestatus,'')<>'已拒绝'
UNION ALL
SELECT
	YEAR(b.starttime) AS nian,
	MONTH(b.starttime) AS yue,
	a.smownerid,
	DATE_FORMAT(b.starttime,'%Y-%m-%d') AS workdate,
	b.starttime,
	b.endtime,
	IFNULL(a.approvestatus,'') AS approvestatus,
CASE WHEN b.minusjobtype='特殊报钟' THEN '报钟' ELSE b.minusjobtype END AS timetype,
	costtime AS hours,
	b.description
FROM ld_minusjobbill a
LEFT JOIN ld_minusjobbilldetail b ON a.minusjobbillid=b.id
WHERE a.deleted=0
	AND IFNULL(a.approvestatus,'')<>'已拒绝';
delimiter;
 
DROP PROCEDURE IF EXISTS `altercolumnfor_primarykey`;
delimiter ||
CREATE  PROCEDURE `altercolumnfor_primarykey`(
 tablename varchar(50),
 columnname varchar(50)
)
BEGIN
    SELECT DATABASE() INTO @tableschema;
    SET tablename=LOWER(tablename);
    SET @primaryNum=0;
		select database() into @db_name;
		
		select count(*) into @primaryNum
		from INFORMATION_SCHEMA.KEY_COLUMN_USAGE t
		where t.table_schema = @db_name and t.TABLE_NAME = tablename and COLUMN_NAME = columnname;
		IF @primaryNum = 0 THEN
			
      SET @altersql=CONCAT(' alter table ',tablename, ' change ',columnname,' ',columnname,' int primary key auto_increment');
      PREPARE stalter FROM @altersql;
      EXECUTE stalter;

			set @altersql1 = CONCAT(' alter table ',tablename, ' change ',columnname,' ',columnname,' int NOT NULL auto_increment');
			PREPARE stalter FROM @altersql1;
      EXECUTE stalter;
			
    END IF;
 end ||
delimiter;

truncate ld_links;
alter table ld_links modify linkid int(11) auto_increment;
delimiter;
call AddColumn('ld_links','description','text','','');
delimiter;
call altercolumnfor_primarykey('ld_links','linkid');
delimiter;

DROP PROCEDURE IF EXISTS `addLinksForModuleImport`;
delimiter ||
CREATE  PROCEDURE `addLinksForModuleImport`(
)
BEGIN
	
	DECLARE approve_module varchar(200);
	DECLARE s int default 0;
	DECLARE module_tabid int default 0;
	DECLARE module_name VARCHAR(200);

	DECLARE cursor_name CURSOR FOR select setype from ld_systems_deploy where setype <> '';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET s=1;

			OPEN cursor_name;
					fetch  cursor_name into approve_module;

					while s <> 1 do
						
					  select tabid into module_tabid from ld_tab where `name` = approve_module;
						select fieldlabel into module_name from ld_tranlabel where tabid = module_tabid and languagetype = 'zh' and trantable = 'ld_tab';
						insert into ld_links(tabid,linktype,linklabel,linkurl,description)
						select module_tabid,'Import','module_import_step1','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=',CONCAT(module_name,'模块导入第一页，选择导入文件') from DUAL
						where not exists(select 1 from ld_links where tabid = module_tabid and linktype = 'Import' and linklabel = 'module_import_step1');
						insert into ld_links(tabid,linktype,linklabel,linkurl,description)
						select module_tabid,'Import','module_import_step2','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=',CONCAT(module_name,'模块导入第二页，设置查重、映射字段，导入方式') from DUAL
						where not exists(select 1 from ld_links where tabid = module_tabid and linktype = 'Import' and linklabel = 'module_import_step2');
						insert into ld_links(tabid,linktype,linklabel,linkurl,description)
						select module_tabid,'Import','module_import_step3','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=',CONCAT(module_name,'模块导入第三页，导出结果') from DUAL
						where not exists(select 1 from ld_links where tabid = module_tabid and linktype = 'Import' and linklabel = 'module_import_step3');

					fetch  cursor_name into approve_module;    
					end while;
			CLOSE cursor_name;
END ||
delimiter;

CALL addLinksForModuleImport();
delimiter;

update ld_desk set fieldlabel='本周新增{$ContactRecords.ContactRecords}数' 
where labelbol='THISWEEKTHENUMBEROFCONTACTRECORDS' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='本月新增{$ContactRecords.ContactRecords}数' 
where labelbol='THISMONTHTHENUMBEROFCONTACTRECORDS' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='上月新增{$ContactRecords.ContactRecords}数' 
where labelbol='LASTMONTHTHENUMBEROFCONTACTRECORDS' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='上周新增{$ContactRecords.ContactRecords}数' 
where labelbol='LASTWEEKTHENUMBEROFCONTACTRECORDS' and languagetype='zh' and labeltype='fixedstr';
delimiter;
select max(salescontracttypeid) into @maxid from ld_salescontracttype;
insert into  ld_salescontracttype_seq (id) select 1 from dual where not exists(select 1 from ld_salescontracttype_seq);
update ld_salescontracttype_seq set id=@maxid;
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total`;
delimiter ||
CREATE  PROCEDURE `update_sales_total`(
	tmp_cashbillid INT(19)
)
BEGIN
	
	declare tmp_entitytypeid int default 0;
	declare tmp_entitytype varchar(200) default NULL;

	declare cur1 CURSOR FOR SELECT DISTINCT
										entitytypeid,
										entitytype
									FROM (
										select
											b.entitytypeid,
											b.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1 and a.cashbillid=tmp_cashbillid
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1 and a.cashbillid=tmp_cashbillid) a
									ORDER BY entitytypeid;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	select ifnull(deploy_value,0) into @approve_deploy_value from ld_systems_deploy where deploy_type=133;
	
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	while(tmp_entitytypeid is not null) DO
	
		set @tmp_entitytypeid=0;
		set @tmp_entitytypeid=tmp_entitytypeid;
		
		
		set @cnt1=0;	
		IF tmp_entitytype='SalesOrder' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_salesorder where salesorderid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) c;
		ELSEIF tmp_entitytype='ServiceContracts' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_servicecontracts where servicecontractsid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) c;
		ELSEIF tmp_entitytype='PaymentPlan' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_paymentplan where paymentplanid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) c;
		ELSEIF tmp_entitytype='Invoice' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_invoice where invoiceid=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) c;
		ELSEIF tmp_entitytype='OutboundOrder' THEN
			select 
				count(DISTINCT currency_id) into @cnt1 
			from (
				select currency_id from ld_outboundorder where out_id=@tmp_entitytypeid and deleted=0
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					where b.entitytypeid=@tmp_entitytypeid and a.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) c;
		END IF;
		
		-- 如果没有多币种的收款
		IF @cnt1=1 THEN
			set @sales_total=0.00;
			set @sales_date='0000-00-00';
			set @sales_total2=0.00;
			set @sales_date2='0000-00-00';
				
			select
				sum(h.amount) into @sales_total
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID  
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by b.entitytypeid;

			-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款
			select
				sum(h.amount) into @sales_total2
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by c.entitytypeid;
				

			IF tmp_entitytype='SalesOrder' THEN
				update ld_salesorder set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='ServiceContracts' THEN
				update ld_servicecontracts set received_amount=round(@sales_total,2)+round(@sales_total2,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PaymentPlan' THEN
				update ld_paymentplan set actualamount=round(@sales_total,2),receivable_balance=round(amount-@sales_total,2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='Invoice' THEN
				update ld_invoice set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
			ELSEIF tmp_entitytype='OutboundOrder' THEN
				update ld_outboundorder set received_amount=round(@sales_total,2),receivable_balance=round(total-@sales_total,2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid; 
			END IF;
				
		-- 如果有多币种的收款
		ELSE
			set @sales_total=0.00;
			set @sales_date='0000-00-00';
			set @sales_total2=0.00;
			set @sales_date2='0000-00-00';
				
			select
				sum(h.amount) into @sales_total
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by b.entitytypeid;
						
			-- 计算合同订单已收金额时，需要考虑合同订单对应的回款计划的收款	
			select
				sum(h.amount) into @sales_total2
			from (
				select 
					a.cashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_cashbill a 
				INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.cashbillid,
						f.entitytypeid,
						e.NoPaymentplan/e.conversion_rate as amount
					from ld_cashbill e
					inner JOIN (select * from (
							select CashBillID,entitytypeid 
								from ld_cashbill2paymentplan 
								order by CashBillID,sequence) t group by CashBillID) f on e.cashbillid=f.CashBillID
							where e.deleted=0 and e.NoPaymentplan<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by c.entitytypeid;
				
			IF tmp_entitytype='SalesOrder' THEN
				update ld_salesorder set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where salesorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='ServiceContracts' THEN
				update ld_servicecontracts set received_amount=round(@sales_total*conversion_rate,2)+round(@sales_total2*conversion_rate,2),receivable_balance=round(total-received_amount,2),cashbilldate=IF(@sales_date>@sales_date2,@sales_date,@sales_date2) where servicecontractsid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PaymentPlan' THEN	
				update ld_paymentplan set actualamount=round(@sales_total*conversion_rate,2),receivable_balance=round(amount-round(@sales_total*conversion_rate,2),2),actualdate=@sales_date where paymentplanid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='Invoice' THEN	
				update ld_invoice set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where invoiceid=@tmp_entitytypeid; 
			ELSEIF tmp_entitytype='OutboundOrder' THEN	
				update ld_outboundorder set received_amount=round(@sales_total*conversion_rate,2),receivable_balance=round(total-round(@sales_total*conversion_rate,2),2),cashbilldate=@sales_date where out_id=@tmp_entitytypeid;
			END IF;
		End IF;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	end while;
	close cur1;
end || 
delimiter;

DROP PROCEDURE IF EXISTS `update_purs_total`;
delimiter ||
CREATE  PROCEDURE `update_purs_total`(
	tmp_sendcashbillid INT(19)
)
BEGIN
	
	declare tmp_entitytypeid int default 0;
	declare tmp_entitytype varchar(200) default NULL;
	
	declare cur1 CURSOR FOR SELECT DISTINCT
										entitytypeid,
										entitytype
									FROM (
										select
											b.entitytypeid,
											b.entitytype
										from ld_sendcashbill a 
										LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1 and a.sendcashbillid=tmp_sendcashbillid
										UNION
										select 
												c.Purchaseorder_id,
												'PurchaseOrder' entitytype
										from ld_sendcashbill a 
										LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
										INNER JOIN ld_sendpayment c on c.sendpaymentid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1 and a.sendcashbillid=tmp_sendcashbillid) a
									ORDER BY entitytypeid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=84;
	select ifnull(deploy_value,0) into @approve_deploy_value from ld_systems_deploy where deploy_type=134;
	
	OPEN cur1;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	while(tmp_entitytypeid is not null) DO
	
		set @tmp_entitytypeid=0;
		set @tmp_entitytypeid=tmp_entitytypeid;
		
		set @cnt1=0;
		select 
			count( DISTINCT currency_id) into @cnt1 
		from (
			select currency_id from ld_purchaseorder where purchaseorderid=@tmp_entitytypeid
			UNION ALL
				select currency_id from ld_purchaseinvoice where purchaseinvoiceid=@tmp_entitytypeid
			UNION ALL
				select currency_id from ld_stock where stock_id=@tmp_entitytypeid 
			UNION ALL	
				select currency_id from ld_sendpayment where sendpaymentid=@tmp_entitytypeid
			UNION ALL
				select 
					a.currency_id 
				from ld_sendcashbill a
				LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			UNION ALL
				select 
					a.currency_id 
				from ld_sendcashbill a
				LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
				where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) c;
					
		-- 如果没有多币种的收款
		IF @cnt1=1 THEN
		      set @purs_total=0.00;
			set @purs_date='0000-00-00';
			set @purs_total2=0.00;
			set @purs_date2='0000-00-00';
			
			select
				sum(h.amount) into @purs_total
			from (
				select 
					a.sendcashbillid,
					b.entitytypeid,
					b.amount
				from ld_sendcashbill a 
				INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.sendcashbillid,
						f.entitytypeid,
						e.nosendpayment as amount
					from ld_sendcashbill e
					inner JOIN (select * from (
							select sendcashbillid,entitytypeid 
								from ld_sendcashbill2payment 
								order by sendcashbillid,sequence) t group by sendcashbillid) f on e.sendcashbillid=f.sendcashbillid
							where e.deleted=0 and e.nosendpayment<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by b.entitytypeid;
			
			-- 计算采购订单已收金额时，需要考虑订单对应的回款计划的收款
			select
				sum(h.amount) into @purs_total2
			from (
				select 
					a.sendcashbillid,
					b.entitytypeid,
					b.amount
				from ld_sendcashbill a 
				INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.sendcashbillid,
						f.entitytypeid,
						e.nosendpayment as amount
					from ld_sendcashbill e
					inner JOIN (select * from (
							select sendcashbillid,entitytypeid 
								from ld_sendcashbill2payment 
								order by sendcashbillid,sequence) t group by sendcashbillid) f on e.sendcashbillid=f.sendcashbillid
							where e.deleted=0 and e.nosendpayment<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by c.Purchaseorder_id;
			
			IF tmp_entitytype='PurchaseOrder' THEN
				update ld_purchaseorder set pay_amount=round(@purs_total,2)+round(@purs_total2,2),pay_balance=round(total-pay_amount,2),sendcashbilldate=IF(@purs_date>@purs_date2,@purs_date,@purs_date2) where purchaseorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PurchaseInvoice' THEN
				update ld_purchaseinvoice set pay_amount=round(@purs_total,2),pay_balance=round(total-round(@purs_total,2),2),sendcashbilldate=@purs_date where purchaseinvoiceid=@tmp_entitytypeid;			
			ELSEIF tmp_entitytype='Stock' THEN
				update ld_stock set pay_amount=round(@purs_total,2),pay_balance=round(total-round(@purs_total,2),2),sendcashbilldate=@purs_date where stock_id=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='SendPayment' THEN
				update ld_sendpayment set Actualamount=round(@purs_total,2),pay_balance=round(Amount-round(@purs_total,2),2),Actualdate=@purs_date where sendpaymentid=@tmp_entitytypeid;
			END IF;
			
			
		-- 如果有多币种的收款	
		ELSE

				set @purs_total=0.00;
			set @purs_date='0000-00-00';
			set @purs_total2=0.00;
			set @purs_date2='0000-00-00';
			
			select
				sum(h.amount) into @purs_total
			from (
				select 
					a.sendcashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_sendcashbill a 
				INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.sendcashbillid,
						f.entitytypeid,
						e.nosendpayment/e.conversion_rate as amount
					from ld_sendcashbill e
					inner JOIN (select * from (
							select sendcashbillid,entitytypeid 
								from ld_sendcashbill2payment 
								order by sendcashbillid,sequence) t group by sendcashbillid) f on e.sendcashbillid=f.sendcashbillid
							where e.deleted=0 and e.nosendpayment<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by b.entitytypeid;
			
			-- 计算采购订单已收金额时，需要考虑订单对应的回款计划的收款
			select
				sum(h.amount) into @purs_total2
			from (
				select 
					a.sendcashbillid,
					b.entitytypeid,
					b.amount/a.conversion_rate as amount
				from ld_sendcashbill a 
				INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
				UNION ALL
				select * from (
					select 
						e.sendcashbillid,
						f.entitytypeid,
						e.nosendpayment/e.conversion_rate as amount
					from ld_sendcashbill e
					inner JOIN (select * from (
							select sendcashbillid,entitytypeid 
								from ld_sendcashbill2payment 
								order by sendcashbillid,sequence) t group by sendcashbillid) f on e.sendcashbillid=f.sendcashbillid
							where e.deleted=0 and e.nosendpayment<>0 and f.entitytypeid>0 
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(e.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001) and IF(a.approvestatus = '已拒绝',0,1) <> IF(@approve_deploy_value=1,0.0001,0)
			group by c.Purchaseorder_id;
			
			IF tmp_entitytype='PurchaseOrder' THEN
				update ld_purchaseorder set pay_amount=round(@purs_total*conversion_rate,2)+round(@purs_total2*conversion_rate,2),pay_balance=round(total-pay_amount,2),sendcashbilldate=IF(@purs_date>@purs_date2,@purs_date,@purs_date2) where purchaseorderid=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='PurchaseInvoice' THEN
				update ld_purchaseinvoice set pay_amount=round(@purs_total*conversion_rate,2),pay_balance=round(total-round(@purs_total*conversion_rate,2),2),sendcashbilldate=@purs_date where purchaseinvoiceid=@tmp_entitytypeid;			
			ELSEIF tmp_entitytype='Stock' THEN
				update ld_stock set pay_amount=round(@purs_total*conversion_rate,2),pay_balance=round(total-round(@purs_total*conversion_rate,2),2),sendcashbilldate=@purs_date where stock_id=@tmp_entitytypeid;
			ELSEIF tmp_entitytype='SendPayment' THEN
				update ld_sendpayment set Actualamount=round(@purs_total*conversion_rate,2),pay_balance=round(Amount-round(@purs_total*conversion_rate,2),2),Actualdate=@purs_date where sendpaymentid=@tmp_entitytypeid;
			END IF;
		END IF;
	Fetch cur1 into tmp_entitytypeid,tmp_entitytype;
	end while;
	close cur1;
end ||
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_field set displaytype = 3 where tabid = @tabid and fieldname in ('hdnSubTotal');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','smownerid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select fieldid into @trigger_fieldid from ld_field where tabid = 16 and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = 16 and columnname = 'smownerid';
delete from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'contact_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','sql','select ld_account.smownerid from ld_contactdetails LEFT JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid and ld_account.deleted = 0 where ld_contactdetails.contactid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'quote_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'potential_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','potentialid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'quote_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','accountid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'quote_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'contact_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'contact_id,contacts_name','sql','select {hrefcolumn},ld_contactdetails.contactid from ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid LEFT JOIN ld_quotes on ld_quotes.accountid = ld_contactdetails.accountid where ld_quotes.quoteid = ? order by reference desc,ld_contactdetails.contactid desc limit 1' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'quote_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'ServiceContractsassigned_user_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','sql','select ld_account.smownerid from ld_quotes LEFT JOIN ld_account on ld_account.accountid = ld_quotes.accountid and ld_account.deleted = 0 where quoteid = ?' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'quote_id';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'potential_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','potentialid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and fieldname = 'servicecontractsid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'potential_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','potentialid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'salesorder_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','salesorderid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'ServiceCharge',0,0,'ld_account:accountname:accountname:Accounts_客户名称:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceCharge' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceCharge',1,0,'ld_account:servicecasher:servicecasher:Accounts_服务收费人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceCharge' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceCharge',1,1,'ld_account:rating:rating:Accounts_客户状态:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceCharge' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ServiceCharge',1,2,'ld_account:createdtime:createdtime:Accounts_创建时间:D' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ServiceCharge' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'Vendors',0,0,'ld_vendor:vendor_no:vendor_no:Vendors_fieldlabel:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Vendors' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Vendors',1,0,'ld_vendor:vendorname:vendorname:Vendors_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Vendors' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Vendors',1,1,'ld_vendor:smownerid:assigned_user_id:Vendors_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Vendors' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Vendors',1,2,'ld_vendor:createdtime:createdtime:Vendors_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Vendors' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'VendorContact',0,0,'ld_vendorcontacts:lastname:lastname:VendorContact_fieldlabel:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContact' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'VendorContact',1,0,'ld_vendorcontacts:smownerid:assigned_user_id:VendorContact_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContact' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'VendorContact',1,1,'ld_vendorcontacts:vendorid:vendor_id:VendorContact_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContact' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'VendorContact',1,2,'ld_vendorcontacts:mobile:mobile:VendorContact_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContact' and rownumber=1 AND listnumber=2);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'VendorContactRecords',0,0,'ld_vendorcontactrecords:subject:subject:VendorContactRecords_fieldlabel:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContactRecords' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'VendorContactRecords',1,0,'ld_vendorcontactrecords:vendorid:vendor_id:VendorContactRecords_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContactRecords' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'VendorContactRecords',2,0,'ld_vendorcontactrecords:smownerid:assigned_user_id:VendorContactRecords_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContactRecords' and rownumber=2 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'VendorContactRecords',2,1,'ld_vendorcontactrecords:createdtime:createdtime:VendorContactRecords_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'VendorContactRecords' and rownumber=2 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,typedescribe)
  select 'PurchaseOrder',0,0,'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_fieldlabel:V',2,'蓝色加粗' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PurchaseOrder' and rownumber=0 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PurchaseOrder',0,1,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PurchaseOrder' and rownumber=0 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PurchaseOrder',1,0,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PurchaseOrder' and rownumber=1 AND listnumber=0);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PurchaseOrder',1,1,'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PurchaseOrder' and rownumber=1 AND listnumber=1);

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'PurchaseOrder',1,2,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PurchaseOrder' and rownumber=1 AND listnumber=2);
-- 2017-05-27

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_version set old_version='V7.0.0',current_version='V7.0.0',remark='V7.0.0-20170527';
delimiter;