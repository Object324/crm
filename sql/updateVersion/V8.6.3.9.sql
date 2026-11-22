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
CREATE PROCEDURE `addtableIndex`(tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50))
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

update ld_desk set fieldlabel = '模块和菜单管理' where labelbol = 'MODULE_MENU_MANAGEMENT' and languagetype = 'zh';
delimiter;

update ld_settings_field set blockid = (select blockid from ld_settings_blocks where `name` = 'LBL_INTERFACE_SETTINGS') where `name` = 'zhiyuan_setting';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENABLEATONE','停用失败，请至少启用一个类别','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENABLEATONE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENABLEATONE',"Disable failure, please enable at least one category",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENABLEATONE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FixedReviewers','固定点评人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'FixedReviewers' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FixedReviewers','Fixed reviewers','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'FixedReviewers' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',' MinCCRange','最小抄送范围','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MinCCRange' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MinCCRange','Minimum CC Range','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'MinCCRange' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OneMemberOneRule','一个成员仅适用于一个规则','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'OneMemberOneRule' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OneMemberOneRule','One member only applies to one rule','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'OneMemberOneRule' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetFixedReviewerTip','固定点评人设置后，员工不可修改点评人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetFixedReviewerTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetFixedReviewerTip','After the fixed reviewer is set, the employee cannot modify the reviewer','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetFixedReviewerTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetFixedReviewer','设置固定点评人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetFixedReviewer' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetFixedReviewer','Set fixed reviewer','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetFixedReviewer' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetMinCCRange','设置最小抄送范围','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetMinCCRange' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetMinCCRange','Set minimum CC range','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetMinCCRange' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkReportSelectType','选择类型','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WorkReportSelectType' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkReportSelectType','Select type','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'WorkReportSelectType' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetType','设置类型','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetType' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetType','Set type','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetType' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReviewerAndCCRange','点评人与抄送范围','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReviewerAndCCRange' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReviewerAndCCRange','Reviewer and CC range','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReviewerAndCCRange' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetMinCCRangeTip','员工在选择抄送范围时，最小抄送范围不可删除，但可继续添加','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetMinCCRangeTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetMinCCRangeTip','When employees select the CC range, the minimum CC range cannot be deleted, but can continue to add','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetMinCCRangeTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReuserType','点评人类型','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReuserType' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReuserType','Reviewer type','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReuserType' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CCuserType','抄送范围类型','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CCuserType' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CCuserType','Reviewer type','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CCuserType' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetSubmissionDeadlineReminderRule','设置提交期限提醒规则','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetSubmissionDeadlineReminderRule' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetSubmissionDeadlineReminderRule','Set the submission deadline reminder rule','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SetSubmissionDeadlineReminderRule' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SubmissionDeadline','提交期限截止时间','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SubmissionDeadline' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SubmissionDeadline','Submission deadline','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SubmissionDeadline' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReminderFrequency','提醒次数','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReminderFrequency' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReminderFrequency','Reminder frequency','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReminderFrequency' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HoursAgo','小时前','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'HoursAgo' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HoursAgo','hour(s) ago','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'HoursAgo' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIMESNUM','次','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'TIMESNUM' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIMESNUM','times','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'TIMESNUM' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VARTIMES','第{Var}次','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'VARTIMES' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VARTIMES','Time {Var}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'VARTIMES' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SameDay','当天','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SameDay' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SameDay','Same day','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SameDay' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReuserValueTip','点评人可设为空，为空时员工可修改点评人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReuserValueTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReuserValueTip','The reviewer can be set to empty, and the employee can modify the reviewer when it is empty','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ReuserValueTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UserRangeCanNotBeEmpty','适用范围不能为空!','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UserRangeCanNotBeEmpty' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UserRangeCanNotBeEmpty','User range can not be empty!','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UserRangeCanNotBeEmpty' and languagetype='en' and labeltype = 'jspop');
delimiter;

set @id = (select max(id) from ld_workreport_field)+1;
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultheight,is_mandatory,is_activate,sequence,tablename,allow_edit,relatedmodulefield)
select @id,'workexperience','','workreport',4,'50',0,0,1,'ld_workreport','yes','no' from dual
where not exists(select 1 from ld_workreport_field where `name`='workexperience' and type=4);
delimiter;
set @id = (select max(id) from ld_workreport_field)+1;
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultheight,is_mandatory,is_activate,sequence,tablename,allow_edit,relatedmodulefield)
select @id,'workexperience','','workreport',5,'50',0,0,1,'ld_workreport','yes','no' from dual
where not exists(select 1 from ld_workreport_field where `name`='workexperience' and type=5);
delimiter;

CREATE TABLE if not EXISTS `ld_workreport_rulesettings` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `type` varchar(50) DEFAULT NULL COMMENT '日志类型',
    `sequence` int(19) DEFAULT 1 COMMENT '优先级',
    `status` varchar(10) DEFAULT 'no' COMMENT '启用规则',
    `name` varchar(255) DEFAULT NULL COMMENT '规则名',
    `rule_range` varchar(50) DEFAULT NULL COMMENT '规则适用范围',
    `rule_value` text DEFAULT NULL COMMENT '规则使用范围值',
    `reuser_presence` varchar(10) DEFAULT 'no' COMMENT '启用固定点评人',
    `reuser_type` varchar(50) DEFAULT NULL COMMENT '固定点评人类型',
    `reuser_value` text DEFAULT NULL COMMENT '固定点评人值',
    `ccuser_presence` varchar(10) DEFAULT 'no' COMMENT '启用最小抄送范围',
    `ccuser_type` varchar(255) DEFAULT NULL COMMENT '最小抄送范围类型',
    `ccuser_value` varchar(100) DEFAULT NULL COMMENT '最小抄送范围值',
    `deadline_date` varchar(50) DEFAULT NULL COMMENT '提醒截止日期',
    `remind_time` time DEFAULT NULL COMMENT '提醒时间',
    `remind_num` int(19) DEFAULT NULL COMMENT '提醒次数',
    `first_value` int(19) DEFAULT NULL COMMENT '第一次提醒提前值',
    `second_value` int(19) DEFAULT NULL COMMENT '第二次提醒提前值',
    `third_value` int(19) DEFAULT NULL COMMENT '第三次提醒提前值',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

set @day_remind_time = (select case when cooperativeworkdaily = "不提醒" or cooperativeworkdaily = "Don't remind"
	then "18:00:00" else cooperativeworkdaily end as cooperativeworkdaily from ld_workremindset LIMIT 1);
set @day_remind_num = (select case when cooperativeworkdaily = "不提醒" or cooperativeworkdaily = "Don't remind"
	then 0 else 1 end as remind_num from ld_workremindset LIMIT 1 );
set @day_first_value = (case when @day_remind_num = 0 then null else 1 end);
insert into ld_workreport_rulesettings(type,sequence,`status`,`name`,rule_range,rule_value,reuser_presence,reuser_type,ccuser_presence,ccuser_type,
                                       deadline_date,remind_time,remind_num,`first_value`)
select 'day',1,'yes','默认规则','all','-1','no','user','no','user','today',@day_remind_time,@day_remind_num,@day_first_value from dual
where not exists(select 1 from ld_workreport_rulesettings where type='day');
delimiter;

set @week_deadline_date = (select case when cooperativeworkweek = "no" or cooperativeworkweek = NULL
	then 7 else cooperativeworkweek end as cooperativeworkweek from ld_workremindset LIMIT 1);
set @week_remind_time = '09:00:00';
set @week_remind_num = (select case when cooperativeworkweek = "no" or cooperativeworkweek = NULL
	then 0 else 2 end as remind_num from ld_workremindset LIMIT 1 );
set @week_first_value = (case when @day_remind_num = 0 then null else 2 end);
set @week_second_value = (case when @day_remind_num = 0 then null else 1 end);
insert into ld_workreport_rulesettings(type,sequence,`status`,`name`,rule_range,rule_value,reuser_presence,reuser_type,ccuser_presence,ccuser_type,
                                       deadline_date,remind_time,remind_num,`first_value`,second_value)
select 'week',1,'yes','默认规则','all','-1','no','user','no','user',@week_deadline_date,@week_remind_time,@week_remind_num,@week_first_value,@week_second_value from dual
where not exists(select 1 from ld_workreport_rulesettings where type='week');
delimiter;

set @month_deadline_date = (select case when cooperativeworkmonth = "no" or cooperativeworkmonth = NULL
	then 40 else cooperativeworkmonth end as cooperativeworkmonth from ld_workremindset LIMIT 1);
set @month_remind_time = '09:00:00';
set @month_remind_num = (select case when cooperativeworkmonth = "no" or cooperativeworkmonth = NULL
	then 0 else 3 end as remind_num from ld_workremindset LIMIT 1 );
set @month_first_value = (case when @day_remind_num = 0 then null else 3 end);
set @month_second_value = (case when @day_remind_num = 0 then null else 2 end);
set @month_third_value = (case when @day_remind_num = 0 then null else 1 end);
insert into ld_workreport_rulesettings(type,sequence,`status`,`name`,rule_range,rule_value,reuser_presence,reuser_type,ccuser_presence,ccuser_type,
                                       deadline_date,remind_time,remind_num,`first_value`,second_value,third_value)
select 'month',1,'yes','默认规则','all','-1','no','user','no','user',@month_deadline_date,@month_remind_time,@month_remind_num,@month_first_value,@month_second_value,@month_third_value from dual
where not exists(select 1 from ld_workreport_rulesettings where type='month');
delimiter;

delete from ld_settings_field where `name`='LBL_cooperative_REMIND_SET' and blockid = 1 and description='LBL_cooperative_REMIND_SET_DESCRIPTION';
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_reminder`(
    tmp_reporttype VARCHAR(19),
    tmp_userid INT(11),
    tmp_eventdate datetime,
    tmp_nowtime datetime
        )
BEGIN
	DECLARE tmp_rule_range VARCHAR(19) DEFAULT '';
	DECLARE tmp_rule_value VARCHAR(19) DEFAULT '';
	DECLARE tmp_remind_num INT(11) DEFAULT '';
	DECLARE tmp_deadline_date VARCHAR(19) DEFAULT '';
	DECLARE tmp_remind_time time DEFAULT '';
	DECLARE tmp_first_value INT(11) DEFAULT '';
	DECLARE tmp_second_value INT(11) DEFAULT '';
	DECLARE tmp_third_value INT(11) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
SELECT rule_range,rule_value,remind_num,deadline_date,remind_time,`first_value`,second_value,third_value
FROM ld_workreport_rulesettings WHERE type = tmp_reporttype AND `status` = 'yes' and remind_num >0 ORDER BY sequence;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;

	SET @event_minutes = '10';
	

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_rule_range,tmp_rule_value,tmp_remind_num,tmp_deadline_date,tmp_remind_time,tmp_first_value,tmp_second_value,tmp_third_value;
WHILE(tmp_userid IS NOT NULL) DO
			IF tmp_rule_range = 'all' THEN SET @remind_status='yes';
			ELSEIF tmp_rule_range = 'user' AND FIND_IN_SET(tmp_userid,tmp_rule_value)
				THEN SET @remind_status='yes';
			ELSEIF tmp_rule_range = 'group' AND
								tmp_userid IN (SELECT GROUP_CONCAT(userid SEPARATOR ',') AS userid_str FROM ld_users2group WHERE groupid IN (tmp_rule_value))
								THEN SET @remind_status='yes';
			ELSEIF tmp_rule_range = 'role' AND EXISTS(SELECT 1 from ld_users where id=tmp_userid and profileid in (tmp_rule_value))
								THEN SET @remind_status='yes';
ELSE SET @remind_status='no';
END IF;

			IF @remind_status = 'yes' AND tmp_remind_num > 0 THEN
					IF tmp_remind_num > 0 THEN
						-- 第一次提醒提前时间范围
						SET @first_remind_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_SUB(tmp_remind_time, INTERVAL (60 * tmp_first_value) MINUTE)
									ELSE tmp_remind_time END;
						SET @first_end_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_ADD(tmp_remind_time, INTERVAL (60 * tmp_first_value + @event_minutes + 2) MINUTE)
									ELSE DATE_ADD(tmp_remind_time, INTERVAL @event_minutes + 2 MINUTE) END;
						SET @deadline_date = CONVERT(tmp_deadline_date, DECIMAL);
						-- 	第一次提醒日期/星期几
						SET @first_date = CASE
									WHEN tmp_reporttype = 'day' THEN CURDATE()
									WHEN tmp_reporttype = 'week' THEN CAST(tmp_deadline_date AS DECIMAL) - CAST(tmp_first_value AS DECIMAL)
									WHEN tmp_reporttype = 'month' THEN
											CASE
											WHEN @deadline_date >=20 AND @deadline_date <=28
												THEN DATE_SUB(STR_TO_DATE(CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m'), '-', @deadline_date), '%Y-%m-%d'),INTERVAL tmp_first_value DAY)
											WHEN @deadline_date = 40
												THEN DATE_SUB(LAST_DAY(CURDATE()),INTERVAL tmp_first_value DAY)
											WHEN @deadline_date >= 1 AND @deadline_date <= 5
												THEN DATE_SUB(DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @deadline_date DAY),INTERVAL tmp_first_value DAY)
END
END;
						-- 提醒处理
							IF (tmp_reporttype = 'day' OR tmp_reporttype = 'month') THEN
								SET @first_remind_datetime = STR_TO_DATE(CONCAT(@first_date, ' ', @first_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @first_end_datetime = STR_TO_DATE(CONCAT(@first_date, ' ', @first_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @first_remind_datetime AND tmp_nowtime >= @first_remind_datetime AND tmp_nowtime < @first_end_datetime
									THEN
										IF tmp_reporttype = 'day' THEN SET @content = CONCAT('日志提交提醒：您该提交日志啦，还有',tmp_first_value,'个小时就到提交期限哦');
										ELSEIF tmp_reporttype = 'month' THEN SET @content = CONCAT('月计划提交提醒：您该提交月计划啦，还有',tmp_first_value,'天就到提交期限哦')	;
END IF;
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
							ELSEIF tmp_reporttype = 'week' AND DAYOFWEEK(CURDATE()) = @first_date THEN
								SET @first_remind_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @first_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @first_end_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @first_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @first_remind_datetime AND tmp_nowtime >= @first_remind_datetime AND tmp_nowtime< @first_end_datetime
									THEN SET @content = CONCAT('周计划提交提醒：您该提交周计划啦，还有',tmp_first_value,'天就到提交期限哦');
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
END IF;
END IF;

					IF tmp_remind_num > 1 THEN
						-- 第一次提醒提前时间范围
						SET @second_remind_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_SUB(tmp_remind_time, INTERVAL (60 * tmp_second_value) MINUTE)
									ELSE tmp_remind_time END;
						SET @second_end_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_ADD(tmp_remind_time, INTERVAL (60 * tmp_second_value +  @event_minutes + 2) MINUTE)
									ELSE DATE_ADD(tmp_remind_time, INTERVAL @event_minutes + 2 MINUTE) END;
						SET @deadline_date = CONVERT(tmp_deadline_date, DECIMAL);
						-- 	第一次提醒日期/星期几
						SET @second_date = CASE
									WHEN tmp_reporttype = 'day' THEN CURDATE()
									WHEN tmp_reporttype = 'week' THEN CAST(tmp_deadline_date AS DECIMAL) - CAST(tmp_second_value AS DECIMAL)
									WHEN tmp_reporttype = 'month' THEN
											CASE
											WHEN @deadline_date >=20 AND @deadline_date <=28
												THEN DATE_SUB(STR_TO_DATE(CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m'), '-', @deadline_date), '%Y-%m-%d'),INTERVAL tmp_second_value DAY)
											WHEN @deadline_date = 40
												THEN DATE_SUB(LAST_DAY(CURDATE()),INTERVAL tmp_second_value DAY)
											WHEN @deadline_date >= 1 AND @deadline_date <= 5
												THEN DATE_SUB(DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @deadline_date DAY),INTERVAL tmp_second_value DAY)
END
END;
						-- 提醒处理
						IF (tmp_reporttype = 'day' OR tmp_reporttype = 'month') THEN
								SET @second_remind_datetime = STR_TO_DATE(CONCAT(@second_date, ' ', @second_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @second_end_datetime = STR_TO_DATE(CONCAT(@second_date, ' ', @second_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @second_remind_datetime AND tmp_nowtime >= @second_remind_datetime AND tmp_nowtime < @second_end_datetime
									THEN
										IF tmp_reporttype = 'day' THEN SET @content = CONCAT('日志提交提醒：您该提交日志啦，还有',tmp_second_value,'个小时就到提交期限哦');
										ELSEIF tmp_reporttype = 'month' THEN SET @content = CONCAT('月计划提交提醒：您该提交月计划啦，还有',tmp_second_value,'天就到提交期限哦')	;
END IF;
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
							ELSEIF tmp_reporttype = 'week' AND DAYOFWEEK(CURDATE()) = @second_date THEN
								SET @second_remind_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @second_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @second_end_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @second_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @second_remind_datetime AND tmp_nowtime >= @second_remind_datetime AND tmp_nowtime< @second_end_datetime
									THEN SET @content = CONCAT('周计划提交提醒：您该提交周计划啦，还有',tmp_second_value,'天就到提交期限哦');
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
END IF;

END IF;

					IF tmp_remind_num > 2 THEN
						-- 第一次提醒提前时间范围
						SET @third_remind_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_SUB(tmp_remind_time, INTERVAL (60 * tmp_third_value ) MINUTE)
									ELSE tmp_remind_time END;
						SET @third_end_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_ADD(tmp_remind_time, INTERVAL (60 * tmp_third_value +  @event_minutes + 2 ) MINUTE)
									ELSE DATE_ADD(tmp_remind_time, INTERVAL @event_minutes + 2 MINUTE) END;
						SET @deadline_date = CONVERT(tmp_deadline_date, DECIMAL);
						-- 	第一次提醒日期/星期几
						SET @third_date = CASE
									WHEN tmp_reporttype = 'day' THEN CURDATE()
									WHEN tmp_reporttype = 'week' THEN CAST(tmp_deadline_date AS DECIMAL) - CAST(tmp_third_value AS DECIMAL)
									WHEN tmp_reporttype = 'month' THEN
											CASE
											WHEN @deadline_date >=20 AND @deadline_date <=28
												THEN DATE_SUB(STR_TO_DATE(CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m'), '-', @deadline_date), '%Y-%m-%d'),INTERVAL tmp_third_value DAY)
											WHEN @deadline_date = 40
												THEN DATE_SUB(LAST_DAY(CURDATE()),INTERVAL tmp_third_value DAY)
											WHEN @deadline_date >= 1 AND @deadline_date <= 5
												THEN DATE_SUB(DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @deadline_date DAY),INTERVAL tmp_third_value DAY)
END
END;
						-- 提醒处理
						IF (tmp_reporttype = 'day' OR tmp_reporttype = 'month') THEN
								SET @third_remind_datetime = STR_TO_DATE(CONCAT(@third_date, ' ', @third_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @third_end_datetime = STR_TO_DATE(CONCAT(@third_date, ' ', @third_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @third_remind_datetime AND tmp_nowtime >= @third_remind_datetime AND tmp_nowtime < @third_end_datetime
									THEN
										IF tmp_reporttype = 'day' THEN SET @content = CONCAT('日志提交提醒：您该提交日志啦，还有',tmp_third_value,'个小时就到提交期限哦');
										ELSEIF tmp_reporttype = 'month' THEN SET @content = CONCAT('月计划提交提醒：您该提交月计划啦，还有',tmp_third_value,'天就到提交期限哦')	;
END IF;
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
							ELSEIF tmp_reporttype = 'week' AND DAYOFWEEK(CURDATE()) = @third_date THEN
								SET @third_remind_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @third_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @third_end_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @third_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @third_remind_datetime AND tmp_nowtime >= @third_remind_datetime AND tmp_nowtime< @third_end_datetime
									THEN SET @content = CONCAT('周计划提交提醒：您该提交周计划啦，还有',tmp_third_value,'天就到提交期限哦');
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
END IF;

END IF;

					SET tmp_userid = NULL;
END IF;

FETCH MYCUSOR INTO tmp_rule_range,tmp_rule_value,tmp_remind_num,tmp_deadline_date,tmp_remind_time,tmp_first_value,tmp_second_value,tmp_third_value;
END WHILE ;
CLOSE MYCUSOR;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_reminder_exec`(
    tmp_reporttype VARCHAR(19)
)
BEGIN
	DECLARE tmp_userid INT DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR
SELECT DISTINCT a.id FROM ld_users a
                              LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
                              LEFT JOIN ld_tab d ON d.tabid=c.tabid
WHERE (d.`name`='CooperativeWork' AND permissions=0 AND d.presence in(0,2) AND a.`status`='Active' )
   OR (a.is_admin='on' AND a.`status`='Active');
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;

	SET @eventdatetime = (SELECT eventdate from ld_sys_event where type = CONCAT('task_cooperativework',tmp_reporttype,'_eventreminder'));
	SET @nowdatetime = NOW();
	SET @daytime = DAY(@nowdatetime);

	IF NOT EXISTS (SELECT 1 FROM ld_module_setting_byuser WHERE modulename = 'WorkTemplateRule' AND label = tmp_reporttype AND content = 'no') AND
		 EXISTS (SELECT 1 FROM ld_workreport_rulesettings WHERE type = tmp_reporttype AND `status` = 'yes' LIMIT 1 ) THEN
				OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_userid;
WHILE(tmp_userid IS NOT NULL) DO
					-- 是否已写日周月
					SET @remind_status = CASE
							WHEN tmp_reporttype = 'day'
									 AND NOT EXISTS(SELECT 1 FROM ld_workreport WHERE  DATE_FORMAT(createdtime,"%Y-%m-%d")=CURDATE() AND smcreatorid=tmp_userid and type=1)
							THEN 'yes'
							WHEN tmp_reporttype = 'week'
									 AND NOT EXISTS(SELECT 1 FROM  ld_workreport where createdtime BETWEEN date_sub(curdate(),INTERVAL WEEKDAY(curdate()) + 0 DAY)
									 AND date_sub(curdate(),INTERVAL WEEKDAY(curdate()) - 6 DAY) AND type=2 AND smcreatorid=tmp_userid)
							THEN 'yes'
							WHEN tmp_reporttype = 'month' AND @daytime <= 5 AND @daytime >= 20
									 AND NOT EXISTS(SELECT 1 FROM ld_workreport WHERE DATE_FORMAT(createdtime,"%Y-%m")=DATE_FORMAT(CURDATE(),"%Y-%m")  AND smcreatorid=tmp_userid and type=3)
							THEN 'yes'
							ELSE 'no' END;

					IF @remind_status = 'yes' THEN
						CALL task_cooperativework_reminder(tmp_reporttype,tmp_userid,@eventdatetime,@nowdatetime);
END IF;
FETCH MYCUSOR INTO tmp_userid;
END WHILE;
CLOSE MYCUSOR;
END IF;
UPDATE ld_sys_event set eventdate = NOW() where type = CONCAT('task_cooperativework',tmp_reporttype,'_eventreminder');
end ||
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkdaily_eventreminder`;
DROP EVENT IF EXISTS `task_cooperativeworkday_eventreminder`;
CREATE EVENT `task_cooperativeworkday_eventreminder` ON SCHEDULE EVERY 10 MINUTE STARTS '2024-06-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_reminder_exec('day');
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkweek_eventreminder`;
CREATE EVENT `task_cooperativeworkweek_eventreminder` ON SCHEDULE EVERY 10 MINUTE STARTS '2024-06-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_reminder_exec('week');
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkmonth_eventreminder`;
CREATE EVENT `task_cooperativeworkmonth_eventreminder` ON SCHEDULE EVERY 10 MINUTE STARTS '2024-06-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_reminder_exec('month');
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder`;
DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder`;
DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder`;
DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder_exec`;
DROP PROCEDURE IF EXISTS `task_task_cooperativeworkdaily_eventreminder`;

delete from ld_sys_event where `type` = 'task_cooperativeworkdaily_eventreminder';
delete from ld_sys_event where `type` = 'task_cooperativeworkweek_eventreminder';
delete from ld_sys_event where `type` = 'task_cooperativeworkmonth_eventreminder';
insert into ld_sys_event(eventdate,type)
select '2024-06-01 00:00:00','task_cooperativeworkday_eventreminder' from DUAL
where not exists(select 1 from ld_sys_event where type = 'task_cooperativeworkday_eventreminder');
insert into ld_sys_event(eventdate,type)
select '2024-06-01 00:00:00','task_cooperativeworkweek_eventreminder' from DUAL
where not exists(select 1 from ld_sys_event where type = 'task_cooperativeworkweek_eventreminder');
insert into ld_sys_event(eventdate,type)
select '2024-06-01 00:00:00','task_cooperativeworkmonth_eventreminder' from DUAL
where not exists(select 1 from ld_sys_event where type = 'task_cooperativeworkmonth_eventreminder');
delimiter;

UPDATE ld_producttoolfield set bigtype='textarea' WHERE `uitype` = 21 AND bigtype = 'text' AND fieldid <> 0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TaskDescription','任务描述','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TaskDescription' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TaskDescription','Task Description','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TaskDescription' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddTask','新增任务','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AddTask' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddTask','Add task','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AddTask' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FieldTasks','字段任务','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FieldTasks' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FieldTasks','Field tasks','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='FieldTasks' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FieldTasks','字段任务','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FieldTasks' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FieldTasks','Field tasks','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FieldTasks' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateRecord','创建单据','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CreateRecord' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateRecord','Create record','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CreateRecord' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectType','选项型','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SelectType' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectType','select type','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SelectType' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TickSelection','勾选型','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TickSelection' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TickSelection','Tick selection','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TickSelection' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CheckBox','复选框','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CheckBox' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CheckBox','check box','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CheckBox' and labeltype='jspop' and languagetype='en');
delimiter;

call AddColumn('ld_advancepicklisttask','task_sequence','smallint','4','');
delimiter;

UPDATE ld_advancepicklisttask SET task_sequence = 
	CASE 
		WHEN type = 'field' THEN 0
		WHEN type = 'module' THEN 1
		WHEN type = 'select' THEN 2
		WHEN type = 'checkbox' THEN 3
	END
WHERE task_sequence is NULL;
delimiter;

call AddColumn('ld_advancepicklist','taskdescription','text','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectField','选择字段','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SelectField' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectField','Select field','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SelectField' and languagetype='en' and labeltype = 'jspop');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FINDSETTINGS','查找设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'FINDSETTINGS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FINDSETTINGS','Find Settings','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'FINDSETTINGS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;


SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label='LBI_FUNCTION_SETTINGS';
SELECT max(sequence)INTO @sequence from ld_settings_field WHERE blockid=@blockid;
select id into @fieldid from  ld_settings_field_seq ;
update ld_settings_field_seq set id=id+1;
insert into ld_settings_field(fieldid,blockid,NAME,iconpath,description,linkto,sequence,active)
select @fieldid+1, @blockid,'TRACKPOSITONINGGROUP','ico-roles.png','DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS',
'index.php?module=Settings&action=listtracks&parenttab=Settings&blockidsetting=2&fieldidsetting=2',@sequence+1,0
from dual where not EXISTS(select 1 from ld_settings_field  where blockid = @blockid and `name` ='TRACKPOSITONINGGROUP');
delimiter;
 delete from ld_trackpostion where  not exists (select * from information_schema.`TABLES` where  TABLE_SCHEMA=DATABASE() and  TABLE_NAME='ld_tracklocation');
delimiter;
CREATE TABLE if not exists  `ld_tracklocation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `jingdu` decimal(25,10) DEFAULT NULL,
  `weidu` decimal(25,10) DEFAULT NULL,
  `userid` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `address` text,
  `mobiletracktime` datetime DEFAULT NULL,
  `trackpositionid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_location_userid` (`userid`,`createdtime`) USING BTREE,
  KEY `idx_location_createdtime` (`createdtime`)
) ENGINE=InnoDB;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkdDay','工作日','fixedstr' from dual
where not  exists(select 1 from ld_desk where  labelbol='WorkDay' and  languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkdDay','Weekdays','fixedstr' from dual
where not  exists(select 1 from ld_desk where   labelbol='WorkDay' and   languagetype='en' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LocationFrequency','定位频率','fixedstr' from dual
where not  exists(select 1 from ld_desk where   labelbol='LocationFrequency' and   languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LocationFrequency','Positioning frequency','fixedstr' from dual
where not  exists(select 1 from ld_desk where labelbol='LocationFrequency' and  languagetype='en' and labeltype='fixedstr');
delimiter;
call AddColumn('ld_trackpostion','frequency','mediumint','9','3');
 delimiter;
call AddColumn('ld_trackpostion','cycle','varchar','25','3');
 delimiter;
 select  max(tabid) into @maxtabid from ld_tab;
insert into ld_tab(tabid,`name`,presence,tablabel,mobilepresence)
select @maxtabid+1,'TrackLocationMap',0,'TrackLocationMap','weixin'
from dual where not exists(select 1 from ld_tab where `name`='TrackLocationMap');
delimiter;

select tabid into @tabid from ld_tab where `name`='TrackLocationMap';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid ,'轨迹定位图' from dual
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_tab' and tabid=@tabid and relateid=@tabid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid ,'Trajectory localization map' from dual
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_tab' and tabid=@tabid and relateid=@tabid);
delimiter;

select ld_parenttabrel.parenttabid into @parenttabid from ld_parenttabrel
inner join ld_tab on ld_tab.tabid=ld_parenttabrel.tabid  and tab_tablename='ld_tab'
inner join ld_parenttab on ld_parenttab.parenttabid=ld_parenttabrel.parenttabid
and ld_parenttab.visible=0
where ld_tab.name='chinamap'  ORDER BY ld_parenttab.sequence asc limit 1;
select tabid into @chinamaptabid from ld_tab where name='chinamap';
select tabid into @tracklocatiomaptabid from ld_tab where name='tracklocationmap';

select sequence into @sequence from ld_parenttabrel where parenttabid=@parenttabid and tabid=@chinamaptabid ;

update ld_parenttabrel set sequence=sequence+1 where parenttabid=@parenttabid and tabid=@chinamaptabid   and sequence> @sequence and  ifnull(@tracklocatiomaptabid,0)>0;
insert into ld_parenttabrel(parenttabid ,tabid, tab_tablename,sequence)
select @parenttabid,@tracklocatiomaptabid,'ld_tab',@sequence+1 from dual
where not exists(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tracklocatiomaptabid);
delimiter;
select ld_appparenttab.blockid into @parenttabid from ld_appparenttabrel
inner join ld_tab on ld_tab.tabid=ld_appparenttabrel.tabid  and tab_tablename='ld_tab'
inner join ld_appparenttab on ld_appparenttab.blockid=ld_appparenttabrel.blockid
and ld_appparenttab.presence=0
where ld_tab.name='chinamap'  ORDER BY ld_appparenttab.sequence asc limit 1;

select tabid into @chinamaptabid from ld_tab where name='chinamap';
select tabid into @tracklocatiomaptabid from ld_tab where name='tracklocationmap';


select sequence into @sequence from ld_appparenttabrel where blockid=@parenttabid and tabid=@chinamaptabid ;

update ld_appparenttabrel set sequence=sequence+1 where blockid=@parenttabid and tabid=@chinamaptabid   and sequence> @sequence and
 ifnull(@tracklocatiomaptabid,0)>0;
insert into ld_appparenttabrel(blockid ,tabid, tab_tablename)
select @parenttabid,@tracklocatiomaptabid,'ld_tab' from dual
where not exists(select 1 from ld_appparenttabrel where blockid=@parenttabid and tabid=@tracklocatiomaptabid);
delimiter;

select tabid into @tracklocatiomaptabid from ld_tab where name='tracklocationmap';
INSERT into ld_profileallpermission(tabid,operation,sequence)
SELECT @tracklocatiomaptabid,3,1 from dual where not EXISTS(SELECT 1 from ld_profileallpermission where tabid = @tracklocatiomaptabid and operation = 3);

set @profileid = 1;
INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid,@tracklocatiomaptabid,3,0,1 from dual
where not EXISTS(SELECT 1 from ld_profile2standardpermissions where profileid = @profileid and tabid = @tracklocatiomaptabid and operation = 3);
delimiter;

set @map_sequence = (SELECT tabsequence from ld_tab where `name` = 'ChinaMap');
set @locate_sequence = (SELECT tabsequence from ld_tab where `name` = 'TrackLocationMap');
UPDATE ld_tab set tabsequence = tabsequence+1 where tabsequence > @map_sequence and IFNULL(@locate_sequence,0) < @map_sequence;
UPDATE ld_tab set tabsequence = @map_sequence+1 where `name` = 'TrackLocationMap' and IFNULL(@locate_sequence,0) < @map_sequence;
delimiter;

SET @labelbol = 'DELETIONNOPOSITIONING';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'删除后，适用范围内的成员将不再启用轨迹定位功能，是否继续？',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After deletion, members within the scope of application will no longer be able to enable trajectory positioning function. Do you want to continue?',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'THEDAYBEFORE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'前一天',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The day before',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'THEDAYAFTER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'后一天',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The day after',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_relatedlists SET related_coltable=REPLACE(related_coltable,'CustomForm','customform');
UPDATE ld_relatedlists SET `name`=label WHERE label LIKE 'CustomForm%' AND `name`=1;
delimiter;

CALL AddColumn('ld_option_module','unallowrepeat','varchar','20','no');
update ld_option_module set unallowrepeat = 'no' where unallowrepeat is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnallowRepeatLabelWithDetail','选择源单界面，相同源单已选过的产品分录不允许重复选择','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithDetail' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnallowRepeatLabelWithDetail','Select source interface,duplicate selection is not allowed for product entries that have already been selected for the same source','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithDetail' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnallowRepeatLabelWithNoDetail','选择源单界面，相同源单已选过的整单不允许重复选择','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithNoDetail' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnallowRepeatLabelWithNoDetail','Select source interface, duplicate selection is not allowed for entire orders that have already been selected for the same source','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithNoDetail' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnallowRepeatLabelWithDetail','选择源单界面，相同源单已选过的产品分录不允许重复选择','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithDetail' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnallowRepeatLabelWithDetail','Select source interface,duplicate selection is not allowed for product entries that have already been selected for the same source','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithDetail' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnallowRepeatLabelWithNoDetail','选择源单界面，相同源单已选过的整单不允许重复选择','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithNoDetail' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnallowRepeatLabelWithNoDetail','Select source interface, duplicate selection is not allowed for entire orders that have already been selected for the same source','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatLabelWithNoDetail' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnallowRepeatTip','针对同一条单据','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnallowRepeatTip','For the same document','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'UnallowRepeatTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_bireportscreen','modifiedby','int',11,0);
UPDATE ld_bireportscreen SET modifiedby = smcreatorid WHERE modifiedby IS NULL;
call AddColumn('ld_bireportscreen','modifiedtime','datetime','',0);
UPDATE ld_bireportscreen SET modifiedtime = createdtime WHERE modifiedtime IS NULL;
delimiter;

UPDATE ld_bireportscreen SET scope = 'all' WHERE project_id = 'ldcrm_default_1' AND scope IS NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commongroup','常用分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='commongroup' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commongroup','Common Group','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='commongroup' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ungrouped','未分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ungrouped' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ungrouped','Ungrouped','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ungrouped' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deletegroup','删除‘组名’，删除后无法恢复','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='deletegroup' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deletegroup','Delete ‘group name’, can‘t recover after deletion','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='deletegroup' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Blockingdeletionofgroups','请先移除分组中所有的分类，再进行删除操作','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Blockingdeletionofgroups' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Blockingdeletionofgroups','Please remove all the categories in the group before deleting.','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Blockingdeletionofgroups' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OPERATION','操作','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OPERATION' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OPERATION','Operation','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OPERATION' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Subgroups','所属分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Subgroups' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Subgroups','Subgroups','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Subgroups' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Collectionsincommonuse','收藏常用','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Collectionsincommonuse' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Collectionsincommonuse','Collections in common use','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Collectionsincommonuse' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','management','管理','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='management' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','management','management','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='management' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Searchforgroupsorcategories','搜索分组或分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Searchforgroupsorcategories' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Searchforgroupsorcategories','Search for groups or categories','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Searchforgroupsorcategories' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CancelFavorites','取消收藏','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CancelFavorites' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CancelFavorites','Cancel Favorites','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CancelFavorites' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MANAGEMENTGROUPING','管理分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MANAGEMENTGROUPING' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MANAGEMENTGROUPING','Management Grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MANAGEMENTGROUPING' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWGROUPING','新建分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWGROUPING' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWGROUPING','New Grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWGROUPING' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POPUPGROUPNAME','分组名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='POPUPGROUPNAME' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POPUPGROUPNAME','Group Name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='POPUPGROUPNAME' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOGrouping','暂无任何分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOGrouping','There are no subgroups','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWCATEGORIESTIPS','新建的分类需要被授权至少一个分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWCATEGORIESTIPS' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWCATEGORIESTIPS','New categories need to be authorized for at least one grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NEWCATEGORIESTIPS' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOGrouping','暂无任何分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOGrouping','There are no subgroups','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOGrouping' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPNAMENOTEMPTY','分组名称不得为空','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPNAMENOTEMPTY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPNAMENOTEMPTY','Group names must not be empty','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPNAMENOTEMPTY' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPSTOBEDELETED','要删除的分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPSTOBEDELETED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPSTOBEDELETED','Groups to be deleted','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPSTOBEDELETED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEGROUPING','删除分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEGROUPING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEGROUPING','Delete Grouping','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEGROUPING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONVERTCATEGORIEDTOGROUP','转换分类到分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONVERTCATEGORIEDTOGROUP' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONVERTCATEGORIEDTOGROUP','Convert Categories to Groups','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONVERTCATEGORIEDTOGROUP' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETASMYCOMMON','设为我的常用分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETASMYCOMMON' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETASMYCOMMON','Set as my favorite category','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETASMYCOMMON' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customviewgroup` (
                                                    `groupid`  int(19) NOT NULL AUTO_INCREMENT ,
    `group_name`  varchar(100) NULL COMMENT '分组名称' ,
    `entity_type`  varchar(50) NULL COMMENT '模块类别' ,
    `sequence`  int(19) NULL COMMENT '排序' ,
    `is_dafault`  varchar(10) NOT NULL DEFAULT 'no' COMMENT '是否默认分组' ,
    `created_id`  int(11) NULL COMMENT '创建人id' ,
    `modified_by`  int(11) NULL COMMENT '修改人id' ,
    `created_time`  datetime DEFAULT CURRENT_TIMESTAMP ,
    `modified_time`  datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
    PRIMARY KEY (`groupid`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;


call AddColumn('ld_customview','groupid','INT','19',NULL);
delimiter;

SET @tmp_tabid=(select tabid from ld_tab where name='Users');
update ld_field set uitype = 161,bigtype='' where columnname = 'approveby' and tabid=@tmp_tabid and uitype = 11 and bigtype = 'phone';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLFormulaTips1_1',"单选用户字段，变量需用大括号'{a}'，查询结果需命名为tmp_valueid",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SQLFormulaTips1_1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLFormulaTips1_1',"Single Choice User Fields,The variable is wrapped in '{a}' and the query result is named tmp_valueid",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SQLFormulaTips1_1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `UpdateFileReadHistoryProfile`;
delimiter ||
CREATE PROCEDURE UpdateFileReadHistoryProfile()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE current_tabid INT;
    DECLARE seq_43 INT;

    DECLARE tabid_cursor CURSOR FOR
    SELECT DISTINCT tabid FROM ld_profileallpermission;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN tabid_cursor;

    read_loop: LOOP
        FETCH tabid_cursor INTO current_tabid;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF (SELECT COUNT(*) FROM ld_profileallpermission WHERE tabid = current_tabid AND operation = 42) > 0 AND 
           (SELECT COUNT(*) FROM ld_profileallpermission WHERE tabid = current_tabid AND operation = 43) > 0 AND
           (SELECT COUNT(*) FROM ld_profileallpermission WHERE tabid = current_tabid AND operation = 50) = 0 THEN

            SET seq_43 = (SELECT sequence FROM ld_profileallpermission WHERE tabid = current_tabid AND operation = 43);

            UPDATE ld_profileallpermission SET sequence = sequence + 1
            WHERE tabid = current_tabid AND sequence > seq_43;

            INSERT INTO ld_profileallpermission (tabid, operation, sequence)
            VALUES (current_tabid, 50, seq_43 + 1);

            SET @new_sequence = -1;
            UPDATE ld_profileallpermission SET sequence = (@new_sequence := @new_sequence + 1) WHERE tabid = current_tabid ORDER BY sequence;

        END IF;
    END LOOP;

    CLOSE tabid_cursor;
END ||
delimiter;

CALL UpdateFileReadHistoryProfile();
DROP PROCEDURE IF EXISTS `UpdateFileReadHistoryProfile`;
delimiter;


DROP PROCEDURE IF EXISTS `update_operations_sequence`;
delimiter ||
CREATE PROCEDURE update_operations_sequence(IN p_tabid INT)
BEGIN

    UPDATE ld_profileallpermission
    SET sequence = CASE operation
				WHEN 0 THEN 0
        WHEN 3 THEN 1
        WHEN 4 THEN 2
        WHEN 11 THEN 3
        WHEN 1 THEN 4
        WHEN 2 THEN 5
        ELSE sequence
    END
    WHERE tabid = p_tabid AND operation IN (0, 3, 4, 11, 1, 2);

    SET @max_seq = (SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid = p_tabid);

    SET @new_sequence = 5;
    UPDATE ld_profileallpermission
    SET sequence = (SELECT @new_sequence := @new_sequence + 1)
    WHERE tabid = p_tabid AND operation NOT IN (0, 3, 4, 11, 1, 2)
    ORDER BY sequence;
END ||
delimiter;

DROP PROCEDURE IF EXISTS `update_operations_sequence_processmodule`;
delimiter ||
CREATE PROCEDURE update_operations_sequence_processmodule()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE current_tabid INT;
    
    DECLARE tabid_cursor CURSOR FOR
    SELECT DISTINCT tabid FROM ld_tab WHERE `name` in ('BudgetChange','WeChatUser','Employment','Resignation'
					,'Evaluation','CollectionSlip','Ambassador','Questionnaire','PurchaseInquiryOrder','Holiday','Personnelfile'
					,'Laborcontract','Salary','Competition','Articles','WorkSheet','ExpenseBudget','Questionnaire','PurchaseBack'
					,'Singin','Signout');
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN tabid_cursor;
    
    read_loop: LOOP
        FETCH tabid_cursor INTO current_tabid;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        CALL update_operations_sequence(current_tabid);
    END LOOP;
    
    CLOSE tabid_cursor;
END ||
delimiter;
CALL update_operations_sequence_processmodule();
DROP PROCEDURE IF EXISTS `update_operations_sequence_processmodule`;

DROP PROCEDURE IF EXISTS `update_operations_sequence`;
delimiter;

update ld_desk set fieldlabel = '设定后，只有包含机器人自定义关键词的消息内容才会被正常发送' where labelbol = 'dingtalk_webhook_tips1' and languagetype = 'zh';
update ld_desk set fieldlabel = 'After setting, only message content containing robot custom keywords will be sent normally' where labelbol = 'dingtalk_webhook_tips1' and languagetype = 'en';
delimiter;

UPDATE ld_producttoolfield set bigtype='textarea' WHERE `uitype` = 19 AND bigtype = 'text' AND fieldid <>0;
delimiter;

CREATE TABLE if not EXISTS `ld_crmlog_relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `relation_id` int(11) DEFAULT NULL,
	`operation_log_id` int(11) DEFAULT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

SET @labelbol = 'ModifyingLogDetails';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'修改日志详情',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Modifying Log Details',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ModifyingLogDetailstr';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'修改日志详情',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Modifying Log Details',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;
   
call addtableIndex('ld_crmlog_relation', 'idx_logration_relation_id', 'relation_id');
call addtableIndex('ld_crmlog_relation', 'idx_logration_operation_log_id', 'operation_log_id');
delimiter;


CREATE TABLE IF NOT EXISTS `ld_wechatmapuserid` (
    `mapid` int(11)  NOT NULL AUTO_INCREMENT,
    `mapuserid` varchar(50) DEFAULT NULL,
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`mapid`)  USING BTREE,
    CONSTRAINT unique_mapuserid UNIQUE (mapuserid)
    ) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

call AddColumn('ld_wechatsession','mapfromid','int','11',0);
call AddColumn('ld_wechatsession','maptolist','int','11',0);
call AddColumn('ld_wechatsession','maproomid','int','11',0);
call addtableIndex('ld_wechatsession','idx_mapfromid','mapfromid');
call addtableIndex('ld_wechatsession','idx_maptolist','maptolist');
call addtableIndex('ld_wechatsession','idx_maproomid','maproomid');
call addtableIndex('ld_wechatsession','idx_msgtype','msgtype');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatsessiontime` (
    `id` int(11)  NOT NULL AUTO_INCREMENT,
    `wechatsessionid` int(11),
    `mapfromid` int(11) COMMENT '关联ld_wechatsession的mapfromid,其他同理',
    `maptolist` int(11),
    `maxmsgtime` datetime,
    `session_type` varchar(25),
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)  USING BTREE,
    CONSTRAINT unique_wechatsessionid UNIQUE (wechatsessionid),
    INDEX idx_mapfromid (mapfromid),
    INDEX idx_maptolist (maptolist),
    INDEX idx_maxmsgtime (maxmsgtime),
    INDEX idx_session_type (session_type)
    ) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatmaproomid` (
    `groupid` int(11)  NOT NULL AUTO_INCREMENT,
    `roomid` varchar(50) COMMENT '关联ld_wechatsession的roomid,其他同理',
    `roomname` varchar(255) DEFAULT NULL,
    `wechatsessionid` int(11),
    `maxmsgtime` datetime,
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`groupid`)  USING BTREE,
    CONSTRAINT unique_roomid UNIQUE (roomid),
    INDEX idx_roomname (roomname),
    INDEX idx_wechatsessionid (wechatsessionid)
    ) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatroomuserid` (
    `id` int(11)  NOT NULL AUTO_INCREMENT,
    `groupid` int(11) COMMENT '关联ld_wechatmaproomid主键',
    `mapid` int(11) COMMENT '关联ld_wechatmapuserid主键',
    `active` varchar(10) DEFAULT 'in' COMMENT '状态：默认进群in，退群out',
    `active_time` datetime COMMENT '记录群成员进群时间或退群时间',
    PRIMARY KEY (`id`)  USING BTREE,
    INDEX idx_groupid (groupid),
    INDEX idx_mapid (mapid)
    ) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHTITLE','的搜索结果','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHTITLE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHTITLE','search result','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHTITLE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDTOCOMMON','设为常用','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDTOCOMMON' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDTOCOMMON','Add To Common','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDTOCOMMON' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITCATEGORY','编辑分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EDITCATEGORY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITCATEGORY','Edit Category','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EDITCATEGORY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel='，删除后无法恢复' where languagetype='zh' and labelbol='deletegroup' and Labeltype='jspop';
update ld_desk set fieldlabel=', can‘t recover after deletion' where languagetype='en' and labelbol='deletegroup' and Labeltype='jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoMassEditField','没有可批量编辑的字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoMassEditField' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoMassEditField','There are no fields available for batch editing','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoMassEditField' and labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2024-07-05

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MANAGEMENTGROUPING','管理分组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MANAGEMENTGROUPING' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MANAGEMENTGROUPING','Management Grouping','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MANAGEMENTGROUPING' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COPYCATEGORY','复制分类','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='COPYCATEGORY' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COPYCATEGORY','Copy Category','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='COPYCATEGORY' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTONEUSER','请至少选择一个用户!','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'PLEASESELECTONEUSER' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTONEUSER','Please select at least one user !','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'PLEASESELECTONEUSER' and languagetype='en' and labeltype = 'jspop');
delimiter;

update ld_producttoolfield set bigtype='tax' where uitype=17 and (bigtype is  null or bigtype = '');
delimiter;

call AddColumn('ld_field','disabled_copy','char','20',NULL);
set @tabid = (SELECT tabid from ld_tab where `name` = 'Users');
UPDATE ld_field set disabled_copy = 'yes',disallowed_copy = 'yes' where tabid = @tabid and columnname in ('wx_userid','wx_openid','dingtalk_userid','yunzhijia_wbuserid','fanwei_userid','zhiyuan_userid');
delimiter;

call AddColumn('ld_customtable','show_athome','varchar',4,'no');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPSTOBEDELETED','要删除的分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPSTOBEDELETED' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPSTOBEDELETED','Groups to be deleted','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='GROUPSTOBEDELETED' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEGROUPING','删除分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEGROUPING' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEGROUPING','Delete Grouping','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DELETEGROUPING' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONVERTCATEGORIEDTOGROUP','转换分类到分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONVERTCATEGORIEDTOGROUP' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONVERTCATEGORIEDTOGROUP','Convert Categories to Groups','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONVERTCATEGORIEDTOGROUP' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ungrouped','未分组','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ungrouped' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ungrouped','Ungrouped','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ungrouped' and labeltype='jspop' and languagetype='en');
delimiter;

SET @labelbol = 'ByAccount';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按客户',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'By Account',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;
update ld_desk set fieldlabel='定位参数设置' where labelbol='TRACKPOSITONINGGROUP' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='Positioning parameter settings' where labelbol='TRACKPOSITONINGGROUP' and languagetype='en' and labeltype='fixedstr';
delimiter;

SET @labelbol = 'LBL_EXPRESS100_SETTINGS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'快递100接口设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Express 100 interface Settings',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_QUERY_COMPONENT_INTERFACE_MODE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'快递查询组件接口方式',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Express query component interface mode',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'DETAIL_QUERY_INTERFACE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'默认查询接口',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Default query interface',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_100_INTERFACE_KEY';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'快递100接口Key',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Express 100 interface key',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


SET @labelbol = 'EXPRESS_100_INTERFACE_CUSTOMER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'快递100接口Customer',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Express 100 interface Costomer',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SELF_PURCHASE_EXPRESS_100_INTERFACE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自购快递100接口',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Self-purchase express 100 interface',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_QUERY_SUCCESS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'查询成功',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'query success',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_NOT_FIND_COMPANY';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'找不到对应公司,请检查Customer是否填写正确',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Can not find the corresponding company, please check whether the Customer is filled in correctly',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_NOT_EXIST';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'快递信息不存在,请检查快递单号是否正确',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"The express information does not exist, please check whether the express number is correct",@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_SERVER_ERROR';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'服务器错误',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Server Error",@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_SERVER_BUSY';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'服务器繁忙',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Server Busy",@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_SIGN_VERIFY_FAILED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'验证签名失败,请检查Key是否填写正确',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Signature verification failed, please check whether the Key is entered correctly",@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'EXPRESS_KEY_EXPIRED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'key已过期',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Key has expired",@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

set @max_fieldid = (SELECT id from ld_settings_field_seq);
set @blockid = (SELECT blockid from ld_settings_blocks where label = 'LBL_INTERFACE_SETTINGS');
INSERT INTO ld_settings_field(fieldid, blockid, `name`,description,linkto,sequence)
SELECT @max_fieldid+1, @blockid, 'LBL_EXPRESS100_SETTINGS','快递100接口设置','index.php?module=Settings&action=Express100&parenttab=Settings', 15 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_settings_field WHERE name = 'LBL_EXPRESS100_SETTINGS');
UPDATE ld_settings_field_seq SET id=(SELECT MAX(fieldid) FROM ld_settings_field);
delimiter;

INSERT INTO ld_wx_config(`name`, description, para_one)
SELECT 'express_100_interface_setting','快递100接口设置','default' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_wx_config WHERE name = 'express_100_interface_setting');
delimiter;

CALl AddColumn('ld_parenttab','fonticon','varchar','100','&#xe600;');
delimiter;

ALTER TABLE ld_parenttab ALTER COLUMN fonticon SET DEFAULT '&#xe600;';
delimiter;

CALl AddColumn('ld_parenttab','fonticon_active','varchar','100','&#xe601;');
delimiter;

ALTER TABLE ld_parenttab ALTER COLUMN fonticon_active SET DEFAULT '&#xe601;';
delimiter;

update ld_parenttab set fonticon = '&#xe61c;',fonticon_active='&#xe614;' where imagename = 'left_nav_home_ico.png';
update ld_parenttab set fonticon = '&#xe606;',fonticon_active='&#xe609;' where imagename = 'left_nav_marketing_ico.png';
update ld_parenttab set fonticon = '&#xe613;',fonticon_active='&#xe618;' where imagename = 'left_nav_account_ico.png';
update ld_parenttab set fonticon = '&#xe60c;',fonticon_active='&#xe612;' where imagename = 'left_nav_sales_ico.png';
update ld_parenttab set fonticon = '&#xe61a;',fonticon_active='&#xe611;' where imagename = 'left_nav_report_ico.png';
update ld_parenttab set fonticon = '&#xe60e;',fonticon_active='&#xe605;' where imagename = 'left_nav_base_ico.png';
update ld_parenttab set fonticon = '&#xe60d;',fonticon_active='&#xe61b;' where imagename = 'left_nav_finacial_ico.png';
update ld_parenttab set fonticon = '&#xe60f;',fonticon_active='&#xe602;' where imagename = 'left_nav_project_ico.png';
update ld_parenttab set fonticon = '&#xe619;',fonticon_active='&#xe61e;' where imagename = 'left_nav_purchase_ico.png';
update ld_parenttab set fonticon = '&#xe608;',fonticon_active='&#xe603;' where imagename = 'left_nav_stock_ico.png';
update ld_parenttab set fonticon = '&#xe616;',fonticon_active='&#xe61d;' where imagename = 'left_nav_service_ico.png';
update ld_parenttab set fonticon = '&#xe61f;',fonticon_active='&#xe617;' where imagename = 'left_nav_oa_ico.png';
update ld_parenttab set fonticon = '&#xe600;',fonticon_active='&#xe601;' where imagename = 'left_nav_custom_ico.png';
update ld_parenttab set fonticon = '&#xe60b;',fonticon_active='&#xe610;' where imagename = 'left_nav_search_ico.png';
delimiter;

DELETE from ld_module_setting_byuser where modulename = 'notbymodule' and label = 'Modifyskinset';
delimiter;

call AddColumn('ld_customreport_chartset','series_datalabel','text','',' ');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','theleftside','左侧','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='theleftside' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','theleftside','The Left Side','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='theleftside' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','therightside','右侧','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='therightside' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','therightside','The Right Side','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='therightside' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Externallyabove','外部上方','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Externallyabove' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Externallyabove','Externally above','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Externallyabove' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Belowtheexterior','外部下方','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Belowtheexterior' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Belowtheexterior','Below the exterior','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Belowtheexterior' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InternalCenter','内部中心','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InternalCenter' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InternalCenter','Internal Center','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InternalCenter' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Internalbacking','内部贴底','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Internalbacking' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Internalbacking','Internal backing','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Internalbacking' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ProhibitUploadingPHPFiles','为了安全考虑，禁止上传该文件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ProhibitUploadingPHPFiles' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ProhibitUploadingPHPFiles','For safety reasons, uploading this file is prohibited','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ProhibitUploadingPHPFiles' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnterpriseWeChatCustomerTags','企微客户标签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnterpriseWeChatCustomerTags' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnterpriseWeChatCustomerTags','Enterprise WeChat customer tags','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnterpriseWeChatCustomerTags' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel='扫码后给对应企微客户打标签' where labelbol='Labelthecorrespondingcustomerafterscanningthecode' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='After scanning the code, label the corresponding enterprise WeChat customers' where labelbol='Labelthecorrespondingcustomerafterscanningthecode' and languagetype='en' and labeltype='fixedstr';
delimiter;
-- 2024-07-12

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MASSELECTTENTIP','您勾选了{Var}条记录，最多可合并前10条记录，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MASSELECTTENTIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MASSELECTTENTIP',"You have selected {Var} records and can merge up to the first 10 records. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MASSELECTTENTIP' and labeltype='jspop');
delimiter;

SET @sequence = (select sequence from ld_systems_deploy where deploy_type = 357);
update ld_systems_deploy set sequence = sequence + 1 where sequence > @sequence and roottype = 1 ;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 'yes',482,'列表和详情页是否启用小编辑功能',@sequence+1,1,'select',0,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=482 );
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',482,482,'列表和详情页是否启用小编辑功能'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
                                                         and trantable ='ld_systems_deploy' and tabid = 482 and relateid=482);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',482,482,'Is the list and detail page enabled for small editing function'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
                                                         and trantable ='ld_systems_deploy' and tabid = 482 and relateid=482);
delimiter;
update ld_settings_field set active=1 where name = 'TRACKPOSITONINGGROUP' and active = 0;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Isitdisplayedvertically','是否垂直显示','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Isitdisplayedvertically' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Isitdisplayedvertically',"Is it displayed vertically",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Isitdisplayedvertically' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','datalabel','数据标签','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='datalabel' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','datalabel',"Data Label",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='datalabel' and labeltype='jspop');
delimiter;

SET @labelbol = 'DownloadAllowed';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据满足条件时才允许下载',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Downloading is only allowed when the documents meet the conditions',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'PreviewAllowed';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据满足条件时才允许预览',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Preview is only allowed when the document meets the conditions',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'SetConditions';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置条件',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set conditions',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TaskTextCannotEmpty','任务文本不能为空','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TaskTextCannotEmpty' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TaskTextCannotEmpty','The task text cannot be empty','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TaskTextCannotEmpty' and labeltype='jspop' and languagetype='en');
delimiter;


SET @labelbol = 'inside_radial';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'内部冲圆心',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Inside Radial',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

DELETE FROM ld_salesorder_electronicsignet WHERE ifnull(flowid,'') = '';
delimiter;

call AddColumn('ld_salesorder_electronicsignet','documentid','varchar','50','');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DownloadContract','下载合同','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DownloadContract' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DownloadContract','Download Contract','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DownloadContract' and labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
update ld_field set tablename='ld_salesorder' where tabid=@tabid and tablename='ld_salesorder_electronicsignet' and columnname = 'flowstatus';
update ld_field set tablename='ld_salesorder' where tabid=@tabid and tablename='ld_salesorder_electronicsignet' and columnname = 'sponsorid';
UPDATE ld_salesorder t1 INNER JOIN ld_salesorder_electronicsignet t2 ON t1.salesorderid = t2.salesorderid SET t1.sponsorid=ifnull(t2.sponsorid,0) WHERE  ifnull(t2.sponsorid,0) = 0 OR ifnull(t2.flowstatus,'') = '';
delimiter;
UPDATE ld_tabwithproductview SET `columns` = REPLACE(`columns`, 'ld_salesorder_electronicsignet', 'ld_salesorder') WHERE tabid =@tabid AND `columns` LIKE '%ld_salesorder_electronicsignet%';
delimiter;

call AddColumn('ld_servicecontracts', 'sponsorid', 'int', '11', '');
call AddColumn('ld_servicecontracts', 'flowstatus', 'varchar', '25', '');
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
update ld_field set tablename='ld_servicecontracts' where tabid=@tabid and tablename='ld_salesorder_electronicsignet' and columnname = 'flowstatus';
update ld_field set tablename='ld_servicecontracts' where tabid=@tabid and tablename='ld_salesorder_electronicsignet' and columnname = 'sponsorid';
UPDATE ld_servicecontracts t1 INNER JOIN ld_salesorder_electronicsignet t2 ON t1.servicecontractsid = t2.salesorderid SET t1.sponsorid=ifnull(t2.sponsorid,0) WHERE  ifnull(t2.sponsorid,0) = 0 OR ifnull(t2.flowstatus,'') = '';
delimiter;
UPDATE ld_tabwithproductview SET `columns` = REPLACE(`columns`, 'ld_salesorder_electronicsignet', 'ld_servicecontracts') WHERE tabid =@tabid AND `columns` LIKE '%ld_salesorder_electronicsignet%';
delimiter;

call AddColumn('ld_quotes', 'sponsorid', 'int', '11', '');
call AddColumn('ld_quotes', 'flowstatus', 'varchar', '25', '');
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes');
update ld_field set tablename='ld_quotes' where tabid=@tabid and tablename='ld_salesorder_electronicsignet' and columnname = 'flowstatus';
update ld_field set tablename='ld_quotes' where tabid=@tabid and tablename='ld_salesorder_electronicsignet' and columnname = 'sponsorid';
UPDATE ld_quotes t1 INNER JOIN ld_salesorder_electronicsignet t2 ON t1.quoteid = t2.salesorderid SET t1.sponsorid=ifnull(t2.sponsorid,0) WHERE ifnull(t2.sponsorid,0) = 0 OR ifnull(t2.flowstatus,'') = '';
delimiter;
UPDATE ld_tabwithproductview SET `columns` = REPLACE(`columns`, 'ld_salesorder_electronicsignet', 'ld_quotes') WHERE tabid =@tabid AND `columns` LIKE '%ld_salesorder_electronicsignet%';
delimiter;

CALl AddColumn('ld_appparenttab','menudescription','text','','');
delimiter;

CALl AddColumn('ld_mobile_report_parent_tab','menudescription','text','','');
delimiter;

SET @labelbol = 'MENUDESCRIPTION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'功能菜单描述',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Menu Description",@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Part','部分','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Part' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Part','Part','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Part' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReplaceVarWith','将{Var}更换为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReplaceVarWith' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReplaceVarWith','Replace {Var} with','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReplaceVarWith' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LetOriginalVar','将原{Var}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LetOriginalVar' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LetOriginalVar','Let the original {Var}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LetOriginalVar' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SimultaneouslyVarRelinfo','同时{Var}相关信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SimultaneouslyVarRelinfo' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SimultaneouslyVarRelinfo','Simultaneously {Var} relevant information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SimultaneouslyVarRelinfo' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DataScopeforVarRelinfo','{Var}相关信息的数据范围','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataScopeforVarRelinfo' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DataScopeforVarRelinfo','Data scope for {Var} relevant information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataScopeforVarRelinfo' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RemoveFromSharers','从共享人中移除','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RemoveFromSharers' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RemoveFromSharers','Remove from sharers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RemoveFromSharers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAsSharer','设置为共享人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAsSharer' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAsSharer','Set as a sharer','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAsSharer' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OnlyChangeSameVarData','仅变更与{Module}同{Var}的数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OnlyChangeSameVarData' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OnlyChangeSameVarData','Only change data with the same {Var} as {Module}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OnlyChangeSameVarData' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChangeAllData','变更全部的数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ChangeAllData' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChangeAllData','Change all data','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ChangeAllData' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddSharers','追加共享人','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='AddSharers' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddSharers','Add sharers','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='AddSharers' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReplaceSharer','替换共享人为','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ReplaceSharer' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReplaceSharer','Replace sharer','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ReplaceSharer' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CancelSharers','取消共享人','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CancelSharers' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CancelSharers','Cancel sharers','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CancelSharers' and labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_tranlabel SET fieldlabel = "设置分配/共享{$Accounts.Accounts}时是否允许同时分配/共享相关信息"
WHERE tabid = 61 and relateid = 61 and trantable = "ld_systems_deploy" and languagetype = "zh";
UPDATE ld_tranlabel SET fieldlabel = "Whether to distribute/share related information when distributing/sharing the {$Accounts.Accounts}"
WHERE tabid = 61 and relateid = 61 and trantable = "ld_systems_deploy" and languagetype = "en";
delimiter;

UPDATE ld_tranlabel SET fieldlabel = "设置分配/共享{$Potentials.Potentials}时是否允许同时分配/共享相关信息"
WHERE tabid = 26 and relateid = 26 and trantable = "ld_systems_deploy" and languagetype = "zh";
UPDATE ld_tranlabel SET fieldlabel = "Whether to distribute/share related information when distributing/sharing the {$Potentials.Potentials}"
WHERE tabid = 26 and relateid = 26 and trantable = "ld_systems_deploy" and languagetype = "en";
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelectOneRelatedModule','请至少选择一个相关信息模块','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectOneRelatedModule' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelectOneRelatedModule','Please select at least one module from the relevant information','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectOneRelatedModule' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SimultaneouslyShareRelinfo','同时共享相关信息','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SimultaneouslyShareRelinfo' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SimultaneouslyShareRelinfo','Simultaneously sharing relevant information','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SimultaneouslyShareRelinfo' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SimultaneouslyCancelShareRelinfo','同时取消共享相关信息','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SimultaneouslyCancelShareRelinfo' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SimultaneouslyCancelShareRelinfo','Simultaneously cancel the sharing of relevant information','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SimultaneouslyCancelShareRelinfo' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RelevantInfoModulesAllocated','分配的相关信息模块为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RelevantInfoModulesAllocated' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RelevantInfoModulesAllocated','The relevant information modules allocated are','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RelevantInfoModulesAllocated' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RelevantInfoModulesShared','共享的相关信息模块为','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RelevantInfoModulesShared' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RelevantInfoModulesShared','The shared related information modules are','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RelevantInfoModulesShared' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Optionaltag','可选标签','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Optionaltag' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Optionaltag','Optional tag','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Optionaltag' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectedTags','已选标签','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SelectedTags' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectedTags','Selected Tags','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SelectedTags' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnterTagSearchFor','请输入要查找的标签','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterTagSearchFor' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnterTagSearchFor','Please enter the tag to search for','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterTagSearchFor' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2024-07-18

update ld_homeboard_plate_stuff set height='400px'
where boardid in(select boardid from ld_homeboard where boardtype='MobileReport')  and stufftype='defaultstuff'
  and stuffid<>35 and stuffid<>112 and stuffid<>115 and stuffid<>19;

update ld_homeboard_plate_stuff set height='450px' where boardid in(select boardid from ld_homeboard where boardtype='MobileReport') and stufftype='customreport';

update ld_homeboard_plate_stuff set height='550px' where boardid in(select boardid from ld_homeboard where boardtype='MobileReport') and stuffid=112;
update ld_homeboard_plate_stuff set height='450px' where boardid in(select boardid from ld_homeboard where boardtype='MobileReport') and stuffid=115;
update ld_homeboard_plate_stuff set height='290px' where boardid in(select boardid from ld_homeboard where boardtype='MobileReport') and stuffid=19;
delimiter;

drop PROCEDURE if exists `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
    referencemodule varchar(100)
)
begin
    IF NOT EXISTS (select 1 from ld_ws_fieldtype INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid  where type=referencemodule) THEN
        select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
        if @maxuitype<2000  then
		    set @maxuitype=2000;
        else
			set @maxuitype=@maxuitype+1;
        end if;
        set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
        prepare stmta from @sql;
        execute stmta;
        deallocate prepare stmta;
        set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
        prepare stmt1 from @sql;
        execute stmt1;
        deallocate prepare stmt1;

        set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referencemodule,'")');
        prepare stmt2 from @sql;
        execute stmt2;
        deallocate prepare stmt2;
    END IF;
end ||
delimiter;
call addReferenceUitypmodule('CustomForm14');
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;
delimiter;

set @tabid = (select tabid from ld_tab where `name`='BudgetChange');
set @uitype = (select uitype from ld_ws_fieldtype INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid  where type='CustomForm14');
update ld_field set uitype = @uitype where tabid=@tabid and columnname='customform14id';
delimiter;

UPDATE ld_desk SET fieldlabel = '不允许直接新增，可通过{$CustomForm14.CustomForm14}关联新建' WHERE labelbol = 'How_to_create_budgetchange_infos' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Direct addition is not allowed, but can be created through association with {$CustomForm14.CustomForm14}' WHERE labelbol = 'How_to_create_budgetchange_infos' AND languagetype = 'en';
delimiter;
-- 2024-07-19

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

UPDATE ld_version SET old_version='V8.6.3.9',current_version='V8.6.3.9',remark='V8.6.3.9-20240719',wx_version='V8.6.3.9';
delimiter;