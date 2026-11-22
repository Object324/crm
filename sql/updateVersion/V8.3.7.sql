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
			IF tmp_defaultvalue='' THEN
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
			IF tmp_columnlen<=1 THEN 
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

call AddColumn('ld_users','quickcreatemodules','text','','');
delimiter;

update ld_expensedetail INNER JOIN ld_crmentity
on ld_expensedetail.entitytypeid=ld_crmentity.crmid
set ld_expensedetail.entitytype=ld_crmentity.setype
where ld_expensedetail.entitytypeid>0 and (ld_expensedetail.entitytype is null or ld_expensedetail.entitytype='');
delimiter;


set @modulenames=(select modulenames from ld_dashboard_app where name='salesdragontiger');
set @modulenames = concat(@modulenames,'Leads,LeadsUpToAccounts,SalesOrder,ServiceContracts,ContractAmount,Commission') ;
update ld_dashboard_app set modulenames=@modulenames where name='salesdragontiger';
delimiter;
-- 2020-12-31

DELETE FROM ld_related_field WHERE effect_fieldid IS NULL;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',6,'是否显示关键视图','no' ,'',6 from dual
where not exists(select 1 from ld_appsystem where deploy_type=6 and description='是否显示关键视图');
delimiter;

update ld_dashboard_app set modulenames='Accounts,Contacts,Potentials,Calendar,ContactRecords,HelpDesk,SignLeads,LeadsUpToAccounts,SalesOrder,ServiceContracts,ContractAmount,CommissionLeads,Commission' where name='salesdragontiger';
delimiter;

UPDATE ld_relatedlists SET actions='add,select' WHERE actions='add,select,Import' AND tabid IN (2,48) AND related_tabid=4;
UPDATE ld_desk SET fieldlabel='覆盖方式会更新系统原有的数据，但是不会更新其关联单据的产品分录信息，请慎用！' WHERE labelbol='coveragemethodwillupdate' AND languagetype='zh';
-- 2021-01-04

SET @disable_triggers=1;
UPDATE ld_troubletickets a
SET a.approvestatus=(CASE WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=6 AND deploy_value=0) THEN '已批准' ELSE '未提交' END)
WHERE a.deleted=0
	AND a.approvestatus='审批中'
	AND ticketid NOT IN (SELECT crmid FROM ld_approvelog WHERE crmid>0 GROUP BY crmid);

UPDATE ld_troubletickets a
INNER JOIN (SELECT MAX(id) AS maxid,crmid FROM ld_approvelog WHERE crmid>0 GROUP BY crmid) b ON b.crmid=a.ticketid
INNER JOIN ld_approvelog c ON c.id=b.maxid
SET a.approvestatus='已批准',a.currentapprover=NULL
WHERE a.deleted=0
	AND a.approvestatus='审批中'
	AND c.approveresult=2;

UPDATE ld_troubletickets
SET
	currentapprover=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_troubletickets.ticketid AND isfinished='no') THEN
				(SELECT GROUP_CONCAT(nextstepapproveby) FROM ld_approvelog WHERE crmid=ld_troubletickets.ticketid AND isfinished='no')
			ELSE
				(SELECT nextstepapproveby FROM ld_approvelog WHERE crmid=ld_troubletickets.ticketid ORDER BY seqtime DESC,id DESC LIMIT 1)
		END),
	currentapprovestepid=(
		CASE
			WHEN EXISTS (SELECT 1 FROM ld_approvelog WHERE crmid=ld_troubletickets.ticketid AND isfinished='no') THEN
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_troubletickets.ticketid AND isfinished='no' AND nextstepid>0 ORDER BY id DESC LIMIT 1)
			ELSE
				(SELECT nextstepid FROM ld_approvelog WHERE crmid=ld_troubletickets.ticketid AND nextstepid>0 ORDER BY seqtime DESC,id DESC LIMIT 1)
		END)
WHERE deleted=0
	AND approvestatus IN ('审批中');
SET @disable_triggers=NULL;
-- 2021-01-05

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approvesetrequiredfield','审批流程中设置的有审批人必填字段为空','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='approvesetrequiredfield' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','approvesetrequiredfield','审批流程中设置的有审批人必填字段为空','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='approvesetrequiredfield' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel="收款额月度同比" where labelbol="BACKAMOUNTMONTHYEAR" and languagetype="zh";
delimiter;

update ld_desk set fieldlabel="商机统计图_按{$Potentials.assigned_user_id}和{$Potentials.sales_stage}统计"
where labelbol="StatisticsPotentialsBySalesPersonAndSalesStage" and languagetype="zh";

update ld_desk set fieldlabel="商机统计图_按{$Accounts}{$Accounts.industry}和{$Potentials.sales_stage}统计"
where labelbol="StatisticalPotentialsByTheAccountIndustryAndSalesStage" and languagetype="zh";
delimiter;

update ld_relatedlists set type='datacategory_sql', related_coltable='purchaseinquiryorder.vendorid'
where tabid=@tabid and name='get_purchaseinquiryorder';
delimiter;

update ld_field set bigtype='date' where tabid=6 and uitype = 5;
update ld_field set bigtype='text' where tabid=6 and uitype = 1;
update ld_field set bigtype='date' where tabid=18 and uitype = 5;
update ld_field set bigtype='text' where tabid=18 and uitype = 1;
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
update ld_field set bigtype='date' where tabid=@tabid and uitype = 5;
update ld_field set bigtype='text' where tabid=@tabid and uitype = 1;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_producttoolfield_20210106`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_producttoolfield_20210106`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT tabid FROM ld_producttoolfield WHERE columnname IN ('usageunit','product_no');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		SET @i=0;
		UPDATE ld_producttoolfield SET sequence=sequence+10 WHERE tabid=tmp_id;
		UPDATE ld_producttoolfield SET sequence=sequence+1000 WHERE tabid=tmp_id AND presence=1;
		UPDATE ld_producttoolfield SET sequence=1 WHERE tabid=tmp_id AND columnname='productname';
		UPDATE ld_producttoolfield SET sequence=2 WHERE tabid=tmp_id AND columnname='product_no';
		UPDATE ld_producttoolfield SET sequence=3 WHERE tabid=tmp_id AND columnname='productsheet';
		UPDATE ld_producttoolfield SET sequence=4 WHERE tabid=tmp_id AND columnname='usageunit';
		UPDATE ld_producttoolfield SET sequence=(@i:=@i+1) WHERE tabid=tmp_id ORDER BY sequence;
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

DROP PROCEDURE IF EXISTS `reset_public_demo_20210105`;
delimiter ||
CREATE PROCEDURE `reset_public_demo_20210105`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) AND EXISTS (SELECT 1 FROM ld_version WHERE IFNULL(trade,'')='' AND IFNULL(account,'')='') AND DATABASE()='ldcrm' THEN

		UPDATE ld_tab SET presence=5 WHERE `name` IN ('Leads','ServiceReturn','Emails','Faq','MassSMS',
			'MassEmails','SmsPhrases','EmailListtmp','CommunicationLog','QuotesChange',
			'ProjectMilestone','Rate','PublicAnnouncement','PutCash','CashDeposit',
			'BankCash','Comprehensivereport','Productbom','PriceBooks');

		UPDATE ld_field SET presence=1 WHERE tablename='ld_leads' AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tablename IN ('ld_account','ld_accountscf') AND columnname IN ('accountproperty');
		UPDATE ld_field SET presence=1 WHERE tablename IN ('ld_contactdetails') AND columnname IN ('imagename');
		UPDATE ld_field SET presence=1 WHERE tablename='ld_leads' AND columnname IN ('modifiedby');
		UPDATE ld_field SET quickcreate=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND presence<>1;
		UPDATE ld_tab SET isduplicate='no' WHERE `name`='ContactRecords';

		UPDATE ld_field SET presence=1 WHERE tabid=37 AND columnname IN ('lastinvoicedate','lastinvoice_no','cashbilldate');
		UPDATE ld_field SET presence=1 WHERE tabid=13 AND columnname IN ('ticket_title','modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge') AND columnname IN ('modifiedby',
			'potentialid','lastorderdate','accountproperty','productcategory','bill_code','traffic','faxx');

		UPDATE ld_field SET presence=1 WHERE tabid=16 AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Documents') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Faq') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Campaigns') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') AND columnname IN ('modifiedby','productcategory','callhigh','lastorderdate');

		UPDATE ld_field SET presence=1 WHERE tabid=20 AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=22 AND columnname IN ('modifiedby','lastinvoicedate','cashbilldate','lastinvoice_no','totalquantity');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='QuotesChange') AND columnname IN ('modifiedby',
			'approvetime','approveby','currentapprover');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack') AND columnname IN ('modifiedby',
			'approvetime','approveby','currentapprover');
		UPDATE ld_field SET presence=1 WHERE tabid=18 AND columnname IN ('modifiedby','postalcode','fax');


		UPDATE ld_field SET presence=1 WHERE tabid=21 AND columnname IN ('modifiedby','lastinvoicedate','lastinvoice_no','sendcashbilldate');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact') AND columnname IN ('fax');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder') AND columnname IN ('modifiedby',
			'approvetime','approveby','currentapprover');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords') AND columnname IN ('subject');


		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Project') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectTask') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress') AND columnname IN ('modifiedby');
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress');
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
		UPDATE ld_field SET fieldlabel='创建时间' WHERE fieldid=@fieldid AND fieldlabel='创建日期';
		UPDATE ld_tranlabel SET fieldlabel='创建时间' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='zh' AND fieldlabel='创建日期';

		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` IN ('TimeSheet','Rate')) AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder') AND columnname IN ('modifiedby',
			'subsmownerid','lastinvoicedate','cashbilldate','lastinvoice_no');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock') AND columnname IN ('modifiedby',
			'subsmownerid','lastinvoicedate','sendcashbilldate','lastinvoice_no');
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock');
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='contactid' LIMIT 1);
		UPDATE ld_field SET fieldlabel='供应商联系人' WHERE fieldid=@fieldid AND fieldlabel='联系人姓名';
		UPDATE ld_tranlabel SET fieldlabel='供应商联系人' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='zh' AND fieldlabel='联系人姓名';

		UPDATE ld_field SET presence=1 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE `name` IN ('WareHouseTransfer','Checks','Invoice','PurchaseInvoice')) AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill') AND columnname IN ('modifiedby');
		UPDATE ld_field SET displaytype=3,presence=2 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill') AND columnname IN ('total');

		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack') AND columnname IN ('modifiedby');
		UPDATE ld_field SET displaytype=3,presence=2 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack') AND columnname IN ('total');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack') AND columnname IN ('modifiedby');
		UPDATE ld_field SET displaytype=3,presence=2 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack') AND columnname IN ('total');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendPayment') AND columnname IN ('modifiedby','actualdate');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan') AND columnname IN ('modifiedby','actualdate');

		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='LoanApply') AND columnname IN ('modifiedby');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='CardApply') AND columnname IN ('modifiedby');

		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products') AND columnname IN ('modifiedby','taxclass','imagename','productcode');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Productbom') AND columnname IN ('modifiedby','bomcode');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='PriceBooks') AND columnname IN ('modifiedby','approvetime','approveby','currentapprover');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='SocialPromotion') AND columnname IN ('modifiedby','approvetime','approveby','currentapprover');
		UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users') AND columnname IN ('modifiedby');


		-- 相关信息
		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contactRecords' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_publicaccount' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contacts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contactrecords' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_opportunities' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_quotes' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_salesorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_ServiceContracts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_project' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_campaigns' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_schedule' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contactRecords' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_opportunities' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_paymentplan' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_cashbill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_outboundorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_invoice' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_helpdesk' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_expense' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_project' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_servicereturn' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contactRecords' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_SharedUsers' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_commonproblem' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contacts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contactrecords' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_opportunities' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_quotes' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_salesorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_ServiceContracts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_campaigns' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_schedule' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=9;
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Documents');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Faq');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachments' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Campaigns');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_accounts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contacts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_opportunities' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_SharedUsers' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_accounts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contacts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_contactrecords' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_Quotes' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_salesorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_servicecontracts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_schedule' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_project' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_receivablesforecast' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_salesorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_servicecontracts' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchaseinquiryorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;

		SET @nycnt=(SELECT COUNT(1) FROM ld_relatedlists WHERE tabid=20 AND `name`='get_purchaseinquiryorder' AND related_coltable='tmpsourcedetail.id');
		SET @myminid=(SELECT MIN(relation_id) FROM ld_relatedlists WHERE tabid=20 AND `name`='get_purchaseinquiryorder' AND related_coltable='tmpsourcedetail.id');
		DELETE FROM ld_relatedlists WHERE tabid=20 AND relation_id>@myminid AND @nycnt>1;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='QuotesChange');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_salesorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_paymentplan' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_cashbill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_outorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_invoices' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_project' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_servicecontracts' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_tickets' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchaseorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_commission' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_expense' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_salesback' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_cashback' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_cashback' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_vendorcontact' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_VendorContactRecords' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchase_orders' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_SendPayment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_SendCashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_stock' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchaseinvoice' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_expense' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchaseback' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchasecashback' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_VendorContactRecords' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_quotes' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_purchaseorder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE `name` ='get_viewhistory' AND tabid=@tabid;

			SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Project');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ProjectTask' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ProjectProgress' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ProjectMilestone' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='HelpDesk' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectTask');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ProjectProgress' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ServiceReturn' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Rate');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='CashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Invoice' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SendCashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='PurchaseInvoice' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WareHouseTransfer');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Checks');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Invoice');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='PaymentPlan' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='CashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SendPayment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SendCashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='CashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendPayment');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SendCashBill' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PutCash');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashDeposit');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='LoanApply');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CardApply');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='PriceBooks' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Productbom' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Potentials' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Quotes' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SalesOrder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='PurchaseInquiryOrder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='PurchaseOrder' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ServiceContracts' AND tabid=@tabid;

		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='HelpDesk' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Productbom');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PriceBooks');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Products' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SharedUsers' AND tabid=@tabid;

		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Users');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='Attachment' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='ViewHistory' AND tabid=@tabid;


		SET @i=0;
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SocialPromotion');
		UPDATE ld_relatedlists SET presence=1 WHERE tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SocialPromotionForm' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SocialPromotionReport' AND tabid=@tabid;
		UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE label ='SharedUsers' AND tabid=@tabid;


		UPDATE ld_producttoolfield SET presence=0 WHERE columnname IN ('usageunit','product_no');
		UPDATE ld_producttoolfield SET defaultvalue=13 WHERE columnname IN ('tax2');
		CALL ldcrm_reset_producttoolfield_20210106();


		SET @i=0;
		SET @myparenttab_label='My Home Page';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Home'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Calendar'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Documents'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Attachment'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='SocialPromotion'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Cache'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Parent Accounts';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Accounts'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Contacts'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ChinaMap'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Sales';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,2,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,20,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,22,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='QuotesChange'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='SalesBack'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Service';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,37,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,13,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Project';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,48,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,47,(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Rate'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Finacial';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='SendPayment'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Invoice'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CashBack'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PutCash'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CashDeposit'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='BankCash'),(@i:=@i+1),'ld_tab';

		SET @i=0;
		SET @myparenttab_label='Stock';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Stock'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='WareHouseTransfer'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Checks'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Purchase';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Vendors'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='VendorContact'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack'),(@i:=@i+1),'ld_tab';



		SET @i=0;
		SET @myparenttab_label='Parent Reports';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='OftenUseReport'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Comprehensivereport'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Customreport'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='Marketing';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Campaigns'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='MassSMS'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='SmsPhrases'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CommunicationLog'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='MassEmails'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Emails'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='EmailListtmp'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='OAForms';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='LoanApply'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Commission'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Expense'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		SET @myparenttab_label='CustomForms';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT
			@myparenttabid,
			tabid,
			(@i:=@i+1),
			'ld_tab'
		FROM ld_tab
		WHERE `name` LIKE 'CustomForm%'
		ORDER BY FIELD(description,'CUSTOMFORMBASIC','CUSTOMFORMPRODUCTREL','CUSTOMFORMBASICREL'),`name`;


		SET @i=0;
		SET @myparenttab_label='Tools';
		SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label=@myparenttab_label);
		DELETE FROM ld_parenttabrel WHERE parenttabid=@myparenttabid;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Products'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Productbom'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PriceBooks'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='SalesGoal'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='ModComments'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='PublicAnnouncement'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='RecycleBin'),(@i:=@i+1),'ld_tab';

		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)
		SELECT @myparenttabid,(SELECT tabid FROM ld_tab WHERE `name`='Faq'),(@i:=@i+1),'ld_tab';


		SET @i=0;
		UPDATE ld_parenttab SET sequence=sequence+100;
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='My Home Page';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Parent Accounts';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Sales';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Service';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Project';

		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Finacial';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Stock';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Purchase';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Parent Reports';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Marketing';

		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='OAForms';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='CustomForms';
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE parenttab_label='Tools';

		SET @i=0;
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) ORDER BY sequence;

	END IF;


END ||
delimiter;

CALL reset_public_demo_20210105();
DROP PROCEDURE IF EXISTS `reset_public_demo_20210105`;
DROP PROCEDURE IF EXISTS `ldcrm_reset_producttoolfield_20210106`;


DROP PROCEDURE IF EXISTS `ldcrm_reset_home_20210107`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_home_20210107`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT templateid FROM ld_templates;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) AND EXISTS (SELECT 1 FROM ld_version WHERE IFNULL(trade,'')='' AND IFNULL(account,'')='') THEN
		OPEN MYCUSOR;
		FETCH MYCUSOR INTO tmp_id;
		WHILE(tmp_id IS NOT NULL) DO
			DELETE FROM ld_templatesstuff WHERE templateid=tmp_id;
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('35', tmp_id, 'saleskit', '0', 'saleskit', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('19', tmp_id, 'chart', '1', 'SALESFUNNEL', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('40', tmp_id, 'chart', '2', 'COMPLATIONRATESIXMONTH', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('9', tmp_id, 'chart', '3', 'INDIVIDUALSIXMONTH', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('1', tmp_id, 'chart', '4', 'SALESSIXMONTH', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('5', tmp_id, 'chart', '5', 'BACKAMOUNTMONTHYEAR', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('4', tmp_id, 'chart', '6', 'AMOUNTMONTHCONTRACTYEAR', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('41', tmp_id, 'chart', '7', 'INVOICEAMOUNTYEAR', '0');
			INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES ('42', tmp_id, 'chart', '8', 'OUTBOUNDORDERAMOUNTYEAR', '0');
			FETCH MYCUSOR INTO tmp_id;
		END WHILE;
		CLOSE MYCUSOR;
	END IF;

END ||
delimiter;

CALL ldcrm_reset_home_20210107();
DROP PROCEDURE IF EXISTS `ldcrm_reset_home_20210107`;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isSureImportWxUsers','确定要导入企业微信客户吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='isSureImportWxUsers' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isSureImportWxUsers','Are you sure you want to import enterprise WeChat customers？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='isSureImportWxUsers' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2021-01-11

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Showtheallincludecommonaccounttab','显示 “全部（普通客户）”页签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Showtheallincludecommonaccounttab' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Showtheallincludecommonaccounttab','Show the all include common account tab','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Showtheallincludecommonaccounttab' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public','show_commonaccount_tab','varchar','20','no');
delimiter;

update ld_account_public set show_commonaccount_tab = 'no' where show_commonaccount_tab is NULL;
delimiter;


call AddColumn('ld_account_public','show_account_rule','varchar','20','no');
delimiter;

update ld_account_public set show_account_rule = 'no' where show_account_rule is NULL;
delimiter;

call AddColumn('ld_account_public','account_rule_pool_id','int','11','no');
delimiter;

call AddColumn('ld_account_public','recycleselect','text','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','theallincludecommonaccountpool','全部（普通客户）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='theallincludecommonaccountpool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','theallincludecommonaccountpool','the all include common account pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='theallincludecommonaccountpool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Edittheunassignedpool','编辑公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Edittheunassignedpool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Edittheunassignedpool','Edit the unassigned pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Edittheunassignedpool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deletetheunassignedpool','删除公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deletetheunassignedpool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deletetheunassignedpool','Delete the unassigned pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deletetheunassignedpool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','deletetheunassignedpools','要删除的公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deletetheunassignedpools' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','deletetheunassignedpools','Delete the unassigned pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='deletetheunassignedpools' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Transferunassignedcustomerstounassignedpool','转移公海{$Accounts.Accounts}到公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transferunassignedcustomerstounassignedpool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Transferunassignedcustomerstounassignedpool','Transfer unassigned customers to unassigned pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Transferunassignedcustomerstounassignedpool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','afterdeletethehignseaspool','删除公海池后，该公海池中的公海客户将全部转移到所选公海池的“公海未分配”中，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='afterdeletethehignseaspool' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','afterdeletethehignseaspool',' After deleting the high seas pool, all the high Seas customers in the pool will be transferred to the "high seas not allocated" of the selected high seas pool. Do you want to continue? ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='afterdeletethehignseaspool' and Labeltype='jspop' and languagetype='en');
delimiter;

call AddColumn('ld_account_public_pool','deleted','int','11',0);
delimiter;


update ld_desk set fieldlabel = '新建公海池' where labelbol = 'createpublicaccountpool' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '公海池名称（中文）' where labelbol = 'Name(ZH)' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '公海池名称（英文）' where labelbol = 'Name(EN)' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommoncustomersautomaticallyreclaimruleSettings','普通客户自动回收规则设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommoncustomersautomaticallyreclaimruleSettings' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommoncustomersautomaticallyreclaimruleSettings','Common customers automatically reclaim rule Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CommoncustomersautomaticallyreclaimruleSettings' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Enablecommoncustomerautomaticreclaimrules','启用普通客户自动回收规则，自动回收到公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Enablecommoncustomerautomaticreclaimrules' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Enablecommoncustomerautomaticreclaimrules','Enable common customer automatic reclaim rules, automatic reclaim to the unassigned pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Enablecommoncustomerautomaticreclaimrules' and Labeltype='fixedstr' and languagetype='en');
delimiter;

select count(1) into @cnt from ld_account_public_pool;
insert into ld_account_public_pool(zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,userid_after_transfer,userid_after_release,create_buttons,recycleselect,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid)
select '旧公海','High seas',count,if(astricttype=1,'user','role'),adminaccount,usersaccount,usersaccount_type,if(dataprofile=0,'yes','no'),if(getprofile=0,'yes','no'),'yes','yes','yes',userid,allotaccount,case when buttontype = '1' then 'COMMONACCOUNT' when buttontype = '2' then 'NOALLOCATE' when buttontype = '3' then 'PUBLICALLOCATE' when buttontype = '1,2' then 'COMMONACCOUNT,NOALLOCATE' when buttontype = '2,3' then 'NOALLOCATE,PUBLICALLOCATE' when buttontype = '1,3' then 'COMMONACCOUNT,PUBLICALLOCATE' when buttontype = '1,2,3' then 'COMMONACCOUNT,NOALLOCATE,PUBLICALLOCATE' else '' END,recycleselect,beforereminddays,objtainaccountcontroldays,now(),1 from ld_account_set where @cnt = 0;
delimiter;

update ld_account set pool_id = 1 where publicaccount >= 1 and pool_id = 0;
delimiter;

update ld_account_public set show_commonaccount_tab = 'yes' where `status` = 'yes';
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool;
	declare continue handler  for not   found  SET done =1;
if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
	UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';
	call account_singlerecycle_normal_rule();
	call account_singlerecycle_normal_rule_beforeremind();
	OPEN cur1;
		Fetch cur1 into tmp_pool_id;
			loop1: while  done<>1 DO
				call account_singlerecycle_highsea_rule(tmp_pool_id);
				call account_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
		Fetch cur1 into tmp_pool_id;
	end while loop1;
	close cur1;
end if;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule`()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = 1;
	
    declare continue handler  for not   found  SET done =1;
    
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule.days) into @maxdays
      from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
    	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = 1;
    
    	select recycleselect,account_rule_pool_id into @recycleselect,@account_rule_pool_id from ld_account_public;
    
    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;
    
    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    		  if(var_condition='and' ) then
    
    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');
    
    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;
    
    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);
    
    			 end if;
          set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
    					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
    						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );
    
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);
    
    
    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );
    
    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;
    
    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
    			   end if;
    
    				set @tmpsql=concat(@tmpsql,' union all ' );
    
    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;
    
    
    	if @tmpint>0 then
    		set @len=CHAR_LENGTH(' union all ');
    		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
    
    	  if var_condition='or'  then
    
    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    			if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
    				end if;
    		else
    			 if @recycleselect is not null and @recycleselect<>'' then
    
    					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
    				ELSE
    					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				end if;
    
    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    		 end if;
    
    	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
    		 prepare stmt from @TMPSQL_THREE;
    		 execute stmt;
    		 deallocate prepare stmt;
    
    
    
    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
    		else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
    		end if;
    
         delete from ld_publicaccount_remindtableview ;
    
         set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
    		prepare stmt from @tmpthree;
    		execute stmt;
    		deallocate prepare stmt;
    
       call crm_publicaccount_recoveryreminds();
    
    
    		if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
    
    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    					end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
    
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				  end if;
    			ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
    		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    
    		 end if;
    		prepare stmt from @TMPSQL_TWO;
    		execute stmt;
    		deallocate prepare stmt;
    
    	end if;
    END IF;

end ||
delimiter;



DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`()
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = 1;
	
    declare continue handler  for not   found  SET done =1;
    
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule.days) into @maxdays
      from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
    	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active' and pool_id = 1;
    
    	select recycleselect,account_rule_pool_id into @recycleselect,@account_rule_pool_id from ld_account_public;
    
    	select beforereminddays into @var_beforereminddays from ld_account_public_pool where id = @account_rule_pool_id;
      if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
    	end if;
       set @maxdays=@maxdays-@var_beforereminddays;
    
    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;
    
    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
    		   end if;
    		  if(var_condition='and' ) then
    
    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');
    
    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;
    
    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);
    
    			 end if;
    
               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');
    
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);
    
    
    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );
    
    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;
    
    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
    			   end if;
    
    				set @tmpsql=concat(@tmpsql,' union all ' );
    
    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;
    
    
    	if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
    
    			if var_condition='or'  then
    				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
    									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
    									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
    										where type='complete' and ld_account_set_rule.status='active' and ld_account_set_rule.status='active' ORDER BY ld_account_set_rule.sequence asc ) ";
    
    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    				end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
    					end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
    
    		  else
    				if @recycleselect is not null and @recycleselect<>'' then
    
    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
    				ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
    				end if;
    
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
    			end if;
    
    	 	delete from ld_publicaccount_remindtableview ;
    		 set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
    			prepare stmt from @tmpthree;
    			execute stmt;
    			deallocate prepare stmt;
    
    			call crm_publicaccount_beforereminds();
    	 end if;
    END IF;

end ||
delimiter;

SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=16 AND columnname='contactid');
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=16 AND columnname='accountid');
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'column','accountid' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid);
-- 2021-01-12

UPDATE ld_account_public_pool SET zh_name='默认公海' WHERE id=1 AND zh_name='旧公海' AND NOT EXISTS (SELECT 1 FROM ld_account);

update ld_desk set fieldlabel = '显示 “全部（不含公海）”页签' where labelbol = 'Showtheallincludecommonaccounttab' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SocialPromotionReport','统计报表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SocialPromotionReport' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SocialPromotionReport','SocialPromotionReport','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SocialPromotionReport' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Fieldformulavalidationerror','字段公式验证错误，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Fieldformulavalidationerror' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Fieldformulavalidationerror','Field formula validation error,Do you want to continue?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Fieldformulavalidationerror' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Formulacontentcannotbeempty','公式内容不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Formulacontentcannotbeempty' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Formulacontentcannotbeempty','Formula content cannot be empty!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Formulacontentcannotbeempty' and Labeltype='jspop' and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step1','http://51mis.com.cn/forum.php?mod=viewthread&tid=21&fromuid=1','费用报销模块导入第一页，选择导入文件' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step1');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step2','http://51mis.com.cn/forum.php?mod=viewthread&tid=21&fromuid=1','费用报销模块导入第二页，设置查重、映射字段，导入方式' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step2');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step3','http://51mis.com.cn/forum.php?mod=viewthread&tid=21&fromuid=1','费用报销模块导入第三页，导出结果' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step3');
delimiter;
-- 2021-01-13

UPDATE ld_account_public_pool SET zh_name='默认公海' WHERE id=1 AND zh_name='旧公海' AND NOT EXISTS (SELECT 1 FROM ld_account WHERE pool_id=1);
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Highseaspool','公海池','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseaspool' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Highseaspool','High seas pool','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Highseaspool' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set Labeltype = 'fixedstr' where  labelbol = 'TOTHEHIGNSEASCUSTOMERERROR1';
delimiter;

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

UPDATE ld_version SET old_version='V8.3.7',current_version='V8.3.7',remark='V8.3.7-20210113',wx_version='V8.3.7';
delimiter;