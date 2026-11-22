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

ALTER TABLE `ld_loopcalendar_reminds` MODIFY COLUMN loop_dayvalue VARCHAR(255);
delimiter;

UPDATE ld_field set masseditable = 2 where bigtype = 'reference' and columnname = 'accountid' and masseditable = 0 
and tabid in (SELECT ld_tab.tabid from ld_tab where LOCATE('CustomForm',ld_tab.`name`) >0); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SIGNINANDOUTTIP','您不是当前签到记录的负责人，不允许签退/补签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SIGNINANDOUTTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SIGNINANDOUTTIP',"You are not the person responsible for the current sign-in record and are not allowed to sign out/supplementary sign ou",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SIGNINANDOUTTIP' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKDUPTIP','在{$Leads.Leads}或{$Accounts.Accounts}不能重复','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKDUPTIP' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKDUPTIP','cannot be duplicated in the {$Leads.Leads} or {$Accounts.Accounts} ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHECKDUPTIP' and labeltype='fixedstr');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'SocialPromotion');
UPDATE ld_field SET presence = 1 WHERE tabid = @tabid and columnname = 'h5pageurl';
UPDATE ld_field SET presence = 1 WHERE tabid = @tabid and columnname = 'h5pagebutton';
UPDATE ld_field SET presence = 1 WHERE tabid = @tabid and columnname = 'H5buttoncolor';
UPDATE ld_field SET allowedit = 'no' WHERE tabid = @tabid and columnname = 'social_activitytype';
delimiter;

SET @module='CustomForm45';
SET @rel_module='Attachment';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm45');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
DELETE FROM ld_relatedlists
WHERE tabid=@tabid  AND related_tabid=@rel_tabid AND `name`=@template AND type='datacategory_sql' AND related_coltable='attachmentsforbills.related_to';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','attachmentsforbills.related_to' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

UPDATE ld_desk SET fieldlabel='您的{module}被{operator}在{nowtime}正在尝试报备，请联系{operator}，联系电话：{operatorphone}' WHERE labelbol='REMINDOPEAFORHEDGING' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel=' Your {module} is trying to report by the {operator} at {nowtime}. Please contact the {operator} at {operatorphone}' WHERE labelbol='REMINDOPEAFORHEDGING' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

UPDATE ld_listview_btn SET btntype = 'both' WHERE `name` = 'Export' and btntype = 'rely' and iconname != '';
delimiter;

SET @deploy_type = 467;
insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 2,@deploy_type,'天眼查工商模糊查询开始查询数量' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type=@deploy_type);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNABLEVIEWDETAILS','无法查看明细','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UNABLEVIEWDETAILS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNABLEVIEWDETAILS',"Unable to view details",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UNABLEVIEWDETAILS' and labeltype='fixedstr');
delimiter;

drop PROCEDURE  if EXISTS ldcrm_transdatatype_source_list;
delimiter ||
create PROCEDURE ldcrm_transdatatype_source_list
(
)
BEGIN
	declare var_tablename VARCHAR(100);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT tablename from ld_field where columnname = 'source_list';
	declare continue handler for not found SET done =1;	
	
	open cur1;
	Fetch cur1 into var_tablename;
	loop1: while  done<>1 DO
				set @tmp_sql = CONCAT('ALTER table `',var_tablename,'` MODIFY COLUMN `source_list` text');
				prepare stmt from @tmp_sql;
				execute stmt;
				deallocate prepare stmt;
				Fetch cur1 into var_tablename;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_transdatatype_source_list();
drop PROCEDURE  if EXISTS ldcrm_transdatatype_source_list;
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','IMPORTCONTROL','导入控制','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'IMPORTCONTROL' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','IMPORTCONTROL','Import Control','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'IMPORTCONTROL' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','CHECKPICKLIST','校验下拉框','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CHECKPICKLIST' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CHECKPICKLIST','Verify drop-down box','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CHECKPICKLIST' AND labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','CHECKPICKLISTCOLUMN','设置校验字段','fixedstr'FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'CHECKPICKLISTCOLUMN' AND labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','CHECKPICKLISTCOLUMN','Set verification fields','fixedstr' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'CHECKPICKLISTCOLUMN' AND labeltype = 'fixedstr');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Users');
update ld_field set defaultvalue='Active' where defaultvalue!='Inactive' and tabid = @tabid and columnname='status';
delimiter;

UPDATE ld_desk SET fieldlabel="请填写内容" WHERE labelbol='FILLINCOMMENTS' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel="Please fill in the content" WHERE labelbol='FILLINCOMMENTS' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addmodule_bireportscreen`;
delimiter ||
CREATE PROCEDURE `ldcrm_addmodule_bireportscreen`(
)
BEGIN
    IF NOT EXISTS (select 1 from ld_tab where `name`='BIReportScreen') THEN

        select tabsequence,tabid into @tabsequence,@hometabid from ld_tab where `name` = 'ReportAnalysis';
        update ld_tab set tabsequence := tabsequence + 1 where tabsequence > @tabsequence;
        select parenttabid,sequence into @parenttabid,@homeseq from ld_parenttabrel where tabid = @hometabid limit 1;
        update ld_parenttabrel set sequence := sequence + 1 where sequence > @homeseq;

        select max(tabid) + 1 into @newtabid from ld_tab;

        insert into ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab )
        select @newtabid,'BIReportScreen',0,@tabsequence+1,'BIReportScreen',1 from dual
        where not EXISTS(select 1 from ld_tab where `name`='BIReportScreen');

        insert into ld_parenttabrel(parenttabid,tabid,sequence) value (@parenttabid,@newtabid,@homeseq+1);

        insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        select 'zh','ld_tab',@newtabid,@newtabid,'数字大屏' from dual
        where not exists(select 1 from ld_tranlabel where tabid=@newtabid and relateid=@newtabid and languagetype='zh'and trantable='ld_tab' );
        insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
        select 'en','ld_tab',@newtabid,@newtabid,'Home Data Cockpit' from dual
        where not exists(select 1 from ld_tranlabel where tabid=@newtabid and relateid=@newtabid and languagetype='en' and trantable='ld_tab');

        CREATE TABLE if not EXISTS `ld_bireportscreen` (
           `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
           `project_id` varchar(255) NOT NULL COMMENT '大屏id',
           `project_name` varchar(255) COMMENT '大屏名称',
           `deleted` int(11) DEFAULT 0 COMMENT '是否删除',
           `smcreatorid` int(11) COMMENT '创建用户',
           `createdtime` datetime COMMENT '创建时间',
           `scope` varchar(20) COMMENT '分配类型',
           `index_image` varchar(255) COMMENT '封面图片地址',
           `remarks` text  COMMENT '描述',
           PRIMARY KEY (`id`)
        ) ENGINE=InnoDB;
    END IF;
end ||
delimiter;

CALL ldcrm_addmodule_bireportscreen();
delimiter;

call AddColumn('ld_bireportscreen','scope','varchar',20,'');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_bireportscreen`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_bireportscreen`()
BEGIN

    DECLARE tmp_profileid INT(19) DEFAULT 0;

    DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

    SET @tabid=(select tabid from ld_tab  where name='BIReportScreen');

    set @operation = (SELECT actionid from ld_actionmapping where actionname = 'index');

    IF NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) THEN
        INSERT INTO ld_profileallpermission(tabid,operation,sequence) VALUES (@tabid,@operation,0);
    END IF;

        IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid) THEN
            OPEN MYCUSOR;
            FETCH MYCUSOR INTO tmp_profileid;
            WHILE(tmp_profileid IS NOT NULL) DO
                    SET @profileid=tmp_profileid;
                    INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
                    SELECT
                        @profileid AS profileid,
                        @tabid AS tabid,
                        @operation,
                        0,
                        0
                    FROM ld_profile2standardpermissions a
                             LEFT JOIN ld_tab b ON b.tabid=a.tabid
                    WHERE a.profileid=@profileid
                      AND a.operation=@operation
                    LIMIT 1;

                    SET @i=0;
                    UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND profileid=@profileid ORDER BY sequence;

                    IF NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE tabid=@tabid AND profileid=@profileid) THEN
                        INSERT INTO ld_profile2tab(profileid,tabid,permissions)
                        SELECT profileid,@tabid,IF(MIN(permissions)=0,1,0) FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid;
                    END IF;

                    IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid AND permissions=0) THEN
                        UPDATE ld_profile2standardpermissions SET permissions=1 WHERE tabid=@tabid AND profileid=@profileid AND operation=0;
                    END IF;

                    FETCH MYCUSOR INTO tmp_profileid;
                END WHILE;
            CLOSE MYCUSOR;
        END IF;
    END ||
delimiter;

CALL ldcrm_add_profile_for_bireportscreen();
delimiter;


INSERT INTO ld_bireportscreen(project_id,project_name,deleted,smcreatorid,createdtime,index_image,scope)
SELECT 'ldcrm_default_1','预设大屏1',0,1,NOW(),'ldcrm_default_1_indexImg.png','all' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_bireportscreen WHERE project_id = 'ldcrm_default_1');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Holiday');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'holidayno' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Personnelfile');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'personnelfile_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Laborcontract');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'laborcontract_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Salary');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'salary_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Competition');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'competition_no' and typeofdata<>'V~M';
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Collectionslip');
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname = 'collectionslip_no' and typeofdata<>'V~M';
delimiter;

call addtableIndex('ld_singin','idx_record_singin','record');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HIGH','高','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HIGH' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HIGH',"High",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HIGH' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOW','低','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOW' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOW',"low",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOW' and labeltype='fixedstr');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Singin');
update ld_relatedlists set buttonstatus='no' where related_tabid = @tabid and label = 'Singin';
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Signout');
update ld_relatedlists set buttonstatus='no' where related_tabid = @tabid and label = 'Signout';
delimiter;


UPDATE ld_desk SET fieldlabel="恢复默认列宽" WHERE labelbol='ResetListWidth' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel="Restore default column width" WHERE labelbol='ResetListWidth' AND languagetype='en' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel="恢复默认列宽" WHERE labelbol='ResetListWidth' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel="Restore default column width" WHERE labelbol='ResetListWidth' AND languagetype='en' AND Labeltype='jspop';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CallRecordSetting','通话录音设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecordSetting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CallRecordSetting','Call recording settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecordSetting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CallRecordLogsQuery','通话日志查询','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecordLogsQuery' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CallRecordLogsQuery','Call recording logs query','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecordLogsQuery' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','callrecordlogs','通话日志查询','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='callrecordlogs' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','callrecordlogs','Call recording logs query','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='callrecordlogs' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CallRecordDate','通话日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecordDate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CallRecordDate','Call recording date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecordDate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Caller','呼叫人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Caller' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Caller','Caller','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Caller' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Listener','接听人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Listener' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Listener','Listener','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Listener' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CallRecording','通话录音','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecording' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CallRecording','Call recording','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CallRecording' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Attention','注意','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Attention' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Attention','Attention','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Attention' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Called','打电话给','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Called' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Called','called','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Called' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Answered','接听','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Answered' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Answered','answered','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Answered' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','sPhoneCall','的电话','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='sPhoneCall' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','sPhoneCall',"'s phone call",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='sPhoneCall' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoCallRecording','没有通话记录','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoCallRecording' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoCallRecording',"No call recording",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NoCallRecording' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBI_FUNCTION_SETTINGS';
select max(fieldid) + 1 into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select  @fieldid,@blockid,'CallRecordSetting','','CallRecordSetting','index.php?module=Settings&action=CallRecordSetting&parenttab=Settings',2,0 from dual 
where not exists(select 1 from ld_settings_field where name='CallRecordSetting');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_callrecordfields` (
  `id` INT(4) NOT NULL AUTO_INCREMENT,
  `module` varchar(100) DEFAULT NULL ,
  `columnnames` varchar(150) DEFAULT NULL,
	`status` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
delimiter;

INSERT INTO ld_callrecordfields(module,`status`) 
SELECT "Leads","no" from dual 
WHERE NOT EXISTS (select 1 from ld_callrecordfields where module='Leads');

INSERT INTO ld_callrecordfields(module,`status`) 
SELECT "Accounts","no" from dual 
WHERE NOT EXISTS (select 1 from ld_callrecordfields where module='Accounts');

INSERT INTO ld_callrecordfields(module,`status`)
SELECT "Contacts","no" from dual  
WHERE NOT EXISTS (select 1 from ld_callrecordfields where module='Contacts');

INSERT INTO ld_callrecordfields(module,`status`)
SELECT "Potentials","no" from dual 
WHERE NOT EXISTS (select 1 from ld_callrecordfields where module='Potentials');

INSERT INTO ld_callrecordfields(module,`status`)
SELECT "Vendors","no" from dual 
WHERE NOT EXISTS (select 1 from ld_callrecordfields where module='Vendors');

INSERT INTO ld_callrecordfields(module,`status`)
SELECT "VendorContact","no" from dual 
WHERE NOT EXISTS (select 1 from ld_callrecordfields where module='VendorContact');
delimiter;

call AddColumn('ld_callbutler','leadsid','int',11,'');
call AddColumn('ld_callbutler','phonefieldname','varchar',20,'');
call AddColumn('ld_callbutler','uuid','varchar',100,'');
call AddColumn('ld_callbutler','phonebrand','varchar',100,'');
call AddColumn('ld_callbutler','createdtime','datetime','','');
call AddColumn('ld_callbutler','recordingfilename','varchar',200,'');
call AddColumn('ld_callbutler','fromtype','varchar',20,'');
delimiter;

UPDATE ld_relatedlists SET mobile_presence = 0,wx_presence = 0 WHERE `label` = 'CallButler' AND `name` = 'get_CallButler';

set @tabid = (SELECT tabid from ld_tab where `name` = 'Leads');
set @att_tabid = 0;
set @maxid = (SELECT id+1 from ld_relatedlists_seq);
set @max_seq = (SELECT MAX(sequence)+1 from ld_relatedlists where tabid = @tabid);
INSERT into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,wx_presence,wx_sequence,buttonstatus)
SELECT @maxid,@tabid,@att_tabid,'get_CallButler',@max_seq,'CallButler',1,'',0,@max_seq,'CallButler_Info',0,@max_seq,'yes' from DUAL 
where NOT EXISTS(SELECT 1 from ld_relatedlists where tabid = @tabid and related_tabid = @att_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

UPDATE ld_desk set fieldlabel='功能定制' WHERE labelbol='LBI_FUNCTION_SETTINGS' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Function Settings' WHERE labelbol='LBI_FUNCTION_SETTINGS' and languagetype='en';
delimiter;


CALL AddColumn('ld_collectionslip','collected_amount','decimal','25','8');
ALTER TABLE ld_collectionslip MODIFY COLUMN total DECIMAL(25,8);	

SET @filedid=IFNULL((SELECT fieldid FROM ld_field WHERE tablename='ld_collectionslip' AND fieldname='hdnGrandTotal'),0);
UPDATE ld_field SET columnname='collected_amount',fieldname='collected_amount' WHERE tablename='ld_collectionslip' AND fieldname='total' AND @filedid=0;
UPDATE ld_collectionslip SET collected_amount=total WHERE @filedid=0;
delimiter;

SET @modulename='CollectionSlip';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='total';
SET @fieldname='hdnGrandTotal';
SET @zh='合计';
SET @en='合计';
SET @uitype=72;
SET @typeofdata='N~O~25,2';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @allowedit='yes';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','200',NULL);
ALTER TABLE ld_collectionslip MODIFY COLUMN total DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);



SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip' LIMIT 1);
INSERT INTO ld_tabdetailfield(
    tabid,
    columnname,
    allowhide,
    tablename,
    fieldlabel,

    defaultvalue,
    presence,
    fieldtype,
    typeofdata,
    sequence,

    width,
    edit_permission,
    input_type,
    fieldid,
    defaultcolumn,

    savedatabase
)
SELECT
    @tabid,
    columnname,
    allowhide,
    'ld_collectionslip',
    fieldlabel,

    defaultvalue,
    presence,
    fieldtype,
    typeofdata,
    100,

    width,
    edit_permission,
    input_type,
    fieldid,
    defaultcolumn,

    savedatabase
FROM ld_tabdetailfield
WHERE tabid=67
  AND columnname='total'
  AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='total');

SET @trantable='ld_tabdetailfield';
SET @zh='合计';
SET @en='Total';
SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='total' LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE @relateid>0
  AND NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE @relateid>0
  AND NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


SET @modulename='CollectionSlip';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
update ld_tabdetailfield set newline=1 where tabid=@tabid and columnname='total';
delimiter;

SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='endowment_rate'; 
SET @fieldname='endowment_rate'; 
SET @zh='养老保险比例'; 
SET @en='Endowment insurance Rate'; 
SET @uitype=7; 
SET @typeofdata='NN~M~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN endowment_rate DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='medical_rate'; 
SET @fieldname='medical_rate'; 
SET @zh='医疗保险比例'; 
SET @en='Medical insurance Rate'; 
SET @uitype=7; 
SET @typeofdata='NN~M~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN medical_rate DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='unemployment_rate'; 
SET @fieldname='unemployment_rate'; 
SET @zh='失业保险比例'; 
SET @en='Unemployment insurance Rate'; 
SET @uitype=7; 
SET @typeofdata='NN~M~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN unemployment_rate DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='maternity_insurance'; 
SET @fieldname='maternity_insurance'; 
SET @zh='生育保险'; 
SET @en='Maternity insurance'; 
SET @uitype=7; 
SET @typeofdata='NN~O~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN maternity_insurance DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='house_base'; 
SET @fieldname='house_base'; 
SET @zh='公积金缴纳基数'; 
SET @en='Provident fund deposit base'; 
SET @uitype=7; 
SET @typeofdata='NN~M~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN house_base DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='social_base'; 
SET @fieldname='social_base'; 
SET @zh='社保缴纳基数'; 
SET @en='Social security payment base'; 
SET @uitype=7; 
SET @typeofdata='NN~M~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN social_base DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);



SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='house_rate'; 
SET @fieldname='house_rate'; 
SET @zh='公积金比例'; 
SET @en='Provident fund rate'; 
SET @uitype=7; 
SET @typeofdata='NN~M~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN house_rate DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);



SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_SALARYINSURANCE_INFO');

SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='social_base';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='house_base';
UPDATE ld_field SET sequence=(@i:=@i+1),allowedit='no' WHERE tabid=@tabid AND columnname='medical_insurance';
UPDATE ld_field SET sequence=(@i:=@i+1),defaultvalue=8 WHERE tabid=@tabid AND columnname='medical_rate';

UPDATE ld_field SET sequence=(@i:=@i+1),allowedit='no' WHERE tabid=@tabid AND columnname='endowment_insurance';
UPDATE ld_field SET sequence=(@i:=@i+1),defaultvalue=8 WHERE tabid=@tabid AND columnname='endowment_rate';

UPDATE ld_field SET sequence=(@i:=@i+1),allowedit='no' WHERE tabid=@tabid AND columnname='unemployment_insurance';
UPDATE ld_field SET sequence=(@i:=@i+1),defaultvalue=1 WHERE tabid=@tabid AND columnname='unemployment_rate';

UPDATE ld_field SET sequence=(@i:=@i+1),allowedit='no' WHERE tabid=@tabid AND columnname='injury_insurance';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='maternity_insurance';

UPDATE ld_field SET sequence=(@i:=@i+1),allowedit='no' WHERE tabid=@tabid AND columnname='house_insurance';
UPDATE ld_field SET sequence=(@i:=@i+1),defaultvalue=6 WHERE tabid=@tabid AND columnname='house_rate';

UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='insurance_subtotal';



SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='child_education_deduction' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='babycare_deduction'; 
SET @fieldname='babycare_deduction'; 
SET @zh='3岁以下婴幼儿照护'; 
SET @en='Baby care'; 
SET @uitype=7; 
SET @typeofdata='NN~O~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN babycare_deduction DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);



SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='child_education_deduction' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='tax_startpoint'; 
SET @fieldname='tax_startpoint'; 
SET @zh='个税起征点'; 
SET @en='Starting point'; 
SET @uitype=7; 
SET @typeofdata='NN~O~25,2';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);
ALTER TABLE ld_salary MODIFY COLUMN tax_startpoint DECIMAL(25,8);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);



SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='babycare_deduction';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='child_education_deduction';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='continue_education_deduction';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='elderly_deduction';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='house_loan_deduction';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='house_rental_deduction';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='additional_subtotal';
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND columnname='tax_startpoint';


SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='house_rental_deduction' LIMIT 1);
SET @trantable='ld_field';
SET @zh='住房租金抵扣'; 
SET @en='House Rental Deduction'; 

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);



SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='additional_subtotal' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'babycare_deduction'},{'lettervar':'b','column':'child_education_deduction'},{'lettervar':'c','column':'continue_education_deduction'},{'lettervar':'d','column':'elderly_deduction'},{'lettervar':'e','column':'house_loan_deduction'},{'lettervar':'f','column':'house_rental_deduction'}]}",
	'a+b+c+d+e+f',
	'',
	NOW(),
	NOW();


SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='medical_insurance' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'social_base'},{'lettervar':'b','column':'medical_rate'}]}",
	'a*b*0.01',
	'',
	NOW(),
	NOW();


SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='endowment_insurance' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'social_base'},{'lettervar':'b','column':'endowment_rate'}]}",
	'a*b*0.01',
	'',
	NOW(),
	NOW();

SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='unemployment_insurance' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'social_base'},{'lettervar':'b','column':'unemployment_rate'}]}",
	'a*b*0.01',
	'',
	NOW(),
	NOW();

SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='house_insurance' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'social_base'},{'lettervar':'b','column':'house_rate'}]}",
	'a*b*0.01',
	'',
	NOW(),
	NOW();

SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='insurance_subtotal' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'endowment_insurance'},{'lettervar':'b','column':'medical_insurance'},{'lettervar':'c','column':'unemployment_insurance'},{'lettervar':'d','column':'injury_insurance'},{'lettervar':'e','column':'house_base'},{'lettervar':'f','column':'house_rate'}]}",
	'a+b+c+d+e*f*0.01',
	'',
	NOW(),
	NOW();



SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='salary_period'; 
SET @fieldname='salary_period'; 
SET @zh='工资期间'; 
SET @en='工资期间'; 
SET @uitype=15; 
SET @typeofdata='V~M';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='picklist';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','7','');

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

INSERT INTO ld_picklist_set(listname,relatetable,picklist_allowedit)
SELECT 'salary_period','ld_field','no' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE listname='salary_period' AND relatetable='ld_field');
delimiter;




SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@relateid;
UPDATE ld_field SET sequence=1 WHERE tabid=@tabid AND columnname='salary_period';
UPDATE ld_field SET sequence=2 WHERE tabid=@tabid AND columnname='smownerid';
UPDATE ld_field SET sequence=3 WHERE tabid=@tabid AND columnname='salary_total';
UPDATE ld_field SET sequence=4 WHERE tabid=@tabid AND columnname='salary_no';
UPDATE ld_field SET sequence=5 WHERE tabid=@tabid AND columnname='actual_amount';
UPDATE ld_field SET sequence=6 WHERE tabid=@tabid AND columnname='income_tax';
SET @i=0;

UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@relateid ORDER BY sequence;
delimiter;


SET @modulename='Salary';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @trigger_columnname='smownerid';
SET @effect_columnname='salary_period';
SET @picklist_sql="SELECT
	optionvalue,
	optionvalue AS optiontext
FROM (
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 0 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 2 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 3 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 4 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 5 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 6 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 7 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 8 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 9 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 10 MONTH),'%Y-%m') AS optionvalue
	UNION ALL
	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 11 MONTH),'%Y-%m') AS optionvalue
) a";
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info,picklistsql)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'sql',"SELECT DATE_FORMAT(CURDATE(),'%Y-%m')",@picklist_sql FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;



SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='insurance_subtotal' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'endowment_insurance'},{'lettervar':'b','column':'medical_insurance'},{'lettervar':'c','column':'unemployment_insurance'},{'lettervar':'d','column':'injury_insurance'},{'lettervar':'e','column':'house_base'},{'lettervar':'f','column':'house_rate'}]}",
	'a+b+c+d+e*f*0.01',
	'',
	NOW(),
	NOW();

SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pretax_salary_total' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'payable_subtotal'},{'lettervar':'b','column':'attendance_subtotal'},{'lettervar':'c','column':'insurance_subtotal'}]}",
	'a-b-c',
	'',
	NOW(),
	NOW();


SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='individual_income_tax' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;

SET @this_sql="SELECT
	CASE
		WHEN yingna_total<=0 THEN 0.00
		WHEN yingna_total<36000 THEN ROUND(yingna_total*0.03-yina_total,2)
		WHEN yingna_total<144000 THEN ROUND(yingna_total*0.1-2520-yina_total,2)
		WHEN yingna_total<300000 THEN ROUND(yingna_total*0.2-16920-yina_total,2)
		WHEN yingna_total<420000 THEN ROUND(yingna_total*0.25-31920-yina_total,2)
		WHEN yingna_total<660000 THEN ROUND(yingna_total*0.3-52920-yina_total,2)
		WHEN yingna_total<960000 THEN ROUND(yingna_total*0.35-85920-yina_total,2)
		WHEN yingna_total>=960000 THEN ROUND(yingna_total*0.45-181920-yina_total,2)
	END AS tmp_value
FROM (
	SELECT
		SUM(yingna_total)+'{c}'-'{d}'-'{e}' AS yingna_total,
		SUM(yina_total) AS yina_total
	FROM (
		SELECT
			SUM(IFNULL(pretax_salary_total,0)-IFNULL(insurance_subtotal,0)-IFNULL(additional_subtotal,0)-IFNULL(tax_startpoint,0)) AS yingna_total,
			SUM(IFNULL(individual_income_tax,0)) AS yina_total
		FROM ld_salary
		WHERE deleted=0
			AND approvestatus<>'已拒绝'
			AND LEFT(salary_period,4)=LEFT('{a}',4)
			AND RIGHT(salary_period,2)<RIGHT('{a}',2)
			AND smownerid='{b}'
		UNION
		SELECT 0 AS yingna_total,0 AS yina_total
	) a
) a";
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'salary_period'},{'lettervar':'b','column':'smownerid'},{'lettervar':'c','column':'pretax_salary_total'},{'lettervar':'d','column':'tax_startpoint'},{'lettervar':'e','column':'additional_subtotal'}]}",
	@this_sql,
	'sql',
	NOW(),
	NOW();


SET @tabid=(SELECT tabid FROm ld_tab WHERE NAME='Salary' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='actual_amount_paid' LIMIT 1);
DELETE FROM ld_field_formula WHERE fieldid=@filedid;
INSERT INTO ld_field_formula(
	fieldid,
	columnstring,
	formulastring,
	functiontype,
	created_at,
	updated_at
)
SELECT 
	@filedid,
	"{formulavar:[{'lettervar':'a','column':'pretax_salary_total'},{'lettervar':'b','column':'individual_income_tax'}]}",
	'a-b',
	'',
	NOW(),
	NOW();
delimiter;

UPDATE ld_field SET defaultvalue=5000,allowedit='no' WHERE tablename='ld_salary' AND columnname='tax_startpoint';
UPDATE ld_field SET allowedit='no' WHERE tablename='ld_salary' AND columnname='pretax_salary_total';
UPDATE ld_field SET allowedit='yes' WHERE tablename='ld_salary' AND columnname='salary_period';
delimiter;

UPDATE ld_collectionslip a
LEFT JOIN ( 
	SELECT
		id,
		SUM(amount) AS total
	FROM ld_collectionslipdetail
	GROUP BY id
) b ON b.id=a.collectionslip_id
SET 
	a.total=IFNULL(b.total,0);
	
SET @field=(SELECT fieldid FROM ld_field WHERE columnname='pretax_salary_total' AND tablename='ld_salary' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='应税工资合计' WHERE trantable='ld_field' AND Relateid=@field AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='Total taxable amount' WHERE trantable='ld_field' AND Relateid=@field AND languagetype='en';
delimiter;
-- 2024-04-28

UPDATE ld_field SET allowedit='yes' WHERE tablename='ld_salary' AND columnname='tax_startpoint';
UPDATE ld_field SET allowedit='no' WHERE tablename='ld_salary' AND columnname='maternity_insurance';

ALTER TABLE ld_competition MODIFY COLUMN approvestatus VARCHAR(50) DEFAULT "未提交";
ALTER TABLE ld_holiday MODIFY COLUMN approvestatus VARCHAR(50) DEFAULT "未提交";
ALTER TABLE ld_laborcontract MODIFY COLUMN approvestatus VARCHAR(50) DEFAULT "未提交";
ALTER TABLE ld_personnelfile MODIFY COLUMN approvestatus VARCHAR(50) DEFAULT "未提交";
ALTER TABLE ld_salary MODIFY COLUMN approvestatus VARCHAR(50) DEFAULT "未提交";

UPDATE ld_competition SET approvestatus='未提交' WHERE IFNULL(approvestatus,'')<>'';
UPDATE ld_holiday SET approvestatus='未提交' WHERE IFNULL(approvestatus,'')<>'';
UPDATE ld_laborcontract SET approvestatus='未提交' WHERE IFNULL(approvestatus,'')<>'';
UPDATE ld_personnelfile SET approvestatus='未提交' WHERE IFNULL(approvestatus,'')<>'';
UPDATE ld_salary SET approvestatus='未提交' WHERE IFNULL(approvestatus,'')<>'';

DROP PROCEDURE IF EXISTS `createmodulebillno`;
delimiter ||
CREATE PROCEDURE `createmodulebillno`(
	out modulebillno varchar(50)
)
begin 

	select concat( prefix , case when datetype = 'yyyymmdd' or  datetype = 'yyyymmdd-' then  DATE_FORMAT(now(),'%Y%m%d') 
			when datetype = 'yymm' or  datetype = 'yymm-'  or datetype = 'yymm.' 				then 		DATE_FORMAT(now(),'%Y%m') 
		  when datetype = 'yy-mm'  then  DATE_FORMAT(now(),'%Y-%m') 
		  when datetype = 'mmdd'  then  DATE_FORMAT(now(),'%m%d') 
			when datetype = 'mm-dd'  then  DATE_FORMAT(now(),'%m-%d')
		   when datetype = 'yyyy-mm-dd' or datetype = 'yyyy-mm-dd-'  then DATE_FORMAT(now(),'%Y-%m-%d')  
		 else  '' end,  case when right(datetype,1)='-' or right(datetype,1)='.' then right(datetype,1)
										else '' end ,

	case when ifnull(complement,0)>0 then LPAD(cur_id,complement,'0')
		else cur_id end ) into modulebillno
			from ld_modentity_num  where semodule='CashBill' and  active=1;
		

update ld_modentity_num set cur_id=case when ifnull(complement,0)>0 then LPAD(cur_id+1,complement,'0')
		else cur_id+1  end     
 where semodule='CashBill' and  active=1;
	
end ||
delimiter;

DROP PROCEDURE IF EXISTS `autocreatecashbillbycollectionslipwithdetail`;
delimiter ||
CREATE PROCEDURE `autocreatecashbillbycollectionslipwithdetail`(collectionslip_id int(19))
BEGIN

	declare done  int  default 0;
  declare entitytype_info varchar(50);
	declare entitytypeid_info  int(11);
  declare amount_info decimal(25,8);

	declare cur2 CURSOR FOR SELECT entitytype,entitytypeid,amount   FROM  ld_collectionslipdetail where id=collectionslip_id;
	declare continue handler  for not   found  SET done =1;
  open cur2;
	fetch cur2 into entitytype_info,entitytypeid_info,amount_info;
	loop2: while  done<>1 DO

		  call createmodulebillno(@modulebillno);
			if entitytype_info='SalesOrder' then 
					select received_amount, total,signed_data ,currency_id,currency_symbol,conversion_rate   into  @source_received_amount,@source_total,@source_date, @source_currencyid,@source_currency_symbol,@source_conversion_rate
					 from ld_salesorder where salesorderid=entitytypeid_info;
			ELSEif entitytype_info='ServiceContracts' then 
				select received_amount ,total,due_date ,currency_id,currency_symbol,conversion_rate   into @source_received_amount, @source_total,@source_date, @source_currencyid,@source_currency_symbol,@source_conversion_rate
					 from ld_servicecontracts where servicecontractsid=entitytypeid_info;
			end if;
			 select max(maxcrmid) into @maxcrmid from (
			select max(crmid) as maxcrmid  from ld_crmentity 
			union all 
			select * from ld_crmentity_seq ) as tmp;
			 update ld_crmentity_seq set id=@maxcrmid+1;
			 insert into ld_crmentity(setype,crmid)value('CashBill',@maxcrmid+1);
			set @disable_triggers='aa';
			insert into ld_cashbill (cashbillid, smcreatorid,createdtime,modifiedtime,total,accountid,subtotal,currency_id,conversion_rate,currency_symbol ,cashbill_no
			,cashbilldate,cashtype,bankaccountsetid,smownerid,collectionslip_id,entitytype,source_list )
			select @maxcrmid+1,smownerid,now(),now(),total,accountid,total,currency_id,conversion_rate,currency_symbol
			,@modulebillno,remit_date,'cashbill',bankaccountsetid,smownerid,collectionslip_id,entitytype_info,entitytypeid_info from ld_collectionslip
			where ld_collectionslip.collectionslip_id=collectionslip_id;
		 
	   insert into ld_cashbillscf(cashbillid) value(@maxcrmid+1);
	   insert into ld_cashbill2paymentplan(cashbillid,amount,entitytype,entitytypeid,source_total,received_amount,currency_id,conversion_rate,currency_symbol,entitytype_value)value
			(@maxcrmid+1,amount_info,entitytype_info,entitytypeid_info,@source_total, @source_received_amount, @currencyid,@currency_symbol,@conversion_rate,@modulebillno);
		insert into ld_cashbill2paymentplanscf( cashbill2paymentplan_id)value( LAST_INSERT_ID());
		set @disable_triggers=null;
		update ld_cashbill set total=amount_info,subtotal=amount_info where cashbillid=@maxcrmid+1;
		fetch cur2 into entitytype_info,entitytypeid_info,amount_info;
	end while loop2;
	close cur2;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `autocreatecashbillbycollectionsslip`;
delimiter ||
CREATE PROCEDURE `autocreatecashbillbycollectionsslip`(
	collectionslip_id int(19)
)
begin
 

 call createmodulebillno(@modulebillno);
 select max(maxcrmid) into @maxcrmid from (
			select max(crmid) as maxcrmid  from ld_crmentity 
			union all 
			select * from ld_crmentity_seq ) as tmp;
			 update ld_crmentity_seq set id=@maxcrmid+1;
			 insert into ld_crmentity(setype,crmid)value('CashBill',@maxcrmid+1);
insert into ld_cashbill (cashbillid,smcreatorid,createdtime,modifiedtime,total,accountid,subtotal,currency_id,conversion_rate,currency_symbol ,cashbill_no,cashbilldate,cashtype,collectionslip_id
	,bankaccountsetid,smownerid)

select @maxcrmid+1,smownerid,now(),now(),total,accountid,total,currency_id,conversion_rate,currency_symbol
,@modulebillno,remit_date,'cashbill',bankaccountsetid ,collectionslip_id,smownerid from ld_collectionslip
where ld_collectionslip.collectionslip_id=collectionslip_id;

insert into ld_cashbillscf(cashbillid) select @maxcrmid+1;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `autocreatecashbillbycollectionsslip_where`;
delimiter ||
CREATE PROCEDURE `autocreatecashbillbycollectionsslip_where`(
	collectionslip_id int(19)
)
BEGIN 

	if exists(select * from  ld_collectionslipdetail   where  id=collectionslip_id) then 
		call autocreatecashbillbycollectionslipwithdetail(collectionslip_id);
	ELSE
		call autocreatecashbillbycollectionsslip(collectionslip_id);
	end if;

	update ld_collectionslip set collectionslip_status ='havecashbill' where collectionslip_id=collectionslip_id;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_shoukuanrenlingdan_20240514`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_shoukuanrenlingdan_20240514`(
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM ld_collectionslip) OR EXISTS (SELECT 1 FROM ld_validatasavedetail WHERE relateid IS NULL AND relatefieldname='hdnGrandTotal') THEN
		DELETE FROM ld_validatasavedetail WHERE relateid IN (SELECT id FROM ld_validatasave WHERE module='CollectionSlip');
		DELETE FROM ld_validatasave WHERE module='CollectionSlip';
		DELETE FROM ld_validatasavemain WHERE module='CollectionSlip';

		INSERT INTO `ld_validatasavemain` (
			`rulename`, 
			`module`, 
			`actionprevent`, 
			`tipzhtype`, 
			`tipzh`,

			`tipen`, 
			`conditiongroup`, 
			`validataapplication`, 
			`relatedtable`, 
			`sequence`
		) 
		SELECT
			'合计金额必须等于收款金额或者为零', 
			'CollectionSlip', 
			'yes', 
			'text', 
			'分录的金额合计必须等于认领单的收款金额！', 

			'The total amount of the entry shall be equal to the amount of the receipt.',
			'[null,{"groupcondition":""}]', 
			'create,edit', 
			'ld_field', 
			'1';

		SET @main_id=(SELECT id FROM ld_validatasavemain WHERE module='CollectionSlip' AND rulename='合计金额必须等于收款金额或者为零' LIMIT 1);
		INSERT INTO `ld_validatasave` (
			`module`, 
			`relatedtable`, 
			`fieldname`, 
			`comparator`,
			`status`, 
			`allowsave`, 
			`funtype`,
			`validatasavemainid`,
			`valid_condition`
		)
		SELECT
			'CollectionSlip', 
			'ld_field', 
			'collected_amount',
			'e',
			'active',
			'no',
			'fields',
			@main_id,
			'or';

		SET @valid_id=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@main_id AND module='CollectionSlip' AND fieldname='collected_amount' LIMIT 1);
		INSERT INTO `ld_validatasavedetail` (
			`relateid`,
			`relatefieldname`, 
			`relatedtable`, 
			`funtype`
		) 
		SELECT
			@valid_id,
			'hdnGrandTotal',
			'ld_field', 
			'fields';

		INSERT INTO `ld_validatasave` (
			`module`, 
			`relatedtable`, 
			`fieldname`, 
			`comparator`,
			`status`, 
			`allowsave`, 
			`funtype`,
			`validatasavemainid`,
			`valid_condition`
		)
		SELECT
			'CollectionSlip', 
			'ld_field', 
			'collected_amount',
			'e',
			'active',
			'no',
			'fields',
			@main_id,
			'';


		SET @valid_id=(SELECT id FROM ld_validatasave WHERE validatasavemainid=@main_id AND module='CollectionSlip' AND fieldname='amount' LIMIT 1);
		INSERT INTO `ld_validatasavedetail` (
			`relateid`,
			`relatefieldname`, 
			`relatedtable`, 
			`funtype`
		) 
		SELECT
			@valid_id,
			'0',
			'ld_field', 
			'number';


		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip');
		DELETE FROM ld_workflow_excutesql WHERE id IN (
			SELECT
				b.id
			FROM ld_workflow a
			LEFT JOIN ld_workflow_actions b ON b.workflow_id=a.id
			WHERE a.tabid=@tabid
		);
		DELETE FROM ld_workflow_actions WHERE workflow_id IN (SELECT id FROM ld_workflow WHERE tabid=@tabid);
		DELETE FROM ld_workflow WHERE tabid=@tabid;

		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_workflow),0)+1;
		INSERT INTO `ld_workflow` (
			`id`, 
			`tabid`, 
			`name`, 
			`status`, 
			`description`, 

			`triggertime`, 
			`repeatmode`, 
			`approvalnode`, 
			`deleted`, 
			`createdtime`, 
			`advft_criteria`, 
			`advft_criteria_groups`
		) 
		SELECT
			@maxid, 
			@tabid,
			'客户名称为空时则根据汇款户名查询并关联相应的客户和负责人', 
			'Active', 
			'仅在新建的时候进行一次判断', 

			'Creation', 
			'every', 
			NULL, 
			'0', 
			NOW(), 
			'[{\"groupid\":\"1\",\"columnname\":\"\",\"comparator\":\"无\",\"value\":\"\",\"columncondition\":\"\"}]', 
			'[null,{\"groupcondition\":\"\"}]';


		UPDATE ld_workflow_seq SET id=(SELECT MAX(id) FROM ld_workflow);
		
		INSERT INTO `ld_workflow_actions` (
			`workflow_id`, 
			`action_title`, 
			`action_type`, 
			`api_url`, 
			`api_jsondata`, 
			`status`, 
			`createdtime`, 
			`deleted`, 
			`body_query_type`, 
			`sequence`, 
			`api_receive_msg`
		) 
		SELECT
			@maxid, 
			'如果有该客户，则自动选择相应客户和负责人', 
			'ExcuteSql', 
			NULL, 
			NULL, 
			'Active', 
			NOW(), 
			'0', 
			'form-data', 
			'1', 
			'no';

		SET @action_id=(SELECT id FROM ld_workflow_actions WHERE workflow_id=@maxid LIMIT 1);

		INSERT INTO ld_workflow_excutesql(
			workflow_action_id,
			query_sql
		)
		SELECT 
			@action_id,
			"UPDATE ld_collectionslip a
INNER JOIN ld_account b ON b.accountname=a.remit_account_name
SET 
a.accountid=b.accountid,
a.smownerid=b.smownerid
WHERE a.collectionslip_id='{Record.ID}'
AND b.deleted=0
AND IFNULL(a.accountid,0)  = 0;";


		SET @maxid=IFNULL((SELECT MAX(id) FROM ld_workflow),0)+1;
		INSERT INTO `ld_workflow` (
			`id`, 
			`tabid`, 
			`name`, 
			`status`, 
			`description`, 

			`triggertime`, 
			`repeatmode`, 
			`approvalnode`, 
			`deleted`, 
			`createdtime`, 
			`advft_criteria`, 
			`advft_criteria_groups`
		) 
		SELECT
			@maxid, 
			@tabid,
			'收款认领单通过审批通过后自动创建收款单', 
			'Active', 
			'', 

			'Approval', 
			'every', 
			'Approved', 
			'0', 
			NOW(), 
			'[{\"groupid\":\"1\",\"columnname\":\"\",\"comparator\":\"无\",\"value\":\"\",\"columncondition\":\"\"}]', 
			'[null,{\"groupcondition\":\"\"}]';


		UPDATE ld_workflow_seq SET id=(SELECT MAX(id) FROM ld_workflow);
		
		INSERT INTO `ld_workflow_actions` (
			`workflow_id`, 
			`action_title`, 
			`action_type`, 
			`api_url`, 
			`api_jsondata`, 
			`status`, 
			`createdtime`, 
			`deleted`, 
			`body_query_type`, 
			`sequence`, 
			`api_receive_msg`
		) 
		SELECT
			@maxid, 
			'收款认领单自动创建对应的收款单', 
			'ExcuteSql', 
			NULL, 
			NULL, 
			'Active', 
			NOW(), 
			'0', 
			'form-data', 
			'1', 
			'no';

		SET @action_id=(SELECT id FROM ld_workflow_actions WHERE workflow_id=@maxid LIMIT 1);

		INSERT INTO ld_workflow_excutesql(
			workflow_action_id,
			query_sql
		)
		SELECT 
			@action_id,
			"CALL autocreatecashbillbycollectionsslip_where('{Record.ID}');";

	END IF;
end ||
delimiter;

CALL ldcrm_reset_shoukuanrenlingdan_20240514();
DROP PROCEDURE IF EXISTS `ldcrm_reset_shoukuanrenlingdan_20240514`;
delimiter;

CALL addtableIndex('ld_collectionslip','remit_account_name','remit_account_name');
CALL addtableIndex('ld_collectionslip','smownerid','smownerid');
CALL addtableIndex('ld_collectionslip','smcreatorid','smcreatorid');
CALL addtableIndex('ld_collectionslip','modifiedtime','modifiedtime');
CALL addtableIndex('ld_collectionslip','createdtime','createdtime');
CALL addtableIndex('ld_collectionslip','approvestatus','approvestatus');
CALL addtableIndex('ld_collectionslip','accountid','accountid');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='CollectionSlip' LIMIT 1);
SET @detailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='total' LIMIT 1);
INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
SELECT @detailfieldid,'sum(a)',"{formulavar:[{'lettervar':'a','column':'amount'}]}",1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@detailfieldid);
delimiter;
-- 2024-04-29

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

UPDATE ld_version SET old_version='V8.6.3.3',current_version='V8.6.3.3',remark='V8.6.3.3-20240428',wx_version='V8.6.3.2';
delimiter;