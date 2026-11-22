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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

UPDATE ld_field SET displaytype=3 WHERE columnname='print_times';

DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180123`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetfields_20180123`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx17%' THEN
		UPDATE ld_field SET presence=1 WHERE tabid=6 AND tablename='ld_contactdetails' AND columnname='pphone';

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge' LIMIT 1);
		UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND tablename='ld_contactdetails' AND columnname='pphone';

	END IF;

end ||
delimiter;

CALL ldcrm_resetfields_20180123();
DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180123`;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'isenabled';
update ld_field set defaultvalue = '是' where tabid = @tabid and columnname = 'isenabled';
update ld_tranlabel set fieldlabel = '允许查看或下载' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Allow viewing or downloading' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
update ld_attachmentsforbills set isenabled = '是' where isenabled = '公开';
update ld_attachmentsforbills set isenabled = '否' where isenabled = '私有';
update ld_isenabled set isenabled = '是' where isenabled = '公开';
update ld_isenabled set isenabled = '否' where isenabled = '私有';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'isenabled';
update ld_field set defaultvalue = '1',uitype=56 where tabid = @tabid and columnname = 'isenabled';
update ld_attachmentsforbills set isenabled = '1' where isenabled = '是';
update ld_attachmentsforbills set isenabled = '0' where isenabled = '否';
delimiter;
-- 2018-01-23

DROP PROCEDURE IF EXISTS `update_number_creator_cratetime_field`;
delimiter ||
CREATE  PROCEDURE `update_number_creator_cratetime_field`(
)
begin

	declare tmp_tabid int(10) default 0;
	declare tmp_columnname varchar(100) default '';
	declare tmp_block int(10) default 0;
	declare cur1 cursor for SELECT DISTINCT tabid,columnname,block from ld_field WHERE uitype=4;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx17%' THEN
		OPEN cur1;
		Fetch cur1 into tmp_tabid,tmp_columnname,tmp_block;
		while(tmp_tabid is not null) DO
			select max(sequence) into @sequence from ld_field where tabid = tmp_tabid and block=tmp_block;
			update ld_field set sequence = @sequence+1 where columnname='smcreatorid' and tabid = tmp_tabid and block=tmp_block;
			update ld_field set sequence = @sequence+2 where columnname='createdtime' and tabid = tmp_tabid and block=tmp_block;
			update ld_field set sequence = @sequence+3 where columnname=tmp_columnname and tabid = tmp_tabid and block=tmp_block;

			SET @i=0;
			SET @j=0;
			UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid = tmp_tabid AND block=tmp_block AND presence<>1 ORDER BY sequence;
			UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid = tmp_tabid AND block=tmp_block ORDER BY sequence;

			Fetch cur1 into tmp_tabid,tmp_columnname,tmp_block;
		end while;

		close cur1;
	END IF;

end ||
delimiter;

CALL update_number_creator_cratetime_field();
DROP PROCEDURE IF EXISTS `update_number_creator_cratetime_field`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','launchtime','发起时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'launchtime' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','launchtime','Launch time','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'launchtime' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approvestatus','审批状态','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'approvestatus' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approvestatus','Approve status','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'approvestatus' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','resubmit','重新提交','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'resubmit' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','resubmit','Resubmit','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'resubmit' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_field SET quickcreate=1 WHERE displaytype=2;

DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180124`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetfields_20180124`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_block INT(19) DEFAULT 0;
	DECLARE tmp_fieldid INT(19) DEFAULT 0;

	DECLARE mycursor CURSOR FOR SELECT tabid,block,fieldid FROM ld_field WHERE columnname='modifiedtime' GROUP BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid= NULL;
	
	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx17%' THEN
		OPEN mycursor;
		FETCH mycursor INTO tmp_tabid,tmp_block,tmp_fieldid;
		WHILE (tmp_tabid IS NOT NULL) DO
			SET @seq=IFNULL((SELECT sequence FROM ld_field WHERE tabid=tmp_tabid AND columnname='createdtime'),(SELECT MAX(sequence) FROM ld_field WHERE tabid=tmp_tabid AND block=tmp_block));
			UPDATE ld_field SET sequence=sequence+1 WHERE tabid=tmp_tabid AND block=tmp_block AND sequence>=@seq;
			UPDATE ld_field SET presence=0,sequence=@seq WHERE tabid=tmp_tabid AND block=tmp_block AND columnname='modifiedtime';
			
			SET @i=0;
			UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND block=tmp_block ORDER BY sequence;
			UPDATE ld_tranlabel SET fieldlabel='更新时间' WHERE tabid=tmp_tabid AND trantable='ld_field' AND languagetype='zh' AND Relateid=tmp_fieldid;
			
			FETCH mycursor INTO tmp_tabid,tmp_block,tmp_fieldid;
		END WHILE;

	END IF;

end ||
delimiter;

CALL ldcrm_resetfields_20180124();
DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180124`;
delimiter;

update ld_usereport set pagewidthpercent = 100 where pagewidthpercent < 100;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_SUPEGROUP','上级部门','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_SUPEGROUP' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_SUPEGROUP','Superior Department','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_SUPEGROUP' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_GROUPOTRANSFER1','转移下级部门','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_GROUPOTRANSFER1' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_GROUPOTRANSFER1','Transfer lower level Department','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_GROUPOTRANSFER1' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','transferassociatedusers','转移关联成员','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'transferassociatedusers' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','transferassociatedusers','Transfer associated users','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'transferassociatedusers' and labeltype = 'jspop');
delimiter;
-- 2018-01-24

delete from  ld_cvcolumnlistsort where cvid in (select cvid from ld_customview where entitytype IN ('InventoryAccount','InventoryQuery'));
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SO_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_company');
select max(sequence)  into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
  select @tabid,@maxfieldid+1,'express_company','ld_salesorder',1,15,'express_company','物流公司',1,0,@maxsequence+1,@blockid ,1,'V~O',0,1 from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_company');
call getallprofile('SalesOrder');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='express_company';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'物流公司' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Logistics Company' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');

CREATE TABLE  if not exists `ld_express_company` (
  `express_companyid` int(19) NOT NULL DEFAULT '0',
  `express_company` varchar(100) DEFAULT NULL,
  `presence` int(1) DEFAULT '1',
  `picklist_valueid` int(19) DEFAULT '0',
  PRIMARY KEY (`express_companyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(picklistid) into @maxpicklistid from ld_picklist;
update ld_picklist_seq set id=@maxpicklistid+1  where not exists(select 1 from ld_picklist where name='express_company');
insert into ld_picklist(picklistid,name) select @maxpicklistid+1 ,'express_company' from DUAL
where not exists(select 1 from ld_picklist where name='express_company');
select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='顺丰速运');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 1,'顺丰速运',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='顺丰速运');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='天天快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 2,'天天快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='天天快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='百世快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 3,'百世快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='百世快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='圆通快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 4,'圆通快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='圆通快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='中通快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 5,'中通快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='中通快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='韵达快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 6,'韵达快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='韵达快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='邮政EMS');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 7,'邮政EMS',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='邮政EMS');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='申通快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 8,'申通快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='申通快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='丰巢快递');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 9,'丰巢快递',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='丰巢快递');

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_express_company where express_company='德邦');
insert into ld_express_company(express_companyid,express_company,picklist_valueid)
  select 10,'德邦',@id+1 from dual where not exists(select 1 from ld_express_company where express_company='德邦');

call AddColumn('ld_salesorder','express_company','varchar','255',null);
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SO_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_no');
select sequence into @sequence from ld_field where tabid=@tabid AND columnname='express_company' LIMIT 1;

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
  select @tabid,@maxfieldid+1,'express_no','ld_salesorder',1,1,'express_no','物流单号',1,0,@sequence+1,@blockid ,1,'V~O',0,1 from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_no');

call getallprofile('SalesOrder');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='express_no';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'物流单号' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Logistics Single Number' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');

call AddColumn('ld_salesorder','express_no','text',null,null);
delimiter;

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_OUT_INFO';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_company');
select max(sequence)  into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
  select @tabid,@maxfieldid+1,'express_company','ld_outboundorder',1,15,'express_company','物流公司',1,0,@maxsequence+1,@blockid ,1,'V~O',0,1 from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_company');
call getallprofile('OutboundOrder');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='express_company';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'物流公司' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Logistics Company' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');


call AddColumn('ld_outboundorder','express_company','varchar','255',null);
delimiter;

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_OUT_INFO';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_no');
select sequence into @sequence from ld_field where tabid=@tabid AND columnname='express_company' LIMIT 1;

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
  select @tabid,@maxfieldid+1,'express_no','ld_outboundorder',1,1,'express_no','物流单号',1,0,@sequence+1,@blockid ,1,'V~O',0,1 from dual
  where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='express_no');

call getallprofile('OutboundOrder');
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='express_no';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid, @fieldid,'物流单号' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Logistics Single Number' from dual
  where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');

call AddColumn('ld_outboundorder','express_no','text',null,null);
delimiter;

UPDATE ld_field SET presence=1 WHERE columnname IN ('express_company','express_no') AND tablename IN ('ld_salesorder','ld_outboundorder');

UPDATE ld_field SET presence=1 WHERE columnname IN ('purchasestatus','stockpresence') 
	AND tablename IN ('ld_invoice','ld_salesorder','ld_servicecontracts')
	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);

UPDATE ld_field SET presence=1 WHERE tablename='ld_cashbill' AND columnname='cashtype'
	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
    
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=133 AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);

UPDATE ld_field SET quickcreate=0 WHERE tablename='ld_expense' AND columnname IN ('bankaccountsetid','expense_no')
	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
    
UPDATE ld_field SET quickcreate=0 WHERE tablename='ld_businessapply' AND columnname IN ('businessapply_no')
	AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
        
UPDATE ld_field SET quickcreate=1 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE name IN ('Expense','SalesOrder','CashBill','Invoice','BusinessApply','ContactRecords'));
-- 2018-01-25

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.2.6',current_version='V7.2.6',remark='V7.2.6-20180125',wx_version='V7.2.6';
delimiter;