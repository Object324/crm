select cvid into @cvid from ld_customview where viewname='mobileContacts' and entitytype='mobileContacts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_contactdetails:lastname:lastname:Contacts_姓名:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_contactdetails:smownerid:assigned_user_id:Contacts_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_contactdetails:accountid:account_id:Contacts_Account_Name:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_contactdetails:mobile:mobile:Contacts_Mobile:V' );
delimiter;

select tabid into @tabid from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,2,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;
-- 2015-09-09

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PERCENTAGEPRICE','百分比降价','fixedstr' from dual   
where not exists(select 1 from ld_desk where labelbol = 'PERCENTAGEPRICE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PERCENTAGEPRICE','Percentage price','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PERCENTAGEPRICE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERNUMBERBETWEEN0AND100','请输入0~100之间数字','jspop' from dual   
where not exists(select 1 from ld_desk where labelbol = 'PLEASEENTERNUMBERBETWEEN0AND100' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERNUMBERBETWEEN0AND100','Please enter a number between 0 and 100','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASEENTERNUMBERBETWEEN0AND100' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_salesorder','discount_type','int','1', 0);
call AddColumn('ld_servicecontracts','discount_type','int','1', 0);
call AddColumn('ld_quotes','discount_type','int','1', 0);
call AddColumn('ld_salesback','discount_type','int','1',0);
call AddColumn('ld_purchaseorder','discount_type','int','1', 0);
call AddColumn('ld_purchaseback','discount_type','int','1', 0);
call AddColumn('ld_outboundorder','discount_type','int','1', 0);
call AddColumn('ld_stock','discount_type','int','1', 0);
call AddColumn('ld_warehousetransfer','discount_type','int','1', 0);
call AddColumn('ld_checks','discount_type','int','1', 0);
call AddColumn('ld_invoice','discount_type','int','1', 0);
call AddColumn('ld_purchaseinvoice','discount_type','int','1', 0);
call AddColumn('ld_cashback','discount_type','int','1', 0);
call AddColumn('ld_purchasecashback','discount_type','int','1', 0);
delimiter;
-- 2015-09-11

alter table ld_singin change distince  distince varchar(50);
alter table ld_activity alter column visibility set default '公共';
UPDATE ld_activity SET visibility='公共' WHERE visibility='all';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVEALLGENERATEDASINGLE','已全部生成出库单，是否继续？','jspop' from dual   
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVEALLGENERATEDASINGLE','Have all generated a single, whether to continue?','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVEALLGENERATEDASINGLES','已全部生成入库单，是否继续？','jspop' from dual   
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLES' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVEALLGENERATEDASINGLES','Have all generated a single, whether to continue?','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLES' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where columnname = 'listprice' and uitype = 26 and tablename = 'ld_products' and tabid = @tabid;
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where columnname = 'taxprice' and uitype = 26 and tablename = 'ld_products' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOQD5D','仅显示符合条件的前5条数据。','fixedstr' from dual   
where not exists(select 1 from ld_desk where labelbol = 'SOQD5D' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOQD5D','Show only qualified before 5 data.','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SOQD5D' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2015-09-14

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select  'en','Applicable personnel','Applicable personnel','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='Applicable personnel' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select  'zh','Applicable personnel','适用人员','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='Applicable personnel' and languagetype='zh');
delimiter

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','TORELEASETHECUSTOMERTOTHEHIGNSEAS','将客户释放到公海未分配','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS' and labeltype = 'fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','TORELEASETHECUSTOMERTOTHEHIGNSEAS','To release the customer to the high seas not allocated','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS' and labeltype = 'fixedstr'); 
delimiter;
update ld_logpublicaccount set operation = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS' where operation = '将客户释放到公海未分配';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','YOUDONOTHAVETHECONTRACTPORDER','您没有编辑权限','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'YOUDONOTHAVETHECONTRACTPORDER' and labeltype = 'jspop'); 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','YOUDONOTHAVETHECONTRACTPORDER','You do not have the permissions to edit the current payment plan','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'YOUDONOTHAVETHECONTRACTPORDER' and labeltype = 'jspop'); 
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_products:productname:productname:InventoryQuery_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_products:productsheet:productsheet:Products_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_products:usageunit:usageunit:Products_计量单位:V' );
delimiter;
-- 2015-09-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','POSTITIONLEVELCANNOTBEEMPTY','职位级别不能为空！','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'POSTITIONLEVELCANNOTBEEMPTY' and labeltype = 'jspop'); 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','POSTITIONLEVELCANNOTBEEMPTY','Position level can not be empty!','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'POSTITIONLEVELCANNOTBEEMPTY' and labeltype = 'jspop'); 
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileSalesOrder' and entitytype='mobileSalesOrder';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_salesorder:accountid:account_id:SalesOrder_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_quotes:quote_no:quote_no:Quotes_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_quotes:accountid:account_id:Quotes_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_quotes:subtotal:hdnSubTotal:Quotes_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_quotes:smownerid:assigned_user_id:Quotes_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_quotes:createdtime:createdtime:Quotes_创建日期:D' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' );
delimiter;


CREATE TABLE IF NOT EXISTS shuowei_dividend (
	id INT (10),
	zqici VARCHAR (200),
	paixi INT (1),
	daydate VARCHAR (200)
) ENGINE = INNODB DEFAULT CHARSET = latin1;

drop TABLE if EXISTS digits; 
CREATE TABLE if not EXISTS digits (digit INT(1)); 
INSERT INTO digits 
VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9); 

drop TABLE if EXISTS sequence; 
CREATE TABLE if not EXISTS sequence (seq INT(3)); 
INSERT INTO sequence ( 
SELECT 
D1.digit + D2.digit * 10+1 
FROM 
digits D1 
CROSS JOIN digits D2 
); 
delimiter;
-- 2015-09-18

select tabid into @tabid from ld_tab where `name` = 'SalesGoal'; 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 1); 
insert into ld_profileallpermission(tabid,operation) 
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 4); 
delimiter;
select tabid into @tabid from ld_tab where `name`= 'PurchaseInvoice';
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where tabid = @tabid and columnname = 'taxprice' and uitype = '27' and defaultcolumn = 2;
delimiter;
-- 2015-09-21

update ld_producttoolfield set tablename='ld_inventoryproductrel' 
where tabid in(select  tabid from ld_tab where name='PurchaseCashBack') and columnname='listprice' and tablename='ld_products';

update ld_producttoolfield set tablename='ld_inventoryproductrel' 
where tabid in(select  tabid from ld_tab where name='PurchaseCashBack') and columnname='taxprice' and tablename='ld_products';
delimiter;

select cvid into @cvid  from ld_customview where viewname='All' and entitytype='Emails';
insert  into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid ,0,'ld_activity:subject:subject:Emails_Subject:V' from DUAL
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname='ld_activity:subject:subject:Emails_Subject:V');

insert  into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid ,1,'ld_emaildetails:to_email:saved_toid:Emails_To:V' from DUAL
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname='ld_emaildetails:to_email:saved_toid:Emails_To:V');

insert  into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid ,2,'ld_activity:date_start:date_start:Emails_Date_Sent:D' from DUAL
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname='ld_activity:date_start:date_start:Emails_Date_Sent:D');
delimiter;


call AddColumn('ld_users','telephone_view','int','10',1);
delimiter;
update ld_users set telephone_view = 1 where telephone_view is NULL;
delimiter;
update ld_field_seq set id =(select max(fieldid) from ld_field);
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_users' and fieldname='telephone_view');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select 29,@id+1,'telephone_view','ld_users',1,56,'telephone_view','是否允许该用户访问通讯录',0,0,'',100,19,77,1,'V~O',3,'','BAS',1,'',0 from dual 
where not exists (select 1 from ld_field where tablename='ld_users' and fieldname='telephone_view');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 29 and columnname = 'telephone_view';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',29,@fieldid,'是否允许该用户访问通讯录'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = 29 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',29,@fieldid,'Address privacy settings'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = 29 and relateid=@fieldid);
delimiter;
-- 2015-09-22

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
delimiter;

update ld_version set old_version='V6.1.3' ,current_version='V6.1.3' ,remark='V6.1.3-20150922';
delimiter;