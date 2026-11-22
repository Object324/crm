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

select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and columnname = 'rating';
delimiter;
-- 2020-02-20

update ld_setscoperhigher set modulename='UnAssignedAccounts' where modulename='NOALLOCATEACCOUNTS';
update ld_scoperhigher set modulename='UnAssignedAccounts' where modulename='NOALLOCATEACCOUNTS';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_field set typeofdata = 'DT~O' where tabid = @tabid and typeofdata = 'datetime';
delimiter;

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

UPDATE ld_version SET old_version='V7.9.9.10',current_version='V7.9.9.10',remark='V7.9.9.10-20200220',wx_version='V7.9.9.8';
delimiter;