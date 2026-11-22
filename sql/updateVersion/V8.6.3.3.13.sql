set @tabid = (select tabid from ld_tab where `name`='WorkReportList');
update ld_field set uitype=5,typeofdata='D~O',bigtype='date' where tabid=@tabid and columnname='sendlog_workdate' and tablename='ld_workreport';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMFIRMTOWRITEOFF','确定要注销吗','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMFIRMTOWRITEOFF' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMFIRMTOWRITEOFF','Are you sure you want to write it off','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMFIRMTOWRITEOFF' and Labeltype='jspop' and languagetype='en');
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'Singin');
UPDATE ld_blocks set display_status = 0 where  blocklabel = 'LBL_ADDRESS_SINGIN' 
and tabid in (SELECT option_tabid from ld_option_module where tabid = @tabid and enablewhenadding = 0);
UPDATE ld_option_module set enablewhenadding = 1 where tabid = @tabid;
delimiter;
-- 2024-11-01


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

UPDATE ld_version SET old_version='V8.6.3.3.13',current_version='V8.6.3.3.13',remark='V8.6.3.3.13-20241101',wx_version='V8.6.5.0';
delimiter;