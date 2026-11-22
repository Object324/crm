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

DROP PROCEDURE IF EXISTS `ldcrm_update_entryprofile_history`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_entryprofile_history`(

)BEGIN

	IF NOT EXISTS (select 1 from information_schema.`COLUMNS` where TABLE_SCHEMA=database() and TABLE_NAME='ld_producttoolprofile' and column_name='create_profile') THEN
		call AddColumn('ld_producttoolprofile','create_profile','varchar','20',NULL);
		call AddColumn('ld_producttoolprofile','edit_profile','varchar','20',NULL);
		call AddColumn('ld_producttoolprofile','details_profile','varchar','20',NULL);
		update ld_producttoolprofile set create_profile = 'write';
		update ld_producttoolprofile set edit_profile = 'write';
		update ld_producttoolprofile set details_profile = 'read';
		call AddColumn('ld_tabdetailprofile','create_profile','varchar','20',NULL);
		call AddColumn('ld_tabdetailprofile','edit_profile','varchar','20',NULL);
		call AddColumn('ld_tabdetailprofile','details_profile','varchar','20',NULL);
		update ld_tabdetailprofile set create_profile = 'write';
		update ld_tabdetailprofile set edit_profile = 'write';
		update ld_tabdetailprofile set details_profile = 'read';
	END IF;
end ||
delimiter;

CALL ldcrm_update_entryprofile_history();
DROP PROCEDURE IF EXISTS `ldcrm_update_entryprofile_history`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTRYFIELDSILLUSTRATE','说明：该字段仅对界面上展示的成员或角色可见（管理员自动拥有所有字段权限）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTRYFIELDSILLUSTRATE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTRYFIELDSILLUSTRATE','Description: This field is only visible to the members or roles displayed on the interface（Admin automatically have all field permissions）','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTRYFIELDSILLUSTRATE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETVISIBLERANGEFIELDS','设置成员字段权限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETVISIBLERANGEFIELDS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETVISIBLERANGEFIELDS','Set the visible range of fields','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SETVISIBLERANGEFIELDS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Newinterface','新增界面','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Newinterface' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Newinterface','New interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Newinterface' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Editinginterface','编辑界面','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Editinginterface' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Editinginterface','Editing interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Editinginterface' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Viewinterface','查看界面','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Viewinterface' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Viewinterface','View interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Viewinterface' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VISIBLE','可见','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VISIBLE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VISIBLE','Visible','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VISIBLE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITABLE','可编辑','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EDITABLE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITABLE','Editable','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EDITABLE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VISIBLE','可见','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='VISIBLE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VISIBLE','Visible','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='VISIBLE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITABLE','可编辑','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='EDITABLE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITABLE','Editable','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='EDITABLE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDLINE','新增行','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDLINE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDLINE','Add Line','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADDLINE' and Labeltype='fixedstr' and languagetype='en');
delimiter;


call AddColumn('ld_homeboard','saleskit_colcount','int',4,'');
delimiter;

call AddColumn('ld_homeboard','saleskit_height','int',4,'');
delimiter;

call AddColumn('ld_homestuffdetail','stufflabel_zh','varchar',100,'');
delimiter;

call AddColumn('ld_homestuffdetail','stufflabel_en','varchar',100,'');
delimiter;

call AddColumn('ld_homestuffdetail','daterange','varchar',255,'');
delimiter;

call AddColumn('ld_homestuffdetail','viewrange','varchar',255,'');
delimiter;

call AddColumn('ld_homestuffdetail','is_default','varchar',10,'');
delimiter;

call AddColumn('ld_homestuffdetailcondition','advance_demand','varchar',255,'');
delimiter;

call AddColumn('ld_homestuffdetailcondition','advance_demand_groups','varchar',255,'');
delimiter;

call AddColumn('ld_homeboard','saleskit_isshowpredata','varchar',10,'yes');
delimiter;

CREATE TABLE if not EXISTS `ld_homestuffsaleskit2board` (
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`boardid` int(11) DEFAULT NULL,
	`homestuffdetailid` int(11),
	`sequence` int(4) DEFAULT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SALESKITCUSTOMIZATION','销售简报定制','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SALESKITCUSTOMIZATION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SALESKITCUSTOMIZATION','SalesKit Customization','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SALESKITCUSTOMIZATION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SALESKITCUSTOMIZATION','销售简报定制','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SALESKITCUSTOMIZATION' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SALESKITCUSTOMIZATION','SalesKit Customization','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SALESKITCUSTOMIZATION' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTTHESALESKITNAME','搜索简报名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='INPUTTHESALESKITNAME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTTHESALESKITNAME','Please enter the name of the saleskit report to find','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='INPUTTHESALESKITNAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SALESKITZHNAME','简报中文名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SALESKITZHNAME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SALESKITZHNAME','SalesKit Chinese Name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SALESKITZHNAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SALESKITENNAME','简报英文名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SALESKITENNAME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SALESKITENNAME','SalesKit English Name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SALESKITENNAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWCUSTOMSALESKIT','新建自定义简报','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NEWCUSTOMSALESKIT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWCUSTOMSALESKIT','New Custom SalesKit','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NEWCUSTOMSALESKIT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LAYOUTSETTING','布局设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LAYOUTSETTING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LAYOUTSETTING','Layout setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LAYOUTSETTING' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GLOBALSETTING','全局设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GLOBALSETTING' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GLOBALSETTING','Global setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GLOBALSETTING' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUMSOFCOLUMNS','每行简报列数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NUMSOFCOLUMNS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUMSOFCOLUMNS','Number of columns','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NUMSOFCOLUMNS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HEIGHTOFEACHROW','每行简报高度','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HEIGHTOFEACHROW' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HEIGHTOFEACHROW','Height of each row','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HEIGHTOFEACHROW' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOWPREVIOUSPERIODDATA','显示上期对比数据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHOWPREVIOUSPERIODDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOWPREVIOUSPERIODDATA','Show previous period data','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHOWPREVIOUSPERIODDATA' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILTERSVIEWSCOPEMAPPINGFIELDS','筛选器查看范围映射字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILTERSVIEWSCOPEMAPPINGFIELDS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILTERSVIEWSCOPEMAPPINGFIELDS','View range mapping fields','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILTERSVIEWSCOPEMAPPINGFIELDS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FILTERTIMERANGEMAPPINGFIELD','筛选器时间范围映射字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FILTERTIMERANGEMAPPINGFIELD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FILTERTIMERANGEMAPPINGFIELD','Date range mapping fields','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FILTERTIMERANGEMAPPINGFIELD' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SCOPEOFSTATISTICALDOCUMENTS','统计单据范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SCOPEOFSTATISTICALDOCUMENTS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SCOPEOFSTATISTICALDOCUMENTS','Data range','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SCOPEOFSTATISTICALDOCUMENTS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETSEARCHCONDITIONS','设置查询条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETSEARCHCONDITIONS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETSEARCHCONDITIONS','Set search conditions','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETSEARCHCONDITIONS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SALESKITICON','简报显示图标','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SALESKITICON' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SALESKITICON','Icon','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SALESKITICON' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PREVIOUSDATA','上期','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PREVIOUSDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PREVIOUSDATA','Previous period data','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PREVIOUSDATA' and labeltype='fixedstr');
delimiter;

update ld_homestuffdetail set stufflabel_en='New Accounts' where stufflabel='NewAccounts' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Contacts' where stufflabel='NewContacts' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Contact Records' where stufflabel='NewContactRecords' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New SalesOrder Count' where stufflabel='NewSalesOrderCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New ServiceContracts Count' where stufflabel='NewServiceContractsCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New SalesOrder Amount' where stufflabel='NewSalesOrderAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New ServiceContracts Amount' where stufflabel='NewServiceContractsAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Sign Contract Count' where stufflabel='SignContractCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Sign Contract Count' where stufflabel='SignContractCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Sign Contract Amount' where stufflabel='SignContractAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Sign Contract Amount' where stufflabel='SignContractAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Invoice Amount' where stufflabel='NewInvoiceAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Outbound Order Amount' where stufflabel='NewOutboundOrderAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New CashBill Amount' where stufflabel='NewCashBillAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Potentials Count' where stufflabel='NewPotentialsCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Potentials Amount' where stufflabel='NewPotentialsAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Advance Potentials Amount' where stufflabel='AdvancePotentialsAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Sign Count' where stufflabel='NewSignCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Leads Count' where stufflabel='NewLeadsCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New HelpDesk Count' where stufflabel='NewHelpDeskCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New CashBill Count' where stufflabel='NewCashBillCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New OutboundOrder Count' where stufflabel='NewOutboundOrderCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Invoice Count' where stufflabel='NewInvoiceCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New PurchaseOrder Count' where stufflabel='NewPurchaseOrderCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New PurchaseOrder Amount' where stufflabel='NewPurchaseOrderAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New SalesOrder Receipts' where stufflabel='NewSalesOrderReceipts' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New ServiceContracts Receipts' where stufflabel='NewServiceContractsReceipts' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Quotes Count' where stufflabel='NewQuotesCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Quotes Amount' where stufflabel='NewQuotesAmount' and stufflabel_en is null ;
update ld_homestuffdetail set stufflabel_en='New Payment Plan CashBill Amount' where stufflabel='NewPaymentPlanCashBillAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Lead Ugrade To Customer Count' where stufflabel='LeadUgradeToCustomerCount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Expenses Amount' where stufflabel='ExpensesAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Commissions Amount' where stufflabel='CommissionsAmount' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Salesorder Balance Receivable' where stufflabel='SalesorderBalanceReceivable' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Service Contract Balance Receivable' where stufflabel='ServiceContractBalanceReceivable' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Sign Contract Balance Receivable' where stufflabel='SignContractBalanceReceivable' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Sign Contract Balance Receivable' where stufflabel='SignContractBalanceReceivable' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Purchase Order PayBalance' where stufflabel='PurchaseOrderPayBalance' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='New Service ChargeNums' where stufflabel='NewServiceChargeNums' and stufflabel_en is null;
update ld_homestuffdetail set stufflabel_en='Lead Ugrade To Potentials' where stufflabel='LeadUgradeToPotentials' and stufflabel_en is null;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldformula`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_tabdetailfieldformula`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR
	SELECT
			tabdetailfieldid
	FROM ld_tabdetailfield
	WHERE tabid>=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm181' LIMIT 1)
		AND columnname='total';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
			INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
	SELECT tmp_id,'sum(a)',"{formulavar:[{'lettervar':'a','column':'amount'}]}",1 FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=tmp_id);
	FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_tabdetailfieldformula();
DROP PROCEDURE IF EXISTS `ldcrm_reset_tabdetailfieldformula`;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','SUCCESSFULLYCOPIED','复制成功！','jspop'
from dual WHERE NOT EXISTS(SELECT 1 from ld_desk where languagetype = 'zh' and labelbol = 'SUCCESSFULLYCOPIED' and Labeltype = 'jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','SUCCESSFULLYCOPIED','Successfully copied!','jspop'
from dual WHERE not EXISTS(SELECT 1 from ld_desk where languagetype = 'en' and labelbol = 'SUCCESSFULLYCOPIED' and Labeltype = 'jspop');
delimiter;

call AddColumn('ld_homestuffdetail','compute_module','varchar',20,'');
delimiter;

update ld_homestuffdetail set is_default='yes' where ifnull(compute_module,'')='';
delimiter;

SET @labelbol = 'HOMEPAGEAPP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'首页','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Home','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

update ld_field set keywords='' where fieldname='tag';
delimiter;


update ld_desk set fieldlabel = '说明：该字段仅对界面上展示的成员、部门或角色可见（管理员自动拥有所有字段权限）' where labelbol = 'ENTRYFIELDSILLUSTRATE' and labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Description: This field is only visible to the members,groups or roles displayed on the interface（Admin automatically have all field permissions）' where labelbol = 'ENTRYFIELDSILLUSTRATE' and labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SETBYROLEPROFILE','按角色权限','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SETBYROLEPROFILE' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SETBYROLEPROFILE','Set by users roles','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SETBYROLEPROFILE' and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SETBYPOSITION','按职位级别','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='SETBYPOSITION' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SETBYPOSITION','Set by position','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='SETBYPOSITION' and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_fixcustomforminfo_0606`;
delimiter ||
CREATE PROCEDURE `ldcrm_fixcustomforminfo_0606`(
)
BEGIN
	DECLARE i int DEFAULT 161;

	WHILE 161<=i AND i<=180 DO

		SET @tabid=(SELECT tabid FROM ld_tab WHERE name=CONCAT('CustomForm',i) LIMIT 1);
		SET @pay_banlance_fieldid=(SELECT fieldid FROM ld_field WHERE fieldname='pay_balance' AND tabid=@tabid);
		SET @receive_banlance_fieldid=(SELECT fieldid FROM ld_field WHERE fieldname='receivable_balance' AND tabid=@tabid);

		UPDATE ld_field SET tablename=CONCAT('ld_customform',i) WHERE fieldid=@pay_banlance_fieldid;
		UPDATE ld_tranlabel SET fieldlabel='应付余额' where Relateid=@pay_banlance_fieldid and languagetype='zh' and tabid=@tabid;
		UPDATE ld_field SET tablename=CONCAT('ld_customform',i) WHERE fieldid=@receive_banlance_fieldid;

		SET i=i+1;
	END WHILE;

end ||
delimiter;

CALL ldcrm_fixcustomforminfo_0606();
DROP PROCEDURE IF EXISTS `ldcrm_fixcustomforminfo_0606`;
delimiter;

update ld_desk set fieldlabel = '管理旧看板列表' where labelbol = 'OldKanban' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Manage Old Kanban List' where labelbol = 'OldKanban' and languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NONSELECTEDRECORDSNUMS','当前没有选定记录','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NONSELECTEDRECORDSNUMS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NONSELECTEDRECORDSNUMS','no record is currently selected','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NONSELECTEDRECORDSNUMS' and labeltype='jspop');
delimiter;

DELETE FROM ld_systems_deploy WHERE deploy_type = 13;
delimiter;

CALL AddColumn('ld_option_module',"samesourcevalue",'text',0,'');
delimiter;

set @tabid = (select tabid from ld_tab where `name` = 'Singin');
update ld_field set allowhide = 'yes' where tabid = @tabid and columnname = 'entityaddress';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TABLESETTINGS','表格设置','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TABLESETTINGS' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TABLESETTINGS','Table Settings','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TABLESETTINGS' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUMBEROFMODULESPERPAGE','每页显示数量','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NUMBEROFMODULESPERPAGE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUMBEROFMODULESPERPAGE','Number of page','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NUMBEROFMODULESPERPAGE' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2023-06-11


SET @tabid = (SELECT tabid from ld_tab where `name` = 'Contacts');
UPDATE ld_field set typeofdata = 'V~M' WHERE tabid =@tabid AND columnname = 'lastname';
delimiter;

SET @labelbol = 'SHOWHYPERLINKS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示超链接','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Show Hyperlinks','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_field','showhyperlinks','varchar','5','yes');
delimiter;

call AddColumn('ld_option_module','showhyperlinks','varchar','5','yes');/*使用yes no*/
delimiter;

call AddColumn('ld_producttoolfield','showhyperlinks','varchar','5','yes');/*使用yes no*/
delimiter;

call AddColumn('ld_tabdetailfield','showhyperlinks','varchar','5','yes');/*使用yes no*/
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'ModComments');
SET @sequence = 0;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow,showhyperlinks)
SELECT @tabid,tmp.tabid,tmp.presence,0,0,@sequence := @sequence + 1,'permit',20,'yes' FROM (
	SELECT DISTINCT
		tabid,
		CASE WHEN presence IN (0, 2) THEN 0 ELSE 1 END AS presence
	FROM ld_tab
	WHERE NAME NOT IN (
		'Home',
		'MassSMS',
		'MassEmails',
		'SmsPhrases',
		'MailManager',
		'Emails',
		'SalesGoal',
		'EmailListtmp',
		'CommunicationLog',
		'Navigation',
		'InventoryLedger',
		'InventoryAccount',
		'InventoryQuery',
		'Prdtnums',
		'OftenUseReport',
		'Dashboard',
		'Comprehensivereport',
		'Reports',
		'Reminds',
		'FieldFormulas',
		'Cache',
		'reportlog',
		'recyclebin',
		'Faq',
		'Customreport',
		'CooperativeWork',
		'ChinaMap',
		'CustomEcharts',
		'WechatSession',
		'CardSettings'
	)
	GROUP BY tabid
	ORDER BY tabsequence 
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid = @tabid);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Attachment');
SET @sequence = 0;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow,showhyperlinks)
SELECT @tabid,tmp.tabid,tmp.presence,0,0,@sequence := @sequence + 1,'permit',20,'yes' FROM (
select distinct ld_tab.tabid,
	CASE WHEN ld_tab.presence IN (0, 2) THEN 0 ELSE	1 END AS presence
 from ld_relatedlists 
INNER JOIN ld_tab on ld_relatedlists.tabid=ld_tab.tabid 
 where ld_relatedlists.name='get_attachment'
) as tmp
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid = @tabid);
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'Reminds');
SET @sequence = 0;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow,showhyperlinks)
SELECT @tabid,tmp.tabid,tmp.presence,0,0,@sequence := @sequence + 1,'permit',20,'yes' FROM (
SELECT DISTINCT
	tabid,
	CASE WHEN presence IN (0, 2) THEN
		0
	ELSE
		1
	END
		as presence
FROM
	ld_tab
WHERE  NAME NOT IN ('Home','MassSMS','MassEmails','SmsPhrases','MailManager','Emails','SalesGoal',
'EmailListtmp','CommunicationLog','Navigation','InventoryLedger','InventoryAccount',
'InventoryQuery','Prdtnums','BankCash','OftenUseReport','Dashboard','Comprehensivereport',
'Reports','Reminds','FieldFormulas','Cache','reportlog','recyclebin','Faq','Customreport','CooperativeWork','ChinaMap','CustomEcharts',
'WechatSession','WeChatUser','CardSettings')
GROUP BY
	tabid
ORDER BY
	tabsequence ) as tmp
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid = @tabid);
delimiter;

UPDATE ld_desk set fieldlabel = 'Default Value'
where languagetype = 'en' and labelbol = 'LBL_DEFAULTVALUE' and Labeltype = 'jspop';
UPDATE ld_desk set fieldlabel = 'Default Value'
where languagetype = 'en' and labelbol = 'LBL_DEFAULTVALUE' and Labeltype = 'fixedstr';
delimiter;
-- 2023-06-13

SET @labelbol = 'HOURS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'小时','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hours','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELSALESKITSETCHECK','该数据简报没有保存，退出将丢失未保存的信息，确定要退出吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELSALESKITSETCHECK' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELSALESKITSETCHECK','The data saleskit has not been saved. Exiting will lose any unsaved information. Are you sure you want to exit?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CANCELSALESKITSETCHECK' and Labeltype='jspop' and languagetype='en');
delimiter;

set @cur_module = 'Potentials';set @option_module = 'HelpDesk';
set @tabid = (SELECT tabid from ld_tab where `name` = @cur_module);
set @option_tabid = (SELECT tabid from ld_tab where `name` = @option_module);
SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@option_tabid,CONCAT('get_',LOWER(@option_module)),@i+1,@option_module,1,'add','troubletickets.potentialid','datacategory_sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@option_tabid AND `name`=CONCAT('get_',LOWER(@option_module)));
delimiter;

update ld_desk set Labeltype = 'fixedstr' where labelbol = 'NUMBEROFMODULESPERPAGE';
update ld_desk set Labeltype = 'fixedstr' where labelbol = 'TABLESETTINGS';
delimiter;

UPDATE ld_desk set fieldlabel = 'Select field' where languagetype = 'en' and labelbol = 'Select_field' and Labeltype = 'fixedstr';
UPDATE ld_desk set fieldlabel = 'Select field' where languagetype = 'en' and labelbol = 'SelectField' and Labeltype = 'fixedstr';
delimiter;
-- 2023-06-14

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Campaigns');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
UPDATE ld_relatedlists set type = 'crmentityrel_datacategory_sql' where related_coltable = 'crmentityrel.crmid' and tabid = @tabid and related_tabid = @rel_tabid;
delimiter;

CREATE TABLE IF not EXISTS `ld_shop_phones` (
  `phoneid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `status` char(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `phoneseq` int(11) DEFAULT NULL,
  PRIMARY KEY (`phoneid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;
delimiter;

INSERT into ld_shop_phones(phone,`name`,`status`,phoneseq)
SELECT SUBSTR(input_content,locate_1,locate_2-locate_1) as tmp_phone,'客服' as tmp_name,'yes',1 
from ld_shop_settings INNER JOIN 
(SELECT LOCATE('custelno',input_content)+11 as locate_1,LOCATE('sharedescription',input_content)-3 as locate_2,id as tmp_id 
from ld_shop_settings where `name` = 'InterfaceSettings' and IFNULL(input_content,'') <> '') as tmp 
on tmp.tmp_id = ld_shop_settings.id
where not EXISTS(SELECT 1 from ld_shop_phones) and IFNULL(SUBSTR(input_content,locate_1,locate_2-locate_1),'') <> '';
delimiter;

SET @labelbol = 'PHONECANNOTBENULL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'电话与名字不能为空','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Name and Phone can not be empty','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'CORRECTPHONEFORMAT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请输入正确的电话格式','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the correct customer service phone format','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'NEWCUSTOMER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增客服电话','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'add new customer phonenumber','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'NEWCUSTOMER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增客服电话','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'add new customer phonenumber','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CUSTOMERSTATUS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否显示','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display or not','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'CUSTOMERSTATUS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Display or not','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EDITCUSTOMER';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑客服电话','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'EDITCUSTOMERPHONE','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NONSELECTEDRECORDSNUMS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前没有选定记录','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'no record is currently selected','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'PHONECHECK';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'电话号码不能为空！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'phone number cannot be empty!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'NAMECHECK';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'姓名不能为空！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'name cannot be empty!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '设置字段权限' where labelbol = 'SETVISIBLERANGEFIELDS' and languagetype = 'zh';
delimiter;

UPDATE ld_desk set fieldlabel = '单选产品' where languagetype = 'zh' and labelbol = 'MANUALLYSELECTANDENTERPRODUCTS' and Labeltype = 'fixedstr';
UPDATE ld_desk set fieldlabel = 'Single Choice Product' where languagetype = 'en' and labelbol = 'MANUALLYSELECTANDENTERPRODUCTS' and Labeltype = 'fixedstr';
delimiter;
UPDATE ld_desk set fieldlabel = '扫码添加产品' where languagetype = 'zh' and labelbol = 'SCANTOADDPRODUCTS' and Labeltype = 'fixedstr';
UPDATE ld_desk set fieldlabel = 'Scan code to add products' where languagetype = 'en' and labelbol = 'SCANTOADDPRODUCTS' and Labeltype = 'fixedstr';
delimiter;
SET @labelbol = 'MULTIPLEPRODUCTSELECTION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'多选产品','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Multiple product selection','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PREVIOUSDATA','上期','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PREVIOUSDATA' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PREVIOUSDATA','Previous period data','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PREVIOUSDATA' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISPERIOD','本期','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THISPERIOD' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISPERIOD','Current period','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THISPERIOD' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel='<span style="color:black;line-height:40px;height:40px">单据没有严格参照源单录入数据，请修改之后，重新保存，其中：</span><br>####第{n}行{productname}#### 录入{columnname_deskvalue}->实际{columnname_dbvalue},####'
where labelbol='SaveBillStrictSourceTip' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='<span style="color:black;line-height:40px;height:40px">The document did not strictly reference the data entered in the source document. Please modify it and save it again. Among them:</span><br>####Line {n} {productname}####  Input {columnname_deskvalue}->Actual {columnname_dbvalue},####'
where labelbol='SaveBillStrictSourceTip' and Labeltype='fixedstr' and languagetype='en';
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE   PROCEDURE `account_singlerecycle_normal_rule`(new_normal_id 	int(11),
	new_pool_id 	int(11))
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
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
		ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    declare continue handler  for not   found  SET done =1;
    select ld_account_public_pool.userid_after_transfer into @allotaccount from ld_account_public_pool
		inner join ld_users on ld_users.id =ld_account_public_pool.userid_after_transfer where ld_account_public_pool.id = new_pool_id;
		if  ifnull(@allotaccount,0)=0  then 
			set @allotaccount=0;
	end if;
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule_normal.days) into @maxdays
			from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
			INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
			and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

			select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;
			set @account_rule_pool_id = new_pool_id;

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
							if @allotaccount>0 THEN
							set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				  end if;

    			ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
								set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;

						set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');

    		 end if;
    		prepare stmt from @TMPSQL_TWO;
    		execute stmt;
    		deallocate prepare stmt;

    	end if;
    END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule`(IN tmp_pool_id INT(11))
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and (ld_field.presence in(0,2) ) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
	where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

	select userid_after_release into @allotaccount from ld_account_public_pool inner join ld_users on ld_users.id=userid_after_release
			where ld_account_public_pool.id = tmp_pool_id;
	if  ifnull(@allotaccount,0)=0  then 
			set @allotaccount=0;
	end if;
	select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;

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

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );

				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;

	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then

			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id =  ',tmp_pool_id);

			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);

			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;

		else

				if @recycleselect is not null and @recycleselect<>'' then

					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
				ELSE
					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
				end if;

			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);

		end if;

	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;


    if var_condition='or'  then

			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
			end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'   group by ld_account.smownerid    ');
		end if;

     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();
    if @allotaccount>0 then
				select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
					on ld_related_field.effect_fieldid=ld_field.fieldid
					where ld_field.uitype=1600  )  as  tmp
					INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
					where ld_field.tabid=6 and ld_field.columnname='smownerid'
					and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;

				 select  tmp.columnname into @groupcolumnname  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
					on ld_related_field.effect_fieldid=ld_field.fieldid
					where ld_field.uitype=1600  )  as  tmp
					INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
					where ld_field.tabid=6 and ld_field.columnname='smownerid'
					and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;
        end if;
	if var_condition='or'  then

		 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		if @recycleselect<>'' and @recycleselect is not null THEN
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
		end if;
		set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		 if @allotaccount>0 THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
			end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
	ELSE

	  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);

						if   ifnull(@groupcolumnname,'')!='' then

								select GROUP_CONCAT(groupid) into @groupid from  ld_users2group where userid =@allotaccount;
								set @TMPSQL_GroupEditSql=concat( ' update  ',@grouptablename,' inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=',@grouptablename,'.accountid ') ;
								if @grouptablename!='ld_account' then
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' inner join ld_account on ld_account.accountid=ld_accountscf.accountid ');
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql, ' set ',@groupcolumnname,'="', @groupid,'"');

								end if ;
								set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
							prepare stmt1 from @TMPSQL_GroupEditSql;
							execute stmt1;
							deallocate prepare stmt1;
						end if;

end if;
  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
 end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
end ||
delimiter;

update ld_desk SET fieldlabel="Cashback Date"
WHERE languagetype="en" AND labelbol="cashbackdate" AND Labeltype="fixedstr";
update ld_desk SET fieldlabel="Send Payment"
WHERE languagetype="en" AND labelbol="Payment1" AND Labeltype="fixedstr";
delimiter;

update ld_desk set fieldlabel='数据简报' where  languagetype='zh' and labelbol='saleskit' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PREVIOUSDATA','上期','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PREVIOUSDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PREVIOUSDATA','Previous period data','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PREVIOUSDATA' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISPERIOD','本期','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THISPERIOD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISPERIOD','Current period','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THISPERIOD' and labeltype='fixedstr');
delimiter;

SET @labelbol = 'Rowheightsetting';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'表格行高设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Row height setting','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'compact';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'紧凑','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'compact','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'comfortable';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'舒适','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'comfortable','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'spacious';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'宽敞','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'spacious','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_usereportcolumns set realcolumns ='ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_源单已收总金额:N' where realcolumns='ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_源单已收总金额:V';
delimiter;
-- 2023-06-16

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

UPDATE ld_version SET old_version='V8.5.0.5',current_version='V8.5.0.5',remark='V8.5.0.5-20230616',wx_version='V8.5.0.4';
delimiter;