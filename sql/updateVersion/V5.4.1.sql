-- begin 2014-07-07
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','HBRREPORT','红不让报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='HBRREPORT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','HBRREPORT','HBR Report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HBRREPORT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','amountofcustomervisits','客户拜访量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='amountofcustomervisits' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','amountofcustomervisits','amount of customer visits','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='amountofcustomervisits' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','amountofnewcustomers','新增客户量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='amountofnewcustomers' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','amountofnewcustomers','amount of new customers','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='amountofnewcustomers' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','numberofnewcustomersdeal','新客户成交数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='numberofnewcustomersdeal' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','numberofnewcustomersdeal','number of new customers deal','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='numberofnewcustomersdeal' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','NewCustomerTurnover','新客户成交额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NewCustomerTurnover' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','NewCustomerTurnover','New Customer Turnover','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NewCustomerTurnover' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Newcustomerturnoveraccountedfor','新客户成交额占比','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Newcustomerturnoveraccountedfor' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Newcustomerturnoveraccountedfor','New customer turnover accounted for','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Newcustomerturnoveraccountedfor' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Oldcustomerturnover','老客户成交额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Oldcustomerturnover' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Oldcustomerturnover','Old customer turnover','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Oldcustomerturnover' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Oldcustomerturnovernumber','老客户成交数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Oldcustomerturnovernumber' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Oldcustomerturnovernumber','Old customer turnover number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Oldcustomerturnovernumber' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','totalnumberoftransactions','总成交数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='totalnumberoftransactions' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','totalnumberoftransactions','total number of transactions','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='totalnumberoftransactions' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','totalturnover','总的成交额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='totalturnover' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','totalturnover','total turnover','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='totalturnover' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET Fieldlabel='金额超出转出账号余额' WHERE labelbol='Amountexceedstheaccountbalance' AND Labeltype='jspop' AND languagetype='zh';

UPDATE ld_desk SET Fieldlabel='The amount transferred out of the account balance exceeds' WHERE labelbol='Amountexceedstheaccountbalance' AND Labeltype='jspop' AND languagetype='en';
delimiter;


UPDATE ld_desk SET Fieldlabel='毛利=含税金额-数量*产品成本价。' WHERE 
labelbol='MROSSMARGINNETPRODUCT' AND Labeltype='fixedstr' AND languagetype='zh';

UPDATE ld_desk SET Fieldlabel='Gross margin = Net Price - the number of * product cost price.' WHERE 
labelbol='MROSSMARGINNETPRODUCT' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

select usereportid into @usereportid from ld_usereport where name='CashBillSum_SalesOrder';
delete from ld_usereportbasic  where COLUMNS in 
(
select COLUMNS  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid
group by COLUMNS  having count >1  
 order by id) as tab
 ) and usereportid=@usereportid and  id not in
(
select id  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid 
group by COLUMNS  having count >1  
 order by id
) as tab1);
delimiter;


select usereportid into @usereportid from ld_usereport where name='CashBillSum_SalesOrder';
delete from ld_usereportbasic  where COLUMNS in 
(
select COLUMNS  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid
group by COLUMNS  having count >1  
 order by id) as tab
 ) and usereportid=@usereportid and  id not in
(
select id  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid 
group by COLUMNS  having count >1  
 order by id
) as tab1);
delimiter;
select usereportid into @usereportid from ld_usereport where name='CashBillSum_SalesOrder';
delete from ld_usereportbasic  where COLUMNS in 
(
select COLUMNS  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid
group by COLUMNS  having count >1  
 order by id) as tab
 ) and usereportid=@usereportid and  id not in
(
select id  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid 
group by COLUMNS  having count >1  
 order by id
) as tab1);
delimiter;


select usereportid into @usereportid from ld_usereport where name='SalesSumSequence';
delete from ld_usereportbasic  where COLUMNS in 
(
select COLUMNS  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid
group by COLUMNS  having count >1  
 order by id) as tab
 ) and usereportid=@usereportid and  id not in
(
select id  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid 
group by COLUMNS  having count >1  
 order by id
) as tab1);
delimiter;

select usereportid into @usereportid from ld_usereport where name='Contractamount';
delete from ld_usereportbasic  where COLUMNS in 
(
select COLUMNS  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid
group by COLUMNS  having count >1  
 order by id) as tab
 ) and usereportid=@usereportid and  id not in
(
select id  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid 
group by COLUMNS  having count >1  
 order by id
) as tab1);
delimiter;


select usereportid into @usereportid from ld_usereport where name='Contractnumber';
delete from ld_usereportbasic  where COLUMNS in 
(
select COLUMNS  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid
group by COLUMNS  having count >1  
 order by id) as tab
 ) and usereportid=@usereportid and  id not in
(
select id  from 
(
select id, COLUMNS,count(1) as count
 from ld_usereportbasic where Usereportid=@usereportid 
group by COLUMNS  having count >1  
 order by id
) as tab1);
delimiter;


update ld_desk set Fieldlabel="联系记录'备注'字段列表显示时是否截取" where labelbol='CONTACTRECORDINTERCEPTION' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set Fieldlabel="审核{$OutboundOrder.OutboundOrder}时是否发送短信通知客户" where labelbol='CONFIRMINFORMOUTBOUND'  and languagetype='zh' and Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','THEFILEISMISSPLEASERETURN','文件已丢失，请返回','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEFILEISMISSPLEASERETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','THEFILEISMISSPLEASERETURN','The file is missing, please return','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEFILEISMISSPLEASERETURN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SYSTEMERRORPLEASERETURN','系统错误，请返回','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SYSTEMERRORPLEASERETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SYSTEMERRORPLEASERETURN','System error, please return','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SYSTEMERRORPLEASERETURN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','THEAPPROVALPARAMENTERS','审批参数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEAPPROVALPARAMENTERS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','THEAPPROVALPARAMENTERS','The approval parameters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEAPPROVALPARAMENTERS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','REMINDERPARAMENERS','提醒参数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='REMINDERPARAMENERS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','REMINDERPARAMENERS','The reminder parameters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REMINDERPARAMENERS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
insert into ld_blocks(blockid,tabid,blocklabel,sequence,display_status)
select (select max(blockid)+1 from ld_blocks),@tabid,'LBL_SERVICECONTRACTS',0,1 from dual 
where not EXISTS(select 1 from ld_blocks  where tabid=@tabid and blocklabel='LBL_SERVICECONTRACTS');
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);

select sequence into @sequence from ld_blocks where tabid = @tabid and blocklabel = 'LBL_USER_IMAGE_INFORMATION';
update ld_blocks set sequence = @sequence where tabid = @tabid and blocklabel = 'LBL_SERVICECONTRACTS';
update ld_blocks set sequence = @sequence+1 where tabid = @tabid and blocklabel = 'LBL_USER_IMAGE_INFORMATION';
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_SERVICECONTRACTS';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable)
select @tabid,'select_servicedetail','LD_users',1,56,'select_servicedetail','Select ServiceDetail',1,0,1,@blockid,1,'V~O',3,0,'BAS',2 from dual
where not exists(select 1 from ld_field where tabid = @tabid and columnname='select_servicedetail' and tablename='LD_users');
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_SERVICECONTRACTS';
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable)
select @tabid,'select_due_date','LD_users',1,56,'select_due_date','Select DueDate',1,0,1,@blockid,1,'V~O',3,0,'BAS',2 from dual
where not exists(select 1 from ld_field where tabid = @tabid and columnname='select_due_date' and tablename='LD_users');
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICECONTRACTS';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'服务信息查看权限' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Service information access' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'select_due_date';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'是否允许查看具体的服务到期日' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Wether allowed to view the real service enddate' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'select_servicedetail';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'{$Accounts.Accounts}和{$HelpDesk.HelpDesk}明细界面是否显示服务信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Whether to display the block of service information on the details of accounts and servicecontracts' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call AddColumn('LD_users','select_servicedetail','int',11,0);
call AddColumn('LD_users','select_due_date','int',11,0);

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','PERIODOFSERVICE','服务期内','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='PERIODOFSERVICE');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','PERIODOFSERVICE','In Period of service','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='PERIODOFSERVICE');
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','OUTSIDEPERIODOFSERVICE','服务期外','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='OUTSIDEPERIODOFSERVICE');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','OUTSIDEPERIODOFSERVICE','Outside Period of service','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='OUTSIDEPERIODOFSERVICE');
delimiter;

select tabid into @tabid from ld_tab where name ='HelpDesk';
update ld_field set presence=1 where tabid=13 and columnname=' servicecontractsid';
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','SERVICEINFORMATION','服务信息','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='SERVICEINFORMATION');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','SERVICEINFORMATION','Service information','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='SERVICEINFORMATION');
delimiter;

update ld_desk set fieldlabel = '{$ServiceContracts.ServiceContracts}中产品服务到期提醒' where labelbol = 'REMINDSERVICECONTRACTSDEADLINE' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Products service reminder about the servicecontracts' where labelbol = 'REMINDSERVICECONTRACTSDEADLINE' and languagetype = 'en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'noamount','LD_commission',222,'noamount','noamount',(select blockid from ld_blocks where blocklabel = 'LBL_COMMISSION_INFO'),3,0,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'noamount');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'noamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整金额' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='调整金额');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Modified Time');
delimiter;


select fieldid into @fieldid from ld_field where tabid=29 and columnname='select_servicedetail';
select tabid into @tabid from ld_tab where name='Commission';
delete from ld_tranlabel where Relateid=@fieldid and tabid=@tabid;
delimiter;

update ld_tab set printtab=0 where `name` in ('Home','Accounts','Contacts','Webmails','MailManager','Attachment',
'Announcements','SalesGoal','Cache','Users','FieldFormulas','Reminds','Tooltip','ModTracker','ReportLog','Emails',
'MassSMS','MassEmails','SmsPhrases','EmailListtmp','CommunicationLog','Navigation','InventoryLedger','InventoryAccount',
'InventoryQuery','Prdtnums','BankCash','BankAccountSet','Dashboard','OftenUseReport','Comprehensivereport','Reports',
'ModComments','RecycleBin','PriceBooks','Products');
-- end 2014-07-07

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TATIGTTABWTS','金额大于转出账户余额，是否保存?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TATIGTTABWTS' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TATIGTTABWTS','The amount transferred is greater than the account balance, whether to save?','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TATIGTTABWTS' and Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
update ld_field set displaytype = 3 where tabid = @tabid and columnname = 'approvestatus';
delimiter;

insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','PERIODOFSERVICEEND','服务到期日','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='PERIODOFSERVICEEND');
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','PERIODOFSERVICEEND','End Date','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='PERIODOFSERVICEEND');
delimiter;

update ld_users set select_servicedetail = 1,select_due_date = 1;
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
update ld_field set presence = 1 where tabid = @tabid and columnname='servicecontractsid';
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
select tabid into @related_tabid from ld_tab where name = 'ServiceContracts';
update ld_relatedlists set presence = 1 where tabid = @tabid and related_tabid = @related_tabid;
delimiter;


SELECT max(id) into @id from ld_approve;
SELECT tabid into @tabid FROM ld_tab where name='ServiceContracts';
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
SELECT @id+1,@tabid,'服务合同二级审批流程','服务合同预置二级审批流程',0,1,1,NOW(),NOW() from dual where not exists
(select 1 from ld_approve where name='服务合同二级审批流程');
delimiter;

SELECT tabid into @tabid FROM ld_tab where name='ServiceContracts';
SELECT id into @id from ld_approve WHERE name='服务合同二级审批流程' and tabid =@tabid ;
insert into ld_approve2role(approveid,roleid) SELECT @id,'H2' from dual where not exists (select 1 from ld_approve2role where approveid=@id);
delimiter;

SELECT max(id) into @id from ld_approvestep;
SELECT tabid into @tabid FROM ld_tab where name='ServiceContracts';
SELECT id into @approveid from ld_approve WHERE name='服务合同二级审批流程' and tabid =@tabid ;
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
SELECT @id+1,@approveid,'服务合同第一步审批','服务合同第一步审批步骤',1,0,1,NOW(),NOW(),0,1 from dual where not exists 
(select 1 from ld_approvestep where approveid=@approveid and sequence=1);
delimiter;

SELECT max(id) into @id from ld_approvestep;
SELECT tabid into @tabid FROM ld_tab where name='ServiceContracts';
SELECT id into @approveid from ld_approve WHERE name='服务合同二级审批流程' and tabid =@tabid ;
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue)
SELECT @id+1,@approveid,'服务合同第二步审批','服务合同第二步审批步骤',1,0,2,NOW(),NOW(),0,1 from dual where not exists 
(select 1 from ld_approvestep where approveid=@approveid and sequence=2);
delimiter;

update ld_approve_seq set id = (select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id = (select max(id) from ld_approvestep);
delimiter;

UPDATE ld_systems_deploy set  setype='' where deploy_type=10;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,26,'销售机会分配时，是否同时分配相关信息。1:否，0:是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=26);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid =  @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'adjustment','LD_servicecontracts',72,'txtAdjustment','Adjustment',@blockid,3,2,'NN~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'adjustment');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'txtAdjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'调整' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Adjustment' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
update ld_tranlabel set fieldlabel = '负责人' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','GLOBALFIELDSMANAGER','全局字段管理','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='GLOBALFIELDSMANAGER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','GLOBALFIELDSMANAGER','Global Fields Manager','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='GLOBALFIELDSMANAGER' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='只统计已审核的收款单、付款单，已审批通过的提现单、存现单、费用报销单、佣金单' where labelbol='ONLYSTSTISTICSHASBEENCLOSING' and languagetype='zh';
update ld_desk set Fieldlabel='Statistics only includes the checked Payment Bills,Repayment Bills and the approved Deposit,Withdraw,Expenses,Commission! ' where labelbol='ONLYSTSTISTICSHASBEENCLOSING' and languagetype='en';
delimiter;
-- end 2014-07-08

select sequence into @seq from ld_parenttab where parenttab_label='Tools';
update ld_parenttab set sequence=sequence+1 where parenttab_label='Tools';
update ld_parenttab set sequence=@seq where parenttab_label='Marketing';
select 0 into @i;
update ld_parenttab set sequence=(@i:=@i+1) order by sequence;
delimiter;

update ld_field set presence=2,block=77,uitype=19 where tabid=29 and columnname='description';

select tabid into @tabid from ld_tab where name='Users';
select fieldid into @relateid from ld_field where tabid=29 and columnname='description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@relateid,'备注' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@relateid,'Description' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_field');
delimiter;

update ld_cvcolumnlist set columnname='LD_potential:closingdate:closingdate:Potentials_fieldlabel:D' 
where cvid in (select cvid from ld_customview where entitytype='Potentials') and columnname like '%LD_potential:closingdate:closingdate:%';

select tabid into @tabid from ld_tab where name = 'HelpDesk';
select tabid into @related_tabid from ld_tab where name = 'ServiceContracts';
delete from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid;

select cvid into @cvid from ld_customview where entitytype='Products' and viewname='d';
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvcolumnlist where cvid=@cvid;
delimiter;

update ld_field set uitype=7,typeofdata='NN~O~2,2' where tabid=14 and columnname in ('qtyinstock','qtyearly');
delimiter;

drop PROCEDURE if EXISTS modifyproducttoolfield;
delimiter ||
create PROCEDURE modifyproducttoolfield
(
)
begin
	
select columnname into @columndsf from  ld_producttoolfield where fieldlabel='描述';
set @sql=CONCAT('alter table ld_inventoryproductrelscf modify column ',@columndsf,' text');

if @columndsf is not null then
    update ld_producttoolfield set uitype=19,typeofdata='V~O' where fieldlabel='描述';
    prepare stmt from @sql;
    execute stmt;
    deallocate  prepare  stmt;
end if;
end ||
delimiter;

call modifyproducttoolfield();
delimiter;

call fieldprofile('ServiceContracts');
delimiter;

call getallprofile('ServiceContracts');
delimiter;

call addtabintoprofile('ServiceContracts',0);
delimiter;

SELECT usereportid into @usereportid from ld_usereport where name='Contractnumber';
update ld_usereportcolumns set `columns`='LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:V' 
,realcolumns='LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:V',
realencolumns='LD_salesorder:ordernum:ordernum:SalesOrder_Rank:V'
where Usereportid=@usereportid and  `columns`='LD_salesorder:ordernum:ordernum:SalesOrder_ordernum:N' ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UPDATES','修改','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='UPDATES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UPDATES','Update','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UPDATES' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','QTY','数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='QTY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','QTY','Quantity','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='QTY' and Labeltype='fixedstr');
delimiter;
-- end 2014-07-09

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.4.1' ,current_version='V5.4.1' ,remark='V5.4.1-20140709';
delimiter;