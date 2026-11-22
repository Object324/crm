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

/*创建短信表*/
CREATE TABLE IF NOT EXISTS `ld_smssend`(
  `TaskID` int(11) NOT NULL auto_increment COMMENT '标识种子',
  `BatchNo` varchar(20) default '' COMMENT '批次号',
  `CalledNumber` varchar(20) default '' COMMENT '被叫号码',
  `SmsContent` varchar(500) default '' COMMENT '短信文本内容',
  `Priority` tinyint(4) default '0' COMMENT '是否优先',
  `SubmitTime` datetime default NULL COMMENT '期望发送时间',
  `AliveStartTime` datetime default NULL COMMENT '可呼叫起始时间',
  `AliveEndTime` datetime default NULL COMMENT '可呼叫中止时间',
  `CreateTime` datetime default NULL COMMENT '数据录入时间',
  `ServerJobNo` varchar(20) default '' COMMENT 'Sms 服务端作业号',
  `ServerTaskID` int(11) default '0' COMMENT 'CC 服务端任务ID',
  `SmsSegment` int(11) default '0' COMMENT '短信段数',
  `SmsResult` int(11) default '-1' COMMENT '短信发送结果',
  `SmsBillingFee` float default '0' COMMENT '短信费用',
  `Subject` varchar(100) default NULL COMMENT '主题',
  `operator` varchar(100) default NULL COMMENT '发送人',
  `ReceiveCompany` int(11) default '0' COMMENT '接收公司',
  `ReceiveContacts` int(11) default '0' COMMENT '接收联系人',
  `FDataStatu` int(1) NOT NULL default '0' COMMENT '状态,0-新插入（Default），1-已上传，2-已反馈',
  `FAccount` varchar(100) default NULL COMMENT '通讯账号',
  PRIMARY KEY  (`TaskID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE IF NOT EXISTS `ld_smssend_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
INSERT INTO ld_smssend_seq   select 0 from dual where not exists(select 1 from ld_smssend_seq);
delimiter;

select id into @id from ld_customview_seq;
update ld_customview_seq set id=@id+1 where not EXISTS(select 1 from ld_customview where entitytype='MassSMS' and viewname='All');
insert into ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, status, userid,sequence)
select @id+1,'All',1,0,'MassSMS',0,1,null from dual where not exists(select 1 from ld_customview where entitytype='MassSMS' and viewname='All');
delimiter;

update LD_cvColumnlist set columnname='LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' where columnname='LD_paymentplan:planpate:plandate:PaymentPlan_planpate:D';
delimiter;
 

CREATE TABLE  if not exists  `ld_cashbill`(
  `cashbillid` int(19) NOT NULL,
  `cashbill_no` varchar(100) NOT NULL,
  `accountid` int(19) default NULL,
  `salesorderid` int(19) default NULL,
  `cashbilldate` date default NULL,
  `paymentmethod` varchar(255) default NULL,
  `iscashbill` varchar(50) default NULL,
  `Total` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `NoPaymentplan` decimal(25,2) default NULL,
  PRIMARY KEY  (`cashbillid`),
  KEY `idx_cashbill_paymentmethod` (`paymentmethod`,`iscashbill`),
  KEY `idx_cashbill_accountid` (`accountid`),
  KEY `idx_cashbill_iscashbill` (`iscashbill`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE   if not exists `ld_cashbill_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
insert into `ld_cashbill_seq`(id)  select 1 from `ld_cashbill_seq` where not exists(select 1 from `ld_cashbill_seq`);
delimiter;

CREATE TABLE   if not exists `ld_cashbill2paymentplan` (
  `CashBillID` int(19) NOT NULL,
  `paymentplanid` int(19) NOT NULL,
  `amount` decimal(25,2) default NULL,
  `sequence` int(10) default NULL,
  `CashbillStatus` int(2) default NULL,
  PRIMARY KEY  (`CashBillID`,`paymentplanid`),
  KEY `Idx_cashbill2paymemtplan_cashbillid` (`CashBillID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
CREATE TABLE  if not exists `ld_iscashbill`(
  `Iscashbillid` int(19) NOT NULL auto_increment,
  `Iscashbill` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`Iscashbillid`),
  UNIQUE KEY `cashbill_paymentstatus_idx` (`Iscashbill`),
  KEY `cashbill_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE  if not exists `ld_iscashbill_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
insert into ld_iscashbill_seq (id) select 1 from dual where not exists(select 1 from ld_iscashbill_seq);
delimiter;
CREATE TABLE  if not exists  `ld_paymentmethod`(
  `paymentmethodid` int(19) NOT NULL auto_increment,
  `paymentmethod` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`paymentmethodid`),
  UNIQUE KEY `periodtime_periodtime_idx` (`paymentmethod`),
  KEY `paymentmethod_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE   if not exists `ld_paymentmethod_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
insert into ld_paymentmethod_seq (id) select 1 from dual where not exists(select 1 from ld_paymentmethod_seq);
delimiter;
CREATE TABLE  if  not exists `ld_paymentplan`  (
  `paymentplanid` int(11) NOT NULL,
  `paymentplan_no` varchar(100) default NULL,
  `accountid` int(19) default NULL,
  `salesorderid` int(19) default NULL,
  `Periodtime` varchar(50) default NULL,
  `plandate` date default NULL,
  `actualdate` date default NULL,
  `amount` decimal(25,2) default NULL,
  `actualamount` decimal(25,2) default NULL,
  `paymentstatus` varchar(255) default NULL,
  PRIMARY KEY  (`paymentplanid`),
  KEY `idx_ld_paymentstatus` (`paymentstatus`),
  KEY `idx_lD_plandate` (`plandate`),
 KEY `idx_lD_accountid` (`accountid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
CREATE TABLE  if not exists `ld_paymentplan_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

delimiter;
insert into `ld_paymentplan_seq` (id) select 1 from dual where not exists(select 1 from `ld_paymentplan_seq`);
delimiter;

CREATE TABLE  if not exists `ld_paymentstatus`  (
  `paymentstatusid` int(19) NOT NULL auto_increment,
  `paymentstatus` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`paymentstatusid`),
  UNIQUE KEY `paymentstatus_paymentstatus_idx` (`paymentstatus`),
  KEY `paymentstatus_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE  if not exists `ld_paymentstatus_seq`  (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into `ld_paymentstatus_seq`  (id) select 1 from dual where not exists(select 1 from `ld_paymentstatus_seq` );
delimiter;
CREATE TABLE  if not exists `ld_periodtime` (
  `Periodtimeid` int(19) NOT NULL auto_increment,
  `Periodtime` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`Periodtimeid`),
  UNIQUE KEY `Periodtime_Periodtime_idx` (`Periodtime`),
  KEY `Periodtime_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE   if not exists `ld_periodtime_seq`(
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
insert into `ld_periodtime_seq`  (id) select 1 from dual where not exists(select 1 from `ld_periodtime_seq` );
delimiter;
delete from LD_tab where tabid=0 ;
delimiter;
select max(tabid) into @maxid from  lD_tab  ;
select tabsequence into @tabseq from LD_tab where tabid=23;
insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent)
select @maxid+1 ,'PaymentPlan',0,@tabseq,'PaymentPlan',0,0,1,'5.0','Finacial'  from dual where not exists(select 1 from LD_tab where name='PaymentPlan');

insert into LD_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,version,parent)
select @maxid+2 ,'CashBill',0,@tabseq+1,'CashBill',0,0,1,'5.0','Finacial'  from dual where not exists(select 1 from LD_tab where name='CashBill');

update lD_tab set tabsequence=tabsequence+2  where @tabseq=18 and tabsequence>=18 and  name<>'CashBill' and name<>'PaymentPlan';

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

select tabid into @paytabid from lD_tab where name='PaymentPlan';
insert into LD_parenttabrel (parenttabid,tabid,sequence)
select @parentid ,@paytabid,1 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@paytabid);

select tabid into @billtabid from lD_tab where name='CashBill';
insert into LD_parenttabrel (parenttabid,tabid,sequence)
select @parentid ,@billtabid,2 from dual where not exists( select 1 from LD_parenttabrel  where tabid=@billtabid);

insert into LD_parenttabrel (parenttabid,tabid,sequence)
select @parentid ,23,3 from dual where not exists( select 1 from LD_parenttabrel  where tabid=23);
delimiter;


drop procedure  if exists `addtabintoprofile`;
create procedure addtabintoprofile
(
tabname varchar(50),
permissions int
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
end;
delimiter;
call addtabintoprofile('CashBill',1);
delimiter;
call addtabintoprofile('PaymentPlan',1);

select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='PaymentPlan';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_PaymentPlan_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION');
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'accountid','LD_paymentplan',1,73,'account_id','Account Name',1,2,'',100,1,@paymentplanid,1,'I~M',0,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_PaymentPlan'  ) ;
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='paymentpan_no'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'paymentplan_no','LD_paymentplan',1,4,'paymentplan_no','PaymentPlan No',1,0,'',100,2,@paymentplanid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='paymentplan_no'  and tablename='ld_PaymentPlan' ) ;
delimiter;



select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesorderid','LD_paymentplan',1,80,'salesorder_id','Sales Order',1,2,'',100,3,@paymentplanid,1,'I~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='ld_PaymentPlan' ) ;
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','Assigned To',1,0,'',100,4,@paymentplanid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='plandate'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'plandate','LD_paymentplan',1,5,'plandate','plandate',1,2,'',100,5,@paymentplanid,1,'D~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='plandate'  and tablename='ld_PaymentPlan' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='periodtime'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'periodtime','LD_paymentplan',1,15,'periodtime','periodtime',1,2,'1',100,6,@paymentplanid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='periodtime'  and tablename='ld_PaymentPlan' ) ;
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='amount'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'amount','LD_paymentplan',1,71,'amount','amount',1,2,'',100,7,@paymentplanid,1,'N~O',2,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='amount'  and tablename='ld_PaymentPlan' ) ;
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='paymentstatus'  and tablename='ld_PaymentPlan' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'paymentstatus','LD_paymentplan',1,15,'paymentstatus','paymentstatus',1,2,'未收',100,8,@paymentplanid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='paymentstatus'  and tablename='ld_PaymentPlan' ) ;
delimiter;
select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,9,@paymentplanid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,9,@paymentplanid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedby','LD_crmentity',1,52,'modifiedby','最新更新人',1,0,'',100,11,@paymentplanid,3,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedby'  and tabid=@tabid ) ;
delimiter;
select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,12,@paymentplanid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,10,@paymentplanid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','Description',1,2,'',100,1,@paymentplanid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;


CREATE TABLE if not exists `ld_periodtime` (
  `periodtimeid` int(19) NOT NULL auto_increment,
  `periodtime` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`periodtimeid`),
  UNIQUE KEY `periodtime_periodtime_idx` (`periodtime`),
  KEY `periodtime_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB   DEFAULT CHARSET=utf8;
CREATE TABLE  if not exists `ld_periodtime_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not exists `ld_paymentstatus` (
  `paymentstatusid` int(19) NOT NULL auto_increment,
  `paymentstatus` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`paymentstatusid`),
  UNIQUE KEY `paymentstatus_paymentstatus_idx` (`paymentstatus`),
  KEY `paymentstatus_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB   DEFAULT CHARSET=utf8;
CREATE TABLE  if not exists `ld_paymentstatus_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='periodtime');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'periodtime'  from dual where not exists(select 1 from LD_picklist where name='periodtime');
delimiter;
select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='paymentstatus');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'paymentstatus' from dual where not exists(select 1 from LD_picklist where name='paymentstatus');
delimiter;


insert into LD_paymentstatus_seq  (id) select 0 from dual where not exists(select 1 from LD_paymentstatus_seq);
delimiter;
insert into `ld_periodtime_seq`  (id) select 0 from dual where not exists(select 1 from `ld_periodtime_seq`);
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='1');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='1');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'1',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='1');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='2');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='2');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'2',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='2');
delimiter;
select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='3');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='3');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'3',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='3');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='4');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='4');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'4',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='4');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='5');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='5');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'5',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='5');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='6');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='6');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'6',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='6');
delimiter;
select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='7');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='7');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'7',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='7');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='8');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='8');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'8',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='8');
delimiter;


select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='9');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='9');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'9',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='9');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='10');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='10');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'10',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='10');
delimiter;
select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='11');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='11');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'11',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='11');
delimiter;

select  id into @seqmaxid from ld_periodtime_seq ;
update ld_periodtime_seq set id=@seqmaxid+2 where not exists(select 1 from ld_periodtime where periodtime='12');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_periodtime where periodtime='12');
INSERT INTO `ld_periodtime` (periodtimeid,periodtime,picklist_valueid) select  @seqmaxid+1,'12',@maxid+1 from dual where not exists(select 1 from LD_periodtime where periodtime='12');
delimiter;


select  id into @seqmaxid from ld_paymentstatus_seq ;
update ld_paymentstatus_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentstatus where paymentstatus='未收');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentstatus where paymentstatus='未收');
INSERT INTO `ld_paymentstatus` (paymentstatusid,paymentstatus,picklist_valueid,presence) select  @seqmaxid+1,'未收',@maxid+1,0 from dual where not exists(select 1 from LD_paymentstatus where paymentstatus='未收');
delimiter;

select  id into @seqmaxid from ld_paymentstatus_seq ;
update ld_paymentstatus_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentstatus where paymentstatus='部分已收');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentstatus where paymentstatus='部分已收');
INSERT INTO `ld_paymentstatus` (paymentstatusid,paymentstatus,picklist_valueid,presence) select  @seqmaxid+1,'部分已收',@maxid+1,0 from dual where not exists(select 1 from LD_paymentstatus where paymentstatus='部分已收');
delimiter;

select  id into @seqmaxid from ld_paymentstatus_seq ;
update ld_paymentstatus_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentstatus where paymentstatus='已收');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentstatus where paymentstatus='已收');
INSERT INTO `ld_paymentstatus` (paymentstatusid,paymentstatus,picklist_valueid,presence) select  @seqmaxid+1,'已收',@maxid+1,0 from dual where not exists(select 1 from LD_paymentstatus where paymentstatus='已收');
delimiter;





select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'PaymentPlan','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='PaymentPlan');
delimiter;
select max(id) into @maxid from LD_ws_entity ;
insert into LD_ws_entity(id,name,handler_path,handler_class,ismodule) select @maxid+1,'CashBill','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 from dual
where not exists(select 1 from lD_ws_entity where name='CashBill');
delimiter;

select  tabid into @tabid from LD_tab where name='paymentplan';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'PaymentPlan','LD_PaymentPlan','paymentplan_no','paymentplanid','paymentplan_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);
delimiter;

select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='PaymentPlan');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active)
select @maxid+1,'PaymentPlan','GP',1,1,1 from dual  where  not exists(select 1 from LD_modentity_num where  semodule='PaymentPlan');
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='paymentplan');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'PaymentPlan',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='paymentplan');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_PaymentPlan_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentplan_no:paymentplan_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:periodtime:periodtime%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_paymentplan:amount:amount:PaymentPlan_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:amount:amount%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:plandate:plandate%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
delimiter;
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:accountid:account_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:salesorderid:salesorder_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:PaymentPlan_Assigned_To:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='未收' and entitytype='paymentplan');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'未收',    1, 0, 'PaymentPlan',3,1,2 from dual where not exists(select 1 from LD_customview where viewname='未收' and entitytype='paymentplan');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_PaymentPlan_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentplan_no:paymentplan_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:periodtime:periodtime%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_paymentplan:amount:amount:PaymentPlan_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:amount:amount%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:plandate:plandate%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:accountid:account_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:salesorderid:salesorder_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PaymentPlan_Assigned_To:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='未收' and entitytype='paymentplan';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' ,'e','未收',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;




select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='已收' and entitytype='paymentplan');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'已收',    1, 0, 'PaymentPlan',3,1,3 from dual where not exists(select 1 from LD_customview where viewname='已收' and entitytype='paymentplan');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_PaymentPlan_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentplan_no:paymentplan_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:periodtime:periodtime%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_paymentplan:amount:amount:PaymentPlan_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:amount:amount%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:plandate:plandate%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:accountid:account_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:salesorderid:salesorder_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PaymentPlan_Assigned_To:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='已收' and entitytype='paymentplan';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' ,'e','未收',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='部分已收' and entitytype='paymentplan');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'部分已收',    1, 0, 'PaymentPlan',3,1,4 from dual where not exists(select 1 from LD_customview where viewname='部分已收' and entitytype='paymentplan');
delimiter;

select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_PaymentPlan_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentplan_no:paymentplan_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:periodtime:periodtime%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_paymentplan:amount:amount:PaymentPlan_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:amount:amount%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:plandate:plandate%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:accountid:account_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:salesorderid:salesorder_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PaymentPlan_Assigned_To:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='部分已收' and entitytype='paymentplan';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' ,'e','未收',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;


select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='本月应收' and entitytype='paymentplan');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'本月应收',    1, 0, 'PaymentPlan',3,1,5 from dual where not exists(select 1 from LD_customview where viewname='本月应收' and entitytype='paymentplan');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_PaymentPlan_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentplan_no:paymentplan_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:periodtime:periodtime%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_paymentplan:amount:amount:PaymentPlan_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:amount:amount%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:plandate:plandate%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:accountid:account_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:salesorderid:salesorder_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PaymentPlan_Assigned_To:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月应收' and entitytype='paymentplan';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) select @cvid,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' ,'thismonth','2013-05-01','2013-05-31' from dual
 where not exists( select 1 from ld_cvstdfilter  where cvid=@cvid and  columnname like '%LD_paymentplan:plandate:plandate%');

delimiter;



select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='本月已收' and entitytype='paymentplan');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'本月已收',    1, 0, 'PaymentPlan',3,1,6 from dual where not exists(select 1 from LD_customview where viewname='本月已收' and entitytype='paymentplan');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_PaymentPlan_No:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentplan_no:paymentplan_no%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_paymentplan:periodtime:periodtime:PaymentPlan_periodtime:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:periodtime:periodtime%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_paymentplan:amount:amount:PaymentPlan_amount:N' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:amount:amount%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:plandate:plandate%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';

insert into LD_cvcolumnlist (cvid,columnindex,columnname)

select @cvid,5,'LD_paymentplan:accountid:account_id:PaymentPlan_Account_Name:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:accountid:account_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:I' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_paymentplan:salesorderid:salesorder_id%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:PaymentPlan_Assigned_To:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V' ,'e','已收',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_paymentplan:paymentstatus:paymentstatus%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);


select cvid into @cvid   from LD_customview where viewname='本月已收' and entitytype='paymentplan';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) select @cvid,'LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' ,'thismonth','2013-05-01','2013-05-31' from dual
 where not exists( select 1 from ld_cvstdfilter  where cvid=@cvid and  columnname like '%LD_paymentplan:plandate:plandate%');

delimiter;


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
		set @sql=Concat('insert into LD_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from LD_def_org_field where tabid=' ,ttabid,' and fieldid=',ffieldid,')');
		
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end;

delimiter;
call fieldprofile('paymentplan');

delimiter;

select max(blockid) into @maxid  from LD_blocks;
select tabid into @tabid from LD_tab where name='Cashbill';
Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+1,@tabid,'LBL_Cashbill_INFORMATION',2,0,0,0,0,0,1,0 from dual where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION');

Insert into LD_Blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,Edit_view,Detail_view,display_status,iscustom)
select @maxid+2,@tabid,'LBL_DESCRIPTION_INFORMATION',2,0,0,0,0,0,1,0 from dual  where not exists(select 1 from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
delimiter;


select tabid into @tabid from LD_tab where name='Cashbill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_Cashbill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'accountid','LD_cashbill',1,73,'account_id','客户名称',1,2,'',100,1,@cashbillid,1,'I~M',0,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='accountid'  and tablename='ld_CashBill'  ) ;
delimiter;

select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='CashBill_no'  and tablename='ld_CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cashbill_no','LD_cashbill',1,4,'cashbill_no','收款单编号',1,0,'',100,2,@cashbillid,1,'V~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='CashBill_no'  and tablename='ld_CashBill' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='ld_CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'salesorderid','LD_cashbill',1,80,'salesorder_id','销售订单',1,2,'',100,3,@cashbillid,1,'I~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='salesorderid'  and tablename='ld_Cashbill' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='cashbill';
select blockid into @cashbill from LD_blocks where tabid=@tabid and blocklabel='LBL_cashbill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smownerid','LD_crmentity',1,53,'assigned_user_id','负责人',1,0,'',100,4,@cashbillid,1,'V~M',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smownerid'  and tablename='ld_crmentity' and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='CashBillDate'  and tablename='ld_CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'cashbilldate','LD_cashbill',1,5,'cashbilldate','收款日期',1,2,'',100,5,@cashbillid,1,'D~M',3,'','BAS',1,''  
from dual where not exists (select columnname from  ld_field where columnname='CashBillDate'  and tablename='ld_CashBill' ) ;
delimiter;


select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='PaymentMethod'  and tablename='CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'paymentmethod','LD_cashbill',1,15,'paymentmethod','付款方式',1,2,'',100,6,@cashbillid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='paymentmethod'  and tablename='ld_CashBill' ) ;
delimiter;


select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='Iscashbill'  and tablename='CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'iscashbill','LD_cashbill',1,15,'iscashbill','是否开票',1,2,'',100,7,@cashbillid,1,'V~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='Iscashbill'  and tablename='ld_CashBill' ) ;
delimiter;

select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'smcreatorid','LD_crmentity',1,52,'smcreatorid','创建人',1,0,'',100,8,@cashbillid,2,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='smcreatorid'  and tabid=@tabid ) ;
delimiter;

select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'createdtime','LD_crmentity',1,70,'createdtime','Created Time',1,0,'',100,9,@cashbillid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='createdtime'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'description','LD_crmentity',1,19,'description','备注',1,2,'',100,1,@cashbillid,1,'V~O',1,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='description'  and tabid=@tabid ) ;
delimiter;
select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='total'  and tablename='ld_CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'total','LD_cashbill',1,222,'hdnGrandTotal','Total',1,2,'',100,23,@cashbillid,1,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='total'  and tablename='ld_CashBill' ) ;
delimiter;


select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @cashbillid from LD_blocks where tabid=@tabid and blocklabel='LBL_CashBill_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='subtotal'  and tablename='ld_CashBill' );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'subtotal','LD_cashbill',1,222,'hdnSubTotall','Sub Total',1,2,'',100,25,@cashbillid,1,'N~O',3,'','BAS',1,''  
from dual where  not exists (select columnname from  ld_field where columnname='subtotal'  and tablename='ld_CashBill' ) ;
delimiter;


CREATE TABLE if not exists `ld_paymentmethod` (
  `paymentmethodid` int(19) NOT NULL auto_increment,
  `paymentmethod` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`paymentmethodid`),
  UNIQUE KEY `periodtime_periodtime_idx` (`paymentmethod`),
  KEY `paymentmethod_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB   DEFAULT CHARSET=utf8;

CREATE TABLE  if not exists `ld_paymentmethod_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not exists `ld_iscashbill` (
  `Iscashbillid` int(19) NOT NULL auto_increment,
  `Iscashbill` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`iscashbillid`),
  UNIQUE KEY `cashbill_paymentstatus_idx` (`iscashbill`),
  KEY `cashbill_picklist_valueid` (`picklist_valueid`)
) ENGINE=InnoDB   DEFAULT CHARSET=utf8;

CREATE TABLE  if not exists `ld_Iscashbill_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='paymentmethod');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'paymentmethod'  from dual where not exists(select 1 from LD_picklist where name='paymentmethod');
delimiter;

select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='iscashbill');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'iscashbill' from dual where not exists(select 1 from LD_picklist where name='iscashbill');
delimiter;

insert into ld_paymentmethod_seq  (id) select 0 from dual where not exists(select 1 from LD_paymentmethod_seq);
delimiter;
insert into `ld_iscashbill_seq`  (id) select 0 from dual where not exists(select 1 from `ld_iscashbill_seq`);
delimiter;

select  id into @seqmaxid from ld_paymentmethod_seq ;
update ld_paymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='现金');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='现金');
INSERT INTO `ld_paymentmethod` (paymentmethodid,paymentmethod,picklist_valueid) select  @seqmaxid+1,'现金',@maxid+1 from dual where not exists(select 1 from LD_paymentmethod where paymentmethod='现金');
delimiter;

select  id into @seqmaxid from ld_paymentmethod_seq ;
update ld_paymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='支票');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='支票');
INSERT INTO `ld_paymentmethod` (paymentmethodid,paymentmethod,picklist_valueid) select  @seqmaxid+1,'支票',@maxid+1 from dual where not exists(select 1 from LD_paymentmethod where paymentmethod='支票');
delimiter;


select  id into @seqmaxid from ld_paymentmethod_seq ;
update ld_paymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='电汇');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='电汇');
INSERT INTO `ld_paymentmethod` (paymentmethodid,paymentmethod,picklist_valueid) select  @seqmaxid+1,'电汇',@maxid+1 from dual where not exists(select 1 from LD_paymentmethod where paymentmethod='电汇');
delimiter;

select  id into @seqmaxid from ld_paymentmethod_seq ;
update ld_paymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='邮政汇款');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='邮政汇款');
INSERT INTO `ld_paymentmethod` (paymentmethodid,paymentmethod,picklist_valueid) select  @seqmaxid+1,'邮政汇款',@maxid+1 from dual where not exists(select 1 from LD_paymentmethod where paymentmethod='邮政汇款');
delimiter;

select  id into @seqmaxid from ld_paymentmethod_seq ;
update ld_paymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='网上银行');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='网上银行');
INSERT INTO `ld_paymentmethod` (paymentmethodid,paymentmethod,picklist_valueid) select  @seqmaxid+1,'网上银行',@maxid+1 from dual where not exists(select 1 from LD_paymentmethod where paymentmethod='网上银行');
delimiter;

select  id into @seqmaxid from ld_paymentmethod_seq ;
update ld_paymentmethod_seq set id=@seqmaxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='其他');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_paymentmethod where paymentmethod='其他');
INSERT INTO `ld_paymentmethod` (paymentmethodid,paymentmethod,picklist_valueid) select  @seqmaxid+1,'其他',@maxid+1 from dual where not exists(select 1 from LD_paymentmethod where paymentmethod='其他');
delimiter;


select  id into @seqmaxid from ld_iscashbill_seq ;
update ld_iscashbill_seq set id=@seqmaxid+2 where not exists(select 1 from ld_iscashbill where iscashbill='未开');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_iscashbill where iscashbill='未开');
INSERT INTO `ld_iscashbill` (iscashbillid,iscashbill,picklist_valueid) select  @seqmaxid+1,'未开',@maxid+1 from dual where not exists(select 1 from LD_iscashbill where iscashbill='未开');
delimiter;

select  id into @seqmaxid from ld_iscashbill_seq ;
update ld_iscashbill_seq set id=@seqmaxid+2 where not exists(select 1 from ld_iscashbill where iscashbill='已开');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_iscashbill where iscashbill='已开');
INSERT INTO `ld_iscashbill` (iscashbillid,iscashbill,picklist_valueid) select  @seqmaxid+1,'已开',@maxid+1 from dual where not exists(select 1 from LD_iscashbill where iscashbill='已开');
delimiter;






select  tabid into @tabid from LD_tab where name='CashBill';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select  @tabid,'CashBill','LD_cashbill','cashbill_no','cashbillid','cashbill_id' from dual
where not exists(select 1 from LD_entityname where tabid=@tabid);
delimiter;

select id into @maxid from LD_modentity_num_seq ;
update LD_modentity_num_seq set id=@maxid+1 where  not exists(select 1 from LD_modentity_num where  semodule='cashbill');
insert into LD_modentity_num (num_id,semodule,prefix,start_id,cur_id,active)
select @maxid+1,'CashBill','GR',1,1,1 from dual  where  not exists(select 1 from LD_modentity_num where  semodule='CashBill');
delimiter;

select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='All' and entitytype='CashBill');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'All',    1, 0, 'CashBill',0,1,1 from dual where not exists(select 1 from LD_customview where viewname='All' and entitytype='CashBill');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbill_no:cashbill_no%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashbill:total:hdnGrandTotal:CashBill_Total:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:total:hdnGrandTota%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbilldate:cashbilldate%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashbill:iscashbill:iscashbill:CashBill_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:iscashbill:iscashbill%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashbill:paymentmethod:paymentmethod:CashBill_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:paymentmethod:paymentmethod%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashbill:accountid:account_id:CashBill_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:accountid:account_id%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:salesorderid:salesorder_id%');
delimiter;




select cvid into @cvid   from LD_customview where viewname='All' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBill_负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;






select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='本月收款' and entitytype='cashbill');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'本月收款',    1, 0, 'CashBill',3,1,2 from dual where not exists(select 1 from LD_customview where viewname='本月收款' and entitytype='cashbill');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbill_no:cashbill_no%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashbill:total:hdnGrandTotal:CashBill_Total:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:total:hdnGrandTota%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbilldate:cashbilldate%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashbill:iscashbill:iscashbill:CashBill_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:iscashbill:iscashbill%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashbill:paymentmethod:paymentmethod:CashBill_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:paymentmethod:paymentmethod%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashbill:accountid:account_id:CashBill_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:accountid:account_id%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:salesorderid:salesorder_id%');
delimiter;




select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBill_负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='本月收款' and entitytype='cashbill';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) select @cvid,'LD_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D' ,'thismonth','2013-05-01','2013-05-31' from dual
 where not exists( select 1 from ld_cvstdfilter  where cvid=@cvid and  columnname like '%LD_cashbill:cashbilldate:cashbilldate%');

delimiter;




select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='现金收款' and entitytype='cashbill');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'现金收款',    1, 0, 'CashBill',3,1,2 from dual where not exists(select 1 from LD_customview where viewname='现金收款' and entitytype='cashbill');
delimiter;

select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbill_no:cashbill_no%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashbill:total:hdnGrandTotal:CashBill_Total:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:total:hdnGrandTota%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbilldate:cashbilldate%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashbill:iscashbill:iscashbill:CashBill_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:iscashbill:iscashbill%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashbill:paymentmethod:paymentmethod:CashBill_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:paymentmethod:paymentmethod%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashbill:accountid:account_id:CashBill_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:accountid:account_id%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:salesorderid:salesorder_id%');
delimiter;




select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBill_负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='现金收款' and entitytype='CashBill';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_cashbill:paymentmethod:paymentmethod:CashBill_paymentmethod:V' ,'e','现金',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_cashbill:paymentmethod:paymentmethod%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);





select id  into @maxid from LD_customview_seq;
update LD_customview_seq set id=@maxid+2   where not exists(select 1 from LD_customview where viewname='无需发票' and entitytype='cashbill');
insert into LD_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select  @maxid+1,'无需发票',    1, 0, 'CashBill',3,1,2 from dual where not exists(select 1 from LD_customview where viewname='无需发票' and entitytype='cashbill');
delimiter;

select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,0,'LD_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbill_no:cashbill_no%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,1,'LD_cashbill:total:hdnGrandTotal:CashBill_Total:N' 

 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:total:hdnGrandTota%');
delimiter;
select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,2,'LD_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:cashbilldate:cashbilldate%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,3,'LD_cashbill:iscashbill:iscashbill:CashBill_是否开票:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:iscashbill:iscashbill%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,4,'LD_cashbill:paymentmethod:paymentmethod:CashBill_付款方式:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:paymentmethod:paymentmethod%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,5,'LD_cashbill:accountid:account_id:CashBill_客户名称:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:accountid:account_id%');
delimiter;


select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,6,'LD_cashbill:salesorderid:salesorder_id:CashBill_销售订单:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_cashbill:salesorderid:salesorder_id%');
delimiter;




select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvcolumnlist (cvid,columnindex,columnname)
select @cvid,7,'LD_crmentity:smownerid:assigned_user_id:CashBill_负责人:V' 
 from dual where  not exists(select 1 from LD_cvcolumnlist where cvid=@cvid and columnname like '%LD_crmentity:smownerid:assigned_user_id%');
delimiter;

select cvid into @cvid   from LD_customview where viewname='无需发票' and entitytype='cashbill';
insert into LD_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) select @cvid,0,'LD_cashbill:iscashbill:iscashbill:CashBill_是否开票:V' ,'e','无需发票',1,'' from dual
 where not exists( select 1 from LD_cvadvfilter where cvid=@cvid and  columnname like '%LD_cashbill:iscashbill:iscashbill%');
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid, '','' from dual where not exists(select 1 from ld_cvadvfilter_grouping where groupid=1 and cvid=@cvid);

delimiter;



select tabid into @tabid from LD_tab where name='PaymentPlan' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);
insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select tabid into @tabid from LD_tab where name='CashBill' ;
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);


select max(ruleid) into @ruleid from LD_def_org_share;
select tabid into @tabid from LD_tab  where name='PaymentPlan';
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

delimiter;
select max(ruleid) into @ruleid from LD_def_org_share;
select tabid into @tabid from LD_tab where name='CashBill';
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
delimiter;

select id into @id from ld_customview_seq;
update ld_customview_seq set id=@id+1 where not EXISTS(select 1 from ld_customview where entitytype='MassSMS' and viewname='All');
insert into ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, status, userid,sequence)
select @id+1,'All',1,0,'MassSMS',0,1,null from dual where not exists(select 1 from ld_customview where entitytype='MassSMS' and viewname='All');
delimiter;

create table if not exists ld_smstemplates
(
templateid int(19) not null,
templatename varchar(100) null,
body text null,
PRIMARY KEY(templateid)
)engine=innodb default charset=utf8;
delimiter;
create table if not exists ld_smstemplates_seq
(
id int (11) not null
)engine=innodb default charset=utf8;
delimiter;
insert into ld_smstemplates_seq(id)
select 1 from dual where not exists (select 1 from ld_smstemplates_seq where id>0);
delimiter;
select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
select sequence into @sequence FROM ld_settings_field where blockid=@blockid and name='LBL_MAIL_SERVER_SETTINGS';
update ld_settings_field set sequence=sequence+1 where blockid=@blockid and sequence>=@sequence;
select id into @id from ld_settings_field_seq;
update ld_settings_field_seq set id=id+1 where not exists (select 1 from ld_settings_field where name='LBL_SMS_SETTINGS');
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,5,'LBL_SMS_SETTINGS','proxy.gif','LBL_SMS_DESCRIPTION','index.php?module=Settings&action=SMSSetting&parenttab=Settings',@sequence,0
from dual where not EXISTS(select 1 from ld_settings_field where blockid=@blockid and name='LBL_SMS_SETTINGS');
delimiter;
select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
update ld_settings_field set iconpath='code.gif' where name='LBL_SECURITYCODE_SET' and blockid=@blockid;
delimiter;

update ld_tab set presence = 5 where name = 'CommunicationLog';
delimiter;

alter table ld_smssend MODIFY SmsBillingFee decimal(18,2);
delimiter;

update LD_field set uitype=77 where tablename = 'LD_account' and columnname = 'lastdistributer' ;
delimiter;

call fieldprofile('CashBill');
delimiter;
call AddColumn('ld_cashbill','invoiceid','int',19);
delimiter;
drop procedure if exists UpdateInvoiceIntoCashBill;
create procedure UpdateInvoiceIntoCashBill
(

)
begin
declare done  int  default 0;
declare iinvoiceid int ;
declare iaccountid int ;
declare isalesorderid int;
declare iinvoicedate date;
declare ismownerid int ;
declare itotal int;
declare isubtotal int ;
declare ismcreatorid int ;
declare cur1 CURSOR FOR SELECT  LD_invoice.invoiceid,LD_invoice.accountid ,LD_invoice.salesorderid,LD_invoice.invoicedate,LD_invoice.total,ld_invoice.subtotal,
 LD_crmentity.smownerid ,LD_crmentity.smcreatorid  FROM  LD_Invoice inner join LD_crmentity on LD_crmentity.crmid=LD_Invoice.invoiceid
 where LD_crmentity.deleted=0 and LD_invoice.invoicestatus='已付款' and exists(select 1 from LD_version where current_version ='v2.0' or current_version='v2.01');
declare continue handler  for not   found  SET done =1;

select cur_id into @curid  from LD_modentity_num where semodule='CashBill';

select prefix into @prefix from LD_modentity_num where semodule='CashBill';

select id into @crmid from LD_crmentity_seq;

OPEN cur1;
Fetch cur1 into iinvoiceid,iaccountid,isalesorderid,iinvoicedate,itotal,isubtotal,ismownerid,ismcreatorid;
 loop1: while  done<>1 DO
 	set @curid=@curid+1;
	update LD_Crmentity_seq set id=@crmid+1 where not exists(select 1 from LD_CashBill where invoiceId=iinvoiceid);
	set @crmid=@crmid+1;
insert into LD_crmentity(crmid,smownerid,smcreatorid,modifiedby,setype,createdtime,viewedtime,modifiedtime)
select @crmid,ismownerid,ismcreatorid,ismownerid,'CashBill',now(),now(),now() from dual  where not exists(select 1 from LD_CashBill where invoiceId=iinvoiceid);
update LD_modentity_num set cur_id=@curid where not exists(select 1 from LD_CashBill where invoiceId=iinvoiceid);

 	insert into LD_CashBill(cashbillid,accountid,salesorderid,cashbill_no,cashbilldate,paymentmethod,iscashbill,total ,nopaymentplan)
  	select @crmid,iaccountid,isalesorderid, concat(@prefix,@curid),iinvoicedate,'现金','已开',itotal,isubtotal from dual where not exists(select 1 from LD_CashBill where invoiceId=iinvoiceid); 
	
	Fetch cur1 into iinvoiceid,iaccountid,isalesorderid,iinvoicedate,itotal,isubtotal,ismownerid,ismcreatorid;
end while loop1;
close cur1;


end;
delimiter;

call UpdateInvoiceIntoCashBill;
delimiter;

update LD_cvadvfilter set value='已收' where  cvid in(select cvid  from LD_customview where entitytype='paymentplan' and viewname='已收') and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%';
delimiter;
update LD_cvadvfilter set value='已收' where  cvid in(select cvid  from LD_customview where entitytype='paymentplan' and viewname='本月已收') and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%';
 
delimiter;
update LD_cvadvfilter set value='部分已收' where  cvid in(select cvid  from LD_customview where entitytype='paymentplan' and viewname='部分已收') and columnname like '%LD_paymentplan:paymentstatus:paymentstatus%';
 
delimiter;

alter table ld_smssend MODIFY ReceiveContacts varchar(20);
delimiter;

update ld_tab set presence = 0 where name = 'CommunicationLog';
delimiter;

update lD_relatedlists set sequence=sequence+2 where tabid=6 and sequence>=11;
select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='PaymentPlan';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_paymentplan' and tabid=6);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,6,@relatedtabid,'get_paymentplan',11,'paymentplan',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_paymentplan' and tabid=6);
delimiter;
select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='CashBill';
update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_cashbill' and tabid=6);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,6,@relatedtabid,'get_cashbill',12,'cashbill',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_cashbill' and tabid=6);
delimiter;


select id into @id from lD_RelatedLists_seq;
select tabid into @relatedtabid from ld_tab where name='CashBill';
select tabid into @tabid from LD_tab where name='paymentplan';

update lD_RelatedLists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_cashbill'and tabid=@tabid);
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @id+1,@tabid,@relatedtabid,'get_cashbill',1,'cashbill',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_cashbill' and tabid=@tabid);
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='actualdate'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'actualdate','LD_paymentplan',1,70,'acutaldate','actualdate',1,0,'',100,9,@paymentplanid,2,'D~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='actualdate'  and tabid=@tabid ) ;
delimiter;


select tabid into @tabid from LD_tab where name='PaymentPlan';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='actualamount'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'actualamount','LD_paymentplan',1,70,'actualamount','actualamount',1,0,'',100,10,@paymentplanid,2,'N~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='actualamount'  and tabid=@tabid ) ;
delimiter;

select tabid into @tabid from LD_tab where name='PaymentPlan';
update LD_field set sequence=sequence+2 where tabid=@tabid and columnname in('modifiedtime','createdtime','modifiedby');


call fieldprofile('PaymentPlan');

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
VALUES(57,0,'ld_smssend:taskid:CommunicationLog_Task_Id:taskid:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,1,'ld_smssend:receivecontacts:CommunicationLog_Receive_Contacts:firstreceivecontacts:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,2,'ld_smssend:callednumber:CommunicationLog_Called_Number:callednumber:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,3,'ld_smssend:smscontent:CommunicationLog_Sms_Content:smscontent:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,4,'ld_smssend:smsbillingfee:CommunicationLog_Sms_Billingfee:smsbillingfee:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,5,'ld_smssend:smsresultname:CommunicationLog_Sms_Resultname:smsresultname:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,6,'ld_smssend:operator:CommunicationLog_Oper_Ator:operator:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,7,'ld_smssend:createtime:CommunicationLog_Create_Time:createtime:V');
delimiter;
INSERT INTO LD_selectcolumn(queryid,columnindex,columnname)
VALUES(57,8,null);
delimiter;

alter table ld_communicationaccount MODIFY balance decimal(18,2);
delimiter;

update LD_field set displaytype=3 where columnname in('total','subtotal') and tablename='ld_cashbill';
delimiter;
 

update LD_cvColumnlist set columnname='LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D' where columnname='LD_paymentplan:plandate:plandate:PaymentPlan_plandate:D';
delimiter;
 
select tabid into @tabid from LD_tab where name='CashBill';
select blockid into @paymentplanid from LD_blocks where tabid=@tabid and blocklabel='LBL_CASHBILL_INFORMATION';
select max(fieldid) into @maxfieldid  from ld_field ;
update ld_field_seq set id=@maxfieldid+2  where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid );
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo)
select @tabid,@maxfieldid+1,'modifiedtime','LD_crmentity',1,70,'modifiedtime','修改时间',1,0,'',100,26,@paymentplanid,2,'DT~O',3,'','BAS',0,''  
from dual where  not exists (select columnname from  ld_field where columnname='modifiedtime'  and tabid=@tabid ) ;
delimiter;
select max(linkid) into @maxLinkid from LD_links;
update LD_links_seq set id=@maxLinkid +1;
select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='CashBill' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;
 
select id into @id from ld_links_seq;
select  tabid into @tabid from lD_Tab where name='PaymentPlan' ;
update LD_links_seq set id=@id+1 where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
insert into LD_Links (linkid,tabid,linktype,linklabel,linkurl,linkicon,sequence,handler_path,handler_class,handler)
select @id+1,@tabid,'DETAILVIEWBASIC','View History','javascript:ModTrackerCommon.showhistory(''$RECORD$'')','themes/images/pointer.gif',1,'modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted' from dual 
where not exists(select 1 from LD_links where tabid=@tabid and Linklabel='View History');
delimiter;

update ld_links set linkurl='index.php?module=Documents&action=EditView&return_module=Project&return_action=DetailView&return_id=$RECORD$&parent_id=$RECORD$&Create=yes' where linklabel='Add Note';
delimiter;

select tabid into @tabid from LD_tab where name='paymentplan';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
delimiter;
 
select tabid into @tabid from LD_tab where name='cashbill';
insert into LD_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not exists(select 1 from LD_modtracker_tabs where tabid=@tabid);
delimiter;
 
update LD_field set uitype=71 where tablename='ld_paymentplan' and columnname='actualamount';
update lD_users set first_name='' where first_name is null;
update  LD_report set state = 'SAVED' where reportid = 57;
update LD_customview set setdefault=0 where  entitytype='paymentplan';
update LD_customview set setdefault=1 where  entitytype='paymentplan' and viewname='all';
update LD_customview set setdefault=0 where  entitytype='cashbill';
update LD_customview set setdefault=1 where  entitytype='cashbill' and viewname='all';
delimiter;

update ld_version set old_version='V2.02',current_version='V2.02',remark='V2.02-20130710';
delimiter;