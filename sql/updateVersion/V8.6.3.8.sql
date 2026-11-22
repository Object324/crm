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

CREATE TABLE if not EXISTS `ld_crmlog_viewdetail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(20) NOT NULL,
  `action` varchar(100) NOT NULL,
	`actiontype` varchar(100) NOT NULL,
	`module` varchar(100) DEFAULT NULL,
	`crmid` int(19) DEFAULT NULL,
	`operationdetails` text DEFAULT NULL,
  `operationtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

SET @labelbol = 'VIEWDETAILSINFO';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'查看详情',@labeltype FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'viewDetailsInfo',@labeltype FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
UPDATE ld_relatedlists SET type = 'signin_datacategory_sql' WHERE related_tabid = @tabid AND label = 'Singin' AND type = 'entitytype_datacategory_sql';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
UPDATE ld_relatedlists SET buttonstatus = 'no' WHERE related_tabid = @tabid AND label = 'Singin';
delimiter;

SET @labelbol = 'COMMONLYUSED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'常用',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'CommonlyUsed',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOUBLECLICKTOSELECTDOCUMENT','双击选择','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOUBLECLICKTOSELECTDOCUMENT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOUBLECLICKTOSELECTDOCUMENT','Double click to select the document','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOUBLECLICKTOSELECTDOCUMENT' and labeltype='jspop');
delimiter;

UPDATE ld_callrecordfields set `status` = 'yes' where columnnames <> '' and columnnames is not null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','moduleAccounts','{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='moduleAccounts' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','moduleAccounts','{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='moduleAccounts' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','modulePotentials','{$Potentials.Potentials}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='modulePotentials' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','modulePotentials','{$Potentials.Potentials}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='modulePotentials' and labeltype='jspop' and languagetype='en');
delimiter;
-- 2024-06-18

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','moduleAccounts','{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='moduleAccounts' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','moduleAccounts','{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='moduleAccounts' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','modulePotentials','{$Potentials.Potentials}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='modulePotentials' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','modulePotentials','{$Potentials.Potentials}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='modulePotentials' and labeltype='jspop' and languagetype='en');
delimiter;


update ld_desk set fieldlabel='该阶段停留商机数' where labelbol='curnums' and languagetype='zh' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UserPermissionManagement','用户和权限管理','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UserPermissionManagement' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UserPermissionManagement',"User and permission management",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UserPermissionManagement' and labeltype='fixedstr');
delimiter;


DROP PROCEDURE IF EXISTS `updatesettingsblocksfields`;
delimiter ||
CREATE PROCEDURE `updatesettingsblocksfields`(
)
BEGIN
    DECLARE field_exists INT;
    DECLARE current_db VARCHAR(64);

    SELECT DATABASE() INTO current_db;

    SELECT COUNT(*)
    INTO field_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = current_db
    AND TABLE_NAME = 'ld_settings_field'
    AND COLUMN_NAME = 'frequency';

    IF field_exists = 0 THEN
				CALl AddColumn('ld_settings_field','frequency','int','10',0);
				CALl AddColumn('ld_settings_blocks','inactive_icon','varchar','255','');
				CALl AddColumn('ld_settings_blocks','active_icon','varchar','255','');



				DELETE FROM ld_settings_blocks;

				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (1,'ENTERPRISE_MANAGEMENT',1,0,'ENTERPRISE_MANAGEMENT.png','ENTERPRISE_MANAGEMENT_hover.png');
				insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
				select 'zh','ENTERPRISE_MANAGEMENT','企业管理','fixedstr' from dual
				where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ENTERPRISE_MANAGEMENT' and labeltype='fixedstr');
				insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
				select 'en','ENTERPRISE_MANAGEMENT',"Enterprise management",'fixedstr' from dual
				where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ENTERPRISE_MANAGEMENT' and labeltype='fixedstr');
				update ld_settings_field set blockid = 1 , sequence = 1 where `name` = 'LBL_COMPANY_DETAILS';
				update ld_settings_field set blockid = 1 , sequence = 2 where `name` = 'watermark_setting';
				update ld_settings_field set blockid = 1 , sequence = 3 where `name` = 'LBL_CURRENCY_SETTINGS';
				update ld_settings_field set blockid = 1 , sequence = 4 where `name` = 'LBL_SERVICE_PERFORMANCE_PARAMETERS';
				update ld_settings_field set blockid = 1 , sequence = 5 where `name` = 'LBL_AUTOMATICREMINDS_SET';
				update ld_settings_field set blockid = 1 , sequence = 6 where `name` = 'LBL_cooperative_REMIND_SET';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (2,'EnterpriseLogs',2,0,'EnterpriseLogs.png','EnterpriseLogs_hover.png');
				update ld_settings_field set blockid = 2 , sequence = 1 where `name` = 'LBL_LOGIN_HISTORY_DETAILS';
				update ld_settings_field set blockid = 2 , sequence = 2 where `name` = 'LBL_AUDIT_TRAIL';
				update ld_settings_field set blockid = 2 , sequence = 3 where `name` = 'ImportExportLogs';
				update ld_settings_field set blockid = 2 , sequence = 4 where `name` = 'OperationLogs';



				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (3,'MODULE_MENU_MANAGEMENT',3,0,'MODULE_MENU_MANAGEMENT.png','MODULE_MENU_MANAGEMENT_hover.png');
				insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
				select 'zh','MODULE_MENU_MANAGEMENT','模块和企业管理','fixedstr' from dual
				where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MODULE_MENU_MANAGEMENT' and labeltype='fixedstr');
				insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
				select 'en','MODULE_MENU_MANAGEMENT',"Module and menu management",'fixedstr' from dual
				where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MODULE_MENU_MANAGEMENT' and labeltype='fixedstr');
				update ld_settings_field set blockid = 3 , sequence = 1 where `name` = 'VTLIB_LBL_MODULE_MANAGER';
				update ld_settings_field set blockid = 3 , sequence = 2 where `name` = 'LBL_HREFMODULE_Custom';
				update ld_settings_field set blockid = 3 , sequence = 3 where `name` = 'LBL_ProductTool_field';
				update ld_settings_field set blockid = 3 , sequence = 4 where `name` = 'LBL_TABLIST';
				update ld_settings_field set blockid = 3 , sequence = 5 where `name` = 'mobile_home_setting';
				update ld_settings_field set blockid = 3 , sequence = 6 where `name` = 'MobileAppMenuCustomization';
				update ld_settings_field set blockid = 3 , sequence = 7 where `name` = 'report_menu_customization';
				update ld_settings_field set blockid = 3 , sequence = 8 where `name` = 'MobileAppDataListCustomization';
				update ld_settings_field set blockid = 3 , sequence = 9 where `name` = 'MobileAppMainInfoCustomization';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (4,'LBI_FUNCTION_SETTINGS',4,0,'LBI_FUNCTION_SETTINGS.png','LBI_FUNCTION_SETTINGS_hover.png');
				update ld_settings_field set blockid = 4 , sequence = 1 where `name` = 'LBL_SYSTEM_SET';
				update ld_settings_field set blockid = 4 , sequence = 2 where `name` = 'LBL_CUSTOMIZE_MODENT_NUMBER';
				update ld_settings_field set blockid = 4 , sequence = 3 where `name` = 'LBL_PICKLIST_DEPENDENCY_SETUP';
				update ld_settings_field set blockid = 4 , sequence = 4 where `name` = 'LBI_BUSINESS_SETTINGS';
				update ld_settings_field set blockid = 4 , sequence = 5 where `name` = 'CallRecordSetting';
				update ld_settings_field set blockid = 4 , sequence = 6 where `name` = 'TRACKPOSITONINGGROUP';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (5,'PROCESS_TEMPLATE_CUSTOMIZATION',5,0,'PROCESS_TEMPLATE_CUSTOMIZATION.png','PROCESS_TEMPLATE_CUSTOMIZATION_hover.png');
				insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
				select 'zh','PROCESS_TEMPLATE_CUSTOMIZATION','流程和模板定制','fixedstr' from dual
				where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PROCESS_TEMPLATE_CUSTOMIZATION' and labeltype='fixedstr');
				insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
				select 'en','PROCESS_TEMPLATE_CUSTOMIZATION',"Process and template customization",'fixedstr' from dual
				where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PROCESS_TEMPLATE_CUSTOMIZATION' and labeltype='fixedstr');
				update ld_settings_field set blockid = 5 , sequence = 1 where `name` = 'LBL_APPROVE';
				update ld_settings_field set blockid = 5 , sequence = 2 where `name` = 'LBL_WORKFLOWCUSTOMIZATION_SET';
				update ld_settings_field set blockid = 5 , sequence = 3 where `name` = 'LBL_PRINT_TEMPLATE';
				update ld_settings_field set blockid = 5 , sequence = 4 where `name` = 'THEDOCUMENTTEMPLATE';
				update ld_settings_field set blockid = 5 , sequence = 5 where `name` = 'LBL_CALENDAR_TEMPLATE';
				update ld_settings_field set blockid = 5 , sequence = 6 where `name` = 'LBL_WORK_TEMPLATE';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (6,'LBI_UI_SETTINGS',6,0,'LBI_UI_SETTINGS.png','LBI_UI_SETTINGS_hover.png');
				update ld_desk set fieldlabel = '页面定制' where labelbol = 'LBI_UI_SETTINGS' and languagetype = 'zh';
				update ld_desk set fieldlabel = 'Interface customization' where labelbol = 'LBI_UI_SETTINGS' and languagetype = 'en';
				update ld_settings_field set blockid = 6 , sequence = 1 where `name` = 'LBL_LOGIN_SETTINGS';
				update ld_desk set fieldlabel = '登录界面定制' where labelbol = 'LBL_LOGIN_SETTINGS' and languagetype = 'zh';
				update ld_settings_field set blockid = 6 , sequence = 2 where `name` = 'ld_leftmenu_ui_setting';
				update ld_settings_field set blockid = 6 , sequence = 3 where `name` = 'ld_listviewview_topui_setting';
				update ld_settings_field set blockid = 6 , sequence = 4 where `name` = 'ld_detailview_ui_setting';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (7,'LBL_OTHER_SETTINGS',7,0,'LBL_OTHER_SETTINGS.png','LBL_OTHER_SETTINGS_hover.png');
				update ld_settings_field set blockid = 7 , sequence = 1 where `name` = 'LBL_TAX_SETTINGS';
				update ld_settings_field set blockid = 7 , sequence = 2 where `name` = 'LBL_WASEHOUSE';
				update ld_settings_field set blockid = 7 , sequence = 3 where `name` = 'LBL_BACKUP_SET';
				update ld_settings_field set blockid = 7 , sequence = 4 where `name` = 'LBL_RESTOREDATABASE';
				update ld_settings_field set blockid = 7 , sequence = 5 where `name` = 'LBL_SHARING_ACCESS';
				update ld_settings_field set blockid = 7 , sequence = 6 where `name` = 'LBL_AUTHENINFO';
				update ld_settings_field set blockid = 7 , sequence = 7 where `name` = 'LBL_ACCOUNTS_CONTACTS_FIELDS';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (8,'LBL_INTERFACE_SETTINGS',8,0,'LBL_INTERFACE_SETTINGS.png','LBL_INTERFACE_SETTINGS_hover.png');
				update ld_settings_field set blockid = 8 , sequence = 1 where `name` = 'LBL_SMS_SETTINGS';
				update ld_settings_field set blockid = 8 , sequence = 2 where `name` = 'LBL_MAIL_SERVER_SETTINGS';
				update ld_settings_field set blockid = 8 , sequence = 3 where `name` = 'LBL_EXPANSION_CAMCARD';
				update ld_settings_field set blockid = 8 , sequence = 4 where `name` = 'BANGWO8INTERFACE';
				update ld_settings_field set blockid = 8 , sequence = 5 where `name` = 'LBL_PHONESTEWARD_SET';
				update ld_settings_field set blockid = 8 , sequence = 6 where `name` = 'ExternalContactSetting';
				update ld_settings_field set blockid = 8 , sequence = 7 where `name` = 'channelcode_settings';
				update ld_settings_field set blockid = 8 , sequence = 8 where `name` = 'addressbook_setting';
				update ld_settings_field set blockid = 8 , sequence = 9 where `name` = 'CHECKINSETTING';
				update ld_settings_field set blockid = 8 , sequence = 10 where `name` = 'dingtalk_setting';
				update ld_settings_field set blockid = 8 , sequence = 11 where `name` = 'dingtalk_webhook_setting';
				update ld_settings_field set blockid = 8 , sequence = 12 where `name` = 'yunzhijia_setting';
				update ld_settings_field set blockid = 8 , sequence = 13 where `name` = 'wxselfbuiltapp_setting';
				update ld_settings_field set blockid = 8 , sequence = 14 where `name` = 'weixinpay_setting';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (9,'LBI_MINI_SETTINGS',9,0,'LBI_MINI_SETTINGS.png','LBI_MINI_SETTINGS_hover.png');
				update ld_settings_field set blockid = 9 , sequence = 1 where `name` = 'WECHATAPPLETSETTINGS';


				INSERT INTO ld_settings_blocks(blockid,label,sequence,active,inactive_icon,active_icon) VALUES (10,'LBL_SERVICE_MINI_SETTINGS',10,0,'LBL_SERVICE_MINI_SETTINGS.png','LBL_SERVICE_MINI_SETTINGS_hover.png');
				update ld_desk set fieldlabel = '服务小程序' where labelbol = 'LBL_SERVICE_MINI_SETTINGS' and languagetype = 'zh' and Labeltype = 'fixedstr';
				update ld_desk set fieldlabel = 'Service applet' where labelbol = 'LBL_SERVICE_MINI_SETTINGS' and languagetype = 'en' and Labeltype = 'fixedstr';
				update ld_settings_field set blockid = 10 , sequence = 1 where `name` = 'LOGINSETTING';
				update ld_settings_field set blockid = 10 , sequence = 2 where `name` = 'MOUDLESETTING';
				update ld_settings_field set blockid = 10 , sequence = 3 where `name` = 'LISTSETTING';
				update ld_settings_field set blockid = 10 , sequence = 4 where `name` = 'DETAILSETTING';
				update ld_settings_field set blockid = 0 , sequence = 0 where `name` = 'LOGINSETTING' and linkto like '%order%';
				update ld_settings_field set blockid = 0 , sequence = 0 where `name` = 'MOUDLESETTING' and linkto like '%order%';
				update ld_settings_field set blockid = 0 , sequence = 0 where `name` = 'LISTSETTING' and linkto like '%order%';
				update ld_settings_field set blockid = 0 , sequence = 0 where `name` = 'DETAILSETTING' and linkto like '%order%';




    END IF;
end ||
delimiter;

CALL updatesettingsblocksfields();
DROP PROCEDURE IF EXISTS `updatesettingsblocksfields`;
delimiter;

INSERT INTO `ld_module_setting_byuser` ( `modulename`, `userid`, `label`, `content`)
SELECT 'WorkSheet', '1', 'WorkSheet_solution_columnname', '[\"description\",\"solution\",\"filename\"]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_module_setting_byuser WHERE label='WorkSheet_solution_columnname');
delimiter;

call AddColumn('ld_articles','smownerid','int','11','');
delimiter;

set @modulename='Articles';
set @tablename='ld_articles';
SET @tabid = (select tabid from ld_tab where `name` = 'Articles');
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_ARTICLES_INFO';

set @columnname='smownerid';
set @fieldname='assigned_user_id';
set @zh='负责人';
set @uitype=53;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='负责人';
SET @en='Owner';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
    new_normal_id 	int(11),
    new_pool_id 	int(11)
        )
    label_a:
BEGIN
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
                                   ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
                                                                                                                                                ,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                                                                                                                                                                                                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_account_set_rule_normal.days) into @maxdays
from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

select beforereminddays into @var_beforereminddays from ld_account_public_pool where id = new_pool_id;
if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
else
    				set	var_smownercolumn='smownerid' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;

    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
    			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;


if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
    				 set @TMP_TMPTable=concat(' ( select  concat("(",GROUP_CONCAT(ld_tranlabel.fieldlabel),")")  from ld_account_set_rule_normal
							INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname
							INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
							and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
							where ld_account_set_rule_normal.status="active" and normal_id = ',new_normal_id,' ORDER BY ld_account_set_rule_normal.sequence asc ) ');
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,'  separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
end if;

delete from ld_publicaccount_remindtableview ;
set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_beforereminds();
end if;
END IF;

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
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare accountid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done  int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while  done<>1 DO
		set i=1;
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，即将要回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsBEFOREREMIND',parent_remindsid);
elseif var_type='complete' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Accounts',0,'AccountsBEFOREREMIND',parent_remindsid);
end if;

			-- 循环提取每个部分的accountid并生成提醒
			WHILE i <= var_totalaccounts DO
				SET accountid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
				-- 生成提醒
				set @remind_content="您的客户未达成目标，即将要被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Accounts',accountid,'AccountsBEFOREREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
end while loop1;
close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
                                                                                                                                                                                                                          INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_account_set_rule.days) into @maxdays
from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                          INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

select beforereminddays into @var_beforereminddays  from ld_account_public_pool where  id = tmp_pool_id;


if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
end if;
select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;


if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set @old_days=var_days;
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
else
				set	var_smownercolumn='smownerid' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate) BETWEEN ",var_days,' and ' ,@old_days);
end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);
					IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',var_days);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
end if;
				set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_account.accountid)
							as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid  from ld_account  inner join ( ',@sql,' ) as lingdangtmp
							on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid ');
end if;
delete from ld_publicaccount_remindtableview ;

set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;
call crm_publicaccount_beforereminds();
end if;
end ||
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule_beforeremind(tmp_pool_id INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare var_leadsidcolumnname varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
                                 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and  (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                       INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_leads_set_rule.days) into @maxdays
from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and pool_id = tmp_pool_id;
select beforereminddays into @var_beforereminddays from ld_leads_public_pool where id=tmp_pool_id;



if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
end if;
select userid_after_release into @allotaccount from ld_leads_public_pool where id = tmp_pool_id;
select recycleselect into @recycleselect from ld_leads_public_pool where id = tmp_pool_id;
set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
						set	var_leadsidcolumnname='record' ;
else
				set	var_smownercolumn='smownerid' ;
				set	var_leadsidcolumnname='leads_id' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,' and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_leads.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_leads_set_rule.`status`='active' ORDER BY ld_leads_set_rule.sequence asc ) ";
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>\'');
			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid ') ;
ELSE
					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid') ;
end if;
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id,'  group by ld_leads.smownerid    ');
end if;
delete from ld_publicleads_remindtableview ;
set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_beforereminds();
end if;
end ||
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule_beforeremind()
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
                                   ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
                                                                                                                                                                        ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                                                                                                                                                              INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_leads_set_rule.days) into @maxdays
from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and pool_id = 1;

select recycleselect,account_rule_pool_id into @recycleselect,@leads_rule_pool_id from ld_leads_public;

select beforereminddays into @var_beforereminddays from ld_leads_public_pool where id = @leads_rule_pool_id;
if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO

    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
						  set	var_leadsidcolumnname='record' ;
else
    				set	var_smownercolumn='smownerid' ;
					   set	var_leadsidcolumnname='leads_id' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime , '",var_tabname,"' as remindtabname from ld_leads LEFT JOIN (select ld_leads.leadsid from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',
                    var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leads_id is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads inner join "  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
    			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;


if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
    				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
    									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
    									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
    										where type='complete' and ld_leads_set_rule.status='active' and ld_leads_set_rule.status='active' ORDER BY ld_leads_set_rule.sequence asc ) ";
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");

else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid ') ;
ELSE
    					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountname,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid'  );
end if;

delete from ld_publicleads_remindtableview ;
set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_beforereminds();
end if;
END IF;

end ||
delimiter;

drop PROCEDURE if exists crm_publicleads_recoveryreminds;
delimiter ||
create PROCEDURE crm_publicleads_recoveryreminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare leadsid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done  int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
declare continue handler  for not   found  SET done =1;

OPEN cur1;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while  done<>1 DO
		set i=1;
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND',parent_remindsid);
elseif var_type='complete' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND',parent_remindsid);
else
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND',parent_remindsid);

-- 循环提取每个部分的leadsid并生成提醒
WHILE i <= var_totalaccounts DO
					SET leadsid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
					-- 生成提醒
					set @remind_content="您的线索未达成目标，已被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Leads',leadsid,'LeadsRECYCLEREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
end while loop1;
close cur1;

end ||
delimiter;

drop PROCEDURE if exists crm_publicleads_beforereminds;
delimiter ||
create PROCEDURE crm_publicleads_beforereminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare var_ids text;

	declare parent_remindsid int(19); -- 父提醒id
	declare leadsid int(19); -- 当前分割出的字符串(客户id)
	declare remindid int(19); -- 子提醒id
  declare i INT DEFAULT 1;

	declare done  int  default 0;
  declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
loop1: while  done<>1 DO
		set i=1;
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsBEFOREREMIND',parent_remindsid);
elseif var_type='complete' THEN
				set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype_returnid(@tmpcontent,var_smownerid,'Leads',0,'LeadsBEFOREREMIND',parent_remindsid);
end if;

			-- 循环提取每个部分的leadsid并生成提醒
			WHILE i <= var_totalaccounts DO
				SET leadsid = SUBSTRING_INDEX(SUBSTRING_INDEX(var_ids, '##', i), '##', -1);
				-- 生成提醒
				set @remind_content="您的线索未达成目标，已被回收到公海池。";
call ldcrm_add_reminder_havetype_returnid(@remind_content,var_smownerid,'Leads',leadsid,'LeadsBEFOREREMIND',remindid);
update ld_reminds set deleted=1,parentid=parent_remindsid where remindsid=remindid;
SET i = i + 1;
END WHILE;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid,var_ids;
end while loop1;
close cur1;

end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','systemmanagement','系统管理','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='systemmanagement' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','systemmanagement',"system management",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='systemmanagement' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','crmmanagement','CRM管理','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='crmmanagement' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','crmmanagement',"CRM management",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='crmmanagement' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Integratedmanagement','集成管理','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Integratedmanagement' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Integratedmanagement',"Integrated management",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Integratedmanagement' and labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `reset_key_20241225`;
delimiter ||
CREATE  PROCEDURE `reset_key_20241225`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_cashback' AND CONSTRAINT_NAME='ld_cashback_ibfk_1') THEN
		ALTER TABLE ld_cashback DROP FOREIGN KEY ld_cashback_ibfk_1;
	END IF;
	
	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_cashbackscf' AND CONSTRAINT_NAME='ld_cashbackscf_ibfk_1') THEN
		ALTER TABLE ld_cashbackscf DROP FOREIGN KEY ld_cashbackscf_ibfk_1;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_customview' AND CONSTRAINT_NAME='ld_customview_ibfk_1') THEN
		ALTER TABLE ld_customview DROP FOREIGN KEY ld_customview_ibfk_1;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_parenttabrel' AND CONSTRAINT_NAME='fk_1_vtiger_parenttabrel') THEN
		ALTER TABLE ld_parenttabrel DROP FOREIGN KEY fk_1_vtiger_parenttabrel;
	END IF;

	IF EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='ld_parenttabrel' AND CONSTRAINT_NAME='fk_2_vtiger_parenttabrel') THEN
		ALTER TABLE ld_parenttabrel DROP FOREIGN KEY fk_2_vtiger_parenttabrel;
	END IF;

end ||
delimiter;

CALL reset_key_20241225();
DROP PROCEDURE IF EXISTS `reset_key_20241225`;
delimiter;

DROP PROCEDURE IF EXISTS `reset_renshi_20240624`;
delimiter ||
CREATE  PROCEDURE `reset_renshi_20240624`(
)
BEGIN
	
	IF NOT EXISTS (SElECT 1 FROM ld_linkmodulecustom WHERE url LIKE 'CustomReport/JsReport/index.php?crm_report_key=default_performance_project.mrt%') THEN
		INSERT INTO ld_linkmodulecustom(`name`,zh_label,en_label,url,`status`,scope,entitytype,linkmodule)
		SELECT 'CRMLinkModule_performanceprojec','项目提成表','项目提成表','CustomReport/JsReport/index.php?crm_report_key=default_performance_project.mrt&default_report=1&report_name=%E9%A1%B9%E7%9B%AE%E6%8F%90%E6%88%90%E8%A1%A8','yes','all','custom','Customreport';
	END IF;

	IF NOT EXISTS (SElECT 1 FROM ld_linkmodulecustom WHERE url LIKE 'CustomReport/JsReport/index.php?crm_report_key=default_performance_byorder.mrt%') THEN
		INSERT INTO ld_linkmodulecustom(`name`,zh_label,en_label,url,`status`,scope,entitytype,linkmodule)
		SELECT 'CRMLinkModule_performanceprojec','销售提成表_按合同统计','销售提成表_按合同统计','CustomReport/JsReport/index.php?crm_report_key=default_performance_byorder.mrt&default_report=1&report_name=%E9%94%80%E5%94%AE%E6%8F%90%E6%88%90%E8%A1%A8_%E6%8C%89%E5%90%88%E5%90%8C%E7%BB%9F%E8%AE%A1','yes','all','custom','Customreport';
	END IF;

	IF NOT EXISTS (SElECT 1 FROM ld_linkmodulecustom WHERE url LIKE 'CustomReport/JsReport/index.php?crm_report_key=default_performance_bycashbill.mrt%') THEN
		INSERT INTO ld_linkmodulecustom(`name`,zh_label,en_label,url,`status`,scope,entitytype,linkmodule)
		SELECT 'CRMLinkModule_performanceprojec','销售提成表_按收款统计','销售提成表_按收款统计','CustomReport/JsReport/index.php?crm_report_key=default_performance_bycashbill.mrt&default_report=1&report_name=%E9%94%80%E5%94%AE%E6%8F%90%E6%88%90%E8%A1%A8_%E6%8C%89%E6%94%B6%E6%AC%BE%E7%BB%9F%E8%AE%A1','yes','all','custom','Customreport';
	END IF;

	
	SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='RenShiGuanLi' LIMIT 1);
	SET @linkid=(SElECT id FROM ld_linkmodulecustom WHERE url LIKE 'CustomReport/JsReport/index.php?crm_report_key=default_performance_byorder.mrt%' ORDER BY id DESC LIMIT 1);
	INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
	SELECT @parenttabid,@linkid,100001,'ld_linkmodulecustom' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@linkid AND tab_tablename='ld_linkmodulecustom');

	SET @linkid=(SElECT id FROM ld_linkmodulecustom WHERE url LIKE 'CustomReport/JsReport/index.php?crm_report_key=default_performance_bycashbill.mrt%' ORDER BY id DESC LIMIT 1);
	INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
	SELECT @parenttabid,@linkid,100002,'ld_linkmodulecustom' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@linkid AND tab_tablename='ld_linkmodulecustom');

	SET @linkid=(SElECT id FROM ld_linkmodulecustom WHERE url LIKE 'CustomReport/JsReport/index.php?crm_report_key=default_performance_project.mrt%' ORDER BY id DESC LIMIT 1);
	INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
	SELECT @parenttabid,@linkid,100003,'ld_linkmodulecustom' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@linkid AND tab_tablename='ld_linkmodulecustom');

	
	SET @i=0;
	UPDATE ld_parenttabrel SET sequence=(@i=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;

end ||
delimiter;


CALL reset_renshi_20240624();
DROP PROCEDURE IF EXISTS `reset_renshi_20240624`;
delimiter;


SET @labelbol = 'THEDAYBEFORE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'前一天',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The day before',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'THEDAYAFTER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'后一天',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The day after',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','historyNames','曾用名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='historyNames' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','historyNames','Name used before','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='historyNames' and Labeltype='fixedstr' and languagetype='en');
delimiter;
SET @sequence = (select max(sequence) from ld_business_mappingfields);
SET @mappingfieldname='historyNames';
SET @mappingfieldlabel='historyNames';
insert into ld_business_mappingfields (`mappingfieldlabel`,`mappingfieldname`,`sequence`)
select @mappingfieldlabel,@mappingfieldname,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_business_mappingfields WHERE mappingfieldlabel=@mappingfieldlabel and mappingfieldname=@mappingfieldname);
delimiter;
SET @tianyanchaname = 'historyNames';
SET @tianyanchalabel = 'historyNames';
SET @sequence = (select max(sequence) from ld_business_backfillfield);
insert into ld_business_backfillfield (`tabid`,`tianyanchalabel`,`tianyanchaname`,`sequence`)
select ld_business_settings.tabid,@tianyanchalabel,@tianyanchaname,@sequence+1 from ld_business_settings
where NOT EXISTS (SELECT 1 from ld_business_backfillfield WHERE tianyanchalabel=@tianyanchalabel and tianyanchaname=@tianyanchaname and tabid=ld_business_settings.tabid );
delimiter;
-- 2024-06-25

SET @tabid = (select tabid from ld_tab where `name`='Leads');
UPDATE ld_field set businessquery = 'no' WHERE tabid = @tabid;
UPDATE ld_field set businessquery = 'yes' WHERE tabid = @tabid and fieldid = (SELECT fieldid from ld_business_settings WHERE tabid = @tabid);
delimiter;

update ld_appsystem set is_open = 'yes' where deploy_type = 4;
delimiter;


SET @labelbol = 'DepartmentComponents';
set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'部门组件',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Department Components',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_AddOrUpdateRelationFrom_20240621`;
delimiter ||
CREATE PROCEDURE `ldcrm_AddOrUpdateRelationFrom_20240621` ()
BEGIN
    IF NOT EXISTS ( SELECT 1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA = DATABASE () AND TABLE_NAME = 'ld_relatecreatecondition' AND column_name = 'relationfrom') THEN
        CALL AddColumn('ld_relatecreatecondition','relationfrom','varchar','50','main');
        ALTER TABLE ld_relatecreatecondition ALTER COLUMN relationfrom SET DEFAULT 'main';
        UPDATE ld_relatecreatecondition
        INNER JOIN ld_tab on ld_tab.name = ld_relatecreatecondition.modulename
        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_field.columnname=ld_relatecreatecondition.columnname
        SET relationfrom = 'main';
        UPDATE ld_relatecreatecondition
        SET relationfrom = 'detail'
        WHERE relationfrom != 'main' OR relationfrom IS NULL;
    END IF;
END||
delimiter;
CALL ldcrm_AddOrUpdateRelationFrom_20240621();
DROP PROCEDURE IF EXISTS `ldcrm_AddOrUpdateRelationFrom_20240621`;
delimiter;


update ld_desk set fieldlabel='常用' where labelbol='commonmodules' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='Common' where labelbol='commonmodules' and languagetype='en' and labeltype='fixedstr';
update ld_desk set fieldlabel='最近' where labelbol='recentModule' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='Recently' where labelbol='recentModule' and languagetype='en' and labeltype='fixedstr';
update ld_desk set fieldlabel='高频' where labelbol='highFrequency' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='High frequency' where labelbol='highFrequency' and languagetype='en' and labeltype='fixedstr';
delimiter;
-- 2024-06-26

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
DELIMITER ||
CREATE   PROCEDURE `account_singlerecycle_highsea_rule`(IN tmp_pool_id INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR
select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule
                                                                                                                                                                            inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                                                                                                                                                                            INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and (ld_field.presence in(0,2))
where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

declare continue handler  for not found SET done =1;
	set @tmpint=0;
	set @tmpsql='';

select max(ld_account_set_rule.days) into @maxdays
from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
                          INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

select IF(ld_users.id>0,userid_after_release,0) into @allotaccount from ld_account_public_pool LEFT join ld_users on ld_users.id=userid_after_release
where ld_account_public_pool.id = tmp_pool_id;

if  ifnull(@allotaccount,0)=0  then
			set @allotaccount=0;
end if;
select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;

if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
else
				set	var_smownercolumn='smownerid' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );

				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;
if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id =  ',tmp_pool_id);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
else
			if @recycleselect is not null and @recycleselect<>'' then
				set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
ELSE
				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
end if;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);

prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;

set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,\'</a>\'';
if var_condition='or'  then
			set @TMPSQL_ONE=concat( 'select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid) as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ld_account.pool_id = ',tmp_pool_id);
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'   group by ld_account.smownerid    ');
end if;

delete from ld_publicaccount_remindtableview ;


set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids ) ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_recoveryreminds();
if @allotaccount>0 then
select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field
                                                                                                                                          INNER JOIN ld_related_field on ld_related_field.effect_fieldid=ld_field.fieldid where ld_field.uitype=1600  )  as  tmp
                                                     INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
where ld_field.tabid=6 and ld_field.columnname='smownerid'
  and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;

select  tmp.columnname into @groupcolumnname  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
                                                                                                                                                            on ld_related_field.effect_fieldid=ld_field.fieldid
                                                    where ld_field.uitype=1600  )  as  tmp
                                                       INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
where ld_field.tabid=6 and ld_field.columnname='smownerid'
  and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;
end if;
	if var_condition='or'  then

		 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		if @recycleselect<>'' and @recycleselect is not null THEN
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		 if @allotaccount>0 THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
ELSE

	  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);

						if   ifnull(@groupcolumnname,'')!='' then

select GROUP_CONCAT(groupid) into @groupid from  ld_users2group where userid =@allotaccount;
set @TMPSQL_GroupEditSql=concat( ' update  ',@grouptablename,' inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=',@grouptablename,'.accountid ') ;
								if @grouptablename!='ld_account' then
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' inner join ld_account on ld_account.accountid=ld_accountscf.accountid ');
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql, ' set ',@groupcolumnname,'="', @groupid,'"');

end if ;
								set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
prepare stmt1 from @TMPSQL_GroupEditSql;
execute stmt1;
deallocate prepare stmt1;
end if;

end if;
  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
end ||
delimiter;
-- 2024-06-28

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

UPDATE ld_version SET old_version='V8.6.3.8',current_version='V8.6.3.8',remark='V8.6.3.8-20240628',wx_version='V8.6.3.8';
delimiter;