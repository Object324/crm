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

update ld_crmentity set setype = 'Attachment' where setype = 'Documents Attachment';
delimiter;

call altercolumnfor_primarykey('ld_expensescf','expenseid');
delimiter;
-- 2017-08-08

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set typeofdata = 'V~M' where tabid = @tabid and columnname = 'reltab';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and fieldname = 'contact_id';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select tabid into @related_tabid from ld_tab where `name` = 'Project';
select max(relation_id) into @relation_id from ld_relatedlists;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,related_coltable,type)
select @relation_id+1,@tabid,@related_tabid,'get_project',@sequence+1,'Project',0,'add',1,1,'project.salesorderid','datacategory_sql' from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
delimiter;

delete from ld_templatesrole where profileid is NULL;
delimiter;

select tabid into @tabid from ld_tab where name='ProjectProgress';
select blockid into @blockid from ld_appparenttab where parenttab_label='Project';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
delimiter;

update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ProjectProgress',0,0,'ld_projectprogress:projectprogress_no:projectprogress_no:ProjectProgress_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectProgress' and columnname LIKE 'ld_projectprogress:projectprogress_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'ProjectProgress',0,1,'ld_projectprogress:projectid:projectid:ProjectProgress_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectProgress' and columnname LIKE 'ld_projectprogress:projectid:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectProgress',1,0,'ld_projectprogress:timecost:timecost:ProjectProgress_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectProgress' and columnname LIKE 'ld_projectprogress:timecost:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectProgress',1,1,'ld_projectprogress:totalcost:totalcost:ProjectProgress_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectProgress' and columnname LIKE 'ld_projectprogress:totalcost:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'ProjectProgress',1,2,'ld_projectprogress:smownerid:assigned_user_id:ProjectProgress_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'ProjectProgress' and columnname LIKE 'ld_projectprogress:smownerid:%');
delimiter;
-- 2017-08-15

update ld_entityname set fieldname='purchaseinvoice_no' WHERE modulename='PurchaseInvoice' AND fieldname='subject'
	AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tablename='ld_purchaseinvoice' AND columnname='subject' AND typeofdata='V~M');

DROP TRIGGER IF EXISTS `up_lastcomments1`;
DROP TRIGGER IF EXISTS `up_lastcomments2`;
DROP TRIGGER IF EXISTS `up_lastcomments3`;
DROP TRIGGER IF EXISTS `ldcrm_remind_smowner`;
delimiter ||
CREATE TRIGGER `ldcrm_remind_smowner` AFTER INSERT ON `ld_modcomments` FOR EACH ROW BEGIN 
	
	SELECT setype INTO @reltab FROM ld_crmentity WHERE crmid=NEW.related_to;

	IF NEW.related_to>0 THEN
		SELECT
			b.fieldlabel INTO @content
		FROM ld_tab a
		LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND B.trantable='ld_tab' AND b.languagetype='zh'
		WHERE a.`name`=@reltab LIMIT 1;
		SELECT CONCAT(last_name,'刚刚评论了你的',@content) INTO @content FROM ld_users WHERE id=NEW.smownerid;

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
		
		IF @smownerid>0 AND @smownerid<>NEW.smownerid THEN
			CALL ldcrm_add_reminder(@content,@smownerid,@reltab,NEW.related_to);
		END IF;

		IF @servicecasher>0 AND @servicecasher<>NEW.smownerid THEN
			CALL ldcrm_add_reminder(@content,@servicecasher,'ServiceCharge',NEW.related_to);
		END IF;
	END IF;

END ||
delimiter;

SET @report_name='客户年度服务报告';
SET @report_template='default_account_servicereport.mrt';
SET @setype='HelpDesk';
SELECT
	b.fieldlabel INTO @report_describe
FROM ld_tab a
LEFT JOIN ld_tranlabel b ON a.tabid=b.Relateid AND b.trantable='ld_tab' AND b.languagetype='zh'
WHERE a.`name`='HelpDesk';
SET @report_describe=CONCAT('数据来源：',@report_describe,'，查看范围：所有数据');
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,'template',@report_template,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);
delimiter;

CALL AddColumn('ld_wx_config','limitnum','int','2',NULL);
update ld_wx_config set limitnum=5 where name='remind_time';
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select '','updateversion','updatewaresql','http://51mis.com.cn/forum.php?mod=viewthread&tid=156&fromuid=1','升级过程中，进度条卡住怎么办' from DUAL
where not exists(select 1 from ld_links where linktype = 'updateversion' and linklabel = 'updatewaresql');
delimiter;

update ld_tab set mobilepresence='weixin' where name='PublicAnnouncement';
delimiter;
select tabid into @tabid from ld_tab where name='CashBill';
select blockid into @blockid from ld_appparenttab where parenttab_label='Sales';
select max(sequence) into @sequence from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence+1 from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEREMINDS','分配提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ALLOCATEREMINDS' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEREMINDS','Allocate Remind','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ALLOCATEREMINDS' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USERLOGINDETAILS','用户登录细节','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'USERLOGINDETAILS' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','USERLOGINDETAILS','User Login Details','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'USERLOGINDETAILS' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MSG_DEAR','亲爱的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MSG_DEAR' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MSG_DEAR','Dear','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MSG_DEAR' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MSG_DEAR','亲爱的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MSG_DEAR' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MSG_DEAR','Dear','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MSG_DEAR' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_PLEASE_CLICK','请点击','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_PLEASE_CLICK' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_PLEASE_CLICK','Please click','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_PLEASE_CLICK' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_PLEASE_CLICK','请点击','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_PLEASE_CLICK' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_PLEASE_CLICK','Please click','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_PLEASE_CLICK' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_HERE','这里','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_HERE' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_HERE','here','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_HERE' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_TO_LOGIN','登录','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_TO_LOGIN' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_TO_LOGIN','to login','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_TO_LOGIN' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_ROLE_NAME','角色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_ROLE_NAME' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_ROLE_NAME','Profile name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_ROLE_NAME' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MSG_THANKS','谢谢,','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MSG_THANKS' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MSG_THANKS','Thanks','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MSG_THANKS' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_wx_config','datetime','datetime','','');
CALL AddColumn('ld_reminds','push_time','datetime','','');
CALL AddColumn('ld_workreport_remind','push_time','datetime','','');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense'; 
update ld_tabdetailfield set fieldtype = 'Num' where tabid = @tabid and columnname = 'conversion_rate'; 
delimiter;
-- 2017-08-17

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

update ld_version set old_version='V7.0.9',current_version='V7.0.9',remark='V7.0.9-20170817';
delimiter;