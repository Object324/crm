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

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name` = 'ldsoukebao');
update ld_tranlabel set fieldlabel = '找企业' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'zh';
delimiter;

drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240415;
delimiter ||
create PROCEDURE crm_addtab_intoprofile_20240415
(
	tabname varchar(100),
	operation int(10)
)
BEGIN
	declare var_profileid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
declare continue handler  for not   found  SET done =1;
	set @sql='select tabid into @tabid from ld_tab  where ';
	set @sql=CONCAT(@sql, " name='",tabname,"'");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
open cur1;
Fetch cur1 into var_profileid;
loop1: while  done<>1 DO

        set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
        set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
        set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
        set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

Fetch cur1 into var_profileid;
end while loop1;
close cur1;
end ||
delimiter;

call crm_addtab_intoprofile_20240415('ldsoukebaomap',3);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240415;
delimiter;

UPDATE ld_tab SET presence=0,mobilepresence=0 WHERE `name` IN ('ldsoukebao','ldsoukebaomap');

UPDATE ld_relatedlists SET presence=1,mobile_presence=1 WHERE tabid=14 AND related_tabid IN (20,21,22,23,37,6,7,4,2,13) AND (SELECT COUNT(1) FROM ld_products WHERE deleted=0)<=2;
delimiter;
-- 2024-04-15

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name` = 'ldsoukebao');
update ld_tranlabel set fieldlabel = '找企业' where trantable = 'ld_tab' and tabid = @tabid and languagetype = 'zh';
delimiter;

drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240415;
delimiter ||
create PROCEDURE crm_addtab_intoprofile_20240415
(
	tabname varchar(100),
	operation int(10)
)
BEGIN
	declare var_profileid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
declare continue handler  for not   found  SET done =1;
	set @sql='select tabid into @tabid from ld_tab  where ';
	set @sql=CONCAT(@sql, " name='",tabname,"'");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
open cur1;
Fetch cur1 into var_profileid;
loop1: while  done<>1 DO

        set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
        set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
        set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
        set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;

Fetch cur1 into var_profileid;
end while loop1;
close cur1;
end ||
delimiter;

call crm_addtab_intoprofile_20240415('ldsoukebaomap',3);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile_20240415;
delimiter;

UPDATE ld_tab SET presence=0,mobilepresence=0 WHERE `name` IN ('ldsoukebao','ldsoukebaomap');

update ld_tab set mobilepresence='weixin' where tabid>=359 and tabid<=364 and mobilepresence is null ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTRYNOTEXIST','该分录信息不存在','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTRYNOTEXIST' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTRYNOTEXIST','The entry information does not exist','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTRYNOTEXIST' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Events');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename='ld_loopcalendar_reminds';
SET @columnname='reminder_description';
SET @fieldname='reminder_description';
SET @zh='提醒设置';
SET @en='Reminder setting';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=3;
SET @displaytype=3;
SET @bigtype='text';
SET @datarang='';
SET @maxrowsshow=0;
SET @presence=0;
SET @defaultvalue='';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,@defaultvalue,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
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


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Events');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename='ld_loopcalendar_reminds';
SET @columnname='loop_description';
SET @fieldname='loop_description';
SET @zh='循环设置';
SET @en='Loop setting';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=3;
SET @displaytype=3;
SET @bigtype='text';
SET @datarang='';
SET @maxrowsshow=0;
SET @presence=0;
SET @defaultvalue='';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,@defaultvalue,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
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

CREATE TABLE IF NOT EXISTS `ld_loopcalendar_reminds` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`activityid` int(11) NOT NULL,
	`loop_type` varchar(25) DEFAULT 'norepeat' COMMENT '循环类型',
	`loop_month` varchar(255) DEFAULT NULL COMMENT "循环月份所选月",
	`loop_dayvalue` varchar(25) DEFAULT NULL COMMENT "既用来保存所选周1-7,也用来存储月份选择的日期1-31,最后一天lastday",
	`loop_description` varchar(255) DEFAULT NULL COMMENT "列表显示的针对循环日程的描述内容",
	`reminder_setting` varchar(255) DEFAULT NULL COMMENT "提醒设置",
	`reminder_description` varchar(255) DEFAULT NULL COMMENT "提醒设置描述",
	`expiredate` date DEFAULT NULL COMMENT "到期日期",
	PRIMARY KEY (`id`) USING BTREE,
	INDEX idx_activityid (activityid)
	) ENGINE=InnoDB;
delimiter;

INSERT INTO ld_sys_event(eventdate,type)
SELECT '','LoopCalendarCreateRemind' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE type='LoopCalendarCreateRemind');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LoopSchedule','循环日程','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LoopSchedule' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LoopSchedule','Loop schedule','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LoopSchedule' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReminderSettings','提醒设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReminderSettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReminderSettings','Reminder settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ReminderSettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExpireDate','到期日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExpireDate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExpireDate','Expiration date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExpireDate' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ExpireDateCanNotLTStartTime','到期日期不能小于开始时间','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ExpireDateCanNotLTStartTime' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ExpireDateCanNotLTStartTime','The expiration date cannot be less than the start time','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ExpireDateCanNotLTStartTime' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKDUPNUMBER','在所有销售线索和客户中进行查重，最多只显示符合条件的前{Var}条数据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKDUPNUMBER' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKDUPNUMBER','check in all of the Leads and Accounts, only the first {Var} qualifying data.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHECKDUPNUMBER' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','JOINTCHECKDUPLICATE','联合查重','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='JOINTCHECKDUPLICATE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','JOINTCHECKDUPLICATE','Joint check of duplicate','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='JOINTCHECKDUPLICATE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENABLEJOINTCHECKDUPLICATE','开启联合查重','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENABLEJOINTCHECKDUPLICATE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENABLEJOINTCHECKDUPLICATE','Enable joint review','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENABLEJOINTCHECKDUPLICATE' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_option_module','signinmappingrule','varchar',10,'');
call AddColumn('ld_option_module','signinmappingcontent','text',0,'');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
SET @trigger_fieldid = (select fieldid from ld_field where `tabid` = @tabid and columnname = 'source_list');
SET @effect_fieldid = (select fieldid from ld_field where `tabid` = @tabid and columnname = 'entityaddress');
SET @fromvalue_info = (select fromvalue_info from ld_related_field WHERE trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid and fromvalue_type = 'sql' LIMIT 1);

UPDATE ld_option_module SET signinmappingrule = 'sql',signinmappingcontent = @fromvalue_info WHERE `tabid` = @tabid AND signinmappingrule is null AND signinmappingcontent is null;

SET @option_tabid = (select tabid from ld_tab where `name` = 'Accounts');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(IFNULL(ld_account.bill_state,""),IFNULL(ld_account.bill_city,""),IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS tmp_value FROM ld_account WHERE ld_account.deleted = 0 AND accountid = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='Accounts' and from_module='Singin');

SET @option_tabid = (select tabid from ld_tab where `name` = 'Leads');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(ld_leads.bill_state,ld_leads.bill_city,IFNULL(ld_leads.bill_area,""),ld_leads.bill_street) AS tmp_value FROM ld_leads	WHERE deleted = 0 AND leadsid = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='Leads' and from_module='Singin');

SET @option_tabid = (select tabid from ld_tab where `name` = 'HelpDesk');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(IFNULL(ld_account.bill_state,""),IFNULL(ld_account.bill_city,""),IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS tmp_value FROM ld_troubletickets INNER JOIN ld_account ON ld_account.accountid = ld_troubletickets.accountid WHERE ld_account.deleted = 0 AND ld_troubletickets.ticketid = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='HelpDesk' and from_module='Singin');

SET @option_tabid = (select tabid from ld_tab where `name` = 'Contacts');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(IFNULL(ld_account.bill_state,""),IFNULL(ld_account.bill_city,""),IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS tmp_value FROM ld_contactdetails INNER JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid WHERE ld_account.deleted = 0 AND ld_contactdetails.contactid = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='Contacts' and from_module='Singin');

SET @option_tabid = (select tabid from ld_tab where `name` = 'ContactRecords');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(IFNULL(ld_account.bill_state,""),IFNULL(ld_account.bill_city,""),IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS tmp_value FROM ld_contactrecords INNER JOIN ld_account ON ld_account.accountid = ld_contactrecords.accountid WHERE ld_account.deleted = 0 AND ld_contactrecords.contactrecordID = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='ContactRecords' and from_module='Singin');

SET @option_tabid = (select tabid from ld_tab where `name` = 'Potentials');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(IFNULL(ld_account.bill_state,""),IFNULL(ld_account.bill_city,""),IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS tmp_value FROM ld_potential INNER JOIN ld_account ON ld_account.accountid = ld_potential.accountid WHERE ld_account.deleted = 0 AND ld_potential.potentialid = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='Potentials' and from_module='Singin');

SET @option_tabid = (select tabid from ld_tab where `name` = 'Project');
UPDATE ld_option_module SET signinmappingcontent = 'SELECT CONCAT(IFNULL(ld_account.bill_state,""),IFNULL(ld_account.bill_city,""),IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS tmp_value FROM ld_project INNER JOIN ld_account ON ld_account.accountid = ld_project.accountid WHERE ld_account.deleted = 0 AND ld_project.projectid = {Record.ID}' 
WHERE `tabid` = @tabid AND option_tabid = @option_tabid AND signinmappingrule = 'sql'
and NOT EXISTS(select 1 from ld_singin where entitytype='Project' and from_module='Singin');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
SET @trigger_fieldid = (select fieldid from ld_field where `tabid` = @tabid and columnname = 'source_list');
SET @effect_fieldid = (select fieldid from ld_field where `tabid` = @tabid and columnname = 'entityaddress');
DELETE FROM ld_related_field WHERE trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid and fromvalue_type = 'sql' LIMIT 1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChooseModuleFields','选择模块字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ChooseModuleFields' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChooseModuleFields','Choose module fields','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ChooseModuleFields' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VisitingAddressMappingRule','拜访地址映射规则','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitingAddressMappingRule' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VisitingAddressMappingRule','Visiting address mapping rule','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitingAddressMappingRule' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VisitingAddressMappingSQL','拜访地址映射SQL','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitingAddressMappingSQL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VisitingAddressMappingSQL','Visiting address mapping SQL','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitingAddressMappingSQL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VisitingAddressMappingFields','拜访地址映射字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitingAddressMappingFields' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VisitingAddressMappingFields','Visiting address mapping fields','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitingAddressMappingFields' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectModuleRecordID','所选模块单据的ID：{Record.ID}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SelectModuleRecordID' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectModuleRecordID','The selected module document`s ID:{Record.ID}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SelectModuleRecordID' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VisitAddressGetFirstOne','拜访地址将取SQL查询结果第一行第一个','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitAddressGetFirstOne' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VisitAddressGetFirstOne','The visiting address will be taken as the first line, first item in the SQL query result','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitAddressGetFirstOne' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VisitAddressMustInclude','拜访地址中必须包含省份和城市，请输入准确的地址！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitAddressMustInclude' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VisitAddressMustInclude','The visiting address must include the province and city, please enter an accurate address!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VisitAddressMustInclude' and Labeltype='fixedstr' and languagetype='en');
delimiter;


CALL addtableIndex('ld_troubletickets','servicetype','servicetype');
CALL addtableIndex('ld_picklist_values','listvalue','listvalue');
CALL addtableIndex('ld_servicereturn','troubleticketid','troubleticketid');
CALL addtableIndex('ld_picklist_set','listname','listname');
CALL addtableIndex('ld_picklist_set','relatetable','relatetable');


CALL addtableIndex('ld_troubletickets','accountid','accountid');
delimiter;

UPDATE ld_option_module SET datarang='permit' WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Singin') AND NOT EXISTS (SELECT 1 FROM ld_singin);
ALTER TABLE ld_approvelog MODIFY COLUMN seqtime timestamp(6) NULL DEFAULT NULL AFTER logconcurrentid;
-- 2024-04-19

CALL addtableIndex('ld_setscoperhigher','modulename','modulename');
CALL addtableIndex('ld_setscoperhigher','scopeauthority','scopeauthority');
CALL addtableIndex('ld_setscoperhigher','userid','userid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnableOneRule','请至少启用一个规则','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnableOneRule' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnableOneRule','Please enable at least one rule','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnableOneRule' and Labeltype='fixedstr' and languagetype='en');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','DATE','日期', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DATE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','DATE','Date', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DATE' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','JobBriefDetails','工作简报详情', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'JobBriefDetails' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','JobBriefDetails','Job brief details', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'JobBriefDetails' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','COMMENTNOW','现在点评', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'COMMENTNOW' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','COMMENTNOW','Comment now', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'COMMENTNOW' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','MORE','更多', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'MORE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','MORE','More', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'MORE' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','FORWARDING','转发', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'FORWARDING' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','FORWARDING','Forwarding', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'FORWARDING' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','DELETE','删除', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DELETE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','DELETE','Delete', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DELETE' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','Reply','回复', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'Reply' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','Reply','Reply', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'Reply' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','DATE','日期', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'DATE' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','DATE','Date', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'DATE' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','thisweek','本周', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'thisweek' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','thisweek','This Week', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'thisweek' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','lastweek','上周', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'lastweek' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','lastweek','Last Week', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'lastweek' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','beflastweek','上上周', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'beflastweek' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','beflastweek','The Week Before Last', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'beflastweek' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','lastmonth','上月', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'lastmonth' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','lastmonth','Last Month', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'lastmonth' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','beflastmonth','上上月', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'beflastmonth' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','beflastmonth','The Month Before Last', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'beflastmonth' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','thismonth','本月', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'thismonth' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','thismonth','This Month', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'thismonth' AND labeltype = 'fixedstr' );
delimiter;
INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','SELECTREVIEWERS','选择点评人', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'SELECTREVIEWERS' AND labeltype = 'fixedstr' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','SELECTREVIEWERS','Select reviewers', 'fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'SELECTREVIEWERS' AND labeltype = 'fixedstr' );
delimiter;

ALTER TABLE `ld_loopcalendar_reminds` MODIFY COLUMN loop_dayvalue VARCHAR(255);
delimiter;

UPDATE ld_field set masseditable = 2 where bigtype = 'reference' and columnname = 'accountid' and masseditable = 0 
and tabid in (SELECT ld_tab.tabid from ld_tab where LOCATE('CustomForm',ld_tab.`name`) >0); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SIGNINANDOUTTIP','您不是当前签到记录的负责人，不允许签退/补签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SIGNINANDOUTTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SIGNINANDOUTTIP',"You are not the person responsible for the current sign-in record and are not allowed to sign out/supplementary sign ou",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SIGNINANDOUTTIP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKDUPTIP','在{$Leads.Leads}或{$Accounts.Accounts}不能重复','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKDUPTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKDUPTIP','cannot be duplicated in the {$Leads.Leads} or {$Accounts.Accounts} ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHECKDUPTIP' and labeltype='fixedstr');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'SocialPromotion');
UPDATE ld_field SET presence = 1 WHERE tabid = @tabid and columnname = 'h5pageurl';
UPDATE ld_field SET presence = 1 WHERE tabid = @tabid and columnname = 'h5pagebutton';
UPDATE ld_field SET presence = 1 WHERE tabid = @tabid and columnname = 'H5buttoncolor';
UPDATE ld_field SET allowedit = 'no' WHERE tabid = @tabid and columnname = 'social_activitytype';
delimiter;

SET @module='CustomForm45';
SET @rel_module='Attachment';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm45');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
DELETE FROM ld_relatedlists
WHERE tabid=@tabid  AND related_tabid=@rel_tabid AND `name`=@template AND type='datacategory_sql' AND related_coltable='attachmentsforbills.related_to';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','attachmentsforbills.related_to' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

UPDATE ld_desk SET fieldlabel='您的{module}被{operator}在{nowtime}正在尝试报备，请联系{operator}，联系电话：{operatorphone}' WHERE labelbol='REMINDOPEAFORHEDGING' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel=' Your {module} is trying to report by the {operator} at {nowtime}. Please contact the {operator} at {operatorphone}' WHERE labelbol='REMINDOPEAFORHEDGING' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

UPDATE ld_listview_btn SET btntype = 'both' WHERE `name` = 'Export' and btntype = 'rely' and iconname != '';
delimiter;
-- 2024-04-23

DROP PROCEDURE IF EXISTS `ldcrm_reset_caidan_20240423`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_caidan_20240423`(
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ld_parenttab WHERE parenttab_label='RenShiGuanLi') THEN
		SET @seq=(SELECT sequence FROM ld_parenttab WHERE parenttab_label='OAForms');
		UPDATE ld_parenttab SET sequence = sequence+2 WHERE sequence>@seq;

		SET @parentid=(SELECT MAX(parenttabid)+1 FROM ld_parenttab);
		INSERT INTO ld_parenttab(parenttabid,parenttab_label,sequence,allocatetype,imagename) 
		SELECT @parentid,'RenShiGuanLi',@seq+1,'all','left_nav_oa_ico.png';

		SET @i=0;
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) ORDER BY sequence;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) VALUE ('zh','ld_parenttab',@parentid,@parentid,'人事管理');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) VALUE ('en','ld_parenttab',@parentid,@parentid,'Personnel Management');


		DELETE FROM ld_parenttabrel WHERE tabid IN (SELECT tabid FROM ld_tab WHERE name IN ('Holiday','Personnelfile','Laborcontract','Salary'));
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parentid,(SELECT tabid FROM ld_tab WHERE name='Holiday' LIMIT 1),(@i:=@i+1);

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parentid,(SELECT tabid FROM ld_tab WHERE name='Personnelfile' LIMIT 1),(@i:=@i+1);

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parentid,(SELECT tabid FROM ld_tab WHERE name='Laborcontract' LIMIT 1),(@i:=@i+1);

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parentid,(SELECT tabid FROM ld_tab WHERE name='Salary' LIMIT 1),(@i:=@i+1);

		SET @parentid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Accounts');
		SET @seq=(SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parentid AND tabid=55 LIMIT 1);
		IF @seq>0 AND NOT EXISTS (SELECT 1 FROM ld_competition) THEN
			DELETE FROM ld_parenttabrel WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Competition' LIMIT 1);

			UPDATE ld_parenttabrel SET sequence=sequence+2 WHERE parenttabid=@parentid AND sequence>@seq;
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT @parentid,(SELECT tabid FROM ld_tab WHERE name='Competition' LIMIT 1),@seq+1;
			
			SET @i=0;
			UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parentid ORDER BY sequence;
		END IF;

	END IF;
end ||
delimiter;


CALL ldcrm_reset_caidan_20240423();
DROP PROCEDURE IF EXISTS `ldcrm_reset_caidan_20240423`;


SET @deploy_type = 467;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 2,@deploy_type,'天眼查工商模糊查询开始查询字数' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNABLEVIEWDETAILS','无法查看明细','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UNABLEVIEWDETAILS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNABLEVIEWDETAILS',"Unable to view details",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UNABLEVIEWDETAILS' and labeltype='fixedstr');
delimiter;

drop PROCEDURE  if EXISTS ldcrm_transdatatype_source_list;
delimiter ||
create PROCEDURE ldcrm_transdatatype_source_list
(
)
BEGIN
	declare var_tablename VARCHAR(100);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT tablename from ld_field where columnname = 'source_list';
	declare continue handler for not found SET done =1;	
	
	open cur1;
	Fetch cur1 into var_tablename;
	loop1: while  done<>1 DO
		CALl AddColumn(var_tablename,'source_list','text',NULL,NULL);
		
		set @tmp_sql = CONCAT('ALTER table `',var_tablename,'` MODIFY COLUMN `source_list` text');
		prepare stmt from @tmp_sql;
		execute stmt;
		deallocate prepare stmt;
		Fetch cur1 into var_tablename;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_transdatatype_source_list();
drop PROCEDURE  if EXISTS ldcrm_transdatatype_source_list;
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','IMPORTCONTROL','导入控制','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'IMPORTCONTROL' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','IMPORTCONTROL','Import Control','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'IMPORTCONTROL' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','CHECKPICKLIST','校验下拉框','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CHECKPICKLIST' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CHECKPICKLIST','Verify drop-down box','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CHECKPICKLIST' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','CHECKPICKLISTCOLUMN','设置校验字段','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CHECKPICKLISTCOLUMN' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CHECKPICKLISTCOLUMN','Set verification fields','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CHECKPICKLISTCOLUMN' AND labeltype = 'fixedstr');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Users');
update ld_field set defaultvalue='Active' where defaultvalue!='Inactive' and tabid = @tabid and columnname='status';
delimiter;

UPDATE ld_desk SET fieldlabel="请填写内容" WHERE labelbol='FILLINCOMMENTS' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel="Please fill in the content" WHERE labelbol='FILLINCOMMENTS' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addmodule_bireportscreen`;
delimiter ||
CREATE PROCEDURE `ldcrm_addmodule_bireportscreen`(
)
BEGIN
    IF NOT EXISTS (select 1 from ld_tab where `name`='BIReportScreen') THEN

        select tabsequence,tabid into @tabsequence,@hometabid from ld_tab where `name` = 'ReportAnalysis';
        update ld_tab set tabsequence := tabsequence + 1 where tabsequence > @tabsequence;
        select parenttabid,sequence into @parenttabid,@homeseq from ld_parenttabrel where tabid = @hometabid limit 1;
        update ld_parenttabrel set sequence := sequence + 1 where sequence > @homeseq;

        select max(tabid) + 1 into @newtabid from ld_tab;

        insert into ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab )
        select @newtabid,'BIReportScreen',0,@tabsequence+1,'BIReportScreen',1 from dual
        where not EXISTS(select 1 from ld_tab where `name`='BIReportScreen');

        insert into ld_parenttabrel(parenttabid,tabid,sequence) value (@parenttabid,@newtabid,@homeseq+1);

        insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        select 'zh','ld_tab',@newtabid,@newtabid,'数字大屏' from dual
        where not exists(select 1 from ld_tranlabel where tabid=@newtabid and relateid=@newtabid and languagetype='zh'and trantable='ld_tab' );
        insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        select 'en','ld_tab',@newtabid,@newtabid,'Home Data Cockpit' from dual
        where not exists(select 1 from ld_tranlabel where tabid=@newtabid and relateid=@newtabid and languagetype='en' and trantable='ld_tab');

        CREATE TABLE if not EXISTS `ld_bireportscreen` (
           `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
           `project_id` varchar(255) NOT NULL COMMENT '大屏id',
           `project_name` varchar(255) COMMENT '大屏名称',
           `deleted` int(11) DEFAULT 0 COMMENT '是否删除',
           `smcreatorid` int(11) COMMENT '创建用户',
           `createdtime` datetime COMMENT '创建时间',
           `index_image` varchar(255) COMMENT '封面图片地址',
           `remarks` text  COMMENT '描述',
           PRIMARY KEY (`id`)
        ) ENGINE=InnoDB;
    END IF;
end ||
delimiter;

CALL ldcrm_addmodule_bireportscreen();
delimiter;

DELETE FROM ld_bireportscreen WHERE project_id = 'ldcrm_default_1';
INSERT INTO ld_bireportscreen(project_id,project_name,deleted,smcreatorid,createdtime,index_image)
SELECT 'ldcrm_default_1','预设大屏1',0,1,NOW(),'ldcrm_default_1_indexImg.png' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_bireportscreen WHERE project_id = 'ldcrm_default_1');
-- 2024-04-24

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

UPDATE ld_version SET old_version='V8.6.3.1',current_version='V8.6.3.1',remark='V8.6.3.1-20240424',wx_version='V8.6.3.1';
delimiter;