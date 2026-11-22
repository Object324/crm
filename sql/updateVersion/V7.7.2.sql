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

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
	tabname varchar(50),
	permissions int(19)
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AVAILABLE','可用的','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AVAILABLE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AVAILABLE','Available ','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AVAILABLE' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_shujuzidian`;
delimiter ||
CREATE PROCEDURE `ldcrm_shujuzidian`(
	tmp_modulelabel VARCHAR(100)
)
BEGIN

	(SELECT
		f.fieldlabel AS '表单名称',
		CONCAT('单据表头-',e.fieldlabel) AS '区块名称',
		b.columnname AS '字段名称',
		s.COLUMN_TYPE AS '字段类型',
		b.tablename AS '数据库表名',
		d.fieldlabel AS '显示名称（CH）'
	FROM ld_tab a
	LEFT JOIN ld_field b ON a.tabid=b.tabid
	LEFT JOIN ld_blocks c ON c.blockid=b.block
	LEFT JOIN ld_tranlabel d ON d.trantable='ld_field' AND d.Relateid=b.fieldid AND d.languagetype='zh'
	LEFT JOIN ld_tranlabel e ON e.trantable='ld_blocks' AND e.Relateid=c.blockid AND e.languagetype='zh'
	LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
	INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
	WHERE f.fieldlabel=tmp_modulelabel
		AND b.presence<>1
	ORDER BY b.block,b.sequence)
	UNION ALL
	(SELECT
		f.fieldlabel AS '表单名称',
		'单据分录-字段信息' AS '区块名称',
		b.columnname AS '字段名称',
		s.COLUMN_TYPE AS '字段类型',
		b.tablename AS '数据库表名',
		d.fieldlabel AS '显示名称（CH）'
	FROM ld_tab a
	LEFT JOIN ld_producttoolfield b ON a.tabid=b.tabid
	LEFT JOIN ld_tranlabel d ON d.trantable='ld_producttoolfield' AND d.Relateid=b.producttoolfieldid AND d.languagetype='zh'
	LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
	INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
	WHERE f.fieldlabel=tmp_modulelabel
		AND b.presence<>1
	ORDER BY b.sequence)
	UNION ALL
	(SELECT
		f.fieldlabel AS '表单名称',
		'单据分录-字段信息' AS '区块名称',
		b.columnname AS '字段名称',
		s.COLUMN_TYPE AS '字段类型',
		b.tablename AS '数据库表名',
		d.fieldlabel AS '显示名称（CH）'
	FROM ld_tab a
	LEFT JOIN ld_tabdetailfield b ON a.tabid=b.tabid
	LEFT JOIN ld_tranlabel d ON d.trantable='ld_tabdetailfield' AND d.Relateid=b.tabdetailfieldid AND d.languagetype='zh'
	LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
	INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
	WHERE f.fieldlabel=tmp_modulelabel
		AND b.presence<>1
	ORDER BY b.sequence);

END ||
delimiter;

UPDATE ld_field SET defaultvalue=0 WHERE tabid=29 AND columnname='is_mobile_style' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='select_servicedetail' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='select_due_date' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='helpdesk_log' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname='campaignsview' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
-- 2019-03-28

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ISREPLACEHISTORYDATA','以下选项已修改，是否替换历史数据？','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='ISREPLACEHISTORYDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ISREPLACEHISTORYDATA','Options have changed, replace the historical data?','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='ISREPLACEHISTORYDATA' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_chooseaccount`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_chooseaccount`(
	tmp_module VARCHAR(100),
	tmp_columnname VARCHAR(100),
	tmp_ZH VARCHAR(100),
	tmp_EN VARCHAR(100)
)
BEGIN


	SET @modulename=tmp_module;
	SET @tabid=(SELECT tabid FROM ld_tab WHERE name=@modulename LIMIT 1);
	SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
	SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
	SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
	SET @trantable='ld_field';
	SET @columnname=tmp_columnname;
	SET @fieldname=tmp_columnname;
	SET @zh=tmp_zh;
	SET @en=tmp_en;
	SET @uitype=173;
	SET @typeofdata='V~O';

	SET @quickcreate=1;
	SET @quickcreatesequence=NULL;
	SET @info_type='BAS';
	SET @masseditable=1;

	SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
	INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
	SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,0,0 FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

	UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

	SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

	CALl AddColumn(@tablename,@columnname,'INT','19',NULL);

END ||
delimiter;
-- 2019-04-02

SET @tabid=2;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='staydays' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='未推进天数' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ISREPLACEHISTORYDATA','以下选项已修改，是否替换历史数据？','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='ISREPLACEHISTORYDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ISREPLACEHISTORYDATA','Options have changed, replace the historical data?','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='ISREPLACEHISTORYDATA' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_profile2standardpermissions','relatednames','text','',null );
delimiter;

update ld_profile2standardpermissions 
inner JOIN ld_profile on ld_profile.profileid=ld_profile2standardpermissions.profileid
INNER JOIN ld_tab on  ld_tab.tabid=ld_profile2standardpermissions.tabid
set relatednames=(select GROUP_CONCAT(name) from ld_usereport where presence in(0))
where ld_tab.name='oftenusereport';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_rule` (
  `rule_id` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(11) DEFAULT NULL,
  `modulename` varchar(100) DEFAULT NULL,
  `rule_name` varchar(200) DEFAULT NULL,
  `rule_type` varchar(100) DEFAULT NULL,
  `rule_description` text,
  `rule_result` varchar(50) DEFAULT NULL,
  `zh_tips` text,
  `en_tips` text,
  PRIMARY KEY (`rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_rule_condition` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rule_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `comparator` varchar(255) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select 501,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=501);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=501;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm01' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm01');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 502,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=502);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=502;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm02' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm02');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 503,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=503);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=503;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm03' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm03');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 504,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=504);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=504;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm04' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm04');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 505,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=505);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=505;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm05' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm05');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 506,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=506);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=506;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm06' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm06');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 507,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=507);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=507;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm07' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm07');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 508,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=508);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=508;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm08' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm08');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 509,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=509);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=509;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm09' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm09');
delimiter;


insert into ld_ws_fieldtype(uitype,fieldtype)
select 510,'reference' from dual 
where not exists(select * from ld_ws_fieldtype where uitype=510);
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=510;

insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'CustomForm10' from dual 
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='CustomForm10');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thiecustomerbusiness','该客户工商信息不存在，无法保存！','fixedstr' from dual
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='thiecustomerbusiness');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','thiecustomerbusiness','This customer business information does not exist, cannot save!','fixedstr' from dual
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='thiecustomerbusiness');
delimiter;
-- 2019-04-09

UPDATE ld_attachments SET imagefromtype='Computer' WHERE imagefromtype IS NULL AND type NOT  LIKE 'image%';
UPDATE ld_attachments SET imagefromtype='Albums' WHERE imagefromtype IS NULL AND type LIKE 'image%';

DROP TABLE IF EXISTS ld_invoicebillads;
DROP TABLE IF EXISTS ld_invoiceshipads;
DROP TABLE IF EXISTS ld_pobillads;
DROP TABLE IF EXISTS ld_poshipads;
DROP TABLE IF EXISTS ld_quotesbillads;
DROP TABLE IF EXISTS ld_quotesshipads;

UPDATE ld_tab SET presence=1 WHERE `name` LIKE 'CustomForm%' AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (7,10,42,43,55,56,57,58));

DROP PROCEDURE IF EXISTS `ldcrm_reset_share_action2tab`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_share_action2tab`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT tabid FROM ld_tab WHERE `name` LIKE 'CustomForm%' ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid;
	WHILE(tmp_tabid IS NOT NULL) DO
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 0,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=0);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 1,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=1);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 2,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=2);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 3,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=3);

		UPDATE ld_def_org_share SET permission=3 WHERE tabid=tmp_tabid;

		FETCH MYCUSOR INTO tmp_tabid;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_share_action2tab();
DROP PROCEDURE IF EXISTS `ldcrm_reset_share_action2tab`;

UPDATE ld_def_org_share SET permission=IFNULL(permission,3) WHERE permission IS NULL;
delimiter;

UPDATE ld_entityname SET fieldname='checks_no' WHERE modulename='Checks' AND fieldname='subject'
	AND EXISTS (SELECT 1 FROM ld_field WHERE tablename='ld_checks' AND columnname='subject' AND presence=1);
    
    
update ld_dashboard_app set wx_presence=1,graphtype=101 where name='InventoryQuery';
select wx_sequence into @sequence  from ld_dashboard_app where name='cashbillsum_paymentplan';
set @i = @sequence+1;
update ld_dashboard_app set wx_sequence=wx_sequence+1 where wx_sequence > @sequence;
update ld_dashboard_app set wx_sequence=@sequence+1 where name='InventoryQuery';
update ld_dashboard_app set wx_sequence=(@i:=@i+1) where wx_sequence > @sequence+1;
delimiter;

update ld_desk set fieldlabel='选择Logo' where labelbol='SELECTNEWLOGO' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Select Logo' where labelbol='SELECTNEWLOGO' and languagetype='en' and Labeltype='fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name='singin';
select fieldid into @fieldid_rd from ld_field where columnname='record' and tabid=@tabid;
select fieldid into @fieldid_ss from ld_field where columnname='address' and tabid=@tabid;
update ld_related_field set fromvalue_info=REPLACE(fromvalue_info,'ld_account.bill_city,ld_account.bill_street','ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street') 
where effect_fieldid=@fieldid_ss and trigger_fieldid=@fieldid_rd;
delimiter;

drop PROCEDURE if EXISTS `execute_account_publicoperation`;
delimiter ||
create PROCEDURE  execute_account_publicoperation()

BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select DATE_FORMAT(eventdate,'%Y-%m-%d') into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
			
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_highsea_rule();
			call account_singlerecycle_normal_rule_beforeremind();
			call account_singlerecycle_highsea_rule_beforeremind();
		end if;

	end if;
end||
delimiter;

drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule_beforeremind()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
  select beforereminddays into @var_beforereminddays from ld_account_set;
 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then 
		leave label_a ;
	end if;
  select allotaccount into @allotaccount from ld_account_set;
	select recycleselect into @recycleselect from ld_account_set;
	set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then 
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;
			if var_days<=0 THEN
				leave loop1;
		   end if;
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;

	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	
    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN	
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN	 
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then 
				
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone 
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid 
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;
				
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
		delete from ld_publicaccount_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicaccount_beforereminds();
	end if;
end||
delimiter;

select count(1) into @cnt from ld_crmentity;
update ld_tab set isduplicate = 'yes' where @cnt <= 10;
delimiter;

update ld_desk set fieldlabel='选择Logo' where labelbol='SELECTNEWLOGO' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Select Logo' where labelbol='SELECTNEWLOGO' and Labeltype='fixedstr' and languagetype='en';
delimiter;
-- 2019-04-11

CALL AddColumn('ld_account','bill_area','VARCHAR','100',NULL);


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

UPDATE ld_version SET old_version='V7.7.2',current_version='V7.7.2',remark='V7.7.2-20190412',wx_version='V7.7.2';
delimiter;