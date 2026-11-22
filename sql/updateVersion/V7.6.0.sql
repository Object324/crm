DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;


UPDATE ld_tranlabel SET fieldlabel='“库存状态”更新的触发点' WHERE trantable='ld_systems_deploy' AND languagetype='zh' AND Relateid=48;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MINIPROFRAMEREMINDDEC','Edit will affect the current login and use of small procedures, if there is an exception, please log out and re-login','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MINIPROFRAMEREMINDDEC' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MINIPROFRAMEREMINDDEC','编辑后会影响当前正在登录和使用的小程序，如果有异常请退出后重新登录！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MINIPROFRAMEREMINDDEC' and Labeltype='jspop');
delimiter;

UPDATE ld_cvcolumnlist_wx SET columnname=REPLACE(columnname,':Accounts_',':ServiceCharge_') WHERE modulename='ServiceCharge';
UPDATE ld_cvcolumnlist_wx SET columnname=REPLACE(columnname,'assigned_user_id','servicecasher') WHERE modulename='ServiceCharge' AND columnname LIKE 'ld_account:smownerid%';
UPDATE ld_cvcolumnlist_wx SET columnname=REPLACE(columnname,'smownerid','servicecasher') WHERE modulename='ServiceCharge' AND columnname LIKE 'ld_account:smownerid%';

DELETE FROM ld_settings_field WHERE  `name`='LBL_ACCOUNTS_CONTACTS_FIELDS' AND EXISTS (SELECT 1 FROM ld_blockdisplay WHERE is_display=1);

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock');
UPDATE ld_field SET displaytype=3 WHERE tabid=@tabid AND columnname='stockpresence';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('pay_amount','pay_balance','sendcashbilldate')
	AND NOT EXISTS (SELECT 1 FROM ld_sendcashbill2payment WHERE entitytype='Stock');
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('have_invoicetotal','nothave_invoicetotal','lastinvoicedate','lastinvoice_no')
	AND NOT EXISTS (SELECT 1 FROM ld_purchaseinvoice a LEFT JOIN ld_inventoryproductrel b ON a.purchaseinvoiceid=b.id WHERE b.entitytype='Stock');
delimiter;

DELETE FROM ld_picklist_values WHERE listid IS NULL;

UPDATE ld_field SET approve_demand=2 WHERE uitype IN (72,5,1,1109,70,15,64,65,52,131,132,560,4,56,166,130,11,1101,1102,117,118,13,19,2,21,609,7,71,53,153,154);
UPDATE ld_field SET approve_demand=2 WHERE tabid=6 AND columnname='potentialid' AND displaytype=2;
UPDATE ld_field SET approve_demand=2 WHERE tablename='ld_dividendorder' AND columnname='accountid' AND displaytype=2;

ALTER TABLE ld_field ALTER COLUMN approve_demand SET DEFAULT 2;

SET @usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='InventoryAccount' LIMIT 1);
UPDATE ld_usereportcolumns SET sequence=8,columnshow=1 WHERE Usereportid=@usereportid AND `columns` LIKE 'ld_warehouse:warhouse:%';
delimiter;

update ld_systems_deploy set inputvalue='[{"value":"0","text":"Approvals"},{"value":"1","text":"SAVE"},{"sql":""},{"or_relatedmodule":"OutboundOrder,Stock"}]'
where deploy_type=48 ;
delimiter;
-- 2018-12-06

DROP PROCEDURE IF EXISTS `drop_disabled_tmptable`;
delimiter ||
CREATE  PROCEDURE `drop_disabled_tmptable`(
)
BEGIN

	DECLARE tmp_tablename VARCHAR(200) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
				SELECT 
					TABLE_NAME 
				FROM information_schema.TABLES 
				WHERE TABLE_SCHEMA=DATABASE() 
					AND TABLE_TYPE='BASE TABLE' 
					AND (TABLE_NAME LIKE 'allocate_tmp_%' OR TABLE_NAME LIKE 'mass_del_tmp_%' OR TABLE_NAME LIKE 'vt_tmp_u%');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tablename;
	WHILE(IFNULL(tmp_tablename,'')<>'') DO
		SET @querysql=CONCAT('DROP TABLE IF EXISTS ',tmp_tablename);
		PREPARE stmt FROM @querysql;
		EXECUTE stmt;
		DROP PREPARE stmt;
		FETCH MYCUSOR INTO tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;


end ||
delimiter;

CALL drop_disabled_tmptable();
DROP PROCEDURE IF EXISTS `drop_disabled_tmptable`;
delimiter;

DROP PROCEDURE IF EXISTS `drop_disabled_cfptable`;
delimiter ||
CREATE  PROCEDURE `drop_disabled_cfptable`(
)
BEGIN

	DECLARE tmp_tablename VARCHAR(200) DEFAULT '';
	DECLARE tmp_tablename1 VARCHAR(200) DEFAULT '';  

	DECLARE MYCUSOR CURSOR FOR 
				SELECT 
					TABLE_NAME,
					LEFT(TABLE_NAME,LENGTH(TABLE_NAME)-4) AS TABLE_NAME1
				FROM information_schema.TABLES 
				WHERE TABLE_SCHEMA=DATABASE() 
					AND TABLE_TYPE='BASE TABLE' 
					AND LEFT(TABLE_NAME,6)='ld_cf_' 
					AND RIGHT(TABLE_NAME,4)='_seq';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tablename,tmp_tablename1;
	WHILE(IFNULL(tmp_tablename,'')<>'') DO
		SET @querysql=CONCAT('DROP TABLE IF EXISTS ',tmp_tablename);
		SET @querysql1=CONCAT('DROP TABLE IF EXISTS ',tmp_tablename1);
		PREPARE stmt FROM @querysql;
		PREPARE stmt1 FROM @querysql1;
		EXECUTE stmt;
		EXECUTE stmt1;
		DROP PREPARE stmt;
		DROP PREPARE stmt1;
		FETCH MYCUSOR INTO tmp_tablename,tmp_tablename1;
	END WHILE;
	CLOSE MYCUSOR;


end ||
delimiter;

CALL drop_disabled_cfptable();
DROP PROCEDURE IF EXISTS `drop_disabled_cfptable`;
delimiter;

select sequence into @sequence from ld_systems_deploy where setype='SalesOrder' and roottype=2;
update ld_systems_deploy set sequence=sequence+2 where sequence>@sequence and roottype=2 ;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '0',197,'销售退货单是否启用审批流程','SalesBack',@sequence+1,2,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type=197);
call AddColumn('ld_salesback','approvestatus','varchar',100,'未提交' );
delimiter;
call AddColumn('ld_salesback','approveby','int',19,0 );
delimiter;
call AddColumn('ld_salesback','currentapprover','varchar',1000,'' );
delimiter;
call AddColumn('ld_salesback','approvetime','datetime',12,'' );
delimiter;

select tabid into @tabid from ld_tab where name='salesback';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SalesBack_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field  where tabid=@tabid and columnname='approvestatus');
insert into ld_field (fieldid,columnname,allowhide,tablename,tabid,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @maxfieldid+1,'approvestatus' ,'yes','ld_salesback',@tabid,609,'approvestatus','审批状态',1,0,5,@blockid,2,'V~O',1 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

select fieldid into @relateid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'zh','审批状态','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and Relateid=@relateid);

select fieldid into @relateid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'en','Approve Status','ld_salesback',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and Relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='salesback';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SalesBack_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field  where tabid=@tabid and columnname='approveby');
insert into ld_field (fieldid,columnname,allowhide,tablename,tabid,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @maxfieldid+1,'approveby' ,'yes','ld_salesback',@tabid,131,'approveby','上一步审批人',1,0,6,@blockid,2,'V~O',1 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approveby');

select fieldid into @relateid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'zh','上一步审批人','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and Relateid=@relateid);

insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'en','The Last Approver','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and Relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='salesback';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SalesBack_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field  where tabid=@tabid and columnname='currentapprover');
insert into ld_field (fieldid,columnname,allowhide,tablename,tabid,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @maxfieldid+1,'currentapprover' ,'yes','ld_salesback',@tabid,132,'currentapprover','当前审批人',1,0,7,@blockid,2,'V~O',1 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');

select fieldid into @relateid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'zh','当前审批人','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and Relateid=@relateid);

insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'en','Current Approver','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and Relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='salesback';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SalesBack_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field  where tabid=@tabid and columnname='approvetime');
insert into ld_field (fieldid,columnname,allowhide,tablename,tabid,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate)
select @maxfieldid+1,'approvetime' ,'yes','ld_salesback',@tabid,70,'approvetime','最新审批时间',1,0,8,@blockid,2,'DT~O',1 from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvetime');

select fieldid into @relateid from ld_field where tabid=@tabid and columnname='approvetime';
insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'zh','最新审批时间','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and Relateid=@relateid);

insert into ld_tranlabel(languagetype,fieldlabel,trantable,relateid,tabid)
select 'en','Last approval time','ld_field',@relateid,@tabid from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and Relateid=@relateid);
delimiter;
call getallprofile("SalesBack");
delimiter;
select tabid into @tabid from ld_tab where name='salesback';
update ld_field set displaytype=1,uitype=15,defaultvalue='已入库' where tabid=@tabid and columnname='salesbackstatus';
delimiter;
insert into ld_picklist_set(listname,relatetable,parent_listname,parent_relatetable)
select 'salesbackstatus','ld_field','','' from dual 
where not exists(select 1 from ld_picklist_set where listname='salesbackstatus' and relatetable='ld_field');

select listid into @listid from ld_picklist_set where listname='salesbackstatus' and relatetable='ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'未入库' ,1 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=1);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'已入库' ,2 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=2);
delimiter;
	
select tabid into @tabid from  ld_tab where name='salesback';
select fieldlabel into @tmp_zhmoudulename from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh' and trantable='ld_tab' ;
SET @approvename=CONCAT(@tmp_zhmoudulename,'选人审批流程');
SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
	SELECT @approveid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0,'no' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
	SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
delimiter;

update ld_salesback set approvestatus='已批准' where salesbackstatus='已入库' and approvestatus is null ;
delimiter;

select fieldid into @fieldid from ld_field where tabid = 6 and columnname = 'nolinkdays';
update ld_tranlabel set fieldlabel = '未联系天数' where tabid = 6 and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
delimiter;
-- 2018-12-07

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

UPDATE ld_version SET old_version='V7.6.0',current_version='V7.6.0',remark='V7.6.0-20181210',wx_version='V7.6.0';
delimiter;