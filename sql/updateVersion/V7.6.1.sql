SET @existdefault=(SELECT COUNT(1) FROM ld_option_module WHERE tabid=23 AND `default`=1);
UPDATE ld_option_module SET `default`=1 WHERE tabid=23 AND option_tabid=22 AND @existdefault=0;

update ld_tranlabel set fieldlabel = '设置出库、入库类库单据更新库存数量的触发点' where trantable = 'ld_systems_deploy' and tabid = 48 and Relateid = 48 and languagetype='zh';
update ld_tranlabel set fieldlabel = 'Setting the trigger point for updating the inventory quantity of the out and in-stock' where trantable = 'ld_systems_deploy' and tabid = 48 and Relateid = 48 and languagetype='en';
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"0","text":"Approvals"},{"value":"1","text":"SAVE"},{"sql":""}]' where deploy_type = 48;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','theparametertriggerpoint','The parameter trigger point for updating inventory data has been changed,the system will recalculate the total inventory of products.','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='theparametertriggerpoint' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','theparametertriggerpoint','参数出库、入库类单据更新库存数据触发点已更改，系统将重算产品总库存数量','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='theparametertriggerpoint' and Labeltype='jspop');
delimiter;
-- 2018-12-10

UPDATE ld_tab SET presence=0 WHERE presence=1 AND `name` IN ('MassSMS','SmsPhrases','CommunicationLog') 
	AND EXISTS(SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57));
UPDATE ld_parenttab SET visible=0 WHERE parenttab_label='Marketing' AND visible=5
    AND EXISTS(SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57));
    
update ld_cvcolumnlist_wx set columnname=replace(columnname,':ServiceCharge',':Accounts') 
 WHERE presence=0 AND modulename='ServiceCharge' ;
delimiter;

insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','USEREPORTENTRIESTITLE1','当前台账产品名称','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='USEREPORTENTRIESTITLE1' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','USEREPORTENTRIESTITLE1','Current ledger product name','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='USEREPORTENTRIESTITLE1' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','USEREPORTENTRIESTITLE2','产品代码','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='USEREPORTENTRIESTITLE2' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','USEREPORTENTRIESTITLE2','Product code','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='USEREPORTENTRIESTITLE2' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','USEREPORTENTRIESREMIND3','指定查询范围中没有相应记录，请重新选择','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='USEREPORTENTRIESREMIND3' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','USEREPORTENTRIESREMIND3','There is no record in the specified query scope. Please choose again.','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='USEREPORTENTRIESREMIND3' and languagetype='en' and Labeltype='fixedstr');

select usereportid into @id from ld_usereport where name='InventoryQuery';
update ld_usereportcolumns set realencolumns='ld_products:productname:productname:Products_Product Name:V'
where columns='ld_products:productname:productname:Products_产品名称#:V' and usereportid=@id;

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryAccount';
select Sequence into @sequence from ld_usereportbasic where Usereportid=@usereportid and columns='ld_stock:wareid:wareid:Stock_wareid:I';
set @seq = @sequence;
update ld_usereportbasic set sequence=(@seq:=@seq+1) where Usereportid=@usereportid and Sequence > @sequence;
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_products:productname:productname:Products_productname:I','',2 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_productname:I');

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryLedger';
update ld_usereportcolumns set columnshow=0 where
  columns='ld_products:productname:productname:Products_产品名称#:V' and Usereportid=@usereportid;
  
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','ENDINGBALANCE','期末结存','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='ENDINGBALANCE' AND languagetype='zh');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','ENDINGBALANCE','Ending balance','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='ENDINGBALANCE' AND languagetype='en');
-- 2018-12-11

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryLedger';
select Sequence into @sequence from ld_usereportbasic where Usereportid=@usereportid and columns='ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I';
set @seq = 3;
update ld_usereportbasic set sequence=(@seq:=@seq+1) where Usereportid=@usereportid and Sequence >= @sequence;

insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
  select @usereportid,'ld_stock:wareid:wareid:Stock_wareid:I','',3 from DUAL
  where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_stock:wareid:wareid:Stock_wareid:I');
-- 2018-12-12

DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND Relateid IN (SELECT blockid FROM ld_blocks WHERE blocklabel='');
DELETE FROM ld_field WHERE block IN (SELECT blockid FROM ld_blocks WHERE blocklabel='');
DELETE FROM ld_blocks WHERE blocklabel='';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','THEPRINTPARAMENTERS','打印参数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='THEPRINTPARAMENTERS' AND languagetype='zh');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','THEPRINTPARAMENTERS','Print Parameters','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='THEPRINTPARAMENTERS' AND languagetype='en');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','THEINVENTORYPARAMENTERS','库存参数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='THEINVENTORYPARAMENTERS' AND languagetype='zh');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','THEINVENTORYPARAMENTERS','Inventory Parameters','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='THEINVENTORYPARAMENTERS' AND languagetype='en');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','THEINTERFACEPARAMENTERS','接口参数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='THEINTERFACEPARAMENTERS' AND languagetype='zh');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','THEINTERFACEPARAMENTERS','Interface Parameters','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='THEINTERFACEPARAMENTERS' AND languagetype='en');


SET @i=0;
SET @roottype=1;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (90,73,65,80,81,166,110,33,61,26,25,
 32,122,123,124,140,79,86,83,84,49,93,13,14,151,67,137,198);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,90,73,65,80,81,166,33,110,61,26,25,
 32,122,123,124,140,79,86,83,84,13,14,151,67,137,198,49,93);


SET @roottype=2;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (68,71,82,72,69,74,108,109,139,138,119,116,117,118,
	54,37,38,12,130,1,162,56,63,89,111,164,161,58,59,163,146,147,15,20,148,149,102,103);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,68,82,71,72,69,74,108,109,139,138,119,116,117,118,
	54,37,38,12,130,1,162,56,63,89,111,164,161,58,59,163,146,147,15,20,148,149,102,103);


SET @i=0;
SET @roottype=3;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (70,11,94,27,47,6,100,28,17,120,96,29,5,150,3,197,112,8,113,158,22,23,98,99,135,136,4,50,133,134,30,
    31,125,126,127,128,129,131,36,9,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,70,11,94,27,47,6,100,28,17,120,96,29,5,150,3,197,112,8,113,158,22,23,98,99,135,136,4,50,133,134,30,
    31,125,126,127,128,129,131,36,9,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195);


SET @i=0;
SET @roottype=4;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (51,145,95,18,24,40,41,7,62,115,167,21);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,51,145,95,18,24,40,41,7,62,115,167,21);


SET @i=0;
SET @roottype=5;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (10,48,85,132,141,142,196);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,196,48,142,141,10,85,132);


SET @i=0;
SET @roottype=6;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (57,153,154,155,156,157);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,153,154,57,155,156,157);


SET @i=0;
SET @roottype=7;
UPDATE ld_systems_deploy SET roottype=@roottype WHERE deploy_type IN (77,92,105,106,114,143,144,152,159,165);
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY FIELD(deploy_type,165,114,143,144,152,159,92,105,106,77);

UPDATE ld_tranlabel SET fieldlabel='设置微信端拜访签选择客户是否为必填字段' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=143;
UPDATE ld_tranlabel SET fieldlabel='设置录入{$Products.Products}时是否允许选择禁用的单据' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=82;
UPDATE ld_tranlabel SET fieldlabel='设置单据分录中录入{$Products.Products}时是否只允许选择已审批的单据' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=71;
UPDATE ld_tranlabel SET fieldlabel='出库和入库类库单据更新库存数量的触发点' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=48;
UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,' Parameters','') WHERE languagetype='en' AND labelbol IN ('Businessparameters',
'SYSTEMPARAMETERS','THEINVENTORYPARAMENTERS','THEINTERFACEPARAMENTERS','THEAPPROVALPARAMENTERS','REMINDERPARAMENERS','THEPRINTPARAMENTERS'); 
-- 2018-12-13

UPDATE ld_tranlabel SET fieldlabel='设置单据分录明细新增时预置的分录行数' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=122;
UPDATE ld_tranlabel SET fieldlabel='设置单据分录明细最后一行录入产品后是否自动新增行' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=123;
UPDATE ld_tranlabel SET fieldlabel='设置单据分录明细中{$Products.Products}的价格和金额计算时的基准字段' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=124;
UPDATE ld_tranlabel SET fieldlabel='设置单据分录明细中录入价税合计后重算单价还是折扣' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=140;
UPDATE ld_tranlabel SET fieldlabel='中单价是否自动根据客户最近购买记录带出' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=79;
UPDATE ld_tranlabel SET fieldlabel='设置计算已收金额时是否统计未审批通过的{$CashBill.CashBill}' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=83;
UPDATE ld_tranlabel SET fieldlabel='设置计算已付金额时是否统计未审批通过的{$SendCashBill.SendCashBill}' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=84;
UPDATE ld_tranlabel SET fieldlabel='设置分配功能选择被分配人时是否显示所有用户' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=110;
UPDATE ld_tranlabel SET fieldlabel='设置分配{$Potentials.Potentials}时是否同时分配相关信息' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=26;
UPDATE ld_tranlabel SET fieldlabel='设置分配{$Accounts.Accounts}时是否同时分配相关信息' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=61;
UPDATE ld_tranlabel SET fieldlabel='设置共享功能是否仅允许单据负责人和管理员用户操作' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=33;
UPDATE ld_tranlabel SET fieldlabel='设置是否启用批次管理' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=196;
UPDATE ld_tranlabel SET fieldlabel='设置{$SalesOrder.SalesOrder}分录明细中数量超过库存数量时是否需要提示负库存' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=142;
UPDATE ld_tranlabel SET fieldlabel='设置未出库的{$SalesOrder.SalesOrder}是否允许退货' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=85;
UPDATE ld_tranlabel SET fieldlabel='设置未入库的{$PurchaseOrder.PurchaseOrder}是否允许退货' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=132;
UPDATE ld_tranlabel SET fieldlabel='设置出库类单据负库存时是否允许出库（根据参数库存更新触发点在保存或审批通过时判断）' WHERE languagetype='zh' AND trantable='ld_systems_deploy' AND Relateid=141;

INSERT INTO ld_settings_field (fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
SELECT 55,5,'LBL_ACCOUNTS_CONTACTS_FIELDS','AccountContact.png','LBL_ACCOUNTS_CONTACTS_DESCRIPTION','index.php?module=Settings&action=AccountsContactsField&parenttab=Settings',10,0 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_settings_field WHERE fieldid=55);

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

UPDATE ld_version SET old_version='V7.6.1',current_version='V7.6.1',remark='V7.6.1-20181212',wx_version='V7.6.0';
delimiter;