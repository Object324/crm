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


call AddColumn('ld_users','yunzhijia_openid','varchar','100','');
delimiter;
call AddColumn('ld_users','yunzhijia_wbuserid','varchar','100','');
delimiter;

SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='user_name' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='user_name' LIMIT 1);
SET @columnname='yunzhijia_wbuserid';
SET @fieldname='yunzhijia_wbuserid';
SET @zh='云之家通讯录账号';
SET @en='yunzhijia wbuserid';
SET @uitype=1;
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

UPDATE ld_desk SET fieldlabel='Select dynamic variables' WHERE labelbol= 'SETTHECONTENTFORMAT' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='选择动态变量' WHERE labelbol= 'SETTHECONTENTFORMAT' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

update ld_option_module set maxrowsshow=5 where maxrowsshow is null or maxrowsshow=0;
delimiter;

call AddColumn('ld_customform36','entitytype','varchar','50',null);
delimiter;
call AddColumn('ld_customform36','source_list','varchar','500',null);
delimiter;

call AddColumn('ld_customform37','source_list','varchar','50',null);
delimiter;
call AddColumn('ld_customform37','source_list','varchar','500',null);
delimiter;

call AddColumn('ld_customform38','source_list','varchar','500',null);
delimiter;
call AddColumn('ld_customform38','entitytype','varchar','50',null);
delimiter;
call AddColumn('ld_customform39','entitytype','varchar','50',null);
delimiter;
call AddColumn('ld_customform39','source_list','varchar','500',null);
delimiter;
call AddColumn('ld_customform40','entitytype','varchar','50',null);
delimiter;
call AddColumn('ld_customform41','entitytype','varchar','50',null);
delimiter;
call AddColumn('ld_customform40','source_list','varchar','500',null);
delimiter;


select max(sequence) + 1 into @max_sequence from ld_settings_field where blockid = 4;
select max(fieldid) + 1 into @max_fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @max_fieldid,4,'yunzhijia_setting','picklistdependency.png','yunzhijia_setting','index.php?module=Settings&action=yunzhijia_setting&parenttab=Settings',@max_sequence,0 from DUAL
where not exists(select 1 from ld_settings_field where `name` = 'yunzhijia_setting');
delimiter;

update ld_settings_field_seq set id = (select max(fieldid) from ld_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','yunzhijia_setting','云之家接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='yunzhijia_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','yunzhijia_setting','yunzhijia settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='yunzhijia_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WECHATAPPLETSETTINGSREMIND051','CRM外网访问地址请参照此格式输入：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WECHATAPPLETSETTINGSREMIND051' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WECHATAPPLETSETTINGSREMIND051','Please enter CRM URL according to the example, example: ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WECHATAPPLETSETTINGSREMIND051' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_reminds','push_to_yzj','int','2',0);
delimiter;
call AddColumn('ld_workreport_remind','push_to_yzj','int','2',0);
delimiter;
CALL AddColumn('ld_reminds','push_time_yzj','datetime',null ,null );
delimiter;
CALL AddColumn('ld_workreport_remind','push_time_yzj','datetime',null,null);
delimiter;

alter table `ld_reminds` change `push_to_yzj` `push_to_yzj` int DEFAULT 2 COMMENT '云之家提醒发送标识';
alter table `ld_reminds` change `push_time_yzj` `push_time_yzj` datetime COMMENT '云之家提醒发送时间';
alter table `ld_workreport_remind` change `push_to_yzj` `push_to_yzj` int DEFAULT 2 COMMENT '云之家提醒发送标识';
alter table `ld_workreport_remind` change `push_time_yzj` `push_time_yzj` datetime COMMENT '云之家提醒发送时间';
delimiter

update ld_reminds set push_to_yzj = 2 where push_to_yzj = 0;
delimiter;
-- 2020-10-18

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TemplatesCustomization','组件模板定制','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TemplatesCustomization' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TemplatesCustomization','Templates Customization','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TemplatesCustomization' and labeltype='fixedstr');
delimiter;
update ld_attachmentsforbillsdetails set storage_location='local' where (storage_location is null or storage_location ='') 
and( cloud_path is null or cloud_path='');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BillMeetCondition','该单据不符合条件，不允许创建相关联的单据！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BillMeetCondition' and labeltype='fixedstr') ;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BillMeetCondition','This document does not meet the conditions, do not allow the creation of associated documents!','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BillMeetCondition' and labeltype='fixedstr') ;
delimiter;

CREATE TABLE if NOT EXISTS `ld_wechatsession` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
    `seq` int(11) DEFAULT NULL COMMENT '会话消息seq',
    `msgid` VARCHAR(255) DEFAULT NULL UNIQUE COMMENT '消息id，可用此去重',
    `filepath` VARCHAR(255) DEFAULT NULL  COMMENT '文件cos地址',
    `filename` VARCHAR(255) DEFAULT NULL  COMMENT '文件名称',
	`action` VARCHAR(100) DEFAULT NULL COMMENT '消息动作，目前有send(发送消息)/recall(撤回消息)/switch(切换企业日志)三种类型',
	`fromid` VARCHAR(255) DEFAULT NULL COMMENT '消息发送方id',
    `tolist` TEXT DEFAULT NULL COMMENT '消息接收方列表',
	`roomid`  VARCHAR(100) DEFAULT NULL COMMENT '群聊消息的群id',
    `msgtype` VARCHAR(100) DEFAULT NULL COMMENT '消息类型', 
    `content` TEXT  DEFAULT NULL COMMENT '消息内容',
    `sdkfileid` TEXT  DEFAULT NULL COMMENT '媒体资源的id信息',
    `md5sum` VARCHAR(100) DEFAULT NULL COMMENT '资源的md5值', 
    `filesize` VARCHAR(100) DEFAULT NULL COMMENT '资源的文件大小',
    `msgtime` datetime DEFAULT '0000-00-00 00:00:00' COMMENT '消息发送时间戳',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
	 PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
-- 2020-10-21

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

UPDATE ld_version SET old_version='V8.2.7',current_version='V8.2.7',remark='V8.2.7-20201021',wx_version='V8.2.6';
delimiter;