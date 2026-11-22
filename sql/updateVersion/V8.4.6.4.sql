SET @disable_triggers='abcde';
update ld_salesorder set order_source='' where order_source='null';
alter table `ld_salesorder` alter column `order_source` drop default;
alter table `ld_salesorder` alter column `order_source` set default '';
SET @disable_triggers=NULL;
delimiter;

update ld_desk set fieldlabel= '在{$SalesOrder.SalesOrder}序时簿先找到需要退货的订单，在订单查看界面单击相关信息“{$SalesBack.SalesBack}”操作按钮“新建”即可' where labelbol = 'wsfftntroboiotstroictbhrt' and languagetype = 'zh';
update ld_desk set fieldlabel= 'In the {$SalesOrder.SalesOrder}, the book first finds the order that needs to be returned. At the order view interface, click the relevant information, "sales return order" button, "newly-built".' where labelbol = 'wsfftntroboiotstroictbhrt' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel= '在{$PurchaseOrder.PurchaseOrder}序时簿先找到需要退货的订单，在订单查看界面单击相关信息“{$PurchaseBack.PurchaseBack}”操作按钮“新建”即可；' where labelbol = 'RETURNPURCHASE2' and languagetype = 'zh';
update ld_desk set fieldlabel= 'You can choose the order that needs to be returned in the {$PurchaseOrder.PurchaseOrder} list first and click the button "New" besides "{$PurchaseBack.PurchaseBack}" through the relevant information of the order.' where labelbol = 'RETURNPURCHASE2' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel= '在{$SalesBack.SalesBack}序时簿先找到需要退款的{$SalesBack.SalesBack}，在{$SalesBack.SalesBack}查看界面单击相关信息“{$CashBack.CashBack}”的操作按钮“新建”即可。' where labelbol = 'WHENTHERETURNLISTISSOLD' and languagetype = 'zh';
update ld_desk set fieldlabel= 'When the return list is sold, a refund is found in the book, and the "new" operation button of the list is "new".' where labelbol = 'WHENTHERETURNLISTISSOLD' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel= '在{$PurchaseBack.PurchaseBack}序时簿先找到需要退款的{$PurchaseBack.PurchaseBack}，在{$PurchaseBack.PurchaseBack}查看界面单击相关信息“{$PurchaseCashBack.PurchaseCashBack}”的操作按钮“新建”即可。' where labelbol = 'INORDERTOPURCHASEARETURNLIST' and languagetype = 'zh';
update ld_desk set fieldlabel= 'In order to purchase a return list, you can find a refund list, and the "purchase refund" operation button "new" of the list to check the left side information on the left side of the single machine.' where labelbol = 'INORDERTOPURCHASEARETURNLIST' and languagetype = 'en';
delimiter;

update ld_industrydemo set industry_zh='通用行业', industry_en='General industry' where datasql_path = 'IndustryDemo/001_factory.sql' and industry_zh='出厂设置';
delimiter;

update  ld_dashboard_app set home_sequence=0 where name='PersonalAccountBalance' or name='search_erp_stcok';
delimiter;

UPDATE ld_desk SET fieldlabel = '查询分类设置' where labelbol = 'managecustomview' and languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Manage classification settings' where labelbol = 'managecustomview' and languagetype = 'en';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Products');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='productstatus');
update ld_tranlabel set fieldlabel='商城商品状态' where languagetype='zh' and Relateid=@fieldid and trantable='ld_field' and fieldlabel='商品状态';
update ld_tranlabel set fieldlabel='Mall commodity status' where languagetype='en' and Relateid=@fieldid and trantable='ld_field' and fieldlabel='Commodity status';
delimiter;
-- 2022-05-27

DROP EVENT IF EXISTS task_gonggao_reminder;

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

UPDATE ld_version SET old_version='V8.4.6.4',current_version='V8.4.6.4',remark='V8.4.6.4-20220527',wx_version='V8.4.6.4';
delimiter;