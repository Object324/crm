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

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;

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

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress' LIMIT 1);
SET @tablabel=(SELECT fieldlabel FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@tabid AND languagetype='zh' AND trantable='ld_tab' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tablename='ld_projectprogress' AND columnname='projectprogress_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='项目日志编号' WHERE Relateid=@filedid AND trantable='ld_field' AND languagetype='zh' AND @tablabel='项目日志';
delimiter;

UPDATE ld_desk SET fieldlabel='导入明细' WHERE labelbol='IMPORTENTRY' AND languagetype='zh';
delimiter

UPDATE ld_desk SET fieldlabel='全局快速授权' WHERE labelbol='SELECTTHESELECTEDPERMISSIONS' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='授权' WHERE labelbol='OPENMODULE' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='除权' WHERE labelbol='CLOSE' AND languagetype='zh' AND Labeltype='jspop';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_ADDTABLE_LIKETABLE`;
delimiter ||
CREATE PROCEDURE `ldcrm_ADDTABLE_LIKETABLE`(
)
BEGIN

	CREATE TABLE IF NOT EXISTS ld_reminds_accepted LIKE ld_reminds;

end ||
delimiter;

CALL ldcrm_ADDTABLE_LIKETABLE();
DROP PROCEDURE IF EXISTS `ldcrm_ADDTABLE_LIKETABLE`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_remindsdata_transfer`;
delimiter ||
CREATE PROCEDURE `ldcrm_remindsdata_transfer`(
)
BEGIN

	DECLARE tmp_dataids MEDIUMTEXT DEFAULT NULL;

	
	DECLARE REMIND_CUSOR CURSOR FOR 
		SELECT
			GROUP_CONCAT(remindsid) AS ids
		FROM (
			SELECT 
				remindsid
			FROM ld_reminds 
			WHERE date_time<DATE_SUB(CURDATE(),INTERVAL 1 MONTH)
				AND (
					status_rmd='已读' 
					OR push_to_yzj=3
					OR push_to_weixin=3 
					OR push_to_ding=3
			)
			LIMIT 1000
		) a;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_dataids = NULL;

	OPEN REMIND_CUSOR; 
	FETCH REMIND_CUSOR INTO tmp_dataids;
	WHILE(tmp_dataids IS NOT NULL) DO
		INSERT INTO ld_reminds_accepted
		SELECT * FROM ld_reminds WHERE FIND_IN_SET(remindsid,tmp_dataids);

		DELETE FROM ld_reminds WHERE FIND_IN_SET(remindsid,tmp_dataids);

		FETCH REMIND_CUSOR INTO tmp_dataids;
	END WHILE;
	CLOSE REMIND_CUSOR;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_remindsdata_delete`;
delimiter ||
CREATE PROCEDURE `ldcrm_remindsdata_delete`(
)
BEGIN

	DECLARE tmp_deldataids MEDIUMTEXT DEFAULT NULL;

	
	DECLARE REMIND_DELCUSOR CURSOR FOR 
		SELECT
			GROUP_CONCAT(remindsid) AS ids
		FROM (
			SELECT 
				remindsid
			FROM ld_reminds_accepted 
			WHERE date_time<DATE_SUB(CURDATE(),INTERVAL 3 MONTH)
			LIMIT 200
		) a;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_deldataids = NULL;

	OPEN REMIND_DELCUSOR; 
	FETCH REMIND_DELCUSOR INTO tmp_deldataids;
	WHILE(tmp_deldataids IS NOT NULL) DO
		DELETE FROM ld_reminds_accepted WHERE FIND_IN_SET(remindsid,tmp_deldataids);
		DELETE FROM ld_crmentity WHERE setype='Reminds' AND FIND_IN_SET(crmid,tmp_deldataids);
		FETCH REMIND_DELCUSOR INTO tmp_deldataids;
	END WHILE;
	CLOSE REMIND_DELCUSOR;

end ||
delimiter;

DROP EVENT IF EXISTS `ldcrm_remindsdata_transfer_every1mintue`;
delimiter ||
CREATE  EVENT `ldcrm_remindsdata_transfer_every1mintue` ON SCHEDULE EVERY 1 MINUTE STARTS NOW() ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_remindsdata_transfer();
||
delimiter;

DROP EVENT IF EXISTS `ldcrm_remindsdata_delete_every5mintue`;
DROP EVENT IF EXISTS `ldcrm_remindsdata_delete_every10second`;
delimiter ||
CREATE  EVENT `ldcrm_remindsdata_delete_every10second` ON SCHEDULE EVERY 10 SECOND STARTS NOW() ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_remindsdata_delete();
||
delimiter;
-- 2022-04-01

call AddColumn('ld_approvestep','emptyapproverdeal','text','','');
delimiter;

SET @labelbol = 'WHENAPPROVERISEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批人为空时','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'When approver is empty','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTOMATICPASS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自动通过','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Automatic pass','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTPFORWARDTOADMIN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自动转交管理员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Auto forward to admin','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTOMATICPASSDESC';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当用户、角色或职位级别为空时，审批单将自动通过','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'When the user, role or position level is blank, the approval document will pass automatically','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTPFORWARDTOADMINDESC';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当用户、角色或职位级别为空时，审批单将自动转交给管理员（管理员为已启用的所有管理员）','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'When the user, role or position level is blank, the approval form will be automatically transferred to the admin (admin are all enabled admin)','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTPFORWARDTOUSERDESC';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当用户、角色或职位级别为空时，审批单将自动转交给指定成员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'When the user, role or position level is blank, the approval document will be automatically forwarded to the specified member','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTOMATICPASSRESULT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该步骤没有审批人，自动通过','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'There is no approver for this step, so it had been passed automatically','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTPFORWARDTOADMINRESULT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该步骤没有审批人，自动转交管理员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This step has no approver and will be automatically forwarded to the admin','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTPFORWARDTOUSERRESULT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该步骤没有审批人，自动转交指定成员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This step has no approver and is automatically forwarded to the designated member','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddApprover','添加审批人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddApprover' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddApprover',"Add approver",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddApprover' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddApprover','添加审批人','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddApprover' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddApprover',"Add approver",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddApprover' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVALSTEP','审批步骤','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVALSTEP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVALSTEP',"Approval step",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APPROVALSTEP' and labeltype='jspop');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
SET @relatedid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'kis_no');
UPDATE ld_tranlabel set fieldlabel = 'Leads upgrade status' 
where tabid = @tabid and trantable = 'ld_field' and Relateid = @relatedid AND languagetype = 'en' and fieldlabel = '是否来源销售线索';
delimiter;
-- 2022-04-07


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

UPDATE ld_version SET old_version='V8.4.5.8.3',current_version='V8.4.5.8.3',remark='V8.4.5.8.3-20220407',wx_version='V8.4.5.8.2';
delimiter;