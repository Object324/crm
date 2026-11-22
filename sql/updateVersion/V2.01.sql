drop procedure  if exists `AddColumn`;
create procedure   AddColumn
(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50),
columntype varchar(50),
columnlen int(5)
)
begin

select database() into @tableschema;

set tablename=lower(tablename);

SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;
set @coladd=IFNULL(@colName,'-1');

IF @coladd = '-1'  or @coladd<>columnname THEN
 	if columntype='date'  or columntype='datetime' then 
		set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
	else 

		 set @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
	end if;
prepare stalter from @altercolumn;
execute stalter;

END IF;
end;
delimiter;

select max(fieldid) into @fieldid from ld_settings_field;
update ld_settings_field_seq set id=@fieldid;
delimiter;

insert into lD_Actionmapping (actionid,actionname,securitycheck)
select 11,'Create',0 from dual where not exists(select 1 from LD_Actionmapping where actionid=11) ;
delimiter;
alter table ld_potential modify column amount decimal(25,2);
delimiter;
alter table ld_quotes modify column subtotal decimal(25,2);
alter table ld_quotes modify column adjustment decimal(25,2);
alter table ld_quotes modify column total decimal(25,2);
alter table ld_quotes modify column discount_percent decimal(25,2);
alter table ld_quotes modify column discount_amount decimal(25,2);
alter table ld_quotes modify column s_h_amount decimal(25,2);
alter table ld_quotes modify column conversion_rate decimal(25,3); 
alter table ld_invoice modify column adjustment decimal(25,2);
alter table ld_invoice modify column subtotal decimal(25,2);
alter table ld_invoice modify column total decimal(25,2);
alter table ld_invoice modify column discount_percent decimal(25,2);   
alter table ld_invoice modify column discount_amount decimal(25,2);
alter table ld_invoice modify column s_h_amount decimal(25,2);
alter table ld_invoice modify column salescommission decimal(25,3);
alter table ld_invoice modify column exciseduty decimal(25,3);
alter table ld_invoice modify column conversion_rate decimal(25,3);
alter table ld_salesorder modify column adjustment decimal(25,2);
alter table ld_salesorder modify column total decimal(25,2);
alter table ld_salesorder modify column subtotal decimal(25,2);
alter table ld_salesorder modify column discount_percent decimal(25,2);
alter table ld_salesorder modify column discount_amount decimal(25,2);
alter table ld_salesorder modify column s_h_amount decimal(25,2);
alter table ld_salesorder modify column salescommission decimal(25,3);
alter table ld_salesorder modify column exciseduty decimal(25,3);
alter table ld_salesorder modify column conversion_rate decimal(25,3);
alter table ld_products modify column qty_per_unit decimal(25,3);
alter table ld_products modify column weight decimal(25,3);
alter table ld_products modify column commissionrate decimal(25,3);
alter table ld_products modify column qtyinstock decimal(25,3);
delimiter;

select max(tabid) into @maxtabid from LD_tab;
update LD_tab set tabsequence=tabsequence+1 where  name<>'ReportLog'  and tabsequence>5;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype)
select @maxtabid+1,'ReportLog',0,6,'ReportLog',0,0,0 from dual where not exists(select 1 from LD_tab where name='ReportLog');

create table if not exists LD_workremindset
(
dailyreminddate VARCHAR(100) null,
weekreminddate VARCHAR(100) NULL,
monthreminddate VARCHAR(100) null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into LD_workremindset(dailyreminddate,weekreminddate,monthreminddate) select '17:00','5','40'
from dual where not exists (select 1 from LD_workremindset);
delimiter;

select  max(id) into @maxfieldid from ld_settings_field_seq;
update ld_settings_field_seq set id=@maxfieldid +1  where  not exists(select 1 from ld_settings_field where name='LBL_REMIND_SET');

insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active) select  @maxfieldid +1,5,'LBL_REMIND_SET','remindset.gif','LBL_REMIND_SET_DESCRIPTION',
'index.php?module=Settings&action=WorkRemindSet&parenttab=Settings',17,0 from dual where not exists(select 1 from ld_settings_field where name='LBL_REMIND_SET');

delimiter;


create table if not EXISTS LD_dailyreport(
dailyid int(19) NOT NULL,
worksummary text NULL,
tomorrowplan text NULL,
dstatus int(1) NULL,
startdate date NULL,
submitdate datetime NULL,
smcreatorid int(19) NULL,
createdtime datetime NULL,
delaydays int(4) NULL,
dyear int(4) NULL,
dmonth int(4) NULL,
dday int(4) NULL,
dweek int(4) NULL,
PRIMARY KEY (dailyid)
)engine=innodb default charset=utf8;
delimiter;
create table if not EXISTS LD_dailyreport_seq(
id int(19) NULL
)engine=innodb  default charset=utf8;
delimiter;
insert into LD_dailyreport_seq(id) select 1 from dual where not exists(select 1 from LD_dailyreport_seq);
delimiter;


CREATE TABLE if not EXISTS `ld_reportcomments` (
  `reportcommentid` int(19) NOT NULL,
  `commentcontent` text,
  `commentdate` datetime default NULL,
  `commentatorid` int(19) default NULL,
  `reportid` int(19) default NULL,
  `type` int(1) default NULL,
  PRIMARY KEY  (`reportcommentid`),
  KEY `idx_reportcomments_type_reportid` (`type`,`reportid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
create table if not EXISTS LD_reportcomments_seq
(
id int(19)
)ENGINE=INNODB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_reportcomments_seq(id) select 1 from dual where not exists(select 1 from ld_reportcomments);

delimiter;
update ld_settings_field set iconpath='jk_ico.jpg' where fieldid=39 and blockid=5;
delimiter;
select fieldid into @fieldid from ld_settings_field where name='LBL_REMIND_SET';
update ld_settings_field set iconpath='Cron.png' where fieldid=@fieldid  and blockid=5;
delimiter;

create temporary table tem(
templateid int(19),
stuffsequence int(19)
);
delimiter;
insert into tem
select T2.templateid,max(T2.stuffsequence)+1  as stuffsequence from ld_templates as T1
left join ld_templatesstuff as T2
on T1.templateid=T2.templateid
where not EXISTS(select 1 from ld_templatesstuff where stuffId=24)
GROUP BY T2.templateid;
delimiter;
create temporary table temother(
stuffId int(19),
Stufftype varchar(100),
stufftitle varchar(100)
);
delimiter;
insert into temother
VALUES('24','Default','日/周/月报');
delimiter;
create temporary table temp(
stuffId int(19),
templateid int(19),
Stufftype varchar(100),
stuffsequence int(19),
stufftitle varchar(100)
);
delimiter;
insert into temp
select stuffId,templateid,Stufftype,stuffsequence,stufftitle from temother,tem;
delimiter;
insert INTO ld_templatesstuff
select * from temp;
delimiter;
drop table if exists `tem`;
drop table if exists `temother`;
drop table if exists `temp`;
delimiter;

CREATE TABLE if not EXISTS `ld_weekreport` (
  `weekreportid` int(19) NOT NULL,
  `WorkSummary` text,
  `Nextweekplan` text,
  `status` int(4) default NULL,
  `Startdate` date default NULL,
  `Enddate` date default NULL,
  `createdtime` datetime default NULL,
  `smcreatorid` int(19) default NULL,
  `yearbol` int(4) default NULL,
  `Monthofyear` int(4) default NULL,
  `Weeksofyear` int(4) default NULL,
  `weekofmonth` int(4) default NULL,
  `Submitdate` datetime default NULL,
  `Delaydays` int(4) default NULL,
  PRIMARY KEY  (`weekreportid`),
  KEY `idx_WeekReport_yearbol_Monthofyear` USING BTREE (`yearbol`,`Monthofyear`,`Weeksofyear`,`smcreatorid`),
  KEY `idx_weekReport_date_userid` (`Startdate`,`Enddate`,`smcreatorid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_weekreport_seq` (
  `id` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_weekreport_seq(id) select 1 from dual where not exists(select 1 from ld_weekreport_seq);
delimiter;
CREATE TABLE if not EXISTS `ld_monthreport` (
  `MonthReportID` int(19) NOT NULL,
  `WorkSummary` text,
  `Nextmonthplan` text,
  `Startdate` date default NULL,
  `Enddate` date default NULL,
  `createdtime` datetime default NULL,
  `smcreatorid` int(19) default NULL,
  `yearbol` int(4) default NULL,
  `monthofyear` int(4) default NULL,
  `Submitdate` datetime default NULL,
  `delaydays` int(4) default NULL,
  `Status` int(2) default NULL,
  PRIMARY KEY  (`MonthReportID`),
  KEY `idx_MonthReport_year_month` USING BTREE (`yearbol`,`monthofyear`,`smcreatorid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE if not EXISTS `ld_monthreport_seq` (
  `id` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_monthreport_seq(id) select 1 from dual where not exists(select 1 from ld_monthreport_seq);
delimiter;

 
 
select sequence into @sequence from LD_parenttab where parenttab_label='sales';
select max(parenttabid) into @maxid from LD_parenttab;
insert into LD_parenttab (parenttabid,parenttab_label,sequence,visible)
select @maxid+1,'Finacial',@sequence+1,0 from dual where not exists(select 1 from LD_Parenttab where parenttab_label='finacial');
select sequence into @seq from LD_parenttab where parenttab_label='Parent Reports';
update LD_parenttab set sequence=sequence+1 where sequence>=@seq and parenttab_label <>'Finacial' and @seq=6;
 
delimiter;
select parenttabid into @parentid from LD_parenttab where parenttab_label='Finacial';
delete from LD_parenttabrel  where tabid=23 and parenttabid=4 ; 
 
 
insert into LD_parenttabrel (parenttabid,tabid,sequence)
select @parentid ,23,3 from dual where not exists( select 1 from LD_parenttabrel  where tabid=23);
delimiter;


update ld_tab set presence = 5 where name = 'CommunicationLog';
delimiter;

call addcolumn('ld_version','remark','varchar','50');
delimiter;

select max(fieldid) into @fieldid from ld_settings_field;
update ld_settings_field_seq set id=@fieldid;
delimiter;
select  max(id) into @maxfieldid from ld_settings_field_seq;
update ld_settings_field_seq set id=@maxfieldid +1  where  not exists(select 1 from ld_settings_field where name='LBL_SECURITYCODE_SET');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active) select  @maxfieldid +1,5,'LBL_SECURITYCODE_SET','remindset.gif','LBL_SECURITYCODE_SET_DESCRIPTION',
'index.php?module=Settings&action=DefSecutityCode&parenttab=Settings',18,0 from dual where not exists(select 1 from ld_settings_field where name='LBL_SECURITYCODE_SET');
delimiter;
CREATE TABLE if not exists `ld_code` (
  `status` int(4) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_code(status)
select 1 from dual where not exists(select 1 from ld_code);
delimiter;

select max(fieldid) into @fieldid from ld_settings_field;
update ld_settings_field_seq set id=@fieldid;
delimiter;
select  max(id) into @maxfieldid from ld_settings_field_seq;
update ld_settings_field_seq set id=@maxfieldid +1  where  not exists(select 1 from ld_settings_field where name='LBL_SECURITYCODE_SET');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active) select  @maxfieldid +1,5,'LBL_SECURITYCODE_SET','remindset.gif','LBL_SECURITYCODE_SET_DESCRIPTION',
'index.php?module=Settings&action=DefSecutityCode&parenttab=Settings',18,0 from dual where not exists(select 1 from ld_settings_field where name='LBL_SECURITYCODE_SET');
delimiter;
CREATE TABLE if not exists `ld_code` (
  `status` int(4) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into ld_code(status)
select 1 from dual where not exists(select 1 from ld_code);

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,modifiedby,
modifiedtime,customized,ownedby,isentitytype,version,parent)
select @tabid+1,'ReportLog',0,6,'ReportLog',null,null,0,0,0,null,null from dual where not EXISTS(select 1 from ld_tab where name='ReportLog');
delimiter;

select parenttabid into @parentid from LD_parenttab where parenttab_label='My Home Page';
select  tabid into @tabid  from ld_tab where name='Home';
select sequence into @homesequence from LD_parenttabrel where tabid=@tabid;
select sequence into @calendarsequence from LD_parenttabrel where tabid=9;
select tabid into @ReportLogid from lD_tab where name='ReportLog';
update ld_parenttabrel set sequence=sequence+1 
where parenttabid=1 and  sequence>=@calendarsequence   and sequence<7;
insert into LD_parenttabrel (parenttabid,tabid,sequence)
select @parentid ,@ReportLogid,@homesequence+1 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@ReportLogid);
delimiter;
select tabid into @tabid from ld_tab where name='ReportLog';
update ld_tab set isentitytype=1 where tabid=@tabid;
delimiter;
select tabid into @tabid from lD_tab where name='ReportLog';
select max( ruleid) into @maxid  from LD_def_org_share ;
insert into ld_def_org_share (ruleid,tabid,permission,editstatus) select @maxid+1,@tabid,3,0 from dual where not exists(select 1 from LD_def_org_share where tabid=@tabid);
delimiter;
 
insert into LD_org_share_action2tab(share_action_id,tabid)
select 0,@tabid from dual where not EXISTS(select 1 from LD_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into LD_org_share_action2tab(share_action_id,tabid)
select 1,@tabid from dual where not EXISTS(select 1 from LD_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into LD_org_share_action2tab(share_action_id,tabid)
select 2,@tabid from dual where not EXISTS(select 1 from LD_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into LD_org_share_action2tab(share_action_id,tabid)
select 3,@tabid from dual where not EXISTS(select 1 from LD_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;
update ld_version set old_version='V2.01',current_version='V2.01',remark='V2.01-20130614';
delimiter;
