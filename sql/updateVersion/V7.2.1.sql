update ld_cvadvfilter set columnname='ld_contactdetails:birthday:birthday:Contacts_fieldlabel' where columnname='ld_contactsubdetails:birthday:birthday:Contacts_Birthdate';
delimiter;

select tabid into @tabid from ld_tab where name='Attachment';
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
update ld_relatedlists set wx_presence=presence where related_tabid=@tabid;
delimiter;
select blockid into @blockid from ld_appparenttab where parenttab_label='Others';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual
where not exists(select 1 from ld_appparenttabrel where tabid=@tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Theallocationway','分摊方式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Theallocationway' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Theallocationway',"The allocation way",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Theallocationway' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','shareequally','均摊','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'shareequally' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','shareequally',"Share equally",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'shareequally' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','apportionmentofdifferentproportions','不同比例分摊','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'apportionmentofdifferentproportions' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','apportionmentofdifferentproportions',"Apportionment of different proportions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'apportionmentofdifferentproportions' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
update ld_field set searchfieldtype = 0 where tabid = @tabid and columnname in ('campaignname','campaign_no','campaignstatus','smownerid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','totalamountmust','合计必须等于100！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'totalamountmust' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','totalamountmust'," total amount must be equal to 100!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'totalamountmust' and labeltype = 'jspop');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_shareequally` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fieldname` varchar(50) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `entitytype` varchar(50) DEFAULT NULL,
  `default` int(1) DEFAULT '0',
  `presence` int(11) DEFAULT '0',
  `sequence` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_shareequally_value` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recordid` int(11) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `entitytype` varchar(50) DEFAULT NULL,
  `entitytypeid` int(11) DEFAULT NULL,
  `percent` varchar(50) DEFAULT NULL,
  `sequence` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPORTPROMPT','（单次导出数据不能超过5000条）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'EXPORTPROMPT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPORTPROMPT','(The single export data can\'t exceed 5000)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'EXPORTPROMPT' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMPORTPROMPT','（单次导入数据不能超过5000条）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'IMPORTPROMPT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMPORTPROMPT','(Single import data can\'t exceed 5000)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'IMPORTPROMPT' and labeltype = 'fixedstr');
delimiter;
update ld_desk set fieldlabel='邀请的方式可以从可选择成员列表中选择并点击添加按钮。' where labelbol='INVITEMENTHODUSER' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Invitation of the way can select from the list of users and click the Add button.' where labelbol='INVITEMENTHODUSER' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='移除的方式可以从已选择成员列表中选择并点击移除按钮。' where labelbol='REMOVEINVITEUSER' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='deletion of the way can select from the list of users and click the delete button.' where labelbol='REMOVEINVITEUSER' and Labeltype='fixedstr' and languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTINUEADDING','继续添加','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CONTINUEADDING' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTINUEADDING',"Brows",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CONTINUEADDING' and labeltype = 'fixedstr');
delimiter;

update ld_tab set mobilepresence='' where name='Attachment';
delimiter;
-- 2018-01-11


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

update ld_version set old_version='V7.2.1',current_version='V7.2.1',remark='V7.2.1-20180111',wx_version='V7.2.1';
delimiter;