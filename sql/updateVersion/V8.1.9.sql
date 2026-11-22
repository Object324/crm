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

ALTER TABLE ld_customform11 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform12 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform12 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform13 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform13 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform14 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform14 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform15 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform15 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform16 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform16 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform17 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform17 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform18 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform18 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform19 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform19 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform20 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform20 ALTER COLUMN currency_symbol SET DEFAULT '¥';
delimiter;

ALTER TABLE ld_customform36 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform36 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform37 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform37 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform38 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform38 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform39 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform39 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform40 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform40 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform41 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform41 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform42 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform42 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform43 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform43 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform44 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform44 ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_customform45 ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_customform45 ALTER COLUMN currency_symbol SET DEFAULT '¥';
delimiter;

UPDATE ld_customform11 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform11 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform12 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform12 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform13 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform13 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform14 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform14 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform15 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform15 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform16 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform16 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform17 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform17 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform18 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform18 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform19 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform19 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform20 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform20 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
delimiter;

UPDATE ld_customform36 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform36 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform37 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform37 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform38 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform38 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform39 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform39 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform40 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform40 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform41 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform41 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform42 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform42 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform43 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform43 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform44 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform44 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
UPDATE ld_customform45 SET conversion_rate = 1.000000 WHERE currency_id=1 AND conversion_rate IS NULL;
UPDATE ld_customform45 SET currency_symbol = '¥' WHERE currency_id=1 AND currency_symbol IS NULL;
delimiter;
-- 2020-08-19

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TILEDSEARCH','平铺查找','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TILEDSEARCH' and labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TILEDSEARCH',"Tiled Search",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TILEDSEARCH' and labeltype = 'fixedstr');
delimiter;

call addcolumn('ld_account','lastservicetime','datetime','0',NULL);
SET  @tabid = (select tabid  from ld_tab where name='Accounts');
SET @blockid = (select blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_ACCOUNT_INFORMATION');
SET @maxfieldid = (select max(fieldid)  from ld_field);

INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select  @tabid, @maxfieldid+1, 'lastservicetime', 'yes', 'ld_account', 1, '70', 'lastservicetime', '最新服务时间', 1, 1, NULL, 100, 69, @blockid, 2, 'DT~O', 1, NULL, 'BAS', 0, NULL, 0, 0, 1, 1, 0, 0, NULL, NULL, 2, 0, 'no', 'no', 'no', 'no', 'yes', 0, 0, 'yes', 'datetime', NULL, 0, NULL, 'yes', NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid =@tabid and columnname ='lastservicetime');
UPDATE ld_field_seq SET id =(SELECT  max(fieldid)  from ld_field);

SET @fieldid = (SELECT  fieldid FROM  ld_field WHERE  tabid =@tabid and columnname='lastservicetime');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid ,'最新服务时间' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid ,'Latest service time' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and relateid=@fieldid and trantable='ld_field');
delimiter;


call addcolumn('ld_leads','lastdistributer','varchar','255',NULL);
call addcolumn('ld_leads','distributiondate','date','0',NULL);
SET  @tabid = (select tabid  from ld_tab where name='Leads');
SET @blockid = (select blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_LEADS_BASICINFORMATION');
SET @maxfieldid = (select max(fieldid)  from ld_field);

INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select  @tabid, @maxfieldid+1, 'lastdistributer', 'yes', 'ld_leads', 1, '199', 'lastdistributer', '最新分配人', 1, 1, NULL, 255, 2, @blockid, 2, 'V~O', 1, 0, 'BAS', 0, '', 0, 0, 1, 1, 0, 0, NULL, NULL, 2, 0, 'no', 'no', 'no', 'no', 'yes', 0, 0, 'yes', 'Users', NULL, 0, NULL, 'yes', NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid =@tabid and columnname ='lastdistributer');


SET @fieldid = (SELECT  fieldid FROM  ld_field WHERE  tabid =@tabid and columnname='lastdistributer');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid ,'最新分配人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid ,'Lastdistributer' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and relateid=@fieldid and trantable='ld_field');

SET @maxfieldid2 = (select max(fieldid)  from ld_field);
INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select  @tabid, @maxfieldid2+1, 'distributiondate', 'yes', 'ld_leads', 1, '70', 'distributiondate', '分配日期', 1, 1, NULL, 100, 1, @blockid, 2, 'D~O', 1, 0, 'BAS', 0, '', 0, 0, 1, 1, 0, 0, NULL, NULL, 2, 0, 'no', 'no', 'no', 'no', 'yes', 0, 0, 'yes', 'datetime', NULL, 0, NULL, 'yes', NULL FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid =@tabid and columnname ='distributiondate');
UPDATE ld_field_seq SET id =(SELECT  max(fieldid)  from ld_field);

SET @fieldid = (SELECT  fieldid FROM  ld_field WHERE  tabid =@tabid and columnname='distributiondate');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid ,'分配日期' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid ,'Distribution date' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and relateid=@fieldid and trantable='ld_field');
UPDATE ld_field_seq SET id =(SELECT  max(fieldid)  from ld_field);
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%') AND 
		NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkdaily_eventreminder') THEN
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
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>NOW() AND type='task_cooperativeworkweek_eventreminder')  THEN
			
		SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() 
								and content LIKE '周计划提交提醒：%'  and reltab='CooperativeWork' ;
		if @cnt=0 then 
			CALL task_cooperativework_weekreport_reminder();
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkweek_eventreminder';
		end if;

	END IF;

end ||
delimiter;


-- 钉钉webhook
select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(id) into @maxfieldid from ld_settings_field_seq;
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
update ld_settings_field_seq set id=@maxfieldid +1  where  not exists(select 1 from ld_settings_field where name='dingtalk_webhook_setting');

select sequence into @sequence from ld_settings_field where linkto like '%dingtalk_webhook_setting%' and blockid=@blockid;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select  @maxfieldid +1,@blockid,'dingtalk_webhook_setting','picklistdependency.png','dingtalk_webhook_setting_description','index.php?module=Settings&action=dingtalk_webhook_setting&parenttab=Settings',@sequence+1,0
from dual where not exists(select 1 from ld_settings_field where name='dingtalk_webhook_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_setting','钉钉群消息推送设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_setting','DingTalk group message push settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_setting_describe','设置合同订单提交审批后，自动推送合同订单内容至钉钉群','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_setting_describe' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_setting_describe','Set the content of the sales order to be automatically pushed to the DingTalk group after the sales order is submitted for approval','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='dingtalk_webhook_setting_describe' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_approve_success','钉钉群消息发送成功！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dingtalk_webhook_approve_fail' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_approve_success','Succeeded to send DingTalk group message!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dingtalk_webhook_approve_fail' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_approve_fail','钉钉群消息发送失败。请确认钉钉群消息推送参数配置是否正确！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dingtalk_webhook_approve_fail' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_approve_fail','Failed to send DingTalk group message. Please confirm whether the DingTalk group message push parameter configuration is correct!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dingtalk_webhook_approve_fail' and labeltype='jspop');
delimiter;
-- 2020-08-21

SET @disable_triggers=1;
UPDATE ld_account 
INNER JOIN (
	SELECT 
		accountid,
		max(createdtime ) as lastservicetime 
	FROM ld_troubletickets
	WHERE deleted=0
		AND approvestatus<>'已拒绝'
		AND accountid>0
	GROUP BY accountid
) as tmp on ld_account.accountid  =tmp.accountid 
set ld_account.lastservicetime = DATE_FORMAT(tmp.lastservicetime,'%Y-%m-%d');
SET @disable_triggers=NULL;

SET @disable_triggers=1;
UPDATE ld_purchaseinquiryorder SET currency_id=1,currency_symbol='¥',conversion_rate='1.000000' WHERE currency_id=1 OR currency_id=0 OR currency_id IS NULL;
SET @disable_triggers=NULL;
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
	and a.module ='Leads' 
GROUP BY a.crmid 
) as  tmp ON tmp.crmid = ld_leads.leadsid 
set lastdistributer = tmp.whodid,distributiondate =date(tmp.changedon);
-- 2020-08-24

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

UPDATE ld_version SET old_version='V8.1.9',current_version='V8.1.9',remark='V8.1.9-20200824',wx_version='V8.1.8';
delimiter;