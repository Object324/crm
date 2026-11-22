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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
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

CREATE TABLE IF NOT EXISTS `ld_wechatuserid` (
	`id` int(11)  NOT NULL AUTO_INCREMENT,
	`wechatuserid` varchar(100) DEFAULT NULL,
	`convertuserid` varchar(255) DEFAULT NULL,
	`lastname` varchar(255) COMMENT '成员编辑后的姓名',
	`status` varchar(25) DEFAULT 'active' COMMENT '成员状态，离职(或者未开启存档)后标记为inactive',
	`createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
	`modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)  USING BTREE
	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnknownName','未知姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UnknownName' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnknownName','Unknown name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='UnknownName' and labeltype='fixedstr' and languagetype='en');
delimiter;

CALL addtableIndex('ld_wechatsession','idx_fromid','fromid');
CALL addtableIndex('ld_wechatsession','idx_roomid','roomid');
delimiter;


SET @modulename='Commission';
SET @tabid=(SELECT tabid FROM ld_tab WHERE name=@modulename);
UPDATE ld_tabdetailfield SET bigtype='amount',relatedmodulefield='yes',savedatabase='no',parentbigtype='currency' WHERE columnname='source_total' AND tabid=@tabid;

UPDATE ld_tabdetailfield SET fieldlabel='源单金额' WHERE columnname='source_total' AND tabid=@tabid AND fieldlabel='合同金额';

UPDATE ld_tranlabel a
LEFT JOIN ld_tabdetailfield b ON b.tabdetailfieldid=a.Relateid
SET 
	a.fieldlabel='源单金额'
WHERE a.trantable='ld_tabdetailfield'
	AND a.fieldlabel='合同金额'
	AND a.tabid=@tabid
	AND b.columnname='source_total'
	AND a.languagetype='zh';
delimiter;

INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT
	*
FROM (
	SELECT
		@modulename AS modulename,
		'entitytypeid' AS trigger_columnname,
		'source_total' AS effect_columnname,
		'source_total' AS curmodule_columninfo,
		'selectsource' AS fromvalue_type,
		CONCAT('[',GROUP_CONCAT(CONCAT('{"module":"',b.name,'","columntype":"main","column":"total"}')),']') AS fromvalue_info
	FROM ld_option_module a
	INNER JOIN ld_tab b ON b.tabid=a.option_tabid
	WHERE a.tabid=@tabid
		AND b.tabid>0
		AND b.tabid<>2
		AND NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename=@modulename AND trigger_columnname='entitytypeid' AND effect_columnname='source_total')
) a
WHERE fromvalue_info IS NOT NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PopupProductListDoubleClick','双击选择或者反选整单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PopupProductListDoubleClick' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PopupProductListDoubleClick',"Double-click to select or unselect the whole list",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PopupProductListDoubleClick' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PopupProductListDoubleClick','双击选择或者反选整单','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PopupProductListDoubleClick' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PopupProductListDoubleClick',"Double-click to select or unselect the whole list",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PopupProductListDoubleClick' and labeltype='jspop');
delimiter;

DROP PROCEDURE
    IF EXISTS `ldcrm_update_fieldsubtotalattr_history`;
delimiter ||

CREATE PROCEDURE `ldcrm_update_fieldsubtotalattr_history` ()
BEGIN
	IF NOT EXISTS(
		SELECT
			1
		FROM
			information_schema.`COLUMNS`
		WHERE
			TABLE_SCHEMA = DATABASE ()
		AND TABLE_NAME = 'ld_field'
		AND column_name = 'subtotal_attr'
	) THEN
		CALL AddColumn ('ld_field','subtotal_attr','varchar','10','');
CALL AddColumn ('ld_producttoolfield','subtotal_attr','varchar','10','');
CALL AddColumn ('ld_tabdetailfield','subtotal_attr','varchar','10','');
UPDATE ld_field SET subtotal_attr = 'yes' WHERE uitype IN ('7', '560', '71', '72') AND columnname <> 'nolinkdays' AND columnname <> 'approve_hours' AND columnname <> 'unit_price' AND columnname <> 'costprice';
update ld_producttoolfield set subtotal_attr = 'yes' where uitype in ('10','7','20','24','28','29','32','50');
update ld_tabdetailfield set subtotal_attr = 'yes' where fieldtype in ('num','number','int','amount','rmb_amount') and columnname <> 'conversion_rate';
END IF;
END||
delimiter;
CALL ldcrm_update_fieldsubtotalattr_history() ;
DROP PROCEDURE IF EXISTS `ldcrm_update_fieldsubtotalattr_history`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CalculateSubtotal','是否计算小计','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CalculateSubtotal' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CalculateSubtotal','Calculate Subtotal','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CalculateSubtotal' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_producttoolfield set savedatabase='yes' where uitype=69 or uitype=1109;
delimiter;

update ld_tabdetailfield set savedatabase='yes' where fieldtype='Attachment' or fieldtype='Image';
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'ACCOUNTCOUNT','fixedstr',
       'ld_account.account_no','count','新增客户数',
       'New Account Nums','',
       'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V','yes','Accounts','[{"groupid":"1","columnname":"ld_account:createdtime:createdtime:Accounts_fieldlabel:DT","comparator":"thismonth","value":"2023-11-01 00:00:00,2023-11-30 23:59:59","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='ACCOUNTCOUNT' and compute_module='Accounts' and stuffid=7);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'CALENDARCOUNT','fixedstr',
       'ld_activity.subject','count','新增日程数',
       'New Calendar Nums','',
       'ld_activity:smownerid:assigned_user_id:Calendar_fieldlabel:V','yes','Calendar','[null,{"groupid":"1","columnname":"ld_activity:createdtime:createdtime:Calendar_fieldlabel:DT","comparator":"thismonth","value":"2023-11-01 00:00:00,2023-11-30 23:59:59","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='CALENDARCOUNT' and compute_module='Calendar' and stuffid=7);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'POTENTIALCOUNT','fixedstr',
       'ld_potential.potential_no','count','新增销售机会数',
       'New Potential Nums','',
       'ld_potential:smownerid:assigned_user_id:Potential_fieldlabel:V','yes','Potentials','[null,{"groupid":"1","columnname":"ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT","comparator":"thismonth","value":"2023-11-01 00:00:00,2023-11-30 23:59:59","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='POTENTIALCOUNT' and compute_module='Potentials' and stuffid=7);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'SALESORDERCOUNT','fixedstr',
       'ld_salesorder.salesorder_no','count','新增合同数',
       'New Order Nums','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','[null,{"groupid":"1","columnname":"ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERCOUNT' and compute_module='SalesOrder' and stuffid=7);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'SALESORDERCOUNT','fixedstr',
       'ld_servicecontracts.contract_no','count','新增合同数',
       'New Order Nums','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','[null,{"groupid":"1","columnname":"ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERCOUNT' and compute_module='ServiceContracts' and stuffid=7);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'SALESORDERTOTAL','fixedstr',
       'ld_salesorder.total','sum','合同金额',
       'New Order Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','[null,{"groupid":"1","columnname":"ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERTOTAL' and compute_module='SalesOrder' and stuffid=7);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'SALESORDERTOTAL','fixedstr',
       'ld_servicecontracts.total','sum','合同金额',
       'New Order Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','[null,{"groupid":"1","columnname":"ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERTOTAL' and compute_module='ServiceContracts' and stuffid=7);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 7,'CASHBILLTOTAl','fixedstr',
       'ld_cashbill.total','sum','已收款',
       'New Cash Amount','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','[null,{"groupid":"1","columnname":"ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='CASHBILLTOTAl' and compute_module='CashBill' and stuffid=7);
delimiter;




INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'AMOUNTTO_Sales','fixedstr',
       'ld_cashbill.total','sum','收款金额',
       'Cash Amount','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','[null,{"groupid":"2","columnname":"ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D","comparator":"thisfy","value":"2023-01-01,2023-12-31","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='AMOUNTTO_Sales' and compute_module='CashBill' and stuffid=2);


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'AMOUNTTO_Service','fixedstr',
       'ld_cashbill.total','sum','收款金额',
       'Cash Amount','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','[null,{"groupid":"2","columnname":"ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D","comparator":"thisfy","value":"2023-01-01,2023-12-31","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='AMOUNTTO_Service' and compute_module='CashBill' and stuffid=2);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'signAmount_Sales','fixedstr',
       'ld_salesorder.total','sum','签约金额',
       'Sign Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','[null,{"groupid":"3","columnname":"ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D","comparator":"thisfy","value":"2023-01-01,2023-12-31","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='signAmount_Sales' and compute_module='SalesOrder' and stuffid=2);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'signAmount_Service','fixedstr',
       'ld_servicecontracts.total','sum','签约金额',
       'Sign Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','[null,{"groupid":"4","columnname":"ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D","comparator":"thisfy","value":"2023-01-01,2023-12-31","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='signAmount_Service' and compute_module='ServiceContracts' and stuffid=2);
delimiter;




INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'signNewAccount_Sales','fixedstr',
       'ld_account.account_no','count','签约新客户',
       'New Sign Acounts','',
       'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V','yes','Accounts','[null,{"groupid":"5","columnname":"ld_account:createdtime:createdtime:Accounts_fieldlabel:DT","comparator":"thisfy","value":"2023-01-01 00:00:00,2023-12-31 23:59:59","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='signNewAccount_Sales' and compute_module='Accounts' and stuffid=2);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'signNewAccount_Service','fixedstr',
       'ld_account.account_no','count','签约新客户',
       'New Sign Acounts','',
       'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V','yes','Accounts','[null,{"groupid":"5","columnname":"ld_account:createdtime:createdtime:Accounts_fieldlabel:DT","comparator":"thisfy","value":"2023-01-01 00:00:00,2023-12-31 23:59:59","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='signNewAccount_Service' and compute_module='Accounts' and stuffid=2);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'signCount_Sales','fixedstr',
       'ld_salesorder.salesorder_no','count','签约数',
       'Sign Count','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','[null,{"groupid":"3","columnname":"ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D","comparator":"thisfy","value":"2023-01-01,2023-12-31","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='signCount_Sales' and compute_module='SalesOrder' and stuffid=2);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 2,'signCount_Service','fixedstr',
       'ld_servicecontracts.contract_no','count','签约数',
       'Sign Count','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','[null,{"groupid":"4","columnname":"ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D","comparator":"thisfy","value":"2023-01-01,2023-12-31","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='signCount_Service' and compute_module='ServiceContracts' and stuffid=2);
delimiter;





INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'ACCOUNTCOUNT','fixedstr',
       'ld_account.account_no','count','新增客户数',
       'New Account Nums','',
       'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V','yes','Accounts','[{"groupid":"1","columnname":"ld_account:createdtime:createdtime:Accounts_fieldlabel:DT","comparator":"thismonth","value":"2023-11-01 00:00:00,2023-11-30 23:59:59","columncondition":"and"},{"groupid":"1","columnname":"ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='ACCOUNTCOUNT' and compute_module='Accounts' and stuffid=8);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'CALENDARCOUNT','fixedstr',
       'ld_activity.subject','count','新增日程数',
       'New Calendar Nums','',
       'ld_activity:smownerid:assigned_user_id:Calendar_fieldlabel:V','yes','Calendar','[null,{"groupid":"1","columnname":"ld_activity:createdtime:createdtime:Calendar_fieldlabel:DT","comparator":"thismonth","value":"2023-11-01 00:00:00,2023-11-30 23:59:59","columncondition":"and"},{"groupid":"1","columnname":"ld_activity:smownerid:assigned_user_id:Calendar_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='CALENDARCOUNT' and compute_module='Calendar' and stuffid=8);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'POTENTIALCOUNT','fixedstr',
       'ld_potential.potential_no','count','新增销售机会数',
       'New Potential Nums','',
       'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V','yes','Potentials','[null,{"groupid":"1","columnname":"ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT","comparator":"thismonth","value":"2023-11-01 00:00:00,2023-11-30 23:59:59","columncondition":"and"},{"groupid":"1","columnname":"ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='POTENTIALCOUNT' and compute_module='Potentials' and stuffid=8);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'SALESORDERCOUNT','fixedstr',
       'ld_salesorder.salesorder_no','count','新增合同数',
       'New Order Nums','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','[null,{"groupid":"1","columnname":"ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":"and"},{"groupid":"1","columnname":"ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERCOUNT' and compute_module='SalesOrder' and stuffid=8);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'SALESORDERCOUNT','fixedstr',
       'ld_servicecontracts.contract_no','count','新增合同数',
       'New Order Nums','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','[null,{"groupid":"1","columnname":"ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":"and"},{"groupid":"1","columnname":"ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERCOUNT' and compute_module='ServiceContracts' and stuffid=8);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'SALESORDERTOTAL','fixedstr',
       'ld_salesorder.total','sum','合同金额',
       'New Order Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','[null,{"groupid":"1","columnname":"ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":"and"},{"groupid":"1","columnname":"ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERTOTAL' and compute_module='SalesOrder' and stuffid=8);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'SALESORDERTOTAL','fixedstr',
       'ld_servicecontracts.total','sum','合同金额',
       'New Order Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','[null,{"groupid":"1","columnname":"ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":"and"},{"groupid":"1","columnname":"ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SALESORDERTOTAL' and compute_module='ServiceContracts' and stuffid=8);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 8,'CASHBILLTOTAl','fixedstr',
       'ld_cashbill.total','sum','已收款',
       'New Cash Amount','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','[null,{"groupid":"1","columnname":"ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D","comparator":"thismonth","value":"2023-11-01,2023-11-30","columncondition":"and"},{"groupid":"1","columnname":"ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V","comparator":"curuser","value":"","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='CASHBILLTOTAl' and compute_module='CashBill' and stuffid=8);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 6,'RECEIVEBYORDER','fixedstr',
       'ld_salesorder.receivable_balance','sum','应收(按合同)',
       'Receivable(By Order)','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='RECEIVEBYORDER' and compute_module='SalesOrder' and stuffid=6);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 6,'RECEIVEBYORDER','fixedstr',
       'ld_servicecontracts.receivable_balance','sum','应收(按合同)',
       'Receivable(By Order)','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='RECEIVEBYORDER' and compute_module='ServiceContracts' and stuffid=6);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 6,'RECEIVEBYPaymentplan','fixedstr',
       'ld_paymentplan.receivable_balance','sum','应收(按收款计划)',
       'Receivable(By Paymentplan)','',
       'ld_paymentplan:smownerid:assigned_user_id:Paymentplan_fieldlabel:V','yes','PaymentPlan','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='RECEIVEBYPaymentplan' and compute_module='PaymentPlan' and stuffid=6);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 6,'PaymentPurchase','fixedstr',
       'ld_purchaseorder.pay_balance','sum','应付(按采购订单)',
       'Payable(By Purchase)','',
       'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_fieldlabel:V','yes','PurchaseOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='PaymentPurchase' and compute_module='PurchaseOrder' and stuffid=6);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 6,'PaymentSendPayment','fixedstr',
       'ld_sendpayment.pay_balance','sum','应付(按付款计划)',
       'Payable(By SendPayment)','',
       'ld_sendpayment:smownerid:assigned_user_id:SendPayment_fieldlabel:V','yes','SendPayment','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='PaymentSendPayment' and compute_module='SendPayment' and stuffid=6);
delimiter;




INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_Cash','fixedstr',
       'ld_cashbill.total','sum','收款金额',
       'Cash Amount','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_Cash' and compute_module='CashBill' and stuffid=33);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_Order','fixedstr',
       'ld_salesorder.total','sum','签约金额',
       'Sign Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_Order' and compute_module='SalesOrder' and stuffid=33);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_Order','fixedstr',
       'ld_servicecontracts.total','sum','签约金额',
       'Sign Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_Order' and compute_module='ServiceContracts' and stuffid=33);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_Counts','fixedstr',
       'ld_salesorder.salesorder_no','count','签约数量',
       'Sign Count','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_Counts' and compute_module='SalesOrder' and stuffid=33);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 33,'SalesRanking_Counts','fixedstr',
       'ld_servicecontracts.contract_no','count','签约数量',
       'Sign Count','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='SalesRanking_Counts' and compute_module='ServiceContracts' and stuffid=33);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_amount_sales','fixedstr',
       'ld_salesorder.total','sum','合同金额',
       'Sign Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_amount_sales' and compute_module='SalesOrder' and stuffid=34);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_received_sales','fixedstr',
       'ld_salesorder.received_amount','sum','合同已收',
       'Received Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_received_sales' and compute_module='SalesOrder' and stuffid=34);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_balance_sales','fixedstr',
       'ld_salesorder.receivable_balance','sum','合同未收',
       'Receivable Balance Amount','',
       'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V','yes','SalesOrder','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_balance_sales' and compute_module='SalesOrder' and stuffid=34);
delimiter;



INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_amount_service','fixedstr',
       'ld_servicecontracts.total','sum','合同金额',
       'Sign Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_amount_service' and compute_module='ServiceContracts' and stuffid=34);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_received_service','fixedstr',
       'ld_servicecontracts.received_amount','sum','服务合同已收',
       'Received Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_received_service' and compute_module='ServiceContracts' and stuffid=34);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_balance_service','fixedstr',
       'ld_servicecontracts.receivable_balance','sum','服务合同未收',
       'Receivable Balance Amount','',
       'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V','yes','ServiceContracts','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_balance_service' and compute_module='ServiceContracts' and stuffid=34);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_cash_amount','fixedstr',
       'ld_cashbill.total','sum','收款金额',
       'Cash Amount','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_cash_amount' and compute_module='CashBill' and stuffid=34);
delimiter;
INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_approvecash_amount','fixedstr',
       'ld_cashbill.total','sum','收款金额_审批通过',
       'Cash Amount Approved','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','[{"groupid":"1","columnname":"ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V","comparator":"e","value":"已批准","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_approvecash_amount' and compute_module='CashBill' and stuffid=34);
delimiter;

INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_unapprovecash_amount','fixedstr',
       'ld_cashbill.total','sum','收款金额_审批未通过',
       'Cash Amount Unapproved','',
       'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V','yes','CashBill','[{"groupid":"1","columnname":"ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V","comparator":"n","value":"已批准","columncondition":""}]','[null,{"groupcondition":""}]',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_unapprovecash_amount' and compute_module='CashBill' and stuffid=34);
delimiter;


INSERT INTO ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,
                               compute_type,stufflabel_zh,stufflabel_en,daterange,viewrange,is_default,compute_module,
                               advance_demand,advance_demand_groups,topnumber)
SELECT 34,'transaction_cashback_amount','fixedstr',
       'ld_cashback.total','sum','退款金额',
       'CashBack Amount','',
       'ld_cashback:smownerid:assigned_user_id:CashBack_fieldlabel:V','yes','CashBack','','',0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_homestuffdetail WHERE stufflabel='transaction_cashback_amount' and compute_module='CashBack' and stuffid=34);
delimiter;

UPDATE ld_customreport set isshow_table = 'Bottom';
delimiter;

update ld_customreport
set themename = (
    case
        when themename = 'dark' then 'black'
        when themename = 'purple-passion' then 'purple'
        end
    );
delimiter;

SET @labelbol = 'DelVariableComfirm';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'确定删除变量吗','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sure you want to delete a variable ?','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

set @tabid = (SELECT tabid from ld_tab where name = 'Contacts');
set @trigger_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'accountid');
set @effect_fieldid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'reference');
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,'','sql',
       'SELECT CASE WHEN NOT EXISTS (SELECT 1 from ld_contactdetails where deleted = 0 and accountid={accountid}  and reference = 1) THEN 1 ELSE 0 END AS tmp_value' from DUAL
where NOT EXISTS (SELECT 1 FROM ld_related_field where trigger_fieldid =@trigger_fieldid and effect_fieldid = @effect_fieldid)
  AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AMOUNTTO_Sales','收款金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNTTO_Sales' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AMOUNTTO_Sales','Cash Amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNTTO_Sales' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AMOUNTTO_Service','收款金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AMOUNTTO_Service' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AMOUNTTO_Service','Cash Amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AMOUNTTO_Service' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','signAmount_Sales','签约金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signAmount_Sales' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','signAmount_Sales','Sign Amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signAmount_Sales' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','signAmount_Service','签约金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signAmount_Service' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','signAmount_Service','Sign Amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signAmount_Service' and labeltype='fixedstr');
delimiter;




insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','signNewAccount_Sales','签约新客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signNewAccount_Sales' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','signNewAccount_Sales','New Sign Acounts','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signNewAccount_Sales' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','signNewAccount_Service','签约新客户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signNewAccount_Service' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','signNewAccount_Service','New Sign Acounts','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signNewAccount_Service' and labeltype='fixedstr');
delimiter;




insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','signCount_Sales','签约数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signCount_Sales' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','signCount_Sales','Sign Count','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signCount_Sales' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','signCount_Service','签约数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='signCount_Service' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','signCount_Service','Sign Count','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='signCount_Service' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RECEIVEBYORDER','应收(按合同)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RECEIVEBYORDER' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RECEIVEBYORDER','Receivable(By Order)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RECEIVEBYORDER' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RECEIVEBYPaymentplan','应收(按收款计划)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RECEIVEBYPaymentplan' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RECEIVEBYPaymentplan','Receivable(By Paymentplan)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RECEIVEBYPaymentplan' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PaymentPurchase','应付(按采购订单)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PaymentPurchase' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PaymentPurchase','Payable(By Purchase)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PaymentPurchase' and labeltype='fixedstr');
delimiter;



insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PaymentSendPayment','应付(按付款计划)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PaymentSendPayment' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PaymentSendPayment','Payable(By SendPayment)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PaymentSendPayment' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SensitiveRules','敏感规则','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveRules' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SensitiveRules','Sensitive rules','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveRules' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SensitiveConditions','敏感条件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveConditions' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SensitiveConditions','Sensitive conditions','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveConditions' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EncryptionMethod','加密方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptionMethod' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EncryptionMethod','Encryption method','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptionMethod' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SensitiveAllEncrypted','敏感信息-全部加密','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveAllEncrypted' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SensitiveAllEncrypted','Sensitive Information - All encrypted','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveAllEncrypted' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SensitiveNonEditable','敏感信息-不可编辑','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveNonEditable' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SensitiveNonEditable','Sensitive Information - Non editable','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SensitiveNonEditable' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EffectWhenMet','满足条件时规则生效','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EffectWhenMet' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EffectWhenMet','Take effect when conditions are met','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EffectWhenMet' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EffectWhenNotMet','不满足条件时规则生效','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EffectWhenNotMet' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EffectWhenNotMet','Take effect when conditions are not met','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EffectWhenNotMet' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllEncrypted','全部加密','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllEncrypted' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllEncrypted','All encrypted','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AllEncrypted' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EncryptLeftPart','左起部分加密','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptLeftPart' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EncryptLeftPart','Encrypt left part','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptLeftPart' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EncryptRightPart','右起部分加密','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptRightPart' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EncryptRightPart','Encrypt right part','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptRightPart' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EncryptSpecifiedPart','指定部分加密','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptSpecifiedPart' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EncryptSpecifiedPart','Encrypt specified part','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EncryptSpecifiedPart' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_field','sensitivepresence','varchar','20','no');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_sensitiverules` (
  `sensitiveid` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(11) NOT NULL,
	`relatedfieldid` int(11) NOT NULL,
  `relatedtable` varchar(100) DEFAULT NULL ,
  `sensitivename` varchar(100) DEFAULT NULL,
  `rulestatus` varchar(20) DEFAULT NULL,
  `ruletype` varchar(20) DEFAULT NULL,
  `encryptyinfo` text(0) DEFAULT NULL,
  `effectivemethod` varchar(20) DEFAULT NULL,
	`group_condition` text(0) DEFAULT NULL,
	`createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
	`modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `smcreatorid` INT(11) DEFAULT NULL,
  `modifiedby` INT(11) DEFAULT NULL,
  PRIMARY KEY (`sensitiveid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_sensitiveruleconditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sensitiveid` int(11) NOT NULL,
	`selectfuntype` varchar(20) NOT NULL,
  `selectinfo` text(0) DEFAULT NULL ,
  `comparator` varchar(20) DEFAULT NULL,
  `comparefuntype` varchar(20) DEFAULT NULL,
  `compareinfo` text(0) DEFAULT NULL,
  `groupid` int(4) DEFAULT NULL,
  `rowcondition` char(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Displayallgroupstructure','展示全部组织架构信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Displayallgroupstructure' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Displayallgroupstructure','Display all organizational structure information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Displayallgroupstructure' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE
    IF EXISTS `ldcrm_update_fieldshowallgroupstructure_history_20231108`;
delimiter ||
CREATE PROCEDURE `ldcrm_update_fieldshowallgroupstructure_history_20231108` ()
BEGIN
IF NOT EXISTS ( SELECT 1 FROM information_schema.`COLUMNS` WHERE TABLE_SCHEMA = DATABASE () AND TABLE_NAME = 'ld_field' AND column_name = 'showallgroupstructure') THEN
	CALL AddColumn('ld_field','showallgroupstructure','char','10','yes');
	IF NOT EXISTS (select 1 from ld_crmentity where crmid>2) THEN
UPDATE ld_field SET showallgroupstructure = 'yes' WHERE uitype in (52,53,131,100,165,199,153,154,132,603);
END IF;
END IF ;
END||
delimiter;
CALL ldcrm_update_fieldshowallgroupstructure_history_20231108 () ;
DROP PROCEDURE IF EXISTS `ldcrm_update_fieldshowallgroupstructure_history_20231108` ;
delimiter;

SET @labelbol = 'ABOUTUS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公司简介','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'About Us','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'PRODUCTINTRODUCTION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公司简介','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Our product introduction','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Potentials');
set @tmp_fieldid = ( SELECT fieldid FROM ld_field where tabid = @tabid and (fieldname = 'cf_1308' or fieldname = 'cf_1317') ORDER BY fieldid LIMIT 1);
INSERT INTO ld_field_formula(`fieldid`, `formulastring`, `columnstring`, `functiontype`, `created_at`, `updated_at`)
SELECT @tmp_fieldid, 'select ROUND({a}/100* ( CASE WHEN (SELECT deploy_value from ld_systems_deploy WHERE deploy_type = 205) = 1 THEN {b} ELSE {c} END ),2) as tmp_value;', '{formulavar:[{\'lettervar\':\'a\',\'column\':\'possibility\'},{\'lettervar\':\'b\',\'column\':\'amount\'},{\'lettervar\':\'c\',\'column\':\'total\'}]}', 'sql', NOW(), NOW() FROM DUAL
where NOT EXISTS (SELECT 1 from ld_field_formula WHERE fieldid = @tmp_fieldid);
delimiter;


update ld_homestuffdetail set compute_columns='ld_account.account_no' where compute_columns='ld_account.accountid';
update ld_homestuffdetail set compute_columns='ld_contactdetails.contact_no' where compute_columns='ld_contactdetails.contactid';
update ld_homestuffdetail set compute_columns='ld_contactrecords.contactrecord_no' where compute_columns='ld_contactrecords.contactrecordID';
update ld_homestuffdetail set compute_columns='ld_contactrecords.contactrecord_no' where compute_columns='ld_contactrecords.accountid';
update ld_homestuffdetail set compute_columns='ld_salesorder.salesorder_no' where compute_columns='ld_salesorder.salesorderid';

update ld_homestuffdetail set compute_columns='ld_servicecontracts.contract_no' where compute_columns='ld_servicecontracts.servicecontractsid';
update ld_homestuffdetail set compute_columns='ld_cashbill.cashbill_no' where compute_columns='ld_cashbill.cashbillid';
update ld_homestuffdetail set compute_columns='ld_cashbill.cashbill_no' where compute_columns='ld_cashbill.accountid';
update ld_homestuffdetail set compute_columns='ld_leads.leads_no' where compute_columns='ld_leads.leadsid';
update ld_homestuffdetail set compute_columns='ld_outboundorder.out_no' where compute_columns='ld_outboundorder.out_id';
update ld_homestuffdetail set compute_columns='ld_invoice.invoice_no' where compute_columns='ld_invoice.invoiceid';
update ld_homestuffdetail set compute_columns='ld_purchaseorder.purchaseorder_no' where compute_columns='ld_purchaseorder.purchaseorderid';
update ld_homestuffdetail set compute_columns='ld_purchaseorder.purchaseorder_no' where compute_columns='ld_purchaseorder.vendorid';
update ld_homestuffdetail set compute_columns='ld_troubletickets.ticket_no' where compute_columns='ld_troubletickets.ticketid';
update ld_homestuffdetail set compute_columns='ld_troubletickets.ticket_no' where compute_columns='ld_troubletickets.servicecontractsid';
update ld_homestuffdetail set compute_columns='ld_potential.total' where stufflabel='NewPotentialsAmount' and compute_columns='ld_potential.amount';
update ld_homestuffdetail set compute_columns='ld_potential.potential_no' where stufflabel='NewPotentialsCount' and compute_columns='ld_potential.potentialid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTREVIEWER','请选择点评人!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTREVIEWER' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTREVIEWER',"Please select a reviewer !",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTREVIEWER' and labeltype='jspop');
delimiter;
-- 2023-11-05

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='自定义表单' WHERE Relateid=@parenttabid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel='Custom Forms';
delimiter;

UPDATE ld_tab SET showdisabledapprove = 'yes' WHERE NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid > 2);
delimiter;

ALTER TABLE ld_wechatsession MODIFY COLUMN fileext TEXT;
ALTER TABLE ld_wechatsession MODIFY COLUMN filepath TEXT;
ALTER TABLE ld_wechatsession MODIFY COLUMN roomname TEXT;
ALTER TABLE ld_wechatsession MODIFY COLUMN topic TEXT;
delimiter;

CALl AddColumn('ld_searchhistory','searchfrom','VARCHAR','100','listpage');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MoveRightToDisplay','拖动到右侧显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MoveRightToDisplay' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MoveRightToDisplay','Drag to the right to display','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='MoveRightToDisplay' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @tabid = (select tabid from ld_tab where `name` = 'Accounts');
update ld_field set displaytype = 1 where tabid = @tabid and columnname = 'mailingzip';
delimiter;

SET @module='Singin';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
SET @rel_tabid=-5;
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template='get_SharedUsers';
DELETE FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@rel_tabid AND `name`=@template;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,buttonstatus)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,'SharedUsers',0,'share','','','yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid  AND related_tabid=@rel_tabid AND `name`=@template);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnterColumnSearchFor','请输入要查找的栏目','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterColumnSearchFor' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnterColumnSearchFor','Please enter the column to search for','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterColumnSearchFor' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OptionModules','可选模块','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OptionModules' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OptionModules','Option modules','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OptionModules' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Selectedmodule','已选模块','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Selectedmodule' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Selectedmodule','Selected module','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Selectedmodule' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PleaseEnterModuleSearchFor','请输入要查找的模块','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterModuleSearchFor' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PleaseEnterModuleSearchFor','Please enter the module to search for','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='PleaseEnterModuleSearchFor' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_attachmentstype SET file_type='mpp' WHERE file_type like 'mpp，%';
INSERT INTO ld_attachmentstype (file_type)
SELECT 'mp4' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_attachmentstype WHERE file_type = 'mp4' AND module_name IS NULL);
delimiter;

call DelColumn('ld_workreport','signaddress_week');
call DelColumn('ld_workreport','signaddress_month');
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='WorkReportList');
delete from ld_field where tabid=@tabid and columnname='signaddress_week';
delete from ld_field where tabid=@tabid and columnname='signaddress_month';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TOTALOFSELECTEDDOCUMENTS','已选单据合计','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TOTALOFSELECTEDDOCUMENTS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TOTALOFSELECTEDDOCUMENTS',"Total of selected documents",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TOTALOFSELECTEDDOCUMENTS' and labeltype='fixedstr');
delimiter;
-- 2023-11-15


update ld_desk set fieldlabel = '驳回，返回初始状态' where labelbol = 'NOTPASSRETURNCHARGE' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Reject, return to initial state' where labelbol = 'NOTPASSRETURNCHARGE' and languagetype = 'en';
delimiter;

update ld_homestuffdetail set viewrange='' ,advance_demand='',advance_demand_groups='' where stuffid=2 and stufflabel="signNewAccount_Sales";
update ld_homestuffdetail set viewrange='' ,advance_demand='',advance_demand_groups='' where stuffid=2 and stufflabel="signNewAccount_Service";
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','PleaseEnterColumnSearchFor','请输入要查找的栏目', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'PleaseEnterColumnSearchFor' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','PleaseEnterColumnSearchFor','Please enter the category you are looking for', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'PleaseEnterColumnSearchFor' AND labeltype = 'jspop' );
delimiter;
-- 2023-11-17

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

UPDATE ld_version SET old_version='V8.6.1.3',current_version='V8.6.1.3',remark='V8.6.1.3-20231117',wx_version='V8.6.1.3';
delimiter;