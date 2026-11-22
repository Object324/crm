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

UPDATE ld_tranlabel SET fieldlabel='关键决策人是谁（who）' 
WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') 
AND Relateid=(SELECT fieldid FROM ld_field WHERE tabid=2 AND columnname='5w2p_why2') 
AND languagetype='zh' AND trantable='ld_field';
delimiter;

SELECT max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence) 
select 1,82,'单据分录中调用产品资料时是否显示无效的产品。0:否，1:是','',@sequence+1 
from dual where not exists(select 1 from ld_systems_deploy where description='单据分录中调用产品资料时是否显示无效的产品。0:否，1:是');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','AllowedSelectProductsOrdersOtherModuleProducts','单据分录中调用产品资料时是否显示无效的产品','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='AllowedSelectProductsOrdersOtherModuleProducts' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','AllowedSelectProductsOrdersOtherModuleProducts','Is allowed to select invalid products in orders, invoices and other module products list','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='AllowedSelectProductsOrdersOtherModuleProducts' and languagetype='en');
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 25,'ChangeCreator','CHANGECREATED',0 from dual 
where not EXISTS(select 1 from ld_actionmapping  where actionid = 25);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHANGECREATED','更改创建人','jspop'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHANGECREATED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHANGECREATED','Change Creator','jspop'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHANGECREATED' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHANGECREATED','更改创建人','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHANGECREATED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHANGECREATED','Change Creator','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHANGECREATED' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Calendar';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Documents';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesBack';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectMilestone';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBack';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PutCash';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashDeposit';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankAccountSet';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContact';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileAccounts' and entitytype='mobileAccounts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_account:accountname:accountname:Accounts_客户名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_account:rating:rating:Accounts_客户状态:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_account:createdtime:createdtime:Accounts_创建时间:D' );
delimiter;
-- 2015-10-09

update ld_field set searchfieldtype=0  where columnname in('subject','accountid','sostatus','signed_data','smownerid','total','salesorder_no') and tabid=22;
update ld_field set searchfieldtype=0  where columnname in('subject','accountid','contract_status','due_date','smownerid','total','contract_no') and tabid=37;
delimiter;

select cvid into @cvid   from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_products:productname:productname:InventoryQuery_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_products:usageunit:usageunit:Products_计量单位:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_products:productsheet:productsheet:Products_fieldlabel:V' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','sales_stage','销售阶段','jspop' from dual where not exists(select 1 from ld_desk where labelbol='sales_stage' and languagetype='zh' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','sales_stage','SalesStage','jspop' from dual where not exists(select 1 from ld_desk where labelbol='sales_stage' and languagetype='en' and labeltype='jspop');
delimiter;
call AddColumn('ld_relatedlists','mobile_presence','int','10',NULL);
call AddColumn('ld_relatedlists','mobile_sequence','int','10',0);

update ld_relatedlists set mobile_sequence = sequence where mobile_sequence = 0;
delimiter;
update ld_relatedlists set mobile_presence = 1 where mobile_presence is NULL;
delimiter;
update ld_relatedlists LEFT JOIN ld_tab on ld_tab.tabid = ld_relatedlists.tabid set ld_relatedlists.mobile_presence = 0
where ld_tab.`name` in ('Accounts','Contacts','ContactRecords','SalesOrder','Potentials','Quotes','ServiceContracts','HelpDesk','Campaigns','Products','PublicAnnouncement')
and ld_relatedlists.label in ('Accounts','Contacts','ContactRecords','SalesOrder','Potentials','Quotes','ServiceContracts','HelpDesk','Campaigns','Products','PublicAnnouncement');
delimiter;
-- 2015-10-13

update ld_desk set fieldlabel = '该区块下还有字段，请将字段移动到其他区块再进行删除!' 
where labelbol = 'PLEASEMOVEFIELDTOOTERBLACKS' and Labeltype = 'jspop' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = 'Under the block data information, please move the data information to other blocks under the delete!' 
where labelbol = 'PLEASEMOVEFIELDTOOTERBLACKS' and Labeltype = 'jspop' and languagetype = 'en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
update ld_field set presence = 1 where tabid = @tabid and columnname = 'first_name';
delimiter;

SELECT usereportid into @id from ld_usereport where name='SalesReport';
SELECT tabid into @tid from ld_tab where name='CashBill';
insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','Reportingpaymentschedulestatistics','应收款统计表—按申报及款项进度统计',@tid,1,0,1,@id,12,5,100 
from dual where not exists(select usereportid from ld_usereport where name='Reportingpaymentschedulestatistics');
delimiter;

select usereportid into @id from ld_usereport where name='Reportingpaymentschedulestatistics';
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_potentialscf:cf_1100:cf_1100:CashBill_cf_1100:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=3);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_projectcf:cf_1751:cf_1751:Project_cf_1751:I','',4  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=4);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_project:projectstatus:projectstatus:Project_projectstatus:I','',5  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=5);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_project:cf_1783:cf_1783:Project_cf_1783:I','',6  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Reportingpaymentschedulestatistics',
'应收款统计表—按申报及款项进度统计','fixedstr' from dual where not EXISTS(select 1 from ld_desk 
where languagetype='zh' and labelbol='Reportingpaymentschedulestatistics' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Reportingpaymentschedulestatistics',
'Reporting and payment schedule by statistics','fixedstr' from dual where not EXISTS(select 1 from ld_desk  
where languagetype='en' and labelbol='Reportingpaymentschedulestatistics' and Labeltype='fixedstr');

/*添加显示列名称*/
select usereportid into @id from ld_usereport where name='Reportingpaymentschedulestatistics';

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_account:accountname:accountname:Accounts_accountname:V', 1, 1, 'ld_account:accountname:accountname:Accounts_客户名称:V',
'ld_account:accountname:accountname:Accounts_account name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_account:accountname:accountname:Account_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:subject:subject:SalesOrder_subject:V', 2, 1, 'ld_salesorder:subject:subject:SalesOrder_项目类型:V',
'ld_salesorder:subject:subject:SalesOrder_subject:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:subject:subject:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_products:productname:productname:Products_productname:V', 3, 1, 'ld_products:productname:productname:Products_产品名称:V',
'ld_products:productname:productname:Products_products name:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_products:productname:productname:Products_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_potential:potentialname:potentialname:Potentials_potentialname:V', 4, 1, 'ld_potential:potentialname:potentialname:Potentials_合同编号:V',
'ld_potential:potentialname:potentialname:Potentials_order no:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_potential:potentialname:potentialname:Potentials_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', 5, 1, 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_项目信息编号:V',
'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_order no:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:project_no:project_no:Project_project_no:V', 6, 1, 'ld_salesorder:project_no:project_no:Project_项目申报编号:V',
'ld_salesorder:project_no:project_no:Project_project no:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:project_no:project_no:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1751:cf_1751:Project_cf_1751:V', 7, 1, 'ld_projectcf:cf_1751:cf_1751:Project_重报项目编号:V',
'ld_projectcf:cf_1751:cf_1751:Project_new project no:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_projectcf:cf_1751:cf_1751:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'potential_users:businessmanager:businessmanager:OftenUseReport_businessmanager:V', 8, 1, 'potential_users:businessmanager:businessmanager:OftenUseReport_业务经理:V',
'potential_users:businessmanager:businessmanager:OftenUseReport_business manager:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
columns = 'potential_users:businessmanager:businessmanager:OftenUseReport_businessmanager:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_potential:cf_1726:cf_1726:Potentials_cf_1726:V', 9, 1, 'ld_potential:cf_1726:cf_1726:Potentials_合作签单人:V',
'ld_potential:cf_1726:cf_1726:Potentials_Co-signing people:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_potential:cf_1726:cf_1726:Potentials_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesordercf:cf_1772:cf_1772:SalesOrder_cf_1772:D', 10, 1, 'ld_salesordercf:cf_1772:cf_1772:SalesOrder_项目预申报时间:D',
'ld_salesordercf:cf_1772:cf_1772:SalesOrder_Project pre-declaration time:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesordercf:cf_1772:cf_1772:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_977:cf_977:Project_cf_977:D', 11, 1, 'ld_projectcf:cf_977:cf_977:Project_计划申报时间:D',
'ld_projectcf:cf_977:cf_977:Project_Program reporting time:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_projectcf:cf_977:cf_977:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1750:cf_1750:Project_cf_1750:V', 12, 1, 'ld_projectcf:cf_1750:cf_1750:Project_项目申报批次:V',
'ld_projectcf:cf_1750:cf_1750:Project_Batch project application:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_projectcf:cf_1750:cf_1750:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:cf_1109:cf_1109:SalesOrder_cf_1109:V', 13, 1, 'ld_salesorder:cf_1109:cf_1109:SalesOrder_项目总金额（元）:V',
'ld_salesorder:cf_1109:cf_1109:SalesOrder_amount of the project:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:cf_1109:cf_1109:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:cf_1110:cf_1110:SalesOrder_cf_1110:V', 14, 1, 'ld_salesorder:cf_1110:cf_1110:SalesOrder_项目首付金额（元）:V',
'ld_salesorder:cf_1110:cf_1110:SalesOrder_Project down payment:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:cf_1110:cf_1110:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:cf_1111:cf_1111:SalesOrder_cf_1111:V', 15, 1, 'ld_salesorder:cf_1111:cf_1111:SalesOrder_项目尾款金额（元）:V',
'ld_salesorder:cf_1111:cf_1111:SalesOrder_payment amount:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:cf_1111:cf_1111:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:cf_1704:cf_1704:SalesOrder_cf_1704:V', 16, 1, 'ld_salesorder:cf_1704:cf_1704:SalesOrder_合同约定比例:V',
'ld_salesorder:cf_1704:cf_1704:SalesOrder_proportion contract:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_salesorder:cf_1704:cf_1704:SalesOrder_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:projectstatus:projectstatus:Project_projectstatus:V', 17, 1, 'ld_project:projectstatus:projectstatus:Project_项目状态:V',
'ld_project:projectstatus:projectstatus:SalesOrder_proportion contract:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:projectstatus:projectstatus:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1699:cf_1699:Project_cf_1699:V', 18, 1, 'ld_project:cf_1699:cf_1699:Project_项目主管:V',
'ld_project:cf_1699:cf_1699:Project_Project Director:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1699:cf_1699:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:Project_Engineer:Project_Engineer:OftenUseReport_Project_Engineer:V', 19, 1, 'ld_project:Project_Engineer:Project_Engineer:OftenUseReport_项目工程师:V',
'ld_project:Project_Engineer:Project_Engineer:OftenUseReport_Project Engineer:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:Project_Engineer:Project_Engineer:OftenUseReport_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1747:cf_1747:Project_cf_1747:V', 20, 1, 'ld_project:cf_1747:cf_1747:Project_项目撰写人:V',
'ld_project:cf_1747:cf_1747:Project_Project authors:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1747:cf_1747:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1700:cf_1700:Project_cf_1700:V', 21, 1, 'ld_projectcf:cf_1700:cf_1700:Project_合作工程师:V',
'ld_projectcf:cf_1700:cf_1700:Project_Cooperation engineer:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_projectcf:cf_1700:cf_1700:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1746:cf_1746:Project_cf_1746:D', 22, 1, 'ld_project:cf_1746:cf_1746:Project_通过日期:D',
'ld_project:cf_1746:cf_1746:Project_data:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1746:cf_1746:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1745:cf_1745:Project_cf_1745:D', 23, 1, 'ld_project:cf_1745:cf_1745:Project_递交日期:D',
'ld_project:cf_1745:cf_1745:Project_data:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1745:cf_1745:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:modifiedby:modifiedby:Project_modifiedby:V', 24, 1, 'ld_project:modifiedby:modifiedby:Project_最新更新人:V',
'ld_project:modifiedby:modifiedby:Project_modifiedby:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:modifiedby:modifiedby:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1773:cf_1773:Project_cf_1773:V', 25, 1, 'ld_project:cf_1773:cf_1773:Project_项目上一操作人:V',
'ld_project:cf_1773:cf_1773:Project_One operator on the project:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1773:cf_1773:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:description:description:Project_description:V', 26, 1, 'ld_project:description:description:Project_备注（项目申报）:V',
'ld_project:description:description:Project_description:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:description:description:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_potential:cf_1100:cf_1100:Potentials_cf_1100:V', 27, 1, 'ld_potential:cf_1100:cf_1100:Potentials_签约日期:V',
'ld_potential:cf_1100:cf_1100:Potentials_data:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_potential:cf_1100:cf_1100:Potentials_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:ccount:ccount:OftenUseReport_ccount:V', 28, 1, 'ld_cashbill:ccount:ccount:OftenUseReport_收款单数量（张）:V',
'ld_cashbill:ccount:ccount:OftenUseReport_cash bill count:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_cashbill:ccount:ccount:OftenUseReport_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:subtotal:subtotal:CashBill_subtotal:N', 29, 1, 'ld_cashbill:subtotal:subtotal:CashBill_最近收款金额（元）:N',
'ld_cashbill:subtotal:subtotal:CashBill_Recently Receivables Amount:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_cashbill:subtotal:subtotal:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D', 30, 1, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_最近收款日期:D',
'ld_cashbill:cashbilldate:cashbilldate:CashBill_Recently Receivables data:D'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_cashbill:cashbilldate:cashbilldate:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:total:total:CashBill_total:N', 31, 1, 'ld_cashbill:total:total:CashBill_已收款金额（元）:N',
'ld_cashbill:total:total:CashBill_total:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_cashbill:total:total:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:weishou:weishou:CashBill_weishou:N', 32, 1, 'ld_cashbill:weishou:weishou:CashBill_未收款金额（元）:N',
'ld_cashbill:weishou:weishou:CashBill_total:N'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_cashbill:weishou:weishou:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:description:description:CashBill_description:V', 33, 1, 'ld_cashbill:description:description:CashBill_备注（催款信息）:V',
'ld_cashbill:description:description:CashBill_description:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_cashbill:description:description:CashBill_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1774:cf_1774:Project_cf_1774:V', 34, 1, 'ld_project:cf_1774:cf_1774:Project_配合政府申报项目:V',
'ld_project:cf_1774:cf_1774:Project_Cooperate:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1774:cf_1774:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1783:cf_1783:Project_cf_1783:V', 35, 1, 'ld_project:cf_1783:cf_1783:Project_是否留档:V',
'ld_project:cf_1783:cf_1783:Project_y/n:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1783:cf_1783:Project_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Searchcannotbeempty','搜索内容不能为空','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Searchcannotbeempty' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Searchcannotbeempty','Search can not be empty','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Searchcannotbeempty' 
and Labeltype='jspop');
delimiter;
-- 2015-10-15

select taxid into @taxid from ld_inventorytaxinfo where taxname = 'tax_customs';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_inventorytaxinfo',@taxid,@taxid,'关税' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'zh' and trantable = 'ld_inventorytaxinfo');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_inventorytaxinfo',@taxid,@taxid,'Tax_Customs' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'en' and trantable = 'ld_inventorytaxinfo');
delimiter;
select taxid into @taxid from ld_inventorytaxinfo where taxname = 'tax_added';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_inventorytaxinfo',@taxid,@taxid,'增值税' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'zh' and trantable = 'ld_inventorytaxinfo');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_inventorytaxinfo',@taxid,@taxid,'Tax_Added' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'en' and trantable = 'ld_inventorytaxinfo');
delimiter;
select taxid into @taxid from ld_inventorytaxinfo where taxname = 'tax_profit';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_inventorytaxinfo',@taxid,@taxid,'利润率' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'zh' and trantable = 'ld_inventorytaxinfo');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_inventorytaxinfo',@taxid,@taxid,'Tax_Profit' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'en' and trantable = 'ld_inventorytaxinfo');
delimiter;
select taxid into @taxid from ld_inventorytaxinfo where taxname = 'tax_freight';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_inventorytaxinfo',@taxid,@taxid,'运费系数' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'zh' and trantable = 'ld_inventorytaxinfo');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_inventorytaxinfo',@taxid,@taxid,'Tax_Freight' 
from dual where not exists(select 1 from ld_tranlabel where tabid = @taxid and relateid = @taxid and languagetype = 'en' and trantable = 'ld_inventorytaxinfo');
delimiter;

UPDATE ld_usereport SET name='THESINGNINGAMOUNTOFBILLBOARD' WHERE name='ThebillboardofReceivables';

UPDATE ld_desk SET fieldlabel='签约金额龙虎榜' WHERE labelbol='Contractamount' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','replycontentcannotbeempty','回复内容不能为空！','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol='replycontentcannotbeempty' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','replycontentcannotbeempty','Reply content can not be empty!','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol='replycontentcannotbeempty' and labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBack';
update ld_producttoolfield set tablename='ld_inventoryproductrel' where tabid = @tabid and columnname = 'listprice' and uitype = 26;
delimiter;
update ld_producttoolfield set tablename='ld_inventoryproductrel' where tabid = @tabid and columnname = 'taxprice' and uitype = 27;
delimiter;
-- 2015-10-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEPUBLICACCOUNTGIVEN','分配公海客户给%s','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEPUBLICACCOUNTGIVEN');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEPUBLICACCOUNTGIVEN','Allocate high Seas customers%s','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEPUBLICACCOUNTGIVEN');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETMYPUBLICACCOUNT','获取为自己的公海客户','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='GETMYPUBLICACCOUNT');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETMYPUBLICACCOUNT','get high Seas customers for me','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='GETMYPUBLICACCOUNT');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELAYPUBLICACCOUNTDAYS','将公海客户回收日期延期%s天','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELAYPUBLICACCOUNTDAYS');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELAYPUBLICACCOUNTDAYS','Delay high Seas %s days','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELAYPUBLICACCOUNTDAYS');

select usereportid into @id from ld_usereport where name='Reportingpaymentschedulestatistics';
DELETE FROM ld_usereportcolumns where  Usereportid=@id and 
realcolumns like 'ld_project:cf_1783:cf_1783:Project_%';

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1784:cf_1784:Project_cf_1784:V', 35, 1, 'ld_project:cf_1784:cf_1784:Project_是否留档:V',
'ld_project:cf_1784:cf_1784:Project_y/n:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and 
realcolumns like 'ld_project:cf_1784:cf_1784:Project_%');
delimiter;
-- 2015-10-19

update ld_field set masseditable=2 where columnname='plandate' and tabid =(select tabid from ld_tab where `name`='PaymentPlan');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVALIDALLSINGLEDISCOUNT','无效的整单折扣','jspop'
from dual where not EXISTS(select 1 from ld_desk where Labeltype='jspop' and labelbol='INVALIDALLSINGLEDISCOUNT'
and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVALIDALLSINGLEDISCOUNT','Invalid all Single Discount','jspop'
from dual where not EXISTS(select 1 from ld_desk where Labeltype='jspop' and labelbol='INVALIDALLSINGLEDISCOUNT'
and languagetype='en');

update ld_usereportcolumns set realcolumns='ld_singin:distance:distance:OftenUseReport_误差(米):N'  
where usereportid in(select usereportid from ld_usereport where name='SIGNINSTATISTICS')  and COLUMNS like '%ld_singin:distance:distance:OftenUseReport%';

update ld_desk set fieldlabel='更改{$SalesOrder.sostatus}' where labeltype='fixedstr' and labelbol='UPDATESTATE' and languagetype='zh';
update ld_desk set fieldlabel='Update{$SalesOrder.sostatus}' where labeltype='fixedstr' and labelbol='UPDATESTATE' and languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPDATEPURCHASEORDERSTATUS','更改{$PurchaseOrder.postatus}','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where Labeltype='fixedstr' and labelbol='UPDATEPURCHASEORDERSTATUS'
and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPDATEPURCHASEORDERSTATUS','Update{$PurchaseOrder.postatus}','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where Labeltype='fixedstr' and labelbol='UPDATEPURCHASEORDERSTATUS'
and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecurrentapprovalprocesshasbeendeletedordisabled','当前审批流程已删除，是否使用新的流程重新流转？','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labeltype='jspop' and labelbol = 'thecurrentapprovalprocesshasbeendeletedordisabled');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecurrentapprovalprocesshasbeendeletedordisabled','The current approval process has been deleted or disabled, the use of the new approval process to re transfer?','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labeltype='jspop' and labelbol = 'thecurrentapprovalprocesshasbeendeletedordisabled');
delimiter;
-- 2015-10-20

update ld_field set presence = 1 where uitype = 16 and fieldname = 'hdnTaxType' and columnname = 'taxtype';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,83,'已收金额计算时是否统计未审核的收款单','',410 from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=83);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Whetherreceivedamountcalculatesnoncheckedcashbills','已收金额计算时是否统计未审核的{$CashBill.CashBill}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Whetherreceivedamountcalculatesnoncheckedcashbills' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Whetherreceivedamountcalculatesnoncheckedcashbills','Whether the received amount calculates the non checked {$CashBill.CashBill}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Whetherreceivedamountcalculatesnoncheckedcashbills' and Labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,84,'已付金额计算时是否统计未审核的付款单','',420 from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=84);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Whetherreceivedamountcalculatesnoncheckedsendcashbills','已付金额计算时是否统计未审核的{$SendCashBill.SendCashBill}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Whetherreceivedamountcalculatesnoncheckedsendcashbills' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Whetherreceivedamountcalculatesnoncheckedsendcashbills','Whether the amount paid the non checked send {$SendCashBill.SendCashBill}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Whetherreceivedamountcalculatesnoncheckedsendcashbills' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Businessparameters','业务参数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Businessparameters' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Businessparameters','Business parameters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Businessparameters' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where tablename = 'ld_products' and tabid = @tabid and columnname = 'listprice' and input_type = 1 and defaultcolumn = 3;
delimiter;
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where tablename = 'ld_products' and tabid = @tabid and columnname = 'taxprice' and input_type = 1 and defaultcolumn = 2;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TORELEASETHECUSTOMERTOTHEHIGNSEAS','释放公海已分配客户到公海未分配','fixedstr' from DUAL
where not exists(select 1 from  ld_desk where labeltype='fixedstr' and labelbol='TORELEASETHECUSTOMERTOTHEHIGNSEAS' and languagetype='zh');
update ld_cvadvfilter set value='未出库' where columnname like '%ld_outboundorder:presence:presence:OutboundOrder%' and value=0;
update ld_cvadvfilter set value='已出库' where columnname like '%ld_outboundorder:presence:presence:OutboundOrder%' and value=1;
update ld_cvadvfilter set value='盘点中' where columnname like '%ld_checks:presence:presence:Checks%' and value=0;
update ld_cvadvfilter set value='盘点结束' where columnname like '%ld_checks:presence:presence:Checks%' and value=1;
update ld_cvadvfilter set value='未入库' where columnname like '%ld_stock:presence:presence:Stock%' and value=0;
update ld_cvadvfilter set value='已入库' where columnname like '%ld_stock:presence:presence:Stock%' and value=1;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
delete from ld_profileallpermission where tabid = @tabid and  operation = 5;
delimiter;

select tabid into @tabid from ld_tab where `name` ='SendPayment';
delete from ld_profileallpermission where tabid = @tabid and  operation = 5;
delimiter;

update ld_desk set fieldlabel='更改{Var}' where labelbol='CHANGECREATED' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Change {Var}' where labelbol='CHANGECREATED' and Labeltype='fixedstr' and languagetype='en';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHANGEREMINDCREATOR','更改{$Reminds.creator}','jspop' from DUAL where not exists(select 1 from ld_desk where 
		labelbol='CHANGEREMINDCREATOR' and LANGUAGEtype='zh' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHANGEREMINDCREATOR','Change {$Reminds.creator}','jspop' from DUAL where not exists(select 1 from ld_desk where 
		labelbol='CHANGEREMINDCREATOR' and LANGUAGEtype='en' and labeltype='jspop');

select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='transferdate_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='transferdate';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='outwarehouse';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='inwarehouse';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,5,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='transfersmownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,6,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='transfersmownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,6,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where fieldid=@fieldid and tabid=@tabid);
delimiter;
-- 2015-10-22

call AddColumn ('ld_warehousecondtions','entity_title' ,'varchar','250',Null);
delimiter;

drop procedure if EXISTS setwarehouseconditionentity_title;
delimiter ||
create PROCEDURE setwarehouseconditionentity_title(
)
BEGIN
	declare entityidd int ;
	declare done  int  default 0;
	declare module varchar(50); 
	declare cur1 CURSOR FOR  select  DISTINCT entityid,setype from ld_warehousecondtions INNER JOIN ld_crmentity 
														 on ld_crmentity.crmid=ld_warehousecondtions.entityid;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into entityidd,module;
  loop1: while  done<>1 DO
   
	
		set @sql=CONCAT('select fieldname into @fieldname from ld_entityname  where modulename=''',module,'''');

			prepare stmt from @sql;
			execute stmt;
		set @sql=CONCAT('select entityidfield into @entityidfieldidd  from ld_entityname  where modulename=''',module,'''');
			prepare stmt from @sql;
			execute stmt;
	   set @sql=CONCAT('select tablename into @tablename  from ld_field where tabid in(select tabid from ld_tab where name=''',module,''') and columnname=@fieldname');
			prepare stmt from @sql;
			execute stmt;	
	
		set @sql=CONCAT('select ',@fieldname ,' into @columnvalue  from  ',@tablename,' where ',@entityidfieldidd,'=' ,entityidd);
		  
				prepare stmt from @sql;
			execute stmt;
		  set @sql=CONCAT('update ld_warehousecondtions set entity_title=''',@columnvalue,'''  where entityid=',entityidd);
			
			prepare stmt from @sql;
			execute stmt;

		Fetch cur1 into entityidd,module;
	end while loop1;
	close cur1;
end ||
delimiter;

call setwarehouseconditionentity_title();
delimiter;

update ld_warehousecondtions set entity_title='' where entityid not in(select crmid from  ld_crmentity);
delimiter;
-- 2015-10-26

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','searchforcolleagues','搜索同事','jspop' from dual where not exists(select 1 from ld_desk where labelbol='searchforcolleagues' and languagetype='zh' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','searchforcolleagues','Search for colleagues','jspop' from dual where not exists(select 1 from ld_desk where labelbol='searchforcolleagues' and languagetype='en' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isselect','已选','jspop' from dual where not exists(select 1 from ld_desk where labelbol='isselect' and languagetype='zh' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isselect','Select','jspop' from dual where not exists(select 1 from ld_desk where labelbol='isselect' and languagetype='en' and labeltype='jspop');
delimiter;
-- 2015-10-27

update ld_backup set intervaldays='day',intervalhours=23,intervalminute=0 where id=2 and backuppath is NULL;
update ld_tab set printtab=1  where `name` = 'Commission';
delimiter;
-- 2015-10-28

update ld_tab set printtab=1  where `name` = 'Commission';
delimiter;

select sequence into @sequence from ld_field  where tabid=29 and columnname='profileid';
update ld_field set sequence=sequence+1 where  sequence>@sequence;
select max(fieldid) into @fieldid from ld_field;
update ld_field_seq set id=id+1  where not EXISTS(select 1 from ld_field where tabid=29 and columnname='departments');
insert into ld_field (fieldid,tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,masseditable,fieldonly)
select @fieldid+1,29,'departments','ld_users',1,103,'departments','部门',0,0,'',100,@sequence+1,77,2,'V~O',1,1,0
from dual where not EXISTS(select 1 from ld_field where tabid=29 and columnname='departments');
select fieldid into @relateid from ld_field  where tabid=29 and columnname='departments';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',29,@relateid,'部门' from dual where not EXISTS(select 1 from ld_tranlabel where Relateid=@relateid and languagetype='zh' and trantable='ld_field');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',29,@relateid,'Sector' from dual where not EXISTS(select 1 from ld_tranlabel where Relateid=@relateid and languagetype='en' and trantable='ld_field');
delimiter;
    
select tabid into @tabid from ld_tab where name='productbom';
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='productbom_no';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,110,1,1,1 from dual where not EXISTS(select 1 from ld_relatedlists_lable where  tabid=@tabid and fieldid=@fieldid);
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='subject';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,110,2,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where  tabid=@tabid and fieldid=@fieldid);
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,110,3,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where  tabid=@tabid and fieldid=@fieldid);
select fieldid  into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_relatedlists_lable (tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,110,4,1,0 from dual where not EXISTS(select 1 from ld_relatedlists_lable where  tabid=@tabid and fieldid=@fieldid);
delimiter;

call AddColumn('ld_field','duplicatefield','int',10,1);
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','FIELD','查重字段','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='FIELD' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','FIELD','Field','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='FIELD' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','KEYWORDS','查重内容','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='KEYWORDS' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','KEYWORDS','Keyword','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='KEYWORDS' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','SERCHNOW','立即查重','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='SERCHNOW' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','SERCHNOW','search now','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='SERCHNOW' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','DESCRIPTIONFINDDATASHOWTOP5OFRESULT','说明信息：在所有数据中进行查重，仅显示符合条件的前5条数据。','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='DESCRIPTIONFINDDATASHOWTOP5OFRESULT' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','DESCRIPTIONFINDDATASHOWTOP5OFRESULT','Find duplicate records in all data, only to show the top 5 of the query result','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='DESCRIPTIONFINDDATASHOWTOP5OFRESULT' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','PLEASEENTERKEYWORDRECHECKING','请输入查重关键字','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='PLEASEENTERKEYWORDRECHECKING' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','PLEASEENTERKEYWORDRECHECKING','Please enter keyword rechecking','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol='PLEASEENTERKEYWORDRECHECKING' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'zh','PLEASEENTERKEYWORDRECHECKING','请输入查重关键字','jspop' 
from dual where not exists(select 1 from ld_desk where labelbol='PLEASEENTERKEYWORDRECHECKING' and languagetype='zh' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) 
select 'en','PLEASEENTERKEYWORDRECHECKING','Please enter keyword rechecking','jspop' 
from dual where not exists(select 1 from ld_desk where labelbol='PLEASEENTERKEYWORDRECHECKING' and languagetype='en' and Labeltype='jspop');
delimiter;

update ld_field set duplicatefield=0 where tabid=6 and columnname='accountname';
delimiter;
-- 2015-10-30

update ld_users set dailyreporttemplet='<p>
    今日总结：
</p>' where dailyreporttemplet='<p>
    今日计划(昨日填写)：<br/><br/>今日总结：
</p>';

update ld_users set monthtypetemplet='<p>
    本月总结：
</p>' where monthtypetemplet='<p>
    本月计划(上月填写)：<br/><br/>本月总结：
</p>';

update ld_users set weekreporttemplet='<p>
    本周总结：
</p>' where weekreporttemplet='<p>
    本周计划(上周填写)：<br/><br/>本周总结：
</p>';

update ld_desk set fieldlabel = '退货金额不允许超过源单金额' where labelbol = 'THENUMBEROFRETURNS2' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DETAILRECORDSEXPORTING','条记录，明细','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol='DETAILRECORDSEXPORTING' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DETAILRECORDSEXPORTING',' records，detials', 'jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol='DETAILRECORDSEXPORTING' and languagetype='en' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DETAILRECORDSEXPORTINGNEXT','条,正在导出第', 'jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol='DETAILRECORDSEXPORTINGNEXT' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DETAILRECORDSEXPORTINGNEXT','records,exporting ', 'jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol='DETAILRECORDSEXPORTINGNEXT' and languagetype='en' and Labeltype='jspop');
delimiter;
-- 2015-11-02

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
delete from ld_profileallpermission where tabid = @tabid and operation = 12;
delimiter;
select tabid into @tabid from ld_tab where `name` ='SendPayment';
delete from ld_profileallpermission where tabid = @tabid and operation = 12;
delimiter;
-- 2015-11-04

update ld_attachmentsforbills inner join ld_crmentity on ld_attachmentsforbills.related_to=ld_crmentity.crmid 
set reltab=ld_crmentity.setype;
delimiter;
-- 2015-11-05

update ld_desk set fieldlabel='Field' where fieldlabel='Lookup field';
delimiter;

update ld_desk set fieldlabel='Keyword' where fieldlabel='keyword';
delimiter;

update ld_tranlabel set fieldlabel='编码或条码' where tabid=14 and Relateid=176 and trantable='ld_field' and languagetype='zh';
-- 2015-11-06

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

update ld_version set old_version='V6.1.4' ,current_version='V6.1.4' ,remark='V6.1.4-20151106';
delimiter;