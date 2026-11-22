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

DROP PROCEDURE IF EXISTS `ldcrm_add_column_forlangjie`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_column_forlangjie`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE account='langjie') AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tablename='ld_customform47' AND columnname='conversionrate_rmbtohkd') THEN
		CALl AddColumn('ld_customform47','accountid','INT','19',NULL);
		CALl AddColumn('ld_customform47','validfrom','DATE','12',NULL);
		CALl AddColumn('ld_customform47','validtill','DATE','12',NULL);

		CALl AddColumn('ld_customform47','conversionrate_rmbtousd','INT','19',NULL);
		CALl AddColumn('ld_customform47','conversionrate_rmbtohkd','INT','19',NULL);
		CALl AddColumn('ld_customform47','conversionrate_rmbtokrw','INT','19',NULL);
		CALl AddColumn('ld_customform47','conversionrate_rmbtovnd','INT','19',NULL);
		CALl AddColumn('ld_customform47','conversionrate_rmbtoeur','INT','19',NULL);

		ALTER TABLE ld_customform47 MODIFY COLUMN conversionrate_rmbtousd DECIMAL(25,6);
		ALTER TABLE ld_customform47 MODIFY COLUMN conversionrate_rmbtohkd DECIMAL(25,6);
		ALTER TABLE ld_customform47 MODIFY COLUMN conversionrate_rmbtokrw DECIMAL(25,6);
		ALTER TABLE ld_customform47 MODIFY COLUMN conversionrate_rmbtovnd DECIMAL(25,6);
		ALTER TABLE ld_customform47 MODIFY COLUMN conversionrate_rmbtoeur DECIMAL(25,6);

		CALl AddColumn('ld_customform48','vendorid','INT','19',NULL);
		CALl AddColumn('ld_customform48','validfrom','DATE','12',NULL);
		CALl AddColumn('ld_customform48','validtill','DATE','12',NULL);

		CALl AddColumn('ld_customform48','conversionrate_rmbtousd','INT','19',NULL);
		CALl AddColumn('ld_customform48','conversionrate_rmbtohkd','INT','19',NULL);
		CALl AddColumn('ld_customform48','conversionrate_rmbtokrw','INT','19',NULL);
		CALl AddColumn('ld_customform48','conversionrate_rmbtovnd','INT','19',NULL);
		CALl AddColumn('ld_customform48','conversionrate_rmbtoeur','INT','19',NULL);

		ALTER TABLE ld_customform48 MODIFY COLUMN conversionrate_rmbtousd DECIMAL(25,6);
		ALTER TABLE ld_customform48 MODIFY COLUMN conversionrate_rmbtohkd DECIMAL(25,6);
		ALTER TABLE ld_customform48 MODIFY COLUMN conversionrate_rmbtokrw DECIMAL(25,6);
		ALTER TABLE ld_customform48 MODIFY COLUMN conversionrate_rmbtovnd DECIMAL(25,6);
		ALTER TABLE ld_customform48 MODIFY COLUMN conversionrate_rmbtoeur DECIMAL(25,6);

	END IF;
END ||
delimiter;

CALL ldcrm_add_column_forlangjie();
DROP PROCEDURE IF EXISTS `ldcrm_add_column_forlangjie`;

insert into ld_customreport_folder(folder_name,sequence,systemdefault,visible,description)
select '推广大使中心报表',0,1,0,'推广大使中心报表' from dual 
where not exists(select 1 from ld_customreport_folder where folder_name='推广大使中心报表'); 


SET @report_name='分销中心报表';
SET @report_type='template_js';
SET @report_template='mycloudusers.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='推广大使中心报表');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);


SET @report_name='预约中心报表';
SET @report_type='template_js';
SET @report_template='mycloudbook.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='推广大使中心报表');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ABOUTUS','公司简介','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ABOUTUS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ABOUTUS','About Us','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ABOUTUS' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAINMAPLINK','主图链接','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MAINMAPLINK' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAINMAPLINK','main map link','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MAINMAPLINK' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIDEOLINK','视频链接','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VIDEOLINK' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIDEOLINK','video link','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VIDEOLINK' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIDEOCOVER','视频封面','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VIDEOCOVER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIDEOCOVER','video cover','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VIDEOCOVER' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BRIEF','简介','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='BRIEF' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BRIEF','brief','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='BRIEF' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMAGELINK','图片链接','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IMAGELINK' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMAGELINK','image link','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IMAGELINK' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTINTRODUCTION','公司产品简介','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTINTRODUCTION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTINTRODUCTION','our product introduction','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTINTRODUCTION' and Labeltype='fixedstr' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INTRODUCTION','介绍','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INTRODUCTION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INTRODUCTION','introduction','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INTRODUCTION' and Labeltype='fixedstr' and languagetype='en');
delimiter;


CREATE TABLE IF NOT EXISTS `ld_organizationdetails_brief` (
	`id` INT (11) UNSIGNED AUTO_INCREMENT COMMENT '自增ID',
	`organizationdetails_id` INT (11) COMMENT '公司ID',
	`brief` text COMMENT "简介",
	`image_link` text COMMENT '图片链接',
	`type` VARCHAR (10) COMMENT '简介类型 文字或者图片',
	PRIMARY KEY (`id`)
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_organizationdetails_product` (
	`id` INT (11) UNSIGNED NOT NULL AUTO_INCREMENT,
	`organizationdetails_id` INT (11) COMMENT '公司ID',
	`title` VARCHAR (10) COMMENT '产品标题',
	`brief` text COMMENT '产品简介',
	`image_link` text COMMENT '产品图片链接',
	`order` TINYINT(4) COMMENT '排序',
	PRIMARY KEY (`id`)
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

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

CALL AddColumn('ld_organizationdetails','brief_title','varchar','10',0);
CALL AddColumn('ld_organizationdetails','image_main','text','',0);
CALL AddColumn('ld_organizationdetails','video_cover','text','',0);
CALL AddColumn('ld_organizationdetails','video_link','text','',0);
CALL AddColumn('ld_organizationdetails','product_title','text','',0);
delimiter;

INSERT INTO `ld_organizationdetails_brief` (
	organizationdetails_id,
	brief,
	image_link,
	type
) 
SELECT
	'1',
	'成立于2008年，总部位于上海，在上海、北京、深圳、苏州、南京、杭州、济南、武汉、合肥等地设立了分支机构和服务中心。灵当软件专注于CRM客户关系管理软件和SAAS云服务应用的开发、销售、运营和服务，致力于为客户提供CRM行业解决方案，通过平台化定制和流程自定义满足客户个性化管理需求，是个性化CRM倡导者。',
	'',
	'text'
FROM DUAL
WHERE NOT EXISTS (
	SELECT
		1
	FROM ld_organizationdetails_brief
	WHERE organizationdetails_id = 1
		AND brief = '成立于2008年，总部位于上海，在上海、北京、深圳、苏州、南京、杭州、济南、武汉、合肥等地设立了分支机构和服务中心。灵当软件专注于CRM客户关系管理软件和SAAS云服务应用的开发、销售、运营和服务，致力于为客户提供CRM行业解决方案，通过平台化定制和流程自定义满足客户个性化管理需求，是个性化CRM倡导者。'
		AND type = 'text'
	);

INSERT INTO `ld_organizationdetails_brief` (
	organizationdetails_id,
	brief,
	image_link,
	type
) SELECT
	'1',
	'“灵当”含义：灵活配置，口碑响当当',
	'',
	'text'
FROM DUAL
WHERE NOT EXISTS (
	SELECT
		1
	FROM ld_organizationdetails_brief
	WHERE organizationdetails_id = 1
		AND brief = '“灵当”含义：灵活配置，口碑响当当'
		AND type = 'text'
);

INSERT INTO `ld_organizationdetails_product` (
	organizationdetails_id,
	title,
	brief,
	image_link,
	`order`
) 
SELECT
	'1',
	'标准版',
	'管控销售流程助你增加销售业绩|100人以内的销售团队|500人以内的中型企业',
	'http://71mis.cn/web_51mis/mob92/images/p_biaozhun.png',
	'8'
FROM DUAL
WHERE NOT EXISTS (
	SELECT
		1
	FROM ld_organizationdetails_product
	WHERE organizationdetails_id = 1
		AND title = '标准版'
		AND brief = '管控销售流程助你增加销售业绩|100人以内的销售团队|500人以内的中型企业'
);

INSERT INTO `ld_organizationdetails_product` (
	organizationdetails_id,
	title,
	brief,
	image_link,
	`order`
) SELECT
	'1',
	'企业版',
	'覆盖企业管理五大需求，实现多种需求|销售团队100人以上的大型集团企业使用',
	'http://71mis.cn/web_51mis/mob92/images/p_qiye.png',
	'6'
FROM DUAL
WHERE NOT EXISTS (
	SELECT
		1
	FROM ld_organizationdetails_product
	WHERE organizationdetails_id = 1
		AND title = '企业版'
		AND brief = '覆盖企业管理五大需求，实现多种需求|销售团队100人以上的大型集团企业使用'
	);

INSERT INTO `ld_organizationdetails_product` (
	organizationdetails_id,
	title,
	brief,
	image_link,
	`order`
) 
SELECT
	'1',
	'基础版',
	'简单易操作|20人以内的销售团队|100人以内的中小型企业',
	'http://71mis.cn/web_51mis/mob92/images/p_jichu.png',
	'6'
FROM DUAL
WHERE NOT EXISTS (
	SELECT
		1
	FROM ld_organizationdetails_product
	WHERE organizationdetails_id = 1
		AND title = '基础版'
		AND brief = '简单易操作|20人以内的销售团队|100人以内的中小型企业'
	);

INSERT INTO `ld_organizationdetails_product` (
	organizationdetails_id,
	title,
	brief,
	image_link,
	`order`
) 
SELECT
	'1',
	'进销存',
	'集销售、采购、库存管理为一体的进销存管理专家|500人以内的中型企业',
	'http://71mis.cn/web_51mis/mob92/images/p_jinxiaocun.png',
	'7'
FROM DUAL
WHERE NOT EXISTS (
	SELECT
		1
	FROM ld_organizationdetails_product
	WHERE organizationdetails_id = 1
		AND title = '进销存'
		AND brief = '集销售、采购、库存管理为一体的进销存管理专家|500人以内的中型企业'
);

UPDATE ld_organizationdetails SET product_title = "产品介绍",brief_title="公司介绍" WHERE organization_id=1;
CALL AddColumn('ld_cloud_users','share','int','11',0);
delimiter;
-- 2020-09-24

DROP TABLE IF EXISTS backup_table_inventoryproductrel;
DROP TABLE IF EXISTS backup_table_inventoryproductrelscf;
delimiter;

UPDATE ld_field a
LEFT JOIN ld_tab b ON b.tabid=a.tabid
LEFT JOIN ld_entityname c ON c.tabid=a.tabid
SET a.columnname='source_list',a.allowhide='yes',a.tablename=c.tablename,a.fieldname='selectlistval',a.bigtype='selectsource'
WHERE a.uitype=202 
	AND b.`name` LIKE 'CustomForm%'
	AND RIGHT(b.`name`,2) BETWEEN 36 AND 45
	AND IFNULL(a.bigtype,'')='';
delimiter;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
SELECT
	languagetype,
	trantable,
	tabid,
	fieldid,
	fieldlabel
FROM (
	SELECT 
		'zh' AS languagetype,
		'ld_field' AS trantable,
		a.tabid,
		a.fieldid,
		'选择源单' AS fieldlabel
	FROM ld_field a
	LEFT JOIN ld_tab b ON b.tabid=a.tabid
	WHERE a.uitype=202 
		AND b.`name` LIKE 'CustomForm%'
		AND RIGHT(b.`name`,2) BETWEEN 36 AND 45
	UNION
	SELECT 
		'en' AS languagetype,
		'ld_field' AS trantable,
		a.tabid,
		a.fieldid,
		'Data sources' AS fieldlabel
	FROM ld_field a
	LEFT JOIN ld_tab b ON b.tabid=a.tabid
	WHERE a.uitype=202 
		AND b.`name` LIKE 'CustomForm%'
		AND RIGHT(b.`name`,2) BETWEEN 36 AND 45
) a
WHERE 1=1
	AND fieldid NOT IN (
		SELECT 
			a.fieldid
		FROM ld_field a
		LEFT JOIN ld_tab b ON b.tabid=a.tabid
		INNER JOIN ld_tranlabel c ON c.trantable='ld_field' AND c.Relateid=a.fieldid
		WHERE a.uitype=202 
			AND b.`name` LIKE 'CustomForm%'
			AND RIGHT(b.`name`,2) BETWEEN 36 AND 45
			AND c.languagetype='zh'
		)
ORDER BY tabid,languagetype DESC;
delimiter;

INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence,datarang)
SELECT
	a.tabid,
	22,
	0,
	1,
	0,
	1,
	a.tabsequence,
	'all'
FROM ld_tab a
WHERE a.`name` LIKE 'CustomForm%'
	AND RIGHT(a.`name`,2) BETWEEN 36 AND 45
	AND tabid NOT IN (
		SELECT
			a.tabid
		FROM ld_tab a
		INNER JOIN ld_option_module b ON b.tabid=a.tabid
		WHERE a.`name` LIKE 'CustomForm%'
			AND RIGHT(a.`name`,2) BETWEEN 36 AND 45
			AND b.option_tabid=22
		);
delimiter;

INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence,datarang)
SELECT
	a.tabid,
	37,
	0,
	0,
	0,
	1,
	a.tabsequence,
	'all'
FROM ld_tab a
WHERE a.`name` LIKE 'CustomForm%'
	AND RIGHT(a.`name`,2) BETWEEN 36 AND 45
	AND tabid NOT IN (
		SELECT
			a.tabid
		FROM ld_tab a
		INNER JOIN ld_option_module b ON b.tabid=a.tabid
		WHERE a.`name` LIKE 'CustomForm%'
			AND RIGHT(a.`name`,2) BETWEEN 36 AND 45
			AND b.option_tabid=37
		);
delimiter;
-- 2020-09-27

UPDATE ld_field set typeofdata ='DT~O' where fieldname='lastcontactdate' and uitype IN (86,70);

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

UPDATE ld_version SET old_version='V8.2.4',current_version='V8.2.4',remark='V8.2.4-20200927',wx_version='V8.2.3.2';
delimiter;