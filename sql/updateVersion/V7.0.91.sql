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

CALL AddColumn('ld_wx_config','datetime','datetime','','');
CALL AddColumn('ld_reminds','push_time','datetime','','');
CALL AddColumn('ld_workreport_remind','push_time','datetime','','');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense'; 
update ld_tabdetailfield set fieldtype = 'Num' where tabid = @tabid and columnname = 'conversion_rate'; 
delimiter;

ALTER TABLE ld_hantian_phonerecord MODIFY COLUMN userid INT(19);
delimiter;
-- 2017-08-29

select id into @id from ld_option_showtableheader where module='Invoice' and selectmodule='SalesOrder';
update ld_option_showheader_label set columnname = 'have_invoicetotal' where columnname = 'invoicetotal' and label_from = 'desk' and optionshowtabheader_id = @id;
delimiter;

update ld_desk set fieldlabel = '我共享给他人的' where labelbol = 'Ishared' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'I share it with others' where labelbol = 'Ishared' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
delete from ld_usereportbasic where Usereportid = @usereportid and columns = 'ld_troubletickets:approvestatus:approvestatus:HelpDesk_approvestatus:I';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice'; 
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202; 
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'smownerid'; 
delete from ld_related_field where trigger_fieldid = @trigger_fieldid and @effect_fieldid = effect_fieldid; 
delimiter;
-- 2017-08-31

select tabid into @tabid from ld_tab where `name` = 'Invoice'; 
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid'; 
delete from ld_related_field where trigger_fieldid = @trigger_fieldid; 
delimiter;
-- 2017-09-04

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
delimiter;

update ld_version set old_version='V7.0.91',current_version='V7.0.91',remark='V7.0.9SP1-20170831';
delimiter;