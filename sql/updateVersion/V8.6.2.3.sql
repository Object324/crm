SET @labelbol = 'PROGRESSSETTINGSPREVIEW';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'进度设置预览',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Progress Settings Preview',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel = '当前阶段值为空或不在进度中，请流转到第一个阶段开始' where labelbol = 'STAGEVALUEISINCORRECT' AND Labeltype = 'jspop' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'The current stage value is empty or not in progress. Please proceed to the first stage to start' where labelbol = 'STAGEVALUEISINCORRECT' AND Labeltype = 'jspop' AND languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetLeastOneFieldQuerying','请至少选择一个查询字段！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SetLeastOneFieldQuerying' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetLeastOneFieldQuerying','Please set at least one field available for querying!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SetLeastOneFieldQuerying' and Labeltype='jspop' and languagetype='en');
delimiter;

CALL AddColumn('ld_account_public_pool','poolmember_show_noallocate','varchar','10','');
CALL AddColumn('ld_leads_public_pool','poolmember_show_noallocate','varchar','10','');
update ld_account_public_pool set poolmember_show_noallocate='no' where poolmember_show_noallocate='' or poolmember_show_noallocate is NULL;
update ld_leads_public_pool set poolmember_show_noallocate='no' where poolmember_show_noallocate='' or poolmember_show_noallocate is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWPUBLICMEMBERSVIEWPUBLICSEAS','允许公海成员查看"公海未分配"列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ALLOWPUBLICMEMBERSVIEWPUBLICSEAS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWPUBLICMEMBERSVIEWPUBLICSEAS','Allow members of the public seas to view the "Unallocated Public Seas" list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ALLOWPUBLICMEMBERSVIEWPUBLICSEAS' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2024-01-18

UPDATE ld_cvcolumnlist SET columnname=REPLACE(columnname,'cf_1308','cf_1317') WHERE columnname LIKE '%cf_1308:cf_1317%'
	AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=2 AND columnname='cf_1308');

UPDATE ld_tabwithproductview SET columns=REPLACE(columns,'cf_1308','cf_1317') WHERE columns LIKE '%cf_1308:cf_1317%'
	AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=2 AND columnname='cf_1308');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWCOMBINATION','添加组合条件','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NEWCOMBINATION' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWCOMBINATION',"New Combination",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NEWCOMBINATION' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConditionSetting','条件设置','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ConditionSetting' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConditionSetting',"Condition Setting",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ConditionSetting' and labeltype='jspop');
delimiter;
-- 2024-01-19

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

UPDATE ld_version SET old_version='V8.6.2.3',current_version='V8.6.2.3',remark='V8.6.2.3-20240119',wx_version='V8.6.2.0';
delimiter;