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

SET @tabid = (SELECT tabid FROM ld_tab WHERE name = 'SocialPromotion');
UPDATE ld_field SET quickcreate  =1 WHERE tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PendingApproval','待审批','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PendingApproval' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PendingApproval','Pending Approval','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PendingApproval' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff_20200717`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_templatesstuff_20200717`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT templateid FROM ld_templatesstuff;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	SET @this_stuffid=39;	-- 待审批组件

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO	
		INSERT INTO ld_templatesstuff(stuffid,templateid,stufftype,stuffsequence,stufftitle,presence)
		SELECT @this_stuffid,tmp_id,'pendingapproval',-1,'PendingApproval',0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_templatesstuff WHERE stuffid=@this_stuffid AND templateid=tmp_id);
		
		SET @i=-1;
		UPDATE ld_templatesstuff SET stuffsequence=(@i:=@i+1) WHERE templateid=tmp_id ANd presence=0 ORDER BY stuffsequence;
		
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_templatesstuff_20200717();
DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff_20200717`;
delimiter;


SET @roottype=8;
SET @deploy_type=213;
SET @deploy_value=1;
SET @description='设置移动端通讯录中是否显示离职人员。1:否，0:是';
SET @zh='设置移动端通讯录中是否显示离职人员';
SET @en='Set whether the resigned employees are displayed in the address book of the mobile terminal';
SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT @deploy_value,@deploy_type,@description,'',@seq+1,@roottype,'select',0 ,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);

INSERT INTO ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_systems_deploy',@deploy_type,@deploy_type,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@deploy_type AND relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='zh');

INSERT INTO ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_systems_deploy',@deploy_type,@deploy_type,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@deploy_type AND relateid=@deploy_type and trantable='ld_systems_deploy' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUMBEROFACQUIRED','获取的{$Accounts.Accounts}数量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NUMBEROFACQUIRED' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUMBEROFACQUIRED2','Number of {$Accounts.Accounts} acquired','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NUMBEROFACQUIRED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUMBEROFACQUIRED2','获取的{$Leads.Leads}数量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NUMBEROFACQUIRED2' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUMBEROFACQUIRED2','Number of {$Leads.Leads} acquired','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NUMBEROFACQUIRED2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PREVIEWNUMBER','浏览量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PREVIEWNUMBER' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PREVIEWNUMBER','Preview Number','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PREVIEWNUMBER' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMERCONTRACTS','客户合同数量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMERCONTRACTS' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERCONTRACTS','Number of customer contracts','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CUSTOMERCONTRACTS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOTALCONTRACTAMOUNT','合同总金额','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOTALCONTRACTAMOUNT' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOTALCONTRACTAMOUNT','Total contract amount','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOTALCONTRACTAMOUNT' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2020-07-17

DROP PROCEDURE IF EXISTS `ldcrm_reset_billapproveinfo_20200715`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_billapproveinfo_20200715`(
)
BEGIN

	DECLARE tmp_modulename VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tablename VARCHAR(100) DEFAULT NULL;
	DECLARE tmp_tableindex VARCHAR(100) DEFAULT NULL;

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.setype AS modulename,
				c.tablename,
				e.entityidfield AS tmp_tableindex
			FROM (
				SELECT
					b.setype
				FROM (SELECT crmid FROM ld_approvelog WHERE crmid>0 GROUP BY crmid) a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				GROUP BY b.setype
			) a
			LEFT JOIN ld_tab b ON b.`name`=a.setype
			INNER JOIN (SELECT tabid,tablename FROM ld_field WHERE columnname='approvestatus') c ON c.tabid=b.tabid
			INNER JOIN ld_entityname e ON e.modulename=a.setype
			WHERE IFNULL(a.setype,'')<>'' 
				AND IFNULL(c.tablename,'')<>'' 
				AND IFNULL(e.entityidfield,'')<>'';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_modulename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_modulename,tmp_tablename,tmp_tableindex;
	WHILE(tmp_modulename IS NOT NULL) DO
		SET @my_execsql_approveinfo=CONCAT("
			UPDATE (
				SELECT
					a.crmid,
					MAX(a.id) AS max_logid
				FROM ld_approvelog a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				WHERE b.setype='",tmp_modulename,"'
				GROUP BY a.crmid
			) a
			LEFT JOIN ld_approvelog b ON b.id=a.max_logid
			LEFT JOIN (
				SELECT
					a.crmid,
					MAX(a.id) AS max_logid
				FROM ld_approvelog a
				INNER JOIN ld_crmentity b ON b.crmid=a.crmid
				WHERE b.setype='",tmp_modulename,"'
					AND a.stepid=-1
				GROUP BY a.crmid
			) c ON a.crmid=c.crmid
			LEFT JOIN ld_approvelog d ON d.id=c.max_logid
			LEFT JOIN ",tmp_tablename," t ON t.",tmp_tableindex,"=d.crmid
			SET t.approvesubmittedtime=d.createdtime,
				t.approvesubmitter=d.approved_by,
				t.currentapprovestepid=b.stepid"
			);
		SET @disable_triggers=1;

		PREPARE my_execsql_stmt FROM @my_execsql_approveinfo;
		EXECUTE my_execsql_stmt;
		DEALLOCATE PREPARE my_execsql_stmt;

	FETCH MYCUSOR INTO tmp_modulename,tmp_tablename,tmp_tableindex;
	END WHILE;
	CLOSE MYCUSOR;

	SET @disable_triggers=NULL;

end ||
delimiter;

CALL ldcrm_reset_billapproveinfo_20200715();
DROP PROCEDURE IF EXISTS `ldcrm_reset_billapproveinfo_20200715`;

UPDATE ld_tab SET presence=0 WHERE `name`='SocialPromotion';

set @tabid =(SELECT tabid  from ld_tab where name ='Users');
set @actionid =(SELECT max(actionid) from ld_actionmapping) +1 ;
set @maxSequence = (SELECT max(sequence) from ld_profileallpermission where tabid =@tabid)+1;
insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid,'Department',0,'DEPARTMENT'  from  dual
where not EXISTS(select 1 from ld_actionmapping where actionname='Department');
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@maxSequence from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid);

set @actionid =(SELECT max(actionid) from ld_actionmapping) +1 ;
set @maxSequence = (SELECT max(sequence) from ld_profileallpermission where tabid =@tabid)+1;

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid,'Job level',0,'JOBLEVEL'  from  dual
where not EXISTS(select 1 from ld_actionmapping where actionname='Job level');
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@actionid,@maxSequence from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid);
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DEPARTMENT',"部门",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DEPARTMENT' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DEPARTMENT',"Department",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DEPARTMENT' and Labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','JOBLEVEL',"职位级别",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='JOBLEVEL' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','JOBLEVEL',"Joblevel",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='JOBLEVEL' and Labeltype='fixedstr');
delimiter;
-- 2020-07-20

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

UPDATE ld_version SET old_version='V8.1.4',current_version='V8.1.4',remark='V8.1.4-20200720',wx_version='V8.1.4';
delimiter;