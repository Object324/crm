DROP PROCEDURE if EXISTS `addautoincreament`;
delimiter ||
create PROCEDURE `addautoincreament`
(
 tablename varchar(50),
tmpcolumnname varchar(50)
)
begin 
	
	
 set @sql=concat("select count(*) into @tmpcount  from INFORMATION_SCHEMA.KEY_COLUMN_USAGE t where t.TABLE_NAME ='",tablename,"'");

PREPARE mystatement FROM @sql;


	EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;

	if @tmpcount=0 THEN
		set @sql=concat(" alter table ", tablename," modify ",tmpcolumnname,"  int(19) not null AUTO_INCREMENT primary key");
		PREPARE mystatement FROM @sql;

	EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;

	end if;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_chooseaccount`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_chooseaccount`(
	tmp_modulename VARCHAR(100)
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @columnname='accountid'; 
		SET @fieldname='account_id'; 
		SET @zh='客户名称'; 
		SET @en='Account Name'; 
		SET @uitype=73; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @presence=2;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
		DELETE FROM ld_tranlabel WHERE trantable=@trantable AND tabid = @tabid AND relateid=@fieldid;
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en;

		CALl AddColumn(@tablename,@columnname,'INT','19',NULL);
		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=6);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,6,@tabid,LOWER(CONCAT('get_',tmp_modulename)),@seq+1,tmp_modulename,1,'add',LOWER(CONCAT(tmp_modulename,'.accountid')),'datacategory_sql' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=6 AND related_tabid=@tabid);
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
	END IF;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_choosesourcebill_20181114`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_choosesourcebill_20181114`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_moudlename VARCHAR(100) DEFAULT NULL; 

	DECLARE MYCUSOR CURSOR FOR SELECT tabid,`name` FROM ld_tab WHERE `name` LIKE 'CustomForm%' AND RIGHT(`name`,2)>=11 AND RIGHT(`name`,2)<=20;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_moudlename;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @tabid=tmp_tabid;
		SET @modulename=tmp_moudlename;
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename='';
		SET @columnname=''; 
		SET @fieldname=''; 
		SET @zh='选择源单'; 
		SET @en='Data sources'; 
		SET @uitype=202; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @presence=2;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND uitype=@uitype); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND uitype=@uitype LIMIT 1);
		DELETE FROM ld_tranlabel WHERE trantable=@trantable AND tabid = @tabid AND relateid=@relateid;
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en;

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);

		DELETE FROM ld_option_module WHERE tabid=@tabid;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,22,0,1,0,1,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,37,0,0,0,2,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,21,1,0,0,3,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,23,1,0,0,4,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice'),1,0,0,5,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder'),1,0,0,6,5;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,(SELECT tabid FROM ld_tab WHERE `name`='Stock'),1,0,0,7,5;
				
		FETCH MYCUSOR INTO tmp_tabid,tmp_moudlename;
	END WHILE;
	CLOSE MYCUSOR;
	
end ||
delimiter;


CALL ldcrm_add_choosesourcebill_20181114();
DROP PROCEDURE IF EXISTS `ldcrm_add_choosesourcebill_20181114`;


DROP PROCEDURE if EXISTS `addautoincreament`;
delimiter ||
create PROCEDURE `addautoincreament`
(
 tablename varchar(50),
tmpcolumnname varchar(50)
)
begin 
	
	
 set @sql=concat("select count(*) into @tmpcount  from INFORMATION_SCHEMA.KEY_COLUMN_USAGE t where t.TABLE_NAME ='",tablename,"'");

PREPARE mystatement FROM @sql;


	EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;

	if @tmpcount=0 THEN
		set @sql=concat(" alter table ", tablename," modify ",tmpcolumnname,"  int(19) not null AUTO_INCREMENT primary key");
		PREPARE mystatement FROM @sql;

	EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;

	end if;

end ||
delimiter;

call addautoincreament("ld_customform11detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform12detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform13detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform14detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform15detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform16detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform17detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform18detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform19detail",'lineitem_id');
delimiter;
call addautoincreament("ld_customform20detail",'lineitem_id');
delimiter;

DROP PROCEDURE if EXISTS `addautoincreament`;

UPDATE ld_field SET approve_demand=2 WHERE uitype=202;

CALL AddColumn('ld_servicecontracts','salesorderid','int',19,0 );
delimiter;

update ld_desk set fieldlabel='WeChatApplet' where languagetype='en' and labelbol='WECHATAPPLETHEADER' and Labeltype='fixedstr';
delimiter;

select fieldid into @effectfieldid from ld_field  where tabid=22 and columnname='accountid';
select fieldid into @triggerfieldid from ld_field where tabid=22 and columnname='contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main' , @triggerfieldid,@effectfieldid,'account_id,accounts_name' ,'sql',"select {hrefcolumn},ld_account.accountid from ld_account LEFT JOIN ld_accountscf on ld_account.accountid=ld_accountscf.accountid  inner JOIN ld_contactdetails on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.contactid = ? and ld_account.deleted = 0 order by ld_account.accountid  desc limit 1"
from dual where not exists(select 1 from ld_related_field where fieldtype='main' and trigger_fieldid=@triggerfieldid and effect_fieldid=@effectfieldid);
delimiter;

select fieldid into @effectfieldid from ld_field  where tabid=37 and columnname='accountid';
select fieldid into @triggerfieldid from ld_field where tabid=37 and columnname='contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main' , @triggerfieldid,@effectfieldid,'account_id,accounts_name' ,'sql',"select {hrefcolumn},ld_account.accountid from ld_account LEFT JOIN ld_accountscf on ld_account.accountid=ld_accountscf.accountid  inner JOIN ld_contactdetails on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.contactid = ? and ld_account.deleted = 0 order by ld_account.accountid  desc limit 1"
from dual where not exists(select 1 from ld_related_field where fieldtype='main' and trigger_fieldid=@triggerfieldid and effect_fieldid=@effectfieldid);
delimiter;
select fieldid into @effectfieldid from ld_field  where tabid=2 and columnname='accountid';
select fieldid into @triggerfieldid from ld_field where tabid=2 and columnname='contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main' , @triggerfieldid,@effectfieldid,'account_id,accounts_name' ,'sql',"select {hrefcolumn},ld_account.accountid from ld_account LEFT JOIN ld_accountscf on ld_account.accountid=ld_accountscf.accountid  inner JOIN ld_contactdetails on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.contactid = ? and ld_account.deleted = 0 order by ld_account.accountid  desc limit 1"
from dual where not exists(select 1 from ld_related_field where fieldtype='main' and trigger_fieldid=@triggerfieldid and effect_fieldid=@effectfieldid);
delimiter;
select fieldid into @effectfieldid from ld_field  where tabid=20 and columnname='accountid';
select fieldid into @triggerfieldid from ld_field where tabid=20 and columnname='contactid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main' , @triggerfieldid,@effectfieldid,'account_id,accounts_name' ,'sql',"select {hrefcolumn},ld_account.accountid from ld_account LEFT JOIN ld_accountscf on ld_account.accountid=ld_accountscf.accountid  inner JOIN ld_contactdetails on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.contactid = ? and ld_account.deleted = 0 order by ld_account.accountid  desc limit 1"
from dual where not exists(select 1 from ld_related_field where fieldtype='main' and trigger_fieldid=@triggerfieldid and effect_fieldid=@effectfieldid);
delimiter;

update ld_field  set presence=0 where tabid=14 and columnname='batchmanagement' ;
delimiter;

UPDATE ld_desk SET fieldlabel='数量大于当前批次号产品库存数量!' WHERE labelbol='QUANTITYMORTHANCURRENTROWBATCH' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='the quantity is larger than the stock quantity of the batch!' WHERE labelbol='QUANTITYMORTHANCURRENTROWBATCH' AND languagetype='en';

select sequence into  @sequence from ld_usereport where name='SalesReport';
set @i=@sequence+1;
update ld_usereport set sequence=(@i:=@i+1) where Parent_id=0 and sequence>@sequence order by sequence;
insert into ld_usereport( name, reportlabel, tabids, basicfilter,advfilter, Setcolumns, Parent_id, sequence, reporttype, pagewidthpercent)
select 'InventoryReport','库存报表',0,0,0,0,0,@sequence+1,0,100
from dual where not exists(select 1 from ld_usereport where name='InventoryReport');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','InventoryReport','库存报表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InventoryReport' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','InventoryReport','Inventory Report','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InventoryReport' and languagetype='en' and Labeltype='fixedstr');

select usereportid into @usereportid from ld_usereport where name='InventoryReport';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,Parent_id, sequence, reporttype, pagewidthpercent)
select 'InventoryAccount','库存流水账',0,1,0,1,@usereportid,1,47,100 from dual
where not exists(select 1 from ld_usereport where name='InventoryAccount');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','InventoryAccount','库存流水账','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InventoryAccount' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','InventoryAccount','Inventory Account','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InventoryAccount' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','INCOME','收入','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INCOME' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','INCOME','Income','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INCOME' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','SENDOUT','发出','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SENDOUT' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','SENDOUT','Send Out','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SENDOUT' and languagetype='en' and Labeltype='fixedstr');

select usereportid into @usereportid from ld_usereport where `name` = 'InventoryAccount';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_stock:createdate:createdate:Stock_createdate:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_stock:createdate:createdate:Stock_createdate:D');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_stock:wareid:wareid:Stock_wareid:I','',2 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_stock:wareid:wareid:Stock_wareid:I');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I','',3 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_products:batchmanagement:batchmanagement:Products_batchmanagement:I');

select usereportid into @id from ld_usereport where name='InventoryAccount';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:createdate:createdate:Stock_入库日期:V', 1, 1, 'ld_stock:bill_date:createdate:Stock_日期:V','ld_stock:createdate:createdate:Stock_Date:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:createdate:createdate:Stock_入库日期:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:V', 2, 1, 'ld_stock:bill_no:ware_stock_no:Stock_单据编号:V','ld_stock:ware_stock_no:ware_stock_no:Stock_DocumentNumber:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:productname:productname:Products_单据产品名称:V', 3, 1, 'ld_products:productname:productname:Products_产品名称:V','ld_products:productname:productname:Products_Product Name:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:productname:productname:Products_单据产品名称:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_stock:batchtext:batchtext:Stock_产品批次:V', 4, 1, 'ld_stock:batchtext:batchtext:Stock_批次:V','ld_stock:batchtext:batchtext:Stock_Batch:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_stock:batchtext:batchtext:Stock_产品批次:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_products:productsheet:productsheet:Products_单据产品型号:V', 5, 1, 'ld_products:productsheet:productsheet:Products_产品型号:V','ld_products:productsheet:productsheet:Products_Model:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_products:productsheet:productsheet:Products_单据产品型号:V');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'ld_warehouse:warhouse:warhouse:Products_产品仓库:V', 6, 0, 'ld_warehouse:warhouse:warhouse:Products_仓库:V','ld_warehouse:warhouse:warhouse:Products_Warehouse:V'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='ld_warehouse:warhouse:warhouse:Products_产品仓库:V');
delimiter;

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
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.5.7',current_version='V7.5.7',remark='V7.5.7-20181116',wx_version='V7.5.5.4';
delimiter;