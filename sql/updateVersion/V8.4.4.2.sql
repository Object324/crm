update  ld_business_backfillfield set tianyanchalabel = 'trade'
where  tianyanchalabel='industry'
and not EXISTS(select * from ld_desk  where  labelbol='trade') ;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','trade','行业','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='trade' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','trade','Industry','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='trade' and labeltype='fixedstr');
delimiter;

delete from ld_business_backfillfield  where tianyanchalabel='industry';
delimiter; 

update ld_field set typeofdata='N~O~20,2' where columnname='hastime' and (tablename='ld_project' or tablename='ld_projecttask')
and typeofdata='V~o';
delimiter;
update ld_field set typeofdata='N~O~20,2' where columnname='hastime' and (tablename='ld_project' or tablename='ld_projecttask')
and typeofdata='N~o';
delimiter;
-- 2021-10-21

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

UPDATE ld_version SET old_version='V8.4.4.2',current_version='V8.4.4.2',remark='V8.4.4.2-20211021',wx_version='V8.4.4.0.1';
delimiter;