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

call AddColumn('ld_relatedlists','dynamicstatus','varchar',50 ,'no' );
delimiter;

update ld_relatedlists 
  inner join ld_tab on ld_tab.tabid=ld_relatedlists.related_tabid
set dynamicstatus='yes' where ld_tab.name in('Contacts','Potentials','Quotes','SalesOrder','Invoice','Emails','Documents','HelpDesk','Products',
'Campaigns','ServiceContracts','ContactRecords','PaymentPlan','CashBill','Expense','Attachment',
'OutboundOrder','SalesBack','CashBack','Accounts','Commission','CommunicationLog','Calendar','Project',
'MobileReport','DividendOrder','ServiceReturn','Reminds','BusinessApply','PurchaseOrder',
'Stock','Vendors')
and ld_relatedlists.tabid=6;
delimiter;

insert into ld_setscoperhigher(userid,scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills)
select userid,scopeauthority,'UnAssignedAccounts',viewothers,editothers,delothers,viewselfbills from ld_setscoperhigher  where modulename='Accounts'
and  not EXISTS (select userid from ld_setscoperhigher where modulename='UnAssignedAccounts');

insert into ld_scoperhigher(userid,viewid,scopeauthority,modulename)
select userid,viewid,scopeauthority,'UnAssignedAccounts' from ld_scoperhigher where  modulename='Accounts'
and  not EXISTS (select userid from ld_scoperhigher where modulename='UnAssignedAccounts');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','ORDEROUTNOALLOWRETURN','当前系统参数设置未出库订单不允许退货，该{$SalesOrder.SalesOrder}还未出库，不允许办理退货！','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','ORDEROUTNOALLOWRETURN','The {$SalesOrder.SalesOrder} not yet out of the library, do not allow for return!','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','OUTBOUNDCOUNTEQUALZERO','该单据已出库数量为零，请审核出库单！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OUTBOUNDCOUNTEQUALZERO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','OUTBOUNDCOUNTEQUALZERO','The bill has been shipped out to zero, please check the OutboundOrder！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OUTBOUNDCOUNTEQUALZERO' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','ORDERFULLYOUTNOALLOWRETURN','该单据已出库产品已经创建{$SalesBack.SalesBack}，不允许再办理退货！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','ORDERFULLYOUTNOALLOWRETURN','The document has been out of the library and the product has been created {$SalesBack.SalesBack} and no return is allowed!','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PURCHASEORDEROUTNOALLOWRETURN','当前系统参数设置未入库订单不允许退货，该{$PurchaseOrder.PurchaseOrder}还未入库，不允许办理退货！，不允许再办理退货！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PURCHASEORDEROUTNOALLOWRETURN','The {$PurchaseOrder.PurchaseOrder} not yet out of the library, do not allow for return!','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','THISDOCUMENTHASBEENSHIPPEDTOZERO','该单据已入库数量为零，请审核{$Stock.Stock}！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THISDOCUMENTHASBEENSHIPPEDTOZERO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','THISDOCUMENTHASBEENSHIPPEDTOZERO','This document has been shipped to zero, please check {$Stock.Stock}','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISDOCUMENTHASBEENSHIPPEDTOZERO' and Labeltype='fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PURCHASEORDERFULLYOUTNOALLOWRETURN','该{$PurchaseOrder.PurchaseOrder}已全部退货，不允许办理退货。','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PURCHASEORDERFULLYOUTNOALLOWRETURN','The PurchaseOrder has been fully returned orders, handle returns are not allowed.','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');

delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AssessmentMethod','考核方法','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='AssessmentMethod' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Assessment Method','考核方法','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='AssessmentMethod' and languagetype='en' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ByCity','按{$Accounts.bill_city}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByCity' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ByCity','By {$Accounts.bill_city}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByCity' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ByBillArea','按{$Accounts.bill_area}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByBillArea' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ByBillArea','By {$Accounts.bill_area}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByBillArea' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'bill_city',207,'服务考核方法类型','',100000,4,'select',1 ,'' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=207);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Performance_scores_bill_area','1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重*0.01 + {$Accounts.bill_area}绩效基数)*{$HelpDesk.servicetype}绩效权重*0.01*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})','fixedstr'
from dual  where not exists (select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='Performance_scores_bill_area');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Performance_scores_bill_area','1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重*0.01 + {$Accounts.bill_area}绩效基数)*{$HelpDesk.servicetype}绩效权重*0.01*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})','fixedstr'
from dual  where not exists (select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='Performance_scores_bill_area');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Performance_scores_bill_area','1.	Performance scores of {$HelpDesk.HelpDesk}=scores of ({$HelpDesk.productcategory} * {$HelpDesk.ticketcategories} * weight*0.01+ scores of {$Accounts.bill_city})*{$HelpDesk.servicetype}* weight*0.01*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})','fixedstr'
from dual  where not exists (select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='Performance_scores_bill_area');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Project_scores_bill_area','2.	{$ProjectTask.ProjectTask}业绩=({$HelpDesk.productcategory}绩效基数*{$ProjectTask.projecttasktype}绩效权重*0.01+{$Accounts.bill_area}绩效基数)','fixedstr'
from dual  where not exists (select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='Project_scores_bill_area');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Project_scores_bill_area','2.	Performance scores of {$ProjectTask.ProjectTask}=scores of {$HelpDesk.productcategory} * {$ProjectTask.projecttasktype} * weight*0.01+ scores of {$Accounts.bill_city}','fixedstr'
from dual  where not exists (select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='Project_scores_bill_area');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ObjtainAccountControlDays', '{$Accounts.Accounts}被自动回收后__天内不允许被当前{$Accounts.assigned_user_id}再次领取（为0或空表示不控制）','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='ObjtainAccountControlDays' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ObjtainAccountControlDays', 'The accounts is not allowed to be obtained again by the current owner within__days after being recycled','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='ObjtainAccountControlDays' and Labeltype='fixedstr' and languagetype='en');
delimiter;
CALl AddColumn('ld_account_set','objtainaccountcontroldays','int','11','');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ObtainAccountError', '距上次自动回收日期未超过设定的天数，不允许被领取！','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='ObtainAccountError' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ObtainAccountError', 'Operation failed because the set day is not bigger than the latest recycled date.','fixedstr' from dual 
where not exists(select 1 from ld_desk  where labelbol='ObtainAccountError' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2019-12-19

UPDATE ld_bankaccountset a
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.Total) AS Total
	FROM ld_cashbill a
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=83 AND deploy_value=0) THEN 1=1
				ELSE a.approvestatus='已批准'
			END)
	GROUP BY a.bankaccountsetid
) s1 ON a.Bankaccountsetid=s1.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.Total) AS Total
	FROM ld_sendcashbill a
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND (
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=84 AND deploy_value=0) THEN 1=1
				ELSE a.approvestatus='已批准'
			END)
	GROUP BY a.bankaccountsetid
) z1 ON a.Bankaccountsetid=z1.bankaccountsetid
LEFT JOIN (
	SELECT
		a.inaccount,
		SUM(a.cashmoney) AS total
	FROM ld_cashdeposit a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.inaccount
) s2 ON a.Bankaccountsetid=s2.inaccount
LEFT JOIN (
	SELECT
		a.Outaccount,
		SUM(a.cashmoney) AS total
	FROM ld_cashdeposit a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.Outaccount
) z2 ON a.Bankaccountsetid=z2.Outaccount
LEFT JOIN (
	SELECT
		a.inaccount,
		SUM(a.cashmoney) AS total
	FROM ld_putcash a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.inaccount
) s3 ON a.Bankaccountsetid=s3.inaccount
LEFT JOIN (
	SELECT
		a.Outaccount,
		SUM(a.cashmoney) AS total
	FROM ld_putcash a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.Outaccount
) z3 ON a.Bankaccountsetid=z3.Outaccount
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_purchasecashback a
	WHERE a.deleted=0
	GROUP BY a.bankaccountsetid
) s4 ON a.Bankaccountsetid=s4.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_cashback a
	WHERE a.deleted=0
	GROUP BY a.bankaccountsetid
) z4 ON a.Bankaccountsetid=z4.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_expense a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.bankaccountsetid
) z5 ON a.Bankaccountsetid=z5.bankaccountsetid
LEFT JOIN (
	SELECT
		a.bankaccountsetid,
		SUM(a.total) AS total
	FROM ld_commission a
	WHERE a.deleted=0
		AND a.approvestatus='已批准'
	GROUP BY a.bankaccountsetid
) z6 ON a.Bankaccountsetid=z6.bankaccountsetid
SET a.curbalancemoney=IFNULL(a.InitMoney,0)+IFNULL(s1.Total,0)+IFNULL(s2.Total,0)+IFNULL(s3.Total,0)+IFNULL(s4.Total,0)-IFNULL(z1.Total,0)-IFNULL(z2.Total,0)-IFNULL(z3.Total,0)-IFNULL(z4.Total,0)-IFNULL(z5.Total,0)-IFNULL(z6.Total,0);


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

UPDATE ld_version SET old_version='V7.9.9.5',current_version='V7.9.9.5',remark='V7.9.9.5-20191227',wx_version='V7.9.9.5';
delimiter;