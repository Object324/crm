DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
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

SET @report_name='销售提成表-按合同创建人统计';
SET @report_type='template_js';
SET @report_template='default_performance_byorder2.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;


SET @report_name='销售提成表——按收款创建人统计';
SET @report_type='template_js';
SET @report_template='default_performance_bycashbill2.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;


SET @report_name='合同跟踪表-按合同创建人统计';
SET @report_type='template_js';
SET @report_template='default_ordertracking2.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;

UPDATE ld_customreport_info SET presence=5 WHERE report_template IN ('default_performance_byorder2.mrt','default_performance_bycashbill2.mrt','default_ordertracking2.mrt');
delimiter;


SET @account_pageurl = 'index.php?pageto_module=Accounts&pageto_action=index&pagepublicaccounttype=ALLACCOUNT';
UPDATE ld_homestuffdetail SET pageurl = @account_pageurl where stufflabel = 'NewAccounts';
UPDATE ld_homestuffdetail SET pageurl = @account_pageurl where stufflabel = 'LeadUgradeToCustomerCount';
delimiter;
SET @account_potential_pageurl = 'index.php?pageto_module=Accounts&pageto_action=index&pagepublicaccounttype=ALLACCOUNT,index.php?pageto_module=Potentials&pageto_action=index';
UPDATE ld_homestuffdetail SET pageurl = @account_potential_pageurl where stufflabel = 'LeadUgradeToPotentials';
delimiter;
SET @leads_pageurl = 'index.php?pageto_module=Leads&pageto_action=index&pagepublicaccounttype=ALLACCOUNT';
UPDATE ld_homestuffdetail SET pageurl = @leads_pageurl where stufflabel = 'NewLeadsCount';
delimiter;

UPDATE ld_desk SET fieldlabel='转公海' where labelbol = 'Transfer' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel = 'Total contract amount received' where labelbol = 'CONTRACTRECIVETOTAL' and languagetype='en' and Labeltype='fixedstr';
delimiter;

UPDATE ld_desk SET fieldlabel='Transfer' where labelbol = 'Transfer' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dingtalk_webhook_tips3','设置单据提交审批后，自动推送单据内容至钉钉群','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='dingtalk_webhook_tips3' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dingtalk_webhook_tips3',"Set the content of the document to be automatically pushed to the DingTalk group after the document is submitted for approval",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='dingtalk_webhook_tips3' and labeltype='fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
insert into ld_wx_config (name,description) select 'wxselfbuiltapp_setting','企业微信自建应用设置' from dual where not exists(select 1 from ld_wx_config where name='wxselfbuiltapp_setting');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(id) into @maxfieldid from ld_settings_field_seq;
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
update ld_settings_field_seq set id=@maxfieldid +1  where not exists(select 1 from ld_settings_field where name='wxselfbuiltapp_setting');
delimiter;

select sequence into @sequence from ld_settings_field where linkto like '%wxselfbuiltapp_setting%' and blockid=@blockid;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select  @maxfieldid +1,@blockid,'wxselfbuiltapp_setting','picklistdependency.png','企业微信自建应用设置','index.php?module=Settings&action=wxselfbuiltapp_setting&parenttab=Settings',@sequence+1,0
from dual where not exists(select 1 from ld_settings_field where name='wxselfbuiltapp_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','wxselfbuiltapp_setting','企业微信自建应用设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='wxselfbuiltapp_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','wxselfbuiltapp_setting','Enterprise wechat self-built application Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='wxselfbuiltapp_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_reminds','push_to_wxselfbuilt','int','2',0);
delimiter;
CALL AddColumn('ld_reminds_accepted','push_to_wxselfbuilt','int','2',0);
delimiter;
CALL AddColumn('ld_workreport_remind','push_to_wxselfbuilt','int','2',0);
delimiter;
CALL AddColumn('ld_reminds','push_time_wxselfbuilt','datetime',null ,null );
delimiter;
CALL AddColumn('ld_reminds_accepted','push_time_wxselfbuilt','datetime',null ,null );
delimiter;
CALL AddColumn('ld_workreport_remind','push_time_wxselfbuilt','datetime',null,null);
delimiter;

alter table `ld_reminds` change `push_to_wxselfbuilt` `push_to_wxselfbuilt` int DEFAULT 2 COMMENT '企业微信自建应用提醒发送标识';
alter table `ld_reminds` change `push_time_wxselfbuilt` `push_time_wxselfbuilt` datetime COMMENT '企业微信自建应用提醒发送时间';
alter table `ld_reminds_accepted` change `push_to_wxselfbuilt` `push_to_wxselfbuilt` int DEFAULT 2 COMMENT '企业微信自建应用提醒发送标识';
alter table `ld_reminds_accepted` change `push_time_wxselfbuilt` `push_time_wxselfbuilt` datetime COMMENT '企业微信自建应用提醒发送时间';
alter table `ld_workreport_remind` change `push_to_wxselfbuilt` `push_to_wxselfbuilt` int DEFAULT 2 COMMENT '企业微信自建应用提醒发送标识';
alter table `ld_workreport_remind` change `push_time_wxselfbuilt` `push_time_wxselfbuilt` datetime COMMENT '企业微信自建应用提醒发送时间';
delimiter;

update ld_reminds set push_to_wxselfbuilt = push_to_weixin  where push_to_wxselfbuilt = 0;
update ld_reminds_accepted set push_to_wxselfbuilt = 3 where push_to_wxselfbuilt = 0;
delimiter;

update ld_producttoolfield set bigtype='num' where columnname='quantity';
delimiter; 

call AddColumn('ld_advancepicklist','stagename_target','varchar','255','');
delimiter;

call AddColumn('ld_advancepicklist','presence','varchar','10','yes');
delimiter;

call AddColumn('ld_advancepicklist','profileid','varchar','255','');
delimiter;

call AddColumn('ld_advancepicklist','userid','varchar','255','');
delimiter;

call AddColumn('ld_advancepicklist','userfieldid','varchar','255','');
delimiter;

call AddColumn('ld_advancepicklisttask','completerequest','varchar','10','');
delimiter;

call AddColumn('ld_advancepicklisttask','presence','varchar','10','yes');
delimiter;

SET @labelbol = 'PLEASESETRELATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请先设置状态间的先后流转关系','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please set the sequential flow relationship between States','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'PLEASEENABLETASKTYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请先启用任务类型','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enable the task type first','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'ENTERPUSHERTIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'进入推进人和时间','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Enter pusher and time','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LEAVEPUSHERTIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'离开推进人和时间','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Leave pusher and time','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PROCESSSETTINGS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'流程设置','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Process settings','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FROMPUSHTO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'从【%s】，可流转到','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push 【%s】 to','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SETADVANCERELATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置各状态间的先后流转关系，请在需要流转的状态间的复选框内打勾。','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'To set the sequential flow relationship between States, please check the check box between states to be transferred','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONFIGURATIONTASKANDUSER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'配置阶段推进任务和授权用户','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Configuration phase advance tasks and authorized users','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENTCIRCULATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前流转','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Current Circulation','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHOPERATIONPERMISSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推进操作权限','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push operation permission','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHPERMISSIONDESCRIPTION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'配置阶段推进的用户权限，如果为空则表示有“推进”按钮操作权限和单据查看权限的人可操作','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'the user permission pushed in the configuration phase. If it is blank, it means that the person with "push" button operation permission and document viewing permission can operate','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'USERFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'用户字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'User field','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADVANCETASK';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推进任务','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Advance task','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CREATERECORD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'创建单据','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create record','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CHECKTYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'勾选型','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Tick selection','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTTYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选项型','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'select type','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SELECTTYPE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选项型','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'select type','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'AUTOMATICPROPULSION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'所有任务完成后自动推进','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Automatic propulsion after all tasks are completed','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOTENABLEORNOPERMIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该字段未启用，或您没有该字段的查看权限，请联系管理员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This field is not enabled, or you do not have permission to view this field, please contact the administrator','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'STAGEDETENTIONDURATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'阶段滞留时长','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Stage detention duration','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SHOWADVANCEDETAIL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'点击查看推进详情','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click to show advance detail','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ENTERSTAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'进入阶段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Enter stage','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LEAVESTAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'离开阶段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Leave stage','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OPERATIONER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作人员','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'operator','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'current','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADVANCEPUSHDETAIL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'阶段推进详情','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Advance push detail','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'TASKINFOEMPTY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未设置任务信息','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Task information is not set','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

drop PROCEDURE if EXISTS AdvanceDataBackup;
delimiter ||
create PROCEDURE AdvanceDataBackup
(
)
BEGIN
	CREATE TABLE IF NOT EXISTS ld_advancepicklist_bak8466 LIKE ld_advancepicklist;
	IF NOT EXISTS (SELECT 1 from ld_advancepicklist_bak8466 ) and EXISTS(SELECT 1 from ld_advancepicklist) THEN
		INSERT INTO ld_advancepicklist_bak8466 SELECT * FROM ld_advancepicklist;
	END if;

	CREATE TABLE IF NOT EXISTS ld_advancepicklisttask_bak8466 LIKE ld_advancepicklisttask;
	IF NOT EXISTS (SELECT 1 from ld_advancepicklisttask_bak8466 ) and EXISTS(SELECT 1 from ld_advancepicklisttask) THEN
		INSERT INTO ld_advancepicklisttask_bak8466 SELECT * FROM ld_advancepicklisttask;
	END if;

	CREATE TABLE IF NOT EXISTS ld_advancepicklistlog_bak8466 LIKE ld_advancepicklistlog;
	IF NOT EXISTS (SELECT 1 from ld_advancepicklistlog_bak8466 )and EXISTS(SELECT 1 from ld_advancepicklistlog)  THEN
		INSERT INTO ld_advancepicklistlog_bak8466 SELECT * FROM ld_advancepicklistlog;
	END if;

	CREATE TABLE IF NOT EXISTS ld_advancepicklist_selectinfo_bak8466 LIKE ld_advancepicklist_selectinfo;
	IF NOT EXISTS (SELECT 1 from ld_advancepicklist_selectinfo_bak8466 )and EXISTS(SELECT 1 from ld_advancepicklist_selectinfo)  THEN
		INSERT INTO ld_advancepicklist_selectinfo_bak8466 SELECT * FROM ld_advancepicklist_selectinfo;
	END if;
end ||
delimiter;

call AdvanceDataBackup();
drop PROCEDURE  if EXISTS AdvanceDataBackup;
delimiter;

drop PROCEDURE if EXISTS update_advance_first;
delimiter ||
create PROCEDURE update_advance_first
(
)
BEGIN
 declare var_id int(19);
 declare done  int  default 0;
 declare cur1 CURSOR FOR SELECT id FROM  ld_settings_advance where method = 'field' and module_field is not NULL;
 declare continue handler  for not   found  SET done =1;
 
SET @@max_sp_recursion_depth = 5;
 open cur1;
Fetch cur1 into var_id;
 loop1: while  done<>1 DO
        
        set @sql='select tabid,pushback,module_field into @tabid,@pushback,@module_field from ld_settings_advance  where ';
				set @sql=CONCAT(@sql, " id='",var_id,"'");
				prepare stmt from @sql;
				execute stmt;
				deallocate prepare stmt;
				
				set @sql="SELECT listid into @listid FROM ld_picklist_set where listname = ";
				set @sql=CONCAT(@sql, "'",@module_field,"' LIMIT 1");
				prepare stmt from @sql;
				execute stmt;
				deallocate prepare stmt;

				call update_advance_second(@module_field,@tabid,@pushback,@listid);
    
				Fetch cur1 into var_id;
 end while loop1;
 close cur1;
end ||
delimiter;

drop PROCEDURE if EXISTS update_advance_second;
delimiter ||
create PROCEDURE update_advance_second
(
module_field varchar(100),
var_tabid int(10),
pushback varchar(10),
tmp_listid int(10)
)
BEGIN
 declare var_stagename varchar(100);
 declare pre_stagename varchar(100);
 declare done1  int  default 0;
	
 declare cur1 CURSOR FOR SELECT listvalue FROM ld_picklist_values where listid = tmp_listid ORDER BY sequence ASC;
 declare continue handler  for not   found  SET done1 =1;
 
 open cur1;
Fetch cur1 into var_stagename;
 loop1: while  done1<>1 DO
        IF pushback = 'yes' THEN
					call update_advance_third(module_field,var_tabid,tmp_listid,var_stagename);
					IF pre_stagename <> '' AND EXISTS(SELECT 1 from ld_advancepicklist where stagename = pre_stagename and tabid = var_tabid and fieldname = module_field and (stagename_target = '' or stagename_target is NULL)) THEN
						DELETE from ld_advancepicklist where stagename = pre_stagename and tabid = var_tabid and fieldname = module_field and stagename_target = var_stagename;
						UPDATE ld_advancepicklist SET stagename_target = var_stagename,presence='yes' where stagename = pre_stagename and tabid = var_tabid and fieldname = module_field and (stagename_target = '' or stagename_target is NULL);
					END if;
			  ELSEIF pre_stagename <> '' THEN
					UPDATE ld_advancepicklist SET stagename_target = var_stagename,presence='yes' where stagename = pre_stagename and tabid = var_tabid and fieldname = module_field and (stagename_target = '' or stagename_target is NULL);
					CALL update_advance_fourth(module_field,var_tabid,pre_stagename,var_stagename);
				END if;
				SET pre_stagename = var_stagename;
				Fetch cur1 into var_stagename;
 end while loop1;
 close cur1;
end ||
delimiter;

drop PROCEDURE if EXISTS update_advance_third;
delimiter ||
create PROCEDURE update_advance_third
(
module_field varchar(100),
var_tabid int(10),
tmp_listid int(10),
var_stagename varchar(100) 
)
BEGIN
 declare var_stagename_target varchar(100);
 declare done2  int  default 0;

 declare cur2 CURSOR FOR SELECT listvalue FROM ld_picklist_values where listid = tmp_listid and listvalue <> var_stagename ORDER BY sequence ASC;
 declare continue handler  for not   found  SET done2 =1;
				
 open cur2;
Fetch cur2 into var_stagename_target;
 loop2: while  done2<>1 DO
        CALL update_advance_fourth(module_field,var_tabid,var_stagename,var_stagename_target);
				Fetch cur2 into var_stagename_target;
 end while loop2;
 close cur2;
end ||
delimiter;

drop PROCEDURE if EXISTS update_advance_fourth;
delimiter ||
create PROCEDURE update_advance_fourth
(
module_field varchar(100),
var_tabid int(10),
var_stagename varchar(100),
var_stagename_target varchar(100)
)
BEGIN
		INSERT into ld_advancepicklist(tabid,fieldname,stagename,stagename_target,presence)
		SELECT var_tabid,module_field,var_stagename,var_stagename_target,'yes' from DUAL
		where NOT EXISTS(SELECT 1 from ld_advancepicklist where stagename = var_stagename and tabid = var_tabid and fieldname = module_field and stagename_target =var_stagename_target );
end ||
delimiter;

call update_advance_first();
drop PROCEDURE  if EXISTS update_advance_first;
delimiter;
drop PROCEDURE  if EXISTS update_advance_second;
delimiter;
drop PROCEDURE  if EXISTS update_advance_third;
delimiter;
drop PROCEDURE  if EXISTS update_advance_fourth;
delimiter;

SET @labelbol = 'SignContractCount';
set @homestuffdetailid = (SELECT id from ld_homestuffdetail where stufflabel = @labelbol and compute_columns='ld_salesorder.salesorderid');
SET @column_field = 'ld_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V';
SET @column_value = '已作废';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,@column_value,'n' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field and `value`=@column_value and homestuffdetailid=@homestuffdetailid and groupid=1);


SET @labelbol = 'SignContractCount';
set @homestuffdetailid = (SELECT id from ld_homestuffdetail where stufflabel = @labelbol and compute_columns='ld_servicecontracts.servicecontractsid');
SET @column_field = 'ld_servicecontracts:contract_status:contract_status:ServiceContracts_fieldlabel:V';
SET @column_value = '已作废';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,@column_value,'n' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field and `value`=@column_value and homestuffdetailid=@homestuffdetailid and groupid=1);
delimiter;

update ld_desk set fieldlabel = '请先设置状态间的先后流转关系' WHERE languagetype = 'zh' AND labelbol='PLEASESETRELATION' and Labeltype='jspop'  ;
delimiter;
-- 2022-06-09

update ld_field SET savedatabase='no' where uitype=1503 and bigtype = 'qrcode';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Potentials');
update ld_field set tablename = 'ld_potential' where tabid = @tabid and columnname='subtotal';
update ld_tabwithproductview set `columns` = 'ld_potential:subtotal:hdnSubTotal:Potentials_:N' where tabid=@tabid and `columns` like '%ld_potentials:subtotal:hdnSubTotal:Potentials_:N%';
delimiter;

UPDATE ld_desk SET fieldlabel='停留' WHERE labelbol='STAGEDETENTIONDURATION' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Stay' WHERE labelbol='STAGEDETENTIONDURATION' AND languagetype='en';
delimiter;

UPDATE ld_desk SET fieldlabel='从【%s】可流转到' WHERE labelbol='FROMPUSHTO' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='Push 【%s】 to' WHERE labelbol='FROMPUSHTO' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;


SET @labelbol = 'SAVEANDADVANCE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'保存并推进','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Save and Advance','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PLEASECHOOSENEXTSTAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择下一状态','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please choose next stage','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'STAGEDETENTIONDURATIONTWO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'阶段滞留时长','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Stage detention duration','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_advancepicklisttask
INNER JOIN ld_advancepicklist ON ld_advancepicklist.advanceid = ld_advancepicklisttask.advanceid
SET ld_advancepicklisttask.completerequest = ld_advancepicklist.completerequest
where (ld_advancepicklisttask.completerequest is NULL or  ld_advancepicklisttask.completerequest = '')
AND ld_advancepicklist.completerequest = 'yes' ;
delimiter;

ALTER TABLE ld_advancepicklisttask MODIFY presence varchar(10);
delimiter;
UPDATE ld_advancepicklisttask SET presence = 'yes' where presence = 0;
delimiter;
call addtableIndex('ld_advancepicklistlog','advancelog_record','record');
delimiter;

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

UPDATE ld_version SET old_version='V8.4.6.6',current_version='V8.4.6.6',remark='V8.4.6.6-20220615',wx_version='V8.4.6.6';
delimiter;