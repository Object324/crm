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

call addcolumn('ld_communicationaccount','service_tel','varchar',255,null);
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','该单据审批状态已变化，请重新加载该单据','Approvestephavechangetip' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Approvestephavechangetip' and languagetype='zh' and labeltype='fixedstr' );

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','The status of this record has been changed,please reload this record','Approvestephavechangetip' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Approvestephavechangetip' and languagetype='en' and labeltype='fixedstr' );
delimiter;

call addcolumn('ld_approve','default_on_new','varchar',255,null);
alter table `ld_approve` alter column `default_on_new` drop default;
alter table `ld_approve` alter column `default_on_new` set default 'no';
call addcolumn('ld_approve','default_on_submit','varchar',255,null);
alter table `ld_approve` alter column `default_on_submit` drop default;
alter table `ld_approve` alter column `default_on_submit` set default 'no';
update ld_approve set default_on_new='no' where default_on_new <> 'yes';
update ld_approve set default_on_submit='no' where default_on_new <> 'yes';
delete from ld_desk where labelbol='APPROVEFINISHEDALLOWEDIT' and languagetype='en';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEFINISHEDALLOWEDIT','Whether editing documents is allowed at the end of approval','fixedstr' from dual where not exists(select 1 from ld_desk  where labelbol='APPROVEFINISHEDALLOWEDIT' and labeltype='fixedstr' and languagetype='en');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','APPROVEDEFAULTVALUEONNEW','是否移动端新建时默认流程','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='APPROVEDEFAULTVALUEONNEW' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEDEFAULTVALUEONNEW','Default values when new on the mobile','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='APPROVEDEFAULTVALUEONNEW' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','APPROVEDEFAULTVALUEONSUBMIT','是否提交审批时默认流程','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='APPROVEDEFAULTVALUEONSUBMIT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEDEFAULTVALUEONSUBMIT','Default process when submitting for approval','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='APPROVEDEFAULTVALUEONSUBMIT' and labeltype='fixedstr');
delimiter;
-- 2019-08-02

UPDATE ld_workreport
SET sendlog_workdate=(
	CASE
		WHEN type=1 THEN DATE_FORMAT(createdtime,'%Y-%m-%d')
		WHEN type=2 THEN CONCAT(DATE_SUB(DATE_FORMAT(createdtime,'%Y-%m-%d'),INTERVAL DATE_FORMAT(createdtime,'%w')-1 DAY),' ~ ',DATE_SUB(DATE_FORMAT(createdtime,'%Y-%m-%d'),INTERVAL DATE_FORMAT(createdtime,'%w')-7 DAY))
		WHEN type=3 THEN CONCAT(DATE_FORMAT(LAST_DAY(createdtime),'%Y-%m-'),'01',' ~ ',LAST_DAY(createdtime)) 
	END
)
WHERE IFNULL(sendlog_workdate,'')='';

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

UPDATE ld_version SET old_version='V7.8.1.3',current_version='V7.8.1.3',remark='V7.8.1.3-20190802',wx_version='V7.8.1.3';
delimiter;