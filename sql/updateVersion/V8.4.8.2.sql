SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBL_SYSTEM_SETTINGS');
UPDATE ld_settings_field SET blockid=@blockid,sequence=10000 WHERE `name`='LBL_WORKFLOWCUSTOMIZATION_SET';

SET @i=0;
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;
-- 2022-11-21

set @presence = ( select presence from ld_tab where `name` = 'OutboundOrder');
UPDATE ld_relatedlists SET presence=1 WHERE `name`='account_buy_products.mrt' and (@presence<>0 and @presence <>2 and @presence=5);
delimiter;

SET @labelbol = 'CANNOTVIEWMULTIPLEDOC';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'多条单据无法查看明细','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Details cannot be viewed for multiple documents','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_account_public','limit_type','varchar','20',NULL);
CALL AddColumn('ld_account_public','limit_count','int','11',0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_account_role_limitcount_common` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roleid` int(11) DEFAULT NULL,
  `limit_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CALL AddColumn('ld_leads_public','limit_type','varchar','20',NULL);
CALL AddColumn('ld_leads_public','limit_count','int','11',0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_leads_role_limitcount_common` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roleid` int(11) DEFAULT NULL,
  `limit_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','maximumnumberofcustomers','{$Accounts.Accounts}数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='maximumnumberofcustomers' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','maximumnumberofcustomers','maximum number of {$Accounts.Accounts}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='maximumnumberofcustomers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Themaximumnumberofcustomers','可拥有{$Accounts.Accounts}数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Themaximumnumberofcustomers' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Themaximumnumberofcustomers','The maximum number of {$Accounts.Accounts}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Themaximumnumberofcustomers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateMaximumnumberofTip','说明：若启用公海，则仅针对成员普通{$Accounts.Accounts}设置数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateMaximumnumberofTip' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateMaximumnumberofTip','Instructions: if the high seas is enabled, the upper limit of the number is set only for members {$Accounts.Accounts}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateMaximumnumberofTip' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateReacheMaximumError','您拥有的{$Accounts.Accounts}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateReacheMaximumError','The number of {$Accounts.Accounts} you have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateReacheMaximumError1','您拥有的普通{$Accounts.Accounts}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateReacheMaximumError1','The number of {$Accounts.Accounts} you have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateSaveReacheMaximumError','%s拥有的{$Accounts.Accounts}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateSaveReacheMaximumError','The number of {$Accounts.Accounts} %s have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateSaveReacheMaximumError1','%s拥有的普通{$Accounts.Accounts}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateSaveReacheMaximumError1','The number of {$Accounts.Accounts} %s have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMERError','单据[%s]%s失败！原因：[%s]{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMERError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMERError','Document [%s]%s failed! Reason: The number of {$Accounts.Accounts} in [%s] has reached the upper limit!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMERError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMERError1','单据[%s]%s失败！原因：[%s]普通{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMERError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMERError1','Document [%s]%s failed! Reason: The number of common {$Accounts.Accounts} in [%s] has reached the upper limit!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMERError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMERJSError','被分配人{$Accounts.Accounts}数量已达上限!','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXCUSTOMERJSError' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMERJSError','The number of {$Accounts.Accounts} assigned has reached the upper limit','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXCUSTOMERJSError' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMERJSError1','被分配人普通{$Accounts.Accounts}数量已达上限!','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXCUSTOMERJSError1' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMERJSError1','The number of common {$Accounts.Accounts} assigned has reached the upper limit','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXCUSTOMERJSError1' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMERAppError','被分配人{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXCUSTOMERAppError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMERAppError','The number of {$Accounts.Accounts} assigned has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXCUSTOMERAppError' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXCUSTOMERAppError1','被分配人普通{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMERAppError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXCUSTOMERAppError1','The number of common {$Accounts.Accounts} assigned has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXCUSTOMERAppError1' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TransferToCommonCustomerError','单据[%s]转公海失败！原因：【%s】{$Accounts.Accounts}数量已达上限！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TransferToCommonCustomerError' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TransferToCommonCustomerError','Document [%s] to open sea failed! Reason: The number of {$Accounts.Accounts} [%s] has reached the upper limit!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TransferToCommonCustomerError' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TransferToCommonCustomerError1','单据[%s]转公海失败！原因：【%s】普通{$Accounts.Accounts}数量已达上限！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TransferToCommonCustomerError1' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TransferToCommonCustomerError1','Document [%s] to open sea failed! Reason: The number of common {$Accounts.Accounts} [%s] has reached the upper limit!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TransferToCommonCustomerError1' and Labeltype = 'fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TransferToCommonCustomerAppError','单据负责人[%s]拥有的{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonCustomerAppError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TransferToCommonCustomerAppError','Document person in charge [%s] {$Accounts.Accounts} number has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonCustomerAppError' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TransferToCommonCustomerAppError1','单据负责人[%s]拥有的普通{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonCustomerAppError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TransferToCommonCustomerAppError1','Document person in charge [%s] common {$Accounts.Accounts} number has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonCustomerAppError1' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXPUBLICCUSTOMERError','单据[%s]%s失败！原因：[%s]公海已分配{$Accounts.Accounts}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXPUBLICCUSTOMERError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXPUBLICCUSTOMERError','Document [%s]%s failed! Reason: The number of high seas {$Accounts.Accounts} in [%s] has reached the upper limit!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXPUBLICCUSTOMERError' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','maximumnumberofleads','{$Leads.Leads}数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='maximumnumberofleads' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','maximumnumberofleads','maximum number of {$Leads.Leads}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='maximumnumberofleads' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Themaximumnumberofleads','可拥有{$Leads.Leads}数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Themaximumnumberofleads' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Themaximumnumberofleads','The maximum number of {$Leads.Leads}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Themaximumnumberofcustomers' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateMaximumnumberofLeadsTip','说明：若启用公海，则仅针对成员普通{$Leads.Leads}设置数量上限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateMaximumnumberofLeadsTip' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateMaximumnumberofLeadsTip','Instructions: if the high seas is enabled, the upper limit of the number is set only for members {$Leads.Leads}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateMaximumnumberofLeadsTip' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateReacheMaximumLeadsError','您拥有的{$Leads.Leads}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumLeadsError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateReacheMaximumLeadsError','The number of {$Leads.Leads} you have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumLeadsError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateReacheMaximumLeadsError1','您拥有的普通{$Leads.Leads}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumLeadsError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateReacheMaximumLeadsError1','The number of {$Leads.Leads} you have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateReacheMaximumLeadsError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateSaveReacheMaximumLeadsError','%s拥有的{$Leads.Leads}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumLeadsError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateSaveReacheMaximumLeadsError','The number of {$Leads.Leads} %s have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumLeadsError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CreateSaveReacheMaximumLeadsError1','%s拥有的普通{$Leads.Leads}数量已达上限，创建失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumLeadsError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CreateSaveReacheMaximumLeadsError1','The number of {$Leads.Leads} %s have reached the maximum, failed to create!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CreateSaveReacheMaximumLeadsError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXLeadsError','单据[%s]%s失败！原因：[%s]{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXLeadsError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXLeadsError','Document [%s]%s failed! Reason: The number of {$Leads.Leads} in [%s] has reached the upper limit!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXLeadsError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXLeadsError1','单据[%s]%s失败！原因：[%s]普通{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXLeadsError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXLeadsError1','Document [%s]%s failed! Reason: The number of common {$Leads.Leads} in [%s] has reached the upper limit!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXLeadsError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXLeadsJSError','被分配人{$Leads.Leads}数量已达上限!','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXLeadsJSError' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXLeadsJSError','The number of {$Leads.Leads} assigned has reached the upper limit','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXLeadsJSError' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXLeadsJSError1','被分配人普通{$Leads.Leads}数量已达上限!','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXLeadsJSError1' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXLeadsJSError1','The number of common {$Leads.Leads} assigned has reached the upper limit','jspop' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXLeadsJSError1' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXLeadsAppError','被分配人{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXLeadsAppError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXLeadsAppError','The number of {$Leads.Leads} assigned has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol= 'ALLOCATERREACHMAXLeadsAppError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXLeadsAppError1','被分配人普通{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXLeadsAppError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXLeadsAppError1','The number of common {$Leads.Leads} assigned has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXLeadsAppError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TransferToCommonLeadsError','单据[%s]转公海失败！原因：【%s】{$Leads.Leads}数量已达上限！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TransferToCommonLeadsError' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TransferToCommonLeadsError','Document [%s] to open sea failed! Reason: The number of {$Leads.Leads} [%s] has reached the upper limit!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TransferToCommonLeadsError' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TransferToCommonLeadsError1','单据[%s]转公海失败！原因：【%s】普通{$Leads.Leads}数量已达上限！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TransferToCommonLeadsError1' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TransferToCommonLeadsError1','Document [%s] to open sea failed! Reason: The number of common {$Leads.Leads} [%s] has reached the upper limit!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TransferToCommonLeadsError1' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TransferToCommonLeadsAppError','单据负责人[%s]拥有的{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonLeadsAppError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TransferToCommonLeadsAppError','Document person in charge [%s] {$Leads.Leads} number has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonLeadsAppError' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TransferToCommonLeadsAppError1','单据负责人[%s]拥有的普通{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonLeadsAppError1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TransferToCommonLeadsAppError1','Document person in charge [%s] common {$Leads.Leads} number has reached the upper limit','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'TransferToCommonLeadsAppError1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATERREACHMAXPUBLICLeadsError','单据[%s]%s失败！原因：[%s]公海已分配{$Leads.Leads}数量已达上限!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXPUBLICLeadsError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATERREACHMAXPUBLICLeadsError','Document [%s]%s failed! Reason: The number of high seas {$Leads.Leads} in [%s] has reached the upper limit!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where  labelbol= 'ALLOCATERREACHMAXPUBLICLeadsError' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_linkmodulecustom set url=REPLACE(url,'module=Customreport','module=ReportAnalysis');
delimiter;

update ld_linkmodulecustom set url=REPLACE(url,'action=CustomreportAjax','action=ReportAnalysisAjax');
delimiter;

update ld_field 
LEFT JOIN ld_tab on ld_field.tabid=ld_tab.tabid 
LEFT JOIN ld_settings_advance on ld_tab.`name`=ld_settings_advance.module and ld_field.fieldname=ld_settings_advance.module_field
set editpage = ''
where (`enable`='yes' or showadvancemobile = 'yes') and ld_field.editpage='listview';
delimiter;

SET @labelbol = 'ADMINISTRATORLOCATEADDRESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请联系系统管理员定位地址','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please contact the system administrator to locate the address','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ADMINISTRATORCREATEVENDORS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请联系系统管理员创建{$Vendors.Vendors}','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please contact the system administrator to create {$Vendors.Vendors}','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

drop PROCEDURE if EXISTS updataamounttypeofdata_demcial_20221108;
delimiter ||
create PROCEDURE updataamounttypeofdata_demcial_20221108(
)
begin 
	declare tfieldtab varchar(50);
	declare ttablename varchar(50);
	declare tcolumnname varchar(50);
    declare tamountlength int(11);
  declare done  int  default 0;
	declare cur2 CURSOR FOR select  'ld_producttoolfield' as infotablename,tablename,columnname,substring_index(typeofdata,',',-1)+0 as tamountlength   from ld_producttoolfield where  uitype>=25 and uitype<=50 
				UNION 
					select 'ld_tabdetailfield' as infotablename,tablename,columnname,substring_index(typeofdata,',',-1)+0 as tamountlength  from ld_tabdetailfield where (fieldtype='Amount' or fieldtype='RMB_Amount' or fieldtype = 'SourceAmount')
				UNION
					select 'ld_field' as infotablename,tablename,columnname,substring_index(typeofdata,',',-1)+0 as tamountlength  from ld_field where bigtype='currency' and (uitype = 71 or uitype=72);
	declare continue handler  for not   found  SET done =1;
	open cur2;
	fetch cur2 into tfieldtab,ttablename,tcolumnname,tamountlength;
	set @disable_triggers = 'updataamounttypeofdata_20221108';
	loop2: while  done<>1 DO
		IF NOT EXISTS (select 1 from ld_systems_deploy where deploy_type=351) THEN
			IF(tamountlength<8) and 
				((tfieldtab = 'ld_producttoolfield' and tcolumnname in('list_amount','tax_amount','discount_amount','tax_total'
					,'subtotal','discount_amount','adjustment','havereceivedamount','balancereceivedamount','havepayamount','balancepayamount'
					,'product_received_amount','amount','total','product_pay_amount','plan_contract_amount','amount'))
					or (tfieldtab = 'ld_tabdetailfield' and tcolumnname in ('total','source_total','received_amount','amount','reference_amount','rmb_total'
					,'adjustment_amount','budget_amount','invoicetotal','order_pay_amount','plan_amount','plan_invoicetotal','plan_orderreceivedamount'))
					or(tfieldtab = 'ld_field' and tcolumnname != 'unit_price')) THEN
						set @sql=Concat(' 	alter  table ',ttablename,' modify column ',tcolumnname,' decimal(25,8) ');
						prepare stmt1 from @sql;
						execute stmt1;
						deallocate  prepare  stmt1;
			END IF;
		END IF;
	fetch cur2 into tfieldtab,ttablename,tcolumnname,tamountlength;
	end while loop2;
	close cur2;
end ||
delimiter;

SET @disable_triggers = 'aaaa';
call updataamounttypeofdata_demcial_20221108(); 
SET @disable_triggers = NULL;
delimiter;

drop PROCEDURE if EXISTS updataamounttypeofdata_demcial_20221108;
delimiter;


SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT '2',351,'设置单据分录明细金额字段和单据头货币字段小数位数','',@sequence+1,1,'opetext',0,'' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 351);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',351,351,'设置单据分录明细金额字段和单据头货币字段小数位数' from dual
where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=351);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',351,351,'Set the decimal number of the Currency field in the entry details of products and bill header' from dual 
where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=351);
delimiter;


set @tabid = (select tabid from ld_tab where `name`='Campaigns');
update ld_field set uitype=9,bigtype='' where columnname  in ('expectedroi','actualroi');
delimiter;

update ld_usereportcolumns set `columns`=replace(`columns`,'ld_PurchaseOrder:','ld_purchaseorder:'),
realcolumns = replace(realcolumns,'ld_PurchaseOrder:','ld_purchaseorder:'),
realencolumns = replace(realencolumns,'ld_PurchaseOrder:','ld_purchaseorder:')
where `columns`='ld_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_Total:N';
delimiter;

drop PROCEDURE if EXISTS updataamounttypeofdata_20221108;
delimiter ||
create PROCEDURE updataamounttypeofdata_20221108(
	deploy_value_351 int(4)
)
begin 
	declare tfieldtab varchar(50);
	declare ttablename varchar(50);
  declare ttableid int(11);
  declare tproducttoolfieldid int(11);
	declare tcolumnname varchar(50);
	declare ttypeofdata varchar(50);
	declare tamountlength int(11);
  declare done  int  default 0;
	declare cur2 CURSOR FOR select  'ld_producttoolfield' as infotablename,tablename,tabid,producttoolfieldid,columnname,typeofdata,substring_index(typeofdata,',',-1)+0 as tamountlength  from ld_producttoolfield where  uitype>=25 and uitype<=50 
				UNION 
					select 'ld_tabdetailfield' as infotablename,tablename,tabid,tabdetailfieldid,columnname,typeofdata,substring_index(typeofdata,',',-1)+0 as tamountlength from ld_tabdetailfield where (fieldtype='Amount' or fieldtype='RMB_Amount' or fieldtype = 'SourceAmount')
				UNION
					select 'ld_field' as infotablename,tablename,tabid,fieldid,columnname,typeofdata,substring_index(typeofdata,',',-1)+0 as tamountlength from ld_field where bigtype='currency' and (uitype = 71 or uitype=72) and columnname<>'unit_price';
	declare continue handler  for not   found  SET done =1;
	open cur2;
	fetch cur2 into tfieldtab,ttablename,ttableid,tproducttoolfieldid,tcolumnname,ttypeofdata,tamountlength;
	set @disable_triggers = 'updataamounttypeofdata_20221108';
	loop2: while  done<>1 DO
		IF (tamountlength>0 && tamountlength !=deploy_value_351 ) THEN
				set @sql=Concat('update ',tfieldtab,' set typeofdata=replace(typeofdata,",',tamountlength,'"',',",',deploy_value_351,'") where tablename="', ttablename,'" and tabid=',ttableid,' and columnname="',tcolumnname,'"');
				prepare stmt2 from @sql;
				execute stmt2;
				deallocate  prepare  stmt2;
		END IF;
		IF(tamountlength=0 && ttypeofdata in ('N~O','NN~O','N~M') ) THEN
				set @sql=Concat('update ',tfieldtab,' set typeofdata="',ttypeofdata,'~25,',deploy_value_351,'" where tablename="', ttablename,'" and tabid=',ttableid,' and columnname="',tcolumnname,'"');
				prepare stmt3 from @sql;
				execute stmt3;
				deallocate  prepare  stmt3;
		END IF;
	fetch cur2 into tfieldtab,ttablename,ttableid,tproducttoolfieldid,tcolumnname,ttypeofdata,tamountlength;
	end while loop2;
	close cur2;
end ||
delimiter;

set @deploy_value = (select deploy_value from ld_systems_deploy where deploy_type=351);
call updataamounttypeofdata_20221108(@deploy_value); 
delimiter;
drop PROCEDURE if EXISTS updataamounttypeofdata_20221108;
delimiter;

CALL AddColumn('ld_workreport_remind','push_to_offiaccount','int','2',2);
CALL AddColumn('ld_workreport_remind','push_time_offiaccount','datetime',null ,null );
delimiter;
update ld_workreport_remind set push_to_offiaccount = 3;
delimiter;

SET @labelbol = 'PREVPAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'上一页','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Prev Page','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'NEXTPAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'下一页','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Next Page','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

update ld_homestuffdetail set pageurl='index.php?pageto_module=ReportAnalysis&pageto_action=newindex' where stufflabel='NewSignCount';
delimiter;

UPDATE ld_producttoolfield SET nullfield = 0 WHERE columnname='productname' AND nullfield=1;
delimiter;
-- 2022-11-25

DROP FUNCTION IF EXISTS `getPY`;
delimiter ||
CREATE  FUNCTION `getPY`(in_string text) RETURNS mediumtext CHARSET utf8
BEGIN
	DECLARE tmp_str text charset gbk DEFAULT '' ;
	DECLARE tmp_len SMALLINT DEFAULT 0; 
	DECLARE tmp_char VARCHAR(2) charset gbk DEFAULT '';
	DECLARE tmp_rs text charset gbk DEFAULT '';
	DECLARE tmp_cc VARCHAR(2) charset gbk DEFAULT '';

	SET tmp_str = in_string;
	SET tmp_len = LENGTH(tmp_str);

	WHILE tmp_len > 0 DO 
		SET tmp_char = LEFT(tmp_str,1); 
		SET tmp_cc = tmp_char;
		IF LENGTH(tmp_char)>1 THEN
			SELECT ELT(INTERVAL(CONV(HEX(tmp_char),16,10),0xB0A1,0xB0C5,0xB2C1,0xB4EE,0xB6EA,0xB7A2,0xB8C1,0xB9FE,0xBBF7,0xBFA6,0xC0AC
			,0xC2E8,0xC4C3,0xC5B6,0xC5BE,0xC6DA,0xC8BB,0xC8F6,0xCBFA,0xCDDA ,0xCEF4,0xD1B9,0xD4D1), 
			'A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','W','X','Y','Z') INTO tmp_cc;
		END IF; 

		
		IF tmp_char='钰' THEN
			-- 特殊汉字的处理
			SET tmp_rs = CONCAT(tmp_rs,'Y');
		ELSE
			SET tmp_rs = CONCAT(tmp_rs,tmp_cc);
		END IF;
		
		SET tmp_str = SUBSTRING(tmp_str,2);
		SET tmp_len = LENGTH(tmp_str);
	END WHILE; 
	RETURN tmp_rs;
END ||
delimiter;

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

UPDATE ld_version SET old_version='V8.4.8.2',current_version='V8.4.8.2',remark='V8.4.8.2-20221125',wx_version='V8.4.8.2';
delimiter;