DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
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
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;


DROP PROCEDURE IF EXISTS `Del_TableIndex`;
delimiter ||
CREATE  PROCEDURE `Del_TableIndex`(
	tmp_tablename varchar(100),
	tmp_indexname varchar(100)
)
BEGIN  

	IF EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND index_name=tmp_indexname) THEN  
		SET @execsql=CONCAT(' DROP INDEX ',tmp_indexname,' ON ',tmp_tablename);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;


UPDATE ld_producttoolfield SET defaultcolumn=3 WHERE columnname IN ('discount_percent','discount_amount');
UPDATE ld_producttoolfield SET defaultcolumn=2 WHERE columnname IN ('tax_amount');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment' LIMIT 1);
UPDATE ld_parenttabrel SET parenttabid=1 WHERE tabid=@tabid AND parenttabid=6 AND NOT EXISTS (SELECT 1 FROM ld_attachmentsforbills);

UPDATE ld_tab SET presence=0 WHERE presence=5 AND `name` IN ('Emails','EmailListtmp','MassEmails') AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
UPDATE ld_field SET approve_demand=2 WHERE approve_demand=0 AND uitype IN (1,5,15,7,56,86);
-- 2019-04-19

DELETE FROM ld_field WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` IN ('CashBill','SendCashBill')) AND columnname='checker';
-- 2019-04-23

-- CREATE TABLE IF NOT EXISTS backup_db_triggers SELECT * FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA=DATABASE();

DROP PROCEDURE IF EXISTS `fenbiao_createtables_20190318`;
delimiter ||
CREATE PROCEDURE `fenbiao_createtables_20190318`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_exectag1 INT(4) DEFAULT 0; 
	DECLARE tmp_exectag2 INT(4) DEFAULT 0; 
	DECLARE tmp_querysql1 TEXT DEFAULT '';
	DECLARE tmp_querysql2 TEXT DEFAULT ''; 
	DECLARE tmp_querysql3 TEXT DEFAULT ''; 
	DECLARE tmp_querysql4 TEXT DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.tabid,
				CASE
					WHEN NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',LOWER(a.modulename),'detail')) THEN '1'
					ELSE 0
				END AS exectag1,
				CASE
					WHEN NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',LOWER(a.modulename),'detailscf')) THEN '1'
					ELSE 0
				END AS exectag2,
				CONCAT('CREATE TABLE IF NOT EXISTS ld_',LOWER(a.modulename),'detail LIKE ld_inventoryproductrel') AS querysql1,
				CONCAT('CREATE TABLE IF NOT EXISTS ld_',LOWER(a.modulename),'detailscf LIKE ld_inventoryproductrelscf') AS querysql2,
				CONCAT('INSERT INTO ld_',LOWER(a.modulename),'detail SELECT b.* FROM ', a.tablename, ' a',
						' INNER JOIN ld_inventoryproductrel b ON a.',a.tablekey,'=b.id') AS querysql3,
				CONCAT('INSERT INTO ld_',LOWER(a.modulename),'detailscf SELECT c.* FROM ', a.tablename, ' a',
						' INNER JOIN ld_inventoryproductrel b ON a.',a.tablekey,'=b.id'
						' INNER JOIN ld_inventoryproductrelscf c ON  b.lineitem_id=c.lineitem_id') AS querysql4
			FROM (
				SELECT DISTINCT
					a.tabid,
					a.name AS modulename,
					b.tablename,
					CASE
						WHEN tablename='ld_quotes' THEN 'quoteid'
						WHEN tablename='ld_quoteschange' THEN 'quoteschangeid'
						WHEN tablename='ld_salesorder' THEN 'salesorderid'
						WHEN tablename='ld_servicecontracts' THEN 'servicecontractsid'
						WHEN tablename='ld_purchaseinquiryorder' THEN 'purchaseinquiryorderid'
						WHEN tablename='ld_purchaseorder' THEN 'purchaseorderid'
						WHEN tablename='ld_invoice' THEN 'invoiceid'
						WHEN tablename='ld_purchaseinvoice' THEN 'purchaseinvoiceid'
						WHEN tablename='ld_salesback' THEN 'salesbackid'
						WHEN tablename='ld_cashback' THEN 'cashbackid'
						WHEN tablename='ld_purchaseback' THEN 'purchasebackid'
						WHEN tablename='ld_purchasecashback' THEN 'purchasecashbackid'
						WHEN tablename='ld_outboundorder' THEN 'out_id'
						WHEN tablename='ld_stock' THEN 'stock_id'
						WHEN tablename='ld_warehousetransfer' THEN 'warehousetransferid'
						WHEN tablename='ld_productbom' THEN 'productbomid'
						WHEN tablename='ld_checks' THEN 'id'
					END AS tablekey
				FROM ld_tab a
				INNER JOIN ld_field b ON a.tabid=b.tabid AND b.columnname='smownerid'
				WHERE a.name IN (
					'Quotes',
					'QuotesChange',
					'SalesOrder',
					'ServiceContracts',
					'PurchaseInquiryOrder',
					'PurchaseOrder',
					'Invoice',
					'PurchaseInvoice',
					'SalesBack',
					'CashBack',
					'PurchaseBack',
					'PurchaseCashBack',
					'OutboundOrder',
					'Stock',
					'WareHouseTransfer',
					'Checks',
				'Productbom'
					)
				ORDER BY FIELD(a.name,
				'Quotes',
				'QuotesChange',
				'SalesOrder',
				'ServiceContracts',
				'PurchaseInquiryOrder',
				'PurchaseOrder',
				'Invoice',
				'PurchaseInvoice',
				'SalesBack',
				'CashBack',
				'PurchaseBack',
				'PurchaseCashBack',
				'OutboundOrder',
				'Stock',
				'WareHouseTransfer',
				'Checks',
			'Productbom')	
			) a;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_exectag1,tmp_exectag2,tmp_querysql1,tmp_querysql2,tmp_querysql3,tmp_querysql4;
	WHILE(tmp_tabid IS NOT NULL) DO

		IF tmp_exectag1=1 THEN
			SET @query_sql1=tmp_querysql1;
			PREPARE smtp1 FROM @query_sql1;
			EXECUTE smtp1;
			DEALLOCATE PREPARE smtp1;

			SET @query_sql3=tmp_querysql3;
			PREPARE smtp3 FROM @query_sql3;
			EXECUTE smtp3;
			DEALLOCATE PREPARE smtp3;
		END IF;

		IF tmp_exectag2=1 THEN
			SET @query_sql2=tmp_querysql2;
			PREPARE smtp2 FROM @query_sql2;
			EXECUTE smtp2;
			DEALLOCATE PREPARE smtp2;
			
			SET @query_sql4=tmp_querysql4;
			PREPARE smtp4 FROM @query_sql4;		
			EXECUTE smtp4;
			DEALLOCATE PREPARE smtp4;
		END IF;

		FETCH MYCUSOR INTO tmp_tabid,tmp_exectag1,tmp_exectag2,tmp_querysql1,tmp_querysql2,tmp_querysql3,tmp_querysql4;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;


CALL fenbiao_createtables_20190318();
DROP PROCEDURE IF EXISTS `fenbiao_createtables_20190318`;
delimiter;

UPDATE ld_tab a
INNER JOIN ld_producttoolfield b ON a.tabid=b.tabid
SET b.tablename=CONCAT('ld_',LOWER(a.name),'detail')
WHERE a.name IN (
	'Quotes',
	'QuotesChange',
	'SalesOrder',
	'ServiceContracts',
	'PurchaseInquiryOrder',
	'PurchaseOrder',
	'Invoice',
	'PurchaseInvoice',
	'SalesBack',
	'CashBack',
	'PurchaseBack',
	'PurchaseCashBack',
	'OutboundOrder',
	'Stock',
	'WareHouseTransfer',
	'Checks',
	'Productbom'
	)
AND b.tablename='ld_inventoryproductrel';

UPDATE ld_tab a
INNER JOIN ld_producttoolfield b ON a.tabid=b.tabid
SET b.tablename=CONCAT('ld_',LOWER(a.name),'detailscf')
WHERE a.name IN (
	'Quotes',
	'QuotesChange',
	'SalesOrder',
	'ServiceContracts',
	'PurchaseInquiryOrder',
	'PurchaseOrder',
	'Invoice',
	'PurchaseInvoice',
	'SalesBack',
	'CashBack',
	'PurchaseBack',
	'PurchaseCashBack',
	'OutboundOrder',
	'Stock',
	'WareHouseTransfer',
	'Checks',
	'Productbom'
	)
AND b.tablename='ld_inventoryproductrelscf';

UPDATE ld_tab a
INNER JOIN ld_tabwithproductview b ON a.tabid=b.tabid
SET b.`columns`=REPLACE(b.`columns`,'ld_inventoryproductrel',CONCAT('ld_',LOWER(a.name),'detail'))
WHERE a.name IN (
	'Quotes',
	'QuotesChange',
	'SalesOrder',
	'ServiceContracts',
	'PurchaseInquiryOrder',
	'PurchaseOrder',
	'Invoice',
	'PurchaseInvoice',
	'SalesBack',
	'CashBack',
	'PurchaseBack',
	'PurchaseCashBack',
	'OutboundOrder',
	'Stock',
	'WareHouseTransfer',
	'Checks',
	'Productbom'
	)
AND b.`columns` LIKE '%ld_inventoryproductrel%';

UPDATE ld_tab a
INNER JOIN ld_customview b ON a.`name`=b.entitytype
INNER JOIN ld_cvadvfilter c ON b.cvid=c.cvid
SET c.columnname=REPLACE(c.columnname,'ld_inventoryproductrel',CONCAT('ld_',LOWER(a.name),'detail'))
WHERE a.name IN (
	'Quotes',
	'QuotesChange',
	'SalesOrder',
	'ServiceContracts',
	'PurchaseInquiryOrder',
	'PurchaseOrder',
	'Invoice',
	'PurchaseInvoice',
	'SalesBack',
	'CashBack',
	'PurchaseBack',
	'PurchaseCashBack',
	'OutboundOrder',
	'Stock',
	'WareHouseTransfer',
	'Checks',
	'Productbom'
	)
AND c.columnname LIKE '%ld_inventoryproductrel%';

UPDATE ld_tab a
INNER JOIN ld_automaticreminds b ON a.`tabid`=b.tabid
INNER JOIN ld_remindcvadvfilter c ON b.id=c.cvid
SET c.columnname=REPLACE(c.columnname,'ld_inventoryproductrel',CONCAT('ld_',LOWER(a.name),'detail'))
WHERE a.name IN (
	'Quotes',
	'QuotesChange',
	'SalesOrder',
	'ServiceContracts',
	'PurchaseInquiryOrder',
	'PurchaseOrder',
	'Invoice',
	'PurchaseInvoice',
	'SalesBack',
	'CashBack',
	'PurchaseBack',
	'PurchaseCashBack',
	'OutboundOrder',
	'Stock',
	'WareHouseTransfer',
	'Checks',
	'Productbom'
	)
AND c.columnname LIKE '%ld_inventoryproductrel%';
delimiter;

update ld_relatedlists inner join ld_tab on ld_tab.tabid=ld_relatedlists.related_tabid
set related_coltable=CONCAT(lower(ld_tab.name),'detail.entitytypeid')
where related_coltable = 'inventoryproductrel.entitytypeid';
delimiter;


UPDATE ld_tab a
INNER JOIN ld_approve b ON a.`tabid`=b.tabid
INNER JOIN ld_approvestep  on ld_approvestep.approveid=b.id
INNER JOIN ld_approvestepadvfilter c ON b.id=c.stepid
SET c.columnname=REPLACE(c.columnname,'ld_inventoryproductrel',CONCAT('ld_',LOWER(a.name),'detail'))
WHERE a.name IN (
	'Quotes',
	'QuotesChange',
	'SalesOrder',
	'ServiceContracts',
	'PurchaseInquiryOrder',
	'PurchaseOrder',
	'Invoice',
	'PurchaseInvoice',
	'SalesBack',
	'CashBack',
	'PurchaseBack',
	'PurchaseCashBack',
	'OutboundOrder',
	'Stock',
	'WareHouseTransfer',
	'Checks',
	'Productbom'
	)
AND c.columnname LIKE '%ld_inventoryproductrel%';
delimiter;

DROP PROCEDURE IF EXISTS `fenbiao_backup_tables_20190423`;
delimiter ||
CREATE PROCEDURE `fenbiao_backup_tables_20190423`(
)
BEGIN


	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_inventoryproductrelscf') THEN
		CREATE TABLE IF NOT EXISTS backup_table_inventoryproductrelscf LIKE ld_inventoryproductrelscf;
		INSERT INTO backup_table_inventoryproductrelscf SELECT * FROM ld_inventoryproductrelscf;
		DROP TABLE IF EXISTS ld_inventoryproductrelscf;
	END IF;


	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_inventoryproductrel') THEN
		CREATE TABLE IF NOT EXISTS backup_table_inventoryproductrel LIKE ld_inventoryproductrel;
		INSERT INTO backup_table_inventoryproductrel SELECT * FROM ld_inventoryproductrel;
		DROP TABLE IF EXISTS ld_inventoryproductrel;
	END IF;


END ||
delimiter;

CALL fenbiao_backup_tables_20190423();
DROP PROCEDURE IF EXISTS `fenbiao_backup_tables_20190423`;
delimiter;
-- 2019-04-23


CALL addtableIndex('ld_outboundorderdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_outboundorderdetail','entitytype','entitytype');
CALL addtableIndex('ld_outboundorderdetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_stockdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_stockdetail','entitytype','entitytype');
CALL addtableIndex('ld_stockdetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_salesbackdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_salesbackdetail','entitytype','entitytype');
CALL addtableIndex('ld_salesbackdetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_cashbackdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_cashbackdetail','entitytype','entitytype');
CALL addtableIndex('ld_cashbackdetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_purchasebackdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_purchasebackdetail','entitytype','entitytype');
CALL addtableIndex('ld_purchasebackdetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_purchasecashbackdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_purchasecashbackdetail','entitytype','entitytype');
CALL addtableIndex('ld_purchasecashbackdetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_invoicedetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_invoicedetail','entitytype','entitytype');
CALL addtableIndex('ld_invoicedetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_purchaseinvoicedetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_purchaseinvoicedetail','entitytype','entitytype');
CALL addtableIndex('ld_purchaseinvoicedetail','entitytypeid','entitytypeid');

CALL addtableIndex('ld_purchaseinquiryorderdetail','parent_lineitem_id','parent_lineitem_id');
CALL addtableIndex('ld_purchaseinquiryorderdetail','entitytype','entitytype');
CALL addtableIndex('ld_purchaseinquiryorderdetail','entitytypeid','entitytypeid');

DROP PROCEDURE IF EXISTS `CopyModuleField`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule`;

ALTER TABLE ld_tabshare MODIFY COLUMN createdtime datetime NULL DEFAULT CURRENT_TIMESTAMP;

update ld_tabwithproductview set `columns`=replace(`columns`,'ld_inventoryproductrel','ld_servicecontractsdetail')
where tabid in(select tabid from ld_tab where name='ServiceCharge');
update ld_tabwithproductview set `columns`=replace(`columns`,'ld_inventoryproductrelscf','ld_servicecontractsdetailscf')
where tabid in(select tabid from ld_tab where name='ServiceCharge');
delimiter;

update ld_desk set fieldlabel = '设置系统模块的开启或关闭，可用Ctrl+F快速查找' where labelbol = 'VTLIB_LBL_MODULE_MANAGER_DESCRIPTION' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Setting system module being open or closed, quick search with Ctrl+F' where labelbol = 'VTLIB_LBL_MODULE_MANAGER_DESCRIPTION' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '订单小程序下载' where labelbol = 'CUSTOMERSELFSERVICECONFIGHOME08ORDER' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Order applet download' where labelbol = 'CUSTOMERSELFSERVICECONFIGHOME08ORDER' and languagetype = 'en' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '服务小程序下载' where labelbol = 'CUSTOMERSELFSERVICECONFIGHOME08' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Service applet download' where labelbol = 'CUSTOMERSELFSERVICECONFIGHOME08' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
-- 2019-04-24

CALl AddColumn('ld_outboundorderdetailscf','sf3','VARCHAR','100',NULL);
CALl AddColumn('ld_outboundorderdetailscf','sf4','VARCHAR','100',NULL);
ALTER TABLE ld_outboundorderdetailscf MODIFY COLUMN sf4 VARCHAR(100) DEFAULT NULL AFTER sf3;

CALL AddColumn('ld_salesorder','triggercount','INT',19,NULL);
ALTER TABLE ld_salesorder MODIFY COLUMN triggercount INT(19) DEFAULT 0 AFTER salesorderid;


select max(actionid) into @maxactionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select @maxactionid+1,'reduction','REDUCTION',0 from DUAL 
where not exists(select 1 from ld_actionmapping where actionname='reduction');
delimiter;
select tabid into @tabid from ld_tab where name='RecycleBin';
select actionid into @operation from ld_actionmapping where actionname='reduction';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,1 from dual where 
not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);

select actionid into @operation from ld_actionmapping where actionname='Delete';
insert into ld_profileallpermission(tabid,operation,sequence)
select @tabid,@operation,2 from dual where 
not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@operation);
delimiter;


select tabid into @tabid from ld_tab where name='RecycleBin';
select actionid into @operation from ld_actionmapping where actionname='reduction';
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select profileid,@tabid,@operation,0,1  from 
(select profileid from ld_profile2standardpermissions
where tabid=@tabid and permissions=0 and operation=3 group by profileid) as tmpb 
where not EXISTS(select 1 from ld_profile2standardpermissions where tabid=@tabid and operation=@operation)
and profileid>0;
delimiter;

select tabid into @tabid from ld_tab where name='RecycleBin';
select actionid into @operation from ld_actionmapping where actionname='Delete';
insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select profileid,@tabid,@operation,0,2  from 
(select profileid from ld_profile2standardpermissions
where tabid=@tabid and permissions=0 and operation=3 group by profileid) as tmpb 
where not EXISTS(select 1 from ld_profile2standardpermissions where tabid=@tabid and operation=@operation)
and profileid>0;
delimiter;

update ld_relatedlists
INNER JOIN ld_tab on ld_tab.tabid=ld_relatedlists.related_tabid
 set related_coltable=replace(related_coltable,'inventoryproductrel',concat(lower(ld_tab.name),'detail'));
delimiter;


update ld_desk set fieldlabel='Order applet' where labelbol='SELFSERVICEQRCODEORDER' and languagetype='en';
update ld_desk set fieldlabel='订单小程序' where labelbol='SELFSERVICEQRCODEORDER' and languagetype='zh';

update ld_desk set fieldlabel='Service applet' where labelbol='SELFSERVICEQRCODE' and languagetype='en';
update ld_desk set fieldlabel='服务小程序' where labelbol='SELFSERVICEQRCODE' and languagetype='zh';

update ld_desk set fieldlabel='Here is the CRM applet code, service applet and order applet code please go to the member management details interface to view and download'
where labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and languagetype='en';
update ld_desk set fieldlabel='这里是CRM小程序的小程序码，服务小程序和订单小程序的小程序码请到成员管理详情界面查看和下载'
where labelbol='CANBESCANNEDDIRECTLYWITHWECHAT' and languagetype='zh';
delimiter;

update ld_tranlabel set fieldlabel='设置客户查重和选择客户/供应商列表每页显示记录的条数'
where  languagetype='zh' and trantable='ld_systems_deploy' and  relateid=151;
delimiter;

update ld_tranlabel set fieldlabel='{$ServiceContracts.ServiceContracts}中产品服务到期前N天提醒{$ServiceContracts.ServiceContracts}{$ServiceContracts.ServiceContractsassigned_user_id}（为0表示当天提醒，为空表示不提醒）'
where relateid=24 and tabid=24 and languagetype='zh'  and trantable='ld_systems_deploy';
delimiter;


select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'haveoutboundamount','yes','ld_servicecontracts',1,72,'haveoutboundamount','已发货金额',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'haveoutboundamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'haveoutboundamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已发货金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Amount of shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_servicecontracts','haveoutboundamount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'balanceoutboundamount','yes','ld_servicecontracts',1,72,'balanceoutboundamount','未发货金额',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'balanceoutboundamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'balanceoutboundamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'未发货金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'amount of non-shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_servicecontracts','balanceoutboundamount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'lastoutbounddate','yes','ld_servicecontracts',1,5,'lastoutbounddate','最新发货日期',0,1,NULL,NULL,@sequence+1,@blockid,2,'D~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'lastoutbounddate');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'lastoutbounddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'最新发货日期' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'latest date of shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_servicecontracts','lastoutbounddate','date','',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'haveoutboundcount','yes','ld_servicecontracts',1,7,'haveoutboundcount','已发货数量',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'haveoutboundcount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'haveoutboundcount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已发货数量' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Quantity of shipped shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_servicecontracts','haveoutboundcount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'balanceoutboundcount','yes','ld_servicecontracts',1,7,'balanceoutboundcount','未发货数量',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'balanceoutboundcount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'balanceoutboundcount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'未发货数量' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'quantity of non-shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_servicecontracts','balanceoutboundcount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'haveoutboundamount','yes','ld_salesorder',1,72,'haveoutboundamount','已发货金额',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'haveoutboundamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'haveoutboundamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已发货金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Amount of shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','haveoutboundamount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'balanceoutboundamount','yes','ld_salesorder',1,72,'balanceoutboundamount','未发货金额',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'balanceoutboundamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'balanceoutboundamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'未发货金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'amount of non-shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','balanceoutboundamount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'lastoutbounddate','yes','ld_salesorder',1,5,'lastoutbounddate','最新发货日期',0,1,NULL,NULL,@sequence+1,@blockid,2,'D~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'lastoutbounddate');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'lastoutbounddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'最新发货日期' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'latest date of shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','lastoutbounddate','date','',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'haveoutboundcount','yes','ld_salesorder',1,7,'haveoutboundcount','已发货数量',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'haveoutboundcount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'haveoutboundcount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已发货数量' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Quantity of shipped shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','haveoutboundcount','decimal','25,2',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'balanceoutboundcount','yes','ld_salesorder',1,7,'balanceoutboundcount','未发货数量',0,1,NULL,NULL,@sequence+1,@blockid,2,'N~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,2,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'balanceoutboundcount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'balanceoutboundcount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'未发货数量' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'quantity of non-shipment' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','balanceoutboundcount','decimal','25,2',NULL);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_cvcolumnlistsort`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_cvcolumnlistsort`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN
		DELETE FROM ld_cvcolumnlistsort WHERE cvid IN (SELECT cvid FROM ld_customview WHERE viewname='All' AND entitytype NOT IN ('Webmails','MassSMS'));
		INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
		SELECT 
			a.cvid,
			CONCAT(c.tablename,':modifiedtime:modifiedtime:',a.entitytype,'_DT~O:fieldlabel'),
			'desc'
		FROM ld_customview a
		INNER JOIN ld_tab b ON a.entitytype=b.`name`
		LEFT JOIN ld_field c ON c.tabid=b.tabid AND c.columnname='modifiedtime'
		WHERE a.viewname='All' 
			AND a.entitytype NOT IN ('Webmails','MassSMS')
		ORDER BY a.cvid;

	END IF;

end ||
delimiter;

CALL ldcrm_reset_cvcolumnlistsort();
DROP PROCEDURE IF EXISTS `ldcrm_reset_cvcolumnlistsort`;
-- 2019-04-26

DROP PROCEDURE IF EXISTS `ldcrm_add_choosebillfield`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_choosebillfield`(
	tmp_modulename VARCHAR(100),
	tmp_uitype INT(19)
)
BEGIN

	-- 73 	单选客户
	-- 57 	单选联系人
	-- 76 	单选销售机会
	-- 82		单选项目
	-- 240 	单选服务单
	-- 241 	单选项目任务
	-- 59		单选产品
	-- 81   单选供应商
	-- 96		单选供应商联系人
	-- 80   单选合同订单
	-- 243  单选服务合同
	-- 78   单选报价单

	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename) AND tmp_uitype IN (73,57,76,82,240,241,59,81,96,80,243,78) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
		SET @trantable='ld_field';
		
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @columnname=(SELECT columnname FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1);
		SET @fieldname=(SELECT fieldname FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1);
		SET @zh=(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_field' AND languagetype='zh' AND Relateid=(SELECT fieldid FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1) LIMIT 1); 
		SET @en=(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_field' AND languagetype='en' AND Relateid=(SELECT fieldid FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1) LIMIT 1);  
		
		SET @uitype=tmp_uitype; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @presence=2;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@blockid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND uitype=@uitype LIMIT 1);
		SET @cnt=(SELECT COUNT(1) FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid);
		DELETE FROM ld_tranlabel WHERE trantable=@trantable AND tabid = @tabid AND relateid=@fieldid AND @cnt>2; 
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@fieldid,@zh FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid AND languagetype='zh');

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@fieldid,@en FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid AND languagetype='en');

		CALl AddColumn(@tablename,@columnname,'INT','19',NULL);
		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

		IF tmp_uitype=73 THEN
			SET @choosetabid=6;
		ELSEIF tmp_uitype=57 THEN
			SET @choosetabid=4;
		ELSEIF tmp_uitype=76 THEN
			SET @choosetabid=2;
		ELSEIF tmp_uitype=82 THEN
			SET @choosetabid=48;
		ELSEIF tmp_uitype=240 THEN
			SET @choosetabid=13;
		ELSEIF tmp_uitype=241 THEN
			SET @choosetabid=47;
		ELSEIF tmp_uitype=59 THEN
			SET @choosetabid=14;
		ELSEIF tmp_uitype=81 THEN
			SET @choosetabid=18;
		ELSEIF tmp_uitype=96 THEN
			SET @choosetabid=(SELECT tabid FROM ld_tab WHERE name='VendorContact' LIMIT 1);
		ELSEIF tmp_uitype=80 THEN
			SET @choosetabid=22;
		ELSEIF tmp_uitype=243 THEN
			SET @choosetabid=37;
		ELSEIF tmp_uitype=78 THEN
			SET @choosetabid=20;
		END IF;

		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@choosetabid);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@choosetabid,@tabid,LOWER(CONCAT('get_',tmp_modulename)),@seq+1,tmp_modulename,1,'add',LOWER(CONCAT(tmp_modulename,'.',@columnname)),'datacategory_sql' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@choosetabid AND related_tabid=@tabid);
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
	END IF;
end ||
delimiter;

select tabid into @tabid from ld_tab where name='project';
update ld_relatedlists set actions='add', type='lessionplan_datacategory_sql',related_coltable='lessionplan.projectid'
 where name='get_projectservicecontracts' and tabid=48;
delimiter;
select tabid into @tabid from ld_tab where name='project';
update ld_relatedlists set related_coltable='lessionplan.project' where tabid=48 and name='get_lessionplan';
delimiter;
select tabid into @tabid from ld_tab where name='project';
update ld_relatedlists set related_coltable='lessionplanorg.otherid',type='projectaccount_datacategory_sql' where tabid=48 and name='get_projectaccounts';
delimiter;
-- 2019-04-28

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid INT(19),
    tmp_reltab VARCHAR(100),
	tmp_related_to INT(19)
    
)
BEGIN
	
	SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
	INSERT INTO ld_crmentity(crmid,setype)
	SELECT @max_remindid+1,'Reminds';		

	UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
	
	INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
	SELECT @max_remindid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;

	

end ||
delimiter;

update ld_systems_deploy set description = '设置客户、服务收费管理和供应商是否显示工商查询功能' where deploy_type = 152;
delimiter;

update ld_systems_deploy set description = '设置客户、服务收费管理和供应商是否显示自动匹配的工商查询客户列表' where deploy_type = 159;
delimiter;

update ld_tranlabel set fieldlabel = '设置{$Accounts.Accounts}、{$ServiceCharge.ServiceCharge}和{$Vendors.Vendors}是否显示工商查询功能'
where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 152 and Relateid = 152;
update ld_tranlabel set fieldlabel = 'Whether charging management of Accounts 、 Service Charge and Vendor shows business inquiry function'
where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 152 and Relateid = 152;
delimiter;

update ld_tranlabel set fieldlabel = '设置{$Accounts.Accounts}、{$ServiceCharge.ServiceCharge}和{$Vendors.Vendors}是否显示自动匹配的工商查询客户列表'
where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 159 and Relateid = 159;
update ld_tranlabel set fieldlabel = 'Set up Accounts 、Service Charge management and Vendor to show automatically matched business query customer or Vendor list'
where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 159 and Relateid = 159;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterthename1','Please enter the name of vendor name!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='pleaseenterthename1' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterthename1','请输入供应商名称！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='pleaseenterthename1' and labeltype='jspop');
delimiter;


select tabid into @tabid from ld_tab where name='Calendar';
select blockid into @blockid from ld_appparenttab where parenttab_label='Accounts';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid='-1';
set @i = @sequence;
update ld_appparenttabrel set sequence=sequence+1 where sequence > @sequence;
insert into ld_appparenttabrel(blockid,tabid,sequence)
  select @blockid,@tabid,@sequence+1 from dual
  where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
update ld_appparenttabrel set sequence=(@i:=@i+1) where sequence > @sequence and blockid=@blockid;
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Calendar',1,1,'ld_activity:subject:subject:Calendar_fieldlabel:V',2
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Calendar' and columnname LIKE 'ld_activity:subject:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Calendar',2,1,'ld_activity:date_start:date_start:Calendar_fieldlabel:V'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Calendar' and columnname LIKE 'ld_activity:date_start:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Calendar',3,1,'ld_activity:due_date:due_date:Calendar_fieldlabel:V'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Calendar' and columnname LIKE 'ld_activity:due_date:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Calendar',4,1,'ld_activity:smownerid:assigned_user_id:Calendar_fieldlabel:V'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Calendar' and columnname LIKE 'ld_activity:smownerid:%');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','SENDEMAILREMINDERTIME','邮件通知时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SENDEMAILREMINDERTIME' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','SENDEMAILREMINDERTIME','Email notification time','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='SENDEMAILREMINDERTIME' and languagetype='en');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','POPMESSAGENOTICETIME','消息通知时间','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='POPMESSAGENOTICETIME' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','POPMESSAGENOTICETIME','Message notification time','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='POPMESSAGENOTICETIME' and languagetype='en');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CANOTEMPTYGTH','不能为空！','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CANOTEMPTYGTH' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CANOTEMPTYGTH','can not be empty!','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CANOTEMPTYGTH' and languagetype='en' and Labeltype='fixedstr');
delimiter;
-- 2019-05-07

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

UPDATE ld_version SET old_version='V7.7.4',current_version='V7.7.4',remark='V7.7.4-20190507',wx_version='V7.7.3';
delimiter;