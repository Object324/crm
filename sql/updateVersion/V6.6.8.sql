insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CASHBILLNETGROSS','收款毛利','fixedstr' from dual
 where not exists(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='CASHBILLNETGROSS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CASHBILLNETGROSS','收款毛利','fixedstr' from dual
 where not exists(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='CASHBILLNETGROSS' and labeltype='fixedstr');
delimiter;

UPDATE ld_servicecontracts a
LEFT JOIN  (
	SELECT
		servicecontractsid,
		COUNT(1) AS qty
	FROM ld_troubletickets
	WHERE deleted=0
		AND approvestatus<>'已拒绝'
	GROUP BY servicecontractsid
) b ON b.servicecontractsid=a.servicecontractsid
SET a.service_units=IFNULL(b.qty,0)
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=6 AND columnname='service_units');
-- 2017-05-05

update ld_desk set fieldlabel='当前系统参数设置未出库订单不允许退货，该{$SalesOrder.SalesOrder}还未出库，不允许办理退货！' where labelbol='ORDEROUTNOALLOWRETURN' and languagetype='zh';
update ld_desk set fieldlabel='当前系统参数设置未入库订单不允许退货，该{$PurchaseOrder.PurchaseOrder}还未入库，不允许办理退货！' where labelbol='PURCHASEORDEROUTNOALLOWRETURN' and languagetype='zh';


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
delimiter;

update ld_version set old_version='V6.6.8',current_version='V6.6.8',remark='V6.6.5SP4-20170505';
delimiter;