UPDATE ld_tabdetailfield SET presence=0 WHERE columnname='entitytype' AND tablename='ld_timesheetdetail'
	AND NOT EXISTS (SELECT 1 FROM ld_timesheet);
-- 2020-04-24

DROP TRIGGER IF EXISTS `update_account_lastservicedate`;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=8 AND columnname='filestatus' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='Allow to view or download' WHERE tabid=8 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='Allow viewing or downloading';
delimiter;

SET @tabid=(select tabid from ld_tab where name = 'Attachment' LIMIT 1);
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='isenabled' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='Allow to view or download' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='Allow viewing or downloading';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LASTRECORD','上一条','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LASTRECORD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LASTRECORD','Last record','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LASTRECORD' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEXTRECORD','下一条','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NEXTRECORD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEXTRECORD','Next record','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NEXTRECORD' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWFILTERS','新建分类','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NEWFILTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWFILTERS','New filters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NEWFILTERS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHAND','且','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHAND' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHAND','And','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHAND' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OR','或','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OR','Or','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='OR' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETECOMBINATION','删除组合','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETECOMBINATION' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETECOMBINATION','Delete combination','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELETECOMBINATION' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDCOMPARE','字段比较','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='FIELDCOMPARE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDCOMPARE','Field for Comparision','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='FIELDCOMPARE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ATTRIBUTEFIELD','相关字段','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ATTRIBUTEFIELD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ATTRIBUTEFIELD','Related field','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ATTRIBUTEFIELD' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Execution','执行','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Execution' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Execution','Execution','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Execution' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NONE','无','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NONE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NONE','NONE','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NONE' and Labeltype='jspop');
delimiter;

SET @i=0;
SET @mytype=1;
SET @columnname='signaddress';
SET @labelname='签到';
SET @max_id=(SELECT MAX(id) FROM ld_workreport_field);
INSERT INTO ld_workreport_field (id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename,allow_edit)
SELECT @max_id+1,@columnname,@labelname,'workreport',@mytype,NULL,50,1,0,0,200000,'ld_workreport','yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_field WHERE type=@mytype AND `name`=@columnname);

UPDATE ld_workreport_field SET sequence=(@i:=@i+1) WHERE type=@mytype ORDER BY sequence;

SET @i=0;
SET @mytype=2;
SET @columnname='signaddress';
SET @labelname='签到';
SET @max_id=(SELECT MAX(id) FROM ld_workreport_field);
INSERT INTO ld_workreport_field (id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename,allow_edit)
SELECT @max_id+1,@columnname,@labelname,'workreport',@mytype,NULL,50,1,0,0,200000,'ld_workreport','yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_field WHERE type=@mytype AND `name`=@columnname);

UPDATE ld_workreport_field SET sequence=(@i:=@i+1) WHERE type=@mytype ORDER BY sequence;


SET @i=0;
SET @mytype=3;
SET @columnname='signaddress';
SET @labelname='签到';
SET @max_id=(SELECT MAX(id) FROM ld_workreport_field);
INSERT INTO ld_workreport_field (id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename,allow_edit)
SELECT @max_id+1,@columnname,@labelname,'workreport',@mytype,NULL,50,1,0,0,200000,'ld_workreport','yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_field WHERE type=@mytype AND `name`=@columnname);

UPDATE ld_workreport_field SET sequence=(@i:=@i+1) WHERE type=@mytype ORDER BY sequence;

UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);

UPDATE ld_workreport_field SET label='签到' where name = 'signaddress' and label = '定位';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BeforeYesterday','前天','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BeforeYesterday' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BeforeYesterday','Before yesterday','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BeforeYesterday' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BeforeLastYear','前年','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BeforeLastYear' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BeforeLastYear','Before last year','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BeforeLastYear' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewAccounts','新建{$Accounts.Accounts}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewAccounts' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewAccounts','New {$Accounts.Accounts}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewAccounts' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewContacts','新建{$Contacts.Contacts}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewContacts' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewContacts','New {$Contacts.Contacts}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewContacts' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewContactRecords','新建{$ContactRecords.ContactRecords}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewContactRecords' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewContactRecords','New {$ContactRecords.ContactRecords}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewContactRecords' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewSalesOrderCount','{$SalesOrder.SalesOrder}个数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewSalesOrderCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewSalesOrderCount','New {$SalesOrder.SalesOrder} count','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewSalesOrderCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewServiceContractsCount','{$ServiceContracts.ServiceContracts}个数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewServiceContractsCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewServiceContractsCount','New {$ServiceContracts.ServiceContracts} count','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewServiceContractsCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewSalesOrderAmount','{$SalesOrder.SalesOrder}金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewSalesOrderAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewSalesOrderAmount','New {$SalesOrder.SalesOrder} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewSalesOrderAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewServiceContractsAmount','{$ServiceContracts.ServiceContracts}金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewServiceContractsAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewServiceContractsAmount','New {$ServiceContracts.ServiceContracts} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewServiceContractsAmount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SignContractCount','签约单数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SignContractCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SignContractCount','签约单数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SignContractCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SignContractAmount','签约金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SignContractAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SignContractAmount','签约金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SignContractAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewInvoiceAmount','{$Invoice.Invoice}金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewInvoiceAmount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewInvoiceAmount','{$Invoice.Invoice} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewInvoiceAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewOutboundOrderAmount','{$OutboundOrder.OutboundOrde}金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewOutboundOrderAmount' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewOutboundOrderAmount','{$OutboundOrder.OutboundOrder} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewOutboundOrderAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewCashBillAmount','{$CashBill.CashBill}金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewCashBillAmount' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewCashBillAmount','{$CashBill.CashBill} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewCashBillAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewPotentialsCount','新建{$Potentials.Potentials}个数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewPotentialsCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewPotentialsCount','New {$Potentials.Potentials} count','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewPotentialsCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewPotentialsAmount','新建{$Potentials.Potentials} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewPotentialsAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewPotentialsAmount','New {$Potentials.Potentials} amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewPotentialsAmount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AdvancePotentialsAmount','预计成交机会金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AdvancePotentialsAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AdvancePotentialsAmount','预计成交机会金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AdvancePotentialsAmount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChangePotentialStageCount','阶段变化的机会个数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ChangePotentialStageCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChangePotentialStageCount','阶段变化的机会个数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ChangePotentialStageCount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewSignCount','新建签到记录','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewSignCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewSignCount','新建签到记录','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewSignCount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewLeadsCount','新建{$Leads.Leads}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewLeadsCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewLeadsCount','New {$Leads.Leads}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewLeadsCount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewHelpDeskCount','新建{$HelpDesk.HelpDesk}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewHelpDeskCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewHelpDeskCount','New {$HelpDesk.HelpDesk}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewHelpDeskCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewCashBillCount','{$CashBill.CashBill}数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewCashBillCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewCashBillCount','{$CashBill.CashBill} count','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewCashBillCount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewOutboundOrderCount','{$OutboundOrder.OutboundOrder}个数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewOutboundOrderCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewOutboundOrderCount','{$OutboundOrder.OutboundOrder} count','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewOutboundOrderCount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewInvoiceCount','{$Invoice.Invoice}数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewInvoiceCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewInvoiceCount','New {$Invoice.Invoice}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewInvoiceCount' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewPurchaseOrderCount','{$PurchaseOrder.PurchaseOrder}数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewPurchaseOrderCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewPurchaseOrderCount','New {$PurchaseOrder.PurchaseOrder}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewPurchaseOrderCount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewPurchaseOrderAmount','{$PurchaseOrder.PurchaseOrder}金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewPurchaseOrderAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewPurchaseOrderAmount','{$PurchaseOrder.PurchaseOrder} Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewPurchaseOrderAmount' and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not EXISTS `ld_homestuffdetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `stuffid` int(19) DEFAULT NULL,
  `stufflabel` varchar(50) DEFAULT NULL,
  `stufflabeltype` varchar(50) DEFAULT NULL,
  `compute_columns` varchar(200) DEFAULT NULL,
  `compute_type` varchar(50) DEFAULT NULL,
  `pageurl` varchar(200) DEFAULT NULL,
  `sequence` int(4) DEFAULT NULL,
  `cssname` varchar(50) DEFAULT NULL,
	`presence` varchar(50) DEFAULT 'yes',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_homestuffdetailcondition` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `homestuffdetailid` int(19) DEFAULT NULL,
 
  `groupid` int(4) DEFAULT NULL,
  `columns` varchar(200) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewAccounts','fixedstr','ld_account.accountid','count','index.php?pageto_module=Accounts&pageto_action=index',1 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewAccounts');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewAccounts';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:createdtime:createdtime:Accounts_创建时间:DT','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:createdtime:createdtime:Accounts%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_account:approvestatus:approvestatus%') ;
delimiter;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewContacts','fixedstr','ld_contactdetails.contactid','count','index.php?pageto_module=Contacts&pageto_action=index',2 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewContacts');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewContacts';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_contactdetails:createdtime:createdtime:Contacts_创建时间:DT','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_contactdetails:createdtime:createdtime:%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_contactdetails:approvestatus:approvestatus:Contacts_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_contactdetails:approvestatus:approvestatus:Contacts%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewContactRecords','fixedstr','ld_contactrecords.contactrecordid','count','index.php?pageto_module=ContactRecords&pageto_action=index',3 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewContactRecords');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewContactRecords';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_contactrecords:createdtime:createdtime:ContactRecords_创建时间:DT','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_contactrecords:createdtime:createdtime%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_contactrecords:approvestatus:approvestatus:ContactRecords_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_contactrecords:approvestatus:approvestatus:ContactRecords%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewSalesOrderCount','fixedstr','ld_salesorder.salesorderid','count','index.php?pageto_module=SalesOrder&pageto_action=index',4 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewSalesOrderCount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewSalesOrderCount';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where  homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:signed_data:signed_data%' ) ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:approvestatus:approvestatus%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V','n','已作废' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:sostatus:sostatus%') ;

delimiter;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewServiceContractsCount','fixedstr','ld_servicecontracts.servicecontractsid','count','index.php?pageto_module=ServiceContracts&pageto_action=index',5 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceContractsCount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceContractsCount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:due_date:due_date%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewSalesOrderAmount','fixedstr','ld_salesorder.total','sum','index.php?pageto_module=SalesOrder&pageto_action=index',6 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewSalesOrderAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewSalesOrderAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:signed_data:signed_data%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewServiceContractsAmount','fixedstr','ld_servicecontracts.total','sum','index.php?pageto_module=ServiceContracts&pageto_action=index',7 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceContractsAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewServiceContractsAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like 'ld_servicecontracts:due_date:due_date%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'SignContractCount','fixedstr','ld_salesorder.salesorderid','count','index.php?pageto_module=SalesOrder&pageto_action=index',8 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractCount' and pageurl like '%salesorder%');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractCount' and pageurl like '%salesorder%';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and columns like '%ld_salesorder:signed_data:signed_data%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'SignContractCount','fixedstr','ld_servicecontracts.servicecontractsid','count','index.php?pageto_module=ServiceContracts&pageto_action=index',8 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractCount' and pageurl like '%ServiceContracts%');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractCount' and pageurl like '%ServiceContracts%';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:due_date:due_date:ServiceContracts%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'SignContractAmount','fixedstr','ld_salesorder.total','sum','index.php?pageto_module=SalesOrder&pageto_action=index',9 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractAmount' and pageurl like '%salesorder%');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractAmount' and pageurl like '%salesorder%';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and columns like '%ld_salesorder:signed_data:signed_data%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'SignContractAmount','fixedstr','ld_servicecontracts.total','sum','index.php?pageto_module=ServiceContracts&pageto_action=index',9 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractAmount' and pageurl like '%ServiceContracts%');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractAmount' and pageurl like '%ServiceContracts%';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid  and COLUMNS like '%ld_servicecontracts:due_date:due_date:ServiceContracts%') ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:approvestatus:approvestatus:ServiceContracts_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewInvoiceAmount','fixedstr','ld_invoice.total','sum','index.php?pageto_module=Invoice&pageto_action=index',10 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewInvoiceAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewInvoiceAmount' ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_invoice:invoicedate:invoicedate:Invoice_开票日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_invoice:invoicedate:invoicedate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_invoice:approvestatus:approvestatus:Invoice_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_invoice:approvestatus:approvestatus:Invoice%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewOutboundOrderAmount','fixedstr','ld_outboundorder.total','sum','index.php?pageto_module=OutboundOrder&pageto_action=index',11 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewOutboundOrderAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewOutboundOrderAmount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_outboundorder:outdate:outdate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_outboundorder:approvestatus:approvestatus:OutboundOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_outboundorder:approvestatus:approvestatus%') ;
delimiter;


insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewCashBillAmount','fixedstr','ld_cashbill.total','sum','index.php?pageto_module=CashBill&pageto_action=index',12 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewCashBillAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewCashBillAmount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:cashbilldate:cashbilldate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:approvestatus:approvestatus%') ;
delimiter;


insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewPotentialsCount','fixedstr','ld_potentials.potentialid','count','index.php?pageto_module=Potentials&pageto_action=index',13 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewPotentialsCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPotentialsCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:createdtime:createdtime:Potentials_fieldlabel:DT','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:createdtime:createdtime%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:approvestatus:approvestatus:Potentials_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewPotentialsAmount','fixedstr','ld_potentials.amount','sum','index.php?pageto_module=Potentials&pageto_action=index',14 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewPotentialsAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPotentialsCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:createdtime:createdtime:Potentials_fieldlabel:DT','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:createdtime:createdtime%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:approvestatus:approvestatus:Potentials_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'AdvancePotentialsAmount','fixedstr','ld_potentials.amount','sum','index.php?pageto_module=Potentials&pageto_action=index',15 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='AdvancePotentialsAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='AdvancePotentialsAmount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:closingdate:closingdate:Potentials_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:closingdate:closingdate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:approvestatus:approvestatus:Potentials_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'ChangePotentialStageCount','fixedstr','ld_potentials.potentialid','count','index.php?pageto_module=Potentials&pageto_action=index',15 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='ChangePotentialStageCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='ChangePotentialStageCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:lastsales_stage:lastsales_stage:Potentials_fieldlabel:V','isnotnull','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:lastsales_stage:lastsales_stage%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)

select @homestuffdetailid,1,'ld_potentials:createdtime:createdtime:Potentials_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:createdtime:createdtime%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:approvestatus:approvestatus:Potentials_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewSignCount','fixedstr','ld_singin.id','count','index.php?pageto_module=OftenUseReport&pageto_action=newindex',17 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewSignCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewSignCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_singin:createdtime:createdtime:Singin_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_singin:createdtime:createdtime%' ) ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewLeadsCount','fixedstr','ld_leads.leadsid','count','index.php?pageto_module=Leads&pageto_action=index',18 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewLeadsCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewLeadsCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_leads:createdtime:createdtime:Leads_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_leads:createdtime:createdtime:Leads%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_leads:approvestatus:approvestatus:Leads_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_leads:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewHelpDeskCount','fixedstr','ld_troubletickets.ticketid','count','index.php?pageto_module=HelpDesk&pageto_action=index',19 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewHelpDeskCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewHelpDeskCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_troubletickets:createdtime:createdtime%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_troubletickets:approvestatus:approvestatus:Leads_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_troubletickets:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewCashBillCount','fixedstr','ld_cashbill.cashbillid','count','index.php?pageto_module=CashBill&pageto_action=index',20 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewCashBillCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewCashBillCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:cashbilldate:cashbilldate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_cashbill:approvestatus:approvestatus%') ;
delimiter;


insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewOutboundOrderCount','fixedstr','ld_outboundorder.out_id','count','index.php?pageto_module=OutboundOrder&pageto_action=index',21 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewOutboundOrderCount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewOutboundOrderCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_outboundorder:outdate:outdate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_outboundorder:approvestatus:approvestatus:OutboundOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_outboundorder:approvestatus:approvestatus%') ;
delimiter;




insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewInvoiceCount','fixedstr','ld_invoice.invoiceid','count','index.php?pageto_module=Invoice&pageto_action=index',22 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewInvoiceCount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewInvoiceCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_invoice:invoicedate:invoicedate%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_invoice:approvestatus:approvestatus:Invoice_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_invoice:approvestatus:approvestatus%') ;
delimiter;

insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewPurchaseOrderCount','fixedstr','ld_purchaseorder.purchaseorderid','count','index.php?pageto_module=PurchaseOrder&pageto_action=index',23 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewPurchaseOrderCount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPurchaseOrderCount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_purchaseorder:signed_data:signed_data%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_purchaseorder:approvestatus:approvestatus:PurchaseOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_purchaseorder:approvestatus:approvestatus%') ;
delimiter;


insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence)
select 35,'NewPurchaseOrderAmount','fixedstr','ld_purchaseorder.total','sum','index.php?pageto_module=PurchaseOrder&pageto_action=index',24 from dual 
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='NewPurchaseOrderAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPurchaseOrderAmount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_purchaseorder:signed_data:signed_data%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_purchaseorder:approvestatus:approvestatus:PurchaseOrder_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_purchaseorder:approvestatus:approvestatus%') ;
delimiter;

update ld_homestuffdetail set presence='yes' where presence is null or presence='';
delimiter;
update ld_templatesstuff set stuffid=35 where stuffid=36;
delimiter;

SET @templateids=IFNULL((SELECT GROUP_CONCAT(templateid) FROM (SELECT templateid from ld_templatesstuff where stuffid=35 GROUP BY templateid HAVING count(stuffid)>1) a),'');
DELETE FROM ld_templatesstuff WHERE FIND_IN_SET(templateid,@templateids) AND stufftitle='STATISTICALWEEKMONTH';
delimiter;


update ld_homestuffdetail set cssname='item-ico-account' where stufflabel like '%accounts%';
update ld_homestuffdetail set cssname='item-ico-contacts' where stufflabel like '%contacts%';
update ld_homestuffdetail set cssname='item-ico-contactrecords' where stufflabel like '%ContactRecords%';
update ld_homestuffdetail set cssname='item-ico-salesorder' where stufflabel like '%salesorder%';
update ld_homestuffdetail set cssname='item-ico-servicecontracts' where stufflabel like '%servicecontracts%';
update ld_homestuffdetail set cssname='item-ico-potentials' where stufflabel like '%potentials%';
update ld_homestuffdetail set cssname='item-ico-sign' where stufflabel ='NewSignCount';
update ld_homestuffdetail set cssname='item-ico-cashbill' where stufflabel like '%cashbill%';
update ld_homestuffdetail set cssname='item-ico-leads' where stufflabel like '%leads%';
update ld_homestuffdetail set cssname='item-ico-helpdesk' where stufflabel like '%helpdesk%';
update ld_homestuffdetail set cssname='item-ico-potentials-salesstage' where stufflabel = 'ChangePotentialStageCount';

update ld_homestuffdetail set cssname='item-ico-salesorder' where stufflabel = 'SignContractCount';
update ld_homestuffdetail set cssname='item-ico-salesorder' where stufflabel = 'SignContractAmount';
update ld_homestuffdetail set cssname='item-ico-invoice' where stufflabel = 'NewInvoiceCount';
update ld_homestuffdetail set cssname='item-ico-invoice' where stufflabel = 'NewInvoiceAmount';
update ld_homestuffdetail set cssname='item-ico-purchaseorder' where stufflabel = 'NewPurchaseOrderCount';
update ld_homestuffdetail set cssname='item-ico-purchaseorder' where stufflabel = 'NewPurchaseOrderAmount';
update ld_homestuffdetail set cssname='item-ico-outboundorder' where stufflabel = 'NewOutboundOrderCount';
update ld_homestuffdetail set cssname='item-ico-outboundorder' where stufflabel = 'NewOutboundOrderAmount';
delimiter;

update ld_desk set fieldlabel='{$OutboundOrder.OutboundOrder}金额' where labelbol='NewOutboundOrderAmount' 
and languagetype='zh'  and Labeltype='fixedstr';
delimiter;



SET @report_name='电话录音盒呼叫中心报表';
SET @report_type='template_js';
SET @report_template='default_callbutler_detail.mrt';
SET @databasetype='crmlink';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='呼叫中心报表');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info);

INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,@databasetype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;



SET @report_name='成员使用分析';
SET @report_type='template_js';
SET @report_template='default_userlogin_info.mrt';
SET @databasetype='crmlink';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info);

INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,@databasetype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;


SET @report_name='成员使用监测';
SET @report_type='template_js';
SET @report_template='default_userlogin_fenxi.mrt';
SET @databasetype='crmlink';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info);

INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,@databasetype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;
-- 2020-04-28

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='NewPotentialsAmount' ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:createdtime:createdtime:Potentials_fieldlabel:DT','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:createdtime:createdtime%' ) ;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_potentials:approvestatus:approvestatus:Potentials_fieldlabel:V','','' from dual 
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_potentials:approvestatus:approvestatus%') ;
delimiter;

update ld_desk set fieldlabel='新建{$Potentials.Potentials}金额' where languagetype='zh' and labelbol='NewPotentialsAmount' and Labeltype='fixedstr';
delimiter;

UPDATE ld_homestuffdetail SET presence='no';
UPDATE ld_homestuffdetail SET presence='yes' WHERE stufflabel IN ('NewAccounts','NewContactRecords','SignContractAmount',
	'NewInvoiceAmount','NewOutboundOrderAmount','NewCashBillAmount','NewPotentialsCount','NewPotentialsAmount');

SET @i=0;
SET @j=0;
UPDATE ld_homestuffdetail SET sequence=sequence+100;
UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE presence='yes' ORDER BY FIELD(stufflabel,'SignContractAmount','NewInvoiceAmount',
	'NewCashBillAmount','NewOutboundOrderAmount','NewAccounts','NewContactRecords','NewPotentialsCount','NewPotentialsAmount');
UPDATE ld_homestuffdetail SET sequence=(@j:=@j+1) ORDER BY sequence;
delimiter;
-- 2020-04-29


UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);
UPDATE ld_links_seq SET id=(SELECT MAX(linkid) FROM ld_links);
UPDATE ld_picklist_dependency_seq SET id=(SELECT MAX(id) FROM ld_picklist_dependency);
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) FROM ld_autotask);
UPDATE ld_currency_info_seq SET id=(SELECT MAX(id) FROM ld_currency_info);
UPDATE ld_users_seq SET id=(SELECT MAX(id) FROM ld_users);
UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);
UPDATE ld_customreport_info_seq SET id=(SELECT MAX(report_id) FROM ld_customreport_info);
UPDATE ld_producttoolfield_seq SET id=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
UPDATE ld_workreport_field_seq SET id=(SELECT MAX(id) FROM ld_workreport_field);
delimiter;

UPDATE ld_version SET old_version='V8.0.0.10',current_version='V8.0.0.10',remark='V8.0.0.10-20200429',wx_version='V8.0.0.9.2';
delimiter;