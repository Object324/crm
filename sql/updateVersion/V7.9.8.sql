DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
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

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','EVALUATESETTING03','满足以下条件时可评价','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='EVALUATESETTING03' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','EVALUATESETTING03','It can be evaluated if the following conditions are met','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='EVALUATESETTING03' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mapviewlist','地图视图列表','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewlist' and languagetype='zh');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mapviewlist','Map view list','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewlist' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mapviewdetails','地图视图详情','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewdetails' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mapviewdetails','Map view details','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewdetails' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mapviewlistinfo','设置地图视图模式下左侧单据列表显示字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewlistinfo' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mapviewlistinfo','Set the left document list display field in map view','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewlistinfo' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mapviewdetailinfo','设置地图视图模式下右侧单据详情显示字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewdetailinfo' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mapviewdetailinfo','Set the right document detail display field in map view mode','fixedstr' from dual 
where not exists(select 1 from ld_desk where labeltype='fixedstr' and labelbol='mapviewdetailinfo' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','displaycolumnselectatleasttwo','显示列至少选择两列','jspop' from dual 
where not exists(select 1 from ld_desk where labeltype='jspop' and labelbol='displaycolumnselectatleasttwo' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','displaycolumnselectatleasttwo','Display column select at least two','jspop' from dual 
where not exists(select 1 from ld_desk where labeltype='jspop' and labelbol='displaycolumnselectatleasttwo' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_map_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(50) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  `columnname` text,
  `map_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

truncate ld_map_field;
select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'accountname';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',0,@col_name,'list' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'list' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'smownerid';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',1,@col_name,'list' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'list' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'locationaddress';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',2,@col_name,'list' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'list' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'accountname';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',0,@col_name,'detail' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'detail' and columnname = @col_name);
delimiter;
select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'locationaddress';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',1,@col_name,'detail' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'detail' and columnname = @col_name);
delimiter;
select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'rating';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',2,@col_name,'detail' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'detail' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'smownerid';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',3,@col_name,'detail' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'detail' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'createdtime';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',4,@col_name,'detail' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'detail' and columnname = @col_name);
delimiter;


select tabid  into @tabid from ld_tab where name='project';
update ld_field  set bigtype='selectsource' where tabid=48 and columnname='salesorderid';
select tabid into @option_tabid from ld_tab where name='salesorder';

insert into ld_option_module(tabid,option_tabid,presence,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,0,1,'all','5' from DUAL where not exists(select 1 from ld_option_module
where tabid=@tabid and option_tabid=@option_tabid);

select tabid into @option_tabid from ld_tab where name='ServiceContracts';
insert into ld_option_module(tabid,option_tabid,presence,approve_demand,sequence,datarang,maxrowsshow,`default`)
select @tabid,@option_tabid,0,0,2,'all','5',1 from DUAL where not exists(select 1 from ld_option_module
where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

call AddColumn('ld_account','kis_id','int','22',0);
call AddColumn('ld_account','kis_no','varchar','200',0);
call AddColumn('ld_products','kis_id','int','22',0);
call AddColumn('ld_products','kis_no','varchar','200',0);
delimiter;

SET @report_name='合同跟踪表';
SET @report_type='template_js';
SET @report_template='default_ordertracking.mrt';
SET @setype='SalesOrder,ServiceContracts';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;

SET @report_name='客户服务汇总表'; 
SET @report_type='template_js'; 
SET @report_template='default_account_services.mrt'; 
SET @setype='Accounts'; 
SET @report_describe=''; 
SET @report_url=''; 
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports'); 
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id); 

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq; 
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype) 
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1); 
delimiter;


CALl AddColumn('ld_workremindset','cooperativeworkdaily','varchar','50','no');
delimiter;

CALl AddColumn('ld_workremindset','cooperativeworkweek','varchar','50','no');
delimiter;

CALl AddColumn('ld_workremindset','cooperativeworkmonth','varchar','50','no');
delimiter;

update ld_workremindset set cooperativeworkdaily='no' where cooperativeworkdaily is null or cooperativeworkdaily='';
update ld_workremindset set cooperativeworkweek='no' where cooperativeworkweek is null or cooperativeworkweek='';
update ld_workremindset set cooperativeworkmonth='no' where cooperativeworkmonth is null or cooperativeworkmonth='';
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_PARAMETER_SETTINGS';

select  max(id) into @maxfieldid from ld_settings_field_seq;
update ld_settings_field_seq set id=@maxfieldid +1  where  not exists(select 1 from ld_settings_field where name='LBL_REMIND_SET');
select sequence into @sequence from ld_settings_field where linkto like '%AutomaticReminds%' and blockid=@blockid;

insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
 select  @maxfieldid +1,@blockid,'LBL_cooperative_REMIND_SET','remindset.gif','LBL_cooperative_REMIND_SET_DESCRIPTION',
'index.php?module=Settings&action=CooperativeWorkRemindSet&parenttab=Settings',@sequence+1,0 
from dual where not exists(select 1 from ld_settings_field where name='LBL_cooperative_REMIND_SET');

delimiter;
update ld_settings_field  INNER JOIN(
SELECT fieldid, @trownum:=@trownum+1 AS seq FROM (SELECT @trownum:=0) r, ld_settings_field  where blockid=@blockid ORDER BY sequence asc,fieldid asc
) as tmp on tmp.fieldid=ld_settings_field.fieldid
set sequence=seq ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_cooperative_REMIND_SET','{$CooperativeWork.CooperativeWork}提醒设置','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='LBL_cooperative_REMIND_SET' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_cooperative_REMIND_SET','Work report remind Settings','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='LBL_cooperative_REMIND_SET' and languagetype='en' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DailySubmitDeadLine','日志提交期限','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='DailySubmitDeadLine' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DailySubmitDeadLine','Log submission deadline','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='DailySubmitDeadLine' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WeekSubmitDeadLine','周计划提交期限','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='WeekSubmitDeadLine' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','WeekSubmitDeadLine','Week plan submission deadline','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='WeekSubmitDeadLine' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MonthSubmitDeadLine','月计划提交期限','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='MonthSubmitDeadLine' and languagetype='zh' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MonthSubmitDeadLine','Month plan submission deadline','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='WeekSubmitDeadLine' and languagetype='en' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DailySubmitDeadLineDescription','提前1小时开始，到当天23:59为止，在消息中心提醒','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='DailySubmitDeadLineDescription' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DailySubmitDeadLineDescription','Start 1 hour in advance, until 23:59 on the day, remind in the message center','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='DailySubmitDeadLineDescription' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WeekSubmitDeadLineDescription','提前1天开始，到本周最后一天，在消息中心提醒','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='WeekSubmitDeadLineDescription' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','WeekSubmitDeadLineDescription','Start 1 day in advance and remind you at the message center on the last day of the week','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='WeekSubmitDeadLineDescription' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MonthSubmitDeadLineDescription','提前3天开始，在消息中心提醒','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='MonthSubmitDeadLineDescription' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','MonthSubmitDeadLineDescription','Start 3 days in advance and remind you in the message center','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='MonthSubmitDeadLineDescription' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConfirmSubmitCooperativeWorkRemind','确认要修改{$CooperativeWork.CooperativeWork}的提交期限吗？','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='zh' and labelbol='ConfirmSubmitCooperativeWorkRemind' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConfirmSubmitCooperativeWorkRemind','Are you sure you want to change the submission deadline for the work report?','fixedstr' from dual 
where not exists(select * from ld_desk where languagetype='en' and labelbol='ConfirmSubmitCooperativeWorkRemind' and labeltype='fixedstr');
delimiter;



DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkdaily,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;
	
	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '日志提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork' ;

	IF @remindtime<>'no' AND WEEKDAY(NOW())<5 AND @cnt=0 AND DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 HOUR),'%H:%i')>=@remindtime AND DATE_FORMAT(NOW(),'%H:%i')<=@remindtime THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO

			IF NOT EXISTS (SELECT 1 FROM ld_workreport WHERE  DATE_FORMAT(createdtime,"%Y-%m-%d")=CURDATE() AND smcreatorid=tmp_id and type=1) THEN
						 
			SET @content=CONCAT('日志提交提醒：您该提交日志啦，还有一个小时就到提交期限哦');
					CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			end if;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

	

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkweek,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '周计划提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork';

	IF @remindtime<>'no' AND WEEKDAY(NOW())IN (@remindtime-2,@remindtime-1) AND @cnt=0 THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO
			IF NOT EXISTS (SELECT 1 FROM  ld_workreport where createdtime BETWEEN date_sub(curdate(),INTERVAL WEEKDAY(curdate()) + 0 DAY) and date_sub(curdate(),INTERVAL WEEKDAY(curdate()) - 6 DAY) and  type=2 AND smcreatorid=tmp_id) THEN
				IF WEEKDAY(NOW())=@remindtime-2 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，明天是最后一天期限哦');
				ELSEIF WEEKDAY(CURDATE())=@remind-1 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，今天是最后一天期限哦');
				END IF;
				CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			END IF;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_monthreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkmonth,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	IF @remindtime<>'no' THEN
		IF @remindtime>=20 AND @remindtime<32 THEN
			SET @yue=MONTH(CURDATE());
			SET @do_remind=IF(DAY(CURDATE())>=@remindtime-2 AND DAY(CURDATE())<=@remindtime,1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月计划提交提醒：%' AND date_time>=DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(CURDATE())-2 DAY) and reltab='CooperativeWork';
			SET @days=@remindtime-DAY(CURDATE())+1;
		ELSEIF @remindtime=40 THEN
			SET @yue=MONTH(CURDATE());
			SET @do_remind=IF(DATE_ADD(CURDATE(),INTERVAL 2 DAY)>=LAST_DAY(CURDATE()),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月计划提交提醒：%' AND date_time>=DATE_SUB(LAST_DAY(CURDATE()),INTERVAL 2 DAY) and reltab='CooperativeWork';	
			SET @days=DATEDIFF(LAST_DAY(CURDATE()),CURDATE())+1;
		ELSEIF @remindtime<=2 AND DAY(CURDATE())>=25 THEN
			SET @yue=MONTH(CURDATE());
			SET @do_remind=IF(CURDATE()>=DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @remindtime-2 DAY),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月计划提交提醒：%' AND date_time>=DATE_ADD(LAST_DAY(CURDATE()),INTERVAL @remindtime-2 DAY) and reltab='CooperativeWork';	
			SET @days=DATEDIFF(DATE_ADD(LAST_DAY(CURDATE()), INTERVAL @remindtime DAY),CURDATE())+1;
		ELSEIF @remindtime<=2 AND DAY(CURDATE()) IN (1,2) THEN
			SET @yue=MONTH(CURDATE())-1;
			SET @do_remind=IF(CURDATE()<=DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(CURDATE()) DAY),1,0);
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月计划提交提醒：%' AND date_time>=DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(CURDATE())-2 DAY) and reltab='CooperativeWork';	
			SET @days=DATEDIFF(DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(CURDATE()) DAY),CURDATE())+1;
		ELSEIF @remindtime>=3 AND @remindtime<=5 THEN
			SET @yue=MONTH(CURDATE())-1;
			SET @do_remind=IF(CURDATE()>=DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(CURDATE())-2 DAY) AND CURDATE()<=DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(curdate()) DAY),1,0) and reltab='CooperativeWork';
			SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '月计划提交提醒：%' AND date_time>=DATE_ADD(CURDATE(),INTERVAL @remindtime-DAY(CURDATE())-2 DAY) and reltab='CooperativeWork';
			SET @days=DATEDIFF(DATE_ADD(CURDATE(),INTERVAL @remind-DAY(curdate()) DAY),CURDATE())+1;
		ELSE 
				SET @do_remind=0;
		END IF;

		IF @do_remind=1 AND @cnt=0 THEN 
			OPEN Mycur;
			FETCH Mycur INTO tmp_id;
			WHILE (tmp_id IS NOT NULL) DO
				IF NOT EXISTS (SELECT 1 FROM ld_workreport WHERE DATE_FORMAT(createdtime,"%Y-%m")=DATE_FORMAT(CURDATE(),"%Y-%m")  AND smcreatorid=tmp_id and type=3) THEN
					IF @days=1 THEN
						SET @content=CONCAT('月计划提交提醒：您该提交月计划啦，今天是最后一天期限哦');	
				  elseIF @days=2 THEN
						SET @content=CONCAT('月计划提交提醒：您该提交月计划啦，明天是最后一天期限哦');
					ELSE
						SET @content=CONCAT('月计划提交提醒：您该提交月计划啦，还有',@days,'天就是提交期限哦');
					END IF;
					CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
				END IF;
			FETCH Mycur INTO tmp_id;
			END WHILE;
			CLOSE Mycur;	
		END IF;
	END IF;
end ||
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `task_cooperativeworkdaily_eventreminder`;
CREATE EVENT `task_cooperativeworkdaily_eventreminder`
ON SCHEDULE EVERY 10 MINUTE STARTS '2019-06-21 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO
CALL task_cooperativework_dailyreport_reminder();
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkweek_eventreminder`;
CREATE EVENT `task_cooperativeworkweek_eventreminder`
ON SCHEDULE EVERY 1 HOUR STARTS '2019-06-21 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_cooperativework_weekreport_reminder();
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkmonth_eventreminder`;
CREATE EVENT `task_cooperativeworkmonth_eventreminder`
ON SCHEDULE EVERY 1 HOUR STARTS '2019-06-21 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_cooperativework_monthreport_reminder();
delimiter;
-- 2019-11-29

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%') THEN
		CALL task_cooperativeworkdaily_eventreminder();
	END IF;

end ||
delimiter;


DROP EVENT IF EXISTS `task_cooperativeworkdaily_eventreminder`;
CREATE EVENT `task_cooperativeworkdaily_eventreminder` ON SCHEDULE EVERY 10 MINUTE STARTS '2019-06-21 14:00:00' ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_dailyreport_reminder_exec();
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3) THEN
		CALL task_cooperativeworkweek_eventreminder();
	END IF;

end ||
delimiter;


DROP EVENT IF EXISTS `task_cooperativeworkweek_eventreminder`;
CREATE EVENT `task_cooperativeworkweek_eventreminder` ON SCHEDULE EVERY 1 HOUR STARTS '2019-06-21 15:00:00' ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_weekreport_reminder_exec();
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_monthreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkmonth>=3) THEN
		CALL task_cooperativework_monthreport_reminder();
	END IF;

end ||
delimiter;


DROP EVENT IF EXISTS `task_cooperativeworkmonth_eventreminder`;
CREATE EVENT `task_cooperativeworkmonth_eventreminder` ON SCHEDULE EVERY 1 HOUR STARTS '2019-06-21 15:30:00' ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_monthreport_reminder_exec();
delimiter;


DROP PROCEDURE IF EXISTS `drop_reportlog_event_20191204`;
delimiter ||
CREATE PROCEDURE `drop_reportlog_event_20191204`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE dailyreminddate='不提醒') THEN
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
	END IF;

	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE weekreminddate='不提醒') THEN
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	END IF;

	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE monthreminddate='不提醒') THEN
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
	END IF;

end ||
delimiter;

CALL drop_reportlog_event_20191204();
DROP PROCEDURE IF EXISTS `drop_reportlog_event_20191204`;

CALL addtableIndex('ld_reminds','recieverid','recieverid');
CALL addtableIndex('ld_reminds','smownerid','smownerid');
CALL addtableIndex('ld_reminds','smcreatorid','smcreatorid');
CALL addtableIndex('ld_reminds','date_time','date_time');

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

UPDATE ld_version SET old_version='V7.9.8',current_version='V7.9.8',remark='V7.9.8-20191129',wx_version='V7.9.8';
delimiter;