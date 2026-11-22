update ld_dashboard_app set modulenames='Leads,Accounts,Contacts,Potentials,Calendar,ContactRecords,HelpDesk,SignLeads,LeadsUpToAccounts,SalesOrder,ServiceContracts,ContractAmount,CommissionLeads,Commission' where name='salesdragontiger';
delimiter;

update ld_relatedlists set actions='SELECT' where tabid in(46,48) and name='get_projectabstract' and actions='ADD,SELECT';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_account_nolinkdays`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_account_nolinkdays`(
)
BEGIN
	SET @disable_triggers=1;
	UPDATE ld_account SET nolinkdays=DATEDIFF(CURDATE(),DATE_FORMAT(GREATEST(IFNULL(lastcontactdate,'1960-01-01' ),createdtime),'%Y-%m-%d'));
	SET @disable_triggers=NULL;
end ||
delimiter;

UPDATE ld_blocks SET display_status=1 WHERE blocklabel='LBL_LABEL' AND tabid=4 and blockid=565;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEARBYCUSTOMERVISIBLE','附近客户地图默认可见范围','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NEARBYCUSTOMERVISIBLE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEARBYCUSTOMERVISIBLE','Default visible range for nearby customer maps','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NEARBYCUSTOMERVISIBLE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @modulename = 'PaymentPlan';
INSERT INTO ld_relatecreatecondition(modulename,columnname,comparator,content,relatecreatemodule,sequence,contenttype)
SELECT 'Project','projectid','','(ld_project.salesorderid={$PaymentPlan.entitytypeid} OR ld_project.salesorderid IN (SELECT entitytypeid FROM ld_invoicedetail WHERE id ={$PaymentPlan.entitytypeid})) ','PaymentPlan',1,'sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatecreatecondition WHERE modulename='Project' AND relatecreatemodule=@modulename AND columnname='projectid' AND content LIKE '%ld_project.salesorderid={$PaymentPlan.entitytypeid}%');
delimiter;

update ld_productcurrencyrel INNER JOIN ld_products on ld_products.productid = ld_productcurrencyrel.productid and ld_products.currency_id = ld_productcurrencyrel.currencyid set actual_price=ld_products.costprice where  price_type = 'procostprice';
delimiter;

set @addblackkey = '科技';
insert into ld_business_wordslist(wordkey,wordtype)
select @addblackkey,'blackkey' from DUAL
where NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey=@addblackkey AND wordtype='blackkey');
delimiter;

set @addblackkey = '电器';
insert into ld_business_wordslist(wordkey,wordtype)
select @addblackkey,'blackkey' from DUAL
where NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey=@addblackkey AND wordtype='blackkey');
delimiter;

set @addblackkey = '股份';
insert into ld_business_wordslist(wordkey,wordtype)
select @addblackkey,'blackkey' from DUAL
where NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey=@addblackkey AND wordtype='blackkey');
delimiter;

set @addblackkey = '实业';
insert into ld_business_wordslist(wordkey,wordtype)
select @addblackkey,'blackkey' from DUAL
where NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey=@addblackkey AND wordtype='blackkey');
delimiter;

set @addblackkey = '机电';
insert into ld_business_wordslist(wordkey,wordtype)
select @addblackkey,'blackkey' from DUAL
where NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey=@addblackkey AND wordtype='blackkey');
delimiter;

ALTER TABLE `ld_quoteschange` MODIFY COLUMN `currentapprover` varchar(255);
delimiter;

delete from ld_stuff where stufftitle='DAILYWEEKMONTH';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTTHAN','不能大于','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTTHAN' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTTHAN'," cannot be greater than ",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTTHAN' and labeltype='jspop');
delimiter;

update ld_desk set Labeltype='fixedstr' where languagetype='en' and Labeltype='fixedstr !';
delimiter;

DELETE FROM ld_module_setting_byuser WHERE label='structuretree_expend' AND modulename='products' AND userid=1;
delimiter;

UPDATE ld_relatedlists SET actions='add' WHERE related_tabid=61;
delimiter;

select (max(IFNULL(sequence,0))+1) into @sequence from ld_systems_deploy where roottype = 4;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,462,'跟进记录是否启用回访提醒','ContactRecords',@sequence,4,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 462);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',462,462,'{$ContactRecords.ContactRecords}是否启用回访提醒'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = 462 and relateid=462);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',462,462,'Enable Follow-up Reminder for {$ContactRecords.ContactRecords} '
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 462 and relateid=462);
delimiter;
-- 2023-09-22

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

UPDATE ld_version SET old_version='V8.6.0.8',current_version='V8.6.0.8',remark='V8.6.0.8-20230922',wx_version='V8.6.0.8';
delimiter;