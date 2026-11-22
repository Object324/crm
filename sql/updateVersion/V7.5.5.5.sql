insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'CRM微信小程序二维码','zh','CRMWECHATSMALLPROGRAMTWODIMENSIONAL','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CRMWECHATSMALLPROGRAMTWODIMENSIONAL' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'CRM Wechat Small Program Two-Dimensional Code','en','CRMWECHATSMALLPROGRAMTWODIMENSIONAL','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CRMWECHATSMALLPROGRAMTWODIMENSIONAL' and labeltype='fixedstr');
delimiter;
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select '下载地址','zh','DOWNLOADLINK','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOWNLOADLINK' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'download link','en','DOWNLOADLINK','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOWNLOADLINK' and labeltype='fixedstr');
delimiter;
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'CRM微信小程序二维码图片，可直接用微信扫码','zh','CANBESCANNEDDIRECTLYWITHWECHAT','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and labeltype='fixedstr');
insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'Two-dimensional code picture of CRM Wechat applet can be scanned directly with Wechat.','en','CANBESCANNEDDIRECTLYWITHWECHAT','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel='CRM外网访问地址请参照此格式' where labelbol='WECHATAPPLETSETTINGSREMIND05' and Labeltype='fixedstr' and languagetype='zh';
delimiter;
-- 2018-11-29

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.5.5.5',current_version='V7.5.5.5',remark='V7.5.5.5-20181129',wx_version='V7.5.5.5';
delimiter;