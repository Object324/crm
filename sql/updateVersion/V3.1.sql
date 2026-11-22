drop procedure if exists `fieldprofile`;
delimiter ||
create procedure fieldprofile
(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from LD_def_org_field where fieldid=',ffieldid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

drop procedure `addtabintoprofile`;
delimiter ||
create procedure addtabintoprofile
(

profileid int(19),
tabname varchar(50)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  LD_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from LD_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;

	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;

 loop1: while  done<>1 DO
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;
		
		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
		prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

          set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

	     set @sql=CONCAT('insert into LD_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from lD_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
              prepare stmt from @sql;
       		 execute stmt;
		deallocate prepare stmt;

		Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

CREATE TABLE if not exists `ld_expense` (
  `expenseid` int(19) NOT NULL,
  `expensedate` date default NULL,
  `expense_no` varchar(255) default NULL,
  `accountid` int(19) default NULL,
  `Salesorderid` int(19) default NULL,
  `NumCount` decimal(11,0) default NULL,
  `total` decimal(25,2) default NULL,
  `approvestatus` int(11) default NULL,
  `approveby` int(19) default NULL,
  `currency_id` int(19) default '1',
  `conversion_rate` decimal(25,2) default '1.00',
  `potentialid` int(19) default NULL,
  PRIMARY KEY  (`expenseid`),
  KEY `idx_expense_approvestatus` (`approvestatus`),
  CONSTRAINT `fk_1_lingdang_expense` FOREIGN KEY (`expenseid`) REFERENCES `ld_crmentity` (`crmid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_expensedetail` (
  `expensedetailid` int(19) NOT NULL auto_increment,
  `expensetype` varchar(100) default NULL,
  `Startdate` date default NULL,
  `enddate` date default NULL,
  `Money` decimal(25,2) default NULL,
  `description` text,
  `expenseid` int(19) default NULL,
  `expenseuse` varchar(200) default NULL,
  `Sequence` int(10) default NULL,
  PRIMARY KEY  (`expensedetailid`),
  KEY `idx_expensedetail_expenseid` (`expenseid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
CREATE TABLE   if not exists `ld_expensescf` (
  `expenseid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE  if not exists `ld_expensetype` (
  `expensetypeid` int(11) NOT NULL default '0',
  `expensetype` varchar(11) default NULL,
  PRIMARY KEY  (`expensetypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


drop procedure  if exists `AddColumn`;
delimiter ||
create procedure   AddColumn
(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50),
columntype varchar(50),
columnlen int(5),
isdefault int(2)
)
begin

select database() into @tableschema;

set tablename=lower(tablename);

SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and 

table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;
set @coladd=IFNULL(@colName,'-1');

IF @coladd = '-1'  or @coladd<>columnname THEN
 	if columntype='date'  or columntype='datetime' then 
		set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
	elseif isdefault=0 then
		set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default 0 ');
	else 

		 set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
	end if;
prepare stalter from @altercolumn;
execute stalter;

END IF;

end ||
delimiter;

drop procedure  if exists `ChangeColumn`;
delimiter ||
create procedure ChangeColumn
(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50),
newname varchar(50),
columntype varchar(50),
columnlen int(5)
)
begin
select database() into @tableschema;
set tablename=lower(tablename);

SET @tsql=CONCAT('select count(*) into @colchange from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and 

table_name= ','''',tablename,'''',' and column_name=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;
-- set @colchange=IFNULL(@column_name,'-1');

IF @colchange=1  THEN
 	if columntype='date'  or columntype='datetime' then 
		set @alterColumn=CONCAT('alter table ',tablename, ' change ',columnname, ' ', newname, ' ', columntype, ' ');
	else 
		set @alterColumn=CONCAT('alter table ',tablename, ' change ',columnname, ' ', newname, ' ', columntype, '(',columnlen,')');
	end if;
prepare stalter from @altercolumn;
execute stalter;

END IF;
end ||
delimiter;

drop procedure if exists `getallprofile`;
delimiter ||
create procedure getallprofile
(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;


declare cur2 CURSOR FOR SELECT profileid   FROM  LD_profile;

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

drop procedure if exists `fieldintoprofile`;
delimiter ||
create procedure fieldintoprofile
(
profileid int(19),
 tabname varchar(50)
)
begin
declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from LD_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');
	
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

-- add 2013-11-15 by luyx
update ld_users set approvestatus = 1 where approveby is null;
delimiter;

-- add 2013-11-07 by dean
select id into @id from LD_settings_field_seq;
update  LD_settings_field_seq set id=@id+1 where not exists(select 1 from  LD_settings_field where name='LBL_PAGE_SET');
insert into LD_settings_field (fieldid,blockid,name,iconpath,description,linkto,sequence,active) 
select  @id+1,3,'LBL_PAGE_SET','Settings.gif','LBL_PAGE_SET_DESCRIPTION','index.php?module=Settings&action=ModuleSettings&parenttab=Settings',1,0 from dual 
where not exists(select 1 from LD_settings_field where name='LBL_PAGE_SET');
delimiter;

-- add 2013-11-01 by bao
INSERT INTO ld_systems_deploy (deploy_value,deploy_type,description) 
select 0,10,"出入库时是否必须严格参照源单" FROM DUAL 
WHERE NOT EXISTS(select 1 from ld_systems_deploy where deploy_type =10);
delimiter;

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description)
SELECT 0,11,"客户是否需要审批流程" FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_systems_deploy WHERE deploy_type=11);
delimiter;


-- add 2013-11-16 by kevin
CREATE TABLE if not EXISTS `ld_warehouse` (
  `id` int(19) NOT NULL default '0',
  `name` varchar(255) default NULL,
  `status` int(1) default '0',
  `started` int(1) default '1',
  `description` text,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE if not EXISTS `ld_warehouse_seq` (
  `id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_warehouse_seq(id)
select 1 from dual where not EXISTS(select 1 from ld_warehouse_seq);
delimiter;

CREATE TABLE if not EXISTS `ld_warehouse2products` (
  `warehouseid` int(19) default NULL,
  `productid` int(19) default NULL,
  `productqty` decimal(11,3) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_warehouse2startedproducts` (
  `warehouseid` int(19) default NULL,
  `productid` int(19) default NULL,
  `qty` decimal(11,3) default NULL,
  KEY `idx_warehouse2startedproducts_warehouseandproduct` (`warehouseid`,`productid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_warehouse2user` (
  `warehouseid` int(19) default NULL,
  `userid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_warehousecondtions` (
  `id` int(19) NOT NULL default '0',
  `entityid` int(19) default NULL,
  `modulename` varchar(255) default NULL,
  `type` varchar(255) default NULL,
  `warehouseid` int(19) default NULL,
  `productid` int(19) default NULL,
  `firstqty` decimal(11,3) default NULL,
  `inputqty` decimal(11,3) default NULL,
  `outputqty` decimal(11,3) default NULL,
  `lastqty` decimal(11,3) default NULL,
  `operationtime` datetime default NULL,
  `smownerid` int(19) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_warehousecondtions_seq` (
  `id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into ld_warehousecondtions_seq(id)
select 1 from dual where not exists(select 1 from ld_warehousecondtions_seq);
delimiter;

select max(parenttabid) into @parenttabid from ld_parenttab;

update ld_parenttab set sequence=sequence+1 where sequence>=8;

insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible)

select @parenttabid+1,'Stock',8,0 from dual where not exists (select 1 from ld_parenttab where parenttab_label='Stock');

delimiter;

select max(tabid) into @tabid from ld_tab;

insert into ld_tab(tabid,name,presence,tabsequence,tablabel,modifiedby,modifiedtime,customized,ownedby,isentitytype,

version,parent,printtab)

select @tabid+1,'Prdtnums',0,76,'Prdtnums',null,null,0,0,1,null,'Stocks',0 from dual where not exists(select 1 FROM

ld_tab where name='Prdtnums');

delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Stock';

select tabid into @tabid from ld_tab where name='Prdtnums';

insert into ld_parenttabrel(parenttabid,tabid,sequence)

select @parenttabid,@tabid,4 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid

and tabid=@tabid);

delimiter;


-- add 2013-11-18 by luyx
select blockid into @blockid from ld_settings_blocks WHERE label='LBL_OTHER_SETTINGS';
select id into @id from ld_settings_field_seq;
update ld_settings_field_seq set id=@id+1 where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LBL_WASEHOUSE');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_WASEHOUSE','wasehouse.gif','LBL_WASEHOUSE_DESCRIPTION','index.php?module=Settings&action=ListWareHouse&parenttab=Settings',32,0
from dual where not exists (select 1 from ld_settings_field where blockid=@blockid and name='LBL_WASEHOUSE');
delimiter;

-- add 2013-11-19 by kevin
select blockid into @blockid from ld_settings_blocks where label='LBL_STUDIO';
select id into @id from ld_settings_field_seq;
update ld_settings_field_seq set id=@id where not exists (select 1 from ld_settings_field where name='LBL_TABLIST');
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_TABLIST','tablist.gif','LBL_TABLIST_DESCRIPTION','index.php?module=Settings&action=MenuList&parenttab=Settings',
@sequence+1,0 from dual where not exists(select 1 from ld_settings_field where name='LBL_TABLIST');
delimiter;
create table if not exists ld_languagepackage(
tabid int(19),
tablabel varchar(25),
chinesename varchar(255),
newchinesename varchar(255),
index idx_languagepackage_tabid(tabid)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
create table if not exists ld_parentlanguagepackage(
parentid int(19),
parentlabel varchar(25),
chinesename varchar(255)
)ENGINE=INNODB DEFAULT CHARSET=utf8;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='My Home Page';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'My Home Page','工作台' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='My Home Page');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Marketing';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Marketing','营销' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Marketing');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Parent Accounts';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Parent Accounts','客户' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Parent Accounts');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Sales';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Sales','销售' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Sales');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Parent Reports';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Parent Reports','报表' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Parent Reports');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Tools';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Tools','工具' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Tools');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Finacial';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Finacial','财务' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Finacial');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Project';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Project','项目' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Project');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Purchase';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Purchase','采购' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Purchase');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Stock';
insert into ld_parentlanguagepackage(parentid,parentlabel,chinesename)
select @parenttabid,'Stock','库存' from dual where not exists (select 1 from ld_parentlanguagepackage
where parentid=@parenttabid and parentlabel='Stock');
delimiter;

select tabid into @tabid from ld_tab where name='Dashboard';
select tablabel into @tablabel from ld_tab where name='Dashboard';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'仪表板','仪表板' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Home';
select tablabel into @tablabel from ld_tab where name='Home';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'首页','首页' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='ReportLog';
select tablabel into @tablabel from ld_tab where name='ReportLog';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'日/周/月报','日/周/月报' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Calendar';
select tablabel into @tablabel from ld_tab where name='Calendar';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'日程管理','日程管理' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Webmails';
select tablabel into @tablabel from ld_tab where name='Webmails';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'邮件管理','邮件管理' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Documents';
select tablabel into @tablabel from ld_tab where name='Documents';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'知识管理','知识管理' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Faq';
select tablabel into @tablabel from ld_tab where name='Faq';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'常见问题','常见问题' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Campaigns';
select tablabel into @tablabel from ld_tab where name='Campaigns';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'市场活动','市场活动' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='MassSMS';
select tablabel into @tablabel from ld_tab where name='MassSMS';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'群发短信','群发短信' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='MassFaxs';
select tablabel into @tablabel from ld_tab where name='MassFaxs';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'群发传真','群发传真' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='MassVoices';
select tablabel into @tablabel from ld_tab where name='MassVoices';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'群发语音','群发语音' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='MassEmails';
select tablabel into @tablabel from ld_tab where name='MassEmails';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'群发邮件','群发邮件' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='SmsPhrases';
select tablabel into @tablabel from ld_tab where name='SmsPhrases';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'短信模板','短信模板' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='EmailListtmp';
select tablabel into @tablabel from ld_tab where name='EmailListtmp';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'邮件模板','邮件模板' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='CommunicationLog';
select tablabel into @tablabel from ld_tab where name='CommunicationLog';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'通讯历史记录','通讯历史记录' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Accounts';
select tablabel into @tablabel from ld_tab where name='Accounts';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'客户','客户' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
select tablabel into @tablabel from ld_tab where name='Contacts';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'联系人','联系人' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='ContactRecords';
select tablabel into @tablabel from ld_tab where name='ContactRecords';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'联系记录','联系记录' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select tablabel into @tablabel from ld_tab where name='ServiceContracts';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'服务合同','服务合同' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='HelpDesk';
select tablabel into @tablabel from ld_tab where name='HelpDesk';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'服务单','服务单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select tablabel into @tablabel from ld_tab where name='Potentials';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'销售机会','销售机会' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Quotes';
select tablabel into @tablabel from ld_tab where name='Quotes';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'报价单','报价单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select tablabel into @tablabel from ld_tab where name='SalesOrder';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'合同订单','合同订单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='OftenUseReport';
select tablabel into @tablabel from ld_tab where name='OftenUseReport';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'常用报表','常用报表' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Comprehensivereport';
select tablabel into @tablabel from ld_tab where name='Comprehensivereport';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'综合报表','综合报表' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Reports';
select tablabel into @tablabel from ld_tab where name='Reports';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'自定义报表','自定义报表' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='ModComments';
select tablabel into @tablabel from ld_tab where name='ModComments';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'评论','评论' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Announcements';
select tablabel into @tablabel from ld_tab where name='Announcements';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'公告','公告' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Products';
select tablabel into @tablabel from ld_tab where name='Products';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'产品','产品' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Services';
select tablabel into @tablabel from ld_tab where name='Services';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'服务','服务' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='PriceBooks';
select tablabel into @tablabel from ld_tab where name='PriceBooks';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'价格表','价格表' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='RecycleBin';
select tablabel into @tablabel from ld_tab where name='RecycleBin';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'回收站','回收站' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
select tablabel into @tablabel from ld_tab where name='PaymentPlan';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'回款计划','回款计划' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
select tablabel into @tablabel from ld_tab where name='Invoice';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'发票','发票' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='CashBill';
select tablabel into @tablabel from ld_tab where name='CashBill';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'收款单','收款单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Expense';
select tablabel into @tablabel from ld_tab where name='Expense';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'费用报销','费用报销' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Project';
select tablabel into @tablabel from ld_tab where name='Project';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'项目','项目' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='ProjectTask';
select tablabel into @tablabel from ld_tab where name='ProjectTask';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'项目任务','项目任务' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='ProjectMilestone';
select tablabel into @tablabel from ld_tab where name='ProjectMilestone';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'项目里程碑','项目里程碑' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
select tablabel into @tablabel from ld_tab where name='Vendors';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'供应商','供应商' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='Prdtnums';
select tablabel into @tablabel from ld_tab where name='Prdtnums';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'仓库初始化','仓库初始化' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tablabel into @tablabel from ld_tab where name='PurchaseOrder';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'采购订单','采购订单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
select tabid into @tabid from ld_tab where name='Navigation';
select tablabel into @tablabel from ld_tab where name='Navigation';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'库存导航','库存导航' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
select tabid into @tabid from ld_tab where name='OutboundOrder';
select tablabel into @tablabel from ld_tab where name='OutboundOrder';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'出库单','出库单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
select tabid into @tabid from ld_tab where name='InventoryLedger';
select tablabel into @tablabel from ld_tab where name='InventoryLedger';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'库存台账','库存台账' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
select tabid into @tabid from ld_tab where name='InventoryAccount';
select tablabel into @tablabel from ld_tab where name='InventoryAccount';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'库存流水账','库存流水账' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
select tabid into @tabid from ld_tab where name='InventoryQuery';
select tablabel into @tablabel from ld_tab where name='InventoryQuery';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'即时库存查询','即时库存查询' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
select tabid into @tabid from ld_tab where name='Stock';
select tablabel into @tablabel from ld_tab where name='Stock';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'入库单','入库单' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
update ld_tab set tablabel='ServiceContracts' where name='ServiceContracts';
delimiter;
update ld_relatedlists set label='SalesOrder' where name='get_salesorder';
delimiter;
update ld_relatedlists set label='PurchaseOrder' where name='get_purchase_orders';
delimiter;
update ld_relatedlists set label='ServiceContracts' where name='get_ServiceContracts';
delimiter;
update ld_relatedlists set label='ContactRecords' where name='get_contactrecords';
delimiter;
update ld_relatedlists set label='Webmails' where name='get_emails';
delimiter;
update ld_relatedlists set label='Expense' where name='get_expense';
delimiter;
update ld_relatedlists set label='Calendar' where name='get_schedule';
delimiter;
update ld_relatedlists set label='CashBill' where name='get_cashbill';
delimiter;
update ld_relatedlists set label='PaymentPlan' where name='get_paymentplan';
delimiter;
update ld_relatedlists set label='Project' where name='get_dependents_list';
delimiter;
update ld_relatedlists set label='HelpDesk' where label='Service Requests';
delimiter;
update ld_relatedlists set label='HelpDesk' where label='Trouble Tickets';
delimiter;
update ld_relatedlists set label='ProjectTask' where tabid=48 and related_tabid=47;
delimiter;
update ld_relatedlists set label='ProjectMilestone' where tabid=48 and related_tabid=46;
delimiter;

-- add 2013-11-20 by chenhuangjian
insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'Navigation',71,'Navigation','Stocks' from dual where not exists (select * from ld_tab where name = 'Navigation');

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Stock';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'Navigation'),1 from dual where not exists (select * from ld_parenttabrel where 
parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'Navigation') and sequence = 1);

insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'OutboundOrder',72,'OutboundOrder','Stocks' from dual 
where not exists (select * from ld_tab where name = 'OutboundOrder');

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'OutboundOrder'),2 from dual 
where not exists (select * from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'OutboundOrder'));

insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'Stock',73,'Stock','Stocks' from dual 
where not exists (select * from ld_tab where name = 'Stock');

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'Stock'),3 from dual 
where not exists (select * from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'Stock'));

insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'Prdtnums',76,'Prdtnums','Stocks' from dual 
where not exists (select * from ld_tab where name = 'Prdtnums');

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'Prdtnums'),6 from dual 
where not exists (select * from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'Prdtnums'));

insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'InventoryLedger',77,'InventoryLedger','Stocks' from dual 
where not exists (select * from ld_tab where name = 'InventoryLedger');

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'InventoryLedger'),7 from dual 
where not exists (select * from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'InventoryLedger'));

insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'InventoryAccount',78,'InventoryAccount','Stocks' from dual 
where not exists (select * from ld_tab where name = 'InventoryAccount');

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'InventoryAccount'),8 from dual 
where not exists (select * from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'InventoryAccount'));

insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'InventoryQuery',79,'InventoryQuery','Stocks' from dual 
where not exists (select * from ld_tab where name = 'InventoryQuery');

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'InventoryQuery'),9 from dual 
where not exists (select * from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'InventoryQuery'));


select tabid into @tabid from ld_tab where name='Stock';
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
select 1,@tabid,0,0 from dual where not exists (select * from ld_profile2standardpermissions where 
profileid = 1 and tabid = @tabid and operation = 0);

insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
select 1,@tabid,1,0 from dual where not exists (select * from ld_profile2standardpermissions where 
profileid = 1 and tabid = @tabid and operation = 1);

insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
select 1,@tabid,2,0 from dual where not exists (select * from ld_profile2standardpermissions where 
profileid = 1 and tabid = @tabid and operation = 2);

insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
select 1,@tabid,3,0 from dual where not exists (select * from ld_profile2standardpermissions where 
profileid = 1 and tabid = @tabid and operation = 3);

insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
select 1,@tabid,4,0 from dual where not exists (select * from ld_profile2standardpermissions where 
profileid = 1 and tabid = @tabid and operation = 4);

insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions)
select 1,@tabid,11,0 from dual where not exists (select * from ld_profile2standardpermissions where 
profileid = 1 and tabid = @tabid and operation = 11);


insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_WARE_INFO',1 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO');

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_WARE_DESCRIPTION',2 from dual 
where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_DESCRIPTION');

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'OutboundOrder'),'LBL_OUT_INFO',1 from dual 
where not exists (select 1 from ld_blocks where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and blocklabel = 'LBL_OUT_INFO');

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'OutboundOrder'),'LBL_OUT_DESCRIPTION',2 from dual 
where not exists (select 1 from ld_blocks where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and blocklabel = 'LBL_OUT_DESCRIPTION');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'vendor_id','LD_stock',75,'vendor_id','供应商名称',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),1,0,'V~M' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'vendor_id');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'ware_stock_no','LD_stock',4,'ware_stock_no','入库单编号',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),1,0,'I~O' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'ware_stock_no');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'purchaseorder_id','LD_stock',150,'purchaseorder_id','采购订单',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),1,0,'I~O' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'purchaseorder_id');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','LD_stock',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),1,0,'I~O' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'createdate','LD_stock',23,'createdate','入库日期',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),1,0,'D~O' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'createdate');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'wareid','LD_stock',151,'wareid','仓库',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'wareid');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'remark','LD_stock',19,'remark','描述',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_DESCRIPTION'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'remark');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'presence','LD_stock',130,'presence','状态',(select blockid from ld_blocks where blocklabel = 
'LBL_WARE_INFO'),2,2,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'presence');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'accountid','LD_outboundorder',73,'account_id','客户名称',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'accountid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'out_no','LD_outboundorder',4,'out_no','出库单编号',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'out_no');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'salesorderid','LD_outboundorder',80,'salesorder_id','合同订单',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'salesorderid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'smownerid','LD_outboundorder',53,'smownerid','负责人',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'outdate','LD_outboundorder',23,'outdate','出库日期',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),1,0,'D~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'outdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'wareid','LD_outboundorder',151,'wareid','仓库',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'wareid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'remark','LD_outboundorder',19,'remark','描述',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_DESCRIPTION'),1,0,'I~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'remark');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),(select max(fieldid) from ld_field)+1,'presence','LD_outboundorder',130,'presence','状态',(select blockid from ld_blocks where blocklabel = 
'LBL_OUT_INFO'),2,2,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'presence');

INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active)
SELECT (SELECT MAX(num_id)+1 FROM ld_modentity_num),'Stock','PK',1,1,1 from dual where not exists 
(select 1 from ld_modentity_num where semodule= 'Stock');

INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active)
SELECT (SELECT MAX(num_id)+1 FROM ld_modentity_num),'OutboundOrder','CK',1,1,1 from dual where not exists 
(select 1 from ld_modentity_num where semodule= 'OutboundOrder');


insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select (select tabid from ld_tab where `name` = 'Stock'),'Stock','LD_Stock','ware_stock_no','stock_id','stock_id' from dual where not exists 
(select * from ld_entityname where tabid = (select tabid from ld_tab where `name` = 'Stock'));

insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),'OutboundOrder','LD_outboundorder','out_no','out_id','out_id' from dual where not exists 
(select * from ld_entityname where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder'));


insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'Stock' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'Stock');

insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'OutboundOrder' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'OutboundOrder');

insert into ld_customview(cvid,viewname,entitytype,`status`,sequence)
select (select max(cvid) from ld_customview) + 1,'未入库','Stock',3,1 from dual where not exists 
(select *from ld_customview where viewname = '未入库' and entitytype = 'Stock');
insert into ld_customview(cvid,viewname,entitytype,`status`,sequence)
select (select max(cvid) from ld_customview) + 1,'已入库','Stock',3,2 from dual where not exists 
(select *from ld_customview where viewname = '已入库' and entitytype = 'Stock');

insert into ld_customview(cvid,viewname,entitytype,`status`,sequence)
select (select max(cvid) from ld_customview) + 1,'未出库','OutboundOrder',3,1 from dual where not exists 
(select *from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder');
insert into ld_customview(cvid,viewname,entitytype,`status`,sequence)
select (select max(cvid) from ld_customview) + 1,'已出库','OutboundOrder',3,2 from dual where not exists 
(select *from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder');

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),0,'LD_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),1,'LD_stock:wareid:wareid:Stock_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),2,'LD_stock:createdate:createdate:Stock_入库日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),3,'LD_stock:purchaseorder_id:purchaseorder_id:Stock_采购订单:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),4,'LD_stock:smownerid:smownerid:Stock_负责人:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),5,'LD_stock:vendor_id:vendor_id:Stock_供应商名称:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock') and columnindex = 5);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'),0,'LD_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'),1,'LD_stock:wareid:wareid:Stock_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'),2,'LD_stock:createdate:createdate:Stock_入库日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'),3,'LD_stock:purchaseorder_id:purchaseorder_id:Stock_采购订单:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'),4,'LD_stock:smownerid:smownerid:Stock_负责人:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'),5,'LD_stock:vendor_id:vendor_id:Stock_供应商名称:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'),0,'LD_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'),1,'LD_stock:wareid:wareid:Stock_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'),2,'LD_stock:createdate:createdate:Stock_入库日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'),3,'LD_stock:purchaseorder_id:purchaseorder_id:Stock_采购订单:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'),4,'LD_stock:smownerid:smownerid:Stock_负责人:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'),5,'LD_stock:vendor_id:vendor_id:Stock_供应商名称:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已入库' and entitytype = 'Stock'));

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),0,'LD_outboundorder:out_no:out_no:OutboundOrder_出库单编号:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),1,'LD_outboundorder:wareid:wareid:OutboundOrder_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),2,'LD_outboundorder:outdate:outdate:OutboundOrder_出库日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),3,'LD_outboundorder:account_id:account_id:OutboundOrder_客户名称:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),4,'LD_outboundorder:salesorder_id:salesorder_id:OutboundOrder_合同订单:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),5,'LD_outboundorder:presence:presence:OutboundOrder_状态:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'),6,'LD_outboundorder:smownerid:smownerid:LD_outboundorder_负责人:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),0,'LD_outboundorder:out_no:out_no:OutboundOrder_出库单编号:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),1,'LD_outboundorder:wareid:wareid:OutboundOrder_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),2,'LD_outboundorder:outdate:outdate:OutboundOrder_出库日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),3,'LD_outboundorder:account_id:account_id:OutboundOrder_客户名称:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),4,'LD_outboundorder:salesorder_id:salesorder_id:OutboundOrder_合同订单:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),5,'LD_outboundorder:presence:presence:OutboundOrder_状态:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));


insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'),6,'LD_outboundorder:smownerid:smownerid:LD_outboundorder_负责人:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder'));

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),0,'LD_outboundorder:out_no:out_no:OutboundOrder_出库单编号:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),1,'LD_outboundorder:wareid:wareid:OutboundOrder_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),2,'LD_outboundorder:outdate:outdate:OutboundOrder_出库日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),3,'LD_outboundorder:account_id:account_id:OutboundOrder_客户名称:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),4,'LD_outboundorder:salesorder_id:salesorder_id:OutboundOrder_合同订单:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),5,'LD_outboundorder:presence:presence:OutboundOrder_状态:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'),6,'LD_outboundorder:smownerid:smownerid:LD_outboundorder_负责人:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder'));


call addcolumn('ld_inventoryproductrel','remark','varchar','50',NULL);
delimiter;

insert ld_ws_entity(`name`,handler_path,handler_class,ismodule)
select 'OutboundOrder','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual where not exists 
(select * from ld_ws_entity where `name`= 'OutboundOrder'); 
insert ld_ws_entity(`name`,handler_path,handler_class,ismodule)
select 'Stock','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual where not exists 
(select * from ld_ws_entity where `name`= 'Stock'); 

CREATE TABLE IF NOT EXISTS `ld_stock` (
  `stock_id` int(11) NOT NULL auto_increment COMMENT 'id',
  `ware_stock_no` varchar(25) NOT NULL COMMENT '入库单编号',
  `wareid` int(11) NOT NULL COMMENT '仓库ID',
  `vendor_id` int(11) NOT NULL COMMENT '供应商ID',
  `purchaseorder_id` int(11) default '0' COMMENT '采购订单ID',
  `presence` int(11) NOT NULL default '0' COMMENT '状态0未入库 1已入库 2 已出库',
  `taxtype` varchar(25) default NULL COMMENT '税的类型',
  `currency_id` int(11) NOT NULL default '1' COMMENT '币种',
  `total` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `smownerid` int(11) NOT NULL default '0' COMMENT '负责人ID',
  `addstockperson` int(11) NOT NULL default '0' COMMENT '入库人',
  `remark` varchar(255) NOT NULL COMMENT '描述',
  `describe` varchar(255) default NULL COMMENT '备注',
  `createdate` date default NULL COMMENT '创建时间',
  `editdate` date default NULL COMMENT '修改时间',
  `conversion_rate` decimal(25,3) default NULL,
  `adjustment` decimal(25,2) default NULL,
  `s_h_amount` decimal(25,2) default NULL,
  `discount_amount` decimal(25,2) default NULL,
  `discount_percent` decimal(25,2) default NULL,
  PRIMARY KEY  (`stock_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11861 DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_outboundorder` (
  `out_id` int(11) NOT NULL auto_increment,
  `accountid` int(11) NOT NULL COMMENT '客户ID',
  `out_no` varchar(25) NOT NULL COMMENT '出库单编号',
  `salesorderid` int(11) NOT NULL COMMENT '合同订单ID',
  `smownerid` int(11) default NULL COMMENT '负责人ID',
  `outdate` date default NULL COMMENT '出库日期',
  `wareid` int(11) default NULL COMMENT '仓库ID',
  `presence` int(11) default '0' COMMENT '0未出库 1已出库',
  `remark` varchar(25) default NULL COMMENT '备注',
  `taxtype` varchar(25) default NULL COMMENT '税的类型',
  `currency_id` int(11) default NULL COMMENT '币种',
  `total` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `conversion_rate` decimal(25,3) default NULL,
  `adjustment` decimal(25,2) default NULL,
  `s_h_amount` decimal(25,2) default NULL,
  `discount_amount` decimal(25,2) default NULL,
  `discount_percent` decimal(25,2) default NULL,
  PRIMARY KEY  (`out_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11863 DEFAULT CHARSET=utf8;


-- add 2013-11-20 by dean
update ld_settings_field set iconpath = 'public_sea_account.gif' where name = 'LBL_ACCOUNT_SET';
delimiter;
update ld_settings_field set iconpath = 'pageset.gif' where name = 'LBL_PAGE_SET';
delimiter;



-- add 2013-11-21 by can
call addcolumn('ld_users','accountallview','int',2,0);
CREATE TABLE  if not EXISTS`ld_account2userview` (
  `accountid` int(19) NOT NULL default '0',
  `AllViewUsers` varchar(300) default NULL,
  `Shareuserid` int(19) default NULL,
  PRIMARY KEY  (`accountid`),
  KEY `account2userview_accountid_idx` USING BTREE (`accountid`),
  KEY `account2userview_shareuserid_idx` USING BTREE (`Shareuserid`),
  CONSTRAINT `fk_1_lingdang_account2userview` FOREIGN KEY (`accountid`) REFERENCES `ld_account` (`accountid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='users';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_ACCOUNT_MOREINFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_MOREINFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='users';
select blockid into @userblockid from LD_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_MOREINFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountallview'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'accountallview','LD_users',1,56,'accountallview','Account AllView',1,0,'',100,1,@userblockid,1,'V~O',0,'','BAS',2,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountallview'  and tabid=@tabid ) ;
delimiter;


select id into @id  from LD_def_org_share_seq;
update LD_def_org_share_seq set id=id+1 where not EXISTS(select 1 from ld_def_org_share where tabid=48);
insert into ld_def_org_share (ruleid,tabid,permission,editstatus)
 select @id+1 ,48,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=48);
select id into @id  from LD_def_org_share_seq;
update LD_def_org_share_seq set id=id+1 where not EXISTS(select 1 from ld_def_org_share where tabid=47);
insert into ld_def_org_share (ruleid,tabid,permission,editstatus)
 select @id+1 ,47,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=47);
select id into @id  from LD_def_org_share_seq;
update LD_def_org_share_seq set id=id+1 where not EXISTS(select 1 from ld_def_org_share where tabid=46);
insert into ld_def_org_share (ruleid,tabid,permission,editstatus)
 select @id+1 ,46,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=46);

select id into @id  from LD_def_org_share_seq;
update LD_def_org_share_seq set id=id+1 where not EXISTS(select 1 from ld_def_org_share where tabid=37);
insert into ld_def_org_share (ruleid,tabid,permission,editstatus)
 select @id+1 ,37,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=37);
select id into @id  from LD_def_org_share_seq;
update LD_def_org_share_seq set id=id+1 where not EXISTS(select 1 from ld_def_org_share where tabid=21);
insert into ld_def_org_share (ruleid,tabid,permission,editstatus)
 select @id+1 ,21,3,0 from dual where not EXISTS(select 1 from ld_def_org_share where tabid=21);

update ld_def_org_share set permission=3 where permission is null or permission='';
delimiter;

-- add 2013-11-21 by qiu
call AddColumn('ld_account','approvestatus','int',11,null);
delimiter;
call AddColumn('ld_account','approveby','int',1,null);
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_account' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select 6,@id+1,'approvestatus','ld_account',1,53,'approvestatus','Approvestatus',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_account' and fieldname='approvestatus');
delimiter;
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_account' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select 6,@id+1,'approveby','ld_account',1,53,'approveby','Approveby',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='ld_account' and fieldname='approveby');
delimiter;

-- add 2013-11-21 by luyx

update ld_systems_deploy set description='在合同订单模块创建回款计划时是否控制回款计划总额必须等于订单金额。1:是，0:否' where deploy_type=1;
delete from ld_systems_deploy where deploy_type=2;
update ld_systems_deploy set description='合同订单是否启用审批流程。1:否，0:是' where deploy_type=3;
update ld_systems_deploy set description='发票是否启用审批流程。1:否，0:是' where deploy_type=4;
update ld_systems_deploy set description='报价单是否启用审批流程。1:否，0:是' where deploy_type=5;
update ld_systems_deploy set description='服务单是否启用审批流程。1:否，0:是' where deploy_type=6;
update ld_systems_deploy set description='当客户负责人变更时是否发送短信通知新的负责人 。1:是，0:否' where deploy_type=7;
update ld_systems_deploy set description='采购订单是否启用审批流程。1:否，0:是' where deploy_type=8;
update ld_systems_deploy set description='费用报销是否启用审批流程。1:否，0:是' where deploy_type=9;
update ld_systems_deploy set description='出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。1:是，0:否' where deploy_type=10;
update ld_systems_deploy set description='客户是否启用审批流程。1:否，0:是' where deploy_type=11;

-- add 2013-11-22 by chenhuangjian
update ld_relatedlists_lable set edit = 0 where tabid = (select tabid from ld_tab where `name` = 'Campaigns') and sequence !=1;

insert into ld_productfieldlist(fieldid,fieldname,fieldwidth,fieldorder)
select 174,'productname',0,1 from dual where not exists 
(select * from ld_productfieldlist where fieldid = 174 and fieldname = 'productname');

insert into ld_productfieldlist(fieldid,fieldname,fieldwidth,fieldorder)
select 189,'productsheet',0,2 from dual where not exists 
(select * from ld_productfieldlist where fieldid = 189 and fieldname = 'productsheet');

insert into ld_productfieldlist(fieldid,fieldname,fieldwidth,fieldorder)
select 175,'product_no',0,3 from dual where not exists 
(select * from ld_productfieldlist where fieldid = 175 and fieldname = 'product_no');

insert into ld_productfieldlist(fieldid,fieldname,fieldwidth,fieldorder)
select 197,'usageunit',0,4 from dual where not exists 
(select * from ld_productfieldlist where fieldid = 197 and fieldname = 'usageunit');


-- add 2013-11-25 by kevin
select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,modifiedby,modifiedtime,customized,ownedby,
isentitytype,version,parent,printtab)
select @tabid+1,'Cache',0,0,'Cache',null,null,0,1,0,null,null,0 from dual where not EXISTS(select 1 from 
ld_tab where tablabel='Cache');
delimiter;
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Tools';
select tabid into @tabid from ld_tab where tablabel='Cache';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid=@parenttabid;
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from dual where not exists(
select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
delimiter;
select tabid into @tabid from ld_tab where name='Cache';
select tablabel into @tablabel from ld_tab where name='Cache';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'清除缓存','清除缓存' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,12,'合同订单新增保存后是否立即弹出创建回款计划。1:否，0:是' from dual where not exists(select 
1 from ld_systems_deploy where deploy_type=12);
delimiter;


-- add 2013-11-27 by chen
-- 流水账
insert into ld_ws_entity(`name`,handler_path,handler_class,ismodule)
select 'InventoryAccount','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual where not exists 
(select * from ld_ws_entity where `name`= 'InventoryAccount'); 
-- 库存及时查询
insert into ld_ws_entity(`name`,handler_path,handler_class,ismodule)
select 'InventoryQuery','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual where not exists 
(select * from ld_ws_entity where `name`= 'InventoryQuery'); 
-- ALL权限 流水账
insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'InventoryAccount' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'InventoryAccount');
-- ALL权限  及时查询
insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'InventoryQuery' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'InventoryQuery');

-- 给流水账 默认插入全部字段信息
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 0);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 1);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 2);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 3);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 4);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 5);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 6);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 7);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 9);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 8);
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount'),10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount') and columnindex = 10);


-- 流水账表单信息
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'type','LD_warehousecondtions',1,'type','操作类型',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'type');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'warehouseid','LD_warehousecondtions',151,'warehouseid','仓库',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'warehouseid');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'productname','LD_products',1,'productname','产品名称',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'productname');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'product_no','LD_products',1,'product_no','产品编号',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'product_no');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'productcode','LD_products',1,'productcode','产品型号',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'productcode');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'inputqty','LD_warehousecondtions',1,'inputqty','入库数',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'inputqty');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'outputqty','LD_warehousecondtions',1,'outputqty','出库数',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'outputqty');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'lastqty','LD_warehousecondtions',1,'lastqty','操作后数量',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'lastqty');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'modulename','LD_warehousecondtions',154,'modulename','所属模块',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'modulename');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'operationtime','LD_warehousecondtions',23,'operationtime','操作时间',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'operationtime');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryAccount'),(select max(fieldid) from ld_field)+1,'entityid','LD_warehousecondtions',155,'entityid','库存单据',(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),1,0,'I~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and columnname = 'entityid');



-- blocks  流水账
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'InventoryAccount'),'LBL_INVENTORYACCOUNT_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and blocklabel = 'LBL_INVENTORYACCOUNT_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'InventoryAccount'),'LBL_INVENTORYACCOUNT_DESCRIPTION',2 from dual where not exists (select * from ld_blocks where 
tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and blocklabel = 'LBL_INVENTORYACCOUNT_DESCRIPTION' and sequence = 2);

-- blocks 及时查询
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'InventoryQuery'),'LBL_INVENTORYQUERY_INFO',1 from dual where not exists 
(select * from ld_blocks where 
tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and blocklabel = 'LBL_INVENTORYQUERY_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'InventoryQuery'),'LBL_INVENTORYQUERY_DESCRIPTION',2 from dual where not 
exists (select * from ld_blocks where 
tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and blocklabel = 'LBL_INVENTORYQUERY_DESCRIPTION' and sequence = 2);

-- 更新  ld_field_seq  ld_blocks_seq
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
update ld_field_seq set id = (select max(fieldid) from ld_field);

-- 产品表添加 预警数量字段
call addcolumn('ld_products','qtyearly','int','11',0);


-- 库存及时查询
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'productname','LD_products',1,'productname','产品名称',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'productname');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'product_no','LD_products',1,'product_no','产品编号',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'product_no');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'productcode','LD_products',1,'productcode','型号',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'productcode');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'unit_price','LD_products',163,'unit_price','单价',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'unit_price');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'productqty','LD_warehouse2products',164,'productqty','库存数量',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'productqty');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'qtyearly','LD_products',1,'qtyearly','预警数量',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'qtyearly');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'commissionrate','LD_products',160,'commissionrate','库存金额',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'commissionrate' and uitype = 160);
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'warehouseid','LD_warehouse2products',161,'warehouseid','待入库数量',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'warehouseid' and uitype = 161);
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'InventoryQuery'),(select max(fieldid) from ld_field)+1,'productid','LD_warehouse2products',162,'productid','待出库数量',
(select blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'InventoryQuery') and columnname = 'productid' and uitype = 162);


insert into LD_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions)
select (select max(relation_id)+1 from ld_relatedlists),21,(select tabid from ld_tab where `name` = 'Stock'),'get_stock',3,'Stock',0,'add' from dual where not exists 
(select * from LD_relatedlists where tabid = 21 and related_tabid = (select tabid from ld_tab where `name` = 'Stock'));

update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
select tabid into @relatedtabid from ld_tab where `name` = 'Stock';

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'ware_stock_no' and tabid = @relatedtabid),0,1,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'ware_stock_no' and tabid = @relatedtabid));
select tabid into @relatedtabid from ld_tab where `name` = 'Stock';

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'createdate' and tabid = @relatedtabid),0,2,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'createdate' and tabid = @relatedtabid));
select tabid into @relatedtabid from ld_tab where `name` = 'Stock';

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'wareid' and tabid = @relatedtabid),0,3,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'wareid' and tabid = @relatedtabid));
select tabid into @relatedtabid from ld_tab where `name` = 'Stock';

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'presence' and tabid = @relatedtabid),0,4,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'presence' and tabid = @relatedtabid));

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'smownerid' and tabid = @relatedtabid),0,5,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'smownerid' and tabid = @relatedtabid));


insert into ld_tab(tabid,presence,`name`,tabsequence,tablabel,parent)
select (select max(tabid)+1 from ld_tab),0,'Checks',75,'Checks','Stocks' from dual 
where not exists (select * from ld_tab where name = 'Checks');

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Stock';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,(select tabid from ld_tab where tablabel = 'Checks'),10 from dual where not exists (select * from ld_parenttabrel where 
parenttabid = @parenttabid and tabid = (select tabid from ld_tab where tablabel = 'Checks'));


insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'Checks' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'Checks');

insert into ld_ws_entity(`name`,handler_path,handler_class,ismodule)
select 'Checks','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual where not exists 
(select * from ld_ws_entity where `name`= 'Checks'); 

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'Checks'),'LBL_CHECKS_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = (select tabid from ld_tab where `name` = 'Checks') and blocklabel = 'LBL_CHECKS_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,(select tabid from ld_tab where `name` = 'Checks'),'LBL_CHECKS_DESCRIPTION',2 from dual where not exists (select * from ld_blocks where 
tabid = (select tabid from ld_tab where `name` = 'Checks') and blocklabel = 'LBL_CHECKS_DESCRIPTION' and sequence = 2);



update ld_field set typeofdata = 'V~M' where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and fieldname = 'smownerid' or fieldname = 'wareid';

update ld_customview set `status` = 0 where viewname = 'All' and entitytype = 'Stock';
update ld_customview set `status` = 0 where viewname = 'All' and entitytype = 'OutboundOrder';


update ld_field set typeofdata = '' where tabid = (select tabid from ld_tab where `name` = 'Stock') and fieldname = 'vendor_id';

update ld_field set typeofdata = 'V~M' where tabid = (select tabid from ld_tab where `name` = 'Stock') and fieldname = 'smownerid';

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Stock'),(select max(fieldid) from ld_field)+1,'presence','LD_stock',130,'presence','状态',(select blockid from ld_blocks where blocklabel = 
'LBL_WARE_INFO'),2,2,'V~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Stock') and columnname = 'presence');

-- 共享规则 默认入库单为公共 私有
insert into ld_def_org_share(tabid,permission,editstatus)
select (select tabid from ld_tab where `name` = 'Stock'),3,0 from dual where not exists 
(select * from ld_def_org_share where tabid = (select tabid from ld_tab where `name` = 'Stock') and permission = 3 and editstatus = 0);
update ld_def_org_share_seq set id = (select max(ruleid) from ld_def_org_share);

-- 增加入库序时薄 状态  列
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Stock'),(select max(fieldid) from ld_field)+1,'presence','LD_stock',130,'presence','状态',(select blockid from ld_blocks where blocklabel = 
'LBL_WARE_INFO'),2,2,'V~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Stock') and columnname = 'presence');


-- 增加 产品预警数量
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Products'),(select max(fieldid) from ld_field)+1,'qtyearly','LD_products',1,'qtyearly','预警数量',(select blockid from ld_blocks where blocklabel = 'LBL_STOCK_INFORMATION'),1,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Products') and columnname = 'qtyearly');

insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'Stock' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'Stock');

insert into ld_customview(cvid,viewname,setdefault,entitytype)
select (select max(cvid) from ld_customview) + 1,'All',1,'OutboundOrder' from dual where not exists 
(select * from ld_customview where viewname = 'All' and setdefault = 1 and entitytype = 'OutboundOrder');

select tabid into @tabid from ld_tab where name='prdtnums';
update ld_languagepackage set chinesename='库存初始化',newchinesename='库存初始化' where tabid=@tabid;
delimiter;
select id into @id from ld_warehouse_seq;
update ld_warehouse_seq set id=@id+1 where not exists (select 1 from ld_warehouse where name='总仓');
insert into ld_warehouse(id,name,status,started,description)
select @id+1,'总仓',0,1,null from dual where not exists(select 1 from ld_warehouse where name='总仓');
select id into @userid from ld_users where user_name='admin';
insert into ld_warehouse2user(warehouseid,userid)
select @id+1,@userid from dual where not exists(select 1 from ld_warehouse2user
 where warehouseid=@id+1 and userid=@userid);
delimiter;
select id into @id from ld_warehouse_seq;
update ld_warehouse_seq set id=@id+1 where not exists (select 1 from ld_warehouse where name='赠品仓');
insert into ld_warehouse(id,name,status,started,description)
select @id+1,'赠品仓',0,1,null from dual where not exists(select 1 from ld_warehouse where name='赠品仓');
select id into @userid from ld_users where user_name='admin';
insert into ld_warehouse2user(warehouseid,userid)
select @id+1,@userid from dual where not exists(select 1 from ld_warehouse2user
 where warehouseid=@id+1 and userid=@userid);
delimiter;
select id into @id from ld_warehouse_seq;
update ld_warehouse_seq set id=@id+1 where not exists (select 1 from ld_warehouse where name='其他仓');
insert into ld_warehouse(id,name,status,started,description)
select @id+1,'其他仓',0,1,null from dual where not exists(select 1 from ld_warehouse where name='其他仓');
select id into @userid from ld_users where user_name='admin';
insert into ld_warehouse2user(warehouseid,userid)
select @id+1,@userid from dual where not exists(select 1 from ld_warehouse2user
 where warehouseid=@id+1 and userid=@userid);
delimiter;

-- add 2013-11-29 by luyx
select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Stock';
delete from ld_parenttabrel where parenttabid=@parenttabid;
 
select tabid into @tabid from ld_tab where name='Navigation';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,1 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'Navigation','库存导航','库存导航' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
update ld_languagepackage set chinesename='库存导航',newchinesename='库存导航' where tabid=@tabid;
 
select tabid into @tabid from ld_tab where name='OutboundOrder';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,2 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'OutboundOrder','出库单','出库单' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
 
select tabid into @tabid from ld_tab where name='Stock';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,3 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'Stock','入库单','入库单' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
 
select tabid into @tabid from ld_tab where name='Checks';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,4 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'Checks','盘点','盘点' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
select tabid into @tabid from ld_tab where name='Checks';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,5 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'Checks','盘点','盘点' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
select tabid into @tabid from ld_tab where name='Prdtnums';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,6 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'Prdtnums','库存初始化','库存初始化' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
select tabid into @tabid from ld_tab where name='InventoryLedger';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,7 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'InventoryLedger','库存台账','库存台账' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
select tabid into @tabid from ld_tab where name='InventoryAccount';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,8 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'InventoryAccount','库存流水账','库存流水账' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
 
select tabid into @tabid from ld_tab where name='InventoryQuery';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,9 from dual 
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'InventoryQuery','即时库存查询','即时库存查询' from dual
where not exists(select 1 from ld_languagepackage where tabid=@tabid);
delimiter;
 
update ld_languagepackage set tablabel='ServiceContracts' where tabid=37;
update ld_field set presence=1 where tabid=14 and columnname='commissionrate' ;
update ld_field set presence=1 where tabid=14 and columnname='weight';
update ld_field set presence=0,displaytype=2,sequence=1,fieldlabel='总库存数量' where tabid=14 and columnname='qtyinstock';
update ld_field set sequence=2 where tabid=14 and columnname='qtyearly';
update ld_field set sequence=3 where tabid=14 and columnname='smownerid';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 20,13,'序时簿列表每页显示记录条数' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=13);

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 5,14,'更多信息列表显示记录条数 ' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=14);
delimiter;


update ld_field set typeofdata = '' where tabid = (select tabid from ld_tab where `name` = 'Stock') and columnname = 'ware_stock_no';
update ld_field set typeofdata = '' where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and columnname = 'out_no';

select tabid into @accounttabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set block = (select blockid from ld_blocks where tabid = @accounttabid and blocklabel = 'LBL_INVENTORYACCOUNT_INFO') 
where tabid = @accounttabid;


select tabid into @accounttabid1 from ld_tab where `name` = 'InventoryQuery';
update ld_field set block = (select blockid from ld_blocks where tabid = @accounttabid1 and blocklabel = 'LBL_INVENTORYQUERY_INFO') 
where tabid = @accounttabid1;

-- add 2013-11-29 by chenhuangjian
select tabid into @taid from ld_tab where name='InventoryQuery';
select cvid into @cvid from ld_customview where entitytype='InventoryQuery' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
delimiter;

-- 库存及时查询  序时薄 列表
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),0,'LD_products:productname:productname:products_产品名称:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 0);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),1,'LD_products:product_no:product_no:products_产品编号:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 1);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),2,'LD_products:productcode:productcode:products_产品型号:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 2);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),3,'LD_products:unit_price:unit_price:products_参考价:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 3);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),4,'LD_warehouse2products:productqty:productqty:products_库存数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 4);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),5,'LD_products:qtyearly:qtyearly:products_预警数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 5);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),6,'LD_products:commissionrate:commissionrate:products_库存金额:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 6);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),7,'LD_warehouse2products:warehouseid:warehouseid:products_待入库数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 7);
 
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),8,'LD_warehouse2products:productid:productid:products_待出库数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex =8);
 
-- add 2013-12-02 by luyx
select tabsequence into @tabsequence from ld_tab where name='Webforms';
update ld_tab set tabsequence=@tabsequence+1 where name='Cache';
delimiter;
 
-- add by chenhuanjian 2013-12-02
-- 盘点功能
-- 盘点菜单项
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'subject','LD_checks',1,'subject','标题',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'subject');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'checksdate','LD_checks',23,'checksdate','盘点日期',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),1,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'checksdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'wareid','LD_checks',151,'wareid','仓库',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),1,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'warehouseid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'smownerid','LD_checks',53,'smownerid','盘点日期',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),1,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'presence','LD_checks',130,'presence','状态',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),2,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'presence');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'remark','LD_checks',19,'remark','描述',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_DESCRIPTION'),1,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'remark');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'createdtime','LD_crmentity',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),2,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'modifiedtime','LD_crmentity',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),2,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select (select tabid from ld_tab where `name` = 'Checks'),(select max(fieldid) from ld_field)+1,'subsmownerid','LD_checks',165,'subsmownerid','确认盘点人',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),2,0,'' from dual where not exists 
(select * from ld_field where tabid = (select tabid from ld_tab where `name` = 'Checks') and columnname = 'subsmownerid');

insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select (select tabid from ld_tab where `name` = 'Checks'),'Checks','LD_Checks','subject','id','id' from dual where not exists 
(select * from ld_entityname where tabid = (select tabid from ld_tab where `name` = 'Checks') and modulename = 'Checks');
-- 盘点 插入实盘数量字段
call addcolumn('ld_inventoryproductrel','firmoffer','int','11',0);
-- 盘点 插入盈亏数量字段
call addcolumn('ld_inventoryproductrel','profitloss','int','11',0);
-- 盘点 序时薄列表
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks'),0,'LD_checks:subject:subject:Checks_标题:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks') and columnindex = 0);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks'),1,'LD_checks:smownerid:smownerid:Checks_负责人:V' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks') and columnindex = 1);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks'),2,'LD_checks:checksdate:checksdate:Checks_盘点日期:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks') and columnindex = 2);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks'),3,'LD_checks:wareid:wareid:Checks_仓库:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks') and columnindex = 3);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks'),4,'LD_checks:presence:presence:Checks_状态:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Checks') and columnindex = 4);
-- 库存及时查询  序时薄 列表
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),0,'LD_products:productname:productname:products_产品名称:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 0);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),1,'LD_products:product_no:product_no:products_产品编号:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 1);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),2,'LD_products:productcode:productcode:products_产品型号:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 2);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),3,'LD_products:unit_price:unit_price:products_参考价:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 3);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),4,'LD_warehouse2products:productqty:productqty:products_库存数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 4);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),5,'LD_products:qtyearly:qtyearly:products_预警数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 5);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),6,'LD_products:commissionrate:commissionrate:products_库存金额:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 6);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),7,'LD_warehouse2products:warehouseid:warehouseid:products_待入库数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex = 7);

insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery'),8,'LD_warehouse2products:productid:productid:products_待出库数量:' from dual where 
not exists (select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'InventoryQuery') and columnindex =8);

call addtabintoprofile('Stock',0);
call addtabintoprofile('OutboundOrder',0);
call addtabintoprofile('Checks',0);

insert into ld_def_org_share(tabid,permission,editstatus)
select (select tabid from ld_tab where `name` = 'OutboundOrder'),3,0 from dual where not exists 
(select * from ld_def_org_share where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') and permission = 3 and editstatus = 0);

insert into ld_def_org_share(tabid,permission,editstatus)
select (select tabid from ld_tab where `name` = 'Checks'),3,0 from dual where not exists 
(select * from ld_def_org_share where tabid = (select tabid from ld_tab where `name` = 'Checks') and permission = 3 and editstatus = 0);
update ld_def_org_share_seq set id = (select max(ruleid) from ld_def_org_share);

-- 共享规则权限列表
select tabid into @out_tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_org_share_action2tab(share_action_id,tabid)
select 0,@out_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 0 and tabid = @out_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 1,@out_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 1 and tabid = @out_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 2,@out_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 2 and tabid = @out_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 3,@out_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 3 and tabid = @out_tabid);
select tabid into @check_tabid from ld_tab where `name` = 'Checks';
insert into ld_org_share_action2tab(share_action_id,tabid)
select 0,@check_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 0 and tabid = @check_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 1,@check_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 1 and tabid = @check_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 2,@check_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 2 and tabid = @check_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 3,@check_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 3 and tabid = @check_tabid);

select tabid into @stock_tabid from ld_tab where `name` = 'Stock';
insert into ld_org_share_action2tab(share_action_id,tabid)
select 0,@stock_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 0 and tabid = @stock_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 1,@stock_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 1 and tabid = @stock_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 2,@stock_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 2 and tabid = @stock_tabid);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 3,@stock_tabid from dual where not exists(select * from ld_org_share_action2tab where share_action_id = 3 and tabid = @stock_tabid); 
 
-- add 2013-12-02 by qiu
update LD_settings_field_seq set id=(select max(fieldid) from ld_settings_field);
select id into @id from LD_settings_field_seq;
update  LD_settings_field_seq set id=@id+1 where not exists(select 1 from  LD_settings_field where fieldid=@id+1 and name='LBL_BACKUP_SET');

insert into LD_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active) 
select  @id+1,5,'LBL_BACKUP_SET','backupserver.gif','LBL_BACKUP_SET_DESCRIPTION','index.php?module=Settings&action=BackupSettings&parenttab=Settings',33,0  from dual 
where not exists(select 1 from LD_settings_field where name='LBL_BACKUP_SET');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_backup` (
  `id` int(11) default NULL,
  `isusing` int(11) default NULL,
  `backuppath` text,
  `intervaldays` int(11) default NULL,
  `intervalhours` int(11) default NULL,
  `intervalminute` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_backup(id,isusing)
select 1,1 from dual where not exists(select 1 from ld_backup where id=1);
insert into ld_backup(id,isusing)
select 2,1 from dual where not exists(select 1 from ld_backup where id=2);
delimiter;

call fieldprofile('Stock');
call fieldprofile('OutboundOrder');
call fieldprofile('Checks');

delete from ld_tab where `name` = 'CallWareHouse';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select (select tabid from ld_tab where `name` = 'Checks'),'Checks','盘点','盘点' from dual where not exists
(select * from ld_languagepackage where tabid = (select tabid from ld_tab where `name` = 'Checks') and tablabel = 'Checks');


-- add 2013-12-03 by can

Select  max(tabid) into @tabid from LD_tab;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'OftenUseReport',0,50,'Often_UseReport',0,0,1,'Parent Report',0 from dual where not exists(select 1 from lD_tab where name='oftenUseReport');

select tabid into @tabid from lD_tab where name='oftenUseReport';
select parenttabid into @parenttabid from LD_parenttab where  parenttab_Label='Parent Reports';
insert into LD_parenttabrel(tabid,parenttabid,sequence) select @tabid,@parenttabid,1 from dual where not exists(select 1 from LD_parenttabrel where tabid=@tabid );
call addtabintoprofile('OftenUseReport',1);

select tabid into @tabid from lD_tab where name='oftenUseReport';
update LD_parenttabrel set sequence=1  where parenttabid=5 and tabid=@tabid;
select tabid into @tabide from lD_tab where name='Comprehensivereports'; 
update LD_parenttabrel set sequence=4  where parenttabid=5 and tabid=@tabide;
select tabid into @tabidd from lD_tab where name='Reports'; 
update LD_parenttabrel set sequence=8  where parenttabid=5 and tabid=@tabidd;



Select  max(tabid) into @tabid from LD_tab;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'OftenUseReport',0,50,'Often_UseReport',0,0,1,'Parent Report',0 from dual where not exists(select 1 from 

lD_tab where name='oftenUseReport');

select tabid into @tabid from lD_tab where name='oftenUseReport';
select parenttabid into @parenttabid from LD_parenttab where  parenttab_Label='Parent Reports';
insert into LD_parenttabrel(tabid,parenttabid,sequence) select @tabid,@parenttabid,1 from dual where not exists(select 1 from LD_parenttabrel where tabid=@tabid );
call addtabintoprofile('OftenUseReport',1);

select tabid into @tabid from lD_tab where name='oftenUseReport';
update LD_parenttabrel set sequence=1  where parenttabid=5 and tabid=@tabid;
select tabid into @tabide from lD_tab where name='Comprehensivereports'; 
update LD_parenttabrel set sequence=4  where parenttabid=5 and tabid=@tabide;
select tabid into @tabidd from lD_tab where name='Reports'; 
update LD_parenttabrel set sequence=8  where parenttabid=5 and tabid=@tabidd;
delimiter;

CREATE TABLE if not EXISTS `ld_usereport` (
  `usereportid` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `reportlabel` varchar(100) default NULL,
  `tabids` varchar(100) default NULL,
  `basicfilter` int(1) default '1',
  `advfilter` int(1) default '1',
  `Setcolumns` int(1) default '1',
  `Parent_id` int(11) default '0',
  `sequence` int(4) default NULL,
  `reporttype` int(4) default NULL,
  PRIMARY KEY  (`usereportid`),
  KEY `idx_usereport_parentid` (`Parent_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_usereportadv` (
  `reportid` int(19) NOT NULL,
  `columnindex` int(11) NOT NULL,
  `columnname` varchar(250) default '',
  `comparator` varchar(10) default '',
  `value` varchar(200) default '',
  `groupid` int(11) default '1',
  `column_condition` varchar(256) default 'and',
  KEY `idx_usereportadv_reportid` USING BTREE (`reportid`),
  CONSTRAINT `fk_1_usereportadv_reportid` FOREIGN KEY (`reportid`) REFERENCES `ld_usereport` (`usereportid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  IF NOT EXISTS `ld_usereportadv_grouping` (
  `groupid` int(11) NOT NULL,
  `reportid` int(19) NOT NULL,
  `group_condition` varchar(256) default NULL,
  `condition_expression` text,
  PRIMARY KEY  (`groupid`,`reportid`),
  KEY `idx_usereportgroupusereportid` USING BTREE (`reportid`,`groupid`),
  CONSTRAINT `fk_1_lingdang_usereportgroup_reportid` FOREIGN KEY (`reportid`) REFERENCES `ld_usereport` (`usereportid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO `ld_usereport`(name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
 select  'SalesReport', '销售报表', '0', '0', '0', '0', '0', '1', '0' from dual 
where not EXISTS(select 1 from ld_usereport where name='salesreport');

INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
 select 'SumSequence', '统计排名', '0', '0', '0', '0', '0', '2', '0' from DUAL
where not EXISTS(select 1 from ld_usereport where name='SumSequence');
select usereportid into @parentid from ld_usereport where name='SalesReport';

INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
select 'SalesOrderTrack', '{$SalesOrder}跟踪表', '22', '1', '1', '1',  @parentid,3, '10' from DUAL
where not EXISTS(select 1 from ld_usereport where name='SalesOrderTrack');
select tabid into @tabid from ld_tab where name='paymentplan';
INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
select 'CashBillSum_Paymentplan', '应收款统计表_按{$PaymentPlan}统计', @tabid, '1', '1', '1', @parentid,6,'10' from DUAL
where not EXISTS(select 1 from ld_usereport where name='CashBillSum_Paymentplan');

INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
 select 'CashBillSum_SalesOrder', '应收款统计表_按{$SalesOrder}统计', '22', '1', '1', '1', @parentid, '11', '10' from DUAL
where not EXISTS(select 1 from ld_usereport where name='CashBillSum_SalesOrder');
delimiter;

select usereportid into @parentid from ld_usereport where name='SumSequence';
INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
select 'Contractnumber', '签约数量龙虎榜', '22', '1', '1', '0', @parentid, '3', '20' from DUAL
where not EXISTS(select 1 from ld_usereport where name='Contractnumber');

INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
select 'Contractamount', '签约金额龙虎榜', '22', '1', '1', '0', @parentid, '7', '20' from DUAL
where not EXISTS(select 1 from ld_usereport where name='Contractamount');

INSERT INTO `ld_usereport` (name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype)
select  'SalesSumSequence', '销售统计排名', '0', '1', '0', '1', @parentid, '11', '25' from dual 
where not EXISTS(select 1 from ld_usereport where name='SalesSumSequence');
delimiter;


CREATE TABLE if not EXISTS `ld_usereportbasic` (
  `id` int(10) NOT NULL auto_increment,
  `Usereportid` int(10) default '0',
  `columns` varchar(100) default NULL,
  `Defaultvalue` varchar(100) default NULL,
  `Sequence` int(4) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_usereportbasic_usereportid` (`Usereportid`),
  CONSTRAINT `fk_1_lingdang_usereportbasic_usereportid` FOREIGN KEY (`Usereportid`) REFERENCES `ld_usereport` (`usereportid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';
INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid, 'LD_salesorder:duedate:duedate:SalesOrder_duedate:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_salesorder:duedate:duedate:SalesOrder%'and Usereportid=@usereportid);

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid, 'LD_accountSalesOrder:accountname:account_id:SalesOrder_accountname:I', '', '6' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_accountSalesOrder:accountname:account_id:SalesOrder%' and Usereportid=@usereportid);
delimiter;
select usereportid into @usereportid from ld_usereport where name='CashBillSum_Paymentplan';

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_paymentplan:plandate:plandate:PaymentPlan%' and Usereportid=@usereportid);


INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid,'LD_accountpaymentplan:accountname:account_id:PaymentPlan_Account_Name:I', '', '6' from dual 
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_accountpaymentplan:accountname:account_id:PaymentPlan%'and Usereportid=@usereportid);
delimiter;

select usereportid into @usereportid from ld_usereport where name='Contractnumber';

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid,'LD_crmentity:createdtime:createdtime:SalesOrder_createdtime:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_crmentity:createdtime:createdtime:SalesOrder%' and Usereportid=@usereportid);

delimiter;
select usereportid into @usereportid from ld_usereport where name='Contractamount';

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid,'LD_crmentity:createdtime:createdtime:SalesOrder_createdtime:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_crmentity:createdtime:createdtime:SalesOrder%' and Usereportid=@usereportid);

delimiter;

select usereportid into @usereportid from ld_usereport where name='SalesSumSequence';

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid,'LD_crmentity:createdtime:createdtime:OftenUseReport_createdtime:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_crmentity:createdtime:createdtime:OftenUseReport%' and Usereportid=@usereportid);

delimiter;
select usereportid into @usereportid from ld_usereport where name='CashBillSum_SalesOrder';
INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid, 'LD_salesorder:duedate:duedate:SalesOrder_duedate:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_salesorder:duedate:duedate:SalesOrder%'and Usereportid=@usereportid);

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid, 'LD_accountSalesOrder:accountname:account_id:SalesOrder_Account_Name:I', '', '6' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_accountSalesOrder:accountname:account_id:SalesOrder%' and Usereportid=@usereportid);
delimiter;
CREATE TABLE IF not EXISTS `ld_usereportcolumns` (
  `id` int(11) NOT NULL auto_increment,
  `Usereportid` int(11) default '0',
  `columns` varchar(100) default NULL,
  `Sequence` int(4) default NULL,
  `columnshow` int(1) default '1',
  `realcolumns` varchar(100) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_usereportcolumns_usereportid` (`Usereportid`),
  CONSTRAINT `ld_usereportcolumns_ibfk_1` FOREIGN KEY (`Usereportid`) REFERENCES `ld_usereport` (`usereportid`) ON DELETE 

CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

select usereportid into @usereportid from ld_usereport where name='CashBillSum_Paymentplan';
INSERT INTO `ld_usereportcolumns`(usereportid,columns,sequence,columnshow,realcolumns)
select @usereportid, 'LD_paymentplan:smownerid:assigned_user_id:PaymentPlan_assigned_user_id:V', '3', '1', 'LD_paymentplan:smownerid:assigned_user_id:PaymentPlan_assigned_user_id:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:smownerid:assigned_user_id:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:V', '6', '1', 'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:accountid:account_id:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_salesorder:I', '9', '1', 'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_salesorder:I' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:salesorderid:salesorder_id:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns`(usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', '12', '1', 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:salesorder_no:salesorder_no:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N', '15', '1', 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:total:hdnGrandTotal:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan_no:I', '18', '1', 'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan_no:I' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns`  (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D', '18', '1', 'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:plandate:plandate:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V', '21', '1', 'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:periodtime:periodtime:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_paymentplan:amount:amount:PaymentPlan_amount:N', '24', '1', 'LD_paymentplan:amount:amount:PaymentPlan_amount:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:amount:amount:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns`  (usereportid,columns,sequence,columnshow,realcolumns)
select @usereportid,  'LD_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:V', '30', '1', 'LD_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:actualamount:actualamount:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,   'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V', '33', '1', 'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,  'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N', '36', '1', 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N' from dual 
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport%' and Usereportid=@usereportid);

delimiter;
select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V', '3', '1', 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_crmentity:smownerid:assigned_user_id:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', '6', '1', 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:salesorder_no:salesorder_no:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT', '9', '1', 'LD_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_crmentity:createdtime:createdtime:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_salesorder:subject:subject:SalesOrder_Subject:V', '12', '1', 'LD_salesorder:subject:subject:SalesOrder_Subject:V' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:subject:subject:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_accountSalesOrder:accountid:account_id:SalesOrder_Account_Name:I', '15', '1', 'LD_accountSalesOrder:accountid:account_id:SalesOrder_Account_Name:I' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_accountSalesOrder:accountid:account_id:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_salesorder:sostatus:sostatus:SalesOrder_sostatus:V', '18', '1', 'LD_salesorder:sostatus:sostatus:SalesOrder_sostatus:V'from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:sostatus:sostatus:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_salesorder:duedate:duedate:SalesOrder_duedate:D', '21', '1', 'LD_salesorder:duedate:duedate:SalesOrder_duedate:D' from dual
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:duedate:duedate:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N', '24', '1', 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_salesorder:total:hdnGrandTotal:SalesOrder%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_invoice:total:hdnGrandTotal:Invoice_Total:N', '27', '1', 'LD_invoice:total:hdnGrandTotal:Invoice_Total:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_invoice:total:hdnGrandTotal:Invoice%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_InvoiceBalance:N', '30', '1', 'LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_InvoiceBalance:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_reporttable:InvoiceBalance:开票余额:OftenUseReport%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_reporttable:Expenseamount:费用金额:OftenUseReport_Expenseamount:N', '33', '1', 'LD_reporttable:Expenseamount:费用金额:OftenUseReport_Expenseamount:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_reporttable:Expenseamount:费用金额:OftenUseReport%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N', '36', '1', 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_reporttable:CashBillamount:已收款金额:OftenUseReport%' and Usereportid=@usereportid);

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N', '39', '1', 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport%' and Usereportid=@usereportid);

delimiter;
select usereportid into @usereportid from ld_usereport where name='CashBillSum_SalesOrder';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 
@usereportid,'LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V',3,1,'LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_usersSalesOrder:smownerid:assigned_user_id:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V',6,1,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:salesorder_no:salesorder_no:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT',9,1,'LD_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_crmentity:createdtime:createdtime:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:subject:subject:SalesOrder_Subject:V',12,1,'LD_salesorder:subject:subject:SalesOrder_Subject:V' 
from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:subject:subject:SalesOrder%');


INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:accountid:account_id:SalesOrder_Account Name:I',15,1,'LD_salesorder:accountid:account_id:SalesOrder_Account Name:I' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:accountid:account_id:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:sostatus:sostatus:SalesOrder_Status:V',18,1,'LD_salesorder:sostatus:sostatus:SalesOrder_Status:V' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:sostatus:sostatus:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select  @usereportid,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N',21,1,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:total:hdnGrandTotal:SalesOrder%');


INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N',24,1,'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_reporttable:CashBillamount:已收款金额:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N',27,1,'LD_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_reporttable:PaymentBalance:应收款余额:OftenUseReport%');
delimiter;
select usereportid into @usereportid from ld_usereport where name='SalesSumSequence';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_users:last_name:last_name:OftenUseReport_last_name:N',2,1,'LD_users:last_name:last_name:OftenUseReport_last_name:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_users:last_name:last_name:OftenUseReport%');


INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_account:accountcount:accountcount:OftenUseReport_accountcount:N',3,1,'LD_account:accountcount:accountcount:OftenUseReport_accountcount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_account:accountcount:accountcount:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_contactdetails:contactcount:contactcount:OftenUseReport_contactcount:N',6,1,'LD_contactdetails:contactcount:contactcount:OftenUseReport_contactcount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_contactdetails:contactcount:contactcount:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_potentials:potentialcount:potentialcount:OftenUseReport_potentialcount:N',9,1,'LD_potentials:potentialcount:potentialcount:OftenUseReport_potentialcount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_potentials:potentialcount:potentialcount:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
select 

@usereportid,'LD_activies:calendarcount:calendarcount:OftenUseReport_calendarcount:N',12,1,'LD_activies:calendarcount:calendarcount:OftenUseReport_calendarcount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_activies:calendarcount:calendarcount:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_contactrecordscount:N',15,1,'LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_contactrecordscount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_helpdeskcount:N',18,1,'LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_helpdeskcount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_cashbilltotal:N',21,1,'LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_cashbilltotal:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_cashbill:cashbillcount:cashbillcount:OftenUseReport_cashbillcount:N',24,1,'LD_cashbill:cashbillcount:cashbillcount:OftenUseReport_cashbillcount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_cashbill:cashbillcount:cashbillcount:OftenUseReport%');


INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_salesorder:salesordertotal:salesordertotal:OftenUseReport_salesordertotal:N',27,1,'LD_salesorder:salesordertotal:salesordertotal:OftenUseReport_salesordertotal:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:salesordertotal:salesordertotal:OftenUseReport%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:salesordercount:salesordercount:OftenUseReport_salesordercount:N',30,1,'LD_salesorder:salesordercount:salesordercount:OftenUseReport_salesordercount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:salesordercount:salesordercount:OftenUseReport%');


INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_expense:expensetotal:expensetotal:OftenUseReport_expensetotal:N',33,1,'LD_expense:expensetotal:expensetotal:OftenUseReport_expensetotal:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_expense:expensetotal:expensetotal:OftenUseReport%');
delimiter;
select usereportid into @usereportid from ld_usereport where name='Contractnumber';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N',3,1,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:ordernum:ordernum:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_salesorder:createor:createor:SalesOrder_createor:N',6,1,'LD_salesorder:createor:createor:SalesOrder_createor:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:createor:createor:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:groupbycount:groupbycount:SalesOrder_groupbycount:N',9,1,'LD_salesorder:groupbycount:groupbycount:SalesOrder_groupbycount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:groupbycount:groupbycount:SalesOrder%');

delimiter;

select usereportid into @usereportid from ld_usereport where name='Contractamount';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N',3,1,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:ordernum:ordernum:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 

@usereportid,'LD_salesorder:createor:createor:SalesOrder_createor:N',6,1,'LD_salesorder:createor:createor:SalesOrder_createor:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:createor:createor:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:total:total:SalesOrder_total:N',9,1,'LD_salesorder:total:total:SalesOrder_total:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:total:total:SalesOrder%');
delimiter;

CREATE TABLE  if not EXISTS `ld_usereportfilter` (
  `id` int(4) NOT NULL auto_increment,
  `Usereportid` int(10) default '0',
  `Usewhere` text,
  `sequence` int(4) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_usereportid_advfilter` (`Usereportid`),
  CONSTRAINT `fk_1_lingdang_userreportadvfilter` FOREIGN KEY (`Usereportid`) REFERENCES `ld_usereport` (`usereportid`) ON 

DELETE CASCADE
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;

update ld_field_seq set id =(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_customview_seq set id=(select max(cvid) from ld_customview);
update ld_settings_field_seq set id=(select max(fieldid) from ld_settings_field);
update ld_modentity_num_seq set id=(select max(num_id) from ld_modentity_num);
delimiter;
-- add 2013-12-04 by chenhuangjian
insert into LD_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions)
select (select max(relation_id)+1 from ld_relatedlists),22,(select tabid from ld_tab where `name` = 'OutboundOrder'),'get_outorder',3,'OutboundOrder',0,'add' from dual where not exists 
(select * from LD_relatedlists where tabid = 22 and related_tabid = (select tabid from ld_tab where `name` = 'OutboundOrder'));

update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);

select tabid into @relatedtabid from ld_tab where `name` = 'OutboundOrder';
-- 出入库更多信息列
insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'accountid' and tabid = @relatedtabid),0,1,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'accountid' and tabid = @relatedtabid));

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'salesorderid' and tabid = @relatedtabid),0,2,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'salesorderid' and tabid = @relatedtabid));

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'out_no' and tabid = @relatedtabid),0,3,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'out_no' and tabid = @relatedtabid));

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'wareid' and tabid = @relatedtabid),0,4,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'wareid' and tabid = @relatedtabid));

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'smownerid' and tabid = @relatedtabid),0,5,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'smownerid' and tabid = @relatedtabid));

insert ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @relatedtabid,(select fieldid from ld_field where columnname = 'presence' and tabid = @relatedtabid),0,5,1,0 from dual where not exists 
(select * from ld_relatedlists_lable where tabid = @relatedtabid and fieldid = (select fieldid from ld_field where columnname = 'presence' and tabid = @relatedtabid));

-- 库存流水账列固定
update ld_field set typeofdata ='V~M' where tabid = (select tabid from ld_tab where `name` = 'InventoryAccount') and uitype <= 151;
insert ld_cvcolumnlist(cvid,columnindex,columnname)
select (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock'),6,'LD_stock:presence:presence:Stock_状态:' from dual where not exists 
(select * from ld_cvcolumnlist where cvid= (select max(cvid) from ld_customview where viewname = 'All' and entitytype = 'Stock') and columnindex = 6);

-- 入库单  未入库 已入库 条件检索
select cvid into @w_cvid from ld_customview where entitytype = 'Stock' and viewname = '未入库';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @w_cvid,0,'LD_stock:presence:presence:Stock_状态:V','e','0',1,'' from dual where not exists 
(select * from ld_cvadvfilter where cvid = @w_cvid);

select cvid into @y_cvid from ld_customview where entitytype = 'Stock' and viewname = '已入库';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @y_cvid,0,'LD_stock:presence:presence:Stock_状态:V','e','1',1,'' from dual where not exists 
(select * from ld_cvadvfilter where cvid = @y_cvid);

-- 出库单  未出库 已出库 条件检索
select cvid into @w_cvid from ld_customview where entitytype = 'OutboundOrder' and viewname = '未出库';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @w_cvid,0,'LD_outboundorder:presence:presence:OutboundOrder_状态:V','e','0',1,'' from dual where not exists 
(select * from ld_cvadvfilter where cvid = @w_cvid);

select cvid into @y_cvid from ld_customview where entitytype = 'OutboundOrder' and viewname = '已出库';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @y_cvid,0,'LD_outboundorder:presence:presence:OutboundOrder_状态:V','e','1',1,'' from dual where not exists 
(select * from ld_cvadvfilter where cvid = @y_cvid);

-- add 2013-11-04 by can
CREATE TABLE if not EXISTS `ld_producttoolfield` (
  `producttoolfieldid` int(10) NOT NULL,
  `columnname` varchar(50) default NULL,
  `fieldlabel` varchar(100) default NULL,
  `defaultvalue` varchar(255) default NULL,
  `presence` int(4) default '0',
  `uitype` int(10) default NULL,
  `typeofdata` varchar(20) default NULL,
`sequence` int(10) default 1,
  PRIMARY KEY  (`producttoolfieldid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_producttoolfield_seq` (
  `id` int(19) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not EXISTS `ld_inventoryproductrelscf` (
  `lineitem_id` int(19) default NULL,
  `sequence` int(10) default NULL,
  `sendarea` decimal(15,2) default NULL,
  KEY `idx_lineitemid_inventoryproductrelscf` USING BTREE (`lineitem_id`),
  CONSTRAINT `fk_1_lingdang_inventoryproductrelscf` FOREIGN KEY (`lineitem_id`) REFERENCES `ld_inventoryproductrel` (`lineitem_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(fieldid) into @maxid  from ld_settings_field ;
UPDATE ld_settings_field_seq set id=@maxid+2 where not EXISTS(select 1 from ld_settings_field where blockid=3 and name='LBL_ProductTool_field');
insert into ld_settings_field (fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @maxid+1,3,'LBL_ProductTool_field','producttoolfield.gif','LBL_ProductTool_field','index.php?module=Settings&action=ProdctToolField&parenttab=Settings',20,0
from dual where not EXISTS(select 1 from ld_settings_field where blockid=3 and name='LBL_ProductTool_field');


insert into ld_producttoolfield_seq (id) select 1 from dual where not EXISTS(select 1 from ld_producttoolfield_seq);
select id into @id from ld_producttoolfield_seq  ;
update ld_producttoolfield_seq set id=id+1 where not EXISTS (select 1 from ld_producttoolfield where columnname='sendarea');
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence)
select @id,'sendarea','已租面积','',0,7,'NN~M~15,2',1 from dual where not EXISTS (select 1 from ld_producttoolfield where columnname='sendarea');
delimiter;

update ld_producttoolfield set presence=1 where columnname='sendarea';

select tabid into @tabid from ld_tab where name='OftenUseReport';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,'Often_UseReport','常用报表','常用报表' from dual 
where not exists(select * from ld_languagepackage where tabid = @tabid);
delimiter;

update ld_systems_deploy set deploy_value=1 where deploy_type=11;
update ld_backup set backuppath=NULL;

-- 2013-12-06 by chen
-- 出入库 设置 字段排序
select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set sequence = 1 where tabid  = @tabid and columnname = 'vendor_id';
update ld_field set sequence = 2 where tabid  = @tabid and columnname = 'ware_stock_no';
update ld_field set sequence = 3 where tabid  = @tabid and columnname = 'purchaseorder_id';
update ld_field set sequence = 4 where tabid  = @tabid and columnname = 'smownerid';
update ld_field set sequence = 5 where tabid  = @tabid and columnname = 'createdate';
update ld_field set sequence = 6 where tabid  = @tabid and columnname = 'wareid';
update ld_field set sequence = 7 where tabid  = @tabid and columnname = 'remark';
update ld_field set sequence = 8 where tabid  = @tabid and columnname = 'presence';

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_field set sequence = 1 where tabid  = @tabid and columnname = 'accountid';
update ld_field set sequence = 2 where tabid  = @tabid and columnname = 'salesorderid';
update ld_field set sequence = 3 where tabid  = @tabid and columnname = 'smownerid';
update ld_field set sequence = 4 where tabid  = @tabid and columnname = 'outdate';
update ld_field set sequence = 5 where tabid  = @tabid and columnname = 'wareid';
update ld_field set sequence = 6 where tabid  = @tabid and columnname = 'out_no';
update ld_field set sequence = 7 where tabid  = @tabid and columnname = 'presence';
update ld_field set sequence = 8 where tabid  = @tabid and columnname = 'remark';
-- 出入库 打印模板
update ld_tab set printtab = 1 where `name` = 'Stock' or `name` = 'OutboundOrder';

-- add 2013-12-09 by chen
-- 产品表 总库存数添加默认值
alter table ld_products alter column qtyinstock set default 0.000;
-- 采购订单 添加库存状态
call addcolumn('ld_purchaseorder','stockpresence','varchar','25',null);
-- 合同订单 添加出库状态
call addcolumn('ld_salesorder','stockpresence','varchar','25',null);
-- 采购订单 详细界面 添加入库状态
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'stockpresence','LD_purchaseorder',1,1,0,'stockpresence','入库状态',
(select sequence from ld_field where tabid = @tabid and columnname = 'smownerid'),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PO_INFORMATION'),
2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'stockpresence'); 
-- 采购订单  添加入库状态默认值
alter table ld_purchaseorder alter column stockpresence set default '未入库';
-- 合同订单  添加出库状态默认值
alter table ld_salesorder alter column stockpresence set default '未出库';
-- 采购订单 序时薄添加入库状态列
select cvid into @cvid from ld_customview where entitytype = 'PurchaseOrder' and viewname = 'All';
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex + 1,'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' 
from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnname = 'LD_crmentity:stockpresence:stockpresence:PurchaseOrder_入库状态:V'); 
-- 合同订单 详细界面 添加出库状态
select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'stockpresence','LD_salesorder',1,1,0,'stockpresence','出库状态',
(select sequence from ld_field where tabid = @tabid and columnname = 'smownerid'),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_SO_INFORMATION'),2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'stockpresence');
-- 合同订单 序时薄添加出库状态列
select cvid into @cvid from ld_customview where entitytype = 'SalesOrder' and viewname = 'All';
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex + 1,'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V' 
from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnname = 'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V'); 
-- 系统参数 出入单 说明
update ld_systems_deploy set description = '出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否' where deploy_type = 10;

-- add 2013-12-09 by can
update ld_settings_field  set active=0 where name='LBL_ProductTool_field';
update ld_settings_field  set description='LBL_ProductTool_Description' where name='LBL_ProductTool_field';
update ld_settings_field  set linkto='index.php?module=Settings&action=ProductToolField&parenttab=Settings' where name='LBL_ProductTool_field';
update ld_settings_field  set iconpath='productfield.gif' where name='LBL_ProductTool_field';
call addcolumn('ld_version','trade','varchar','50',NULL);
delimiter;
update ld_modentity_num set prefix='RK' where semodule='Stock';

-- add 2013-12-09 by chen
-- 入库单 增加确认入库单人字段
call addcolumn('ld_stock','subsmownerid','int','11',0);
-- 入库单 详细界面添加：创建人，创建时间，修改时间，确认入库人
select tabid into @tabid from ld_tab where `name` = 'Stock';
select max(sequence) into @sequence  from ld_field where tabid = @tabid;
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'smcreatorid','LD_crmentity',1,53,0,'smcreatorid','创建人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+1 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'createdtime','LD_crmentity',1,1,0,'createdtime','创建时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+2 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'modifiedtime','LD_crmentity',1,1,0,'modifiedtime','修改时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+3 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'subsmownerid','LD_stock',1,165,0,'subsmownerid','确认入库人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+4 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'subsmownerid'); 
-- 出入单 详细界面添加:创建人，创建时间，修改时间，确认出库人
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select max(sequence) into @sequence  from ld_field where tabid = @tabid;
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'smcreatorid','LD_crmentity',1,53,0,'smcreatorid','创建人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+1 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'createdtime','LD_crmentity',1,1,0,'createdtime','创建时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+2 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'modifiedtime','LD_crmentity',1,1,0,'modifiedtime','修改时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+3 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'subsmownerid','ld_outboundorder',1,165,0,'subsmownerid','确认出库人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+4 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'subsmownerid');


-- add 2013-12-12
select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';
update ld_usereportbasic set COLUMNS='LD_crmentity:createdtime:createdtime:SalesOrder_createdtime:D' 
where COLUMns='LD_salesorder:duedate:duedate:SalesOrder_duedate:D' and Usereportid=@usereportid;
update ld_usereportcolumns set COLUMNS='LD_users:last_name:last_name:OftenUseReport_last_name:V' ,
realcolumns='LD_users:last_name:last_name:OftenUseReport_last_name:V' where  columns='LD_users:last_name:last_name:OftenUseReport_last_name:N';
delimiter;

call AddColumn('ld_templateprint','replacespacevalue','varchar',20,'1');
delimiter;

-- 盘点新增画面  显示仓库4
select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set fieldlabel = "负责人" where tabid = @tabid and columnname = 'smownerid';
delete from ld_field where tabid = @tabid and columnname = 'wareid';

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'wareid','LD_checks',1,'wareid','仓库',(select blockid from ld_blocks where blocklabel = 'LBL_CHECKS_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'wareid');
-- 盘点全部 不可编辑 删除
update ld_customview set status = 0 where entitytype ='Checks' and viewname = 'All';
update ld_customview set status = 0 where entitytype ='InventoryAccount' and viewname = 'All';
update ld_customview set status = 0 where entitytype ='InventoryQuery' and viewname = 'All';
-- 盘点默认分类添加
select max(cvid) into @cvid from ld_customview;
insert into ld_customview(cvid,viewname,entitytype,`status`,userid,sequence)
select @cvid+1,'盘点中','Checks',0,1,1 from dual where not exists (select * from ld_customview where entitytype = 'Checks' and viewname = '盘点中');
insert into ld_customview(cvid,viewname,entitytype,`status`,userid,sequence)
select @cvid+2,'盘点结束','Checks',0,1,2 from dual where not exists (select * from ld_customview where entitytype = 'Checks' and viewname = '盘点结束');
-- 盘点 盘点中显示项
select cvid into @cvid from ld_customview where viewname = '盘点中' and entitytype = 'Checks';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_checks:subject:subject:Checks_标题:V' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_checks:smownerid:smownerid:Checks_负责人:V' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_checks:checksdate:checksdate:Checks_盘点日期:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_checks:wareid:wareid:Checks_仓库:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_checks:presence:presence:Checks_状态:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_checks:subsmownerid:subsmownerid:Checks_确认盘点人:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 5);
insert into ld_cvadvfilter(cvid,columnname,comparator,`value`)
select @cvid,'LD_checks:presence:presence:Checks_状态:','e',0 from dual where not exists (select * from ld_cvadvfilter where cvid = @cvid and columnname = 'LD_checks:presence:presence:Checks_状态:');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 0 ' from dual where not exists (select * from ld_cvadvfilter_grouping where cvid = @cvid);
-- 盘点 盘点结束显示项
select cvid into @cvid from ld_customview where viewname = '盘点结束' and entitytype = 'Checks';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_checks:subject:subject:Checks_标题:V' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_checks:smownerid:smownerid:Checks_负责人:V' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_checks:checksdate:checksdate:Checks_盘点日期:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_checks:wareid:wareid:Checks_仓库:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_checks:presence:presence:Checks_状态:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_checks:subsmownerid:subsmownerid:Checks_确认盘点人:' from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 5);
insert into ld_cvadvfilter(cvid,columnname,comparator,`value`)
select @cvid,'LD_checks:presence:presence:Checks_状态:','e',1 from dual where not exists (select * from ld_cvadvfilter where cvid = @cvid and columnname = 'LD_checks:presence:presence:Checks_状态:');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',' 1 ' from dual where not exists (select * from ld_cvadvfilter_grouping where cvid = @cvid);

UPDATE LD_salesorder set stockpresence = '未出库' where stockpresence is null;
UPDATE ld_purchaseorder set stockpresence = '未入库' where stockpresence is null;
delimiter;

update ld_field set quickcreate=3;

update ld_field set quickcreate=1 where tabid=6;
update ld_field set quickcreate=2 where tabid=6 and fieldname in ('phone','email1');
update ld_field set quickcreate=0 where tabid=6 and typeofdata='V~M';

update ld_field set quickcreate=1 where tabid=4;
update ld_field set quickcreate=2 where tabid=4 and fieldname in ('account_id','mobile','email');
update ld_field set quickcreate=0 where tabid=4 and typeofdata='V~M';

update ld_field set quickcreate=1 where tabid=14;
update ld_field set quickcreate=2 where tabid=14 and fieldname in ('productcategory','productsheet','discontinued','usageunit','unit_price');
update ld_field set quickcreate=0 where tabid=14 and typeofdata='V~M';

update ld_field set quickcreate=1 where tabid=18;
update ld_field set quickcreate=2 where tabid=18 and fieldname in('phone','email','glacct');
update ld_field set quickcreate=0 where tabid=18 and typeofdata='V~M';

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description)
SELECT 0,15,"采购合同新增保存后是否立即弹出创建回款计划。1:否，0:是" FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_systems_deploy WHERE deploy_type=15);
delimiter;

INSERT INTO ld_systems_deploy (deploy_value,deploy_type,description) 
select 1,16,"客户资料审批完成后是否允许进行编辑 1:否，0:是" FROM DUAL 
WHERE NOT EXISTS(select 1 from ld_systems_deploy where deploy_type =16);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_documenttemplates`(
  `foldername` varchar(100) default NULL,
  `templatename` varchar(100) default NULL,
  `subject` varchar(100) default NULL,
  `description` text,
  `body` text,
  `deleted` int(1) NOT NULL default '0',
  `templateid` int(19) NOT NULL auto_increment,
  PRIMARY KEY  (`templateid`),
  KEY `emailtemplates_foldernamd_templatename_subject_idx` 

(`foldername`,`templatename`,`subject`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


update ld_usereportcolumns set `columns`='LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V' ,realcolumns='LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V'
where Usereportid in  (select usereportid from ld_usereport where name='Contractamount') and columns='LD_salesorder:createor:createor:SalesOrder_createor:N';

update ld_usereportcolumns set `columns`='LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V' ,realcolumns='LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V'
where Usereportid in  (select usereportid from ld_usereport where name='Contractnumber') and columns='LD_salesorder:createor:createor:SalesOrder_createor:N';
delimiter;

-- add 2013-12-12 by chen
-- 2013-12-11
select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set uitype = 159 where tabid = @tabid and columnname = 'productname' and fieldlabel = '产品名称';
-- 盘点默认分类添加   以前脚本更新
select max(cvid) into @cvid from ld_customview;
update ld_customview set `status` = 1 where cvid = @cvid and viewname = '盘点中' and entitytype = 'Checks';
update ld_customview set `status` = 1 where cvid = @cvid and viewname = '盘点结束' and entitytype = 'Checks';
-- 盘点默认分类添加   更新结束
-- 盘点 新增仓库 文本框
select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set uitype = 151 where tabid = @tabid and columnname = 'wareid' and fieldlabel = '仓库';

-- 盘点表
CREATE TABLE IF NOT EXISTS `ld_checks` (
  `id` int(11) NOT NULL auto_increment,
  `subject` varchar(25) NOT NULL COMMENT '标题',
  `checksdate` date default NULL COMMENT '盘点日期',
  `wareid` int(11) default NULL COMMENT '仓库',
  `smownerid` int(11) default NULL COMMENT '负责人',
  `presence` int(11) default '0' COMMENT '0 盘点中 1盘点结束',
  `subsmownerid` int(11) default NULL COMMENT '确认盘点人',
  `taxtype` varchar(25) default NULL,
  `currency_id` int(11) default NULL,
  `conversion_rate` decimal(25,3) default NULL,
  `remark` varchar(25) default NULL COMMENT '描述',
  `editdate` date default NULL COMMENT '修改时间',
  `createdate` date default NULL COMMENT '创建时间',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12350 DEFAULT CHARSET=utf8;


insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'本月',0,0,'InventoryAccount',1,1,1 from dual where not exists (select * from ld_customview 
where viewname = '本月' and entitytype = 'InventoryAccount');

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'上月',0,0,'InventoryAccount',1,1,2 from dual where not exists (select * from ld_customview 
where viewname = '上月' and entitytype = 'InventoryAccount' );

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'确认入库',0,0,'InventoryAccount',1,1,3 from dual where not exists (select * from ld_customview 
where viewname = '确认入库' and entitytype = 'InventoryAccount' );

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'确认出库',0,0,'InventoryAccount',1,1,4 from dual where not exists (select * from ld_customview 
where viewname = '确认出库' and entitytype = 'InventoryAccount');

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'确认调拨',0,0,'InventoryAccount',1,1,5 from dual where not exists (select * from ld_customview 
where viewname = '确认调拨' and entitytype = 'InventoryAccount' );

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'确认盘点',0,0,'InventoryAccount',1,1,6 from dual 
where not exists (select * from ld_customview where viewname = '确认盘点' and entitytype = 'InventoryAccount');
update ld_customview_seq set id = (select max(cvid) from ld_customview);

select cvid into @cvid from ld_customview where viewname = '本月' and entitytype = 'InventoryAccount';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间','thismonth',
(select date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 0 month)),
(select date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval -1 month)) from dual where not exists (select * from ld_cvstdfilter 
where cvid = @cvid);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);

select cvid into @cvid from ld_customview where viewname = '上月' and entitytype = 'InventoryAccount';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间','lastmonth',
(select date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now())-1 day),interval 1 month)),
(select date_sub(date_sub(date_format(now(),'%y-%m-%d'),interval extract(day from now()) day),interval 0 month)) from dual where not exists (select * from ld_cvstdfilter 
where cvid = @cvid);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);

select cvid into @cvid from ld_customview where viewname = '确认入库' and entitytype = 'InventoryAccount';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:','e','确认入库',1,'' from dual where not exists (select * from ld_cvadvfilter 
where cvid = @cvid and columnname = 'LD_warehousecondtions:type:type:InventoryAccount_操作类型:');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid and groupid = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);

select cvid into @cvid from ld_customview where viewname = '确认出库' and entitytype = 'InventoryAccount';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:','e','确认出库',1,'' from dual where not exists (select * from ld_cvadvfilter 
where cvid = @cvid and columnname = 'LD_warehousecondtions:type:type:InventoryAccount_操作类型:');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid and groupid = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);

select cvid into @cvid from ld_customview where viewname = '确认调拨' and entitytype = 'InventoryAccount';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:','e','确认调拨',1,'' from dual where not exists (select * from ld_cvadvfilter 
where cvid = @cvid and columnname = 'LD_warehousecondtions:type:type:InventoryAccount_操作类型:');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid and groupid = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);

select cvid into @cvid from ld_customview where viewname = '确认盘点' and entitytype = 'InventoryAccount';
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:','e','确认盘点',1,'' from dual where not exists (select * from ld_cvadvfilter 
where cvid = @cvid and columnname = 'LD_warehousecondtions:type:type:InventoryAccount_操作类型:');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid and groupid = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);


select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set fieldlabel = '所属模块' where tabid = @tabid and columnname = 'modulename';

-- 及时库存查询 添加库存预警 分类模块
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence)
select (select max(cvid)+1 from ld_customview),'库存预警',0,0,'InventoryQuery',1,1,1 from dual where not exists (select * from ld_customview 
where viewname = '库存预警' and entitytype = 'InventoryQuery');
select cvid into @cvid from ld_customview where viewname = '库存预警' and entitytype = 'InventoryQuery';
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid and groupid = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_products:productname:productname:products_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_products:product_no:product_no:products_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productcode:productcode:products_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:unit_price:unit_price:products_参考价:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_warehouse2products:productqty:productqty:products_库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_products:qtyearly:qtyearly:products_预警数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_products:commissionrate:commissionrate:products_库存金额:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehouse2products:warehouseid:warehouseid:products_待入库数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehouse2products:productid:productid:products_待出库数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
delimiter;

-- add 2013-12-16 by can
call AddColumn('ld_usereport','pagewidthpercent','int',4,'100');
update ld_usereport set pagewidthpercent=180 where name='SalesOrderTrack';
update ld_usereport set pagewidthpercent=180 where name='CashBillSum_Paymentplan';
update ld_usereport set pagewidthpercent=180 where name='CashBillSum_SalesOrder';
update ld_usereport set pagewidthpercent=50 where name='Contractnumber';
update ld_usereport set pagewidthpercent=50 where name='Contractamount';
update ld_usereport set pagewidthpercent=100 where name='SalesSumSequence';
delimiter;

update ld_field_seq set id =(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_customview_seq set id=(select max(cvid) from ld_customview);
update ld_settings_field_seq set id=(select max(fieldid) from ld_settings_field);
update ld_modentity_num_seq set id=(select max(num_id) from ld_modentity_num);

-- add 2013-12-23 by qiu
update ld_field set uitype = 1101 where tabid = 4 and columnname = 'mobile';
delimiter;
update ld_field set uitype = 1102 where tabid = 4 and columnname = 'fax';
delimiter;
update ld_field set uitype = 1103 where tabid = 4 and columnname = 'qq';
delimiter;
update ld_field set uitype = 1101 where tabid = 6 and columnname = 'mobile';
delimiter;
update ld_field set uitype = 1102 where tabid = 6 and columnname = 'fax';
delimiter;
update ld_field set uitype = 1103 where tabid = 6 and columnname = 'qq';
delimiter;
update ld_languagepackage set tabid = 10,tablabel='Emails' where chinesename = '邮件管理';
delimiter;

-- add 2013-12-23 by can
select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';
delete from  ld_usereportbasic  where usereportid=@usereportid and columns like '%LD_salesorder:duedate:duedate:SalesOrder%';

-- add 2013-12-23 by karl
CALL AddColumn('ld_modentity_num','usedate','date',20,null);
delimiter;
CALL AddColumn('ld_modentity_num','datetype','varchar',20,null);
delimiter;
update ld_modentity_num set datetype='none';

-- add 2013-12-23 by andy
call AddColumn('ld_notes','approvestatus','int',1,null);
delimiter;
call AddColumn('ld_notes','approveby','int',1,null);
delimiter;

update ld_field_seq set id =(select max(fieldid) from ld_field);
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_notes' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select 8,@id+1,'approvestatus','ld_notes',1,53,'approvestatus','Approvestatus',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual 
where not exists (select 1 from ld_field where tablename='ld_notes' and fieldname='approvestatus');
delimiter;

update ld_field_seq set id =(select max(fieldid) from ld_field);
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_notes' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select 8,@id+1,'approveby','ld_notes',1,53,'approveby','Approveby',1,0,'',100,19,61,3,'V~O',3,'','BAS',1,'',0 from dual 
where not exists (select 1 from ld_field where tablename='ld_notes' and fieldname='approveby');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 0,'17','知识管理是否启用审批流程。1:否，0:是' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=17);
delimiter;


/* 销售机会名称、客户名称、销售阶段、预计成交日期、预计金额、可能性、最新联系日期、负责人、创建时间 */

/* 删除方案定制 无需求*/
delete from  ld_customview where viewname='方案制定'; 
/* 销售机会数据分类排序*/
update ld_customview set sequence=7 where viewname='本月创建' and entitytype='Potentials';
update ld_customview set sequence=8 where viewname='本周预计成交' and entitytype='Potentials';

/* 全部字段排序 cvid=10 */
select cvid into @cvid  from LD_customview where viewname='ALL' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='ALL' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;


/* 初期沟通字段排序 cvid=190 */
select cvid into @cvid  from LD_customview where viewname='初期沟通' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='初期沟通' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*商务谈判字段排序*/
select cvid into @cvid  from LD_customview where viewname='商务谈判' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='商务谈判' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*成功结案 字段排序*/
select cvid into @cvid  from LD_customview where viewname='成功结案' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='成功结案' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*失败结案 字段排序*/
select cvid into @cvid  from LD_customview where viewname='失败结案' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='失败结案' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/* 本周创建 字段排序*/
select cvid into @cvid  from LD_customview where viewname='本周创建' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本周创建' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*本月创建字段排序*/
select cvid into @cvid  from LD_customview where viewname='本月创建' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本月创建' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/* 本周预计成交字段排序*/
select cvid into @cvid  from LD_customview where viewname='本周预计成交' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本周预计成交' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*本月预计成交字段排序*/
select cvid into @cvid  from LD_customview where viewname='本月预计成交' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本月预计成交' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

-- add 2013-12-23 by chen
update ld_tab set ownedby = 0 where tablabel in ('OutboundOrder','Stock','Checks');
update ld_tab set ownedby = 1 where tablabel in ('Prdtnums','Navigation','InventoryLedger','InventoryAccount','InventoryQuery');
delimiter;

-- 盘点序时薄添加确认盘点人
select cvid into @cvid from ld_customview where viewname = 'All' and entitytype = 'Checks';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_checks:subsmownerid:subsmownerid:Checks_确认盘点人:' 
from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 5);
delimiter;

update ld_tab set printtab = 1 where `name` = 'Checks';
update ld_field set sequence = 1 where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder' and columnname = 'out_no');

-- 采购订单，多个入库状态
select cvid into @cvid from ld_customview where entitytype = 'PurchaseOrder' and viewname = 'All';
select columnindex into @columnindex  from ld_cvcolumnlist where cvid = @cvid 
and columnname = 'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' order by columnindex asc limit 0,1;
delete from ld_cvcolumnlist where columnname = 'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' and columnindex != @columnindex;


update ld_field set fieldname = 'assigned_user_id' where tabid = (select tabid from ld_tab where `name` = 'Stock') 
and columnname = 'smownerid';
update ld_field set fieldname = 'assigned_user_id' where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') 
and columnname = 'smownerid';
update ld_field set fieldname = 'assigned_user_id' where tabid = (select tabid from ld_tab where `name` = 'Checks') 
and columnname = 'smownerid';
delimiter;

call addcolumn('ld_outboundorder','subsmownerid','int','11',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,`handler`)
select (select max(linkid)+1 from ld_links),@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",'themes/images/pointer.gif',
0,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual where not exists (select * from ld_links 
where tabid = @tabid);

insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not exists (select * from ld_modtracker_tabs where tabid = @tabid);
delimiter;

--  及时库存查询产品名称 查看产品详细
select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
update ld_field set uitype = 159 where tabid = @tabid and columnname = 'productname';
delimiter;

-- 及时库存查询 待出库数量
select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
update ld_field set uitype = 162 where tabid = @tabid and columnname = 'productid';
delimiter;

-- 出入库保持时，描述默认为0
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_field set typeofdata = '' where tabid = @tabid and columnname = 'remark';
delimiter;

-- 2013-12-17
update ld_tab set ownedby = 0 where tablabel in ('OutboundOrder','Stock','Checks');
update ld_tab set ownedby = 1 where tablabel in ('Prdtnums','Navigation','InventoryLedger','InventoryAccount','InventoryQuery');
-- 盘点序时薄添加确认盘点人
select cvid into @cvid from ld_customview where viewname = 'All' and entitytype = 'Checks';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_checks:subsmownerid:subsmownerid:Checks_确认盘点人:' 
from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnindex = 5);

update ld_tab set printtab = 1 where `name` = 'Checks';
update ld_field set sequence = 1 where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder' and columnname = 'out_no');
-- 采购订单，多个入库状态
select cvid into @cvid from ld_customview where entitytype = 'PurchaseOrder' and viewname = 'All';
select columnindex into @columnindex  from ld_cvcolumnlist where cvid = @cvid 
and columnname = 'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' order by columnindex asc limit 0,1;
delete from ld_cvcolumnlist where columnname = 'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' and columnindex != @columnindex;

update ld_field set fieldname = 'assigned_user_id' where tabid = (select tabid from ld_tab where `name` = 'Stock') 
and columnname = 'smownerid';
update ld_field set fieldname = 'assigned_user_id' where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder') 
and columnname = 'smownerid';
update ld_field set fieldname = 'assigned_user_id' where tabid = (select tabid from ld_tab where `name` = 'Checks') 
and columnname = 'smownerid';


call addcolumn('ld_outboundorder','subsmownerid','int','11',0);

-- 2013-12-19
select tabid into @tabid from ld_tab where `name` = 'Checks';
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,`handler`)
select (select max(linkid)+1 from ld_links),@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",'themes/images/pointer.gif',
0,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual where not exists (select * from ld_links 
where tabid = @tabid);
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not exists (select * from ld_modtracker_tabs where tabid = @tabid);
--  及时库存查询产品名称 查看产品详细
select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
update ld_field set uitype = 159 where tabid = @tabid and columnname = 'productname';
-- 及时库存查询 待出库数量
select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
update ld_field set uitype = 162 where tabid = @tabid and columnname = 'productid';
-- 出入库保持时，描述默认为0
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_field set typeofdata = '' where tabid = @tabid and columnname = 'remark';

-- 2013-12-20 BUG
-- 盘点 新增 个人权限看不到仓库信息
select tabid into @tabid from ld_tab where `name` = 'Checks';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname='wareid';
insert into LD_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,1 from dual where not exists (select * from LD_def_org_field 
where tabid = @tabid and fieldid = @fieldid);
-- 出入库 详细界面 缺少修改日志按钮
select tabid into @tabid from ld_tab where `name` = 'Stock';
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,`handler`)
select (select max(linkid)+1 from ld_links),@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",'themes/images/pointer.gif',
0,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual where not exists (select * from ld_links 
where tabid = @tabid);
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not exists (select * from ld_modtracker_tabs where tabid = @tabid);

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,`handler`)
select (select max(linkid)+1 from ld_links),@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",'themes/images/pointer.gif',
0,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual where not exists (select * from ld_links 
where tabid = @tabid);
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not exists (select * from ld_modtracker_tabs where tabid = @tabid);
-- 盘点 系统管理员不能删除、编辑 全部分类外的其他分类
update ld_customview set `status` = 3 where viewname in ('盘点中','盘点结束') and entitytype = 'Checks';
-- 个人权限 新增盘点 产片无法添加
call getallprofile('Checks');
-- 序时薄 查询 采购订单
insert into ld_ws_fieldtype(uitype,fieldtype)
select 150,'text' from dual where not exists (select * from ld_ws_fieldtype where uitype = 150);
-- 出入库 序时薄 负责人
update ld_cvcolumnlist set columnname = 'LD_stock:smownerid:assigned_user_id:Stock_负责人:' where columnname = 'LD_stock:smownerid:smownerid:Stock_负责人:';

update ld_cvcolumnlist set columnname = 'LD_outboundorder:smownerid:assigned_user_id:OutboundOrder_负责人:' where columnname = 'LD_outboundorder:smownerid:smownerid:LD_outboundorder_负责人:';

update ld_cvcolumnlist set columnname = 'LD_checks:smownerid:assigned_user_id:Checks_负责人:V' where columnname = 'LD_checks:smownerid:smownerid:Checks_负责人:V';

select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set typeofdata = '' where tabid = @tabid and columnname = 'remark';


select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set fieldlabel = '操作后产品库存' where tabid = @tabid and columnname = 'lastqty';

update ld_field set presence=1 where tabid=13 and columnname='from_portal';
delimiter;

-- add 2013-12-24 by kara
drop procedure  if exists `DelColumn`;
delimiter ||
create procedure   DelColumn
(
-- tableschema varchar(50),
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
set @coladd=IFNULL(@colName,'-1');

IF @coladd = '-1'  or @coladd<>columnname THEN
	select 1;
else
	set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);
	
	prepare stalter from @altercolumn;
	execute stalter;
deallocate prepare stalter;
END IF;
deallocate prepare stmt;
end ||
delimiter;

CALL DelColumn('ld_modentity_num','usedate');
delimiter;

-- add 2013-12-24 by chen
-- 2013-12-23
select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set fieldlabel = '操作后产品库存' where tabid = @tabid and columnname = 'lastqty';
-- 采购订单 详细界面 添加入库状态
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'stockpresence','LD_purchaseorder',1,1,0,'stockpresence','入库状态',
(select sequence from ld_field where tabid = @tabid and columnname = 'smownerid'),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 

'LBL_PO_INFORMATION'),
2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'stockpresence'); 
-- 采购订单 序时薄添加入库状态列
select cvid into @cvid from ld_customview where entitytype = 'PurchaseOrder' and viewname = 'All';
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex + 1,'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V' 
from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnname = 'LD_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V'); 
-- 合同订单 详细界面 添加出库状态
select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'stockpresence','LD_salesorder',1,1,0,'stockpresence','出库状态',
(select sequence from ld_field where tabid = @tabid and columnname = 'smownerid'),(select blockid from ld_blocks where tabid = @tabid and blocklabel = 
'LBL_SO_INFORMATION'),2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'stockpresence');
-- 合同订单 序时薄添加出库状态列
select cvid into @cvid from ld_customview where entitytype = 'SalesOrder' and viewname = 'All';
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex + 1,'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V' 
from dual where not exists (select * from ld_cvcolumnlist where cvid = @cvid and columnname = 'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V');
-- 库存流水账  操作前入库数量
select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,sequence,block,displaytype,typeofdata)
select @tabid,'firstqty','LD_warehousecondtions',1,1,0,'firstqty','操作前库存数量',
6,(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_INVENTORYACCOUNT_INFO'),
2,'V~O' from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'firstqty'); 
-- 库存流水账 all
select cvid into @cvid from ld_customview where viewname = 'All' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 本月
select cvid into @cvid from ld_customview where viewname = '本月' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 上月
select cvid into @cvid from ld_customview where viewname = '上月' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 确认入库
select cvid into @cvid from ld_customview where viewname = '确认入库' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 确认出库
select cvid into @cvid from ld_customview where viewname = '确认出库' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 确认调拨
select cvid into @cvid from ld_customview where viewname = '确认调拨' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 确认盘点
select cvid into @cvid from ld_customview where viewname = '确认盘点' and entitytype = 'InventoryAccount';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_操作类型:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 0);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_warehousecondtions:warehouseid:warehouseid:InventoryAccount_仓库:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 1);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_products:productname:productname:InventoryAccount_产品名称:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 2);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_products:product_no:product_no:InventoryAccount_产品编号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 3);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_products:productcode:productcode:InventoryAccount_产品型号:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 4);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_warehousecondtions:firstqty:firstqty:InventoryAccount_操作前库存数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 5);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_warehousecondtions:inputqty:inputqty:InventoryAccount_入库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 6);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_warehousecondtions:outputqty:outputqty:InventoryAccount_出库数:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 7);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_warehousecondtions:lastqty:lastqty:InventoryAccount_操作后数量:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 8);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_warehousecondtions:operationtime:operationtime:InventoryAccount_操作时间12:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 9);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_warehousecondtions:modulename:modulename:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 10);
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'LD_warehousecondtions:entityid:entityid:InventoryAccount_所属模块:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnindex = 11);
-- 入库单 详细界面添加：创建人，创建时间，修改时间，确认入库人
select tabid into @tabid from ld_tab where `name` = 'Stock';
select max(sequence) into @sequence  from ld_field where tabid = @tabid;
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'smcreatorid','LD_crmentity',1,53,0,'smcreatorid','创建人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+1 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'createdtime','LD_crmentity',1,1,0,'createdtime','创建时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+2 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'modifiedtime','LD_crmentity',1,1,0,'modifiedtime','修改时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+3 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'subsmownerid','LD_stock',1,165,0,'subsmownerid','确认入库人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WARE_INFO'),
2,'V~O',@sequence+4 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'subsmownerid'); 
-- 出入单 详细界面添加:创建人，创建时间，修改时间，确认出库人
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select max(sequence) into @sequence  from ld_field where tabid = @tabid;
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'smcreatorid','LD_crmentity',1,53,0,'smcreatorid','创建人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+1 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'smcreatorid'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'createdtime','LD_crmentity',1,1,0,'createdtime','创建时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+2 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'createdtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'modifiedtime','LD_crmentity',1,1,0,'modifiedtime','修改时间',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO'),
2,'V~O',@sequence+3 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'modifiedtime'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,presence,fieldname,fieldlabel,block,displaytype,typeofdata,sequence)
select @tabid,'subsmownerid','ld_outboundorder',1,165,0,'subsmownerid','确认出库人',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 

'LBL_OUT_INFO'),
2,'V~O',@sequence+4 from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'subsmownerid');
-- 出库单 详细  负责人 无法显示
select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_field set typeofdata = '' where tabid = @tabid and columnname = 'subsmownerid';

-- add 2013-12-25 by chen
call fieldprofile('SalesOrder');
call fieldprofile('PurchaseOrder');
call fieldprofile('Stock');
call fieldprofile('OutboundOrder');
call fieldprofile('InventoryQuery');
call fieldprofile('InventoryAccount');
call fieldprofile('InventoryLedger');

select cvid into @cvid from ld_customview where viewname = '未入库' and entitytype = 'Stock';
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid);
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex + 1,'LD_stock:presence:presence:Stock_状态:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnname = 'LD_stock:presence:presence:Stock_状态:');

select cvid into @cvid from ld_customview where viewname = '已入库' and entitytype = 'Stock';
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid);
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex + 1,'LD_stock:presence:presence:Stock_状态:' from dual where not exists (select * from ld_cvcolumnlist 
where cvid = @cvid and columnname = 'LD_stock:presence:presence:Stock_状态:');

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_field set tablename = 'LD_outboundorder' where tabid = @tabid and columnname = 'subsmownerid';

select cvid into @cvid from ld_customview where viewname = '未出库' and entitytype = 'OutboundOrder';
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid);
select cvid into @cvid from ld_customview where viewname = '已出库' and entitytype = 'OutboundOrder';
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 from dual where not exists (select * from ld_cvadvfilter_grouping 
where cvid = @cvid);
delimiter;

/* 销售机会名称、客户名称、销售阶段、预计成交日期、预计金额、可能性、最新联系日期、负责人、创建时间 */

/* 删除方案定制 无需求*/
delete from  ld_customview where viewname='方案制定'; 
/* 销售机会数据分类排序*/
update ld_customview set sequence=7 where viewname='本月创建' and entitytype='Potentials';
update ld_customview set sequence=8 where viewname='本周预计成交' and entitytype='Potentials';

/* 全部字段排序 cvid=10 */
select cvid into @cvid  from LD_customview where viewname='ALL' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='ALL' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;


/* 初期沟通字段排序 cvid=190 */
select cvid into @cvid  from LD_customview where viewname='初期沟通' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='初期沟通' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*商务谈判字段排序*/
select cvid into @cvid  from LD_customview where viewname='商务谈判' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='商务谈判' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*成功结案 字段排序*/
select cvid into @cvid  from LD_customview where viewname='成功结案' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='成功结案' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*失败结案 字段排序*/
select cvid into @cvid  from LD_customview where viewname='失败结案' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='失败结案' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/* 本周创建 字段排序*/
select cvid into @cvid  from LD_customview where viewname='本周创建' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本周创建' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*本月创建字段排序*/
select cvid into @cvid  from LD_customview where viewname='本月创建' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本月创建' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/* 本周预计成交字段排序*/
select cvid into @cvid  from LD_customview where viewname='本周预计成交' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本周预计成交' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;

/*本月预计成交字段排序*/
select cvid into @cvid  from LD_customview where viewname='本月预计成交' and entitytype='Potentials';
update ld_cvcolumnlist set columnindex=10 where cvid=@cvid and columnname='LD_potential:nextstep:nextstep:Potentials_Next_Step:V';
update ld_cvcolumnlist set columnindex=7 where cvid=@cvid and columnname='LD_crmentity:smownerid:assigned_user_id:Potentials_Assigned_To:V';
update ld_cvcolumnlist set columnindex=8 where cvid=@cvid and columnname='LD_crmentity:createdtime:createdtime:Potentials_Created_Time:DT';

select cvid into @cvid  from LD_customview where viewname='本月预计成交' and entitytype='Potentials';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_potential:lastcontactdate:lastcontactdate:Potentials%');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 154,'text' from dual 
where not exists (select * from ld_ws_fieldtype where uitype = 154); 
delimiter;

select fieldid into @fieldid from ld_field where fieldname='related_to' and tabid = 61;
insert into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) 
select  @fieldid,'Reminds' ,'Project','0','null' from dual where not exists 
(select 1 from LD_fieldmodulerel where module='Reminds' and relmodule='Project');
delimiter;

update ld_systems_deploy set deploy_value=1 where deploy_type=17;
update ld_field set uitype=230 where tabid=8 and columnname='notecontent';
update lD_version set old_version='V3.1' ,current_version='V3.1' ,remark='V3.1-20131225';
delimiter;

call addcolumn('LD_potential','lastcontactdate','date','1',0);
call addcolumn('LD_potential','lastorderdate','date','1',0);
delimiter;

UPDATE ld_field set sequence = 23 where columnname= 'smcreatorid' and tabid=2;

select tabid into @tabid from LD_tab where name='Potentials';
delete from ld_field where columnname='lastorderdate' and tabid=@tabid;
delete from ld_field where columnname='lastcontactdate' and tabid=@tabid;
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_OPPORTUNITY_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='lastcontactdate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'lastcontactdate','LD_potential',1,70,'lastcontactdate','最新联系日期',1,0,'',100,21,@paymentplanid,2,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='lastcontactdate'  and tabid=@tabid ) ;
insert into LD_def_org_field (tabid,fieldid,visible,readonly) select @tabid,@maxfieldid+1,0,0 from dual where not exists (select 1 from LD_def_org_field where tabid=@tabid);

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+1  where  not exists (select columnname from  ld_field where columnname='lastorderdate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'lastorderdate','LD_potential',1,70,'lastorderdate','最新订单日期',1,0,'',100,22,@paymentplanid,2,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='lastorderdate'  and tabid=@tabid ) ;
insert into LD_def_org_field (tabid,fieldid,visible,readonly) select @tabid,@maxfieldid+1,0,0 from dual where not exists (select 1 from LD_def_org_field where tabid=@tabid);
delimiter;


delete from ld_usereportcolumns  where Usereportid in  
(select usereportid from ld_usereport where name='Contractamount' or name='Contractnumber') ;

select usereportid into @usereportid from ld_usereport where name='Contractnumber';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 
@usereportid,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N',3,1,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:ordernum:ordernum:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 
@usereportid,'LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V',6,1,'LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:smownerid:smownerid:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:groupbycount:groupbycount:SalesOrder_groupbycount:N',9,1,'LD_salesorder:groupbycount:groupbycount:SalesOrder_groupbycount:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:groupbycount:groupbycount:SalesOrder%');

delimiter;

select usereportid into @usereportid from ld_usereport where name='Contractamount';
INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select 
@usereportid,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N',3,1,'LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:ordernum:ordernum:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select  @usereportid,'LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V',6,1,'LD_salesorder:smownerid:smownerid:SalesOrder_smownerid:V' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:smownerid:smownerid:SalesOrder%');

INSERT INTO `ld_usereportcolumns` (usereportid,columns,sequence,columnshow,realcolumns)
 select @usereportid,'LD_salesorder:total:total:SalesOrder_total:N',9,1,'LD_salesorder:total:total:SalesOrder_total:N' from DUAL
 where not EXISTS (select 1 from ld_usereportcolumns where  usereportid=@usereportid and  columns like'%LD_salesorder:total:total:SalesOrder%');
delimiter;

update ld_systems_deploy set deploy_value=1 where deploy_type=17;
update ld_field set uitype=230 where tabid=8 and columnname='notecontent';

-- add 2013-12-26 by qiu
update ld_parenttabrel set tabid = 10 where tabid = 28; 
INSERT INTO ld_systems_deploy (deploy_value,deploy_type,description) 
select null,18,'合同订单交付日期前Ｎ天提醒负责人（为0表示当天提醒，为空表示不提醒'） 
FROM DUAL WHERE NOT EXISTS(select 1 from ld_systems_deploy where deploy_type =18);
delimiter;

delete from ld_languagepackage where tablabel = 'ServiceContracts';
delimiter;
select tabid into @tabid from ld_tab where name='ServiceContracts';
select tablabel into @tablabel from ld_tab where name='ServiceContracts';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'服务合同','服务合同' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,modifiedby,modifiedtime,customized,ownedby,
isentitytype,version,parent,printtab)
select @tabid+1,'Attachment',5,0,'Attachment',null,null,0,1,0,null,null,0 from dual where not EXISTS(select 1 from 
ld_tab where tablabel='Attachment');
delimiter;
select tabid into @tabid from ld_tab where name='Attachment';
select tablabel into @tablabel from ld_tab where name='Attachment';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'附件','附件' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

/*创建附件表ld_attachmentsforbills*/
CREATE TABLE IF NOT EXISTS `ld_attachmentsforbills` (
  `attachmentsid` int(11) NOT NULL auto_increment,
  `record` int(11) default NULL,
  `filename` varchar(100) default NULL,
  `isenabled` varchar(100) default NULL,
  `size` varchar(100) default NULL,
  `path` text,
  `description` text,
  `creator` int(11) default NULL,
  `createdtime` date default NULL,
  `modifiedtime` date default NULL,
  PRIMARY KEY  (`attachmentsid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0 ;


/*客户更多信息增加附件功能，并且排序在知识管理上面*/
select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,6,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=6);
delimiter;
update LD_relatedlists set sequence = 11 where name = 'get_attachments' and tabid = 6;
delimiter;


select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='Attachment';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_Attachment_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='filename'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'filename','ld_attachmentsforbills',1,1,'filename','FileName',1,0,'',100,1,@blockid,1,'V~O',0,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='filename'  and tablename='ld_attachmentsforbills' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'isenabled','ld_attachmentsforbills',1,15,'isenabled','IsEnabled',1,0,'',100,2,@blockid,1,'V~O',0,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='isenabled'  and tablename='ld_attachmentsforbills' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='size'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'size','ld_attachmentsforbills',1,1,'size','Size',1,0,'',100,3,@blockid,1,'V~O',0,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='size'  and tablename='ld_attachmentsforbills' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','ld_attachmentsforbills',1,19,'description','Description',1,0,'',100,4,@blockid,1,'V~O',0,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tablename='ld_attachmentsforbills' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','ld_attachmentsforbills',1,70,'createdtime','Created Time',1,0,'',100,5,@blockid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime' and tablename='ld_attachmentsforbills' and tabid=@tabid) ;
delimiter;
select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','ld_attachmentsforbills',1,70,'modifiedtime','Modified Time',1,0,'',100,6,@blockid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime' and tablename='ld_attachmentsforbills' and tabid=@tabid) ;
delimiter;
select tabid into @tabid from LD_tab where name='Attachment';
select blockid into @blockid from LD_blocks where tabid=@tabid and blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='creator'  and tablename='ld_attachmentsforbills' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'creator','ld_attachmentsforbills',1,52,'creator','Creator',1,2,'',100,7,@blockid,2,'V~O',1,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='creator' and tablename='ld_attachmentsforbills' and tabid=@tabid) ;
delimiter;


select tabid into @tabid from lD_tab where name='Attachment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Attachment') and columnname='filename';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,1,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='Attachment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Attachment') and columnname='size';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,2,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='Attachment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Attachment') and columnname='description';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,3,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='Attachment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Attachment') and columnname='createdtime';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,4,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;
select tabid into @tabid from lD_tab where name='Attachment';
select fieldid into @fieldid from lD_field where tabid in(select tabid from LD_tab where name='Attachment') and columnname='creator';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)  select @tabid,@fieldid,0,5,1,0 from dual where not exists(select 1 from ld_relatedlists_lable where tabid=@tabid and fieldid=@fieldid);
delimiter;


call getallprofile('attachment');
delimiter;
call addtabintoprofile('attachment',0);
delimiter;
call fieldintoprofile(0,'attachment');
delimiter;
call fieldprofile('attachment');
delimiter;


select tabid into @tabid from lD_tab where name='Attachment';
insert into LD_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)  
select @tabid,'Attachment','LD_attachmentsforbills','filename','attachmentsid','attachmentsid' from dual where not exists 
(select 1 from LD_entityname where tabid=@tabid);
delimiter;
insert into ld_ws_entity(name,handler_path,handler_class,ismodule)  
select 'Attachment','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual where not exists 
(select 1 from ld_ws_entity where name='Attachment');
delimiter;
select tabid into @tabid from lD_tab where name='Attachment';
insert into LD_Def_org_share(tabid,permission,editstatus)  
select @tabid,3,0 from dual where not exists 
(select 1 from LD_Def_org_share where tabid=@tabid);
delimiter;

/*联系人增加附件管理*/
select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,4,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=4);
delimiter;

/*联系记录增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='ContactRecords';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;
/*服务合同增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='ServiceContracts';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*收款单增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='CashBill';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*出库单增加附件管理 ，出库单附件有问题，提示admin没有权限*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='OutboundOrder';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*入库单增加附近管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Stock';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*盘点增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Checks';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*服务单增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='HelpDesk';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*销售机会增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Potentials';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*报价单增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Quotes';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*合同订单增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*市场活动增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Campaigns';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*供应商增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Vendors';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*采购订单增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*项目增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Project';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*项目任务增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='ProjectTask';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*项目里程碑增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='ProjectMilestone';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*费用报销增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Expense';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;

/*发票增加附件管理*/
update lD_RelatedLists_seq set id =(select max(relation_id) from lD_RelatedLists);
select id into @id from lD_RelatedLists_seq;
select tabid into @tabid from ld_tab where name='Invoice';
select tabid into @relatedtabid from ld_tab where name='Attachment';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_attachment');
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_attachment',10,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
delimiter;


-- add 2013-12-26 by chen
insert into ld_ws_fieldtype(uitype,fieldtype)
select 154,'text' from dual where not exists (select * from ld_ws_fieldtype 
where uitype = 154);
 
update ld_customview set `status` = 3 where entitytype = 'InventoryAccount' and viewname != 'All';
update ld_customview set `status` = 3 where entitytype = 'InventoryQuery' and viewname != 'All';
 
call addcolumn('ld_inventoryproductrel','paperquantity','int','11',0);

-- add 2013-12-27
select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';
delete from ld_usereportbasic where usereportid=@usereportid;
INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid, 'LD_crmentity:createdtime:createdtime:SalesOrder_createdtime:D', 'thisstartmonth~thisendmonth', '3' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_crmentity:createdtime:createdtime:SalesOrder%'and Usereportid=@usereportid);
delimiter;

delete from ld_languagepackage where  chinesename = '邮件管理';
delimiter;
select tabid into @tabid from ld_tab where name='Emails';
select tablabel into @tablabel from ld_tab where name='Emails';
insert into ld_languagepackage(tabid,tablabel,chinesename,newchinesename)
select @tabid,@tablabel,'邮件管理','邮件管理' from dual where not exists(select 1 from ld_languagepackage 
where tabid=@tabid and tablabel=@tablabel);
delimiter;

-- add 2013-12-31 by qiu
delete from ld_relatedlists_lable where tabid = 8 and fieldid = (select fieldid from ld_field where tabid = 8 and columnname = 'approvestatus');
delete from ld_relatedlists_lable where tabid = 8 and fieldid = (select fieldid from ld_field where tabid = 8 and columnname = 'approveby');
delimiter;

-- add 2013-12-31 by can
call fieldprofile('products');
call getallprofile('products');
delimiter;

-- add 2013-12-31 by andy
/*6581*/
alter  table ld_attachmentsforbills modify  createdtime datetime  default null;
alter  table ld_attachmentsforbills modify  modifiedtime datetime  default null;
/*6579*/
/*客户*/
select tabid into @tabid from ld_tab where name='Accounts';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*联系人*/
select tabid into @tabid from ld_tab where name='Contacts';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*服务合同*/
select tabid into @tabid from ld_tab where name='ServiceContracts';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*销售机会*/
select tabid into @tabid from ld_tab where name='Potentials';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';
 
/*报价单*/
select tabid into @tabid from ld_tab where name='Quotes';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*合同订单*/
select tabid into @tabid from ld_tab where name='SalesOrder';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*发票*/
select tabid into @tabid from ld_tab where name='Invoice';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*供应商*/
/*此模块无知识管理，默认排序即可*/

/*采购订单*/
select tabid into @tabid from ld_tab where name='PurchaseOrder';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*项目*/
select tabid into @tabid from ld_tab where name='Project';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

/*项目任务*/
select tabid into @tabid from ld_tab where name='ProjectTask';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';


/*服务单*/
select tabid into @tabid from ld_tab where name='HelpDesk';
select sequence into @sequence from LD_relatedlists where tabid=@tabid and `name`='get_attachments';
update ld_relatedlists set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
update ld_relatedlists set sequence=@sequence where tabid=@tabid and `name`='get_attachment';

update ld_field set defaultvalue='thistoday' where tabid=23 and columnname='invoicedate';

-- add 2014-01-02 by luyx
update ld_field set uitype=19 where tabid=(select tabid from ld_tab where name='Documents') and columnname='notecontent';
update ld_blocks_seq set id=(select max(blockid) from ld_blocks); 

update ld_field set tablename = 'LD_troubletickets' where columnname in ('approvestatus','approveby') and tabid = 13;
update LD_relatedlists_seq set id=(select max(id) from LD_relatedlists);
delimiter;

select fieldid into @fieldid from ld_field where tabid = 13 and columnname = 'approvestatus';
insert into LD_def_org_field(tabid,fieldid,visible,readonly) 
select 13,@fieldid,0,1 from dual where not exists 
(select 1 from LD_def_org_field where fieldid=@fieldid and tabid = 13);
select fieldid into @fieldid from ld_field where tabid = 13 and columnname = 'approveby';
insert into LD_def_org_field(tabid,fieldid,visible,readonly) 
select 13,@fieldid,0,1 from dual where not exists 
(select 1 from LD_def_org_field where fieldid=@fieldid and tabid = 13);

select fieldid into @fieldid from ld_field where tabid = 20 and columnname = 'approvestatus';
insert into LD_def_org_field(tabid,fieldid,visible,readonly) 
select 20,@fieldid,0,1 from dual where not exists 
(select 1 from LD_def_org_field where fieldid=@fieldid and tabid = 20);
select fieldid into @fieldid from ld_field where tabid = 20 and columnname = 'approveby';
insert into LD_def_org_field(tabid,fieldid,visible,readonly) 
select 20,@fieldid,0,1 from dual where not exists 
(select 1 from LD_def_org_field where fieldid=@fieldid and tabid = 20);
select fieldid into @fieldid from ld_field where tabid = 23 and columnname = 'approvestatus';
insert into LD_def_org_field(tabid,fieldid,visible,readonly) 
select 23,@fieldid,0,1 from dual where not exists 
(select 1 from LD_def_org_field where fieldid=@fieldid and tabid = 23);
select fieldid into @fieldid from ld_field where tabid = 23 and columnname = 'approveby';
insert into LD_def_org_field(tabid,fieldid,visible,readonly) 
select 23,@fieldid,0,1 from dual where not exists 
(select 1 from LD_def_org_field where fieldid=@fieldid and tabid = 23);
delimiter;


-- add 2014-01-03 by can
select usereportid into @usereportid from ld_usereport where name='SalesOrderTrack';

INSERT INTO `ld_usereportbasic` (usereportid,columns,defaultvalue,sequence)
select  @usereportid, 'LD_accountSalesOrder:accountname:account_id:SalesOrder_accountname:I', '', '6' from DUAL
where not EXISTS(select 1 from ld_usereportbasic  where columns like '%LD_accountSalesOrder:accountname:account_id:SalesOrder%' and Usereportid=@usereportid);
delimiter;

update ld_tab set presence=0 where name='Attachment';
select cvid into @cvid from ld_customview where viewname = '确认入库' and entitytype = 'InventoryAccount';  
update ld_customview set viewname = '入库' where cvid = @cvid;
update ld_cvadvfilter set `value` = '入库',comparator = 'c' where cvid = @cvid;
 
select cvid into @cvid from ld_customview where viewname = '确认出库' and entitytype = 'InventoryAccount';  
update ld_customview set viewname = '出库' where cvid = @cvid;
update ld_cvadvfilter set `value` = '出库',comparator = 'c' where cvid = @cvid;
 
select cvid into @cvid from ld_customview where viewname = '确认调拨' and entitytype = 'InventoryAccount';  
update ld_customview set viewname = '调拨' where cvid = @cvid;
update ld_cvadvfilter set `value` = '调拨',comparator = 'c' where cvid = @cvid;
 
select cvid into @cvid from ld_customview where viewname = '确认盘点' and entitytype = 'InventoryAccount';  
update ld_customview set viewname = '盘点' where cvid = @cvid;
update ld_cvadvfilter set `value` = '盘点',comparator = 'c' where cvid = @cvid;
 
call fieldprofile('Products');
delimiter

Alter table ld_inventoryproductrel MODIFY firmoffer decimal(25,3);
Alter table ld_inventoryproductrel MODIFY profitloss decimal(25,3);
Alter table ld_inventoryproductrel MODIFY paperquantity decimal(25,3);

-- add 2014-01-07 by luyx
delete from ld_profile2standardpermissions where tabid in(select tabid from ld_tab where name='oftenusereport');
delete from ld_profile2standardpermissions where tabid in(select tabid from ld_tab where name='Attachment');
delimiter


update ld_tab set tabsequence=81  where name='OftenUseReport';
update ld_tab set tabsequence=82  where name='Comprehensivereport';
update ld_tab set tabsequence=83  where name='Reports';
update ld_tab set tabsequence=84  where name='Dashboard';


update ld_tab set tabsequence=96 where name='Reminds';
update ld_tab set tabsequence=97 where name='FieldFormulas';
update ld_tab set tabsequence=98 where name='Attachment';
update ld_tab set tabsequence=99  where name='Cache';

CREATE TABLE if not EXISTS `ld_outboundordercf` (
  `out_id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`out_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE if not EXISTS `ld_checkscf` (
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE if not EXISTS `ld_stockcf` (
  `stock_id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`stock_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

update ld_cvadvfilter set `value` = '出库',comparator = 'c',columnname='LD_warehousecondtions:type:type:InventoryAccount_操作类型:' 
where cvid in (select cvid from ld_customview where viewname = '出库' and entitytype = 'InventoryAccount');

update ld_field set presence=0 where tabid=22 and columnname='sostatus' and presence=2;
delimiter;


select sequence into @seq from ld_field where tabid=2 and columnname='modifiedtime';
update ld_field set fieldlabel='最新更新时间' where tabid=2 and columnname='modifiedtime';
update ld_field set sequence=@seq+1 where tabid=2 and columnname='lastorderdate';
update ld_field set sequence=@seq+2 where tabid=2 and columnname='lastcontactdate';
update ld_field set sequence=@seq+3 where tabid=2 and columnname='smcreatorid';
update ld_field set sequence=@seq+4 where tabid=2 and columnname='createdtime';
delimiter;

select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;


select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='初期沟通';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;



select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='商务谈判';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;



select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='成功结案';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;


select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='失败结案';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;



select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='本周创建';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;



select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='本月创建';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;



select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='本周预计成交';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;



select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='本月预计成交';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_Potential_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=0);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_Account_Name:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=1);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:sales_stage:sales_stage:Potentials_Sales_Stage:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=2);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:closingdate:closingdate:Potentials_预计成交日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=3);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:amount:amount:Potentials_预计金额:N' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=4);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potentialscf:possibility:possibility:Potentials_可能性(%):V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=5);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:D' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=6);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Potentials_销售负责人:V' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=7);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:modifiedtime:modifiedtime:Potentials_最新更新时间:DT' from dual
where not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnindex=8);
delimiter;

update ld_field set fieldlabel='手机' where tabid=4 and columnname='mobile';
update ld_cvcolumnlist set columnname='LD_troubletickets:ticket_no:ticket_no:HelpDesk_Ticket_No:V' where cvid in (select cvid from ld_customview where entitytype='HelpDesk') and columnname='LD_crmentity:crmid::HelpDesk_Ticket_ID:I';
update ld_field set tablename='LD_troubletickets' where tabid=13 and columnname='salesorderid';
call addcolumn('ld_attachmentsforbills','newfile_name','varchar','100',NUll);
update ld_field set fieldlabel='英文名' where tabid=4 and columnname='firstname';
delimiter;

CREATE TABLE if not EXISTS`ld_templateprint2user` (
  `templateprintid` int(19) NOT NULL,
  `userid` int(19) NOT NULL,
  KEY `idx_templateprintid_templateprint2user` USING BTREE (`templateprintid`),
  KEY `dx_userid_templateprint2user` USING BTREE (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);

update ld_version set old_version='V3.1' ,current_version='V3.1' ,remark='V3.1-20140107';
delimiter;