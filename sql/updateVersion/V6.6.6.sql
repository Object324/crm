insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ResetListWidth','重置序时簿列宽','fixedstr' from DUAL 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ResetListWidth' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ResetListWidth','Reset Column Width','fixedstr' from DUAL 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ResetListWidth' and labeltype = 'fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ResetSuccess','重置成功','jspop' from DUAL 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ResetSuccess' and labeltype = 'jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ResetSuccess','Reset Success','jspop' from DUAL 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ResetSuccess' and labeltype = 'jspop'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ResetFailed','重置失败','jspop' from DUAL 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ResetFailed' and labeltype = 'jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ResetFailed','Reset Failed','jspop' from DUAL 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ResetFailed' and labeltype = 'jspop'); 
delimiter;
-- 2017-03-17 

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
delimiter;

update ld_version set old_version='V6.6.6',current_version='V6.6.6',remark='V6.6.6SP1-20170317';
delimiter;