DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
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
BEGIN
	
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

drop PROCEDURE  if EXISTS delete_wrong_signin_relatedinfo;
delimiter ||
create PROCEDURE delete_wrong_signin_relatedinfo
(
)
BEGIN
	declare var_sourcelist_fieldid int(19);
  declare var_signaddress_fieldid int(19);
	declare var_entityaddress_fieldid int(19);
	declare var_sign_tabid int(19);
	
	set var_sign_tabid = (SELECT tabid from ld_tab where `name` = 'Singin');
	set var_sourcelist_fieldid = (SELECT fieldid from ld_field where tabid = var_sign_tabid and columnname = 'source_list');
	set var_signaddress_fieldid = (SELECT fieldid from ld_field where tabid = var_sign_tabid and columnname = 'address');
	set var_entityaddress_fieldid = (SELECT fieldid from ld_field where tabid = var_sign_tabid and columnname = 'entityaddress');
	IF EXISTS(SELECT 1 from ld_related_field where trigger_fieldid = var_sourcelist_fieldid and effect_fieldid = var_signaddress_fieldid) 
		and EXISTS(SELECT 1 from ld_related_field where trigger_fieldid = var_sourcelist_fieldid and effect_fieldid = var_entityaddress_fieldid) THEN
			DELETE from ld_related_field where trigger_fieldid = var_sourcelist_fieldid and effect_fieldid = var_signaddress_fieldid;
	END IF;
end ||
delimiter;

call delete_wrong_signin_relatedinfo();
drop PROCEDURE  if EXISTS delete_wrong_signin_relatedinfo;
delimiter;


drop PROCEDURE  if EXISTS `reset_homestufdetail_dateviewrange`;
delimiter ||
create PROCEDURE reset_homestufdetail_dateviewrange
(
)
BEGIN
    select count(1) into @counts from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER';
    if @counts<=0 then
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewAccounts') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_contactdetails:lastcontactdate:lastcontactdate:Contacts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_contactdetails:smownerid:assigned_user_id:Contacts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewContacts')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSalesOrderCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewServiceContractsCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSalesOrderAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewServiceContractsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractCount') and compute_columns like 'ld_salesorder.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractCount') and compute_columns like 'ld_servicecontracts.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractAmount') and compute_columns like 'ld_salesorder.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractAmount') and compute_columns like 'ld_servicecontracts.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewInvoiceAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewOutboundOrderAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewCashBillAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPotentialsCount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPotentialsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='AdvancePotentialsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_singin:createdtime:createdtime:Singin_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_singin:smownerid:assigned_user_id:Singin_fieldlabel:V' else `viewrange` end),compute_columns='ld_singin.smownerid',compute_module='Singin' WHERE (`stufflabel`='NewSignCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_leads:createdtime:createdtime:Leads_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_leads:smownerid:assigned_user_id:Leads_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewLeadsCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewHelpDeskCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewCashBillCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_outboundorder:outdate:outdate:OutboundOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewOutboundOrderCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewInvoiceCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPurchaseOrderCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPurchaseOrderAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewSalesOrderReceipts')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewServiceContractsReceipts') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_quotes:createdtime:createdtime:Quotes_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_quotes:smownerid:assigned_user_id:Quotes_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewQuotesCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_quotes:createdtime:createdtime:Quotes_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_quotes:smownerid:assigned_user_id:Quotes_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewQuotesAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='NewPaymentPlanCashBillAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='LeadUgradeToCustomerCount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_expense:expensedate:expensedate:Expense_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_expense:smownerid:assigned_user_id:Expense_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='ExpensesAmount')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_commission:createdtime:createdtime:Commission_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_commission:smcreatorid:smcreatorid:Commission_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='CommissionsAmount') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SalesorderBalanceReceivable') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='ServiceContractBalanceReceivable')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractBalanceReceivable') and compute_columns like 'ld_salesorder.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='SignContractBalanceReceivable') and compute_columns like 'ld_servicecontracts.%' and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_fieldlabel:D' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='PurchaseOrderPayBalance')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;
        UPDATE ld_homestuffdetail SET `daterange`=(case when `daterange` is null then 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT' else `daterange` end), `viewrange`=(case when `viewrange` is null then 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V' else `viewrange` end) WHERE (`stufflabel`='LeadUgradeToPotentials') and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;

        UPDATE ld_homestuffdetail SET `viewrange`=(case when `viewrange` is null then 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V' else `viewrange` end),
                              `daterange`=(case when `daterange` is null then 'ld_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:DT' else `daterange` end)
        WHERE (`stufflabel`='NewContactRecords')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;

        UPDATE ld_homestuffdetail SET `viewrange`=(case when `viewrange` is null then 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V'else `viewrange` end),
                                      `daterange`=(case when `daterange` is null then 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT' else `daterange` end)
        WHERE (`stufflabel`='NewServiceChargeNums')  and (ifnull(`daterange`,'')='' or ifnull(`viewrange`,'')='') LIMIT 1;

END IF;
end ||
delimiter;

call reset_homestufdetail_dateviewrange();
drop PROCEDURE  if EXISTS reset_homestufdetail_dateviewrange;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDCUSTOMDRAGONTIGER','新增自定义龙虎榜','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDCUSTOMDRAGONTIGER','Add a custom dragon and tiger list','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDCUSTOMDRAGONTIGER' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2023-08-10

update ld_field set  associatedfields=1 where uitype=301;
delimiter;

call AddColumn('ld_users', 'chanjet_id', 'VARCHAR', 50, null);
delimiter;

update ld_field set bigtype = 'moduleno' where uitype=4 and ifnull(bigtype,'') = '';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OneYearLater','一年后','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OneYearLater' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OneYearLater','1 year later','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OneYearLater' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OneYearAgo','一年前','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OneYearAgo' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OneYearAgo','1 year ago','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OneYearAgo' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_tab set printtab = 1 where ld_tab.`name` = 'ReportAnalysis';
SELECT tabid INTO @tmp_tabid from ld_tab where `name` = 'ReportAnalysis';
SELECT actionid INTO @tmp_actionid from ld_actionmapping where `actionname` = 'Print';
delete from ld_profileallpermission where operation = @tmp_actionid and tabid = @tmp_tabid;
delimiter;

SET @labelbol = 'TARGETCOMPLETIONRATE';
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule)
select '101',@labelbol,'chart','SalesGoal' from dual
where not exists(select 1 from ld_stuff where stuffid='101' and stufftitle='TARGETCOMPLETIONRATE' and stufftype='chart');
delimiter;

SET @labelbol = 'TARGETCOMPLETIONRATE';
select wx_sequence into @wx_sequence from ld_dashboard_app where `name`='complationRateSixMonth';
update ld_dashboard_app set wx_sequence=wx_sequence+2 where wx_sequence>@wx_sequence;

insert into ld_dashboard_app(`name`,labelbol,modulenames,wx_sequence,image,presence,wx_presence,home_presence,home_sequence)
select 'TargetCompletionRate',@labelbol,'SalesGoal',@wx_sequence+1,'dashboard_4',0,1,'',0 from dual  
where not exists(select 1 from ld_dashboard_app where `name`='TargetCompletionRate');
delimiter;

SET @labelbol = 'TARGETCOMPLETIONRATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'目标完成率','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Target Completion Rate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_salestarget_basic','showtype','varchar','30','board');
delimiter;

SET @labelbol = 'INCOMPLETEVALUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未完成值','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Incomplete Value','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPLETIONRATE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'完成率','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Completion Rate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'ISSHOWBOARD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否在看板显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Displayed on the homeboard','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ISSHOWBOARDHELP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'在“最近6个月目标完成情况”和“目标完成率”中显示','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Displayed in the \'Last 6 Months Goal Completion Status\' and\' Goal Completion Rate \'','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_expensebudget SET budget_indicators =(
	CASE
		WHEN budget_indicators = 'ContractVolumeamount' THEN 'contractamount'
		WHEN budget_indicators = 'Invoicedamount' THEN 'invoiceamount'
		WHEN budget_indicators = 'Outboundorderamount' THEN 'Outboundorderamount'
		WHEN budget_indicators = 'Paymentamount' THEN 'paymentamount'
	END)
WHERE expensebudget_type = 'salesGoalBudget' AND budget_indicators IN ('ContractVolumeamount','Invoicedamount','Outboundorderamount','Paymentamount');
delimiter;

UPDATE ld_tranlabel set fieldlabel = "设置移动端客户、服务收费管理单据详情页签上方是否显示联系人区块" 
WHERE languagetype = 'zh' and trantable = "ld_systems_deploy" and fieldlabel = "设置移动端客户/服务收费管理单据详情页签上方是否显示联系人区块";

UPDATE ld_tranlabel set fieldlabel = "Set whether the contact block is displayed above the mobile accounts、service charge document details tab" 
WHERE languagetype = 'en' and trantable = "ld_systems_deploy" and fieldlabel = "Set whether the contact block is displayed above the mobile accounts/service charge document details tab";
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SelectMultiBill','关联选择单据（多选）','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SelectMultiBill' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SelectMultiBill','Associated Selection Document (Multiple Selection)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SelectMultiBill' and Labeltype='fixedstr');
delimiter;

UPDATE ld_relatedlists SET actions='select,import' where tabid = (select tabid from ld_tab where `name`='PriceBooks') and `name`='get_pricebook_products' and actions='import';
delimiter;

CALl AddColumn('ld_stuff','datarangmodule','VARCHAR','200',NULL);
update ld_stuff set datarangmodule = '' where stufftitle = 'COMPLATIONRATESIXMONTH';
delimiter;

update ld_homestuffdetail inner join (
    select ld_tab.`name` as tabname,tmp.compute_columns,tmp.compute_module,tmp.stufflabel from ld_tab inner join (
    select  substring_index(compute_columns,'.',1) as tablename,compute_columns,compute_module,stufflabel
    from ld_homestuffdetail
    where ifnull(compute_module,'')='' and stuffid=35
    ) as tmp on tmp.tablename=ld_tab.main_tablename group by stufflabel
    )tmp on tmp.stufflabel=ld_homestuffdetail.stufflabel set ld_homestuffdetail.compute_module=tmp.tabname
where ifnull(ld_homestuffdetail.compute_module,'')='' and ld_homestuffdetail.stuffid=35;
delimiter;

DELETE from ld_settings_field where name = 'wxselfbuiltapp_setting' AND NOT EXISTS (SELECT 1 FROM ld_crmentity where crmid>2);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELFSHOPQRCODE','商城小程序','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELFSHOPQRCODE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELFSHOPQRCODE',"Mall applet",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELFSHOPQRCODE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','businessblue','商务蓝','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='businessblue' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','businessblue','Business blue','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='businessblue' and Labeltype='fixedstr' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','simplewhite','简约白','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='simplewhite' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','simplewhite','Simple white','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='simplewhite' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_homestuffdetail set
	advance_demand='[null,{"groupid":"1","columnname":"ld_account:kis_no:kis_no:Accounts_线索升级状态:V","comparator":"e","value":"from_leads","columncondition":""}]',
	advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='LeadUgradeToCustomerCount';

update ld_homestuffdetail set
	advance_demand='[null,{"groupid":"1","columnname":"ld_potential:kis_no:kis_no:Potentials_线索升级状态:V","comparator":"e","value":"from_leads","columncondition":""}]',
	advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='LeadUgradeToPotentials';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','accounthasnotallocated','该{$Accounts.Accounts}未分配公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='accounthasnotallocated' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','accounthasnotallocated','The {$Accounts.Accounts} has not been allocated high seas','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='accounthasnotallocated' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HoldiconToDrag','按住相应图标可上下或左右拖拽','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HoldiconToDrag' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HoldiconToDrag','Press and hold the corresponding icon to drag up, down, or left, right','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HoldiconToDrag' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_paymentplan INNER JOIN ld_crmentity on ld_crmentity.crmid=ld_paymentplan.entitytypeid
set ld_paymentplan.entitytype=ld_crmentity.setype where ld_paymentplan.entitytype!=ld_crmentity.setype;
delimiter;
-- 2023-08-17


call AddColumn('ld_field','disallowed_copy','varchar','20','no');
update ld_field set disallowed_copy = 'yes' where bigtype='date' or bigtype='datetime';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ContentNotAllowCopying','内容不允许复制','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ContentNotAllowCopying' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ContentNotAllowCopying','Content does not allow copying','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'ContentNotAllowCopying' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
-- 2023-08-18

UPDATE ld_organizationdetails SET logoname='logo_big_dark_0721.png' WHERE logoname='透明底.png';

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

UPDATE ld_version SET old_version='V8.6.0.4',current_version='V8.6.0.4',remark='V8.6.0.4-20230818',wx_version='V8.6.0.4';
delimiter;