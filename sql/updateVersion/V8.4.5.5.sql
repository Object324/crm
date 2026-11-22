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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
BEGIN
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;


update ld_field set typeofdata='N~O~20,2' where columnname='total' and tablename='ld_timesheet' and typeofdata='N~O';
update ld_field set typeofdata='N~O~20,2' where columnname='sum_indirect' and tablename='ld_timesheet' and typeofdata='V~O';
update ld_field set typeofdata='N~O~20,2' where columnname='sum_direct' and tablename='ld_timesheet' and typeofdata='V~O';
delimiter;

ALTER TABLE ld_timesheet MODIFY COLUMN total decimal(25,2) NOT NULL DEFAULT '0.00';
ALTER TABLE ld_timesheet MODIFY COLUMN sum_indirect decimal(25,2) NOT NULL DEFAULT '0.00';
ALTER TABLE ld_timesheet MODIFY COLUMN sum_direct decimal(25,2) NOT NULL DEFAULT '0.00';
delimiter;

call AddColumn('ld_customform21','entitytype','varchar','50',NULL);
call AddColumn('ld_customform21','source_list','varchar','100',NULL);
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STATISTICALE','统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='STATISTICALE' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STATISTICALE','Statistical Table','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='STATISTICALE' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_detailtracker_basic` ( 
    `trackid` int(11) NOT NULL auto_increment PRIMARY KEY, 
    `trackid_no` varchar(20) NOT NULL,
    `modulename` Varchar(50) NOT NULL,
	`record` int(19),
	`whodid` int(19),
	`changedon` Datetime,
	`total` decimal(25,6)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_detailtracker_detail` ( 
    `trackid` int(11) NOT NULL,
	`crmid` int(19) NOT NULL,
	`lineitem_id` int(11),
    `prevaluejson` Text,
	`postvaluejson` Text,
	`changetype` varchar(20)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call addtableIndex('ld_detailtracker_basic','detail_tracker_record','record');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','DOCUMENTHEADER','单据表头','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='DOCUMENTHEADER' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','DOCUMENTHEADER','Document header','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='DOCUMENTHEADER' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','VERSION','版本','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='VERSION' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','VERSION','Edition','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='VERSION' and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','addressbook_setting','企业微信通讯录同步设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='addressbook_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','addressbook_setting','Address book Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='addressbook_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select sequence into @sequence from ld_settings_field where blockid = 4 and name = 'channelcode_settings';
update ld_settings_field set sequence = sequence + 10000 where blockid = 4 and sequence > @sequence;
select max(fieldid) + 1 into @max_fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @max_fieldid,4,'addressbook_setting','picklistdependency.png','addressbook_setting','index.php?module=Settings&action=addressbook_setting&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where `name` = 'addressbook_setting');
delimiter;

set @i =0 ;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=4 order by sequence asc;
delimiter;

update ld_settings_field_seq set id = (select max(fieldid) from ld_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','addressbook_sync','通讯录同步','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='addressbook_sync' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','addressbook_sync','Address book Synchronization','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='addressbook_sync' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','receivingeventsettings','接收事件服务器设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='receivingeventsettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','receivingeventsettings','Setting of receiving event server','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='receivingeventsettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Synchronizeaddressbook','同步企业微信通讯录部门和成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Synchronizeaddressbook' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Synchronizeaddressbook','Synchronize enterprise wechat address book departments and members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Synchronizeaddressbook' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AddressbookAgreerule','同步企业微信通讯录组织架构前，您需先同意上述同步规则，否则将无法进行同步操作','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AddressbookAgreerule' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AddressbookAgreerule','Before synchronizing the organizational structure of enterprise wechat address book, you need to agree to the above synchronization rules, otherwise you will not be able to synchronize','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AddressbookAgreerule' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep1','请输入admin账号需要绑定的企业微信通讯录成员姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep1','Please enter the name of the enterprise wechat address book member whose admin account needs to be bound','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep1Msg1','企业微信通讯录成员姓名不存在，请重新输入！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep1Msg1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep1Msg1','The member name of enterprise wechat address book does not exist, please re-enter!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep1Msg1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep1Msg2','CRM系统已存在该成员姓名，不可绑定！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep1Msg2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep1Msg2','The member name already exists in the CRM system and cannot be bound!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep1Msg2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep2','同步企业微信组织架构以“企业微信通讯录”为准，同步规则如下：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep2','The organizational structure of synchronized enterprise wechat is subject to the "enterprise wechat address book", and the synchronization rules are as follows:','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep2Rule1','同步时以企业微信通讯录“姓名”判断新增或更新用户信息;','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Rule1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep2Rule1','When synchronizing, add or update user information according to the "name" of enterprise wechat address book;','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Rule1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep2Rule2','同步企业微信通讯录组织架构中的姓名、手机号、邮箱、部门信息;','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Rule2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep2Rule2','Synchronize the name, mobile phone number, email address and department information in the organizational structure of enterprise wechat address book','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Rule2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep2Rule3','CRM系统中已有的成员和部门信息若是不在企业微信通讯录中，将放在组织架构最下方;','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Rule3' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep2Rule3','If the existing member and department information in the CRM system is not in the enterprise wechat address book, it will be placed at the bottom of the organizational structure','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Rule3' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep2Agree','我已认真阅读并同意上述同步规则','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Agree' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep2Agree','I have carefully read and agree to the above synchronization rules','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep2Agree' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep3','同步企业微信通讯录部门和成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep3' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep3','Synchronize enterprise wechat address book departments and members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep3' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SyncAddressbookStep3Msg1','企业微信没有需要同步的成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep3Msg1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SyncAddressbookStep3Msg1','There are no members to synchronize','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SyncAddressbookStep3Msg1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','FieldDescription','字段说明','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FieldDescription' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','FieldDescription','Field Description','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FieldDescription' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','FieldColor','字段颜色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FieldColor' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','FieldColor','Field Color','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FieldColor' and labeltype='fixedstr');
delimiter;

insert into ld_wx_config (name,description) select 'dial_record','企业微信公费电话拨打记录' from dual where not exists(select 1 from ld_wx_config where name='dial_record');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_dial_record` (
		`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `call_type` varchar(25) DEFAULT NULL COMMENT '通话类型，1-单人通话 2-多人通话',
	  `call_time` datetime DEFAULT NULL COMMENT "拨出时间",
    `total_duration` int(11) DEFAULT 0 COMMENT '总通话时长',
    `caller_wx_userid` varchar(255) DEFAULT NULL COMMENT "主叫用户的userid",
	  `caller_duration` int(11) DEFAULT 0 COMMENT "主叫用户的通话时长",
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_dial_record_details` (
		`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `dialid` varchar(25) DEFAULT NULL COMMENT '通话类型，1-单人通话 2-多人通话',
	  `callee_wx_userid` varchar(255) DEFAULT NULL COMMENT "被叫用户的userid,外部人员为空",
	  `callee_phone` varchar(255) DEFAULT NULL COMMENT "被叫用户的手机号",
	  `callee_duration` int(11) DEFAULT 0 COMMENT "被叫用户的通话时长",
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select usereportid into @usereportid from ld_usereport where name='AttendanceReport';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,Parent_id, sequence, reporttype, pagewidthpercent)
select 'dial_record','公费电话拨打统计表',0,1,0,1,@usereportid,5,51,100 from dual where not exists(select 1 from ld_usereport where name='dial_record');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','dial_record','公费电话拨打统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dial_record' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','dial_record','Public phone records','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dial_record' and labeltype='fixedstr');
delimiter;


select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'caller_name', 1, 1, '主叫姓名','Caller name' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='caller_name');
delimiter;
select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'group', 2, 1, '部门','Department' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='group');
delimiter;
select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'call_type', 3, 1, '通话类型','Call type' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='call_type');
delimiter;
select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'call_time', 4, 1, '拨出时间','Call time' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='call_time');
delimiter;
select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'total_duration', 5, 1, '总通话时长(m)','Total duration' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='total_duration');
delimiter;

select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'caller_duration', 6, 1, '主叫通话时长(m)','Caller duration' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='caller_duration');
delimiter;

select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'callee_name', 7, 1, '被叫姓名','Callee name' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='callee_name');
delimiter;

select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'callee_phone', 8, 1, '被叫手机号','Callee phone' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='callee_phone');
delimiter;

select usereportid into @id from ld_usereport where name='dial_record';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @id, 'callee_duration', 9, 1, '被叫通话时长(m)','Callee duration' from dual
where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='callee_duration');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DialRecordSyncButton','同步公费电话拨打记录','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DialRecordSyncButton' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DialRecordSyncButton','Synchronize public phone call records','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DialRecordSyncButton' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DialRecordSyncMsg1','结束时间不得小于开始时间，开始时间也不得早于当前时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DialRecordSyncMsg1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DialRecordSyncMsg1','The end time must be no later than the start time and the start time must be no earlier than the current time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DialRecordSyncMsg1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DialRecordSyncMsg2','自定义日期时间段最长跨度不得超过60天','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DialRecordSyncMsg2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DialRecordSyncMsg2','The maximum span of a user-defined date period cannot exceed 60 days','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DialRecordSyncMsg2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DialRecordSyncMsg3','请确认Secret等参数是否配置正确','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DialRecordSyncMsg3' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DialRecordSyncMsg3','Check whether parameters such as Secret are correctly configured','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DialRecordSyncMsg3' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:ticket_no:服务单编号:HelpDesk_ticket_no:V',2,1,'ld_troubletickets:ticket_no:服务单编号:HelpDesk_服务单编号:V','ld_troubletickets:ticket_no:服务单编号:HelpDesk_ticket_no:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:ticket_no:服务单编号:HelpDesk_ticket_no:V');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','treestruturesettings','树结构设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='treestruturesettings' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','treestruturesettings','Tree structure settings','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='treestruturesettings' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Enabletreestructureclassification','是否启用树结构分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Enabletreestructureclassification' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Enabletreestructureclassification','Enable tree structure classification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Enabletreestructureclassification' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Treestructuregroupingfield','树结构分组字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Treestructuregroupingfield' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Treestructuregroupingfield','Tree structure grouping field','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Treestructuregroupingfield' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CascadeField','级联字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CascadeField' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CascadeField','Cascade Field','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CascadeField' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','whethertodisplayasatreenode','级联字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='whethertodisplayasatreenode' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','whethertodisplayasatreenode','whether to display as a tree node','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='whethertodisplayasatreenode' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_tree` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(50) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_module_tree_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tree_id` int(11) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_module_tree(module,fieldname)
select 'Products','productcategory' from dual
where not exists(select 1 from ld_module_tree where module = 'Products');
delimiter;
-- 2022-01-02

update ld_field set presence = 0 where tabid =16 and columnname = 'advance_stage';
delimiter;

select tabid into @tabid  from ld_tab where `name` = 'ContactRecords';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'potential_id,potential_id_name','sql','select potentialid,{hrefcolumn} from ld_potential where accountid = ? and deleted = 0 ORDER BY createdtime desc limit 1' from dual
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

update ld_producttoolfield set allowhide = 'yes' where columnname = 'total';
delimiter;
-- 2022-01-05

UPDATE ld_systems_deploy SET deploy_value=CONCAT(UPPER(LEFT(MD5(RAND()),3)),RIGHT(MD5(RAND()),2),UPPER(LEFT(MD5(RAND()),3))) WHERE deploy_type=105 AND (SELECT COUNT(1) FROM ld_users)<2;
UPDATE ld_systems_deploy SET deploy_value=CONCAT(UPPER(LEFT(MD5(RAND()),3)),RIGHT(MD5(RAND()),2),UPPER(LEFT(MD5(RAND()),3))) WHERE deploy_type=105 AND (SELECT COUNT(1) FROM ld_crmentity)<10;

UPDATE ld_field SET displaytype=3 WHERE tabid=2 AND columnname IN ('total','subtotal');

INSERT INTO ld_linkmodulecustom(`name`,zh_label,en_label,url,`status`,scope,entitytype,linkmodule,linkcvid)
SELECT 'ProjectGanttReport','项目甘特图','项目甘特图','gantindex.php','yes','all','custom','Project','0' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_linkmodulecustom WHERE `name`='ProjectGanttReport');

SET @tabid=(SELECT id FROM ld_linkmodulecustom WHERE `name`='ProjectGanttReport' LIMIT 1);
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Project' LIMIT 1);
SET @seq=(SELECT COUNT(1) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
SELECT @parenttabid,@tabid,@seq+1,'ld_linkmodulecustom' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid AND tab_tablename='ld_linkmodulecustom')
	AND @tabid>0
	AND @parenttabid>0;
delimiter;

SET @tabid=48;
SET @relationid=(SELECT MAX(relation_id)+1 FROM ld_relatedlists);
SET @related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomReport');
SET @sequence=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,trade,islistbutton,buttonstatus,dynamicstatus)
SELECT @relationid,@tabid,@related_tabid,'project_ganttview',@sequence+1,'项目甘特图',0,'',1,0,'datacategory_template_url','crmlink',1,0,'','','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`='project_ganttview' AND type='datacategory_template_url' AND related_coltable='crmlink');

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

update ld_field set presence = 0 where tabid =16 and columnname = 'advance_stage';
delimiter;

select tabid into @tabid  from ld_tab where `name` = 'ContactRecords';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'potentialid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'potential_id,potential_id_name','sql','select potentialid,{hrefcolumn} from ld_potential where accountid = ? and deleted = 0 ORDER BY createdtime desc limit 1' from dual
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

update ld_producttoolfield set allowhide = 'yes' where columnname = 'total';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','FieldDescription','字段说明','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FieldDescription' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','FieldDescription','Field Description','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FieldDescription' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','FieldColor','字段颜色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FieldColor' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','FieldColor','Field Color','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FieldColor' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_field','fieldvaluecolor','varchar','20',NULL);
call AddColumn('ld_field','fieldplaceholder','varchar','300',NULL);
call AddColumn('ld_producttoolfield','fieldvaluecolor','varchar','20',NULL);
call AddColumn('ld_producttoolfield','fieldplaceholder','varchar','300',NULL);
call AddColumn('ld_tabdetailfield','fieldvaluecolor','varchar','20',NULL);
call AddColumn('ld_tabdetailfield','fieldplaceholder','varchar','300',NULL);
delimiter;

SET @oprationid = (SELECT actionid from ld_actionmapping where actionname = 'DownloadSelected');
UPDATE ld_profileallpermission AS tmp1
INNER JOIN ld_profileallpermission AS tmp2 ON tmp1.tabid = tmp2.tabid and tmp2.operation = @oprationid
SET tmp1.sequence = tmp1.sequence - 1 WHERE tmp1.sequence > tmp2.sequence;
delimiter;

UPDATE ld_profileallpermission AS tmp1	INNER JOIN 
(SELECT max(sequence) as seq,tabid from ld_profileallpermission where operation <> @oprationid GROUP BY tabid ) AS tmp2 
ON tmp1.tabid = tmp2.tabid and tmp1.operation = @oprationid SET tmp1.sequence = tmp2.seq+1 where tmp1.operation = @oprationid;
delimiter;


update ld_desk set fieldlabel='文字颜色' where languagetype='zh' and labelbol='FieldColor' and Labeltype='fixedstr';
update ld_desk set fieldlabel='填写说明' where languagetype='zh' and labelbol='FieldDescription' and Labeltype='fixedstr';
delimiter;
-- 2022-01-07

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

UPDATE ld_version SET old_version='V8.4.5.5',current_version='V8.4.5.5',remark='V8.4.5.5-20220107',wx_version='V8.4.5.5';
delimiter;