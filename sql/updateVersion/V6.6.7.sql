INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPORTDATATITLE','导出数据','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORTDATATITLE');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPORTDATATITLE','Export data','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPORTDATATITLE');
delimiter;
-- 2017-03-23

update ld_select_related_field set relatedstring='{"main":[{"table_column_value":"accountid","fieldname":"account_id"},{"table_column_value":"contactid","fieldname":"contact_id"}]}'
where module='OutboundOrder' and selectmodule='SalesOrder';

update ld_tranlabel set fieldlabel='评论信息' where trantable='ld_blocks' and Relateid=38 and languagetype='zh';

update ld_salesorder INNER JOIN(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) AS invoicetotal
FROM
	(
		SELECT
			b.invoice_num,
			a.invoicedate,
			a.currency_id,
			c.entitytypeid,
			round(
				c.tax_amount / ifnull(a.conversion_rate, 1),
				2
			) tax_amount
		FROM
			ld_invoice a
		LEFT JOIN ld_invoicecf b ON a.invoiceid = b.invoiceid
		LEFT JOIN (
			SELECT
				ld_inventoryproductrel.id,
				ld_inventoryproductrel.entitytypeid,
				sum(
					ifnull(
						tmp_adjustment.adjustment,
						0
					)
				) AS tax_amount
			FROM
				(
					SELECT DISTINCT
						b.id,
						b.entitytypeid,
						a.adjustment,
						min(lineitem_id) AS minlineitem_id
					FROM
						ld_invoice a
					LEFT JOIN ld_inventoryproductrel b ON a.invoiceid = b.id
					GROUP BY
						a.invoiceid
				) AS tmp_adjustment
			INNER JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = tmp_adjustment.id
			AND minlineitem_id = lineitem_id
			WHERE
				ifnull(adjustment, 0) <> 0
			GROUP BY
				entitytypeid
			UNION ALL
				SELECT
					id,
					entitytypeid,
					tax_amount
				FROM
					ld_inventoryproductrel
		) c ON a.invoiceid = c.id
		WHERE
			a.deleted = 0
		AND ifnull(a.invoicestatus, '') != '已作废'
		
		ORDER BY
			a.invoicedate DESC,
			createdtime DESC
	) c GROUP BY c.entitytypeid ) as sales_entity on sales_entity.entitytypeid=ld_salesorder.salesorderid
set have_invoicetotal=if(ld_salesorder.currency_id=1,invoicetotal,invoicetotal*ifNULL(ld_salesorder.conversion_rate,1));
delimiter;


update ld_servicecontracts INNER JOIN(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) AS invoicetotal
FROM
	(
		SELECT
			b.invoice_num,
			a.invoicedate,
			a.currency_id,
			c.entitytypeid,
			round(
				c.tax_amount / ifnull(a.conversion_rate, 1),
				2
			) tax_amount
		FROM
			ld_invoice a
		LEFT JOIN ld_invoicecf b ON a.invoiceid = b.invoiceid
		LEFT JOIN (
			SELECT
				ld_inventoryproductrel.id,
				ld_inventoryproductrel.entitytypeid,
				sum(
					ifnull(
						tmp_adjustment.adjustment,
						0
					)
				) AS tax_amount
			FROM
				(
					SELECT DISTINCT
						b.id,
						b.entitytypeid,
						a.adjustment,
						min(lineitem_id) AS minlineitem_id
					FROM
						ld_invoice a
					LEFT JOIN ld_inventoryproductrel b ON a.invoiceid = b.id
					GROUP BY
						a.invoiceid
				) AS tmp_adjustment
			INNER JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = tmp_adjustment.id
			AND minlineitem_id = lineitem_id
			WHERE
				ifnull(adjustment, 0) <> 0
			GROUP BY
				entitytypeid
			UNION ALL
				SELECT
					id,
					entitytypeid,
					tax_amount
				FROM
					ld_inventoryproductrel
		) c ON a.invoiceid = c.id
		WHERE
			a.deleted = 0
		AND ifnull(a.invoicestatus, '') != '已作废'
		
		ORDER BY
			a.invoicedate DESC,
			createdtime DESC
	) c GROUP BY c.entitytypeid ) as sales_entity on sales_entity.entitytypeid=ld_servicecontracts.servicecontractsid
set have_invoicetotal=if(ld_servicecontracts.currency_id=1,invoicetotal,invoicetotal*ifNULL(ld_servicecontracts.conversion_rate,1));
delimiter;


update ld_outboundorder INNER JOIN(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) AS invoicetotal
FROM
	(
		SELECT
			b.invoice_num,
			a.invoicedate,
			a.currency_id,
			c.entitytypeid,
			round(
				c.tax_amount / ifnull(a.conversion_rate, 1),
				2
			) tax_amount
		FROM
			ld_invoice a
		LEFT JOIN ld_invoicecf b ON a.invoiceid = b.invoiceid
		LEFT JOIN (
			SELECT
				ld_inventoryproductrel.id,
				ld_inventoryproductrel.entitytypeid,
				sum(
					ifnull(
						tmp_adjustment.adjustment,
						0
					)
				) AS tax_amount
			FROM
				(
					SELECT DISTINCT
						b.id,
						b.entitytypeid,
						a.adjustment,
						min(lineitem_id) AS minlineitem_id
					FROM
						ld_invoice a
					LEFT JOIN ld_inventoryproductrel b ON a.invoiceid = b.id
					GROUP BY
						a.invoiceid
				) AS tmp_adjustment
			INNER JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = tmp_adjustment.id
			AND minlineitem_id = lineitem_id
			WHERE
				ifnull(adjustment, 0) <> 0
			GROUP BY
				entitytypeid
			UNION ALL
				SELECT
					id,
					entitytypeid,
					tax_amount
				FROM
					ld_inventoryproductrel
		) c ON a.invoiceid = c.id
		WHERE
			a.deleted = 0
		AND ifnull(a.invoicestatus, '') != '已作废'
		
		ORDER BY
			a.invoicedate DESC,
			createdtime DESC
	) c GROUP BY c.entitytypeid ) as sales_entity on sales_entity.entitytypeid=ld_outboundorder.out_id
set have_invoicetotal=if(ld_outboundorder.currency_id=1,invoicetotal,invoicetotal*ifNULL(ld_outboundorder.conversion_rate,1));
delimiter;
-- 2017-03-30

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

update ld_version set old_version='V6.6.7',current_version='V6.6.7',remark='V6.6.5SP2-20170330';
delimiter;