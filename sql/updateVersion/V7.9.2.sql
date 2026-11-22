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

SET @id=(SELECT id FROM ld_wx_config WHERE `name`='dingtalk_setting' LIMIT 1);
DELETE FROM ld_wx_config WHERE `name`='dingtalk_setting' AND id > @id;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Singin' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_option_module WHERE tabid=@tabid AND option_tabid=14);
SET @tabsequence=(SELECT tabsequence FROM ld_tab WHERE `name`='Singin' LIMIT 1);
UPDATE ld_option_module SET sequence=sequence+2 WHERE tabid=@tabid AND sequence>=@seq;

SET @i=0;
SET @option_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Campaigns' LIMIT 1);
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence,maxrowsshow)
SELECT @tabid,@option_tabid,0,0,0,@seq-1,@tabsequence,5 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

UPDATE ld_option_module SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

CALl AddColumn('ld_customreport_info','databaselinktype','varchar','50','crmlink');
delimiter;

CALl AddColumn('ld_field','parentbigtype','varchar','50','');
delimiter;

update ld_field set bigtype='text' where uitype=1 or uitype=2;
delimiter;

update ld_field inner join (
select ld_field.bigtype,tmp.effect_fieldid from ld_field INNER JOIN (
select ld_related_field.fromvalue_info,ld_related_field.effect_fieldid  from ld_field
inner join ld_related_field
on ld_related_field.effect_fieldid=ld_field.fieldid where  bigtype='relatedmodulefield'
and fieldtype='main') as tmp on  tmp.fromvalue_info=ld_field.fieldname) as tmp_one
on tmp_one.effect_fieldid=ld_field.fieldid 
set parentbigtype=tmp_one.bigtype;
delimiter;

update ld_customreport_info set databaselinktype='crmlink' where systemdefault=1;
delimiter;
update ld_customreport_info set report_type='template_flex' where report_type='template';
delimiter;

update ld_desk set fieldlabel='Stimulsoft Reports.PHP 模板' where labelbol='STIMULSORTREPORTSPHP' and labeltype='fixedstr' and languagetype='zh';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UseSysConfigParam','使用系统配置参数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UseSysConfigParam' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','UseSysConfigParam','Using System Configuration Parameters','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UseSysConfigParam' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UseTemplateParam','使用模板配置参数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UseTemplateParam' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','UseTemplateParam','Using Template Configuration Parameters','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UseTemplateParam' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DataBaseLink','数据库连接:','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DataBaseLink' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DataBaseLink','DataBase Link:','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DataBaseLink' and labeltype='fixedstr');
delimiter;


select blockid into @blockid from ld_settings_blocks  where label='LBI_UI_SETTINGS';
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'LBL_HREFMODULE_Custom','pageset.png','链接模块定制','index.php?module=Settings&action=LinkModuleCustom&parenttab=Settings',2, 0 from dual 
where not exists(select 1 from ld_settings_field where `name`='LBL_HREFMODULE_Custom');
delimiter;

update ld_settings_field INNER JOIN (
SELECT @sequnece:=@sequnece+1 AS seq,name FROM (SELECT @sequnece:=0) r, ld_settings_field where blockid=@blockid 
 ORDER BY sequence asc ,fieldid desc
) as tmpone on tmpone.name=ld_settings_field.name 
set ld_settings_field.sequence=tmpone.seq;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_HREFMODULE_Custom','链接模块定制','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_HREFMODULE_Custom' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_HREFMODULE_Custom','Link Module Customization','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_HREFMODULE_Custom' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_HREFMODULE_CustomDescription','自定义的链接模块允许在网页端菜单定制或移动端菜单定制中选择','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_HREFMODULE_CustomDescription' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_HREFMODULE_CustomDescription','Customized Link Module allows you to choose in Web-side or Mobile-side menu customization','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_HREFMODULE_CustomDescription' and labeltype='fixedstr');
delimiter;


CREATE TABLE if not exists `ld_linkmodulecustom` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `zh_label` varchar(100) DEFAULT NULL,
  `en_label` varchar(100) DEFAULT NULL,
  `url` varchar(300) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'yes',
  `scope` varchar(20) DEFAULT NULL,
  `smcreatorid` int(19) DEFAULT NULL,
  `modifiedby` int(19) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_linkmodulecustom2user` (
  `linkmodulecustomid` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CALl AddColumn('ld_parenttabrel','tab_tablename','varchar','50','ld_tab');
delimiter;
CALl AddColumn('ld_appparenttabrel','tab_tablename','varchar','50','ld_tab');
delimiter;

update ld_parenttabrel set tab_tablename='ld_tab' where tab_tablename is null or tab_tablename='';
delimiter;
update ld_appparenttabrel set tab_tablename='ld_tab' where tab_tablename is null or tab_tablename='';
delimiter;
-- 2019-10-17
						

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

UPDATE ld_version SET old_version='V7.9.2',current_version='V7.9.2',remark='V7.9.2-20191018',wx_version='V7.9.2';
delimiter;