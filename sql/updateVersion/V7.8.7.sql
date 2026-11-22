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


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','OFTENUSEREPORTTITLE1','显示库存数量为0的记录','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'OFTENUSEREPORTTITLE1' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','OFTENUSEREPORTTITLE1','Shows record that the quantity in stock is zero','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'OFTENUSEREPORTTITLE1' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_appparenttab','allocatetype','varchar',50,'all');
delimiter;

call AddColumn('ld_appparenttab','allocateid','text','','');
delimiter;

update ld_appparenttab set allocatetype='all' where allocatetype is null or allocatetype='';
delimiter;

select usereportid into @id from ld_usereport where name='checkin_monthly';
update ld_usereportcolumns set columnshow=0 where usereportid=@id and columns='time';
delimiter;

update ld_relatedlists set related_tabid=-1 where name='get_receivablesforecast' and tabid=2;
delimiter;
select tabid into @tabid from ld_tab where name='checks';
update ld_producttoolfield set uitype=729 where tabid=@tabid and columnname='batchtext';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OperationModule','操作模块','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OperationModule' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OperationModule','Operation module','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='OperationModule' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_loginhistory','entitytype','varchar',100,'');
delimiter;
-- 2019-09-04


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

UPDATE ld_version SET old_version='V7.8.7',current_version='V7.8.7',remark='V7.8.7-20190904',wx_version='V7.8.7';
delimiter;