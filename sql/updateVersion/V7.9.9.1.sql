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


DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;

select tabid into @tabid from ld_tab where name='customreport' ;
select GROUP_CONCAT( DISTINCT profileid)  into @allprofileids  from  ld_profile2standardpermissions
where  tabid=@tabid and ld_profile2standardpermissions.profileid not in(select DISTINCT profileid  from ld_profile2standardpermissions where tabid=@tabid and operation=3);
delete from ld_profile2standardpermissions where FIND_IN_SET(profileid,@allprofileids) 
and tabid=@tabid;
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%') AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkdaily_eventreminder') THEN
		CALL task_cooperativework_dailyreport_reminder();
		INSERT INTO ld_sys_event(eventdate,type) SELECT NOW(),'task_cooperativeworkdaily_eventreminder';
	END IF;

end ||
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkdaily_eventreminder`;
CREATE EVENT `task_cooperativeworkdaily_eventreminder` ON SCHEDULE EVERY 10 MINUTE STARTS CONCAT('2019-06-21 ',floor(rand()*24),':',floor(rand()*60),':',floor(rand()*60)) ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_dailyreport_reminder_exec();
delimiter;

DROP PROCEDURE IF EXISTS `task_dailyreport_reminder`;
delimiter ||
CREATE  PROCEDURE `task_dailyreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE d.`name`='ReportLog'
			AND permissions=0
			AND a.`status`='Active';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE dailyreminddate LIKE '%:%') AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_dailyreport_reminder') THEN
		SET @remind='不提醒';
		SELECT IFNULL(dailyreminddate,'不提醒') INTO @remind FROM ld_workremindset LIMIT 1;
		
		SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '日报提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE();

		IF @remind<>'不提醒' AND WEEKDAY(NOW())<5 AND @cnt=0 AND DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 HOUR),'%H:%i')>=@remind AND DATE_FORMAT(NOW(),'%H:%i')<=@remind THEN
			OPEN Mycur;
			FETCH Mycur INTO tmp_id;
			WHILE (tmp_id IS NOT NULL) DO
				IF NOT EXISTS (SELECT 1 FROM ld_dailyreport WHERE startdate=CURDATE() AND dstatus=1 AND smcreatorid=tmp_id) THEN
					SET @content=CONCAT('日报提交提醒：您该提交日报啦，还有一个小时就到提交期限哦');
					CALL ldcrm_add_reminder(@content,tmp_id,'ReportLog',0);
				END IF;
			FETCH Mycur INTO tmp_id;
			END WHILE;
			CLOSE Mycur;

			INSERT INTO ld_sys_event(eventdate,type) SELECT NOW(),'task_dailyreport_reminder';
		END IF;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `drop_event_task_dailyreport_reminder_20191209`;
delimiter ||
CREATE PROCEDURE `drop_event_task_dailyreport_reminder_20191209`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`='Report' AND presence IN (1,5)) THEN
		DELETE FROM ld_tab WHERE `name`='Report';
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	ELSEIF NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='Report') THEN
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	END IF;
end ||
delimiter;

CALL drop_event_task_dailyreport_reminder_20191209();
DROP PROCEDURE IF EXISTS `drop_event_task_dailyreport_reminder_20191209`;

DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkweek_eventreminder')  THEN
		CALL task_cooperativework_weekreport_reminder();
		INSERT INTO ld_sys_event(eventdate,type) SELECT NOW(),'task_cooperativeworkweek_eventreminder';
	END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_monthreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkmonth>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkmonth_eventreminder')  THEN
		CALL task_cooperativework_monthreport_reminder();
		INSERT INTO ld_sys_event(eventdate,type) SELECT NOW(),'task_cooperativeworkmonth_eventreminder';
	END IF;

end ||
delimiter;

DROP EVENT IF EXISTS `task_cooperativeworkmonth_eventreminder`;
CREATE EVENT `task_cooperativeworkmonth_eventreminder` ON SCHEDULE EVERY 1 HOUR STARTS CONCAT('2019-06-21 ',floor(rand()*24),':',floor(rand()*60),':',floor(rand()*60)) ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_monthreport_reminder_exec();
delimiter;


DROP EVENT IF EXISTS `task_cooperativeworkweek_eventreminder`;
CREATE EVENT `task_cooperativeworkweek_eventreminder` ON SCHEDULE EVERY 1 HOUR STARTS CONCAT('2019-06-21 ',floor(rand()*24),':',floor(rand()*60),':',floor(rand()*60)) ON COMPLETION NOT PRESERVE ENABLE DO
CALL task_cooperativework_weekreport_reminder_exec();
delimiter;

INSERT INTO ld_sys_event(eventdate,type) 
SELECT NOW(),'task_dailyreport_reminder' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE type='task_dailyreport_reminder');

INSERT INTO ld_sys_event(eventdate,type) 
SELECT NOW(),'task_cooperativeworkdaily_eventreminder' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE type='task_cooperativeworkdaily_eventreminder');

INSERT INTO ld_sys_event(eventdate,type) 
SELECT NOW(),'task_cooperativeworkweek_eventreminder' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE type='task_cooperativeworkweek_eventreminder');


INSERT INTO ld_sys_event(eventdate,type) 
SELECT NOW(),'task_cooperativeworkmonth_eventreminder' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE type='task_cooperativeworkmonth_eventreminder');


DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%') AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkdaily_eventreminder') THEN
		CALL task_cooperativework_dailyreport_reminder();
		UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkdaily_eventreminder';
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkweek_eventreminder')  THEN
		CALL task_cooperativework_weekreport_reminder();
		UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkweek_eventreminder';
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_monthreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkmonth>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkmonth_eventreminder')  THEN
		CALL task_cooperativework_monthreport_reminder();
		UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkmonth_eventreminder';
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_dailyreport_reminder`;
delimiter ||
CREATE  PROCEDURE `task_dailyreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE d.`name`='ReportLog'
			AND permissions=0
			AND a.`status`='Active';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE dailyreminddate LIKE '%:%') AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_dailyreport_reminder') THEN
		SET @remind='不提醒';
		SELECT IFNULL(dailyreminddate,'不提醒') INTO @remind FROM ld_workremindset LIMIT 1;
		
		SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '日报提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE();

		IF @remind<>'不提醒' AND WEEKDAY(NOW())<5 AND @cnt=0 AND DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 HOUR),'%H:%i')>=@remind AND DATE_FORMAT(NOW(),'%H:%i')<=@remind THEN
			OPEN Mycur;
			FETCH Mycur INTO tmp_id;
			WHILE (tmp_id IS NOT NULL) DO
				IF NOT EXISTS (SELECT 1 FROM ld_dailyreport WHERE startdate=CURDATE() AND dstatus=1 AND smcreatorid=tmp_id) THEN
					SET @content=CONCAT('日报提交提醒：您该提交日报啦，还有一个小时就到提交期限哦');
					CALL ldcrm_add_reminder(@content,tmp_id,'ReportLog',0);
				END IF;
			FETCH Mycur INTO tmp_id;
			END WHILE;
			CLOSE Mycur;

			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_dailyreport_reminder';
		END IF;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN

	IF EXISTS (SELECT 1 FROM ld_account_set WHERE `status`=0) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
		UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';	
		call account_singlerecycle_normal_rule();
		call account_singlerecycle_highsea_rule();
		call account_singlerecycle_normal_rule_beforeremind();
		call account_singlerecycle_highsea_rule_beforeremind();
	END IF;

end ||
delimiter;


DROP EVENT IF EXISTS `lingdang_public_account_event`;
CREATE EVENT `lingdang_public_account_event` ON SCHEDULE EVERY 5 MINUTE STARTS CONCAT('2019-06-21 ',floor(rand()*24),':',floor(rand()*60),':',floor(rand()*60)) ON COMPLETION NOT PRESERVE ENABLE DO 
call execute_account_publicoperation();
delimiter;

update ld_desk set fieldlabel='设置全部普通成员可编辑的字段' where labelbol='ALLOWEDITUSERFIELD' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Set the editable fields for all common members' where labelbol='ALLOWEDITUSERFIELD' and labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='设置工作汇报提交期限' where labelbol='LBL_REMIND_SET_DESCRIPTION' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Set deadline for submission of work report' where labelbol='LBL_REMIND_SET_DESCRIPTION' and labeltype='fixedstr' and languagetype='en';
delimiter;
-- 2019-12-11

SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='validfrom'; 
SET @fieldname='validfrom'; 
SET @zh='有效期起'; 
SET @en='有效期起'; 
SET @uitype=5; 
SET @typeofdata='D~M';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype=NULL;
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

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
ALTER TABLE ld_pricebook MODIFY COLUMN validfrom DATE;




SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='validtill'; 
SET @fieldname='validtill'; 
SET @zh='有效期止'; 
SET @en='有效期止'; 
SET @uitype=5; 
SET @typeofdata='D~M';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype=NULL;
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

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
ALTER TABLE ld_pricebook MODIFY COLUMN validtill DATE;

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

select tabid into @tabid from ld_tab where name='customreport' ;
select GROUP_CONCAT( DISTINCT profileid)  into @allprofileids  from  ld_profile2standardpermissions
where  tabid=@tabid and ld_profile2standardpermissions.profileid not in(select DISTINCT profileid  from ld_profile2standardpermissions where tabid=@tabid and operation=3);
delete from ld_profile2standardpermissions where FIND_IN_SET(profileid,@allprofileids) 
and tabid=@tabid;
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select '150','reference' from dual
where not exists(select * from ld_ws_referencetype where type='PurchaseOrder');

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=150;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'PurchaseOrder' from dual
where not exists(select * from ld_ws_referencetype where type='PurchaseOrder' and fieldtypeid=@fieldtypeid);
delimiter;


DROP PROCEDURE IF EXISTS `drop_event_task_dailyreport_reminder_20191209`;
delimiter ||
CREATE PROCEDURE `drop_event_task_dailyreport_reminder_20191209`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ReportLog' AND presence IN (1,5)) THEN
		DELETE FROM ld_tab WHERE `name`='ReportLog';
		DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET';
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	ELSEIF NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ReportLog') THEN
		DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET';
		DROP EVENT IF EXISTS `task_dailyreport_reminder`;
		DROP EVENT IF EXISTS `task_monthreport_reminder`;
		DROP EVENT IF EXISTS `task_weekreport_reminder`;
	END IF;
end ||
delimiter;


CALL drop_event_task_dailyreport_reminder_20191209();
DROP PROCEDURE IF EXISTS `drop_event_task_dailyreport_reminder_20191209`;
-- 2019-12-13

SET @module='Accounts';
SET @template_name='account_buy_products.mrt';
SET @display_name='产品出库记录';
SET @databasetype='crmlink';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module LIMIT 1);
SET @related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Customreport' LIMIT 1);
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,type,related_coltable)
SELECT @relation_id+1,@tabid,@related_tabid,@template_name,@seq+1,@display_name,0,'datacategory_template_js',@databasetype FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE `name`=@template_name AND tabid=@tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

CALl AddColumn('ld_callbutler','potentialid','int','19','');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CALLCENTERREPORT','呼叫中心报表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT'
                                               and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CALLCENTERREPORT','Call center report','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT' and Labeltype='fixedstr' and languagetype='en');
delimiter;


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

UPDATE ld_version SET old_version='V7.9.9.1',current_version='V7.9.9.1',remark='V7.9.9.1-20191213',wx_version='V7.9.9.2';
delimiter;