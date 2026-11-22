DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE PROCEDURE `addtableIndex`(tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50))
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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERCOMPANYNAME','请输入企业名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEENTERCOMPANYNAME' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERCOMPANYNAME','Please enter the company name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEENTERCOMPANYNAME' and Labeltype='fixedstr' and languagetype='en');
delimiter;

delete from ld_appsystem where deploy_type = 14 AND deploy_value = 'no';
delete from ld_appsystem where deploy_type = 14 AND deploy_value = 'yes';
delimiter;

UPDATE ld_producttoolfield SET typeofdata = 'V~M' , defaultcolumn = '2' WHERE columnname = 'batchtext';
delimiter;

SET @stufftitle = 'IncomeAndExpenditureReport';
set @stuffid=65;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show)
select @stuffid,@stufftitle,'saleskit','','','no','no' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');
delimiter;


SET @stufftitle = 'IncomeAndExpenditureReport';
set @stuffid=65;
update ld_homestuffdetail set
                              daterange='ld_purchaseorder:createdtime:createdtime:PurchaseOrder_fieldlabel:DT' ,
                              viewrange='ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',
                              compute_module='PurchaseOrder'
where stufflabel='TotalPurchaseContractAmount' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');


update ld_homestuffdetail set
                              daterange='ld_commission:createdtime:createdtime:Commission_fieldlabel:DT' ,
                              viewrange='ld_commission:smownerid:assigned_user_id:Commission_fieldlabel:V',
                              compute_module='Commission'
where stufflabel='TotalCommissionBill' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_sendcashbill:createdtime:createdtime:SendCashBill_fieldlabel:DT' ,
                              viewrange='ld_sendcashbill:smownerid:assigned_user_id:SendCashBill_fieldlabel:V',
                              compute_module='SendCashBill'
where stufflabel='TotalAmountPaid' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_expense:createdtime:createdtime:Expense_fieldlabel:DT' ,
                              viewrange='ld_expense:smownerid:assigned_user_id:Expense_fieldlabel:V',
                              compute_module='Expense'
where stufflabel='TotalAmountOfExpenseReimbursement' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_cashbill:createdtime:createdtime:CashBill_fieldlabel:DT' ,
                              viewrange='ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V',
                              compute_module='CashBill'
where stufflabel='ServiceContractsTotalReceived' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT' ,
                              viewrange='ld_servicecontracts:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V',
                              compute_module='ServiceContracts'
where stufflabel='ServiceContractsTotalBalanceReceivable' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:DT' ,
                              viewrange='ld_servicecontracts:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V',
                              compute_module='ServiceContracts'
where stufflabel='ServiceContractsHaveNotReceived' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_cashbill:createdtime:createdtime:CashBill_fieldlabel:DT' ,
                              viewrange='ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V',
                              compute_module='CashBill'
where stufflabel='SalesorderTotalReceived' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT' ,
                              viewrange='ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',
                              compute_module='SalesOrder'
where stufflabel='SalesorderTotalBalanceReceivable' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_salesorder:createdtime:createdtime:SalesOrder_fieldlabel:DT' ,
                              viewrange='ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',
                              compute_module='SalesOrder'
where stufflabel='SalesorderHaveNotReceived' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_invoice:createdtime:createdtime:Invoice_fieldlabel:DT' ,
                              viewrange='ld_invoice:smownerid:assigned_user_id:Invoice_fieldlabel:V',
                              compute_module='Invoice'
where stufflabel='SalesInvoicedAmount' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseback::createdtime:createdtime:PurchaseBack_fieldlabel:DT' ,
                              viewrange='ld_purchaseback:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V',
                              compute_module='PurchaseBack'
where stufflabel='RefundAmount' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseinvoice::createdtime:createdtime:PurchaseInvoice_fieldlabel:DT' ,
                              viewrange='ld_purchaseinvoice:smownerid:assigned_user_id:PurchaseInvoice_fieldlabel:V',
                              compute_module='PurchaseInvoice'
where stufflabel='PurchaseInvoicedAmount' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseorder:createdtime:createdtime:PurchaseOrder_fieldlabel:DT' ,
                              viewrange='ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V',
                              compute_module='PurchaseOrder'
where stufflabel='PurchaseBalancePayable' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_customform16:createdtime:createdtime:CustomForm16_fieldlabel:DT' ,
                              viewrange='ld_customform16:smownerid:assigned_user_id:CustomForm16_fieldlabel:V',
                              compute_module='CustomForm16'
where stufflabel='ProjectOutputValueConfirmationSheetAmount' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_customform15:createdtime:createdtime:CustomForm15_fieldlabel:DT' ,
                              viewrange='ld_customform15:smownerid:assigned_user_id:CustomForm15_fieldlabel:V',
                              compute_module='CustomForm15'
where stufflabel='PlannedQuantities' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_customform15:createdtime:createdtime:CustomForm15_fieldlabel:DT' ,
                              viewrange='ld_customform15:smownerid:assigned_user_id:CustomForm15_fieldlabel:V',
                              compute_module='CustomForm15'
where stufflabel='PlannedOutputValue' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');

update ld_homestuffdetail set
                              daterange='ld_purchaseback:createdtime:createdtime:PurchaseBack_fieldlabel:DT' ,
                              viewrange='ld_purchaseback:smownerid:assigned_user_id:PurchaseBack_fieldlabel:V',
                              compute_module='PurchaseBack'
where stufflabel='HaveRefundAmount' and stuffid=@stuffid
  and  exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='saleskit');


delimiter;

UPDATE ld_cvcolumnlistsort SET columnname = 'ld_reminds:date_time:date_time:Reminds_DT~O:fieldlabel'
WHERE cvid=108 AND columnname='ld_reminds:modifiedtime:modifiedtime:Reminds_DT~O:fieldlabel';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOBEADD','待添加','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOBEADD' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOBEADD','To be add','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOBEADD' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'LINGDANGHUOKE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'灵当获客',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Lingdang captures guests',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'SharedUsers';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'共享人',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Shared Users',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

set @tabid = (SELECT tabid from ld_tab where name = 'CollectionSlip');
UPDATE ld_tabdetailfield set defaultcolumn = 0 where tabid = @tabid and columnname = 'line_project_id';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GetStaging','获取暂存信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GetStaging' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GetStaging','Get Staging Info','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GetStaging' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotStaging','没有暂存信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotStaging' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotStaging','No staging information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotStaging' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LoadLocalStorage','确定后，将会覆盖现有信息，是否继续？','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LoadLocalStorage' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LoadLocalStorage','After confirmation, the existing information will be overwritten. Do you want to continue?','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LoadLocalStorage' and labeltype='fixedstr' and languagetype='en');
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'Salary' limit 1);
set @blockid = (SELECT blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SALARYOTHERPAYABLE_INFO' limit 1);
set @cnt = (SELECT COUNT(1) from ld_tranlabel where tabid = @tabid and languagetype = 'en' and trantable = 'ld_blocks' and Relateid = @blockid limit 1);
set @deleted_id = (SELECT tranlabelid from ld_tranlabel where tabid = @tabid and languagetype = 'en' and trantable = 'ld_blocks' and Relateid = @blockid limit 1);
DELETE from ld_tranlabel where tranlabelid = @deleted_id and @deleted_id >0 and @cnt >1 ;
delimiter;

CALL addtableIndex('ld_competition','createdtime','createdtime');
CALL addtableIndex('ld_competition','modifiedtime','modifiedtime');
call addtableIndex('ld_competition','deleted','deleted');
CALL addtableIndex('ld_competition','smownerid','smownerid');
CALL addtableIndex('ld_competition','smcreatorid','smcreatorid');

CALL addtableIndex('ld_laborcontract','createdtime','createdtime');
CALL addtableIndex('ld_laborcontract','modifiedtime','modifiedtime');
call addtableIndex('ld_laborcontract','deleted','deleted');
CALL addtableIndex('ld_laborcontract','smownerid','smownerid');
CALL addtableIndex('ld_laborcontract','smcreatorid','smcreatorid');

CALL addtableIndex('ld_personnelfile','createdtime','createdtime');
CALL addtableIndex('ld_personnelfile','modifiedtime','modifiedtime');
call addtableIndex('ld_personnelfile','deleted','deleted');
CALL addtableIndex('ld_personnelfile','smownerid','smownerid');
CALL addtableIndex('ld_personnelfile','smcreatorid','smcreatorid');

CALL addtableIndex('ld_salary','createdtime','createdtime');
CALL addtableIndex('ld_salary','modifiedtime','modifiedtime');
call addtableIndex('ld_salary','deleted','deleted');
CALL addtableIndex('ld_salary','smownerid','smownerid');
CALL addtableIndex('ld_salary','smcreatorid','smcreatorid');

CALL addtableIndex('ld_collectionslip','createdtime','createdtime');
CALL addtableIndex('ld_collectionslip','modifiedtime','modifiedtime');
call addtableIndex('ld_collectionslip','deleted','deleted');
CALL addtableIndex('ld_collectionslip','smownerid','smownerid');
CALL addtableIndex('ld_collectionslip','smcreatorid','smcreatorid');
delimiter;

UPDATE ld_desk set fieldlabel='已自动生成{$PaymentPlan.PaymentPlan}' WHERE labelbol='AUTOCREATEPAYMENTPLANTIP' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Automatically generated {$PaymentPlan.PaymentPlan}' WHERE labelbol='AUTOCREATEPAYMENTPLANTIP' and languagetype='en' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='已自动生成{$SendPayment.SendPayment}' WHERE labelbol='AUTOCREATESENDPAYMENTTIP' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Automatically generated {$SendPayment.SendPayment}' WHERE labelbol='AUTOCREATESENDPAYMENTTIP' and languagetype='en' and labeltype='fixedstr';
delimiter;

UPDATE ld_desk set fieldlabel='设置系统登录时密码连续输错{n}次后，不允许登录的限制时长（为空表示不限制时长，允许登录）' WHERE labelbol='PwdErrorAllowTimes' and languagetype='zh' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','beforevardays','{Var}天前','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='beforevardays' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','beforevardays','{Var} days ago','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='beforevardays' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','lastvardays','过去{Var}天','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='lastvardays' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','lastvardays','last {Var} days','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='lastvardays' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','nextvardays','未来{Var}天','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='nextvardays' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','nextvardays','next {Var} days','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='nextvardays' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','aftervardays','{Var}天后','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='aftervardays' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','aftervardays','{Var} days later','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='aftervardays' and labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2024-06-14

DROP PROCEDURE IF EXISTS `ldcrm_add_holiday`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_holiday`(
	tmp_name VARCHAR(100),
	tmp_date DATE,
	tmp_type VARCHAR(10)
)
BEGIN


		SET @autoadd_module='Holiday';
		SET @tmp_date=tmp_date;

		SET @tmp_title=CONCAT(DATE_FORMAT(tmp_date,'%Y年'),tmp_name,IF(tmp_type='休','放','补'),'假');
		
		IF NOT EXISTS (SELECT 1 FROM ld_holiday WHERE deleted=0 AND holiday_date=@tmp_date) THEN
			SET @autoadd_maxcrmid=(SELECT MAX(crmid) FROM ld_crmentity);
			INSERT INTO ld_crmentity(crmid,setype)
			SELECT @autoadd_maxcrmid+1,@autoadd_module;
			UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);

			INSERT INTO ld_holiday(
				holidayid,
				holidayno,

				
				holiday_title,
				holiday_name,
				holiday_date,
				wheatherholidays,
				holiday_type,
				deleted,
				
				smownerid,					
				smcreatorid,				
				modifiedby,					
				createdtime,				
				modifiedtime
			)
			SELECT
				@autoadd_maxcrmid+1,
				(SELECT CONCAT(prefix,cur_id) FROM ld_modentity_num WHERE semodule=@autoadd_module AND active=1),

				@tmp_title,
				tmp_name,
				tmp_date,
				tmp_type,
				'法定节假日',
				0,
				
				1,					
				1,				
				1,					
				NOW(),				
				NOW();
		
			UPDATE ld_modentity_num SET cur_id=cur_id+1 WHERE semodule=@autoadd_module AND active=1;

			INSERT INTO ld_holidayscf(holidayid) SELECT @autoadd_maxcrmid+1;

	END IF;
			
END ||
delimiter;

INSERT INTO ld_crmentity(crmid,setype)
SELECT holidayid,'Holiday' FROM ld_holiday 
WHERE holidayid NOT IN (SELECT crmid FROM ld_crmentity WHERE setype='Holiday')
	AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid=ld_holiday.holidayid);

CALL ldcrm_add_holiday('国庆节','2024-10-07','休');
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

UPDATE ld_version SET old_version='V8.6.3.3.4',current_version='V8.6.3.3.4',remark='V8.6.3.3.4-20240614',wx_version='V8.6.3.7';
delimiter;