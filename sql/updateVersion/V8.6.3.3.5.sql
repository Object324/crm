UPDATE ld_callrecordfields set `status` = 'yes' where columnnames <> '' and columnnames is not null;
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

SET @tabid = (select tabid from ld_tab where `name`='Leads');
UPDATE ld_field set businessquery = 'no' WHERE tabid = @tabid;
UPDATE ld_field set businessquery = 'yes' WHERE tabid = @tabid and fieldid = (SELECT fieldid from ld_business_settings WHERE tabid = @tabid);
delimiter;

update ld_appsystem set is_open = 'yes' where deploy_type = 4;
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

UPDATE ld_version SET old_version='V8.6.3.3.5',current_version='V8.6.3.3.5',remark='V8.6.3.3.5-20240628',wx_version='V8.6.3.8';
delimiter;