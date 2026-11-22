select cvid into @cvid from ld_customview where entitytype='VendorContact' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist
select @cvid,0,'LD_vendorcontacts:lastname:lastname:VendorContact_姓名:V';

insert into ld_cvcolumnlist
select @cvid,1,'LD_vendorcontacts:vendorid:vendor_id:VendorContact_供应商名称:V';

insert into ld_cvcolumnlist
select @cvid,2,'LD_vendorcontacts:title:title:VendorContact_职位:V';

insert into ld_cvcolumnlist
select @cvid,3,'LD_vendorcontacts:officephone:officephone:VendorContact_办公电话:V';

insert into ld_cvcolumnlist
select @cvid,4,'LD_vendorcontacts:mobile:mobile:VendorContact_手机:V';

insert into ld_cvcolumnlist
select @cvid,5,'LD_vendorcontacts:fax:fax:VendorContact_传真:V';

insert into ld_cvcolumnlist
select @cvid,6,'LD_vendorcontacts:email:email:VendorContact_Email:V';

insert into ld_cvcolumnlist
select @cvid,7,'LD_vendorcontacts:birthday:birthday:VendorContact_Birthdate:D';

insert into ld_cvcolumnlist
select @cvid,8,'LD_crmentity:smownerid:assigned_user_id:VendorContact_采购负责人:V';
delimiter;

delete from ld_quickactions where tabid=22 and related_tabid in (22,9);

UPDATE ld_quickactions set related_tabid=16 where related_tabid=9;
delimiter;

SELECT tabid into @tabid from ld_tab where name='SalesOrder';
DELETE from ld_quickactions where tabid=@tabid and related_tabid=@tabid;
delimiter;

SELECT tabid into @tabid  FROM ld_tab where name='SalesBack';
SELECT tabid into @tabid2  FROM ld_tab where name='CashBack';
UPDATE ld_quickactions set related_tabid=@tabid2 WHERE tabid=@tabid and related_tabid=@tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OLDPASSWORD','旧密码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='OLDPASSWORD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OLDPASSWORD','Old Password','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OLDPASSWORD' and Labeltype='fixedstr');
delimiter;

ALTER TABLE ld_bankaccountset MODIFY COLUMN bankNum int(19) default 0;
delimiter;
call AddColumn('ld_smssend','lossreason','varchar',100,null);
delimiter;

select tabid into @tabid from ld_tab where name='CommunicationLog';
update ld_tranlabel set fieldlabel='短信历史记录' where trantable='LD_tab' and tabid=@tabid and relateid=@tabid and languagetype='zh';
update ld_tranlabel set fieldlabel='Message history' where trantable='LD_tab' and tabid=@tabid and relateid=@tabid and languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @CommunicationLogid from ld_tab where name = 'CommunicationLog';
select sequence into @sequence from ld_relatedlists where tabid =@tabid and label = 'Emails';
SELECT max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @relation_id+1,@tabid,@CommunicationLogid,'get_communicationLog',@sequence,'CommunicationLog','' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@CommunicationLogid);
UPDATE ld_relatedlists set sequence=sequence+2 where sequence >@sequence and tabid=@tabid;
UPDATE ld_relatedlists set sequence=sequence+1 where sequence=@sequence and tabid=@tabid and label = 'Emails';
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @CommunicationLogid from ld_tab where name = 'CommunicationLog';
select sequence into @sequence from ld_relatedlists where tabid =@tabid and label = 'Emails';
SELECT max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @relation_id+1,@tabid,@CommunicationLogid,'get_communicationLog',@sequence,'CommunicationLog','' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@CommunicationLogid);
UPDATE ld_relatedlists set sequence=sequence+2 where sequence >@sequence and tabid=@tabid;
UPDATE ld_relatedlists set sequence=sequence+1 where sequence=@sequence and tabid=@tabid and label = 'Emails';
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

SELECT tabid into @tabid from ld_tab where name='Campaigns';
DELETE from ld_relatedlists where tabid=@tabid and label='Leads' and name='get_leads';
DELETE from ld_relatedlists where name='get_related_list' and label='Services';
delimiter;
UPDATE ld_quickactions set related_tabid=16 where related_tabid=9;
delimiter;
SELECT tabid into @tabid from ld_tab where name='SalesOrder';
DELETE from ld_quickactions where tabid=@tabid and related_tabid=@tabid;
delimiter;

SELECT tabid into @tabid  FROM ld_tab where name='SalesBack';
SELECT tabid into @tabid2  FROM ld_tab where name='CashBack';
UPDATE ld_quickactions set related_tabid=@tabid2 WHERE tabid=@tabid and related_tabid=@tabid;
delimiter;
UPDATE ld_tab set printtab=1 ;
delimiter;
/*andy end*/

-- begin:add 2014-06-26 by luyx bug:9655
select 6 into @tabid;
select sequence into @seq from ld_relatedlists where tabid=@tabid and label='Emails';
update ld_relatedlists set sequence=sequence+2 where tabid=@tabid and sequence>@seq;
update ld_relatedlists set sequence=@seq+1 where tabid=@tabid and label='CommunicationLog';
select @i:=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence; 
delimiter;

select 4 into @tabid;
select sequence into @seq from ld_relatedlists where tabid=@tabid and label='Emails';
update ld_relatedlists set sequence=sequence+2 where tabid=@tabid and sequence>@seq;
update ld_relatedlists set sequence=@seq+1 where tabid=@tabid and label='CommunicationLog';
select @i:=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence; 
delimiter;

update ld_field set uitype=15 where tabid=6 and columnname in ('bill_city','bill_state','bill_country');

select tabid into @tabid from ld_tab where `name`='SalesBack';
update ld_tranlabel set fieldlabel='SalesBack Order' where trantable='LD_tab' and Relateid=@tabid and languagetype='en';
delimiter;

update ld_desk set Fieldlabel='管理货币与换算率' where labelbol='LBL_CURRENCY_DESCRIPTION' and languagetype='zh';
update ld_desk set Fieldlabel='换算率' where labelbol='CONVERSIONRATE' and languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SENDSTATESMS','发送状态','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SENDSTATESMS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SENDSTATESMS','Send state','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SENDSTATESMS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'Commission';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual 
where not exists(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
delimiter;

select tabid into @tabid from ld_tab where name = 'Commission';
select tabid into @tabid2 from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not exists(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Commission';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual 
where not exists(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;


select tabid into @tabid from ld_tab where name='Commission';
select tabid into @relatedtabid from ld_tab where name='Attachment';
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_attachment',2,'attachment',1,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_attachment' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ADREPORT','爱安德报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ADREPORT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ADREPORT','A&D Report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADREPORT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Drilldownreports','明细表','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Drilldownreports' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Drilldownreports','Drilldown reports','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Drilldownreports' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Summaryreports','汇总表','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Summaryreports' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Summaryreports','Summary reports','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Summaryreports' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','nYear','年','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='nYear' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','nYear','Year','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='nYear' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','nMonth','月','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='nMonth' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','nMonth','Month','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='nMonth' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','nMonth','月','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='nMonth' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','nMonth','Month','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='nMonth' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OrderNO','订单号','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OrderNO' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OrderNO','Order NO','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OrderNO' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Costp','成本','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Costp' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Costp','Cost','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Costp' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEINITIALQUERYCANNOTBEEMPTY','查询期初不能为空!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THEINITIALQUERYCANNOTBEEMPTY' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEINITIALQUERYCANNOTBEEMPTY','Opening a query cannot be empty!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEINITIALQUERYCANNOTBEEMPTY' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Salesman','业务员','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Salesman' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Salesman','Salesman','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Salesman' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Sector','部门','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Sector' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Sector','Sector','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Sector' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Rebates','返点','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Rebates' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Rebates','Rebates','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Rebates' and Labeltype='fixedstr');
delimiter;


delete from ld_relatedlists where name = 'get_schedule' and label = 'Calendar' ORDER BY sequence;
delimiter;
select fieldid into @fieldid from ld_field where tabid = 13 and columnname = 'salesorderid';
update LD_profile2field set readonly = 0 where tabid = 13 and fieldid = @fieldid;
delimiter;
select fieldid into @fieldid from ld_field where tabid = 13 and columnname = 'servicecontractsid';
update LD_profile2field set readonly = 0 where tabid = 13 and fieldid = @fieldid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'salesorderid';
update LD_profile2field set readonly = 0 where tabid = @tabid and fieldid = @fieldid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'troubleticketid';
update LD_profile2field set readonly = 0 where tabid = @tabid and fieldid = @fieldid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMISSIONAMOUNT','佣金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMISSIONAMOUNT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMISSIONAMOUNT','Commission Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMISSIONAMOUNT' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
select fieldid into @fieldid  from ld_field where tabid = @tabid and uitype = 200;
select count(1) into @cnt from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delete from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and @cnt > 1;
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'合同订单' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype='zh' and tabid=@tabid and Relateid=@fieldid) and  @cnt < 1;
select count(1) into @cnt from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'en';
delete from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and @cnt > 1;
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'SalesOrder' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype='en' and tabid=@tabid and Relateid=@fieldid) and @cnt < 1;
delimiter;

select tabid into @tabid from ld_tab where name = 'SendCashBill';
select fieldid into @fieldid  from ld_field where tabid = @tabid and uitype = 201;
select count(1) into @cnt from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delete from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and @cnt > 1;
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购订单' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype='zh' and tabid=@tabid and Relateid=@fieldid) and  @cnt < 1;
select count(1) into @cnt from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'en';
delete from ld_tranlabel where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and @cnt > 1;
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PurchaseOrder' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype='en' and tabid=@tabid and Relateid=@fieldid) and @cnt < 1;
delimiter;

update ld_field set presence = 2 where columnname in('subject','salesorderid') and tablename='LD_servicecontracts';
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
update ld_entityname set fieldname = 'contract_no' where tabid = @tabid;
delimiter;

update ld_field set presence = 1 where columnname in('start_date','end_date') and tablename='LD_servicecontracts';
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid =  @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'total','LD_servicecontracts',72,'hdnGrandTotal','Total',@blockid,3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'subtotal','LD_servicecontracts',72,'hdnSubTotal','Sub Total',@blockid,3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'taxtype','LD_servicecontracts',16,'hdnTaxType','Tax Type',@blockid,3,2,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_percent','LD_servicecontracts',1,'hdnDiscountPercent','Discount Percent',@blockid,3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'discount_amount','LD_servicecontracts',72,'hdnDiscountAmount','Discount Amount',@blockid,3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'s_h_amount','LD_servicecontracts',72,'hdnS_H_Amount','运费和物流附加费',@blockid,3,2,'N~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 's_h_amount');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;

call AddColumn('LD_servicecontracts','total','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN total decimal(25,2) default 0.00;
call AddColumn('LD_servicecontracts','subtotal','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN subtotal decimal(25,2) default 0.00;
call AddColumn('LD_servicecontracts','taxtype','varchar',25,null);
call AddColumn('LD_servicecontracts','discount_percent','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN discount_percent decimal(25,2) default 0.00;
call AddColumn('LD_servicecontracts','discount_amount','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN discount_amount decimal(25,2) default 0.00;
call AddColumn('LD_servicecontracts','s_h_amount','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN s_h_amount decimal(25,2) default 0.00;
call AddColumn('LD_servicecontracts','currency_id','int',19,0);
call AddColumn('LD_servicecontracts','conversion_rate','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN conversion_rate decimal(25,3) default 0.00;
call AddColumn('LD_servicecontracts','adjustment','int',19,0);
ALTER TABLE LD_servicecontracts MODIFY COLUMN adjustment decimal(25,2) default 0.00;

call AddColumn('LD_inventoryproductrel','servicecontracts_start_date','date','',0);
call AddColumn('LD_inventoryproductrel','servicecontracts_end_date','date','',0);

call AddColumn('LD_servicecontracts','approvestatus','varchar','200',null);
Alter table LD_servicecontracts alter column approvestatus set default '未提交';
call AddColumn('LD_servicecontracts','approveby','int',1,null);

SELECT tabid into @tabid FROM ld_tab where name='ServiceContracts';
SELECT blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
select id into @id from ld_field_seq;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approvestatus','LD_servicecontracts',1,130,'approvestatus','Approvestatus',1,2,'',100,19,@blockid,2,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_servicecontracts' and fieldname='approvestatus');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;
SELECT tabid into @tabid FROM ld_tab where name='ServiceContracts';
SELECT blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
select id into @id from ld_field_seq;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approveby','LD_servicecontracts',1,131,'approveby','Approveby',1,2,'',100,19,@blockid,2,'V~O',3,'','BAS',1,'',0 from dual where not exists (select 1 from ld_field where tablename='LD_servicecontracts' and fieldname='approveby');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'Approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='审批状态');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Approve Status');
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'Approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='审批人');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Approver');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,47,'服务合同是否启用审批流程。1:否，0:是','ServiceContracts' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=47);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
delete from ld_tabwithproductview where tabid=@tabid and cvid=0;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_servicecontracts:subject:subject:ServiceContracts_主题:V',0,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V',1,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:V',2,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_servicecontracts:contract_type:contract_type:ServiceContracts_fieldlabel:V',3,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_servicecontracts:contract_status:contract_status:ServiceContracts_fieldlabel:V',4,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_servicecontracts:total:hdnGrandTotal:ServiceContracts_fieldlabel:V',5,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_crmentity:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V',6,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_products:productname:productname:Products_fieldlabel:V',7,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',8,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_products:productcode:productcode:Products_fieldlabel:V',9,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_products:productsheet:productsheet:Products_fieldlabel:V',10,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_inventoryproductrel:servicecontracts_start_date:servicecontracts_start_date:Products_fieldlabel:N',11,0;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select  @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:N',12,0;
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnGrandTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'合计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Total' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'小计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Sub Total' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnTaxType';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'税种' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Tax Type' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountPercent';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣百分比' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Percent' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnDiscountAmount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'折扣直接降价' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Discount Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hdnS_H_Amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'运费和物流附加费' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'S&H Amount' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
update ld_field set fieldname = 'hdnSubTotal' where fieldname = 'hdnSubTotall';
delimiter;


select tabid into @tabid from ld_tab where name = 'Commission';
update ld_relatedlists set label = 'Attachment' where tabid = @tabid and label = 'attachment';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Amountexceedstheaccountbalance','金额超出账号余额','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Amountexceedstheaccountbalance' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Amountexceedstheaccountbalance','Amount exceeds the account balance','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Amountexceedstheaccountbalance' and Labeltype='jspop');

delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ROLES','角色','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ROLES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ROLES','Roles','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ROLES' and Labeltype='fixedstr');
delimiter;

SELECT tabid into @tabid FROM ld_tab WHERE name='PutCash';

UPDATE ld_field SET typeofdata='N~O' WHERE tabid=@tabid and fieldname='cashmoney';
delimiter;
SELECT tabid into @tabid FROM ld_tab WHERE name='CashDeposit';

UPDATE ld_field SET typeofdata='N~O' WHERE tabid=@tabid and fieldname='cashmoney';
delimiter;

update ld_tranlabel set fieldlabel='公司Email' where trantable='LD_field' and languagetype='zh' and Relateid=9;
update ld_field set uitype=15 where columnname in ('bill_city','bill_state','bill_country') and tabid in (2,6,18);

select 2 into @tabid;
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='potentialname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='accountid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='contactid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='sales_stage' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='leadsource' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=7 where columnname='amount' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=8 where columnname='closingdate' and tabid=@tabid;

select 4 into @tabid;
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='lastname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='firstname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='mobile' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='email' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='accountid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='smownerid' and tabid=@tabid;

select 6 into @tabid;
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='accountname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='phone' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='email1' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='rating' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='leadsource' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='ContactRecords';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='subject' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='contactrecordtype' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='contactdate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='content' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='ServiceContracts';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='HelpDesk';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Quotes';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='SalesBack';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Vendors';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='vendorname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='glacct' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='phone' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='email' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='VendorContact';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='lastname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='firstname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='mobile' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='officephone' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='email' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='smownerid' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='VendorContactRecords';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='subject' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='contactrecordtype' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='contactdate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='description' and tabid=@tabid;

select 48 into @tabid;
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='projectname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='accountid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='contactid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='salesorderid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6,defaultvalue=NULL where columnname='projectstatus' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=7 where columnname='startdate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=8 where columnname='targetenddate' and tabid=@tabid;

select 47 into @tabid;
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='projecttaskname' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='accountid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='contactid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='projectid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='projecttasktype' and tabid=@tabid;

select 46 into @tabid;
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='projectmilestonename' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='projectid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='projectmilestonedate' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='Invoice';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='CashBill';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='SendCashBill';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='CashBack';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='PaymentPlan';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='accountid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='salesorderid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='periodtime' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='plandate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='amount' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='SendPayment';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='vendorid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='purchaseorder_id' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='cpperiodtime' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='plandate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='amount' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='Expense';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Commission';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='PutCash';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='putcashdate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='cashmoney' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='outaccount' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='inaccount' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='billnumber' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='smownerid' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='CashDeposit';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='cashdepositdate' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='cashmoney' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='inaccount' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='outaccount' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='billnumber' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='smownerid' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='BankAccountSet';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='OutboundOrder';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Stock';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Checks';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='InventoryAccount';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='InventoryQuery';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='ModComments';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='PriceBooks';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Events';
update ld_field set quickcreate=1 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where columnname='subject' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=2 where columnname='smownerid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=3 where columnname='date_start' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=4 where columnname='due_date' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=5 where columnname='activitytype' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=6 where columnname='eventstatus' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=7 where columnname='accountid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=8 where columnname='contactid' and tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=8 where columnname='description' and tabid=@tabid;

select tabid into @tabid from ld_tab where name='Calendar';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Documents';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Attachment';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Faq';
update ld_field set quickcreate=3 where tabid=@tabid;

select tabid into @tabid from ld_tab where name='Campaigns';
update ld_field set quickcreate=3 where tabid=@tabid;
-- End: 2014-07-01 by luyx 

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.3.4' ,current_version='V5.3.4' ,remark='V5.3.4-20140701';
delimiter;