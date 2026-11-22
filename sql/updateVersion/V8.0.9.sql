update ld_desk set fieldlabel='查看其他成员的单据详情' where labelbol='allowviewothers' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='查看自己创建的单据详情' where labelbol='ViewCreateMe' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='查看自己创建的单据详情（优先于角色权限）' where labelbol='ViewCreateMeTip' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='查询自己创建的单据列表' where labelbol='allowviewselfcreatedbill' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='允许查询自己创建的单据列表（负责人不是自己的单据）' where labelbol='viewselfbills' and labeltype='fixedstr' and languagetype='zh';
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','Sendcustomsdeclarationemail','Send customs declaration email','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Sendcustomsdeclarationemail' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Sendcustomsdeclarationemail','发送报关单邮件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Sendcustomsdeclarationemail' and labeltype='fixedstr');
delimiter;
-- 2020-06-23

ALTER TABLE ld_relatecreatecondition MODIFY COLUMN content TEXT;

DROP TABLE IF EXISTS ld_customform24detailscflangjie;
delimiter;
update ld_field set bigtype='users' where uitype=52 or uitype=53;
delimiter;

CALl AddColumn('ld_logpublicaccount','userid','int','19',0);
delimiter;

update ld_logpublicaccount 
INNER JOIN ld_users on ld_users.last_name=ld_logpublicaccount.username
set ld_logpublicaccount.userid=ld_users.id
where ld_logpublicaccount.username<>'系统' or ld_logpublicaccount.username<>'System';
delimiter;
-- 2020-06-28

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

UPDATE ld_version SET old_version='V8.0.9',current_version='V8.0.9',remark='V8.0.9-20200628',wx_version='V8.0.9';
delimiter;