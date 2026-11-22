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

ALTER TABLE ld_field_formula MODIFY formulastring TEXT;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SQLFormulaCannotEmpty','SQL内容不能为空','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SQLFormulaCannotEmpty' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SQLFormulaCannotEmpty','SQL content cannot be empty','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SQLFormulaCannotEmpty' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLFormulaTips1',"变量需用大括号'{a}'，查询结果需命名为tmp_value",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SQLFormulaTips1' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLFormulaTips1',"The variable is wrapped in '{a}' and the query result is named tmp_value",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SQLFormulaTips1' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SQLFormulaTips2',"特殊字段如关联选择单据需要查询ID和显示名称2个值，分别命名为tmp_valueid，tmp_value",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SQLFormulaTips2' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SQLFormulaTips2',"The query results, such as associated selection documents, are named tmp_value and tmp_valueid",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SQLFormulaTips2' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QUERYBYSQL',"通过SQL查询",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='QUERYBYSQL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QUERYBYSQL',"Query by sql",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='QUERYBYSQL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','QuerySqlError','查询SQL错误','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='QuerySqlError' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','QuerySqlError','Query sql error','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='QuerySqlError' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','businessqueryinterfacemethod','工商查询接口方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='businessqueryinterfacemethod' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','businessqueryinterfacemethod','Business query interface method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='businessqueryinterfacemethod' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','uselingdangbusinessinterfacekey','使用灵当天眼查工商接口','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='uselingdangbusinessinterfacekey' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','uselingdangbusinessinterfacekey','Use Lingdang business interface key','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='uselingdangbusinessinterfacekey' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','useselfpurchasedbusinessinterfacekey','使用自购天眼查工商接口','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='useselfpurchasedbusinessinterfacekey' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','useselfpurchasedbusinessinterfacekey','Use self purchased business interface key','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='useselfpurchasedbusinessinterfacekey' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','usageperiod','使用期限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='usageperiod' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','usageperiod','Usage Period','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='usageperiod' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','keyexpired','您的天眼查工商接口已到期，请联系服务商续费开通！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='keyexpired' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','keyexpired','Your business query interface has expired. Please contact your service provider for re-authorization!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='keyexpired' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_cvcolumnlist as a 
INNER JOIN ld_customview as c on c.cvid = a.cvid
INNER JOIN (SELECT CONCAT(tablename,':',columnname,':',fieldname,':',ld_tab.`name`,'_fieldlabel:') as tmp_field,SUBSTR(typeofdata,1,LOCATE('~',typeofdata)-1) as tmp_type,ld_tab.`name` as modulename
from ld_field INNER JOIN ld_tab on ld_tab.tabid = ld_field.tabid ) as b 
ON c.entitytype = b.modulename and a.columnname = b.tmp_field 
SET columnname = CONCAT(a.columnname,b.tmp_type);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)VALUES('en','TIMEANGE','Time Filtering','fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)VALUES('zh','TIMEANGE','时间筛选','fixedstr');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Checks');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename='ld_checks';
SET @columnname='smcreatorid';
SET @fieldname='creator';
SET @zh='创建人';
SET @en='Creator';
SET @uitype=52;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='users';
SET @datarang='';
SET @maxrowsshow=5;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


CALL AddColumn('ld_homestuffdetail','advance_demand','text','','');
CALL AddColumn('ld_homestuffdetail','advance_demand_groups','text','','');
delimiter;

UPDATE ld_homestuffdetail 
LEFT JOIN (
	SELECT 
		homestuffdetailid,
		CONCAT(
			'[null,',
			GROUP_CONCAT(
				'{"groupid":"',groupid,
				'","columnname":"',`columns`,
				'","comparator":"',comparator,
				'","value":"',`value`,
				'","columncondition":"',(CASE WHEN IFNULL(advance_demand,'')!='' THEN advance_demand WHEN id=tmpgroupsql.maxconditionid THEN '' ELSE 'and' END ),
				'"}')
			,']') AS advance_demandstr,
		(CASE WHEN IFNULL(advance_demand_groups,'')='' THEN '[null,{"groupcondition":""}]' ELSE advance_demand_groups END) AS advance_demand_groupsstr
	FROM ld_homestuffdetailcondition
	LEFT JOIN (
		SELECT 
			MAX(id) AS maxconditionid,
			homestuffdetailid AS detailid 
		FROM ld_homestuffdetailcondition 
		GROUP BY homestuffdetailid,groupid
	) tmpgroupsql ON tmpgroupsql.detailid=ld_homestuffdetailcondition.homestuffdetailid
	WHERE IFNULL(comparator,'')!=''
	GROUP BY homestuffdetailid
) tmp ON tmp.homestuffdetailid=ld_homestuffdetail.id
SET 
	ld_homestuffdetail.advance_demand=tmp.advance_demandstr,
	ld_homestuffdetail.advance_demand_groups=tmp.advance_demand_groupsstr
WHERE advance_demand IS NULL;
delimiter;


update ld_homestuffdetail set compute_module='Accounts' where stufflabel='NewAccounts';
update ld_homestuffdetail set compute_module='Contacts' where stufflabel='NewContacts';
update ld_homestuffdetail set compute_module='ContactRecords' where stufflabel='NewContactRecords';
update ld_homestuffdetail set compute_module='SalesOrder' where stufflabel='NewSalesOrderCount';
update ld_homestuffdetail set compute_module='ServiceContracts' where stufflabel='NewServiceContractsCount';
update ld_homestuffdetail set compute_module='SalesOrder' where stufflabel='NewSalesOrderAmount';
update ld_homestuffdetail set compute_module='ServiceContracts' where stufflabel='NewServiceContractsAmount';
update ld_homestuffdetail set compute_module='SalesOrder' where stufflabel='SignContractCount' and compute_columns='ld_salesorder.salesorderid';
update ld_homestuffdetail set compute_module='ServiceContracts' where stufflabel='SignContractCount' and compute_columns='ld_servicecontracts.servicecontractsid';
update ld_homestuffdetail set compute_module='SalesOrder' where stufflabel='SignContractAmount' and compute_columns='ld_salesorder.total';
update ld_homestuffdetail set compute_module='ServiceContracts' where stufflabel='SignContractAmount' and compute_columns='ld_servicecontracts.total';
update ld_homestuffdetail set compute_module='Invoice' where stufflabel='NewInvoiceAmount';
update ld_homestuffdetail set compute_module='OutboundOrder' where stufflabel='NewOutboundOrderAmount';
update ld_homestuffdetail set compute_module='CashBill' where stufflabel='NewCashBillAmount';
update ld_homestuffdetail set compute_module='Potentials' where stufflabel='NewPotentialsCount';
update ld_homestuffdetail set compute_module='Potentials' where stufflabel='NewPotentialsAmount';
update ld_homestuffdetail set compute_module='Potentials' where stufflabel='AdvancePotentialsAmount';
update ld_homestuffdetail set compute_module='Singin' where stufflabel='NewSignCount';
update ld_homestuffdetail set compute_module='Leads' where stufflabel='NewLeadsCount';
update ld_homestuffdetail set compute_module='HelpDesk' where stufflabel='NewHelpDeskCount';
update ld_homestuffdetail set compute_module='CashBill' where stufflabel='NewCashBillCount';
update ld_homestuffdetail set compute_module='OutboundOrder' where stufflabel='NewOutboundOrderCount';
update ld_homestuffdetail set compute_module='Invoice' where stufflabel='NewInvoiceCount';
update ld_homestuffdetail set compute_module='PurchaseOrder' where stufflabel='NewPurchaseOrderCount';
update ld_homestuffdetail set compute_module='PurchaseOrder' where stufflabel='NewPurchaseOrderAmount';
update ld_homestuffdetail set compute_module='CashBill' where stufflabel='NewSalesOrderReceipts';
update ld_homestuffdetail set compute_module='CashBill' where stufflabel='NewServiceContractsReceipts';
update ld_homestuffdetail set compute_module='Quotes' where stufflabel='NewQuotesCount';
update ld_homestuffdetail set compute_module='Quotes' where stufflabel='NewQuotesAmount' ;
update ld_homestuffdetail set compute_module='CashBill' where stufflabel='NewPaymentPlanCashBillAmount';
update ld_homestuffdetail set compute_module='Accounts' where stufflabel='LeadUgradeToCustomerCount';
update ld_homestuffdetail set compute_module='Expense' where stufflabel='ExpensesAmount';
update ld_homestuffdetail set compute_module='Commission' where stufflabel='CommissionsAmount';
update ld_homestuffdetail set compute_module='Salesorder' where stufflabel='SalesorderBalanceReceivable';
update ld_homestuffdetail set compute_module='ServiceContracts' where stufflabel='ServiceContractBalanceReceivable';
update ld_homestuffdetail set compute_module='Salesorder' where stufflabel='SignContractBalanceReceivable' and compute_columns='ld_salesorder.receivable_balance';
update ld_homestuffdetail set compute_module='ServiceContracts' where stufflabel='SignContractBalanceReceivable' and compute_columns='ld_servicecontracts.receivable_balance';
update ld_homestuffdetail set compute_module='PurchaseOrder' where stufflabel='PurchaseOrderPayBalance';
update ld_homestuffdetail set compute_module='ServiceCharge' where stufflabel='NewServiceChargeNums';
update ld_homestuffdetail set compute_module='Potentials' where stufflabel='LeadUgradeToPotentials';
delimiter;
-- 2023-07-25

SET @labelbol = 'PREVIEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'预览','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Preview','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'CANCELPREVIEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'取消预览','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cancel Preview','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'Potentials' );
update ld_relatedlists set actions = 'add' where tabid = @tabid and label = 'RECEIVABLESFORECAST';
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',4,'是否显示销售助手','no' ,'',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=4);
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'超过N天没有跟进的客户','no' ,'Accounts',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Accounts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'预计N天内成交的销售机会','no' ,'Potentials',1 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Potentials');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'N天内需要收款的回款计划','no' ,'PaymentPlan',2 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='PaymentPlan');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'N天内将到期的服务合同','no' ,'ServiceContracts',3 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='ServiceContracts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'最近N天将要过生日的联系人','no' ,'Contacts',4 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Contacts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',6,'是否显示关键视图','no' ,'',6 from dual
where not exists(select 1 from ld_appsystem where deploy_type=6 and description='是否显示关键视图');
delimiter;

UPDATE ld_desk SET fieldlabel = "自定义表单，有单据分录"
WHERE languagetype = 'zh' and labelbol = "CUSTOMFORMBASICREL" and Labeltype = 'fixedstr';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Products');
update ld_field set masseditable=2 where tabid=@tabid and columnname='unit_price' and masseditable=0 ;
delimiter;

update ld_desk set fieldlabel = '按住拖拽排序' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel = 'Hold down drag sort' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'en' and Labeltype='fixedstr';
update ld_desk set fieldlabel = '按住拖拽排序' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'zh' and Labeltype='jspop';
update ld_desk set fieldlabel = 'Hold down drag sort' WHERE labelbol = 'DRAGTOSORT' and languagetype = 'en' and Labeltype='jspop';
delimiter;
-- 2023-07-27


update ld_homestuffdetail set
advance_demand='[null,{"groupid":"1","columnname":"ld_account:kis_no:kis_no:Accounts_线索升级状态:V","comparator":"e","value":"升级到\\"客户\\"","columncondition":""}]',
advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='LeadUgradeToCustomerCount';

update ld_homestuffdetail set
advance_demand='[null,{"groupid":"1","columnname":"ld_potential:kis_no:kis_no:Potentials_线索升级状态:V","comparator":"e","value":"升级到\\"客户\\"和\\"销售机会\\"","columncondition":""}]',
advance_demand_groups='[null,{"groupcondition":""}]'
where stufflabel='LeadUgradeToPotentials';
delimiter;

update ld_homestuffdetail set compute_module='SalesOrder' where stufflabel='SalesorderBalanceReceivable';
update ld_homestuffdetail set compute_module='SalesOrder' where stufflabel='SignContractBalanceReceivable' and compute_columns='ld_salesorder.receivable_balance';
delimiter;


insert into ld_homeboard_plate_filter (boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
SELECT
    s.boardstuffid,'highsearch','yes','','PaymentPlan','PaymentPlan',
    '[null,{"groupid":"1","columnname":"ld_paymentplan:paymentstatus:paymentstatus:PaymentPlan_状态:V","comparator":"e","value":"未收","columncondition":""},{"groupid":"2","columnname":"ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D","comparator":"today","value":"2023-07-27,2023-07-27","columncondition":"or"},{"groupid":"2","columnname":"ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D","comparator":"before1days","value":"1600-01-01,2023-07-26","columncondition":"or"},{"groupid":"2","columnname":"ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D","comparator":"next30days","value":"2023-07-28,2023-08-26","columncondition":""}]',
    '[null,{"groupcondition":"and"},{"groupcondition":""}] '
from ld_homeboard_plate_stuff s
     left join ld_stuff on ld_stuff.stuffid=s.stuffid
     left join
     (
         select * from ld_homeboard_plate_filter
         where conditionkey='highsearch' and advance_demand is not null and advance_demand<>'[]'
     )tmp on s.boardstuffid=tmp.boardstuffid
where ld_stuff.stufftitle='WITHINPAYMENTPLAN'
  and tmp.boardstuffid is null ;
delimiter;

select (max(IFNULL(sequence,0))+1) into @sequence from ld_systems_deploy where roottype = 8;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,461,'设置移动端客户/服务收费管理单据详情页签上方是否显示联系人区块','',@sequence,8,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 461);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',461,461,'设置移动端客户/服务收费管理单据详情页签上方是否显示联系人区块'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_systems_deploy' and tabid = 461 and relateid=461);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',461,461,'Set whether the contact block is displayed above the mobile accounts/service charge document details tab'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_systems_deploy' and tabid = 461 and relateid=461);
delimiter;

SET @labelbol = 'DOWNLOAD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'下载','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Download','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;
-- 2023-07-28

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

UPDATE ld_version SET old_version='V8.6.0.2',current_version='V8.6.0.2',remark='V8.6.0.2-20230728',wx_version='V8.6.0.1';
delimiter;