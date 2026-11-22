insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Image','图片','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='image' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Image','Image','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='image' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='Contract Amount' where labelbol='SignContractAmount' and labeltype='fixedstr' and languagetype='en';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QTY','数量','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='QTY' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','QTY','Quantity','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='QTY' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AMOUNT','金额','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNT' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AMOUNT','Amount','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNT' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURYEAR','今年','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CURYEAR' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURYEAR','This Year','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CURYEAR' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PREVYEAR','去年','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PREVYEAR' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','PREVYEAR','Prev Year','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PREVYEAR' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YUAN','元','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='YUAN' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','YUAN','','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='YUAN' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GECOUNT','个','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GECOUNT' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','GECOUNT','','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GECOUNT' and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel='Last Year' where labelbol='PREVYEAR' and labeltype='fixedstr' and languagetype='en';
delimiter;

CALL addtableIndex('ld_crmentity','setype','setype');
-- 2020-06-02

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

UPDATE ld_version SET old_version='V8.0.4',current_version='V8.0.4',remark='V8.0.4-20200602',wx_version='V8.0.4';
delimiter;