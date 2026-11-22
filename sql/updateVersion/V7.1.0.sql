UPDATE ld_tab SET presence=1 WHERE `name`='Leads';
UPDATE ld_field SET presence=1 WHERE columnname IN ('promotionalpartner','promoter') AND tabid=6;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Attachment';
UPDATE ld_field SET defaultvalue='私有' WHERE tabid=@tabid AND columnname='isenabled' AND defaultvalue='公开';
delimiter;
-- 2017-10-09

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HIDE','不显示','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HIDE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HIDE','Hide','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HIDE' and labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NONMANDATORY','非必填字段','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NONMANDATORY' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NONMANDATORY','Non mandatory','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NONMANDATORY' and labeltype='fixedstr');
delimiter;
update ld_tranlabel set fieldlabel='微信端外勤签到选择客户功能的控制方式' 
where Relateid=143 and trantable='ld_systems_deploy' and languagetype='zh';
delimiter;
update ld_tranlabel set fieldlabel="Select the customer's control mode when sign on the WeChat"
where Relateid=143 and trantable='ld_systems_deploy' and languagetype='en';
delimiter;
update ld_systems_deploy set inputvalue='[{"value":"0","text":"HIDE"},{"value":"1","text":"MANDATORYFIELDS"},{"value":"2","text":"NONMANDATORY"},{"sql":""}]' where deploy_type=143;
delimiter;
update ld_systems_deploy set presence=1 where deploy_type=144;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
select tabid into @salesorderid from ld_tab where `name` = 'SalesOrder';
select tabid into @serivcecontracts from ld_tab where `name` = 'ServiceContracts';
select tabid into @invoice from ld_tab where `name` = 'Invoice';
INSERT into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@salesorderid,0,1,0,1 from dual 
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @salesorderid);
INSERT into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@serivcecontracts,0,0,0,2 from dual 
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @serivcecontracts);
INSERT into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@invoice,0,0,0,3 from dual 
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @invoice);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
select tabid into @purchaseorderid from ld_tab where `name` = 'PurchaseOrder';
select tabid into @purchaseinvoiceid from ld_tab where `name` = 'PurchaseInvoice';
INSERT into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@purchaseorderid,0,1,0,1 from dual 
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @purchaseorderid);
INSERT into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@purchaseinvoiceid,0,0,0,2 from dual 
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @purchaseinvoiceid);
delimiter;

call AddColumn('ld_option_module','table_sequence','int','11',0);
update ld_option_module set table_sequence = 1 where tabid = (select tabid from ld_tab where `name` = 'PaymentPlan');
update ld_option_module set table_sequence = 2 where tabid = (select tabid from ld_tab where `name` = 'SendPayment');
update ld_option_module set table_sequence = 3 where tabid = (select tabid from ld_tab where `name` = 'Expense');
update ld_option_module set table_sequence = 4 where tabid = (select tabid from ld_tab where `name` = 'TimeSheet');
update ld_option_module set table_sequence = 5 where tabid = (select tabid from ld_tab where `name` = 'Invoice');
update ld_option_module set table_sequence = 6 where tabid = (select tabid from ld_tab where `name` = 'PurchaseInvoice');
update ld_option_module set table_sequence = 7 where tabid = (select tabid from ld_tab where `name` = 'CashBill');
update ld_option_module set table_sequence = 8 where tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
update ld_option_module set table_sequence = 9 where tabid = (select tabid from ld_tab where `name` = 'OutboundOrder');
update ld_option_module set table_sequence = 10 where tabid = (select tabid from ld_tab where `name` = 'Stock');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 59;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,146,'设置销售发票新增保存后是否立即创建回款计划',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 146);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',146,146,'设置{$Invoice.Invoice}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'zh' and tabid = 146 and Relateid = 146 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',146,146,'Whether to create {$PaymentPlan.PaymentPlan} immediately after creating Sales {$Invoice.Invoice}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'en' and tabid = 146 and Relateid = 146 and trantable = 'ld_systems_deploy');
select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 146;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,147,'设置销售发票关联创建回款计划时是否控制回款计划总金额等于销售发票金额',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 147);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',147,147,'设置{$Invoice.Invoice}关联创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总金额等于{$Invoice.Invoice}金额' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'zh' and tabid = 147 and Relateid = 147 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',147,147,'If the total {$PaymentPlan.PaymentPlan} must be equal to the amount of {$Invoice.Invoice} to create outstanding program in the {$Invoice.Invoice} control module' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'en' and tabid = 147 and Relateid = 147 and trantable = 'ld_systems_deploy');
SET @i=0;
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'entitytypeid' and fieldname = 'entitytypeid';
update ld_field set uitype = 202,approve_demand=2 where tabid = @tabid and columnname = 'entitytypeid' and fieldname = 'entitytypeid';
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Select Source' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realcolumns = 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期/开票日期:D',realencolumns = 'ld_salesorder:signed_data:signed_data:SalesOrder_Date of Contract/Invoice Date:D' 
where `columns` = 'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_paymentplan:salesorderid:salesorder_id:OftenUseReport_源单摘要:I',realencolumns = 'ld_paymentplan:salesorderid:salesorder_id:OftenUseReport_SourceOrder Abstract:I' 
where `columns` = 'ld_paymentplan:salesorderid:salesorder_id:OftenUseReport_salesorder:I' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_源单编号:V',realencolumns = 'ld_salesorder:salesorder_no:salesorder_no:SourceOrder No:V' 
where `columns` = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_源单合计:N',realencolumns = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_SourceOrder Total:N' 
where `columns` = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:N' and Usereportid = @usereportid;
delimiter;

call AddColumn('ld_sendpayment','entitytype','varchar','200',NULL);
update ld_sendpayment set entitytype = 'PurchaseOrder' where entitytype is NULL and Purchaseorder_id > 0;
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 147;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,148,'设置采购发票新增保存后是否立即创建付款计划',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 148);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',148,148,'设置{$PurchaseInvoice.PurchaseInvoice}新增保存后是否立即创建{$SendPayment.SendPayment}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'zh' and tabid = 148 and Relateid = 148 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',148,148,'Whether to create {$SendPayment.SendPayment} Plan immediately after creating {$PurchaseInvoice.PurchaseInvoice}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'en' and tabid = 148 and Relateid = 148 and trantable = 'ld_systems_deploy');
select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 148;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,149,'设置采购发票关联创建付款计划时是否控制付款计划总金额等于采购发票金额',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from DUAL
where not exists(select 1 from ld_systems_deploy where deploy_type = 149);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',149,149,'设置{$PurchaseInvoice.PurchaseInvoice}关联创建{$SendPayment.SendPayment}时是否控制{$SendPayment.SendPayment}总金额等于{$PurchaseInvoice.PurchaseInvoice}金额' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'zh' and tabid = 149 and Relateid = 149 and trantable = 'ld_systems_deploy');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',149,149,'If the total {$SendPayment.SendPayment} Plan must be equal to the amount of invoice to create outstanding program in the {$PurchaseInvoice.PurchaseInvoice} control module' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype= 'en' and tabid = 149 and Relateid = 149 and trantable = 'ld_systems_deploy');
SET @i=0;
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'purchaseorder_id' and fieldname = 'purchaseorder_id';
update ld_field set uitype = 202,approve_demand=2 where tabid = @tabid and columnname = 'purchaseorder_id' and fieldname = 'purchaseorder_id';
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Select Source' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realcolumns = 'ld_crmentity:smownerid:smownerid:SendPayment_负责人:V',realencolumns = 'ld_crmentity:smownerid:smownerid:SendPayment_Assigned To:V' 
where `columns` = 'ld_crmentity:smownerid:smownerid:SendPayment_smownerid:V' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期/开票日期:D',realencolumns = 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Date of Contract/Invoice Date:D' 
where `columns` = 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_源单编号:V',realencolumns = 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_SourceOrder No:V' 
where `columns` = 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_purchaseorder_no:V' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_vendor:vendorid:vendorid:SendPayment_供应商名称:V',realencolumns = 'ld_vendor:vendorid:vendorid:SendPayment_Vendor Name:V' 
where `columns` = 'ld_vendor:vendorid:vendorid:SendPayment_vendorid:V' and Usereportid = @usereportid;
update ld_usereportcolumns set realcolumns = 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_源单合计:N:V',realencolumns = 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_SourceOrder_Total:N:V' 
where `columns` = 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N' and Usereportid = @usereportid;
delimiter;
-- 2017-10-12

DROP PROCEDURE IF EXISTS `update_invoice_receivedamount_byinvoiceid`;
delimiter ||
CREATE  PROCEDURE `update_invoice_receivedamount_byinvoiceid`(
	tmp_invoiceid INT(19)
)
BEGIN

	SET @cnt1=0;
	SELECT
		count(1) INTO @cnt1
	FROM (
		SELECT IFNULL(currency_id,1) AS currency_id FROM ld_invoice WHERE invoiceid=tmp_invoiceid
		UNION
		SELECT IFNULL(currency_id,1) FROM ld_paymentplan WHERE deleted=0 AND entitytypeid=tmp_invoiceid AND actualamount>0
		UNION
		SELECT 
			IFNULL(a.currency_id,1)
		FROM ld_cashbill a
		LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
		WHERE a.deleted=0
			AND b.entitytypeid=tmp_invoiceid
			AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=83)=1 THEN a.checkoutstatus='已审核'
					ELSE 1=1
				END)
	) a;

	IF @cnt=1 THEN
		-- 没有多币种
		SET @dir_cashtotal=0;
		SET @indir_cashtotal=0;
		SELECT 
			SUM(b.amount) INTO @dir_cashtotal
		FROM ld_cashbill a
		LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
		WHERE a.deleted=0
			AND b.entitytypeid=tmp_invoiceid
			AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=83)=1 THEN a.checkoutstatus='已审核'
					ELSE 1=1
				END);

		SELECT SUM(actualamount) INTO @indir_cashtotal FROM ld_paymentplan WHERE deleted=0 AND entitytypeid=tmp_invoiceid AND actualamount>0;
		UPDATE ld_invoice SET received_amount=IFNULL(@dir_cashtotal,0)+IFNULL(@indir_cashtotal,0) WHERE invoiceid=tmp_invoiceid;
	ELSE
		-- 有多币种,计算已收时统一转换为人民币计算
		SET @dir_cashtotal=0;
		SET @indir_cashtotal=0;
		SELECT 
			SUM(b.amount/IFNULL(a.conversion_rate,1)) INTO @dir_cashtotal
		FROM ld_cashbill a
		LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
		WHERE a.deleted=0
			AND b.entitytypeid=tmp_invoiceid
			AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=83)=1 THEN a.checkoutstatus='已审核'
					ELSE 1=1
				END);

		SELECT SUM(actualamount/IFNULL(conversion_rate,1)) INTO @indir_cashtotal FROM ld_paymentplan WHERE deleted=0 AND entitytypeid=tmp_invoiceid AND actualamount>0;
		UPDATE ld_invoice SET received_amount=(IFNULL(@dir_cashtotal,0)+IFNULL(@indir_cashtotal,0))*IFNULL(conversion_rate,1) WHERE invoiceid=tmp_invoiceid;
	END IF;

end ||
delimiter;

DROP TRIGGER IF EXISTS `update_invoice_cashtotal_edit`;
delimiter ||
CREATE TRIGGER `update_invoice_cashtotal_edit` AFTER UPDATE ON `ld_paymentplan` 
FOR EACH ROW 
BEGIN 
	
	IF NEW.entitytype='Invoice' AND NEW.entitytypeid>0 THEN
		CALL update_invoice_receivedamount_byinvoiceid(NEW.entitytypeid);
	END IF;
END ||
delimiter;


DROP TRIGGER IF EXISTS `update_invoice_cashtotal_delete`;
delimiter ||
CREATE TRIGGER `update_invoice_cashtotal_delete` AFTER DELETE ON `ld_paymentplan` 
FOR EACH ROW 
BEGIN 
	
	IF OLD.entitytype='Invoice' AND OLD.entitytypeid>0 THEN
		CALL update_invoice_receivedamount_byinvoiceid(OLD.entitytypeid);
	END IF;
END ||
delimiter;

DROP PROCEDURE IF EXISTS `update_purchaseinvoice_receivedamount_bypurchaseinvoiceid`;
delimiter ||
CREATE  PROCEDURE `update_purchaseinvoice_receivedamount_bypurchaseinvoiceid`(
	tmp_invoiceid INT(19)
)
BEGIN

	SET @cnt1=0;
	SELECT
		count(1) INTO @cnt1
	FROM (
		SELECT IFNULL(currency_id,1) AS currency_id FROM ld_purchaseinvoice WHERE purchaseinvoiceid=tmp_invoiceid
		UNION
		SELECT IFNULL(currency_id,1) FROM ld_sendpayment WHERE deleted=0 AND Purchaseorder_id=tmp_invoiceid AND IFNULL(actualamount,0)>0
		UNION
		SELECT 
			IFNULL(a.currency_id,1)
		FROM ld_sendcashbill a
		LEFT JOIN ld_sendcashbill2payment b ON a.sendcashbillid=b.sendcashbillid
		WHERE a.deleted=0
			AND b.entitytypeid=tmp_invoiceid
			AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=84)=1 THEN a.checkoutstatus='已审核'
					ELSE 1=1
				END)
	) a;

	IF @cnt=1 THEN
		-- 没有多币种
		SET @dir_cashtotal=0;
		SET @indir_cashtotal=0;
		SELECT 
			SUM(b.amount) INTO @dir_cashtotal
		FROM ld_sendcashbill a
		LEFT JOIN ld_sendcashbill2payment b ON a.sendcashbillid=b.sendcashbillid
		WHERE a.deleted=0
			AND b.entitytypeid=tmp_invoiceid
			AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=84)=1 THEN a.checkoutstatus='已审核'
					ELSE 1=1
				END);

		SELECT SUM(actualamount) INTO @indir_cashtotal FROM ld_sendpayment WHERE deleted=0 AND Purchaseorder_id=tmp_invoiceid AND IFNULL(actualamount,0)>0;
		UPDATE ld_purchaseinvoice SET pay_amount=IFNULL(@dir_cashtotal,0)+IFNULL(@indir_cashtotal,0) WHERE purchaseinvoiceid=tmp_invoiceid;
	ELSE
		-- 有多币种,计算已收时统一转换为人民币计算
		SET @dir_cashtotal=0;
		SET @indir_cashtotal=0;
		SELECT 
			SUM(b.amount/IFNULL(a.conversion_rate,1)) INTO @dir_cashtotal
		FROM ld_cashbill a
		LEFT JOIN ld_cashbill2paymentplan b ON a.cashbillid=b.CashBillID
		WHERE a.deleted=0
			AND b.entitytypeid=tmp_invoiceid
			AND (
				CASE
					WHEN (SELECT deploy_value FROM ld_systems_deploy WHERE deploy_type=83)=1 THEN a.checkoutstatus='已审核'
					ELSE 1=1
				END);

		SELECT SUM(actualamount/IFNULL(conversion_rate,1)) INTO @indir_cashtotal FROM ld_sendpayment WHERE deleted=0 AND Purchaseorder_id=tmp_invoiceid AND IFNULL(actualamount,0)>0;
		UPDATE ld_purchaseinvoice SET pay_amount=(IFNULL(@dir_cashtotal,0)+IFNULL(@indir_cashtotal,0))*IFNULL(conversion_rate,1) WHERE purchaseinvoiceid=tmp_invoiceid;
	END IF;

end ||
delimiter;

DROP TRIGGER IF EXISTS `update_purchaseinvoice_cashtotal_edit`;
delimiter ||
CREATE TRIGGER `update_purchaseinvoice_cashtotal_edit` AFTER UPDATE ON `ld_sendpayment` 
FOR EACH ROW 
BEGIN 
	
	IF NEW.entitytype='PurchaseInvoice' AND NEW.Purchaseorder_id>0 THEN
		CALL update_purchaseinvoice_receivedamount_bypurchaseinvoiceid(NEW.Purchaseorder_id);
	END IF;
END ||
delimiter;


DROP TRIGGER IF EXISTS `update_purchaseinvoice_cashtotal_delete`;
delimiter ||
CREATE TRIGGER `update_purchaseinvoice_cashtotal_delete` AFTER DELETE ON `ld_sendpayment` 
FOR EACH ROW 
BEGIN 
	
	IF OLD.entitytype='PurchaseInvoice' AND OLD.Purchaseorder_id>0 THEN
		CALL update_purchaseinvoice_receivedamount_bypurchaseinvoiceid(OLD.Purchaseorder_id);
	END IF;
END ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ORDER1CREATED','该单据已创建','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ORDER1CREATED' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ORDER1CREATED','The order has been created ','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ORDER1CREATED' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select tabid into @paymentplan_id from ld_tab where `name` = 'PaymentPlan';
select max(relation_id) into @relation_id from ld_relatedlists;
select tabid into @cashbill_id from ld_tab where `name` = 'CashBill';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and related_tabid = @cashbill_id and `name` = 'get_cashbill';
update ld_relatedlists set sequence = sequence + 100 where tabid = @tabid and sequence > @sequence;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,mobile_presence,type,related_coltable,wx_presence)
select @relation_id+1,@tabid,@paymentplan_id,'get_paymentplan',@sequence+1,'PaymentPlan',0,1,'datacategory_sql','paymentplan.entitytypeid',1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @paymentplan_id);
SET @i=0;
UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select tabid into @sendpayment_id from ld_tab where `name` = 'SendPayment';
select max(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,mobile_presence,type,related_coltable,wx_presence)
select @relation_id+1,@tabid,@sendpayment_id,'get_SendPayment',@sequence+1,'SendPayment',0,1,'datacategory_sql','sendpayment.purchaseorder_id',1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @sendpayment_id);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','theorderisnotapproved','该单据未审批，不允许创建相关联的单据!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'theorderisnotapproved' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','theorderisnotapproved','The order is not approved and is not allowed to create relevant order!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'theorderisnotapproved' and labeltype = 'fixedstr');
delimiter;

update ld_option_module set table_sequence = 11 where tabid = (select tabid from ld_tab where `name` = 'Commission');
delimiter;
-- 2017-10-13

select presence into @presence from ld_tab where `name` = 'Leads';
update ld_field set presence = @presence where columnname in ('promotionalpartner','promoter');
delimiter;

select max(relation_id) into @relation_id from ld_relatedlists;
select presence into @presence from ld_quickactions where related_tabid=-3;
select max(sequence) into @sequence from ld_relatedlists where tabid = 4;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,wx_presence)
select @relation_id+1,4,-8,'get_ContactsHierarchy',@sequence+1,'ContactsHierarchy',@presence,'',1,1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = 4 and related_tabid = -8);
delimiter;

DROP PROCEDURE IF EXISTS `transfer_AccountHierarchy`;
delimiter ||
CREATE  PROCEDURE `transfer_AccountHierarchy`(
)
begin

	declare tmp_tabid varchar(100) default '';
	declare tmp_presence varchar(100) default '';
	declare cur1 cursor for select distinct tabid,presence from ld_quickactions where related_tabid=-4;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid,tmp_presence;
	while(tmp_tabid is not null) DO
		select max(relation_id) into @relation_id from ld_relatedlists;
		select max(sequence) into @sequence from ld_relatedlists where tabid = tmp_tabid;
		insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,wx_presence)
		select @relation_id+1,tmp_tabid,-9,'get_AccountHierarchy',@sequence+1,'AccountHierarchy',tmp_presence,'',1,1 from DUAL
		where not exists(select 1 from ld_relatedlists where tabid = tmp_tabid and related_tabid = -9);
		Fetch cur1 into tmp_tabid,tmp_presence;
	end while;

	close cur1;

end ||
delimiter;
call transfer_AccountHierarchy();
delimiter;

update ld_quickactions set tabid=9 where tabid=16;
delimiter;

DROP PROCEDURE IF EXISTS `transer_history`;
delimiter ||
CREATE  PROCEDURE `transer_history`(
)
begin

	declare tmp_tabid varchar(100) default '';
	declare tmp_presence varchar(100) default '';
	declare cur1 cursor for select distinct tabid,presence from ld_quickactions where related_tabid=-1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid,tmp_presence;
	while(tmp_tabid is not null) DO
		select max(relation_id) into @relation_id from ld_relatedlists;
		select max(sequence) into @sequence from ld_relatedlists where tabid = tmp_tabid;
		insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,wx_presence)
		select @relation_id+1,tmp_tabid,-7,'get_viewhistory',@sequence+1,'ViewHistory',tmp_presence,'',1,1 from DUAL
		where not exists(select 1 from ld_relatedlists where tabid = tmp_tabid and related_tabid = -7);
		Fetch cur1 into tmp_tabid,tmp_presence;
	end while;

	close cur1;

end ||
delimiter;
call transer_history();
delimiter;

DROP PROCEDURE IF EXISTS `transfer_changeview`;
delimiter ||
CREATE  PROCEDURE `transfer_changeview`(
)
begin

	declare tmp_tabid varchar(100) default '';
	declare tmp_presence varchar(100) default '';
	declare cur1 cursor for select distinct tabid,presence from ld_quickactions where related_tabid=-10;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid,tmp_presence;
	while(tmp_tabid is not null) DO
		select max(relation_id) into @relation_id from ld_relatedlists;
		select max(sequence) into @sequence from ld_relatedlists where tabid = tmp_tabid;
		insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,wx_presence)
		select @relation_id+1,tmp_tabid,-10,'get_changeview',@sequence+1,'ChangeView',tmp_presence,'',1,1 from DUAL
		where not exists(select 1 from ld_relatedlists where tabid = tmp_tabid and related_tabid = -10);
		Fetch cur1 into tmp_tabid,tmp_presence;
	end while;

	close cur1;

end ||
delimiter;
call transfer_changeview();
delimiter;

select tabid into @tabid from ld_tab where name='Invoice';
select tabid into @relate_tabid from ld_tab where name='PaymentPlan';
update ld_relatedlists set wx_presence=presence,wx_sequence=sequence where tabid=@tabid and related_tabid=@relate_tabid;
delimiter;

delete from ld_quickactions where related_tabid in(-1,-3,-4,-10);
delimiter;

DROP PROCEDURE IF EXISTS `transfer_print`;
delimiter ||
CREATE  PROCEDURE `transfer_print`(
)
begin

	declare tmp_tabid varchar(100) default '';
	declare tmp_presence varchar(100) default '';
	declare cur1 cursor for select distinct tabid,presence from ld_quickactions where related_tabid=-5;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	OPEN cur1;
	Fetch cur1 into tmp_tabid,tmp_presence;
	while(tmp_tabid is not null) DO
		select max(relation_id) into @relation_id from ld_relatedlists;
		select max(sequence) into @sequence from ld_relatedlists where tabid = tmp_tabid;
		insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,wx_presence)
		select @relation_id+1,tmp_tabid,-11,'get_print',@sequence+1,'Print',tmp_presence,'',1,1 from DUAL
		where not exists(select 1 from ld_relatedlists where tabid = tmp_tabid and related_tabid = -11);
		Fetch cur1 into tmp_tabid,tmp_presence;
	end while;

	close cur1;

end ||
delimiter;

call transfer_print();
delimiter;

delete from ld_quickactions where related_tabid = -5;
delimiter;

DROP PROCEDURE IF EXISTS `transfer_print`;
DROP PROCEDURE IF EXISTS `transer_history`;
DROP PROCEDURE IF EXISTS `transfer_AccountHierarchy`;
DROP PROCEDURE IF EXISTS `transfer_changeview`;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Leads';
DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield in ('bill_country','bill_state');

SELECT max(id) INTO @id FROM ld_picklist_dependency;
INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
SELECT (@id:=@id+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency WHERE tabid=6 AND sourcefield in ('bill_country','bill_state');
delimiter;

DELETE FROM ld_bill_city WHERE bill_city='--无--';
DELETE FROM ld_bill_state WHERE bill_state='--无--';
DELETE FROM ld_bill_country WHERE bill_country='--无--';


DELETE FROM ld_picklist_dependency WHERE sourcevalue='--无--' AND sourcefield in ('bill_country','bill_state');
UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,'"--无--",','') WHERE targetvalues like '["--无--",%' AND sourcefield in ('bill_country','bill_state');
UPDATE ld_picklist_dependency SET targetvalues=REPLACE(targetvalues,'["--\u65e0--",','') WHERE targetvalues like '["--\u65e0--",%' AND sourcefield in ('bill_country','bill_state');

UPDATE ld_field SET defaultvalue=NULL WHERE defaultvalue='--无--' AND columnname='bill_city'; 

UPDATE ld_account SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_account SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_account SET bill_country='' WHERE bill_country='--无--';


UPDATE ld_vendor SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_vendor SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_vendor SET bill_country='' WHERE bill_country='--无--';

UPDATE ld_potential SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_potential SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_potential SET bill_country='' WHERE bill_country='--无--';

UPDATE ld_quotesbillads SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_quotesbillads SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_quotesbillads SET bill_country='' WHERE bill_country='--无--';

UPDATE ld_pobillads SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_pobillads SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_pobillads SET bill_country='' WHERE bill_country='--无--';

UPDATE ld_invoicebillads SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_invoicebillads SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_invoicebillads SET bill_country='' WHERE bill_country='--无--';

UPDATE ld_leads SET bill_city='' WHERE bill_city='--无--';
UPDATE ld_leads SET bill_state='' WHERE bill_state='--无--';
UPDATE ld_leads SET bill_country='' WHERE bill_country='--无--';
-- 2017-10-18

UPDATE ld_field SET presence=0 WHERE tabid=6 AND columnname='product_id'
	AND NOT EXISTS (SELECT 1 FROM ld_account);
UPDATE ld_tranlabel SET fieldlabel='Attachment' WHERE fieldlabel='附件' AND languagetype='en' AND trantable='ld_field';
-- 2017-10-19

UPDATE ld_field SET presence=1 WHERE columnname IN ('currentapprover','modifiedtime')
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);

UPDATE ld_field SET presence=1 WHERE columnname ='approveby' AND tabid<>29
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ServiceCharge';
UPDATE ld_field SET presence=1 WHERE tabid IN (6,@tabid) 
	AND columnname IN ('fax','parentid','registeredcapital','accountsize','annualincome','email1','firstname')
	AND NOT EXISTS (SELECT 1 FROM ld_account);

UPDATE ld_field SET presence=1 WHERE tabid=4
	AND columnname IN ('parentid','firstname','homephone','faxx','mailingstate','mailingcity','mailingcountry','mailingzip','mailingstreet')
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ContactRecords';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid
	AND columnname IN ('potentialid','salesorderid','product_id','projecttaskid','projectid','subject')
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);

UPDATE ld_field SET presence=1 WHERE tabid=22
	AND columnname IN ('parentid','potentialid','subject')
	AND NOT EXISTS (SELECT 1 FROM ld_salesorder);

UPDATE ld_producttoolfield SET presence=1 WHERE columnname IN ('listprice','list_amount','tax2','tax_total')
	AND NOT EXISTS (SELECT 1 FROM ld_salesorder);

DELETE FROM ld_minusjobtype WHERE minusjobtype='特殊报钟' AND NOT EXISTS (SELECT 1 FROM ld_minusjobbill);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Commission';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('potentialid','bankaccountsetid','currency_id')
	AND NOT EXISTS(SELECT 1 FROM ld_commission);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Expense';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('numcount')
	AND NOT EXISTS(SELECT 1 FROM ld_expense);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Invoice';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('subject')
	AND NOT EXISTS(SELECT 1 FROM ld_invoice);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='PurchaseInvoice';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname IN ('subject')
	AND NOT EXISTS(SELECT 1 FROM ld_purchaseinvoice);

ALTER TABLE ld_commission ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_commission ALTER COLUMN conversion_rate SET DEFAULT '1.000000';
ALTER TABLE ld_commission ALTER COLUMN currency_symbol SET DEFAULT '¥';

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Expense';
UPDATE ld_tabdetailfield SET presence=1 WHERE tabid=@tabid AND columnname in ('currency_id','conversion_rate','money')
	AND NOT EXISTS (SELECT 1 FROM ld_expense);
UPDATE ld_tabdetailfield SET edit_permission=0 WHERE tabid=@tabid AND columnname in ('rmb_total')
	AND NOT EXISTS (SELECT 1 FROM ld_expense);

SELECT tabdetailfieldid INTO @tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='rmb_total';
UPDATE ld_tabdetailfield_formula SET formulastring='a$1' WHERE tabdetailfieldid=@tabdetailfieldid
	AND NOT EXISTS (SELECT 1 FROM ld_expense);

ALTER TABLE ld_expense ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_expense ALTER COLUMN conversion_rate SET DEFAULT '1.000000';
ALTER TABLE ld_expense ALTER COLUMN currency_symbol SET DEFAULT '¥';

SELECT tabdetailfieldid INTO @relateid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='rmb_total';
UPDATE ld_tranlabel SET fieldlabel='报销金额' WHERE tabid=@tabid AND Relateid=@relateid AND languagetype='zh'
	AND EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='money' AND presence=1);
UPDATE ld_tranlabel SET fieldlabel='Amount' WHERE tabid=@tabid AND Relateid=@relateid  AND languagetype='en'
	AND EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='money' AND presence=1);

SELECT tabdetailfieldid INTO @relateid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='rmb_total';
UPDATE ld_tranlabel SET fieldlabel='人民币金额' WHERE tabid=@tabid AND Relateid=@relateid  AND languagetype='zh'
	AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='money' AND presence=1);
UPDATE ld_tranlabel SET fieldlabel='Amount(RMB)' WHERE tabid=@tabid AND Relateid=@relateid AND languagetype='en'
	AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='money' AND presence=1);
delimiter;

UPDATE ld_field SET presence=1 WHERE tabid=2 AND columnname='currency_id'
	AND NOT EXISTS (SELECT 1 FROM ld_potential);
ALTER TABLE ld_potential ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_potential ALTER COLUMN conversion_rate SET DEFAULT '1.000000';
ALTER TABLE ld_potential ALTER COLUMN currency_symbol SET DEFAULT '¥';

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='CashBill';
UPDATE ld_field SET presence=1 WHERE tabid=@tabid AND columnname='currency_id'
    AND NOT EXISTS (SELECT 1 FROM ld_cashbill);
ALTER TABLE ld_cashbill ALTER COLUMN currency_id SET DEFAULT 1;
ALTER TABLE ld_cashbill ALTER COLUMN conversion_rate SET DEFAULT '1.000000';
ALTER TABLE ld_cashbill ALTER COLUMN currency_symbol SET DEFAULT '¥';

update ld_desk set fieldlabel = '{$OutboundOrder.OutboundOrder}产品累计出库数量超过源单产品可出库数量' 
where labelbol = 'THETOTALOUTBOUNDQUANTITY' and languagetype = 'zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'The {$OutboundOrder.OutboundOrder} total number of outbound goods exceeds the quantity of the source single product' 
where labelbol = 'THETOTALOUTBOUNDQUANTITY' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select tabid into @related_tabid from ld_tab where `name` = 'ServiceReturn';
update ld_relatedlists set actions = 'add' where tabid = @tabid and related_tabid = @related_tabid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
select tabid into @related_tabid from ld_tab where `name` = 'ServiceReturn';
update ld_relatedlists set actions = 'add' where tabid = @tabid and related_tabid = @related_tabid;
delimiter;

update ld_desk set fieldlabel = '{$Stock.Stock}产品累计入库数量超过源单产品可入库数量' 
where labelbol = 'THETOTALSTOCKQUANTITY' and languagetype = 'zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'The {$Stock.Stock} total number of stock goods exceeds the quantity of the source single product' 
where labelbol = 'THETOTALSTOCKQUANTITY' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

update ld_tranlabel INNER JOIN(
	select blockid,tabid from ld_blocks where blocklabel = 'LBI_ATTACHMENT_FILE'
) as tp on tp.blockid = ld_tranlabel.Relateid and tp.tabid = ld_tranlabel.tabid 
set fieldlabel = 'Attachment Infos' where trantable = 'ld_blocks' and languagetype = 'en';
delimiter;

select max(sequence) into @sequence from ld_appparenttab;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '移动办公',0,0,'yes','Office' from DUAL
where not exists(select 1 from ld_appparenttab where blockname='移动办公');
select blockid into @blockid from ld_appparenttab where parenttab_label='Office';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-1,1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-1);
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-2,2 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-2);
delimiter; 

select sequence into @sequence from ld_appparenttab where parenttab_label='Sales';
update ld_appparenttab set sequence=sequence+2 where sequence>@sequence;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '应用',0,@sequence+1,'yes','Apply' from DUAL
where not exists(select 1 from ld_appparenttab where blockname='应用');
select blockid into @blockid from ld_appparenttab where parenttab_label='Apply';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-3,1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-3);
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-4,2 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-4);
delimiter; 

select max(sequence) into @sequence from ld_appparenttab;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '基础设置',0,@sequence+1,'yes','BaseSetting' from DUAL
where not exists(select 1 from ld_appparenttab where blockname='基础设置');
select blockid into @blockid from ld_appparenttab where parenttab_label='BaseSetting';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-5,1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-5);
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-6,2 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-6);
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,-7,3 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=-7);
delimiter; 

set @i=0;
update ld_appparenttab set sequence=(@i:=@i+1) order by sequence;
delimiter; 
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OUTSIDESIGN','外勤签到','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OUTSIDESIGN' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OUTSIDESIGN','Outside Sign','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OUTSIDESIGN' and labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DASHBOARD','仪表盘','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DASHBOARD' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DASHBOARD','Dashboard','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DASHBOARD' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MENU','菜单','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MENU' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MENU','Menu ','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MENU' and labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPORTINGDATA','正在导出数据请不要关闭或刷新浏览器','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORTINGDATA');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPORTINGDATA','Exporting data please do not refresh or close the browser','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPORTINGDATA');
delimiter;
-- 2017-10-20

select blockid into @applyblockid from ld_appparenttab where parenttab_label='Apply';
select blockid into @officeblockid from ld_appparenttab where parenttab_label='Office';
update ld_appparenttabrel set blockid=@officeblockid,sequence=sequence+2 where blockid=@applyblockid;
delete from ld_appparenttab where blockid=@applyblockid;
delimiter;

SET @pid=0;
SELECT Picklist_valueid INTO @pid FROM ld_traffictype WHERE traffictype='其他';
UPDATE ld_traffictype SET Picklist_valueid=Picklist_valueid+1;

INSERT INTO ld_traffictype(traffictype,presence,Picklist_valueid) 
SELECT '公交车',1,@pid FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_traffictype WHERE traffictype='公交车');

SET @i=0;
UPDATE ld_traffictype SET Picklist_valueid=(@i:=@i+1) ORDER BY Picklist_valueid;
delimiter;

select blockid into @applyblockid from ld_appparenttab where parenttab_label='Apply';
select blockid into @officeblockid from ld_appparenttab where parenttab_label='Office';
update ld_appparenttabrel set blockid=@officeblockid,sequence=sequence+2 where blockid=@applyblockid;
delete from ld_appparenttab where blockid=@applyblockid;
delimiter;
-- 2017-10-23

UPDATE ld_field SET allowhide='yes' WHERE tabid=14 AND columnname='unit_price';
update ld_systems_deploy set inputvalue='[{"value":"1","text":"MANDATORYFIELDS"},{"value":"2","text":"NONMANDATORY"},{"sql":""}]',deploy_value=1 where deploy_type=143;
delimiter;

update ld_systems_deploy set deploy_type=143 where description='微信端外勤签到时是否显示客户' and deploy_type=1;
delimiter;
-- 2017-10-24

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=70
	AND NOT EXISTS (SELECT 1 FROM ld_products); 
UPDATE ld_field SET presence=1 WHERE tabid=14 AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_products); 

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=11
	AND NOT EXISTS (SELECT 1 FROM ld_account); 
UPDATE ld_field SET presence=1 WHERE tabid=6 AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_account);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=94
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails); 
UPDATE ld_field SET presence=1 WHERE tabid=4 AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);
 
UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=112
	AND NOT EXISTS (SELECT 1 FROM ld_vendor); 
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_vendor);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=113
	AND NOT EXISTS (SELECT 1 FROM ld_vendorcontacts); 
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_vendorcontacts);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=27
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords); 
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=29
	AND NOT EXISTS (SELECT 1 FROM ld_potential); 
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_potential);

UPDATE ld_field SET presence=1 
WHERE tabid=6 AND columnname IN ('modifiedby','lastorderdate','lastcontactdate','allocatedate','protectdate',
    'potentialid','lastservicedate','distributiondate','firt_concatuser','lastcontactuser','product_id','servicecasher')
	AND NOT EXISTS(SELECT 1 FROM ld_account);
-- 2017-10-26

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Contacts';
UPDATE ld_field SET fieldname='bill_country',uitype=15,defaultvalue='中国' WHERE tabid=@tabid AND columnname='mailingcountry';
UPDATE ld_field SET fieldname='bill_state',uitype=15 WHERE tabid=@tabid AND columnname='mailingstate';
UPDATE ld_field SET fieldname='bill_city',uitype=15 WHERE tabid=@tabid AND columnname='mailingcity';

DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield in ('bill_country','bill_state');

SELECT max(id) INTO @id FROM ld_picklist_dependency;
INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
SELECT (@id:=@id+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency WHERE tabid=6 AND sourcefield in ('bill_country','bill_state');
delimiter;



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
delimiter;

update ld_version set old_version='V7.1.0',current_version='V7.1.0',remark='V7.1.0-20171024',wx_version='V5';
delimiter;