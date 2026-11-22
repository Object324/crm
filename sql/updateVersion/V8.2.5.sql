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

CREATE TABLE if NOT EXISTS `ld_dingtalk_msg_conf` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
    `tabid` smallint(3) DEFAULT NULL COMMENT '表id',
	`modulename` VARCHAR(100) DEFAULT NULL COMMENT '模块名',
	`keywords` TEXT DEFAULT NULL COMMENT '关键字',
    `webhook` TEXT DEFAULT NULL COMMENT '地址',
	`content` TEXT DEFAULT NULL COMMENT '提醒内容',
    `is_enable` VARCHAR(25) DEFAULT 'no' COMMENT '是否启用：no否 yes是',
     `createdby` int(11) DEFAULT 0 COMMENT '创建人',
    `modifiedby` int(11) DEFAULT 0 COMMENT '修改人',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
	PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

update ld_desk set fieldlabel='设置单据提交审批后，自动推送单据内容至钉钉群' where labelbol ='dingtalk_webhook_setting_describe' AND Labeltype='fixedstr' AND languagetype='zh';
update ld_desk set fieldlabel='Set the content of the document to be automatically pushed to the DingTalk group after the document is submitted for approval' where labelbol ='dingtalk_webhook_setting_describe' AND Labeltype='fixedstr' AND languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_keywords','钉钉群消息关键词','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_keywords' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_keywords','Dingtalk group message keywords','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_keywords' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_keywords_not_null','钉钉群消息关键词不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dingtalk_keywords_not_null' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_keywords_not_null',"Dingtalk group message keywords Can't be empty!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dingtalk_keywords_not_null' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_address_not_null','Webhook地址不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dingtalk_address_not_null' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_address_not_null',"Webhook Address Can't be empty!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dingtalk_address_not_null' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_tips1','设定后，只有包含关键词的消息内容才会被正常发送','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_tips1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_tips1','After setting, only messages containing keywords will be sent normally','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_tips1' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_tips2','“货币”类型的字段仅推送大于0的字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_tips2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_tips2','The "currency" field only pushes fields greater than 0','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_tips2' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','reminder_content_settings','提醒内容设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='reminder_content_settings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','reminder_content_settings','The "Reminder content Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='reminder_content_settings' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','add_remind','新增提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='add_remind' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','add_remind','Add Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='add_remind' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','edit_remind','编辑提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='edit_remind' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','edit_remind','Edit Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='edit_remind' and Labeltype='fixedstr' and languagetype='en');
delimiter;


call AddColumn('ld_cloud_users','status','tinyint','2',0);

ALTER TABLE ld_users MODIFY COLUMN groupid TEXT DEFAULT NULL;
delimiter;

UPDATE ld_field set typeofdata ='DT~O' where fieldname='lastcontactdate' and uitype IN (86,70);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddRows','添加行','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='AddRows');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddRows','Add rows','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='AddRows');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DeleteRows','删除行','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='DeleteRows');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DeleteRows','Delete rows','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='DeleteRows');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DragRows','拖动行','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='DragRows');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DragRows','Drag rows','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='DragRows');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CtrlEnterComBox','光标定位在[varfield]中按下Ctrl+Enter键可以更改当前行及之后所有行的[varfield]值','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='CtrlEnterComBox');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CtrlEnterComBox','Press Ctrl+Enter to change the value of the [varfield] for the current row and all subsequent rows','fixedstr' from dual  
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='CtrlEnterComBox');
delimiter;
-- 2020-09-27

update ld_desk set fieldlabel = '设置审批人' where labelbol = 'APPROVERINFO' and Labeltype = 'fixedstr' and languagetype = 'zh';
delimiter;

update ld_desk set fieldlabel = '多人审批方式“或签”（一个审批人通过即可通过审批步骤）' where labelbol = 'MultipleapproversOne' and Labeltype = 'fixedstr' and languagetype = 'zh';
delimiter;

update ld_desk set fieldlabel = '多人审批方式“会签”（一个审批人通过即可通过审批步骤）' where labelbol = 'MultipleCountersignature' and Labeltype = 'fixedstr' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Isitallowedtoaddapproversincurrentstep','本步骤审批时是否允许加签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Isitallowedtoaddapproversincurrentstep' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Isitallowedtoaddapproversincurrentstep','Is it allowed to add approvers in current step','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Isitallowedtoaddapproversincurrentstep' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_approvestep','augmentsinger','varchar','10',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesettheapprovers','通过并增加本步骤审批人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Pleasesettheapprovers' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesettheapprovers','Please set the approvers','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Pleasesettheapprovers' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleasesettheapproversjs','请选择审批人','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Pleasesettheapproversjs' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleasesettheapproversjs','Please set the approvers','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Pleasesettheapproversjs' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_approvelog','augmentsinger','varchar','10',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','augmentsingerapprove','加签审批','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'augmentsingerapprove' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','augmentsingerapprove','Augmentsinger','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'augmentsingerapprove' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','augmentsingercurapprovestep','加签当前审批步骤','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'augmentsingercurapprovestep' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','augmentsingercurapprovestep','Augmentsinger cur approvestep','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'augmentsingercurapprovestep' and labeltype = 'fixedstr');
delimiter;

select max(fieldtypeid) into  @maxfieldtypeid from ld_ws_fieldtype;
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @maxfieldtypeid+1,102,'reference' from dual 
where not EXISTS(select 1 from ld_ws_fieldtype where uitype=102);
delimiter;

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=102;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'SalesOrder' from dual 
where not exists(select 1 from  ld_ws_referencetype where fieldtypeid=@fieldtypeid);
delimiter;
-- 2020-09-28

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

UPDATE ld_version SET old_version='V8.2.5',current_version='V8.2.5',remark='V8.2.5-20200928',wx_version='V8.2.3.2';
delimiter;