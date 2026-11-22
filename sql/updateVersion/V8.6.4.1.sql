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

call AddColumn('ld_sensitiverules','disabledscene','text','','');
update ld_sensitiverules set disabledscene='' where disabledscene is null;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisabledScene','禁用场景','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DisabledScene' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisabledScene',"Disable Scene",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DisabledScene' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ModuleListView','模块列表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ModuleListView' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ModuleListView',"Module List",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ModuleListView' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DocumentDetailView','单据查看详情界面','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DocumentDetailView' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DocumentDetailView',"Document View Details Interface",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DocumentDetailView' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RelatedModuleListView','相关信息模块列表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RelatedModuleListView' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RelatedModuleListView',"List of relevant information modules",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RelatedModuleListView' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk set fieldlabel='仅变更与{Module}相同{Var}的数据' WHERE labelbol='OnlyChangeSameVarData' and languagetype='zh' and labeltype='fixedstr';
delimiter;

SET @labelbol = 'FileAllowed';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据满足条件时才允许下载和预览',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Download and preview are only allowed when the documents meet the conditions',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseSelectAtLeastOneVar','请至少选择一个{Var}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectAtLeastOneVar' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseSelectAtLeastOneVar','Please select at least one {Var}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseSelectAtLeastOneVar' and Labeltype='jspop' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `sethistoryusergrouptype`;
delimiter ||
CREATE PROCEDURE `sethistoryusergrouptype`(
)
BEGIN
    DECLARE field_exists INT;
    DECLARE current_db VARCHAR(64);

    SELECT DATABASE() INTO current_db;

    SELECT COUNT(*)
    INTO field_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = current_db
    AND TABLE_NAME = 'ld_users'
    AND (COLUMN_NAME = 'user_type' or COLUMN_NAME = 'crm_user_type');

    IF field_exists = 0 THEN

				call AddColumn('ld_users','crm_user_type','varchar',50,'');

				call AddColumn('ld_groups','group_type','varchar',50,'');

				call AddColumn('ld_groups','related_crmid','int',10,'');

				ALTER TABLE ld_users ALTER COLUMN crm_user_type SET DEFAULT 'crm';

				ALTER TABLE ld_groups ALTER COLUMN group_type SET DEFAULT 'crm';

				UPDATE ld_users set crm_user_type = 'crm';

				UPDATE ld_groups set group_type = 'crm';

    END IF;
end ||
delimiter;

CALL sethistoryusergrouptype();
DROP PROCEDURE IF EXISTS `sethistoryusergrouptype`;
delimiter;

call AddColumn('ld_stuff','charttype','char','10','');
update ld_stuff set charttype='strip' where stuffid in(102,103,104,112);
update ld_stuff set charttype='funnel' where stuffid in(19);
update ld_stuff set charttype='bar' where stuffid in(4,5,41,42,57,105,106,107,113);
update ld_stuff set charttype='linebar' where stuffid in(1,9,40,44,45);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;
	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);

		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 1,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);
		SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
		SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		
		UPDATE ld_approve_seq SET id=(SELECT MAX(id) FROM ld_approve);
		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
	
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
		SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
		SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
		SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
		SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;
		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);
		
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);
		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
END IF;
end ||
delimiter;
set @modulename='Singin';
CALL ldcrm_add_approveforbill(@modulename,483);
delimiter;

set @modulename='Singin';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
set @blockid = (SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
set @tablename = CONCAT('ld_',LOWER(@modulename));
set @i = (SELECT COUNT(1) from ld_field where block = @blockid);

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'approvestatus','yes',@tablename,1,609,'approvestatus','审批状态',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'text',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'approvetime','yes',@tablename,1,70,'approvetime','最新审批时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2,'datetime',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'approveby','yes',@tablename,1,131,'approveby','上一步审批人',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'currentapprover','yes',@tablename,1,132,'currentapprover','当前审批人',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

call AddColumn(@tablename,'approvestatus','varchar','50',NULL);
call AddColumn(@tablename,'currentapprover','text','',NULL);
call AddColumn(@tablename,'approveby','text','',NULL);
call AddColumn(@tablename,'approvetime','datetime','',NULL);
call AddColumn(@tablename,'currentapprovestepid','int','4',NULL);
call AddColumn(@tablename,'approvesubmitter','int','11',NULL);
call AddColumn(@tablename,'approvesubmittedtime','datetime','',NULL);
call AddColumn(@tablename,'approveexpediting','varchar','20',NULL);
call AddColumn(@tablename,'approveurgent','varchar','20',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnterBuildingStreetCompanyAddress','请输入写字楼、街道、公司名称或详细地址','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterBuildingStreetCompanyAddress' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnterBuildingStreetCompanyAddress','Please enter the office building, street, company name or detailed address','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterBuildingStreetCompanyAddress' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MASSELECTTENTIP2','您勾选了{Var}条记录，最多可合并前100条记录，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MASSELECTTENTIP2' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MASSELECTTENTIP2',"You have selected {Var} records and can merge up to the first 100 records. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MASSELECTTENTIP2' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AfterMergeAddToTeamMember','合并后，将被删除记录的单据负责人自动添加到主记录团队成员中','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterMergeAddToTeamMember' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AfterMergeAddToTeamMember','After the merge, the document owner of the deleted record is automatically added to the master record team member','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AfterMergeAddToTeamMember' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OptionalValues','可选值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OptionalValues' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OptionalValues','Optional Values','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OptionalValues' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectedValues','已选值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SelectedValues' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectedValues','Selected Values','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SelectedValues' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoOptionalValues','没有可选值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NoOptionalValues' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoOptionalValues','No optional values','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NoOptionalValues' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnterOptionValueSearch','请输入要查找的选项值名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterOptionValueSearch' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnterOptionValueSearch','Please enter the name of the option value you want to search for','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterOptionValueSearch' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAsPrimaryRecord','设为主要记录','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SetAsPrimaryRecord' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAsPrimaryRecord','Set as primary record','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SetAsPrimaryRecord' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRIMARRECORDMERGE2','主记录将在合并后保留。 您可以选择哪些数据需要保留，其他记录将被删除，但相关的信息将被合并','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRIMARRECORDMERGE2' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRIMARRECORDMERGE2','The primary record will be retained after the merge. You can select the values to retain. The other record will be deleted but the related information will be merged.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRIMARRECORDMERGE2' and labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'KUAIDI100USETIPSONE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'1、使用默认查询接口，会跳转到对应浏览器界面。',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'1、Using the default query interface will jump to the corresponding browser interface.',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'KUAIDI100USETIPSTWO';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'2、使用自购快递100Key，会弹出对应弹窗接口。',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'2、When using the self-purchased express 100Key, the corresponding pop-up window interface will pop up.',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TitleCreate','新建','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TitleCreate' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TitleCreate',"New ",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TitleCreate' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TitleCopy','复制','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TitleCopy' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TitleCopy',"Copy ",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TitleCopy' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TitleEdit','编辑','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TitleEdit' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TitleEdit',"Edit ",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TitleEdit' and labeltype='jspop');
delimiter;

update ld_field set bigtype='selectmultiuser',datarang='all',columnname='recipient' where fieldname='recipient' and uitype=242;
delimiter;

SET @labelbol = 'APPROVERESULTADDSIGN';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'通过（加签本节点）',@labeltype FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Pass (sign this node)',@labeltype FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTHELPMANUAL','帮助手册','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PRODUCTHELPMANUAL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTHELPMANUAL',"Help manual",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PRODUCTHELPMANUAL' and labeltype='jspop');
delimiter;

CALL AddColumn('ld_module_setting_byuser','description','text','','');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Accounts',1,'HelpUrl_PublicPoolParam','','公海参数设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Accounts' and label='HelpUrl_PublicPoolParam');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Leads',1,'HelpUrl_PublicPoolParam','','公海参数设置帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Leads' and label='HelpUrl_PublicPoolParam');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_ListRoles','','角色权限帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and label='HelpUrl_ListRoles');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_ModuleManager','','模块管理帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where modulename = 'Settings' and  label='HelpUrl_ModuleManager');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_TemplatePrintList','','打印模板定制帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Settings' and label='HelpUrl_TemplatePrintList');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_MultiApproveList','','审批流程定制帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Settings' and label='HelpUrl_MultiApproveList');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_WorkflowCustomizationList','','工作流程定制帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Settings' and label='HelpUrl_WorkflowCustomizationList');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Users',1,'HelpUrl_ScopeAuthority','','业务单据数据范围帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Users' and label='HelpUrl_ScopeAuthority');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Settings',1,'HelpUrl_OrgSharingDetailView','','模块共享规则帮助' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Settings' and label='HelpUrl_OrgSharingDetailView');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Header',1,'HelpUrl_AllHelp','','帮助总入口' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Header' and label='HelpUrl_AllHelp');
delimiter;

insert into ld_module_setting_byuser(modulename,userid,label,content,description)
select 'Header',1,'HelpUrl_SettingsHelp','','后台设置帮助总入口' from dual
where not exists(select 1 from ld_module_setting_byuser where  modulename = 'Header' and label='HelpUrl_SettingsHelp');
delimiter;
-- 2024-08-05

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

UPDATE ld_version SET old_version='V8.6.4.1',current_version='V8.6.4.1',remark='V8.6.4.1-20240805',wx_version='V8.6.4.0';
delimiter;