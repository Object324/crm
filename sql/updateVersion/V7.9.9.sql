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
delimiter;


update ld_desk set fieldlabel='设置工作汇报提交期限' where labelbol='LBL_REMIND_SET_DESCRIPTION' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel=' Set deadline for submission of work report ' where labelbol='LBL_REMIND_SET_DESCRIPTION' and labeltype='fixedstr' and languagetype='en';
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

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'bill_street';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',2,@col_name,'list' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'list' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'accountname';
insert into ld_map_field(module,sequence,columnname,map_type)
select 'Accounts',0,@col_name,'detail' from DUAL
where not exists(select 1 from ld_map_field where module = 'Accounts' and map_type = 'detail' and columnname = @col_name);
delimiter;

select CONCAT(tablename,':',columnname,':',fieldname,':','Accounts_fieldlabel',':',typeofdata) into @col_name from ld_field where tabid = 6 and columnname = 'bill_street';
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


SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='lastcontactdate'; 
SET @fieldname='lastcontactdate'; 
SET @zh='最新联系日期'; 
SET @en='最新联系日期'; 
SET @uitype=70; 
SET @typeofdata='datetime';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='textarea';
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
ALTER TABLE ld_leads MODIFY COLUMN lastcontactdate DATE;

SET @modulename='Leads';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='lastcontent'; 
SET @fieldname='lastcontent'; 
SET @zh='最新进展'; 
SET @en='最新进展'; 
SET @uitype=21; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='textarea';
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
ALTER TABLE ld_leads MODIFY COLUMN lastcontent TEXT;

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

UPDATE ld_leads a
LEFT JOIN (
	SELECT
		leads_id,
		contactdate,
		content
	FROM (
		SELECT
			leads_id,
			contactdate,
			content
		FROM ld_contactrecords
		WHERE deleted=0
			AND approvestatus<>'已拒绝'
			AND leads_id>0
		ORDER BY leads_id,contactdate DESC
	) tmp
	GROUP BY leads_id
) b ON b.leads_id=a.leadsid
SET a.lastcontactdate=b.contactdate,
	a.lastcontent=b.content;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PROMOTERRORREASON','单据[%s]推进失败！原因：%s字段不能为空!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PROMOTERRORREASON' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PROMOTERRORREASON','Document [%s] failed to advance! Reason: %s cannot be empty!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PROMOTERRORREASON' and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChangemodulestatusError','单据[%s]更改%s失败！原因：%s字段不能为空','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ChangemodulestatusError' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChangemodulestatusError','Document [%s] failed  to change %s! Reason: %s cannot be empty!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ChangemodulestatusError' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChangemodulestatusSuccess','单据[%s]更改%s成功！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ChangemodulestatusSuccess' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChangemodulestatusSuccess','Document [%s] change %s success!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ChangemodulestatusSuccess' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllocateSmownerError','单据[%s]分配失败！原因：%s字段不能为空！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AllocateSmownerError' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllocateSmownerError','Document  [%s] distribution failed! Reason: %s field cannot be empt','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AllocateSmownerError' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FieldCANNOTEMPTY','字段不能为空!','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='FieldCANNOTEMPTY' and languagetype='zh' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FieldCANNOTEMPTY','Field can not be empty!','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='FieldCANNOTEMPTY' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWEDITUSERFIELD','设置允许成员自行编辑的字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOWEDITUSERFIELD' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWEDITUSERFIELD','Set the fields that members can edit by themselves','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ALLOWEDITUSERFIELD' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_field','profileeditfield','varchar',50,'yes');
delimiter;
alter table ld_field alter column profileeditfield set default 'yes';
delimiter;
select tabid into @tabid from ld_tab where name='Users';
update ld_field set profileeditfield='yes' where tabid=@tabid and columnname in('user_password','confirm_password','phone_mobile','phone_home','email1','imagename')
and profileeditfield is null ;
delimiter;
select tabid into @tabid from ld_tab where name='Users';
update ld_field set profileeditfield='no' where tabid=@tabid and columnname not in('user_password','confirm_password','phone_mobile','phone_home','email1','imagename')
and profileeditfield is null ;
delimiter;

select tabid into @tabid from ld_tab where name='Users';
update ld_field set profileeditfield='yes' where tabid<>@tabid and profileeditfield is null;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportExcel','导出Excel','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='exportexcel');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportExcel','Export Excel','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='exportexcel');
delimiter;
select max(actionid) into @maxactionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @maxactionid+1,'ExportExcel',0,'ExportExcel' from dual where not exists(select 1 from ld_actionmapping where actionname='exportexcel');
delimiter;
select max(actionid) into @maxactionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @maxactionid+1,'Print',0,'PRINT' from dual where not exists(select 1 from ld_actionmapping where actionname='Print');
delimiter;

select max(actionid) into @maxactionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @maxactionid+1,'SaveReportStore',0,'SaveReportStore' from dual where not exists(select 1 from ld_actionmapping where actionname='SaveReportStore');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveReportStore','保存报表','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='SaveReportStore');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveReportStore','Save Report','fixedstr' from dual where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='SaveReportStore');
delimiter;
select actionid into @operation from ld_actionmapping where actionname='print';
select tabid into @tabid from ld_tab where name='OftenUseReport';
select max(sequence) into @maxsequence from ld_profileallpermission  where tabid=@tabid ;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,@maxsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);

select max(sequence) into @sequence from ld_profile2standardpermissions  where tabid=@tabid;
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select distinct ld_profile.profileid,@tabid,@operation,0,@sequence+1 from ld_profile  
INNER JOIN ld_profile2standardpermissions on ld_profile.profileid=ld_profile2standardpermissions.profileid
where not EXISTS(select 1 from ld_profile2standardpermissions where tabid=@tabid and operation=@operation);
delimiter;


select actionid into @operation from ld_actionmapping where actionname='ExportExcel';
select tabid into @tabid from ld_tab where name='OftenUseReport';
select max(sequence) into @maxsequence from ld_profileallpermission  where tabid=@tabid ;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,@maxsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);

select max(sequence) into @sequence from ld_profile2standardpermissions  where tabid=@tabid;
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select distinct ld_profile.profileid,@tabid,@operation,0,@sequence+1 from ld_profile  
INNER JOIN ld_profile2standardpermissions on ld_profile.profileid=ld_profile2standardpermissions.profileid
where not EXISTS(select 1 from ld_profile2standardpermissions where tabid=@tabid and  operation=@operation);
delimiter;

select actionid into @operation from ld_actionmapping where actionname='print';
select tabid into @tabid from ld_tab where name='customreport';
select max(sequence) into @maxsequence from ld_profileallpermission  where tabid=@tabid;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,@maxsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);

select IFNULL(max(sequence),0) into @sequence from ld_profile2standardpermissions  where tabid=@tabid;
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select distinct ld_profile.profileid,@tabid,@operation,0,@sequence+1 from ld_profile  
INNER JOIN ld_profile2standardpermissions on ld_profile.profileid=ld_profile2standardpermissions.profileid
where not EXISTS(select 1 from ld_profile2standardpermissions where tabid=@tabid and  operation=@operation);
delimiter;

select actionid into @operation from ld_actionmapping where actionname='savereportstore';
select tabid into @tabid from ld_tab where name='customreport';
select max(sequence) into @maxsequence from ld_profileallpermission  where tabid=@tabid;
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,@maxsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);

select IFNULL(max(sequence),0) into @sequence from ld_profile2standardpermissions  where tabid=@tabid;
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select distinct ld_profile.profileid,@tabid,@operation,0,@sequence+1 from ld_profile  
INNER JOIN ld_profile2standardpermissions on ld_profile.profileid=ld_profile2standardpermissions.profileid
where not EXISTS(select 1 from ld_profile2standardpermissions where tabid=@tabid and  operation=@operation) ;
delimiter;
-- 2019-12-06

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
		CALL task_cooperativeworkdaily_eventreminder();
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
		CALL task_cooperativeworkweek_eventreminder();
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
		CALL task_cooperativeworkdaily_eventreminder();
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
		CALL task_cooperativeworkweek_eventreminder();
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

UPDATE ld_version SET old_version='V7.9.9',current_version='V7.9.9',remark='V7.9.9-20191206',wx_version='V7.9.9';
delimiter;