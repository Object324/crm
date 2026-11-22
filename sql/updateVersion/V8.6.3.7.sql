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
select 'zh','Renew','续签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Renew' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Renew',"Renew",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Renew' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RENEWEDSUCCESSFULLY','成功续签!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RENEWEDSUCCESSFULLY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RENEWEDSUCCESSFULLY',"Renewed successfully!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RENEWEDSUCCESSFULLY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RENEWEDUNSUCCESSFULLY','续签失败! 原因：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RENEWEDUNSUCCESSFULLY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RENEWEDUNSUCCESSFULLY',"Renewed unsuccessfully! Reason :",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RENEWEDUNSUCCESSFULLY' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RENEWEDCONTRACTSCONTINUETIP','该服务合同已续签，是否继续?','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RENEWEDCONTRACTSCONTINUETIP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RENEWEDCONTRACTSCONTINUETIP','The service contract has been renewed. Do you want to continue?','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RENEWEDCONTRACTSCONTINUETIP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTRENEWEDCONTRACTS','当前产品分录没有{Var}字段，无法进行续签','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CANNOTRENEWEDCONTRACTS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTRENEWEDCONTRACTS','The current product entry does not have a field named {Var} and cannot be renewed','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CANNOTRENEWEDCONTRACTS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_servicecontracts','renewed','varchar','10','no');
delimiter;

call AddColumn('ld_servicecontracts','renewfrom','varchar','20','');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_Renew`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_Renew`(
)
BEGIN
	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	IF NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname = 'Renew') THEN
			-- 增加续签
			SET @actionid = (SELECT max(actionid) FROM ld_actionmapping)+1;
INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @actionid,'Renew',0,'Renew' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname = 'Renew');
-- 总表增加续签
SET @renew_operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='Renew');
			SET @copy_operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='Copy');
			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
			SET @desequence = (SELECT sequence FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@copy_operation);
UPDATE ld_profileallpermission SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@desequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT @tabid,@renew_operation,@desequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@renew_operation);
-- 增加角色续签权限
IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation = @renew_operation) THEN
				OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
					SET @profileid=tmp_profileid;
					IF EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@copy_operation AND profileid=@profileid) THEN
						INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid AS profileid,@tabid AS tabid,@renew_operation,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@renew_operation AND profileid=@profileid)
    LIMIT 1;
END IF;
FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_default_Renew();
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_Renew`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERCOMPANYNAME','请输入企业名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEENTERCOMPANYNAME' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERCOMPANYNAME','Please enter the company name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PLEASEENTERCOMPANYNAME' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2024-06-01

update ld_desk set fieldlabel = '最近访问' where labelbol = 'CommonFunctions' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Recently visited' where labelbol = 'CommonFunctions' and languagetype = 'en';
delimiter;

call AddColumn('ld_crmlog_entity','crmid','int','20','');
delimiter;

UPDATE ld_crmlog_entity INNER JOIN ld_crmlog_create ON ld_crmlog_entity.id = ld_crmlog_create.id SET ld_crmlog_entity.crmid = ld_crmlog_create.crmid WHERE ld_crmlog_entity.actiontype = 'Create';
delimiter;

UPDATE ld_crmlog_entity INNER JOIN ld_crmlog_edit ON ld_crmlog_entity.id = ld_crmlog_edit.id SET ld_crmlog_entity.crmid = ld_crmlog_edit.crmid WHERE ld_crmlog_entity.actiontype = 'Edit';
delimiter;

UPDATE ld_crmlog_entity INNER JOIN ld_crmlog_share ON ld_crmlog_entity.id = ld_crmlog_share.id SET ld_crmlog_entity.crmid = ld_crmlog_share.crmid WHERE ld_crmlog_entity.actiontype = 'Share';
delimiter;

UPDATE ld_crmlog_entity as entity INNER JOIN ld_crmlog_delete ON entity.id = ld_crmlog_delete.id SET entity.crmid = ld_crmlog_delete.crmid
WHERE entity.actiontype = 'Delete' or entity.actiontype = 'Reduction' or entity.actiontype = 'Merge';
delimiter;

UPDATE ld_crmlog_entity as entity INNER JOIN ld_logpublicaccount ON entity.relatedid = ld_logpublicaccount.id SET entity.crmid = ld_logpublicaccount.accountid 
WHERE entity.actiontype = 'Transfer' or entity.actiontype = 'Distribute' or entity.actiontype = 'Receuve' or entity.actiontype = 'Release' or entity.actiontype = 'Delay'
AND entity.module = 'Accounts';
delimiter;

UPDATE ld_crmlog_entity as entity INNER JOIN ld_logpublicleads ON entity.relatedid = ld_logpublicleads.id SET entity.crmid = ld_logpublicleads.leadsid 
WHERE entity.actiontype = 'Transfer' or entity.actiontype = 'Distribute' or entity.actiontype = 'Receuve' or entity.actiontype = 'Release' or entity.actiontype = 'Delay'
AND entity.module = 'Leads';
delimiter;

UPDATE ld_crmlog_entity as entity INNER JOIN ld_modtracker_basic ON entity.relatedid = ld_modtracker_basic.id SET entity.crmid = ld_modtracker_basic.crmid WHERE entity.actiontype = 'Allocate';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_relatedlists_get_viewhistory`;
delimiter ||
CREATE PROCEDURE `ldcrm_relatedlists_get_viewhistory`(
)
BEGIN
	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_presence INT(1) DEFAULT 0;
	DECLARE tmp_actions VARCHAR(100) DEFAULT '';
	DECLARE tmp_mobile_presence INT(1) DEFAULT 0;
	DECLARE tmp_wx_presence INT(1) DEFAULT 0;
	DECLARE tmp_buttonstatus VARCHAR(20) DEFAULT '';
	DECLARE tmp_type VARCHAR(100) DEFAULT '';
	DECLARE tmp_related_coltable VARCHAR(100) DEFAULT '';


	DECLARE MYCUSOR CURSOR FOR
SELECT tabid,presence,actions,mobile_presence,type,related_coltable,wx_presence,buttonstatus FROM ld_relatedlists WHERE related_tabid=-7 and `name`='get_viewhistory' and label='ViewHistory';
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_tabid,tmp_presence,tmp_actions,tmp_mobile_presence,tmp_type,tmp_related_coltable,tmp_wx_presence,tmp_buttonstatus;
WHILE(tmp_tabid IS NOT NULL) DO
			SET @sequence=(SELECT (sequence) FROM ld_relatedlists WHERE tabid=tmp_tabid and related_tabid=-7);
			SET @mobile_sequence=(SELECT MAX(mobile_sequence) FROM ld_relatedlists WHERE tabid=tmp_tabid);
			SET @wx_sequence=(SELECT MAX(wx_sequence) FROM ld_relatedlists WHERE tabid=tmp_tabid);
			SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);

			IF NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=tmp_tabid and related_tabid=-19 and `name`='get_operationlogs' and label='OperationLogs') THEN
				UPDATE ld_relatedlists SET sequence = sequence+1 WHERE tabid=tmp_tabid and sequence > @sequence;
			
				INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,buttonstatus)
				SELECT @maxrelation_id+1,tmp_tabid,'-19','get_operationlogs',@sequence+1,'OperationLogs',0,tmp_actions,0,@mobile_sequence+1,tmp_type,tmp_related_coltable,0,@wx_sequence+1,tmp_buttonstatus FROM DUAL;
			END IF;
            FETCH MYCUSOR INTO tmp_tabid,tmp_presence,tmp_actions,tmp_mobile_presence,tmp_type,tmp_related_coltable,tmp_wx_presence,tmp_buttonstatus;

						
END WHILE;
CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_relatedlists_get_viewhistory();
DROP PROCEDURE IF EXISTS `ldcrm_relatedlists_get_viewhistory`;
delimiter;

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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


delete from ld_appsystem where deploy_type = 14 AND deploy_value = 'no';
delete from ld_appsystem where deploy_type = 14 AND deploy_value = 'yes';
delimiter;

UPDATE ld_producttoolfield SET typeofdata = 'V~M' , defaultcolumn = '2' WHERE columnname = 'batchtext';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WordTemplateSupportFile','打印Word模版，支持文件类型：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WordTemplateSupportFile' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WordTemplateSupportFile','Word printing template, supporting file types: ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WordTemplateSupportFile' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExcelTemplateSupportFile','打印Excel模版，支持文件类型：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExcelTemplateSupportFile' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExcelTemplateSupportFile','Excel printing template, supporting file types: ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExcelTemplateSupportFile' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_templateprint','modifiedby','int','4','');
delimiter;

call AddColumn('ld_templateprint','modifiedtime','datetime','','');
delimiter;

UPDATE ld_templateprint SET modifiedby = 1,modifiedtime = NOW() WHERE modifiedtime IS NULL;
delimiter;
-- 2024-06-04

UPDATE ld_desk SET fieldlabel='多个关键字用竖线“|”分隔' WHERE labelbol='SEARCHBELONGTIP' AND languagetype='zh';
delimiter;

UPDATE ld_cvcolumnlistsort SET columnname = 'ld_reminds:date_time:date_time:Reminds_DT~O:fieldlabel'
WHERE cvid=108 AND columnname='ld_reminds:modifiedtime:modifiedtime:Reminds_DT~O:fieldlabel';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','menudeletesearchhistorytip','确定要删除所有删除历史吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='menudeletesearchhistorytip' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','menudeletesearchhistorytip','Are you sure you want to delete all deletion history?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='menudeletesearchhistorytip' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LatestModifiedby','最新修改人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LatestModifiedby' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LatestModifiedby','Latest Modified by','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LatestModifiedby' and Labeltype='fixedstr' and languagetype='en');
delimiter;


update ld_linkmodulecustom set `name`='KingdeeStockSearch' where url='index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=stock_report';
delimiter;

update ld_picklist_set set parent_listname = 'userlevel',parent_relatetable='ld_field' where listname = 'personnelfile_rank' and relatetable = 'ld_field' and ifnull(parent_listname,'') = '';
delimiter;
-- 2024-06-05

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOBEADD','待添加','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOBEADD' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOBEADD','To be add','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOBEADD' and Labeltype='fixedstr' and languagetype='en');
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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VALUENONE','无','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VALUENONE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VALUENONE',"none",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VALUENONE' and labeltype='fixedstr');
delimiter;

CALL AddPrimaryKey('ld_purchaseinvoicecf','purchaseinvoiceid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PresetTemplate','预制模板','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PresetTemplate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PresetTemplate','preset template','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PresetTemplate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='预制模版不存在或已被删除' WHERE labelbol='PresetTemplateDeleted' and languagetype='zh' and Labeltype='jspop';
delimiter;


set @tabid = (SELECT tabid from ld_tab where `name` = 'Salary' limit 1);
set @blockid = (SELECT blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SALARYOTHERPAYABLE_INFO' limit 1);
set @cnt = (SELECT COUNT(1) from ld_tranlabel where tabid = @tabid and languagetype = 'en' and trantable = 'ld_blocks' and Relateid = @blockid limit 1);
set @deleted_id = (SELECT tranlabelid from ld_tranlabel where tabid = @tabid and languagetype = 'en' and trantable = 'ld_blocks' and Relateid = @blockid limit 1);
DELETE from ld_tranlabel where tranlabelid = @deleted_id and @deleted_id >0 and @cnt >1 ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Renew','续签','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Renew' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Renew',"Renew",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Renew' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RENEWEDSUCCESSFULLY','成功续签!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RENEWEDSUCCESSFULLY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RENEWEDSUCCESSFULLY',"Renewed successfully!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RENEWEDSUCCESSFULLY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RENEWEDUNSUCCESSFULLY','续签失败! 原因：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RENEWEDUNSUCCESSFULLY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RENEWEDUNSUCCESSFULLY',"Renewed unsuccessfully! Reason :",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RENEWEDUNSUCCESSFULLY' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RENEWEDCONTRACTSCONTINUETIP','该服务合同已续签，是否继续?','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RENEWEDCONTRACTSCONTINUETIP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RENEWEDCONTRACTSCONTINUETIP','The service contract has been renewed. Do you want to continue?','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'RENEWEDCONTRACTSCONTINUETIP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTRENEWEDCONTRACTS','当前产品分录没有{Var}字段，无法进行续签','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CANNOTRENEWEDCONTRACTS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTRENEWEDCONTRACTS','The current product entry does not have a field named {Var} and cannot be renewed','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'CANNOTRENEWEDCONTRACTS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_servicecontracts','renewed','varchar','10','no');
delimiter;

call AddColumn('ld_servicecontracts','renewfrom','varchar','20','');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_Renew`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_Renew`(
)
BEGIN
	DECLARE tmp_profileid INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	IF NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname = 'Renew') THEN
			-- 增加续签
			SET @actionid = (SELECT max(actionid) FROM ld_actionmapping)+1;
INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @actionid,'Renew',0,'Renew' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname = 'Renew');
-- 总表增加续签
SET @renew_operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='Renew');
			SET @copy_operation=(SELECT actionid FROM ld_actionmapping WHERE actionname='Copy');
			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
			SET @desequence = (SELECT sequence FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@copy_operation);
UPDATE ld_profileallpermission SET sequence=sequence+1 WHERE tabid=@tabid AND sequence>@desequence;
INSERT INTO ld_profileallpermission(tabid,operation,sequence) SELECT @tabid,@renew_operation,@desequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@renew_operation);
-- 增加角色续签权限
IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation = @renew_operation) THEN
				OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
					SET @profileid=tmp_profileid;
					IF EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@copy_operation AND profileid=@profileid) THEN
						INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT @profileid AS profileid,@tabid AS tabid,@renew_operation,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND operation=@renew_operation AND profileid=@profileid)
    LIMIT 1;
END IF;
FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_default_Renew();
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_Renew`;
delimiter;

UPDATE ld_desk set fieldlabel='设置系统登录时密码连续输错{n}次后，不允许登录的限制时长（为空表示不限制时长，允许登录）' WHERE labelbol='PwdErrorAllowTimes' and languagetype='zh' and labeltype='fixedstr';
delimiter;
-- 2024-06-09

CREATE TABLE IF NOT EXISTS `ld_employment` (
    `employment_id` int(11) NOT NULL,
    `employment_no` varchar(100) DEFAULT NULL,
    `smownerid` Int(11) NOT NULL,
    `smcreatorid` Int(11),
    `createdtime` datetime ,
    `employment_name` varchar(100),
    `employment_joineddate` Date,
    `employment_position` Varchar(100),
    `employment_expirationdate` Date,
    `employment_group` text,
    `employment_phone` Varchar(30),
    `employment_salary` decimal(25,8),
    `employment_idcard` varchar(100),
    `employment_signing` varchar(100),
    `employment_state` varchar(100),
    `employment_residence` text,
    `employment_emergencyname` varchar(100),
    `employment_emergencycontact` varchar(30),
    `employment_description` text,
    `modifiedby` Int(11),
    `modifiedtime` datetime,
    `approvestatus` Varchar(200),
    `approvetime` Datetime,
    `approveby` Int(11),
    `currentapprover` Varchar(1000),
    `latestpushtime` Datetime,
    `advance_stage` Varchar(100),
    `exchtime` Datetime,
    `exchmsg` text,
    `team_memberid` text,
    `tag` text,
    `print_times` int(11),
    `approvesubmitter` int(11),
    `approvesubmittedtime` Datetime,
    `currentapprovestepid` int(19),
    `approveurgent` Varchar(10),
    `approveexpediting` Varchar(10) ,
    `kis_id` varchar(200) ,
    `kis_no` varchar(100) ,
    PRIMARY KEY (`employment_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_employmentscf` (
    `employment_id` int(11) NOT NULL,
    PRIMARY KEY (`employment_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

call AddColumn('ld_employment','deleted','int',4,0);

set @modulename='Employment';
set @tablename='ld_employment';
SELECT max(tabid) INTO @maxtabid FROM	ld_tab;
SELECT max(tabsequence) INTO @maxtabsequence FROM ld_tab ;
INSERT INTO ld_tab (
    tabid,NAME,presence,tabsequence,tablabel,parent,printtab,isduplicate
)
SELECT
        @maxtabid + 1,@modulename,0 ,@maxtabsequence + 1,@modulename,null,1,'yes'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE NAME = @modulename);


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_LABEL', 1
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_LABEL' );

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_EMPLOYMENT_INFO', 2
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_EMPLOYMENT_INFO' );

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT  @blockid,@tabid,'LBL_DESCRIPTION_INFORMATION', 3
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_DESCRIPTION_INFORMATION' );

update ld_blocks_seq set id=@blockid;

select deploy_value INTO @decimalplace from ld_systems_deploy where deploy_type=351;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_EMPLOYMENT_INFO';

set @columnname='employment_no';
set @fieldname='employment_no';
set @zh='单据编号';
set @uitype=4;
set @bigtype='moduleno';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=1;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smownerid';
set @fieldname='assigned_user_id';
set @zh='负责人';
set @uitype=53;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smcreatorid';
set @fieldname='smcreatorid';
set @zh='创建人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='createdtime';
set @fieldname='createdtime';
set @zh='创建时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_name';
set @fieldname='employment_name';
set @zh='姓名';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_joineddate';
set @fieldname='employment_joineddate';
set @zh='入职日期';
set @uitype=5;
set @bigtype='date';
set @readonly=0;
set @presence=2;
set @defaultvalue='thistoday';
set @displaytype=1;
set @typeofdata='D~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_position';
set @fieldname='employment_position';
set @zh='岗位';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_expirationdate';
set @fieldname='employment_expirationdate';
set @zh='合同到期日';
set @uitype=5;
set @bigtype='date';
set @readonly=0;
set @presence=2;
set @defaultvalue='oneyear';
set @displaytype=1;
set @typeofdata='D~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_group';
set @fieldname='employment_group';
set @zh='部门';
set @uitype=180;
set @bigtype=NULL;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_phone';
set @fieldname='employment_phone';
set @zh='手机';
set @uitype=1101;
set @bigtype='mobile';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_salary';
set @fieldname='employment_salary';
set @zh='工资';
set @uitype=71;
set @bigtype='currency';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
SET @typeofdata=concat('N~O~25,',@decimalplace);
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_idcard';
set @fieldname='employment_idcard';
set @zh='身份证';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_signing';
set @fieldname='employment_signing';
set @zh='合同签署';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_state';
set @fieldname='employment_state';
set @zh='状态';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_residence';
set @fieldname='employment_residence';
set @zh='现居住地';
set @uitype=19;
set @bigtype='textarea';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_emergencyname';
set @fieldname='employment_emergencyname';
set @zh='紧急联系人';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='employment_emergencycontact';
set @fieldname='employment_emergencycontact';
set @zh='紧急联系人电话';
set @uitype=1101;
set @bigtype='mobile';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedby';
set @fieldname='modifiedby';
set @zh='更新人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedtime';
set @fieldname='modifiedtime';
set @zh='更新时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvestatus';
set @fieldname='approvestatus';
set @zh='审批状态';
set @uitype=609;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvetime';
set @fieldname='approvetime';
set @zh='最新审批时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approveby';
set @fieldname='approveby';
set @zh='上一步审批人';
set @uitype=131;
set @bigtype=NULL;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='currentapprover';
set @fieldname='currentapprover';
set @zh='当前审批人';
set @uitype=132;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='latestpushtime';
set @fieldname='latestpushtime';
set @zh='最新推进时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='advance_stage';
set @fieldname='advance_stage';
set @zh='推进阶段';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='exchtime';
set @fieldname='exchtime';
set @zh='最新同步时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='exchmsg';
set @fieldname='exchmsg';
set @zh='最新同步结果';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='team_memberid';
set @fieldname='team_memberid';
set @zh='团队成员';
set @uitype=154;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='tag';
set @fieldname='tag';
set @zh='标签';
set @uitype=301;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='print_times';
set @fieldname='print_times';
set @zh='打印次数';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';

set @columnname='employment_description';
set @fieldname='employment_description';
set @zh='备注';
set @uitype=19;
set @bigtype='textarea';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=1;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=@seq;


INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'employment_signing', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='employment_signing');
set @listid = (select listid  from ld_picklist_set where listname ='employment_signing');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '劳动合同', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='劳动合同' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '劳务合同', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='劳务合同' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '未签署合同', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='未签署合同' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'employment_state', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='employment_state');
set @listid = (select listid  from ld_picklist_set where listname ='employment_state');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '在职', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='在职' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '未到', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='未到' and listid =@listid);


DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_bymodule`(
    tmp_modulename VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);

	IF @tabid>0 THEN
SELECT MAX(blockid) into @maxid FROM ld_blocks;
SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=@tabid;
SET @trantable='ld_blocks';
		SET @blocklabel='LBI_ATTACHMENT_FILE';
		SET @zh='附件信息';
		SET @en='Attachments Information';
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
SELECT @maxid+1,@tabid,@blocklabel,@maxseq+1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

SET @maxseq=0;
SELECT MAX(fieldid) INTO @maxid FROM ld_field;
SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=@tabid AND block=@relateid;
SET @trantable='ld_field';
		SET @tmptablename='ld_attachments';
		SET @columnname='filename';
		SET @fieldname='filename';
		SET @zh='附件';
		SET @en='Attachment';
		SET @uitype=1109;

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,editpage)
SELECT @tabid,@maxid+1,@columnname,@tmptablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment','listview' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tmptablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

CALL getallprofile(tmp_modulename);
CALL fieldprofile(tmp_modulename);

END IF;

end ||
delimiter;
CALl ldcrm_add_attachments_filename_bymodule(@modulename);

INSERT INTO ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab' ,@tabid ,@tabid,'入职申请' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'zh'
                                     AND trantable = 'ld_tab'
    );

INSERT INTO ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab' ,@tabid ,@tabid,'Employment application' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'en'
                                     AND trantable = 'ld_tab'
    );

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_LABEL');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '标签' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Tag' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_EMPLOYMENT_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '备注信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Description Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_no' LIMIT 1);
SET @trantable='ld_field';
SET @zh='单据编号';
SET @en='Employment No';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_name' LIMIT 1);
SET @trantable='ld_field';
SET @zh='姓名';
SET @en='Name';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='负责人';
SET @en='Owner';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建人';
SET @en='Creator';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建时间';
SET @en='Created Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_joineddate' LIMIT 1);
SET @trantable='ld_field';
SET @zh='入职日期';
SET @en='Boarding Date';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_position' LIMIT 1);
SET @trantable='ld_field';
SET @zh='岗位';
SET @en='Job Title';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_expirationdate' LIMIT 1);
SET @trantable='ld_field';
SET @zh='合同到期日';
SET @en='Contract expiration date';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_group' LIMIT 1);
SET @trantable='ld_field';
SET @zh='部门';
SET @en='Department';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_phone' LIMIT 1);
SET @trantable='ld_field';
SET @zh='手机';
SET @en='Mobile phone';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_salary' LIMIT 1);
SET @trantable='ld_field';
SET @zh='工资';
SET @en='Salary';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_idcard' LIMIT 1);
SET @trantable='ld_field';
SET @zh='身份证';
SET @en='ID card';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_signing' LIMIT 1);
SET @trantable='ld_field';
SET @zh='合同签署';
SET @en='Contract signing';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_state' LIMIT 1);
SET @trantable='ld_field';
SET @zh='状态';
SET @en='State';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_residence' LIMIT 1);
SET @trantable='ld_field';
SET @zh='现居住地';
SET @en='Current residence';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_emergencyname' LIMIT 1);
SET @trantable='ld_field';
SET @zh='紧急联系人';
SET @en='Emergency contact';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_emergencycontact' LIMIT 1);
SET @trantable='ld_field';
SET @zh='紧急联系人电话';
SET @en='Emergency contact number';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新更新人';
SET @en='Modified By';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='更新时间';
SET @en='Modified Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus' LIMIT 1);
SET @trantable='ld_field';
SET @zh='审批状态';
SET @en='Approve Status';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新审批时间';
SET @en='Last Approval Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='上一步审批人';
SET @en='The Last Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover' LIMIT 1);
SET @trantable='ld_field';
SET @zh='当前审批人';
SET @en='Current Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新推进时间';
SET @en='Latest push time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage' LIMIT 1);
SET @trantable='ld_field';
SET @zh='推进阶段';
SET @en='Advance Stage';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='employment_description' LIMIT 1);
SET @trantable='ld_field';
SET @zh='备注';
SET @en='Description';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @parenttabid = (select parenttabid from ld_parenttab where parenttab_label='RenShiGuanLi');
set @sequence = (select sequence from ld_parenttabrel left join ld_tab on ld_parenttabrel.tabid=ld_tab.tabid where parenttabid=@parenttabid and ld_tab.name='Personnelfile' and tab_tablename = 'ld_tab');
UPDATE ld_parenttab SET sequence = sequence + 1 WHERE  parenttabid = @parenttabid and sequence >= @sequence  and NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid =@tabid
                                        AND tab_tablename = 'ld_tab'
    );

INSERT INTO ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename)
SELECT @parenttabid,@tabid,@sequence-1,'ld_tab' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid =@tabid
                                        AND tab_tablename = 'ld_tab'
    );

SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (
    cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence
) SELECT
          @maxcvid + 1,'All',1,0,@modulename,3,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype =@modulename AND viewname = 'All');

SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = @modulename AND viewname = 'All' );
INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,0,CONCAT('ld_',LOWER(@modulename),':','employment_no',':','employment_no',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,1,CONCAT('ld_',LOWER(@modulename),':','employment_name',':','employment_name',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,2,CONCAT('ld_',LOWER(@modulename),':','employment_state',':','employment_state',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,3,CONCAT('ld_',LOWER(@modulename),':','employment_joineddate',':','employment_joineddate',':',@modulename,'_fieldlabel:DT')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,4,CONCAT('ld_',LOWER(@modulename),':','employment_expirationdate',':','employment_expirationdate',':',@modulename,'_fieldlabel:DT')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,5,CONCAT('ld_',LOWER(@modulename),':','smownerid',':','asssigned_uesr_id',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,6,CONCAT('ld_',LOWER(@modulename),':','smcreatorid',':','smcreatorid',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);

SET @modentity_num_seq = (select id+1 from ld_modentity_num_seq);
INSERT INTO `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`)
select @modentity_num_seq, @modulename, 'EA', '1', '1', '1', 'none', 0, 0, 0  from dual where not exists (select 1 from ld_modentity_num where  semodule =@modulename);
update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;
INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
SELECT @tabid, @modulename, @tablename, 'employment_no', 'employment_id', 'employment_id' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 1, 1 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=1);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 2, 2 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=2 );
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 3, 3  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=3);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 4, 4  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=4);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 5, 5  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=5);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 6, 6  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=6);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 11, 7  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=11);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 12, 8  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=12);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 13, 9  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=13);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 14, 10  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=14);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 22, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=22);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 25, 11  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=25);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 37, 12  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=37);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 57, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=57);

INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 1,0,1 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=1 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 2,0,2 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=2 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 3,0,3 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=3 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 4,0,4 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=4 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 5,0,5 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=5 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 6,0,6 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=6 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 11,0,7 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=11 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 12,0,8 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=12 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 13,0,9 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=13 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 14,0,10 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=14 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 22,0,11 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=22 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 25,0,12 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=25 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 37,0,13 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=37 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 57,0,14 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=57 and profileid=1);

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;
	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);

SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;

UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

END IF;

end ||
delimiter;
CALL ldcrm_add_approveforbill(@modulename,479);

drop PROCEDURE  if EXISTS update_validatarule;
delimiter ||
create PROCEDURE update_validatarule
(
)
BEGIN
	declare var_validataid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_validatasave where validatasavetype = 'php' and isshowlist = 'no' AND IFNULL(validatasavemainid,0) = 0;
declare continue handler  for not found  SET done =1;

open cur1;
Fetch cur1 into var_validataid;
loop1: while  done<>1 DO
				INSERT into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence,isshowlist)
SELECT rulename,module,`status`,case when allowsave = 'no' then 'yes' ELSE 'no' END,tipzh,tipen,'',validatacheckbutton,relatedtable,sequence,'no' from ld_validatasave where id = var_validataid;
SELECT MAX(id) into @max_mainid from ld_validatasavemain;

UPDATE ld_validatasave SET conditiongroupid = 1,validatasavemainid = @max_mainid where id = var_validataid;
Fetch cur1 into var_validataid;
end while loop1;
close cur1;
end ||
delimiter;
call update_validatarule();
drop PROCEDURE if EXISTS update_validatarule;

update ld_tab set mobilepresence='weixin' where tabid =@tabid;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
    tmp_module VARCHAR(100),
    tmp_column VARCHAR(100),
    tmp_rownum INT(1),
    tmp_colnum INT(1),
    tmp_showtag VARCHAR(20),
    tmp_sysdefault VARCHAR(20)
        )
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'employment_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'smownerid','3','1','yes','yes');

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`=@modulename);
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;


CREATE TABLE IF NOT EXISTS `ld_resignation` (
    `resignation_id` int(11) NOT NULL,
    `resignation_no` varchar(100) DEFAULT NULL,
    `smownerid` Int(11) NOT NULL,
    `smcreatorid` Int(11),
    `createdtime` datetime ,
    `resignation_group` varchar(255),
    `resignation_resigndate` Date,
    `resignation_type` Varchar(100),
    `resignation_handover` Varchar(3),
    `resignation_handoversituation` text,
    `resignation_suspendinsurance` Varchar(100),
    `resignation_reason` text,
    `resignation_description` text,
    `modifiedby` Int(11),
    `modifiedtime` datetime,
    `approvestatus` Varchar(200),
    `approvetime` Datetime,
    `approveby` Int(11),
    `currentapprover` Varchar(1000),
    `latestpushtime` Datetime,
    `advance_stage` Varchar(100),
    `exchtime` Datetime,
    `exchmsg` text,
    `team_memberid` text,
    `tag` text,
    `print_times` int(11),
    `approvesubmitter` int(11),
    `approvesubmittedtime` Datetime,
    `currentapprovestepid` int(19),
    `approveurgent` Varchar(10),
    `approveexpediting` Varchar(10) ,
    `kis_id` varchar(200) ,
    `kis_no` varchar(100) ,
    PRIMARY KEY (`resignation_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_resignationscf` (
    `resignation_id` int(11) NOT NULL,
    PRIMARY KEY (`resignation_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

call AddColumn('ld_resignation','deleted','int',4,0);

set @modulename='Resignation';
set @tablename='ld_resignation';
SELECT max(tabid) INTO @maxtabid FROM	ld_tab;
SELECT max(tabsequence) INTO @maxtabsequence FROM ld_tab ;
INSERT INTO ld_tab (
    tabid,NAME,presence,tabsequence,tablabel,parent,printtab,isduplicate
)
SELECT
        @maxtabid + 1,@modulename,0 ,@maxtabsequence + 1,@modulename,null,1,'yes'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE NAME = @modulename);


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_LABEL', 1
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_LABEL');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_RESIGNATION_INFO', 2
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_RESIGNATION_INFO');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT  @blockid,@tabid,'LBL_DESCRIPTION_INFORMATION', 3
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_DESCRIPTION_INFORMATION');

update ld_blocks_seq set id=@blockid;


select deploy_value INTO @decimalplace from ld_systems_deploy where deploy_type=351;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_RESIGNATION_INFO';

set @columnname='resignation_no';
set @fieldname='resignation_no';
set @zh='单据编号';
set @uitype=4;
set @bigtype='moduleno';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=1;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smownerid';
set @fieldname='assigned_user_id';
set @zh='负责人';
set @uitype=53;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smcreatorid';
set @fieldname='smcreatorid';
set @zh='创建人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='createdtime';
set @fieldname='createdtime';
set @zh='创建时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_group';
set @fieldname='resignation_group';
set @zh='部门';
set @uitype=1600;
set @bigtype='memberdepartment';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
set @relatedmodulefield='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type,relatedmodulefield)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type,@relatedmodulefield from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_resigndate';
set @fieldname='resignation_resigndate';
set @zh='离职日期';
set @uitype=5;
set @bigtype='date';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='D~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_type';
set @fieldname='resignation_type';
set @zh='离职类型';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_handover';
set @fieldname='resignation_handover';
set @zh='工作是否交接';
set @uitype=56;
set @bigtype='boolean';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='C~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_handoversituation';
set @fieldname='resignation_handoversituation';
set @zh='工作交接情况';
set @uitype=19;
set @bigtype='textarea';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_suspendinsurance';
set @fieldname='resignation_suspendinsurance';
set @zh='是否停保';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='resignation_reason';
set @fieldname='resignation_reason';
set @zh='离职原因';
set @uitype=19;
set @bigtype='textarea';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
SET @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedby';
set @fieldname='modifiedby';
set @zh='更新人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedtime';
set @fieldname='modifiedtime';
set @zh='更新时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvestatus';
set @fieldname='approvestatus';
set @zh='审批状态';
set @uitype=609;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvetime';
set @fieldname='approvetime';
set @zh='最新审批时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approveby';
set @fieldname='approveby';
set @zh='上一步审批人';
set @uitype=131;
set @bigtype=NULL;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='currentapprover';
set @fieldname='currentapprover';
set @zh='当前审批人';
set @uitype=132;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='latestpushtime';
set @fieldname='latestpushtime';
set @zh='最新推进时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='advance_stage';
set @fieldname='advance_stage';
set @zh='推进阶段';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='exchtime';
set @fieldname='exchtime';
set @zh='最新同步时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='exchmsg';
set @fieldname='exchmsg';
set @zh='最新同步结果';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='team_memberid';
set @fieldname='team_memberid';
set @zh='团队成员';
set @uitype=154;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='tag';
set @fieldname='tag';
set @zh='标签';
set @uitype=301;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='print_times';
set @fieldname='print_times';
set @zh='打印次数';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';

set @columnname='resignation_description';
set @fieldname='resignation_description';
set @zh='备注';
set @uitype=19;
set @bigtype='textarea';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=1;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=@seq;

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'resignation_type', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='resignation_type');
set @listid = (select listid  from ld_picklist_set where listname ='resignation_type');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '自请离职', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='自请离职' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '解雇离职', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='解雇离职' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '合同到期', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='合同到期' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '协商解除合同', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='合同到期' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '退休', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='合同到期' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '试用期不合格', 6 from dual
where not exists (select 1 from ld_picklist_values where listvalue='合同到期' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '其他', 7 from dual
where not exists (select 1 from ld_picklist_values where listvalue='合同到期' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'resignation_suspendinsurance', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='resignation_suspendinsurance');
set @listid = (select listid  from ld_picklist_set where listname ='resignation_suspendinsurance');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '停保', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='停保' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '在保', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='在保' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '未参保', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='未参保' and listid =@listid);

DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_bymodule`(
    tmp_modulename VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);

	IF @tabid>0 THEN
SELECT MAX(blockid) into @maxid FROM ld_blocks;
SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=@tabid;
SET @trantable='ld_blocks';
		SET @blocklabel='LBI_ATTACHMENT_FILE';
		SET @zh='附件信息';
		SET @en='Attachments Information';
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
SELECT @maxid+1,@tabid,@blocklabel,@maxseq+1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

SET @maxseq=0;
SELECT MAX(fieldid) INTO @maxid FROM ld_field;
SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=@tabid AND block=@relateid;
SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename';
		SET @fieldname='filename';
		SET @zh='附件';
		SET @en='Attachment';
		SET @uitype=1109;

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,editpage)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,'fileattachment','listview' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

CALL getallprofile(tmp_modulename);
CALL fieldprofile(tmp_modulename);

END IF;

end ||
delimiter;
CALl ldcrm_add_attachments_filename_bymodule(@modulename);

INSERT INTO ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab' ,@tabid ,@tabid,'离职申请' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'zh'
                                     AND trantable = 'ld_tab'
    );

INSERT INTO ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab' ,@tabid ,@tabid,'Resignation Application' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'en'
                                     AND trantable = 'ld_tab'
    );

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_LABEL');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '标签' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Tag' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_RESIGNATION_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_DESCRIPTION_INFORMATION');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '备注信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Description Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_no' LIMIT 1);
SET @trantable='ld_field';
SET @zh='单据编号';
SET @en='resignation No';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='申请人';
SET @en='Applicant';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建人';
SET @en='Creator';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建时间';
SET @en='Created Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_group' LIMIT 1);
SET @trantable='ld_field';
SET @zh='部门';
SET @en='Department';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_resigndate' LIMIT 1);
SET @trantable='ld_field';
SET @zh='离职日期';
SET @en='Resignation date';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_type' LIMIT 1);
SET @trantable='ld_field';
SET @zh='离职类型';
SET @en='Resignation type';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_handover' LIMIT 1);
SET @trantable='ld_field';
SET @zh='工作是否交接';
SET @en='Job handover';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_handoversituation' LIMIT 1);
SET @trantable='ld_field';
SET @zh='工作交接情况';
SET @en='Work handover situation';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_suspendinsurance' LIMIT 1);
SET @trantable='ld_field';
SET @zh='是否停保';
SET @en='Whether to suspend insurance';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_reason' LIMIT 1);
SET @trantable='ld_field';
SET @zh='离职原因';
SET @en='Reason for resignation';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新更新人';
SET @en='Modified By';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='更新时间';
SET @en='Modified Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus' LIMIT 1);
SET @trantable='ld_field';
SET @zh='审批状态';
SET @en='Approve Status';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新审批时间';
SET @en='Last Approval Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='上一步审批人';
SET @en='The Last Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover' LIMIT 1);
SET @trantable='ld_field';
SET @zh='当前审批人';
SET @en='Current Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='latestpushtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新推进时间';
SET @en='Latest push time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage' LIMIT 1);
SET @trantable='ld_field';
SET @zh='推进阶段';
SET @en='Advance Stage';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='resignation_description' LIMIT 1);
SET @trantable='ld_field';
SET @zh='备注';
SET @en='Description';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @parenttabid = (select parenttabid from ld_parenttab where parenttab_label='RenShiGuanLi');
set @sequence = (select sequence from ld_parenttabrel left join ld_tab on ld_parenttabrel.tabid=ld_tab.tabid where parenttabid=@parenttabid and ld_tab.name='Salary' and tab_tablename = 'ld_tab');
UPDATE ld_parenttab SET sequence = sequence + 1 WHERE  parenttabid = @parenttabid and sequence > @sequence  and NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid =@tabid
                                        AND tab_tablename = 'ld_tab'
    );

INSERT INTO ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename)
SELECT @parenttabid,@tabid,@sequence,'ld_tab' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid =@tabid
                                        AND tab_tablename = 'ld_tab'
    );

SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (
    cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence
) SELECT
          @maxcvid + 1,'All',1,0,@modulename,3,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype =@modulename AND viewname = 'All');

SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = @modulename AND viewname = 'All' );
INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,0,CONCAT('ld_',LOWER(@modulename),':','resignation_no',':','resignation_no',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,1,CONCAT('ld_',LOWER(@modulename),':','Smownerid',':','assigned_user_id',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,2,CONCAT('ld_',LOWER(@modulename),':','resignation_type',':','resignation_type',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,3,CONCAT('ld_',LOWER(@modulename),':','resignation_group',':','resignation_group',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,4,CONCAT('ld_',LOWER(@modulename),':','resignation_resigndate',':','resignation_resigndate',':',@modulename,'_fieldlabel:DT')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,5,CONCAT('ld_',LOWER(@modulename),':','resignation_handover',':','resignation_handover',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);

SET @modentity_num_seq = (select id+1 from ld_modentity_num_seq);
INSERT INTO `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`)
select @modentity_num_seq, @modulename, 'RA', '1', '1', '1', 'none', 0, 0, 0  from dual where not exists (select 1 from ld_modentity_num where  semodule =@modulename);
update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;
INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
SELECT @tabid, @modulename, @tablename, 'resignation_no', 'resignation_id', 'resignation_id' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

DROP PROCEDURE IF EXISTS `ldcrm_defaultcreateprofileon`;
delimiter ||
CREATE  PROCEDURE `ldcrm_defaultcreateprofileon`(
    modulename varchar(50),
    permissions int(19)
)
begin
	declare done int default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid FROM ld_profile where profileid!=1;-- 总经理字段需要所有权限 之后统一添加
declare continue handler  for not   found  SET done =1;
	set @sql = concat('select tabid into @tabid from ld_tab where name=','''',modulename,'''');
prepare stmt from @sql;
execute stmt;
deallocate  prepare stmt;
OPEN cur1;
Fetch cur1 into pprofileid;
loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
Fetch cur1 into pprofileid;
end while loop1;
close cur1;
end ||
delimiter;
CALL ldcrm_defaultcreateprofileon(@modulename,0);

INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 1, 1 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=1);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 2, 2 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=2 );
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 3, 3  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=3);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 4, 4  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=4);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 5, 5  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=5);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 6, 6  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=6);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 11, 7  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=11);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 12, 8  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=12);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 13, 9  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=13);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 14, 10  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=14);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 22, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=22);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 25, 11  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=25);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 37, 12  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=37);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 57, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=57);

INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 1,0,1 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=1 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 2,0,2 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=2 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 3,0,3 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=3 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 4,0,4 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=4 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 5,0,5 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=5 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 6,0,6 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=6 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 11,0,7 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=11 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 12,0,8 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=12 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 13,0,9 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=13 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 14,0,10 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=14 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 22,0,11 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=22 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 25,0,12 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=25 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 37,0,13 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=37 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 57,0,14 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=57 and profileid=1);

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;
	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);

SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;

UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

END IF;

end ||
delimiter;
CALL ldcrm_add_approveforbill(@modulename,480);

drop PROCEDURE  if EXISTS update_validatarule;
delimiter ||
create PROCEDURE update_validatarule
(
)
BEGIN
	declare var_validataid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_validatasave where validatasavetype = 'php' and isshowlist = 'no' AND IFNULL(validatasavemainid,0) = 0;
declare continue handler  for not found  SET done =1;

open cur1;
Fetch cur1 into var_validataid;
loop1: while  done<>1 DO
				INSERT into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence,isshowlist)
SELECT rulename,module,`status`,case when allowsave = 'no' then 'yes' ELSE 'no' END,tipzh,tipen,'',validatacheckbutton,relatedtable,sequence,'no' from ld_validatasave where id = var_validataid;
SELECT MAX(id) into @max_mainid from ld_validatasavemain;

UPDATE ld_validatasave SET conditiongroupid = 1,validatasavemainid = @max_mainid where id = var_validataid;
Fetch cur1 into var_validataid;
end while loop1;
close cur1;
end ||
delimiter;
call update_validatarule();
drop PROCEDURE if EXISTS update_validatarule;

update ld_tab set mobilepresence='weixin' where tabid =@tabid;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
    tmp_module VARCHAR(100),
    tmp_column VARCHAR(100),
    tmp_rownum INT(1),
    tmp_colnum INT(1),
    tmp_showtag VARCHAR(20),
    tmp_sysdefault VARCHAR(20)
        )
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'resignation_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'smownerid','3','1','yes','yes');

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`=@modulename);
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_evaluation` (
    `evaluation_id` int(11) NOT NULL,
    `evaluation_no` varchar(100) DEFAULT NULL,
    `smownerid` Int(11) NOT NULL,
    `evaluation_month` varchar(100),
    `evaluation_score` int(10),
    `smcreatorid` Int(11),
    `createdtime` datetime ,
    `modifiedby` Int(11),
    `modifiedtime` datetime,
    `approvestatus` Varchar(200),
    `approvetime` Datetime,
    `approveby` Int(11),
    `currentapprover` Varchar(1000),
    `global_awareness` Varchar(100),
    `collaboration_awareness` Varchar(100),
    `service_awareness` Varchar(100),
    `communication_ability` Varchar(100),
    `business_ability` Varchar(100),
    `planning_ability` Varchar(100),
    `innovation_ability` Varchar(100),
    `principality` Varchar(100),
    `responsibility` varchar(100),
    `morality` varchar(100),
    `comments` text,
    `latestpushtime` Datetime,
    `advance_stage` Varchar(100),
    `exchtime` Datetime,
    `exchmsg` text,
    `team_memberid` text,
    `tag` text,
    `print_times` int(11),
    `approvesubmitter` int(11),
    `approvesubmittedtime` Datetime,
    `currentapprovestepid` int(19),
    `approveurgent` Varchar(10),
    `approveexpediting` Varchar(10) ,
    `kis_id` varchar(200) ,
    `kis_no` varchar(100) ,
    PRIMARY KEY (`evaluation_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_evaluationscf` (
    `evaluation_id` int(11) NOT NULL,
    PRIMARY KEY (`evaluation_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

call AddColumn('ld_evaluation','deleted','int',4,0);

set @modulename='Evaluation';
set @tablename='ld_evaluation';
SELECT max(tabid) INTO @maxtabid FROM	ld_tab;
SELECT max(tabsequence) INTO @maxtabsequence FROM ld_tab ;
INSERT INTO ld_tab (
    tabid,NAME,presence,tabsequence,tablabel,parent,printtab,isduplicate
)
SELECT
        @maxtabid + 1,@modulename,0 ,@maxtabsequence + 1,@modulename,null,1,'yes'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE NAME = @modulename);

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_LABEL', 1
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_LABEL');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_EVALUATION_INFO', 2
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_EVALUATION_INFO');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_TEAMWORK', 3
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_TEAMWORK');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_WORKING_ABILITY', 4
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_WORKING_ABILITY');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_WORKING_ATTITUDE', 5
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_WORKING_ATTITUDE');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_COMMENTS', 6
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_COMMENTS');

update ld_blocks_seq set id=@blockid;

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_EVALUATION_INFO';

set @columnname='evaluation_no';
set @fieldname='evaluation_no';
set @zh='单据编号';
set @uitype=4;
set @bigtype='moduleno';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=1;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smownerid';
set @fieldname='assigned_user_id';
set @zh='负责人';
set @uitype=53;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='evaluation_month';
set @fieldname='evaluation_month';
set @zh='被评估月份';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='evaluation_score';
set @fieldname='evaluation_score';
set @zh='累计得分';
set @uitype=7;
set @bigtype='number';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='NN~O~25,0';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smcreatorid';
set @fieldname='smcreatorid';
set @zh='创建人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='createdtime';
set @fieldname='createdtime';
set @zh='创建时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedby';
set @fieldname='modifiedby';
set @zh='更新人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedtime';
set @fieldname='modifiedtime';
set @zh='更新时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvestatus';
set @fieldname='approvestatus';
set @zh='审批状态';
set @uitype=609;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvetime';
set @fieldname='approvetime';
set @zh='最新审批时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approveby';
set @fieldname='approveby';
set @zh='上一步审批人';
set @uitype=131;
set @bigtype=NULL;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='currentapprover';
set @fieldname='currentapprover';
set @zh='当前审批人';
set @uitype=132;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='tag';
set @fieldname='tag';
set @zh='标签';
set @uitype=301;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_TEAMWORK';

set @columnname='global_awareness';
set @fieldname='global_awareness';
set @zh='全局意识';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='collaboration_awareness';
set @fieldname='collaboration_awareness';
set @zh='协作意识';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='service_awareness';
set @fieldname='service_awareness';
set @zh='服务意识';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_WORKING_ABILITY';

set @columnname='communication_ability';
set @fieldname='communication_ability';
set @zh='沟通表达能力';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='business_ability';
set @fieldname='business_ability';
set @zh='基本业务能力';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='planning_ability';
set @fieldname='planning_ability';
set @zh='计划能力';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='innovation_ability';
set @fieldname='innovation_ability';
set @zh='创新能力';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_WORKING_ATTITUDE';

set @columnname='principality';
set @fieldname='principality';
set @zh='原则性';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='responsibility';
set @fieldname='responsibility';
set @zh='责任心';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='morality';
set @fieldname='morality';
set @zh='品德诚信';
set @uitype=15;
set @bigtype='picklist';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_COMMENTS';

set @columnname='comments';
set @fieldname='comments';
set @zh='评语及建议';
set @uitype=231;
set @bigtype='richtext';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @fieldonly=0;
set @input_type='';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=@seq;

set @tmp_fieldid = ( SELECT fieldid FROM ld_field where tabid = @tabid and columnname = 'evaluation_score');
INSERT INTO ld_field_formula(`fieldid`, `formulastring`, `columnstring`, `functiontype`, `created_at`, `updated_at`)
SELECT @tmp_fieldid, "SELECT 0+'{a}'+'{b}'+'{c}'+'{d}'+'{e}'+'{f}'+'{g}'+'{h}'+'{i}'+'{j}' as tmp_value",
       "{formulavar:[{'lettervar':'a','column':'global_awareness'},{'lettervar':'b','column':'collaboration_awareness'},{'lettervar':'c','column':'service_awareness'},
       {'lettervar':'d','column':'communication_ability'},{'lettervar':'e','column':'business_ability'},{'lettervar':'f','column':'planning_ability'},
       {'lettervar':'g','column':'innovation_ability'},{'lettervar':'h','column':'principality'},{'lettervar':'i','column':'responsibility'},{'lettervar':'j','column':'morality'}]}",'sql',NOW(),NOW()
FROM DUAL where NOT EXISTS (SELECT 1 from ld_field_formula WHERE fieldid = @tmp_fieldid);

set @trigger_fieldid = ( SELECT fieldid FROM ld_field where tabid = @tabid and columnname = 'smownerid');
set @effect_fieldid = ( SELECT fieldid FROM ld_field where tabid = @tabid and columnname = 'evaluation_month');
INSERT INTO `ld_related_field` (
    `fieldid`,
    `fieldtype`,
    `relatedstring`,
    `trigger_fieldid`,
    `effect_fieldid`,
    `curmodule_columninfo`,
    `fromvalue_type`,
    `fromvalue_info`,
    `frommodule`,
    `picklistsql`
)
VALUES
    (
        NULL,
        'main',
        NULL,
        @trigger_fieldid,
        @effect_fieldid,
        NULL,
        'sql',
        'SELECT DATE_FORMAT(CURDATE(),\'%Y-%m\')',
        NULL,
        'SELECT\r\n	optionvalue,\r\n	optionvalue AS optiontext\r\nFROM (\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 0 MONTH),\'%Y-%m\') AS optionvalue\r\n
	UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 2 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 3 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 4 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 5 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 6 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 7 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 8 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 9 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 10 MONTH),\'%Y-%m\') AS optionvalue\r\n
UNION ALL\r\n	SELECT DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 11 MONTH),\'%Y-%m\') AS optionvalue\r\n) a'
    );

-- 下拉框字段
INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'global_awareness', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='global_awareness');
set @listid = (select listid  from ld_picklist_set where listname ='global_awareness');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：系统地思考，主次分明，能以集体利益为重，不计个人得失', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：系统地思考，主次分明，能以集体利益为重，不计个人得失' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：多数情况下，能够系统地思考和处理问题，绝大多数情况下能够以集体利益为重', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：多数情况下，能够系统地思考和处理问题，绝大多数情况下能够以集体利益为重' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '3分：能够较好的思考和处理问题，但在分清主次轻重、系统化思考上还须加强', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：能够较好的思考和处理问题，但在分清主次轻重、系统化思考上还须加强' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：多数情况下，不能站在集体利益上考虑问题，无法分清主次轻重', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：多数情况下，不能站在集体利益上考虑问题，无法分清主次轻重' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '0分：完全从个人利益角度出发来计算或衡量得失，不顾及集体利益', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：完全从个人利益角度出发来计算或衡量得失，不顾及集体利益' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'collaboration_awareness', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='collaboration_awareness');
set @listid = (select listid  from ld_picklist_set where listname ='collaboration_awareness');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：能够牺牲个人利益，和他人通力合作，积极达成目标', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：能够牺牲个人利益，和他人通力合作，积极达成目标' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：充分理解团队目标，乐意为团队目标作贡献', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：充分理解团队目标，乐意为团队目标作贡献' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：理解领导意图，主动为领导者分担责任，乐于协助团队其他成员，共同努力', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：理解领导意图，主动为领导者分担责任，乐于协助团队其他成员，共同努力' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：只关心本职工作，对其他工作不闻不问', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：只关心本职工作，对其他工作不闻不问' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：只关心本职工作，对其他工作不闻不问', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：只关心本职工作，对其他工作不闻不问' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'service_awareness', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='service_awareness');
set @listid = (select listid  from ld_picklist_set where listname ='service_awareness');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：在工作中彻底贯注服务意识，主动为其他团队、岗位的工作服务', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：在工作中彻底贯注服务意识，主动为其他团队、岗位的工作服务' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：有较强的服务意识，大多数情况之下能够为他人服务', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：有较强的服务意识，大多数情况之下能够为他人服务' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：服务意识一般，在遇到的工作难度不大等一般情形下，能够为他人服务', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：服务意识一般，在遇到的工作难度不大等一般情形下，能够为他人服务' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：服务意识较差，不主动服务于他人', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：服务意识较差，不主动服务于他人' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：服务意识非常差，完全根据个人情绪决定，只希望得到他人的服务', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：服务意识非常差，完全根据个人情绪决定，只希望得到他人的服务' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'communication_ability', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='communication_ability');
set @listid = (select listid  from ld_picklist_set where listname ='communication_ability');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：说服力强，具备较强的沟通技巧，富有亲和力，文字表达结构严谨，简练流畅', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：说服力强，具备较强的沟通技巧，富有亲和力，文字表达结构严谨，简练流畅' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：说服力较强，善于疏导，文章结构合理，文字简洁', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：说服力较强，善于疏导，文章结构合理，文字简洁' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：有一定的疏导技巧，尚能被他人接受，文章通顺，较简洁，很少语病', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：有一定的疏导技巧，尚能被他人接受，文章通顺，较简洁，很少语病' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：说服力较差，勉强被他人接受，书面表达能力较差', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：说服力较差，勉强被他人接受，书面表达能力较差' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：说服力差，态度生硬，缺乏技巧，文章结构零乱不规范，书面表达能力差', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：说服力差，态度生硬，缺乏技巧，文章结构零乱不规范，书面表达能力差' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'business_ability', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='business_ability');
set @listid = (select listid  from ld_picklist_set where listname ='business_ability');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：积极进取，不断自我提升，完全具备高质完成本职工作的能力，还能一专多长', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：积极进取，不断自我提升，完全具备高质完成本职工作的能力，还能一专多长' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：能够不断地自我完善，业务能力强，对本职工作的各项工作内容得心应手', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：能够不断地自我完善，业务能力强，对本职工作的各项工作内容得心应手' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：具备完成本职工作的一般技能和技巧，基本能够完成份内的各项工作', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：具备完成本职工作的一般技能和技巧，基本能够完成份内的各项工作' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：具备较好的基础或潜力，但在技能、技巧上仍有所不足，还需一定的指导和培养', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：具备较好的基础或潜力，但在技能、技巧上仍有所不足，还需一定的指导和培养' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：基本技能、技巧未达到要求，不主动提升，虽经指导亦不能完成基本工作内容', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：基本技能、技巧未达到要求，不主动提升，虽经指导亦不能完成基本工作内容' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'planning_ability', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='planning_ability');
set @listid = (select listid  from ld_picklist_set where listname ='planning_ability');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：能及时准确发现问题并把握问题发展趋势和关键，制订细致周密的计划方案', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：能及时准确发现问题并把握问题发展趋势和关键，制订细致周密的计划方案' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：能正确的发现问题并较周密的思考问题，制订出较为有效的计划方案', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：能正确的发现问题并较周密的思考问题，制订出较为有效的计划方案' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：能及时发现问题，思考欠周密，对于难度较大的问题把握不大', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：能及时发现问题，思考欠周密，对于难度较大的问题把握不大' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：能及时发现问题，但把握不住问题的关键，制订的计划思路重点模糊，较难奏效', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：能及时发现问题，但把握不住问题的关键，制订的计划思路重点模糊，较难奏效' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：不能及时发现问题，更谈不上制订计划方案', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：不能及时发现问题，更谈不上制订计划方案' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'innovation_ability', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='innovation_ability');
set @listid = (select listid  from ld_picklist_set where listname ='innovation_ability');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：积极创新，不断自我剖析和改进，推动创新工作，完成多项开拓性质的工作', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：积极创新，不断自我剖析和改进，推动创新工作，完成多项开拓性质的工作' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：富有创新意识，能够积极参与开拓创新工作', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：富有创新意识，能够积极参与开拓创新工作' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：有创新意识，能够对自己的工作不断改进和提高', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：有创新意识，能够对自己的工作不断改进和提高' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：少有创新，偶尔能够提出初步建议，但较少有实质性工作创新和改进', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：少有创新，偶尔能够提出初步建议，但较少有实质性工作创新和改进' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：极少创新，安于现状，完全按章办事，不能打破现有的思路和陈规', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：极少创新，安于现状，完全按章办事，不能打破现有的思路和陈规' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'principality', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='principality');
set @listid = (select listid  from ld_picklist_set where listname ='principality');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：坚持原则，敢于碰硬，依制度办事，能够同违规行为作斗争；', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：坚持原则，敢于碰硬，依制度办事，能够同违规行为作斗争；' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：原则性较强，是非分明，积极进行批评与自我批评', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：原则性较强，是非分明，积极进行批评与自我批评' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：一般情形下，能够做到坚持原则', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：一般情形下，能够做到坚持原则' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：原则性较差，碍于人情关系，默许或纵容违规行为', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：原则性较差，碍于人情关系，默许或纵容违规行为' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：原则性极差，不能坚持基本的工作原则，甚至自身出现违规行为', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：原则性极差，不能坚持基本的工作原则，甚至自身出现违规行为' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'responsibility', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='responsibility');
set @listid = (select listid  from ld_picklist_set where listname ='responsibility');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：勇于接受挑战承担责任，为实现目标尽全力，能彻底达成任务，可放心交办工作', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：勇于接受挑战承担责任，为实现目标尽全力，能彻底达成任务，可放心交办工作' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：能不断自我改进和提高，顺利完成交办的任务，可以交付工作', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：能不断自我改进和提高，顺利完成交办的任务，可以交付工作' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：工作上不断改善，尚有责任心，能够如期完成任务', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：工作上不断改善，尚有责任心，能够如期完成任务' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：责任心不强，遇到问题不能主动解决，经常需要他人督促，工作方能完成', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：责任心不强，遇到问题不能主动解决，经常需要他人督促，工作方能完成' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：工作避难就易，挑挑拣拣，虽经他人时时督促，仍无法如若完成工作', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：工作避难就易，挑挑拣拣，虽经他人时时督促，仍无法如若完成工作' and listid =@listid);

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`)
select  'morality', 'ld_field', NULL, NULL from dual
where not exists (select 1 from ld_picklist_set where listname ='morality');
set @listid = (select listid  from ld_picklist_set where listname ='morality');
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '5分：品行廉洁，言行诚信，以身作则', 1 from dual
where not exists (select 1 from ld_picklist_values where listvalue='5分：品行廉洁，言行诚信，以身作则' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '4分：品行廉洁，绝大多数情况下能够把握分寸、以身作则，诚恳待人', 2 from dual
where not exists (select 1 from ld_picklist_values where listvalue='4分：品行廉洁，绝大多数情况下能够把握分寸、以身作则，诚恳待人' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '3分：无违纪违规行为发生，能够遵照公司要求与社会道德标准处事', 3 from dual
where not exists (select 1 from ld_picklist_values where listvalue='3分：无违纪违规行为发生，能够遵照公司要求与社会道德标准处事' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '2分：偶尔有违规行为出现，但影响不大，很难得到他人的信任', 4 from dual
where not exists (select 1 from ld_picklist_values where listvalue='2分：偶尔有违规行为出现，但影响不大，很难得到他人的信任' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '0分：品行不佳，言行有损公司形象，虚与委蛇，城府较深，令人无法信任', 5 from dual
where not exists (select 1 from ld_picklist_values where listvalue='0分：品行不佳，言行有损公司形象，虚与委蛇，城府较深，令人无法信任' and listid =@listid);

INSERT INTO ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab' ,@tabid ,@tabid,'360度绩效评估表' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'zh'
                                     AND trantable = 'ld_tab'
    );

INSERT INTO ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab' ,@tabid ,@tabid,'360 degree performance evaluation' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'en'
                                     AND trantable = 'ld_tab'
    );

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_LABEL');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '标签' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh'  and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Tag' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en'  and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_EVALUATION_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh'  and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en'  and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_TEAMWORK');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '团队协作' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh'  and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Teamwork' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en'  and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_WORKING_ABILITY');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '工作能力' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh'  and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Working Ability' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en'  and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_WORKING_ATTITUDE');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '工作态度' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh'  and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Working Attitude' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en'  and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_COMMENTS');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '评语及建议' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh'  and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Comments and Suggestion' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en'  and Relateid=@blockid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='evaluation_no' LIMIT 1);
SET @trantable='ld_field';
SET @zh='单据编号';
SET @en='evaluation No';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='被评估者';
SET @en='Assessee';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='evaluation_month' LIMIT 1);
SET @trantable='ld_field';
SET @zh='被评估月份';
SET @en='Assessed month';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='evaluation_score' LIMIT 1);
SET @trantable='ld_field';
SET @zh='累计得分';
SET @en='Accumulated score';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建人';
SET @en='Creator';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建时间';
SET @en='Created Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新更新人';
SET @en='Modified By';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='更新时间';
SET @en='Modified Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus' LIMIT 1);
SET @trantable='ld_field';
SET @zh='审批状态';
SET @en='Approve Status';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新审批时间';
SET @en='Last Approval Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='上一步审批人';
SET @en='The Last Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover' LIMIT 1);
SET @trantable='ld_field';
SET @zh='当前审批人';
SET @en='Current Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='global_awareness' LIMIT 1);
SET @trantable='ld_field';
SET @zh='全局意识';
SET @en='Global awareness';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='collaboration_awareness' LIMIT 1);
SET @trantable='ld_field';
SET @zh='协作意识';
SET @en='Collaboration awareness';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='service_awareness' LIMIT 1);
SET @trantable='ld_field';
SET @zh='服务意识';
SET @en='Service awareness';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='communication_ability' LIMIT 1);
SET @trantable='ld_field';
SET @zh='沟通表达能力';
SET @en='Communication and expression skills';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='business_ability' LIMIT 1);
SET @trantable='ld_field';
SET @zh='基本业务能力';
SET @en='Basic business capabilities';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='planning_ability' LIMIT 1);
SET @trantable='ld_field';
SET @zh='计划能力';
SET @en='Planning ability';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='innovation_ability' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创新能力';
SET @en='Innovation ability';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='principality' LIMIT 1);
SET @trantable='ld_field';
SET @zh='原则性';
SET @en='Principality';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='responsibility' LIMIT 1);
SET @trantable='ld_field';
SET @zh='责任心';
SET @en='Responsibility';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='morality' LIMIT 1);
SET @trantable='ld_field';
SET @zh='品德诚信';
SET @en='Moral integrity';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='comments' LIMIT 1);
SET @trantable='ld_field';
SET @zh='评语及建议';
SET @en='Comments and suggestions';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @parenttabid = (select parenttabid from ld_parenttab where parenttab_label='RenShiGuanLi');
set @sequence = (select max(sequence) from ld_parenttabrel where parenttabid=@parenttabid and tab_tablename = 'ld_tab');
INSERT INTO ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename)
SELECT @parenttabid,@tabid,@sequence+1,'ld_tab' FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid =@tabid
                                        AND tab_tablename = 'ld_tab'
    );

SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (
    cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence
) SELECT
          @maxcvid + 1,'All',1,0,@modulename,3,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype =@modulename AND viewname = 'All');

SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = @modulename AND viewname = 'All' );
INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,0,CONCAT('ld_',LOWER(@modulename),':','evaluation_no',':','evaluation_no',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,1,CONCAT('ld_',LOWER(@modulename),':','smownerid',':','assigned_user_id',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,2,CONCAT('ld_',LOWER(@modulename),':','evaluation_month',':','evaluation_month',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);

INSERT INTO ld_cvcolumnlist (
    cvid,columnindex,columnname
) SELECT
      @cvid,3,CONCAT('ld_',LOWER(@modulename),':','evaluation_score',':','evaluation_score',':',@modulename,'_fieldlabel:N')
from dual where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3);

SET @modentity_num_seq = (select id+1 from ld_modentity_num_seq);
INSERT INTO `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`)
select @modentity_num_seq, @modulename, 'JXPG-', '1', '1', '1', 'yymm', 0, 0, 0  from dual where not exists (select 1 from ld_modentity_num where  semodule =@modulename);
update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;
INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
SELECT @tabid, @modulename, @tablename, 'evaluation_no', 'evaluation_id', 'evaluation_id' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 1, 1 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=1);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 2, 2 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=2 );
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 3, 3  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=3);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 4, 4  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=4);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 5, 5  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=5);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 6, 6  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=6);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 11, 7  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=11);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 12, 8  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=12);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 13, 9  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=13);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 14, 10  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=14);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 22, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=22);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 25, 11  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=25);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 37, 12  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=37);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 57, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=57);

INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 1,0,1 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=1 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 2,0,2 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=2 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 3,0,3 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=3 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 4,0,4 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=4 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 5,0,5 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=5 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 6,0,6 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=6 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 11,0,7 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=11 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 12,0,8 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=12 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 13,0,9 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=13 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 14,0,10 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=14 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 22,0,11 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=22 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 25,0,12 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=25 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 37,0,13 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=37 and profileid=1);
INSERT INTO ld_profile2standardpermissions(profileid, tabid, `operation`, permissions , `sequence`) SELECT  1,@tabid, 57,0,14 from dual where NOT exists(SELECT 1 FROM  ld_profile2standardpermissions where tabid =@tabid and operation=57 and profileid=1);

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;
	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);

SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;

UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

END IF;

end ||
delimiter;
CALL ldcrm_add_approveforbill(@modulename,481);

drop PROCEDURE  if EXISTS update_validatarule;
delimiter ||
create PROCEDURE update_validatarule
(
)
BEGIN
	declare var_validataid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_validatasave where validatasavetype = 'php' and isshowlist = 'no' AND IFNULL(validatasavemainid,0) = 0;
declare continue handler  for not found  SET done =1;

open cur1;
Fetch cur1 into var_validataid;
loop1: while  done<>1 DO
				INSERT into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence,isshowlist)
SELECT rulename,module,`status`,case when allowsave = 'no' then 'yes' ELSE 'no' END,tipzh,tipen,'',validatacheckbutton,relatedtable,sequence,'no' from ld_validatasave where id = var_validataid;
SELECT MAX(id) into @max_mainid from ld_validatasavemain;

UPDATE ld_validatasave SET conditiongroupid = 1,validatasavemainid = @max_mainid where id = var_validataid;
Fetch cur1 into var_validataid;
end while loop1;
close cur1;
end ||
delimiter;
call update_validatarule();
drop PROCEDURE if EXISTS update_validatarule;

update ld_tab set mobilepresence='weixin' where tabid =@tabid;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
    tmp_module VARCHAR(100),
    tmp_column VARCHAR(100),
    tmp_rownum INT(1),
    tmp_colnum INT(1),
    tmp_showtag VARCHAR(20),
    tmp_sysdefault VARCHAR(20)
        )
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'evaluation_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'smownerid','3','1','yes','yes');

set @tabid = (select tabid from ld_tab where `name`='Reminds');
set @option_tabid = (select tabid from ld_tab where `name`=@modulename);
set @max_seq = (select MAX(sequence) from ld_option_module where tabid=@tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,datarang,maxrowsshow)
select @tabid,@option_tabid,0,1,0,@max_seq+1,'all',20 from dual
where not exists(select 1 from ld_option_module where tabid=@tabid and option_tabid=@option_tabid);
delimiter;

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


SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Holiday' AND viewname='All' LIMIT 1);
INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype)
SELECT @cvid,'ld_holiday:holiday_date:holiday_date:Holiday_D~M:fieldlabel','desc' from dual
WHERE @cvid>0 AND NOT EXISTS (SELECT 1 FROM ld_cvcolumnlistsort WHERE cvid=@cvid AND columnname LIKE 'ld_holiday:holiday_date:holiday_date%');
delimiter;

CALL addtableIndex('ld_holiday','holiday_date','holiday_date');
CALL addtableIndex('ld_holiday','smownerid','smownerid');
CALL addtableIndex('ld_holiday','smcreatorid','smcreatorid');
CALL addtableIndex('ld_holiday','createdtime','createdtime');
CALL addtableIndex('ld_holiday','modifiedtime','modifiedtime');
CALL addtableIndex('ld_holiday','deleted','deleted');
delimiter;


DELETE FROM ld_picklist_values WHERE listid IS NULL OR listid = 0;
delimiter;




select usereportid into @usereportid from ld_usereport where name='Performancestatisticscollection';
delete from ld_usereportcolumns where Usereportid=@usereportid and `columns`='ld_products:unit_price:unit_price:Products_unit_price:N';
delete from ld_usereportcolumns where Usereportid=@usereportid and `columns`='ld_inventoryproductrel:discountamount:discountamount:OftenUseReport_discountamount:V';
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

CALL addtableIndex('ld_employment','createdtime','createdtime');
CALL addtableIndex('ld_employment','modifiedtime','modifiedtime');
call addtableIndex('ld_employment','deleted','deleted');
CALL addtableIndex('ld_employment','smownerid','smownerid');
CALL addtableIndex('ld_employment','smcreatorid','smcreatorid');

CALL addtableIndex('ld_resignation','createdtime','createdtime');
CALL addtableIndex('ld_resignation','modifiedtime','modifiedtime');
call addtableIndex('ld_resignation','deleted','deleted');
CALL addtableIndex('ld_resignation','smownerid','smownerid');
CALL addtableIndex('ld_resignation','smcreatorid','smcreatorid');

CALL addtableIndex('ld_evaluation','createdtime','createdtime');
CALL addtableIndex('ld_evaluation','modifiedtime','modifiedtime');
call addtableIndex('ld_evaluation','deleted','deleted');
CALL addtableIndex('ld_evaluation','smownerid','smownerid');
CALL addtableIndex('ld_evaluation','smcreatorid','smcreatorid');
delimiter;




call AddColumn('ld_project','end_accountid','INT','19',NULL);
delimiter;

SET @labelbol = 'EDITDOCUMENTRESETTHEAPPROVAL';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'审批结束编辑单据是否重置审批状态',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Approval end edit document whether to reset the approval status',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

call AddColumn('ld_approve','editresetapprove','varchar','20','');
UPDATE ld_approve LEFT JOIN ld_tab on ld_tab.tabid = ld_approve.tabid
set ld_approve.editresetapprove = IF(IFNULL(ld_tab.againsubmit,'')='','yes',ld_tab.againsubmit)
where IFNULL(ld_approve.editresetapprove,'') = '';
delimiter;

UPDATE ld_desk set fieldlabel='已自动生成{$PaymentPlan.PaymentPlan}' WHERE labelbol='AUTOCREATEPAYMENTPLANTIP' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Automatically generated {$PaymentPlan.PaymentPlan}' WHERE labelbol='AUTOCREATEPAYMENTPLANTIP' and languagetype='en' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='已自动生成{$SendPayment.SendPayment}' WHERE labelbol='AUTOCREATESENDPAYMENTTIP' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Automatically generated {$SendPayment.SendPayment}' WHERE labelbol='AUTOCREATESENDPAYMENTTIP' and languagetype='en' and labeltype='fixedstr';
delimiter;

call AddColumn('ld_field','helptips','text','','');
delimiter;

call AddColumn('ld_field','default_helptips','text','','');
delimiter;

call AddColumn('ld_producttoolfield','helptips','text','','');
delimiter;

call AddColumn('ld_producttoolfield','default_helptips','text','','');
delimiter;

call AddColumn('ld_tabdetailfield','helptips','text','','');
delimiter;

call AddColumn('ld_tabdetailfield','default_helptips','text','','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HelpInformation','帮助信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HelpInformation' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HelpInformation','Help Information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HelpInformation' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HoverQuestionMarkDisplay','悬停问号展示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HoverQuestionMarkDisplay' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HoverQuestionMarkDisplay','Hover question mark display','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HoverQuestionMarkDisplay' and labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='Users');
UPDATE ld_field set helptips = '开启后，自动拥有后台管理设置的相关权限' WHERE tabid = @tabid and columnname = 'setmenuprofileid' and helptips is NULL;

UPDATE ld_field set helptips = '允许编辑其他成员单据的手机号码字段' WHERE tabid = @tabid and columnname = 'edit_other_mobile' and helptips is NULL;

UPDATE ld_field set helptips = '允许编辑自己单据的手机号码字段' WHERE tabid = @tabid and columnname = 'edit_me_mobile' and helptips is NULL;

UPDATE ld_field set helptips = '手机号码显示样式是否根据系统参数“设置系统中手机字段显示的样式（是否隐藏部分内容）”控制' WHERE tabid = @tabid and columnname = 'is_mobile_style' and helptips is NULL;

UPDATE ld_field set helptips = '客户管理和客户服务单详情界面是否显示服务合同信息' WHERE tabid = @tabid and columnname = 'select_servicedetail' and helptips is NULL;

UPDATE ld_field set helptips = '客户管理和客户服务单详情界面是否显示具体的服务到期日' WHERE tabid = @tabid and columnname = 'select_due_date' and helptips is NULL;

UPDATE ld_field set helptips = '客户服务单详情界面是否显示客户服务单历史记录' WHERE tabid = @tabid and columnname = 'helpdesk_log' and helptips is NULL;

UPDATE ld_field set helptips = '单据相关信息列表是否允许查询所有关联数据' WHERE tabid = @tabid and columnname = 'accountallview' and helptips is NULL;
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='Users');
UPDATE ld_field set default_helptips = '开启后，自动拥有后台管理设置的相关权限' WHERE tabid = @tabid and columnname = 'setmenuprofileid' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '允许编辑其他成员单据的手机号码字段' WHERE tabid = @tabid and columnname = 'edit_other_mobile' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '允许编辑自己单据的手机号码字段' WHERE tabid = @tabid and columnname = 'edit_me_mobile' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '手机号码显示样式是否根据系统参数“设置系统中手机字段显示的样式（是否隐藏部分内容）”控制' WHERE tabid = @tabid and columnname = 'is_mobile_style' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '客户管理和客户服务单详情界面是否显示服务合同信息' WHERE tabid = @tabid and columnname = 'select_servicedetail' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '客户管理和客户服务单详情界面是否显示具体的服务到期日' WHERE tabid = @tabid and columnname = 'select_due_date' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '客户服务单详情界面是否显示客户服务单历史记录' WHERE tabid = @tabid and columnname = 'helpdesk_log' and default_helptips is NULL;

UPDATE ld_field set default_helptips = '单据相关信息列表是否允许查询所有关联数据' WHERE tabid = @tabid and columnname = 'accountallview' and default_helptips is NULL;
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='Products');
UPDATE ld_field set helptips = '点击查看详情' WHERE tabid = @tabid and columnname = 'qtyinstock' and helptips is NULL;
UPDATE ld_field set default_helptips = '点击查看详情' WHERE tabid = @tabid and columnname = 'qtyinstock' and default_helptips is NULL;
delimiter;

set @tabid=(select tabid from ld_tab where name ='Resignation');
update ld_field set relatedmodulefield='yes' where tabid=@tabid and columnname='resignation_group';
delimiter;

UPDATE ld_desk set fieldlabel='设置系统登录时密码连续输错{n}次后，不允许登陆的限制时长（为空表示不限制时长，允许登录）' WHERE labelbol='PwdErrorAllowTimes' and languagetype='zh' and labeltype='fixedstr';
delimiter;


SET @labelbol = 'SELECTFOLDERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'选择文件夹','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Select folder','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','recentModule','最近使用','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='recentModule' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','recentModule',"Recently used",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='recentModule' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','highFrequency','高频使用','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='highFrequency' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','highFrequency',"High frequency usage",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='highFrequency' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_appuiset_for_tab_tabname`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_appuiset_for_tab_tabname`(
)
BEGIN
	DECLARE tmp_settabid int(11);
	DECLARE tmp_setname varchar(100);
	DECLARE tmp_userid int(11);
	DECLARE tmp_tabid int(11);
	DECLARE tmp_id int(11);
	DECLARE tmp_entitytype varchar(100);

	DECLARE MYCUSOR CURSOR FOR
select ld_appuiset.userid,ld_appuiset.setname,ld_appuiset.tabid as settabid,ld_tab.tabid,ld_linkmodulecustom.id,ld_linkmodulecustom.entitytype from ld_appuiset
  left join ld_tab on ld_tab.tabid = ld_appuiset.tabid and ld_tab.`name` = ld_appuiset.setname
   left join ld_linkmodulecustom on ld_linkmodulecustom.linkcvid = ld_appuiset.tabid and ld_linkmodulecustom.linkmodule = ld_appuiset.setname
where ld_appuiset.apptype = 'commonmodules' and ld_appuiset.settype = 'module'
  and ld_appuiset.setname not in('PublicAccounts','PublicLeads','GlobalScan','GlobalSearch') and ld_appuiset.tab_tablename is null;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_settabid = NULL;
OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_userid,tmp_setname,tmp_settabid,tmp_tabid,tmp_id,tmp_entitytype;
WHILE(tmp_settabid IS NOT NULL) DO
			set @tablename = if (tmp_tabid is not null , 'ld_tab',IF(tmp_entitytype = 'category','ld_linkmodulecustom_category','ld_linkmodulecustom'));
update ld_appuiset set tab_tablename = @tablename where userid = tmp_userid and setname = tmp_setname and tabid = tmp_settabid and apptype = 'commonmodules' and settype = 'module';
FETCH MYCUSOR INTO tmp_userid,tmp_setname,tmp_settabid,tmp_tabid,tmp_id,tmp_entitytype;
END WHILE;
CLOSE MYCUSOR;
END ||
delimiter;
CALL ldcrm_update_appuiset_for_tab_tabname();
DROP PROCEDURE IF EXISTS `ldcrm_update_appuiset_for_tab_tabname`;
delimiter;

UPDATE ld_attachments set watermark = 'no' where watermark is NULL;
UPDATE ld_attachmentsforbillsdetails set watermark = 'no' where watermark is NULL;
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

CREATE TABLE if not EXISTS `ld_crmlog_viewdetail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(20) NOT NULL,
  `action` varchar(100) NOT NULL,
	`actiontype` varchar(100) NOT NULL,
	`module` varchar(100) DEFAULT NULL,
	`crmid` int(19) DEFAULT NULL,
	`operationdetails` text DEFAULT NULL,
  `operationtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

SET @labelbol = 'VIEWDETAILSINFO';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'查看详情',@labeltype FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'viewDetailsInfo',@labeltype FROM dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'COMMONLYUSED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'常用',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'CommonlyUsed',@labeltype FROM dual
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOUBLECLICKTOSELECTDOCUMENT','双击选择','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOUBLECLICKTOSELECTDOCUMENT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOUBLECLICKTOSELECTDOCUMENT','Double click to select the document','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOUBLECLICKTOSELECTDOCUMENT' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','moduleAccounts','{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='moduleAccounts' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','moduleAccounts','{$Accounts.Accounts}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='moduleAccounts' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','modulePotentials','{$Potentials.Potentials}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='modulePotentials' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','modulePotentials','{$Potentials.Potentials}','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='modulePotentials' and labeltype='jspop' and languagetype='en');
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

UPDATE ld_version SET old_version='V8.6.3.7',current_version='V8.6.3.7',remark='V8.6.3.7-20240614',wx_version='V8.6.3.7';
delimiter;