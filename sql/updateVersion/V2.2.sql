drop procedure  if exists `AddColumn`;
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

end;
delimiter;

update ld_report set sharingtype='Public' where reportname='SalesOrder Detailed Report';
update ld_tab set presence=1 where name='MassVoices';
delimiter;
select tabsequence into @tabsequence from ld_tab where name='EmailListtmp';
update ld_tab set tabsequence=@tabsequence where name='CommunicationLog';
delimiter;
update ld_field set defaultvalue=1 where  tabid=(select tabid from ld_tab where name='Products') and fieldname='discontinued';
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_STUDIO';
select id into @id from ld_settings_field_seq;
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
update ld_settings_field_seq set id=@id+1 where not exists (select 1 from ld_settings_field where blockid=@blockid and name='LBL_RELATED_PARAMETERS');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_RELATED_PARAMETERS','productfield.gif','LBL_RELATED_PARAMETERS_DESCRIPTION','index.php?module=Settings&action=ParametersSet&parenttab=Settings',@sequence+1,0 from dual 
where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LBL_RELATED_PARAMETERS');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_STUDIO';
select id into @id from ld_settings_field_seq;
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
update ld_settings_field_seq set id=@id+1 where not exists (select 1 from ld_settings_field where blockid=@blockid and name='LBL_SYSTEM_SET');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_SYSTEM_SET','migrate.gif','LBL_SYSTEM_SET_DESCRIPTION','index.php?module=Settings&action=SystemSet&parenttab=Settings',@sequence+1,0 from dual 
where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LBL_SYSTEM_SET');
delimiter;

create table if not exists`ld_productfieldlist` (

`id` INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, 

`fieldid` INT(11) NOT NULL ,

`fieldname` varchar (25) NOT NULL,

`fieldwidth` INT(11) DEFAULT 0 ,

`fieldorder` INT(11) DEFAULT 1

);
delimiter;

select fieldid,fieldname into @id,@fname from ld_field where  tabid=14 and fieldname = 'productname';
insert into ld_productfieldlist(fieldid,fieldname)
select @id,@fname from dual
where not exists(select 1 from ld_productfieldlist where fieldname=@fname);
delimiter;
 
 
CREATE TABLE if not exists `ld_systems_deploy` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `deploy_value` varchar(25) default '0' COMMENT '置配参数值',
  `deploy_type` tinyint(3) default '1' COMMENT '1:控制回款计划金额',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

INSERT INTO ld_systems_deploy (id,deploy_value,deploy_type)
select '1', '0', '1' from dual 
where not exists(select 1 from ld_systems_deploy where id=1);

INSERT INTO ld_systems_deploy (id,deploy_value,deploy_type)
select '2', '0', '2' from dual 
where not exists(select 1 from ld_systems_deploy where id=2);
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_STUDIO';
select id into @id from ld_settings_field_seq;
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
update ld_settings_field_seq set id=@id+1 where not exists (select 1 from ld_settings_field where blockid=@blockid and name='LBL_PRINT_TEMPLATE');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_PRINT_TEMPLATE','printtemplate.gif','LBL_PRINT_TEMPLATE_DESCRIPTION','index.php?module=Settings&action=TemplateprintList&parenttab=Settings',@sequence+1,0 from dual 
where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LBL_PRINT_TEMPLATE');
delimiter;

CREATE TABLE if not exists `ld_templateprint` (
  `templateprintid` int(19) NOT NULL auto_increment,
  `printfilename` varchar(20) default NULL,
  `tabid` int(19) default NULL,
  `isdefault` int(1) default NULL,
  `templateprintname` varchar(50) default NULL,
  `systemdefault` int(1) default '0',
  PRIMARY KEY  (`templateprintid`),
  KEY `templatePrint_tabid` (`tabid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
call addcolumn('ld_tab','printtab','int','2',0);
delimiter;

update lD_tab set printtab=1 where name in('helpdesk','quotes','invoice','paymentplan','salesorder','pricebooks');
delimiter;

update ld_settings_field set sequence=12 where name='LBL_PRINT_TEMPLATE' and blockid='3';
update ld_settings_field set sequence=13 where name='LBL_RELATED_PARAMETERS' and blockid='3';
update ld_settings_field set sequence=14 where name='LBL_SYSTEM_SET' and blockid='3';
delimiter;

alter table ld_templateprint modify column printfilename varchar(40);
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'SalesOrderDefault.html',@tabid,1,'合同预置模板',1 from dual
where not exists(select 1 from ld_templateprint where printfilename='SalesOrderDefault.html');
delimiter;

select tabid into @tabid from ld_tab where name='Quotes';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'QuotesDefault.html',@tabid,1,'报价单预置模板',1 from dual
where not exists(select 1 from ld_templateprint where printfilename='QuotesDefault.html');
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'InvoiceDefault.html',@tabid,1,'发票预置模板',1 from dual
where not exists(select 1 from ld_templateprint where printfilename='InvoiceDefault.html');
delimiter;

select tabid into @tabid from ld_tab where name='HelpDesk';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'HelpDeskDefault.html',@tabid,1,'服务单预置模板',1 from dual
where not exists(select 1 from ld_templateprint where printfilename='HelpDeskDefault.html');
delimiter;


select tabid into @tabid from ld_tab where name='PaymentPlan';
insert into ld_templateprint(printfilename,Tabid,isDefault,TemplatePrintName,SystemDefault)
select 'PaymentPlanDefault.html',@tabid,1,'回款计划预置模板',1 from dual
where not exists(select 1 from ld_templateprint where printfilename='PaymentPlanDefault.html');
delimiter;

select tabid into @tabid from ld_tab where name='PaymentPlan';
update ld_field set tablename='LD_paymentplan' where fieldname='account_id' and tabid=@tabid;
update ld_field set tablename='LD_paymentplan' where fieldname='paymentplan_no' and tabid=@tabid;
delimiter;

update LD_tab set isentitytype = 1 where name = 'Documents';
update LD_tab set printtab=0 where name='pricebooks';
delimiter;

select tabid into @tabid from ld_tab where name='HelpDesk';
update ld_field set tablename='LD_troubletickets' where tabid=@tabid and fieldname='servicetype';
update ld_field set tablename='LD_troubletickets' where tabid=@tabid and fieldname='hopetime';
update ld_field set tablename='LD_troubletickets' where tabid=@tabid and fieldname='realtime';
update ld_field set tablename='LD_troubletickets' where tabid=@tabid and fieldname='consumetime';
delimiter;

update ld_systems_deploy set deploy_value=1 where id=1;
delimiter;

select tabid into @tabid from ld_tab where name='Products';
select fieldid into @fieldid from ld_field where tabid=@tabid and fieldname='productsheet';
insert into ld_productfieldlist(fieldid,fieldname,fieldwidth,fieldorder)
select @fieldid,'productsheet',0,2 from dual
where not exists(select 1 from ld_productfieldlist where fieldname='productsheet' and fieldid=@fieldid);
delimiter;

update LD_salesorder set taxtype='单独' where taxtype='individual';
update LD_salesorder set taxtype='部门' where taxtype='group';
delimiter;

update LD_invoice set taxtype='单独' where taxtype='individual';
update LD_invoice set taxtype='部门' where taxtype='group';
delimiter;

update LD_quotes set taxtype='单独' where taxtype='individual';
update LD_quotes set taxtype='部门' where taxtype='group';
delimiter;

select max(tabid) into @maxid from LD_tab  ;
select tabsequence into @tabseq from LD_tab where tabid=25;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,modifiedby,modifiedtime,customized,ownedby,isentitytype,version,parent,printtab) 
select  @maxid+1 ,'Comprehensivereport' ,0,@tabseq,'Comprehensivereport','','',0,1,0,'','Analytics',0  from dual 
where not exists(select 1 from LD_tab where name='Comprehensivereport' and tablabel='Comprehensivereport');
delimiter;

select tabid into @tabid from ld_tab where name='Comprehensivereport';
insert into LD_parenttabrel(parenttabid,tabid,sequence)
select 5,@tabid,2 from dual 
where not exists(select 1 from LD_parenttabrel where parenttabid=5 and tabid=@tabid);
delimiter;

update ld_tab set  presence = 1 where name = 'Comprehensivereport';
delimiter;

update ld_parenttab set sequence=1 where parenttab_label='My Home Page';
update ld_parenttab set sequence=2 where parenttab_label='Marketing';
update ld_parenttab set sequence=3 where parenttab_label='Parent Accounts';
update ld_parenttab set sequence=4 where parenttab_label='Sales';
update ld_parenttab set sequence=5 where parenttab_label='Finacial';
update ld_parenttab set sequence=6 where parenttab_label='Parent Reports';
update ld_parenttab set sequence=7 where parenttab_label='Tools';
update ld_parenttab set sequence=8 where parenttab_label='Inventroy';
update ld_parenttab set sequence=9 where parenttab_label='Settings';
delimiter;

update LD_entityname set fieldname='user_name' where modulename='Users';
delimiter;

select cvid into @cvid from ld_customview where entitytype='Calendar' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_activity:activitytype:activitytype:Calendar_事件类型:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_activity:eventstatus:eventstatus:Calendar_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_activity:subject:subject:Calendar_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_activity:accountid:account_id:Calendar_Account_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_activity:contactid:contact_id:Calendar_Contact_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_activity:date_start:date_start:Calendar_Start_Date:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_activity:due_date:due_date:Calendar_End_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Calendar_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7); 
delimiter;

select cvid into @cvid from ld_customview where entitytype='Calendar' and viewname='计划中';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_activity:activitytype:activitytype:Calendar_事件类型:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_activity:eventstatus:eventstatus:Calendar_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_activity:subject:subject:Calendar_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_activity:accountid:account_id:Calendar_Account_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_activity:contactid:contact_id:Calendar_Contact_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_activity:date_start:date_start:Calendar_Start_Date:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_activity:due_date:due_date:Calendar_End_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Calendar_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7); 

delete from ld_cvadvfilter where cvid=@cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid)
select @cvid,0,'LD_activity:eventstatus:eventstatus:Calendar_Status:V','e','计划中',1 from dual
where not exists(select 1 from ld_cvadvfilter where cvid=@cvid and columnindex=0); 
delimiter;


select cvid into @cvid from ld_customview where entitytype='Calendar' and viewname='未执行';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_activity:activitytype:activitytype:Calendar_事件类型:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_activity:eventstatus:eventstatus:Calendar_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_activity:subject:subject:Calendar_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_activity:accountid:account_id:Calendar_Account_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_activity:contactid:contact_id:Calendar_Contact_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_activity:date_start:date_start:Calendar_Start_Date:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_activity:due_date:due_date:Calendar_End_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Calendar_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7); 

delete from ld_cvadvfilter where  cvid=@cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid)
select @cvid,0,'LD_activity:eventstatus:eventstatus:Calendar_Status:V','e','未执行',1 from dual
where not exists(select 1 from ld_cvadvfilter where cvid=@cvid and columnindex=0); 
delimiter;


select cvid into @cvid from ld_customview where entitytype='Calendar' and viewname='已执行';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_activity:activitytype:activitytype:Calendar_事件类型:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_activity:eventstatus:eventstatus:Calendar_Status:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_activity:subject:subject:Calendar_Subject:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_activity:accountid:account_id:Calendar_Account_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_activity:contactid:contact_id:Calendar_Contact_Name:I' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_activity:date_start:date_start:Calendar_Start_Date:DT' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_activity:due_date:due_date:Calendar_End_Date:D' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6); 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:Calendar_Assigned_To:V' from dual
where not exists(select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7); 

delete from ld_cvadvfilter where  cvid=@cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid)
select @cvid,0,'LD_activity:eventstatus:eventstatus:Calendar_Status:V','e','已执行',1 from dual
where not exists(select 1 from ld_cvadvfilter where cvid=@cvid and columnindex=0); 
delimiter;


select tabid into @tabid from ld_tab where name='Events';
update ld_field set fieldlabel='事件类型' where tabid=@tabid and fieldname='activitytype';
update ld_field set fieldlabel='Status' where tabid=@tabid and fieldname='eventstatus';
delimiter;

select parenttabid into @parenttabid from ld_parenttab where  parenttab_label='My Home Page';
update ld_parenttabrel set sequence=1 where parenttabid=@parenttabid and tabid=3;
update ld_parenttabrel set sequence=2 where parenttabid=@parenttabid and tabid=63;
update ld_parenttabrel set sequence=3 where parenttabid=@parenttabid and tabid=9;
update ld_parenttabrel set sequence=4 where parenttabid=@parenttabid and tabid=28;
update ld_parenttabrel set sequence=5 where parenttabid=@parenttabid and tabid=8;
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select sequence into @seq1 from ld_field where fieldname='account_id' and tabid=@tabid;
update ld_field set sequence=@seq1+1 where fieldname='contact_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select sequence into @seq1 from ld_field where fieldname='contact_id' and tabid=@tabid;
update ld_field set sequence=@seq1+1 where fieldname='potential_id' and tabid=@tabid;
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select sequence into @seq1 from ld_field where fieldname='potential_id' and tabid=@tabid;
update ld_field set sequence=@seq1+1 where fieldname='quote_id' and tabid=@tabid;
delimiter;

select max(blockid) into @blockid from ld_blocks;
update ld_blocks_seq set id=@blockid+1;
delimiter;

update LD_entityname set fieldname='first_name,last_name' where modulename='Users';
delimiter;

update lD_version set old_version='V2.2' ,current_version='V2.2' ,remark='V2.2-20130906';
delimiter;
