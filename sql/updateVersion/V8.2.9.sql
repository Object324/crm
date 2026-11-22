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

CALL AddColumn('ld_linkmodulecustom','entitytype','varchar','100',null);
UPDATE  ld_linkmodulecustom set entitytype = 'custom' where entitytype is null or entitytype ='';

CALL  AddColumn('ld_linkmodulecustom','linkmodule','varchar','50',null);
CALL  AddColumn('ld_linkmodulecustom','linkcvid', 'int','19',0);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETASLINKMODULE','设为链接模块','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETASLINKMODULE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETASLINKMODULE','Set as the link module','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETASLINKMODULE' and labeltype='fixedstr');
delimiter;

alter table ld_articles alter column look_nums set default 0;
alter table ld_articles alter column like_nums set default 0;
alter table ld_articles alter column share_nums set default 0;
alter table ld_articles alter column copy_nums set default 0;
delimiter;

call addcolumn('ld_wx_users','last_name','varchar','50','');
call addcolumn('ld_wx_users','weixin','varchar','20','');
call addcolumn('ld_wx_users','position','varchar','50','');
call addcolumn('ld_wx_users','company','varchar','255','');
delimiter;



CREATE TABLE IF NOT EXISTS `ld_articles_appid_set` (
	`app_id` VARCHAR (255) COMMENT 'app_id',
	`app_secret` varchar(255) COMMENT 'app_secret ',
	`token` varchar(255) COMMENT 'token '
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','associatedOfficialAccountSettings','关联公众号设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='associatedOfficialAccountSettings' and labeltype='fixedstr') ;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','associatedOfficialAccountSettings','Associated official account settings','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='associatedOfficialAccountSettings' and labeltype='fixedstr') ;
delimiter;


select max(tabid)into @maxtabid from ld_tab ;
select tabsequence into @tabsequence from ld_tab where `name` = 'Accounts';
update ld_tab set tabsequence = tabsequence +1000 where tabsequence >= @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'ChannelCode',0,@tabsequence+1,'ChannelCode',1 from dual 
where not EXISTS(select 1 from ld_tab where name='ChannelCode');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select tabid into @tabid from ld_tab  where name='ChannelCode';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'渠道码' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Channelcode' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

select sequence into @sequence from ld_settings_field where blockid = 4 and name = 'ExternalContactSetting';
update ld_settings_field set sequence = sequence + 10000 where blockid = 4 and sequence > @sequence;
select max(fieldid) + 1 into @max_fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @max_fieldid,4,'channelcode_settings','picklistdependency.png','channelcode_settings','index.php?module=Settings&action=channelcode_settings&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where `name` = 'channelcode_settings');
delimiter;

set @i =0 ;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=4 order by sequence asc;
delimiter;

update ld_settings_field_seq set id = (select max(fieldid) from ld_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','channelcode_settings','企业微信渠道码设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='channelcode_settings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','channelcode_settings','channelcode settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='channelcode_settings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','account_contact','客户联系','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='account_contact' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','account_contact','Account contact','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='account_contact' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','accepteventserversettings','接受事件服务器设置（需将以下字段填写至企业微信后台相应字段，否则无法使用自动打标签和自动招呼功能）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='accepteventserversettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','accepteventserversettings','Accept event server settings(The following fields need to be filled in to the corresponding fields in the enterprise wechat background)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='accepteventserversettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','tokenurl','回调地址','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='tokenurl' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','tokenurl','Token url','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='tokenurl' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wechat','个人微信','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='wechat' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wechat','Wechat','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='wechat' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nameofenterprise','企业名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='nameofenterprise' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nameofenterprise','Name of enterprise','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='nameofenterprise' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','channelname','渠道名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='channelname' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','channelname','Channel name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='channelname' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','scanningcustomers','扫码客户','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='scanningcustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','scanningcustomers','Scanning customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='scanningcustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','channelcode','渠道码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='channelcode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','channelcode','Channel code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='channelcode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Scancodetocontactstaff','扫码联系员工','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Scancodetocontactstaff' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Scancodetocontactstaff','Scan code to contact staff','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Scancodetocontactstaff' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Scanthecodeandlabelthecorrespondingcustomers','扫码给对应客户打标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Scanthecodeandlabelthecorrespondingcustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Scanthecodeandlabelthecorrespondingcustomers','Scan the code and label the corresponding customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Scanthecodeandlabelthecorrespondingcustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Welcomemessageform','欢迎语形式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Welcomemessageform' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Welcomemessageform','Welcome message form','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Welcomemessageform' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
SELECT @maxcvid+1,'All',1,0,'ChannelCode',3,1,1 FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype='ChannelCode' and viewname='All');
UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
delimiter;

select max(blockid) into @maxblockid from ld_blocks;
select tabid into @tabid from ld_tab where `name` = 'ChannelCode';
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_CHANNELCODE_INFORMATION',@sequence,null,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where blocklabel='LBL_CHANNELCODE_INFORMATION' and tabid=@tabid);
UPDATE  ld_blocks_seq SET  id=(SELECT max(blockid) FROM  ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ChannelCode';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_CHANNELCODE_INFORMATION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
delimiter;


SET @modulename='ChannelCode';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select blockid from ld_blocks where blocklabel = 'LBL_CHANNELCODE_INFORMATION');
SET @maxseq=1;
SET @trantable='ld_field';
SET @tablename='ld_channelcode';
SET @columnname='channel_name';
SET @fieldname='channel_name';
SET @zh='渠道名称';
SET @en='Channel name';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


SET @modulename='ChannelCode';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select blockid from ld_blocks where blocklabel = 'LBL_CHANNELCODE_INFORMATION');
SET @maxseq=1;
SET @trantable='ld_field';
SET @tablename='ld_channelcode';
SET @columnname='smcreatorid';
SET @fieldname='creator';
SET @zh='创建人';
SET @en='Creator';
SET @uitype=52;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @modulename='ChannelCode';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select blockid from ld_blocks where blocklabel = 'LBL_CHANNELCODE_INFORMATION');
SET @maxseq=1;
SET @trantable='ld_field';
SET @tablename='ld_channelcode';
SET @columnname='createdtime';
SET @fieldname='createdtime';
SET @zh='创建时间';
SET @en='Creator time';
SET @uitype=70;
SET @typeofdata='DT~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @modulename='ChannelCode';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select blockid from ld_blocks where blocklabel = 'LBL_CHANNELCODE_INFORMATION');
SET @maxseq=1;
SET @trantable='ld_field';
SET @tablename='ld_channelcode';
SET @columnname='scan_times';
SET @fieldname='scan_times';
SET @zh='扫码次数';
SET @en='Scan times';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @modulename='ChannelCode';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select blockid from ld_blocks where blocklabel = 'LBL_CHANNELCODE_INFORMATION');
SET @maxseq=1;
SET @trantable='ld_field';
SET @tablename='ld_channelcode';
SET @columnname='channel_userid';
SET @fieldname='channel_userid';
SET @zh='可联系成员';
SET @en='Scan times';
SET @uitype=154;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


select cvid into @cvid from ld_customview where entitytype = 'ChannelCode' and viewname = 'All';
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,0,CONCAT('ld_channelcode:channel_name:channel_name:ChannelCode_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,1,CONCAT('ld_channelcode:scan_times:scan_times:ChannelCode_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,2,CONCAT('ld_channelcode:channel_userid:channel_userid:ChannelCode_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,3,CONCAT('ld_channelcode:smcreatorid:creator:ChannelCode_fieldlabel:V');
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,4,CONCAT('ld_channelcode:createdtime:createdtime:ChannelCode_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ChannelCode';
INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
SELECT @tabid,'ChannelCode','ld_channelcode','channel_name','id','id' FROM DUAl
WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename='ChannelCode');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Generate','生成','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Generate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Generate','Generate','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Generate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Selectwechatemployees','选择企业微信员工','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Selectwechatemployees' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Selectwechatemployees','Select wechat employees','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Selectwechatemployees' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Channelinformationsetting','渠道信息设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Channelinformationsetting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Channelinformationsetting','Channel information setting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Channelinformationsetting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customersautomaticallybecomefriendswithoutconfirmation','客户添加时无需经过确认自动成为好友','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customersautomaticallybecomefriendswithoutconfirmation' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customersautomaticallybecomefriendswithoutconfirmation','Customers automatically become friends without confirmation','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customersautomaticallybecomefriendswithoutconfirmation' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Labelthecorrespondingcustomerafterscanningthecode','扫码后给对应客户打标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Labelthecorrespondingcustomerafterscanningthecode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Labelthecorrespondingcustomerafterscanningthecode','Label the corresponding customer after scanning the code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Labelthecorrespondingcustomerafterscanningthecode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Autogreetingsettings','自动打招呼设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Autogreetingsettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Autogreetingsettings','Auto greeting settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Autogreetingsettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Turnonautogreeting','开启自动打招呼','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Turnonautogreeting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Turnonautogreeting','Turn on auto greeting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Turnonautogreeting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Text1','文字','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Text1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Text1','Text','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Text1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Card','链接卡片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Card' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Card','Link card','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Card' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','App','小程序','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='App' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','App','App','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='App' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Twotypesofmessagetypescanbeselected','可同时选择两类消息类型，但受限于企业微信。[链接卡片]、[图片]、[小程序]只能选择其中一种发送','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Twotypesofmessagetypescanbeselected' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Twotypesofmessagetypescanbeselected','Two types of message types can be selected at the same time, but limited to enterprise wechat. [link card], [image], [app] can only select one of them to send','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Twotypesofmessagetypescanbeselected' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Welcomeexamples','欢迎示例','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Welcomeexamples' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Welcomeexamples','Welcome examples','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Welcomeexamples' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Uploadpictures','上传图片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Uploadpictures' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Uploadpictures','Upload pictures','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Uploadpictures' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Therecommendedscaleoflinkcardimageis','链接卡片图片建议比例为1:1，最大尺寸不超过640*640，体积小于2MB，支持PNG、JPG格式上传。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Therecommendedscaleoflinkcardimageis' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Therecommendedscaleoflinkcardimageis','The recommended scale of link card image is 1:1, the maximum size is not more than 640 * 640, and the volume is less than 2MB. It supports PNG and JPG format upload. ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Therecommendedscaleoflinkcardimageis' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Inputcardlink','输入卡片链接','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Inputcardlink' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Inputcardlink','Input card link','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Inputcardlink' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseuploadpicturesinPNGandJPGformat','请上传格式为 PNG、JPG 格式的图片，建议尺寸为 520*416，大小不超过 2MB。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseuploadpicturesinPNGandJPGformat' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseuploadpicturesinPNGandJPGformat','Please upload pictures in PNG and JPG format. The recommended size is 520 * 416, and the size should not exceed 2MB.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseuploadpicturesinPNGandJPGformat' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Cover','封面图','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Cover' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Cover','Cover','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Cover' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','route','路径','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='route' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','route','route','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='route' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thisappletmusthavebeenassociated','注意：此小程序必须已经关联到企业微信。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='thisappletmusthavebeenassociated' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thisappletmusthavebeenassociated','Note: this applet must have been associated with the enterprise wechat.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='thisappletmusthavebeenassociated' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Seehowtorelate','查看如何关联','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Seehowtorelate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Seehowtorelate','See how to relate','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Seehowtorelate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Seehowtorelate','查看如何关联','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Seehowtorelate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Seehowtorelate','See how to relate','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Seehowtorelate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Appexample','小程序示例','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Appexample' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Appexample','App example','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Appexample' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_channelcode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_id` varchar(200) DEFAULT NULL COMMENT '渠道码唯一ID',
  `qr_code` varchar(200) DEFAULT NULL COMMENT '渠道码链接地址',
  `channel_name` varchar(50) DEFAULT NULL,
  `channel_userid` varchar(50) DEFAULT NULL,
  `scan_times` int(11) DEFAULT '0',
  `channelverify` varchar(10) DEFAULT NULL,
  `contact_way_type` varchar(20) DEFAULT NULL,
  `words` text,
  `file_path` varchar(255) DEFAULT NULL,
  `file_name` varchar(200) DEFAULT NULL,
  `file_media_id` varchar(255) DEFAULT NULL,
  `file_pic_url` text,
  `card_title` varchar(255) DEFAULT NULL,
  `card_description` text,
  `card_href` varchar(200) DEFAULT NULL,
  `app_title` varchar(200) DEFAULT NULL,
  `app_id` varchar(200) DEFAULT NULL,
  `app_src` text,
  `deleted` int(1) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT NULL,
  `smownerid` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_channelcode_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `record` int(11) DEFAULT NULL,
  `wx_userid` varchar(50) DEFAULT NULL,
  `external_contact_name` varchar(100) DEFAULT NULL,
  `external_contact_corpname` varchar(100) DEFAULT NULL,
  `external_contact_type` int(2) DEFAULT NULL,
  `externaluserid` varchar(200) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `changetype` varchar(50) DEFAULT NULL,
  `deleted` int(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_channellabel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channelcode_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `label_string` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

ALTER TABLE ld_warehouse ALTER COLUMN started SET DEFAULT 0;
DELETE FROM ld_tab WHERE `name`='Prdtnums';
UPDATE ld_warehouse SET started=0 WHERE started=1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Installenterprisewechatversion','安装企业微信版本','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Installenterprisewechatversion' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Installenterprisewechatversion','Install enterprise wechat version','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Installenterprisewechatversion' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YouhavenotinstalledenterprisewechatCRM','您尚未安装企业微信CRM，请点击链接前往安装。','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='YouhavenotinstalledenterprisewechatCRM' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YouhavenotinstalledenterprisewechatCRM','You have not installed enterprise wechat CRM, please click the link to install.','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='YouhavenotinstalledenterprisewechatCRM' and Labeltype='jspop' and languagetype='en');
delimiter;

SET @modulename='Articles';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where tabid = @tabid and fieldname = 'assigned_user_id');
SET @maxseq=(select max(sequence) as a from ld_field where tabid = @tabid and block = @relateid);
SET @trantable='ld_field';
SET @tablename='ld_articles';
SET @columnname='customers';
SET @fieldname='customers';
SET @zh='客户来源';
SET @en='customers';
SET @uitype=15;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

insert into ld_picklist_set(listname,relatetable)
select 'customers','ld_field' from dual 
where not exists(select 1 from ld_picklist_set where listname = 'customers' and relatetable = 'ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname = 'customers' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'微信',1 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '微信' and sequence = 1);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'渠道码',2 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '渠道码' and sequence = 2);
delimiter;

SET @modulename='Articles';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where tabid = @tabid and fieldname = 'assigned_user_id');
SET @maxseq=(select max(sequence) as a from ld_field where tabid = @tabid and block = @relateid);
SET @trantable='ld_field';
SET @tablename='ld_articles';
SET @columnname='weixin';
SET @fieldname='weixin';
SET @zh='微信';
SET @en='Wechat';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


SET @modulename='Articles';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where tabid = @tabid and fieldname = 'assigned_user_id');
SET @maxseq=(select max(sequence) as a from ld_field where tabid = @tabid and block = @relateid);
SET @trantable='ld_field';
SET @tablename='ld_articles';
SET @columnname='channelcode_id';
SET @fieldname='channelcode_id';
SET @zh='渠道码';
SET @en='Channel code';
SET @uitype=84;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='NULL';
SET @datarang=NULL;
SET @maxrowsshow=5;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

call AddColumn('ld_articles','customers','varchar','50',NULL);
call AddColumn('ld_articles','weixin','varchar','50',NULL);
call AddColumn('ld_articles','channelcode_id','int','11',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ChannelCode';
update ld_field set searchfieldtype = 0 where tabid = @tabid and columnname in ('channel_name','smcreatorid','createdtime','scan_times','channel_userid');
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select '84','reference' from dual
where not exists(select * from ld_ws_fieldtype where uitype='84' and fieldtype = 'reference');
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=84;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'ChannelCode' from dual
where not exists(select * from ld_ws_referencetype where type='ChannelCode' and fieldtypeid=@fieldtypeid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Articles';
update ld_field set defaultvalue = '微信' where tabid = @tabid and columnname = 'customers';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Articles';
insert into ld_fieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)
select @tabid,'客户来源','customers',now(),1,'yes' from DUAL
where not exists(select 1 from ld_fieldrule where tabid = @tabid and columnname = 'customers');
delimiter;

select id into @id from ld_fieldrule where tabid = @tabid and columnname = 'customers'; 
insert into ld_fieldrulebasicsearch(ruleid,comparator,`value`)
select @id,'e','微信' from DUAL 
where not exists(select 1 from ld_fieldrulebasicsearch where ruleid = @id and comparator = 'e' and `value` = '微信');
insert into ld_fieldrulebasicsearch(ruleid,comparator,`value`)
select @id,'e','渠道码' from DUAL 
where not exists(select 1 from ld_fieldrulebasicsearch where ruleid = @id and comparator = 'e' and `value` = '渠道码');
delimiter

select id into @id from ld_fieldrule where tabid = @tabid and columnname = 'customers'; 
select id into @sid from ld_fieldrulebasicsearch where ruleid = @id and comparator = 'e' and `value` = '微信';
insert into ld_fieldrule_operate(columnname,type,basicsearchid)
select 'weixin','display',@sid from DUAL
where not exists(select 1 from ld_fieldrule_operate where columnname = 'weixin' and type = 'display' and basicsearchid = @sid);
select id into @sid from ld_fieldrulebasicsearch where ruleid = @id and comparator = 'e' and `value` = '渠道码';
insert into ld_fieldrule_operate(columnname,type,basicsearchid)
select 'channelcode_id','display',@sid from DUAL
where not exists(select 1 from ld_fieldrule_operate where columnname = 'channelcode_id' and type = 'display' and basicsearchid = @sid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_articlesscf` (
  `articlesid` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`articlesid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Welcometousethechannelcode','欢迎您使用助力企业微信私域流量的强大工具——渠道码。您可以通过渠道码了解区分不同渠道的推广效果，并根据不同来源渠道给客户发送特定的欢迎语和自动打标签。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Welcometousethechannelcode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Welcometousethechannelcode','Welcome to use the channel code, a powerful tool to help enterprises wechat private domain traffic. You can know how to distinguish the promotion effect of different channels through the channel code, and send specific welcome messages and automatically label customers according to different source channels.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Welcometousethechannelcode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Thefirstchannelcodetoexperienceit','第一个渠道码去体验吧！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Thefirstchannelcodetoexperienceit' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Thefirstchannelcodetoexperienceit','The first channel code to experience it!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Thefirstchannelcodetoexperienceit' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Start','开始','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Start' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Start','Start','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Start' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2020-10-30

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

UPDATE ld_version SET old_version='V8.2.9',current_version='V8.2.9',remark='V8.2.9-20201030',wx_version='V8.2.8';
delimiter;