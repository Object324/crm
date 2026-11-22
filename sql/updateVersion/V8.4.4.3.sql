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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE','未授权工商查询接口，请联系供应商授权或使用自有key','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE',"Unauthorized industrial and commercial query interface, please contact the supplier for authorization or use your own key",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE' and labeltype='jspop');
delimiter;

call AddColumn('ld_profile2field','editreadonly','int','19',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVISIBLE','不可见','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INVISIBLE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVISIBLE',"Invisible",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INVISIBLE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READONLYPERMISSIONSDURINGEDIT','编辑时只读','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READONLYPERMISSIONSDURINGEDIT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READONLYPERMISSIONSDURINGEDIT',"Read only during editing",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READONLYPERMISSIONSDURINGEDIT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVISIBLEEXPLAIN','不可见：新增、编辑、查看界面不显示；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INVISIBLEEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVISIBLEEXPLAIN',"Invisible: the interface of creating, editing and viewing is not displayed;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INVISIBLEEXPLAIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READONLYEXPLAIN','只读权限：查看界面显示，新增、编辑界面不显示；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READONLYEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READONLYEXPLAIN',"Read-only permissions：The view interface is displayed, and the create and  edit interface is not displayed;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READONLYEXPLAIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READANDWRITEEXPLAIN','读写权限：新增、编辑、查看界面都显示，新增、编辑界面可录入；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READANDWRITEEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READANDWRITEEXPLAIN',"Read and write permission: it is displayed in the create, edit and view interfaces, and can be entered in the create and edit interfaces;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READANDWRITEEXPLAIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','READANDWRITEDURINGEDITEXPLAIN','编辑时只读：新增、编辑、查看界面都显示，仅新增界面可录入；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='READANDWRITEDURINGEDITEXPLAIN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','READANDWRITEDURINGEDITEXPLAIN',"Read only during editing: the create, edit and view interfaces are displayed, and only the create interface can be entered;",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='READANDWRITEDURINGEDITEXPLAIN' and labeltype='fixedstr');
delimiter;
-- 2021-11-05

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

UPDATE ld_version SET old_version='V8.4.4.3',current_version='V8.4.4.3',remark='V8.4.4.3-20211105',wx_version='V8.4.5.1';
delimiter;