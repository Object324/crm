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

ALTER TABLE ld_paymentplan ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_paymentplan ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_paymentplan ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_paymentplan ALTER COLUMN actualamount SET DEFAULT 0;

ALTER TABLE ld_sendpayment ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_sendpayment ALTER COLUMN conversion_rate SET DEFAULT 1.000000;
ALTER TABLE ld_sendpayment ALTER COLUMN currency_symbol SET DEFAULT '¥';
ALTER TABLE ld_sendpayment ALTER COLUMN actualamount SET DEFAULT 0;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','recyclingtothehighseas','回收至公海','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='recyclingtothehighseas' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','recyclingtothehighseas',"Create RecyclingScheme",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='recyclingtothehighseas' and labeltype='fixedstr');
delimiter;

UPDATE ld_producttoolfield SET edit_permission = 0 where bigtype = 'reference';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Synchronizationvoucher','同步凭证','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Synchronizationvoucher' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Synchronizationvoucher','Synchronization voucher','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Synchronizationvoucher' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Confirmwhetherto','确认是否同步生成凭证！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Confirmwhetherto' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Confirmwhetherto','Confirm whether to generate vouchers synchronously!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Confirmwhetherto' and Labeltype='jspop' and languagetype='en');
delimiter;

call AddColumn('ld_field','editpage','varchar','100','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOINFO','暂无信息','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOINFO' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOINFO',"No information",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOINFO' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isubmitted','我提交的','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='isubmitted' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isubmitted',"I submitted",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='isubmitted' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Processed','已处理','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Processed' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Processed',"Approved",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Processed' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pending','待处理','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Pending' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pending',"Approving",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Pending' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVAL','审批','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVAL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVAL',"Approval",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APPROVAL' and labeltype='jspop');
delimiter;
-- 2021-03-21

UPDATE ld_customreport_info SET report_name='平均单值气泡图表(按订单)' WHERE report_template='default_salesorder_avg_amount.mrt' AND report_name='平均单值气泡图表';

SET @i=0;
SET @report_name='平均单值气泡图表(按收款)';
SET @report_type='template_js';
SET @report_template='default_cashbill_avg_amount.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_salesorder_avg_amount.mrt' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_customreport_info WHERE report_template='default_salesorder_avg_amount.mrt' LIMIT 1);
UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);

UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id ORDER BY sequence;
delimiter;


SET @i=0;
SET @report_name='平均单值气泡图表(按出库)';
SET @report_type='template_js';
SET @report_template='default_outboundorder_avg_amount.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT folder_id FROM ld_customreport_info WHERE report_template='default_cashbill_avg_amount.mrt' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_customreport_info WHERE report_template='default_cashbill_avg_amount.mrt' LIMIT 1);
UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);

UPDATE ld_customreport_info SET sequence=(@i:=@i+1) WHERE folder_id=@id ORDER BY sequence;
delimiter;


SET @wx_sequence = (select max(wx_sequence)+1 from ld_dashboard_app);
SET @home_sequence = (select max(home_sequence)+1 from ld_dashboard_app);

select wx_sequence into @sequence from ld_dashboard_app where name='CustomReportBlock';
update ld_dashboard_app set wx_sequence=wx_sequence+2;
insert into ld_dashboard_app(name,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence)
select 'PersonalAccountBalance','PersonalAccountBalance','','dashboard_6',0,1,@sequence+1,0,0,'no',@home_sequence  from dual
where not EXISTS(select 1 from ld_dashboard_app where name='PersonalAccountBalance');
delimiter;

select blockid into @blockid from ld_appparenttab where parenttab_label='Reports';
select id into @tabid from ld_dashboard_app where name='PersonalAccountBalance';
select max(sequence) into @maxsequence from ld_appparenttabrel;
insert into ld_appparenttabrel(blockid,tabid,sequence,relatename)
select @blockid,@tabid,1,'PersonalAccountBalance' from dual where not EXISTS(select 1 from ld_appparenttabrel where relatename='PersonalAccountBalance');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PersonalAccountBalance','个人账户余额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PersonalAccountBalance' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PersonalAccountBalance','Personal Account balance','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PersonalAccountBalance' and Labeltype='fixedstr');
delimiter;

SET @sequence = (select max(sequence)+1 from ld_mobile_report_tab_rel);
select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='sales';
select id into @reportid from ld_dashboard_app where name = 'PersonalAccountBalance';
insert into ld_mobile_report_tab_rel (block_id, tabid, sequence, tab_tablename) select @block_id,@reportid,1,'ld_tab'
from dual where not exists(select 1 from ld_mobile_report_tab_rel where block_id=@block_id and tabid=@reportid);
delimiter;
-- 2022-03-27

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_ROLE_NAME','角色','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='LBL_ROLE_NAME' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_ROLE_NAME','Profile','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='LBL_ROLE_NAME' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_relatedlists SET actions=NULL WHERE `name`='get_CallButler';
delimiter;

call AddColumn('ld_warehouse','allocatetype','varchar','50',NULL);
update ld_warehouse set allocatetype = 'user' where id in (select warehouseid from ld_warehouse2user where userid > 1) and allocatetype is null;
delimiter;
update ld_warehouse set allocatetype = 'all' where id in (select warehouseid from ld_warehouse2user where userid = -1) and allocatetype is null;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress' LIMIT 1);
SET @tablabel=(SELECT fieldlabel FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@tabid AND languagetype='zh' AND trantable='ld_tab' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tablename='ld_projectprogress' AND columnname='projectprogress_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='项目日志编号' WHERE Relateid=@filedid AND trantable='ld_field' AND languagetype='zh' AND @tablabel=@tablabel;
delimiter;

UPDATE ld_desk SET fieldlabel='导入明细' WHERE labelbol='IMPORTENTRY' AND languagetype='zh' AND fieldlabel='导入单据分录';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPLAINTREE','说明：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPLAINTREE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPLAINTREE','Explain:','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPLAINTREE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DetailedDescriptionTree1','1、树结构“分组字段”可在页面设置中新增“下拉框”字段类型添加；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DetailedDescriptionTree1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DetailedDescriptionTree1','1. The tree structure "grouping field" can be added with the "drop-down box" field type in the page setting;','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DetailedDescriptionTree1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DetailedDescriptionTree2','2、级联字段定制，可设置“分组字段的树节点，下级“级联字段”；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DetailedDescriptionTree2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DetailedDescriptionTree2','2. Cascade field Customization: you can set the tree node of "group field" and the lower level "cascade field";','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DetailedDescriptionTree2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DetailedDescriptionTree3','3、“分组字段”选项值为“一级分类”，“分组字段”的下级“级联字段”树节点选项值为“子分类”；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DetailedDescriptionTree3' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DetailedDescriptionTree3','3、“3. The option value of "group field" is "primary classification", and the option value of the lower level "cascade field" tree node of "group field" is "sub classification";','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DetailedDescriptionTree3' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TREEIMGEXPLAIN1','单级树节点分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TREEIMGEXPLAIN1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TREEIMGEXPLAIN1','Single level tree node classification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TREEIMGEXPLAIN1' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TREEIMGEXPLAIN2','多级树节点分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TREEIMGEXPLAIN2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TREEIMGEXPLAIN2','Multilevel tree node classification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TREEIMGEXPLAIN2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnableTreeStructure','（启用后，根据“分组字段”和“级联字段”树节点选项值在左侧显示）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EnableTreeStructure' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnableTreeStructure','(when enabled, it is displayed on the left according to the option values of "group field" and "cascade field" tree nodes)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EnableTreeStructure' and Labeltype='fixedstr');
delimiter;

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

UPDATE ld_desk SET fieldlabel='全局快速授权' WHERE labelbol='SELECTTHESELECTEDPERMISSIONS' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='授权' WHERE labelbol='OPENMODULE' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='除权' WHERE labelbol='CLOSE' AND languagetype='zh' AND Labeltype='jspop';
-- 2022-04-01


DROP PROCEDURE IF EXISTS `ldcrm_back_reminds_table`;
delimiter ||
CREATE PROCEDURE `ldcrm_back_reminds_table`(
)
BEGIN

	IF (SELECT COUNT(1) FROM ld_reminds)>300000 THEN
		CREATE TABLE IF NOT EXISTS ld_reminds_8460 LIKE ld_reminds;
		TRUNCATE TABLE ld_reminds_8460;
		INSERT INTO ld_reminds_8460 
		SELECT * FROM ld_reminds WHERE date_time>DATE_SUB(CURDATE(),INTERVAL 3 MONTH);

		TRUNCATE TABLE ld_reminds;
		INSERT INTO ld_reminds
		SELECT * FROM ld_reminds_8460;
		
		TRUNCATE TABLE ld_reminds_8460;
		DROP TABLE IF EXISTS ld_reminds_8460;
		

	END IF;

end ||
delimiter;

CALL ldcrm_back_reminds_table();
DROP PROCEDURE IF EXISTS `ldcrm_back_reminds_table`;
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

END ||
delimiter;

DROP EVENT IF EXISTS `ldcrm_remindsdata_transfer_every1mintue`;
delimiter ||
CREATE  EVENT `ldcrm_remindsdata_transfer_every1mintue` ON SCHEDULE EVERY 1 MINUTE STARTS NOW() ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_remindsdata_transfer();
||
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

END ||
delimiter;

DROP EVENT IF EXISTS `ldcrm_remindsdata_delete_every5mintue`;
DROP EVENT IF EXISTS `ldcrm_remindsdata_delete_every10second`;
delimiter ||
CREATE  EVENT `ldcrm_remindsdata_delete_every10second` ON SCHEDULE EVERY 10 SECOND STARTS NOW() ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_remindsdata_delete();
||
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

update ld_profile2standardpermissions set relatednames=CONCAT('PersonalAccountBalance,',relatednames) where tabid=-2 and relatednames not like '%PersonalAccountBalance%';
delimiter;
-- 2022-04-03


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

UPDATE ld_field SET typeofdata = 'V~O' WHERE  columnname = 'potentialid' AND uitype=76 AND bigtype='reference' AND typeofdata ='I~O' ;
delimiter;
UPDATE ld_field SET typeofdata = 'V~M' WHERE  columnname = 'potentialid' AND uitype=76 AND bigtype='reference' AND typeofdata ='I~M' ;
delimiter;


select max(fieldid) into @maxfieldid from ld_field ;
select block into @block from ld_field where columnname='servicecasher' and tabid=102;
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,sequence,block,displaytype,typeofdata,savedatabase,bigtype,datarang,maxrowsshow,profileeditfield)
select 102,@maxfieldid+1,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,sequence,@block,displaytype,typeofdata,savedatabase,bigtype,datarang,maxrowsshow,profileeditfield
from ld_field where tabid=6 and not EXISTS(select 1 from ld_field where tabid=102  and columnname='accountproperty' ) and columnname='accountproperty';

update ld_field_seq  set id=@maxfieldid+1;
delimiter;

select ld_tranlabel.fieldlabel into @fieldlabel from ld_field
inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
 where ld_tranlabel.tabid=6 and  columnname='accountproperty'
and ld_tranlabel.trantable='ld_field'
and ld_tranlabel.languagetype='en';
select fieldid into @relateid from ld_field where tabid=102 and  columnname='accountproperty' ;
insert into ld_tranlabel(tabid,trantable,relateid,fieldlabel,languagetype)
select 102 ,'ld_field', @relateid,@fieldlabel,'en' from dual 
 where not exists(select 1 from ld_tranlabel where  tabid=102 and relateid=@relateid and languagetype='en' 
and trantable='ld_field');


select ld_tranlabel.fieldlabel into @fieldlabel from ld_field
inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
 where ld_tranlabel.tabid=6 and  columnname='accountproperty'
and ld_tranlabel.trantable='ld_field'
and ld_tranlabel.languagetype='zh';
select fieldid into @relateid from ld_field where tabid=102 and  columnname='accountproperty' ;
insert into ld_tranlabel(tabid,trantable,relateid,fieldlabel,languagetype)
select 102 ,'ld_field', @relateid,@fieldlabel,'zh' from dual 
 where not exists(select 1 from ld_tranlabel where  tabid=102 and relateid=@relateid and languagetype='zh' 
and trantable='ld_field');
delimiter;

update ld_field_seq  set id=@maxfieldid+1;
delimiter;

select max(fieldid) into @maxfieldid from ld_field ;
select block into @block from ld_field where columnname='servicecasher' and tabid=102;
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,sequence,block,displaytype,typeofdata,savedatabase,bigtype,datarang,maxrowsshow,profileeditfield)
select 102,@maxfieldid+1,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,sequence,@block,displaytype,typeofdata,savedatabase,bigtype,datarang,maxrowsshow,profileeditfield
from ld_field where tabid=6 and not EXISTS(select 1 from ld_field where tabid=102  and columnname='parentid' ) and columnname='parentid';

update ld_field_seq  set id=@maxfieldid+1;
delimiter;

select ld_tranlabel.fieldlabel into @fieldlabel from ld_field
inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
 where ld_tranlabel.tabid=6 and  columnname='parentid'
and ld_tranlabel.trantable='ld_field'
and ld_tranlabel.languagetype='en';
select fieldid into @relateid from ld_field where tabid=102 and  columnname='parentid' ;
insert into ld_tranlabel(tabid,trantable,relateid,fieldlabel,languagetype)
select 102 ,'ld_field', @relateid,@fieldlabel,'en' from dual 
 where not exists(select 1 from ld_tranlabel where  tabid=102 and relateid=@relateid and languagetype='en' 
and trantable='ld_field');


select ld_tranlabel.fieldlabel into @fieldlabel from ld_field
inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
 where ld_tranlabel.tabid=6 and  columnname='parentid'
and ld_tranlabel.trantable='ld_field'
and ld_tranlabel.languagetype='zh';
select fieldid into @relateid from ld_field where tabid=102 and  columnname='parentid' ;
insert into ld_tranlabel(tabid,trantable,relateid,fieldlabel,languagetype)
select 102 ,'ld_field', @relateid,@fieldlabel,'zh' from dual 
 where not exists(select 1 from ld_tranlabel where  tabid=102 and relateid=@relateid and languagetype='zh' 
and trantable='ld_field');
delimiter;

update ld_field_seq  set id=@maxfieldid+1;
delimiter;

CALl AddColumn('ld_field','editpage','VARCHAR','100',NULL);
delimiter;

UPDATE ld_field SET savedatabase='yes' WHERE columnname='filename' AND tablename='ld_worksheet';
delimiter;

UPDATE ld_field 
SET editpage='listview'
WHERE uitype IN (1,2,5,7,9,11,13,14,15,17,19,20,21,33,56,71,85,86,153,154,230,255,1101,1102,1103,1109)
	AND displaytype=1
	AND allowedit='yes'
	AND savedatabase='yes';
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITFAILED','编辑失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EDITFAILED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITFAILED',"Edit failed !",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EDITFAILED' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDCANNOTEDITINLISTVIEW','[%s]字段在列表界面不能编辑！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FIELDCANNOTEDITINLISTVIEW' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDCANNOTEDITINLISTVIEW',"[%s] field cannot be edited in the list interface !",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FIELDCANNOTEDITINLISTVIEW' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDCANNOTEDIT','[%s]字段不能编辑！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FIELDCANNOTEDIT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDCANNOTEDIT',"[%s] field cannot be edited",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FIELDCANNOTEDIT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERTHECORRECT','请输入正确的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASEENTERTHECORRECT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERTHECORRECT',"Please enter the correct ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASEENTERTHECORRECT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTTHAN','不能大于','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTTHAN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTTHAN'," cannot be greater than ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTTHAN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LINE','第','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LINE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LINE',"Line",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LINE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','row','行','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='row' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','row',"row",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='row' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','cannotbelessthan1','不能小于','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='cannotbelessthan1' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','cannotbelessthan1'," cannot be less than ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='cannotbelessthan1' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTEMPTYORZERO','不能为空或0','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTEMPTYORZERO' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTEMPTYORZERO'," cannot be empty or 0 ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTEMPTYORZERO' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTTHAN','不能大于','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTTHAN' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTTHAN'," cannot be greater than ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTTHAN' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOULDGREATEROREQUAL',' 应大于或等于 ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHOULDGREATEROREQUAL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOULDGREATEROREQUAL'," should be greater than or equal to ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHOULDGREATEROREQUAL' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOULDBEGREATER',' 应大于 ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHOULDBEGREATER' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOULDBEGREATER'," should be greater than ",'fixedstr !' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHOULDBEGREATER' and labeltype='fixedstr');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
SET @relatedid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'kis_no');
UPDATE ld_tranlabel set fieldlabel = 'Leads upgrade status' 
where tabid = @tabid and trantable = 'ld_field' and Relateid = @relatedid AND languagetype = 'en' and fieldlabel = '是否来源销售线索';
delimiter;

UPDATE ld_field SET typeofdata = 'V~O' WHERE  columnname = 'potentialid' AND uitype=76 AND bigtype='reference' AND typeofdata ='I~O' ;
delimiter;
UPDATE ld_field SET typeofdata = 'V~M' WHERE  columnname = 'potentialid' AND uitype=76 AND bigtype='reference' AND typeofdata ='I~M' ;
delimiter;
-- 2022-04-10

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COUNT','计数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COUNT' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COUNT',"Count",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COUNT' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UCOUNT','唯一计数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UCOUNT' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UCOUNT',"Unique Count",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UCOUNT' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MAXVALUE','最大值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MAXVALUE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MAXVALUE',"Maximum Value",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MAXVALUE' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MINVALUE','最小值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MINVALUE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MINVALUE',"Minimum Value",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MINVALUE' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AVGVALUE','平均值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AVGVALUE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AVGVALUE',"Average Value",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AVGVALUE' and labeltype='fixedstr');
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Subtotal','小计','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Subtotal' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Subtotal',"Subtotal",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Subtotal' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TotalCount','总计数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TotalCount' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TotalCount',"Total Count",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TotalCount' and labeltype='fixedstr');
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TotalPosition','总计位置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TotalPosition' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TotalPosition',"Total Position",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TotalPosition' and labeltype='fixedstr');
delimiter;





insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetLink','设为链接模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetLink' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetLink',"Set as link module",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetLink' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Showdetails','显示明细','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Showdetails' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Showdetails',"Show details",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Showdetails' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectField','选择字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectField' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectField',"Select Field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectField' and labeltype='fixedstr');
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectCon','选择条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectCon' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectCon',"Select Conditions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectCon' and labeltype='fixedstr');
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Keyword2','关键词','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Keyword2' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Keyword2',"Keyword",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Keyword2' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Operation2','操作','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Operation2' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Operation2',"Operation",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Operation2' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEW2','新增','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NEW2' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEW2',"New",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NEW2' and labeltype='jspop');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewFormula','新增公式字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewFormula' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewFormula',"New formula field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewFormula' and labeltype='fixedstr');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveSee','仅显示部分数据，保存之后可查看全部数据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SaveSee' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveSee',"Only partial data is displayed, and all data can be viewed after saving",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SaveSee' and labeltype='fixedstr');
delimiter;

SET @labelbol = 'SETADDRESSASVISIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否将签到地址设置为拜访对象地址？','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set the check-in address as the address of the visiting object?','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-04-12

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Bottom','底部','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Bottom' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Bottom',"Bottom",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Bottom' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Top','顶部','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Top' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Top',"Top",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Top' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Interval','区间','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Interval' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Interval',"Interval",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Interval' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Equal','等于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Equal' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Equal',"Equal",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Equal' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoEqual','不等于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoEqual' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoEqual',"Not Equal",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoEqual' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LessThan','小于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LessThan' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LessThan',"Less Than",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LessThan' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MoreThan','大于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MoreThan' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MoreThan',"More Than",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MoreThan' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LTET','小于等于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LTET' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LTET',"Less Than or Equal To",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LTET' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MTET','大于等于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MTET' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MTET',"More Than or Equal To",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MTET' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Empty','为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Empty' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Empty',"Empty",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Empty' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotNull','不为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotNull' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotNull',"Not Null",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotNull' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','today','今天','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='today' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','today',"Today",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='today' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','yesterday','昨天','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='yesterday' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','yesterday',"Yesterday",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='yesterday' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','tomorrow','明天','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='tomorrow' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','tomorrow',"Tomorrow",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='tomorrow' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ThisWeek','本周','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ThisWeek' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ThisWeek',"This Week",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ThisWeek' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LastWeek','上周','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LastWeek' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LastWeek',"Last Week",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LastWeek' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NextWeek','下周','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NextWeek' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NextWeek',"Next Week",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NextWeek' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ThisQ','本季度','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ThisQ' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ThisQ',"This Quarter",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ThisQ' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LastQ','上季度','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LastQ' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LastQ',"Last Quarter",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LastQ' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NextQ','下季度','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NextQ' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NextQ',"Next Quarter",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NextQ' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ThisM','本月','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ThisM' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ThisM',"This Month",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ThisM' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LastM','上月','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LastM' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LastM',"Last Month",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LastM' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NextM','下月','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NextM' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NextM',"Next Month",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NextM' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ThisY','本年','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ThisY' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ThisY',"This Year",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ThisY' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LastY','去年','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LastY' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LastY',"Last Year",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LastY' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NextY','明年','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NextY' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NextY',"Next Year",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NextY' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Include','包含','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Include' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Include',"Include",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Include' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotInclude','不包含','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotInclude' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotInclude',"Not Include",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotInclude' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FormSet','表格设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FormSet' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FormSet',"Form Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FormSet' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AdvanceSet','高级设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AdvanceSet' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AdvanceSet',"Advanced Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AdvanceSet' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewT','新建统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewT' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewT',"New Table",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NewT','新建统计表','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NewT' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NewT',"New Table",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NewT' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Looking','请输入要查找的字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Looking' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Looking',"Please enter the field you are looking for",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Looking' and labeltype='fixedstr');


DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldinfo_20220413`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_tabdetailfieldinfo_20220413`(
)
BEGIN

	DECLARE tmp_module VARCHAR(100) DEFAULT '';
	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_tablename VARCHAR(100) DEFAULT '';
	DECLARE tmp_seq INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR 
		SELECT
			b.`name` AS module,
			a.tabid,
			a.tablename,
			a.sequence
		FROM ld_tabdetailfield a
		LEFT JOIN ld_tab b ON b.tabid=a.tabid
		WHERE b.`name` LIKE 'CustomForm%'
			AND RIGHT(b.`name`,2) BETWEEN 26 AND 35
			AND a.columnname='amount'
		ORDER BY a.tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_tablename,tmp_seq;
	WHILE(tmp_tabid IS NOT NULL) DO
		IF NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=tmp_tabid AND columnname='rate') THEN
			IF EXISTS (SELECT 1 FROM ld_crmentity WHERE setype=tmp_module) THEN
				SET @presence=1;
			ELSE
				SET @presence=0;
			END IF;
	
			UPDATE ld_tabdetailfield SET sequence=sequence+1 WHERE tabid=tmp_tabid AND sequence>=tmp_seq;

			SET @tabid=tmp_tabid;
			SET @columnname='rate';
			SET @zh='比例(%)'; 
			SET @en='Rate(%)';

			SET @fieldtype='Num';
			SET @typeofdata='N~O~25,2';
			SET @bigtype=NULL;
			SET @tablename=tmp_tablename;
			SET @seq=tmp_seq;
				
			SET @trantable='ld_tabdetailfield';

			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_producttoolfield WHERE tabid=@tabid),0);
			SET @edit_permission=1;

			INSERT INTO ld_tabdetailfield (tabid,columnname,allowhide,tablename,fieldlabel,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,defaultcolumn,savedatabase) 
			SELECT @tabid,@columnname,'yes',@tablename,@zh,@presence,@fieldtype,@typeofdata,@seq,20,0,0,1,'yes' FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname);


			SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'DECIMAL','25','2');
	

			CALL getallprofile(@modulename);
			CALL fieldprofile(@modulename);


		END IF;
		FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_tablename,tmp_seq;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_tabdetailfieldinfo_20220413();
DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldinfo_20220413`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GoTo','前往','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GoTo' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GoTo',"Go To",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GoTo' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Table','统计表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Table' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Table',"Table",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Table' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ECN','编辑列名称','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ECN' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ECN',"Edit Column Names",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ECN' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Grouping','分组','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Grouping' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Grouping',"Grouping",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Grouping' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Ungroup','取消分组','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Ungroup' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Ungroup',"Ungroup",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Ungroup' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Ascending','升序','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Ascending' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Ascending',"Ascending",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Ascending' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CAscending','取消升序','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CAscending' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CAscending',"Cancel Ascending",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CAscending' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Descending','降序','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Descending' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Descending',"Descending",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Descending' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CDescending','取消降序','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CDescending' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CDescending',"Cancel Descending",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CDescending' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Merge','合并','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Merge' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Merge',"Merge",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Merge' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CMerge','取消合并','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CMerge' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CMerge',"Cancel Merge",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CMerge' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SMethods','统计方式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SMethods' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SMethods',"Statistical Methods",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SMethods' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CancelStatistics','取消统计','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CancelStatistics' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CancelStatistics',"Cancel Statistics",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CancelStatistics' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DeleteField','删除字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DeleteField' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DeleteField',"Delete Field",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DeleteField' and labeltype='jspop');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAlignment','设置对齐方式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetAlignment' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAlignment',"Set Alignment",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetAlignment' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChineseName','中文名称','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ChineseName' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChineseName',"Chinese Name",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ChineseName' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnglishName','英文名称','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EnglishName' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnglishName',"English Name",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EnglishName' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MCName','修改列名称','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MCName' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MCName',"Modify Column Names",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MCName' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MStatistics','修改统计方式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MStatistics' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MStatistics',"Modify Statistics",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MStatistics' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UCount','唯一计数','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UCount' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UCount',"Unique Count",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UCount' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Count','计数','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Count' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Count',"Count",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Count' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModifyAlignment','修改对齐方式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ModifyAlignment' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModifyAlignment',"Modify Alignment",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ModifyAlignment' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AlignLeft','左对齐','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AlignLeft' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AlignLeft',"Align Left",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AlignLeft' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Centered','居中','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Centered' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Centered',"Centered",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Centered' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AlignRight','右对齐','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AlignRight' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AlignRight',"Align Right",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AlignRight' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Prefix','前缀','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Prefix' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Prefix',"Prefix",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Prefix' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Suffix','后缀','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Suffix' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Suffix',"Suffix",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Suffix' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DefineVariable','定义变量','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DefineVariable' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DefineVariable',"Define Variable",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DefineVariable' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VariableName','变量名','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VariableName' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VariableName',"Variable Name",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VariableName' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplaySetting','显示设置','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DisplaySetting' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplaySetting',"Display Setting",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DisplaySetting' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sentence','1.报表已选字段中所有数字、金额和已设置统计方式的字段可参与运算；','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Sentence' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sentence',"1. All numbers, amounts and fields with statistical methods set in the selected fields of the report can participate in the calculation;",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Sentence' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sentence2','2.定义公式时，变量名需用{}包裹，如：({a}+{b})*100；','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Sentence2' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sentence2',"2. When defining a formula, the variable name needs to be wrapped with {}, such as: ({a}+{b})*100;",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Sentence2' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sentence3','3.若需要删除变量信息，则到已选字段中删除对应字段。','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Sentence3' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sentence3',"3. If you need to delete variable information, delete the corresponding field in the selected field.",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Sentence3' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Confirm','确定','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Confirm' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Confirm',"Confirm",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Confirm' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Example','例：% 等','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Example' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Example',"Example: % etc.",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Example' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddFormulaField','新增公式字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddFormulaField' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddFormulaField',"Add Formula Field",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddFormulaField' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EditFormula','编辑公式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EditFormula' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EditFormula',"Edit Formula",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EditFormula' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sum','求和','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Sum' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sum',"Sum",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Sum' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Mean','求均值','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Mean' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Mean',"Mean",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Mean' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MinimumValue','最小值','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MinimumValue' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MinimumValue',"Minimum Value",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MinimumValue' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DefinitionFormula','定义公式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DefinitionFormula' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DefinitionFormula',"Definition formula",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DefinitionFormula' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FillTheName','请填写报表名称！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FillTheName' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FillTheName',"Please fill in the report name!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FillTheName' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectFolder','请先选择文件夹','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectFolder' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectFolder',"Please select a folder first",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectFolder' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectModule','请先选择模块','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectModule' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectModule',"Please select a module first",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectModule' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaveFailed2','保存失败！请重试！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SaveFailed2' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaveFailed2',"Save failed! Please try again!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SaveFailed2' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoNumber','没有可用来设置公式的数字或者金额字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoNumber' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoNumber',"No number or amount fields available for formulas",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoNumber' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotNegative','小数点位数不能为负数！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotNegative' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotNegative',"The number of decimal places cannot be negative!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotNegative' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotEmpty','公式或者名称不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NotEmpty' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotEmpty',"Formula or name cannot be empty",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NotEmpty' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WidthData','宽度数据保存成功','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WidthData' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WidthData',"Width data saved successfully",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WidthData' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoDelete','文件夹下有统计表，不允许删除！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoDelete' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoDelete',"There are statistical tables under the folder, and deletion is not allowed!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoDelete' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SuccessDeleted','删除成功！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SuccessDeleted' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SuccessDeleted',"successfully deleted!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SuccessDeleted' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoPermission','没有删除权限','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoPermission' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoPermission',"No delete permission",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoPermission' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StyleSettings','样式设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='StyleSettings' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','StyleSettings',"Style Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='StyleSettings' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConditionSetting','条件设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ConditionSetting' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConditionSetting',"Condition Setting",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ConditionSetting' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModuleSelection','模块选择','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ModuleSelection' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModuleSelection',"Module Selection",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ModuleSelection' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FromCustomer','来自：客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FromCustomer' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FromCustomer',"From: Customer",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FromCustomer' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Group','分组','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Group' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Group',"Grouping",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Group' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MStatistics','修改统计方式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MStatistics' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MStatistics',"Modify Statistics",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MStatistics' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ItemPage','条/页','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ItemPage' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ItemPage',"items/page",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ItemPage' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoFiled','没有可用来计算的字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NoFiled' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoFiled',"No fields available for calculation",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NoFiled' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MaximumValue','最大值','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MaximumValue' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MaximumValue',"Maximum Value",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MaximumValue' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FROM','来自：','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FROM' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FROM',"From:",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FROM' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Formula','公式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Formula' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Formula',"Formula",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Formula' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EditFields','编辑公式字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EditFields' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EditFields',"Edit formula fields",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EditFields' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FNoEmpty','公式不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FNoEmpty' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FNoEmpty',"Formula cannot be empty",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FNoEmpty' and labeltype='jspop');
delimiter;
-- 2022-04-15

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

UPDATE ld_version SET old_version='V8.4.6.0',current_version='V8.4.6.0',remark='V8.4.6.0-20220415',wx_version='V8.4.6.0';
delimiter;