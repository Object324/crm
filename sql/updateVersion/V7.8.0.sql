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

create table  if not exists `ld_wx_communicate`(
  `id` int primary key auto_increment,
  `module` varchar(255) default '' comment '关联单据的模块名',
  `record` int default null comment '关联单据的ID',
  `create_time` datetime  comment '沟通时间',
  `content` text comment '沟通内容',
  `openid` varchar(255) comment '小程序唯一标识'
) ENGINE=InnoDB DEFAULT CHARSET utf8;
delimiter;

insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','HELPDESKCOMMUNICATE','沟通信息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HELPDESKCOMMUNICATE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','HELPDESKCOMMUNICATE','Communicate information','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='HELPDESKCOMMUNICATE' and languagetype='en' and Labeltype='fixedstr');
delimiter;


INSERT INTO ld_currencies(currency_name,currency_code,currency_symbol,description)
SELECT 'Brazil, Real','BRL','R$','巴西雷亚尔' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_currencies WHERE currency_code='BRL' AND currency_symbol='R');


insert into ld_ws_fieldtype(uitype,fieldtype)
select 540,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=540);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=540;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'PurchaseOrder' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='PurchaseOrder');
delimiter;


CALl AddColumn('ld_relatedlists','islistbutton','varchar','50','');
delimiter;

update ld_salesorderdetail set balanceinvoicecount=quantity where balanceinvoicecount is null;
delimiter;
-- 2019-06-24

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

UPDATE ld_version SET old_version='V7.8.0',current_version='V7.8.0',remark='V7.8.0-20190624',wx_version='V7.7.9';
delimiter;