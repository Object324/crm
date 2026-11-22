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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOLOOKVALUE','目标值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TOLOOKVALUE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOLOOKVALUE','Target','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TOLOOKVALUE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPLETIONVALUE','完成值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPLETIONVALUE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPLETIONVALUE','Completion','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPLETIONVALUE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPLETIONRATE','完成率','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPLETIONRATE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPLETIONRATE','Completion Rate','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMPLETIONRATE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPLATIONRATESIXMONTH','最近6个月目标完成情况','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='COMPLATIONRATESIXMONTH' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPLATIONRATESIXMONTH','Achievement of goals in the last 6 months','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='COMPLATIONRATESIXMONTH' and Labeltype='fixedstr' and languagetype='en');
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
	SELECT IFNULL(cooperativeworkweek,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '周计划提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork';

	IF @remindtime<>'no' AND WEEKDAY(NOW())IN (@remindtime-2,@remindtime-1) AND @cnt=0 THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO
			IF NOT EXISTS (SELECT 1 FROM  ld_workreport where createdtime BETWEEN date_sub(curdate(),INTERVAL WEEKDAY(curdate()) + 0 DAY) and date_sub(curdate(),INTERVAL WEEKDAY(curdate()) - 6 DAY) and  type=2 AND smcreatorid=tmp_id) THEN
			SET @content='';	
			IF WEEKDAY(NOW())=@remindtime-2 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，明天是最后一天期限哦');
				ELSEIF WEEKDAY(CURDATE())=@remindtime-1 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，今天是最后一天期限哦');
				END IF;
				if @content<>'' then 
					CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			  end if;
			END IF;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;

select wx_sequence into @wx_sequence from ld_dashboard_app where name='returnamount' ;
update ld_dashboard_app set wx_sequence=wx_sequence+2 where wx_sequence>@wx_sequence;
update ld_dashboard_app set home_sequence=home_sequence+1;
insert into ld_dashboard_app(name,labelbol,modulenames,wx_sequence,image,presence,wx_presence,home_presence,home_sequence)
select 'complationRateSixMonth','COMPLATIONRATESIXMONTH','SalesGoal',@wx_sequence+1,'dashboard_4',0,1,'',0 from
dual  where not exists(select 1 from ld_dashboard_app where name='COMPLATIONRATESIXMONTH');
delimiter;


CREATE TABLE if NOT EXISTS `ld_related_producttoolfield` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`modulename` VARCHAR(100),
	`trigger_columnname` TEXT DEFAULT NULL COMMENT '触发字段',
	`effect_columnname` TEXT DEFAULT NULL COMMENT '影响字段',
	`query_sql` TEXT DEFAULT NULL COMMENT '查询脚本',
	PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

ALTER TABLE ld_related_producttoolfield MODIFY COLUMN trigger_columnname TEXT;
ALTER TABLE ld_related_producttoolfield MODIFY COLUMN effect_columnname TEXT;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVOICEAMOUNTYEAR','开票额月度同比','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INVOICEAMOUNTYEAR' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVOICEAMOUNTYEAR','Open ticket monthly year-on-year','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='INVOICEAMOUNTYEAR' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OUTBOUNDORDERAMOUNTYEAR','出库额月度同比','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OUTBOUNDORDERAMOUNTYEAR' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OUTBOUNDORDERAMOUNTYEAR','Outbound amount monthly year-on-year','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OUTBOUNDORDERAMOUNTYEAR' and Labeltype='fixedstr' and languagetype='en');
delimiter;



INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`) SELECT '', 261, '天润呼叫中心企业编号', '', 1000, NULL, NULL, 0, NULL  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE description='天润呼叫中心企业编号');
INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`) SELECT '', 262, '天润呼叫中心帐号', '', 1000, NULL, NULL, 0, NULL  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE description='天润呼叫中心帐号');
INSERT INTO ld_systems_deploy ( `deploy_value`, `deploy_type`, `description`, `setype`, `sequence`, `roottype`, `inputtype`, `presence`, `inputvalue`) SELECT '', 263, '天润呼叫中心密码', '', 1000, NULL, NULL, 0, NULL  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE description='天润呼叫中心密码');

set @deploy_type = (select deploy_type from ld_systems_deploy where  description='天润呼叫中心企业编号');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'设置天润呼叫中心企业编号' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Set enterprise number of Tianrun call center' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');

set @deploy_type = (select deploy_type from ld_systems_deploy where  description='天润呼叫中心帐号');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'天润呼叫中心帐号' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Tianrun call center account number' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');

set @deploy_type = (select deploy_type from ld_systems_deploy where  description='天润呼叫中心密码');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@deploy_type,@deploy_type,'天润呼叫中心密码' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@deploy_type,@deploy_type,'Tianrun call center password' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@deploy_type and relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;


CALL AddColumn('ld_users', 'tianrun_exten', 'VARCHAR', '25', null);
SET @tabid =(select tabid from ld_tab where name='Users');
select max(blockid) into @maxblockid from ld_blocks;
SET  @sequence = (SELECT  sequence FROM  ld_blocks WHERE blocklabel='LBL_ATTACHMENTS_INFOMATION');
UPDATE ld_blocks set sequence=sequence+1 where sequence>=@sequence;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'TIANRUN_INTERFACE_INFO',@sequence,null,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where blocklabel='TIANRUN_INTERFACE_INFO' and tabid=@tabid);
UPDATE  ld_blocks_seq SET  id=(SELECT max(blockid) FROM  ld_blocks);

SET  @blocks =(SELECT  blockid FROM  ld_blocks WHERE blocklabel='TIANRUN_INTERFACE_INFO' AND  tabid =@tabid);
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'zh', 'ld_blocks', @tabid, @blocks, '天润呼叫中心设置' FROM dual   WHERE NOT exists( SELECT  1 FROM  ld_tranlabel WHERE  tabid=@tabid AND fieldlabel='天润呼叫中心设置');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'en', 'ld_blocks', @tabid, @blocks, 'Tianrun CallCenter Setting' FROM dual   WHERE NOT exists( SELECT  1 FROM  ld_tranlabel WHERE  tabid=@tabid AND fieldlabel='Tianrun CallCenter Setting');

SET  @fieldid = (SELECT max(fieldid) FROM  ld_field);
INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`, `advance_demand`, `advance_demand_groups`) select @tabid, @fieldid+1, 'tianrun_exten', 'yes', 'ld_users', 2, '2', 'tianrun_exten', '分机号', 1, 0, NULL, NULL, 1, @blocks, 1, 'V~O', 1, NULL, NULL, 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 2, 0, 'yes', 'yes', 'yes', 'yes', 'yes', 0, 0, 'yes', 'text', NULL, 0, NULL, 'no', NULL, NULL, NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 from ld_field where tabid=@tabid and fieldname ='tianrun_exten');

SET @fieldid =(select fieldid FROM  ld_field WHERE  tabid=@tabid AND  fieldname='tianrun_exten');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'zh', 'ld_field', @tabid, @fieldid, '坐席工号' FROM dual   WHERE NOT exists( SELECT  1 FROM  ld_tranlabel WHERE  tabid=@tabid AND Relateid = @fieldid AND fieldlabel='坐席工号');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'en', 'ld_field', @tabid, @fieldid, 'Seat number' FROM dual   WHERE NOT exists( SELECT  1 FROM  ld_tranlabel WHERE  tabid=@tabid AND  Relateid = @fieldid and fieldlabel='Seat number');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tianrun_phonerecord`
(
    `id`            INT(19) UNSIGNED NOT NULL AUTO_INCREMENT,
    `uniqueid`      VARCHAR(100)              DEFAULT NULL,
    `userid`        INT(19)                   DEFAULT NULL,
    `usernum`       VARCHAR(25)               DEFAULT NULL,
    `is_bombscreen` VARCHAR(25)               DEFAULT NULL,
    `type`          VARCHAR(25)               DEFAULT NULL,
    `caller`        VARCHAR(25)               DEFAULT NULL,
    `callee`        VARCHAR(25)               DEFAULT NULL,
    `indexid`       INT(11)                   DEFAULT NULL,
    `modulename`    VARCHAR(100)              DEFAULT NULL,
    `recordnum`     TEXT,
    `starttime`     DATETIME                  DEFAULT NULL,
    `deadline`      DATETIME                  DEFAULT NULL,
    `talktime`      INT(11)          NOT NULL DEFAULT 0,
    `bridging`      VARCHAR(255)              DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8
  ROW_FORMAT = COMPACT;
delimiter;
-- 2020-09-09

CALL addtableIndex('ld_account','modifiedtime','modifiedtime');
delimiter;

UPDATE ld_blocks
SET visible =1
WHERE tabid = 29
	AND blocklabel = 'TIANRUN_INTERFACE_INFO'
	AND NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 55 AND deploy_value='天润融通旧');
-- 2020-09-11

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

UPDATE ld_version SET old_version='V8.2.2',current_version='V8.2.2',remark='V8.2.2-20200911',wx_version='V8.2.2';
delimiter;