SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill' LIMIT 1);
UPDATE ld_field SET keywords='no' WHERE tabid=@tabid;
UPDATE ld_field SET keywords='yes' WHERE tabid=@tabid AND columnname IN ('cashbill_no');
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

    IF @smownerid>0  THEN
      CALL ldcrm_add_reminder(@content,@smownerid,@reltab,NEW.related_to);
    END IF;
    select presence into @presence from ld_tab where name='servicecharge';

    IF @servicecasher>0 AND @smownerid<>@servicecasher AND (@presence=0 or @presence=2)  THEN
      CALL ldcrm_add_reminder(@content,@servicecasher,'ServiceCharge',NEW.related_to);
    END IF;
  END IF;

end ||
delimiter;
-- 2020-07-03

UPDATE ld_tab SET presence=1 WHERE `name`='SocialPromotion';
UPDATE ld_organizationdetails SET small_logoname='logo_mini_1.png' WHERE small_logoname IN ('logo.png','logo_kh001.png');
UPDATE ld_field SET allowedit='no' WHERE tablename='ld_paymentplan' AND columnname='paymentstatus';
ALTER TABLE ld_account ALTER COLUMN nolinkdays SET DEFAULT 0;


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

set @tabid = (select tabid from ld_tab where name ='SocialPromotion');
update ld_field set columnname = 'h5buttoncolor' where columnname='H5buttoncolor' and tabid =@tabid;
delimiter;

DROP table  if exists ld_socialpromotionformcustom;
DROP table  if exists ld_socialpromotionformfixed;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_socialpromotionformfixed`
(
    `id` int(19)  UNSIGNED NOT NULL  AUTO_INCREMENT,
    `userid` int(19) NOT NULL DEFAULT '0',
    `status` int(3) NOT NULL DEFAULT '0' ,
    `statusMsg` varchar(50) not null ,
    `socialpromotionid` int(19) NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_socialpromotionformcustom`
(
  `fixedid` int(19) NOT NULL DEFAULT '0'
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','requiredfieldshavebeen','该阶段布局规则中设置了必填字段，需进入“编辑”界面进行保存推进，是否继续？','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='requiredfieldshavebeen' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','requiredfieldshavebeen','Required fields have been set in the layout rules of this stage, and you need enter the Edit interface to save and push forward. Do you want to continue?','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='requiredfieldshavebeen' and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USERALREADYEXISTSCONTACT','客户已存在,联系人创建成功','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='USERALREADYEXISTSCONTACT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','USERALREADYEXISTSCONTACT','User already exists, contact created successfully','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='USERALREADYEXISTSCONTACT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILEDTOCREATEREASON','创建失败,原因：唯一性校验失败','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='FAILEDTOCREATEREASON' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILEDTOCREATEREASON','Failed to create, reason: uniqueness check failed','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='FAILEDTOCREATEREASON' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONCREATESUCCESS','创建成功','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOCIALPROMOTIONCREATESUCCESS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONCREATESUCCESS','Created successfully','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOCIALPROMOTIONCREATESUCCESS' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_socialpromotionformfixed','mappingmoduleid','varchar','255',null);
CALL AddColumn('ld_socialpromotionformfixed','createdtime','datetime','',null);
CALL AddColumn('ld_socialpromotionformfixed','modifiedby','int','19',null);
CALL AddColumn('ld_socialpromotionformfixed','modifiedtime','datetime','',null);
ALTER TABLE ld_socialpromotionformfixed CHANGE statusMsg statusmsg varchar(50);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONSUBTIME','提交时间','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOCIALPROMOTIONSUBTIME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONSUBTIME','Submission time','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOCIALPROMOTIONSUBTIME' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONENTRYSTATUS','录入情况','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOCIALPROMOTIONENTRYSTATUS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONENTRYSTATUS','Entry status','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOCIALPROMOTIONENTRYSTATUS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONENTRYSTATUS','录入情况','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOCIALPROMOTIONENTRYSTATUS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONENTRYSTATUS','Entry status','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOCIALPROMOTIONENTRYSTATUS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONCORR','对应','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOCIALPROMOTIONCORR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONCORR','Corresponding','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOCIALPROMOTIONCORR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOCIALPROMOTIONQRCODE','二维码','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOCIALPROMOTIONQRCODE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOCIALPROMOTIONQRCODE','Qrcode','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SOCIALPROMOTIONQRCODE' and Labeltype='fixedstr');
delimiter;

set @tabid = (SELECT tabid from ld_tab WHERE name='SocialPromotion');
UPDATE ld_field set defaultvalue ='#229fe2' where fieldname ='h5buttoncolor' and tabid =@tabid;
UPDATE ld_field set defaultvalue ='#229fe2' where fieldname ='buttoncolor' and tabid =@tabid;
delimiter;


INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYSHARESCOPE', '共享范围', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYSHARESCOPE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYSHARESCOPE', 'Shared scope', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYSHARESCOPE');
delimiter;

set @tabid  =(select  tabid from ld_tab where name='SocialPromotion');
set @relation_id  =(select max(relation_id) from ld_relatedlists)+1;
INSERT INTO ld_relatedlists(relation_id,tabid, related_tabid, name, sequence, label, presence, actions, mobile_presence, mobile_sequence, type, related_coltable, wx_presence, wx_sequence, trade, islistbutton, buttonstatus, dynamicstatus) select @relation_id,@tabid, @tabid, 'get_SocialPromotionForm', 0, 'SocialPromotionForm', 0, 'select', 0, 36, NULL, NULL, 0, 0, NULL, NULL, 'yes', NULL from dual where not exists (select 1 from ld_relatedlists where name = 'get_SocialPromotionForm' and tabid = @tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
-- 2020-07-10


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

UPDATE ld_version SET old_version='V8.1.2',current_version='V8.1.2',remark='V8.1.2-20200710',wx_version='V8.1.2';
delimiter;