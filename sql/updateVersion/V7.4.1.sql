INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExternalContactSetting','外部联系人设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactSetting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExternalContactSetting','External contact interface setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactSetting' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CRMWeatherShowExternalContact','设置微信端CRM中是否显示外部联系人','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CRMWeatherShowExternalContact' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CRMWeatherShowExternalContact','Setting up whether an external contact is displayed in the WeChat side CRM','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CRMWeatherShowExternalContact' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @fieldid+1,@blockid,'ExternalContactSetting','picklistdependency.png','CRMWeatherShowExternalContact','index.php?module=Settings&action=ExternalContact&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'ExternalContactSetting');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExternalContactInterfaceSetting','外部联系人接口设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactInterfaceSetting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExternalContactInterfaceSetting','External contact interface setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactInterfaceSetting' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExternalContactUsersSetting','外部联系人人员设置','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactUsersSetting' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExternalContactUsersSetting','External contact users setting','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExternalContactUsersSetting' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExplainOfExternalContact','选择的成员，在微信端CRM列表界面可导入外部联系人至CRM系统，在CRM系统联系人详情界面可直接进行企业微信聊天。','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExplainOfExternalContact' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExplainOfExternalContact','The selected members can import the external contacts to the CRM system on the WeChat CRM list interface, and can directly chat with WeChat in the CRM system contact details interface.','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ExplainOfExternalContact' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
CALL AddColumn('ld_wx_config','userid','text',null,null);
CALL AddColumn('ld_wx_config','usertype','varchar',100,null);
CALL AddColumn('ld_contactdetails','weixin_external_userid','varchar',255,null);
insert into ld_wx_config(name,description,switch,userid,usertype)
select 'external_contact','外部联系人配置','open','','all'
from dual where not exists(select 1 from ld_wx_config where name='external_contact');
delimiter;
-- 2018-06-22

CREATE TABLE IF NOT EXISTS `ld_port_cable` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT '',
  `module` varchar(255) DEFAULT '',
  `crm_id` int(19) not null ,
  `port_id` int(19) not null ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

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

update ld_version set old_version='V7.4.1',current_version='V7.4.1',remark='V7.4.1-20180622',wx_version='V7.4.1';
delimiter;