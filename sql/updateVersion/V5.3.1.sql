insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,34,"订单、报价单、发票、出入库单上是否显示成本和期望GP(毛利率%)",'' 
from dual where not EXISTS(select 1 from ld_systems_deploy  where deploy_type = 34);
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'zh','PRODUCTSETLABEL','{$SalesOrder.SalesOrder}、{$Quotes.Quotes}、{$Invoice.Invoice}、{$Stock.Stock}、{$OutboundOrder.OutboundOrder}、{$PurchaseOrder.PurchaseOrder}上是否显示成本和期望GP(毛利率%)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' and labelbol ='PRODUCTSETLABEL' and Labeltype = 'fixedstr');
 
insert into ld_desk(languagetype,labelbol,Fieldlabel,Labeltype)
select 'en','PRODUCTSETLABEL','Whether to display ‘Expect GP‘ and ‘Cost Price’ on the{$SalesOrder.SalesOrder}、{$Quotes.Quotes}、{$Invoice.Invoice}、{$Stock.Stock}、{$OutboundOrder.OutboundOrder}、{$PurchaseOrder.PurchaseOrder}','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' and labelbol ='PRODUCTSETLABEL' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','DNCNBRIE','Repeat English name display','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DNCNBRIE' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','DNCNBRIE','显示中英文名称重复!','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DNCNBRIE' and Labeltype='jspop');
delimiter;
update ld_desk set fieldlabel='Move Field' where labelbol='MOBILEFIELD' and languagetype='en';
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'zh','TOTALTHIS','本页','fixedstr'
  FROM DUAL
   WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh'
    AND labelbol='TOTALTHIS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'en','TOTALTHIS','This','fixedstr' FROM DUAL
   WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en'
    AND labelbol='TOTALTHIS' AND Labeltype='fixedstr');
    
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'zh','TOTALALL','全部','fixedstr'
  FROM DUAL
   WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh'
    AND labelbol='TOTALALL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'en','TOTALALL','All','fixedstr' FROM DUAL
   WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en'
    AND labelbol='TOTALALL' AND Labeltype='fixedstr');
delimiter;


update ld_systems_deploy set setype = '' where deploy_type = 32;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ENABLEINVENTORYINTERFACE','库存数量接口','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ENABLEINVENTORYINTERFACE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ENABLEINVENTORYINTERFACE','Enable Inventory Interface','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ENABLEINVENTORYINTERFACE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZHANGTAOCHOOSE','账套选择','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ZHANGTAOCHOOSE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZHANGTAOCHOOSE','Zhang Tao Choose','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZHANGTAOCHOOSE' and Labeltype='fixedstr');
delimiter;
call AddColumn('LD_DataInterface','using_inventory','tinyint',1,0);
delimiter;
update ld_desk set Fieldlabel = '选择帐套' where labelbol = 'SELECTZHAOTAO' and languagetype = 'zh';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SELECT','选择','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SELECT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SELECT','Select','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SELECT' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SERVICECHOOSE','服务器选择','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SERVICECHOOSE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SERVICECHOOSE','Service Choose','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICECHOOSE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LOGINNAME','登录名','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LOGINNAME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LOGINNAME','Login name','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LOGINNAME' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DATAINTERFACESTEP6','2.库存数量接口：自动获取接口账套中的库存数量，并更新本系统中对应产品的总库存数量。','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DATAINTERFACESTEP6' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DATAINTERFACESTEP6','2.In the inventory interface: automatic acquisition interface number accounts in the inventory, the total number of inventory and to update the corresponding products in this system.','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DATAINTERFACESTEP6' and Labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel = '2.库存数量接口：自动获取接口账套中的库存数量，并更新本系统中对应产品的总库存数量。'
where languagetype = 'zh' and labelbol = 'DATAINTERFACESTEP2';
update ld_desk set fieldlabel = '2.In the inventory interface: automatic acquisition interface number accounts in the inventory, the total number of inventory and to update the corresponding products in this system.'
where languagetype = 'en' and labelbol = 'DATAINTERFACESTEP2';
delimiter;
update ld_desk set fieldlabel = '3.数据接口为单向接口，即订单接口只能由本系统到接口账套、库存数量接口只能由接口账套到本系统。'
where languagetype = 'zh' and labelbol = 'DATAINTERFACESTEP3';
update ld_desk set fieldlabel = '3.The data interface for the one-way interface, i.e. the order interface only by the system to the interface accounts, inventory number interface only by the interface to the system account.'
where languagetype = 'en' and labelbol = 'DATAINTERFACESTEP3';
delimiter;
update ld_desk set fieldlabel = '4.订单同步过程中，若接口账套中缺少相关的客户或商品时，则自动向接口账套中增加相关信息。'
where languagetype = 'zh' and labelbol = 'DATAINTERFACESTEP4';
update ld_desk set fieldlabel = '4.Order the synchronization process, if the interface account related customers or commodity lack, will automatically increase the relevant information to the interface set of books.'
where languagetype = 'en' and labelbol = 'DATAINTERFACESTEP4';
delimiter;
update ld_desk set fieldlabel = '5.本系统必须和接口软件的数据库账套安装在同一台服务器上，否则无法使用数据接口功能进行数据交换。'
where languagetype = 'zh' and labelbol = 'DATAINTERFACESTEP5';
update ld_desk set fieldlabel = '5.The system must and interface software database account set installed on the same server, or can not use the data interface for data exchange.'
where languagetype = 'en' and labelbol = 'DATAINTERFACESTEP5';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SYNCHRONOUSINVENTORY','同步库存','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SYNCHRONOUSINVENTORY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SYNCHRONOUSINVENTORY','Synchronous inventory','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SYNCHRONOUSINVENTORY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DATAEXCHANGE','数据交换','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DATAEXCHANGE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DATAEXCHANGE','Data exchange','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DATAEXCHANGE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SYNCHRONOUSINVENTORYNOTE','说明：获取接口帐套中产品库存数量，并以“产品编号”为唯一判断标准，更新到本系统中。','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SYNCHRONOUSINVENTORYNOTE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SYNCHRONOUSINVENTORYNOTE','Note: number of product inventory account access interface, and to "the product number" as the sole criterion, update the system.','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SYNCHRONOUSINVENTORYNOTE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SYNCHRONOUSINVENTORYNOTEONE','只更新本系统产品库存数量','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SYNCHRONOUSINVENTORYNOTEONE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SYNCHRONOUSINVENTORYNOTEONE','Just to update the system product inventory number','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SYNCHRONOUSINVENTORYNOTEONE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SYNCHRONOUSINVENTORYNOTETWO','更新本系统产品库存数量，并导入新产品','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SYNCHRONOUSINVENTORYNOTETWO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SYNCHRONOUSINVENTORYNOTETWO','Update the system product inventory, and new product introduction','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SYNCHRONOUSINVENTORYNOTETWO' and Labeltype='fixedstr');
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT id INTO @relatedid FROM ld_relatedlists_seq;
UPDATE ld_relatedlists_seq SET id = @relatedid+1 WHERE 1;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions)
SELECT @relatedid+1,@tabid,@tabid,'get_balanceofaccount',1,"BalanceOfAccount",0,''
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='get_balanceofaccount');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'zh','BALANCEOFACCOUNT','往来对账','fixedstr'
  FROM DUAL
   WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh'
    AND labelbol='BALANCEOFACCOUNT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'en','BALANCEOFACCOUNT','balance of account','fixedstr'
  FROM DUAL
   WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en'
    AND labelbol='BALANCEOFACCOUNT' AND Labeltype='fixedstr');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'SendCashBill',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='SendCashBill');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'PutCash',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='PutCash');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'ServiceContracts',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='ServiceContracts');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'CashDeposit',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='CashDeposit');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'Expense',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Expense');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'Invoice',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Invoice');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'PurchaseOrder',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='PurchaseOrder');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'PaymentPlan',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='PaymentPlan');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'Campaigns',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Campaigns');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'SendPayment',0,''  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='SendPayment');
delimiter;



select usereportid into @id from LD_usereport where name='SalesOrderTrack';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'lD_expense:approvestatus:approvestatus:Expense_approvestatus:I','',4  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;

UPDATE ld_usereportbasic SET columns='t12:accountname:account_id:SalesOrder_account_id:I' WHERE columns='t4:accountname:account_id:SalesOrder_account_id:I';
UPDATE ld_usereportbasic SET columns='LD_accountSalesOrder:accountname:account_id:Potentials_account_id:I' WHERE columns='t4:accountname:account_id:Potentials_account_id:I';
delimiter;

select usereportid into @id from LD_usereport where name='CourseEnquiryReport';
SELECT tabid into @tid from LD_tab where name='SalesOrder';

insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','Contactbusinesstable','联系人业务表',@tid,1,1,0,@id,13,2,100 
from dual where not exists(select 1 from LD_usereport where name='Contactbusinesstable');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Contactbusinesstable','联系人业务表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Contactbusinesstable' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Contactbusinesstable','Contact the business table','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Contactbusinesstable' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='Contactbusinesstable';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_SalesOrder:duedate:duedate:SalesOrder_duedate:D','thisstartmonth~thisendmonth',1  
from dual where not exists(select 1 from LD_usereportbasic where Usereportid=@id and Sequence=1);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'t12:accountname:account_id:SalesOrder_account_id:I','',2  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=2);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_contactdetails:lastname:lastname:Contacts_lastname:I','',3  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

select usereportid into @id from LD_usereport where name='Contactbusinesstable';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:lastname:lastname:contactdetails_lastname:V', 1, 1, 'LD_contactdetails:lastname:lastname:contactdetails_联系人:V','LD_contactdetails:lastname:lastname:contactdetails_联系人:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_contactdetails:lastname:lastname:contactdetails_联系人:V');

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
select '', @id, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_salesordertotal:N', 9, 1, 'LD_salesorder:salesordertotal:salesordertotal:salesorder_合同总计:N','LD_salesorder:salesordertotal:salesordertotal:salesorder_合同总计:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesordertotal:salesordertotal:salesorder_合同总计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_expense:total:total:expense_total:N', 10, 1, 'ld_expense:total:total:expense_佣金:N','LD_salesorder:total:total:expense_佣金:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='ld_expense:total:total:expense_佣金:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:CashBillBalance:CashBillBalance:salesorder_CashBillBalance:N', 11, 1, 'LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:N','LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:CashBillBalance:CashBillBalance:salesorder_已收款项:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_PaymentBalance:N', 12, 1, 'LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款项:N','LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款项:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:PaymentBalance:PaymentBalance:salesorder_应收款项:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_count:salesorder_count:salesorder_salesorder_count:N', 13, 1, 'LD_salesorder:salesorder_count:salesorder_count:salesorder_学员人数:N','LD_salesorder:salesorder_count:salesorder_count:salesorder_学员人数:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_count:salesorder_count:salesorder_学员人数:N');
delimiter;

SELECT tabid into @id FROM ld_tab WHERE name='SalesOrder';
UPDATE ld_usereport SET tabids=@id WHERE name='OverallCommencementSchedule';
delimiter;


select max(sequence) into @sequence from ld_usereport where parent_id=0;
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','AttendanceReport','考勤报表',0,0,0,0,0,@sequene+1,50,100 
from dual where not exists(select usereportid from LD_usereport where name='AttendanceReport');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AttendanceReport','Attendance Report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AttendanceReport' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AttendanceReport','考勤报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AttendanceReport' and Labeltype='fixedstr');

select usereportid into @usereportid from ld_usereport where name='AttendanceReport';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','SIGNINSTATISTICS','签到统计表',0,1,0,1,@usereportid,1,50,100 
from dual where not exists(select usereportid from LD_usereport where name='SIGNINSTATISTICS');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SIGNINSTATISTICS','Sign in statistics','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SIGNINSTATISTICS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SIGNINSTATISTICS','签到统计表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SIGNINSTATISTICS' and Labeltype='fixedstr');


select usereportid into @id from LD_usereport where name='SIGNINSTATISTICS';
insert into LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select  @id, 'LD_users:last_name:last_name:OftenUseReport_职员:V', 1, 1, 'LD_users:last_name:last_name:OftenUseReport_职员:V','LD_users:last_name:last_name:OftenUseReport_lastname:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and columns='LD_users:last_name:last_name:OftenUseReport_职员:V');

insert into LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select  @id, 'LD_singin:createdtime:signedtime:OftenUseReport_签到时间:D', 3, 1, 'LD_singin:createdtime:signedtime:OftenUseReport_签到时间:D','LD_singin:createdtime:signedtime:OftenUseReport_Sign in time:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and columns='LD_singin:createdtime:signedtime:OftenUseReport_签到时间:D');

insert into LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select  @id, 'LD_singin:address:address:OftenUseReport_签到地址:V', 6, 1, 'LD_singin:address:address:OftenUseReport_签到地址:V','LD_singin:address:address:OftenUseReport_Sing in address:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and columns='LD_singin:address:address:OftenUseReport_签到地址:V');

insert into LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select  @id, 'LD_accounts:accountname:accountname:OftenUseReport_签到客户:V', 9, 1, 'LD_accounts:accountname:accountname:OftenUseReport_签到客户:V','LD_accounts:accountname:accountname:OftenUseReport_Sing in customer:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and columns='LD_accounts:accountname:accountname:OftenUseReport_签到客户:V');

insert into LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select  @id, 'LD_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V', 12, 1, 'LD_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V','LD_accounts:bill_street:bill_street:OftenUseReport_Related to customer address:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and columns='LD_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V');


select usereportid into @id from LD_usereport where name='SIGNINSTATISTICS';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_singin:createdtime:signedtime:Singin_CreatedTime:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_account:accountname:accountname:Accounts_accountname:I','',4  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;

CREATE TABLE if not exists `ld_singin` (
  `id` int(19) NOT NULL auto_increment,
  `content` varchar(200) default NULL,
  `createdtime` datetime default NULL,
  `userid` int(19) default NULL,
  `longtitude` varchar(50) default NULL,
  `latitude` varchar(50) default NULL,
  `address` varchar(200) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_userid_singin` USING BTREE (`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

delete from  ld_relatedlists_lable where tabid=10;
select fieldid into @fieldid from ld_field where tabid=10 and columnname='from_email';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 10,@fieldid,0,1,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=10 and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=10 and columnname='subject';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 10,@fieldid,0,2,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=10 and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=10 and columnname='date_start';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 10,@fieldid,0,3,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=10 and fieldid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=10 and columnname='to_email';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select 10,@fieldid,0,4,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where tabid=10 and fieldid=@fieldid);
delimiter;

update ld_tabwithproductview set columns = 'LD_inventoryproductrel:remark:products_remark:Products_fieldlabel:V' 
where columns = 'LD_inventoryproductrel:remark:remark:Products_fieldlabel:V';
DELIMITER;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','Quotes',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Quotes');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','VendorContact',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='VendorContact');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','Products',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Products');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','CashBack',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='CashBack');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','CashBill',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='CashBill');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','BankAccountSet',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='BankAccountSet');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','VendorContactRecords',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='VendorContactRecords');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','OutboundOrder',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='OutboundOrder');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','Stock',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='Stock');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','SalesBack',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='SalesBack');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','PriceBooks',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='PriceBooks');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','PutCash',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='PutCash');
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds','CashDeposit',0,''  
from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='CashDeposit');
delimiter;

update ld_relatedlists set sequence=sequence+1 where tabid=6;
update ld_relatedlists set sequence=0 where tabid=6 and name='get_balanceofaccount';
SELECT @i:=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=6 order by sequence; 
delimiter;

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);

update ld_version set old_version='V5.3.1' ,current_version='V5.3.1' ,remark='V5.3.1-20140611';
delimiter;