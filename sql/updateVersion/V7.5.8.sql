select sequence into @sequence from ld_systems_deploy where roottype=4 and deploy_type=132;
update  ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=4;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,196,'是否启用批次管理','',@sequence+1, 4,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not exists (select * from ld_systems_deploy where deploy_type=196);

delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',196,196,'是否启用批次管理' from dual 
where not exists (select 1 from ld_tranlabel where trantable='ld_systems_deploy' and tabid=196 and relateid=196 and languagetype='zh');
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',196,196,'Whether batch management is enabled' from dual 
where not exists (select 1 from ld_tranlabel where trantable='ld_systems_deploy' and tabid=196 and relateid=196 and languagetype='en');
delimiter;

UPDATE ld_field SET presence=1 WHERE columnname='batchmanagement' AND tabid=14 
	AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=196 AND deploy_value=1);
UPDATE ld_producttoolfield SET presence=1 WHERE columnname='batchtext' AND tablename='ld_inventoryproductrel'
	AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=196 AND deploy_value=1);
UPDATE ld_producttoolfield SET width=50 WHERE columnname='batchtext' AND tablename='ld_inventoryproductrel';
-- 2018-11-19

SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Accounts' AND viewname='All' AND customcategory='ALLACCOUNT');
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid AND columnname LIKE 'ld_contactdetails:pphone%' AND NOT EXISTS (SELECT 1 FROM ld_account);

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=134 AND NOT EXISTS (SELECT 1 FROM ld_sendcashbill);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=135 AND NOT EXISTS (SELECT 1 FROM ld_outboundorder);
UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=136 AND NOT EXISTS (SELECT 1 FROM ld_stock);


SET @userreportid=(SELECT usereportid FROM ld_usereport WHERE `name`='InventoryAccount' LIMIT 1);
SET @i=0;
UPDATE ld_usereportcolumns SET sequence=sequence+10 WHERE Usereportid=@userreportid;
UPDATE ld_usereportcolumns SET sequence=1 WHERE Usereportid=@userreportid AND `columns` LIKE 'ld_stock:createdate%'; 
UPDATE ld_usereportcolumns SET sequence=2 WHERE Usereportid=@userreportid AND `columns` LIKE 'ld_stock:ware_stock_no%'; 
UPDATE ld_usereportcolumns SET sequence=3 WHERE Usereportid=@userreportid AND `columns` LIKE 'ld_products:productname%'; 
UPDATE ld_usereportcolumns SET sequence=4 WHERE Usereportid=@userreportid AND `columns` LIKE 'ld_products:productsheet%'; 
UPDATE ld_usereportcolumns SET sequence=5 WHERE Usereportid=@userreportid AND `columns` LIKE 'ld_stock:batchtext%'; 
UPDATE ld_usereportcolumns SET sequence=6 WHERE Usereportid=@userreportid AND `columns` LIKE 'ld_warehouse:warhouse%'; 
UPDATE ld_usereportcolumns SET sequence=(@i:=@i+1) WHERE Usereportid=@userreportid ORDER BY sequence;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QUANTITYMORTHANCURRENTROWBATCH','{productname}出库数量大于当前批次号产品数量','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QUANTITYMORTHANCURRENTROWBATCH' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QUANTITYMORTHANCURRENTROWBATCH','Save failed, reason: The quantity of {productname} is larger than the quantity of the current batch number!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QUANTITYMORTHANCURRENTROWBATCH' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','bangwobauserpwd','帮我吧客服账号或者密码错误！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='bangwobauserpwd' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','bangwobauserpwd','Inventory Report','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='bangwobauserpwd' and languagetype='en' and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '应收款统计表_按{$OutboundOrder.OutboundOrder}统计' where languagetype = 'zh' and labelbol = 'CashBillSum_Outboundorder' and Labeltype = 'fixedstr';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
update ld_usereportcolumns set realcolumns = 'ld_outboundorder:presence:presence:OutboundOrder_出库状态:V' 
where Usereportid = @usereportid and `columns` = 'ld_outboundorder:presence:presence:OutboundOrder_Status:V';
delimiter;

delete from ld_tab where name='Navigation';
delimiter;

CREATE TABLE if not exists `ld_tmp_autoreminds` (
  `createdtime` datetime NOT NULL,
  PRIMARY KEY (`createdtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select usereportid into @usereportid from ld_usereport where name='InventoryReport';
select sequence into @sequence from ld_usereport where name='InventoryAccount';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,
                         Parent_id, sequence, reporttype, pagewidthpercent)
  select 'InventoryLedger','库存台账',0,1,0,1,@usereportid,@sequence-1,47,100 from dual
  where not exists(select 1 from ld_usereport where name='InventoryLedger');

insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','InventoryLedger','库存台账','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='InventoryLedger' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','InventoryLedger','Stock Ledger','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='InventoryLedger' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','REPORTBALANCE','结存','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='REPORTBALANCE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','REPORTBALANCE','Balance','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='REPORTBALANCE' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','REPORTFORWARD','向前','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='REPORTFORWARD' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','REPORTFORWARD','Forward','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='REPORTFORWARD' and languagetype='en' and Labeltype='fixedstr');


insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','REPORTBACKWARDS','向后','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='REPORTBACKWARDS' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','REPORTBACKWARDS','Backwards','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='REPORTBACKWARDS' and languagetype='en' and Labeltype='fixedstr');


select usereportid into @usereportid from ld_usereport where `name` = 'InventoryLedger';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_stock:createdate:createdate:Stock_createdate:D','thisstartmonth~thisendmonth',1 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_stock:createdate:createdate:Stock_createdate:D');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_products:productname:productname:Products_productname:I','',2 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_productname:I');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I','',3 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I');

select usereportid into @id from ld_usereport where name='InventoryLedger';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:createdate:createdate:Stock_入库日期:V', 1, 1, 'ld_stock:bill_date:createdate:Stock_日期:V','ld_stock:createdate:createdate:Stock_Date:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:createdate:createdate:Stock_入库日期:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_outboundorder:out_no:out_no:OutboundOrder_出库单编号:V', 2, 1, 'ld_outboundorder:out_no:out_no:OutboundOrder_事务类型:V','ld_outboundorder:out_no:out_no:OutboundOrder_Transaction type:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_outboundorder:out_no:out_no:OutboundOrder_出库单编号:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:V', 3, 1, 'ld_stock:bill_no:ware_stock_no:Stock_单据编号:V','ld_stock:ware_stock_no:ware_stock_no:Stock_DocumentNumber:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:batchtext:batchtext:Stock_产品批次:V', 5, 1, 'ld_stock:batchtext:batchtext:Stock_批次:V','ld_stock:batchtext:batchtext:Stock_Batch:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:batchtext:batchtext:Stock_产品批次:V');


select usereportid into @usereportid from ld_usereport where name='InventoryReport';
select sequence into @sequence from ld_usereport where name='InventoryAccount';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,
                         Parent_id, sequence, reporttype, pagewidthpercent)
  select 'InventoryQuery','即时库存查询',0,1,0,1,@usereportid,@sequence+1,47,100 from dual
  where not exists(select 1 from ld_usereport where name='InventoryQuery');

insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','InventoryQuery','即时库存查询','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='InventoryQuery' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','InventoryQuery','Stock List','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='InventoryQuery' and languagetype='en' and Labeltype='fixedstr');

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryQuery';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_products:productname:productname:Products_productname:I','',1 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_productname:I');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_stock:wareid:wareid:Stock_wareid:I','',2 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_stock:wareid:wareid:Stock_wareid:I');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I','',3 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I');



select usereportid into @id from ld_usereport where name='InventoryQuery';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:productname:productname:Products_产品名称#:V', 1, 1, 'ld_products:productname:productname:Products_产品名称:V','ld_products:productname:productname:Products_:Product NameV'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:productname:productname:Products_产品名称#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:batchtext:batchtext:Stock_产品批次:V', 2, 1, 'ld_stock:batchtext:batchtext:Stock_批次:V','ld_stock:batchtext:batchtext:Stock_Batchtext:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:batchtext:batchtext:Stock_产品批次:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:product_no:product_no:Products_产品编号#:V', 3, 1, 'ld_products:product_no:product_no:Products_单据编号:V','ld_products:product_no:product_no:Products_Product No:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:product_no:product_no:Products_产品编号#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:productsheet:productsheet:Products_型号#:V', 4, 1, 'ld_products:productsheet:productsheet:Products_型号:V','ld_products:productsheet:productsheet:Products_Models:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:productsheet:productsheet:Products_型号#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:unit_price:unit_price:Products_单价#:V', 5, 1, 'ld_products:unit_price:unit_price:Products_单价:V','ld_products:unit_price:unit_price:Products_Unit price:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:unit_price:unit_price:Products_单价#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:weight:weight:Products_库存数量#:V', 6, 1, 'ld_products:inventory_qty:weight:Products_库存数量:V','ld_products:weight:weight:Products_Stock Quantity:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:weight:weight:Products_库存数量#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:qtyearly:qtyearly:Products_安全库存#:V', 7, 1, 'ld_products:qtyearly:qtyearly:Products_安全库存:V','ld_products:qtyearly:qtyearly:Products_Safe Stock:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:qtyearly:qtyearly:Products_安全库存#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:costprice:costprice:Products_库存金额#:V', 8, 1, 'ld_products:costprice:costprice:Products_库存金额:V','ld_products:costprice:costprice:Products_Inventory amount:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:costprice:costprice:Products_库存金额#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:qtyearly:qtyearly:Products_待入库数量#:V', 9, 1, 'ld_products:dairu_qty:qtyearly:Products_待入库数量:V','ld_products:qtyearly:qtyearly:Products_Incoming quantity:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:qtyearly:qtyearly:Products_待入库数量#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:qtyearly:qtyearly:Products_待出库数量#:V', 10, 1, 'ld_products:daichu_qty:qtyearly:Products_待出库数量:V','ld_products:qtyearly:qtyearly:Products_QuantityToBeDelivered:V'
  from dual where not exists(select 1 from ld_usereportcolumns
  where usereportid=@id and columns='ld_products:qtyearly:qtyearly:Products_待出库数量#:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:qtyearly:qtyearly:Products_安全库存差额#:V', 11, 1, 'ld_products:cha_qty:qtyearly:Products_安全库存差额:V','ld_products:qtyearly:qtyearly:Products_Safety inventory balance:V'
  from dual where not exists(select 1 from ld_usereportcolumns
  where usereportid=@id and columns='ld_products:qtyearly:qtyearly:Products_安全库存差额#:V');
delimiter;
-- 2018-11-23


UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq set id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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
delimiter;

UPDATE ld_version SET old_version='V7.5.8',current_version='V7.5.8',remark='V7.5.8-20181120',wx_version='V7.5.5.4';
delimiter;