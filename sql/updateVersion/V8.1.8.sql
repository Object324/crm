DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff_20200808`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_templatesstuff_20200808`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT templateid FROM ld_templatesstuff  GROUP BY templateid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		UPDATE ld_templatesstuff SET stuffsequence=-1 WHERE templateid=tmp_id AND stufftype='saleskit';
		SET @i=0;
		UPDATE ld_templatesstuff SET stuffsequence=(@i:=@i+1) WHERE templateid=tmp_id ORDER BY stuffsequence;
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_templatesstuff_20200808();
DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff_20200808`;

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

call AddColumn('ld_customform18','kis_id','int','11',0);
call AddColumn('ld_customform18','kis_no','varchar','50',NULL);
call AddColumn('ld_customform19','kis_id','int','11',0);
call AddColumn('ld_customform19','kis_no','varchar','50',NULL);
delimiter;

call AddColumn('ld_customform18','kis_id','int','11',0);
call AddColumn('ld_customform18','kis_no','varchar','50',NULL);
call AddColumn('ld_customform19','kis_id','int','11',0);
call AddColumn('ld_customform19','kis_no','varchar','50',NULL);
delimiter;

set @sequence = (SELECT max(sequence) from ld_homestuffdetail );
INSERT INTO ld_homestuffdetail( `stuffid`, `stufflabel`, `stufflabeltype`, `compute_columns`, `compute_type`, `pageurl`, `sequence`, `cssname`, `presence`, `icon`)  SELECT  35, 'NewSalesOrderReceipts', 'fixedstr', 'ld_cashbill.total', 'sum', 'index.php?pageto_module=CashBill&pageto_action=index', @sequence+1, 'item-ico-salesorder', 'yes', 'crm_SalesOrder.png' FROM DUAL WHERE NOT EXISTS (SELECT 1 from ld_homestuffdetail where stufflabel='NewSalesOrderReceipts');

INSERT INTO ld_desk(`languagetype`, `labelbol`, `fieldlabel`, `Labeltype`) SELECT  'zh', 'NewSalesOrderReceipts', '{$SalesOrder.SalesOrder}收款额', 'fixedstr' FROM DUAL WHERE NOT EXISTS (select * from ld_desk WHERE languagetype='zh' and labelbol ='NewSalesOrderReceipts');
INSERT INTO ld_desk(`languagetype`, `labelbol`, `fieldlabel`, `Labeltype`) SELECT  'en', 'NewSalesOrderReceipts', '{$SalesOrder.SalesOrder} Receipts', 'fixedstr' FROM DUAL WHERE NOT EXISTS (select * from ld_desk WHERE languagetype='en' and labelbol ='NewSalesOrderReceipts');

set @stuffid = (SELECT id FROM ld_homestuffdetail where stufflabel ='NewSalesOrderReceipts');
INSERT INTO ld_homestuffdetailcondition( `homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`) SELECT @stuffid, 1, 'ld_cashbill2paymentplan:entitytype:entitytype:CashBill_fieldlabe:V', 'SalesOrder', 'e' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_homestuffdetailcondition WHERE homestuffdetailid =@stuffid and columns = 'ld_cashbill2paymentplan:entitytype:entitytype:CashBill_fieldlabe:V');
INSERT INTO ld_homestuffdetailcondition( `homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`) SELECT @stuffid, 1, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D', '', '' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_homestuffdetailcondition WHERE homestuffdetailid =@stuffid and columns = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D');
INSERT INTO ld_homestuffdetailcondition( `homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`) SELECT @stuffid, 1, 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', '', '' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_homestuffdetailcondition WHERE homestuffdetailid =@stuffid and columns = 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V');


set @sequence = (SELECT max(sequence) from ld_homestuffdetail );
INSERT INTO ld_homestuffdetail( `stuffid`, `stufflabel`, `stufflabeltype`, `compute_columns`, `compute_type`, `pageurl`, `sequence`, `cssname`, `presence`, `icon`)  SELECT  35, 'NewServiceContractsReceipts', 'fixedstr', 'ld_cashbill.total', 'sum', 'index.php?pageto_module=CashBill&pageto_action=index', @sequence+1, 'item-ico-servicecontracts', 'yes', 'crm_ServiceContracts.png' FROM DUAL WHERE NOT EXISTS (SELECT 1 from ld_homestuffdetail where stufflabel='NewServiceContractsReceipts');

INSERT INTO ld_desk(`languagetype`, `labelbol`, `fieldlabel`, `Labeltype`) SELECT  'zh', 'NewServiceContractsReceipts', '{$ServiceContracts.ServiceContracts}收款额', 'fixedstr' FROM DUAL WHERE NOT EXISTS (select * from ld_desk WHERE languagetype='zh' and labelbol ='NewServiceContractsReceipts');
INSERT INTO ld_desk(`languagetype`, `labelbol`, `fieldlabel`, `Labeltype`) SELECT  'en', 'NewServiceContractsReceipts', '{$ServiceContracts.ServiceContracts} Receipts', 'fixedstr' FROM DUAL WHERE NOT EXISTS (select * from ld_desk WHERE languagetype='en' and labelbol ='NewServiceContractsReceipts');

set @stuffid = (SELECT id FROM ld_homestuffdetail where stufflabel ='NewServiceContractsReceipts');
INSERT INTO ld_homestuffdetailcondition( `homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`) SELECT @stuffid, 1, 'ld_cashbill2paymentplan:entitytype:entitytype:CashBill_fieldlabe:V', 'ServiceContracts', 'e' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_homestuffdetailcondition WHERE homestuffdetailid =@stuffid and columns = 'ld_cashbill2paymentplan:entitytype:entitytype:CashBill_fieldlabe:V');
INSERT INTO ld_homestuffdetailcondition( `homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`) SELECT @stuffid, 1, 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D', '', '' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_homestuffdetailcondition WHERE homestuffdetailid =@stuffid and columns = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D');
INSERT INTO ld_homestuffdetailcondition( `homestuffdetailid`, `groupid`, `columns`, `value`, `comparator`) SELECT @stuffid, 1, 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', '', '' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_homestuffdetailcondition WHERE homestuffdetailid =@stuffid and columns = 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V');
delimiter;

set @i =0;
UPDATE ld_homestuffdetail set sequence = (@i:=@i+1) ;
set @i =0;
UPDATE ld_homestuffdetail set sequence = (@i:=@i+1) WHERE presence ='yes' ORDER BY sequence asc LIMIT 6;
set @j = 8;
UPDATE ld_homestuffdetail set sequence = (@j:=@j+1) WHERE (sequence >6 and presence ='yes' )or  presence ='no'  ORDER BY sequence asc;
UPDATE ld_homestuffdetail set sequence = 7 where stufflabel ='NewSalesOrderReceipts';
UPDATE ld_homestuffdetail set sequence = 8 where stufflabel ='NewServiceContractsReceipts';
delimiter;

set @reportid = (SELECT Usereportid FROM ld_usereport where name ='Performancestatisticscollection');
INSERT INTO  ld_usereportcolumns ( `Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`) SELECT  @reportid, 'ld_cashbill:paymentmethod:paymentmethod:CashBill_paymentmethod:V', 9, 1, 'ld_cashbill:paymentmethod:paymentmethod:CashBill_收款方式:V', 'ld_cashbill:paymentmethod:paymentmethod:CashBill_Payment:V', NULL, 0  FROM DUAL WHERE not 	EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid=@reportid and columns ='ld_cashbill:paymentmethod:paymentmethod:CashBill_paymentmethod:V');
delimiter;

SET @usereportid  =(SELECT Usereportid FROM ld_usereport WHERE name='InventoryLedger');
SET @maxsequence =(SELECT max(sequence) FROM ld_usereportcolumns where Usereportid =@usereportid);
INSERT INTO  ld_usereportcolumns(`Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)  SELECT  @usereportid, 'ld_stock:expiry_date:expiry_date:Stock_失效日期:D', @maxsequence+1, 0, 'ld_stock:expiry_date:expiry_date:Stock_失效日期:D', 'ld_stock:expiry_date:expiry_date:Stock_Expiry Date:D', NULL, 0  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@usereportid and columns ='ld_stock:expiry_date:expiry_date:Stock_失效日期:D');
delimiter;

SET @usereportid  =(SELECT Usereportid FROM ld_usereport WHERE name='InventoryAccount');
SET @maxsequence =(SELECT max(sequence) FROM ld_usereportcolumns where Usereportid =@usereportid);
INSERT INTO  ld_usereportcolumns(`Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)  SELECT  @usereportid, 'ld_stock:expiry_date:expiry_date:Stock_失效日期:D', @maxsequence+1, 0, 'ld_stock:expiry_date:expiry_date:Stock_失效日期:D', 'ld_stock:expiry_date:expiry_date:Stock_Expiry Date:D', NULL, 0  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@usereportid and columns ='ld_stock:expiry_date:expiry_date:Stock_失效日期:D');
delimiter;

SET @usereportid  =(SELECT Usereportid FROM ld_usereport WHERE name='InventoryQuery');
SET @maxsequence =(SELECT max(sequence) FROM ld_usereportcolumns where Usereportid =@usereportid);
INSERT INTO  ld_usereportcolumns(`Usereportid`, `columns`, `Sequence`, `columnshow`, `realcolumns`, `realencolumns`, `tabname`, `is_advanced`)  SELECT  @usereportid, 'ld_stock:expiry_date:expiry_date:Stock_失效日期:D', @maxsequence+1, 0, 'ld_stock:expiry_date:expiry_date:Stock_失效日期:D', 'ld_stock:expiry_date:expiry_date:Stock_Expiry Date:D', NULL, 0  FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@usereportid and columns ='ld_stock:expiry_date:expiry_date:Stock_失效日期:D');
delimiter;

set @reportid = (SELECT Usereportid FROM ld_usereport where name ='Performancestatisticscollection');
set @i =0;
UPDATE ld_usereportcolumns set Sequence = (@i:=@i+1) WHERE Usereportid =@reportid ORDER BY Sequence asc ;
set @Sequence = (SELECT  Sequence FROM  ld_usereportcolumns WHERE Usereportid =@reportid AND   columns='ld_cashbill:pamount:pamount:OftenUseReport_pamount:N');
set @tmpSequence =@Sequence+2;
UPDATE ld_usereportcolumns set Sequence = (@tmpSequence:=@tmpSequence+1) WHERE Usereportid =@reportid and  Sequence >@Sequence ORDER BY Sequence asc ;
UPDATE ld_usereportcolumns set Sequence =@Sequence+1 WHERE Usereportid =@reportid and columns ='ld_cashbill:paymentmethod:paymentmethod:CashBill_paymentmethod:V';
delimiter;


call addcolumn('ld_potential','lastcontent','text','0',NULL);
call addcolumn('ld_potential','nolinkdays','int','19',0);
delimiter;

SET  @tabid = (select tabid  from ld_tab where name='Potentials');
SET @blockid = (select blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_OPPORTUNITY_INFORMATION');
SET @maxfieldid = (select id  from ld_field_seq);

INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`)
SELECT @tabid, @maxfieldid+1, 'lastcontent', 'yes', 'ld_potential', 1, '21', 'lastcontent', '最新进展', 1, 2, NULL, 1000, 9, @blockid, 2, 'V~O', 1, 0, 'BAS', 0, '', 0, 0, 1, 1, 0, 0, NULL, NULL, 2, 0, 'no', 'no', 'no', 'no', 'yes', 0, 0, 'yes', 'text', NULL, 0, NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field where tabid =@tabid and columnname='lastcontent');
INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) 
SELECT @tabid, @maxfieldid+2, 'nolinkdays', 'yes', 'ld_potential', 1, '7', 'nolinkdays', '未联系天数', 0, 2, '0', 100, 62, @blockid, 2, 'NN~O~13,0', 1, NULL, 'BAS', 1, NULL, 0, 0, 1, NULL, 0, 0, NULL, NULL, 2, 0, 'no', 'no', 'no', 'no', 'yes', 0, 0, 'yes', 'number', NULL, 0, NULL, 'yes', NULL FROM DUAL WHERE NOT EXISTS 
(SELECT 1 FROM ld_field where tabid =@tabid and columnname='nolinkdays');


SET @fieldid = (SELECT  fieldid FROM  ld_field WHERE  tabid =@tabid and columnname='lastcontent');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid ,'最新进展' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid ,'Latest Developments' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and relateid=@fieldid and trantable='ld_field');

SET @fieldid = (SELECT  fieldid FROM  ld_field WHERE  tabid =@tabid and columnname='nolinkdays');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid ,'未联系天数' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid ,'Nolinked Days' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and relateid=@fieldid and trantable='ld_field');


SET  @i =0;
UPDATE ld_field SET sequence =(@i:= @i+1) WHERE  tabid =@tabid and block =@blockid ORDER BY sequence ASC;
set @lastcontactdatesequence = (SELECT sequence FROM ld_field WHERE  tabid=@tabid and columnname='lastcontactdate');
UPDATE ld_field SET sequence =@lastcontactdatesequence+1 WHERE  tabid =@tabid and columnname ='lastcontent';
UPDATE ld_field SET sequence =@lastcontactdatesequence+2 WHERE  tabid =@tabid and columnname ='nolinkdays';

SET @tmpSequence = @lastcontactdatesequence+2;
UPDATE ld_field SET sequence =(@tmpSequence:= @tmpSequence+1) WHERE  tabid =@tabid and block =@blockid and sequence >@tmpSequence ORDER BY sequence ASC;
delimiter;

SET @disable_triggers=1;
UPDATE ld_potential a LEFT JOIN (SELECT tmp.* from ld_potential p INNER JOIN (SELECT * FROM (SELECT potentialid,contactdate,content FROM ld_contactrecords ORDER BY contactdate desc ) a GROUP BY potentialid
) tmp on p.potentialid = tmp.potentialid) b on b.potentialid = a.potentialid  set a.lastcontent= b.content;
update ld_potential set nolinkdays=datediff(CURDATE(),ifnull(lastcontactdate,date_format(createdtime,'%Y-%m-%d')));
delimiter;
SET @disable_triggers=NULL;

CALL AddColumn('ld_option_module', 'enablewhenadding', 'int', '2', 0);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnableWhenAdding','模块新增时启用','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'EnableWhenAdding' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnableWhenAdding',"Activate when the module is added",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'EnableWhenAdding' and labeltype = 'fixedstr');
delimiter;

SET @tabid = (SELECT tabid FROM ld_tab WHERE name = 'Singin');
UPDATE ld_option_module set enablewhenadding = IF(presence=0,1,0) WHERE tabid = @tabid;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HyperlinkField','超链接字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HyperlinkField' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HyperlinkField','Hyperlink field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HyperlinkField' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel='Next step approver' WHERE labelbol= 'NEXTOPERATOR' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

UPDATE  ld_desk  SET  fieldlabel ='模块新增时必填' where labelbol ='WHETHERITISAREQUIREDFILED' and  Labeltype='fixedstr' AND languagetype='zh';
UPDATE  ld_desk  SET  fieldlabel ='Must fill in when the module is added' where labelbol ='WHETHERITISAREQUIREDFILED' and  Labeltype='fixedstr' AND languagetype='en';
delimiter;
update ld_desk set fieldlabel='{$Productbom.Productbom}' where labelbol='PRODUCTPACKAGE';
delimiter;

alter table ld_productbom alter column conversion_rate set default '1';
alter table ld_productbom alter column currency_symbol set default '¥';
delimiter;

update ld_productbom set currency_symbol='¥'  where currency_symbol is null or currency_symbol='' ;
update ld_productbom set currency_id='1'  where ifnull(currency_id,0)=0 ;
update ld_productbom set conversion_rate='1'  where ifnull(conversion_rate,0)=0 ;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_share_action2tab`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_share_action2tab`(
)
BEGIN
	DECLARE tmp_tabid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT tabid FROM ld_tab WHERE `name` LIKE 'CustomForm%' AND RIGHT(`name`,2) BETWEEN 26 AND 60 ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_tabid;
	WHILE(tmp_tabid IS NOT NULL) DO
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 0,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=0);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 1,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=1);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 2,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=2);

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 3,tmp_tabid FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=tmp_tabid AND share_action_id=3);

		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

		UPDATE ld_def_org_share SET permission=3 WHERE tabid=tmp_tabid;

		FETCH MYCUSOR INTO tmp_tabid;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_reset_share_action2tab();
DROP PROCEDURE IF EXISTS `ldcrm_reset_share_action2tab`;
delimiter;

UPDATE ld_def_org_share SET permission=IFNULL(permission,3) WHERE permission IS NULL;
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_dailyreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_dailyreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkdaily LIKE '%:%') AND 
		NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='task_cooperativeworkdaily_eventreminder') THEN
			SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() 
							and content LIKE '日志提交提醒：%'  and reltab='CooperativeWork' ;
			if @cnt=0 then 
				CALL task_cooperativeworkdaily_eventreminder();
				UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkdaily_eventreminder';
			end if;
	END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkweek>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>NOW() AND type='task_cooperativeworkweek_eventreminder')  THEN
			
		SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() 
								and content LIKE '周计划提交提醒：%'  and reltab='CooperativeWork' ;
		if @cnt=0 then 
			CALL task_cooperativeworkweek_eventreminder();
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkweek_eventreminder';
		end if;

	END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `task_cooperativework_monthreport_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_monthreport_reminder_exec`(
)
BEGIN
	
	IF EXISTS (SELECT 1 FROM ld_workremindset WHERE cooperativeworkmonth>=3) AND NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>NOW() AND type='task_cooperativeworkmonth_eventreminder')  THEN
		
			SELECT count(1) into @cnt FROM ld_reminds WHERE  DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() 
								and content LIKE '月计划提交提醒：%'  and reltab='CooperativeWork' ;
			if @cnt=0 then 
				CALL task_cooperativework_monthreport_reminder();
				UPDATE ld_sys_event SET eventdate=NOW() WHERE type='task_cooperativeworkmonth_eventreminder';
			end if;
	END IF;

end ||
delimiter;
-- 2020-08-14

DROP EVENT IF EXISTS `update_potential_nolinkdays`;
delimiter ||
CREATE  EVENT `update_potential_nolinkdays` ON SCHEDULE EVERY 1 DAY STARTS '2020-08-14 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO 
	UPDATE ld_potential SET nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d')))
||
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

UPDATE ld_version SET old_version='V8.1.8',current_version='V8.1.8',remark='V8.1.8-202008014',wx_version='V8.1.8';
delimiter;