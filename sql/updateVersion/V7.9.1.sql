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

update ld_desk set fieldlabel='严格11位手机号码格式' where labelbol='EnableRegExp' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Strict 11 digit mobile number format' where labelbol='EnableRegExp' and Labeltype='fixedstr' and languagetype='en';
delimiter;

call AddColumn('ld_wx_evaluate_content','create_time','datetime',null ,null );
delimiter;

UPDATE ld_field SET tablename='ld_customform19scf' WHERE tablename='ld_customform19cf';
-- 2019-10-09

UPDATE ld_expensedetail a
LEFT JOIN ld_crmentity b ON b.crmid=a.entitytypeid
SET a.entitytype=b.setype
WHERE a.entitytypeid>0 
	AND a.entitytype IS NULL;
    
delete from ld_weixinmp_fields where tabletype='detail';
delimiter;

update ld_actionmapping set actionlabel='list' where actionname='index';
delimiter;

CALl AddColumn('ld_relatedlists','buttonstatus','varchar','50','yes');
delimiter;

update ld_relatedlists set buttonstatus='yes' where buttonstatus is null ;
delimiter;
-- 2019-10-11

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','dingtalk_setting','http://51mis.com.cn/forum.php?mod=viewthread&tid=537&fromuid=1','钉钉微应用配置' from DUAL
where not exists(select 1 from ld_links where tabid = 0 and linktype ='Settings' and linklabel = 'dingtalk_setting');

insert into ld_wx_config (name, description)
select 'dingtalk_setting','钉钉应用秘钥' from dual 
where not exists(select 1 from ld_wx_config where name='dingtalk_appsecret');

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'dingtalk_setting','picklistdependency.png','','index.php?module=Settings&action=dingtalk_setting&parenttab=Settings',@sequence+1,0 from DUAL 
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'dingtalk_setting');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_setting','钉钉接口设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol ='dingtalk_setting' and languagetype='zh' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_setting','Enterprise DingTalk Data Interface','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol ='dingtalk_setting' and languagetype='en' and labeltype = 'fixedstr');

SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
SET @columnname='dingtalk_userid';
SET @fieldname='dingtalk_userid';
SET @zh='钉钉通讯录账号';
SET @en='DingDing Account';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND
columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',0);
CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

SET @i=0;
SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_field WHERE tabid=@tabid AND block=@relateid AND columnname='wx_openid');
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@relateid AND sequence>@seq;
UPDATE ld_field SET sequence=@seq+1 WHERE tabid=@tabid AND block=@relateid AND columnname='dingtalk_userid';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@relateid ORDER BY sequence;
delimiter;
-- 2019-10-12						


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

UPDATE ld_version SET old_version='V7.9.1',current_version='V7.9.1',remark='V7.9.1-20191012',wx_version='V7.9.1';
delimiter;