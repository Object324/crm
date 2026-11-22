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
        ELSEIF columntype LIKE 'timestamp%' THEN
            SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,') NULL DEFAULT NULL');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;


CALL AddColumn ( "ld_approvestep", 'concurrentid', 'int', '11', '0' );
delimiter;

CREATE TABLE if not exists  `ld_approvelog_concurrent` (
  `logconcurrentid` int(11) NOT NULL
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_approvelog_concurrent(logconcurrentid)select 1 from dual where not exists(select 1 from ld_approvelog_concurrent);
delimiter;

CALL AddColumn ("ld_approvelog", 'logconcurrentid', 'int', '11', '0' );
delimiter;

CALL AddColumn ("ld_approvelog", 'seqtime', 'timestamp', '6', '' );
delimiter;

CALL AddColumn ("ld_approvelog", 'stepseq', 'decimal', '20', '5' );
delimiter;

CALL AddColumn ("ld_approvelog", 'isfinished', 'varchar', '20', 'yes' );
delimiter;
CALL AddColumn ("ld_approvestep", 'sequence', 'decimal', '20', '5' );
delimiter;

ALTER TABLE ld_approvestep MODIFY COLUMN sequence decimal(20,5);
delimiter;

update ld_approvelog set isfinished='yes' where isfinished is null or isfinished='';
delimiter;

update ld_approvelog set seqtime=createdtime where seqtime is null or seqtime='';
delimiter;

ALTER TABLE ld_approvelog MODIFY COLUMN isfinished VARCHAR ( 20 ) DEFAULT 'yes' COMMENT '并发步骤审批日志是否完成，yes:完成';
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddConcurrent','新增并发步骤','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddConcurrent' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddConcurrent','Add concurrent','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddConcurrent' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StartConcurrent','进入并发审批','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='StartConcurrent' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','StartConcurrent','Start concurrent approval','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='StartConcurrent' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConcurrentApproval','并发审批','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ConcurrentApproval' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConcurrentApproval','Concurrent approval','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ConcurrentApproval' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='是否允许指定审批步骤' WHERE labelbol='editingprocessd' AND languagetype='zh';
-- 2020-12-14

CALL AddColumn ('ld_users', 'real_name', 'varchar', '255', '' );
delimiter;

update ld_dashboard_app set home_presence='',home_sequence='' WHERE  NAME='InventoryQuery';
delimiter;

update ld_dashboard_app set home_presence='',home_sequence='' WHERE name='AccountsMap';
update ld_dashboard_app set home_presence='',home_sequence='' WHERE name='complationRateSixMonth';
update ld_dashboard_app set home_presence='',home_sequence='' WHERE name='InventoryQuery';
update ld_dashboard_app set home_presence='',home_sequence='' WHERE name='monthweekreport';
delimiter;

update ld_field set typeofdata = 'N~O' where tabid = 14 and columnname = 'productgp' and typeofdata = 'I~O';
delimiter;
-- 2020-12-16


update ld_dashboard_app set home_presence='',home_sequence='' WHERE name='signedamount';
update ld_dashboard_app set home_presence='',home_sequence='' WHERE name='signednumber';
delimiter;

select max(sequence) into @sequence from ld_appparenttabrel where blockid=1;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select 1,-10,@sequence+2 from dual
where not exists(select 1 from ld_appparenttabrel where blockid=1 and tabid=-10);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Recalculatethelatitudeandlongitude','重算经纬度','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Recalculatethelatitudeandlongitude' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Recalculatethelatitudeandlongitude','Recalculate the latitude and longitude','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Recalculatethelatitudeandlongitude' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Recalculationhavenorecordoflatitudeandlongitude','重算有地址没有经纬度的记录（共%s条）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Recalculationhavenorecordoflatitudeandlongitude' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Recalculationhavenorecordoflatitudeandlongitude','Recalculated addresses without longitude and latitude records (%s in total)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Recalculationhavenorecordoflatitudeandlongitude' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Recalculateallrecords','重算所有有地址的记录（共%s条）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Recalculateallrecords' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Recalculateallrecords','Recalculate all records with addresses (%s total)','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Recalculateallrecords' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Donotcloseorrefreshthebrowser','正在重算经纬度，请不要关闭或刷新浏览器','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Donotcloseorrefreshthebrowser' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Donotcloseorrefreshthebrowser','Do not close or refresh the browser while recalculating the latitude and longitude','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Donotcloseorrefreshthebrowser' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AtotalofNdatarecalculationoflatitudeandlongitude','共有%s条数据重算经纬度，预计剩余时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AtotalofNdatarecalculationoflatitudeandlongitude' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AtotalofNdatarecalculationoflatitudeandlongitude','A total of %s data recalculation of latitude and longitude, the estimated remaining time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AtotalofNdatarecalculationoflatitudeandlongitude' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Therearealtogetherdatarecalculations','共有%s条数据重算经纬度，成功重算%s条，失败%s条','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Therearealtogetherdatarecalculations' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Therearealtogetherdatarecalculations','There are altogether %s data recalculations of latitude and longitude, %s successful recalculations, %s failures','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Therearealtogetherdatarecalculations' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Documentrecalculationlongitudeandlatitudesuccess','单据【%s】重算经纬度成功！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Documentrecalculationlongitudeandlatitudesuccess' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Documentrecalculationlongitudeandlatitudesuccess','Document [%s] recalculation longitude and latitude success!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Documentrecalculationlongitudeandlatitudesuccess' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Documentrecalculationoflatitudeandlongitudefailed','单据【%s】重算经纬度失败！原因：地址信息不完整！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Documentrecalculationoflatitudeandlongitudefailed' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Documentrecalculationoflatitudeandlongitudefailed','Document [%s] recalculation of latitude and longitude failed! Reason: Address information is incomplete!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Documentrecalculationoflatitudeandlongitudefailed' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Passandaugmentsinger','通过并加签当前审批步骤','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Passandaugmentsinger' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Passandaugmentsinger','Pass and augmentsinger','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Passandaugmentsinger' and labeltype='fixedstr');
delimiter;
-- 2020-12-18

select usereportid into @usereportid from ld_usereport where name = 'SIGNINSTATISTICS';
select max(Sequence) into @Sequence from ld_usereportcolumns where usereportid = @usereportid;
insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_attachmentsforsign:picture:picture:OftenUseReport_图片:V',@Sequence+1,1,'ld_attachmentsforsign:picture:picture:OftenUseReport_图片:V','ld_attachmentsforsign:picture:picture:OftenUseReport_Picture:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and columns = 'ld_attachmentsforsign:picture:picture:OftenUseReport_图片:V');
delimiter;

select listid into @listid from ld_picklist_set where listname = 'status' and relatetable = 'ld_field';
update ld_picklist_values set listvalue = '升级到客户' where listvalue = '升级' and listid = @listid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETQUICKMODULE','设置快速创建显示的功能模块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETQUICKMODULE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETQUICKMODULE','Set the function module for quick display creation','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETQUICKMODULE' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2020-12-22

SET @disable_triggers=1;
UPDATE ld_salesorder
SET 
	currentapprover=NULL,
	currentapprovestepid=NULL
WHERE deleted=0
	AND approvestatus IN ('未提交','已驳回','已批准');
SET @disable_triggers=NULL;

SET @disable_triggers=1;
UPDATE ld_salesorder
SET 
	currentapprover=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_salesorder.salesorderid AND isfinished='no') THEN
				(SELECT GROUP_CONCAT(nextstepapproveby) FROM ld_approvelog WHERE crmid=ld_salesorder.salesorderid AND isfinished='no')
			ELSE
				(SELECT nextstepapproveby FROM ld_approvelog WHERE crmid=ld_salesorder.salesorderid ORDER BY seqtime DESC,id DESC LIMIT 1)
		END),
	currentapprovestepid=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_salesorder.salesorderid AND isfinished='no') THEN
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_salesorder.salesorderid AND isfinished='no' AND nextstepid>0 ORDER BY id DESC LIMIT 1)
			ELSE
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_salesorder.salesorderid AND nextstepid>0 ORDER BY seqtime DESC,id DESC LIMIT 1)
		END)
WHERE deleted=0
	AND approvestatus IN ('审批中');
SET @disable_triggers=NULL;


SET @disable_triggers=1;
UPDATE ld_quotes
SET 
	currentapprover=NULL,
	currentapprovestepid=NULL
WHERE deleted=0
	AND approvestatus IN ('未提交','已驳回','已批准');
SET @disable_triggers=NULL;

SET @disable_triggers=1;
UPDATE ld_quotes
SET 
	currentapprover=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_quotes.quoteid AND isfinished='no') THEN
				(SELECT GROUP_CONCAT(nextstepapproveby) FROM ld_approvelog WHERE crmid=ld_quotes.quoteid AND isfinished='no')
			ELSE
				(SELECT nextstepapproveby FROM ld_approvelog WHERE crmid=ld_quotes.quoteid ORDER BY seqtime DESC,id DESC LIMIT 1)
		END),
	currentapprovestepid=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_quotes.quoteid AND isfinished='no') THEN
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_quotes.quoteid AND isfinished='no' AND nextstepid>0 ORDER BY id DESC LIMIT 1)
			ELSE
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_quotes.quoteid AND nextstepid>0 ORDER BY seqtime DESC,id DESC LIMIT 1)
		END)
WHERE deleted=0
	AND approvestatus IN ('审批中');
SET @disable_triggers=NULL;


SET @disable_triggers=1;
UPDATE ld_servicecontracts
SET 
	currentapprover=NULL,
	currentapprovestepid=NULL
WHERE deleted=0
	AND approvestatus IN ('未提交','已驳回','已批准');
SET @disable_triggers=NULL;

SET @disable_triggers=1;
UPDATE ld_servicecontracts
SET 
	currentapprover=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no') THEN
				(SELECT GROUP_CONCAT(nextstepapproveby) FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no')
			ELSE
				(SELECT nextstepapproveby FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid ORDER BY seqtime DESC,id DESC LIMIT 1)
		END),
	currentapprovestepid=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no') THEN
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND isfinished='no' AND nextstepid>0 ORDER BY id DESC LIMIT 1)
			ELSE
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_servicecontracts.servicecontractsid AND nextstepid>0 ORDER BY seqtime DESC,id DESC LIMIT 1)
		END)
WHERE deleted=0
	AND approvestatus IN ('审批中');
SET @disable_triggers=NULL;

update ld_desk set fieldlabel = '未启用字段' where labelbol = 'HIDDENFIELDS' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel='Field not enabled' where labelbol='HIDDENFIELDS' and languagetype='en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '启用' where labelbol = 'CANCELHIDDEN' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel='Enable' where labelbol='CANCELHIDDEN' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '选择要启用的字段' where labelbol = 'CHOOSEHIDDENFIELD' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel='Select the fields to enable' where labelbol='CHOOSEHIDDENFIELD' and languagetype='en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '没有未启用字段' where labelbol = 'Nohiddenfields' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel='No fields are not enabled' where labelbol='Nohiddenfields' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

call AddColumn('ld_appsystem','is_open','varchar','10',' ');
call AddColumn('ld_appsystem','name','varchar','255',' ');
call AddColumn('ld_appsystem','sequence','int','11','0');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',4,'是否显示销售助手','no' ,'',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=4);

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'超过N天没有跟进的客户','no' ,'Accounts',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Accounts');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'预计N天内成交的销售机会','no' ,'Potentials',1 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Potentials');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'N天内需要收款的回款计划','no' ,'PaymentPlan',2 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='PaymentPlan');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'N天内将到期的服务合同','no' ,'ServiceContracts',3 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='ServiceContracts');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'最近N天将要过生日的联系人','no' ,'Contacts',4 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Contacts');
delimiter;
-- 2020-12-24

call AddColumn('ld_appsystem','module','varchar','255',' ');

update ld_appsystem set module='Accounts' where name='Accounts' and deploy_type=5;
update ld_appsystem set module='Potentials' where name='Potentials' and deploy_type=5;
update ld_appsystem set module='PaymentPlan' where name='PaymentPlan' and deploy_type=5;
update ld_appsystem set module='ServiceContracts' where name='ServiceContracts' and deploy_type=5;
update ld_appsystem set module='Contacts' where name='Contacts' and deploy_type=5;
delimiter;

delete from ld_desk where labelbol = 'Select the hidden fields to be removed' and labeltype = 'fixedstr';
delimiter;

UPDATE ld_desk SET fieldlabel='签到源单类型定制' WHERE labelbol='LBL_Optionalmodule_Customization' AND languagetype='zh';
-- 2020-12-28

UPDATE ld_account_public_pool SET administrators=(SELECT GROUP_CONCAT(id) FROM ld_users WHERE deleted=0 AND `status`='Active' AND is_admin='on') WHERE zh_name='旧公海' AND administrators IS NULL;
UPDATE ld_desk SET fieldlabel='本公海创建于 %s 共有公海客户 %s 个；已认领 %s 个/未认领 %s 个；本人认领上限 %s 个 / 已领 %s 个； 公海管理员：%s' WHERE labelbol='Thishighseaswasfounded' AND languagetype='zh';


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

UPDATE ld_version SET old_version='V8.3.6',current_version='V8.3.6',remark='V8.3.6-20201228',wx_version='V8.3.6';
delimiter;