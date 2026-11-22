UPDATE ld_desk SET fieldlabel = '全部已读' WHERE labelbol = 'SetAllAsRead' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'All read' WHERE labelbol = 'SetAllAsRead' AND languagetype = 'en';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'no',570,'分页组件，是否显示GO按钮','',100011,1,'select',1,'[{"value":"yes","text":"YES"},{"value":"no","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 570);
delimiter;

select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab (tabid,name,presence,tabsequence)
select -13,'CallRecord',1,@tabsequence+1 from dual 
where not exists(select 1 from ld_tab where name='CallRecord' AND tabid = -13);
delimiter;

insert into ld_tranlabel(languagetype,relateid,trantable,tabid,fieldlabel)
select 'zh','-13','ld_tab' ,'-13' ,'通话记录' from dual 
where not exists(select 1 from ld_tranlabel where tabid=-13 and relateid=-13 and trantable='ld_tab' and languagetype='zh');

insert into ld_tranlabel(languagetype,relateid,trantable,tabid,fieldlabel)
select 'en','-13','ld_tab' ,'-13' ,'Call Records' from dual 
where not exists(select 1 from ld_tranlabel where tabid=-13 and relateid=-13 and trantable='ld_tab' and languagetype='en');
delimiter;

SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='SendCashBill');
update ld_tranlabel set fieldlabel='源单金额'
WHERE languagetype='zh' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in ( select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tranlabel set fieldlabel='Contract amount'
WHERE languagetype='en' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in (select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tabdetailfield set fieldlabel='源单金额' WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额';
delimiter;
SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='CashBill');
update ld_tranlabel set fieldlabel='源单金额'
WHERE languagetype='zh' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in (select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tranlabel set fieldlabel='Contract amount'
WHERE languagetype='en' AND trantable='ld_tabdetailfield' AND tabid=@tabid AND Relateid in (select tabdetailfieldid FROM ld_tabdetailfield  WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额') AND fieldlabel='合同金额';
update ld_tabdetailfield set fieldlabel='源单金额' WHERE tabid=@tabid AND columnname='source_total' AND fieldlabel='合同金额';
delimiter;

UPDATE ld_relatedlists SET buttonstatus = 'no' WHERE `related_tabid` = 142 AND label = 'Singin';
delimiter;

UPDATE ld_relatedlists SET `name` = 'get_singin_list',type = 'entitytype_datacategory_sql',related_coltable = 'tmpsourcedetail.id',related_advanceset = '[{"columnname":"tmpsourcedetail.id","comparator":"e","columncondition":""}]'
WHERE `related_tabid` = 142 AND label = 'Singin' AND `name` = 'get_singin';
delimiter;


call AddColumn('ld_appsystem','is_open','varchar','10',' ');
call AddColumn('ld_appsystem','name','varchar','255',' ');
call AddColumn('ld_appsystem','sequence','int','11','0');
call AddColumn('ld_appsystem','module','varchar','255',' ');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',4,'是否显示销售助手','no' ,'',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=4);

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'超过N天没有跟进的客户','no' ,'Accounts',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Accounts');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'预计N天内成交的销售机会','no' ,'Potentials',1 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Potentials');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'N天内需要收款的回款计划','no' ,'PaymentPlan',2 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='PaymentPlan');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'N天内将到期的服务合同','no' ,'ServiceContracts',3 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='ServiceContracts');

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'最近N天将要过生日的联系人','no' ,'Contacts',4 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Contacts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',6,'是否显示关键视图','no' ,'',6 from dual
where not exists(select 1 from ld_appsystem where deploy_type=6 and description='是否显示关键视图');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WillDeleteLogWhetherContinue','当前变更将会删除{Var}个月前的日志留存，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WillDeleteLogWhetherContinue' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WillDeleteLogWhetherContinue','The current change will delete the log retention from {Var} months ago.Do you want to continue?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WillDeleteLogWhetherContinue' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_systems_deploy SET description="审批通过后计算已开票金额" WHERE deploy_type=463;
UPDATE ld_tranlabel SET fieldlabel='设置{$Invoice.Invoice}或{$PurchaseInvoice.PurchaseInvoice}审批通过后计算已开票金额' WHERE trantable='ld_systems_deploy' AND Relateid=463 AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel = 'Set calculating have_invoicetotal after the approval of {$Invoice.Invoice} or {$PurchaseInvoice.PurchaseInvoice}' WHERE languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 463 and relateid=463;
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription,validatasavetype)
select 'AddJobBill','ld_tabdetailfield','starttime','m','小于等于','js' from dual
where not exists(select 1 from ld_validatasave where module='AddJobBill' and relatedtable='ld_tabdetailfield' and fieldname='starttime');
delimiter;
select id into @relateid from ld_validatasave where module='AddJobBill' and relatedtable='ld_tabdetailfield' and fieldname='starttime';
insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','endtime',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid);
delimiter;

insert into ld_validatasave(module,relatedtable,fieldname,comparator,comparatordescription,validatasavetype)
select 'ExpenseBudget','ld_field','budget_start_date','m','小于等于','js' from dual
where not exists(select 1 from ld_validatasave where module='ExpenseBudget' and relatedtable='ld_field' and fieldname='budget_start_date');
delimiter;
select id into @relateid from ld_validatasave where module='ExpenseBudget' and relatedtable='ld_field' and fieldname='budget_start_date';
insert into ld_validatasavedetail(relateid,relateformulavalue,relatefieldname,sequence)
select @relateid,'','budget_end_date',1 from dual where not exists(select 1 from ld_validatasavedetail where relateid=@relateid);
delimiter;

SET @labelbol = 'LINGDANGHUOKE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'灵当获客',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Lingdang captures guests',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'SharedUsers';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'共享人',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Shared Users',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

set @tabid = (SELECT tabid from ld_tab where name = 'CollectionSlip');
UPDATE ld_tabdetailfield set defaultcolumn = 0 where tabid = @tabid and columnname = 'line_project_id';
delimiter;
-- 2024-05-30

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

UPDATE ld_version SET old_version='V8.6.3.3.3',current_version='V8.6.3.3.3',remark='V8.6.3.3.3-20240531',wx_version='V8.6.3.6';
delimiter;