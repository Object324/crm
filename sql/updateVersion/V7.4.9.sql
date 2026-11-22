DROP PROCEDURE IF EXISTS `del_idx`;
DROP PROCEDURE IF EXISTS `Del_TableIndex`;
delimiter ||
CREATE PROCEDURE `Del_TableIndex`(
	tmp_tablename varchar(100),
	tmp_indexname varchar(100)
)
BEGIN  

	IF EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND index_name=tmp_indexname) THEN  
		SET @execsql=CONCAT(' DROP INDEX ',tmp_indexname,' ON ',tmp_tablename);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `DelForeignkey`;
DROP PROCEDURE IF EXISTS `Del_ForeignKey`;
delimiter ||
CREATE PROCEDURE `Del_ForeignKey`(
	tmp_tablename varchar(100),
	tmp_fkeyname varchar(100)
)
BEGIN

	IF EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE WHERE CONSTRAINT_NAME=tmp_fkeyname AND TABLE_NAME=tmp_tablename AND TABLE_SCHEMA=DATABASE()) THEN
		SET @execsql=CONCAT(' ALTER TABLE ',tmp_tablename, ' DROP FOREIGN KEY ',tmp_fkeyname);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;

CALL Del_ForeignKey('ld_invoice','ld_invoice_ibfk_1');
CALL Del_TableIndex('fk_2_vtiger_invoice','ld_invoice');
CALL Del_TableIndex('invoice_contactid_idx','ld_invoice');
CALL Del_TableIndex('invoice_accountid_idx','ld_invoice');
-- 2018-08-21

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_users`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_users`(
)
BEGIN
	
	SET @blockid=IFNULL((SELECT blockid FROM ld_blocks WHERE tabid=29 AND visible=0 AND blocklabel='LBL_ATTACHMENTS_INFOMATION'),0);
	IF @blockid>0 THEN
		SET @tabid=29;
		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
		SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename'; 
		SET @fieldname='filename'; 
		SET @zh='附件'; 
		SET @en='Attachment'; 
		SET @uitype=1109; 

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0 from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		CALL getallprofile('Users');
		CALL fieldprofile('Users');

	END IF;
	

end ||
delimiter;


CALL ldcrm_add_attachments_filename_users();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_users`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Productbom');
UPDATE ld_producttoolfield SET columnname='product_no',fieldid=175 WHERE tabid=@tabid AND fieldlabel='产品编号' AND tablename='ld_products' AND fieldid=174;
-- 2018-08-22


call AddColumn('ld_warehouse2products','ware_productqty','int','10',0);
alter table ld_warehouse2products modify column ware_productqty decimal(25,8);
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual
where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update ld_relatedLists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

call AddColumn('ld_tabshare','createdtime','datetime','','');

UPDATE ld_tabshare a
LEFT JOIN  ld_reminds b ON a.crmid=b.related_to
SET a.createdtime=b.createdtime
WHERE b.related_to>0
	AND b.content LIKE '%共享给您，请及时关注！'
	AND IFNULL(a.createdtime,'')=''
	AND b.createdtime<=NOW();
delimiter;
-- 2018-08-27

DROP PROCEDURE IF EXISTS `DEL_FK`;
DROP PROCEDURE IF EXISTS `delcrmentityfld`;
DROP PROCEDURE IF EXISTS `deltepotstagehistory`;
DROP PROCEDURE IF EXISTS `deleteApproveLogByDelete`;
DROP PROCEDURE IF EXISTS `add_currentapprover_field`;
DROP PROCEDURE IF EXISTS `add_expiry_date`;
DROP PROCEDURE IF EXISTS `add_lastlistprice_lasttaxprice`;
DROP PROCEDURE IF EXISTS `add_serialnumber`;
DROP PROCEDURE IF EXISTS `addblocklableintotrantable`;
DROP PROCEDURE IF EXISTS `addfldcrmentityinfo`;
DROP PROCEDURE IF EXISTS `addLinksForModuleImport`;
DROP PROCEDURE IF EXISTS `addModuleActivity`;
DROP PROCEDURE IF EXISTS `addModulePrintField`;
DROP PROCEDURE IF EXISTS `addparenttablabelintotrantable`;
DROP PROCEDURE IF EXISTS `AddProductColumn`;
DROP PROCEDURE IF EXISTS `addproducttoolfieldintotrantable`;
DROP PROCEDURE IF EXISTS `addseativityrelintoactivity`;
DROP PROCEDURE IF EXISTS `addtablabelintotrantable`;
DROP PROCEDURE IF EXISTS `addtaxinfointotrantable`;
DROP PROCEDURE IF EXISTS `calendarprofile`;
DROP PROCEDURE IF EXISTS `ChangeColumn`;
DROP PROCEDURE IF EXISTS `changeColumnTittle`;
DROP PROCEDURE IF EXISTS `crm_addtab_intoprofile`;
DROP PROCEDURE IF EXISTS `enaddfieldlabelintotrantable`;
DROP PROCEDURE IF EXISTS `f_addTableKeyIndex`;
DROP PROCEDURE IF EXISTS `getTaxInfoForFormula`;
DROP PROCEDURE IF EXISTS `insert_tabwithproductview`;
DROP PROCEDURE IF EXISTS `insert_templatesstuff`;
DROP PROCEDURE IF EXISTS `insertWorkreply`;
DROP PROCEDURE IF EXISTS `insertWorkreply2user`;
DROP PROCEDURE IF EXISTS `insertintoapproveremindsinfo`;
DROP PROCEDURE IF EXISTS `ldcrm_insertinto_sequence`;
DROP PROCEDURE IF EXISTS `ldcrm_initial_appuiset`;
DROP PROCEDURE IF EXISTS `ldcrm_allprofile_bytabaction`;
DROP PROCEDURE IF EXISTS `ldcrm_addpermission_bytabaction`;
DROP PROCEDURE IF EXISTS `loopapproveremindmethod`;
DROP PROCEDURE IF EXISTS `loopapprovereminduser`;
DROP PROCEDURE IF EXISTS `modifyproducttoolfield`;
DROP PROCEDURE IF EXISTS `puyoung_update_serialnumber`;
DROP PROCEDURE IF EXISTS `rel_shareuser`;
DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx`;
DROP PROCEDURE IF EXISTS `Select_Customview_Insertinto_tabwithproductview`;
DROP PROCEDURE IF EXISTS `set_default_columnlist_V700`;
DROP PROCEDURE IF EXISTS `setProductToolFields`;
DROP PROCEDURE IF EXISTS `setServiceGroupSequence`;
DROP PROCEDURE IF EXISTS `setwarehouseconditionentity_title`;
DROP PROCEDURE IF EXISTS `uddate_account_firtconcatuser`;
DROP PROCEDURE IF EXISTS `update_account_columnindex`;
DROP PROCEDURE IF EXISTS `update_attachment_name`;
DROP PROCEDURE IF EXISTS `update_attachmentsforbills_id`;
DROP PROCEDURE IF EXISTS `update_tranlabel`;
DROP PROCEDURE IF EXISTS `update9permissionto16`;
DROP PROCEDURE IF EXISTS `update_stuffsequence`;
DROP PROCEDURE IF EXISTS `update_ServiceCharge_cvcolumnlist`;
DROP PROCEDURE IF EXISTS `update_ld_fieldwxmaininfo_link2normal`;
DROP PROCEDURE IF EXISTS `update_field_ProjectProgress_enddate`;
DROP PROCEDURE IF EXISTS `update_currentapprover_data`;
DROP PROCEDURE IF EXISTS `update_producttoolfield_taxname`;
DROP PROCEDURE IF EXISTS `update_producttoolfield_width`;
DROP PROCEDURE IF EXISTS `updatecaidandingzhi`;
DROP PROCEDURE IF EXISTS `updatecolumnindex`;
DROP PROCEDURE IF EXISTS `updatecontactscolumnindex`;
DROP PROCEDURE IF EXISTS `updateParent_lineitem_id`;
DROP PROCEDURE IF EXISTS `updateprofieldseq`;
DROP PROCEDURE IF EXISTS `updateprofieldseq2`;
DROP PROCEDURE IF EXISTS `updatequicactionsseq`;

DROP PROCEDURE IF EXISTS `insertReader`;
DROP PROCEDURE IF EXISTS `GetAllRoleIntoPicklist`;
DROP PROCEDURE IF EXISTS `InsertRole2picklist`;
DROP PROCEDURE IF EXISTS `update_products_columnindex`;
DROP PROCEDURE IF EXISTS `UpdateInvoiceIntoCashBill`;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','signin1','签到拜访','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='signin1' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','signin1','Sign in','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='signin1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','to1','给','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='to1' and Labeltype='fixedstr');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','to1',' to ','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='to1' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = '将{$Accounts.Accounts}转为公海客户' where labelbol = 'TOBETHEHIGHSEASCUSTOMTERS' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '将{$Accounts.Accounts}转为普通客户' where labelbol = 'TOBETHEORDINARYCUSTOMERS' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

delete from ld_desk where labelbol='ANNUALREMIND' and Labeltype='fixedstr';
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANNUALREMIND','每年提醒','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ANNUALREMIND' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANNUALREMIND','Annual reminding','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ANNUALREMIND' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid=6;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='locationaddress');
UPDATE ld_tranlabel SET fieldlabel='定位' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='Location' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en';
UPDATE ld_field SET fieldlabel='定位' WHERE fieldid=@fieldid;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_street');
UPDATE ld_tranlabel SET fieldlabel='详细地址' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
UPDATE ld_field SET fieldlabel='详细地址' WHERE fieldid=@fieldid;


SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_LOCATION_ADDRESS');
SET @field_cnt=(SELECT COUNT(fieldid) FROM ld_field WHERE tabid=@tabid AND block= @blockid);
DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND Relateid=@blockid AND tabid=@tabid AND @field_cnt=1;
DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_LOCATION_ADDRESS' AND @field_cnt=1;

SET @blockid2=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='bill_country');
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@blockid2;
UPDATE ld_field SET sequence=0,block=@blockid2 WHERE tabid=@tabid AND columnname='locationaddress';
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@blockid2 ORDER BY sequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='ServiceCharge');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='locationaddress');
UPDATE ld_tranlabel SET fieldlabel='定位' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='Location' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en';
UPDATE ld_field SET fieldlabel='定位' WHERE fieldid=@fieldid;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bill_street');
UPDATE ld_tranlabel SET fieldlabel='详细地址' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
UPDATE ld_field SET fieldlabel='详细地址' WHERE fieldid=@fieldid;


SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_LOCATION_ADDRESS');
SET @field_cnt=(SELECT COUNT(fieldid) FROM ld_field WHERE tabid=@tabid AND block= @blockid);
DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND Relateid=@blockid AND tabid=@tabid AND @field_cnt=1;
DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_LOCATION_ADDRESS' AND @field_cnt=1;

SET @blockid2=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='bill_country');
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@blockid2;
UPDATE ld_field SET sequence=0,block=@blockid2 WHERE tabid=@tabid AND columnname='locationaddress';
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@blockid2 ORDER BY sequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Commission');
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
SELECT @tabid,2,1,0,0,3,12 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=2);
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ifyoufailpleasesetupashort','勾选失败，请设置短信账户！','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='ifyoufailpleasesetupashort' and Labeltype='jspop');
 
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ifyoufailpleasesetupashort','If you fail, please set up a short message account.','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='ifyoufailpleasesetupashort' and Labeltype='jspop');
delimiter;
-- 2018-08-29

DROP PROCEDURE IF EXISTS `update_relatedlists_seq`;
DROP PROCEDURE IF EXISTS `insertaccountsetcondition`;

DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND Relateid IN (SELECT fieldid FROM ld_field WHERE tablename='ld_customerdetails');
DELETE FROM ld_field WHERE tablename='ld_customerdetails';


select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_ADDRESS_INFORMATION';
update ld_field set sequence = sequence + 1000 where tabid = 6 and block = @blockid;
update ld_field set block = @blockid,sequence = 1 where tabid = 6 and columnname = 'locationaddress';
select tabid into @tabid from ld_tab where `name` = 'Accounts';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_ADDRESS_INFORMATION' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress_map','yes','ld_account',1,64,'locationaddress_map','定位地址地图',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress_map');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress_map';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'地图' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Map' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_account','locationaddress_map','varchar','20',NULL);
CALL getallprofile('Accounts');
CALL fieldprofile('Accounts');
CALL getallprofile('ServiceCharge');
CALL fieldprofile('ServiceCharge');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTSMAP','客户地图','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACCOUNTSMAP' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTSMAP','Account Map','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACCOUNTSMAP' and labeltype = 'jspop');
delimiter;

select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_LOCATION_ADDRESS' and tabid = 13;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select 13,@max_fieldid+1,'locationaddress_map','yes','ld_troubletickets',1,64,'locationaddress_map','定位地址地图',1,2,NULL,NULL,2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = 13 and columnname = 'locationaddress_map');
delimiter;

select fieldid into @relateid from ld_field where tabid = 13 and columnname = 'locationaddress_map';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',13,@relateid,'地图' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = 13 and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',13,@relateid,'Map' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = 13 and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 13 and columnname = 'locationaddress';
update ld_tranlabel set fieldlabel = '定位' where tabid = 13 and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
delimiter;

CALL AddColumn('ld_troubletickets','locationaddress_map','varchar','20',NULL);
CALL getallprofile('HelpDesk');
CALL fieldprofile('HelpDesk');
delimiter;


select sequence into @sequence from ld_systems_deploy  where deploy_type=1;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=1;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,162,'设置合同订单保存后是否自动创建收款单',@sequence+1,1,'select',0,'[{"value":"0","text":"NOTCREATE"},{"value":"1","text":"CREATEAFTERSAVE"},{"value":"2","text":"CREATEAFTERAPPROVE"},{"sql":""},{"relatedmodule":"SalesOrder,CashBill"}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=162);

select sequence into @sequence from ld_systems_deploy  where deploy_type=59;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=1;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,163,'设置服务合同保存后是否立即创建收款单',@sequence+1,1,'select',0,'[{"value":"0","text":"NOTCREATE"},{"value":"1","text":"CREATEAFTERSAVE"},{"value":"2","text":"CREATEAFTERAPPROVE"},{"sql":""},{"relatedmodule":"ServiceContracts,CashBill"}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=163);
delimiter;

select deploy_type into @reateid from ld_systems_deploy where deploy_type=162;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@reateid,@reateid,'设置{$SalesOrder.SalesOrder}保存后是否自动创建{$CashBill.CashBill}' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and relateid=@relateid and tabid=@relateid and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@reateid,@reateid,'Whether to create Payment Bills immediately after creating Sales Order' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and relateid=@relateid and tabid=@relateid and languagetype='en');
delimiter;

select deploy_type into @reateid from ld_systems_deploy where deploy_type=163;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@reateid,@reateid,'设置{$ServiceContracts.ServiceContracts}保存后是否自动创建{$CashBill.CashBill}' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and relateid=@relateid and tabid=@relateid and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@reateid,@reateid,'Whether to create Payment Bills immediately after creating Service Contracts' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and relateid=@relateid and tabid=@relateid and languagetype='en');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @blockid;
update ld_field set block = @blockid,sequence = 1 where tabid = @tabid and columnname = 'locationaddress';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_ADDRESS_INFORMATION' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress_map','yes','ld_account',1,64,'locationaddress_map','定位地址地图',1,2,NULL,NULL,2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress_map');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress_map';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'地图' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Map' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

UPDATE ld_systems_deploy SET description='合同订单新增保存后是否自动创建出库单。仓库名称为空:否，仓库名称不为空:是' WHERE deploy_type=56;
UPDATE ld_systems_deploy SET description='合同订单编辑保存后是否自动创建出库单。仓库为空:否，不为空:是' WHERE deploy_type=63;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh' ,'onlyshowpaymorethanzero','只显示应付款大于0','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='onlyshowpaymorethanzero' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en' ,'onlyshowpaymorethanzero','只显示应付款大于0','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='onlyshowpaymorethanzero' and Labeltype='fixedstr');
delimiter;
-- 2018-08-30

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

update ld_version set old_version='V7.4.9',current_version='V7.4.9',remark='V7.4.9-20180830',wx_version='V7.4.9';
delimiter;