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

drop procedure  if exists `addtabintoprofile`;
delimiter ||
create procedure addtabintoprofile
(
tabname varchar(50),
permissions int(19)

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

call fieldprofile('Commission');
call getallprofile('Commission');
call addtabintoprofile('Commission',0);

select usereportid into @id from LD_usereport where name='SalesSumSequence';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='SalesSumSequence';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_users:last_name:last_name:OftenUseReport_last_name:V', 1, 1, 'LD_users:last_name:last_name:OftenUseReport_姓名:V','LD_users:last_name:last_name:OftenUseReport_last name:V' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_users:last_name:last_name:OftenUseReport_姓名:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:accountcount:accountcount:OftenUseReport_accountcount:N', 2, 1, 'LD_account:accountcount:accountcount:OftenUseReport_新建客户数:N','LD_account:accountcount:accountcount:OftenUseReport_Number of new customers:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_account:accountcount:accountcount:OftenUseReport_新建客户数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:contactcount:contactcount:OftenUseReport_contactcount:N', 3, 1, 'LD_contactdetails:contactcount:contactcount:OftenUseReport_新建联系人数:N','LD_contactdetails:contactcount:contactcount:OftenUseReport_New contact number:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactdetails:contactcount:contactcount:OftenUseReport_新建联系人数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potentials:potentialcount:potentialcount:OftenUseReport_potentialcount:N', 4, 1, 'LD_potentials:potentialcount:potentialcount:OftenUseReport_新建机会数:N','LD_potentials:potentialcount:potentialcount:OftenUseReport_Number of new opportunities:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potentials:potentialcount:potentialcount:OftenUseReport_Number of new opportunities:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_activies:calendarcount:calendarcount:OftenUseReport_calendarcount:N', 5, 1, 'LD_activies:calendarcount:calendarcount:OftenUseReport_新建日程数:N','LD_activies:calendarcount:calendarcount:OftenUseReport_New schedule:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_activies:calendarcount:calendarcount:OftenUseReport_新建日程数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_contactrecordscount:N', 6, 1, 'LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_新建联系记录数:N','LD_activies:calendarcount:calendarcount:OftenUseReport_new contact record:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_新建联系记录数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_helpdeskcount:N', 7, 1, 'LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_新建服务单数:N','LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_help desk count:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_新建服务单数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_cashbilltotal:N', 8, 1, 'LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_回款额:N','LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_cashbill total:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_回款额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_cashbill:cashbillcount:cashbillcount:OftenUseReport_cashbillcount:N', 9, 1, 'LD_cashbill:cashbillcount:cashbillcount:OftenUseReport_回款笔数:N','LD_cashbill:cashbillcount:cashbillcount:OftenUseReport_Number of payment:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_cashbill:cashbillcount:cashbillcount:OftenUseReport_回款笔数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:OftenUseReport_salesordertotal:N', 10, 1, 'LD_salesorder:salesordertotal:salesordertotal:OftenUseReport_合同额:N','LD_salesorder:salesordertotal:salesordertotal:OftenUseReport_salesorder total:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesordertotal:salesordertotal:OftenUseReport_合同额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesordercount:salesordercount:OftenUseReport_salesordercount:N', 11, 1, 'LD_salesorder:salesordercount:salesordercount:OftenUseReport_合同笔数:N','LD_salesorder:salesordercount:salesordercount:OftenUseReport_salesorder count:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesordercount:salesordercount:OftenUseReport_合同笔数:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_expense:expensetotal:expensetotal:OftenUseReport_expensetotal:N', 12, 1, 'LD_expense:expensetotal:expensetotal:OftenUseReport_费用:N','LD_expense:expensetotal:expensetotal:OftenUseReport_Fee:N' 
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_expense:expensetotal:expensetotal:OftenUseReport_费用:N');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','OrderSubject','Order Subject','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OrderSubject' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','OrderSubject','合同订单主题','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OrderSubject' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET Fieldlabel=' Email模板' WHERE labelbol='EMAILTEMPLATES' AND languagetype='zh';
delimiter;

UPDATE ld_usereport SET pagewidthpercent=100;
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='SalesOrderTrack';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='CashBillSum_Paymentplan';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='CashBillSum_SalesOrder';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='PurchaseReport';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='PurchaseOrderTrack';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='SendCashBillSum_PurchaseOrder';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='SendCashBillSum_SendPayment';
delimiter;
UPDATE ld_usereport SET pagewidthpercent=110 WHERE name='Performancestatisticscollection';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Public','Public','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Public' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Public','公开','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Public' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_quickactions` (
  `relation_id` int(19) NOT NULL auto_increment,
  `tabid` int(10) default NULL,
  `related_tabid` int(10) default NULL,
  `sequence` int(10) default NULL,
  `presence` int(10) NOT NULL default '0',
  `label` varchar(100) default NULL,
  PRIMARY KEY  (`relation_id`),
  KEY `relatedlists_relation_id_idx` USING BTREE (`relation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=172 DEFAULT CHARSET=utf8;


select tabid into @tabid from ld_tab where name = 'Contacts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Emails';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'MassSMS';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-3,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-3);
delimiter;


select tabid into @tabid from ld_tab where name = 'Accounts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Contacts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Calendar';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Quotes';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Potentials';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'OutboundOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'CashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'CashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Emails';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'MassSMS';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-4,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-4);
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select 16,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=16 and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name = 'Documents';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'Documents';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Documents';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-6,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-6);
delimiter;

select tabid into @tabid from ld_tab where name = 'Documents';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-7,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-7);
delimiter;

select tabid into @tabid from ld_tab where name = 'Documents';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-8,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-8);
delimiter;


select tabid into @tabid from ld_tab where name = 'Faq';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'Faq';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;


select tabid into @tabid from ld_tab where name = 'Campaigns';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Campaigns';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'Potentials';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Quotes';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Calendar';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
select tabid into @tabid2 from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
select tabid into @tabid2 from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'SalesBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'ServiceContracts';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Project';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'OutboundOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'HelpDesk';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Calendar';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'CashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'PaymentPlan';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Expense';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Commission';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesBack';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesBack';
select tabid into @tabid2 from ld_tab where name = 'SalesBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'VendorContact';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'VendorContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'PurchaseOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'VendorContact';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
select tabid into @tabid2 from ld_tab where name = 'VendorContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'Stock';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'SendCashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name = 'VendorContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContactRecords';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContactRecords';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name = 'Project';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
select tabid into @tabid2 from ld_tab where name = 'ProjectTask';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
select tabid into @tabid2 from ld_tab where name = 'ProjectMilestone';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectTask';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectTask';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectTask';
select tabid into @tabid2 from ld_tab where name = 'ContactRecords';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectTask';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name = 'ProjectMilestone';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectMilestone';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'SendCashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'SendCashBill';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'CashBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBack';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'PaymentPlan';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'PaymentPlan';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'PaymentPlan';
select tabid into @tabid2 from ld_tab where name = 'CashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'SendPayment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'SendPayment';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SendPayment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'SendPayment';
select tabid into @tabid2 from ld_tab where name = 'SendCashBill';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'BankAccountSet';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'BankAccountSet';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PutCash';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'PutCash';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'CashDeposit';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'CashDeposit';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ModComments';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'ModComments';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name = 'Products';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Products';
select tabid into @tabid2 from ld_tab where name = 'Quotes';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Products';
select tabid into @tabid2 from ld_tab where name = 'SalesOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'PriceBooks';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name = 'Checks';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Checks';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Checks';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BLOCKCHINESENAMECANNOTBEEMPTY','区块中文名称不能为空','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BLOCKCHINESENAMECANNOTBEEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BLOCKCHINESENAMECANNOTBEEMPTY',"Block Chinese name cannot be empty",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BLOCKCHINESENAMECANNOTBEEMPTY' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BLOCKENGLISHNAMECANNOTBEEMPTY','区块英文名称不能为空','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BLOCKENGLISHNAMECANNOTBEEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BLOCKENGLISHNAMECANNOTBEEMPTY',"Block English name cannot be empty",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BLOCKENGLISHNAMECANNOTBEEMPTY' and Labeltype='jspop');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PROJECTSETTINGS','相关项目设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PROJECTSETTINGS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PROJECTSETTINGS','Project settings','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PROJECTSETTINGS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SHORTCUTSETTINGS','快捷操作设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SHORTCUTSETTINGS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SHORTCUTSETTINGS','Shortcut settings','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHORTCUTSETTINGS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AVAILABLEPROJECT','可用项目','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AVAILABLEPROJECT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AVAILABLEPROJECT','Available project','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AVAILABLEPROJECT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEPROJECTANDTHEORDEROFDISPLAY','显示的项目及顺序','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEPROJECTANDTHEORDEROFDISPLAY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEPROJECTANDTHEORDEROFDISPLAY','The project and the order of display','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEPROJECTANDTHEORDEROFDISPLAY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MODIFIEDBLOCKNAME','修改区块名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MODIFIEDBLOCKNAME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MODIFIEDBLOCKNAME','Modified block name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODIFIEDBLOCKNAME' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PRINTTOOL','打印工具','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PRINTTOOL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PRINTTOOL','Printing tool','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PRINTTOOL' and Labeltype='fixedstr');
delimiter;


select usereportid into @id from LD_usereport where name='Contactbusinesstable';
DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;
delimiter;

select usereportid into @id from LD_usereport where name='Contactbusinesstable';
delete from LD_UseReportcolumns where Usereportid=@id;
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:lastname:lastname:contactdetails_lastname:V', 1, 1, 'LD_contactdetails:lastname:lastname:contactdetails_联系人:V','LD_contactdetails:lastname:lastname:contactdetails_联系人:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:title:title:contactdetails_title:V', 2, 1, 'LD_contactdetails:title:title:contactdetails_职务:V','LD_contactdetails:title:title:contactdetails_职务:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactdetails:title:title:contactdetails_职务:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:mobile:mobile:contactdetails_mobile:N', 3, 1, 'LD_contactdetails:mobile:mobile:contactdetails_手机:N','LD_contactdetails:mobile:mobile:contactdetails_手机:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactdetails:mobile:mobile:contactdetails_手机:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:pphone:pphone:contactdetails_pphone:N', 4, 1, 'LD_contactdetails:pphone:pphone:contactdetails_办公电话:N','LD_contactdetails:pphone:pphone:contactdetails_办公电话:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactdetails:pphone:pphone:contactdetails_办公电话:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:accountid:accountid:contactdetails_accountid:V', 5, 1, 'LD_contactdetails:accountid:accountid:contactdetails_所在公司:V','LD_contactdetails:accountid:accountid:contactdetails_所在公司:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactdetails:accountid:accountid:contactdetails_所在公司:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:signed_data:signed_data:salesorder_signed_data:D', 6, 1, 'LD_salesorder:signed_data:signed_data:salesorder_签约日期:D','LD_salesorder:signed_data:signed_data:salesorder_签约日期:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:signed_data:signed_data:salesorder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_products:productcategory:productcategory:product_productcategory:V', 7, 1, 'LD_products:productcategory:productcategory:product_业务类别:V','LD_products:productcategory:productcategory:product_业务类别:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_products:productcategory:productcategory:product_业务类别:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:salesorder_salesorder_no:V', 8, 1, 'LD_salesorder:salesorder_no:salesorder_no:salesorder_合同编号:V','LD_salesorder:salesorder_no:salesorder_no:salesorder_合同编号:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_no:salesorder_no:salesorder_合同编号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:NN', 9, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:NN', 10, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同金额:NN');


SELECT tabid into@tabid FROM ld_tab WHERE name='Expense';
select  fieldlabel into@enfieldname FROM ld_tranlabel WHERE tabid=@tabid and relateid=@tabid and languagetype='en';
select  fieldlabel into@zhfieldname FROM ld_tranlabel WHERE tabid=@tabid and relateid=@tabid and languagetype='zh';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:NN', 11, 1, concat('ld_expense:total:total:expense_佣金(',@zhfieldname,'):NN'),
concat('ld_expense:total:total:expense_Commission(',@enfieldname,'):NN')   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id 
and columns='ld_expense:total:total:expense_total:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:CashBillBalance:CashBillBalance:salesorder_CashBillBalance:NN', 12, 1, 'LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:NN','LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:NN', 13, 1, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN','LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_count:salesorder_count:salesorder_salesorder_count:N', 14, 1, 'LD_salesorder:salesorder_count:salesorder_count:salesorder_学员人数:N','LD_salesorder:salesorder_count:salesorder_count:salesorder_学员人数:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_count:salesorder_count:salesorder_学员人数:N');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Campaigns';
DELETE from ld_relatedlists where tabid=@tabid and label='Leads' and name='get_leads';
DELETE from ld_relatedlists where name='get_related_list' and label='Services';

update ld_tab set printtab=1;
delimiter;
drop procedure if exists `updatequicactionsseq`;
delimiter ||
create procedure updatequicactionsseq
(

)
begin
   
		declare tmp_tabid int default 0;
		declare mycursor cursor for select tabid from ld_quickactions where tabid>0 group by tabid;		
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;
		
		update ld_quickactions set sequence=1000;
		update ld_quickactions set sequence=1 where related_tabid=(select tabid from ld_tab where name='SalesBack');
		update ld_quickactions set sequence=2 where related_tabid=(select tabid from ld_tab where name='Contacts');
		update ld_quickactions set sequence=3 where related_tabid=(select tabid from ld_tab where name='VendorContact');
		update ld_quickactions set sequence=4 where related_tabid=(select tabid from ld_tab where name='ContactRecords');
		update ld_quickactions set sequence=5 where related_tabid=(select tabid from ld_tab where name='VendorContactRecords');
		update ld_quickactions set sequence=6 where related_tabid in (select tabid from ld_tab where name in('Events','Calendar'));
		update ld_quickactions set sequence=7 where related_tabid=(select tabid from ld_tab where name='Quotes');
		update ld_quickactions set sequence=8 where related_tabid=(select tabid from ld_tab where name='Potentials');
		update ld_quickactions set sequence=9 where related_tabid=(select tabid from ld_tab where name='SalesOrder');
		update ld_quickactions set sequence=10 where related_tabid=(select tabid from ld_tab where name='PurchaseOrder');
		update ld_quickactions set sequence=11 where related_tabid=(select tabid from ld_tab where name='ServiceContracts');
		update ld_quickactions set sequence=12 where related_tabid=(select tabid from ld_tab where name='Invoice');
		update ld_quickactions set sequence=13 where related_tabid=(select tabid from ld_tab where name='PaymentPlan');
		update ld_quickactions set sequence=14 where related_tabid=(select tabid from ld_tab where name='SendPayment');
		update ld_quickactions set sequence=15 where related_tabid=(select tabid from ld_tab where name='CashBill');
		update ld_quickactions set sequence=16 where related_tabid=(select tabid from ld_tab where name='SendCashBill');
		update ld_quickactions set sequence=17 where related_tabid=(select tabid from ld_tab where name='Expense');
		update ld_quickactions set sequence=18 where related_tabid=(select tabid from ld_tab where name='Commission');
		update ld_quickactions set sequence=19 where related_tabid=(select tabid from ld_tab where name='PutCash');
		update ld_quickactions set sequence=20 where related_tabid=(select tabid from ld_tab where name='CashDeposit');
		update ld_quickactions set sequence=21 where related_tabid=(select tabid from ld_tab where name='HelpDesk');
		update ld_quickactions set sequence=22 where related_tabid=(select tabid from ld_tab where name='Project');
		update ld_quickactions set sequence=23 where related_tabid=(select tabid from ld_tab where name='ProjectTask');
		update ld_quickactions set sequence=24 where related_tabid=(select tabid from ld_tab where name='ProjectMilestone');
		update ld_quickactions set sequence=25 where related_tabid=(select tabid from ld_tab where name='OutboundOrder');
		update ld_quickactions set sequence=26 where related_tabid=(select tabid from ld_tab where name='Stock');
		update ld_quickactions set sequence=27 where related_tabid=(select tabid from ld_tab where name='Checks');
		update ld_quickactions set sequence=28 where related_tabid=(select tabid from ld_tab where name='Reminds');
		update ld_quickactions set sequence=29 where related_tabid=(select tabid from ld_tab where name='Attachment');
		update ld_quickactions set sequence=30 where related_tabid=(select tabid from ld_tab where name='Quotes');
		update ld_quickactions set sequence=31 where related_tabid=(select tabid from ld_tab where name='MassSMS');
		update ld_quickactions set sequence=32 where related_tabid=(select tabid from ld_tab where name='Emails');
  					
		open mycursor;
		fetch mycursor into tmp_tabid;
		while(tmp_tabid is not null) DO
				
				insert into ld_quickactions(tabid,related_tabid,sequence,presence)
				select tmp_tabid,-5,0,1 from dual 
				where not exists (select 1 from ld_quickactions where tabid=tmp_tabid and related_tabid=-5);
				
				select 1000 into @seq;
				update ld_quickactions set sequence=@seq+1,label='查看上下级客户' where tabid=tmp_tabid and related_tabid=-4;
				update ld_quickactions set sequence=@seq+2,label='创建下级联系人' where tabid=tmp_tabid and related_tabid=-2;
				update ld_quickactions set sequence=@seq+3,label='查看上下级联系人' where tabid=tmp_tabid and related_tabid=-3;
				update ld_quickactions set sequence=@seq+4,label='修改日志' where tabid=tmp_tabid and related_tabid=-1;
				update ld_quickactions set sequence=@seq+5,label='检查附件完整性' where tabid=tmp_tabid and related_tabid=-7;
				update ld_quickactions set sequence=@seq+6,label='下载附件' where tabid=tmp_tabid and related_tabid=-6;
				update ld_quickactions set sequence=@seq+7,label='打印工具' where tabid=tmp_tabid and related_tabid=-5;
				update ld_quickactions set sequence=@seq+8,label='发送邮件添加附件' where tabid=tmp_tabid and related_tabid=-8;
			
				SELECT 0 into @i;
				update ld_quickactions set sequence=(@i:=@i+1) where tabid=tmp_tabid order by sequence; 
				
				fetch mycursor into tmp_tabid;
		end while;
		close mycursor;

end ||
delimiter;

call updatequicactionsseq;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_lessionplan` (
  `lessionplanid` int(19) NOT NULL,
  `projectid` int(19) default NULL,
  `servicecontractsid` int(19) default NULL,
  `projectmilestoneid` int(19) default NULL,
  `projecttaskid` int(19) default NULL,
  `lessiondate` date default NULL,
  `lessiontype` varchar(100) character set utf8 default NULL,
  `starttime` varchar(25) character set utf8 default NULL,
  `endtime` varchar(25) character set utf8 default NULL,
  `remark` text character set utf8,
  PRIMARY KEY  (`lessionplanid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 

CREATE TABLE IF NOT EXISTS `ld_lessionplanorg` (
  `accountid` int(19) NOT NULL,
  `otherid` int(19) default NULL,
  `type` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_lessionplanscf` (
  `lessionplanid` int(19) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
select trade into @trade from ld_version;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'LessionPlan',case when @trade = 'edu' then 0 else 1 end,@tabsequence+1,'LessionPlan',1,'Tools',0 
from dual where not EXISTS(select 1 from ld_tab where tablabel ='LessionPlan');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Project';
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'课程计划' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='课程计划');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'LessionPlan' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='LessionPlan');
/*-------------------Insert into LD_ws_entity-------------uitls.php报错-------*/
insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'LessionPlan','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'LessionPlan' );
delimiter;
/*----------------插入佣金单模块角色权限---------------*/
call fieldprofile('LessionPlan');
-- call getallprofile('LessionPlan');
-- call addtabintoprofile('LessionPlan',0);
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);
/*----------------插入佣金单模块共享规则(自定义规则在setting/OrgSharingDetailView.php中添加)---------------*/
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

/*-------------------默认分类ALL--------------------*/
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'LessionPlan',0,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' 
and entitytype ='LessionPlan');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'LessionPlan' and viewname = 'All';
/*--班级--*/
delete from ld_cvcolumnlist where cvid =  @cvid and columnindex = 1;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V');
/*--课程--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V');
/*--教师--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V');
/*--教室--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V');
/*--上课日期--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V');
/*--上课时段--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V');
/*-------------------默认分类 本周--------------------*/
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'本周',0,'LessionPlan',1,1,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本周' 
and entitytype ='LessionPlan');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'LessionPlan' and viewname = '本周';
/*--班级--*/
delete from ld_cvcolumnlist where cvid =  @cvid and columnindex = 1;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V');
/*--课程--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V');
/*--教师--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V');
/*--教室--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V');
/*--上课日期--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V');
/*--上课时段--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V');

select cvid into @cvid from ld_customview where entitytype = 'LessionPlan' and viewname = '本周';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel','thisweek','2014-6-25','2014-6-25'
from dual where not EXISTS(select 1 from ld_cvstdfilter  where cvid = @cvid 
and stdfilter = 'thisweek');
/*-------------------默认分类 下周--------------------*/
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'下周',0,'LessionPlan',1,1,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '下周' 
and entitytype ='LessionPlan');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'LessionPlan' and viewname = '下周';
/*--班级--*/
delete from ld_cvcolumnlist where cvid =  @cvid and columnindex = 1;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V');
/*--课程--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V');
/*--教师--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V');
/*--教室--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V');
/*--上课日期--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V');
/*--上课时段--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V');

select cvid into @cvid from ld_customview where entitytype = 'LessionPlan' and viewname = '下周';
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel','nextweek','2014-6-25','2014-6-25'
from dual where not EXISTS(select 1 from ld_cvstdfilter  where cvid = @cvid 
and stdfilter = 'nextweek');
/*-------------------默认分类 本月--------------------*/
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'本月',0,'LessionPlan',1,1,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本月' 
and entitytype ='LessionPlan');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'LessionPlan' and viewname = '本月';
/*--班级--*/
delete from ld_cvcolumnlist where cvid =  @cvid and columnindex = 1;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectid:projectid:LessionPlan_fieldlabel:V');
/*--课程--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:servicecontractsid:servicecontractsid:LessionPlan_fieldlabel:V');
/*--教师--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projectmilestoneid:projectmilestoneid:LessionPlan_fieldlabel:V');
/*--教室--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:projecttaskid:projecttaskid:LessionPlan_fieldlabel:V');
/*--上课日期--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel:V');
/*--上课时段--*/
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnname = 'LD_lessionplan:lessiontype:lessiontype:LessionPlan_fieldlabel:V');

insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_lessionplan:lessiondate:lessiondate:LessionPlan_fieldlabel','thismonth','2014-6-25','2014-6-25'
from dual where not EXISTS(select 1 from ld_cvstdfilter  where cvid = @cvid 
and stdfilter = 'thismonth');
/*----------------插入课程计划表单信息------------------*/
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_LESSIONPLAN_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_LESSIONPLAN_INFO' and sequence = 1);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
delimiter;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_LESSIONPLAN_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='基本信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Reminds Content' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Reminds Content');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'projectid','LD_lessionplan',15,'projectid','班级',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'projectid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'servicecontractsid','LD_lessionplan',15,'servicecontractsid','课程',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'servicecontractsid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'projectmilestoneid','LD_lessionplan',15,'projectmilestoneid','教师',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'projectmilestoneid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'projecttaskid','LD_lessionplan',15,'projecttaskid','教室',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'projecttaskid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'lessiondate','LD_lessionplan',2,'lessiondate','上课时间',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'D~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'lessiondate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'lessiontype','LD_lessionplan',1,'lessiontype','上课时段',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),2,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'lessiontype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'starttime','LD_lessionplan',1,'starttime','开始时段',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'starttime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'endtime','LD_lessionplan',1,'endtime','结束时段',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~M' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'endtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'remark','LD_lessionplan',19,'remark','备注',(select blockid from ld_blocks where blocklabel = 'LBL_LESSIONPLAN_INFO'),1,0,'V~0' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'remark');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','LD_crmentity',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),2,0,'DT~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','LD_crmentity',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),2,0,'DT~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','LD_crmentity',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),2,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
/*----------------插入课程计划翻译信息------------------*/
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projectid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'班级' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='班级');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Class' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Class');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'servicecontractsid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'课程' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='课程');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Course' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Course');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projectmilestoneid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'教师' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='教师');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Teacher' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Teacher');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projecttaskid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'教室' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='教室');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Classroom' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Classroom');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lessiondate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'上课时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='上课时间');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Class Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Class Date');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lessiontype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'上课时段' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='上课时段');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Class Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Class Time');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'starttime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'开始时段' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='开始时段');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Start Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Start Time');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'endtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'结束时段' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='结束时段');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'End Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='End Time');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'remark';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='备注');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Remarks' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Remarks');

/*---------课程计划 创建附件、修改日志 脚本---------*/
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid 
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;
/*---------课程计划 打印工具 脚本---------*/
update ld_tab set printtab = 1 where `name` = 'LessionPlan';
delimiter;
/*---------课程计划 修改日志 脚本---------*/
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid 
and visible =1);
/*---------课程计划  添加 翻译文件---------*/
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADDLESSIONPLAN','新增','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADDLESSIONPLAN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADDLESSIONPLAN','Add','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADDLESSIONPLAN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LESSIONPLANDETAILS','课程计划明细','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LESSIONPLANDETAILS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LESSIONPLANDETAILS','Lession Plan Details','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LESSIONPLANDETAILS' and Labeltype='fixedstr');
delimiter;

/*---------班级更多信息增加---------*/
select tabid into @tabid from ld_tab where `name` = 'Project';
select tabid into @related_tabid from ld_tab where `name` = 'ServiceContracts';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_projectservicecontracts',@sequence+1,'ServiceContracts','add'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

/*---------班级更多信息增加学员---------*/
select tabid into @tabid from ld_tab where `name` = 'Project';
select tabid into @related_tabid from ld_tab where `name` = 'Accounts';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_projectaccounts',@sequence+1,'Accounts','add,select'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

/*---------班级更多信息增加课程计划---------*/
select tabid into @tabid from ld_tab where `name` = 'Project';
select tabid into @related_tabid from ld_tab where `name` = 'LessionPlan';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_lessionplan',@sequence+1,'LessionPlan',''
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

/*---------教室更多信息增加课程计划---------*/
select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
select tabid into @related_tabid from ld_tab where `name` = 'LessionPlan';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_lessionplan',@sequence+1,'LessionPlan',''
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

/*---------教师更多信息增加课程计划---------*/
select tabid into @tabid from ld_tab where `name` = 'ProjectMilestone';
select tabid into @related_tabid from ld_tab where `name` = 'LessionPlan';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_lessionplan',@sequence+1,'LessionPlan',''
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

/*---------课程更多信息增加课程计划---------*/
select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select tabid into @related_tabid from ld_tab where `name` = 'LessionPlan';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_lessionplan',@sequence+1,'LessionPlan',''
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PROJECTHAVEACCOUNTNUM','班级学员人数已上线，请重新选择','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PROJECTHAVEACCOUNTNUM' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PROJECTHAVEACCOUNTNUM','The class number of students has been on the line, please re select','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PROJECTHAVEACCOUNTNUM' and Labeltype='jspop');
delimiter;

/*---------学员更多信息增加班级---------*/
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @related_tabid from ld_tab where `name` = 'Project';
select id into @id from ld_relatedlists_seq;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_project',@sequence+1,'Project','ADD,SELECT'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
select trade into @trade from ld_version;
update  ld_relatedlists set actions = 'ADD,SELECT' 
where tabid = @tabid and related_tabid = @related_tabid and @trade = 'edu';
delimiter;

/*---------学员更多信息增加课程---------*/
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @related_tabid from ld_tab where `name` = 'ServiceContracts';
select id into @id from ld_relatedlists_seq;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_ServiceContracts',@sequence+1,'ServiceContracts','ADD,SELECT'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
select trade into @trade from ld_version;
update  ld_relatedlists set actions = 'ADD,SELECT' 
where tabid = @tabid and related_tabid = @related_tabid and @trade = 'edu';
delimiter;

/*---------学员更多信息增加教师---------*/
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @related_tabid from ld_tab where `name` = 'ProjectMilestone';
select id into @id from ld_relatedlists_seq;
select trade into @trade from ld_version;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_ProjectMilestone',@sequence+1,'ProjectMilestone','ADD,SELECT'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
update  ld_relatedlists set actions = 'ADD,SELECT' 
where tabid = @tabid and related_tabid = @related_tabid and @trade = 'edu';
delimiter;

/*---------学员更多信息增加课程计划---------*/
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @related_tabid from ld_tab where `name` = 'LessionPlan';
select id into @id from ld_relatedlists_seq;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_LessionPlan',@sequence+1,'LessionPlan',''
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid ) and @trade = 'edu';
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'LessionPlan','LD_lessionplan','lessionplanid','lessionplanid','lessionplanid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='LessionPlan');
delimiter;
-- End: 2014-06-25 by luyx 

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.3.3' ,current_version='V5.3.3' ,remark='V5.3.3-20140625';
delimiter;