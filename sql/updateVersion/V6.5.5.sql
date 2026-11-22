DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	defaultvalue INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');	
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default ',defaultvalue);
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

update ld_salesorder  LEFT JOIN
(   SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		b.invoice_num,
		a.invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_invoice a
	LEFT JOIN ld_invoicecf b ON a.invoiceid=b.invoiceid
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_invoice a
		LEFT JOIN ld_inventoryproductrel b on a.invoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.invoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.invoicestatus,'') != '已作废'
	ORDER BY a.invoicedate DESC,createdtime DESC) c  group by c.entitytypeid ) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_salesorder.salesorderid
set have_invoicetotal=if(ld_salesorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_salesorder.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;

update ld_servicecontracts  LEFT JOIN
(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		b.invoice_num,
		a.invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_invoice a
	LEFT JOIN ld_invoicecf b ON a.invoiceid=b.invoiceid
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_invoice a
		LEFT JOIN ld_inventoryproductrel b on a.invoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.invoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.invoicestatus,'') != '已作废'
	ORDER BY a.invoicedate DESC,createdtime DESC) c  group by c.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_servicecontracts.servicecontractsid
set have_invoicetotal=if(ld_servicecontracts.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_servicecontracts.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate ,lastinvoice_no=tmp_invoiceinventory.invoice_num;

update ld_outboundorder  LEFT JOIN
(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		b.invoice_num,
		a.invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_invoice a
	LEFT JOIN ld_invoicecf b ON a.invoiceid=b.invoiceid
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_invoice a
		LEFT JOIN ld_inventoryproductrel b on a.invoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.invoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.invoicestatus,'') != '已作废'
	ORDER BY a.invoicedate DESC,createdtime DESC) c  group by c.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_outboundorder.out_id
set have_invoicetotal=if(ld_outboundorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_outboundorder.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;

update ld_purchaseorder  LEFT JOIN
(
			SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		a.purchaseinvoicenum as invoice_num,
		a.purchaseinvoicedate as invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_purchaseinvoice a
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_purchaseinvoice a
		LEFT JOIN ld_inventoryproductrel b on a.purchaseinvoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.purchaseinvoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.purchaseinvoicestatus,'') != '已作废'
	ORDER BY a.purchaseinvoicedate DESC,createdtime DESC) c
                                GROUP BY 
                                c.entitytypeid ) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_purchaseorder.purchaseorderid
set have_invoicetotal=if(ld_purchaseorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_purchaseorder.conversion_rate),
nothave_invoicetotal=total-ifnull(have_invoicetotal,0),lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;

update ld_stock  LEFT JOIN
(
		SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		a.purchaseinvoicenum as invoice_num,
		a.purchaseinvoicedate as invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_purchaseinvoice a
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_purchaseinvoice a
		LEFT JOIN ld_inventoryproductrel b on a.purchaseinvoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.purchaseinvoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.purchaseinvoicestatus,'') != '已作废'
	ORDER BY a.purchaseinvoicedate DESC,createdtime DESC) c
                                GROUP BY 
                                c.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_stock.stock_id
set have_invoicetotal=if(ld_stock.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_stock.conversion_rate),
nothave_invoicetotal=total-ifnull(have_invoicetotal,0),lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `insert_tmp_date`;
CREATE EVENT `insert_tmp_date`
ON SCHEDULE EVERY 700 DAY STARTS '2016-10-14 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

call insert_tmp_date();
delimiter;

DROP EVENT IF EXISTS `update_potential_staydays`;
CREATE EVENT `update_potential_staydays`
ON SCHEDULE EVERY 1 DAY STARTS '2016-09-01 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

update 
ld_potential a
LEFT JOIN (
	select 
		potentialid,max(lastmodified) as lastmodified
	from ld_potstagehistory 
	where stage<>sales_stage 
	GROUP BY potentialid) b on a.potentialid=b.potentialid
set a.staydays=datediff(NOW(),ifnull(b.lastmodified,a.createdtime));
delimiter;

update 
ld_potential a
LEFT JOIN (
	select 
		potentialid,max(lastmodified) as lastmodified
	from ld_potstagehistory 
	where stage<>sales_stage 
	GROUP BY potentialid) b on a.potentialid=b.potentialid
set a.staydays=datediff(NOW(),ifnull(b.lastmodified,a.createdtime));
-- 2016-11-22

DROP TRIGGER IF EXISTS `update_account_lastservicedate`;
delimiter ||
CREATE TRIGGER `update_account_lastservicedate` AFTER INSERT ON `ld_maxservicedate` FOR EACH ROW BEGIN 

IF NEW.accountid>0 THEN
	update ld_account set lastservicedate=(SELECT max(service_enddate) from ld_maxservicedate where accountid=NEW.accountid) where accountid=NEW.accountid;
END IF;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `update_account_lastservicedate`;
delimiter ||
CREATE  PROCEDURE `update_account_lastservicedate`(
)
begin

	declare tmp_accountid int default 0;

	declare cur2 CURSOR FOR select accountid from ld_account;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;
	
	open cur2;
	fetch cur2 into tmp_accountid;
	while(tmp_accountid is not null) DO
		set @service_enddate=NULL;
		select max(service_enddate) into @service_enddate from ld_maxservicedate where accountid=tmp_accountid;
		
		IF @service_enddate is not NULL THEN
			update ld_account set lastservicedate=@service_enddate where accountid=tmp_accountid;
		END IF;

		Fetch cur2 into tmp_accountid;
	end while;
	close cur2;
end ||
delimiter;

drop trigger if exists up_account_nolinkdays; 
delimiter;

drop trigger if exists up_account_nolinkdays; 
delimiter || 
CREATE TRIGGER up_account_nolinkdays 
BEFORE UPDATE ON ld_account 
FOR EACH ROW 
BEGIN 

IF new.lastcontactdate<>old.lastcontactdate THEN
	SET new.nolinkdays=datediff(CURDATE(),ifnull(new.lastcontactdate,date_format(new.createdtime,'%Y-%m-%d')));
END IF;

END || 
delimiter;
-- 2016-11-24

alter table ld_workreport_remind alter column push_to_weixin set default 2;
delimiter;

alter table ld_reminds alter column push_to_weixin set default 2;
delimiter;

update ld_desk set Fieldlabel='Records' where labelbol='RECORDNUMS' and languagetype='en';
update ld_desk set Fieldlabel='Page' where labelbol='PAGE' and languagetype='en';
update ld_desk set fieldlabel='接通' where labelbol='JIUWEIPHONEANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='无人接听' where labelbol='JIUWEIPHONENOANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='无人接听' where labelbol='JIUWEIPHONECANCEL' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='占线' where labelbol='JIUWEIPHONEBUSY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='其他' where labelbol='JIUWEIPHONEOTHER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='主叫号码' where labelbol='JIUWEICALLER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='被叫号码' where labelbol='JIUWEICALLEE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='账户已停用！' where labelbol='LBL_SMS_DELACCOUNT' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='用户名或密码有误，请重新输入！' where labelbol='LBL_SMS_USERINFO' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='保存失败！原因：{$Products.Products}[%s]{$Products.regmaturitydate}已经过期。' where labelbol='REGMATURITYDATEEXPIRED' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='保存失败！原因：该%s的%s已经过期。' where labelbol='QUALIFYMATURITYDATEEXPIRED' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='最多上传20张图片，支持类型：jpg、jpeg、gif、png、bmp、ico' where labelbol='UPLOADUPTP20PICTURES' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='当{$Accounts.Accounts}访问权为私有时: {$Potentials.Potentials}、{$HelpDesk.HelpDesk}、{$Quotes.Quotes}、{$SalesOrder.SalesOrder}、{$Invoice.Invoice} 访问权限必须设为私有' where labelbol='ACCOUNT_ACCESS_INFO' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='至少设置3个显示列字段' where labelbol='SETUPCOLUMNHEADERREMIND' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='请选择文件' where labelbol='PLEASESELECTAFILE' and languagetype='zh' and Labeltype='jspop';
update ld_desk set fieldlabel='来电' where labelbol='ANSWER' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Notification list' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='通知列表' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
-- 2016-11-29

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

update ld_version set old_version='V6.5.5' ,current_version='V6.5.5' ,remark='V6.5.5-20161129';
delimiter;