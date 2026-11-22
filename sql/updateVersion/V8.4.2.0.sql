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

select tabid into @tabid from ld_tab where name='salesorder';
update ld_field set typeofdata='N~O~25,2' where columnname='purchasecost' and tabid=@tabid;
delimiter;
update ld_relatedlists set type='' ,related_coltable='' where  `name`='get_singin' and label='Singin';
delimiter;


select tabid into @tabid from ld_tab where `name`='Project';
select tabid  into @related_tabid from  ld_tab where `name`='singin';
select presence into @presence from ld_option_module where tabid=@related_tabid and option_tabid=@tabid;
select max(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @maxsequence from ld_relatedlists where tabid=@tabid;
update ld_relatedlists_seq set id=@relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid); 
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,label,presence,wx_presence,wx_sequence,sequence)
select @relation_id+1,@tabid,@related_tabid,'get_singin','Singin',@presence,@presence,@maxsequence+1,@maxsequence+1 from dual 
where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
delimiter;

call AddColumn('ld_servicecontracts','kis_id','varchar','200',NULL);
call AddColumn('ld_servicecontracts','kis_no','varchar','200',NULL);
ALTER TABLE ld_servicecontracts  MODIFY COLUMN `kis_id` varchar(200) NULL DEFAULT null;
delimiter;
-- 2021-03-19

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

UPDATE ld_version SET old_version='V8.4.2.0',current_version='V8.4.2.0',remark='V8.4.2.0-20210315',wx_version='V8.4.2.0';
delimiter;