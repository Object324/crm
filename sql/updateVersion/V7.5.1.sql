CREATE TABLE if not exists `ld_validatasave` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `module` varchar(100) DEFAULT NULL,
  `relatedtable` varchar(50) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `formulavalue` text,
  `comparatordescription` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_validatasavedetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `relateid` int(19) DEFAULT NULL,
  `relateformulavalue` text,
  `relatefieldname` varchar(19) DEFAULT NULL,
  `sequence` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Expense','ld_field','expensedate','m','小于等于' from dual 
where not exists(select 1 from
 ld_validatasave where module='expense' and relatedtable='ld_field' 
and fieldname='expensedate' and comparator='m');

select id into @relateid from ld_validatasave where module='expense' and relatedtable='ld_field' 
and fieldname='expensedate' and comparator='m';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'curdate','',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relateformulavalue='curdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'CashBill','ld_field','cashbilldate','m','小于等于' from dual 
where not exists(select 1 from
 ld_validatasave where module='CashBill' and relatedtable='ld_field' 
and fieldname='cashbilldate' and comparator='m');

select id into @relateid from ld_validatasave where module='CashBill' and relatedtable='ld_field' 
and fieldname='cashbilldate' and comparator='m';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'curdate','',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relateformulavalue='curdate');

delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Commission','ld_field','expensedate','m','小于等于' from dual 
where not exists(select 1 from
 ld_validatasave where module='Commission' and relatedtable='ld_field' 
and fieldname='expensedate' and comparator='m');

select id into @relateid from ld_validatasave where module='Commission' and relatedtable='ld_field' 
and fieldname='expensedate' and comparator='m';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'curdate','',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relateformulavalue='curdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'ContactRecords','ld_field','contactdate','m','小于等于' from dual 
where not exists(select 1 from
 ld_validatasave where module='ContactRecords' and relatedtable='ld_field' 
and fieldname='contactdate' and comparator='m');

select id into @relateid from ld_validatasave where module='ContactRecords' and relatedtable='ld_field' 
and fieldname='contactdate' and comparator='m';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'curdatetime','',1 from dual 
where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relateformulavalue='curdatetime');

delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Commission','ld_tabdetailfield','amount','notempty','不能为空' from dual 
where not exists(select 1 from
 ld_validatasave where module='Commission' and relatedtable='ld_tabdetailfield' 
and fieldname='amount' and comparator='notempty');
delimiter;
insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Expense','ld_tabdetailfield','money','notempty','不能为空' from dual 
where not exists(select 1 from
 ld_validatasave where module='Expense' and relatedtable='ld_tabdetailfield' 
and fieldname='money' and comparator='notempty');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Expense','ld_tabdetailfield','startdate','m','小于等于' from dual 
where not exists(select 1 from
 ld_validatasave where module='Expense' and relatedtable='ld_tabdetailfield' 
and fieldname='startdate' and comparator='m');


select id into @relateid from ld_validatasave where module='Expense' and relatedtable='ld_tabdetailfield' 
and fieldname='startdate' and comparator='m';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','enddate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='enddate');

delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CANNOTTHAN','不能大于','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTTHAN' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CANNOTTHAN','The date of contact cannot be greater than ','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTTHAN' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CANNOTEMPTYORZERO','不能为空或0','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTEMPTYORZERO' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CANNOTEMPTYORZERO','cannot be empty or 0','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTEMPTYORZERO' and Labeltype='jspop');
delimiter;
update ld_field set  quickcreate=1 where uitype=1109;
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CALLCENTERREPORT','呼叫中心报表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT'
                                               and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CALLCENTERREPORT','Call center report','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CALLBUTLERCONNECTRECORD','关联单据','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLBUTLERCONNECTRECORD'
                                               and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CALLBUTLERCONNECTRECORD','Doc Relate','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLBUTLERCONNECTRECORD' and Labeltype='fixedstr' and languagetype='en');

call AddColumn('ld_callbutler','potentialid','int',11,null );
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CALLCENTERREPORT','呼叫中心报表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT'
                                               and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CALLCENTERREPORT','Call center report','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLCENTERREPORT' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CALLBUTLERCONNECTRECORD','关联单据','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLBUTLERCONNECTRECORD'
                                               and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CALLBUTLERCONNECTRECORD','Doc Relate','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CALLBUTLERCONNECTRECORD' and Labeltype='fixedstr' and languagetype='en');

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Contacts','ld_field','birthday','m','小于等于' from dual 
where not exists(select 1 from ld_validatasave where module='Contacts' and relatedtable='ld_field' 
and fieldname='birthday' and comparator='m');
select id into @relateid from ld_validatasave where module='Contacts' and relatedtable='ld_field' 
and fieldname='birthday' and comparator='m';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'curdate','',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relateformulavalue='curdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Project','ld_field','actualenddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='Project' and relatedtable='ld_field' 
and fieldname='actualenddate' and comparator='h');

select id into @relateid from ld_validatasave where module='Project' and relatedtable='ld_field' 
and fieldname='actualenddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Project','ld_field','targetenddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='Project' and relatedtable='ld_field' 
and fieldname='targetenddate' and comparator='h');

select id into @relateid from ld_validatasave where module='Project' and relatedtable='ld_field' 
and fieldname='targetenddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'ProjectTask','ld_field','enddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='ProjectTask' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h');

select id into @relateid from ld_validatasave where module='ProjectTask' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'ProjectTask','ld_field','actualenddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='ProjectTask' and relatedtable='ld_field' 
and fieldname='actualenddate' and comparator='h');

select id into @relateid from ld_validatasave where module='ProjectTask' and relatedtable='ld_field' 
and fieldname='actualenddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Campaigns','ld_field','closingdate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='Campaigns' and relatedtable='ld_field' 
and fieldname='closingdate' and comparator='h');

select id into @relateid from ld_validatasave where module='Campaigns' and relatedtable='ld_field' 
and fieldname='closingdate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'HelpDesk','ld_field','hopetime_end','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='HelpDesk' and relatedtable='ld_field' 
and fieldname='hopetime_end' and comparator='h');

select id into @relateid from ld_validatasave where module='HelpDesk' and relatedtable='ld_field' 
and fieldname='hopetime_end' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','hopetime',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='hopetime');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'PublicAnnouncement','ld_field','enddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='PublicAnnouncement' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h');

select id into @relateid from ld_validatasave where module='PublicAnnouncement' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'ProjectProgress','ld_field','enddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='ProjectProgress' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h');

select id into @relateid from ld_validatasave where module='ProjectProgress' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'Rate','ld_field','enddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='Rate' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h');

select id into @relateid from ld_validatasave where module='Rate' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription)
select 'DividendOrder','ld_field','enddate','h','大于等于' from dual 
where not exists(select 1 from ld_validatasave where module='DividendOrder' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h');

select id into @relateid from ld_validatasave where module='DividendOrder' and relatedtable='ld_field' 
and fieldname='enddate' and comparator='h';

insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','startdate',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid and relatefieldname='startdate');
delimiter;

DELETE FROM ld_related_field
WHERE trigger_fieldid IN (SELECT fieldid FROM ld_field WHERE columnname='contactid' AND uitype=57)
    AND fromvalue_type='column' AND fromvalue_info='accountid';

DELETE FROM ld_related_field
WHERE trigger_fieldid IN (SELECT fieldid FROM ld_field WHERE columnname='contactid' AND uitype=57)
    AND fromvalue_type='sql' AND fromvalue_info LIKE 'select ld_account.smownerid from ld_contactdetails%';
delimiter;
-- 2018-09-12

UPDATE ld_systems_deploy SET presence=1 WHERE deploy_type IN (21,115);
UPDATE ld_desk SET fieldlabel='{$PurchaseBack.PurchaseBack}是针对{$PurchaseOrder.PurchaseOrder}的，不允许直接创建' WHERE labelbol='RETURNPURCHASE1' AND languagetype='zh';
UPDATE ld_relatedlists SET actions=NULL WHERE `name`='get_CallButler';

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','thereisnoemailfield','该模块没有%%字段','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thereisnoemailfield' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','thereisnoemailfield','There is no %% field in this module.','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thereisnoemailfield' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = '{$SalesBack.SalesBack}是针对{$SalesOrder.SalesOrder}的，不允许直接创建' where languagetype = 'zh' and labelbol = 'Returns_SalesOrder_allow_creation' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '{$PurchaseCashBack.PurchaseCashBack}是针对{$PurchaseBack.PurchaseBack}的，不允许直接创建；' where languagetype = 'zh' and labelbol = 'TPURCHASEREFUNDORDERISFORPURCHASEORDER' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel='Line ' 
where languagetype='en' and labelbol='LINE' and Labeltype='jspop';
delimiter;
update ld_desk set fieldlabel=' Row ' 
where languagetype='en' and labelbol='row' and Labeltype='jspop';
delimiter;

update ld_desk set fieldlabel=' cannot be greater than ' 
where languagetype='en' and labelbol='CANNOTTHAN' and Labeltype='jspop';
delimiter;
-- 2018-09-14


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

update ld_version set old_version='V7.5.1',current_version='V7.5.1',remark='V7.5.1-20180914',wx_version='V7.5.1';
delimiter;