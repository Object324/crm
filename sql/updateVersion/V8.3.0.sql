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

update ld_desk set fieldlabel = '接收事件服务器设置（需将以下字段填写至企业微信后台相应字段，否则无法使用自动打标签和自动招呼功能）' 
where languagetype = 'zh' and labelbol = 'accepteventserversettings' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Itisnecessarytofillinthecorrespondingfields','需将企业微信后台相应字段填写至以下字段中，否则无法启用渠道码功能','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Itisnecessarytofillinthecorrespondingfields' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Itisnecessarytofillinthecorrespondingfields','It is necessary to fill in the corresponding fields in the background of enterprise wechat into the following fields, otherwise the channel code function cannot be enabled','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Itisnecessarytofillinthecorrespondingfields' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE
IF NOT EXISTS `ld_wx_user_log` (
	`id` INT (11) UNSIGNED AUTO_INCREMENT COMMENT '自增ID',
	`type` varchar(100) COMMENT '操作类型 ',
	`createdtime` datetime COMMENT '创建时间',
	`articlesid` int(11) COMMENT '文章id',
	`wx_user_id` int(11) COMMENT 'wx的创建人id',
	PRIMARY KEY (`id`)
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','channelcode_secret','http://51mis.com.cn/forum.php?mod=viewthread&tid=872&page=1&extra=#pid872','企业微信渠道码设置-secret取值' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'channelcode_secret');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','channelcode_token','http://51mis.com.cn/forum.php?mod=viewthread&tid=873&page=1&extra=#pid873','企业微信渠道码设置-配置接收事件服务器帮助论坛' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'channelcode_token');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','channelcode_externalcontact','http://51mis.com.cn/forum.php?mod=viewthread&tid=876&page=1&extra=#pid876','企业微信渠道码设置-客户联系我，如何授权企业微信用户' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'channelcode_externalcontact');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Noonefoundtoaddsee','没找到想要添加的人？查看','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Noonefoundtoaddsee' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Noonefoundtoaddsee','No one found to add? see','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Noonefoundtoaddsee' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Howtoaddthem','如何添加他们','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Howtoaddthem' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Howtoaddthem',' how to add them','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Howtoaddthem' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @disable_triggers=1;
call addcolumn('ld_account','wx_user_id','int','11','');
call addcolumn('ld_wx_users','status','tinyint','2','');
SET @disable_triggers=NULL;
delimiter;

call addcolumn('ld_wx_user_log','duration','int','11','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wxcovercontrol','建议尺寸：640*425','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'wxcovercontrol' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wxcovercontrol',"Recommended size:640*425",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'wxcovercontrol' and labeltype = 'jspop');
delimiter;

alter table ld_channelcode modify column channel_userid varchar(255);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ChannelCode';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,3,0 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
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
    `fileext` VARCHAR(25) DEFAULT NULL COMMENT '文件类型后缀',
    `upload_way` varchar(25) DEFAULT NULL COMMENT '上传方式 cos local',
    `play_length` VARCHAR(255) DEFAULT NULL COMMENT '视频播放长度',
    `corpname` varchar(255) DEFAULT NULL COMMENT '名片所有者所在的公司名称',
    `userid` varchar(255) DEFAULT NULL COMMENT '名片所有者的id',
    `longitude` varchar(255) DEFAULT NULL COMMENT '纬度',
    `latitude` varchar(255) DEFAULT NULL COMMENT '经度',
    `address` varchar(255) DEFAULT NULL COMMENT '地址信息',
    `title` varchar(255) DEFAULT NULL COMMENT '标题',
    `zoom` varchar(255) DEFAULT NULL COMMENT '缩放比例',
    `description` TEXT DEFAULT NULL COMMENT '描述',
    `link_url` TEXT DEFAULT NULL COMMENT '链接url地址',
    `image_url` TEXT DEFAULT NULL COMMENT '链接图片url',
    `username` varchar(255) DEFAULT NULL COMMENT '用户名称',
    `displayname` varchar(255) DEFAULT NULL COMMENT '小程序名称',
    `item` TEXT DEFAULT NULL COMMENT '消息记录内的消息内容，批量数据',
    `msgtime` datetime DEFAULT '0000-00-00 00:00:00' COMMENT '消息发送时间戳',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @relatedtabid from ld_tab where name='Accounts';
select id into @id from ld_relatedlists_seq;
select tabid into @tabid from ld_tab where name='Accounts';
update ld_relatedlists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_wechatsession'and tabid=@tabid);
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions) select @id+1,@tabid,@relatedtabid,'get_wechatsession',3,'Wechatsession',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_wechatsession' and tabid=@tabid);
delimiter;

select tabid into @relatedtabid from ld_tab where name='Contacts';
select id into @id from ld_relatedlists_seq;
select tabid into @tabid from ld_tab where name='Contacts';
update ld_relatedlists_seq set id=@id+1 where not exists(select 1 from ld_relatedlists where name='get_wechatsession'and tabid=@tabid);
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions) select @id+1,@tabid,@relatedtabid,'get_wechatsession',3,'Wechatsession',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_wechatsession' and tabid=@tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Wechatsession','会话','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Wechatsession' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Wechatsession','Wechat Session','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Wechatsession' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WechatSessionRecord','企业微信会话记录','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WechatSessionRecord' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WechatSessionRecord','Enterprise WeChat session records','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WechatSessionRecord' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SAVEASDATACLASS','保存为数据分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SAVEASDATACLASS' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SAVEASDATACLASS','Saved as data classification','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SAVEASDATACLASS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWCALASSIFICATION','新建分类','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWCALASSIFICATION' and Labeltype='jspop' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWCALASSIFICATION','New classification','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWCALASSIFICATION' and Labeltype='jspop' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CATEGORYNAME','分类名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CATEGORYNAME' and Labeltype='jspop' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CATEGORYNAME','Category Name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CATEGORYNAME' and Labeltype='jspop' and languagetype='en');
delimiter;

select max(blockid)+1 into @max_blockid from ld_blocks;
select sequence into @sequence from ld_blocks where tabid = 6 and blocklabel = 'LBL_ACCOUNT_INFORMATION';
update ld_blocks set sequence = sequence + 1000  where tabid = 6 and sequence > @sequence;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,6,'LBL_LABEL',@sequence - 1,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = 6 and blocklabel = 'LBL_LABEL');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = 6 order by sequence;
delimiter;

select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_LABEL';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',6,@blockid,'标签' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = 6 and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',6,@blockid,'Label' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = 6 and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select blockid from ld_blocks where blocklabel = 'LBL_LABEL' and tabid = @tabid);
SET @maxseq=1;
SET @trantable='ld_field';
SET @tablename='ld_account';
SET @columnname='tag';
SET @fieldname='tag';
SET @zh='标签';
SET @en='Tag';
SET @uitype=301;
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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Currenttag','当前标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Currenttag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Currenttag','Current tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Currenttag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectavailableTags','选择可用标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SelectavailableTags' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectavailableTags','Select available Tags','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SelectavailableTags' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Createanewtag','创建新的标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Createanewtag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Createanewtag','Create a new tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Createanewtag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','corptag','企业标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='corptag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','corptag','corp tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='corptag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Converttocampanytag','转换为企业标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Converttocampanytag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Converttocampanytag','Convert to campany tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Converttocampanytag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','onverttopersonaltag','转换为个人标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='onverttopersonaltag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','onverttopersonaltag','Convert to personal tag','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='onverttopersonaltag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','listnotag','暂无标签，请到单据详情页进行设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='listnotag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','listnotag','There is no tag at present. Please set it on the document details page','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='listnotag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `module` varchar(100) DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `tag_type` varchar(50) DEFAULT NULL,
  `tag_sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_moduledata_tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `record` int(11) DEFAULT NULL,
  `parentid` int(11) DEFAULT NULL,
  `tagged_on` datetime DEFAULT NULL,
  `tag_userid` int(11) DEFAULT NULL,
  `tag_sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_moduledata_tag_parentid` (`parentid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

SET @disable_triggers=1;
call AddColumn('ld_account','tag','varchar','50',NULL);
SET @disable_triggers=NULL;
delimiter;
-- 2020-11-06

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Converttocampanytag','转换为企业标签','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Converttocampanytag' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Converttocampanytag','Convert to campany tag','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Converttocampanytag' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','onverttopersonaltag','转换为个人标签','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='onverttopersonaltag' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','onverttopersonaltag','Convert to personal tag','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='onverttopersonaltag' and Labeltype='jspop' and languagetype='en');
delimiter;


update ld_dashboard_app set home_sequence=0 where name='monthlog' or name='weeklog' or name='daylog' or name='signednumber'
or name='signedamount' or name='cashbillamount' or name='SalesOrderTrack' or name='CashBillSum_SalesOrder' or name='CashBillSum_Paymentplan'
or name='expense_commission' or name='Salessituation';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewTagalreadyexists','新标签已存在，请重新录入！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NewTagalreadyexists' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewTagalreadyexists','New Tag already exists, please re-enter!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NewTagalreadyexists' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_LABEL';
update ld_tranlabel set fieldlabel = 'Tag' where tabid = 6 and Relateid = @blockid and trantable = 'ld_blocks' and languagetype = 'en';
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','yunzhijia_setting','http://51mis.com.cn/forum.php?mod=viewthread&tid=857&fromuid=1','云之家接口设置' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'yunzhijia_setting');
delimiter;

UPDATE ld_field SET bigtype='picklist' WHERE uitype=15;
-- 2020-11-09

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

UPDATE ld_version SET old_version='V8.3.0',current_version='V8.3.0',remark='V8.3.0-20201109',wx_version='V8.2.8';
delimiter;