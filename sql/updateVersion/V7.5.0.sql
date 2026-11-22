select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 117;
update ld_systems_deploy set sequence = sequence + 1000 where inputtype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',164,'设置服务合同关联合同后是否自动带出产品','',@sequence,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=164);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',164,164,'设置{$ServiceContracts.ServiceContracts}关联{$SalesOrder.SalesOrder}后是否自动带出产品' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=164 and tabid = 164);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',164,164,'Set up {$ServiceContracts.ServiceContracts} automatically delivered after the relevant {$SalesOrder.SalesOrder}?' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=164 and tabid = 164);
delimiter;
-- 2018-09-04

SET @tabid=21;
SET @option_tabid=37;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
SELECT @tabid,@option_tabid,1,0,0,3,12 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

update ld_inventoryproductrel 
inner JOIN ld_crmentity on ld_crmentity.crmid = ld_inventoryproductrel.id and ld_crmentity.setype = 'ServiceContracts'
set balancepurchasecount = quantity,havepurchasecount = 0;
delimiter;

DROP PROCEDURE IF EXISTS `Del_trigger_20180905`;
delimiter ||
CREATE PROCEDURE `Del_trigger_20180905`(
)
BEGIN

	IF DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' OR NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN
		DROP TRIGGER IF EXISTS `update_by_outboundorder_insert`;
		DROP TRIGGER IF EXISTS `update_by_purchaseorder_insert`;
		DROP TRIGGER IF EXISTS `update_by_purchaseinvoice_insert`;
		DROP TRIGGER IF EXISTS `update_by_invoice_insert`;
		DROP TRIGGER IF EXISTS `update_by_stock_insert`;
	END IF;
end ||
delimiter;

CALL Del_trigger_20180905();
DROP PROCEDURE IF EXISTS `Del_trigger_20180905`;
-- 2018-09-05

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HOWTOCASHBACK','如何退款','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='HOWTOCASHBACK' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','HOWTOCASHBACK','How to refunds','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='HOWTOCASHBACK' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THESALESREFUNDORDERISFORSALERETURNS','{$CashBack.CashBack}是针对{$SalesBack.SalesBack}的，不允许直接创建；','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='THESALESREFUNDORDERISFORSALERETURNS' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','THESALESREFUNDORDERISFORSALERETURNS','The sales refund order is for sale returns, and it is not allowed to be created directly.','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='THESALESREFUNDORDERISFORSALERETURNS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHENTHERETURNLISTISSOLD','在{$SalesBack.SalesBack}序时簿先找到需要退款的{$SalesBack.SalesBack}，在{$SalesBack.SalesBack}查看界面单机左侧相关信息“{$CashBack.CashBack}”的操作按钮“新建”即可。','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='WHENTHERETURNLISTISSOLD' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHENTHERETURNLISTISSOLD','When the return list is sold, a refund is found in the book, and the "new" operation button on the left side of the list is "new".','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='WHENTHERETURNLISTISSOLD' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TPURCHASEREFUNDORDERISFORPURCHASEORDER','{$PurchaseCashBack.PurchaseCashBack}是针对{$PurchaseBack.PurchaseBack}的，不允许直接创建；','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='TPURCHASEREFUNDORDERISFORPURCHASEORDER' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','TPURCHASEREFUNDORDERISFORPURCHASEORDER','TPurchase refund order is for purchase order, and it is not allowed to be created directly.','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='TPURCHASEREFUNDORDERISFORPURCHASEORDER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INORDERTOPURCHASEARETURNLIST','在{$PurchaseBack.PurchaseBack}序时簿先找到需要退款的{$PurchaseBack.PurchaseBack}，在{$PurchaseBack.PurchaseBack}查看界面单机左侧相关信息“{$PurchaseCashBack.PurchaseCashBack}”的操作按钮“新建”即可。','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='INORDERTOPURCHASEARETURNLIST' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','INORDERTOPURCHASEARETURNLIST','In order to purchase a return list, you can find a refund list, and the "purchase refund" operation button "new" on the left side of the list to check the left side information on the left side of the single machine.','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='INORDERTOPURCHASEARETURNLIST' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenter','请输入','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='pleaseenter' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenter','Please enter','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='pleaseenter' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='The purchase refund order is for purchase order, and it is not allowed to be created directly.' where labelbol='TPURCHASEREFUNDORDERISFORPURCHASEORDER' and Labeltype='fixedstr' and languagetype='en';
delimiter;
-- 2018-09-07

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

update ld_version set old_version='V7.5.0',current_version='V7.5.0',remark='V7.5.0-20180904',wx_version='V7.5.0';
delimiter;