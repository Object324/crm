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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FNoEmpty','公式不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FNoEmpty' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FNoEmpty',"Formula cannot be empty",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FNoEmpty' and labeltype='jspop');
delimiter;

SET @labelbol = 'SETADDRESSASVISIT';
UPDATE ld_desk SET fieldlabel = '您的拜访对象还没有地址，是否需要将签到地址设置为拜访对象地址？' where labelbol = @labelbol and languagetype = 'zh' and Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel = "Your visitor does n't have an address yet. Do you need to set the sign in address as the visitor's address?" where labelbol = @labelbol and languagetype = 'en' and Labeltype='fixedstr';
delimiter;

update ld_field set bigtype='poolid' where fieldname='pool_id' and bigtype!='poolid';
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts');
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='contact_no' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='contact_no' LIMIT 1);
SET @columnname='lastcontactdate'; 
SET @fieldname='lastcontactdate'; 
SET @zh='最新联系日期'; 
SET @en='Latest contact date'; 
SET @uitype=86; 
SET @typeofdata='DT~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='datetime';
SET @presence = 0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,0,"BAS",0,NULL,0,2,0,@bigtype from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relatedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relatedid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relatedid);
delimiter;
call AddColumn(@tablename,@columnname,'datetime','','');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts');
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='lastcontactdate' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='lastcontactdate' LIMIT 1);
SET @columnname='lastcontent'; 
SET @fieldname='lastcontent'; 
SET @zh='最新进展'; 
SET @en='Latest progress'; 
SET @uitype=19; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='longtextarea';
SET @presence = 2;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,1000,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,0,"BAS",0,NULL,0,2,0,@bigtype from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relatedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relatedid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relatedid);
delimiter;

call AddColumn(@tablename,@columnname,'text','','');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts');
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='lastcontent' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='lastcontent' LIMIT 1);
SET @columnname='nolinkdays'; 
SET @fieldname='nolinkdays'; 
SET @zh='未联系天数'; 
SET @en='Nolinked Days'; 
SET @uitype=7; 
SET @typeofdata='NN~O~13,0';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='number';
SET @presence = 2;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,"BAS",1,NULL,0,2,0,@bigtype from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relatedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relatedid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relatedid);
delimiter;

call AddColumn(@tablename,@columnname,'int','19','');
delimiter;

DROP EVENT IF EXISTS `update_contact_nolinkdays`;
DELIMITER ;;
CREATE EVENT `update_contact_nolinkdays` ON SCHEDULE EVERY 1 DAY STARTS '2020-08-14 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO UPDATE ld_contactdetails SET nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d')))
;;
DELIMITER ;

SET @linkmodulecustomid = (select id from ld_linkmodulecustom where `name`='ProjectGanttReport' and linkmodule = 'Project');
delete from ld_appparenttabrel where tab_tablename = 'ld_linkmodulecustom' and  tabid = @linkmodulecustomid;
delete from ld_mobile_report_tab_rel where tab_tablename = 'ld_linkmodulecustom' and tabid = @linkmodulecustomid;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_field_formula` (
    `formulaid`  int(19) NOT NULL AUTO_INCREMENT,
    `fieldid`  int(19) DEFAULT NULL,
    `formulastring`  varchar(255) DEFAULT NULL,
    `columnstring`  text  DEFAULT NULL,
    `functiontype`  varchar(25)  DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`formulaid`) USING BTREE
    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_field','input_type','varchar','50','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EntryFunction','分录函数','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'EntryFunction' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EntryFunction','entry function','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'EntryFunction' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllNumericAndCurrencyFieldsCanCalculate','字段布局中的所有数字和货币类型的字段可参与运算。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AllNumericAndCurrencyFieldsCanCalculate' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllNumericAndCurrencyFieldsCanCalculate','All numeric and currency fields in a field layout can calculate。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AllNumericAndCurrencyFieldsCanCalculate' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='查询分类' WHERE labelbol='DATACATEGORY' AND languagetype='zh' AND fieldlabel='数据分类';
delimiter;

UPDATE ld_linkmodulecustom SET linkmodule = 'Customreport' where linkmodule = 'CustomReport';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_column_advance_stage`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_column_advance_stage`(
)
BEGIN

	DECLARE tmp_sql TEXT DEFAULT '';
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT
			CONCAT('ALTER TABLE ',TABLE_NAME,' MODIFY COLUMN advance_stage VARCHAR(100)') AS tmp_sql
		FROM information_schema.`COLUMNS`
		WHERE TABLE_SCHEMA=DATABASE()
			AND COLUMN_NAME='advance_stage'
			AND COLUMN_TYPE<>'varchar(100)'
			AND IFNULL(TABLE_NAME,'')<>''
			AND TABLE_NAME IN (SELECT DISTINCT tablename FROM ld_field)
		ORDER BY TABLE_NAME;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_sql = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_sql;
	WHILE(tmp_sql IS NOT NULL) DO
		SET @exec_sql=tmp_sql;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;

		FETCH MYCUSOR INTO tmp_sql;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_column_advance_stage();
DROP PROCEDURE IF EXISTS `ldcrm_reset_column_advance_stage`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPDATETIME','更新时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UPDATETIME' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPDATETIME','update time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UPDATETIME' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

SET @report_name='客户项目信息表';
SET @report_type='template_js';
SET @report_template='gongcheng_accountproject_information.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
select max(sequence) into @sequence from ld_customreport_info where folder_id=@id;
SET @sequence=@sequence+1;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe,'crmlink' from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1)
	AND EXISTS (SELECT 1 FROM ld_version WHERE trade='construction')
	AND NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template='工程行业_客户项目信息表.mrt');
delimiter;

UPDATE ld_field SET bigtype='users' WHERE columnname IN ('smownerid','smcreatorid') AND bigtype IS NULL;
-- 2022-04-25

CREATE TABLE IF NOT EXISTS `ld_approvestep_settinglog` LIKE ld_approvestep;
delimiter;

CALL AddColumn('ld_approvestep_settinglog','stepid','int',19,NULL);
delimiter;

CALL AddColumn('ld_approvestep_settinglog','changedon','Datetime',0,NULL);
delimiter;

CALL AddColumn('ld_approvestep_settinglog','whodid','int',19,NULL);
delimiter;

CALL AddColumn('ld_approvestep_settinglog','advft_criteria','Text',0,NULL);
delimiter;

ALTER TABLE `ld_approvestep_settinglog` MODIFY `id` INT(19) auto_increment;
delimiter;
ALTER TABLE `ld_approvestep_settinglog` MODIFY `stepid` INT(19) NOT NULL AFTER `id`;
delimiter;
ALTER TABLE `ld_approvestep_settinglog` MODIFY `changedon` Datetime NOT NULL AFTER `stepid`;
delimiter;
ALTER TABLE `ld_approvestep_settinglog` MODIFY `whodid` INT(19) NOT NULL AFTER `changedon`;
delimiter;

SET @labelbol = 'PROCESSHAVEUSEDCANOTDELETED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该步骤已被使用过，无法删除！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This process has been used, can not be deleted!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'UPDATERELATEDRECORDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'更新相关单据','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Update related records','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPDATINGRELATEDRECORDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'正在更新单据的审批信息，请不要关闭或刷新浏览器','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Updating approve information of these records,please do not close or refresh the browser ','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'APPROVESETTINGSCHANGED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前审批步骤设置变更，转交新的审批人','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The approval step settings are changed and the document approval information is modified','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPDATEAPPROVEDRECORD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该审批流程正在使用，保存后将会影响正在审批中的单据，是否继续？','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The approval process is in use. Saving will affect the documents being approved. Do you want to continue?','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;
-- 2022-04-28

update ld_field set editpage='' where bigtype = 'richtext' and uitype = 230 ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReminderTitle','提醒标题','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReminderTitle' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReminderTitle','Reminder Title','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReminderTitle' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileReminderContenttitle','（移动端收到消息提醒时，提醒内容显示的标题）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MobileReminderContenttitle' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileReminderContenttitle','（When the mobile terminal receives the message reminder, the title of the reminder content is displayed）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MobileReminderContenttitle' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

Call AddColumn('ld_approvereminds','remindtitle','varchar','100','');
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter ||
CREATE  PROCEDURE `ldcrm_approvereminds_remindtitle_add`(
)
BEGIN
	declare var_id int(100);
	DECLARE var_type varchar(100);
	DECLARE var_reminduser varchar(100);
	DECLARE var_remindmethod varchar(100);
	DECLARE var_title varchar(100);
	DECLARE var_tabid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select ld_approvereminds.id as tmp_id,ld_approvereminds.type,ld_approvereminds.reminduser,ld_approvereminds.remindmethod,ld_approvereminds.remindtitle as tmp_title,tmp_table.tabid as tmp_tabid from ld_approvereminds LEFT JOIN (SELECT ld_approvestep.id AS stepid,ld_approve.tabid AS tabid from ld_approvestep LEFT JOIN ld_approve ON ld_approve.id=ld_approvestep.approveid ) AS tmp_table ON tmp_table.stepid = ld_approvereminds.stepid;
		declare continue handler  for not   found  SET done =1;
	OPEN cur1;

	 Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	 loop1: while  done<>1 DO
		if var_title is null and var_remindmethod in ('dialog','weiin') then
			set @modulename = (select fieldlabel from ld_tranlabel where tabid = var_tabid and languagetype = 'zh' and trantable = 'ld_tab');
			if var_type=0 and var_reminduser='approver' THEN
			 update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批提醒') where ld_approvereminds.id=var_id;
			elseif var_type=0 and var_reminduser='selectuser'  THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批抄送提醒') where ld_approvereminds.id=var_id;
			elseif var_type=1 and var_reminduser='smowner'  THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批结果通知') where ld_approvereminds.id=var_id;
			elseif var_type=1 and var_reminduser in ('smcreator','selectuser')  THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批结果提醒') where ld_approvereminds.id=var_id;
			elseif var_type=2 THEN
				update ld_approvereminds set remindtitle = concat('【',@modulename,'】审批结果提醒') where ld_approvereminds.id=var_id;
			end if;
	end if;
   Fetch cur1 into var_id,var_type,var_reminduser,var_remindmethod, var_title,var_tabid;
	end while loop1;
	close cur1;
end ||
delimiter;

CALL ldcrm_approvereminds_remindtitle_add();
DROP PROCEDURE IF EXISTS `ldcrm_approvereminds_remindtitle_add`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReminderTitleCannotEmpty','提醒标题不能为空','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReminderTitleCannotEmpty' and languagetype = 'zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReminderTitleCannotEmpty','Reminder Title cannot be empty','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReminderTitleCannotEmpty' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReminderTitleMoreThan30IsSave','您设置的提醒标题字数已超过30个，超出部分将不会保存，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReminderTitleMoreThan30IsSave' and languagetype = 'zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReminderTitleMoreThan30IsSave','The number of words of the remind title you set has exceeded 30. The excess part will not be saved. Do you want to continue?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReminderTitleMoreThan30IsSave' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FORCEDREJECTSUBMITAPPROVAL','强制驳回提交审批','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'FORCEDREJECTSUBMITAPPROVAL' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FORCEDREJECTSUBMITAPPROVAL','Forced rejection of submission for approval','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'FORCEDREJECTSUBMITAPPROVAL' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULEEXPEDITINGREMIND','【%s】催审提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULEEXPEDITINGREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULEEXPEDITINGREMIND','【%s】 Expediting Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULEEXPEDITINGREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULEALLOCATEREMIND','【%s】分配提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULEALLOCATEREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULEALLOCATEREMIND','【%s】 Assign Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULEALLOCATEREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULESHAREREMIND','【%s】共享提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULESHAREREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULESHAREREMIND','【%s】 Share Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULESHAREREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULEAUTOREMINDREMIND','【%s】%s提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULEAUTOREMINDREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULEAUTOREMINDREMIND','【%s】 %s Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULEAUTOREMINDREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AccountsRECYCLEREMIND','【{$Accounts.Accounts}】回收提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AccountsRECYCLEREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AccountsRECYCLEREMIND','【{$Accounts.Accounts}】 Recycle Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AccountsRECYCLEREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LeadsRECYCLEREMIND','【{$Leads.Leads}】回收提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LeadsRECYCLEREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LeadsRECYCLEREMIND','【{$Leads.Leads}】 Recycle Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LeadsRECYCLEREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ContactRecordsDateRemind','【{$ContactRecords.ContactRecords}】回访提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ContactRecordsDateRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ContactRecordsDateRemind','【{$ContactRecords.ContactRecords}】 Return visit Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ContactRecordsDateRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AccountsHEDGINGREMIND','【{$Accounts.Accounts}】报备提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AccountsHEDGINGREMIND' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AccountsHEDGINGREMIND','【{$Accounts.Accounts}】 Hedging Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AccountsHEDGINGREMIND' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SalesOrderDueDateRemind','【{$SalesOrder.SalesOrder}】交付提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SalesOrderDueDateRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SalesOrderDueDateRemind','【{$SalesOrder.SalesOrder}】 Delivery Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SalesOrderDueDateRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ServiceContractsDueDateRemind','【{$ServiceContracts.ServiceContracts}】产品服务到期提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ServiceContractsDueDateRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ServiceContractsDueDateRemind','【{$ServiceContracts.ServiceContracts}】Product Service Expiration Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ServiceContractsDueDateRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PaymentPlanPlanDateRemind','【{$PaymentPlan.PaymentPlan}】到期提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PaymentPlanPlanDateRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PaymentPlanPlanDateRemind','【{$PaymentPlan.PaymentPlan}】Expiration Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PaymentPlanPlanDateRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SendPaymentPlanDateRemind','【{$SendPayment.SendPayment}】到期提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SendPaymentPlanDateRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SendPaymentPlanDateRemind','【{$SendPayment.SendPayment}】Expiration Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SendPaymentPlanDateRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULECOMMENTRemind','【%s】评论提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULECOMMENTRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULECOMMENTRemind','【%s】Comment Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'MODULECOMMENTRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModuleCreateRemind','【%s】新增提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ModuleCreateRemind' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModuleCreateRemind','【%s】Create Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ModuleCreateRemind' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder_havetype`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder_havetype`(
	tmp_content text,
	tmp_recieverid INT(19),
  tmp_reltab VARCHAR(100),
	tmp_related_to INT(19),
	tmp_remindstype VARCHAR(100)
    
)
BEGIN
	
	SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
	INSERT INTO ld_crmentity(crmid,setype)
	SELECT @max_remindid+1,'Reminds';		

	UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
	
	INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted,remindstype)
	SELECT @max_remindid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0,tmp_remindstype;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicaccount_beforereminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicaccount_beforereminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，即将要回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'AccountsRECYCLEREMIND');
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'AccountsRECYCLEREMIND');
		
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicaccount_recoveryreminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicaccount_recoveryreminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'AccountsRECYCLEREMIND');
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'AccountsRECYCLEREMIND');
			else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				 call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'AccountsRECYCLEREMIND');
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicleads_beforereminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicleads_beforereminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'LeadsRECYCLEREMIND');
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'LeadsRECYCLEREMIND');
			
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicleads_recoveryreminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicleads_recoveryreminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'LeadsRECYCLEREMIND');
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'LeadsRECYCLEREMIND');
			else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				 call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'',0,'LeadsRECYCLEREMIND');
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end ||
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_remind_smowner`;
delimiter ||
CREATE TRIGGER `ldcrm_remind_smowner` AFTER INSERT ON `ld_modcomments` FOR EACH ROW BEGIN

  SELECT setype INTO @reltab FROM ld_crmentity WHERE crmid=NEW.related_to;

  IF NEW.related_to>0 THEN
    SELECT
      b.fieldlabel INTO @content
    FROM ld_tab a
    LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
    WHERE a.`name`=@reltab LIMIT 1;
	
    SELECT CONCAT(last_name,'评论了您的',@content) INTO @content FROM ld_users WHERE id=NEW.smownerid LIMIT 1;

    SET @smownerid=0;
    SET @servicecasher=0;
    IF @reltab='Accounts' THEN
      SELECT smownerid INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
      SELECT servicecasher INTO @servicecasher FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='Contacts' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactdetails WHERE contactid=NEW.related_to limit 1;
    ELSEIF @reltab='ContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactrecords WHERE contactrecordid=NEW.related_to limit 1;
    ELSEIF @reltab='Potentials' THEN
      SELECT smownerid INTO @smownerid FROM ld_potential WHERE potentialid=NEW.related_to limit 1;
    ELSEIF @reltab='Quotes' THEN
      SELECT smownerid INTO @smownerid FROM ld_quotes WHERE quoteid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesorder WHERE salesorderid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesback WHERE salesbackid=NEW.related_to limit 1;

    ELSEIF @reltab='ServiceContracts' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicecontracts WHERE servicecontractsid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceCharge' THEN
      SELECT servicecasher INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='HelpDesk' THEN
      SELECT smownerid INTO @smownerid FROM ld_troubletickets WHERE ticketid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceReturn' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicereturn WHERE servicereturnid=NEW.related_to limit 1;

    ELSEIF @reltab='Project' THEN
      SELECT smownerid INTO @smownerid FROM ld_project WHERE projectid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectTask' THEN
      SELECT smownerid INTO @smownerid FROM ld_projecttask WHERE projecttaskid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectMilestone' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectmilestone WHERE projectmilestoneid=NEW.related_to limit 1;
    ELSEIF @reltab='TimeSheet' THEN
      SELECT smownerid INTO @smownerid FROM ld_timesheet WHERE timesheet_id=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectProgress' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectprogress WHERE projectprogressid=NEW.related_to limit 1;
    ELSEIF @reltab='Rate' THEN
      SELECT smownerid INTO @smownerid FROM ld_rate WHERE rate_id=NEW.related_to limit 1;

    ELSEIF @reltab='Invoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_invoice WHERE invoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseInvoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseinvoice WHERE purchaseinvoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashbill WHERE cashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='SendCashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendcashbill WHERE sendcashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashback WHERE cashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseCashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchasecashback WHERE purchasecashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PaymentPlan' THEN
      SELECT smownerid INTO @smownerid FROM ld_paymentplan WHERE paymentplanid=NEW.related_to limit 1;
    ELSEIF @reltab='SendPayment' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendpayment WHERE sendpaymentid=NEW.related_to limit 1;
    ELSEIF @reltab='PutCash' THEN
      SELECT smownerid INTO @smownerid FROM ld_putcash WHERE putcashid=NEW.related_to limit 1;
    ELSEIF @reltab='CashDeposit' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashdeposit WHERE cashdepositid=NEW.related_to limit 1;
    ELSEIF @reltab='BankAccountSet' THEN
      SELECT smcreatorid INTO @smownerid FROM ld_bankaccountset WHERE Bankaccountsetid=NEW.related_to limit 1;

    ELSEIF @reltab='OutboundOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_outboundorder WHERE out_id=NEW.related_to limit 1;
    ELSEIF @reltab='Stock' THEN
      SELECT smownerid INTO @smownerid FROM ld_stock WHERE stock_id=NEW.related_to limit 1;
    ELSEIF @reltab='WareHouseTransfer' THEN
      SELECT smownerid INTO @smownerid FROM ld_warehousetransfer WHERE warehousetransferid=NEW.related_to limit 1;
    ELSEIF @reltab='Checks' THEN
      SELECT smownerid INTO @smownerid FROM ld_checks WHERE id=NEW.related_to limit 1;

    ELSEIF @reltab='Vendors' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendor WHERE vendorid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContact' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontacts WHERE vendorcontactsid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontactrecords WHERE contactRecordsid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseorder WHERE purchaseorderid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseback WHERE purchasebackid=NEW.related_to limit 1;

    ELSEIF @reltab='Campaigns' THEN
      SELECT smownerid INTO @smownerid FROM ld_campaign WHERE campaignid=NEW.related_to limit 1;

    ELSEIF @reltab='NormalApprove' THEN
      SELECT smownerid INTO @smownerid FROM ld_normalapprove WHERE normalapproveid=NEW.related_to limit 1;
    ELSEIF @reltab='AddJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='MinusJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='BusinessApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_businessapply WHERE businessapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='LoanApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_loanapply WHERE loanapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='CardApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_cardapply WHERE cardapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='Commission' THEN
      SELECT smownerid INTO @smownerid FROM ld_commission WHERE commission_id=NEW.related_to limit 1;
    ELSEIF @reltab='Expense' THEN
      SELECT smownerid INTO @smownerid FROM ld_expense WHERE expenseid=NEW.related_to limit 1;

    ELSEIF @reltab='Products' THEN
      SELECT smownerid INTO @smownerid FROM ld_products WHERE productid=NEW.related_to limit 1;
    ELSEIF @reltab='PriceBooks' THEN
      SELECT smownerid INTO @smownerid FROM ld_pricebook WHERE pricebookid=NEW.related_to limit 1;
    ELSEIF @reltab='Documents' THEN
      SELECT smownerid INTO @smownerid FROM ld_notes WHERE notesid=NEW.related_to limit 1;
    ELSEIF @reltab='Faq' THEN
      SELECT smownerid INTO @smownerid FROM ld_faq WHERE id=NEW.related_to limit 1;
    ELSEIF @reltab='Attachment' THEN
      SELECT smownerid INTO @smownerid FROM ld_attachmentsforbills WHERE attachmentsid=NEW.related_to limit 1;
    END IF;

    IF @smownerid>0  THEN
      CALL ldcrm_add_reminder_havetype(@content,@smownerid,@reltab,NEW.related_to,'MODULECOMMENTRemind');
    END IF;
    select presence into @presence from ld_tab where name='servicecharge';

    IF @servicecasher>0 AND @smownerid<>@servicecasher AND (@presence=0 or @presence=2)  THEN
      CALL ldcrm_add_reminder_havetype(@content,@servicecasher,'ServiceCharge',NEW.related_to,'MODULECOMMENTRemind');
    END IF;
  END IF;

end ||
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','automaticsignin','自动签到','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='automaticsignin' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','automaticsignin','Automatic signin','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='automaticsignin' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Ifitexceedstheerrorrange','超出误差范围，不允许签到，允许误差','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Ifitexceedstheerrorrange' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Ifitexceedstheerrorrange','If it exceeds the error range, it is not allowed to sign in, and the error is allowed','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Ifitexceedstheerrorrange' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','metre','米','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='metre' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','metre','metre','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='metre' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Labeltypefieldalreadyexistsinmodule','模块中已存在《标签》类型字段，保存失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Labeltypefieldalreadyexistsinmodule' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Labeltypefieldalreadyexistsinmodule','Labeltypefieldalreadyexistsinmodule','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Labeltypefieldalreadyexistsinmodule' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Checkinerrorvaluecannotbeempty','签到误差值不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Checkinerrorvaluecannotbeempty' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Checkinerrorvaluecannotbeempty','Check in error value cannot be empty!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Checkinerrorvaluecannotbeempty' and labeltype='jspop');
delimiter;

call AddColumn('ld_field','auto_signin','varchar','10','no');
call AddColumn('ld_field','no_signin','varchar','10','no');
call AddColumn('ld_field','allowable_distance','int','11',0);
delimiter;
update ld_field set auto_signin = 'no' where auto_signin is NULL;
delimiter;
update ld_field set no_signin = 'no' where no_signin is NULL;
delimiter;

update ld_desk set fieldlabel = '签到源单定制' where labelbol = 'LBL_Optionalmodule_Customization' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Sign in source single customization' where labelbol = 'LBL_Optionalmodule_Customization' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '签到源单定制' where labelbol = 'LBL_Signin_Optionalmodule_Customization' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Sign in source single customization' where labelbol = 'LBL_Signin_Optionalmodule_Customization' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

call AddColumn('ld_option_module','no_signin','varchar','10','no');
call AddColumn('ld_option_module','allowable_distance','int','11',0);
delimiter;
update ld_option_module set no_signin = 'no' where no_signin is NULL;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','notenabled','未启用','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='notenabled' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','notenabled','not enabled','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='notenabled' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Theadministratorhassetthatitisnorange','管理员已设置超出误差范围不允许签到，请完善您的拜访对象地址信息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Theadministratorhassetthatitisnorange' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Theadministratorhassetthatitisnorange','The administrator has set that it is not allowed to sign in beyond the error range. Please improve your visitors address information','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Theadministratorhassetthatitisnorange' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Theadministratorhassetthatitisnotallowedtosign','管理员已设置超出误差范围不允许签到，您的签到误差已超{metre}米，请在规定范围内签到！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Theadministratorhassetthatitisnotallowedtosign' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Theadministratorhassetthatitisnotallowedtosign','The administrator has set that it is not allowed to sign in beyond the error range. Your sign in error has exceeded {mete} meters. Please sign in within the specified range!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Theadministratorhassetthatitisnotallowedtosign' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `insert_module_signin_field`;
delimiter ||
CREATE  PROCEDURE `insert_module_signin_field`(
)
BEGIN
	
	
		declare tmp_option_tabid int;
		declare tmp_presence int;

		declare cur1 CURSOR FOR 
			SELECT
				option_tabid,
				ld_option_module.presence 
			FROM ld_option_module 
			LEFT JOIN ld_tab ON ld_tab.tabid = ld_option_module.tabid 
			WHERE `name` = 'Singin'
				AND option_tabid IN (SELECT tabid FROM ld_tab);

		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_option_tabid = NULL;
	
		OPEN cur1;
		Fetch cur1 into tmp_option_tabid,tmp_presence;
		while(tmp_option_tabid is not null) DO
				select count(1) into @cnt from ld_field where tabid = tmp_option_tabid and bigtype = 'signin';
				if @cnt <=0 THEN
					UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
					select id + 1 into @fieldid from ld_field_seq;
					select block,tablename into @block,@tablename from ld_field where tabid = tmp_option_tabid and columnname = 'smownerid';
					select max(sequence) into @sequence from ld_field where block = @block;
					insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,
					typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked,
					duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,
					fldallow_rewriting,take_photo_only,savedatabase,bigtype,datarang,maxrowsshow,parentbigtype,profileeditfield,keywords,advance_demand,advance_demand_groups,uploadwatermark,
					fieldvaluecolor,fieldplaceholder,createdtime,modifiedtime,editpage,input_type,auto_signin,no_signin,allowable_distance) 
					values 
					(tmp_option_tabid,@fieldid,'signin_address','yes',@tablename,2,306,'signin_address','签到',0,tmp_presence,'',100,@sequence+1,@block,2,
					'V~O',0,0,'BAS',2,NULL,NULL,0,NULL,NULL,0,0,
					NULL,NULL,0,0,'no','no','no','no','yes',
					0,0,'no','signin','all',5,NULL,'yes',NULL,NULL,NULL,'no',
					'','',now(),now(),'','','NO','NO',0
					);
					insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
					select 'zh','ld_field',tmp_option_tabid,@fieldid,'签到' from dual 
					where not exists (select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and tabid = tmp_option_tabid and relateid=@fieldid);
					insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
					select 'en','ld_field',tmp_option_tabid,@fieldid,'Signin' from 
					dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_field' and tabid = tmp_option_tabid and relateid=@fieldid);
					call AddColumn(@tablename,'signin_address','varchar','5',NULL);
					update ld_field_seq set id = (select max(fieldid) from ld_field);
				end if;
		Fetch cur1 into tmp_option_tabid,tmp_presence;
		end while;
		close cur1;
end ||
delimiter;

call insert_module_signin_field();
delimiter;
-- 2022-04-29

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commonmoduleslabel','常用模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commonmoduleslabel','Common module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
delimiter;

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;


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

UPDATE ld_version SET old_version='V8.4.6.1',current_version='V8.4.6.1',remark='V8.4.6.1-20220429',wx_version='V8.4.6.1';
delimiter;