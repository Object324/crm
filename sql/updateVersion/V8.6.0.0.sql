SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SalesOrderTrack';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N';
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_salesorder:havecashbackamount:havecashbackamount:SalesOrder_havecashbackamount:N', @sequence+1, '1', 'ld_salesorder:havecashbackamount:havecashbackamount:SalesOrder_已退款金额:N','ld_salesorder:havecashbackamount:havecashbackamount:SalesOrder_Amount refunded:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_salesorder:havecashbackamount:havecashbackamount:SalesOrder%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SalesOrderTrack';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N';
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_salesorder:totalcashbackamount:totalcashbackamount:SalesOrder_totalcashbackamount:N', @sequence+1, '1', 'ld_salesorder:totalcashbackamount:totalcashbackamount:SalesOrder_应退款金额:N','ld_salesorder:totalcashbackamount:totalcashbackamount:SalesOrder_Total refundable amount:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_salesorder:totalcashbackamount:totalcashbackamount:SalesOrder%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='SalesOrderTrack';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N';
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_salesorder:balancecashbackamount:balancecashbackamount:SalesOrder_balancecashbackamount:N', @sequence+1, '1', 'ld_salesorder:balancecashbackamount:balancecashbackamount:SalesOrder_应退款余额:N','ld_salesorder:balancecashbackamount:balancecashbackamount:SalesOrder_Refundable balance:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_salesorder:balancecashbackamount:balancecashbackamount:SalesOrder%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='PurchaseOrderTrack';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N';
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_purchaseorder:havecashbackamount:havecashbackamount:PurchaseOrder_havecashbackamount:N', @sequence+1, '1', 'ld_purchaseorder:havecashbackamount:havecashbackamount:PurchaseOrder_已退款金额:N','ld_purchaseorder:havecashbackamount:havecashbackamount:PurchaseOrder_Amount refunded:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_purchaseorder:havecashbackamount:havecashbackamount:PurchaseOrder%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='PurchaseOrderTrack';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N';
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_purchaseorder:totalcashbackamount:totalcashbackamount:PurchaseOrder_totalcashbackamount:N', @sequence+1, '1', 'ld_purchaseorder:totalcashbackamount:totalcashbackamount:PurchaseOrder_应退款金额:N','ld_purchaseorder:totalcashbackamount:totalcashbackamount:PurchaseOrder_Total refundable amount:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_purchaseorder:totalcashbackamount:totalcashbackamount:PurchaseOrder%' and Usereportid=@usereportid);
delimiter;

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE name='PurchaseOrderTrack';
SELECT Sequence INTO @sequence FROM ld_usereportcolumns WHERE Usereportid=@usereportid and `columns`='ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N';
UPDATE ld_usereportcolumns SET Sequence=Sequence+1 where Sequence>=@sequence+1;
INSERT INTO `ld_usereportcolumns` (usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid, 'ld_purchaseorder:balancecashbackamount:balancecashbackamount:PurchaseOrder_balancecashbackamount:N', @sequence+1, '1', 'ld_purchaseorder:balancecashbackamount:balancecashbackamount:PurchaseOrder_应退款余额:N','ld_purchaseorder:balancecashbackamount:balancecashbackamount:PurchaseOrder_Refundable balance:N' from DUAL
where not EXISTS (select 1 from ld_usereportcolumns where `columns` like '%ld_purchaseorder:balancecashbackamount:balancecashbackamount:PurchaseOrder%' and Usereportid=@usereportid);
delimiter;

update ld_field set bigtype='date' where columnname='lastorderdate' and uitype=70 and bigtype='datetime';
delimiter;

UPDATE ld_homeboard SET saleskit_height=120 WHERE saleskit_height=180;
delimiter;

UPDATE ld_wx_evaluate_field set zh_label='服务评分' WHERE columname='grade';
UPDATE ld_wx_evaluate_field set zh_label='满意度' WHERE columname='satisfaction';
UPDATE ld_wx_evaluate_field set zh_label='及时率' WHERE columname='timeliness_rate';
UPDATE ld_wx_evaluate_field set zh_label='解决率' WHERE columname='resolution_rate';
UPDATE ld_wx_evaluate_field set zh_label='服务体验' WHERE columname='service_experience';
UPDATE ld_wx_evaluate_field set zh_label='自定义项1' WHERE columname='custom1';
UPDATE ld_wx_evaluate_field set zh_label='自定义项2' WHERE columname='custom2';
UPDATE ld_wx_evaluate_field set zh_label='自定义项3' WHERE columname='custom3';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMFIRMTODELETE','确定要删除吗','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMFIRMTODELETE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMFIRMTODELETE','Are you sure you want to delete it','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='COMFIRMTODELETE' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2023-07-12

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

UPDATE ld_version SET old_version='V8.6.0.0',current_version='V8.6.0.0',remark='V8.6.0.0-20230712',wx_version='V8.6.0.0';
delimiter;