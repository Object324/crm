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

CALL AddColumn('ld_module_mappingfields','mapped_columnname','varchar','100','');
delimiter;

CALL AddColumn('ld_wx_communicate','pid','int','19','');
CALL AddColumn('ld_wx_communicate','role_type','varchar','50','serviceaccount');
update ld_wx_communicate set role_type='serviceaccount' where module='HelpDesk' and role_type is null;  
delimiter;


alter table ld_wx_communicate alter column role_type drop default; 
alter table ld_wx_communicate alter column role_type set default 'serviceaccount';
delimiter;

CALL AddColumn('ld_wx_communicate','crmuserid','int','19','');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','UnselectedIcon','未选中图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UnselectedIcon' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','UnselectedIcon','Unselected Icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UnselectedIcon' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SelectedIcon','选中图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectedIcon' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SelectedIcon','Selected Icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectedIcon' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SelectIcon','选择图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectIcon' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SelectIcon','Select Icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectIcon' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','menuIconUploadSizeTips','建议尺寸大小为：90*90(像素)，格式：png','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='menuIconUploadSizeTips' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','menuIconUploadSizeTips','Recommended size: 90 * 90 (pixels), format: png','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='menuIconUploadSizeTips' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','menuIconUploadTips','图片大小不允许超过1M','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='menuIconUploadTips' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','menuIconUploadTips','The picture size cannot exceed 1M','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='menuIconUploadTips' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_parenttab','inactive_icon','varchar','255','');
call AddColumn('ld_parenttab','active_icon','varchar','255','');
-- 2021-12-08

UPDATE ld_field SET displaytype=3 WHERE tabid=2 AND columnname IN ('total','subtotal');
update ld_producttoolfield  set fieldid=0 ,input_type=1 ,edit_permission=1 where tabid=76 and columnname='paperquantity';
delimiter;

DROP PROCEDURE IF EXISTS `reset_gongchengdemo_20211202`;
delimiter ||
CREATE  PROCEDURE `reset_gongchengdemo_20211202`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='construction') OR 1=1 THEN
		SET @report_name='项目进度计划';
		SET @report_type='template_js';
		SET @report_template='default_project_progress.mrt';
		SET @setype='';
		SET @report_describe='';
		SET @report_url='';
		SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
		SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

		UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
		INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
		SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);

		SET @report_name='项目进度计划与实际对比';
		SET @report_type='template_js';
		SET @report_template='default_project_progresscontrast.mrt';
		SET @setype='';
		SET @report_describe='';
		SET @report_url='';
		SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
		SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

		UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
		INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
		SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);


		UPDATE ld_usercolor SET color='140,139,170' WHERE id=1;
		UPDATE ld_usercolor SET color='222,221,226' WHERE id=2;
		UPDATE ld_usercolor SET color='181,199,201' WHERE id=3;
		UPDATE ld_usercolor SET color='196,218,201' WHERE id=4;
		UPDATE ld_usercolor SET color='146,200,224' WHERE id=5;
		UPDATE ld_usercolor SET color='103,171,214' WHERE id=6;
		UPDATE ld_usercolor SET color='195,176,214' WHERE id=7;
		UPDATE ld_usercolor SET color='0,158,78' WHERE id=8;
		UPDATE ld_usercolor SET color='253,197,0' WHERE id=9;
		UPDATE ld_usercolor SET color='248,125,11' WHERE id=10;
		UPDATE ld_usercolor SET color='22,119,210' WHERE id=11;
	END IF;

end ||
delimiter;

CALL reset_gongchengdemo_20211202();
DROP PROCEDURE IF EXISTS `reset_gongchengdemo_20211202`;
delimiter;

UPDATE ld_producttoolfield SET allowhide='yes' WHERE columnname In ('entitytype','entitytypeid') AND tabid=22;

update ld_producttoolfield  set fieldid=0 ,input_type=0 ,edit_permission=1,uitype=10 ,savedatabase='yes' where tabid=76 and columnname='paperquantity';
delimiter;

set @tabid = (SELECT tabid from ld_tab where name = 'SalesOrder');
set @effect_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'smownerid');
set @trigger_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'accountid');
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'assigned_user_id','column','smownerid' 
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);

set @trigger_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'contactid');
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'','sql',
			'select ld_account.smownerid from ld_contactdetails LEFT JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid and ld_account.deleted = 0 where ld_contactdetails.contactid = ?' 
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);

set @trigger_fieldid = 393 ;
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'assigned_user_id','sql',
			'select ld_account.smownerid from ld_quotes LEFT JOIN ld_account on ld_account.accountid = ld_quotes.accountid and ld_account.deleted = 0 where quoteid = ?' 
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);

set @trigger_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'potentialid');
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'contact_id,contacts_name','sql',
			'select ld_account.smownerid from ld_potential LEFT JOIN ld_account on ld_account.accountid = ld_potential.accountid and ld_account.deleted = 0 where ld_potential.potentialid = ?' 
from DUAL where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

call AddColumn('ld_tab','default_icon','varchar','255','');
call AddColumn('ld_tab','active_icon','varchar','255','');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ModuleIcon','模块图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ModuleIcon' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ModuleIcon','Module Icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ModuleIcon' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MobileTerminal','移动端','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MobileTerminal' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MobileTerminal','Mobile terminal','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MobileTerminal' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SelectTheNewIcon','选择新图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectTheNewIcon' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SelectTheNewIcon','Select the new icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectTheNewIcon' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_linkmodulecustom','active_icon','varchar','255','');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RestoreDefaultIcon','恢复默认图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RestoreDefaultIcon' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RestoreDefaultIcon','Restore default icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RestoreDefaultIcon' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Areyousureyouwanttorestorethedefaulticon','确定要恢复默认图标吗？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Areyousureyouwanttorestorethedefaulticon' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Areyousureyouwanttorestorethedefaulticon','Are you sure you want to restore the default icon?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Areyousureyouwanttorestorethedefaulticon' and labeltype='jspop');
delimiter;
-- 2021-12-10

CALl AddColumn('ld_customform21','triggercount','INT','19','0');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ServiceKanban','服务看板','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ServiceKanban' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ServiceKanban','Service Kanban','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ServiceKanban' and labeltype='fixedstr');
delimiter;

select Parent_id into @Parent_id from ld_usereport where name='Serviceperformanceappraisal';
select sequence+1 into @sequence from ld_usereport where name='Serviceperformanceappraisal';
select tabid into @tabid from ld_tab where name='HelpDesk';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,Parent_id, sequence, reporttype, pagewidthpercent)
  select 'ServiceKanban','服务看板',@tabid,1,1,1,@Parent_id,@sequence,67,100 from dual
  where not exists(select 1 from ld_usereport where name='ServiceKanban');

select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:createdtime:创建时间:HelpDesk_createdtime:DT',1,1,'ld_troubletickets:createdtime:创建时间:HelpDesk_创建时间:DT','ld_troubletickets:createdtime:创建时间:HelpDesk_createdtime:DT' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:createdtime:创建时间:HelpDesk_createdtime:DT');
delimiter;

insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_account:accountname:客户名称:Accounts_accountname:V',2,1,'ld_account:accountname:客户名称:Accounts_客户名称:V','ld_account:accountname:客户名称:Accounts_accountname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_account:accountname:客户名称:Accounts_accountname:V');
delimiter;

insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_account:lastservicedate:最晚服务到期日:Accounts_lastservicedate:D',3,1,'ld_account:lastservicedate:最晚服务到期日:Accounts_最晚服务到期日:D','ld_account:lastservicedate:最晚服务到期日:Accounts_lastservicedate:D' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_account:lastservicedate:最晚服务到期日:Accounts_lastservicedate:D');
delimiter;

insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:waitingtime:等待时间（分钟）:HelpDesk_waitingtime:N',4,1,'ld_troubletickets:waitingtime:等待时间（分钟）:HelpDesk_等待时间（分钟）:N','ld_troubletickets:waitingtime:等待时间（分钟）:HelpDesk_Waiting time (minutes):N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:waitingtime:等待时间（分钟）:HelpDesk_waitingtime:N');
delimiter;

select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:ticketstatus:处理状态:HelpDesk_ticketstatus:V',5,1,'ld_troubletickets:ticketstatus:处理状态:HelpDesk_处理状态:V','ld_troubletickets:ticketstatus:处理状态:HelpDesk_ticketstatus:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:ticketstatus:处理状态:HelpDesk_ticketstatus:V');
delimiter;

select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:smownerid:处理人:HelpDesk_smownerid:V',6,1,'ld_troubletickets:smownerid:处理人:HelpDesk_处理人:V','ld_troubletickets:smownerid:处理人:HelpDesk_Handler:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:smownerid:处理人:HelpDesk_smownerid:V');
delimiter;

select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:distributetime:服务开始时间:HelpDesk_distributetime:DT',7,1,'ld_troubletickets:distributetime:服务开始时间:HelpDesk_服务开始时间:DT','ld_troubletickets:distributetime:服务开始时间:HelpDesk_Service start time:DT' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:distributetime:服务开始时间:HelpDesk_distributetime:DT');
delimiter;


select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:approvesubmittedtime:服务结束时间:HelpDesk_approvesubmittedtime:DT',8,1,'ld_troubletickets:approvesubmittedtime:服务结束时间:HelpDesk_服务结束时间:DT','ld_troubletickets:approvesubmittedtime:服务结束时间:HelpDesk_Service end time:DT' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:approvesubmittedtime:服务结束时间:HelpDesk_approvesubmittedtime:DT');
delimiter;

insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:ServiceTime:服务用时（分钟）:HelpDesk_ServiceTime:N',9,1,'ld_troubletickets:ServiceTime:服务用时（分钟）:HelpDesk_服务用时（分钟）:N','ld_troubletickets:ServiceTime:服务用时（分钟）:HelpDesk_Service time (minutes):N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:ServiceTime:服务用时（分钟）:HelpDesk_ServiceTime:N');
delimiter;

insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_account:accountname:accountname:Accounts_accountname:V','',8 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_account:accountname:accountname:Accounts_accountname:V');

insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_troubletickets:createdtime:createdtime:HelpDesk_createdtime:D','thisstartmonth~thisendmonth',7 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_troubletickets:createdtime:createdtime:HelpDesk_createdtime:D');
delimiter;
CALL AddColumn('ld_worksheet','currentapprovestepid','int','19','');
delimiter;

CALL AddColumn('ld_worksheet','approvesubmitter','int','19','');
delimiter;

CALL AddColumn('ld_worksheet','approvesubmittedtime','datetime','','');
delimiter;
CALL AddColumn('ld_worksheet','approveurgent','varchar','10','');
delimiter;
CALL AddColumn('ld_worksheet','approveexpediting','varchar','10','');
delimiter;
-- 2021-12-16

select usereportid into @usereportid from ld_usereport where name='ServiceKanban';
delete from ld_usereportcolumns where Usereportid=@usereportid and `columns` = 'ld_troubletickets:ServiceTime:服务用时（分钟）:HelpDesk_ServiceTime:N';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_troubletickets:servicetime:服务用时（分钟）:HelpDesk_servicetime:N',9,1,'ld_troubletickets:servicetime:服务用时（分钟）:HelpDesk_服务用时（分钟）:N','ld_troubletickets:servicetime:服务用时（分钟）:HelpDesk_Service time (minutes):N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_troubletickets:servicetime:服务用时（分钟）:HelpDesk_servicetime:N');
delimiter;


UPDATE ld_tab SET presence=5 WHERE name='ShopSettings' AND presence=1;
delimiter;


select tabid into @tabid from ld_tab where name = 'WeChatUser';
select block into @block from ld_field where tabid = @tabid and columnname = 'smownerid';
update ld_field set block = @block where tabid = @tabid and columnname = 'userfrom';
update ld_field set uitype = 1051 where tabid = @tabid and columnname = 'imagename';
delimiter;
-- 2021-12-17

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

UPDATE ld_version SET old_version='V8.4.5.4',current_version='V8.4.5.4',remark='V8.4.5.4-20211217',wx_version='V8.4.5.4';
delimiter;