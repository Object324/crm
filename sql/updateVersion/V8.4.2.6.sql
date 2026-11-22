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
			IF tmp_columnlen<=1 THEN 
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


SET @i=0;
SET @tabseq=IFNULL((SELECT tabsequence FROM ld_tab WHERE `name`='SocialPromotion'),1000);
UPDATE ld_tab SET tabsequence=tabsequence+10 WHERE tabsequence>@tabseq;
UPDATE ld_tab SET tabsequence=@tabseq+1 WHERE `name`='Ambassador';
UPDATE ld_tab SET tabsequence=@tabseq+2 WHERE `name`='ChannelCode';
UPDATE ld_tab SET tabsequence=@tabseq+3 WHERE `name`='Questionnaire';
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;
delimiter;

UPDATE ld_tab SET presence=0 WHERE `name`='Questionnaire';
delimiter;

SET @i=0;
SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Marketing');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SocialPromotion');
SET @tabid1=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @seq=IFNULL((SELECT sequence FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid),100);
UPDATE ld_parenttabrel SET sequence=sequence+1 WHERE sequence>@seq AND parenttabid=@parenttabid;
UPDATE ld_parenttabrel SET sequence=@seq+1 WHERE parenttabid=@parenttabid AND tabid=@tabid1;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;

DROP EVENT IF EXISTS `task_questionnaire_resetstatus_everysecond`;
delimiter ||
CREATE  EVENT `task_questionnaire_resetstatus_everysecond` ON SCHEDULE EVERY 5 SECOND STARTS '2021-05-11 15:00:00' ON COMPLETION NOT PRESERVE ENABLE 
DO 
UPDATE ld_questionnaire SET `status`='暂停' WHERE recovery_endtime<NOW();
||
delimiter;

CALl AddColumn('ld_customreport_chartset','funnel_type','VARCHAR','50','no');
CALl AddColumn('ld_customreport','linkmodulecheck','VARCHAR','50','no');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChartParameters','图表参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ChartParameters' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChartParameters','Chart parameters','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ChartParameters' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StatisticsModule','统计模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='StatisticsModule' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','StatisticsModule','Statistics module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='StatisticsModule' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','chartType','图表类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='chartType' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','chartType','chart type','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='chartType' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StatisticalDimension','统计维度','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='StatisticalDimension' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','StatisticalDimension','Statistical Dimension','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='StatisticalDimension' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LegendSettings','图例设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LegendSettings' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LegendSettings','Legend Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LegendSettings' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','showAtPcHome','在PC端首页显示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='showAtPcHome' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','showAtPcHome','Display on the PC front page','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='showAtPcHome' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','showAtPcHomeOfScope','关联首页数据查看范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='showAtPcHomeOfScope' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','showAtPcHomeOfScope','Associated home page data view scope','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='showAtPcHomeOfScope' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','showAtPcHomeOfTime','关联首页时间查询条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='showAtPcHomeOfTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','showAtPcHomeOfTime','Associated home time query conditions','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='showAtPcHomeOfTime' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','showAtPcHomeOfApprove','关联首页数据审批状态','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='showAtPcHomeOfApprove' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','showAtPcHomeOfApprove','Associated home page data approval status','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='showAtPcHomeOfApprove' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_customform37','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform37','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform38','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform38','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform39','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform39','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform40','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform40','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform41','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform41','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform42','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform42','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform43','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform43','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform44','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform44','source_list','TEXT','',NULL);

CALL AddColumn('ld_customform45','entitytype','varchar','50',NULL);
CALL AddColumn('ld_customform45','source_list','TEXT','',NULL);
delimiter;

update ld_homestuffdetail set compute_columns="ld_salesorder.receivable_balance" where stufflabel="SignContractBalanceReceivable" and stuffid=35 and pageurl like '%SalesOrder%';
update ld_homestuffdetail set compute_columns="ld_servicecontracts.receivable_balance" where stufflabel="SignContractBalanceReceivable" and stuffid=35 and pageurl like '%ServiceContracts%';
delimiter;

CALL AddColumn('ld_questionnaire','category','varchar','50',NULL);
delimiter;

alter table ld_questionnaire alter column category set default '外部';
delimiter;

UPDATE ld_field_seq SET id = (select MAX(fieldid) from ld_field);

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Questionnaire');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER('Questionnaire'),'_BASICINFORMATION') AND tabid=@tabid);
SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
SELECT @tabid,@maxfieldid+1,'category','yes',CONCAT('ld_',LOWER('Questionnaire')),1,1,'category','问卷类别',0,0,11,@blockid ,1,'V~O',1,0,1,2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='category');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='category');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'问卷类别' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Questionnaire category' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
delimiter;

UPDATE ld_questionnaire SET category = '外部' WHERE category IS NULL;
delimiter;
-- 2021-05-14


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

UPDATE ld_version SET old_version='V8.4.2.6',current_version='V8.4.2.6',remark='V8.4.2.6-20210514',wx_version='V8.4.2.6';
delimiter;