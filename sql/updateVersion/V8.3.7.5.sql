update ld_desk set fieldlabel = '您的客户被{operator}在{nowtime}正在尝试报备，请联系{operator}，联系电话：{operatorphone}' 
where languagetype = 'zh' and labelbol = 'REMINDOPEAFORHEDGING' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = ' Your customer is trying to report by the {operator} at {nowtime}. Please contact the {operator} at {operatorphone}' 
where languagetype = 'en' and labelbol = 'REMINDOPEAFORHEDGING' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTQRCODE','产品二维码','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTQRCODE','Product bar code','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTQRCODE','产品二维码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTQRCODE','Product bar code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTQRCODETIPS','{$Products.Products}【{$Products.productcode}】字段为空或未启用，请前往【系统设置】→【页面设置】→【{$Products.Products}->页面设置】启用字段，并录入数据','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODETIPS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTQRCODETIPS','The [{$Products.productcode}] field of {$Products.Products} is empty or not enabled. Please go to [System Settings] → [Page Settings] → [{$Products.Products} -> Page Settings] to enable the field and enter the data','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PRODUCTQRCODETIPS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_cvcolumnlist
SET columnname=REPLACE(columnname,'absamount','cf_1308')
WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Potentials')
    AND columnname LIKE '%cf_1308%'
    AND columnname LIKE '%absamount%';

UPDATE ld_tabwithproductview
SET `columns`=REPLACE(`columns`,'absamount','cf_1308')
WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Potentials')
    AND `columns` LIKE '%cf_1308%'
    AND `columns` LIKE '%absamount%'; 
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Accounts' and viewname = '今日待联系' and customcategory = 'ALLACCOUNT';
update ld_cvadvfilter set columnname = 'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:DT' where cvid =@cvid and columnname = 'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:D';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allownewordinarycustomers','允许新建“普通客户”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allownewordinarycustomers','Allow new ordinary customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public','is_commonaccount_create','varchar','50',NULL);
delimiter;

alter table ld_account_public alter is_commonaccount_create set default 'yes';
update ld_account_public set is_commonaccount_create = 'yes' where is_commonaccount_create is NULL;
delimiter;
-- 2021-03--08

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

UPDATE ld_version SET old_version='V8.3.7.5',current_version='V8.3.7.5',remark='V8.3.7.5-20210308',wx_version='V8.3.7.2';
delimiter;