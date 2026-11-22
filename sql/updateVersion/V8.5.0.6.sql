SET @usereportid = (select usereportid from ld_usereport where `name`='SalesCommissionsByCash');
update ld_usereportcolumns set realcolumns=replace(realcolumns,":V",":N") ,`columns`=replace(`columns`,":V",":N"),realencolumns=replace(realencolumns,":V",":N")   where columns ='ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_source_displayreceived:V' and Usereportid=@usereportid;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','BEYONDHEIGHT','高度请设置150~230之间！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BEYONDHEIGHT' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','BEYONDHEIGHT','Please set the height between 150~230！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BEYONDHEIGHT' and labeltype='jspop');
delimiter;
-- 2023-06-20

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

UPDATE ld_version SET old_version='V8.5.0.6',current_version='V8.5.0.6',remark='V8.5.0.6-20230620',wx_version='V8.5.0.4';
delimiter;