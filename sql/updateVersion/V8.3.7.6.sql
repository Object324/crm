insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allownewordinarycustomers','允许新建“普通客户”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allownewordinarycustomers','Allow new ordinary customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public','is_commonaccount_create','varchar','50',NULL);
alter table ld_account_public alter is_commonaccount_create set default 'yes';
update ld_account_public set is_commonaccount_create = 'yes' where is_commonaccount_create is NULL;
delimiter;
-- 2021-03--16

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

UPDATE ld_version SET old_version='V8.3.7.6',current_version='V8.3.7.6',remark='V8.3.7.6-20210316',wx_version='V8.3.7.5';
delimiter;