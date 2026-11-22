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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUBGROUPUNFOLD','子部门默认收起','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SUBGROUPUNFOLD' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUBGROUPUNFOLD',"Subdepartments are folded by default",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SUBGROUPUNFOLD' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NORELATEDMODULES','没有相关模块','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NORELATEDMODULES' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NORELATEDMODULES','No related modules','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NORELATEDMODULES' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','DELETEDTOPICEDIT','该问卷已有回收数据，删除操作会将无法在统计图表看到该题目的回收数据，确定要删除吗？','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SUBMITREMARKREQUIRE' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','DELETEDTOPICEDIT','The questionnaire has collected data. If you delete it, you will not be able to see the collected data in the statistical chart. Are you sure you want to delete it?','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SUBMITREMARKREQUIRE' and Labeltype='jspop');
delimiter;

INSERT into ld_systems_deploy(deploy_value,deploy_type,description,sequence,presence)
select '0','326','销售机会查重显示超链接','1','1' from dual 
WHERE not EXISTS(SELECT 1 FROM ld_systems_deploy WHERE deploy_type='326');
delimiter;

SET @report_name='未来商机看板';
SET @report_type='template_js';
SET @report_template='default_futurepotentials.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SET @sequence=4;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

update ld_customreport_info set setype="Potentials" where report_name="未来商机看板";
update ld_customreport_info set databaselinktype="crmlink" where report_name="未来商机看板";
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SEARCHMODULE','查找模块','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SEARCHMODULE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SEARCHMODULE','Search module','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SEARCHMODULE' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','MAXNUMBERFIVE','（最多五条）','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='MAXNUMBERFIVE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','MAXNUMBERFIVE','(Up to five)','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='MAXNUMBERFIVE' and Labeltype='fixedstr');
delimiter;
-- 2021-06-29

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template IN ('default_account_xiaoshoufuzrtongji.mrt','default_account_kehuxingzhi.mrt','default_account_shengfenfbu.mrt');
SET @folderid=(SELECT id FROM ld_customreport_folder WHERE description='Statistical Charts' LIMIT 1);
SET @i=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@folderid);
UPDATE ld_customreport_info SET sequence=(@i:=@i+1),folder_id=@folderid
WHERE report_template IN ('default_account_xiaoshoufuzrtongji.mrt','default_account_kehuxingzhi.mrt','default_account_shengfenfbu.mrt')
	AND NOT EXISTS (SELECT 1 FROM ld_customreport_folder WHERE id=ld_customreport_info.folder_id)
ORDER BY sequence;
delimiter;

DELETE FROM ld_customreport_info WHERE report_template='CustomReport_2_41.mrt' AND report_type='template_flex' AND report_name='新报表';
delimiter;

CALL AddColumn('ld_questionnaire_topic', 'topic_json_old', 'varchar', '20', 'no');
delimiter;

update ld_questionnaire_topic set  topic_json_old='yes' where topic_json_old is null or topic_json_old='';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','MONTH','月份','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='MONTH' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','MONTH','month','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='MONTH' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','LBL_PAGE_SET','页面设置','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='LBL_PAGE_SET' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','LBL_PAGE_SET','Page Setting','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='LBL_PAGE_SET' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','LBL_ProductTool_field','单据分录定制','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='LBL_ProductTool_field' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','LBL_ProductTool_field','Bills Details Customization','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='LBL_ProductTool_field' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','DELETEDTOPICEDIT','该问卷已有回收数据，删除操作会将无法在统计图表看到该题目的回收数据，确定要删除吗？','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='DELETEDTOPICEDIT' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','DELETEDTOPICEDIT','The questionnaire has collected data. If you delete it, you will not be able to see the collected data in the statistical chart. Are you sure you want to delete it?','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='DELETEDTOPICEDIT' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','Multilinetextquestions','多行文本题','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='Multilinetextquestions' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','Multilinetextquestions','Multiline text questions','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='Multilinetextquestions' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','Singlelinetextquestion','单行文本题','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='Singlelinetextquestion' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','Singlelinetextquestion','Single line text question','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='Singlelinetextquestion' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','pleaseenter','请输入','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='pleaseenter' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','pleaseenter','Please input','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='pleaseenter' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOQUESTIONNAIRERESULT','未找到问卷结果','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOQUESTIONNAIRERESULT' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOQUESTIONNAIRERESULT','Questionnaire results were not found','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOQUESTIONNAIRERESULT' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_questionnaire_chart', 'seqtime', 'timestamp', '6', '0');
delimiter;

update ld_questionnaire_chart set seqtime=createdtime where seqtime is null or seqtime='' or seqtime='0000-00-00 00:00:00.000000';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','NOTECHECKMODULES','说明：在所有[module]中进行查重，最多只显示符合条件的前{Var}条数据。','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='NOTECHECKMODULES' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','NOTECHECKMODULES','Note: check in all of the [module], only the first {Var} qualifying data.','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='NOTECHECKMODULES' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid  from ld_tab where name='Products';
select actionid into @dupactionid from ld_actionmapping where actionname='accountdatadup';
select actionid into @delactionid from ld_actionmapping where actionname='delete';

select sequence into @delsequence from ld_profileallpermission 
where tabid=@tabid and operation=@delactionid;
update ld_profileallpermission set sequence=sequence+2 where tabid=@tabid and sequence>@delsequence;
insert into ld_profileallpermission(tabid ,operation,sequence)
select @tabid,@dupactionid,@delsequence+1 from dual 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@dupactionid);
delimiter;

drop PROCEDURE if EXISTS productdupprofile;
delimiter ||
create PROCEDURE productdupprofile()
begin
	
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name="Products"');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
			select actionid into @actionid from ld_actionmapping where actionname='accountdatadup';
			set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@actionid,',',0,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
			prepare stmt from @sql;
			execute stmt;

			deallocate prepare stmt;
			
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;
call productdupprofile;
drop PROCEDURE if exists productdupprofile;
delimiter;

INSERT into ld_systems_deploy(deploy_value,deploy_type,description,sequence,presence)
select '0','327','产品管理查重显示超链接','1','1' from dual 
WHERE not EXISTS(SELECT 1 FROM ld_systems_deploy WHERE deploy_type='327');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','ProductsSalesRanking','产品销售排行榜','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='ProductsSalesRanking' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','ProductsSalesRanking','Product sales ranking','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='ProductsSalesRanking' and Labeltype='fixedstr');
delimiter;
-- 2021-07-02

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment');
DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_field' AND Relateid IN (SELECT fieldid FROM ld_field WHERE tablename='ld_attachmentsforbills' AND columnname='isenabled');
DELETE FROM ld_field WHERE tablename='ld_attachmentsforbills' AND columnname='isenabled';
delimiter;

DELETE FROM ld_relatedlists WHERE tabid=20 AND related_tabid=22 AND type='datacategory_sql'
	AND EXISTS (SELECT 1 FROM ld_version WHERE trade='construction');
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

UPDATE ld_version SET old_version='V8.4.3.1',current_version='V8.4.3.1',remark='V8.4.3.1-20210702',wx_version='V8.4.3.1';
delimiter;