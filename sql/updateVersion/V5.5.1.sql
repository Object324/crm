call AddColumn('ld_automaticreminds','remindmethod','int',5,0);
update ld_automaticreminds set remindmethod=0 where remindmethod>=1;
delimiter;
call AddColumn('ld_seactivityrel','reminds_ruleid','int',4,0);
delimiter;
call AddColumn('LD_activity_reminder','reminds_ruleid','int',4,0);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REMINDMETHOD','提醒方式','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REMINDMETHOD' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'end','REMINDMETHOD','Remind Way','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='REMINDMETHOD' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIALOG','对话框','fixedstr' from DUAL
 where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DIALOG' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'end','DIALOG','Dialog','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DIALOG' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EMAIL','邮件','fixedstr' from DUAL
 where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EMAIL' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'end','EMAIL','Email','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EMAIL' and Labeltype='fixedstr');
delimiter;

call addtableIndex('ld_activity','activity_deleted','deleted');
call addtableIndex('ld_activity_reminder','activity_reminder','reminder_sent');
delimiter;
call getallprofile('paymentplan');
call fieldprofile('paymentplan');
delimiter;


insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,40,'回款计划提前提醒天数','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=40);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,41,'付款计划提前提醒天数','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=41);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PAYMENTPLAYREMINDS',"到期前N天提醒（为0表示当前提醒，为空表示不提醒）",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PAYMENTPLAYREMINDS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PAYMENTPLAYREMINDS','N days before the payment plan expired（if 0 remind on the same day, if null don’t remind）','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PAYMENTPLAYREMINDS' and Labeltype='fixedstr');
delimiter;

call Addcolumn('ld_automaticreminds','defaultnum','int','11',null);
delimiter;

SELECT tabid INTO @tabid from LD_tab where name='PaymentPlan';
insert into ld_automaticreminds(tabid,name,columnname,remindnum,remindway,remindday,reminder,remindcontent,status,smcreatorid,remindmethod,defaultnum)
SELECT
@tabid,
'回款计划预置提醒',
'LD_paymentplan:plandate:plandate:PaymentPlan_fieldlabel',
1,2,0,1,
'回款计划到期，请及时催收！公司名称：[var.paymentplan_account_id_PaymentPlan]，
期次：[var.paymentplan_periodtime_PaymentPlan]，金额：[var.paymentplan_amount_PaymentPlan]',1,1,0,40
from dual where not exists (select 1 from ld_automaticreminds where tabid=@tabid and defaultnum=40 );

SELECT id into @cvid from ld_automaticreminds where tabid=@tabid and defaultnum=40;
INSERT into ld_remindway (wayid,remindsday,sequence) SELECT @cvid,-3,1 from  dual where not exists (SELECT 1  from ld_remindway where wayid=@cvid );

INSERT into ld_remindcvadvfilter (cvid,columnindex,columnname,comparator,value,groupid) SELECT @cvid,1,
'LD_paymentplan:paymentstatus:paymentstatus:PaymentPlan_fieldlabel:V','n','已收',1
from dual where not EXISTS (SELECT 1 from ld_remindcvadvfilter where cvid=@cvid);

INSERT into LD_remindcvadvfilter_grouping (groupid,cvid,group_condition,condition_expression) SELECT 1,@cvid,'',0 from DUAL where not EXISTS (SELECT 1 from
LD_remindcvadvfilter_grouping where cvid=@cvid);
delimiter;


SELECT tabid INTO @tabid from LD_tab where name='SendPayment';
insert into ld_automaticreminds(tabid,name,columnname,remindnum,remindway,remindday,reminder,remindcontent,status,smcreatorid,remindmethod,defaultnum)
SELECT
@tabid,
'付款计划预置提醒',
'LD_sendpayment:plandate:plandate:SendPayment_fieldlabel',
1,2,0,1,
'付款计划到期，请及时付款！供应商名称：[var.sendpayment_vendor_id_SendPayment]，期次：[var.sendpayment_cpperiodtime_SendPayment]，金额：[var.sendpayment_amount_SendPayment]',
1,1,0,41
from dual where not exists (select 1 from ld_automaticreminds where tabid=@tabid and defaultnum=41 );

SELECT id into @cvid from ld_automaticreminds where tabid=@tabid and defaultnum=41;
INSERT into ld_remindway (wayid,remindsday,sequence) SELECT @cvid,-3,1 from  dual where not exists (SELECT 1  from ld_remindway where wayid=@cvid );

INSERT into ld_remindcvadvfilter (cvid,columnindex,columnname,comparator,value,groupid) SELECT @cvid,1,
'LD_sendpayment:cpstatus:cpstatus:SendPayment_fieldlabel:V','n','已付',1
from dual where not EXISTS (SELECT 1 from ld_remindcvadvfilter where cvid=@cvid);

INSERT into LD_remindcvadvfilter_grouping (groupid,cvid,group_condition,condition_expression) SELECT 1,@cvid,'',0 from DUAL where not EXISTS (SELECT 1 from
LD_remindcvadvfilter_grouping where cvid=@cvid);
delimiter;


update ld_desk set Fieldlabel = ' {$OutboundOrder.OutboundOrder} or {$Stock.Stock} must be strictly according to source and single (each product cumulative quantity is not allowed to exceed the source single or source <br/> single foreign products)' where labelbol= 'OUTBOUNDSTOCKACCORDORIGNAL'
and languagetype='en' and Labeltype = 'fixedstr';
delimiter;


SELECT MAX(relation_id) INTO @relationid FROM ld_relatedlists;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='ServiceContracts';

SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='Invoice';
INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+1,@tabid,@relatedtabid,'get_invoice',9,'Invoice',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_invoice' AND tabid=@tabid);

SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='CashBill';
INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+2,@tabid,@relatedtabid,'get_cashbill',9,'CashBill',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_cashbill' AND tabid=@tabid);

SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='Commission';
INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+3,@tabid,@relatedtabid,'get_commission',9,'Commission',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_commission' AND tabid=@tabid);

SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='Expense';
INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+4,@tabid,@relatedtabid,'get_expense',9,'Expense',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_expense' AND tabid=@tabid);

UPDATE lD_relatedLists_seq SET id = (@relationid+4);
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='SIGNINSTATISTICS';
DELETE FROM ld_usereportcolumns WHERE usereportid=@id;

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_users:last_name:last_name:OftenUseReport_职员:V', 1, 1, 'LD_users:last_name:last_name:OftenUseReport_职员:V','LD_users:last_name:last_name:OftenUseReport_lastname:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_users:last_name:last_name:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_singin:createdtime:signedtime:OftenUseReport_签到时间:D', 2, 1, 'LD_singin:createdtime:signedtime:OftenUseReport_签到时间:D','LD_singin:createdtime:signedtime:OftenUseReport_Sign in time:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_singin:createdtime:signedtime:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_singin:address:address:OftenUseReport_签到地址:V', 3, 1, 'LD_singin:address:address:OftenUseReport_签到地址:V','LD_singin:address:address:OftenUseReport_Sing in address:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_singin:address:address:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_accounts:accountname:accountname:OftenUseReport_签到客户:V', 4, 1, 'LD_accounts:accountname:accountname:OftenUseReport_签到客户:V','LD_accounts:accountname:accountname:OftenUseReport_Sing in customer:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_accounts:accountname:accountname:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V', 5, 1, 'LD_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V','LD_accounts:bill_street:bill_street:OftenUseReport_Related to customer address:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns LIKE '%LD_accountbillads:bill_street:ship_street:OftenUseReport_%');
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='PartnerCommencementSchedule';
UPDATE  ld_usereportcolumns SET realcolumns='ld_expense:total:total:expense_佣金:NN',realencolumns='ld_expense:total:total:expense_佣金(费用报销):NN' 
WHERE Usereportid=@id AND columns LIKE '%ld_expense:total:total:expense_%';
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='Contactbusinesstable';
UPDATE  ld_usereportcolumns SET realcolumns='ld_expense:total:total:expense_佣金:NN',realencolumns='ld_expense:total:total:expense_佣金(费用报销):NN' 
WHERE Usereportid=@id AND columns LIKE '%ld_expense:total:total:expense_%';
delimiter;

update ld_desk set Fieldlabel='1天前' where labelbol='before0days' and languagetype='zh'; 
update ld_desk set Fieldlabel='1 day ago' where labelbol='before0days' and languagetype='en';

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'ServiceContracts';
SELECT tabid INTO @related_tabid FROM ld_tab WHERE NAME = 'Invoice';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@related_tabid,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@related_tabid);

SELECT tabid INTO @related_tabid FROM ld_tab WHERE NAME = 'CashBill';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@related_tabid,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@related_tabid);

SELECT tabid INTO @related_tabid FROM ld_tab WHERE NAME = 'Commission';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@related_tabid,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@related_tabid);

SELECT tabid INTO @related_tabid FROM ld_tab WHERE NAME = 'Expense';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@related_tabid,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@related_tabid);
delimiter;

update ld_desk set Fieldlabel = ' {$OutboundOrder.OutboundOrder} or {$Stock.Stock} must be strictly according to source and single (each product cumulative quantity is not allowed to exceed the source single or source single foreign products)' where labelbol= 'OUTBOUNDSTOCKACCORDORIGNAL'
and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

alter table ld_cashbill alter column entitytype set default 'SalesOrder';
alter table ld_commission alter column entitytype set default 'SalesOrder';
alter table ld_invoice alter column entitytype set default 'SalesOrder';
alter table ld_expense alter column entitytype set default 'SalesOrder';
delimiter;

update ld_account set modifiedtime=createdtime where modifiedtime='0000-00-00 00:00:00' or modifiedtime is null;
update ld_contactdetails set modifiedtime=createdtime where modifiedtime='0000-00-00 00:00:00' or modifiedtime is null;
update ld_salesorder set modifiedtime=createdtime where modifiedtime='0000-00-00 00:00:00' or modifiedtime is null;
update ld_contactrecords set modifiedtime=createdtime where modifiedtime='0000-00-00 00:00:00' or modifiedtime is null;
delimiter;
-- end 2014-07-29 

call addColumn('ld_singin','accountid','int',19,0);

UPDATE ld_singin INNER JOIN ld_account ON ld_singin.content=ld_account.accountname
SET ld_singin.accountid=ld_account.accountid ;
delimiter;

select  blockid  into @blockid from ld_blocks where blocklabel='LBL_PaymentPlan_INFORMATION';
update ld_field set block=@blockid where tabid in (select tabid from ld_tab where name='paymentplan')  and columnname='smownerid';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,48,'出库单或入库单更新库存流水记录触发点','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=48);
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','UPDATEINVENTORYLEDGER','出库单或入库单更新库存流水记录触发点','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='UPDATEINVENTORYLEDGER');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','UPDATEINVENTORYLEDGER','Out Store or In Store how to update the stock journal','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='UPDATEINVENTORYLEDGER');
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select tabid into @related_tabid from ld_tab where name = 'HelpDesk';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@related_tabid,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@related_tabid);
delimiter;

update ld_field set sequence=0 where tabid=4 and columnname='lastname';
update ld_field set sequence=1 where tabid=4 and columnname='contact_no';
update ld_field set sequence=2 where tabid=4 and columnname='firstname';
update ld_field set sequence=3 where tabid=4 and columnname='salutation';
update ld_field set sequence=4 where tabid=4 and columnname='accountid';
update ld_field set sequence=5 where tabid=4 and columnname='leadsource';
update ld_field set sequence=6 where tabid=4 and columnname='parentid';
update ld_field set sequence=7 where tabid=4 and columnname='reference';
update ld_field set presence=1 where tabid=4 and columnname='emailoptout';

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=4 and presence<>1 and block=4 order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='VendorContact';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_VendorContact_INFORMATION';
update ld_field set sequence=0 where tabid=@tabid and columnname='lastname';
update ld_field set sequence=1 where tabid=@tabid and columnname='vendorcontact_no';
update ld_field set sequence=2 where tabid=@tabid and columnname='firstname';
update ld_field set sequence=4 where tabid=@tabid and columnname='salutation';

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and presence<>1 and block=@blockid order by sequence;
delimiter;


update ld_tab set presence = 0 where name = 'PurchaseCashBack';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'purchaseorder_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购订单' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Purchase Order' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;
-- end 2014-07-30 

update ld_tranlabel set fieldlabel = '计量单位' 
where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'CashBack') 
and Relateid in (select fieldid from ld_field where columnname= 'usageunit' and tabid in (select tabid from ld_tab where name = 'CashBack') );
delimiter;

update ld_field set defaultvalue='thistoday' where tabid=6 and columnname='lastcontactdate';
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='SalesSumSequence';
SELECT tabid INTO @tid FROM ld_tab WHERE name='SalesOrder';

UPDATE  ld_usereport SET tabids=@tid WHERE Usereportid=@id;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Salesrecordslist','销售记录明细表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Salesrecordslist' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Salesrecordslist','Sales records list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Salesrecordslist' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Hospital','医院','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Hospital' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Hospital','Hospital','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Hospital' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OrderDate','下单日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OrderDate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OrderDate','Order Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OrderDate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SerialNumber','序列号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SerialNumber' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SerialNumber','Serial Number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SerialNumber' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Model1','型号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Model1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Model1','Model','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Model1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Degree','度数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Degree' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Degree','Degree','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Degree' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Patient','患者','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Patient' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Patient','Patient','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Patient' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Leftandrighteye','左右眼','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Leftandrighteye' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Leftandrighteye','Left and right eye','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Leftandrighteye' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ICMfilm','ICM(片)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ICMfilm','ICM (film)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TICMfilm','TICM(片)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TICMfilm','TICM (film)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Donatedpieces','赠片','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Donatedpieces' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Donatedpieces','Donated pieces','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Donatedpieces' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Ejectmonth','退片月份','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Ejectmonth' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Ejectmonth','Eject month','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Ejectmonth' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Billingdate','开票日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Billingdate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Billingdate','Billing date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Billingdate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SpecialNote','特别说明','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SpecialNote' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SpecialNote','Special Note','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SpecialNote' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CrystalOrderingInformation','晶体订购信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CrystalOrderingInformation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CrystalOrderingInformation','Crystal Ordering Information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CrystalOrderingInformation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EjectcrystalRecord','退片晶体记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EjectcrystalRecord' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EjectcrystalRecord','Eject crystal Record','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EjectcrystalRecord' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Alibrarycrystalinformation','出库晶体信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Alibrarycrystalinformation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Alibrarycrystalinformation','A library crystal information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Alibrarycrystalinformation' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and fieldname = 'total_units';
delimiter;
select tabid into @tabid from ld_tab where name = 'Products';
update ld_field set presence = 0 where tabid = @tabid and columnname = 'productsheet';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Products';
UPDATE ld_field SET typeofdata = 'NN~O~8,2' WHERE fieldname = 'qtyearly' AND tabid = @tabid AND typeofdata != 'NN~O~8,2';
-- end 2014-08-01


call Addcolumn('LD_modentity_num','isallow','int','2',0);
delimiter;
call Addcolumn('LD_modentity_num','prefixtype','int','2',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CURRENTCODE','当前流水号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CURRENTCODE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CURRENTCODE','Current Code','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CURRENTCODE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ALLOWTOMODIFY','允许手动编码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ALLOWTOMODIFY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ALLOWTOMODIFY','Allows to modify','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ALLOWTOMODIFY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIXEDCHARATERSTR','固定字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIXEDCHARATERSTR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIXEDCHARATERSTR','Fixed Characters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIXEDCHARATERSTR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEFIRSTLETTEROFSTATE','拼音首字母','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEFIRSTLETTEROFSTATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEFIRSTLETTEROFSTATE','The first letter of ','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEFIRSTLETTEROFSTATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REMINDTIMES','提醒时间','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REMINDTIMES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REMINDTIMES','Remind Time','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REMINDTIMES' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPEATTIME','重复次数','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REPEATTIME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPEATTIME','Repeat Times','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REPEATTIME' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPEATMODES','重复方式','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REPEATMODES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPEATMODES','Repeat Mode','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REPEATMODES' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel = '确认密码' where labelbol = 'Password_confirmation' and languagetype = 'zh';
update ld_desk set Fieldlabel = 'Confirmation Password' where labelbol = 'Password_confirmation' and languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','YOUCANCLICKONTHE','你可以点击','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUCANCLICKONTHE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','YOUCANCLICKONTHE','You can click on the','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUCANCLICKONTHE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADDARECORD','增加一条记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADDARECORD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADDARECORD','Add a record','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADDARECORD' and Labeltype='fixedstr');
delimiter;
-- end 2014-08-05

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.5.1' ,current_version='V5.5.1' ,remark='V5.5.1-20140805';
delimiter;