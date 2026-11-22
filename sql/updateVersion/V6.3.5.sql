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
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	declare str varchar(250);  
  set @sql1=concat('drop index ',indexname,' on ',tablename);   
	
	select database() into @datebase;
	set @sql2=concat('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	if @cnt>0 then 
		PREPARE statement_name FROM @sql1;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
	end if;
  
  set @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
  PREPARE statement_name FROM @sql3;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;
	
end ||
delimiter;

DROP PROCEDURE IF EXISTS `DelColumn`;
delimiter ||
CREATE  PROCEDURE `DelColumn`(
tablename varchar(50),
columnname varchar(50)
)
begin

select database() into @tableschema;

set tablename=lower(tablename);
set @colName='';
SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;

set @coldel=IFNULL(@colName,'-1');

IF @coldel <> '-1'  and  @coldel=columnname THEN

	set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);

	prepare stalter from @altercolumn;
	execute stalter;
deallocate prepare stalter;
END IF;
deallocate prepare stmt;
end ||
delimiter;

set @tabid=15;
set @blockid=37;
set @tablename='ld_faq';
set @columnname='pinci';
set @fieldname='pinci';
set @zh='使用频次';
set @en='使用频次';
set @uitype=19;
set @readonly=0;
set @presence=1;
set @defaultvalue=0;
set @displaytype=2;
set @typeofdata='N~O';
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

call getallprofile('Faq');
delimiter;
call fieldprofile('Faq');
delimiter;

alter table ld_troubletickets modify column questionid text;
delimiter;

DROP PROCEDURE IF EXISTS `up_faq_byid`;
delimiter ||
CREATE  PROCEDURE `up_faq_byid`(
	tmp_questionid text
)
BEGIN

	declare tmp_id int(19);
	declare cur1 CURSOR FOR select id from ld_faq where deleted=0 and FIND_IN_SET(id,tmp_questionid);
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;
	
	OPEN cur1;
	Fetch cur1 into tmp_id;
	while(tmp_id is not null) DO
			update ld_faq set pinci=(select ifnull(count(1),0) from ld_troubletickets where FIND_IN_SET(tmp_id,questionid)) where id=tmp_id;	
			Fetch cur1 into tmp_id;
	end while;
	close cur1;
end ||
delimiter;

drop trigger if exists up_faq_pinci1; 
delimiter || 
CREATE TRIGGER up_faq_pinci1 
AFTER INSERT ON ld_troubletickets 
FOR EACH ROW 
BEGIN 

	IF length(new.questionid)>0 THEN
			call up_faq_byid(new.questionid);
	END IF;

END || 
delimiter;

drop trigger if exists up_faq_pinci2; 
delimiter || 
CREATE TRIGGER up_faq_pinci2 
AFTER UPDATE ON ld_troubletickets 
FOR EACH ROW 
BEGIN 

	IF length(new.questionid)>0 THEN
			call up_faq_byid(new.questionid);
	END IF;

	
	IF length(old.questionid)>0 and old.questionid<>new.questionid THEN
			call up_faq_byid(new.questionid);
	END IF;

END || 
delimiter;


SELECT tabid into @tabid from ld_tab where `name`='Users';
UPDATE ld_field SET columnname='bangwo8_supportname' where tabid=@tabid AND columnname='supportname';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,'103','是否隐藏帮我吧在线咨询功能,0:是',85,4,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from  ld_systems_deploy where deploy_type=103);
insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_system_deploy',103,'103','是否隐藏帮我吧在线咨询功能' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=103  and trantable='ld_system_deploy');
insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_system_deploy',103,'103','Whether to hide the online consultation' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=103  and trantable='ld_system_deploy');
delimiter;
-- 2016-05-23

CREATE TABLE IF NOT EXISTS `ld_bangwo8_supportname`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supportname` varchar(500) DEFAULT NULL,
  `operate_smownerid` INT(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label='LBL_OTHER_SETTINGS';
SELECT max(sequence)INTO @sequence from ld_settings_field WHERE blockid=@blockid;
SELECT MAX(fieldid) INTO @fieldid from ld_settings_field ;
insert into ld_settings_field(fieldid,blockid,NAME,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'BANGWO8INTERFACE','backupserver.png','SETUPBANGWO8INTERFACE',
'index.php?module=Settings&action=bangwo8interface&parenttab=Settings&blockidsetting=2&fieldidsetting=2',@sequence+1,0
from dual where not EXISTS(select 1 from ld_settings_field  where blockid = @blockid and `name` ='BANGWO8INTERFACE');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BANGWO8INTERFACE','帮我吧接口','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8INTERFACE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BANGWO8INTERFACE','Bangwo8 Interface','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8INTERFACE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETUPBANGWO8INTERFACE','设置帮我吧接口','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SETUPBANGWO8INTERFACE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETUPBANGWO8INTERFACE','Set Bangwo8 Interface','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SETUPBANGWO8INTERFACE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SYNCHRONIZATIONOFCLIENTSANDCONTACTS','同步客户和联系人','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SYNCHRONIZATIONOFCLIENTSANDCONTACTS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SYNCHRONIZATIONOFCLIENTSANDCONTACTS','Synchronization of clients and contacts','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SYNCHRONIZATIONOFCLIENTSANDCONTACTS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BANGWO8ACCOUNT','帮我吧账户','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8ACCOUNT' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BANGWO8ACCOUNT','Bangwo8 ACCOUNT','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8ACCOUNT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTHCODE','密钥','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'AUTHCODE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTHCODE','Authcode','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'AUTHCODE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BANGWO8CUSTOMERSERVICE','帮我吧客服','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8CUSTOMERSERVICE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BANGWO8CUSTOMERSERVICE','Bangwo8 Customer Service','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8CUSTOMERSERVICE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMERSERVICEACCOUNT','客服账号','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERSERVICEACCOUNT' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERSERVICEACCOUNT','Customer Service Account','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERSERVICEACCOUNT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SYSTEMSCOPECLIENTSANDCONTACTS','可见本系统客户和联系人范围','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SYSTEMSCOPECLIENTSANDCONTACTS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SYSTEMSCOPECLIENTSANDCONTACTS','System scope of clients and contacts','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SYSTEMSCOPECLIENTSANDCONTACTS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE','在帮我吧新增或编辑单据对应本系统操作人','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE','In bangwo8 add or edit to this system operator','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BANGWO8CUSTOMERSERVICEACCOUNT','帮我吧客服账号','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8CUSTOMERSERVICEACCOUNT' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BANGWO8CUSTOMERSERVICEACCOUNT','Bangwo8 Customer Service Account','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BANGWO8CUSTOMERSERVICEACCOUNT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDOREDITRECORDSYSTEMOPERATE','新增或编辑单据对应本系统操作人','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDOREDITRECORDSYSTEMOPERATE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDOREDITRECORDSYSTEMOPERATE',' Add or edit to this system operator','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDOREDITRECORDSYSTEMOPERATE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','KEYORVENDORIDISERRORPLEASEENTERAGAIN','密钥或者VendorID不正确，请重新输入!','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'KEYORVENDORIDISERRORPLEASEENTERAGAIN' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','KEYORVENDORIDISERRORPLEASEENTERAGAIN',' Key or vendorid incorrect,please enter again','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'KEYORVENDORIDISERRORPLEASEENTERAGAIN' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

set @tabid=6;
select block into @blockid from ld_field where tabid=@tabid and columnname='accountname';
set @tablename='ld_account';
set @columnname='nolinkdays';
set @fieldname='nolinkdays';
set @zh='N天未联系';
set @en='Nolinked Days';
set @uitype=9;
set @readonly=0;
set @presence=0;
set @defaultvalue=0;
set @displaytype=2;
set @typeofdata='N~O';
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

call getallprofile('Accounts');
delimiter;
call fieldprofile('Accounts');
delimiter;

update ld_account set nolinkdays=datediff(CURDATE(),ifnull(lastcontactdate,date_format(createdtime,'%Y-%m-%d')));

drop trigger if exists up_account_nolinkdays; 
delimiter || 
CREATE TRIGGER up_account_nolinkdays 
BEFORE UPDATE ON ld_account 
FOR EACH ROW 
BEGIN 

IF new.lastcontactdate<>old.lastcontactdate THEN
	SET new.nolinkdays=datediff(CURDATE(),ifnull(new.lastcontactdate,date_format(new.createdtime,'%Y-%m-%d')));
END IF;

END || 
delimiter;

set global event_scheduler = on;
DROP EVENT IF EXISTS `update_account_nolinkdays`;
CREATE EVENT `update_account_nolinkdays`
ON SCHEDULE EVERY 1 DAY STARTS '2016-05-24 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO
update ld_account set nolinkdays=datediff(CURDATE(),ifnull(lastcontactdate,date_format(createdtime,'%Y-%m-%d')));
delimiter;

set @tabid=2;
select block into @blockid from ld_field where tabid=@tabid and columnname='potentialname';
set @tablename='ld_potential';
set @columnname='callhigh';
set @fieldname='callhigh';
set @zh='是否见老板';
set @en='CallHigh';
set @uitype=21;
set @readonly=0;
set @presence=0;
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

call AddColumn(@tablename,@columnname,'int','19',0);
delimiter;

alter table ld_potential modify column callhigh text;

call getallprofile('Potentials');
delimiter;
call fieldprofile('Potentials');
delimiter;

update ld_field set tablename = 'ld_activity' where tabid = 9 and columnname = 'smownerid' and tablename = 'ld_crmentity';
delimiter;
update ld_field set tablename = 'ld_activity' where tabid = 9 and columnname = 'createdtime' and tablename = 'ld_crmentity';
delimiter;
update ld_field set tablename = 'ld_activity' where tabid = 9 and columnname = 'modifiedtime' and tablename = 'ld_crmentity';
delimiter;
update ld_field set tablename = 'ld_activity' where tabid = 9 and columnname = 'description' and tablename = 'ld_crmentity';
delimiter;
update ld_field set tablename = 'ld_activity' where tabid = 9 and columnname = 'modifiedby' and tablename = 'ld_crmentity';
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Emails' and viewname = 'all';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_activity:subject:subject:Emails_Subject:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_emaildetails:to_email:saved_toid:Emails_To:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_activity:date_start:date_start:Emails_Date_Sent:D';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
insert into ld_modtracker_tabs(tabid,visible) 
select @tabid,1 from dual 
where not exists(select 1 from ld_modtracker_tabs where tabid = @tabid);
delimiter;

update ld_tranlabel set trantable = 'ld_systems_deploy' where trantable = 'ld_system_deploy';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
insert into ld_profileallpermission(tabid,operation)
select @tabid,5 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=5);
delimiter;

call DelColumn('ld_users','supportname');
delimiter;
delete from ld_field where tabid=29 and columnname='supportname';
delimiter;
-- 2016-05-24

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
delimiter;

update ld_version set old_version='V6.3.5' ,current_version='V6.3.5' ,remark='V6.3.5-20160524';
delimiter;