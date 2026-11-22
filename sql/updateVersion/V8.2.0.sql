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

UPDATE ld_leads 
INNER JOIN (
	SELECT 
		a.crmid,
		a.whodid,
		MAX(a.changedon) as changedon 
	FROM ld_modtracker_basic a 
	LEFT JOIN ld_modtracker_detail b ON a.id =b.id 
	WHERE b.fieldname ='assigned_user_id' 
		AND a.module ='Leads' 
	GROUP BY a.crmid 
) AS tmp ON tmp.crmid = ld_leads.leadsid 
SET lastdistributer = tmp.whodid,
    distributiondate = DATE(tmp.changedon);
    
DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN

    IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%')  THEN
        SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE()
                                                    and content LIKE '日志提交提醒：%'  and reltab='CooperativeWork' ;
        if @cnt=0 then
            CALL task_cooperativework_dailyreport_reminder();
            UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkdaily_eventreminder';
        end if;
    END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder_exec`(
)
BEGIN

    IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3)   THEN

        SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE()
                                                    and content LIKE '周计划提交提醒：%'  and reltab='CooperativeWork' ;
        if @cnt=0 then
            CALL task_cooperativework_weekreport_reminder();
            UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkweek_eventreminder';
        end if;

    END IF;

end ||
delimiter;


SET @relation_id = (SELECT id FROM ld_relatedlists_seq );
SET @tabid = (SELECT tabid from ld_tab WHERE name ='Vendors');
SET @relationtabid = (SELECT tabid from ld_tab WHERE name ='PurchaseInquiryOrder');

INSERT INTO ld_relatedlists(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`) 
SELECT @relation_id+1, @tabid, @relationtabid, 'get_purchaseinquiryorder', 10, 'PurchaseInquiryOrder', 0, 'add', 1, 0, 'entitytype_datacategory_sql', 'tmpsourcedetail.id', 0, 0, NULL, NULL, 'yes', NULL FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid =@tabid and related_tabid = @relationtabid);

UPDATE ld_relatedlists_seq SET id =(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;


CALl AddColumn('ld_field','advance_demand','TEXT','','');
CALl AddColumn('ld_field','advance_demand_groups','TEXT','','');
delimiter;


call AddColumn("ld_producttoolprofile",'profilefieldtype','varchar','20','user');
delimiter;

update ld_producttoolprofile set profilefieldtype='user' where profilefieldtype is null or profilefieldtype='';
delimiter;

call AddColumn("ld_tabdetailprofile",'profilefieldtype','varchar','20','user');
delimiter;

update ld_tabdetailprofile set profilefieldtype='user' where profilefieldtype is null or profilefieldtype='';
delimiter;


insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetByRole','按角色','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SetByRole' and labeltype='fixedstr');
delimiter;

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetByRole','Set by users roles','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SetByRole' and labeltype='fixedstr');
delimiter;

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RolesSetting','角色设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RolesSetting' and labeltype='fixedstr');
delimiter;

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','RolesSetting','Roles Setting','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='RolesSetting' and labeltype='fixedstr');
delimiter;


insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectOneUser','单选用户','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SelectOneUser' and labeltype='fixedstr');
delimiter;

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectOneUser','Single user','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SelectOneUser' and labeltype='fixedstr');
delimiter;

insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectMultiUser','多选用户','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SelectMultiUser' and labeltype='fixedstr');
delimiter;
insert  into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectMultiUser','Multiple users','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SelectMultiUser' and labeltype='fixedstr');
delimiter;

update ld_producttoolfield set defaultcolumn = 1 where tabid = 22 and columnname = 'expiry_date';
delimiter;
-- 2020-08-28

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

UPDATE ld_version SET old_version='V8.2.0',current_version='V8.2.0',remark='V8.2.0-20200828',wx_version='V8.1.8';
delimiter;