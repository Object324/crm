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

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MERGECREATE','合并创建{$SalesOrder.SalesOrder}','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MERGECREATE' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MERGECREATE','Merge&Create{$SalesOrder.SalesOrder}','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MERGECREATE' and labeltype = 'fixedstr');
delimiter;
-- 2016-05-18

update ld_desk set fieldlabel = '确认要删除该报表？' where labelbol = 'CONFIRMWANTDELETEREPORTS' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MERGECREATE','合并创建{$SalesOrder.SalesOrder}','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MERGECREATE' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MERGECREATE','Merge&Create{$SalesOrder.SalesOrder}','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MERGECREATE' and labeltype = 'fixedstr');
delimiter;
alter table ld_contactdetails alter approvestatus set default '未提交';
delimiter;

update ld_tranlabel set fieldlabel = '折扣率(%)'
where trantable = 'ld_producttoolfield' and Relateid in (select producttoolfieldid from ld_producttoolfield where uitype = '15' and columnname = 'discount_percent')
and ld_tranlabel.languagetype ='zh';
delimiter;
update ld_tranlabel set fieldlabel = 'Discount rate(%)'
where trantable = 'ld_producttoolfield' and Relateid in (select producttoolfieldid from ld_producttoolfield where uitype = '15' and columnname = 'discount_percent')
and ld_tranlabel.languagetype ='en';
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"version_trade":"finance"}]'
where deploy_type = 89;
delimiter;

UPDATE ld_tranlabel SET fieldlabel = '客户重复是否弹出报备提醒' WHERE trantable = 'ld_system_deploy' AND languagetype = 'zh'
AND tabid = (SELECT tabid from ld_tab where name='GraphicalReports') and Relateid = 95;
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
update ld_field set defaultvalue='100%' where columnname='satisfaction' and tabid=@tabid;
update ld_field set defaultvalue='100%' where columnname='timelyrate' and tabid=@tabid;
update ld_field set defaultvalue='100%' where columnname='resolutionrate' and tabid=@tabid;
update ld_field set defaultvalue='是' where columnname='servant_come' and tabid=@tabid;
delimiter;

SELECT MAX(purchaseinvoicestatusid) INTO @purchaseinvoicestatusid FROM ld_purchaseinvoicestatus;
INSERT INTO ld_purchaseinvoicestatus_seq(id)
SELECT @purchaseinvoicestatusid
FROM DUAL WHERE not EXISTS (SELECT id FROM ld_purchaseinvoicestatus_seq WHERE id <>'');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type= 96;
update ld_systems_deploy set sequence = sequence+1 where sequence > @sequence and roottype = @roottype;
update ld_systems_deploy set sequence = @sequence+1 where deploy_type=100;

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
delete from ld_quickactions where tabid=@tabid and related_tabid=55;
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_usereport set advfilter=0 where name='SalesOrderTrack';
delimiter;
-- 2016-05-19

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select tabid into @related_tabid from ld_tab where `name` = 'Emails';
delete from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid and `name` = 'get_emails';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
update ld_field set relate_search_parent_columnname = 'accountid' where tabid = @tabid and columnname = 'projecttaskid';
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

CALL AddColumn('ld_bangwo8','vendorid','int','11','');
delimiter;

CALL altercolumn('ld_users','supportname','bangwo8_supportname','varchar(50)');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select tabid into @related_tabid from ld_tab where `name` = 'Emails';
delete from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid and `name` = 'get_emails';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
update ld_field set relate_search_parent_columnname = 'accountid' where tabid = @tabid and columnname = 'projecttaskid';
delimiter;

call altercolumn('ld_systems_deploy','deploy_value','deploy_value','TEXT');
delimiter;

INSERT INTO ld_systems_deploy (deploy_value, deploy_type, description, sequence, presence)
SELECT 'http://',101,'呼叫中心地址',74,0 FROM dual
WHERE NOT exists(SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 101);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_jiuweiak_talkrecord`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `userid`     TINYINT(4),
  `usernum`     VARCHAR(25),
  `type`      TINYINT(4),
  `callinphone`  VARCHAR(25),
  `is_bombscreen` TINYINT(4),
  `accountid` INT(11),
  `contactid` INT(11),
  `recordnum` VARCHAR(25),
  `starttime` DATETIME,
  `deadline` DATETIME,
  `talktime` INT(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_users','jw_user','varchar','25',null);
delimiter;
call fieldprofile('Users');
delimiter;
call getallprofile('Users');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select max(sequence) into @sequence from ld_blocks where tabid = @tabid;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,visible,display_status)
select (select max(blockid) from ld_blocks)+1,@tabid,'JW_INTERFACE_INFO',@sequence,1,1 from dual
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'JW_INTERFACE_INFO');
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'JW_INTERFACE_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'九维呼叫中心坐席' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Nine Dimensional CallCenter Setting' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'jw_user','ld_users',2,'jw_user','坐席号',@blockid,1,0,'V~O',2,1,1 from dual
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'jw_user');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'jw_user';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'坐席号' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'UserName' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',101,101,'呼叫中心地址' from dual
where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=101);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',101,101,'Call center address' from dual
where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=101);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PHONECALLINFIELDS','来电号码匹配字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PHONECALLINFIELDS' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PHONECALLINFIELDS','Incoming call number matching field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PHONECALLINFIELDS' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIVIDENDORDERCHANGEDMUSTSAVE','派息单已改变，是否立即保存?','fixedstr' from dual
where not exists(select 1 from ld_desk where LANGUAGetype='zh' and labelbol='DIVIDENDORDERCHANGEDMUSTSAVE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIVIDENDORDERCHANGEDMUSTSAVE','Dividend information has changed, save now?','fixedstr' from dual
where not exists(select 1 from ld_desk where LANGUAGetype='en' and labelbol='DIVIDENDORDERCHANGEDMUSTSAVE' and labeltype='fixedstr');
delimiter;

update ld_modentity_num set semodule = 'TimeSheet' where semodule = 'Timesheet';
delimiter;
-- 2016-05-20

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

update ld_version set old_version='V6.3.4' ,current_version='V6.3.4' ,remark='V6.3.4-20160520';
delimiter;