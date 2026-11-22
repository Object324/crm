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

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','ARTICLE','条','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ARTICLE' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','ARTICLE',' ','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ARTICLE' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','RELATIONAL','关联','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='RELATIONAL' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','RELATIONAL','Relational','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='RELATIONAL' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE6','企业微信CRM联系人可见范围','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE6' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE6','Enterprise WeChat CRM contact visible scope','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE6' and languagetype='en' and Labeltype='fixedstr');
-- 2019-01-07

SET @blockid1=(SELECT block FROM ld_field WHERE tabid=6 AND columnname='publicaccount');
SET @blockid2=(SELECT block FROM ld_field WHERE tabid=6 AND columnname='accountname');
SET @i=(SELECT MAX(sequence) FROM ld_field WHERE tabid=6 AND block=@blockid2);
UPDATE ld_field SET block=@blockid2,sequence=(@i:=@i+1) WHERE tabid=6 AND block=@blockid1 AND NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=6 AND blockid=@blockid1);
delimiter;

update ld_desk set  labelbol='可见范围设置' where languagetype='zh' and labelbol='visiblerangsettings' and fieldlabel='可见范围内设置' and labeltype='fixedstr';
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm01';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm01','customform01_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm01','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm01','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm01');

DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform01_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform01_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm02';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm02','customform02_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm02','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm02','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm02');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform02_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform02_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm03';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm03','customform03_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm03','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm03','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm03');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform03_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform03_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm04';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm04','customform04_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm04','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm04','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm04');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform04_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform04_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm05';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm05','customform05_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm05','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm05','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm05');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform05_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform05_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm06';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm06','customform06_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm06','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm06','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm06');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform06_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform06_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm07';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm07','customform07_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm07','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm07','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm07');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform07_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform07_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm08';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm08','customform08_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm08','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm08','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm08');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform08_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform08_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm09';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm09','customform09_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm09','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm09','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm09');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform09_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform09_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm10';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm10','customform10_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm10','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm10','assigned_user_id','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm10');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform10_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform10_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm11';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm11','customform11_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm11','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm11','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm11');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform11_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform11_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm12';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm12','customform12_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm12','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm12','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm12');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform12_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform12_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm13';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm13','customform13_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm13','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm13','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm13');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform13_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform13_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm14';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm14','customform14_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm14','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm14','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm14');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform14_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform14_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm15';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm15','customform15_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm15','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm15','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm15');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform15_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform15_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm16';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm16','customform16_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm16','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm16','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm16');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform16_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform16_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm17';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm17','customform17_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm17','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm17','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm17');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform17_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform17_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm18';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm18','customform18_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm18','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm18','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm18');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform18_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform18_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm19';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm19','customform19_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm19','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm19','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm19');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform19_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform19_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm20';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm20','customform20_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm20','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm20','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm20');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform20_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform20_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;


DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm21';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm21','customform21_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm21','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm21','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm21');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform21_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform21_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm22';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm22','customform22_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm22','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm22','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm22');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform22_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform22_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm23';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm23','customform23_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm23','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm23','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm23');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform23_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform23_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm24';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm24','customform24_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm24','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm24','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm24');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform24_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform24_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm25';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm25','customform25_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm25','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm25','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm25');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform25_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform25_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'total',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;
/************diony end**************/

/************diony begin**************/
update ld_desk set fieldlabel='允许查看其他成员的单据详情（优先于角色权限）' where languagetype='zh' and labelbol='viewothers' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Allow you to view the details of other members\'documents (prior to role permissions)' where languagetype='en' and labelbol='viewothers' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='允许查看其他成员的单据详情（优先于角色权限）' where languagetype='zh' and labelbol='Allowtoviewotherusers' and Labeltype='jspop';
update ld_desk set fieldlabel='Allow you to view the details of other members\'documents (prior to role permissions)' where languagetype='en' and labelbol='Allowtoviewotherusers' and Labeltype='jspop';
delimiter;
/************diony end**************/


select tabid into @tabid from ld_tab where `name` = 'Potentials';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress','yes','ld_potential',1,65,'locationaddress','定位',1,1,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+2,'locationaddress_map','yes','ld_potential',1,64,'locationaddress_map','定位地址地图',1,1,NULL,NULL,2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress_map');
delimiter;

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+3,'bill_area','yes','ld_potential',1,15,'bill_area','区域',1,1,NULL,NULL,201,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'bill_area');
delimiter;

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+4,'bill_street','yes','ld_potential',1,19,'bill_street','详细地址',1,1,NULL,NULL,202,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'bill_street');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'定位' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Location' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress_map';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'地图' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Map' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'bill_area';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'区域' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Area' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'bill_street';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'详细地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call AddColumn('ld_potential','locationaddress','varchar','255',NULL);
call AddColumn('ld_potential','locationaddress_map','varchar','20',NULL);
call AddColumn('ld_potential','bill_area','varchar','100',NULL);
call AddColumn('ld_potential','bill_street','varchar','250',NULL);

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm01';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm01','customform01_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm01','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm01','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm01');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform01_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform01_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm02';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm02','customform02_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm02','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm02','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm02');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform02_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform02_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm03';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm03','customform03_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm03','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm03','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm03');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform03_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform03_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm04';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm04','customform04_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm04','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm04','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm04');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform04_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform04_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm05';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm05','customform05_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm05','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm05','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm05');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform05_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform05_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm06';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm06','customform06_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm06','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm06','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm06');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform06_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform06_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm07';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm07','customform07_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm07','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm07','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm07');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform07_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform07_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm08';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm08','customform08_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm08','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm08','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm08');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform08_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform08_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm09';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm09','customform09_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm09','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm09','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm09');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform09_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform09_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm10';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm10','customform10_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm10','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm10','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm10');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform10_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform10_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;
-- 2019-01-09

SET @tabid=2;
DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield IN ('bill_country','bill_state','bill_city');
SET @i=(SELECT MAX(id) FROM ld_picklist_dependency);

INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
SELECT (@i:=@i+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency 
WHERE tabid=6 AND sourcefield IN ('bill_country','bill_state','bill_city');

UPDATE ld_picklist_dependency_seq SET id=(SELECT max(id) FROM ld_picklist_dependency);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_read_tmpreminder`;
delimiter ||
CREATE  PROCEDURE `ldcrm_read_tmpreminder`(
)
BEGIN
	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_content text DEFAULT '';
	DECLARE tmp_recieverid INT(19) DEFAULT 0;
	DECLARE tmp_remindtime datetime;
	DECLARE tmp_reltab varchar(100) DEFAULT '';
	DECLARE tmp_related_to INT(19) DEFAULT 0;
	DECLARE tmp_ruleid INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR 
		SELECT
			id,
			content,
			reminderid,
			remindtime,
			reltab,
			related_to,
			reminds_ruleid 
		FROM ld_tmpreminder 
		WHERE remindtime<=NOW() 
			AND IFNULL(content,'') not like '%[var.%'
		ORDER BY remindtime DESC LIMIT 50;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	OPEN Mycur;
	FETCH Mycur INTO tmp_id,tmp_content,tmp_recieverid,tmp_remindtime,tmp_reltab,tmp_related_to,tmp_ruleid;
	WHILE (tmp_id IS NOT NULL) DO
		DELETE FROM ld_tmpreminder WHERE id=tmp_id;
		set @maxid=0;
		select max(crmid) into @maxid from ld_crmentity;
		insert into ld_crmentity(crmid,setype)
		select @maxid+1,'Reminds';
		
		update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			
		insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
		select @maxid+1,tmp_content,tmp_remindtime,tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,tmp_ruleid,0,0,0,tmp_remindtime,tmp_remindtime,null,0
		from dual where not exists (select 1 from ld_reminds where content=tmp_content AND recieverid=tmp_recieverid and related_to=tmp_related_to and date_time=tmp_remindtime and reminds_ruleid=tmp_ruleid);

	FETCH Mycur INTO tmp_id,tmp_content,tmp_recieverid,tmp_remindtime,tmp_reltab,tmp_related_to,tmp_ruleid;
	END WHILE;
	CLOSE Mycur;	
	
end ||
delimiter;

UPDATE ld_field SET presence=1 WHERE tabid=29 AND columnname IN ('approvestatus','approveby')
	AND NOT EXISTS (SELECT approvestatus FROM ld_users WHERE approvestatus=0);
    
DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfield_formula_20190110`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_tabdetailfield_formula_20190110`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_tabdetailfieldid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			tabid,
			tabdetailfieldid
		FROM ld_tabdetailfield 
		WHERE columnname='total' 
			AND tablename IN ('ld_customform21','ld_customform22','ld_customform23','ld_customform24','ld_customform25')
		ORDER BY tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_tabdetailfieldid;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @maxseq=(SELECT MAX(sequence) FROM ld_tabdetailfield_formula WHERE tabdetailfieldid IN (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=tmp_tabid));
		INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
		SELECT tmp_tabdetailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'amount'}]}",IFNULL(@maxseq,0)+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=tmp_tabdetailfieldid);
		FETCH MYCUSOR INTO tmp_tabid,tmp_tabdetailfieldid;
	END WHILE;
	CLOSE MYCUSOR;
end ||
delimiter;

CALL ldcrm_reset_tabdetailfield_formula_20190110();
DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfield_formula_20190110`;

UPDATE ld_products p 
LEFT JOIN (
	SELECT
		a.wareid,
		a.productid,
		a.batchtext,
		SUM(a.inventory_qty) AS inventory_qty
	FROM (
		SELECT
			a.warehouseid AS wareid,
			a.productid,
			a.batchtext,
			a.lastqty AS inventory_qty
		FROM ld_warehousecondtions a
		LEFT JOIN ld_products c ON c.productid=a.productid
		WHERE a.modulename='库存初始化'
			AND a.type='确认初始库存'
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_stock a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.stock_id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_salesback a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.salesbackid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.salesbackstatus<>'中止'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_outboundorder a
		LEFT JOIN ld_outboundordercf b ON a.out_id=b.out_id
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.out_id
		LEFT JOIN ld_inventoryproductrelscf d ON d.lineitem_id=c.lineitem_id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.approvestatus='已批准'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_purchaseback a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.purchasebackid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND a.purchasebackstatus<>'中止'
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.purchasebackstatus='结束'
				END)
		UNION ALL
		SELECT
			a.inwarehouse,
			c.productid,
			c.batchtext,
			c.quantity
		FROM ld_warehousetransfer a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.warehousetransferid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.transferstatus='已审核'
				END)
		UNION ALL
		SELECT
			a.outwarehouse,
			c.productid,
			c.batchtext,
			0-c.quantity
		FROM ld_warehousetransfer a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.warehousetransferid
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.transferstatus='已审核'
				END)
		UNION ALL
		SELECT
			a.wareid,
			c.productid,
			c.batchtext,
			c.profitloss
		FROM ld_checks a
		LEFT JOIN ld_inventoryproductrel c ON c.id=a.id
		LEFT JOIN ld_products p ON p.productid=c.productid
		WHERE a.deleted=0
			AND (
				CASE
					WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=48 AND deploy_value=1) THEN 1=1
					ELSE a.presence='盘点结束'
				END)
	) a
	WHERE a.productid>0
	GROUP BY a.productid
) a ON a.productid=p.productid
SET p.qtyinstock=IFNULL(a.inventory_qty,0)
WHERE p.deleted=0
	AND IFNULL(p.qtyinstock,0)<>IFNULL(a.inventory_qty,0);
    

UPDATE ld_inventoryproductrel b
SET b.discount_amount=b.quantity*IF(IFNULL(b.taxprice,0)=0,IFNULL(b.listprice,0),IFNULL(b.taxprice,0))-b.tax_amount
WHERE b.discount_percent>0 AND b.discount_amount<100
	AND b.discount_amount<>b.quantity*IF(IFNULL(b.taxprice,0)=0,IFNULL(b.listprice,0),IFNULL(b.taxprice,0))-b.tax_amount
	AND EXISTS (SELECT 1 FROM ld_producttoolfield_formula 
        WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname='discount_amount')
		  AND formulastring='a*b*(100-c/100)');

UPDATE ld_producttoolfield_formula SET formulastring='base_tax_amount*a*(100-c)*0.01' 
WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname='discount_amount')
	AND formulastring IN ('a*b*(100-c/100)','a*b*(100-c)*0.01')
	AND columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}";

UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'DT~M~','DT~O~'),quickcreate=0 WHERE tabid=13 AND columnname='realtime'
	AND NOT EXISTS (SELECT 1 FROM ld_troubletickets);
    
call addcolumn('ld_troubletickets','longtitude','varchar',255,NULL);
call addcolumn('ld_troubletickets','latitude','varchar',255,NULL);
call addcolumn('ld_troubletickets','location_address','varchar',255,NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','visiblerangsettings','可见范围设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'visiblerangsettings' and labeltype = 'fixedstr');
delimiter;

update ld_desk set  fieldlabel='可见范围设置'
 where languagetype='zh' and labelbol='visiblerangsettings'
and fieldlabel='visiblerangsettings'
and labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel = 'Batch pull enterprise WeChat \' my customer \' data, do not refresh or close browser'
where languagetype = 'zh' and labelbol = 'IMPORTDATAREMIND1' and Labeltype = 'jspop';
delimiter;

update ld_field set approve_demand = 2 where tabid = 2 and columnname in ('bill_street','bill_area','locationaddress_map','locationaddress','bill_country','bill_state','bill_city');
delimiter;

update ld_field set approve_demand = 2 where tabid = 6 and columnname in ('bill_street','bill_area','locationaddress_map','locationaddress','bill_country','bill_state','bill_city');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_field set approve_demand = 2 where tabid = @tabid and columnname in ('bill_street','bill_area','locationaddress_map','locationaddress','bill_country','bill_state','bill_city');
delimiter;

call AddColumn('ld_workreport_field','allow_edit','varchar','20',NULL);
update ld_workreport_field set allow_edit = 'yes' where allow_edit is NULL;
delimiter;

select max(id) into @id from ld_workreport_field;
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename,allow_edit)
select @id+1,'saleskit_day','简报详情','workreport',1,'',150,1,0,0,100000,'ld_workreport','no' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'saleskit_day' and entitytype = 'workreport' and type = 1);
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename,allow_edit)
select @id+2,'saleskit_week','简报详情','workreport',2,'',150,1,0,0,100000,'ld_workreport','no' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'saleskit_week' and entitytype = 'workreport' and type = 2);
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename,allow_edit)
select @id+3,'saleskit_month','简报详情','workreport',3,'',150,1,0,0,100000,'ld_workreport','no' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'saleskit_month' and entitytype = 'workreport' and type = 3);
delimiter;

call AddColumn('ld_workreport','saleskit_day','text','',NULL);
call AddColumn('ld_workreport','saleskit_week','text','',NULL);
call AddColumn('ld_workreport','saleskit_month','text','',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','visiblerangsettings1','指定日期范围内没有销售简报数据！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'visiblerangsettings1' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','visiblerangsettings1','No sales briefing data is available within the specified date range!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'visiblerangsettings1' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
update ld_field set sequence = sequence + 100 where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'locationaddress','yes','ld_contactdetails',1,65,'locationaddress','定位',1,1,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+2,'locationaddress_map','yes','ld_contactdetails',1,64,'locationaddress_map','定位地址地图',1,1,NULL,NULL,2,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'locationaddress_map');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'定位' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Location' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'locationaddress_map';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'地图' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Map' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where block = @blockid and tabid = @tabid order by sequence;
delimiter;

call AddColumn('ld_contactdetails','locationaddress','varchar','200',NULL);
delimiter;
call AddColumn('ld_contactdetails','locationaddress_map','varchar','20',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'locationaddress';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','locationaddress' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

call AddColumn('ld_usereportcolumns','tabname','varchar',50,null );
delimiter;
select usereportid into @usereportid from ld_usereport where name='SalesSumSequence';
update ld_usereportcolumns set tabname='Accounts' where `columns` like '%ld_account:accountcount:accountcount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='Contacts' where `columns` like '%ld_contactdetails:contactcount:contactcount:OftenUseReport%'
and Usereportid=@usereportid;
update ld_usereportcolumns set tabname='Potentials' where `columns` like '%ld_potentials:potentialcount:potentialcount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='Calendar' where `columns` like '%ld_activies:calendarcount:calendarcount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='ContactRecords' where `columns` like '%ld_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='HelpDesk' where `columns` like '%ld_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='CashBill' where `columns` like '%ld_cashbill:cashbilltotal:cashbilltotal:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='CashBill' where `columns` like '%ld_cashbill:cashbillcount:cashbillcount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='SalesOrder' where `columns` like '%ld_salesorder:salesordercount:salesordercount:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='Expense' where `columns` like '%ld_expense:expensetotal:expensetotal:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='ServiceContracts' where `columns` like '%ld_servicecontracts:servicecontractstotal:servicecontractstotal%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='ServiceContracts' where `columns` like '%ld_servicecontracts:servicecontractscount:servicecontractscount%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='Invoice' where `columns` like '%ld_invoice:invoicetotal:invoicetotal:OftenUseReport%'
and Usereportid=@usereportid;

update ld_usereportcolumns set tabname='OutboundOrder' where `columns` like '%ld_outboundorder:outboundordertotal:outboundordertotal:OftenUseReport%'
and Usereportid=@usereportid;

delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','RELFECTLBL_FIELDNAME','映射前字段名称','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='RELFECTLBL_FIELDNAME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','RELFECTLBL_FIELDNAME','Field Name','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='RELFECTLBL_FIELDNAME' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','AFTERRELFECTLBL_FIELDNAME','映射后字段名称','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='AFTERRELFECTLBL_FIELDNAME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','AFTERRELFECTLBL_FIELDNAME','After Field Name','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='AFTERRELFECTLBL_FIELDNAME' AND Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CHOOSEPUBLICACCOUNTADMIN','选择公海管理员','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHOOSEPUBLICACCOUNTADMIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CHOOSEPUBLICACCOUNTADMIN','选择公海管理员','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHOOSEPUBLICACCOUNTADMIN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','quickcreatesettings','快速创建设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'quickcreatesettings' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','quickcreatesettings','Quick create Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'quickcreatesettings' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','defaultquickcreate','默认快速创建','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'defaultquickcreate' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','defaultquickcreate','Default quick create','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'defaultquickcreate' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','defaultdisplaymoreitem','默认展开更多栏目','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'defaultdisplaymoreitem' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','defaultdisplaymoreitem','Default display more item','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'defaultdisplaymoreitem' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_tab','isduplicate','varchar','20','null');
update ld_tab set isduplicate = 'no' where isduplicate is NULL;
delimiter;
-- 2019-01-11

CREATE TABLE IF NOT EXISTS `ld_bangwobacvadvfilter` (
  `id` int(11) DEFAULT NULL,
  `columnindex` int(11) DEFAULT NULL,
  `columnname` varchar(255) DEFAULT NULL,
  `comparator` varchar(100) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `groupid` int(11) DEFAULT NULL,
  `column_condition` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_bangwobacvadvfilter_grouping` (
  `groupid` int(11) NOT NULL DEFAULT '0',
  `id` int(11) NOT NULL DEFAULT '0',
  `group_condition` varchar(255) DEFAULT NULL,
  `condition_expression` text,
  PRIMARY KEY (`groupid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq set id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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
delimiter;

UPDATE ld_version SET old_version='V7.6.6',current_version='V7.6.6',remark='V7.6.6-20190111',wx_version='V7.6.6';
delimiter;