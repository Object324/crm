DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE PROCEDURE `AddColumn`(
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

SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='Attachment');
SET @columnname = 'isenabled';
DELETE FROM ld_field where tabid=@tabid and uitype=56 and columnname=@columnname;
delimiter;


update ld_desk set fieldlabel = '已添加' where languagetype = 'zh' and labelbol = 'SUCCESSADDCART' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Added' where languagetype = 'en' and labelbol = 'SUCCESSADDCART' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_producttoolfield SET uitype=2,bigtype='textarea' WHERE columnname='comment';
delimiter;

CALL AddColumn('ld_mail_accounts','is_verify_ca','varchar',25,'yes');
ALTER TABLE ld_mail_accounts ALTER COLUMN is_verify_ca SET DEFAULT 'yes';
update ld_mail_accounts set is_verify_ca='yes' where is_verify_ca is null or is_verify_ca = '';
delimiter;

UPDATE ld_field SET allowedit='yes' WHERE uitype=1109 AND allowedit IS NULL;
UPDATE ld_field SET allowedit='yes' WHERE uitype=4 AND columnname LIKE 'customform%' AND allowedit IS NULL;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','AllowAgainSubmitApprove','已批准/拒绝的单据允许再次提交审批','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='AllowAgainSubmitApprove' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','AllowAgainSubmitApprove','Approved/rejected documents can be submitted for approval again','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='AllowAgainSubmitApprove' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_tab','againsubmit','varchar','20','no');
ALTER TABLE ld_tab ALTER COLUMN againsubmit SET DEFAULT 'no';
update ld_tab set againsubmit='no' where againsubmit is null or againsubmit = '';
delimiter;

CALL AddColumn('ld_approve','allowagainsubmit','varchar',255,'no');
ALTER TABLE `ld_approve`  ALTER COLUMN `default_on_submit` set default 'no';
update ld_approve set allowagainsubmit='no' where allowagainsubmit is null or allowagainsubmit = '';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApproveAllowAgainSubmit','审批结束编辑单据保存，自动提交审批时默认审批流程','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ApproveAllowAgainSubmit' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApproveAllowAgainSubmit','After approval, edit the document and save it. The default approval process is when it is automatically submitted for approval','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ApproveAllowAgainSubmit' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApproveAllowAgainSubmitView','编辑单据保存自动提交审批时默认审批流程','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ApproveAllowAgainSubmitView' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApproveAllowAgainSubmitView','The default approval process is when editing a document and saving it for automatic submission for approval','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ApproveAllowAgainSubmitView' and labeltype = 'fixedstr');
delimiter;
-- 2021-11-19

update ld_field set savedatabase = 'yes' where uitype = 301;
delimiter;

SET @disable_triggers=NULL;
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

UPDATE ld_version SET old_version='V8.4.5.2',current_version='V8.4.5.2',remark='V8.4.5.2-20211119',wx_version='V8.4.5.2';
delimiter;