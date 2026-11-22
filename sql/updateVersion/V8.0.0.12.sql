SET @tabid=(select tabid from ld_tab where name = 'Users' LIMIT 1);
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='wx_openid' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='WeiXin OpenID' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='WeiXinOpenID';
delimiter;
SET @tabid=(select tabid from ld_tab where name = 'Users' LIMIT 1);
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='wx_userid' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='WeiXin ID' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='WeiXinID';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELSHARE','取消共享','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CANCELSHARE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELSHARE','Cancel share','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CANCELSHARE' and Labeltype='fixedstr');
delimiter;
SET @tabid=(select tabid from ld_tab where name = 'ContactRecords' LIMIT 1);
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='contactrecord_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='Contact Record No' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='Contactrecord No';
delimiter;
SET @tabid=(select tabid from ld_tab where name = 'SalesOrder' LIMIT 1);
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='salesorder_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='Sales Order No' WHERE tabid=@tabid AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='SalesOrder No';
delimiter;
update ld_homestuffdetail set compute_columns='ld_potential.potentialid' where compute_columns='ld_potentials.potentialid';
update ld_homestuffdetail set compute_columns='ld_potential.amount' where compute_columns='ld_potentials.amount';
delimiter;




insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPLETIONVALUE','完成值','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='COMPLETIONVALUE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPLETIONVALUE','Completion','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='COMPLETIONVALUE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOLOOKVALUE','目标值','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TOLOOKVALUE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOLOOKVALUE','Target','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TOLOOKVALUE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AMOUNTUNIT','金额单位：万元','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNTUNIT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AMOUNTUNIT','Amount unit:Ten thousand yuan','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNTUNIT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUMBEROFCUSTOMERS','客户数量：个','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NUMBEROFCUSTOMERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUMBEROFCUSTOMERS','Number of customers:individual','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NUMBEROFCUSTOMERS' and Labeltype='fixedstr');
delimiter;
-- 2020-05-15

update ld_homestuffdetailcondition set columns='ld_leads:createdtime:createdtime:Leads_fieldlabel:DT' where columns='ld_leads:createdtime:createdtime:Leads_fieldlabel:D';
update ld_homestuffdetailcondition set columns='ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' where columns='ld_potential:createdtime:createdtime:Potentials_fieldlabel:D';
delimiter;

CALL addtableIndex('ld_workreport2user','workreportid','workreportid');
CALL addtableIndex('ld_workreport','createdtime','createdtime');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCKING','锁定','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LOCKING' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCKING','Locking','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LOCKING' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='进度漏斗' where labelbol='PropelledFunnel' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Progress funnel' where labelbol='PropelledFunnel' and labeltype='fixedstr' and languagetype='en';
delimiter;
-- 2020-05-22

CREATE TABLE IF NOT EXISTS `ld_customform24detailscflangjie` (
  `scf169id` int(10) NOT NULL AUTO_INCREMENT,
  `year` int(4) unsigned DEFAULT NULL,
  `month` int(2) unsigned DEFAULT NULL,
  `day` int(2) unsigned DEFAULT NULL,
  `number` int(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`scf169id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

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

UPDATE ld_version SET old_version='V8.0.0.12',current_version='V8.0.0.12',remark='V8.0.0.12-20200522',wx_version='V8.0.1.4';
delimiter;