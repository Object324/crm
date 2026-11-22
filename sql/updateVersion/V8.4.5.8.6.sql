UPDATE ld_desk SET fieldlabel='移动端工作台定制' WHERE labelbol='mobile_home_setting' AND fieldlabel='移动端首页定制' AND languagetype='zh';
-- 2022-05-07

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commonmoduleslabel','常用模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commonmoduleslabel','Common module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
delimiter;

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;
-- 2022-05-11

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','commonmoduleslabel','常用模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','commonmoduleslabel','Common module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'commonmoduleslabel' and labeltype = 'fixedstr');
delimiter;

update ld_dashboard_app set home_sequence = home_sequence + 100 where home_sequence>0;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence,home_presence,home_sequence) 
select 'commonmodules','commonmoduleslabel',NULL,'dashboard_10',0,1,1,1,0,'yes',1 from DUAL 
where not EXISTS(select 1 from ld_dashboard_app where `name` = 'commonmodules');
set @i=0;
update ld_dashboard_app set home_sequence=(@i:=@i+1) where  home_sequence>0 ORDER BY home_sequence ;
delimiter;

UPDATE ld_linkmodulecustom SET linkmodule = 'Customreport' where linkmodule = 'CustomReport';
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'WorkSheet');
UPDATE ld_field SET tablename = 'ld_attachments' where tabid = @tabid AND columnname = 'filename';
delimiter;
-- 2022-05-20

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

UPDATE ld_version SET old_version='V8.4.5.8.6',current_version='V8.4.5.8.6',remark='V8.4.5.8.6-20220520',wx_version='V8.4.5.8.6';
delimiter;