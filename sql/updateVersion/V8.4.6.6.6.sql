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

CALl AddColumn('ld_producttoolfield','effectivecondition','TEXT','','');
CALl AddColumn('ld_tabdetailfield','effectivecondition','TEXT','','');
delimiter;

CALL AddColumn('ld_module_calledlog','phonenum','varchar','20','');
delimiter;

update ld_desk set fieldlabel = '源单类型定制' where labelbol = 'LBL_Optionalmodule_Customization' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'source single type customization' where labelbol = 'LBL_Optionalmodule_Customization' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_remind_smowner`;
delimiter ||
CREATE TRIGGER `ldcrm_remind_smowner` AFTER INSERT ON `ld_modcomments` FOR EACH ROW BEGIN

  SELECT setype INTO @reltab FROM ld_crmentity WHERE crmid=NEW.related_to;

  IF NEW.related_to>0 THEN
    SELECT
      b.fieldlabel INTO @content
    FROM ld_tab a
    LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
    WHERE a.`name`=@reltab LIMIT 1;
	
    SELECT CONCAT(last_name,'评论了您的',@content) INTO @content FROM ld_users WHERE id=NEW.smownerid LIMIT 1;

    SET @smownerid=0;
    SET @servicecasher=0;
    IF @reltab='Accounts' THEN
      SELECT smownerid INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
      SELECT servicecasher INTO @servicecasher FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='Contacts' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactdetails WHERE contactid=NEW.related_to limit 1;
    ELSEIF @reltab='ContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_contactrecords WHERE contactrecordid=NEW.related_to limit 1;
    ELSEIF @reltab='Potentials' THEN
      SELECT smownerid INTO @smownerid FROM ld_potential WHERE potentialid=NEW.related_to limit 1;
    ELSEIF @reltab='Quotes' THEN
      SELECT smownerid INTO @smownerid FROM ld_quotes WHERE quoteid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesorder WHERE salesorderid=NEW.related_to limit 1;
    ELSEIF @reltab='SalesBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_salesback WHERE salesbackid=NEW.related_to limit 1;

    ELSEIF @reltab='ServiceContracts' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicecontracts WHERE servicecontractsid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceCharge' THEN
      SELECT servicecasher INTO @smownerid FROM ld_account WHERE accountid=NEW.related_to limit 1;
    ELSEIF @reltab='HelpDesk' THEN
      SELECT smownerid INTO @smownerid FROM ld_troubletickets WHERE ticketid=NEW.related_to limit 1;
    ELSEIF @reltab='ServiceReturn' THEN
      SELECT smownerid INTO @smownerid FROM ld_servicereturn WHERE servicereturnid=NEW.related_to limit 1;

    ELSEIF @reltab='Project' THEN
      SELECT smownerid INTO @smownerid FROM ld_project WHERE projectid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectTask' THEN
      SELECT smownerid INTO @smownerid FROM ld_projecttask WHERE projecttaskid=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectMilestone' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectmilestone WHERE projectmilestoneid=NEW.related_to limit 1;
    ELSEIF @reltab='TimeSheet' THEN
      SELECT smownerid INTO @smownerid FROM ld_timesheet WHERE timesheet_id=NEW.related_to limit 1;
    ELSEIF @reltab='ProjectProgress' THEN
      SELECT smownerid INTO @smownerid FROM ld_projectprogress WHERE projectprogressid=NEW.related_to limit 1;
    ELSEIF @reltab='Rate' THEN
      SELECT smownerid INTO @smownerid FROM ld_rate WHERE rate_id=NEW.related_to limit 1;

    ELSEIF @reltab='Invoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_invoice WHERE invoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseInvoice' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseinvoice WHERE purchaseinvoiceid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashbill WHERE cashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='SendCashBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendcashbill WHERE sendcashbillid=NEW.related_to limit 1;
    ELSEIF @reltab='CashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashback WHERE cashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseCashBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchasecashback WHERE purchasecashbackid=NEW.related_to limit 1;
    ELSEIF @reltab='PaymentPlan' THEN
      SELECT smownerid INTO @smownerid FROM ld_paymentplan WHERE paymentplanid=NEW.related_to limit 1;
    ELSEIF @reltab='SendPayment' THEN
      SELECT smownerid INTO @smownerid FROM ld_sendpayment WHERE sendpaymentid=NEW.related_to limit 1;
    ELSEIF @reltab='PutCash' THEN
      SELECT smownerid INTO @smownerid FROM ld_putcash WHERE putcashid=NEW.related_to limit 1;
    ELSEIF @reltab='CashDeposit' THEN
      SELECT smownerid INTO @smownerid FROM ld_cashdeposit WHERE cashdepositid=NEW.related_to limit 1;
    ELSEIF @reltab='BankAccountSet' THEN
      SELECT smcreatorid INTO @smownerid FROM ld_bankaccountset WHERE Bankaccountsetid=NEW.related_to limit 1;

    ELSEIF @reltab='OutboundOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_outboundorder WHERE out_id=NEW.related_to limit 1;
    ELSEIF @reltab='Stock' THEN
      SELECT smownerid INTO @smownerid FROM ld_stock WHERE stock_id=NEW.related_to limit 1;
    ELSEIF @reltab='WareHouseTransfer' THEN
      SELECT smownerid INTO @smownerid FROM ld_warehousetransfer WHERE warehousetransferid=NEW.related_to limit 1;
    ELSEIF @reltab='Checks' THEN
      SELECT smownerid INTO @smownerid FROM ld_checks WHERE id=NEW.related_to limit 1;

    ELSEIF @reltab='Vendors' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendor WHERE vendorid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContact' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontacts WHERE vendorcontactsid=NEW.related_to limit 1;
    ELSEIF @reltab='VendorContactRecords' THEN
      SELECT smownerid INTO @smownerid FROM ld_vendorcontactrecords WHERE contactRecordsid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseOrder' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseorder WHERE purchaseorderid=NEW.related_to limit 1;
    ELSEIF @reltab='PurchaseBack' THEN
      SELECT smownerid INTO @smownerid FROM ld_purchaseback WHERE purchasebackid=NEW.related_to limit 1;

    ELSEIF @reltab='Campaigns' THEN
      SELECT smownerid INTO @smownerid FROM ld_campaign WHERE campaignid=NEW.related_to limit 1;

    ELSEIF @reltab='NormalApprove' THEN
      SELECT smownerid INTO @smownerid FROM ld_normalapprove WHERE normalapproveid=NEW.related_to limit 1;
    ELSEIF @reltab='AddJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='MinusJobBill' THEN
      SELECT smownerid INTO @smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.related_to limit 1;
    ELSEIF @reltab='BusinessApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_businessapply WHERE businessapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='LoanApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_loanapply WHERE loanapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='CardApply' THEN
      SELECT smownerid INTO @smownerid FROM ld_cardapply WHERE cardapplyid=NEW.related_to limit 1;
    ELSEIF @reltab='Commission' THEN
      SELECT smownerid INTO @smownerid FROM ld_commission WHERE commission_id=NEW.related_to limit 1;
    ELSEIF @reltab='Expense' THEN
      SELECT smownerid INTO @smownerid FROM ld_expense WHERE expenseid=NEW.related_to limit 1;

    ELSEIF @reltab='Products' THEN
      SELECT smownerid INTO @smownerid FROM ld_products WHERE productid=NEW.related_to limit 1;
    ELSEIF @reltab='PriceBooks' THEN
      SELECT smownerid INTO @smownerid FROM ld_pricebook WHERE pricebookid=NEW.related_to limit 1;
    ELSEIF @reltab='Documents' THEN
      SELECT smownerid INTO @smownerid FROM ld_notes WHERE notesid=NEW.related_to limit 1;
    ELSEIF @reltab='Faq' THEN
      SELECT smownerid INTO @smownerid FROM ld_faq WHERE id=NEW.related_to limit 1;
    ELSEIF @reltab='Attachment' THEN
      SELECT smownerid INTO @smownerid FROM ld_attachmentsforbills WHERE attachmentsid=NEW.related_to limit 1;
    END IF;

    IF @smownerid>0  AND @smownerid<>NEW.smownerid THEN
      CALL ldcrm_add_reminder_havetype(@content,@smownerid,@reltab,NEW.related_to,'MODULECOMMENTRemind');
    END IF;
    select presence into @presence from ld_tab where name='servicecharge';

    IF @servicecasher>0 AND @smownerid<>@servicecasher AND (@presence=0 or @presence=2) AND @servicecasher<>NEW.smownerid THEN
      CALL ldcrm_add_reminder_havetype(@content,@servicecasher,'ServiceCharge',NEW.related_to,'MODULECOMMENTRemind');
    END IF;
  END IF;

end ||
delimiter;
-- 2022-06-30


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

UPDATE ld_version SET old_version='V8.4.6.6.6',current_version='V8.4.6.6.6',remark='V8.4.6.6.6-20220630',wx_version='V8.4.6.6.6';
delimiter;