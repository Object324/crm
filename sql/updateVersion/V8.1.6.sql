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


UPDATE ld_option_module SET datarang='all',maxrowsshow=5 WHERE datarang IS NULL OR maxrowsshow=0 AND tabid>160;
UPDATE ld_field SET bigtype='picklist' WHERE uitype=15 AND IFNULL(bigtype,'')<>'picklist';
UPDATE ld_actionmapping SET actionname ='JobLevel' WHERE actionid ='Job level';
SET @tabid = (SELECT tabid FROM ld_tab WHERE name ='Users');
DELETE FROM ld_profileallpermission WHERE tabid =@tabid AND operation > (SELECT MAX(actionid) FROM ld_actionmapping);
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm26';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm26','customform26_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm26','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm26','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm26');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform26_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform26_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm27';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm27','customform27_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm27','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm27','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm27');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform27_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform27_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm28';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm28','customform28_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm28','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm28','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm28');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform28_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform28_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm29';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm29','customform29_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm29','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm29','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm29');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform29_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform29_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm30';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm30','customform30_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm30','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm30','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm30');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform30_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform30_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm31';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm31','customform31_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm31','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm31','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm31');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform31_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform31_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm32';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm32','customform32_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm32','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm32','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm32');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform32_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform32_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm33';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm33','customform33_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm33','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm33','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm33');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform33_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform33_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm34';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm34','customform34_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm34','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm34','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm34');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform34_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform34_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm35';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm35','customform35_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm35','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm35','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm35');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform35_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform35_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm36';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm36','customform36_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm36','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm36','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm36');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform36_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform36_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm37';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm37','customform37_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm37','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm37','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm37');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform37_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform37_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm38';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm38','customform38_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm38','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm38','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm38');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform38_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform38_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm39';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm39','customform39_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm39','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm39','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm39');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform39_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform39_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm40';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm40','customform40_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm40','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm40','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm40');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform40_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform40_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm41';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm41','customform41_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm41','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm41','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm41');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform41_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform41_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm42';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm42','customform42_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm42','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm42','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm42');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform42_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform42_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm43';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm43','customform43_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm43','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm43','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm43');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform43_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform43_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm44';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm44','customform44_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm44','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm44','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm44');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform44_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform44_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm45';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm45','customform45_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm45','total','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm45','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm45');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform45_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform45_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

-- 46-60不带分录
DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm46';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm46','customform46_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm46','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm46','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm46');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform46_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform46_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm47';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm47','customform47_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm47','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm47','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm47');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform47_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform47_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm48';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm48','customform48_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm48','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm48','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm48');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform48_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform48_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm49';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm49','customform49_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm49','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm49','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm49');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform49_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform49_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm50';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm50','customform50_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm50','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm50','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm50');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform50_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform50_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm51';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm51','customform51_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm51','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm51','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm51');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform51_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform51_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm52';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm52','customform52_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm52','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm52','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm52');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform52_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform52_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm53';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm53','customform53_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm53','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm53','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm53');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform53_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform53_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm54';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm54','customform54_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm54','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm54','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm54');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform54_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform54_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm55';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm55','customform55_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm55','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm55','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm55');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform55_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform55_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm56';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm56','customform56_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm56','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm56','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm56');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform56_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform56_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm57';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm57','customform57_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm57','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm57','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm57');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform57_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform57_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm58';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm58','customform58_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm58','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm58','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm58');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform58_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform58_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm59';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm59','customform59_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm59','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm59','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm59');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform59_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform59_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='CustomForm60';
CALL ldcrm_add_cvcolumnlist_wx('CustomForm60','customform60_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm60','createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('CustomForm60','smownerid','3','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm60');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'customform60_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='customform60_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='SocialPromotion';
CALL ldcrm_add_cvcolumnlist_wx('SocialPromotion','activityname','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('SocialPromotion','smownerid','2','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SocialPromotion');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'activityname',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='activityname');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='smownerid');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CategorySettings','类别设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CategorySettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CategorySettings','Category Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CategorySettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TextDescriptionSettings','文字描述设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TextDescriptionSettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TextDescriptionSettings','Text Description Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TextDescriptionSettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @tabid =(SELECT tabid  from ld_tab where name ='Users');
DELETE FROM  ld_actionmapping where actionname ='Job level' or actionname='Department' or actionname='JobLevel' ;
DELETE FROM ld_profileallpermission WHERE tabid =@tabid AND operation > (SELECT MAX(actionid) FROM ld_actionmapping);

set @actionid =(SELECT max(actionid) from ld_actionmapping) +1 ;
set @maxSequence = (SELECT max(sequence) from ld_profileallpermission where tabid =@tabid)+1;

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid,'Department',0,'DEPARTMENT'  from  dual
where not EXISTS(select 1 from ld_actionmapping where actionname='Department');

SET  @departmentid = (SELECT actionid FROM  ld_actionmapping WHERE actionname='Department');
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@departmentid,@maxSequence from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @departmentid);

set @actionid =(SELECT max(actionid) from ld_actionmapping) +1 ;
set @maxSequence = (SELECT max(sequence) from ld_profileallpermission where tabid =@tabid)+1;

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid,'JobLevel',0,'JOBLEVEL'  from  dual
where not EXISTS(select 1 from ld_actionmapping where actionname='JobLevel');

SET  @jobLevelid = (SELECT actionid FROM  ld_actionmapping WHERE actionname='JobLevel');
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@jobLevelid,@maxSequence from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @jobLevelid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKREFILLABLEFIELD','（打勾字段为“可回填字段”）','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CHECKREFILLABLEFIELD' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKREFILLABLEFIELD','(the check field is "refillable field")','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CHECKREFILLABLEFIELD' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_modentity_num SET prefix = CONCAT(prefix,'-') WHERE active = 1 AND cur_id=1 AND REPLACE(semodule,'CustomForm','') BETWEEN 26 AND 60 AND prefix NOT LIKE '%-%';
delimiter;

update ld_tabdetailfield set defaultcolumn='2' where columnname='total';
delimiter;

UPDATE ld_desk set fieldlabel ='打勾字段为“可回填字段”' where labelbol='CHECKREFILLABLEFIELD' and languagetype='zh';
UPDATE ld_desk set fieldlabel ='The check field is "refillable field"' where labelbol='CHECKREFILLABLEFIELD' and languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_contactrecords',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

set @fieldid = (select fieldid from ld_field where tabid =55 and  columnname = 'location_address');
UPDATE ld_tranlabel  set fieldlabel = '签到地址_old'  where Relateid = @fieldid and tabid =@tabid and  languagetype='zh';
UPDATE ld_tranlabel  set fieldlabel = 'Sing address_old'  where Relateid = @fieldid and tabid =@tabid and  languagetype='en';

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_account',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_contactdetails',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_potential',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_troubletickets',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_project',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_campaign',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)

select @tabid,@fieldid,'sign_location_address','no','ld_products',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

update ld_approvestep set countersigner='no' where countersigner is null or countersigner='';
alter table ld_approvelog alter column countersigner set default 'no';
alter table ld_approvelog alter column nextstep_countersigner set default 'no';
alter table ld_approvestep alter column countersigner set default 'no';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_approveinfo_tobill`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_approveinfo_tobill`(
	tmp_columnname VARCHAR(100),
	tmp_columnnametype VARCHAR(100),
	tmp_columnnamelength INT(1)
)
BEGIN

	DECLARE tmp_tablename VARCHAR(100) DEFAULT NULL;

	DECLARE MYCUSOR CURSOR FOR SELECT tablename FROM ld_field WHERE columnname='approvestatus' AND tabid>=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm26') ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tablename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tablename;
	WHILE(tmp_tablename IS NOT NULL) DO

		-- 对应单据表增加字段即可，无需写入数据库
		SET @disable_triggers=1;
		CALl AddColumn(tmp_tablename,tmp_columnname,tmp_columnnametype,tmp_columnnamelength,NULL);
		SET @disable_triggers=NULL;

	FETCH MYCUSOR INTO tmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;


CALL ldcrm_add_approveinfo_tobill('approvesubmitter','INT',19);
CALL ldcrm_add_approveinfo_tobill('approvesubmittedtime','datetime',100);
CALL ldcrm_add_approveinfo_tobill('currentapprovestepid','INT',19);

DROP PROCEDURE IF EXISTS `ldcrm_add_approveinfo_tobill`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_billapproveinfo_20200731`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_billapproveinfo_20200731`(
)
BEGIN

	DECLARE tmp_modulename VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tablename VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tableindex VARCHAR(100) DEFAULT NULL;

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.setype AS modulename,
				c.tablename,
				e.entityidfield AS tmp_tableindex
			FROM (
				SELECT
					b.setype
				FROM (SELECT crmid FROM ld_approvelog WHERE crmid>0 GROUP BY crmid) a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				GROUP BY b.setype
			) a
			LEFT JOIN ld_tab b ON b.`name`=a.setype
			INNER JOIN (SELECT tabid,tablename FROM ld_field WHERE columnname='approvestatus') c ON c.tabid=b.tabid
			INNER JOIN ld_entityname e ON e.modulename=a.setype
			WHERE IFNULL(a.setype,'')<>'' 
				AND IFNULL(c.tablename,'')<>'' 
				AND IFNULL(e.entityidfield,'')<>''
				AND a.setype LIKE 'CustomForm%'
				AND RIGHT(a.setype,2)+0>=26;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_modulename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_modulename,tmp_tablename,tmp_tableindex;
	WHILE(tmp_modulename IS NOT NULL) DO
		SET @my_execsql_approveinfo=CONCAT("
			UPDATE (
				SELECT
					a.crmid,
					MAX(a.id) AS max_logid
				FROM ld_approvelog a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				WHERE b.setype='",tmp_modulename,"'
				GROUP BY a.crmid
			) a
			LEFT JOIN ld_approvelog b ON b.id=a.max_logid
			LEFT JOIN (
				SELECT
					a.crmid,
					MAX(a.id) AS max_logid
				FROM ld_approvelog a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				WHERE b.setype='",tmp_modulename,"'
					AND a.stepid=-1
				GROUP BY a.crmid
			) c ON a.crmid=c.crmid
			LEFT JOIN ld_approvelog d ON d.id=c.max_logid
			LEFT JOIN ",tmp_tablename," t ON t.",tmp_tableindex,"=d.crmid
			SET t.approvesubmittedtime=d.createdtime,
				t.approvesubmitter=d.approved_by,
				t.currentapprovestepid=b.stepid"
			);
		SET @disable_triggers=1;

		PREPARE my_execsql_stmt FROM @my_execsql_approveinfo;
		EXECUTE my_execsql_stmt;
		DEALLOCATE PREPARE my_execsql_stmt;

	FETCH MYCUSOR INTO tmp_modulename,tmp_tablename,tmp_tableindex;
	END WHILE;
	CLOSE MYCUSOR;

	SET @disable_triggers=NULL;

end ||
delimiter;

CALL ldcrm_reset_billapproveinfo_20200731();
DROP PROCEDURE IF EXISTS `ldcrm_reset_billapproveinfo_20200731`;


DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldformula`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_tabdetailfieldformula`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR 
					SELECT 
						tabdetailfieldid 
					FROM ld_tabdetailfield 
					WHERE tabid>=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm26' LIMIT 1) 
					AND columnname='total';
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
		SELECT tmp_id,'sum(a)',"{formulavar:[{'lettervar':'a','column':'amount'}]}",1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=tmp_id);
	FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_tabdetailfieldformula();
DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldformula`;

SET @i=10000;
UPDATE ld_tab SET tabsequence=(@i:=@i+1) 
WHERE `name` LIKE 'CustomForm%' 
	AND LEFT(RIGHT(`name`,2),1) IN (0,1,2,3,4,5,6) 
ORDER BY FIELD(description,'CUSTOMFORMBASIC','CUSTOMFORMPRODUCTREL','CUSTOMFORMBASICREL');

SET @i=0;
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;
delimiter;

UPDATE ld_option_module a LEFT JOIN ld_tab b ON b.tabid=a.tabid SET a.table_sequence=b.tabsequence;

UPDATE ld_customform26 SET total=(SELECT SUM(amount) FROM ld_customform26detail WHERE id=ld_customform26.customform26id) AND total=0;
UPDATE ld_customform27 SET total=(SELECT SUM(amount) FROM ld_customform27detail WHERE id=ld_customform27.customform27id) AND total=0;
UPDATE ld_customform28 SET total=(SELECT SUM(amount) FROM ld_customform28detail WHERE id=ld_customform28.customform28id) AND total=0;
UPDATE ld_customform29 SET total=(SELECT SUM(amount) FROM ld_customform29detail WHERE id=ld_customform29.customform29id) AND total=0;
UPDATE ld_customform30 SET total=(SELECT SUM(amount) FROM ld_customform30detail WHERE id=ld_customform30.customform30id) AND total=0;
UPDATE ld_customform31 SET total=(SELECT SUM(amount) FROM ld_customform31detail WHERE id=ld_customform31.customform31id) AND total=0;
UPDATE ld_customform32 SET total=(SELECT SUM(amount) FROM ld_customform32detail WHERE id=ld_customform32.customform32id) AND total=0;
UPDATE ld_customform33 SET total=(SELECT SUM(amount) FROM ld_customform33detail WHERE id=ld_customform33.customform33id) AND total=0;
UPDATE ld_customform34 SET total=(SELECT SUM(amount) FROM ld_customform34detail WHERE id=ld_customform34.customform34id) AND total=0;
UPDATE ld_customform35 SET total=(SELECT SUM(amount) FROM ld_customform35detail WHERE id=ld_customform35.customform35id) AND total=0;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_selectbill_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_selectbill_bymodule`(
    tmp_curmodule VARCHAR(100),
    tmp_selmodule VARCHAR(100)
)
BEGIN

    SET @cur_tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_curmodule LIMIT 1);
    SET @sel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_selmodule LIMIT 1);
    SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_option_module WHERE tabid=@cur_tabid),0);
    SET @table_sequence=IFNULL((SELECT tabsequence FROM ld_tab WHERE `name`=tmp_curmodule LIMIT 1),0);

    IF @cur_tabid>0 AND @sel_tabid>0 THEN
        IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_option_module' AND COLUMN_NAME='maxrowsshow') THEN
            SET @insert_sql=CONCAT("INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence,datarang,maxrowsshow)
    		SELECT ",@cur_tabid,",",@sel_tabid,",",0,",",0,",",0,",",@maxseq+1,",",@table_sequence,",'all',5
    		FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=",@cur_tabid," AND option_tabid=",@sel_tabid,")");
        ELSE
            SET @insert_sql=CONCAT("INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
    		SELECT ",@cur_tabid,",",@sel_tabid,",",0,",",0,",",0,",",@maxseq+1,",",@table_sequence,"
    		FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=",@cur_tabid," AND option_tabid=",@sel_tabid,")");
        END IF;
    
        PREPARE mystmt FROM @insert_sql;
        EXECUTE mystmt;
        DEALLOCATE PREPARE mystmt;
    END IF;

end ||
delimiter;


CALL ldcrm_add_selectbill_bymodule('Singin','Leads');

DROP PROCEDURE IF EXISTS `ldcrm_add_signin_fields`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_signin_fields`(
    tmp_tablename VARCHAR(100)
)
BEGIN
    call AddColumn(tmp_tablename,'sign_longtitude','varchar',200,NULL);
    call AddColumn(tmp_tablename,'sign_latitude','varchar',200,NULL);
    call AddColumn(tmp_tablename,'sign_location_address','varchar',200,NULL);
END||
delimiter;

CALL	ldcrm_add_signin_fields('ld_leads');
DROP PROCEDURE  ldcrm_add_signin_fields;

select tabid into @tabid from ld_tab where `name` = 'Leads';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'sign_location_address','no','ld_leads',1,1,'sign_location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'sign_location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'sign_location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');

select tabid into @tabid from ld_tab where `name` = 'Leads';

SET @curTabid = (SELECT tabid from ld_tab where name ='Singin');
UPDATE ld_option_module set sequence = 0 WHERE option_tabid = @tabid and tabid =@curTabid;
set @i=0;
UPDATE ld_option_module set sequence=(@i:=@i+1) where  tabid =@curTabid order by sequence;
delimiter;

UPDATE ld_related_field 
SET fromvalue_info=CONCAT(fromvalue_info,'
UNION
SELECT CONCAT(ld_leads.bill_state,ld_leads.bill_city,IFNULL(ld_leads.bill_area,""),ld_leads.bill_street) AS address
FROM ld_leads
WHERE deleted = 0 AND leadsid = ?') 
WHERE effect_fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_singin' AND columnname='address')
	AND fromvalue_info NOT LIKE '%ld_leads%';
    
drop PROCEDURE if EXISTS addproductbomcolumn;
delimiter ||
create PROCEDURE addproductbomcolumn()
begin 
	declare ttablename varchar(100);
 declare done  int  default 0;
	declare cur1 CURSOR FOR select tablename  from ld_producttoolfield  
 where columnname='quantity' AND tablename IS NOT NULL;
	declare continue handler  for not   found  SET done =1;	
	OPEN cur1;
	Fetch cur1 into ttablename;
loop1: while  done<>1 DO
	 set @sql=concat(" call AddColumn('",ttablename,"', 'productbomid','int' ,'19','0') ");

	  prepare stmt2 from @sql;
		execute stmt2;
		deallocate prepare stmt2;

	  set @sql=concat(" call AddColumn('",ttablename,"', 'productbomquantity','int' ,'19','0') ");
	   prepare stmt3 from @sql;
		execute stmt3;
		deallocate prepare stmt3;

	Fetch cur1 into ttablename;
end while loop1;
close cur1;

end ||
delimiter;

call AddColumn('ld_productbom', 'discount_type','int' ,'11','0');
delimiter;
call AddColumn('ld_productbom', 'discount_percent','decimal' ,'20','0');
delimiter;
call AddColumn('ld_productbom', 'discount_amount','decimal' ,'20','0');
delimiter;
call AddColumn('ld_productbom', 'adjustment','decimal' ,'20','0');
delimiter;

call addproductbomcolumn();
drop PROCEDURE if EXISTS addproductbomcolumn;
delimiter;



select tabid into @tabid  from ld_tab where name='productbom';
select id into @producttoolfieldid  from ld_producttoolfield_seq;
update ld_producttoolfield_seq set id=@id+1 where not EXISTS(select 1 from ld_producttoolfield  where tabid=@tabid and columnname='total');
insert into ld_producttoolfield (producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence
,tabid,tablename,width,edit_permission,input_type,newline,defaultcolumn)
select @producttoolfieldid+1, columnname,allowhide,fieldlabel,defaultvalue,0,uitype,
typeofdata,sequence,@tabid,'ld_productbom',width,edit_permission,input_type,newline,defaultcolumn 
from ld_producttoolfield where tabid=22 and columnname='total'
and not EXISTS(select 1 from ld_producttoolfield  where tabid=@tabid and columnname='total');
delimiter;

select tabid into @tabid  from ld_tab where name='productbom';
select producttoolfieldid into @producttoolfieldid  from ld_producttoolfield where tabid=@tabid and columnname='total';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'合计' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_producttoolfield' and tabid=@tabid and relateid=@producttoolfieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Total' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_producttoolfield' and tabid=@tabid and relateid=@producttoolfieldid);
delimiter;


select tabid into @tabid from ld_tab where name = 'ServiceCharge';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'legal_representative';
update ld_tranlabel set fieldlabel = 'Legal representative' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en';
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'legal_representative';
update ld_tranlabel set fieldlabel = 'Legal representative' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en';
delimiter;

update ld_entityname set fieldname='subject' where modulename='productbom' and fieldname='productbom_no';
delimiter;
-- 2020-07-31

SET @tablename =(SELECT tablename FROM ld_field WHERE tabid=6 AND presence<>1 AND columnname='leadsource');
UPDATE ld_cvcolumnlist SET columnname=REPLACE(columnname,'ld_accountscf','ld_account') WHERE columnname LIKE '%leadsource%' 
	AND columnname LIKE 'ld_accountscf%' AND @tablename='ld_account';
delimiter;

UPDATE ld_related_field
SET fromvalue_info=CONCAT(LEFT(fromvalue_info,CHAR_LENGTH(fromvalue_info)-13),'ld_leads.leadsid = ?')
WHERE effect_fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_singin' AND columnname='address')
	AND fromvalue_info LIKE '%FROM ld_leads%'
	AND RIGHT(fromvalue_info,13)='accountid = ?';

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

UPDATE ld_version SET old_version='V8.1.6',current_version='V8.1.6',remark='V8.1.6-20200731',wx_version='V8.1.6';
delimiter;