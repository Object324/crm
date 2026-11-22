update ld_cvcolumnlist left join ld_customview on ld_cvcolumnlist.cvid = ld_customview.cvid  set columnname = 'LD_products:smownerid:prosmownerid:Products_Handler:V' 
where columnname like '%LD_products:smownerid:assigned_user_id:Products_%' and entitytype = 'Products';

delete ld_cvcolumnlist.* from ld_cvcolumnlist left join ld_customview on ld_cvcolumnlist.cvid = ld_customview.cvid 
where columnname like '%LD_warehouse2products:warehouseid:warehouseid:InventoryQuery_%' and entitytype = 'Products';
update ld_tab set ownedby=0,customized=0 where name='Commission';

call addcolumn('ld_servicetype','weight','int',19,0);
alter table ld_servicetype modify weight decimal(25,2);
delimiter;

UPDATE ld_desk SET 
fieldlabel='1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重*0.01 + {$Accounts.bill_city}绩效基数)*{$HelpDesk.servicetype}*0.01' 
WHERE labelbol='Performance_scores_1' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET 
fieldlabel='1.	Performance scores of {$HelpDesk.HelpDesk}=scores of ({$HelpDesk.productcategory} * {$HelpDesk.ticketcategories} * weight*0.01+ scores of {$Accounts.bill_city})*{$HelpDesk.servicetype}*0.01' 
WHERE labelbol='Performance_scores_1' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

update ld_systems_deploy set description = '出库单或入库单更新库存流水记录触发点 0：审核  1：保存' where deploy_type = 48;
delimiter;

update ld_field set sequence=sequence+10 where tabid=18 and block=42;
update ld_field set sequence=1 where tabid=18 and columnname='vendorname';
update ld_field set sequence=2 where tabid=18 and columnname='vendor_no';
update ld_field set sequence=100 where tabid=18 and columnname='smownerid';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=18 and block=42 order by sequence,fieldid;
delimiter;

update ld_tab set printtab=0 where `name` in ( 'Commission','CashDeposit','PutCash');
update ld_tab set printtab=1 where `name` in ('Expense');

DELETE FROM ld_desk WHERE labelbol = 'Thepotentialhasbeencreatedreceivablesforecast' and labeltype='jspop';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thepotentialhasbeencreatedreceivablesforecast','该{$Potentials.Potentials}已创建回款预测或金额为0','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thepotentialhasbeencreatedreceivablesforecast' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thepotentialhasbeencreatedreceivablesforecast','The {$Potentials.Potentials} has been created receivables forecast or the amount of 0','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thepotentialhasbeencreatedreceivablesforecast' and Labeltype='jspop');
delimiter;
-- 2014-11-26

UPDATE ld_field SET quickcreate=0,quickcreatesequence=6 where tabid=(SELECT tabid FROM ld_tab WHERE name='ContactRecords') AND columnname='nextcontactdate';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '',56,'合同订单新增保存后是否自动生成出库单。仓库名称为空:否，仓库名称不为空:是','' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=56);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 1,57,'合同订单保存后是否立即打印。1:否，0:是','' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=57);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AFTERCREATESALESORDERCREATEOUTORDER','{$SalesOrder.SalesOrder}新增保存后自动创建{$OutboundOrder.OutboundOrder}，关联仓库（为空表示不创建）','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTERCREATESALESORDERCREATEOUTORDER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AFTERCREATESALESORDERCREATEOUTORDER','After creating salesorder create outbound order automaticly，the related warhouse is','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTERCREATESALESORDERCREATEOUTORDER' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AFTERCREATESALESORDERPRINT','{$SalesOrder.SalesOrder}保存后是否立即打印','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTERCREATESALESORDERPRINT' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AFTERCREATESALESORDERPRINT','After creating salesorder print immediately','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTERCREATESALESORDERPRINT' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SELECTWAREHOUSE','选择仓库','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='SELECTWAREHOUSE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SELECTWAREHOUSE','Select Warehouse','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='SELECTWAREHOUSE' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AUTOCREATECHUKUCHAN','自动创建出库单时检测到','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AUTOCREATECHUKUCHAN' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AUTOCREATECHUKUCHAN','Automatically create Chukuchan detected','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AUTOCREATECHUKUCHAN' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DISABLEDPLEASECHOOSEWAREHOUSE','已禁用，请选择出库仓库','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='DISABLEDPLEASECHOOSEWAREHOUSE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DISABLEDPLEASECHOOSEWAREHOUSE','Disabled, please choose outbound warehouse','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='DISABLEDPLEASECHOOSEWAREHOUSE' and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'adjustment','LD_outboundorder',1,72,'txtAdjustment','Adjustment',1,2,
'',100,16,@blockid,3,'NN~O',3,null,'BAS',1,
null,0,null,1,1,0,0
from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'adjustment');
delimiter;

select tabid into @tabid from ld_tab where name = 'Campaigns';
select tabid into @tabid2 from ld_tab where name = 'Accounts';
select tabid into @tabid3 from ld_tab where name = 'Potentials';
update ld_quickactions set sequence=sequence+2 where tabid=@tabid;

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,0,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid3,1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid3);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,58,'服务合同新增保存后是否立即创建回款计划 1：否，0：是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=58);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,59,'服务合同回款计划总额必须等于订单金额 1：否，0：是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=59);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WTCPPIACSS',
'{$ServiceContracts.ServiceContracts}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WTCPPIACSS' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WTCPPIACSS',
'Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$ServiceContracts.ServiceContracts}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WTCPPIACSS' 
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WTTPPMBETTAOOWTCPPTTMOSS',
'在{$ServiceContracts.ServiceContracts}模块创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总额必须等于订单金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WTTPPMBETTAOOWTCPPTTMOSS' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WTTPPMBETTAOOWTCPPTTMOSS',
'Whether the total {$PaymentPlan.PaymentPlan} must be equal to the amount of orders when to create {$PaymentPlan.PaymentPlan} through the module of {$ServiceContracts.ServiceContracts}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WTTPPMBETTAOOWTCPPTTMOSS' 
and Labeltype='fixedstr');
delimiter;

SELECT tabid into @tabid from ld_tab where name='PaymentPlan'; 
SELECT blockid INTO @block FROM ld_blocks WHERE tabid=64 AND blocklabel='LBL_PaymentPlan_INFORMATION'; 
SELECT max(fieldid) into @fieldid from ld_field; 

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,
block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked) 
select @tabid,@fieldid+1,'entitytypeid','LD_paymentplan',1,102,'entitytypeid','entitytypeid',1,2,100,3,@block,1,'V~M',3,3,'BAS',2,'',0,NULL,1,1,0,0 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'entitytypeid'); 
update ld_field_seq set id = (select max(fieldid) from ld_field); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'entitytypeid'; 

delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid; 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@fieldid,'相关对象'; 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@fieldid,'Related To'; 

DELETE FROM ld_field WHERE tabid=@tabid AND columnname='salesorderid';

call AddColumn('LD_paymentplan','entitytypeid','int','19',0); 
delimiter;

call AddColumn('LD_paymentplan','entitytype','varchar','100',NULL); 
delimiter;

call fieldprofile('PaymentPlan');
delimiter;
call getallprofile('PaymentPlan');
delimiter;

update LD_paymentplan set entitytypeid=salesorderid WHERE salesorderid>0; 
update LD_paymentplan set entitytype='SalesOrder' WHERE salesorderid>0; 
delimiter;

SELECT tabid into @tabid from ld_tab where name='PaymentPlan';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='entitytypeid';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'PaymentPlan',
'SalesOrder',0,0  from dual where not exists (select * from LD_fieldmodulerel where module = 'PaymentPlan' and fieldid = @fieldid and relmodule='SalesOrder');
delimiter;

SELECT presence INTO @presence FROM ld_tab WHERE name='ServiceContracts';
SELECT tabid into @tabid from ld_tab where name='PaymentPlan';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='entitytypeid';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'PaymentPlan',
'ServiceContracts',0,@presence  from dual where not exists (select * from LD_fieldmodulerel where module = 'PaymentPlan' and fieldid = @fieldid and relmodule='ServiceContracts');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SERVICECONTRACTSRESULTAMOUNT',
'{$ServiceContracts.ServiceContracts}金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SERVICECONTRACTSRESULTAMOUNT' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SERVICECONTRACTSRESULTAMOUNT',
'{$ServiceContracts.ServiceContracts} Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICECONTRACTSRESULTAMOUNT' 
and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select tabid into @related_tabid from ld_tab where `name` = 'PaymentPlan';
select id into @relation_id from ld_relatedlists_seq;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@related_tabid,'get_paymentplan',1,'PaymentPlan',0,'add' from dual 
where not EXISTS(select 1 from LD_relatedlists  where related_tabid = @related_tabid and tabid = @tabid); 
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','amountreceived1',
'已收金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='amountreceived1' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','amountreceived1',
'amount received','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='amountreceived1' 
and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='应收款统计表_按订单统计' WHERE labelbol='CashBillSum_SalesOrder' AND Labeltype='fixedstr' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='Statistics of receivables acc to order' WHERE labelbol='CashBillSum_SalesOrder' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='CashBillSum_Paymentplan';

UPDATE ld_usereportcolumns SET columns='LD_paymentplan:salesorderid:salesorder_id:OftenUseReport_salesorder:I',
realcolumns='LD_paymentplan:salesorderid:salesorder_id:OftenUseReport_订单主题:I',
realencolumns='LD_paymentplan:salesorderid:salesorder_id:OftenUseReport_order:I' 
WHERE columns LIKE 'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan%' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单编号:V',
realencolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_order no:V' 
WHERE columns LIKE 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder%' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_订单合计:N',
realencolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_Order Total:N' 
WHERE columns LIKE 'LD_salesorder:total:hdnGrandTotal:SalesOrder%' AND Usereportid=@usereportid;
delimiter;


SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='CashBillSum_SalesOrder';

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单编号:V',
realencolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_Order No:V' 
WHERE columns LIKE 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_%' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:subject:subject:SalesOrder_订单_主题:V',
realencolumns='LD_salesorder:subject:subject:SalesOrder_Order Subject:V' 
WHERE columns LIKE 'LD_salesorder:subject:subject:SalesOrder_%' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:accountid:account_id:SalesOrder_订单_客户名称:I',
realencolumns='LD_salesorder:accountid:account_id:SalesOrder_AccountName:I' 
WHERE columns LIKE 'LD_salesorder:accountid:account_id:SalesOrder_%' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:sostatus:sostatus:SalesOrder_订单_订单状态:V',
realencolumns='LD_salesorder:sostatus:sostatus:SalesOrder_order status:V' 
WHERE columns LIKE 'LD_salesorder:sostatus:sostatus:SalesOrder_%' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_订单_合计:N',
realencolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_order total:N' 
WHERE columns LIKE 'LD_salesorder:total:hdnGrandTotal:SalesOrder_%' AND Usereportid=@usereportid;
delimiter;

SELECT tabid into @tabid from ld_tab where name='ContactRecords';
update ld_field set uitype='86',typeofdata='DT~M' where tabid=@tabid and columnname='nextContactDate';
delimiter;
-- 2014-11-28

update ld_field set displaytype=2 where tabid=6 and columnname='servicecasher' and exists(select 1 from ld_version where versiontype in (1,10));

update ld_desk set Fieldlabel='转换负责人为' where labelbol='RESPONSIBLEFORCONVERSION' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Transfer ownership to' where labelbol='RESPONSIBLEFORCONVERSION' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ORDER',
'订单','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ORDER' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ORDER',
'order','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ORDER' 
and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_productbom` (
  `productbomid` int(11) NOT NULL default '0',
  `subject` varchar(100) default NULL,
  `productbom_no` varchar(100) default NULL,
  `productbomdate` date default NULL,
  `adjustment` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `total` decimal(25,2) default NULL,
  `currency_id` int(11) NOT NULL default '1',
  `conversion_rate` decimal(25,3) default NULL,
  `smownerid` int(11) default '0',
  `smcreatorid` int(11) default '0',
  `modifiedby` int(11) default '0',
  `createdtime` datetime default NULL,
  `modifiedtime` datetime default NULL,
  `deleted` int(1) default '0',
  `description` text,
  PRIMARY KEY  (`productbomid`),
  KEY `fk_2_ldcrm_productbom` USING BTREE (`productbomid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_productbomcf` (
  `productbomid` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;

SELECT COUNT(id) INTO @versionid FROM ld_version WHERE versiontype = 1;
SELECT CASE WHEN @versionid > 0 THEN 0 ELSE 1 END INTO @presence;

insert into ld_tab(tabid,name,presence,tabsequence,tablabel,ownedby,isentitytype,parent,printtab)
select @tabid,'Productbom',@presence,@tabsequence+1,'Productbom',0,1,'Tools',0
from dual where not EXISTS(select 1 from ld_tab where tablabel ='Productbom');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Tools';
SELECT tabid INTO @prodtabid FROM ld_tab WHERE NAME = 'Products';

SELECT sequence INTO @seq FROM ld_parenttabrel WHERE parenttabid = @parenttabid AND tabid = @prodtabid;
SELECT @seq+1 INTO @seq1;
UPDATE ld_parenttabrel SET sequence = (@seq1:=@seq1+1) WHERE parenttabid = @parenttabid AND sequence > @seq ORDER BY sequence;
UPDATE ld_parenttabrel SET sequence = @seq+2 WHERE parenttabid = @parenttabid AND sequence = @seq and tabid != @prodtabid ORDER BY sequence;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@seq+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'产品套餐'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='产品套餐');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Products BOM'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='Products BOM');

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'Productbom','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'Productbom' );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
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
select @ruleid+1,@tabid,0,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'Productbom',0,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All'
and entitytype ='Productbom');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Productbom' and viewname = 'All';
select tabid into @tabid from ld_tab where `name`='Productbom';
delete from ld_tabwithproductview where cvid =  @cvid;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_productbom:productbom_no:productbom_no:Productbom_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_productbom:productbom_no:productbom_no:Productbom_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_productbom:subject:subject:Productbom_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_productbom:subject:subject:Productbom_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_productbom:total:total:Productbom_fieldlabel:I',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_productbom:total:total:Productbom_fieldlabel:I');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_productbom:smownerid:smownerid:Productbom_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_productbom:smownerid:smownerid:Productbom_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:productcategory:productcategory:Products_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:productcategory:productcategory:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:productname:productname:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:N');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:usageunit:usageunit:Products_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:usageunit:usageunit:Products_fieldlabel:V');

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PRODUCTBOM_INFO',1 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_PRODUCTBOM_INFO');
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PRODUCTBOM_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

DELETE from ld_field where tabid = @tabid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+1,'subject','LD_productbom',2,'subject','主题',@blockid,1,0,'V~M' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'subject');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+1,'主题'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+1,'Bom Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,masseditable)
select @tabid,@fieldid+2,'productbom_no','LD_productbom',4,'productbom_no','Bom No',@blockid,1,0,'V~O',2 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'productbom_no');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+2,'套餐编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+2,'Bom No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+3,'currency_id','LD_productbom',117,'currency_id','货币',@blockid,3,0,'I~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+3,'货币'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+3);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+3,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+3);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+4,'conversion_rate','LD_productbom',1,'conversion_rate','汇率',@blockid,3,0,'I~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'conversion_rate');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+4,'汇率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+4);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+4,'Exchange Rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+4);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid)
select @tabid,@fieldid+5,'smownerid','LD_productbom',53,'assigned_user_id','负责人',@blockid,1,0,'V~M',1 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+5,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+5);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+5,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+5);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+6,'subtotal','LD_productbom',72,'hdnSubTotal','Sub Total',@blockid,3,0,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+6,'小计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+6);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+6,'Sub Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+6);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+7,'total','LD_productbom',72,'hdnGrandTotal','Total',@blockid,3,0,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+7,'合计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+7);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+7,'Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+7);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+8,'createdtime','LD_productbom',70,'createdtime','创建时间',@blockid,2,0,'DT~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+8,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+8);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+8,'Created Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+8);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+9,'modifiedtime','LD_productbom',70,'modifiedtime','修改时间',@blockid,2,0,'DT~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+9,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+9);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+9,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+9);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+10,'modifiedby','LD_productbom',52,'modifiedby','最新更新人',@blockid,3,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+10,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+10);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+10,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+10);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+11,'smcreatorid','LD_productbom',52,'smcreatorid','创建人',@blockid,2,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+11,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+11);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+11,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+11);

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'Description',3 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'Description');
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'Description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'备注信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+12,'description','LD_productbom',19,'description','备注',@blockid,1,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'description');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+12,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+12);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+12,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+12);

update ld_field_seq set id = (select max(fieldid) from ld_field);

select tabid into @tabid from ld_tab where `name` = 'Productbom';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'Productbom';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid
and visible =1);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADDPRODUCTBOM','新增','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADDPRODUCTBOM' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADDPRODUCTBOM','Add','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADDPRODUCTBOM' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PRODUCTBOMDETAILS','采购发票明细','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PRODUCTBOMDETAILS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PRODUCTBOMDETAILS','Purchase Invoice Details','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PRODUCTBOMDETAILS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
select tabid into @related_tabid from ld_tab where `name` = 'Productbom';

delete from ld_relatedlists where tabid = @tabid and name in ('get_products','get_parent_products');

select id into @id from ld_relatedlists_seq;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_productbom',@sequence+1,'Productbom','add'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'Productbom','LD_productbom','subject','productbomid','productbomid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='Productbom');
delimiter;


CALL fieldprofile('Productbom');
CALL getallprofile('Productbom');
CALL addtabintoprofile('Productbom',0);
CALL addModuleActivity('Productbom',6);
select tabid into @tabid from ld_tab where `name` = 'Productbom';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);
delimiter;

SELECT MAX(relation_id) INTO @relationid FROM ld_relatedlists;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='Productbom';

SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='Attachment';
INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+1,@tabid,@relatedtabid,'get_attachment',1,'Attachment',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_attachment' AND tabid=@tabid);

UPDATE lD_relatedLists_seq SET id = (@relationid+1);
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Productbom';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE NAME = 'Attachment';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@tabid2,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=@tabid2);

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,isallow)
select (select max(num_id)+1 from ld_modentity_num),'Productbom','BOM',1,1,1,'none',2
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'Productbom'
and prefix ='BOM');
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
SELECT roleid INTO @roleid FROM ld_user2role INNER JOIN ld_users ON ld_users.`id` = ld_user2role.`userid` WHERE user_name = 'admin';
SELECT profileid INTO @profileid FROM ld_role2profile WHERE roleid = @roleid;
UPDATE LD_profile2tab SET permissions = 0 WHERE tabid = @tabid AND profileid = @profileid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Productbom';
SELECT roleid INTO @roleid FROM ld_user2role INNER JOIN ld_users ON ld_users.`id` = ld_user2role.`userid` WHERE user_name = 'admin';
SELECT profileid INTO @profileid FROM ld_role2profile WHERE roleid = @roleid;
UPDATE LD_profile2utility SET permission = 0 WHERE profileid = @profileid AND tabid = @tabid AND activityid = 6;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','COMMODITYPRICELABEL','商品总价','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='COMMODITYPRICELABEL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','COMMODITYPRICELABEL','Commodity Price','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='COMMODITYPRICELABEL' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PACKAGEPRICELABEL','套餐售价','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='PACKAGEPRICELABEL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PACKAGEPRICELABEL','Package price','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='PACKAGEPRICELABEL' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SAVEANDSELECT','保存并选择','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SAVEANDSELECT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SAVEANDSELECT','Save and Select','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SAVEANDSELECT' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','CONFIRMANDSELECT','确认并选择','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='CONFIRMANDSELECT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','CONFIRMANDSELECT','Confirm and Select','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='CONFIRMANDSELECT' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PLEASESELECTPRODUCT','请至少选择 一个产品!','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='PLEASESELECTPRODUCT' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PLEASESELECTPRODUCT','Please select at least one product!','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='PLEASESELECTPRODUCT' AND Labeltype='jspop');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','NUMBEROFCOPIES','套餐份数','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='NUMBEROFCOPIES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','NUMBEROFCOPIES','Set the number of copies','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='NUMBEROFCOPIES' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SAMENUMBEROFCOPIES','相同份数','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SAMENUMBEROFCOPIES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SAMENUMBEROFCOPIES','The same number of copies','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SAMENUMBEROFCOPIES' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','NUMBEROFDIFFERENT','不同份数','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='NUMBEROFDIFFERENT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','NUMBEROFDIFFERENT','A number of different','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='NUMBEROFDIFFERENT' AND Labeltype='fixedstr');
DELIMITER;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PRODUCTBOMNAME','套餐名称','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='PRODUCTBOMNAME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PRODUCTBOMNAME','Bom Name','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='PRODUCTBOMNAME' AND Labeltype='fixedstr');
DELIMITER;
-- 2014-12-02


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONTRACTNO','单据号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CONTRACTNO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONTRACTNO','Contract No','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONTRACTNO' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DATEOFCONTRACT','签约日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DATEOFCONTRACT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DATEOFCONTRACT','Date of contract','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DATEOFCONTRACT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONTRACTAMOUNTRE','合同金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CONTRACTAMOUNTRE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONTRACTAMOUNTRE','Contract Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONTRACTAMOUNTRE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOTALINVOICE','开票总额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TOTALINVOICE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOTALINVOICE','Total Invoice','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TOTALINVOICE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LATESTINVOICEDATE','最近开票日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LATESTINVOICEDATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LATESTINVOICEDATE','Latest invoice date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LATESTINVOICEDATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOTALRECEIVES','已收总额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TOTALRECEIVES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOTALRECEIVES','Total receives','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TOTALRECEIVES' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LATESTCOLLECTION','最近收款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LATESTCOLLECTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LATESTCOLLECTION','Latest collection date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LATESTCOLLECTION' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NODATAFOUND','没有找到任何记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NODATAFOUND' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NODATAFOUND','No data found','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NODATAFOUND' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RELATEDORDERSINFORMATION','源单信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RELATEDORDERSINFORMATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RELATEDORDERSINFORMATION','Related Orders Information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RELATEDORDERSINFORMATION' and Labeltype='fixedstr');
delimiter;

UPDATE ld_Desk set fieldlabel='在{$ServiceContracts.ServiceContracts}模块创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总额必须等于{$ServiceContracts.ServiceContracts}金额' where labelbol='WTTPPMBETTAOOWTCPPTTMOSS';
delimiter;
-- 2014-12-04


UPDATE LD_cvcolumnlist SET columnname='LD_paymentplan:entitytypeid:entitytypeid:PaymentPlan_entitytypeid:I' 
WHERE columnname='LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_Sales_Order:V' AND LD_cvcolumnlist.cvid in 
(SELECT cvid FROM LD_customview WHERE entitytype='PaymentPlan');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Productbom';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'subject';
UPDATE ld_tranlabel SET fieldlabel = '套餐名称' WHERE relateid = @fieldid AND languagetype = 'zh';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Productbom';
UPDATE ld_field SET fieldonly = 1 WHERE tabid = @tabid AND columnname = 'subject';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Productbom';
UPDATE ld_tabwithproductview SET `columns` = 'LD_productbom:total:hdnGrandTotal:Productbom_fieldlabel:I' WHERE tabid = @tabid
AND `columns` = 'LD_productbom:total:total:Productbom_fieldlabel:I';
UPDATE ld_tabwithproductview SET `columns` = 'LD_productbom:smownerid:assigned_user_id:Productbom_fieldlabel:V' WHERE tabid = @tabid
AND `columns` = 'LD_productbom:smownerid:smownerid:Productbom_fieldlabel:V';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Productbom';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'subtotal';
UPDATE ld_tranlabel SET fieldlabel = '商品总价' WHERE relateid = @fieldid AND languagetype = 'zh';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'total';
UPDATE ld_tranlabel SET fieldlabel = '套餐售价' WHERE relateid = @fieldid AND languagetype = 'zh';
delimiter;

update ld_desk set Fieldlabel='要删除的部门' where labelbol='TODELETEGROUP' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Group to be Deleted' where labelbol='TODELETEGROUP' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Documents';
UPDATE ld_field SET tablename = 'LD_notes' WHERE tabid = @tabid AND columnname IN ('approvestatus','approveby');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PRODUCTNAME','产品名称','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PRODUCTNAME' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PRODUCTNAME','Product Name','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PRODUCTNAME' and Labeltype='jspop');
delimiter;

SELECT tabid INTO @bom_tabid FROM ld_tab WHERE NAME = 'Productbom';
SELECT tabid,tabsequence INTO @pro_tabid,@pro_seq FROM ld_tab WHERE NAME = 'Products';
SELECT @pro_seq+1 INTO @seq;
UPDATE ld_tab SET tabsequence = (@seq:=@seq+1) WHERE tabsequence > @pro_seq ORDER BY tabsequence;
UPDATE ld_tab SET tabsequence = @pro_seq+2 WHERE tabsequence = @pro_seq AND tabid != @pro_tabid ORDER BY tabsequence;
UPDATE ld_tab SET tabsequence = @pro_seq+1 WHERE tabid = @bom_tabid;
delimiter;
-- 2014-12-05

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Productbom';
UPDATE ld_entityname SET fieldname = 'productbom_no' WHERE tabid = @tabid;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'ModComments';
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_OTHER_INFORMATION';
SELECT MAX(fieldid) INTO @fieldid FROM ld_field;
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata)
SELECT @tabid,@fieldid+1,'reltab','LD_modcomments',1,1,'reltab','相关模块',1,@blockid,3,2,'M' FROM DUAL WHERE NOT EXISTS
(SELECT * FROM ld_field WHERE tabid = @tabid AND columnname = 'reltab');
UPDATE ld_field_seq SET id = (SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','LD_field',@tabid,@fieldid+1,'相关模块'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'zh'
AND trantable ='LD_field' AND tabid = @tabid AND relateid=@fieldid+1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','LD_field',@tabid,@fieldid+1,'Related modules'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'en'
AND trantable ='LD_field' AND tabid = @tabid AND relateid=@fieldid+1);
delimiter;
CALL AddColumn('LD_modcomments','reltab','varchar','100',NULL);
delimiter;

UPDATE LD_modcomments INNER JOIN ld_crmentity ON ld_crmentity.`crmid` = LD_modcomments.`related_to`
SET LD_modcomments.reltab = ld_crmentity.`setype`
WHERE LD_modcomments.`related_to` > 0 and (LD_modcomments.reltab IS NULL OR LD_modcomments.reltab = '');
delimiter;

select sequence into @sequence from ld_blocks where tabid = 6 and blocklabel = 'LBL_INTEGRAL_INFOMATION';
update ld_blocks set sequence = sequence+1 where tabid = 6 and sequence > @sequence;
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,6,'LBL_INTEGRAL_INFOMATION',@sequence+1 from dual where not exists (select * from ld_blocks where 
tabid = 6 and blocklabel = 'LBL_INTEGRAL_INFOMATION');
select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_INTEGRAL_INFOMATION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',6,@blockid,'积分信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = 6 and fieldlabel='积分信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',6,@blockid,'Integral Infomation' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = 6 and fieldlabel='Integral Infomation');
delimiter;

select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_INTEGRAL_INFOMATION';

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 6,(select max(fieldid) from ld_field)+1,'totalintegral','LD_account',2,7,'totalintegral','Total Integral',1,2,
'',100,1,@blockid,2,'NN~O~19,0',1,0,'BAS',1,
null,0,0,null,null,0,0
from dual where not exists (select * from ld_field where tabid = 6 and columnname = 'totalintegral');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 6,(select max(fieldid) from ld_field)+1,'consumedintegral','LD_account',2,7,'consumedintegral','Consumed Integral',1,2,
'',100,2,@blockid,2,'NN~O~19,0',1,0,'BAS',1,
null,0,0,null,null,0,0
from dual where not exists (select * from ld_field where tabid = 6 and columnname = 'consumedintegral');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 6,(select max(fieldid) from ld_field)+1,'expiredintegral','LD_account',2,7,'expiredintegral','Expired Integral',1,2,
'',100,3,@blockid,2,'NN~O~19,0',1,0,'BAS',1,
null,0,0,null,null,0,0
from dual where not exists (select * from ld_field where tabid = 6 and columnname = 'expiredintegral');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 6,(select max(fieldid) from ld_field)+1,'availableintegral','LD_account',2,7,'availableintegral','Available Integral',1,2,
'',100,4,@blockid,2,'NN~O~19,0',1,0,'BAS',1,
null,0,0,null,null,0,0
from dual where not exists (select * from ld_field where tabid = 6 and columnname = 'availableintegral');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 6 and fieldname = 'totalintegral';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',6,@fieldid,'积分总额' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',6,@fieldid,'Total Integral' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid );

select fieldid into @fieldid from ld_field where tabid = 6 and fieldname = 'consumedintegral';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',6,@fieldid,'消费积分' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',6,@fieldid,'Consumed Integral' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid );

select fieldid into @fieldid from ld_field where tabid = 6 and fieldname = 'expiredintegral';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',6,@fieldid,'过期积分' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',6,@fieldid,'Expired Integral' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid );

select fieldid into @fieldid from ld_field where tabid = 6 and fieldname = 'availableintegral';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',6,@fieldid,'可用积分' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',6,@fieldid,'Available Integral' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 6 and relateid=@fieldid );
delimiter;


call AddColumn('LD_account','totalintegral','int','19',0); 
delimiter;
call AddColumn('LD_account','consumedintegral','int','19',0); 
delimiter;
call AddColumn('LD_account','expiredintegral','int','19',0); 
delimiter;
call AddColumn('LD_account','availableintegral','int','19',0); 
delimiter;
call fieldprofile('Accounts');
delimiter;
call getallprofile('Accounts');
delimiter;

select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_INTEGRAL_INFOMATION';
update ld_blocks set visible = 1 where tabid = 6 and blocklabel = 'LBL_INTEGRAL_INFOMATION' 
and not EXISTS (select 1 from ld_version where trade = 'fund');
update ld_field set readonly = 0,presence = 1 where tabid = 6 and block = @blockid
and not EXISTS (select 1 from ld_version where trade = 'fund');
delimiter;

call AddColumn('LD_campaign','autocreate','int','1',0); 
delimiter;

call fieldprofile('Campaigns');
delimiter;

call getallprofile('Campaigns');
delimiter;

call AddColumn('LD_inventoryproductrel','isintegralset','int','1',0); 
delimiter;

call AddColumn('LD_version','account','varchar','100',null); 
delimiter;

CREATE TABLE IF NOT EXISTS `ld_handleintegral` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `accountid` int(19) DEFAULT '0' COMMENT '客户ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOTALOTHER','合计','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TOTALOTHER'and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOTALOTHER','total','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TOTALOTHER'and Labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '10000',60,'基金行业兑换积分基础值','' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=60);
delimiter;
 
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AFTERCREATESALESORDERCREATEOUTORDER','基金行业兑换积分基础值','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTERCREATESALESORDERCREATEOUTORDER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AFTERCREATESALESORDERCREATEOUTORDER','After creating salesorder create outbound order automaticly，the related warhouse is','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTERCREATESALESORDERCREATEOUTORDER' and languagetype='en');
delimiter;
-- 2014-12-08

select tabid into @tabid from ld_tab where `name` = 'Events';
select fieldid into @fieldid  from ld_field where tabid = @tabid and fieldname = 'potential_id';
insert into LD_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM LD_def_org_field  WHERE tabid=@tabid AND
		fieldid=@fieldid);

select fieldid into @fieldid  from ld_field where tabid = @tabid and fieldname = 'visibility';
insert into LD_def_org_field(tabid,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM LD_def_org_field  WHERE tabid=@tabid AND
		fieldid=@fieldid);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Documents';
update ld_field set tablename = 'LD_notes' where tabid = @tabid and fieldname = 'approvestatus';
update ld_field set tablename = 'LD_notes' where tabid = @tabid and fieldname = 'approveby';
delimiter;

UPDATE LD_cvcolumnlist SET columnname='LD_paymentplan:entitytypeid:entitytypeid:PaymentPlan_entitytypeid:I' 
WHERE columnname like 'LD_paymentplan:salesorderid:salesorder_id:PaymentPlan_%' AND LD_cvcolumnlist.cvid in 
(SELECT cvid FROM LD_customview WHERE entitytype='PaymentPlan');
delimiter;

update ld_field set fieldonly=1 where tabid=29 and fieldname='last_name';
delimiter;

set @seq=0;
select sequence into @seq from ld_blocks where tabid=6 and blocklabel='LBL_ACCOUNT_INFORMATION';
update ld_blocks set sequence=sequence+1 where tabid=6 and sequence>@seq;
update ld_blocks set sequence=@seq+1,show_title=0 where tabid=6 and blocklabel='LBL_INTEGRAL_INFOMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=6 order by sequence,blockid;
delimiter;
-- 2014-12-10

update ld_desk set fieldlabel='合同' where labelbol='ORDER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Receivables(by ' where labelbol='RECEIVEBY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Payable(by ' where labelbol='PAYABLEBY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Payable & Receivable Summary' where labelbol='RECEIVESUMMARY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Public Announcement' where labelbol='PUBLICANNOUNCEMENT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Collection amount' where labelbol='AMOUNTTO' and languagetype='en' and Labeltype='fixedstr';

update ld_customview set `status`=3 where `status`=0 and viewname='All';

update ld_desk set fieldlabel='{$PaymentPlan.PaymentPlan}是针对{$SalesOrder.SalesOrder}或{$ServiceContracts.ServiceContracts}的，不允许直接新增' 
where labelbol='How_to_create_plan1' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set fieldlabel='{$PaymentPlan.PaymentPlan} is for the {$SalesOrder.SalesOrder} or {$ServiceContracts.ServiceContracts}, direct creation is not allowed' 
where labelbol='How_to_create_plan1' and languagetype='en' and Labeltype='fixedstr';

update ld_desk set fieldlabel='可通过系统参数控制，新增{$SalesOrder.SalesOrder}或{$ServiceContracts.ServiceContracts}后自动弹出{$PaymentPlan.PaymentPlan}新增界面' 
where labelbol='How_to_create_plan2' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set fieldlabel='Can be controlled by the system parameters, after creating {$SalesOrder.SalesOrder} or {$ServiceContracts.ServiceContracts},create plans immediately' 
where labelbol='How_to_create_plan2' and languagetype='en' and Labeltype='fixedstr';

update ld_desk set fieldlabel='也可以通过{$SalesOrder.SalesOrder}或{$ServiceContracts.ServiceContracts}查看明细界面更多->创建{$PaymentPlan.PaymentPlan}增加' 
where labelbol='How_to_create_plan3' and languagetype='zh' and Labeltype='fixedstr';

update ld_desk set fieldlabel='You can view the {$SalesOrder.SalesOrder} or {$ServiceContracts.ServiceContracts} detailes and click the button More->Create {$PaymentPlan.PaymentPlan}' 
where labelbol='How_to_create_plan3' and languagetype='en' and Labeltype='fixedstr';

update ld_desk set fieldlabel='This page' where labelbol='TOTALTHIS' and languagetype='en';
update ld_desk set fieldlabel='应收款统计表_按合同统计' where labelbol='CashBillSum_SalesOrder' and languagetype='zh' and Labeltype='fixedstr';
update ld_tranlabel set fieldlabel='服务收费管理' where Relateid=@tabid and trantable='LD_tab' and languagetype='zh';

select usereportid into @reportid from ld_usereport where `name`='SalesOrderTrack';
update ld_usereportcolumns set Sequence=Sequence+50,columnshow=0 where Usereportid=@reportid;
update ld_usereportcolumns set Sequence=1, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id%';
update ld_usereportcolumns set Sequence=2, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data%';
update ld_usereportcolumns set Sequence=3, columnshow=1 where Usereportid=@reportid and `columns` like 'ld_servicecontracts:module_zh:module_zh:OftenUseReport_module_zh%';
update ld_usereportcolumns set Sequence=4, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no%';
update ld_usereportcolumns set Sequence=5, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_accountSalesOrder:accountid:account_id:SalesOrder_Account_Name%';
update ld_usereportcolumns set Sequence=6, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total%';
update ld_usereportcolumns set Sequence=7, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_reporttable:CashBillamount:%';
update ld_usereportcolumns set Sequence=8, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_reporttable:PaymentPlanBalance:%';
update ld_usereportcolumns set Sequence=9, columnshow=1 where Usereportid=@reportid and `columns` like 'LD_invoice:total:hdnGrandTotal:Invoice_Total:%';
update ld_usereportcolumns set Sequence=10,columnshow=1 where Usereportid=@reportid and `columns` like 'LD_reporttable:InvoiceBalance:%';
update ld_usereportcolumns set Sequence=11,columnshow=1 where Usereportid=@reportid and `columns` like 'LD_reporttable:Expenseamount:%';
update ld_usereportcolumns set Sequence=12,columnshow=1 where Usereportid=@reportid and `columns` like 'LD_commission2payment:amount:amount:OftenUseReport_Amount%';
update ld_usereportcolumns set Sequence=13,columnshow=1 where Usereportid=@reportid and `columns` like 'LD_salesorder:TotalCost:%';
update ld_usereportcolumns set Sequence=14,columnshow=1 where Usereportid=@reportid and `columns` like 'LD_salesorder:GrossProfit:%';
update ld_usereportcolumns set Sequence=15,columnshow=1 where Usereportid=@reportid and `columns` like 'LD_salesorder:GrossProfitl:%';
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid=@reportid order by Sequence;
delimiter; 

update ld_contactrecords set nextContactDate=NULL where IFNULL(nextContactDate,'1980-01-01 00:00:00')<'1990-01-01 00:00:00';
update ld_contactrecords set nextContactDate=NULL where nextContactDate='0000-00-00 00:00:00';
update ld_field set typeofdata='E~O' where tabid=29 and columnname='email1';

update ld_field set displaytype = 3 where tabid = 6 and fieldname = 'servicecasher';
delimiter;

DELETE FROM LD_templatesstuff where  stufftitle='最新销售订单';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Potentials';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'potential_no';
INSERT INTO ld_relatedlists_lable(tabid,fieldid,presence,sequence)
SELECT @tabid,@fieldid,1,1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid = @tabid AND fieldid = @fieldid);
SET @seq = 1;
UPDATE ld_relatedlists_lable SET sequence = (@seq:=@seq+1) WHERE sequence > 0 AND tabid = @tabid AND fieldid != @fieldid ORDER BY sequence;
delimiter;
-- 2014-12-12

UPDATE ld_cvcolumnlistsort SET columnname='LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel',sorttype='desc' 
WHERE cvid in (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder');

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='待审批'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='待审批'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已审批'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已审批'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已发货'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已发货'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已发货'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已作废'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='本月交付'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='本月交付'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='本月创建'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='本月创建'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='待采购'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='待采购'
));

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select (SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已采购'
),'LD_salesorder:signed_data:signed_data:SalesOrder_DT~O:fieldlabel','desc' from dual
where not EXISTS(select 1 from ld_cvcolumnlistsort  where cvid=(SELECT cvid FROM LD_customview WHERE entitytype='SalesOrder' AND viewname='已采购'
));
delimiter;

update ld_systems_deploy set deploy_value = 1 where deploy_type = 60;
delimiter;
-- 2014-12-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PRODUCTS','产品','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PRODUCTS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PRODUCTS','Products','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PRODUCTS' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CLEAR','清除','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CLEAR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CLEAR','Clear','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CLEAR' and Labeltype='jspop');
delimiter;

INSERT INTO ld_communicationaccount(accountid) 
SELECT '1' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_communicationaccount  WHERE accountid='1');
delimiter;
-- 2014-12-16

update ld_relatedlists set actions='add' where tabid=22 and `name`='get_tickets';
update ld_field set defaultvalue=NULL where tabid=(select tabid from ld_tab where `name` ='ContactRecords') and columnname='nextcontactdate';
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 1,61,'客户分配时，是否同时分配相关信息 1：否，0：是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=61);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ACCOUNTALSDISWHETHERDIS',
'{$Accounts.Accounts}分配时，是否同时分配相关信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ACCOUNTALSDISWHETHERDIS' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ACCOUNTALSDISWHETHERDIS',
'Distribute the related data when distribute {$Accounts.Accounts}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ACCOUNTALSDISWHETHERDIS' 
and Labeltype='fixedstr');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'SalesOrder';
SELECT tabid INTO @reltabid FROM ld_tab WHERE NAME = 'HelpDesk';
UPDATE ld_relatedlists SET actions = 'add' WHERE tabid = @tabid AND related_tabid = @reltabid;
delimiter;
-- 2014-12-17

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Project';
DELETE FROM ld_relatedlists WHERE tabid = @tabid AND NAME = 'get_gantt_chart';
delimiter;

delete from ld_relatedlists where tabid in(select tabid from ld_tab where name='vendors') and( label='Cashbill' or label='Expense');
delimiter;

SELECT GROUP_CONCAT(cvid) INTO @cvid FROM ld_customview WHERE entitytype = 'PaymentPlan';
DELETE FROM ld_cvcolumnlist WHERE FIND_IN_SET(cvid,@cvid) AND columnname = 'LD_paymentplan:entitytypeid:entitytypeid:PaymentPlan_entitytypeid:I';
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='Serviceperformanceappraisal';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid AND columns LIKE 'LD_troubletickets:projecttask_no:projecttask_no:HelpDesk_%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @usereportid, 'LD_troubletickets:servicetype:servicetype:HelpDesk_servicetype:V', @sequence, 1, 
'LD_troubletickets:servicetype:servicetype:HelpDesk_服务方式:V','LD_troubletickets:servicetype:servicetype:HelpDesk_Service Type:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@usereportid and 
realcolumns like 'LD_troubletickets:servicetype:servicetype:HelpDesk_%');

UPDATE ld_usereportbasic set Sequence=6 WHERE columns='LD_troubletickets:approvestatus:approvestatus:HelpDesk_approvestatus:I' AND Usereportid=@usereportid;

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@usereportid,'LD_troubletickets:servicetype:servicetype:HelpDesk_servicetype:I','',5  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@usereportid and Sequence=5);
delimiter;
-- 2014-12-19

select tabid into @tabid from ld_tab where name ='ServiceCharge';
update ld_tranlabel set fieldlabel='服务收费管理' where Relateid=@tabid and trantable='LD_tab' and languagetype='zh';
delimiter;

update ld_tranlabel set fieldlabel='知识管理' where Relateid=8 and trantable='LD_tab' and languagetype='zh';
delimiter;

update ld_desk set Fieldlabel='为0表示当天提醒，为空表示不提醒' where labelbol='ZEROSAMEDAYREMIND' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='0said to remind on this day,empty not remind' where labelbol='ZEROSAMEDAYREMIND' and languagetype='en' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='到期前N天提醒（为0表示当天提醒，为空表示不提醒）' where labelbol='PAYMENTPLAYREMINDS' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel='是否手机验证码登陆' where labelbol='WHETHERTHEMOBILELANGING' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Whether the mobile code landing' where labelbol='WHETHERTHEMOBILELANGING' and languagetype='en' and Labeltype='fixedstr';
delimiter;
-- 2014-12-22


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PurchaseInvoice';
UPDATE ld_quickactions SET sequence = 2 WHERE tabid = @tabid AND related_tabid = -5;
delimiter;

UPDATE ld_desk SET fieldlabel='本年累计资金回笼(元)' 
WHERE labelbol='Theyearsofaccumulatedfundswithdrawalfromcirculation' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thisduringdeliveryamount','本期发货金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thisduringdeliveryamount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thisduringdeliveryamount','delivery time amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thisduringdeliveryamount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','deliverytimetherefundamount','本期退货金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='deliverytimetherefundamount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','deliverytimetherefundamount','delivery time refund amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='deliverytimetherefundamount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','deliverytimetheamountofreceivables','本期收款金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='deliverytimetheamountofreceivables' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','deliverytimetheamountofreceivables','delivery time amount receivables','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='deliverytimetheamountofreceivables' and Labeltype='fixedstr');
delimiter;
-- 2014-12-23

delete from ld_faqcategories where faqcategories='常见问题' and picklist_valueid>46;
update ld_faqcategories_seq set id=(select max(faqcategories_id) from ld_faqcategories);

select tabid into @tabid from ld_tab where `name` = 'Events';
update ld_field set typeofdata = 'DT~M~time_start' where tabid = @tabid and fieldname = 'due_date';
delimiter;
-- 2014-12-24

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
select tabid into @tabid from ld_tab where name='SalesOrder';

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'ziptype','LD_salesorder',2,15,'ziptype','zip type',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'ziptype');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'logistics_no','LD_salesorder',2,1,'logistics_no','logistics_no',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'logistics_no');


select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'logistics_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'物流单号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'logistics no' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;
select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'ziptype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'物流公司' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'zip type' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;
call AddColumn('LD_salesorder','logistics_no','varchar','100',NULL); 
call AddColumn('LD_salesorder','ziptype','varchar','100',NULL); 

call fieldprofile('SalesOrder');
delimiter;
call getallprofile('SalesOrder');
delimiter;

CREATE TABLE  if not exists  `ld_ziptype`(
  `ziptypeid` int(19) NOT NULL auto_increment,
  `ziptype` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) NOT NULL default '0',
  PRIMARY KEY  (`ziptypeid`)
  
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE   if not exists `ld_ziptype_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_ziptype_seq (id) select 1 from dual where not exists(select 1 from ld_ziptype_seq);
delimiter;

select  max(picklistid) into @maxpicklist from LD_picklist;
update LD_picklist_seq set id=@maxpicklist+2 where not exists(select 1 from LD_picklist where name='ziptype');
INSERT INTO `ld_picklist`(  `picklistid`,`name` )  select   @maxpicklist+1,'ziptype'  from dual where not exists(select 1 from LD_picklist where name='ziptype');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='其他');
select  id into @maxid from ld_picklistvalues_seq;

update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='其他');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'其他',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='其他');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='中国邮政');
select  id into @maxid from ld_picklistvalues_seq;

update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='中国邮政');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'中国邮政',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='中国邮政');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='EMS');
select  id into @maxid from ld_picklistvalues_seq;

update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='EMS');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'EMS',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='EMS');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='圆通速递');
select  id into @maxid from ld_picklistvalues_seq;

update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='圆通速递');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'圆通速递',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='圆通速递');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='宅急送');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='宅急送');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'宅急送',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='宅急送');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='顺丰速运');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='顺丰速运');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'顺丰速运',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='顺丰速运');
delimiter;


select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='全峰快递');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='全峰快递');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'全峰快递',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='全峰快递');
delimiter;


select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='中通快递');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='中通快递');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'中通快递',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='中通快递');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='韵达快递');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='韵达快递');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'韵达快递',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='韵达快递');
delimiter;


select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='天天快递');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='天天快递');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'天天快递',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='天天快递');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='申通快递');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='申通快递');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'申通快递',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='申通快递');
delimiter;
select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='邮政国内小包');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='邮政国内小包');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'邮政国内小包',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='邮政国内小包');
delimiter;

select  id into @seqmaxid from ld_ziptype_seq ;
update ld_ziptype_seq set id=@seqmaxid+2 where not exists(select 1 from ld_ziptype where ziptype='新邦物流');
select  id into @maxid from ld_picklistvalues_seq;
update ld_picklistvalues_seq set id=@maxid+2 where not exists(select 1 from ld_ziptype where ziptype='新邦物流');
INSERT INTO `ld_ziptype` (ziptypeid,ziptype,picklist_valueid) select  @seqmaxid+1,'新邦物流',@maxid+1 from dual where not exists(select 1 from LD_ziptype where ziptype='新邦物流');
delimiter;

select max(blockid)into @maxblockid from ld_blocks ;
update ld_blocks_seq set id=@maxblockid+1 where not exists(select 1 from ld_blocks where tabid=22 and blocklabel='LBL_promotion_INFO');
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,display_status,iscustom)
select @maxblockid+1,22,'LBL_promotion_INFO' ,8,0,0,0,0,1,0 from dual where not exists(select 1 from ld_blocks where tabid=22 and blocklabel='LBL_promotion_INFO');

update ld_blocks set sequence = 9 where tabid = 22 and blocklabel = 'LBL_DESCRIPTION_INFORMATION';
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_promotion_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',22,@blockid,'优惠信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = 22 and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',22,@blockid,'promotion info' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = 22 and relateid=@blockid );
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
select tabid into @tabid from ld_tab where name='SalesOrder';
select sequence into @sequence from ld_field where tabid = @tabid and fieldname = 'sostatus';

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'post_fee','LD_salesorder',2,71,'post_fee','post fee',1,2,
'',100,3,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'post_fee');

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_promotion_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'package_info','LD_salesorder',2,19,'package_info','package_info',1,2,
'',100,3,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'package_info');

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_promotion_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'promotion_desc','LD_salesorder',2,19,'promotion_desc','promotion_desc',1,2,
'',100,4,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'promotion_desc');

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_promotion_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'taobao_orderamount','LD_salesorder',2,19,'taobao_orderamount','taobao_orderamount',1,2,
'',100,5,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'taobao_orderamount');

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_DESCRIPTION_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'buy_description','LD_salesorder',2,19,'buy_description','buy_description',1,2,
'',100,4,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'buy_description');

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'taobao_shop','LD_salesorder',2,1,'taobao_shop','taobao_shop',1,2,
'',100,@sequence+1,@blockid,1,'V~O',0,0,'BAS',0,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'taobao_shop');

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'taobao_status','LD_salesorder',2,1,'taobao_status','taobao_status',1,2,
'',100,@sequence+2,@blockid,2,'V~O',0,0,'BAS',0,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'taobao_status');


select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'post_fee';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'物流费' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'post fee' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'taobao_shop';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'淘宝店铺' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'Taobao Shop' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'taobao_status';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'淘宝订单状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'Taobao Order Status' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'taobao_orderamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'订单金额' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'Order Amount' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'promotion_desc';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'zh','LD_field',22,@fieldid,'优惠券' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'promotion' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'package_info';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'zh','LD_field',22,@fieldid,'套餐信息' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'Package Information' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'buy_description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'zh','LD_field',22,@fieldid,'买家备注' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)select 'en','LD_field',22,@fieldid,'Buy Description' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_DESCRIPTION_INFORMATION';
select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'description';
update ld_tranlabel set fieldlabel = '卖家备注' where tabid = 22 and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Seller Description' where tabid = 22 and Relateid = @fieldid and languagetype = 'en';
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_promotion_INFO';
select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'promotion_desc';
update ld_tranlabel set fieldlabel = '优惠信息' where tabid = 22 and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Discount Information' where tabid = 22 and Relateid = @fieldid and languagetype = 'en';
update ld_tranlabel set fieldlabel = '淘宝订单信息' where tabid = 22 and Relateid = @blockid and trantable = 'LD_blocks' and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Taobao Order Info' where tabid = 22 and Relateid = @blockid and trantable = 'LD_blocks' and languagetype = 'en';
delimiter;

select trade into @trade from ld_version limit 1;
update ld_field set presence = 1 where fieldname in ('taobao_status','taobao_shop','buy_description','taobao_orderamount','package_info','ziptype','logistics_no','post_fee','promotion_desc') and @trade != 'adoodoo';
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select sequence,block into @sequence,@blockid from ld_field where tabid = @tabid and fieldname = 'sostatus';
set @seq1 = @sequence+2;
update ld_field set sequence = (@seq1:=@seq1+1) where tabid = @tabid and block = @blockid and sequence > @sequence ORDER BY sequence;
update ld_field set sequence = @seq1+2 where tabid = @tabid and block = @blockid and sequence = @sequence and fieldname != 'sostatus' ORDER BY sequence;
update ld_field set sequence = @sequence+1 where tabid = @tabid and fieldname = 'taobao_shop';
update ld_field set sequence = @sequence+2 where tabid = @tabid and fieldname = 'taobao_status';

call AddColumn('LD_salesorder','post_fee','decimal','(10,2)',NULL); 
call AddColumn('LD_salesorder','promotion_desc','varchar','500',NULL); 
call AddColumn('LD_salesorder','taobao_shop','varchar','500',NULL); 
call AddColumn('LD_salesorder','taobao_status','varchar','100',NULL); 
call AddColumn('LD_salesorder','buy_description','varchar','500',NULL); 
call AddColumn('LD_salesorder','taobao_orderamount','varchar','500',NULL);
call AddColumn('LD_salesorder','package_info','varchar','500',NULL);
call fieldprofile('SalesOrder');
delimiter;
call getallprofile('SalesOrder');
delimiter;

update ld_field set fieldlabel='淘宝店铺' where tabid=22 and columnname='taobao_shop';
update ld_field set fieldlabel='快递公司' where tabid=22 and columnname='ziptype';
update ld_field set fieldlabel='快递单号' where tabid=22 and columnname='logistics_no';
update ld_field set fieldlabel='快递费用' where tabid=22 and columnname='post_fee';
update ld_field set fieldlabel='淘宝订单状态' where tabid=22 and columnname='taobao_status';

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_SO_INFORMATION';
select max(fieldid) into @fieldid from ld_field; 
SELECT sequence+1 INTO @sequence FROM ld_field WHERE tabid=22 ORDER BY sequence DESC LIMIT 1;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@fieldid+1,'print','LD_salesorder',1,1,'print','打印状态',0,2,'',@sequence,@blockid,2,'V~M' from dual 
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'print' and fieldname = 'print');
update ld_field_seq set id = (select max(fieldid) from ld_field); 


insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid,'打印状态' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid,'Print Status' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@fieldid and trantable='ld_field');

CALL AddColumn('LD_salesorder','print','varchar','100',NULL);
delimiter;

call fieldprofile('SalesOrder');
delimiter;
call getallprofile('SalesOrder');
delimiter;

select trade into @trade from ld_version limit 1;
update ld_field set presence = 1 where fieldname in ('print') and @trade != 'adoodoo';
delimiter;

update ld_field set generatedtype=2,readonly=1,maximumlength=100,quickcreate=0,displaytype=2,typeofdata='V~O',masseditable=0 where tabid=22 and columnname='print';

update ld_field set sequence=sequence+100 where tabid=22 and block=61 and presence=1;
update ld_field set sequence=sequence+200 where tabid=22 and block=61 and columnname in ('discount_percent','discount_amount','s_h_amount','subtotal',
'adjustment','exciseduty','total','conversion_rate','currency_id','taxtype');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=22 and block=61 order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOTALOTHER','合计','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TOTALOTHER' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOTALOTHER','total','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TOTALOTHER' and Labeltype='jspop');
delimiter;

create table if not exists `ld_documentscf` (
  `documentsid` int(19) not null default'0',
  primary key  (`documentsid`)
) engine=innodb default charset=utf8;
delimiter;

create table if not exists `ld_faqscf` (
  `faqid` int(19) not null default'0',
  primary key  (`faqid`)
) engine=innodb default charset=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select tabid into @related_tabid from ld_tab where `name` = 'Invoice';
update ld_relatedlists set presence = 1 where tabid = @tabid and related_tabid = @related_tabid;
delimiter;
-- 2014-12-25

select if(trade = 'adoodoo',2,1) as trade into @trade from ld_version limit 1;
update ld_field set presence = @trade 
where fieldname in ('taobao_status','taobao_shop','buy_description','taobao_orderamount','package_info','ziptype','logistics_no','post_fee','promotion_desc','print') and tabid = 22;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_DESCRIPTION_INFORMATION';
select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'description';
update ld_tranlabel set fieldlabel = if(@trade=1,'备注','卖家备注') where tabid = 22 and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = if(@trade=1,'Description','Seller Description') where tabid = 22 and Relateid = @fieldid and languagetype = 'en';
delimiter;
-- 2014-12-29

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.8.1' ,current_version='V5.8.1' ,remark='V5.8.1-20141229';
delimiter;