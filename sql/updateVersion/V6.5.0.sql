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

DROP PROCEDURE IF EXISTS `insert_tabwithproductview`;
delimiter ||
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_tabwithproductview`(
	modulename varchar(200)
)
BEGIN  
declare done int default 0; 
declare p_tabid int default 0; 
declare p_cvid int default 0; 
declare p_name varchar(100);
declare p_cnt int default 0; 
declare p_columnindex int DEFAULT 0; 
declare p_columnname varchar(100); 
declare isCount int default 0; 
declare cvcolumnCount int default 0; 

declare cur1 CURSOR FOR select tabid,cvid,`name` from ld_tab inner join ld_customview on ld_tab.`name` = ld_customview.entitytype where ld_tab.`name` = modulename; 
declare continue handler for not found SET done =1; 

open cur1; 
fetch cur1 into p_tabid,p_cvid,p_name;
loop2: while done<>1 do 
	select count(1) into p_cnt from ld_tabwithproductview where tabid = p_tabid and cvid = p_cvid; 
	if p_cnt = 0 then 
		set isCount=0; 
		set cvcolumnCount = (select count(1) from ld_cvcolumnlist where cvid = p_cvid); 
		while isCount < cvcolumnCount 
		do 
			set @psql = CONCAT('select columnindex,columnname into @p_columnindex,@p_columnname from ld_cvcolumnlist where cvid = ',p_cvid,' order by columnindex asc limit ',isCount,',1;'); 
			prepare stmt from @psql; 
			execute stmt; 
			deallocate prepare stmt;
			set @psql = CONCAT('insert into ld_tabwithproductview(tabid,columns,sequence,cvid) values (',p_tabid,',"',@p_columnname,'",',@p_columnindex,',',p_cvid,');'); 
			prepare stmt from @psql; 
			execute stmt; 
			deallocate prepare stmt;
			set isCount = isCount + 1; 
		end while; 
	end if;
fetch cur1 into p_tabid,p_cvid,p_name;
end while loop2; 
close cur1; 
end ||
delimiter;

DROP PROCEDURE IF EXISTS `altercolumn`;
delimiter ||
CREATE PROCEDURE `altercolumn`(
  tablename VARCHAR(50),
  oldcolumnname VARCHAR(100),
  newcolumnname VARCHAR(100),
  newcolumntype VARCHAR(100)
)
BEGIN
    SELECT DATABASE() INTO @tableschema;
    SET tablename=LOWER(tablename);
    SET @colName=0;

    select length(column_name) into @colName from information_schema.columns
    where TABLE_SCHEMA= @tableschema and table_name=tablename and COLUMN_NAME=oldcolumnname;

    IF @colName>0 THEN

      SET @altersql=CONCAT(' alter table ',tablename, ' change ',oldcolumnname,' ',newcolumnname,' ',newcolumntype);

      PREPARE stalter FROM @altersql;
      EXECUTE stalter;
    END IF;

  end ||
delimiter;

DROP PROCEDURE IF EXISTS `DelForeignkey`;
delimiter ||
CREATE DEFINER=`root`@`localhost` PROCEDURE `DelForeignkey`(
tablename varchar(50),
foreignname varchar(50)
)
begin

		select database() into @tableschema;
		
		set @cnt=0;
		set tablename=lower(tablename);
		select count(1) into @cnt from information_schema.INNODB_SYS_FOREIGN where ID=concat(DATABASE(),'/',foreignname) and FOR_NAME=concat(DATABASE(),'/',tablename);
		
		IF @cnt>0 THEN
				set @sql1=CONCAT(' alter table ',tablename, ' drop foreign key ',foreignname);
				prepare stalter from @sql1;
				execute stalter;
				deallocate prepare stalter;
		END IF;

end ||
delimiter;

update ld_tranlabel set fieldlabel='客户重复时是否启用报备提醒' where trantable='ld_systems_deploy' and languagetype='zh'and Relateid=95;

call AddColumn('ld_troubletickets','bw8_id','int','11',0); 
delimiter;
-- 2016-07-26




select  max(fieldid) into @maxfieldid from ld_settings_field;
update ld_settings_field_seq set id=@maxfieldid +1  where  not exists(select 1 from ld_settings_field where name='LBL_CALENDAR_TEMPLATE');
SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label='LBL_STUDIO';
SELECT sequence into @sequence from ld_settings_field WHERE name = 'LBL_WORK_TEMPLATE' AND blockid = 3 ;
insert into ld_settings_field(fieldid,blockid,NAME,iconpath,description,linkto,sequence,active)
  select @maxfieldid +1,@blockid,'LBL_CALENDAR_TEMPLATE','Cron.png','DEFINECALENDARTEMPLATEDESCRIPTION',
    'index.php?module=Settings&action=CalendarTemplate&parenttab=Settings&template_showtype=listview',@sequence+1,0
  from dual where not EXISTS(select 1 from ld_settings_field  where blockid = @blockid and `name` ='LBL_CALENDAR_TEMPLATE');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_template_calendar` (
  `templateid`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `tabid`     Int(11),
  `templatename`     Varchar(255),
  `status` Varchar(25) DEFAULT 'open',
  `description` text,
  `allocatetype`      int(11),
  `calendardetail`  text,
  `judgeinfo` text,
  `judgeinfo_groups` varchar(500)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_template_calendar_user` (
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `templateid`     Int(11),
  `userid`     Int(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_tab','calendartemplate','tinyint','4',1);
delimiter;

UPDATE ld_tab SET calendartemplate = 1 WHERE calendartemplate is NULL ;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','LBL_CALENDAR_TEMPLATE','日程模板','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'LBL_CALENDAR_TEMPLATE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','LBL_CALENDAR_TEMPLATE','Calendar Template','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'LBL_CALENDAR_TEMPLATE' and languagetype = 'en' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DEFINECALENDARTEMPLATEDESCRIPTION','定制日程模板','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'DEFINECALENDARTEMPLATEDESCRIPTION' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DEFINECALENDARTEMPLATEDESCRIPTION','Customize Calendar Template','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'DEFINECALENDARTEMPLATEDESCRIPTION' and languagetype = 'en' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CALENDARTEMPLATECONDITIONJUDGMENT','条件判断','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'CALENDARTEMPLATECONDITIONJUDGMENT' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CALENDARTEMPLATECONDITIONJUDGMENT','Condition Judgment','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'CALENDARTEMPLATECONDITIONJUDGMENT' and languagetype = 'en' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','NEWSIGNAL','新','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'NEWSIGNAL' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','NEWSIGNAL','New','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'NEWSIGNAL' and languagetype = 'en' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','REMINDFORCALENDARTEMPLATE','起始日期和截止日期设置的值为当前日期延后的天数','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'REMINDFORCALENDARTEMPLATE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','REMINDFORCALENDARTEMPLATE','Start date and deadline set value is the number of days after the current date delay','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'REMINDFORCALENDARTEMPLATE' and languagetype = 'en' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','TEMPLATE','模板','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol = 'TEMPLATE' and languagetype = 'zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','TEMPLATE','Template','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol = 'TEMPLATE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
-- 日程模板
-- 2016-08-01

UPDATE ld_systems_deploy
SET description = '设置关联客户时是否在所有用户的数据中进行查询0：否，1：是',
inputvalue = '[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Accounts"},{"selectmodule":"Accounts"}]'
WHERE deploy_type=74;
delimiter;

UPDATE ld_tranlabel SET fieldlabel='设置关联客户时是否在所有用户的数据中进行查询'
where trantable='ld_systems_deploy' AND tabid=74 and LANGUAGEtype='zh';
delimiter;

UPDATE ld_tranlabel SET fieldlabel='Whether to query all users’ data when related to customers'
where trantable='ld_systems_deploy' AND tabid=74 and LANGUAGEtype='en';
delimiter;

select sequence+1 INTO @sequence  from ld_systems_deploy where deploy_type=74;
update ld_systems_deploy set sequence=sequence+5 where sequence>=sequence and roottype=1;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,108,'设置关联联系人时是否在所有用户的数据中进行查询0：否，1：是','',
@sequence,1,'select','[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Contacts"}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=108);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',108,108,'设置关联联系人时是否在所有用户的数据中进行查询'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=108);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',108,108,'Whether to query all users’ data when related to contacts'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=108);
delimiter;

select sequence+2 INTO @sequence  from ld_systems_deploy where deploy_type=74;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,109,'设置关联供应商时是否在所有用户的数据中进行查询0：否，1：是','',
@sequence,1,'select','[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Contacts"}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=109);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',109,109,'设置关联供应商时是否在所有用户的数据中进行查询'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=109);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',109,109,'Whether to query all users’ data when related to vendors'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=109);
delimiter;

SELECT sequence INTO @sequence from ld_systems_deploy where deploy_type=74;
delimiter;
UPDATE ld_systems_deploy SET sequence=@sequence+1 where deploy_type=108;
delimiter;
UPDATE ld_systems_deploy SET sequence=@sequence+2 where deploy_type=109;
delimiter;
UPDATE ld_systems_deploy SET sequence=@sequence+3 where deploy_type=66;
delimiter;

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=1  order by sequence;
delimiter;

update ld_systems_deploy set presence=1 where deploy_type=68;

CALL AddColumn('ld_field','approve_demand','int','4', '2');
delimiter;

UPDATE ld_field SET approve_demand=2;
delimiter;
UPDATE ld_field SET approve_demand=0 where uitype in (51,57,80,73,57,59,76,80,78,150,10,15,75,81,76,241,240,59,58);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEDEMAND','审批要求','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'APPROVEDEMAND' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEDEMAND','Approve demand','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'APPROVEDEMAND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT sequence into @sequence FROM ld_blocks WHERE blocklabel = 'JW_INTERFACE_INFO' and tabid = @tabid;
set @i=@sequence+1;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid and sequence > @sequence order by sequence asc;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,visible,display_status)
  select (select max(blockid) from ld_blocks)+1,@tabid,'SOPHO_INTERFACE_INFO',@sequence+1,1,1 from dual
  where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'SOPHO_INTERFACE_INFO');
set @j=@sequence;
update ld_blocks set sequence=(@j:=@j+1) where tabid=@tabid and sequence > @sequence order by sequence asc;
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'SOPHO_INTERFACE_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_blocks',@tabid,@blockid ,'思孚呼叫中心设置' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_blocks',@tabid,@blockid,'Sopho CallCenter Setting' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
call AddColumn('ld_users','sopho_exten','varchar','25',null);
delimiter;
call fieldprofile('Users');
delimiter;
call getallprofile('Users');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'sopho_exten','ld_users',2,'sopho_exten','分机号',@blockid,1,0,'V~O',2,1,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'sopho_exten');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'sopho_exten';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'分机号' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'ExtenNumber' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call AddColumn('ld_users','sopho_queue','varchar','25',null);
delimiter;
call fieldprofile('Users');
delimiter;
call getallprofile('Users');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'sopho_queue','ld_users',2,'sopho_queue','队列号',@blockid,1,0,'V~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'sopho_queue');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'sopho_queue';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'队列号' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'QueueNumber' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

INSERT INTO ld_systems_deploy (deploy_value, deploy_type, description, sequence, presence)
  SELECT 'http://',107,'呼叫中心地址',74,0 FROM dual
  WHERE NOT exists(SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 107);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_systems_deploy',107,107,'呼叫中心地址' from dual
  where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=107);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_systems_deploy',107,107,'CallCenter Address' from dual
  where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=107);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_sopho_phonerecord`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `userid`     INT(11),
  `extennum`     VARCHAR(25),
  `switch`     TINYINT(4),
  `status`      TINYINT(4),
  `event` VARCHAR(20),
  `result`      VARCHAR(20),
  `caller`  VARCHAR(25),
  `callee` VARCHAR(25),
  `starttime` INT(15),
  `endtime` INT(15),
  `recordname` TEXT,
  `indexid` INT(11),
  `modulename` VARCHAR(25)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONTYPE','呼叫类型','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONTYPE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONTYPE',' Call Type','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONTYPE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONSIT','呼叫状态','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONSIT' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONSIT',' Call Situation','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONSIT' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONTYPE1','来电','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONTYPE1' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONTYPE1','Call in','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONTYPE1' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONTYPE2','去电','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONTYPE2' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONTYPE2','Call out','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONTYPE2' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONRESULTFAILED','失败','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONRESULTFAILED' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONRESULTFAILED','FAILED','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONRESULTFAILED' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONRESULTNO ANSWER','超时','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONRESULTNO ANSWER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONRESULTNO ANSWER','NO ANSWER','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONRESULTNO ANSWER' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLACTIONRESULTBUSY','对方正忙','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONRESULTBUSY' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLACTIONRESULTBUSY','BUSY','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLACTIONRESULTBUSY' and languagetype='en');

select tabid into @tabid from ld_tab where name ='ProjectTask';
update ld_field set uitype = 82 where tabid = @tabid and columnname = 'projectid' and uitype = 10;

insert into ld_ws_fieldtype(uitype,fieldtype) 
select 82,'reference' from dual where not exists
(select 1 from ld_ws_fieldtype where uitype = 82 and fieldtype='reference');

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=82 and fieldtype='reference';

insert into ld_ws_referencetype(fieldtypeid,type) 
select @fieldtypeid,'Project' from dual where not exists
(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='Project');

select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=11);
-- 2016-08-11


-- 基金管理费、管理费佣金、业绩报酬、业绩报酬佣金脚本
CREATE TABLE IF NOT EXISTS `ld_fund_net` (
  `fundnetid` int(19) NOT NULL,
  `fund_no` varchar(100) DEFAULT NULL,
  `product_id` int(19) DEFAULT NULL,
  `navdate` date,
  `nav` decimal(25,6) DEFAULT NULL,
  `profit_reward` decimal(25,6) DEFAULT NULL,
  `asset_value` decimal(25,6) DEFAULT NULL,
  `description` text,
  `modifiedby` int(11) DEFAULT '0',
  `modifiedtime` datetime DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `deleted` int(11) DEFAULT '0',
  KEY `idx_fund_net_productid` (`product_id`) USING BTREE,
  KEY `idx_fund_net_navdate` (`navdate`) USING BTREE,
  PRIMARY KEY (`fundnetid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_fund_netcf` (
  `fundnetid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fundnetid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select tabsequence into @tabsequence from ld_tab where `name` = 'BankCash';
update ld_tab set tabsequence = tabsequence + 1 where ld_tab.tabsequence > @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'FundNet',0,@tabsequence+1,'FundNet',1,'Finacial',0
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='FundNet');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial';
select tabid into @tabid from ld_tab where `name` = 'BankCash';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid = @parenttabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'基金净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Fund Net'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
delimiter;

call fieldprofile('FundNet');
delimiter;
call getallprofile('FundNet');
delimiter;
call addtabintoprofile('FundNet',0);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'FundNet';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_FUNDNET_INFO',1 from dual where not exists (select 1 from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_FUNDNET_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_FUNDNET_DESCRIPTION',2 from dual where not exists (select 1 from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_FUNDNET_DESCRIPTION' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
delimiter;

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_FUNDNET_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_FUNDNET_DESCRIPTION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'fund_no','ld_fund_net',4,'fund_no','流水编号',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'V~M',2 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'product_id','ld_fund_net',59,'product_id','基金名称',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'I~M',1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'product_id');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'navdate','ld_fund_net',5,'navdate','净值日期',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'D~M',3 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'navdate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'nav','ld_fund_net',1,'nav','净值',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'V~M',4 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'nav');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'profit_reward','ld_fund_net',72,'profit_reward','当日实收报酬',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'V~M',5 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'profit_reward');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'asset_value','ld_fund_net',72,'asset_value','当日基金资产净值',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'V~M',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'asset_value');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'description','ld_fund_net',19,'description','备注',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_DESCRIPTION'),1,0,'V~O',8 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'description');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_fund_net',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),2,0,'DT~O',12 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_fund_net',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),2,0,'DT~O',14 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_fund_net',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),1,0,'V~M',5,1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_fund_net',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),2,0,'V~O',1,11 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_fund_net',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDNET_INFO'),2,0,'V~O',1,13 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;


select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'product_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'基金名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'基金名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'流水编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'流水编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'净值日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'净值日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'nav';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'profit_reward';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当日实收报酬'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'当日实收报酬'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'asset_value';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当日基金资产净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'当日基金资产净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'CreatedTime'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smownerid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smcreatorid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'FundNet','ld_fund_net','fund_no','fundnetid','fundnetid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='FundNet');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'FundNet','FN',1,1,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'FundNet'
and prefix ='FN');
delimiter;

update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'FundNet',3,1,0,100,NULL
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'FundNet' and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'FundNet' and viewname = 'All';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,0,'ld_fund_net:fund_no:fund_no:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,1,'ld_fund_net:product_id:product_id:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,2,'ld_fund_net:navdate:navdate:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,3,'ld_fund_net:nav:nav:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,4,'ld_fund_net:profit_reward:profit_reward:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,5,'ld_fund_net:smcreatorid:smcreatorid:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,6,'ld_fund_net:smownerid:smownerid:FundNet_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,7,'ld_fund_net:description:description:FundNet_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundNet';
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=12);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=14);
insert into ld_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=5);
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=6);
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='FundNet';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,78,'get_attachment',3,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Products';
SELECT tabid INTO @srtabid FROM ld_tab WHERE `name`='FundNet';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,@srtabid,'get_fundnet',5,'FundNet',0,'',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_fundnet');
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,78,2,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-1,3,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-1);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-10,4,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-10);
delimiter;

select tabid into @tabid from ld_tab where name='FundNet';
insert into ld_modtracker_tabs(tabid,visible) select @tabid,1 from dual 
where not exists(select 1 from ld_modtracker_tabs where tabid = @tabid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_fund_reward` (
  `rewardid` int(19) NOT NULL,
  `reward_no` varchar(100) DEFAULT NULL,
  `product_id` int(19) DEFAULT NULL,
  `fund_manager` varchar(100) DEFAULT NULL,
  `basedate` date,
  `amount` decimal(25,6) DEFAULT NULL,
  `salesorderid` int(19) DEFAULT NULL,
  `navn` decimal(25,6) DEFAULT NULL,
  `navh` decimal(25,6) DEFAULT NULL,
  `share` decimal(25,6) DEFAULT NULL,
  `accountid` int(19) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT '0',
  `modifiedtime` datetime DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`rewardid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_fund_rewardcf` (
  `rewardid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`rewardid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select tabsequence into @tabsequence from ld_tab where `name` = 'FundNet';
update ld_tab set tabsequence = tabsequence + 1 where ld_tab.tabsequence > @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'FundReward',0,@tabsequence+1,'FundReward',1,'Finacial',0
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='FundReward');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial';
select tabid into @tabid from ld_tab where `name` = 'FundNet';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab where `name` = 'FundReward';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid = @parenttabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundReward';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'业绩报酬'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Fund Reward'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
delimiter;

call fieldprofile('FundReward');
delimiter;
call getallprofile('FundReward');
delimiter;
call addtabintoprofile('FundReward',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundReward';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundReward';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundReward';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_FUNDREWARD_INFO',1 from dual where not exists (select 1 from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_FUNDREWARD_INFO' and sequence = 1);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_FUNDREWARD_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'reward_no','ld_fund_reward',4,'reward_no','单据编号',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',2 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'reward_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'product_id','ld_fund_reward',59,'product_id','产品名称',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),1,0,'I~M',1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'product_id');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'fund_manager','ld_fund_reward',1,'fund_manager','基金管理人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',3 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_manager');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'basedate','ld_fund_reward',5,'basedate','计提基准日',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',4 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'basedate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'amount','ld_fund_reward',72,'amount','金额',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',5 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'amount');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'salesorderid','ld_fund_reward',80,'salesorder_id','合同订单',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'I~O',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'salesorderid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'navn','ld_fund_reward',72,'navn','当前份额累计净值',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',7 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'navn');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'navh','ld_fund_reward',72,'navh','上次份额累计净值',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',8 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'navh');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'share','ld_fund_reward',1,'share','总份额余数',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~M',9 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'share');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','ld_fund_reward',73,'account_id','投资人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'I~M',10 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'accountid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'description','ld_fund_reward',19,'description','备注',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_DESCRIPTION'),1,0,'V~O',11 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'description');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_fund_reward',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'DT~O',12 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_fund_reward',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'DT~O',13 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_fund_reward',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),1,0,'V~M',14,1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_fund_reward',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~O',1,15 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_fund_reward',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARD_INFO'),2,0,'V~O',1,16 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'product_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'产品名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'产品名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'reward_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'单据编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_manager';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'基金管理人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'基金管理人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'basedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'计提基准日'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'计提基准日'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'salesorder_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'合同订单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'合同订单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navn';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'当前份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navh';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'上次份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'上次份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'share';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'总份额余数'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'总份额余数'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'投资人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'投资人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'CreatedTime'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smownerid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smcreatorid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundReward';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'FundReward','ld_fund_reward','reward_no','rewardid','rewardid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='FundReward');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'FundReward','FR',1,1,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'FundReward'
and prefix ='FR');
delimiter;

update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'FundReward',3,1,0,100,NULL
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'FundReward' and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'FundReward' and viewname = 'All';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,0,'ld_fund_reward:reward_no:reward_no:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,1,'ld_fund_reward:product_id:product_id:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,2,'ld_fund_reward:fund_manager:fund_manager:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,3,'ld_fund_reward:basedate:basedate:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,4,'ld_fund_reward:amount:amount:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,5,'ld_fund_reward:salesorderid:salesorderid:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,6,'ld_fund_reward:navn:navn:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,7,'ld_fund_reward:share:share:FundReward_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,8,'ld_fund_reward:accountid:accountid:FundReward_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundReward';
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=14);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='FundReward';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,78,'get_attachment',3,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;


SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,78,2,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;

SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-1,3,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-1);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-10,4,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-10);
delimiter;

select tabid into @tabid from ld_tab where name='FundReward';
insert into ld_modtracker_tabs(tabid,visible) select @tabid,1 from dual 
where not exists(select 1 from ld_modtracker_tabs where tabid = @tabid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_fund_reward_commission` (
  `rewardcommissionid` int(19) NOT NULL,
  `rewardcommission_no` varchar(100) DEFAULT NULL,
  `product_id` int(19) DEFAULT NULL,
  `fund_manager` varchar(100) DEFAULT NULL,
  `calculateway` varchar(100) DEFAULT NULL,
  `basedate` date,
  `amount` decimal(25,6) DEFAULT NULL,
  `salesorderid` int(19) DEFAULT NULL,
  `cpstatus` varchar(50) DEFAULT NULL,
  `actualpay` decimal(25,6) DEFAULT NULL,
  `navn` decimal(25,6) DEFAULT NULL,
  `navh` decimal(25,6) DEFAULT NULL,
  `profit_reward` decimal(25,6) DEFAULT NULL,
  `vendorid` int(19) DEFAULT NULL,
  `share_rate` decimal(25,2) DEFAULT NULL,
  `accountid` int(19) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT '0',
  `modifiedtime` datetime DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`rewardcommissionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_fund_reward_commissioncf` (
  `rewardcommissionid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`rewardcommissionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select tabsequence into @tabsequence from ld_tab where `name` = 'FundReward';
update ld_tab set tabsequence = tabsequence + 1 where ld_tab.tabsequence > @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'FundRewardCommission',0,@tabsequence+1,'FundRewardCommission',1,'Finacial',0
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='FundRewardCommission');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial';
select tabid into @tabid from ld_tab where `name` = 'FundReward';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid = @parenttabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'业绩报酬佣金'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Fund Reward Commission'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
delimiter;

call fieldprofile('FundRewardCommission');
delimiter;
call getallprofile('FundRewardCommission');
delimiter;
call addtabintoprofile('FundRewardCommission',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_Def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_FUNDREWARDCOMMISSION_INFO',1 from dual where not exists (select 1 from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO' and sequence = 1);


select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'rewardcommission_no','ld_fund_reward_commission',4,'rewardcommission_no','单据编号',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',2 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'rewardcommission_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'product_id','ld_fund_reward_commission',59,'product_id','产品名称',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'I~O',1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'product_id');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'fund_manager','ld_fund_reward_commission',1,'fund_manager','基金管理人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',3 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_manager');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'calculateway','ld_fund_reward_commission',1,'calculateway','计提方法',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',3 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'calculateway');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'basedate','ld_fund_reward_commission',5,'basedate','计提基准日',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',4 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'basedate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'amount','ld_fund_reward_commission',72,'amount','金额',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',5 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'amount');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'salesorderid','ld_fund_reward_commission',80,'salesorder_id','合同订单',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'I~O',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'salesorderid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'cpstatus','ld_fund_reward_commission',15,'cpstatus','付款状态',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),1,0,'V~M',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'cpstatus');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'actualpay','ld_fund_reward_commission',72,'actualpay','实付金额',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),1,0,'V~M',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'actualpay');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'navn','ld_fund_reward_commission',1,'navn','当前份额累计净值',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',7 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'navn');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'navh','ld_fund_reward_commission',1,'navh','上次份额累计净值',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',8 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'navh');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'profit_reward','ld_fund_reward_commission',72,'profit_reward','当日实收业绩报酬',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',9 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'profit_reward');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'share_rate','ld_fund_reward_commission',9,'share_rate','渠道份额占比',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',10 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'share_rate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendorid','ld_fund_reward_commission',81,'vendor_id','渠道',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',11 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'vendorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','ld_fund_reward_commission',73,'account_id','投资人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'I~O',12 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'accountid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_fund_reward_commission',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'DT~O',14 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_fund_reward_commission',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'DT~O',15 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_fund_reward_commission',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~M',16,1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_fund_reward_commission',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~O',1,17 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_fund_reward_commission',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_FUNDREWARDCOMMISSION_INFO'),2,0,'V~O',1,18 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;



update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;


select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'product_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'产品名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'产品名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'rewardcommission_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'单据编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'单据编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_manager';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'基金管理人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'基金管理人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'calculateway';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'计提方法'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'计提方法'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'basedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'计提基准日'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'计提基准日'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'salesorder_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'合同订单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'合同订单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'cpstatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'付款状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'付款状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'actualpay';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'实付金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'实付金额'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navn';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当前份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'当前份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navh';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'上次份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'上次份额累计净值'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'profit_reward';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'当日实收业绩报酬'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'当日实收业绩报酬'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'share_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'渠道份额占比'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'渠道份额占比'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'渠道'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'渠道'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'投资人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'投资人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'CreatedTime'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smownerid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smcreatorid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'FundRewardCommission','ld_fund_reward_commission','rewardcommission_no','rewardcommissionid','rewardcommissionid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='FundRewardCommission');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'FundRewardCommission','FRC',1,1,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'FundRewardCommission'
and prefix ='FRC');
delimiter;

update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'FundRewardCommission',3,1,0,100,NULL
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'FundRewardCommission' and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'FundRewardCommission' and viewname = 'All';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,0,'ld_fund_reward_commission:rewardcommission_no:rewardcommission_no:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,1,'ld_fund_reward_commission:product_id:product_id:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,2,'ld_fund_reward_commission:calculateway:calculateway:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,3,'ld_fund_reward_commission:basedate:basedate:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,4,'ld_fund_reward_commission:amount:amount:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,5,'ld_fund_reward_commission:actualpay:actualpay:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,6,'ld_fund_reward_commission:cpstatus:cpstatus:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,7,'ld_fund_reward_commission:navn:navn:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,8,'ld_fund_reward_commission:share_rate:share_rate:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,9,'ld_fund_reward_commission:vendorid:vendorid:FundRewardCommission_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,10,'ld_fund_reward_commission:accountid:accountid:FundRewardCommission_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'FundRewardCommission';
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=14);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='FundRewardCommission';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,78,'get_attachment',3,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,78,2,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-1,3,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-1);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-10,4,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-10);
delimiter;

select tabid into @tabid from ld_tab where name='FundRewardCommission';
insert into ld_modtracker_tabs(tabid,visible) select @tabid,1 from dual 
where not exists(select 1 from ld_modtracker_tabs where tabid = @tabid);
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);

CREATE TABLE IF NOT EXISTS `ld_fund_management` ( 
`managementid` int(19) NOT NULL AUTO_INCREMENT, 
`management_no` varchar(100) DEFAULT NULL, 
`product_id` int(19) DEFAULT NULL, 
`fund_no` varchar(100) DEFAULT NULL, 
`fund_manager` varchar(100) DEFAULT NULL, 
`service_rate` decimal(25,6) default NULL, 
`salesorderid` int(19) DEFAULT NULL, 
`expensetype` varchar(100) DEFAULT NULL, 
`expensedate` date DEFAULT NULL, 
`amount` decimal(25,6) default NULL, 
`navh` decimal(25,6) default NULL, 
`navn` decimal(25,6) default NULL, 
`days` int(4) DEFAULT NULL, 
`createdtime` datetime DEFAULT NULL, 
`modifiedby` int(11) DEFAULT NULL, 
`modifiedtime` datetime DEFAULT NULL, 
`smownerid` int(11) DEFAULT NULL, 
`smcreatorid` int(11) DEFAULT NULL, 
`accountid` int(19) DEFAULT NULL, 
`deleted` int(11) DEFAULT 0, 
PRIMARY KEY (`managementid`) 
) ENGINE=InnoDB AUTO_INCREMENT=33334 DEFAULT CHARSET=utf8; 
delimiter; 

select max(tabid)+1 into @tabid from ld_tab; 
select max(tabsequence) into @tabsequence from ld_tab; 
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab) 
select @tabid,'Management',0,@tabsequence+1,'Management',1,'Finacial',1 
from dual where not EXISTS(select 1 from ld_tab where tablabel ='Management'); 
delimiter; 

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial'; 
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid; 
select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_parenttabrel(parenttabid,tabid,sequence) 
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid =@tabid); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tab',@tabid,@tabid,'管理费' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_tab' and tabid = @tabid and relateid = @tabid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tab',@tabid,@tabid,'administration expenses' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_tab' and tabid = @tabid and relateid = @tabid); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_blocks(blockid,tabid,blocklabel,sequence) 
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_Management_INFO',1 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Management_INFO'); 
update ld_blocks_seq set id = (select max(blockid) from ld_blocks); 

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Management_INFO'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid = @blockid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_blocks',@tabid,@blockid,'Reminds Content' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid = @blockid); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'management_no','ld_fund_management',4,'management_no','管理费编号',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'management_no'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'product_id','ld_fund_management',59,'product_id','产品名称',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'product_id'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'fund_no','ld_fund_management',1,'fund_no','基金代号',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_no'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'fund_manager','ld_fund_management',1,'fund_manager','管理人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_manager'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'service_rate','ld_fund_management',72,'service_rate','年运营服务费率',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'service_rate'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'salesorderid','ld_fund_management',80,'salesorder_id','认购合同',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'salesorderid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'expensetype','ld_fund_management',15,'expensetype','费用类别',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'expensetype'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'expensedate','ld_fund_management',5,'expensedate','费用日期',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'D~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'expensedate'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'amount','ld_fund_management',72,'amount','金额',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'amount'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'navh','ld_fund_management',72,'navh','前一日基金资产净值',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'navh'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'navn','ld_fund_management',72,'navn','当日基金资产净值',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'navn'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'days','ld_fund_management',1,'days','当年天数',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'days'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_fund_management',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),2,0,'DT' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_fund_management',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),2,1,'DT' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_fund_management',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_fund_management',52,'creator','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),2,0,'V~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','ld_fund_management',73,'account_id','投资人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'accountid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_fund_management_commission',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),2,1,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby'); 
delimiter; 
update ld_field_seq set id = (select max(fieldid) from ld_field); 
delimiter; 
select tabid into @tabid from ld_tab where `name` = 'Management'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'management_no'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'管理费编号' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'management_no' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'product_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'产品名称' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'productname' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_no'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'基金代号' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Fund No' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_manager'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'管理人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Fund Manager' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'service_rate'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'年运营服务费率' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Service Rate' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'salesorder_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'认购合同' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Salesorder' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'expensetype'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'费用类别' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Expense Type' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'expensedate'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'费用日期' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Expense Date' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'amount'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'金额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Amount' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navh'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'前一日基金资产净值' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Navh' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navn'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'当日基金资产净值' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Navn' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'days'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'当年天数' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Days' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建时间' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'修改时间' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'负责人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Assigned To' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'投资人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Investors' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter; 
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent) 
select (select max(id)+1 from ld_customview_seq),'All',1,'Management',0,1,100 from dual 
where not EXISTS(select 1 from ld_customview where viewname = 'All' and entitytype ='Management'); 
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview); 
delimiter; 
select cvid into @cvid from ld_customview where entitytype = 'Management' and viewname = 'All'; 
delete from ld_cvcolumnlist where cvid = @cvid; 
insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,0,'ld_fund_management:management_no:management_no:Management_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,1,'ld_fund_management:product_id:product_id:Management_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,2,'ld_fund_management:fund_no:fund_no:Management_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,3,'ld_fund_management:fund_manager:fund_manager:Management_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,4,'ld_fund_management:expensetype:expensetype:Management_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,5,'ld_fund_management:expensedate:expensedate:Management_fieldlabel:D'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,6,'ld_fund_management:navh:navh:Management_fieldlabel:N'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,7,'ld_fund_management:service_rate:service_rate:Management_fieldlabel:N'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,8,'ld_fund_management:days:days:Management_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,9,'ld_fund_management:accountid:account_id:Management_fieldlabel:V'; 
delimiter; 

CREATE TABLE IF NOT EXISTS `ld_fund_managementscf` ( 
`managementid` int(19) NOT NULL DEFAULT '1', 
PRIMARY KEY (`managementid`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn) 
select @tabid,'Management','ld_fund_management','management_no','managementid','managementid' 
from dual where not EXISTS(select 1 from ld_entityname where tabid = @tabid 
and modulename ='Management'); 
delimiter; 

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Management'; 
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,78,'get_attachment',1,'Attachment',0,'add',1,1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment'); 
delimiter; 

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Management'; 
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions; 
INSERT INTO ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-5,5,0,'打印工具' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-5); 
delimiter; 

update ld_tab set printtab = 1 where `name` = 'Management'; 
delimiter; 

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype) 
select (select max(num_id)+1 from ld_modentity_num),'Management','FMG_',1,2,1,'none' 
from dual where not EXISTS(select 1 from ld_modentity_num where semodule = 'Management' and prefix ='FMG_'); 
delimiter; 
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num); 
delimiter; 
call fieldprofile('Management'); 
call getallprofile('Management'); 
call addtabintoprofile('Management',0); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PROVISION','计提','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PROVISION' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PROVISION','Provision','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PROVISION' and Labeltype='fixedstr'); 
delimiter; 
SELECT MAX(actionid)+1 INTO @actionid FROM ld_actionmapping; 
INSERT into ld_actionmapping(actionid,actionname,securitycheck,actionlabel) 
select @actionid,'Provision',0,'PROVISION' from dual where not EXISTS(select 1 from ld_actionmapping where actionname='Provision' AND actionlabel='PROVISION'); 
delimiter; 
select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,28 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=28); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,2 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=2); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,3 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=3); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,4 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=4); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,13 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=13); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,14 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=14); 
delimiter; 
select tabid into @tabid from ld_tab where `name` = 'Management'; 
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid); 

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid); 

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid); 

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid); 
select max(ruleid) into @ruleid from ld_def_org_share; 
update ld_def_org_share_seq set id=@ruleid+1 where not exists(select 1 from ld_Def_org_share where tabid=@tabid); 
insert into ld_def_org_share(ruleid,tabid,permission,editstatus) 
select @ruleid+1,@tabid,3,0 from dual where not exists(select 1 from ld_Def_org_share where tabid=@tabid); 
delimiter; 

CREATE TABLE IF NOT EXISTS `ld_fund_management_commission` ( 
`managementcommissionid` int(19) NOT NULL AUTO_INCREMENT, 
`managementcommission_no` varchar(100) DEFAULT NULL, 
`product_id` int(19) DEFAULT NULL, 
`salesorderid` int(19) DEFAULT NULL, 
`fund_no` varchar(100) DEFAULT NULL, 
`fund_manager` varchar(100) DEFAULT NULL, 
`service_rate` decimal(25,6) default NULL, 
`expensetype` varchar(100) DEFAULT NULL, 
`expensedate` date DEFAULT NULL, 
`amount` decimal(25,6) default NULL, 
`cpstatus` varchar(50) default NULL, 
`actualpay` decimal(25,6) default NULL, 
`navh` decimal(25,6) default NULL, 
`navn` decimal(25,6) default NULL, 
`days` int(4) DEFAULT NULL, 
`createdtime` datetime DEFAULT NULL, 
`modifiedtime` datetime DEFAULT NULL, 
`modifiedby` int(11) DEFAULT NULL, 
`vendorid` int(19) DEFAULT NULL, 
`accountid` int(19) DEFAULT NULL, 
`smownerid` int(11) DEFAULT NULL, 
`smcreatorid` int(11) DEFAULT NULL, 
`deleted` int(11) DEFAULT 0, 
PRIMARY KEY (`managementcommissionid`) 
) ENGINE=InnoDB AUTO_INCREMENT=33334 DEFAULT CHARSET=utf8; 
delimiter; 
select max(tabid)+1 into @tabid from ld_tab; 
select max(tabsequence) into @tabsequence from ld_tab; 
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab) 
select @tabid,'Mcommission',0,@tabsequence+1,'Mcommission',1,'Finacial',1 
from dual where not EXISTS(select 1 from ld_tab where tablabel ='Mcommission'); 
delimiter 
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial'; 
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid; 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_parenttabrel(parenttabid,tabid,sequence) 
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid =@tabid); 
delimiter 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tab',@tabid,@tabid,'管理费佣金' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_tab' and tabid = @tabid and relateid = @tabid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tab',@tabid,@tabid,'Management fee commission' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_tab' and tabid = @tabid and relateid = @tabid); 
delimiter 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_blocks(blockid,tabid,blocklabel,sequence) 
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_Management_commission_INFO',1 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Management_commission_INFO'); 
insert into ld_blocks(blockid,tabid,blocklabel,sequence) 
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_Management_commission_DESCRIPTION',2 from dual where not exists (select 1 from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_Management_commission_DESCRIPTION'); 
update ld_blocks_seq set id = (select max(blockid) from ld_blocks); 

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_Management_commission_INFO'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid = @blockid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_blocks',@tabid,@blockid,'Reminds Content' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid = @blockid); 
delimiter 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'managementcommission_no','ld_fund_management_commission',4,'managementcommission_no','管理费编号',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'managementcommission_no'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'product_id','ld_fund_management_commission',59,'product_id','产品名称',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'product_id'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'salesorderid','ld_fund_management_commission',80,'salesorder_id','认购合同',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'salesorderid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'fund_no','ld_fund_management_commission',1,'fund_no','基金代号',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_no'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'fund_manager','ld_fund_management_commission',1,'fund_manager','管理人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'fund_manager'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'service_rate','ld_fund_management_commission',72,'service_rate','年运营服务费率',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'service_rate'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'expensetype','ld_fund_management_commission',15,'expensetype','费用类别',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'expensetype'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'expensedate','ld_fund_management_commission',5,'expensedate','费用日期',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'D~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'expensedate'); 


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'amount','ld_fund_management_commission',72,'amount','金额',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'amount'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'cpstatus','ld_fund_management_commission',15,'cpstatus','付款状态',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'cpstatus'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'actualpay','ld_fund_management_commission',72,'actualpay','实付金额',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'actualpay'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'navh','ld_fund_management_commission',72,'navh','前一日基金净值',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'navh'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'navn','ld_fund_management_commission',72,'navn','当日基金净值',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'navn'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'days','ld_fund_management_commission',1,'days','当年天数',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'days'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_fund_management_commission',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'DT' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_fund_management_commission',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'DT' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_fund_management_commission',52,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'vendorid','ld_fund_management_commission',81,'vendor_id','渠道',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'vendorid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','ld_fund_management_commission',73,'account_id','投资人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'accountid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_fund_management_commission',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_fund_management_commission',52,'creator','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_commission_INFO'),2,0,'V~M' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid'); 
delimiter 
update ld_field_seq set id = (select max(fieldid) from ld_field); 
delimiter 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'managementcommission_no'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'管理佣金编号' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'managementcommission_no' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'product_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'产品名称' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'productname' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'salesorder_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'认购合同' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Salesorder' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_no'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'基金代号' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Fund No' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'fund_manager'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'管理人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Fund Manager' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'service_rate'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'年运营服务费率' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Service Rate' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'expensedate'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'费用日期' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Expense Date' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'expensetype'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'费用类别' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Expense Type' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'amount'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'金额' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'cpstatus'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'付款状态' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'cpstatus' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'actualpay'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'实付金额' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Actualpay' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navh'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'前一日基金净值' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Navh' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'navn'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'当日基金净值' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Navn' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'days'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'当年天数' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Days' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建时间' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Created Time' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'修改时间' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'渠道' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Channel' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'投资人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Investors' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Assigned To' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Creator' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter 

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent) 
select (select max(id)+1 from ld_customview_seq),'All',1,'Mcommission',0,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname = 'All' 
and entitytype ='Mcommission'); 
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview); 
delimiter; 
select cvid into @cvid from ld_customview where entitytype = 'Mcommission' and viewname = 'All'; 
delete from ld_cvcolumnlist where cvid = @cvid; 
insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,0,'ld_fund_management_commission:managementcommission_no:managementcommission_no:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,1,'ld_fund_management_commission:product_id:product_id:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,2,'ld_fund_management_commission:fund_no:fund_no:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,3,'ld_fund_management_commission:fund_manager:fund_manager:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,4,'ld_fund_management_commission:expensetype:expensetype:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,5,'ld_fund_management_commission:expensedate:expensedate:Mcommission_fieldlabel:D'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,6,'ld_fund_management_commission:amount:amount:Mcommission_fieldlabel:N'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,7,'ld_fund_management_commission:cpstatus:cpstatus:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,8,'ld_fund_management_commission:actualpay:actualpay:Mcommission_fieldlabel:N'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,9,'ld_fund_management_commission:navh:navh:Mcommission_fieldlabel:N'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,10,'ld_fund_management_commission:service_rate:service_rate:Mcommission_fieldlabel:N'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,11,'ld_fund_management_commission:days:days:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,12,'ld_fund_management_commission:vendorid:vendor_id:Mcommission_fieldlabel:V'; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname) 
select @cvid,13,'ld_fund_management_commission:accountid:account_id:Mcommission_fieldlabel:V'; 
delimiter; 
CREATE TABLE IF NOT EXISTS `ld_fund_manager_commissionscf` ( 
`managementcommissionid` int(19) NOT NULL DEFAULT '1', 
PRIMARY KEY (`managementcommissionid`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 
delimiter; 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn) 
select @tabid,'Mcommission','ld_fund_management_commission','managementcommission_no','managementcommissionid','managementcommissionid' 
from dual where not EXISTS(select 1 from ld_entityname where tabid = @tabid 
and modulename ='Mcommission'); 
delimiter; 

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Mcommission'; 
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,78,'get_attachment',1,'Attachment',0,'add',1,1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment'); 
delimiter; 
SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Mcommission'; 
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions; 
INSERT INTO ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-1,2,0,'修改日志' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-1); 
delimiter; 
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions; 
INSERT INTO ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-5,5,0,'打印工具' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-5); 
delimiter; 
update ld_tab set printtab = 1 where `name` = 'Mcommission'; 
delimiter; 
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype) 
select (select max(num_id)+1 from ld_modentity_num),'Mcommission','GLYJ_',1,2,1,'none' 
from dual where not EXISTS(select 1 from ld_modentity_num where semodule = 'Mcommission' 
and prefix ='GLYJ_'); 
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num); 
delimiter; 

call fieldprofile('Mcommission'); 
call getallprofile('Mcommission'); 
call addtabintoprofile('Mcommission',0); 
delimiter; 
select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_profileallpermission(tabid,operation) select @tabid,28 from dual 
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=28); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,1 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=1); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,2 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=2); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,3 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=3); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,4 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=4); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,13 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=13); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,14 from dual where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid AND operation=14); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid); 

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid); 

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid); 

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid); 
select max(ruleid) into @ruleid from ld_def_org_share; 
update ld_def_org_share_seq set id=@ruleid+1 where not exists(select 1 from ld_Def_org_share where tabid=@tabid); 
insert into ld_def_org_share(ruleid,tabid,permission,editstatus) 
select @ruleid+1,@tabid,3,0 from dual where not exists(select 1 from ld_Def_org_share where tabid=@tabid); 
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Management'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smcreatorid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'负责人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Assigned To' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'modifiedby'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter; 
select tabid into @tabid from ld_tab where `name` = 'Management'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid'; 
DELETE from ld_field where tabid=@tabid AND fieldid=@fieldid AND columnname = 'salesorderid'; 
DELETE from ld_tranlabel where tabid=@tabid AND relateid=@fieldid AND fieldlabel in('认购合同','Salesorder');
delimiter;

call DelColumn('ld_fund_management','salesorderid');
delimiter; 

call getallprofile('Management');
delimiter;
call fieldprofile('Management');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smcreatorid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'创建人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'负责人' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Assigned To' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'modifiedby'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Mcommission'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid'; 
delete from ld_field where tabid=@tabid AND fieldid=@fieldid AND columnname = 'salesorderid'; 
delete from ld_tranlabel where tabid=@tabid AND relateid=@fieldid AND fieldlabel in('认购合同','Salesorder');
delimiter; 

call getallprofile('Mcommission');
delimiter;
call fieldprofile('Mcommission');
delimiter;

call DelColumn('ld_fund_management_commission','salesorderid');
delimiter; 

update ld_tab set presence=1 where `name` in ('FundNet','FundReward','FundRewardCommission','Management','Mcommission')
and not exists (select 1 from ld_version where trade='jijin');
delimiter;

-- 基金份额历史
CREATE TABLE IF NOT EXISTS `ld_fund_redemption`(
  `redemption_id` int(19) NOT NULL AUTO_INCREMENT,   
  `salesorder_id` int(19) DEFAULT '0',
  `redemption_time` datetime DEFAULT NULL,
  `redemption_quantity` DECIMAL(25,6) DEFAULT NULL,  
  `redemption_isfree` int(4) DEFAULT '0',
  `redemption_cost` DECIMAL(25,6) DEFAULT NULL,
  `userid`  int(19) DEFAULT '0',
  `redemption_operatetime` datetime DEFAULT NULL,
  PRIMARY KEY (`redemption_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Salesorder';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
SELECT MIN(related_tabid) INTO @related_tabid FROM ld_relatedlists where tabid=@tabid;
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists where tabid=@tabid;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@related_tabid-1,'get_redemption',@sequence+1,'Redemption',0,'add',1,@sequence+1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_redemption');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REDEMPTION','赎回','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTION' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REDEMPTION','Redemption','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUPERADDTION','追加','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SUPERADDTION' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUPERADDTION','Superaddtion','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SUPERADDTION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUBSCRIBE','申购','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SUBSCRIBE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUBSCRIBE','Subscribe','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SUBSCRIBE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REDEMPTIONTIME','赎回日期','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONTIME' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REDEMPTIONQ','Redemption Time','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONTIME' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REDEMPTIONQUANTITY','赎回份额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONQUANTITY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REDEMPTIONQUANTITY','Redemption Quantity','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONQUANTITY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REDEMPTIONISFREE','是否免赎回费用','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONISFREE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REDEMPTIONISFREE','Redemption Is Free','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONISFREE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REDEMPTIONCOST','赎回费用','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONCOST' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REDEMPTIONCOST','Redemption Cost','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'REDEMPTIONCOST' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTLESSZERO','不能小于0','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CANNOTLESSZERO' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTLESSZERO','Can Not Less Zero','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CANNOTLESSZERO' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PORTION','份额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PORTION' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PORTION','Portion','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PORTION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_fund_buyproductquantityhistory`(
  `id` int(19) NOT NULL AUTO_INCREMENT,   
  `salesorderid` int(19) DEFAULT '0',
  `accountid` int(19) DEFAULT '0',
  `productid` int(19) DEFAULT '0',
  `vendorid` int(19) DEFAULT '0',
  `quantity` DECIMAL(25,6) DEFAULT NULL, 
	`operationtype` VARCHAR(100) DEFAULT NULL,  
  `operationtime` datetime DEFAULT NULL,
  `userid`  int(19) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Accounts';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
SELECT MIN(related_tabid) INTO @related_tabid FROM ld_relatedlists where tabid=@tabid;
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists where tabid=@tabid;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@related_tabid-1,'get_buyproductquantity',@sequence+1,'buyProductQuantity',0,'',1,@sequence+1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_buyproductquantity');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUYPRODUCTQUANTITY','已购产品份额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BUYPRODUCTQUANTITY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUYPRODUCTQUANTITY','Buy Product Quantity','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BUYPRODUCTQUANTITY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HOLDQUANTITY','持有份额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'HOLDQUANTITY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HOLDQUANTITY','Hold Quantity','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'HOLDQUANTITY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THELASTDAYOFCHANGE','最新变更日期','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'THELASTDAYOFCHANGE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THELASTDAYOFCHANGE','The Last Day Of Change','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'THELASTDAYOFCHANGE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BOUGHTPRODUCTQUANTITYTRANSACTIONHISTORY','已购产品份额交易历史','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BOUGHTPRODUCTQUANTITYTRANSACTIONHISTORY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BOUGHTPRODUCTQUANTITYTRANSACTIONHISTORY','Buy Product Quantity Transaction History','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BOUGHTPRODUCTQUANTITYTRANSACTIONHISTORY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

delete from ld_systems_deploy where deploy_type=104;

set @roottype=1;
set @deploy_type=110;
select max(sequence) into @seq from ld_systems_deploy where roottype=@roottype;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,@deploy_type,'分配弹出层是否显示所有用户 0:是，1:否','',@seq+1,@roottype,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=@deploy_type);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'分配弹出层是否显示所有用户'
from dual where not exists (select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=@deploy_type);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Allocate pop up layer to display all users'
from dual where not exists (select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=@deploy_type);
set @i=0; 
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=@roottype order by sequence; 
delimiter;

set @roottype=4;
set @deploy_type=111;
select max(sequence) into @seq from ld_systems_deploy where roottype=@roottype;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,@deploy_type,'已购产品份额是否只统计已审批通过的合同订单 0:是，1:否','',@seq+1,@roottype,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0 from dual 
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=@deploy_type);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'已购产品份额是否只统计已审批通过的合同订单' from dual 
where not exists (select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=@deploy_type);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Whether already bought product only statistics has approved salesorder' from dual 
where not exists (select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=@deploy_type);

set @i=0; 
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=@roottype order by sequence; 
delimiter;
 
-- 基金计算
CREATE TABLE if not EXISTS `ld_fund_reward_low_water` (
  `operationtime` datetime DEFAULT NULL,
  `fund_reward_low_waterid` int(19) NOT NULL AUTO_INCREMENT,
  `accured_date` date DEFAULT NULL,
  `accured_result` varchar(500) DEFAULT NULL,
  `success_result` varchar(10) DEFAULT NULL,
  `salesorderid` int(19) DEFAULT NULL,
	`productid` int(19) DEFAULT NULL,
  `module` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`fund_reward_low_waterid`),
  KEY `idx_fund_reward_low_water_module_productid` (`module`,`productid`,`success_result`) USING BTREE,
	KEY `idx_fund_reward_low_water_salesorderid` (salesorderid) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_salesorder','contracttype','varchar',100,'');
call AddColumn('ld_fund_net','accumlative_total_nav','decimal',25,6);
call AddColumn('ld_fund_redemption','description','text','','');
call AddColumn('ld_fund_redemption','redemption_type','varchar','25','manual');
call AddColumn('ld_fund_buyproductquantityhistory','redemption_type','varchar','25','manual');
call AddColumn('ld_fund_buyproductquantityhistory','contracttype','varchar','100','');
call addtableIndex('ld_fund_net','idx_fund_net_productid','product_id');
call addtableIndex('ld_fund_buyproductquantityhistory','idx_productid_fund_byproducthistory','productid');
call addtableIndex('ld_fund_buyproductquantityhistory','idx_salesorderid_fund_buyproducthis','salesorderid');
delimiter;

CREATE TABLE if not EXISTS `ld_fund_reward_low_water` (
  `operationtime` datetime DEFAULT NULL,
  `fund_reward_low_waterid` int(19) NOT NULL AUTO_INCREMENT,
  `accured_date` date DEFAULT NULL,
  `accured_result` varchar(500) DEFAULT NULL,
  `success_result` varchar(10) DEFAULT NULL,
  `salesorderid` int(19) DEFAULT NULL,
	`productid` int(19) DEFAULT NULL,
  `module` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`fund_reward_low_waterid`),
  KEY `idx_fund_reward_low_water_module_productid` (`module`,`productid`,`success_result`) USING BTREE,
	KEY `idx_fund_reward_low_water_salesorderid` (salesorderid) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
select tabid into @tabid from ld_tab where name='fundnet' ;
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_FUNDNET_INFO' ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='accumlative_total_nav');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @tabid,@maxfieldid+1,'accumlative_total_nav','ld_fund_net',1,'accumlativetotal_nav','累计净值',0,0,10,@blockid,1,'V~O',3 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='accumlative_total_nav');

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='accumlative_total_nav';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'累计净值' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,' Accumulated Net' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and relateid=@fieldid and trantable='ld_field');
delimiter;

select  max(fieldid) into @maxfieldid from ld_field ;
select tabid into @tabid from ld_tab where name='salesorder';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contracttype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @tabid,@maxfieldid+1,'contracttype','ld_salesorder',15,'salescontracttype','合同类型',0,0,10,61,1,'V~O',3 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contracttype');

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contracttype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'合同类型' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Contract Type' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and relateid=@fieldid and trantable='ld_field');
delimiter;

CREATE TABLE if not EXISTS`ld_salescontracttype_seq` (
  `id` int(19) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not exists `ld_salescontracttype` (
  `salescontracttypeid` int(19) NOT NULL DEFAULT '0',
  `salescontracttype` varchar(100) DEFAULT NULL,
  `presence` int(1) DEFAULT '1',
  `picklist_valueid` int(19) DEFAULT '0',
  PRIMARY KEY (`salescontracttypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(picklistid) into @maxpicklistid from ld_picklist;
update ld_picklist_seq set id=@maxpicklistid+1  where not exists(select 1 from ld_picklist where name='salescontracttype');
insert into ld_picklist(picklistid,name) select @maxpicklistid+1 ,'salescontracttype' from DUAL
where not exists(select 1 from ld_picklist where name='salescontracttype');
delimiter;

select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_salescontracttype where salescontracttype='A份额'); 
insert into ld_salescontracttype(salescontracttypeid,salescontracttype,picklist_valueid)
select 1,'A份额',@id+1 from dual where not exists(select 1 from ld_salescontracttype where salescontracttype='A份额');
delimiter;
select id into @id from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@id+1 where not exists(select 1 from ld_salescontracttype where salescontracttype='B份额'); 
insert into ld_salescontracttype(salescontracttypeid,salescontracttype,picklist_valueid)
select 2,'B份额',@id+1 from dual where not exists(select 1 from ld_salescontracttype where salescontracttype='B份额');
delimiter;

call fieldprofile('FundNet');
call fieldprofile('salesorder');
call getallprofile('FundNet');
call getallprofile('salesorder');
delimiter;

update ld_field set presence=1 where tabid=22 and columnname='contracttype' and not EXISTS (select 1 from ld_version where trade='jijin');
update ld_systems_deploy set presence=1 where deploy_type=111 and not EXISTS (select 1 from ld_version where trade='jijin');
-- 2016-08-11

call AddColumn('ld_field','is_checkimportfield','int','1', '');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETTINGS_SET','设置参数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SETTINGS_SET' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETTINGS_SET','Parameter setting','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SETTINGS_SET' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHECKIMPORTFIELD','查重字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKIMPORTFIELD' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHECKIMPORTFIELD','Duplicate check field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHECKIMPORTFIELD' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPEAT_IMPORT_MODE','重复时导入方式','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REPEAT_IMPORT_MODE' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPEAT_IMPORT_MODE','Repeat import mode','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='REPEAT_IMPORT_MODE' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORTUPDATE','覆盖','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORTUPDATE' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORTUPDATE','Update','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IMPORTUPDATE' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORTADD','追加','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORTADD' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORTADD','Add','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IMPORTADD' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORTABORT','跳过','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORTABORT' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORTABORT','Abort','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IMPORTABORT' and Labeltype='fixedstr'); 
delimiter; 

update ld_field set is_checkimportfield=1 where tabid=4 AND columnname in('contact_no','lastname','mobile','pphone');
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOCHECKIMPORTFIELD','未设置查重字段，将按照“追加”方式导入数据','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NOCHECKIMPORTFIELD' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOCHECKIMPORTFIELD','No duplicate check field is set, the data will be imported in \"add\" method','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NOCHECKIMPORTFIELD' and Labeltype='jspop'); 
delimiter; 

CALL altercolumn('ld_fund_management','service_rate','service_rate','decimal(35,2)');
CALL altercolumn('ld_fund_management_commission','service_rate','service_rate','decimal(35,2)');
update ld_field set uitype=7,typeofdata='NN~O~35,2' where columnname='service_rate' AND tablename in('ld_fund_management_commission','ld_fund_management');
delimiter;

select  tabid into @tabid from ld_tab where name='Mcommission';
select  fieldid into @fieldid from ld_field where tabid=@tabid and columnname='service_rate';
update ld_tranlabel set fieldlabel='年费率' where trantable='ld_field' and Relateid=@fieldid;
delimiter;

call DelColumn('ld_tab','calendartemplate');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='VendorContactRecords';
update ld_field set displaytype=2 where columnname='product_id' AND tabid=@tabid; 
delimiter;

call AddColumn('ld_fund_management','modifiedby','int','11',NULL);
select tabid into @tabid from ld_tab where `name` = 'Management';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_fund_management',1,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_Management_INFO'),1,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Management';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name = 'FundReward';
delete from ld_field where tabid = @tabid and columnname = 'salesorderid';
delimiter;
select tabid into @tabid from ld_tab where name = 'FundRewardCommission';
delete from ld_field where tabid = @tabid and columnname = 'salesorderid';
delimiter;

alter table ld_fund_net modify profit_reward decimal(25,2);
alter table ld_fund_net modify asset_value decimal(25,2);
delimiter

select tabid into @tabid from ld_tab where name='management';
select max(relation_id) into @max_relation_id from ld_relatedlists ;
update  ld_relatedlists_seq set id=@max_relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and name='getRecalculate_log');
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence)
select @max_relation_id+1,@tabid,0,'getRecalculate_log',2,'Jijin_Log_Detail',0 from dual  
where not exists(select 1 from ld_relatedlists where tabid=@tabid and name='getRecalculate_log');
delimiter;

select tabid into @tabid from ld_tab where name='Mcommission';
select max(relation_id) into @max_relation_id from ld_relatedlists ;
update  ld_relatedlists_seq set id=@max_relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and name='getRecalculate_log');
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence)
select @max_relation_id+1,@tabid,0,'getRecalculate_log',2,'Jijin_Log_Detail',0 from dual  
where not exists(select 1 from ld_relatedlists where tabid=@tabid and name='getRecalculate_log');
delimiter;

select tabid into @tabid from ld_tab where name='FundReward';
select max(relation_id) into @max_relation_id from ld_relatedlists ;
update  ld_relatedlists_seq set id=@max_relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and name='getRecalculate_log');
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence)
select @max_relation_id+1,@tabid,0,'getRecalculate_log',4,'Jijin_Log_Detail',0 from dual  
where not exists(select 1 from ld_relatedlists where tabid=@tabid and name='getRecalculate_log');
delimiter;

UPDATE ld_desk SET fieldlabel='公海分配' WHERE languagetype='zh' and labelbol='LBL_DISTRIBUT_HIGHSEAS' AND Labeltype='jspop' AND fieldlabel = '';
delimiter;
-- 2016-08-12

update ld_desk set fieldlabel='设置呼叫中心类型以及弹屏时匹配的电话号码字段' where labelbol='LBL_PHONESTEWARD_SET_DESCRIPTION' and languagetype='zh' and Labeltype='fixedstr';

call DelColumn('ld_tab','calendartemplate');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','CALLDETAILCALLER','主叫号码','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLDETAILCALLER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','CALLDETAILCALLER','CallerNumber','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLDETAILCALLER' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CALLDETAILCALLEE','被叫号码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CALLDETAILCALLEE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CALLDETAILCALLEE','CalleeNumber','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CALLDETAILCALLEE' and languagetype='en');

select tabid into @tabid from ld_tab where `name`='FundNet';
update ld_relatedlists set actions = 'add' where tabid = 14 and related_tabid = @tabid;
delimiter;

update ld_field set displaytype=1 where columnname='product_id' and tabid in (select tabid from ld_tab where name='VendorContactRecords');
delimiter;

SELECT tabid INTO @tabid from ld_tab where NAME='SendPayment';
UPDATE ld_blocks  SET sequence=1 WHERE tabid=@tabid AND blocklabel='LBL_SendPayment_INFORMATION';
delimiter;

SELECT tabid INTO @tabid1 from ld_tab where NAME='PaymentPlan';
UPDATE ld_blocks  SET sequence=1 WHERE tabid=@tabid1 AND blocklabel='LBL_Cashbill_INFORMATION';
delimiter;

update ld_field set is_checkimportfield=1 where tabid in(select tabid from ld_tab where name='fundnet') 
and (columnname='navdate' or columnname='product_id');
delimiter;
-- 2016-08-23

CREATE TABLE IF NOT EXISTS `ld_commission2paymentscf` ( 
`commission2payment_id` int(11) DEFAULT '0', 
`source_total` decimal(25,6) DEFAULT NULL, 
`due_date` date DEFAULT NULL, 
`received_amount` decimal(25,6) DEFAULT NULL, 
`cashbilldate` date DEFAULT NULL 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_option_module`(
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`tabid` int(11) DEFAULT NULL,
	`option_tabid` int(11) DEFAULT NULL,
	`presence` int(2) DEFAULT 0,
	`default` int(2) DEFAULT NULL,
	`approve_demand` int(2) DEFAULT NULL,
	`sequence` int(11) DEFAULT NULL,
	PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
select tabid into @Potentailtabid from ld_tab where name = 'Potentials';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,2,0,0,1,1 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 2);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,22,0,1,1,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 22);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,37,0,0,1,3 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 37);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,13,0,0,1,4
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 13);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,48,0,0,1,5
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 48);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,47,0,0,1,6
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 47);
delimiter;

select tabid into @tabid from ld_tab where name = 'Commission';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,22,0,1,1,1
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 22);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,37,0,0,1,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 37);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Optionalmodule_Customization','源单类型定制','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_Optionalmodule_Customization' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Optionalmodule_Customization','Optionalmodule customization','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_Optionalmodule_Customization' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Optionalmodule_Customization_Description','设置关联单据可选模块的范围','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_Optionalmodule_Customization_Description' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Optionalmodule_Customization_Description','Setting the optional module of related module','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_Optionalmodule_Customization_Description' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEDEMAND','审批要求','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVEDEMAND' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEDEMAND','Approve Demand','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APPROVEDEMAND' and labeltype='fixedstr');
delimiter;

select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,3,'LBL_Optionalmodule_Customization','servicemigrate.png','LBL_Optionalmodule_Customization_Description','index.php?module=Settings&action=OptionModule&parenttab=Settings.php','19',0
from dual where not exists(select 1 from ld_settings_field where blockid=3 and name = 'LBL_Optionalmodule_Customization');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_select_related_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(50) DEFAULT NULL,
  `selectmodule` varchar(50) DEFAULT NULL,
  `relatedstring` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_related_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fieldid` int(11) DEFAULT NULL,
  `fieldtype` varchar(100) DEFAULT NULL,
  `relatedstring` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'Commission','ServiceContracts','{"detail":[{"table_column_value":"total","fieldname":"source_total"},{"table_column_value":"due_date","fieldname":"due_date"},{"table_column_value":"received_amount","fieldname":"received_amount"}]}' from dual
where not exists(select 1 from ld_select_related_field where module = 'Commission' and selectmodule = 'ServiceContracts');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'Commission','SalesOrder','{"detail":[{"table_column_value":"total","fieldname":"source_total"},{"table_column_value":"signed_data","fieldname":"due_date"},{"table_column_value":"received_amount","fieldname":"received_amount"}]}' from dual
where not exists(select 1 from ld_select_related_field where module = 'Commission' and selectmodule = 'SalesOrder');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'entitytypeid','ld_commission2payment','源单类型','',0,'SelectSource','V~O~',1,20,0,0,0,0,5 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'源单类型' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Optional Module' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'source_total','ld_commission2paymentscf','合同金额','',2,'Text','N~O~25,6',2,20,1,0,0,0,6 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'source_total');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'source_total';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'合同金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Contract amount' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'due_date','ld_commission2paymentscf','签约日期','',2,'Date_Ymd','D~O',3,20,1,0,0,0,6 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'due_date');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'due_date';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'签约日期' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Date of Contract' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'received_amount','ld_commission2paymentscf','已收总额','',2,'Text','N~O~25,6',4,20,1,0,0,0,7 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'received_amount');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'received_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'已收总额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Total receives' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'cashbilldate','ld_commission2paymentscf','最近收款日期','',2,'Date_Ymd','D~O',5,20,1,0,0,0,7 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'cashbilldate');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'cashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'最近收款日期' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Latest date of receipt' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'remark','ld_commission2payment','备注','',0,'TextArea','V~O~',6,60,0,0,0,0,5 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'remark');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'remark';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'备注' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Description' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'rate','ld_commission2payment','比例','',0,'Num','N~O~25,2',7,20,0,0,0,0,8 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'rate');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'rate';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'比例' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Proportion' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'amount','ld_commission2payment','佣金','',0,'Amount','N~O~25,2',8,24,0,2,0,0,8 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'amount');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'amount';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'佣金' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @tabdetailfieldid and trantable = 'ld_tabdetailfield' and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'amount' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @tabdetailfieldid and trantable = 'ld_tabdetailfield' and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'noamount','ld_commission','调整',0,0,'Adjustment','N~O~25,2',9,20,0,0,0,1,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'noamount');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'noamount';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'调整' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Noamount' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

insert into ld_tabdetailfield(tabid,columnname,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @tabid,'total','ld_commission','合计',0,0,'Amount','N~O~25,2',10,20,1,0,0,1,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'total');
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'total';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tabdetailfield',@tabid,@tabdetailfieldid,'合计' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tabdetailfield',@tabid,@tabdetailfieldid,'Total' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype= 'en');
delimiter;

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'amount';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'a*b/100',"{formulavar:[{'lettervar':'a','column':'source_total'},{'lettervar':'b','column':'rate'}]}",0 from DUAL
where not exists(select 1 from ld_tabdetailfield_formula where tabdetailfieldid = @tabdetailfieldid);
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'rate';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'a/b*100',"{formulavar:[{'lettervar':'a','column':'amount'},{'lettervar':'b','column':'source_total'}]}",0 from DUAL
where not exists(select 1 from ld_tabdetailfield_formula where tabdetailfieldid = @tabdetailfieldid);
delimiter;

call insert_tabwithproductview('Commission');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
delete from ld_field where tabid = @tabid and columnname = 'entitytypeid' and uitype = 202;
delimiter;

call AddColumn('ld_expensedetail','entitytype','varchar','25',NULL);
call AddColumn('ld_expensedetail','entitytypeid','int','11',0);
delimiter;

update ld_expensedetail LEFT JOIN ld_expense on ld_expensedetail.expenseid = ld_expense.expenseid
set ld_expensedetail.entitytypeid = ld_expense.Salesorderid,ld_expensedetail.entitytype = ld_expense.entitytype 
where ld_expensedetail.entitytype is NULL;
delimiter;

update ld_expensedetail LEFT JOIN ld_expensedetailscf on ld_expensedetail.expensedetailid = ld_expensedetailscf.expensedetailid
set ld_expensedetail.entitytypeid = ld_expensedetailscf.projectid,ld_expensedetail.entitytype = 'Project' 
where ld_expensedetailscf.projectid > 0;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set columnname = 'entitytypeid',tablename = 'ld_expensedetail',fieldlabel = '源单类型'
where tabid = @tabid and columnname = 'projectid' and tablename = 'ld_expensedetailscf';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid' and tablename = 'ld_expensedetail' LIMIT 1;
update ld_tranlabel set fieldlabel = '源单类型' where tabid = @tabid and relateid = @tabdetailfieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Optional Module' where tabid = @tabid and relateid = @tabdetailfieldid and languagetype = 'en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
update ld_field set searchfieldtype = 0 where tabid = @tabid and columnname in ('ticket_title','ticket_no','smownerid','servicetype','status','priority');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
delete from ld_field where tabid = @tabid and columnname = 'salesorderid' and uitype = 202;
delete from ld_field where tabid = @tabid and columnname = 'potentialid' and uitype = 76;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
select tabid into @option_tabid from ld_tab where `name` = 'Project';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@option_tabid,0,1,1,1 from DUAL
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @option_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'projectid';
update ld_tranlabel set fieldlabel = '源单类型' where tabid = @tabid and Relateid = @tabdetailfieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Optional Module' where tabid = @tabid and Relateid = @tabdetailfieldid and languagetype = 'en';
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
		
		select count(*) into @primaryNum
		from INFORMATION_SCHEMA.KEY_COLUMN_USAGE t
		where t.TABLE_NAME = tablename and COLUMN_NAME = columnname;
		IF @primaryNum = 0 THEN
			
      SET @altersql=CONCAT(' alter table ',tablename, ' change ',columnname,' ',columnname,' int primary key auto_increment');

      PREPARE stalter FROM @altersql;
      EXECUTE stalter;
    END IF;
  end ||
delimiter;
call AddColumn('ld_commission2payment','commission2payment_id','int','11',NOT NULL);
call altercolumnfor_primarykey('ld_commission2payment','commission2payment_id');
delimiter;

insert into ld_commission2paymentscf(commission2payment_id,source_total,due_date,received_amount,cashbilldate)
select commission2payment_id,total,signed_data,received_amount,cashbilldate from ld_salesorder
LEFT JOIN ld_commission2payment on ld_commission2payment.entitytypeid = ld_salesorder.salesorderid
where ld_commission2payment.entitytype = 'SalesOrder' and ld_commission2payment.commission2payment_id not in (
select commission2payment_id from ld_commission2paymentscf);
delimiter;

insert into ld_commission2paymentscf(commission2payment_id,source_total,due_date,received_amount,cashbilldate)
select commission2payment_id,total,due_date,received_amount,cashbill.cashbilldate from ld_servicecontracts
LEFT JOIN ld_commission2payment on ld_commission2payment.entitytypeid = ld_servicecontracts.servicecontractsid
LEFT JOIN (
select ld_cashbill.cashbilldate,ld_cashbill2paymentplan.entitytypeid from ld_cashbill LEFT JOIN ld_cashbill2paymentplan on ld_cashbill2paymentplan.CashBillID = ld_cashbill.cashbillid 
group by cashbilldate order by  cashbilldate desc) as cashbill on cashbill.entitytypeid = ld_servicecontracts.servicecontractsid
where ld_commission2payment.entitytype = 'ServiceContracts' and ld_commission2payment.commission2payment_id not in (
select commission2payment_id from ld_commission2paymentscf);
delimiter;
-- 2016-08-24

set @deploy_value=0;
select deploy_value into @deploy_value from ld_systems_deploy where deploy_type = 68;
update ld_option_module set approve_demand = @deploy_value;
delimiter;

call AddColumn('ld_timesheetdetail','entitytype','varchar','25',NULL);
call AddColumn('ld_timesheetdetail','entitytypeid','int','11',0);
delimiter;

update ld_timesheetdetail set entitytypeid = projectid,entitytype = 'Project' where projectid > 0;
select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
update ld_tabdetailfield set columnname = 'entitytypeid' where tabid = @tabid and columnname = 'projectid';
delimiter;
-- 2016-08-26

call AddColumn('ld_account','longtitude','varchar','200',NULL);
call AddColumn('ld_account','latitude','varchar','200',NULL);
call AddColumn('ld_account','location_address','varchar','200',NULL);
delimiter;
-- 2016-08-29

CREATE TABLE IF NOT EXISTS `ld_tabdetailfield_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

delete from ld_tabdetailfield_seq;
INSERT INTO `ld_tabdetailfield_seq` VALUES ('1');
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);

set @tabid=2;
select block into @blockid from ld_field where tabid=@tabid and columnname='potentialname';
set @tablename='ld_potential';
set @columnname='staydays';
set @fieldname='staydays';
set @zh='阶段停留天数';
set @en='Stay Days';
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

call getallprofile('Potentials');
delimiter;
call fieldprofile('Potentials');
delimiter;

update 
ld_potential a
LEFT JOIN (
	select 
		potentialid,max(lastmodified) as lastmodified
	from ld_potstagehistory 
	where stage<>sales_stage 
	GROUP BY potentialid) b on a.potentialid=b.potentialid
set a.staydays=datediff(NOW(),ifnull(b.lastmodified,a.createdtime));
delimiter;

drop trigger if exists update_potential_staydays; 
delimiter || 
CREATE TRIGGER update_potential_staydays 
BEFORE UPDATE ON ld_potential 
FOR EACH ROW 
BEGIN 

		IF new.sales_stage<>old.sales_stage THEN
			set new.staydays=0;
		END IF;

END || 
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `update_potential_staydays`;
CREATE EVENT `update_potential_staydays`
ON SCHEDULE EVERY 1 DAY STARTS '2016-09-01 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

update 
ld_potential a
LEFT JOIN (
	select 
		potentialid,max(lastmodified) as lastmodified
	from ld_potstagehistory 
	where stage<>sales_stage 
	GROUP BY potentialid) b on a.potentialid=b.potentialid
set a.staydays=datediff(NOW(),ifnull(b.lastmodified,a.createdtime));
delimiter;

select tabid into @tabid from ld_tab where name ='Rate';
select fieldid into @fieldid from ld_field where columnname ='smcreatorid' and tabid =@tabid;
update ld_tranlabel set fieldlabel = '创建人' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set fieldtype = 'Amount' where tabid = @tabid and columnname in ('source_total','received_amount');
delimiter;

call AddColumn('ld_commission2payment','entitytype_value','varchar','100',NULL);
call AddColumn('ld_expensedetail','entitytype_value','varchar','100',NULL);
call AddColumn('ld_timesheetdetail','entitytype_value','varchar','100',NULL);
delimiter;
-- 2016-09-01

select fieldid into @fieldid from ld_field where tabid=2 and columnname='staydays';
update ld_tranlabel set fieldlabel='N天未推进' where trantable='ld_field' and Relateid=@fieldid and languagetype='zh';
delimiter;

update ld_field set uitype=7 where columnname='nolinkdays' and tabid=6;
update ld_field set uitype=7 where columnname='staydays' and tabid=2;

alter table ld_customreport_info modify report_template varchar(255);
alter table ld_customreport_info modify report_url text;

select tabid into @tabid from ld_tab where name = 'Invoice';
select tabid into @OutboundOrder_tabid from ld_tab where name = 'OutboundOrder';
select tabid into @Stock_tabid from ld_tab where name = 'Stock';
select tabid into @PaymentPlan_tabid from ld_tab where name = 'PaymentPlan';
select tabid into @PurchaseInvoice_tabid from ld_tab where name = 'PurchaseInvoice';
select tabid into @SendPayment_tabid from ld_tab where name = 'SendPayment';
select deploy_value into @approve_demand from ld_systems_deploy where deploy_type = 68;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,22,0,1,@approve_demand,1 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 22);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,37,0,0,@approve_demand,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 37);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@OutboundOrder_tabid,0,0,@approve_demand,3
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @OutboundOrder_tabid);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,21,0,1,@approve_demand,1 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 21);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@Stock_tabid,0,0,@approve_demand,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @Stock_tabid);
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,22,0,1,@approve_demand,1
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 22);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,37,0,0,@approve_demand,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 37);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,23,0,0,@approve_demand,3
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 23);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@PaymentPlan_tabid,0,0,@approve_demand,4
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @PaymentPlan_tabid);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@OutboundOrder_tabid,0,0,@approve_demand,5
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @OutboundOrder_tabid);
delimiter;

select tabid into @tabid from ld_tab where name = 'SendCashBill';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,21,0,1,@approve_demand,1 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 21);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@PurchaseInvoice_tabid,0,0,@approve_demand,2
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @PurchaseInvoice_tabid);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@Stock_tabid,0,0,@approve_demand,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @Stock_tabid);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@SendPayment_tabid,0,0,@approve_demand,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @SendPayment_tabid);
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,22,0,1,@approve_demand,1 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 22);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,37,0,0,@approve_demand,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 37);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,23,0,0,@approve_demand,3
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 23);
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,21,0,1,@approve_demand,1 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 21);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@PurchaseInvoice_tabid,0,0,@approve_demand,2
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @PurchaseInvoice_tabid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Optionalmodule_Customization','源单类型定制','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_Optionalmodule_Customization' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Optionalmodule_Customization','Optionalmodule customization','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_Optionalmodule_Customization' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Optionalmodule_Customization_Description','设置关联单据可选模块的范围','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_Optionalmodule_Customization_Description' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Optionalmodule_Customization_Description','Setting the optional module of related module','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_Optionalmodule_Customization_Description' and labeltype='fixedstr');
delimiter;

update ld_producttoolfield set columnname = 'entitytypeid' where columnname='entitytype' and uitype in(200,201,202);
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_producttoolfield set sequence = sequence-1 where sequence<@sequence and tabid = @tabid;
update ld_producttoolfield set sequence = sequence+1 where sequence>@sequence and tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'entitytype','源单类型','',0,204,'V~O~100',@sequence-1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='entitytype' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'源单类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Entity Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'contractid','合同信息','',0,205,'V~O~100',@sequence+1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='contractid' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'contractid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'合同信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Contract Info'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

set @i=0; 
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence; 
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
update ld_field set uitype = 202 where uitype = 200 and tabid = @tabid;
select fieldid into @fieldid from ld_field where uitype = 202 and tabid = @tabid;
update ld_tranlabel set fieldlabel = '选择源单' where trantable = 'ld_field' and 
tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Select Source' where trantable = 'ld_field' and 
tabid = @tabid and Relateid = @fieldid and languagetype = 'en';

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_producttoolfield set sequence = sequence-1 where sequence<@sequence and tabid = @tabid;
update ld_producttoolfield set sequence = sequence+1 where sequence>@sequence and tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'entitytype','源单类型','',0,204,'V~O~100',@sequence-1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='entitytype' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'源单类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Entity Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'contractid','合同信息','',0,205,'V~O~100',@sequence+1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='contractid' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'contractid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'合同信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Contract Info'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

set @i=0; 
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence; 
delimiter;


select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
update ld_field set uitype = 202 where uitype = 201 and tabid = @tabid;
select fieldid into @fieldid from ld_field where uitype = 202 and tabid = @tabid;
update ld_tranlabel set fieldlabel = '选择源单' where trantable = 'ld_field' and 
tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Select Source' where trantable = 'ld_field' and 
tabid = @tabid and Relateid = @fieldid and languagetype = 'en';

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_producttoolfield set sequence = sequence-1 where sequence<@sequence and tabid = @tabid;
update ld_producttoolfield set sequence = sequence+1 where sequence>@sequence and tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'entitytype','源单类型','',0,204,'V~O~100',@sequence-1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='entitytype' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'源单类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Entity Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'contractid','合同信息','',0,205,'V~O~100',@sequence+1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='contractid' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'contractid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'合同信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Contract Info'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

set @i=0; 
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence; 
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
update ld_field set uitype = 202 where uitype = 201 and tabid = @tabid;
select fieldid into @fieldid from ld_field where uitype = 202 and tabid = @tabid;
update ld_tranlabel set fieldlabel = '选择源单' where trantable = 'ld_field' and 
tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Select Source' where trantable = 'ld_field' and 
tabid = @tabid and Relateid = @fieldid and languagetype = 'en';

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_producttoolfield set sequence = sequence-1 where sequence<@sequence and tabid = @tabid;
update ld_producttoolfield set sequence = sequence+1 where sequence>@sequence and tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'entitytype','源单类型','',0,204,'V~O~100',@sequence-1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='entitytype' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'源单类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Entity Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,
tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid+1,'contractid','合同信息','',0,205,'V~O~100',@sequence+1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,1
from dual where not exists(select 1 from ld_producttoolfield where columnname='contractid' and tabid = @tabid);

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid = @tabid and columnname = 'contractid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'合同信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Contract Info'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_producttoolfield' and tabid = @tabid and relateid=@fieldid);
delimiter;

set @i=0; 
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence; 
delimiter;

CALL AddColumn('ld_inventoryproductrel','contractid','int','19',0);
CALL AddColumn('ld_inventoryproductrel','haveinvoicecount','decimal','25,8',0);
CALL AddColumn('ld_inventoryproductrel','balanceinvoicecount','decimal','25,8',0);
alter table ld_inventoryproductrel modify haveinvoicecount decimal(25,8);
alter table ld_inventoryproductrel modify balanceinvoicecount decimal(25,8);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVEINVOICECOUNT','已开票数量','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HAVEINVOICECOUNT' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVEINVOICECOUNT','Has billing number','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HAVEINVOICECOUNT' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BALANCEINVOICECOUNT','未开票数量','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BALANCEINVOICECOUNT' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BALANCEINVOICECOUNT','No billing number','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BALANCEINVOICECOUNT' and labeltype='fixedstr');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set contractid = entitytypeid where ld_crmentity.setype = 'Invoice' and entitytype in('SalesOrder','ServiceContracts') and entitytypeid > 0;
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set contractid = entitytypeid where ld_crmentity.setype = 'PurchaseInvoice' and entitytype = 'PurchaseOrder' and entitytypeid > 0;
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set contractid = entitytypeid,entitytype = 'SalesOrder' where ld_crmentity.setype = 'OutboundOrder' and entitytypeid > 0;
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set contractid = entitytypeid where ld_crmentity.setype = 'Stock' and entitytype = 'PurchaseOrder' and entitytypeid > 0;
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set balanceinvoicecount = quantity where ld_crmentity.setype in ('OutboundOrder','Stock','SalesOrder','ServiceContracts','PurchaseOrder') 
and balanceinvoicecount <=0 and haveinvoicecount <=0;
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set balanceoutproductcount = quantity where ld_crmentity.setype in ('Invoice','ServiceContracts') 
and balanceoutproductcount <=0 and haveoutproductcount <=0;
delimiter;

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set balancepurchasecount = quantity where ld_crmentity.setype in ('PurchaseInvoice') 
and balancepurchasecount <=0 and havepurchasecount <=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ATLEASTONESOURCESINGLEMODULEISENDALED','至少有一个源单模块为启用，保存失败','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'ATLEASTONESOURCESINGLEMODULEISENDALED' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ATLEASTONESOURCESINGLEMODULEISENDALED','At least one source single module is enabled, save failed','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'ATLEASTONESOURCESINGLEMODULEISENDALED' and labeltype = 'jspop');
delimiter;

update ld_systems_deploy set inputvalue = '[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Vendors"}]'
where deploy_type = 109;
delimiter;
-- 2016-09-04

call AddColumn('ld_customreport_folder','systemdefault','int','4',NULL);
call AddColumn('ld_customreport_folder','visible','int','4',NULL);
CALL AddColumn('ld_customreport_folder','description','varchar','200','NULL');

insert into ld_customreport_folder(folder_name,sequence,systemdefault,visible,description)
select '数据报表(Tabular Data Reports)',0,1,0,'Tabular Data Reports' from dual 
where not exists (select 1 from ld_customreport_folder where (description='Tabular Data Reports' or folder_name='报表库(Report Library)') and systemdefault=1);

call AddColumn('ld_customreport_info','systemdefault','int','4',NULL);
call AddColumn('ld_customreport_info','presence','int','4',NULL);

set @folder_id=0;
set @report_id=0;
set @seq=0;
select id into @folder_id from ld_customreport_folder where systemdefault=1 order by id limit 1;
select max(report_id) into @report_id from ld_customreport_info;
select max(sequence) into @seq from ld_customreport_info where folder_id=@folder_id;

insert into ld_customreport_info(report_id,folder_id,report_name,report_describe,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence)
select @report_id+1,@folder_id,'平均单值气泡图表',NULL,'template','default_salesorder_avg_amount.mrt',NULL,@seq+1,0,1,0 from dual 
where not exists (select 1 from ld_customreport_info where report_template='default_salesorder_avg_amount.mrt');

update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_inventoryproductrel INNER JOIN(select ld_crmentity.crmid from ld_inventoryproductrel LEFT JOIN ld_crmentity on id = crmid
where setype in ('SalesOrder','ServiceContracts')) as tmp on tmp.crmid=ld_inventoryproductrel.id 
set ld_inventoryproductrel.contractid = ld_inventoryproductrel.id;
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceReturn';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,0,'get_SharedUsers',1,'SharedUsers',0,'share',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_SharedUsers');
delimiter;
-- 2016-9-06

select tabid into @tabid from ld_tab where `name`='Customreport';
update ld_tranlabel set fieldlabel='报表库' where tabid=@tabid and trantable='ld_tab' and languagetype='zh' and fieldlabel='定制报表';
update ld_tranlabel set fieldlabel='Report Library' where tabid=@tabid and trantable='ld_tab' and languagetype='en' and fieldlabel='Customreport';
delimiter;

call AddColumn('ld_customreport_info','setype','varchar','100',NULL);
delimiter;


set @folder_id=0;
set @report_id=0;
set @seq=0;
set @report_name=NULL;
set @setype='Accounts';
set @report_template='default_account_category_distribution.mrt';


select id into @folder_id from ld_customreport_folder where systemdefault=1 order by id limit 1;
select max(report_id) into @report_id from ld_customreport_info;
select max(sequence) into @seq from ld_customreport_info where folder_id=@folder_id;
select 
concat(b.fieldlabel,'分布统计') into @report_name
from ld_field a
LEFT JOIN ld_tranlabel b on b.trantable='ld_field' and b.languagetype='zh' and b.Relateid=a.fieldid
where a.tabid=6 and a.columnname='account_type' LIMIT 1;

insert into ld_customreport_info(report_id,folder_id,report_name,report_describe,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype)
select @report_id+1,@folder_id,@report_name,NULL,'template',@report_template,NULL,@seq+1,0,1,0,@setype from dual 
where not exists (select 1 from ld_customreport_info where report_template=@report_template);

update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;
call AddColumn('ld_users', 'wx_userid', 'varchar', '255', NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_USERLOGIN_ROLE';
SELECT sequence into @sequence from ld_field WHERE block=77 and tabid = @tabid and columnname='level';
set @i=@sequence+1;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid AND block=77 and sequence > @sequence order by sequence asc;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'wx_userid','ld_users',2,'wx_userid','微信企业号用户ID',@blockid,1,0,'V~O',2,@sequence+1,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'wx_userid');
set @j=@sequence;
update ld_field set sequence=(@j:=@j+1) where tabid = @tabid AND block=77 and sequence > @sequence order by sequence asc;
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'wx_userid';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'微信企业号通讯录账号' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'WeiXinID' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EDITPROCESS','编辑流程','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EDITPROCESS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EDITPROCESS','Edit Process ','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EDITPROCESS' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HIDDENFOLDER','隐藏文件夹','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='HIDDENFOLDER' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HIDDENFOLDER','Hidden Folder','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='HIDDENFOLDER' and Labeltype='fixedstr'); 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHOWHIDDENFOLDER','显示隐藏文件夹','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SHOWHIDDENFOLDER' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHOWHIDDENFOLDER','Show Hidden Folder','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SHOWHIDDENFOLDER' and Labeltype='fixedstr'); 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HIDDEN','隐藏','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='HIDDEN' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HIDDEN','Hidden','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='HIDDEN' and Labeltype='fixedstr'); 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHOWHIDDENREPORT','显示隐藏报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SHOWHIDDENREPORT' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHOWHIDDENREPORT','Show Hidden Reort','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SHOWHIDDENREPORT' and Labeltype='fixedstr'); 
delimiter; 
-- 2016-09-09

update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set contractid = entitytypeid where ld_crmentity.setype = 'PurchaseOrder' and entitytype = 'SalesOrder' and entitytypeid > 0;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select tabid into @related_tabid from ld_tab where `name` = 'CashBill';
select MAX(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,@related_tabid,'get_cashbill',5,'CashBill',0,'add',1,11 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select MAX(relation_id) from ld_relatedlists);
delimiter;

UPDATE ld_field SET is_checkimportfield = 1 WHERE tabid = (select tabid from ld_tab where `name`='ContactRecords' ) AND columnname IN ('subject');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHECKIMPORTFIELDNOMAPPING','查重字段','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKIMPORTFIELDNOMAPPING' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHECKIMPORTFIELDNOMAPPING','Duplicate check field','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHECKIMPORTFIELDNOMAPPING' and Labeltype='jspop'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOTMAPPEDIMPORTFAILED','未映射，导入失败！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NOTMAPPEDIMPORTFAILED' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOTMAPPEDIMPORTFAILED','s not mapped, import failed!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NOTMAPPEDIMPORTFAILED' and Labeltype='jspop');
delimiter;  

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SELECTUPTOTHREE','最多选择三个！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTUPTOTHREE' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SELECTUPTOTHREE','Select up three','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SELECTUPTOTHREE' and Labeltype='jspop'); 
delimiter; 

update ld_desk set fieldlabel='请选择以.xls或.xlsx为扩展名的文件' where labelbol='PLEASESELECTEXCEL2003FILE' AND languagetype='zh' AND Labeltype='jspop';
update ld_desk set fieldlabel='please Select the file for the .xls or .xlsx extension' where labelbol='PLEASESELECTEXCEL2003FILE' AND languagetype='en' AND Labeltype='jspop';
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONTACTCHECKIMPORTFIELD','联系人查重字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CONTACTCHECKIMPORTFIELD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONTACTCHECKIMPORTFIELD','Duplicate check field of contact','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CONTACTCHECKIMPORTFIELD' and Labeltype='fixedstr');
delimiter; 

SELECT fieldname into @fieldname from ld_entityname where tabid=6;
update ld_field SET is_checkimportfield=1 where columnname in(@fieldname,'accountname','account_no','phone') AND tabid=6;
delimiter; 

SELECT fieldname into @fieldname from ld_entityname where tabid=4;
update ld_field SET is_checkimportfield=1 where columnname in(@fieldname,'contact_no','pphone','mobile') AND tabid=4;
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHECKFIELDOFPRODUCTS','产品查重字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKFIELDOFPRODUCTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHECKFIELDOFPRODUCTS','Duplicate check field of product','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHECKFIELDOFPRODUCTS' and Labeltype='fixedstr');
delimiter; 

SELECT tabid into @tabid from ld_tab where `name`='ServiceContracts';
SELECT fieldname into @fieldname from ld_entityname where modulename='ServiceContracts';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname=@fieldname;
update ld_field SET is_checkimportfield=1 where presence<>1 AND fieldid=@fieldid AND tabid=@tabid;
update ld_field SET is_checkimportfield=1 where presence<>1 AND columnname='subject' AND tabid=@tabid;

call AddColumn('ld_producttoolfield','is_checkimportfield','int','1', '');
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='SalesOrder';
SELECT fieldname into @fieldname from ld_entityname where modulename='SalesOrder';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname=@fieldname;
update ld_field SET is_checkimportfield=1 where presence<>1 AND fieldid=@fieldid AND tabid=@tabid;
update ld_field SET is_checkimportfield=1 where presence<>1 AND columnname='subject' AND tabid=@tabid;


SELECT tabid into @tabid from ld_tab where `name`='SalesOrder';
update ld_producttoolfield set is_checkimportfield=1 where columnname in('productname','productsheet','product_no') AND tabid=@tabid;

SELECT tabid into @tabid from ld_tab where `name`='Quotes';
SELECT fieldname into @fieldname from ld_entityname where modulename='Quotes';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname=@fieldname;
update ld_field SET is_checkimportfield=1 where presence<>1 AND fieldid=@fieldid AND tabid=@tabid;
update ld_field SET is_checkimportfield=1 where presence<>1 AND columnname='subject' AND tabid=@tabid;

SELECT tabid into @tabid from ld_tab where `name`='SalesOrder';
update ld_producttoolfield set is_checkimportfield=1 where columnname in('productname','productsheet','product_no') AND tabid=@tabid;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COVERAGETOCONTINUE','覆盖导入将把已存在的单据以当前模板为准进行更新，请确认是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='COVERAGETOCONTINUE' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COVERAGETOCONTINUE','Cover the import will be the existing documents to the current template for updating, please confirm whether to continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='COVERAGETOCONTINUE' and Labeltype='jspop'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select tabid into @related_tabid from ld_tab where `name` = 'CashBill';
select MAX(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,@related_tabid,'get_cashbill',@sequence+1,'CashBill',0,'add',1,@sequence+1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select MAX(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select tabid into @related_tabid from ld_tab where `name` = 'SendCashBill';
select MAX(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,@related_tabid,'get_SendCashBill',@sequence+1,'SendCashBill',0,'add',1,@sequence+1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select MAX(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select tabid into @related_tabid from ld_tab where `name` = 'SendCashBill';
select MAX(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,@related_tabid,'get_SendCashBill',@sequence+1,'SendCashBill',0,'add',1,@sequence+1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select MAX(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set presence = 0 where tabid = @tabid and columnname = 'entitytypeid';
delimiter;
-- 2016-09-12

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select tabid into @related_tabid from ld_tab where `name` = 'CashBill';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建收款单' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select tabid into @related_tabid from ld_tab where `name` = 'CashBill';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建收款单' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select tabid into @related_tabid from ld_tab where `name` = 'SendCashBill';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建付款单' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select tabid into @related_tabid from ld_tab where `name` = 'SendCashBill';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建付款单' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
select tabid into @related_tabid from ld_tab where `name` = 'SendCashBill';
update ld_quickactions set sequence = sequence + 1 where tabid = @tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,0,0,'创建付款单' from dual
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @tabid  order by sequence;
delimiter;

update ld_desk set fieldlabel ='提醒时间（参考字段）' where labelbol='REMINDTIME' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SOURCETYPE','源单类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOURCETYPE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SOURCETYPE','Entity Type','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOURCETYPE' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='sendcashbill';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_SendCashBill_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='subtotal');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'subtotal','ld_sendcashbill',1,71,'hdnSubTotal','小计',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='subtotal');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='subtotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'小计' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'sub total' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

CREATE TABLE if not EXISTS `ld_option_showheader_label` (
  `id` int(19) NOT NULL auto_increment,
  `optionshowtabheader_id` int(19) default NULL,
  `fieldlabel` varchar(100) default NULL,
  `columnname` varchar(100) default NULL,
  `sequence` int(11) default '0' COMMENT '1',
  `column_type` varchar(50) default NULL COMMENT 'main',
  `label_from` varchar(100) default 'desk',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists`ld_option_showtableheader` (
  `id` int(19) NOT NULL auto_increment,
  `module` varchar(100) default NULL,
  `selectmodule` varchar(100) default NULL,
  `type` varchar(50) default NULL,
  `columns` text,
  `condition_where` text,
  `from_clause` text,
  `special_column_op` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_servicecontracts','cashbilldate','date',8,'');
delimiter;
call AddColumn('ld_paymentplan','receivable_balance','decimal',20,'');
delimiter;

update ld_paymentplan set receivable_balance=amount-ifnull(actualamount,0);
delimiter;

call AddColumn('ld_invoice','receivable_balance','decimal',20,'');
delimiter;
call AddColumn('ld_invoice','received_amount','decimal',20,'');
delimiter;

update ld_invoice set receivable_balance=total-ifnull(received_amount,0);
delimiter;

call AddColumn('ld_outboundorder','receivable_balance','decimal',20,'');
delimiter;

call AddColumn('ld_outboundorder','received_amount','decimal',20,'');
delimiter;

update ld_outboundorder set receivable_balance=total-ifnull(received_amount,0);
delimiter;

select tabid into @tabid from ld_tab where name='paymentplan';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_PaymentPlan_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'receivable_balance','ld_paymentplan',1,71,'receivable_balance','应收余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='receivable_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应收余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Receivable Balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='invoice';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_INVOICE_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'receivable_balance','ld_invoice',1,71,'receivable_balance','应收余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='receivable_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应收余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Receivable Balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='received_amount');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'received_amount','ld_invoice',1,71,'received_amount','已收总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='received_amount');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='received_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已收总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Received Amount' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='outboundorder';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_OUT_INFO';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'receivable_balance','ld_outboundorder',1,71,'receivable_balance','应收余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='receivable_balance');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='receivable_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应收余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Receivable Balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='received_amount');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'received_amount','ld_outboundorder',1,71,'received_amount','已收总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='received_amount');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='received_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已收总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Received Amount' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'Invoice','SalesOrder','source','[{"modulename":"SalesOrder","select_column":"href_columnname,signed_data,total,invoicetotal,invoicedate,href_columnname,received_amount,cashbilldate"}]',' ld_salesorder.salesorderid in({param1})'
,'[{"tablename":"fun:getInvoice_date_amount","othertablename":"ld_invoice", "jointype":"left","joincontent":"ld_invoice.entitytypeid=ld_salesorder.salesorderid"}]','[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"SalesOrder"}]' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='Invoice' and selectmodule='salesorder' and type='source') ;

select id into @id from ld_option_showtableheader where module='Invoice' and selectmodule='salesorder' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'SalesOrder:signed_data','signed_data',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='signed_data'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'HASBILLINGAMOUNT','invoicetotal',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicetotal'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'THENEWINVOICEDATE','invoicedate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicedate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',8,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'Invoice','ServiceContracts','source','[{"modulename":"ServiceContracts","select_column":"href_columnname,due_date,total,invoicetotal,invoicedate,href_columnname,received_amount,cashbilldate"}]',' ld_servicecontracts.servicecontractsid in({param1})'
,'[{"tablename":"fun:getInvoice_date_amount","othertablename":"ld_invoice", "jointype":"left","joincontent":"ld_invoice.entitytypeid=ld_servicecontracts.servicecontractsid"}]','[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"ServiceContracts"}]' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='Invoice' and selectmodule='ServiceContracts' and type='source') ;

select id into @id from ld_option_showtableheader where module='Invoice' and selectmodule='ServiceContracts' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'ServiceContracts:due_date','due_date',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='due_date'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'HASBILLINGAMOUNT','invoicetotal',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicetotal'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'THENEWINVOICEDATE','invoicedate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicedate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',8,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );

delimiter;


insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'Invoice','OutboundOrder','source_detail_multi','[{"modulename":"OutboundOrder","select_column":"href_columnname,outdate,total,invoicetotal,invoicedate"},{"getsourcesql":"select contractid as sourceid,entitytype as sourcemodule from ld_inventoryproductrel where id={param1} and entitytypeid>0","Choosemodule":"ServiceContracts,SalesOrder","Detail":[{"modulename":"SalesOrder","columnname":"href_columnname,received_amount,cashbilldate"},{"modulename":"ServiceContracts","columnname":"href_columnname,received_amount,cashbilldate"}]}]',' ld_outboundorder.out_id in({param1}) '
,'[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_outboundorder.out_id"},{"tablename":"fun:getInvoice_date_amount","othertablename":"ld_invoice", "jointype":"left","joincontent":"ld_invoice.entitytypeid=ld_outboundorder.out_id"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]','[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"SalesOrder"}]' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='Invoice' and selectmodule='OutboundOrder' and type='source_detail_multi') ;

select id into @id from ld_option_showtableheader where module='Invoice' and selectmodule='OutboundOrder' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'OutboundOrder:outdate','outdate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='outdate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'HASBILLINGAMOUNT','invoicetotal',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicetotal'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'THENEWINVOICEDATE','invoicedate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicedate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAIDTOTALAMOUNT','已付总额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAIDTOTALAMOUNT' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAIDTOTALAMOUNT','Total amount paid','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAIDTOTALAMOUNT' and languagetype='en' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAYABLEBALANCE','应付余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAYABLEBALANCE' and languagetype='zh' and Labeltype='fixedstr');

call AddColumn('ld_purchaseorder','pay_balance','decimal','25,2',0);
delimiter;

call AddColumn('ld_purchaseorder','pay_amount','decimal','25,2',0);
delimiter;

call AddColumn('ld_purchaseorder','sendcashbilldate','date',8,'');
delimiter;

select  tabid into @tabid  from ld_tab  where name='purchaseorder';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_PO_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_balance','ld_purchaseorder',1,71,'pay_balance','应付余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应收余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Payable balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_amount','ld_purchaseorder',1,71,'pay_amount','已付总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已付总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Total amount paid' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);


select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sendcashbilldate');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'sendcashbilldate','ld_purchaseorder',1,5,'sendcashbilldate','最新付款日期',0,0,26, @blockid,2,'D~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sendcashbilldate');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='sendcashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'最新付款日期' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'New pay date' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAIDTOTALAMOUNT','已付总额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAIDTOTALAMOUNT' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAIDTOTALAMOUNT','Total amount paid','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAIDTOTALAMOUNT' and languagetype='en' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAYABLEBALANCE','应付余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAYABLEBALANCE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAYABLEBALANCE','Payable balance','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PAYABLEBALANCE' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'PurchaseInvoice','PurchaseOrder','source','[{"modulename":"PurchaseOrder","select_column":"href_columnname,signed_data,total,invoicetotal,invoicedate,href_columnname,pay_amount,sendcashbilldate"}]',' ld_purchaseorder.purchaseorderid in({param1})'
,'[{"tablename":"fun:getPurchaseInvoice_date_amount","othertablename":"ld_purchaseinvoice", "jointype":"left","joincontent":"ld_purchaseinvoice.entitytypeid=ld_purchaseorder.purchaseorderid"}]','[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"PurchaseOrder"}]' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='PurchaseInvoice' and selectmodule='PurchaseOrder' and type='source') ;

select id into @id from ld_option_showtableheader where module='PurchaseInvoice' and selectmodule='PurchaseOrder' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PurchaseOrder:signed_data','signed_data',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='signed_data'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'HASBILLINGAMOUNT','invoicetotal',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicetotal'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'THENEWINVOICEDATE','invoicedate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicedate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PAIDTOTALAMOUNT','pay_amount',7,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFPAYMENT','sendcashbilldate',8,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  );
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'PurchaseInvoice','Stock','source_detail_multi','[{"modulename":"Stock","select_column":"href_columnname,createdate,total,invoicetotal,invoicedate"},{"getsourcesql":"select contractid as sourceid,entitytype as sourcemodule from ld_inventoryproductrel where id={param1} and entitytypeid>0","Choosemodule":"PurchaseOrder","Detail":[{"modulename":"PurchaseOrder","columnname":"href_columnname,pay_amount,sendcashbilldate"}]}]',' ld_stock.stock_id in({param1})'
,'[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_stock.stock_id"},{"tablename":"fun:getPurchaseInvoice_date_amount","othertablename":"ld_purchaseinvoice", "jointype":"left","joincontent":"ld_purchaseinvoice.entitytypeid=ld_stock.stock_id"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]','[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"PurchaseOrder"}]' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='PurchaseInvoice' and selectmodule='Stock' and type='source_detail_multi');

select id into @id from ld_option_showtableheader where module='PurchaseInvoice' and selectmodule='Stock' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'Stock:createdate','createdate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='createdate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'HASBILLINGAMOUNT','invoicetotal',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicetotal'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'THENEWINVOICEDATE','invoicedate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicedate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PAIDTOTALAMOUNT','pay_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFPAYMENT','sendcashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  );
delimiter;

select tabid into @tabid from ld_tab where name = 'SendCashBill';
update ld_field set uitype = 202 where uitype = 201 and tabid = @tabid;
delete from ld_field  where tabid=@tabid and columnname='purchaseorder_id';
select fieldid into @fieldid from ld_field where uitype = 202 and tabid = @tabid  ;
update ld_tranlabel set fieldlabel = '选择源单' where trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Select Source' where trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid and languagetype = 'en';
delimiter;

CALL AddColumn('ld_sendcashbill2payment','entitytypeid','int','11',0);
delimiter;
CALL AddColumn('ld_sendcashbill2payment','entitytype','varchar','25','');
delimiter;

update ld_sendcashbill2payment set entitytypeid=purchaseorder_id,entitytype='PurchaseOrder' where purchaseorder_id>0;
delimiter;

call AddColumn('ld_sendpayment','pay_balance','decimal',20,'');
update ld_sendpayment set pay_balance=amount-ifnull(actualamount,0);
select tabid into @tabid from ld_tab where name='sendpayment';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_SendPayment_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_balance','ld_sendpayment',1,71,'pay_balance','应付余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应付余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Payable Balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

delete from ld_desk where labelbol='LATESTINVOICEDATE' and Labeltype='fixedstr';
delete from ld_desk where labelbol='TOTALINVOICE' and labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTRACTINFO','合同信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTINFO' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTRACTINFO',' Contract info','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTINFO' and labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTRACTRECIVETOTAL','合同已收总额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTRECIVETOTAL' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTRACTRECIVETOTAL','Total contract amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTRECIVETOTAL' and labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_option_showheader_label','modulename','varchar',100,'');
delimiter;

call AddColumn('ld_invoice','cashbilldate','date',8,'');
delimiter;

select  tabid into @tabid  from ld_tab  where name='Invoice';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_INVOICE_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cashbilldate');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'cashbilldate','ld_invoice',1,5,'cashbilldate','收款日期',0,0,26, @blockid,2,'D~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cashbilldate');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='cashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'收款日期' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Collection Date' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

call AddColumn('ld_outboundorder','cashbilldate','date',8,'');
delimiter;

select  tabid into @tabid  from ld_tab  where name='OutboundOrder';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_OUT_INFO';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cashbilldate');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'cashbilldate','ld_outboundorder',1,5,'cashbilldate','收款日期',0,0,26, @blockid,2,'D~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cashbilldate');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='cashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'收款日期' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Collection Date' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'CashBill','SalesOrder','source','[{"modulename":"SalesOrder","select_column":"href_columnname,signed_data,total,received_amount,cashbilldate,href_columnname,received_amount,cashbilldate"}]',' ld_salesorder.salesorderid in({param1})'
,'','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='CashBill' and selectmodule='SalesOrder' and type='source') ;

select id into @id from ld_option_showtableheader where module='CashBill' and selectmodule='SalesOrder' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'SalesOrder:signed_data','signed_data',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='signed_data'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'TOTALRECEIVES','received_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount' and sequence='7' );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',8,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate' and sequence='8' );
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'CashBill','ServiceContracts','source','[{"modulename":"ServiceContracts","select_column":"href_columnname,due_date,total,received_amount,cashbilldate,href_columnname,received_amount,cashbilldate"}]',' ld_servicecontracts.servicecontractsid in({param1})'
,'','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='CashBill' and selectmodule='ServiceContracts' and type='source') ;

select id into @id from ld_option_showtableheader where module='CashBill' and selectmodule='ServiceContracts' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'ServiceContracts:due_date','due_date',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='due_date'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'TOTALRECEIVES','received_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount' and sequence='7' );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',8,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  and sequence='8');
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'CashBill','OutboundOrder','source_detail_multi','[{"modulename":"OutboundOrder","select_column":"href_columnname,outdate,total,received_amount,cashbilldate"},{"getsourcesql":"select contractid as sourceid,entitytype as sourcemodule from ld_inventoryproductrel where id={param1} and entitytypeid>0","Choosemodule":"ServiceContracts,SalesOrder","Detail":[{"modulename":"SalesOrder","columnname":"href_columnname,received_amount,cashbilldate"},{"modulename":"ServiceContracts","columnname":"href_columnname,received_amount,cashbilldate"}]}]',' ld_outboundorder.out_id in({param1})'
,'[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_outboundorder.out_id"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='CashBill' and selectmodule='OutboundOrder' and type='source_detail_multi') ;

select id into @id from ld_option_showtableheader where module='CashBill' and selectmodule='OutboundOrder' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'OutboundOrder:outdate','outdate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='outdate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'TOTALRECEIVES','received_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  and column_type='source_detail_multi' );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFRECEIPT','cashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate' and column_type='source_detail_multi' );
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'CashBill','PaymentPlan','source_detail_multi','[{"modulename":"PaymentPlan","select_column":"href_columnname,plandate,amount,actualamount,actualdate"},{"getsourcesql":"select entitytypeid as sourceid,entitytype as sourcemodule from ld_paymentplan where paymentplanid={param1} and entitytypeid>0","Choosemodule":"ServiceContracts,SalesOrder","Detail":[{"modulename":"SalesOrder","columnname":"href_columnname,received_amount,cashbilldate"},{"modulename":"ServiceContracts","columnname":"href_columnname,received_amount,cashbilldate"}]}]',' ld_paymentplan.paymentplanid in({param1}) and ld_paymentplan.entitytypeid>0'
,'[{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_paymentplan.entitytypeid={sourcetablename}"}]','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='CashBill' and selectmodule='PaymentPlan' and type='source_detail_multi') ;

select id into @id from ld_option_showtableheader where module='CashBill' and selectmodule='PaymentPlan' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PaymentPlan:plandate','plandate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='plandate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','amount',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'TOTALRECEIVES','actualamount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='actualamount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','actualdate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='actualdate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFRECEIPT','cashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'CashBill','Invoice','source_detail_multi','[{"modulename":"Invoice","select_column":"href_columnname,invoicedate,total,received_amount,cashbilldate"},{"getsourcesql":"select contractid as sourceid,entitytype as sourcemodule from ld_inventoryproductrel where id={param1} and entitytypeid>0","Choosemodule":"ServiceContracts,SalesOrder","Detail":[{"modulename":"SalesOrder","columnname":"href_columnname,received_amount,cashbilldate"},{"modulename":"ServiceContracts","columnname":"href_columnname,received_amount,cashbilldate"}]}]',' ld_invoice.invoiceid in({param1})'
,'[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_invoice.invoiceid"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='CashBill' and selectmodule='Invoice' and type='source_detail_multi') ;

select id into @id from ld_option_showtableheader where module='CashBill' and selectmodule='Invoice' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'Invoice:invoicedate','invoicedate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='invoicedate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'TOTALRECEIVES','received_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFRECEIPT','cashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'   and column_type='source_detail_multi' );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTRECIVETOTAL','received_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='received_amount'  and column_type='source_detail_multi'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFRECEIPT','cashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='cashbilldate'  and column_type='source_detail_multi' );
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTRACTLATESTDATEOFRECEIPT','合同最近收款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTLATESTDATEOFRECEIPT' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTRACTLATESTDATEOFRECEIPT','Latest date of contract-receipt','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTLATESTDATEOFRECEIPT' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'SendCashBill','PurchaseOrder','source','[{"modulename":"PurchaseOrder","select_column":"href_columnname,signed_data,total,pay_amount,sendcashbilldate,href_columnname,pay_amount,sendcashbilldate"}]',' ld_purchaseorder.purchaseorderid in({param1})'
,'','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='SendCashBill' and selectmodule='PurchaseOrder' and type='source') ;

select id into @id from ld_option_showtableheader where module='SendCashBill' and selectmodule='PurchaseOrder' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PurchaseOrder:signed_data','signed_data',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='signed_data'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PAIDTOTALAMOUNT','pay_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFPAYMENT','sendcashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTPAIDTOTALAMOUNT','pay_amount',7,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  and sequence=7 );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFPAYMENT','sendcashbilldate',8,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  and sequence=8  );
delimiter;

call AddColumn('ld_purchaseinvoice','pay_balance','decimal','25,2',0);
delimiter;
call AddColumn('ld_purchaseinvoice','pay_amount','decimal','25,2',0);
delimiter;
call AddColumn('ld_purchaseinvoice','sendcashbilldate','date',8,'');
delimiter;

select  tabid into @tabid  from ld_tab  where name='PurchaseInvoice';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_PURCHASEINVOICE_INFO';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_balance','ld_purchaseinvoice',1,71,'pay_balance','应付余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应付余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Payable balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_amount','ld_purchaseinvoice',1,71,'pay_amount','已付总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已付总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Total amount paid' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);


select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sendcashbilldate');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'sendcashbilldate','ld_purchaseinvoice',1,5,'sendcashbilldate','最新付款日期',0,0,26, @blockid,2,'D~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sendcashbilldate');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='sendcashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'最新付款日期' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'New pay date' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'SendCashBill','PurchaseInvoice','source_detail_multi','[{"modulename":"PurchaseInvoice","select_column":"href_columnname,purchaseinvoicedate,total,pay_amount,sendcashbilldate"},{"getsourcesql":"select contractid as sourceid,entitytype as sourcemodule from ld_inventoryproductrel where id={param1} and entitytypeid>0","Choosemodule":"PurchaseOrder","Detail":[{"modulename":"PurchaseOrder","columnname":"href_columnname,pay_amount,sendcashbilldate"}]}]',' ld_purchaseinvoice.purchaseinvoiceid in({param1})'
,'[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_purchaseinvoice.purchaseinvoiceid"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='SendCashBill' and selectmodule='PurchaseInvoice' and type='source_detail_multi');

select id into @id from ld_option_showtableheader where module='SendCashBill' and selectmodule='PurchaseInvoice' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PurchaseInvoice:purchaseinvoicedate','purchaseinvoicedate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='purchaseinvoicedate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PAIDTOTALAMOUNT','pay_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFPAYMENT','sendcashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTPAIDTOTALAMOUNT','pay_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount' and column_type='source_detail_multi');

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFPAYMENT','sendcashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate' and column_type='source_detail_multi'  );
delimiter;

call AddColumn('ld_stock','pay_balance','decimal','25,2',0);
delimiter;
call AddColumn('ld_stock','pay_amount','decimal','25,2',0);
delimiter;
call AddColumn('ld_stock','sendcashbilldate','date',8,'');
delimiter;

select  tabid into @tabid  from ld_tab  where name='Stock';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_WARE_INFO';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_balance','ld_stock',1,71,'pay_balance','应付余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应付余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Payable balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_amount','ld_stock',1,71,'pay_amount','已付总额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_amount');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'已付总额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Total amount paid' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);


select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sendcashbilldate');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'sendcashbilldate','ld_stock',1,5,'sendcashbilldate','最新付款日期',0,0,26, @blockid,2,'D~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='sendcashbilldate');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='sendcashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'最新付款日期' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'New pay date' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'SendCashBill','Stock','source_detail_multi','[{"modulename":"Stock","select_column":"href_columnname,createdate,total,pay_amount,sendcashbilldate"},{"getsourcesql":"select contractid as sourceid,entitytype as sourcemodule from ld_inventoryproductrel where id={param1} and entitytypeid>0","Choosemodule":"PurchaseOrder","Detail":[{"modulename":"PurchaseOrder","columnname":"href_columnname,received_amount,cashbilldate"}]}]',' ld_stock.stock_id in({param1}) '
,'[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_stock.stock_id"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='SendCashBill' and selectmodule='Stock' and type='source_detail_multi');


select id into @id from ld_option_showtableheader where module='SendCashBill' and selectmodule='Stock' and type='source_detail_multi';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'Stock:createdate','createdate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='createdate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','total',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='total'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PAIDTOTALAMOUNT','pay_amount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFPAYMENT','sendcashbilldate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTPAIDTOTALAMOUNT','pay_amount',7,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount' and column_type='source_detail_multi' );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFPAYMENT','sendcashbilldate',8,'source_detail_multi','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate' and column_type='source_detail_multi' );
delimiter;

call AddColumn('ld_sendpayment','pay_balance','decimal','25,2',0);
delimiter;

select  tabid into @tabid  from ld_tab  where name='SendPayment';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_SendPayment_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'pay_balance','ld_sendpayment',1,71,'receivable_balance','应付余额',0,0,26, @blockid,2,'N~O~25,2',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='pay_balance');

select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='pay_balance';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'应付余额' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Payable balance' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);



insert into ld_option_showtableheader(module,selectmodule,type,columns,condition_where,from_clause,special_column_op)
select 'SendCashBill','SendPayment','source','[{"modulename":"SendPayment","select_column":"href_columnname,plandate,amount,actualamount,actualdate"},{"modulename":"PurchaseOrder","select_column":"href_columnname,pay_amount,sendcashbilldate"}]',' ld_sendpayment.sendpaymentid in({param1}) and ld_sendpayment.purchaseorder_id>0'
,'[{"tablename":"ld_purchaseorder","othertablename":"", "jointype":"left","joincontent":"ld_sendpayment.purchaseorder_id=ld_purchaseorder.purchaseorderid"}]','' from dual 
where not EXISTS(select 1 from ld_option_showtableheader where module='SendCashBill' and selectmodule='SendPayment' and type='source');


select id into @id from ld_option_showtableheader where module='SendCashBill' and selectmodule='SendPayment' and type='source';
insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) select @id,'ORIGNALBILL','href_columnname',1,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=1);

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'SendPayment:plandate','plandate',2,'main','tranlabel' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='plandate'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'AMOUNT','amount',3,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'PAIDTOTALAMOUNT','actualamount',4,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='actualamount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'LATESTDATEOFPAYMENT','actualdate',5,'main','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='actualdate'  );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTINFO','href_columnname',6,'detail','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='href_columnname'  and sequence=6 );


insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTPAIDTOTALAMOUNT','pay_amount',7,'detail','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='pay_amount'  );

insert into ld_option_showheader_label(optionshowtabheader_id,fieldlabel,columnname,sequence,column_type,label_from) 
select @id,'CONTRACTLATESTDATEOFPAYMENT','sendcashbilldate',8,'detail','desk' from dual 
where not exists(select 1 from ld_option_showheader_label where optionshowtabheader_id=@id and columnname='sendcashbilldate'  );
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTRACTLATESTDATEOFPAYMENT','合同最近付款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTLATESTDATEOFPAYMENT' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTRACTLATESTDATEOFPAYMENT','Latest date of contract-payment','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTLATESTDATEOFPAYMENT' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTRACTPAIDTOTALAMOUNT','合同已付总额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTPAIDTOTALAMOUNT' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTRACTPAIDTOTALAMOUNT','Total amount paid of contract','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTRACTPAIDTOTALAMOUNT' and labeltype='fixedstr' and languagetype='en');
delimiter;

update
ld_salesorder a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
delimiter; 

update
ld_servicecontracts e
INNER JOIN ld_currency_info f on e.currency_id=f.id
set e.conversion_rate=f.conversion_rate
where e.conversion_rate=0 or e.conversion_rate is NULL;
delimiter; 

update
ld_invoice  a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;
delimiter; 

update
ld_outboundorder e
INNER JOIN ld_currency_info f on e.currency_id=f.id
set e.conversion_rate=f.conversion_rate
where e.conversion_rate=0 or e.conversion_rate is NULL;
delimiter; 
	
update
ld_paymentplan e
INNER JOIN ld_currency_info f on e.currency_id=f.id
set e.conversion_rate=f.conversion_rate
where e.conversion_rate=0 or e.conversion_rate is NULL;
delimiter; 
	
update ld_salesorder set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_servicecontracts set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_invoice set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_outboundorder set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_paymentplan set currency_id=1,conversion_rate=1.000000 where currency_id=0;
delimiter; 

update ld_cashbill2paymentplan set entitytype='PaymentPlan',entitytypeid=paymentplanid where paymentplanid>0;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_sales_total1`;
delimiter ||
CREATE  PROCEDURE `update_sales_total1`(
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
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									ORDER BY entitytypeid;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_sales_total2`;
delimiter ||
CREATE  PROCEDURE `update_sales_total2`(
	tmp_entitytypeid int(19),
	tmp_entitytype varchar(100)
)
BEGIN
		
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
				where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
				where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		where h.entitytypeid=@tmp_entitytypeid
		group by h.entitytypeid;

		select
			max(a.cashbilldate) into @sales_date
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
		where i.entitytypeid=@tmp_entitytypeid
		group by i.entitytypeid;
						
		select
			max(a.cashbilldate) into @sales_date2
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
		where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
		set @sales_date=NULL;
		set @sales_total2=0.00;
		set @sales_date2=NULL;
			
		select
			sum(h.amount) into @sales_total
		from (
			select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		where h.entitytypeid=@tmp_entitytypeid
		group by h.entitytypeid;

		select
			max(a.cashbilldate) into @sales_date
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
		where i.entitytypeid=@tmp_entitytypeid
		group by i.entitytypeid;
					
		select
			max(a.cashbilldate) into @sales_date2
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
		LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
		where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
end ||
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total3`;
delimiter ||
CREATE  PROCEDURE `update_sales_total3`(
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
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									where entitytype in ('PaymentPlan','Invoice','OutboundOrder')
									ORDER BY entitytypeid;					
									
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

drop trigger if exists update_salesorder_received1; 
delimiter || 
CREATE TRIGGER update_salesorder_received1 
AFTER UPDATE ON ld_cashbill 
FOR EACH ROW 
BEGIN 
 
 call update_sales_total(new.cashbillid);
		
END || 
delimiter; 

drop trigger if exists update_salesorder_received2; 
delimiter;


drop trigger if exists update_salesorder_received3; 
delimiter || 
CREATE TRIGGER update_salesorder_received3
AFTER DELETE ON ld_cashbill2paymentplan 
FOR EACH ROW 
BEGIN 
    IF old.entitytypeid>0 and length(ifnull(old.entitytype,''))>1 THEN
	   call update_sales_total2(old.entitytypeid,old.entitytype);
    END IF;

	IF old.entitytype='PaymentPlan' THEN
		set @id=0;
		set @module=NULL;
		select entitytypeid into @id from ld_paymentplan where paymentplanid=old.entitytypeid;
		select entitytype into @module from ld_paymentplan where paymentplanid=old.entitytypeid;
		IF @id>0 THEN
			call update_sales_total2(@id,@module);
		END IF;

	END IF;
		
END || 
delimiter;

drop trigger if exists update_salesorder_received4; 
delimiter; 

DROP TRIGGER IF EXISTS `update_by_salesorder1`;
call update_sales_total3();
delimiter; 

DROP TRIGGER IF EXISTS `update_by_salesorder1`;
delimiter ||
CREATE TRIGGER `update_by_salesorder1` BEFORE UPDATE ON `ld_salesorder` FOR EACH ROW 
BEGIN 
	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);		
END ||
delimiter; 

update ld_paymentplan set actualamount=0.00,receivable_balance=round(amount,2),actualdate='' where paymentplanid not in 
(select 
	ld_cashbill2paymentplan.entitytypeid
from ld_cashbill
INNER JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid=ld_cashbill2paymentplan.CashBillID);

update ld_invoice set received_amount=0.00,receivable_balance=round(total,2),cashbilldate='' where invoiceid not in 
(select 
	ld_cashbill2paymentplan.entitytypeid
from ld_cashbill
INNER JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid=ld_cashbill2paymentplan.CashBillID);

update ld_outboundorder set received_amount=0.00,receivable_balance=round(total,2),cashbilldate='' where out_id not in 
(select 
	ld_cashbill2paymentplan.entitytypeid
from ld_cashbill
INNER JOIN ld_cashbill2paymentplan on ld_cashbill.cashbillid=ld_cashbill2paymentplan.CashBillID);


update
ld_purchaseorder a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;

update
ld_purchaseinvoice e
INNER JOIN ld_currency_info f on e.currency_id=f.id
set e.conversion_rate=f.conversion_rate
where e.conversion_rate=0 or e.conversion_rate is NULL;

update
ld_stock a
INNER JOIN ld_currency_info b on a.currency_id=b.id
set a.conversion_rate=b.conversion_rate
where a.conversion_rate=0 or a.conversion_rate is NULL;

update
ld_sendpayment e
INNER JOIN ld_currency_info f on e.currency_id=f.id
set e.conversion_rate=f.conversion_rate
where e.conversion_rate=0 or e.conversion_rate is NULL;

	
update ld_purchaseorder set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_purchaseinvoice set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_stock set currency_id=1,conversion_rate=1.000000 where currency_id=0;
update ld_sendpayment set currency_id=1,conversion_rate=1.000000 where currency_id=0;
delimiter;

update ld_sendcashbill2payment set entitytypeid=sendpaymentid,entitytype='SendPayment' where sendpaymentid>0;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_sendcashbill a
				LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
				where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
					
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_purs_total1`;
delimiter ||
CREATE  PROCEDURE `update_purs_total1`(
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
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.Purchaseorder_id,
												'PurchaseOrder' entitytype
										from ld_sendcashbill a 
										LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
										INNER JOIN ld_sendpayment c on c.sendpaymentid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									ORDER BY entitytypeid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=84;
	
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_sendcashbill a
				LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
				where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
					
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_purs_total2`;
delimiter ||
CREATE  PROCEDURE `update_purs_total2`(
	tmp_entitytypeid int(19),
	tmp_entitytype varchar(100)
)
BEGIN
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=84;
	
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
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
		UNION ALL
			select 
				a.currency_id 
			from ld_sendcashbill a
			LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
				
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

		select
			max(a.cashbilldate) into @purs_date
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
			where i.Purchaseorder_id=@tmp_entitytypeid
			group by i.Purchaseorder_id;

		select
			max(a.cashbilldate) into @purs_date2
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

		select
			max(a.cashbilldate) into @purs_date
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
			where i.Purchaseorder_id=@tmp_entitytypeid
			group by i.Purchaseorder_id;

		select
			max(a.cashbilldate) into @purs_date2
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
end ||
delimiter;

drop trigger if exists update_purchaseorder_received1; 
delimiter || 
CREATE TRIGGER update_purchaseorder_received1 
AFTER UPDATE ON ld_sendcashbill 
FOR EACH ROW 
BEGIN 
 
		call update_purs_total(new.sendcashbillid);
		
END || 
delimiter; 

drop trigger if exists update_purchaseorder_received2; 
delimiter; 

drop trigger if exists update_purchaseorder_received3; 
delimiter || 
CREATE TRIGGER update_purchaseorder_received3
AFTER DELETE ON ld_sendcashbill2payment 
FOR EACH ROW 
BEGIN 
    IF old.entitytypeid>0 and length(ifnull(old.entitytype,''))>1 THEN
	   call update_purs_total2(old.entitytypeid,old.entitytype);
    END IF;

	IF old.entitytype='SendPayment' THEN
		set @id=0;
		select Purchaseorder_id into @id from ld_sendpayment where sendpaymentid=old.entitytypeid;
		IF @id>0 THEN
			call update_purs_total2(@id,'PurchaseOrder');
		END IF;

	END IF;
		
END || 
delimiter;

drop trigger if exists update_purchaseorder_received4; 
delimiter;


call update_purs_total1();
delimiter; 

update ld_purchaseorder set pay_amount=0.00,pay_balance=round(total,2),sendcashbilldate='' where purchaseorderid not in 
(select 
	ld_sendcashbill2payment.entitytypeid
from ld_sendcashbill
INNER JOIN ld_sendcashbill2payment on ld_sendcashbill.sendcashbillid=ld_sendcashbill2payment.sendcashbillid);

update ld_purchaseinvoice set pay_amount=0.00,pay_balance=round(total,2),sendcashbilldate='' where purchaseinvoiceid not in 
(select 
	ld_sendcashbill2payment.entitytypeid
from ld_sendcashbill
INNER JOIN ld_sendcashbill2payment on ld_sendcashbill.sendcashbillid=ld_sendcashbill2payment.sendcashbillid);

update ld_stock set pay_amount=0.00,pay_balance=round(total,2),sendcashbilldate='' where stock_id not in 
(select 
	ld_sendcashbill2payment.entitytypeid
from ld_sendcashbill
INNER JOIN ld_sendcashbill2payment on ld_sendcashbill.sendcashbillid=ld_sendcashbill2payment.sendcashbillid);

update ld_sendpayment set Actualamount=0.00,pay_balance=round(amount,2),Actualdate='' where sendpaymentid not in 
(select 
	ld_sendcashbill2payment.entitytypeid
from ld_sendcashbill
INNER JOIN ld_sendcashbill2payment on ld_sendcashbill.sendcashbillid=ld_sendcashbill2payment.sendcashbillid);

drop trigger if exists update_by_purchaseorder1; 
delimiter || 
CREATE TRIGGER update_by_purchaseorder1 
BEFORE UPDATE ON ld_purchaseorder 
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.total,0)-ifnull(new.pay_amount,0),2);
	
END || 
delimiter;


drop trigger if exists update_by_purchaseorder_insert; 
delimiter || 
CREATE TRIGGER update_by_purchaseorder_insert 
BEFORE insert ON ld_purchaseorder 
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.total,0)-ifnull(new.pay_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_purchaseinvoice1; 
delimiter || 
CREATE TRIGGER update_by_purchaseinvoice1 
BEFORE UPDATE ON ld_purchaseinvoice
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.total,0)-ifnull(new.pay_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_purchaseinvoice_insert; 
delimiter || 
CREATE TRIGGER update_by_purchaseinvoice_insert 
BEFORE insert ON ld_purchaseinvoice
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.total,0)-ifnull(new.pay_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_stock1; 
delimiter || 
CREATE TRIGGER update_by_stock1 
BEFORE UPDATE ON ld_stock
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.total,0)-ifnull(new.pay_amount,0),2);
	
END || 
delimiter;



drop trigger if exists update_by_stock_insert; 
delimiter || 
CREATE TRIGGER update_by_stock_insert 
BEFORE insert ON ld_stock
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.total,0)-ifnull(new.pay_amount,0),2);
	
END || 
delimiter;


drop trigger if exists update_by_sendpayment1; 
delimiter || 
CREATE TRIGGER update_by_sendpayment1 
BEFORE UPDATE ON ld_sendpayment
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.Amount,0)-ifnull(new.Actualamount,0),2);
	
END || 
delimiter;


drop trigger if exists update_by_sendpayment_insert; 
delimiter || 
CREATE TRIGGER update_by_sendpayment_insert 
BEFORE insert ON ld_sendpayment
FOR EACH ROW 
BEGIN 

	set new.pay_balance=round(ifnull(new.Amount,0)-ifnull(new.Actualamount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_outboundorder1; 
delimiter || 
CREATE TRIGGER update_by_outboundorder1 
BEFORE UPDATE ON ld_outboundorder
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_outboundorder_insert; 
delimiter || 
CREATE TRIGGER update_by_outboundorder_insert 
BEFORE insert ON ld_outboundorder
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_invoice1; 
delimiter || 
CREATE TRIGGER update_by_invoice1 
BEFORE UPDATE ON ld_invoice
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_invoice_insert; 
delimiter || 
CREATE TRIGGER update_by_invoice_insert 
BEFORE insert ON ld_invoice
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_paymentplan1; 
delimiter || 
CREATE TRIGGER update_by_paymentplan1 
BEFORE UPDATE ON ld_paymentplan
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.amount,0)-ifnull(new.actualamount,0),2);
	
END || 
delimiter;

drop trigger if exists update_by_paymentplan_insert; 
delimiter || 
CREATE TRIGGER update_by_paymentplan_insert 
BEFORE insert ON ld_paymentplan
FOR EACH ROW 
BEGIN 

	set new.receivable_balance=round(ifnull(new.amount,0)-ifnull(new.actualamount,0),2);
	
END || 
delimiter;
update ld_inventoryproductrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id
set contractid = id where ld_crmentity.setype = 'PurchaseOrder';
delimiter;
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','EMAILINFO','邮件信息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'EMAILINFO');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','EMAILINFO','Email Information','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'EMAILINFO');
delimiter;

call AddColumn('ld_expensedetailscf','currency_symbol','varchar','30',NULL);
delimiter;

update ld_expensedetailscf 
LEFT JOIN ld_currency_info on ld_currency_info.id = ld_expensedetailscf.currency_id
set ld_expensedetailscf.currency_symbol = ld_currency_info.currency_symbol where ld_expensedetailscf.currency_id >= 1;
delimiter;

DROP PROCEDURE `altercolumnfor_primarykey`;
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
    END IF;
  end ||
delimiter;
call altercolumnfor_primarykey('ld_commission2payment','commission2payment_id');
delimiter;

update ld_desk set fieldlabel='Optional Module customization' where languagetype='en' AND labelbol='LBL_Optionalmodule_Customization' AND Labeltype='fixedstr';
delimiter;
-- 2016-09-13

select usereportid into @usereportid from ld_usereport where `name`='Performancestatisticscollection';
update ld_usereportcolumns set realcolumns='ld_cashbill:cashbilldate:cashbilldate:CashBill_单据日期:D',
	realencolumns='ld_cashbill:cashbilldate:cashbilldate:CashBill_Bill Date:D' 
where Usereportid=@usereportid and `columns`='ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D';

update ld_usereportcolumns set realcolumns='ld_cashbill:cashbill_no:cashbill_no:CashBill_单据编号:V',
	realencolumns='ld_cashbill:cashbill_no:cashbill_no:CashBill_Bill NO.:V' 
where Usereportid=@usereportid and `columns`='ld_cashbill:cashbill_no:cashbill_no:CashBill_cashbill_no:V';

update ld_usereportcolumns set realencolumns='ld_account:accountname:accountname:Accounts_Account Name:V' 
where Usereportid=@usereportid and `columns`='ld_account:accountname:accountname:Accounts_accountname:V';

update ld_usereportcolumns set realencolumns='ld_salesorder:salesorder_no:salesorder_no:OftenUseReport_Order No.:V' 
where Usereportid=@usereportid and `columns`='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V';

update ld_usereportcolumns set realencolumns='ld_cashbill:pamount:pamount:OftenUseReport_Amount Collected:N' 
where Usereportid=@usereportid and `columns`='ld_cashbill:pamount:pamount:OftenUseReport_pamount:N';

update ld_usereportcolumns set realencolumns='ld_salesorder:ssubtotal:ssubtotal:OftenUseReport_Order Total:N' 
where Usereportid=@usereportid and `columns`='ld_salesorder:ssubtotal:ssubtotal:OftenUseReport_ssubtotal:N';

update ld_usereportcolumns set realencolumns='ld_salesorder:ssubtotal:ssubtotal:OftenUseReport_Order Received Amount:N' 
where Usereportid=@usereportid and `columns`='ld_cashbill:Atotal:Atotal:OftenUseReport_Atotal:N';

update ld_usereportcolumns set realencolumns='ld_expense:etotal:etotal:OftenUseReport_Expenses Total:N' 
where Usereportid=@usereportid and `columns`='ld_expense:etotal:etotal:OftenUseReport_etotal:N';

update ld_usereportcolumns set realencolumns='ld_salesordercost:productcost:productcost:OftenUseReport_Total Products Cost:N' 
where Usereportid=@usereportid and `columns`='ld_salesordercost:productcost:productcost:OftenUseReport_productcost:N';

update ld_usereportcolumns set realencolumns='ld_salesordercost:productgp:productgp:OftenUseReport_Collection Profit:N' 
where Usereportid=@usereportid and `columns`='ld_salesordercost:productgp:productgp:OftenUseReport_productgp:N';

update ld_usereportcolumns set realencolumns='ld_inventoryproductrel:costprice:costprice:Products_Products Cost:N' 
where Usereportid=@usereportid and `columns`='ld_cashbill:description:description:CashBill_description:V';

update ld_usereportcolumns set realencolumns='ld_cashbill:description:description:CashBill_Description:V' 
where Usereportid=@usereportid and `columns`='ld_cashbill:description:description:CashBill_description:V';


update ld_usereportcolumns set columnshow=1,sequence=1 where Usereportid=@usereportid and `columns`='ld_users:lastname:lastname:OftenUseReport_lastname:V';
update ld_usereportcolumns set columnshow=1,sequence=2 where Usereportid=@usereportid and `columns`='ld_cashbill:cashbill_no:cashbill_no:CashBill_cashbill_no:V';
update ld_usereportcolumns set columnshow=1,sequence=3 where Usereportid=@usereportid and `columns`='ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D';
update ld_usereportcolumns set columnshow=1,sequence=4 where Usereportid=@usereportid and `columns`='ld_account:accountname:accountname:Accounts_accountname:V';
update ld_usereportcolumns set columnshow=1,sequence=5 where Usereportid=@usereportid and `columns`='ld_cashbill:pamount:pamount:OftenUseReport_pamount:N';

update ld_usereportcolumns set columnshow=1,sequence=6 where Usereportid=@usereportid and `columns`='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V';
update ld_usereportcolumns set columnshow=1,sequence=7 where Usereportid=@usereportid and `columns`='ld_salesorder:ssubtotal:ssubtotal:OftenUseReport_ssubtotal:N';
update ld_usereportcolumns set columnshow=1,sequence=8 where Usereportid=@usereportid and `columns`='ld_cashbill:Atotal:Atotal:OftenUseReport_Atotal:N';
update ld_usereportcolumns set columnshow=1,sequence=9 where Usereportid=@usereportid and `columns`='ld_expense:etotal:etotal:OftenUseReport_etotal:N';
update ld_usereportcolumns set columnshow=1,sequence=10 where Usereportid=@usereportid and `columns`='ld_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN';

update ld_usereportcolumns set columnshow=1,sequence=11 where Usereportid=@usereportid and `columns`='ld_salesordercost:productcost:productcost:OftenUseReport_productcost:N';
update ld_usereportcolumns set columnshow=1,sequence=12 where Usereportid=@usereportid and `columns`='ld_salesordercost:productgp:productgp:OftenUseReport_productgp:N';
update ld_usereportcolumns set columnshow=1,sequence=13 where Usereportid=@usereportid and `columns`='ld_products:productname:productname:Products_productname:V';
update ld_usereportcolumns set columnshow=1,sequence=14 where Usereportid=@usereportid and `columns`='ld_inventoryproductrel:quantity:quantity:OftenUseReport_quantity:N';
update ld_usereportcolumns set columnshow=1,sequence=15 where Usereportid=@usereportid and `columns`='ld_inventoryproductrel:costprice:costprice:Products_costprice:N';

update ld_usereportcolumns set columnshow=1,sequence=16 where Usereportid=@usereportid and `columns`='ld_cashbill:description:description:CashBill_description:V';
update ld_usereportcolumns set columnshow=0,sequence=17 where Usereportid=@usereportid and `columns`='ld_users:lastname3:lastname3:OftenUseReport_lastname3:V';
update ld_usereportcolumns set columnshow=0,sequence=18 where Usereportid=@usereportid and `columns`='ld_salesorder:subject:subject:SalesOrder_subject:V';
update ld_usereportcolumns set columnshow=0,sequence=19 where Usereportid=@usereportid and `columns`='ld_products:product_no:product_no:Products_product_no:V';
update ld_usereportcolumns set columnshow=0,sequence=20 where Usereportid=@usereportid and `columns`='ld_products:usageunit:usageunit:Products_usageunit:V';

update ld_usereportcolumns set columnshow=0,sequence=21 where Usereportid=@usereportid and `columns`='ld_products:productsheet:productsheet:Products_productsheet:V';
update ld_usereportcolumns set columnshow=0,sequence=22 where Usereportid=@usereportid and `columns`='ld_products:unit_price:unit_price:Products_unit_price:N';
update ld_usereportcolumns set columnshow=0,sequence=23 where Usereportid=@usereportid and `columns`='ld_inventoryproductrel:discountamount:discountamount:OftenUseReport_discountamount:V';
delimiter;
-- 2016-09-14

UPDATE ld_field SET approve_demand=2;
delimiter;
UPDATE ld_field SET approve_demand=0 where uitype in (51,57,80,73,57,59,76,80,78,150,10,15,75,81,76,241,240,59,58);
delimiter;

update ld_desk set fieldlabel = 'Viewing Range' where labelbol = 'VIEWRANGE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = 'I Created' where labelbol = 'Icreated' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = 'The statistics of last week' where labelbol = 'LASTSTATICOFTHISWEEK' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'The statistics of last month' where labelbol = 'LASTSTATICOFTHISMONTH' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set defaultcolumn = 7,width = 30 where tabid = @tabid and fieldtype = 'SelectSource' and columnname = 'entitytypeid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set defaultcolumn = 7,width = 30 where tabid = @tabid and fieldtype = 'SelectSource' and columnname = 'entitytypeid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ORDERNUM','排名','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ORDERNUM' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ORDERNUM','OrderNum','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ORDERNUM' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = 'Sales Charts' where labelbol = 'SALESCHARTS' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Last Month' where labelbol = 'lastmonth' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Collection Amount' where labelbol = 'AMOUNTTO' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Contract Amount' where labelbol = 'CONTRACTAMOUNTPANEL' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Contract Amount' where labelbol = 'CONTRACTAOUNT' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Contract Number' where labelbol = 'CONTRACTNUMBERHONE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Contract Quantity' where labelbol = 'CONTRACTQUANTITY' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Daily/Monthly/Yearly' where labelbol = 'DAILYWEEKMONTH' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Submission Case' where labelbol = 'SUBMITSSION' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = 'Showed no group users(User name is displayed as red font)' where labelbol = 'SHOWNOGROUPUSER' and languagetype = 'en' and Labeltype='jspop';
delimiter;
update ld_desk set fieldlabel = 'This month sales data of subordinate' where labelbol = 'SUBORDINATEMOTHSALESDATA' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
-- 2016-09-18

update ld_systems_deploy set deploy_value=0,description='是否隐藏帮我吧在线咨询功能。1:显示，0:隐藏' where deploy_type=103
	and not exists (select 1 from ld_bangwo8);
    
 SELECT tabid into @tabid from ld_tab where `name`='Products';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Products');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'product_no','productname') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Potentials';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Potentials');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'potential_no','potentialname') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='ProjectMilestone';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='ProjectMilestone');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'projectmilestonename','projectmilestone_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='VendorContact';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='VendorContact');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'lastname','vendorcontact_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Events';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Events');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Quotes';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Quotes');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject','quote_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='ServiceContracts';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='ServiceContracts');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject','contract_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='HelpDesk';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='HelpDesk');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject','ticket_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Project';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Project');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'projectname','project_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='ProjectTask';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='ProjectTask');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'projecttaskname','projecttask_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='ProjectProgress';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='ProjectProgress');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'projectprogress_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Vendors';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='Vendors');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'vendorname','vendor_no') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='VendorContactRecords';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='VendorContactRecords');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'subject') AND tabid=@tabid;
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='FundNet';
SELECT fieldname into @fieldname from ld_entityname where tabid in(SELECT tabid from ld_tab where NAME ='FundNet');
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'fund_no') AND tabid=@tabid;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHECKFIELDISNOTNULL','主表查重字段不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKFIELDISNOTNULL' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHECKFIELDISNOTNULL','Main table Duplicate check field cannot be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHECKFIELDISNOTNULL' and Labeltype='jspop'); 
delimiter;

update ld_desk set fieldlabel = 'List View' where labelbol = 'LISTVIEW' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

select defaultvalue into @defaultvalue from ld_field where columnname = 'eventstatus' and tabid = 16;
update ld_activity set eventstatus = @defaultvalue where eventstatus is null or eventstatus = '';
delimiter;

call AddColumn('ld_template_calendar','autoexec','int',2,0);
delimiter;
call AddColumn('ld_activity','product_id','int',19,0);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOEXECUTEWHENMET','满足条件时自动执行','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'AUTOEXECUTEWHENMET' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOEXECUTEWHENMET','Automatic execution when the condition is met','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'AUTOEXECUTEWHENMET' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select 14,9,6,0 
from dual where not exists (select 1 from ld_quickactions where tabid = 14 and related_tabid = 9);
delimiter;
-- 2016-09-19

update ld_desk set fieldlabel = 'List View' where labelbol = 'LISTVIEW' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
select fieldid into @fieldid from ld_field where tabid = 23 and fieldname = 'hdnGrandTotal';
update ld_tranlabel set fieldlabel = 'Total' where Relateid = @fieldid and tabid = 23 and trantable='ld_field' and languagetype='en';
delimiter;
update ld_desk set fieldlabel = 'Last Week' where labelbol = 'lastweek' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Last Month' where labelbol = 'lastmonth' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Daily/Weekly/Monthly' where labelbol = 'DAILYWEEKMONTH' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Submission Case' where labelbol = 'SUBMITSSION' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Display in The Home Key View' where labelbol = 'DISPLAYINHOME' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Display Column Settings' where labelbol = 'DISPLAYCOLUMNSETTINGS' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Available Fields' where labelbol = 'Available_fields' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Sort Order Settings' where labelbol = 'SORTORDERSETTING' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Basic Query' where labelbol = 'Basic_queries' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Advanced Query' where labelbol = 'Advanced_Search' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Easy Time Filter' where labelbol = 'EASYTIMEFILTER' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Select The Field' where labelbol = 'Select_field' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Select Time Period' where labelbol = 'SELECT_TIME' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Today' where labelbol = 'today' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Tomorrow' where labelbol = 'tomorrow' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Next Week' where labelbol = 'nextweek' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Next Month' where labelbol = 'nextmonth' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

select defaultvalue into @defaultvalue from ld_field where columnname = 'eventstatus' and tabid = 16;
update ld_activity set eventstatus = @defaultvalue where eventstatus is null or eventstatus = '';
delimiter;

update ld_relatedlists set mobile_presence = 1 where tabid = 2 and related_tabid = 9;
delimiter;
ALTER TABLE ld_relatedlists ALTER COLUMN mobile_presence set DEFAULT 1;
delimiter;

update ld_desk set fieldlabel = 'Please select the file for the .xls or .xlsx extension' where labelbol = 'PLEASESELECTEXCEL2003FILE' and languagetype = 'en' and Labeltype='jspop';
delimiter;
update ld_desk set fieldlabel = 'Basic Query' where labelbol = 'Basic_queries' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Remove Combination' where labelbol = 'REMOVECOMBINATION' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Field Title' where labelbol = 'Field_title' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOWER_BASIC_QUERY','基本查询','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'LOWER_BASIC_QUERY' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOWER_BASIC_QUERY',' basic query','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'LOWER_BASIC_QUERY' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = ' Statistical Distribution' where labelbol = 'STATISTICALDISTRIBUTION' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'View Empty Folder' where labelbol = 'VIEWEMPTYFOLDER' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CALLTEMPLATE','调用模板','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CALLTEMPLATE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CALLTEMPLATE','Call Template','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CALLTEMPLATE' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = 'Set Field' where labelbol = 'SETFIELD' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Set Column' where labelbol = 'SETUPCOLUMNHEADER' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Search Now' where labelbol = 'SERCHNOW' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'release reason' where labelbol = 'RELEASEACCOUNTTREASON' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='FundNet';
SELECT fieldname into @fieldname from ld_entityname where tabid =@tabid;
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'fund_no') AND tabid=@tabid;
delimiter;

SELECT tabid into @tabid from ld_tab where `name`='TimeSheet';
SELECT fieldname into @fieldname from ld_entityname where tabid =@tabid;
update ld_field set is_checkimportfield=1 where columnname in(@fieldname,'timesheet_no') AND tabid=@tabid;
delimiter;
-- 2016-09-20

DROP FUNCTION IF EXISTS `getPY`; 
delimiter || 
CREATE FUNCTION `getPY`(in_string VARCHAR(65534)) RETURNS mediumtext CHARSET utf8 
BEGIN
	DECLARE tmp_str VARCHAR(65534) charset gbk DEFAULT '' ;
	DECLARE tmp_len SMALLINT DEFAULT 0; 
	DECLARE tmp_char VARCHAR(2) charset gbk DEFAULT '';
	DECLARE tmp_rs VARCHAR(65534) charset gbk DEFAULT '';
	DECLARE tmp_cc VARCHAR(2) charset gbk DEFAULT '';

	SET tmp_str = in_string;
	SET tmp_len = LENGTH(tmp_str);

	WHILE tmp_len > 0 DO 
		SET tmp_char = LEFT(tmp_str,1); 
		SET tmp_cc = tmp_char;
		IF LENGTH(tmp_char)>1 THEN
			SELECT ELT(INTERVAL(CONV(HEX(tmp_char),16,10),0xB0A1,0xB0C5,0xB2C1,0xB4EE,0xB6EA,0xB7A2,0xB8C1,0xB9FE,0xBBF7,0xBFA6,0xC0AC
			,0xC2E8,0xC4C3,0xC5B6,0xC5BE,0xC6DA,0xC8BB,0xC8F6,0xCBFA,0xCDDA ,0xCEF4,0xD1B9,0xD4D1), 
			'A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','W','X','Y','Z') INTO tmp_cc;
		END IF; 
		SET tmp_rs = CONCAT(tmp_rs,tmp_cc);
		SET tmp_str = SUBSTRING(tmp_str,2);
		SET tmp_len = LENGTH(tmp_str);
	END WHILE; 
	RETURN tmp_rs;
END || 
delimiter;

update ld_desk set fieldlabel = 'Templates Name' where labelbol = 'TEMPLATENAME' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Customer Contact Calendar Number TOP10' where labelbol = 'CUSTOMERCALENDARCONTACTTEN' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
select tabid into @tabid from ld_tab where name = 'CommunicationLog';
update ld_tranlabel set fieldlabel = 'Message History' where tabid = @tabid and trantable = 'ld_tab' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel = 'SMS Job Inquiries' where labelbol = 'SMSJOBINQUIRIES' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'SMS List Query' where labelbol = 'SMSLISTQUERY' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Delivery Time' where labelbol = 'Delivery_time' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Job Number' where labelbol = 'Job_number' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Total Number' where labelbol = 'total_number' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Completed Copies' where labelbol = 'Completed_copies' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Create Time' where labelbol = 'Createtime1' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Delivery Time' where labelbol = 'Delivery_time' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTENTLENGTH','字数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTENTLENGTH' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTENTLENGTH','Length','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTENTLENGTH' and labeltype='fixedstr' and languagetype='en');
delimiter;
update ld_desk set fieldlabel = 'Quickly Create' where labelbol = 'Quickly_create' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PHONESTEWARDCLIENTDOWNLOAD','电话管家客户端下载','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PHONESTEWARDCLIENTDOWNLOAD' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PHONESTEWARDCLIENTDOWNLOAD','Client Download','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PHONESTEWARDCLIENTDOWNLOAD' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QUICKLYSTART','快速上手','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'QUICKLYSTART' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','QUICKLYSTART','Quickly Start','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'QUICKLYSTART' and labeltype='fixedstr' and languagetype='en');
delimiter;
update ld_desk set fieldlabel = 'Phone Number' where labelbol = 'PhoneNumber' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Staff Range' where labelbol = 'RANGESTAFF' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '您的权限不足，无权操作任何仓库<br>可能原因：您没有任何仓库的权限或者仓库没有库存初始化' where labelbol = 'INSUFFICIENTWAREHOUSE' and languagetype = 'zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'You have insufficient privileges,not any warehouse operation<br>Possible reason: you do not have any rights to warehouse or warehouse <br>without inventory initialization' where labelbol = 'INSUFFICIENTWAREHOUSE' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHECKFIELDCANNOTBEEMPTY','查重字段不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKFIELDCANNOTBEEMPTY' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHECKFIELDCANNOTBEEMPTY','check field cannot be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHECKFIELDCANNOTBEEMPTY' and Labeltype='jspop'); 
delimiter; 

update ld_desk set fieldlabel = 'During Query' where labelbol = 'DURINGQUERY' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Generation of Current Account' where labelbol = 'GENERATIONOFCURRENTACCOUNT' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Company Account' where labelbol = 'COMPANYACCOUNT' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Generate Inventory Ledger' where labelbol = 'GEMERATEINLEDGER' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'End Returning Goods' where labelbol = 'ENDRETURNGOODS' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'How To Return Goods' where labelbol = 'HOWTOGOODS' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Merge&Create {$SalesOrder.SalesOrder}' where labelbol = 'MERGECREATE' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set languagetype = 'en' where languagetype = 'end';
update ld_desk set fieldlabel = 'Export Templates' where labelbol = 'EXPORTTEMPLATES' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Field Name' where labelbol = 'FIELDNAME' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Query Conditions' where labelbol = 'QUERY' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Optional Field' where labelbol = 'OPTIONALFIELD' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Match Field' where labelbol = 'MATCHFIELD' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Find Duplicate Records' where labelbol = 'FINDDUPLICATERECORDS' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;
-- 2016-09-23

update ld_systems_deploy set deploy_value=0 
where LENGTH(ifnull(setype,''))>0 and deploy_value=1 and not exists (select 1 from ld_crmentity where crmid>2);

update ld_field set associatedfields=1,associatedsequence=0
where associatedfields=0 
	and not exists (select 1 from ld_crmentity where crmid>2)
	and (not exists (select 1 from ld_blockdisplay where is_display=0));

update ld_field set associatedfields=0,associatedsequence=1 
where tabid=6 and columnname='bill_street' 
	and not exists (select 1 from ld_crmentity where crmid>2) 
	and not exists (select 1 from ld_blockdisplay where is_display=0);

update ld_field set associatedfields=0,associatedsequence=2 
where tabid=6 and columnname='smownerid' 
	and not exists (select 1 from ld_crmentity where crmid>2) 
	and not exists (select 1 from ld_blockdisplay where is_display=0);

update ld_field set associatedfields=0,associatedsequence=3 
where tabid=4 and columnname='mobile' 
	and not exists (select 1 from ld_crmentity where crmid>2) 
	and not exists (select 1 from ld_blockdisplay where is_display=0);

update ld_field set associatedfields=0,associatedsequence=4 
where tabid=4 and columnname='pphone' 
	and not exists (select 1 from ld_crmentity where crmid>2) 
	and not exists (select 1 from ld_blockdisplay where is_display=0);

update ld_blockdisplay set display_position=0,is_display=0 where not exists (select 1 from ld_crmentity where crmid>2);
delimiter;

update ld_productcategory set productcategory='KIS迷你版',scores='300.00' 
where productcategory='服务费' and productcategoryid=5
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_productcategory set productcategory='KIS标准版',scores='400.00' 
where productcategory='赠品' and productcategoryid=6
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='宝山区' and bill_cityid=2
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='崇明区' and bill_cityid=4
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='奉贤区' and bill_cityid=5
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='嘉定区' and bill_cityid=8
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='金山区' and bill_cityid=9
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='南汇区' and bill_cityid=13
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='青浦区' and bill_cityid=16
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_bill_city set scores='200.00' 
where bill_city='松江区' and bill_cityid=17
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_ticketcategories set weight='100.00' 
where ticketcategories='答疑'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_ticketcategories set weight='200.00' 
where ticketcategories='培训'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_ticketcategories set weight='150.00' 
where ticketcategories='升级'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_ticketcategories set weight='200.00' 
where ticketcategories='故障排除'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_ticketcategories set weight='100.00' 
where ticketcategories='其他'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_projecttasktype set weight='125.00' 
where projecttasktype='管理'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_projecttasktype set weight='150.00' 
where projecttasktype='操作'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_projecttasktype set weight='100.00' 
where projecttasktype='其他'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_tab set Proportion=3 
where tabid in (13,47) and not exists (select 1 from ld_crmentity where crmid>2);


update ld_servicetype set weight='10.00' 
where servicetype='电话'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_servicetype set weight='25.00' 
where servicetype='远程'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_servicetype set weight='25.00' 
where servicetype='送修'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_servicetype set weight='100.00' 
where servicetype='上门'
	and not exists (select 1 from ld_crmentity where crmid>2);

update ld_servicetype set weight='10.00' 
where servicetype='其它'
	and not exists (select 1 from ld_crmentity where crmid>2);
-- 2016-09-26

update ld_desk set fieldlabel='预算' where labelbol='Expect' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Expect' where labelbol='Expect' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='实际' where labelbol='Actual' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Actual' where labelbol='Actual' and languagetype='en' and Labeltype='fixedstr';
delimiter;

set @zh=NULL;
set @en=NULL;
select fieldlabel into @zh from ld_tranlabel where tabid=2 and languagetype='zh' and trantable='ld_tab' limit 1;
select fieldlabel into @en from ld_tranlabel where tabid=2 and languagetype='en' and trantable='ld_tab' limit 1;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Expect_Description',CONCAT('预算（关联',@zh,')'),'fixedstr' from dual
where not exists (select 1 from ld_desk where labelbol='Expect_Description' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Expect_Description',CONCAT('Expect(Related to',@en,')'),'fixedstr' from dual
where not exists (select 1 from ld_desk where labelbol='Expect_Description' and languagetype='en' and Labeltype='fixedstr');
delimiter;

set @zh=NULL;
set @en=NULL;
set @zh1=NULL;
set @en2=NULL;
select fieldlabel into @zh from ld_tranlabel where tabid=22 and languagetype='zh' and trantable='ld_tab' limit 1;
select fieldlabel into @en from ld_tranlabel where tabid=22 and languagetype='en' and trantable='ld_tab' limit 1;
select fieldlabel into @zh1 from ld_tranlabel where tabid=37 and languagetype='zh' and trantable='ld_tab' limit 1;
select fieldlabel into @en1 from ld_tranlabel where tabid=37 and languagetype='en' and trantable='ld_tab' limit 1;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Actual_Description',CONCAT('实际（关联',@zh,'/',@zh1,')'),'fixedstr' from dual
where not exists (select 1 from ld_desk where labelbol='Actual_Description' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Actual_Description',CONCAT('Actual(Related to',@en,'/',@en1,')'),'fixedstr' from dual
where not exists (select 1 from ld_desk where labelbol='Actual_Description' and languagetype='en' and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `update_field_ProjectProgress_enddate`;
delimiter ||
CREATE  PROCEDURE `update_field_ProjectProgress_enddate`(
)
begin

	set @startdate_presence=1;
	set @enddate_presence=1;
	set @typeofdata=NULL;

	select tabid into @tabid from ld_tab where `name`='ProjectProgress';
	select presence into @startdate_presence from ld_field where tabid=@tabid and columnname='startdate';
	select presence into @enddate_presence from ld_field where tabid=@tabid and columnname='enddate';
	select typeofdata into @typeofdata from ld_field where tabid=@tabid and columnname='enddate';

	IF @startdate_presence=0 and @enddate_presence=0 and @typeofdata like '%D~M%' THEN
		update ld_field set typeofdata='D~M~OTH~GE~startdate~startdate' where tabid=@tabid and columnname='enddate';
	ELSEIF @startdate_presence=0 and @enddate_presence=0 and @typeofdata like '%D~O%' THEN
		update ld_field set typeofdata='D~O~OTH~GE~startdate~startdate' where tabid=@tabid and columnname='enddate';
	END IF;
end ||
delimiter;

CALL update_field_ProjectProgress_enddate();
delimiter;

update ld_desk set fieldlabel='Control Panel' where labelbol='CONTROLPANEL' and languagetype='en';
update ld_desk set fieldlabel='System Parameters Setting' where labelbol='LBL_SYSTEM_SET' and languagetype='en';
update ld_desk set fieldlabel='系统参数设置' where labelbol='LBL_SYSTEM_SET' and languagetype='zh';

update ld_desk set fieldlabel='Home Templates Customization' where labelbol='LBL_TEMPLATES' and languagetype='en';
update ld_desk set fieldlabel='Print Templates Customization' where labelbol='LBL_PRINT_TEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='Document Templates Customization' where labelbol='THEDOCUMENTTEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='文档模板定制' where labelbol='THEDOCUMENTTEMPLATE' and languagetype='zh';

update ld_desk set fieldlabel='Workplan Templates Customization' where labelbol='LBL_WORK_TEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='日志模板定制' where labelbol='LBL_WORK_TEMPLATE' and languagetype='zh';

update ld_desk set fieldlabel='Workreport Templates Customization' where labelbol='LBL_WORK_TEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='日志模板定制' where labelbol='LBL_WORK_TEMPLATE' and languagetype='zh';

update ld_desk set fieldlabel='Bills Details Customization' where labelbol='LBL_ProductTool_field' and languagetype='en';
update ld_desk set fieldlabel='单据分录定制' where labelbol='LBL_ProductTool_field' and languagetype='zh';

update ld_desk set fieldlabel='Related Fields of Accounts & Contacts' where labelbol='LBL_ACCOUNTS_CONTACTS_FIELDS' and languagetype='en';

update ld_desk set fieldlabel='Service Assessment Elements' where labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS' and languagetype='en';
update ld_desk set fieldlabel='服务绩效参数' where labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS' and languagetype='zh';

update ld_desk set fieldlabel='Optional Module Customization' where labelbol='LBL_Optionalmodule_Customization' and languagetype='en';
update ld_desk set fieldlabel='Data Backup' where labelbol='LBL_BACKUP_SET' and languagetype='en';
update ld_desk set fieldlabel='Reminders for Work Report Setting' where labelbol='LBL_REMIND_SET' and languagetype='en';
update ld_desk set fieldlabel='High Seas Parameters Setting' where labelbol='LBL_ACCOUNT_SET' and languagetype='en';
update ld_desk set fieldlabel='Bills Numbers Customization' where labelbol='LBL_CUSTOMIZE_MODENT_NUMBER' and languagetype='en';
update ld_desk set fieldlabel='Automatic Reminders Setting' where labelbol='LBL_AUTOMATICREMINDS_SET' and languagetype='en';
update ld_desk set fieldlabel='自动提醒设置' where labelbol='LBL_AUTOMATICREMINDS_SET' and languagetype='zh';
update ld_desk set fieldlabel='Automatic Tasks Setting' where labelbol='LBL_AUTOMATIC_TASK' and languagetype='en';
update ld_desk set fieldlabel='自动任务设置' where labelbol='LBL_AUTOMATIC_TASK' and languagetype='zh';


update ld_desk set fieldlabel='Latest {$Potentials.Potentials}' where labelbol='LATESTPOTENTIALS' and languagetype='en';
update ld_desk set fieldlabel='Latest {$Quotes.Quotes}' where labelbol='LATESTQUOTATION' and languagetype='en';
update ld_desk set fieldlabel='Latest {$SalesOrder.SalesOrder}' where labelbol='NEWCONTRACTORDERS' and languagetype='en';
update ld_desk set fieldlabel='Latest {$Invoice.Invoice}' where labelbol='LATESTINVOICE' and languagetype='en';
update ld_desk set fieldlabel='Latest {$CashBill.CashBill}' where labelbol='LATESTCASHBILL' and languagetype='en';
update ld_desk set fieldlabel='Latest {$Expense.Expense}' where labelbol='LATESTEXPENSE' and languagetype='en';
update ld_desk set fieldlabel='Latest {$PutCash.PutCash}' where labelbol='LATESTPUTCASH' and languagetype='en';
update ld_desk set fieldlabel='Latest {$CashDeposit.CashDeposit}' where labelbol='LATESTCASHDEPOSIT' and languagetype='en';

update ld_desk set fieldlabel='The Last 7 Days Calendar' where labelbol='OVERSERVENDAYSSCHEDULE' and languagetype='en';
update ld_desk set fieldlabel='The Next 7 Days Calendar' where labelbol='FUTURESEVENDAYSSCHEDULE' and languagetype='en';

update ld_desk set fieldlabel='Statistical Data for This Week' where labelbol='THESTATICOFTHISWEEK' and languagetype='en';
update ld_desk set fieldlabel='Statistical Data for Last Week' where labelbol='LASTSTATICOFTHISWEEK' and languagetype='en';
update ld_desk set fieldlabel='Statistical Data for This Month' where labelbol='THESTATICOFTHISMONTH' and languagetype='en';
update ld_desk set fieldlabel='Statistical Data for Last Month' where labelbol='LASTSTATICOFTHISMONTH' and languagetype='en';

update ld_desk set fieldlabel='Sales Data for the Last 6 Months' where labelbol='SALESSIXMONTH' and languagetype='en';
update ld_desk set fieldlabel='My Sales Data for the Last 6 Months' where labelbol='INDIVIDUALSIXMONTH' and languagetype='en';
update ld_desk set fieldlabel='My Groups Sales Data for This Months' where labelbol='SUBORDINATEMOTHSALESDATA' and languagetype='en';
update ld_desk set fieldlabel='My Sales Data for This Months' where labelbol='Penson Month Sales' and languagetype='en';
update ld_desk set fieldlabel='Orders Amount Year-on-year' where labelbol='AMOUNTMONTHCONTRACTYEAR' and languagetype='en';
update ld_desk set fieldlabel='签约金额同比' where labelbol='AMOUNTMONTHCONTRACTYEAR' and languagetype='zh';
update ld_desk set fieldlabel='Received Amount Year-on-year' where labelbol='BACKAMOUNTMONTHYEAR' and languagetype='en';
update ld_desk set fieldlabel='回款金额同比' where labelbol='BACKAMOUNTMONTHYEAR' and languagetype='zh';

update ld_desk set fieldlabel='Accounts Who Need to be Connected Today' where labelbol='TODAYCONTACTCUSTOMER' and languagetype='en';
update ld_desk set fieldlabel='The Next 30 Days & Overdue Payment Plan' where labelbol='WITHINPAYMENTPLAN' and languagetype='en';

update ld_quickactions set presence = 0 where tabid = 6 and related_tabid = 9;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_quickactions set presence = 0 where tabid = @tabid and related_tabid = 9;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','auserwiththesepecifiednamealreadyexists','用户名已经存在','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'auserwiththesepecifiednamealreadyexists' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','auserwiththesepecifiednamealreadyexists','A User with the specified name already exists','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'auserwiththesepecifiednamealreadyexists' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='Latest {$SendCashBill.SendCashBill}' where labelbol='LATESTSENDCASHBILL' and languagetype='en';
update ld_tranlabel set fieldlabel='Deposit Date' where fieldlabel='Existential date';
update ld_tranlabel set fieldlabel='Deposit No' where fieldlabel='Existential single number';
update ld_tranlabel set fieldlabel='Withdraw No' where fieldlabel='Withdraw single number';
update ld_tranlabel set fieldlabel='Account Out' where fieldlabel='Transfer out Account';
update ld_tranlabel set fieldlabel='Account In' where fieldlabel='Transfer in Account';

select tabid into @tabid from ld_tab where `name`='BankCash';
update ld_tranlabel set fieldlabel='Bank Cash Flow ' where trantable='ld_tab' and Relateid=@tabid and languagetype='en' and fieldlabel='Cash&bank journal';
delimiter;

update ld_desk set fieldlabel='Sharing Rule' where labelbol='LBL_SHARING_ACCESS' and languagetype='en';
update ld_desk set fieldlabel='Departments Setting' where labelbol='USERGROUPLIST' and languagetype='en' and Labeltype='fixedstr';
-- 2016-09-27

update ld_tranlabel set fieldlabel='应付余额'  where trantable='ld_field' and languagetype='zh'  and fieldlabel='应收余额' and Relateid in(select fieldid from ld_field where tabid=21 and COLUMNname='pay_balance');
delimiter;
update ld_desk set fieldlabel='Currency Symbol' where labelbol='CURRENCYSYMBOL' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='Module Management' where labelbol='VTLIB_LBL_MODULE_MANAGER' and languagetype='en';
update ld_desk set fieldlabel='Menu Customization' where labelbol='LBL_TABLIST' and languagetype='en';
update ld_desk set fieldlabel='Cascade Field Setting' where labelbol='LBL_PICKLIST_DEPENDENCY_SETUP' and languagetype='en';

update ld_desk set fieldlabel='Calendar Template Customization' where labelbol='LBL_CALENDAR_TEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='日程模板定制' where labelbol='LBL_CALENDAR_TEMPLATE' and languagetype='zh';
update ld_desk set fieldlabel='Tax Rate Setting' where labelbol='LBL_TAX_SETTINGS' and languagetype='en';

update ld_desk set fieldlabel='Sales and Service Tax on {$Products.Products}' where labelbol='TAXPROSERVICE' and languagetype='en';
update ld_tranlabel set fieldlabel='Surtax' where trantable='ld_inventorytaxinfo' and Relateid=1 and languagetype='en' and fieldlabel='VAT';
update ld_tranlabel set fieldlabel='Sales Tax' where trantable='ld_inventorytaxinfo' and Relateid=2 and languagetype='en' and fieldlabel='Potentials';
update ld_tranlabel set fieldlabel='Service Tax' where trantable='ld_inventorytaxinfo' and Relateid=3 and languagetype='en' and fieldlabel='Service';
update ld_tranlabel set fieldlabel='Tariff' where trantable='ld_inventorytaxinfo' and Relateid=4 and languagetype='en' and fieldlabel='Tax_Customs';
update ld_tranlabel set fieldlabel='VAT' where trantable='ld_inventorytaxinfo' and Relateid=5 and languagetype='en' and fieldlabel='Tax_Added';
update ld_tranlabel set fieldlabel='Profit Margin' where trantable='ld_inventorytaxinfo' and Relateid=6 and languagetype='en' and fieldlabel='Tax_Profit';
update ld_tranlabel set fieldlabel='Freight Coefficient' where trantable='ld_inventorytaxinfo' and Relateid=7 and languagetype='en' and fieldlabel='Tax_Freight';

update ld_desk set fieldlabel='Backup File Path' where labelbol='BACKUPFILEPATH' and languagetype='en';
update ld_desk set fieldlabel='Automatic Backup' where labelbol='AUTOMATICBACKUP' and languagetype='en';
update ld_desk set fieldlabel='Whether to Enable' where labelbol='WHETHERTOENABLE' and languagetype='en';
update ld_desk set fieldlabel='Backup Frequency' where labelbol='AUTOMATICBACKUPCYCLE' and languagetype='en';
update ld_desk set fieldlabel='Delete Historical Data' where labelbol='DELETETHEBACKUPDATA' and languagetype='en';
update ld_desk set fieldlabel='删除历史数据' where labelbol='DELETETHEBACKUPDATA' and languagetype='zh';
update ld_desk set fieldlabel='Every ' where labelbol='EACH' and languagetype='en';

update ld_desk set fieldlabel='SMTP Server' where labelbol='MAILSERVERNAME' and languagetype='en';
update ld_desk set fieldlabel='Email Address' where labelbol='FROMEMAIL' and languagetype='en';
update ld_desk set fieldlabel='Needs to be Verified' where labelbol='REQIREAUTHEN' and languagetype='en';
update ld_desk set fieldlabel='Select Module' where labelbol='SELECTMODULE' and languagetype='en';

update ld_desk set fieldlabel='Allows Input code' where labelbol='ALLOWTOMODIFY' and languagetype='en';
update ld_desk set fieldlabel='Use Date' where labelbol='USEDATE' and languagetype='en';

update ld_desk set fieldlabel='Warehouse Name' where labelbol='WAREHOUSENAME' and languagetype='en';
update ld_desk set fieldlabel='Applicable Scope' where labelbol='WAREHOUSEADMIN' and languagetype='en';
update ld_desk set fieldlabel='Applicable Scope' where labelbol='APPLICABLESCOPE' and languagetype='en';

update ld_desk set fieldlabel='All Users' where labelbol='ALLTHEUSERS' and languagetype='en';
update ld_desk set fieldlabel='Part of the Users' where labelbol='SELECTTHEUSERS' and languagetype='en';
update ld_desk set fieldlabel='Back to Top' where labelbol='BACKTOTOP' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='Overdue Calendars' where labelbol='EXPIREDAGENDA' and languagetype='en';
update ld_desk set fieldlabel='Received Amount Year-on-year' where labelbol='BACKAMOUNTMONTHYEAR' and languagetype='en';
update ld_desk set fieldlabel='回款金额同比' where labelbol='BACKAMOUNTMONTHYEAR' and languagetype='zh';

update ld_desk set fieldlabel='Set Permissions' where labelbol='SETTHEPERMISSIONS' and languagetype='en';
update ld_desk set fieldlabel='Login Records' where labelbol='LOGINHISTORY' and languagetype='en';
update ld_desk set fieldlabel='Login Time' where labelbol='LOGINTIME' and languagetype='en';
update ld_desk set fieldlabel='Logout Time' where labelbol='LOGOUTTIME' and languagetype='en';
update ld_desk set fieldlabel='Login Verification Code' where labelbol='LBL_SECURITYCODE_SET' and languagetype='en';
update ld_desk set fieldlabel='Machine Name' where labelbol='MACHINENAME' and languagetype='en';
update ld_desk set fieldlabel='Use Mobile Authentication' where labelbol='WHETHERTHEMOBILELANGING' and languagetype='en';


update ld_desk set fieldlabel='Is Default' where labelbol='WHETHERDEFAULT' and languagetype='en';
update ld_desk set fieldlabel='Available Staff' where labelbol='APPLICABLEPERSONNEL' and languagetype='en';
update ld_desk set fieldlabel='Available Staff' where labelbol='Applicable personnel' and languagetype='en';
update ld_desk set fieldlabel='Approve Requirements' where labelbol='APPROVEDEMAND' and languagetype='en';

update ld_desk set fieldlabel='Enable Editing' where labelbol='ALLOWEDITING' and languagetype='en';
update ld_desk set fieldlabel='Mandatory Field' where labelbol='MANDATORYFIELDS' and languagetype='en';
update ld_desk set fieldlabel='Mandatory Field' where labelbol='LBL_MANDATORYFIELDS' and languagetype='en';
update ld_desk set fieldlabel='Mandatory Field' where labelbol='REQUIREDFIELDS' and languagetype='en';
update ld_desk set fieldlabel='Mandatory Field' where labelbol='Required_fields' and languagetype='en';
update ld_desk set fieldlabel='Mandatory field can not be empty:' where labelbol='REQUIREDCANOTEMPTY' and languagetype='en';
update ld_desk set fieldlabel='Mandatory field can not be empty:' where labelbol='ERR_MISSING_REQUIRED_FIELDS' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='Basic Properties' where labelbol='BASICPROPERTIES' and languagetype='en';
update ld_desk set fieldlabel='Advanced Properties' where labelbol='ADVANCEDPROPERTIES' and languagetype='en';
update ld_desk set fieldlabel='Input Mode' where labelbol='INPUTMODE' and languagetype='en';
update ld_desk set fieldlabel='Related field' where labelbol='ATTRIBUTEFIELD' and languagetype='en';
update ld_desk set fieldlabel='相关字段' where labelbol='ATTRIBUTEFIELD' and languagetype='zh';
update ld_desk set fieldlabel='Editing Steps' where labelbol='editingsteps' and languagetype='en';
update ld_desk set fieldlabel='Display Enabled' where labelbol='WHETHERTODISPLAY' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='Rapid Creation' where labelbol='Quickly_create' and languagetype='en';
update ld_desk set fieldlabel='Rapid Creation Setting' where labelbol='ASSOCIATIONTOCREATESET' and languagetype='en';
update ld_tranlabel set fieldlabel='Contact Information' where trantable='ld_blocks' and fieldlabel='联系信息' and languagetype='en';
update ld_desk set fieldlabel='Hidden Fields' where labelbol='HIDDENFIELDS' and languagetype='en';

select max(sequence)+1 into @sequence from ld_systems_deploy where roottype = 2;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,112,'供应商是否启用审批流程。1:否，0:是','Vendors',@sequence,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=112);
delimiter;

CALL AddColumn('ld_vendor','approveby','int','19','0');
CALL AddColumn('ld_vendor','approvestatus','varchar','200','');
alter table ld_vendor alter approvestatus set default '未提交';
call fieldprofile('Vendors');
delimiter;
call getallprofile('Vendors');
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_vendor',131,'approveby','审批人',(select blockid from ld_blocks where blocklabel='LBL_VENDOR_INFORMATION'),1,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_vendor',130,'approvestatus','审批状态',(select blockid from ld_blocks where blocklabel='LBL_VENDOR_INFORMATION'),1,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

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

select tabid into @tabid from ld_tab where name='Vendors';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'供应商默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='供应商默认流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='供应商默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

update ld_approve_seq set id=(select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;



select max(sequence)+1 into @sequence from ld_systems_deploy where roottype = 2;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,113,'供应商联系人是否启用审批流程。1:否，0:是','VendorContact',@sequence,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=113);
delimiter;

CALL AddColumn('ld_vendorcontacts','approveby','int','19','0');
CALL AddColumn('ld_vendorcontacts','approvestatus','varchar','200','');
alter table ld_vendorcontacts alter approvestatus set default '未提交';
call fieldprofile('VendorContact');
delimiter;
call getallprofile('VendorContact');
delimiter;

select tabid into @tabid from ld_tab where name='VendorContact';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_vendorcontacts',131,'approveby','审批人',(select blockid from ld_blocks where blocklabel='LBL_VendorContact_INFORMATION'),1,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_vendorcontacts',130,'approvestatus','审批状态',(select blockid from ld_blocks where blocklabel='LBL_VendorContact_INFORMATION'),1,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

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

select tabid into @tabid from ld_tab where name='VendorContact';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'供应商联系人默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='供应商联系人默认流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='供应商联系人默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

update ld_approve_seq set id=(select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECONTACTAPPROVER',' 请联系审批人：','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PLEASECONTACTAPPROVER' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECONTACTAPPROVER',' Please contact the approver:','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PLEASECONTACTAPPROVER' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASECONTACTCHECKER',' 请联系审核人：','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PLEASECONTACTCHECKER' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASECONTACTCHECKER',' Please contact the checker:','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'PLEASECONTACTCHECKER' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEALSTATUS1ORDELETED','该审批流程已经被禁用或者删除，请联系系统管理员！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'APPROVEALSTATUS1ORDELETED' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEALSTATUS1ORDELETED','The approval process has been disabled or deleted, please contact the system administrator!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'APPROVEALSTATUS1ORDELETED' and labeltype='jspop' and languagetype='en');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILEDFORORDERHASAPPROVED','单据[%s]%s不成功！原因：该单据已审批! 请联系审批人：%s','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'FAILEDFORORDERHASAPPROVED' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILEDFORORDERHASAPPROVED','Document[%s] %s no success! The reason: The document had been approved! Please contact approver:%s','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'FAILEDFORORDERHASAPPROVED' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILEDFORORDERISAPPROVING','单据[%s]%s不成功！原因：该单据正在审批中! 请联系审批人：%s','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'FAILEDFORORDERISAPPROVING' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILEDFORORDERISAPPROVING','Document[%s] %s no success! The reason: The document has been pending! Please contact approver:%s','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'FAILEDFORORDERISAPPROVING' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILEDFORORDERISREJECTED','单据[%s]%s不成功！原因：该单据已拒绝! 请联系审批人：%s','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'FAILEDFORORDERISREJECTED' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILEDFORORDERISREJECTED','Document[%s] %s no success! The reason: The document has been rejected! Please contact approver:%s','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'FAILEDFORORDERISREJECTED' and labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2016-09-28

update ld_tab set printtab=1 where name = 'ServiceCharge';
delimiter;

insert into ld_customreport_folder(folder_name,sequence,systemdefault,visible,description)
select '统计图表(Statistical Charts)',0,1,0,'Statistical Charts' from dual 
where not exists (select 1 from ld_customreport_folder where (description='Statistical Charts' or folder_name='客户统计图表(Statistical Report Of Account)') and systemdefault=1);
delimiter; 

insert into ld_customreport_folder(folder_name,sequence,systemdefault,visible,description)
select '同比环比分组统计(YoY and MoM)',0,1,0,'YoY and MoM' from dual 
where not exists (select 1 from ld_customreport_folder where (description='YoY and MoM' or folder_name='联系记录统计图表(Statistical Report Of Contact Records)') and systemdefault=1);
delimiter;

SELECT id into @id from ld_customreport_folder where description='Statistical Charts';
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'回款金额TOP50','template','default_account_cashbilltop50.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_cashbilltop50.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'回款金额TOP10','template','default_account_cashbilltop10.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_cashbilltop10.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'年营业额分布统计图','template','default_account_AnnualRevenue.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_AnnualRevenue.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'客户状态分布统计图','template','default_account_CustomersStatus.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_CustomersStatus.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'重要级别分布统计图','template','default_account_ImportantLevel.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_ImportantLevel.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'所属行业分布统计图','template','default_account_Industry.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_Industry.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'注册资金分布统计图','template','default_account_RegisteredCapital.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_RegisteredCapital.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'客户关系分布统计图','template','default_account_Relations.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_Relations.mrt' and systemdefault=1);

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'人员规模分布统计图','template','default_account_Staffsize.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_Staffsize.mrt' and systemdefault=1);
delimiter; 
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype)
SELECT @id,'客户来源分布统计图','template','default_account_CustomersSource.mrt',100,0,1,0,'Accounts' from DUAL
where not exists (select 1 from ld_customreport_info where report_template='default_account_CustomersSource.mrt' and systemdefault=1);
delimiter; 


update ld_customreport_folder set folder_name='数据报表(Tabular Data Reports)' where folder_name='报表库(Report Library)' and systemdefault=1;
update ld_customreport_folder set description='Tabular Data Reports' where folder_name='数据报表(Tabular Data Reports)' and systemdefault=1;

update ld_customreport_folder set folder_name='统计图表(Statistical Charts)' where folder_name='客户统计图表(Statistical Report Of Account)' and systemdefault=1;
update ld_customreport_folder set description='Statistical Charts' where folder_name='统计图表(Statistical Charts)' and systemdefault=1;

update ld_customreport_folder set folder_name='同比环比分组统计(YoY and MoM)' where folder_name='联系记录统计图表(Statistical Report Of Contact Records)' and systemdefault=1;
update ld_customreport_folder set description='YoY and MoM' where folder_name='同比环比分组统计(YoY and MoM)' and systemdefault=1;
delimiter;

update ld_customreport_info a
LEFT JOIN ld_tab b on a.setype=b.`name`
set a.presence=b.presence
where b.presence in (1,5);
delimiter;
 
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;
select 
	ifnull(b.fieldlabel,'') into @tabname
from ld_tab a
LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh'
where a.tabid=22 limit 1;

update ld_customreport_info set setype='SalesOrder',folder_id=@id,sequence=1,report_describe=concat('数据来源：',@tabname) 
where report_template='default_salesorder_avg_amount.mrt' and systemdefault=1;

select 
	ifnull(b.fieldlabel,'') into @tabname
from ld_tab a
LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh'
where a.tabid=6 limit 1;
update ld_customreport_info set report_name=CONCAT(@tabname,'回款金额TOP10'),folder_id=@id,sequence=2,report_describe=concat('数据来源：',@tabname) 
where report_template='default_account_cashbilltop10.mrt' and systemdefault=1;

update ld_customreport_info set report_name=CONCAT(@tabname,'回款金额TOP50'),folder_id=@id,sequence=3,report_describe=concat('数据来源：',@tabname) 
where report_template='default_account_cashbilltop50.mrt' and systemdefault=1;

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='account_type' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=4,report_describe=concat('数据来源：',@tabname) 
where report_template='default_account_category_distribution.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='account_type' and presence in (1,5)) and report_name='default_account_category_distribution.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='rating' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=5,report_describe=concat('数据来源：',@tabname) 
where report_template='default_account_CustomersStatus.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='rating' and presence in (1,5)) and report_name='default_account_CustomersStatus.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='leadsource' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=6,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_CustomersSource.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='leadsource' and presence in (1,5)) and report_name='default_account_CustomersSource.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='important_level' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=7,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_ImportantLevel.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 where exists (select 1 from ld_field where tabid=6 and columnname='important_level' and presence in (1,5)) and report_name='default_account_ImportantLevel.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='industry' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=8,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_Industry.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 where exists (select 1 from ld_field where tabid=6 and columnname='industry' and presence in (1,5)) and report_name='default_account_Industry.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='accountrelationship' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=9,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_Relations.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='accountrelationship' and presence in (1,5)) and report_name='default_account_Relations.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='accountsize' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=10,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_Staffsize.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='accountsize' and presence in (1,5)) and report_name='default_account_Staffsize.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='annualincome' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=11,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_AnnualRevenue.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='annualincome' and presence in (1,5)) and report_name='default_account_AnnualRevenue.mrt';

select 
	b.fieldlabel into @reporttype
from ld_field a
LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
where a.tabid=6 and a.columnname='registeredcapital' limit 1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计'),folder_id=@id,sequence=12,report_describe=concat('数据来源：',@tabname)
where report_template='default_account_RegisteredCapital.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=6 and columnname='registeredcapital' and presence in (1,5)) and report_name='default_account_RegisteredCapital.mrt';

select tabid into @tabid from ld_tab where `name`='ContactRecords';
select 
	ifnull(b.fieldlabel,'') into @tabname
from ld_tab a
LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh'
where a.tabid=@tabid limit 1;
update ld_customreport_info set report_name=CONCAT(
	(select 
		b.fieldlabel
	from ld_field a
	LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh'
	where a.tabid=@tabid and a.columnname='contactrecordtype' limit 1),'分布统计'),folder_id=@id,sequence=13,report_describe=concat('数据来源：',@tabname)
where report_template='default_ContactRecords_ContactType.mrt' and systemdefault=1;
update ld_customreport_info set presence=5 
where exists (select 1 from ld_field where tabid=@tabid and columnname='contactrecordtype' and presence in (1,5)) and report_name='default_ContactRecords_ContactType.mrt';
delimiter;
-- 2016-09-29

update ld_desk set fieldlabel='预算（关联{$Potentials.Potentials})' where labelbol='Expect_Description' and languagetype='zh';
update ld_desk set fieldlabel='Expect(Related to {$Potentials.Potentials})' where labelbol='Expect_Description' and languagetype='en';

call AddColumn('ld_invoice','stockpresence','varchar','50','');
delimiter;
call AddColumn('ld_purchaseinvoice','stockpresence','varchar','50','');
delimiter;

set @tabid=23;
select blockid into @blockid from ld_blocks where tabid=23 and blocklabel='LBL_INVOICE_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'stockpresence','ld_invoice',2,'stockpresence','出库状态',@blockid,1,0,'V~O',2,1,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'stockpresence');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'stockpresence';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'出库状态' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Batabase State' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='purchaseinvoice';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PURCHASEINVOICE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'stockpresence','ld_purchaseinvoice',2,'stockpresence','入库状态',@blockid,1,0,'V~O',2,1,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'stockpresence');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'stockpresence';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'入库状态' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Batabase State' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
  
delete from ld_option_showheader_label where fieldlabel='CONTRACTINFO' or fieldlabel='CONTRACTPAIDTOTALAMOUNT' or fieldlabel='CONTRACTLATESTDATEOFPAYMENT'
or fieldlabel='LATESTDATEOFRECEIPT' or fieldlabel='CONTRACTRECIVETOTAL'  or fieldlabel='CONTRACTLATESTDATEOFRECEIPT';
delimiter;
-- 2016-09-30

update ld_desk set fieldlabel='已开票总额' where labelbol='HASBILLINGAMOUNT' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set fieldlabel='Workplan Templates Customization' where labelbol='LBL_CUSTOMLOGTEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='日志模板定制' where labelbol='LBL_CUSTOMLOGTEMPLATE' and languagetype='zh';
delimiter;
update ld_desk set fieldlabel='Work Collaboration Customization' where labelbol='LBL_WORK_TEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='工作协同定制' where labelbol='LBL_WORK_TEMPLATE' and languagetype='zh';
delimiter;
update ld_users set approvestatus = 1 where approvestatus = 0 and (approveby = 0 or approveby is NULL);
delimiter;
-- 2016-10-08

update ld_desk set fieldlabel='实际（关联{$SalesOrder.SalesOrder}/{$ServiceContracts.ServiceContracts})' where labelbol='Actual_Description' and languagetype='zh';
update ld_desk set fieldlabel='Actual(Related to {$SalesOrder.SalesOrder}/{$ServiceContracts.ServiceContracts})' where labelbol='Actual_Description' and languagetype='en'; 

update ld_desk set fieldlabel='Workreport Templates Customization' where labelbol='LBL_WORK_TEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='日志模板定制' where labelbol='LBL_WORK_TEMPLATE' and languagetype='zh';

update ld_desk set fieldlabel = 'Allows Input Code' where labelbol = 'ALLOWTOMODIFY' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Current Serial Number' where labelbol = 'CURRENTCODE' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = "Use User's Account" where labelbol = 'USEUSERACCOUNT' and languagetype = 'en' and Labeltype = 'fixedstr';

update ld_desk set fieldlabel = 'Incoming Call Number Matching Fields' where labelbol = 'PHONECALLINFIELDS' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Software Vendors' where labelbol = 'SOFTWAREVENDORS' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Software Version' where labelbol = 'SOFTWAREVERSION' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Account Database Name' where labelbol = 'ZHANGTAONAME' and languagetype = 'en';

update ld_desk set fieldlabel='自动提醒设置' where labelbol='LBL_AUTOMATICREMINDS_SET' and languagetype='zh';
update ld_desk set fieldlabel='Automatic Tasks Setting' where labelbol='LBL_AUTOMATIC_TASK' and languagetype='en';
update ld_desk set fieldlabel='Whether to Enable' where labelbol='WHETHERTOENABLE' and languagetype='en';
update ld_desk set fieldlabel='Common Task' where labelbol='LBL_AUTOMATICTASK_CUSTOMIZED' and languagetype='en';

update ld_desk set fieldlabel='提醒时间参考字段' where labelbol='REMINDTIME' and languagetype='zh';
update ld_desk set fieldlabel='Reminder Time Related Field' where labelbol='REMINDTIME' and languagetype='en';
update ld_desk set fieldlabel='重复次数' where labelbol='REPEATTIMES' and languagetype='zh';
update ld_desk set fieldlabel='Repeated Times' where labelbol='REPEATTIMES' and languagetype='en';
update ld_desk set fieldlabel='重复方式' where labelbol='REPEATMODE' and languagetype='zh';
update ld_desk set fieldlabel='Repeated Way' where labelbol='REPEATMODE' and languagetype='en';
update ld_desk set fieldlabel='Reminder Way' where labelbol='REMINDMETHOD' and languagetype='en';
update ld_desk set fieldlabel='Related Module' where labelbol='Related_modules' and languagetype='en';

update ld_desk set fieldlabel='Set the Content Format' where labelbol='SETTHECONTENTFORMAT' and languagetype='en';
update ld_desk set fieldlabel='Variable Information' where labelbol='VARIABLEINFORMATION' and languagetype='en';
update ld_desk set fieldlabel='Content Template' where labelbol='ACONTENTTEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='Reminder People' where labelbol='REMINDERPEOPLE' and languagetype='en';
update ld_desk set fieldlabel='Select Field' where labelbol='Select_field' and languagetype='en';
update ld_desk set fieldlabel='Reminder Content' where labelbol='REMINDSCONTENT' and languagetype='en';

update ld_desk set fieldlabel='Assessment Elements' where labelbol='Performance_measures' and languagetype='en';
update ld_desk set fieldlabel='Performance Scores' where labelbol='Performance_scores' and languagetype='en';
update ld_desk set fieldlabel='Setting The Approval Parameters' where labelbol='SETPARAMFORAPPROVAL' and languagetype='en';
update ld_desk set fieldlabel='Template Name' where labelbol='TEMLATENAME' and languagetype='en';
update ld_desk set fieldlabel='Modified By' where labelbol='MODIFIEDBY' and languagetype='en';
update ld_desk set fieldlabel='Modified Time' where labelbol='MODIFIEDTIME' and languagetype='en';

update ld_desk set fieldlabel='Source Field' where labelbol='SOURCEFIELD' and languagetype='en';
update ld_desk set fieldlabel='Target Field' where labelbol='TARGETFIELD' and languagetype='en';
update ld_desk set fieldlabel='Approval Parameters' where labelbol='THEAPPROVALPARAMENTERS' and languagetype='en';
update ld_desk set fieldlabel='Reminder Parameters' where labelbol='REMINDERPARAMENERS' and languagetype='en';
update ld_desk set fieldlabel='Business Parameters' where labelbol='Businessparameters' and languagetype='en';
update ld_desk set fieldlabel='菜单名称' where labelbol='PARENTMENU' and languagetype='zh';
update ld_desk set fieldlabel='Menu Name' where labelbol='PARENTMENU' and languagetype='en';

update ld_desk set fieldlabel='Display Order' where labelbol='DISPLAYORDER' and languagetype='en';
update ld_desk set fieldlabel='添加菜单' where labelbol='ADDMAINMENU' and languagetype='zh';
update ld_desk set fieldlabel='Add Menu' where labelbol='ADDMAINMENU' and languagetype='en';
update ld_desk set fieldlabel='菜单名称' where labelbol='PARENTMENUNAME' and languagetype='zh';
update ld_desk set fieldlabel='Menu Name' where labelbol='PARENTMENUNAME' and languagetype='en';
update ld_desk set fieldlabel='中文名称' where labelbol='ZHPARENTMENUNMAE' and languagetype='zh';
update ld_desk set fieldlabel='Chinese Name' where labelbol='ZHPARENTMENUNMAE' and languagetype='en';
update ld_desk set fieldlabel='英文名称' where labelbol='ENPARENTMENUNMAE' and languagetype='zh';
update ld_desk set fieldlabel='English  Name' where labelbol='ENPARENTMENUNMAE' and languagetype='en';

update ld_desk set fieldlabel='显示的功能模块' where labelbol='SUBMODULEDISPLAY' and languagetype='zh';
update ld_desk set fieldlabel='Display Modules' where labelbol='SUBMODULEDISPLAY' and languagetype='en';
update ld_desk set fieldlabel='All Modules' where labelbol='ALLMODULES' and languagetype='en';
update ld_desk set fieldlabel='Display Modules' where labelbol='DISPLAYMODULE' and languagetype='en';
update ld_desk set fieldlabel='Invisible Roles Setting' where labelbol='INVISIBLEROLESET' and languagetype='en';
update ld_desk set fieldlabel='All Roles' where labelbol='ALLROLES' and languagetype='en';
update ld_desk set fieldlabel='Invisible Roles' where labelbol='INVISIBLEROLES' and languagetype='en';

update ld_desk set fieldlabel='Track Group Name' where labelbol='TRACKGROUPNAME' and languagetype='en';
update ld_desk set fieldlabel='Track Period' where labelbol='TRACKPERIOD' and languagetype='en';
update ld_desk set fieldlabel='Start and Stop Time' where labelbol='STARTSTOPTIME' and languagetype='en';
update ld_desk set fieldlabel='Number of Members' where labelbol='NUMBEROFMEMBER' and languagetype='en';

update ld_desk set fieldlabel='Modify rule' where labelbol='MODIFYRULE' and languagetype='en';
update ld_desk set fieldlabel='Global Sharing Rules' where labelbol='GLOBALSHARE' and languagetype='en';
update ld_desk set fieldlabel='Group Name' where labelbol='GROUPNAME' and languagetype='en';
update ld_desk set fieldlabel='Group Name' where labelbol='Group_name' and languagetype='en';
update ld_desk set fieldlabel='Superior Department' where labelbol='LBL_SUPEGROUP' and languagetype='en';

update ld_desk set fieldlabel='Search Keyword' where labelbol='Find_Keyword' and languagetype='en';
update ld_tranlabel set fieldlabel='User Name' where trantable='ld_field' and tabid=29 and Relateid=475 and fieldlabel='User name';

update ld_desk set fieldlabel='Insert into Template' where labelbol='INSERTEDINTOTHECONTENTTEMPLATE' and languagetype='en';
update ld_desk set fieldlabel='The Recipient Information' where labelbol='THERECIPIENTINFORMATION' and languagetype='en';
update ld_desk set fieldlabel='SMS Content' where labelbol='SMS_content' and languagetype='en';
update ld_desk set fieldlabel='Set the Message Format' where labelbol='SETHEMESSAGEFORMAT' and languagetype='en';

CREATE TABLE IF NOT EXISTS `ld_workrangenote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `type` int(1) NOT NULL,
  `entitytype` varchar(20) NOT NULL,
  `rang_group` text,
  `rang_group_name` text,
  `rang_users` text,
  `rang_users_name` text,
  `comment_execution` varchar(100) NOT NULL,
  `comment_execution_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LBL_CONF_MAILSERVER_ERROR','邮件服务器链接异常，请在控制面板设置“邮件服务器“','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_CONF_MAILSERVER_ERROR' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LBL_CONF_MAILSERVER_ERROR','Por favor configure seu servidor de envio de mensagens em Configurações --> link Servidor de Envio','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_CONF_MAILSERVER_ERROR' and Labeltype = 'jspop');
delimiter;

update ld_option_showtableheader set special_column_op='[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"Stock"}]'
where module='purchaseinvoice' and selectmodule='Stock';

update ld_option_showtableheader set special_column_op='[{"columnname":"invoicetotal","show_style":"totalamount","modulename":"OutboundOrder"}]'
where module='invoice' and selectmodule='OutboundOrder';
delimiter;
-- 2016-10-09

select tabid into @tabid from ld_tab where name='outboundorder';
select tabid into @option_tabid from ld_tab where name='stock';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid ,@option_tabid,0,0,0,4 from dual where not EXISTS(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
call AddColumn('ld_stock','stockpresence','varchar','50','');
select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'stockpresence','ld_stock',2,'stockpresence','出库状态',@blockid,1,0,'V~O',2,31,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'stockpresence');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'stockpresence';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'出库状态' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Batabase State' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHOOSEINCLUDEMORETHANACCOUNT','您选择的记录包含多个{$Accounts.Accounts}的单据，只允许选则同一个{$Accounts.Accounts}的单据！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEINCLUDEMORETHANACCOUNT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHOOSEINCLUDEMORETHANACCOUNT','The records that you choosed include more than one customer, only allow to choose the same customer''s bills','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEINCLUDEMORETHANACCOUNT' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHOOSEINCLUDEMORETHANVENDORS','您选择的记录包含多个{$Vendors.Vendors}的单据，只允许选则同一个{$Vendors.Vendors}的单据！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEINCLUDEMORETHANVENDORS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHOOSEINCLUDEMORETHANVENDORS','The records that you choosed include more than one supplier, only allow to choose the same supplier''s bills','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEINCLUDEMORETHANVENDORS' and labeltype='fixedstr');
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='accountproperty' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;

INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,CONCAT(@reporttype,'分布统计'),concat('数据来源：',@tabname),'template','default_account_kehuxingzhi.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_account_kehuxingzhi.mrt' and systemdefault=1);
delimiter;
 
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;

INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'签约金额TOP10',concat('数据来源：',@tabname),'template','default_account_qianyuetop10.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_account_qianyuetop10.mrt' and systemdefault=1);
delimiter; 

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;

INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'签约金额TOP50',concat('数据来源：',@tabname),'template','default_account_qianyuetop50.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_account_qianyuetop50.mrt' and systemdefault=1);
delimiter; 

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='bill_state' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,CONCAT(@reporttype,'分布统计'),concat('数据来源：',@tabname),'template','default_account_shengfenfbu.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_account_shengfenfbu.mrt' and systemdefault=1);
delimiter; 

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='smownerid' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,CONCAT(@reporttype,'分布统计'),concat('数据来源：',@tabname),'template','default_account_xiaoshoufuzrtongji.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_account_xiaoshoufuzrtongji.mrt' and systemdefault=1);
delimiter;
 
set @i=0;
update ld_customreport_info set sequence=(@i:=@i+1) where setype='Accounts' ORDER BY sequence;
delimiter; 

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=55 limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'客户联系次数TOP10',concat('数据来源：',@tabname),'template','default_ContactRecords_kehulianxicishuTOP10.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_ContactRecords_kehulianxicishuTOP10.mrt' and systemdefault=1);
delimiter; 

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=55 limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'客户联系次数TOP50',concat('数据来源：',@tabname),'template','default_ContactRecords_kehulianxicishuTOP50.mrt',0,1,0,'Accounts' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_ContactRecords_kehulianxicishuTOP50.mrt' and systemdefault=1);
delimiter; 

set @i=0;
update ld_customreport_info set sequence=(@i:=@i+1) where setype='Accounts' ORDER BY sequence;
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set typeofdata = 'N~M~25,6' where tabid = @tabid and columnname = 'received_amount';
delimiter;

select max(sequence)+1 into @sequence from ld_systems_deploy where roottype = 1;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,114,'外勤签到拍照上传是否可以选择相册图片。1:否，0:是','',@sequence,1,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=114);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',114,114,'外勤签到拍照上传是否可以选择相册图片'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=114);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',114,114,' Field attendance pictures can choose whether to choose a photo album'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=114);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_dashboard_app`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name`     Varchar(255),
  `labelbol`     VARCHAR(255),
  `graphtype`     VARCHAR(255),
  `modulenames`      VARCHAR(255),
  `blockid` int(11),
  `sequence`      Tinyint(4),
  `filter`  Text,
  `image` VARCHAR(255),
  `presence` Varchar(255)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'daylog','STATISTICALDAYLOG',3,'',10,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='daylog' );

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'weeklog','STATISTICALWEEKLOG',3,'',11,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='weeklog' );

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'monthlog','STATISTICALMONTHLOG',3,'',12,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='monthlog' );

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALDAYLOG','日志统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALDAYLOG'
                                               and languagetype='zh' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALDAYLOG','Daylog on statistical','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALDAYLOG'
                                               and languagetype='en' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALWEEKLOG','周计划统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALWEEKLOG'
                                               and languagetype='zh' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALWEEKLOG','Weeklog on statistical','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALWEEKLOG'
                                               and languagetype='en' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALMONTHLOG','月计划统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALMONTHLOG'
                                               and languagetype='zh' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALMONTHLOG','Monthlog  on statistical','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALMONTHLOG'
                                               and languagetype='en' AND Labeltype= 'fixedstr');
INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'signednumber','Contractnumber',1,'SalesOrder,ServiceContracts',6,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='signednumber' and graphtype = 1);

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'signedamount','Contractamount',1,'SalesOrder,ServiceContracts',7,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='signedamount' and graphtype = 1);

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'cashbillamount','STATISTICALRECEIVABLES',1,'CashBill',8,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='cashbillamount' and graphtype = 1);

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'expense_commission','STATISTICALRECEIVABLES',2,'Expense,Commission',9,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='expense_commission' and graphtype = 2);

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'monthweekreport','STATISTICALWEEKMONTH','','',1,2,'dashboard_1' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='monthweekreport');

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'Salesfunnel','SALESFUNNEL','','',2,2,'dashboard_2' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='Salesfunnel');

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'Contractamount','STATISTICALSIGNQUOTA','','',3,2,'dashboard_3' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='Contractamount');

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'Salessituation','SALESSIXMONTH','','',4,2,'dashboard_4' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='Salessituation');

INSERT INTO ld_dashboard_app(name,labelbol,graphtype,modulenames,sequence,presence,image)
SELECT 'Returnamount','BACKAMOUNTMONTHYEAR','','',5,2,'dashboard_5' FROM dual
WHERE NOT exists(SELECT 1 from ld_dashboard_app WHERE name='Returnamount');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALEXPENSECOMMISSION','费用佣金统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALEXPENSECOMMISSION' and languagetype='zh' AND Labeltype= 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALEXPENSECOMMISSION',' The amount of expense and commission','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALEXPENSECOMMISSION' and languagetype='en' AND Labeltype= 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALRECEIVABLES','回款金额龙虎榜','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALRECEIVABLES' and languagetype='zh' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALRECEIVABLES',' The billboard of Receivables','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALRECEIVABLES' and languagetype='en' AND Labeltype= 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALWEEKMONTH','周月统计','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALWEEKMONTH' and languagetype='zh' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALWEEKMONTH',' Weeks and months on statistical','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALWEEKMONTH' and languagetype='en' AND Labeltype= 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALSIGNQUOTA','签约额度同比','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALSIGNQUOTA' and languagetype='zh' AND Labeltype= 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALSIGNQUOTA',' Signed quota month on month','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='STATISTICALSIGNQUOTA' and languagetype='en' AND Labeltype= 'fixedstr');

alter table ld_salesorder alter column sostatus set default '';
update ld_salesorder set sostatus = '' where sostatus is NULL;
alter table ld_servicecontracts alter column contract_status set default '';
update ld_servicecontracts set contract_status = '' where contract_status is NULL;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_attachmentsforsign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `signid` int(11) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `size` varchar(100) DEFAULT NULL,
  `path` text,
  `type` varchar(100) DEFAULT NULL,
  `imagefromtype` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
delimiter;

select fieldid into @fieldid from ld_field where tabid = 13 and columnname = 'potentialid';
update ld_tranlabel set fieldlabel = 'Potentials' where tabid = 13 and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
update ld_tranlabel set fieldlabel = 'Potentials' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'projectid';
update ld_tranlabel set fieldlabel = 'Project' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'projecttaskid';
update ld_tranlabel set fieldlabel = 'ProjectTask' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;

update ld_field set is_checkimportfield=1 where columnname in('accountname','account_no','phone') AND tabid in(SELECT tabid from ld_tab where `name`='ServiceCharge');
delimiter;

select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
SELECT max(sequence) into @seq from ld_customreport_info where folder_id=@id;
update ld_customreport_info set folder_id=@id,sequence=@seq+1 where report_template='default_ContactRecords_ContactType.mrt' and systemdefault=1;
update ld_customreport_info set folder_id=@id,sequence=@seq+2 where report_template='default_ContactRecords_kehulianxicishuTOP10.mrt' and systemdefault=1;
update ld_customreport_info set folder_id=@id,sequence=@seq+3 where report_template='default_ContactRecords_kehulianxicishuTOP50.mrt' and systemdefault=1;

set @i=0;
update ld_customreport_info set sequence=(@i:=@i+1) where folder_id=@id order by sequence;
delimiter;

update ld_customreport_info set setype='SalesOrder' where report_template='default_salesorder_avg_amount.mrt' and systemdefault=1;
update ld_desk set fieldlabel='取消隐藏字段' where labelbol='HIDDENFIELDS' and languagetype='zh' and fieldlabel='隐藏字段';

select tabid into @tabid1 from ld_tab where `name`='Stock';
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=@tabid1 limit 1;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Stock');
select id into @id from ld_customreport_folder where description='Tabular Data Reports' and systemdefault=1 AND visible=0;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'入库对账表',concat('数据来源：',@tabname),'template','default_Stock_ReconciliationReport.mrt',0,1,0,'Stock' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_Stock_ReconciliationReport.mrt' and systemdefault=1);
delimiter;

select tabid into @tabid1 from ld_tab where `name`='OutboundOrder';
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=@tabid1 limit 1;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='OutboundOrder');
select id into @id from ld_customreport_folder where description='Tabular Data Reports' and systemdefault=1 AND visible=0;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'出库对账表',concat('数据来源：',@tabname),'template','default_OutboundOrder_ReconciliationReport.mrt',0,1,0,'OutboundOrder' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_OutboundOrder_ReconciliationReport.mrt' and systemdefault=1);
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='account_type' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计') where report_template='default_account_category_distribution.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'回款金额TOP50') where report_template='default_account_cashbilltop50.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'回款金额TOP10') where report_template='default_account_cashbilltop10.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='rating' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计') where report_template='default_account_CustomersStatus.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='accountrelationship' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计') where report_template='default_account_Relations.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='leadsource' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'分布统计') where report_template='default_account_CustomersSource.mrt';
delimiter;

SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'联系次数TOP10') where report_template='default_ContactRecords_kehulianxicishuTOP10.mrt';
delimiter;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'联系次数TOP50') where report_template='default_ContactRecords_kehulianxicishuTOP50.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='annualincome' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_AnnualRevenue.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='important_level' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_ImportantLevel.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='Industry' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_Industry.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='registeredcapital' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_RegisteredCapital.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='accountsize' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_Staffsize.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='accountproperty' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_kehuxingzhi.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='smownerid' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_xiaoshoufuzrtongji.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'签约金额TOP10') where report_template='default_account_qianyuetop10.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @reporttype from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1;
update ld_customreport_info set report_name=CONCAT(@reporttype,'签约金额TOP50') where report_template='default_account_qianyuetop50.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='Accounts');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=6 and a.columnname='bill_state' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_account_shengfenfbu.mrt';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=6 limit 1;
SELECT ld_tranlabel.fieldlabel  into @modulename from ld_tranlabel where trantable='ld_tab' AND languagetype='zh' AND tabid in(SELECT tabid FROM ld_tab where NAME='ContactRecords');
select b.fieldlabel into @reporttype from ld_field a LEFT JOIN ld_tranlabel b on a.fieldid=b.Relateid and b.trantable='ld_field' and b.languagetype='zh' where a.tabid=55 and a.columnname='contactrecordtype' limit 1;
select id into @id from ld_customreport_folder where description='Statistical Charts' and systemdefault=1 limit 1;
update ld_customreport_info set report_name=CONCAT(@modulename,@reporttype,'分布统计') where report_template='default_ContactRecords_ContactType.mrt';
delimiter;

update ld_customreport_info a 
LEFT JOIN ld_tab b on a.setype=b.`name` set a.presence=b.presence where b.presence in (1,5); 
delimiter;

update ld_customreport_info set setype='ContactRecords' where report_template in('default_ContactRecords_kehulianxicishuTOP10.mrt','default_ContactRecords_kehulianxicishuTOP50.mrt');
delimiter

SELECT id into @id from ld_customreport_folder where description='Statistical Charts';
set @i=0;
update ld_customreport_info set sequence=(@i:=@i+1) where folder_id=@id ORDER BY FIELD(setype,'SalesOrder','Accounts','ContactRecords'),sequence;
delimiter; 

update ld_field set typeofdata = 'N~O' where tabid = 6 and columnname = 'annualrevenue' and uitype = 71;
delimiter;

delete from ld_quickactions where tabid=20 and related_tabid=23;
delimiter;
-- 2016-10-12

update ld_desk set fieldlabel = 'After the end of the initialization and the initial amount of currency can not be changed, do you want to continue?' where labelbol = 'UPDATEBANKCURRENCY' and languagetype = 'en' and labeltype = 'jspop';
delimiter;
update ld_field set typeofdata = 'C~O' where uitype = 56 and typeofdata = 'V~O';
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-9,1,0,'发送短信' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-9);

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLRELATEDMOBILEPHONE','{$Accounts.Accounts}和{$Contacts.Contacts}所有手机及{$HelpDesk.assigned_user_id}手机','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLRELATEDMOBILEPHONE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLRELATEDMOBILEPHONE','ALL related mobile phone','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLRELATEDMOBILEPHONE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTACTSANDSERVERPHONE','{$Contacts.Contacts}和{$HelpDesk.assigned_user_id}手机','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTACTSANDSERVERPHONE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTACTSANDSERVERPHONE','{$Contacts.Contacts} and {$HelpDesk.assigned_user_id} mobile phone','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'CONTACTSANDSERVERPHONE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOBILEPHONE','手机','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'MOBILEPHONE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOBILEPHONE',' mobile phone','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'MOBILEPHONE' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_sendinformcontent(content,type,description)
select '尊敬的客户您好，我们已为您的工单分派了工程师：[var.troubletickets_assigned_user_id_HelpDesk]，联系方式：[var.users_phone_mobile_Users]，预计上门时间：[var.troubletickets_hopetime_HelpDesk]',11,'客户服务单给客户发送短信'
from dual where not exists(select 1 from ld_sendinformcontent where type = 11);

insert into ld_sendinformcontent(content,type,description)
select '[var.troubletickets_assigned_user_id_HelpDesk]您好，已有新的工单分派给您，工单编号：[var.troubletickets_ticket_no_HelpDesk]，客户：[var.troubletickets_account_id_HelpDesk]，联系方式：[var.contacts_mobile_Contacts]（[var.contacts_lastname_Contacts]）',12,'客户服务单给服务人员发送短信'
from dual where not exists(select 1 from ld_sendinformcontent where type = 12);


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TEMPLATEFORACCOUNTS','{$Accounts.Accounts}接收模板','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'TEMPLATEFORACCOUNTS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TEMPLATEFORACCOUNTS','Template for {$Accounts.Accounts}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'TEMPLATEFORACCOUNTS' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TEMPLATEFORSERVICER','{$HelpDesk.assigned_user_id}接收模板','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'TEMPLATEFORSERVICER' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TEMPLATEFORSERVICER','Template for Servicer','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'TEMPLATEFORSERVICER' and labeltype='fixedstr' and languagetype='en');
delimiter;

select max(sequence)+1 into @sequence from ld_systems_deploy where roottype = 3;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,115,'客户服务单分配后是否发送短信通知。1:否，0:是','',@sequence,3,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=115);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',115,115,'客户服务单分配后是否发送短信通知'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=115);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',115,115,' When you distrbute trouble tickets whether to send SMS'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=115);
delimiter;

select tabid into @htabid from ld_tab where name = 'HelpDesk';
select tabid into @ctabid from ld_tab where name = 'CommunicationLog';

SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@htabid,@ctabid,'get_communicationLog',5,'CommunicationLog',0,'',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@htabid AND NAME='get_communicationLog');
delimiter;

update ld_tab set printtab='1' where name = 'ServiceReturn';
delimiter;

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'CashBill','SalesOrder','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'CashBill' and selectmodule = 'SalesOrder');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'CashBill','ServiceContracts','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'CashBill' and selectmodule = 'ServiceContracts');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'CashBill','Invoice','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'CashBill' and selectmodule = 'Invoice');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'CashBill','PaymentPlan','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'CashBill' and selectmodule = 'PaymentPlan');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'CashBill','OutboundOrder','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'CashBill' and selectmodule = 'OutboundOrder');
delimiter;

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'Stock','PurchaseOrder','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'Stock' and selectmodule = 'PurchaseOrder');
delimiter;

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'Stock','PurchaseInvoice','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'Stock' and selectmodule = 'PurchaseInvoice');
delimiter;

update ld_field set displaytype=4  where tabid in(select tabid from ld_tab where name='stock') and columnname='stockpresence';
delimiter;
-- 2016-10-13

CREATE TABLE IF NOT EXISTS `tmp_date` (
  `date` date PRIMARY KEY
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS `insert_tmp_date`;
delimiter ||
CREATE  PROCEDURE `insert_tmp_date`(
)
begin

	declare tmpdate date default NULL;
	
	set @cnt=0;
	set @maxdate=NULL;
	set @mindate=NULL;
	set @enddate=NULL;
	select ifnull(max(date),CURDATE()) into @maxdate from tmp_date;
	select 
		date_sub(ifnull(min(date),CURDATE()),INTERVAL 1 year) into @mindate
	from (
			select min(cashbilldate) date from ld_cashbill
			UNION ALL select min(signed_data) from ld_salesorder
			UNION ALL select min(due_date) from ld_servicecontracts) a;

	select date_add(CURDATE(),interval 2 YEAR) into @enddate;
	select count(1) into @cnt from tmp_date;

	IF @cnt=0 THEN
		set tmpdate=@mindate;
	ELSE
		set tmpdate=date_add(@maxdate,interval 1 day);
	END IF;

	while tmpdate<=@enddate DO 
			insert into tmp_date(date) select tmpdate;
			set tmpdate=date_add(tmpdate,interval 1 day);
	end while; 

end ||
delimiter;

call insert_tmp_date();
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `insert_tmp_date`;
CREATE EVENT `insert_tmp_date`
ON SCHEDULE EVERY 700 DAY STARTS '2016-10-14 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

call insert_tmp_date();
delimiter;

set @module='CashBill';
select tabid into @tabid from ld_tab where `name`=@module;
select block into @blockid from ld_field where tabid=@tabid and columnname='cashbilldate';
set @tablename='ld_cashbill';
set @columnname='cashtype';
set @fieldname='cashtype';
set @zh='收款类型';
set @en='Cash Type';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue='收款';
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

call AddColumn(@tablename,@columnname,'varchar','100','');
delimiter;

call fieldprofile('CashBill');
delimiter;
call getallprofile('CashBill');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_cashtype` (
  `cashtypeid` int(19) NOT NULL AUTO_INCREMENT,
  `cashtype` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL DEFAULT '1',
  `picklist_valueid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cashtypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_cashtype_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from ld_picklistvalues_seq;

set @cashtype='收款';
insert into ld_cashtype(cashtype,presence,picklist_valueid)
select @cashtype,1,@id+1 from dual 
where not exists (select 1 from ld_cashtype where cashtype=@cashtype);

set @cashtype='预收款';
insert into ld_cashtype(cashtype,presence,picklist_valueid)
select @cashtype,1,@id+2 from dual 
where not exists (select 1 from ld_cashtype where cashtype=@cashtype);

select ifnull(max(picklist_valueid),0) into @picklist_valueid from ld_cashtype;
update ld_picklistvalues_seq set id=@picklist_valueid where id<@picklist_valueid;
delimiter;

delete from ld_cashtype_seq;
insert into ld_cashtype_seq(id)
select max(cashtypeid) from ld_cashtype;
delimiter;

update ld_field set presence=1 where (tabid=22 or tabid=37) and  columnname in('discount_percent','discount_amount');
update ld_field set presence=1 where tabid=20 and  columnname in('discount_percent','discount_amount');
update ld_field set presence=1 where tabid=23 and  columnname in('discount_percent','discount_amount');
update ld_field set presence=1 where tabid in(select tabid from ld_tab where name='purchaseinvoice') and  columnname in('discount_percent','discount_amount');
update ld_field set typeofdata='V~M' where tabid in(select tabid from ld_tab where name='attachment' ) and columnname='reltab' and typeofdata='m';
delimiter;

update ld_desk set fieldlabel = 'Contacts and servicer mobile phone' 
where labelbol = 'CONTACTSANDSERVERPHONE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
select tabid into @tabid from ld_tab where name = 'HelpDesk';
update ld_relatedlists set sequence = -1 where tabid = @tabid and name = 'get_communicationLog';
set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence; 
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SERVERPHONE','{$HelpDesk.assigned_user_id}手机','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'SERVERPHONE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SERVERPHONE','Servicer mobile phone','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'SERVERPHONE' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"smownerid","fieldname":"assigned_user_id"}]}'
where module = 'CashBill' and selectmodule = 'OutboundOrder';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"smownerid","fieldname":"assigned_user_id"}]}'
where module = 'CashBill' and selectmodule = 'PaymentPlan';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"smownerid","fieldname":"assigned_user_id"}]}'
where module = 'CashBill' and selectmodule = 'Invoice';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"smownerid","fieldname":"assigned_user_id"}]}'
where module = 'CashBill' and selectmodule = 'ServiceContracts';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"smownerid","fieldname":"assigned_user_id"}]}'
where module = 'CashBill' and selectmodule = 'SalesOrder';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'related_to';
insert into ld_fieldmodulerel(fieldid,module,relmodule,status,sequence)
select @fieldid,'Reminds','TimeSheet',0,0 from DUAL
where not exists(select 1 from ld_fieldmodulerel where fieldid = @fieldid and module = 'Reminds' and relmodule = 'TimeSheet');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set typeofdata = 'D~M' where tabid = @tabid and columnname = 'cashbilldate';
update ld_tabdetailfield set typeofdata = 'N~M~25,6' where tabid = @tabid and columnname = 'source_total';
update ld_tabdetailfield set typeofdata = 'D~M' where tabid = @tabid and columnname = 'due_date';
update ld_tabdetailfield set typeofdata = 'V~M' where tabid = @tabid and columnname = 'remark';
update ld_tabdetailfield set typeofdata = 'N~M~25,6' where tabid = @tabid and columnname = 'rate';
update ld_tabdetailfield set typeofdata = 'N~M' where tabid = @tabid and columnname = 'amount';
delimiter;
-- 2016-10-14

select id into @id from ld_customreport_folder where description='Tabular Data Reports';
select tabid into @tabid from ld_tab where `name`='CashBill';
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=@tabid limit 1;
select ifnull(b.fieldlabel,'') into @tabname1 from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=22 limit 1;
select presence into @presence from ld_tab where `name`='CashBill';

INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'预收款统计表',concat('数据来源：',@tabname,'、',@tabname1),'template','default_cashbill_yushou.mrt',0,1,@presence,'CashBill' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_cashbill_yushou.mrt' and systemdefault=1);
delimiter;

update ld_customreport_info set report_name='出库对账表' where report_name='出库单对账表' and report_template='default_OutboundOrder_ReconciliationReport.mrt';
update ld_customreport_info set report_name='入库对账表' where report_name='入库单对账表' and report_template='default_Stock_ReconciliationReport.mrt';

select tabid into @tabid1 from ld_tab where `name`='OutboundOrder';
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=@tabid1 limit 1;
select id into @id from ld_customreport_folder where description='Tabular Data Reports' and systemdefault=1 AND visible=0;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'合同出库明细表',concat('数据来源：',@tabname),'template','default_salesorder_outbound.mrt',0,1,0,'OutboundOrder' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_salesorder_outbound.mrt' and systemdefault=1);
delimiter;

CREATE TABLE if not exists `ld_list_headerwidth` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `header_width` int(10) DEFAULT NULL,
  `userid` int(19) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `module` varchar(200) DEFAULT NULL,
  `columns` varchar(400) DEFAULT NULL,
  `relateid` int(19) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_list_headerwidth_module_type_userid` (`module`,`type`,`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

update ld_desk set labeltype='fixedstr' where labelbol='LBL_CONF_MAILSERVER_ERROR'; 
delimiter;
-- 2016-10-17

DROP PROCEDURE IF EXISTS `update_cashbill2paymentplan_entitytype`;
delimiter ||
CREATE  PROCEDURE `update_cashbill2paymentplan_entitytype`(
)
begin

	set @cnt=0;
	select count(1) into @cnt from ld_cashbill2paymentplan where entitytypeid>0 and LENGTH(ifnull(entitytype,''))<1;
	IF @cnt>0 THEN

		update ld_cashbill2paymentplan a
		LEFT JOIN ld_crmentity b on a.entitytypeid=b.crmid
		set a.entitytype=b.setype
		where a.entitytypeid>0 and LENGTH(ifnull(a.entitytype,''))<1;

	END IF;

end ||
delimiter;

call update_cashbill2paymentplan_entitytype();
delimiter;

drop trigger if exists update_salesorder_received1; 
delimiter || 
CREATE TRIGGER update_salesorder_received1 
AFTER UPDATE ON ld_cashbill 
FOR EACH ROW 
BEGIN 
 
 call update_sales_total(new.cashbillid);
		
END || 
delimiter; 

drop trigger if exists update_salesorder_received2; 
delimiter;


drop trigger if exists update_salesorder_received3; 
delimiter || 
CREATE TRIGGER update_salesorder_received3
AFTER DELETE ON ld_cashbill2paymentplan 
FOR EACH ROW 
BEGIN 
    IF old.entitytypeid>0 and length(ifnull(old.entitytype,''))>1 THEN
	   call update_sales_total2(old.entitytypeid,old.entitytype);
    END IF;

	IF old.entitytype='PaymentPlan' THEN
		set @id=0;
		set @module=NULL;
		select entitytypeid into @id from ld_paymentplan where paymentplanid=old.entitytypeid;
		select entitytype into @module from ld_paymentplan where paymentplanid=old.entitytypeid;
		IF @id>0 THEN
			call update_sales_total2(@id,@module);
		END IF;

	END IF;
		
END || 
delimiter;

drop trigger if exists update_salesorder_received4; 
delimiter; 


drop trigger if exists update_purchaseorder_received1; 
delimiter || 
CREATE TRIGGER update_purchaseorder_received1 
AFTER UPDATE ON ld_sendcashbill 
FOR EACH ROW 
BEGIN 
 
		call update_purs_total(new.sendcashbillid);
		
END || 
delimiter; 

drop trigger if exists update_purchaseorder_received2; 
delimiter; 

drop trigger if exists update_purchaseorder_received3; 
delimiter || 
CREATE TRIGGER update_purchaseorder_received3
AFTER DELETE ON ld_sendcashbill2payment 
FOR EACH ROW 
BEGIN 
    IF old.entitytypeid>0 and length(ifnull(old.entitytype,''))>1 THEN
	   call update_purs_total2(old.entitytypeid,old.entitytype);
    END IF;

	IF old.entitytype='SendPayment' THEN
		set @id=0;
		select Purchaseorder_id into @id from ld_sendpayment where sendpaymentid=old.entitytypeid;
		IF @id>0 THEN
			call update_purs_total2(@id,'PurchaseOrder');
		END IF;

	END IF;
		
END || 
delimiter;

drop trigger if exists update_purchaseorder_received4; 
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INTENTIONALPRODUCTS','意向{$Products.Products}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'INTENTIONALPRODUCTS' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','INTENTIONALPRODUCTS','Intentional products','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'INTENTIONALPRODUCTS' and labeltype='fixedstr' and languagetype='en');
delimiter;

select tabid into @ctabid from ld_tab where name = 'Contacts';
select tabid into @ptabid from ld_tab where name = 'Project';
select sequence into @sequence from ld_relatedlists where tabid = @ctabid and name = 'get_tickets';
update ld_relatedlists set sequence = sequence+1 where tabid = @ctabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@ctabid,@ptabid,'get_project',@sequence+1,'Project',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@ctabid AND NAME='get_project');
delimiter;
set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @ctabid order by sequence; 
delimiter;

select tabid into @ptabid from ld_tab where name = 'Products';
select tabid into @setabid from ld_tab where name = 'ServiceContracts';
select tabid into @satabid from ld_tab where name = 'SalesOrder';
select sequence into @sequence from ld_quickactions where tabid = @ptabid and related_tabid = @satabid;
update ld_quickactions set sequence = sequence+1 where tabid = @ptabid and sequence > @sequence;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @ptabid,@setabid,@sequence+1,0,'' from dual where not exists(select 1 from ld_quickactions where tabid=@ptabid and related_tabid=@setabid);
delimiter;
set @i=0; 
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @ptabid order by sequence; 
delimiter;

select sequence into @sequence from ld_relatedlists where tabid = @ptabid and name = 'get_salesorder';
update ld_relatedlists set sequence = sequence+1 where tabid = @ptabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@ptabid,@setabid,'get_ServiceContracts',@sequence+1,'ServiceContracts',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@ptabid AND NAME='get_ServiceContracts');
delimiter;

set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @ptabid order by sequence; 
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMER','单据[%s]%s不成功！原因：被分配人[%s]公海客户数量已达上限!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMER' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMER','Document [%s]%s no success! The reason: [%s] has reached the maximum of customers on the high seas','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMER' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REACHMAXCUSTOMERJS','被分配人公海客户数量已达上限!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'REACHMAXCUSTOMERJS' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','REACHMAXCUSTOMERJS','Allocater reached the maximum of customers on the high seas','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'REACHMAXCUSTOMERJS' and labeltype='jspop' and languagetype='en');
delimiter;

ALTER TABLE ld_vendorcontacts MODIFY salutation varchar (50) DEFAULT '';
update ld_field set typeofdata='V~M' where tabid in(select tabid from ld_tab where name='vendorcontact') and columnname='vendorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set typeofdata = 'N~M~25,2' where tabid = @tabid and columnname = 'rate';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_tranlabel set fieldlabel = '源单' where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype = 'zh';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_tranlabel set fieldlabel = '源单' where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype = 'zh';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'entitytypeid';
update ld_tranlabel set fieldlabel = '源单' where tabid = @tabid and trantable = 'ld_tabdetailfield' and Relateid = @tabdetailfieldid and languagetype = 'zh';
delimiter;

update ld_field set typeofdata='V~O'  where tabid in(select tabid from ld_tab where name='contactrecords')
and columnname in('accountid','potentialid','contactid','salesorderid','troubleticketid','projectid','projecttaskid') and typeofdata='i~O';
update ld_field set typeofdata='V~M'  where tabid in(select tabid from ld_tab where name='contactrecords')
and columnname in('accountid','potentialid','contactid','salesorderid','troubleticketid','projectid','projecttaskid') and typeofdata='i~M';
delete from ld_option_showheader_label  where fieldlabel in('CONTRACTINFO','CONTRACTRECIVETOTAL','LATESTDATEOFRECEIPT');
delimiter;

update ld_desk set fieldlabel = '您的权限不足，无权操作任何仓库!<br>可能原因：您没有任何仓库的权限或者仓库没有库存初始化。' 
where labelbol = 'INSUFFICIENTWAREHOUSE' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'You have insufficient privileges,not any warehouse operation!<br>Possible reason: you do not have any rights to warehouse or warehouse <br>without inventory initialization.' 
where labelbol = 'INSUFFICIENTWAREHOUSE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','TEMPLATEREMINDSFORDUEDATELTDATASTART','Start date should be less than or equal to the deadline','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol = 'TEMPLATEREMINDSFORDUEDATELTDATASTART' and languagetype = 'en' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','TEMPLATEREMINDSFORDUEDATELTDATASTART','起始日期应该小于等于截止日期','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol = 'TEMPLATEREMINDSFORDUEDATELTDATASTART' and languagetype = 'zh' and labeltype = 'jspop');

select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set displaytype = 2 where tabid = @tabid and columnname = 'stockpresence';
delimiter;

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'OutboundOrder','SalesOrder','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'OutboundOrder' and selectmodule = 'SalesOrder');

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'OutboundOrder','ServiceContracts','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'OutboundOrder' and selectmodule = 'ServiceContracts');

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'OutboundOrder','Invoice','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'OutboundOrder' and selectmodule = 'Invoice');

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'OutboundOrder','Stock','{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'OutboundOrder' and selectmodule = 'Stock');
delimiter;

SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
set @i=0;
update ld_customreport_info set sequence=(@i:=@i+1) where folder_id=@id ORDER BY FIELD(setype,'OutboundOrder','Stock','CashBill',NULL),sequence;
delimiter; 
-- 2016-10-20


update ld_desk set fieldlabel = '您的权限不足，无权操作任何仓库！<br>可能原因：您没有任何仓库的权限或者仓库没有库存初始化。' 
where labelbol = 'INSUFFICIENTWAREHOUSE' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_field set typeofdata = 'V~O' where tabid = 6 and columnname = 'parentid' and fieldname = 'account_id';
delimiter;
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"vendor_id","fieldname":"vendor_id"}]}'
where module = 'PurchaseInvoice' and selectmodule = 'Stock';
delimiter;
delete from ld_select_related_field where module = 'OutboundOrder' and selectmodule = 'Stock';
delimiter;

update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'SalesOrder';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'ServiceContracts';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'Invoice';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'PaymentPlan';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'OutboundOrder';

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','PurchaseOrder','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'PurchaseOrder');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','PurchaseInvoice','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'PurchaseInvoice');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','SendPayment','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'SendPayment');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','Stock','{"main":[{"table_column_value":"vendor_id","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'Stock');
delimiter;

update ld_desk set fieldlabel ='统计图表' where labelbol='CURQUERYCHART' AND languagetype='zh';
update ld_desk set fieldlabel ='Statistics Charts' where labelbol='CURQUERYCHART' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel = '当前单据已付款，不允许创建付款单！' where labelbol = 'CURRENTHASPAIDNOTALLOWSINGLE' and Labeltype = 'jspop' and languagetype ='zh';
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select fieldid into @viewfieldid from ld_field where tabid = @tabid and fieldname = 'viewothers';
select fieldid into @editfieldid from ld_field where tabid = @tabid and fieldname = 'editothers';
select fieldid into @delfieldid from ld_field where tabid = @tabid and fieldname = 'delothers';
update ld_tranlabel set fieldlabel = '允许查看其他用户的单据(优先于角色权限)' where languagetype = 'zh' and trantable = 'ld_field' and Relateid = @viewfieldid and tabid = @tabid;
update ld_tranlabel set fieldlabel = '允许编辑其他用户的单据(优先于角色权限)' where languagetype = 'zh' and trantable = 'ld_field' and Relateid = @editfieldid and tabid = @tabid;
update ld_tranlabel set fieldlabel = '允许删除其他用户的单据(优先于角色权限)' where languagetype = 'zh' and trantable = 'ld_field' and Relateid = @delfieldid and tabid = @tabid;
delimiter;
update ld_field set defaultvalue = 1 where tabid = @tabid and fieldname = 'viewothers';
delimiter;
-- 2016-10-21

select usereportid into @reportid from ld_usereport where `name`='SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns='ld_users:last_name:last_name:OftenUseReport_Lastname:V' where Usereportid=@reportid and `columns` like 'ld_users:last_name:last_name:%';
update ld_usereportcolumns set realencolumns='ld_singin:createdtime:signedtime:OftenUseReport_Sign in Time:D' where Usereportid=@reportid and `columns` like 'ld_singin:createdtime:signedtime:%';
update ld_usereportcolumns set realencolumns='ld_singin:address:address:OftenUseReport_Sing in Address:V' where Usereportid=@reportid and `columns` like 'ld_singin:address:address:%';
update ld_usereportcolumns set realencolumns='ld_accounts:accountname:accountname:OftenUseReport_Sing in Customer:V' where Usereportid=@reportid and `columns` like 'ld_accounts:accountname:%';
update ld_usereportcolumns set realencolumns='ld_singin:content:content:OftenUseReport_Remark:V' where Usereportid=@reportid and `columns` like 'ld_singin:content:content:%';
update ld_usereportcolumns set realencolumns='ld_accounts:bill_street:bill_street:OftenUseReport_Related to Customer Address:V' where Usereportid=@reportid and `columns` like 'ld_accountbillads:bill_street%';
update ld_usereportcolumns set realencolumns='ld_singin:uuid:uuid:OftenUseReport_Mobile ID:V' where Usereportid=@reportid and `columns` like 'ld_singin:uuid:uuid:%';
update ld_usereportcolumns set realencolumns='ld_singin:distance:distance:OftenUseReport_Distance(m):N' where Usereportid=@reportid and `columns` like 'ld_singin:distance:distance:%';
delimiter;

select usereportid into @reportid from ld_usereport where `name`='SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_Order No:V' where Usereportid=@reportid and `columns` like 'ld_salesorder:salesorder_no:%';
update ld_usereportcolumns set realencolumns='ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill Amount:N' where Usereportid=@reportid and `columns` like 'ld_reporttable:CashBillamount:%';
update ld_usereportcolumns set realencolumns='ld_commission2payment:amount:amount:OftenUseReport_Commission Total:NN' where Usereportid=@reportid and `columns` like 'ld_commission2payment:amount:%';
update ld_usereportcolumns set realencolumns='ld_salesorder:sostatus:sostatus:SalesOrder_Order Status:V' where Usereportid=@reportid and `columns` like 'ld_salesorder:sostatus:%';
update ld_usereportcolumns set realencolumns='ld_salesorder:duedate:duedate:SalesOrder_Due Date:D' where Usereportid=@reportid and `columns` like 'ld_salesorder:duedate:%';
delimiter;

update ld_desk set fieldlabel='Statistics Range of Expense and Commission' where labelbol='EXCOMMTOTAL' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='{$HelpDesk.HelpDesk}历史记录' where labelbol='SERVICE_HISTORY' and languagetype='zh';
update ld_desk set fieldlabel='{$HelpDesk.HelpDesk} History' where labelbol='SERVICE_HISTORY' and languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','lastsales_stage','上一销售阶段','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'lastsales_stage' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','lastsales_stage','LastSales_Stage','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'lastsales_stage' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
update ld_tabdetailfield set typeofdata = 'V~M~200' where tabid = @tabid and columnname = 'expenseuse';
update ld_tabdetailfield set typeofdata = 'V~O~' where tabid = @tabid and columnname = 'expensetype';
update ld_tabdetailfield set typeofdata = 'D~O' where tabid = @tabid and columnname = 'startdate';
update ld_tabdetailfield set typeofdata = 'D~O~' where tabid = @tabid and columnname = 'enddate';
update ld_tabdetailfield set typeofdata = 'V~O~' where tabid = @tabid and columnname = 'entitytypeid';
update ld_tabdetailfield set typeofdata = 'V~M' where tabid = @tabid and columnname = 'currency_id';
update ld_tabdetailfield set typeofdata = 'N~O~25,6' where tabid = @tabid and columnname = 'conversion_rate';
update ld_tabdetailfield set typeofdata = 'N~O~20,8' where tabid = @tabid and columnname = 'money';
update ld_tabdetailfield set typeofdata = 'N~O~20,8' where tabid = @tabid and columnname = 'rmb_total';
update ld_tabdetailfield set typeofdata = 'V~O~' where tabid = @tabid and columnname = 'description';
update ld_tabdetailfield set typeofdata = 'N~O~25,6' where tabid = @tabid and columnname = 'total';
delimiter;

select tabid into @tabid from ld_tab where name  = 'TimeSheet';
update ld_tabdetailfield set typeofdata = 'D~O' where tabid = @tabid and columnname = 'workdate';
update ld_tabdetailfield set typeofdata = 'V~O~50' where tabid = @tabid and columnname = 'timetype';
update ld_tabdetailfield set typeofdata = 'V~O~30' where tabid = @tabid and columnname = 'entitytypeid';
update ld_tabdetailfield set typeofdata = 'V~O~50' where tabid = @tabid and columnname = 'indirectcharge';
update ld_tabdetailfield set typeofdata = 'V~O~50' where tabid = @tabid and columnname = 'costtime';
update ld_tabdetailfield set typeofdata = 'V~O~200' where tabid = @tabid and columnname = 'description';
update ld_tabdetailfield set typeofdata = 'N~O' where tabid = @tabid and columnname = 'sum_direct';
update ld_tabdetailfield set typeofdata = 'N~O' where tabid = @tabid and columnname = 'sum_indirect';
delimiter;
-- 2016-10-25

update ld_desk set fieldlabel='Notsubmitted' where labelbol='Unapproved' and languagetype='en';
update ld_desk set fieldlabel='Approvaling' where labelbol='Approvalof' and languagetype='en';
update ld_desk set fieldlabel='Approved' where labelbol='Approved' and languagetype='en';
update ld_desk set fieldlabel='Rejected' where labelbol='Rejected' and languagetype='en';
update ld_desk set fieldlabel='Dismissed' where labelbol='Dismissed' and languagetype='en';

update ld_desk set fieldlabel='Quickly Create' where labelbol='Quickly_create' and languagetype='en';
update ld_desk set fieldlabel='Quickly Search' where labelbol='QUICKFIND' and languagetype='en';

set @i=0;
select tabid into @tabid from ld_tab where `name`='PaymentPlan';
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=65 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'回款金额同比',concat('数据来源：',@tabname),'template','default_tongbi_payment.mrt',0,1,0,'cashbill' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_tongbi_payment.mrt' and systemdefault=1);
delimiter; 
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=65 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'回款笔数同比',concat('数据来源：',@tabname),'template','default_tongbi_paymentQty.mrt',0,1,0,'cashbill' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_tongbi_paymentQty.mrt' and systemdefault=1);
delimiter; 
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=22 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'合同金额同比',concat('数据来源：',@tabname),'template','default_tongbi_salesorder.mrt',0,1,0,'Salesorder' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_tongbi_salesorder.mrt' and systemdefault=1);
delimiter; 
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=22 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'合同笔数同比',concat('数据来源：',@tabname),'template','default_tongbi_salesorderQty.mrt',0,1,0,'Salesorder' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_tongbi_salesorderQty.mrt' and systemdefault=1);
delimiter; 

update ld_desk set fieldlabel = '显示隐藏字段' where labelbol = 'HIDDENFIELDS' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectProgress';
update ld_field set relate_search_parent_columnname = 'projectid' where tabid = @tabid and columnname = 'projecttaskid';
update ld_field set uitype = 82 where columnname = 'projectid' and uitype = 10;

update ld_tranlabel set fieldlabel='单据分录调用产品时只能选择已审批的产品' 
where languagetype='zh' and trantable='ld_systems_deploy' and relateid=71;
update ld_desk set fieldlabel='您选择的记录包含多个{$Accounts.Accounts}的单据，只允许选择同一个{$Accounts.Accounts}的单据！' 
where labelbol='CHOOSEINCLUDEMORETHANACCOUNT' and labeltype='fixedstr' and languagetype='zh';

update ld_desk set fieldlabel='您选择的记录包含多个{$Vendors.Vendors}的单据，只允许选择同一个{$Vendors.Vendors}的单据！' 
where labelbol='CHOOSEINCLUDEMORETHANVENDORS' and labeltype='fixedstr' and languagetype='zh';
delimiter;

select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=65 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'回款金额环比',concat('数据来源：',@tabname),'template','default_huanbi_payment.mrt',0,1,0,'cashbill' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_huanbi_payment.mrt' and systemdefault=1);
delimiter;
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=65 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'回款笔数环比',concat('数据来源：',@tabname),'template','default_huanbi_paymentQty.mrt',0,1,0,'cashbill' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_huanbi_paymentQty.mrt' and systemdefault=1);
delimiter; 
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=22 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'合同金额环比',concat('数据来源：',@tabname),'template','default_huanbi_paySalesorder.mrt',0,1,0,'Salesorder' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_huanbi_paySalesorder.mrt' and systemdefault=1);
delimiter; 
select ifnull(b.fieldlabel,'') into @tabname from ld_tab a LEFT JOIN ld_tranlabel b on a.tabid=b.Relateid and b.trantable='ld_tab' and b.languagetype='zh' where a.tabid=22 limit 1;
select id into @id from ld_customreport_folder where description='YoY and MoM' and systemdefault=1;
INSERT into ld_customreport_info(folder_id,report_name,report_describe,report_type,report_template,allocatetype,systemdefault,presence,setype)
select @id,'合同笔数环比',concat('数据来源：',@tabname),'template','default_huanbi_SalesorderQty.mrt',0,1,0,'Salesorder' from DUAL where
not exists (select 1 from ld_customreport_info where report_template='default_huanbi_SalesorderQty.mrt' and systemdefault=1);
delimiter;
insert into ld_templateprint(printfilename,tabid,templateprintname,systemdefault,allocatetype)
select 'SalesOrder_sheet01.html',22,'合同快递单模板',1,0 from dual 
WHERE NOT EXISTS(SELECT 1 FROM ld_templateprint where printfilename='SalesOrder_sheet01.html' AND tabid=22);
delimiter;
insert into ld_templateprint(printfilename,tabid,templateprintname,systemdefault,allocatetype)
select 'PurchaseOrder_20161027.html',21,'采购订单预置模板(2)',1,0 from dual 
WHERE NOT EXISTS(SELECT 1 FROM ld_templateprint where printfilename='PurchaseOrder_20161027.html' AND tabid=21);
delimiter;
insert into ld_templateprint(printfilename,tabid,templateprintname,systemdefault,allocatetype)
select 'Quotes_20161027.html',20,'报价单预置模板(2)',1,0 from dual 
WHERE NOT EXISTS(SELECT 1 FROM ld_templateprint where printfilename='Quotes_20161027.html' AND tabid=20);
delimiter;
insert into ld_templateprint(printfilename,tabid,templateprintname,systemdefault,allocatetype)
select 'SalesOrder_medical01.html',22,'医疗行业合同模板',1,0 from dual 
WHERE NOT EXISTS(SELECT 1 FROM ld_templateprint where printfilename='SalesOrder_medical01.html' AND tabid=22);
delimiter;
CALL DelForeignkey('ld_quotes','ld_quotes_ibfk_1');
delimiter;

update ld_desk set fieldlabel = '设定{$HelpDesk.HelpDesk}{$ProjectTask.ProjectTask}绩效考核参数' where labelbol = 'LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION' and languagetype = 'zh' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Set service performance parameters for {$HelpDesk.HelpDesk} {$ProjectTask.ProjectTask}' where labelbol = 'LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION' and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

select  tabid into @tabid  from ld_tab  where name='ServiceContracts';
select max(fieldid) into @maxfieldid from ld_field ;
select blockid into @blockid from ld_blocks where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cashbilldate');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @tabid,@maxfieldid+1 ,'cashbilldate','ld_servicecontracts',1,5,'cashbilldate','收款日期',0,0,26, @blockid,2,'D~O',3,2,0 from DUAL 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='cashbilldate');
select fieldid into @fieldid from ld_field where  tabid=@tabid and columnname='cashbilldate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'zh','ld_field',@tabid,@fieldid,'收款日期' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select 'en','ld_field',@tabid,@fieldid,'Collection Date' from DUAL
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid=@tabid and relateid=@fieldid);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OUTBOUNDCOUNTEQUALZERO','该单据已出库数量为零！请查看系统参数配置','jspop' from dual 
where not exists(select 1 from ld_desk  where languagetype='zh' and labelbol='OUTBOUNDCOUNTEQUALZERO' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OUTBOUNDCOUNTEQUALZERO','The bill has been out of the number of zero! Check system configuration parameters','jspop' from dual 
where not exists(select 1 from ld_desk  where languagetype='en' and labelbol='OUTBOUNDCOUNTEQUALZERO' and labeltype='jspop');
delimiter;

update ld_field set presence = 0 where columnname = 'discount_amount' and fieldname = 'hdnDiscountAmount';
delimiter;
-- 2016-10-28

alter table ld_rate modify column strrole_id text;
alter table ld_rate modify column struser_id text;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_sendcashbill a
				LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
				where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
					
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_purs_total1`;
delimiter ||
CREATE  PROCEDURE `update_purs_total1`(
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
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.Purchaseorder_id,
												'PurchaseOrder' entitytype
										from ld_sendcashbill a 
										LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
										INNER JOIN ld_sendpayment c on c.sendpaymentid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									ORDER BY entitytypeid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=84;
	
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_sendcashbill a
				LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
				LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
				where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
					
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				where h.entitytypeid=@tmp_entitytypeid
				group by h.entitytypeid;

			select
				max(a.cashbilldate) into @purs_date
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
				LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
				where i.Purchaseorder_id=@tmp_entitytypeid
				group by i.Purchaseorder_id;

			select
				max(a.cashbilldate) into @purs_date2
			from ld_sendcashbill a 
			INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_purs_total2`;
delimiter ||
CREATE  PROCEDURE `update_purs_total2`(
	tmp_entitytypeid int(19),
	tmp_entitytype varchar(100)
)
BEGIN
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=84;
	
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
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
		UNION ALL
			select 
				a.currency_id 
			from ld_sendcashbill a
			LEFT JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
			LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.Purchaseorder_id=@tmp_entitytypeid and c.deleted=0
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
				
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

		select
			max(a.cashbilldate) into @purs_date
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
			where i.Purchaseorder_id=@tmp_entitytypeid
			group by i.Purchaseorder_id;

		select
			max(a.cashbilldate) into @purs_date2
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

		select
			max(a.cashbilldate) into @purs_date
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_sendpayment i on h.entitytypeid=i.sendpaymentid
			where i.Purchaseorder_id=@tmp_entitytypeid
			group by i.Purchaseorder_id;

		select
			max(a.cashbilldate) into @purs_date2
		from ld_sendcashbill a 
		INNER JOIN ld_sendcashbill2payment b on a.sendcashbillid=b.sendcashbillid
		LEFT JOIN ld_sendpayment c on b.entitytypeid=c.sendpaymentid
			where a.deleted=0 and c.purchaseorder_id=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
end ||
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_sales_total1`;
delimiter ||
CREATE  PROCEDURE `update_sales_total1`(
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
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									ORDER BY entitytypeid;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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

DROP PROCEDURE IF EXISTS `update_sales_total2`;
delimiter ||
CREATE  PROCEDURE `update_sales_total2`(
	tmp_entitytypeid int(19),
	tmp_entitytype varchar(100)
)
BEGIN
		
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
				where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
			UNION ALL
				select 
					a.currency_id 
				from ld_cashbill a
				LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
				LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
				where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
					and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		where h.entitytypeid=@tmp_entitytypeid
		group by h.entitytypeid;

		select
			max(a.cashbilldate) into @sales_date
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
		where i.entitytypeid=@tmp_entitytypeid
		group by i.entitytypeid;
						
		select
			max(a.cashbilldate) into @sales_date2
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
		where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
		set @sales_date=NULL;
		set @sales_total2=0.00;
		set @sales_date2=NULL;
			
		select
			sum(h.amount) into @sales_total
		from (
			select 
				a.cashbillid,
				b.entitytypeid,
				b.amount/a.conversion_rate as amount
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		where h.entitytypeid=@tmp_entitytypeid
		group by h.entitytypeid;

		select
			max(a.cashbilldate) into @sales_date
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
		where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
			where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
							and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
		LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
		where i.entitytypeid=@tmp_entitytypeid
		group by i.entitytypeid;
					
		select
			max(a.cashbilldate) into @sales_date2
		from ld_cashbill a 
		INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
		LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
		where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
			and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
end ||
delimiter;

DROP PROCEDURE IF EXISTS `update_sales_total3`;
delimiter ||
CREATE  PROCEDURE `update_sales_total3`(
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
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1
										UNION
										select 
												c.entitytypeid,
												c.entitytype
										from ld_cashbill a 
										LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
										INNER JOIN ld_paymentplan c on c.paymentplanid=b.entitytypeid
										where a.deleted=0 and b.entitytypeid>0 and length(b.entitytype)>1) a
									where entitytype in ('PaymentPlan','Invoice','OutboundOrder')
									ORDER BY entitytypeid;					
									
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_entitytypeid = NULL;
	
	select ifnull(deploy_value,0) into @deploy_value from ld_systems_deploy where deploy_type=83;
	
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
				UNION ALL
					select 
						a.currency_id 
					from ld_cashbill a
					LEFT JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
					LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
					where c.entitytypeid=@tmp_entitytypeid and a.deleted=0 and c.deleted=0
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
						and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) c;
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid 
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
							
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			where h.entitytypeid=@tmp_entitytypeid
			group by h.entitytypeid;

			select
				max(a.cashbilldate) into @sales_date
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID
			where a.deleted=0 and b.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
				where a.deleted=0 and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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
								and IF(e.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)) as g) as h
			LEFT JOIN ld_paymentplan i on h.entitytypeid=i.paymentplanid
			where i.entitytypeid=@tmp_entitytypeid
			group by i.entitytypeid;
						
			select
				max(a.cashbilldate) into @sales_date2
			from ld_cashbill a 
			INNER JOIN ld_cashbill2paymentplan b on a.cashbillid=b.CashBillID 
			LEFT JOIN ld_paymentplan c on b.entitytypeid=c.paymentplanid
			where a.deleted=0 and c.entitytypeid=@tmp_entitytypeid
				and IF(a.checkoutstatus='已审核',1,0) <> IF(@deploy_value=1,0,0.001)
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


insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'PurchaseInvoice','PurchaseOrder','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'PurchaseInvoice' and selectmodule = 'PurchaseOrder');

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'PurchaseInvoice','Stock','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'PurchaseInvoice' and selectmodule = 'Stock');
delimiter;

update  ld_field set approve_demand=(select case when deploy_value=1 then 0 else 1  end  as sys_value from ld_systems_deploy where deploy_type=71 and presence=0)
where uitype=59 and exists(select 1 from ld_systems_deploy where deploy_type=71 and presence=0);

update ld_systems_deploy set presence=1  where deploy_type=71;
delimiter;

update ld_desk set fieldlabel = '您的权限不足，无权操作任何仓库！<br>可能原因：您没有任何仓库的权限或者仓库没有库存初始化。' 
where labelbol = 'INSUFFICIENTWAREHOUSE' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_field set typeofdata = 'V~O' where tabid = 6 and columnname = 'parentid' and fieldname = 'account_id';
delimiter;
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"vendor_id","fieldname":"vendor_id"}]}'
where module = 'PurchaseInvoice' and selectmodule = 'Stock';
delimiter;
delete from ld_select_related_field where module = 'OutboundOrder' and selectmodule = 'Stock';
delimiter;

update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'SalesOrder';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'ServiceContracts';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'Invoice';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'PaymentPlan';
update ld_select_related_field set relatedstring = '{"main":[{"table_column_value":"accountid","fieldname":"account_id"}]}'
where module = 'CashBill' and selectmodule = 'OutboundOrder';

insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','PurchaseOrder','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'PurchaseOrder');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','PurchaseInvoice','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'PurchaseInvoice');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','SendPayment','{"main":[{"table_column_value":"vendorid","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'SendPayment');
insert into ld_select_related_field(module,selectmodule,relatedstring)
select 'SendCashBill','Stock','{"main":[{"table_column_value":"vendor_id","fieldname":"vendor_id"}]}' from DUAL
where not exists(select 1 from ld_select_related_field where module = 'SendCashBill' and selectmodule = 'Stock');
delimiter;

select tabid into @ptabid from ld_tab where name = 'Products';
select tabid into @setabid from ld_tab where name = 'ServiceContracts';
select tabid into @satabid from ld_tab where name = 'SalesOrder';
select sequence into @sequence from ld_quickactions where tabid = @ptabid and related_tabid = @satabid;
update ld_quickactions set sequence = sequence+1 where tabid = @ptabid and sequence > @sequence;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @ptabid,@setabid,@sequence+1,0,'' from dual where not exists(select 1 from ld_quickactions where tabid=@ptabid and related_tabid=@setabid);
delimiter;
set @i=0; 
update ld_quickactions set sequence=(@i:=@i+1) where tabid = @ptabid order by sequence; 
delimiter;

select sequence into @sequence from ld_relatedlists where tabid = @ptabid and name = 'get_salesorder';
update ld_relatedlists set sequence = sequence+1 where tabid = @ptabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@ptabid,@setabid,'get_ServiceContracts',@sequence+1,'ServiceContracts',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@ptabid AND NAME='get_ServiceContracts');
delimiter;

update ld_field set presence = 1 where tabid = 22 and columnname in ('smsfirstdate','smsseconddate','smsthirddate','s_h_amount');
delimiter;
update ld_field set defaultvalue = '' where tabid = 6 and columnname = 'lastcontactdate';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BILLHAVEAPPROVED','该单据已经审批！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BILLHAVEAPPROVED' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BILLHAVEAPPROVED','The bill had approve！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BILLHAVEAPPROVED' and labeltype='fixedstr');
delete from ld_option_showheader_label where fieldlabel='PAIDTOTALAMOUNT' or fieldlabel='LATESTDATEOFPAYMENT';
delimiter;
-- 2016-10-31

call addcolumn('ld_loginhistory','udid','varchar','100',null);
delimiter;

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

update ld_version set old_version='V6.5.0' ,current_version='V6.5.0' ,remark='V6.5.0-20161031';
delimiter;