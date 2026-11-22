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

SET @my_languagetype='en';
SET @my_labelbol='THISDOCUMENTISUNDEREXAMINATIONAND';
SET @my_fieldlabel='This record has been approved, which can’t be deleted! Please contact the approver.';
UPDATE ld_desk SET fieldlabel=@my_fieldlabel WHERE labelbol=@my_labelbol AND languagetype=@my_languagetype;
	
SET @my_languagetype='en';
SET @my_labelbol='THERECORDPROCESSEDING';
SET @my_fieldlabel='This record has been approved, which can’t be edited!';
UPDATE ld_desk SET fieldlabel=@my_fieldlabel WHERE labelbol=@my_labelbol AND languagetype=@my_languagetype;
-- 2020-04-11

CALl AddColumn('ld_seattachmentsrel','attachmentcolumnname','varchar','50','');
delimiter;

update ld_seattachmentsrel 
LEFT JOIN ld_attachments on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid 
LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_seattachmentsrel.attachmentsid 
set attachmentcolumnname = 'imagename' where locate('Image',ld_crmentity.setype) 
and (attachmentcolumnname is NULL OR attachmentcolumnname = '');
delimiter;

update ld_seattachmentsrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_seattachmentsrel.crmid 
set attachmentcolumnname = case when (ld_crmentity.setype = 'Documents') then 'name' when (locate('Image',ld_crmentity.setype)) then 'imagename' else 'filename' end 
where (attachmentcolumnname is NULL OR attachmentcolumnname = '');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CANNOTEMPTYORZERO','不能为空或0','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTEMPTYORZERO' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CANNOTEMPTYORZERO','cannot be empty or 0','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTEMPTYORZERO' and Labeltype='jspop');
delimiter;
update ld_relatedlists set label='Download_Browse_Record'  where name='getAuditTrialLog';

update ld_desk set labelbol='Download_Browse_Record' where labelbol='Download Browse Record';
delimiter;
-- 2020-04-14

CALL AddColumn('ld_activity_reminder','email_sendtime','datetime','','');

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'MinusJobBill','ld_tabdetailfield','starttime','m','小于等于' from dual 
where not exists(select 1 from ld_validatasave where module='MinusJobBill' and relatedtable='ld_tabdetailfield' 
and fieldname='starttime');

delimiter;

select id into @relateid from ld_validatasave where module='MinusJobBill' 
and relatedtable='ld_tabdetailfield' and fieldname='starttime';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','endtime',1 from dual 
where not exists(select 1 from ld_validatasavedetail where relateid=@relateid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VERSIONUPDATEINFO','版本更新说明','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='VERSIONUPDATEINFO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VERSIONUPDATEINFO','Version update description','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='VERSIONUPDATEINFO' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTHELPMANUAL','产品帮助手册','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PRODUCTHELPMANUAL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTHELPMANUAL','Product help manual','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PRODUCTHELPMANUAL' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETMAIL','获取邮件','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='GETMAIL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETMAIL','Get mail','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='GETMAIL' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETTINGMAILINGLIST','正在获取邮件列表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='GETTINGMAILINGLIST' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETTINGMAILINGLIST','Getting mailing list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='GETTINGMAILINGLIST' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WRITELETTERS','写信','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WRITELETTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WRITELETTERS','Write letters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WRITELETTERS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECEIVELETTERS','收信','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RECEIVELETTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECEIVELETTERS','Receive letters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='RECEIVELETTERS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAILBOXSETTINGS','邮箱设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MAILBOXSETTINGS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAILBOXSETTINGS','Mailbox settings','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MAILBOXSETTINGS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARMAIL','星标邮件','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='STARMAIL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARMAIL','Star mail','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='STARMAIL' and Labeltype='fixedstr');
delimiter;


select tabid into @tabid from ld_tab where name='salesback';
select actionid into @actionid from  ld_actionmapping where actionlabel='ENDRETURNGOODS';
delete from ld_profileallpermission where tabid=@tabid and operation=@actionid;
delete from ld_profile2standardpermissions where tabid=@tabid and operation=@actionid;
delimiter;

select tabid into @tabid from ld_tab where name='salesback';
select actionid into @actionid from  ld_actionmapping where actionlabel='WAREHOUSECONFIRMED';
delete from ld_profileallpermission where tabid=@tabid and operation=@actionid;
delete from ld_profile2standardpermissions where tabid=@tabid and operation=@actionid;
delimiter;

select tabid into @tabid from ld_tab where name='salesback';
select actionid into @actionid from  ld_actionmapping where actionlabel='RETRACEMENT';
delete from ld_profileallpermission where tabid=@tabid and operation=@actionid;
delete from ld_profile2standardpermissions where tabid=@tabid and operation=@actionid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETED','已删除','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETED','Deleted','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELETED' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EMPTY','清空','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EMPTY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EMPTY','Empty','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EMPTY' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DUSTBIN','垃圾箱','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DUSTBIN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DUSTBIN','Dustbin','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DUSTBIN' and Labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel='发版说明' where labelbol='VERSIONUPDATEINFO' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Release notes' where labelbol='VERSIONUPDATEINFO' and labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='帮助手册' where labelbol='PRODUCTHELPMANUAL' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Help manual' where labelbol='PRODUCTHELPMANUAL' and labeltype='fixedstr' and languagetype='en';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_templatesstuff`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT templateid FROM ld_templates;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	DELETE FROM ld_templatesstuff;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		SET @my_stuffid=tmp_id;
		SET @i=-1;
		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 35,@my_stuffid,'saleskit',(@i:=@i+1),'saleskit',0;

		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 36,@my_stuffid,'saleskit',(@i:=@i+1),'STATISTICALWEEKMONTH',0;

		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 19,@my_stuffid,'chart',(@i:=@i+1),'SALESFUNNEL',0;

		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 34,@my_stuffid,'transaction',(@i:=@i+1),'transaction',0;

		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 20,@my_stuffid,'default',(@i:=@i+1),'CRITICALVIEW',0;

		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 33,@my_stuffid,'transaction',(@i:=@i+1),'SALESCHARTS',0;

		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 1,@my_stuffid,'chart',(@i:=@i+1),'SALESSIXMONTH',0;


		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT 9,@my_stuffid,'chart',(@i:=@i+1),'INDIVIDUALSIXMONTH',0;

		
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200417`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200417`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		CALL ldcrm_reset_templatesstuff();
	END IF;

end ||
delimiter;

CALL reset_newdemoaccount_20200417();
DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff`;
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200417`;
-- 2020-04-17

UPDATE ld_entityname SET fieldname='quote_no' WHERE tabid=20 AND fieldname='subject' 
	AND EXISTS (SELECT 1 FROM ld_field WHERE tabid=20 AND columnname='subject' AND presence=1);

UPDATE ld_entityname SET fieldname='purchaseorder_no' WHERE tabid=21 AND fieldname='subject' 
	AND EXISTS (SELECT 1 FROM ld_field WHERE tabid=21 AND columnname='subject' AND presence=1);



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

UPDATE ld_version SET old_version='V8.0.0.7',current_version='V8.0.0.7',remark='V8.0.0.7-20200417',wx_version='V8.0.0.8';
delimiter;