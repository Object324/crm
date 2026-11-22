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
call addcolumn('ld_account','publicaccount','int','1',0);
call addcolumn('ld_account','protectdate','date','1',1);
call addcolumn('ld_account','allocatedate','date','1',1);

delimiter;
CREATE TABLE if not exists `ld_logpublicaccount` (
  `id` int(19) NOT NULL auto_increment,
  `username` varchar(50) default NULL,
  `operation` varchar(50) default NULL,
  `opdate` datetime default NULL,
  `accountid` int(19) default NULL,
  PRIMARY KEY  (`id`),
  KEY `logpublicaccount_accountid` (`accountid`)
) ENGINE=InnoDB AUTO_INCREMENT=15335 DEFAULT CHARSET=utf8;

delimiter;
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='allocatedate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 6,@maxfieldid+1,'allocatedate','LD_account',1,5,'allocatedate','allocatedate',1,0,'',100,41,9,2,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='allocatedate'  and tabid=6 ) ;
delimiter;

select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='protectdate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select 6,@maxfieldid+1,'protectdate','LD_account',1,5,'protectdate','protectdate',1,0,'',100,42,9,2,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='protectdate'  and tabid=6 ) ;
delimiter;

DROP PROCEDURE IF EXISTS del_idx;  
create procedure del_idx
(
IN p_tablename varchar(200), 
IN p_idxname VARCHAR(200)
-- in databasename varchar(100)
)  
begin  

DECLARE str VARCHAR(250);  
  set @str=concat(' drop index ',p_idxname,' on ',p_tablename);   
  select database() into @databasename;
  select count(*) into @cnt from information_schema.statistics where table_name=p_tablename and index_name=p_idxname  and table_schema=@databasename;  
  if @cnt >0 then   
    PREPARE stmt FROM @str;  
    EXECUTE stmt ;  
  end if;  
  
end ;  

call del_idx('LD_account','account_publicaccount');  
CREATE INDEX account_publicaccount ON LD_account (publicaccount);
delimiter;


CREATE TABLE if not exists `ld_paymentplanscf` (
  `paymentplanid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_cashbillscf` (
  `cashbillid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`cashbillid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

create table if not exists ld_account_set(
status int(1) null,
days int(11) null,
bills varchar(255) null,
count int(11) null,
adminaccount text null,
usersaccount text null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_account_set(status,days,bills,count,adminaccount,usersaccount)
select 0,10,'SalesOrder',20,null,null from dual where not exists(select 1 from ld_account_set);
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
select id into @id from ld_settings_field_seq;
update ld_settings_field_seq set id=@id+1 where not exists (select 1 from ld_settings_field where name='LBL_ACCOUNT_SET'
and blockid=@blockid);
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,@blockid,'LBL_ACCOUNT_SET','set-IcoTwoTabConfig.gif','LBL_ACCOUNT_SET_DESCRIPTION','index.php?module=Settings&action=AccountSet&parenttab=Settings',@sequence+1,0 from dual WHERE
not exists(select 1 from ld_settings_field where name='LBL_ACCOUNT_SET' and blockid=@blockid);
delimiter;

update ld_tab set presence=5 where `name`='MassVoices';
delimiter;
update LD_field  set sequence=1 where fieldid=306;
delimiter;
update LD_field  set sequence=2 where fieldid=307;
delimiter;
update LD_field  set sequence=3 where fieldid=308;
delimiter;
update LD_field  set sequence=4 where fieldid=309;
delimiter;
update LD_field  set sequence=5 where fieldid=310;
delimiter;
update LD_field  set sequence=6 where fieldid=311;
delimiter;
update LD_field  set sequence=7 where fieldid=312;
delimiter;
update ld_field  set typeofdata='DT~M~time_start',uitype=86 where tabid=61 and columnname='date_time';
delimiter;
update ld_field set typeofdata='V~O' where tabid=61 and columnname='related_to';
delimiter;

select cvid into @cvid from ld_customview where entitytype='PaymentPlan' and viewname='ALl';
select max(columnindex) into @columnindex from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:description:description:PaymentPlan_Description:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:description:description%');
delimiter;

select cvid into @cvid from ld_customview where entitytype='PaymentPlan' and viewname='未收';
select max(columnindex) into @columnindex from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:description:description:PaymentPlan_Description:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:description:description%');
delimiter;

select cvid into @cvid from ld_customview where entitytype='PaymentPlan' and viewname='已收';
select max(columnindex) into @columnindex from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:description:description:PaymentPlan_Description:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:description:description%');
delimiter;

select cvid into @cvid from ld_customview where entitytype='PaymentPlan' and viewname='部分已收';
select max(columnindex) into @columnindex from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:description:description:PaymentPlan_Description:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:description:description%');
delimiter;

select cvid into @cvid from ld_customview where entitytype='PaymentPlan' and viewname='本月应收';
select max(columnindex) into @columnindex from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:description:description:PaymentPlan_Description:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:description:description%');
delimiter;

select cvid into @cvid from ld_customview where entitytype='PaymentPlan' and viewname='本月已收';
select max(columnindex) into @columnindex from LD_cvcolumnlist where cvid=@cvid;
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_crmentity:description:description:PaymentPlan_Description:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:description:description%');
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='试用客户');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='试用客户');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='试用客户');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='试用客户');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='试用客户';
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='普通客户');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='普通客户');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='普通客户');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='普通客户');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='普通客户';
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='失败客户');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='失败客户');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='失败客户');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='失败客户');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='失败客户';
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='60天未更新');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='60天未更新');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='60天未更新');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='60天未更新');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='60天未更新';
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周创建');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周创建');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周创建');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周创建');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='本周创建';
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周需回访');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周需回访');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周需回访');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='本周需回访');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='本周需回访';
delimiter;

delete from ld_cvcolumnlist where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='7天未更新');
delimiter;
delete from ld_cvstdfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='7天未更新');
delimiter;
delete from ld_cvadvfilter where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='7天未更新');
delimiter;
delete from ld_cvadvfilter_grouping where cvid in(select cvid from ld_customview where entitytype='accounts' and viewname='7天未更新');
delimiter;
delete from ld_customview where entitytype='accounts' and viewname='7天未更新';
delimiter;

call addcolumn('ld_field','fieldonly','int','1',0);
delimiter;
delete from LD_fieldmodulerel where fieldid='733' and module='Reminds' and relmodule='SalesOrder';
delimiter;
insert into LD_fieldmodulerel(fieldid,module,relmodule) select  733,'Reminds' ,'SalesOrder'  from dual where not exists(select 1 from LD_fieldmodulerel where module='Reminds' and relmodule='Salesorder');
delimiter;

update LD_field set presence=1 where fieldid=199;
update LD_Field set fieldonly=1 where fieldid=1;
drop procedure if exists `fieldprofile`;
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
end;

call fieldprofile('Accounts');
delimiter;
update LD_tab set isentitytype=1 where name='HelpDesk';
delimiter;

delete from LD_field where fieldid=173;
select id into @maxid from LD_links_seq;
update LD_Links_seq set id=@maxid+1  where not exists(select 1 from LD_Links where tabid=13 and  linktype='DETAILVIEWWIDGET');
insert into LD_links(linkid,tabid,linktype,linklabel,linkurl,sequence) select @maxid+1,13,'DetailViewBlockCommentWidget','DetailViewBlockCommentWidget','block://ModComments:modules/ModComments/ModComments.php','themes/images/pointer.gif'
from dual where not exists(select 1 from LD_Links where tabid=13 and  linktype='DETAILVIEWWIDGET');
delimiter;

delete from ld_selectquery where queryid = 57;
delimiter;
INSERT INTO ld_selectquery(queryid,startindex,numofobjects)
VALUES(57,0,0);
delimiter;
delete from LD_report where reportid = 57;
delimiter;
INSERT INTO LD_report(reportid,folderid,reportname,description,reporttype,queryid,state,customizable,category,owner,sharingtype)
VALUES(57,11,'短信记录查询','短信记录查询','summary',57,'DDFAULT',57,1,26,'Public');
delimiter;
delete from LD_reportmodules where reportmodulesid = 57;
delimiter;
INSERT INTO LD_reportmodules(reportmodulesid,primarymodule,secondarymodules)
VALUES(57,'CommunicationLog','');
delimiter;
delete from LD_selectcolumn where queryid = 57;
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,0,'ld_smssend:taskid:Task_Id:taskid:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,1,'ld_smssend:receivecontacts:Receive_Contactsa:firstreceivecontacts:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,2,'ld_smssend:callednumber:Called_Number:callednumber:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,3,'ld_smssend:smscontent:Sms_Content:smscontent:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,4,'ld_smssend:smsbillingfee:Sms_Billingfee:smsbillingfee:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,5,'ld_smssend:smsresultname:Sms_Resultname:smsresultname:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,6,'ld_smssend:operator:Oper_Ator:operator:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,7,'ld_smssend:createtime:Create_Time:createtime:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,8,null);
delimiter;

select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='cashbill';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_cashbill' and tabid=22);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,22,@relatedtabid,'get_cashbill',5,'cashbill',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_cashbill' and tabid=22);
delimiter;

select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='paymentplan';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_paymentplan' and tabid=22);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,22,@relatedtabid,'get_paymentplan',6,'paymentplan',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_paymentplan' and tabid=22);
delimiter;

update LD_relatedlists set sequence=1 where tabid=6 and label='Contacts';
update LD_relatedlists set sequence=2 where tabid=6 and label='contact records';
update LD_relatedlists set sequence=3 where tabid=6 and label='Schedule Manager';
update LD_relatedlists set sequence=4 where tabid=6 and label='Sales Order';
update LD_relatedlists set sequence=5 where tabid=6 and label='paymentplan';
update LD_relatedlists set sequence=6 where tabid=6 and label='cashbill';
update LD_relatedlists set sequence=7 where tabid=6 and label='Quotes';
update LD_relatedlists set sequence=8 where tabid=6 and label='HelpDesk';
update LD_relatedlists set sequence=9 where tabid=6 and label='Invoice';
update LD_relatedlists set sequence=10 where tabid=6 and label='Products';
update LD_relatedlists set sequence=11 where tabid=6 and label='Documents';
update LD_relatedlists set sequence=12 where tabid=6 and label='Emails';
update LD_relatedlists set sequence=13 where tabid=6 and label='Potentials';
update LD_relatedlists set sequence=14 where tabid=6 and label='Campaigns';
update LD_relatedlists set sequence=15 where tabid=6 and label='Service Contracts';
update LD_relatedlists set sequence=16 where tabid=6 and label='Services';
update LD_relatedlists set sequence=17 where tabid=6 and label='Projects';
update LD_relatedlists set sequence=18 where tabid=6 and label='Assets';
delimiter;

update LD_relatedlists set sequence=1 where tabid=4 and label='contact records';
update LD_relatedlists set sequence=2 where tabid=4 and label='Schedule Manager';
update LD_relatedlists set sequence=3 where tabid=4 and label='Sales Order';
update LD_relatedlists set sequence=4 where tabid=4 and label='Quotes';
update LD_relatedlists set sequence=5 where tabid=4 and label='HelpDesk';
update LD_relatedlists set sequence=6 where tabid=4 and label='Invoice';
update LD_relatedlists set sequence=7 where tabid=4 and label='Products';
update LD_relatedlists set sequence=8 where tabid=4 and label='Documents';
update LD_relatedlists set sequence=9 where tabid=4 and label='Emails';
update LD_relatedlists set sequence=10 where tabid=4 and label='Potentials';
update LD_relatedlists set sequence=11 where tabid=4 and label='Campaigns';
update LD_relatedlists set sequence=12 where tabid=4 and label='Service Contracts';
update LD_relatedlists set sequence=13 where tabid=4 and label='Services';
update LD_relatedlists set sequence=14 where tabid=4 and label='Projects';
update LD_relatedlists set sequence=15 where tabid=4 and label='Purchase Order';
delimiter;

update LD_relatedlists set sequence=1 where tabid=2 and label='Contacts';
update LD_relatedlists set sequence=2 where tabid=2 and label='contact records';
update LD_relatedlists set sequence=3 where tabid=2 and label='Schedule Manager';
update LD_relatedlists set sequence=4 where tabid=2 and label='Sales Order';
update LD_relatedlists set sequence=5 where tabid=2 and label='Quotes';
update LD_relatedlists set sequence=6 where tabid=2 and label='Products';
update LD_relatedlists set sequence=7 where tabid=2 and label='Documents';
update LD_relatedlists set sequence=8 where tabid=2 and label='Services';
update LD_relatedlists set sequence=9 where tabid=2 and label='Sales Stage History';
delimiter;

update LD_relatedlists set sequence=1 where tabid=20 and label='Schedule Manager';
update LD_relatedlists set sequence=2 where tabid=20 and label='Sales Order';
update LD_relatedlists set sequence=3 where tabid=20 and label='Documents';
update LD_relatedlists set sequence=4 where tabid=20 and label='Quote Stage History';
delimiter;

update LD_relatedlists set sequence=1 where tabid=22 and label='Schedule Manager';
update LD_relatedlists set sequence=2 where tabid=22 and label='paymentplan';
update LD_relatedlists set sequence=3 where tabid=22 and label='cashbill';
update LD_relatedlists set sequence=4 where tabid=22 and label='Invoice';
update LD_relatedlists set sequence=5 where tabid=22 and label='Documents';
update LD_relatedlists set sequence=6 where tabid=22 and label='SalesOrder Status History';
delimiter;

update LD_relatedlists set sequence=1 where tabid=23 and label='Schedule Manager';
update LD_relatedlists set sequence=2 where tabid=23 and label='Documents';
update LD_relatedlists set sequence=3 where tabid=23 and label='Assets';
update LD_relatedlists set sequence=4 where tabid=23 and label='Invoice Status History';
delimiter;

update LD_relatedlists set sequence=1 where tabid=14 and label='Leads';
update LD_relatedlists set sequence=2 where tabid=14 and label='Accounts';
update LD_relatedlists set sequence=3 where tabid=14 and label='Contacts';
update LD_relatedlists set sequence=4 where tabid=14 and label='Sales Order';
update LD_relatedlists set sequence=5 where tabid=14 and label='Purchase Order';
update LD_relatedlists set sequence=6 where tabid=14 and label='Quotes';
update LD_relatedlists set sequence=7 where tabid=14 and label='HelpDesk';
update LD_relatedlists set sequence=8 where tabid=14 and label='Invoice';
update LD_relatedlists set sequence=9 where tabid=14 and label='PriceBooks';
update LD_relatedlists set sequence=10 where tabid=14 and label='Product Bundles';
update LD_relatedlists set sequence=11 where tabid=14 and label='Parent Product';
update LD_relatedlists set sequence=12 where tabid=14 and label='Documents';
update LD_relatedlists set sequence=13 where tabid=14 and label='Potentials';
update LD_relatedlists set sequence=14 where tabid=14 and label='Assets';
delimiter;

update LD_relatedlists set sequence=1 where tabid=26 and label='Leads';
update LD_relatedlists set sequence=2 where tabid=26 and label='Accounts';
update LD_relatedlists set sequence=3 where tabid=26 and label='Contacts';
update LD_relatedlists set sequence=4 where tabid=26 and label='Schedule Manager';
update LD_relatedlists set sequence=5 where tabid=26 and label='Potentials';
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='潜在客户' and entitytype='MassSMS');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'潜在客户',    0, 0, 'MassSMS',1,1,1 from dual where not exists(select 1 from LD_customview where viewname='潜在客户' and entitytype='MassSMS');
delimiter;
select cvid into @cvid   from LD_customview where viewname='潜在客户' and entitytype='MassSMS';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_account:rating:rating:Accounts_客户状态:V' ,'c','潜在客户',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_account:rating:rating:Accounts_客户状态%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;
select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='成交客户' and entitytype='MassSMS');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'成交客户',    0, 0, 'MassSMS',1,1,1 from dual where not exists(select 1 from LD_customview where viewname='成交客户' and entitytype='MassSMS');
delimiter;
select cvid into @cvid   from LD_customview where viewname='成交客户' and entitytype='MassSMS';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_account:rating:rating:Accounts_客户状态:V' ,'c','已成交客户',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_account:rating:rating:Accounts_客户状态%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);
delimiter;

select id into @maxid from LD_links_seq;
update LD_Links_seq set id=@maxid+1  where not exists(select 1 from LD_Links where tabid=13 and  linktype='DETAILVIEWWIDGET');
insert into LD_links(linkid,tabid,linktype,linklabel,linkurl,sequence) select @maxid+1,13,'DETAILVIEWWIDGET','DetailViewBlockCommentWidget','block://ModComments:modules/ModComments/ModComments.php','themes/images/pointer.gif'
from dual where not exists(select 1 from LD_Links where tabid=13 and  linktype='DETAILVIEWWIDGET');
delimiter;

select fieldid into @fieldid from ld_field where tabid=13 and fieldname='servicetype';
insert into ld_def_org_field (tabid,fieldid,visible,readonly)
select  13,@fieldid,0,0 from dual where not exists(select 1 from ld_def_org_field where tabid=13 and fieldid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid=13 and fieldname='hopetime';
insert into ld_def_org_field (tabid,fieldid,visible,readonly)
select  13,@fieldid,0,0 from dual where not exists(select 1 from ld_def_org_field where tabid=13 and fieldid=@fieldid);
delimiter;


select fieldid into @fieldid from ld_field where tabid=13 and fieldname='realtime';
insert into ld_def_org_field (tabid,fieldid,visible,readonly)
select  13,@fieldid,0,0 from dual where not exists(select 1 from ld_def_org_field where tabid=13 and fieldid=@fieldid);
delimiter;


select fieldid into @fieldid from ld_field where tabid=13 and fieldname='consumetime';
insert into ld_def_org_field (tabid,fieldid,visible,readonly)
select  13,@fieldid,0,0 from dual where not exists(select 1 from ld_def_org_field where tabid=13 and fieldid=@fieldid);
delimiter;

update ld_troubletickets set hopetime=(select createdtime from ld_crmentity where crmid=ticketid) where hopetime='0000-00-00 00:00:00';
update ld_troubletickets set realtime=(select createdtime from ld_crmentity where crmid=ticketid) where realtime='0000-00-00 00:00:00';
delimiter;

update  LD_report set state = 'SAVED' where reportid = 57;
delimiter;

drop procedure if exists `getallprofile`;
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
end;

drop procedure if exists `fieldintoprofile`;
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
end;

call getallprofile('Accounts');
call getallprofile('HelpDesk');
delimiter;

update LD_field  set tablename='LD_account' where columnname in('lastquotedate','lastorderdate','lastdistributedate','lastdistributer','lastcontactdate','lastcontent' ) and tabid=6;
delimiter;

update lD_version set old_version='V2.1' ,current_version='V2.1' ,remark='V2.1-20130809';
delimiter;

