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

DROP PROCEDURE IF EXISTS `AddPrimaryKey`;
delimiter ||
CREATE  PROCEDURE `AddPrimaryKey`(
	tmp_tablename varchar(100),
	tmp_prikeyname varchar(100)
)
BEGIN
 

	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND CONSTRAINT_NAME='PRIMARY' AND TABLE_NAME=tmp_tablename) THEN
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` DROP PRIMARY KEY,ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	ELSE
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	END IF;

end ||
delimiter;

CALL AddPrimaryKey('ld_producttoolfield_formula','formulaid');
CALL AddColumn('ld_account','bill_area','VARCHAR','100',NULL);

SET @lable='LBL_SERVICE_MINI_SETTINGS';
SET @zh='服务小程序设置';
SET @en='Service applet Settings';
SET @blockid=(SELECT max(blockid) FROM ld_settings_blocks);
SET @sequence=(SELECT max(sequence) FROM ld_settings_blocks);
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
  SELECT @blockid+1,@lable,@sequence+1,0 FROM DUAL
  WHERE NOT EXISTS (SELECT 1 FROM ld_settings_blocks WHERE label=@lable);
UPDATE ld_settings_blocks_seq SET id=(SELECT max(blockid) FROM ld_settings_blocks);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'zh',@lable,@zh,'fixedstr' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@lable AND labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'en',@lable,@en,'fixedstr' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@lable AND labeltype='fixedstr');

SET @lable='LBL_ORDER_MINI_SETTINGS';
SET @zh='订单小程序设置';
SET @en='Order applet Settings';
SET @blockid=(SELECT max(blockid) FROM ld_settings_blocks);
SET @sequence=(SELECT max(sequence) FROM ld_settings_blocks);
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
  SELECT @blockid+1,@lable,@sequence+1,0 FROM DUAL
  WHERE NOT EXISTS (SELECT 1 FROM ld_settings_blocks WHERE label=@lable);
UPDATE ld_settings_blocks_seq SET id=(SELECT max(blockid) FROM ld_settings_blocks);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'zh',@lable,@zh,'fixedstr' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@lable AND labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  SELECT 'en',@lable,@en,'fixedstr' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@lable AND labeltype='fixedstr');

insert into ld_wx_config (name, description)
  select 'ordermp_bindtype','客户自助订单平台首页设置'
  from dual where not exists(select 1 from ld_wx_config where name='ordermp_bindtype');

update ld_desk set fieldlabel='企业号设置' where labelbol='WECHATAPPLETSETTINGS' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Enterprise number setting' where labelbol='WECHATAPPLETSETTINGS' and Labeltype='fixedstr' and languagetype='en';

select blockid into @blockid from ld_settings_blocks where label='LBL_SERVICE_MINI_SETTINGS';
set @sequence = 1;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'LOGINSETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=service&step=login',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LOGINSETTING');
set @sequence = 2;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'MOUDLESETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=service&step=module',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='MOUDLESETTING');
set @sequence = 3;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'LISTSETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=service&step=modulelist',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LISTSETTING');
set @sequence = 4;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'DETAILSETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=service&step=moduledetail',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='DETAILSETTING');

select blockid into @blockid from ld_settings_blocks where label='LBL_ORDER_MINI_SETTINGS';
set @sequence = 1;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'LOGINSETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=order&step=login',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LOGINSETTING');
set @sequence = 2;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'MOUDLESETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=order&step=module',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='MOUDLESETTING');
set @sequence = 3;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'LISTSETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=order&step=modulelist',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='LISTSETTING');
set @sequence = 4;
select max(fieldid) into @maxfieldid from ld_settings_field;
insert into ld_settings_field(fieldid, blockid, name, iconpath, description, linkto, sequence,active)
  select @maxfieldid+1,@blockid ,'DETAILSETTING','picklistdependency.png','',
    'index.php?module=Settings&action=SelfServiceConfig&parenttab=Settings&selftype=order&step=moduledetail',@sequence,0 from dual
  where not exists(select 1 from ld_settings_field where blockid=@blockid and name='DETAILSETTING');

select blockid into @blockid from ld_settings_blocks where label='LBI_MINI_SETTINGS';
delete from ld_settings_field where blockid=@blockid and name <> 'WECHATAPPLETSETTINGS';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','LOGINSETTING','Login settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOGINSETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','LOGINSETTING','登录设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOGINSETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','MOUDLESETTING','Module settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOUDLESETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','MOUDLESETTING','模块设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOUDLESETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','LISTSETTING','List customization','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LISTSETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','LISTSETTING','列表定制','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LISTSETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DETAILSETTING','Details customization','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DETAILSETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DETAILSETTING','详情定制','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DETAILSETTING' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG01ORDER','Order applet login home page Settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG01ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG01ORDER','订单小程序登录首页设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG01ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME06ORDER','System administrator order applet download','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME06ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME06ORDER','系统管理员订单小程序下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME06ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME07ORDER','The order applet for other members can be downloaded from the member details screen','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME07ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME07ORDER','其他成员的订单小程序请在成员详情界面下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME07ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIGHOME08ORDER','Self-help order applet download','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIGHOME08ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIGHOME08ORDER','自助订单小程序下载','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIGHOME08ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG02ORDER','Order small program module Settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG02ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG02ORDER','订单小程序模块设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG02ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG04ORDER','Order small program module list customization','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG04ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG04ORDER','订单小程序模块列表定制','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG04ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CUSTOMERSELFSERVICECONFIG03ORDER','Order small program details interface customization','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMERSELFSERVICECONFIG03ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CUSTOMERSELFSERVICECONFIG03ORDER','订单小程序详情界面定制','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMERSELFSERVICECONFIG03ORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SELFSERVICEQRCODEORDER','Self-order applet','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELFSERVICEQRCODEORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SELFSERVICEQRCODEORDER','自助订单小程序','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELFSERVICEQRCODEORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','SELFSERVICEQRCODEORDER','Self-order applet','jspop' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELFSERVICEQRCODEORDER' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','SELFSERVICEQRCODEORDER','自助订单小程序','jspop' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELFSERVICEQRCODEORDER' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '日周月报' where labelbol = 'STATISTICALWEEKMONTH' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Daily weekly monthly report' where labelbol = 'STATISTICALWEEKMONTH' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

alter table ld_wx_config modify column para_one text;
delimiter;

UPDATE ld_producttoolfield SET defaultcolumn=3 WHERE columnname IN ('discount_percent','discount_amount');
UPDATE ld_producttoolfield SET defaultcolumn=2 WHERE columnname IN ('tax_amount');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment' LIMIT 1);
UPDATE ld_parenttabrel SET parenttabid=1 WHERE tabid=@tabid AND parenttabid=6 AND NOT EXISTS (SELECT 1 FROM ld_attachmentsforbills);
-- 2019-04-19

UPDATE ld_tab SET presence=0 WHERE presence=5 AND `name` IN ('Emails','EmailListtmp','MassEmails') AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET approve_demand=2 WHERE approve_demand=0 AND uitype IN (1,5,15,7,56,86);

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

UPDATE ld_version SET old_version='V7.7.3',current_version='V7.7.3',remark='V7.7.3-20190419',wx_version='V7.7.3';
delimiter;