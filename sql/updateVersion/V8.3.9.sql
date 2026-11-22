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

UPDATE ld_customreport_info SET setype=NULL WHERE report_template IN ('default_callcenter_report.mrt','default_callcenter_detail.mrt');
UPDATE ld_customreport_info SET presence=1 WHERE report_template IN ('default_callcenter_report.mrt','default_callcenter_detail.mrt')
	AND NOT EXISTS (SELECT 1 FROM ld_hantian_phonerecord);
    
DROP PROCEDURE IF EXISTS `ldcrm_addaccountid_forcustomform`;
delimiter ||
CREATE PROCEDURE `ldcrm_addaccountid_forcustomform`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_modulename VARCHAR(100) DEFAULT '';
	DECLARE tmp_tablename VARCHAR(100) DEFAULT '';
	DECLARE tmp_block INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR_ADDFIELD CURSOR FOR 
						SELECT 
							b.tabid,
							a.`name` AS modulename,
							b.tablename,
							b.block
						FROM ld_tab a
						LEFT JOIN ld_field b ON a.tabid=b.tabid
						WHERE a.`name` LIKE 'CustomForm%'
							AND b.columnname='smownerid'
						ORDER BY a.tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR_ADDFIELD; 
	FETCH MYCUSOR_ADDFIELD INTO tmp_id,tmp_modulename,tmp_tablename,tmp_block;
	WHILE(tmp_id IS NOT NULL) DO

		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=tmp_id AND columnname='accountid') THEN
			SET @modulename=tmp_modulename;
			SET @tabid=tmp_id;
			SET @relateid=tmp_block;
			SET @maxseq=-100;
			SET @trantable='ld_field';
			SET @tablename=tmp_tablename;
			SET @columnname='accountid'; 
			SET @fieldname='account_id'; 
			SET @zh='客户名称'; 
			SET @en='Account Name'; 
			SET @uitype=73; 
			SET @typeofdata='V~O';
			SET @quickcreate=1;
			SET @displaytype=1;
			SET @bigtype='reference';
			SET @datarang='permit';
			SET @maxrowsshow=10;

			IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype=@modulename) THEN 
				SET @presence=2;
			ELSE
				SET @presence=1;
			END IF;

			SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
			INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @i=0;
			UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@relateid AND presence<>1 ORDER BY sequence;
		
			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19',NULL);
			CALL getallprofile(@modulename);
			CALL fieldprofile(@modulename);
		END IF;

		SET @module='Accounts';
		SET @related_module=tmp_modulename;
		SET @actions='add';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
		SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@related_module);
		SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
		SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@related_module)),@seq+1,@related_module,1,@actions,'datacategory_sql',CONCAT(LOWER(@related_module),'.accountid') FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@related_module);

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		
		FETCH MYCUSOR_ADDFIELD INTO tmp_id,tmp_modulename,tmp_tablename,tmp_block;
	END WHILE;
	CLOSE MYCUSOR_ADDFIELD;

END ||
delimiter;

CALL ldcrm_addaccountid_forcustomform();
DROP PROCEDURE IF EXISTS `ldcrm_addaccountid_forcustomform`;
-- 2021-02-04

DROP PROCEDURE IF EXISTS `reset_expensedetail_info_formula`;
delimiter ||
CREATE  PROCEDURE `reset_expensedetail_info_formula`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tablename='ld_expensedetailscf' AND columnname='conversion_rate') THEN
		SET @this_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
		SET @this_tabdetailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='rmb_total');
		IF EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid AND formulastring='a*b*0.01') THEN
			DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid;
			INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
			SELECT @this_tabdetailfieldid,'a/b',"{formulavar:[{'lettervar':'a','column':'rmb_total'},{'lettervar':'b','column':'conversion_rate'}]}",1 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid);
		END IF;

		SET @this_tabdetailfieldid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='Rate');
		IF @this_tabdetailfieldid>0 THEN
			DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid=@this_tabdetailfieldid;
		END IF;
	END IF;
end ||
delimiter;

CALL reset_expensedetail_info_formula();
DROP PROCEDURE IF EXISTS `reset_expensedetail_info_formula`;
delimiter;

update ld_field set masseditable=0 where uitype=106 or uitype=99;
delimiter;

select sequence into @sequence from ld_homestuffdetail where stufflabel="NewLeadsCount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'ExpensesAmount','fixedstr','ld_expense.total','sum','index.php?pageto_module=Expense&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='ExpensesAmount');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='ExpensesAmount';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_expense:expensedate:expensedate:Expense_报销日期:D','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_expense:expensedate:expensedate:Expense%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_expense:approvestatus:approvestatus:Expense_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_expense:approvestatus:approvestatus:Expense%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExpensesAmount','{$Expense.Expense}金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExpensesAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExpensesAmount','{$Expense.Expense} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExpensesAmount' and Labeltype='fixedstr');
delimiter;

select sequence into @sequence from ld_homestuffdetail where stufflabel="ExpensesAmount" and stuffid=35;
set @sequence=@sequence+1;
update ld_homestuffdetail set sequence=sequence+1 where sequence>=@sequence;
insert  into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,presence)
select 35,'CommissionsAmount','fixedstr','ld_commission.total','sum','index.php?pageto_module=Commission&pageto_action=index',@sequence,'no' from dual
where not exists(select 1 from ld_homestuffdetail where stuffid=35 and stufflabel='CommissionsAmount');
delimiter;
select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='CommissionsAmount';

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_commission:createdtime:createdtime:Commission_创建时间:DT','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_commission:createdtime:createdtime:Commission%') ;

insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_commission:approvestatus:approvestatus:Commission_审批状态:V','','' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_commission:approvestatus:approvestatus:Commission%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CommissionsAmount','{$Commission.Commission}金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CommissionsAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CommissionsAmount','{$Commission.Commission} amount','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CommissionsAmount' and Labeltype='fixedstr');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomForm24' LIMIT 1);
SET @mypresence=(SELECT COUNT(1) FROM ld_option_module WHERE tabid=@tabid AND option_tabid IN (22,37) AND presence=0);
UPDATE ld_option_module SET presence=0 WHERE tabid=@tabid AND @mypresence=0 AND option_tabid IN (22,37)
	AND EXISTS (SELECT 1 FROM ld_version WHERE trade='construction');
delimiter;
-- 2021-02-18

ALTER TABLE ld_leads MODIFY COLUMN lastcontactdate DATETIME;
UPDATE (
	SELECT
		leads_id,
		MAX(contactdate) AS max_contactdate
	FROM ld_contactrecords
	WHERE deleted=0
		AND leads_id>0
	GROUP BY leads_id
) a
INNER JOIN ld_leads b ON b.leadsid=a.leads_id
SET b.lastcontactdate=a.max_contactdate;

select count(1) into @cnt from ld_account_public where `status` = 'yes';
update ld_account set publicaccount = 1 where pool_id >= 1 and IFNULL(allocatedate,'0000-00-00') < '1600-01-01' and publicaccount = 0 and @cnt = 1;
update ld_account set publicaccount = 2 where pool_id >= 1 and IFNULL(allocatedate,'0000-00-00') > '1600-01-01' and publicaccount = 0 and @cnt = 1;
delimiter;

update ld_desk set fieldlabel = '您的客户被{operator}在{nowtime}正在尝试报备，请联系{operator}，联系电话：{operatorphone}' 
where languagetype = 'zh' and labelbol = 'REMINDOPEAFORHEDGING' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = ' Your customer is trying to report by the {operator} at {nowtime}. Please contact the {operator} at {operatorphone}' 
where languagetype = 'en' and labelbol = 'REMINDOPEAFORHEDGING' and Labeltype = 'fixedstr';
delimiter;

SELECT Parent_id INTO @usereportid FROM ld_usereport WHERE NAME = 'Salesranking';
SELECT sequence INTO @sequence FROM ld_usereport WHERE NAME = 'Salesranking';

INSERT INTO ld_usereport ( NAME, reportlabel, tabids, basicfilter, advfilter, Setcolumns, Parent_id, sequence, reporttype, pagewidthpercent, setype) SELECT 'ProductRanking', '产品销售排行榜', 22, 1, 0, 1 ,@usereportid ,@sequence + 1, 65, 110, 'Products' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_usereport WHERE NAME = 'ProductRanking');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'ProductRanking', '产品销售排行榜', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'ProductRanking' AND Labeltype = 'fixedstr' AND languagetype = 'zh');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'ProductRanking', 'Product Ranking', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'ProductRanking' AND Labeltype = 'fixedstr' AND languagetype = 'en');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productSignCount', '产品签约数量', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productSignCount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'productSignCount', 'Product Contract Quantity', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productSignCount' AND Labeltype = 'fixedstr' AND languagetype = 'en' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productSignAmount', '产品签约金额', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productSignAmount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'productSignAmount', 'Product Contract Amount', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productSignAmount' AND Labeltype = 'fixedstr' AND languagetype = 'en' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productOrderCount', '产品订单数量', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOrderCount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'productOrderCount', 'Product Order Quantity', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOrderCount' AND Labeltype = 'fixedstr' AND languagetype = 'en');

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productOrderAmount', '产品订单金额', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOrderAmount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'productOrderAmount', 'Product Order Amount', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOrderAmount' AND Labeltype = 'fixedstr' AND languagetype = 'en' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productInvoiceAmount', '产品开票金额', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productInvoiceAmount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'productInvoiceAmount', 'Product Invoice Amount', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productInvoiceAmount' AND Labeltype = 'fixedstr' AND languagetype = 'en' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productOutboundCount', '产品出库数量', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOutboundCount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype ) SELECT 'en', 'productOutboundCount', 'Products Outbound Quantity', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOutboundCount' AND Labeltype = 'fixedstr' AND languagetype = 'en' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'productOutboundAmount', '产品出库金额', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOutboundAmount' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype ) SELECT 'en', 'productOutboundAmount', 'Products Outbound Amount', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'productOutboundAmount' AND Labeltype = 'fixedstr' AND languagetype = 'en');

SELECT usereportid INTO @usereportid FROM ld_usereport WHERE NAME = 'ProductRanking'; update ld_usereportbasic set sequence=sequence+1;

INSERT INTO ld_usereportbasic ( Usereportid, `columns`, Defaultvalue, Sequence) SELECT @usereportid, 'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D', 'thisstartmonth~thisendmonth', 1 FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportbasic WHERE Usereportid = @usereportid AND `columns` = 'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' );

SELECT usereportid INTO @id FROM ld_usereport WHERE NAME = 'ProductRanking';

INSERT INTO ld_usereportcolumns (Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns) 
SELECT @id, 'ld_products:productid:productid:Products_productid:V', 1, 1, 'ld_products:productid:productid:Products_排名:V', 'ld_products:productid:productid:Products_sort:V' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_products:productid:productid:Products_排名:V' );

INSERT INTO ld_usereportcolumns (Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns) 
SELECT @id, 'ld_products:productname:productname:Products_productname:V', 1, 1, 'ld_products:productname:productname:Products_签约_产品名称:V', 'ld_products:productname:productname:Products_product_name:V' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_products:productname:productname:Products_签约_产品名称:V');

INSERT INTO ld_usereportcolumns (Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns) 
SELECT @id, 'ld_products:product_no:product_no:Products_product_no:V', 1, 1, 'ld_products:product_no:product_no:Products_产品编号:V', 'ld_products:product_no:product_no:Products_product_NO:V' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_products:product_no:product_no:Products_产品编号:V' );

INSERT INTO ld_usereportcolumns (Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns) 
SELECT @id, 'ld_products:product_count:product_count:Products_product_count:V', 1, 1, 'ld_products:product_count:product_count:Products_产品签约数量:V', 'ld_products:product_count:product_count:Products_product_count:V' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_products:product_count:product_count:Products_产品签约数量:V' );

INSERT INTO ld_usereportcolumns (Usereportid, columns, Sequence, columnshow, realcolumns, realencolumns) 
SELECT @id, 'ld_products:productsheet:productsheet:Products_productsheet:V', 1, 1, 'ld_products:productsheet:productsheet:Products_规格型号:V', 'ld_products:productsheet:productsheet:Products_productsheet:V' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_usereportcolumns WHERE Usereportid =@id AND realcolumns = 'ld_products:productsheet:productsheet:Products_规格型号:V' );
delimiter;
-- 2021-02-22

DROP PROCEDURE IF EXISTS `reset_billinfo_20210915_01`;
delimiter ||
CREATE  PROCEDURE `reset_billinfo_20210915_01`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ProjectMilestone') THEN
		CALl AddColumn('ld_projectmilestone','approvestatus','VARCHAR','50','未提交');
		CALl AddColumn('ld_projectmilestone','approvetime','DATETIME','8','0');
		CALl AddColumn('ld_projectmilestone','approveby','INT','19','');
		CALl AddColumn('ld_projectmilestone','currentapprover','TEXT','100','');

		CALl AddColumn('ld_projectmilestone','approvesubmitter','INT','19',0);
		CALl AddColumn('ld_projectmilestone','approvesubmittedtime','DATETIME','8',0);
		CALl AddColumn('ld_projectmilestone','currentapprovestepid','INT','19',0);

		SET @modulename='ProjectMilestone';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvestatus'; 
		SET @fieldname='approvestatus'; 
		SET @zh='审批状态'; 
		SET @en='Approve status'; 
		SET @uitype=609; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn('ld_projectmilestone','approvestatus','VARCHAR','50','未提交');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @modulename='ProjectMilestone';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approveby'; 
		SET @fieldname='approveby'; 
		SET @zh='上一步审批人'; 
		SET @en='Approve By'; 
		SET @uitype=131; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn('ld_projectmilestone','approveby','INT','19',NULL);

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @modulename='ProjectMilestone';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='currentapprover'; 
		SET @fieldname='currentapprover'; 
		SET @zh='当前审批人'; 
		SET @en='Current Approver'; 
		SET @uitype=132; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn('ld_projectmilestone','currentapprover','TEXT','100',NULL);

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);

		SET @modulename='ProjectMilestone';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvetime'; 
		SET @fieldname='approvetime'; 
		SET @zh='最新审批时间'; 
		SET @en='Last Approve Time'; 
		SET @uitype=70; 
		SET @typeofdata='DT~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn('ld_projectmilestone','approvetime','DATETIME','','0');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @new_deploytype=275;
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 1,@new_deploytype,'项目里程碑是否启用审批流程 1:否，0:是','ProjectMilestone',@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);

		SET @i=0;
		SET @maxseq=(SELECT sequence FROM ld_systems_deploy WHERE deploy_type=98 AND roottype=@roottype LIMIT 1);
		UPDATE ld_systems_deploy SET sequence=sequence+5 WHERE sequence>@maxseq AND roottype=@roottype;
		UPDATE ld_systems_deploy SET sequence=@maxseq+1 WHERE deploy_type=@new_deploytype AND roottype=@roottype;
		UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY sequence;

		SET @tabid=46;
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
		SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

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

CALL reset_billinfo_20210915_01();
DROP PROCEDURE IF EXISTS `reset_billinfo_20210915_01`;
delimiter;

update ld_homestuffdetail set cssname="item-ico-expense",icon="crm_Expense.png" where stufflabel="ExpensesAmount";
update ld_homestuffdetail set cssname="item-ico-commission",icon="crm_Commission.png" where stufflabel="CommissionsAmount";
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
	tmp_moudlename VARCHAR(100),
	tmp_deploytype INT(19)
)
BEGIN
	
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;

	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) AND EXISTS (SELECT 1 FROM ld_tab WHERE `name`=@modulename) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

		CALl AddColumn(@tablename,'approvesubmitter','INT','19',0);
		CALl AddColumn(@tablename,'approvesubmittedtime','DATETIME','',0);
		CALl AddColumn(@tablename,'currentapprovestepid','INT','19',0);

		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvestatus'; 
		SET @fieldname='approvestatus'; 
		SET @zh='审批状态'; 
		SET @en='Approve status'; 
		SET @uitype=609; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approvestatus','VARCHAR','50','未提交');


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approveby'; 
		SET @fieldname='approveby'; 
		SET @zh='上一步审批人'; 
		SET @en='Approve By'; 
		SET @uitype=131; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approveby','INT','19',0);


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='currentapprover'; 
		SET @fieldname='currentapprover'; 
		SET @zh='当前审批人'; 
		SET @en='Current Approver'; 
		SET @uitype=132; 
		SET @typeofdata='V~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'currentapprover','TEXT','100','');


		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
		SET @columnname='approvetime'; 
		SET @fieldname='approvetime'; 
		SET @zh='最新审批时间'; 
		SET @en='Last Approve Time'; 
		SET @uitype=70; 
		SET @typeofdata='DT~O';
		SET @quickcreate=1;
		SET @displaytype=2;
		SET @bigtype=NULL;
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,'approvetime','DATETIME','','0');

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);


		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 1,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);



		SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		
		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

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

CALL ldcrm_add_approveforbill('VendorContactRecords',276);
CALL ldcrm_add_approveforbill('Attachment',277);
CALL ldcrm_add_approveforbill('PublicAnnouncement',278);
delimiter;

DROP PROCEDURE IF EXISTS `reset_billinfo_20210915`;
delimiter ||
CREATE  PROCEDURE `reset_billinfo_20210915`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname='approvestatus' AND tablename='ld_projectmilestone') THEN
		UPDATE ld_projectmilestone SET approvestatus='未提交' WHERE approvestatus IS NULL OR approvestatus='';
	END IF;

	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname='approvestatus' AND tablename='ld_vendorcontactrecords') THEN
		UPDATE ld_vendorcontactrecords SET approvestatus='未提交' WHERE approvestatus IS NULL OR approvestatus='';
	END IF;

	UPDATE ld_attachmentsforbills SET approvestatus='未提交' WHERE (approvestatus IS NULL OR approvestatus='');
	UPDATE ld_publicannouncement SET approvestatus='未提交' WHERE (approvestatus IS NULL OR approvestatus='');

end ||
delimiter;

CALL reset_billinfo_20210915();
DROP PROCEDURE IF EXISTS `reset_billinfo_20210915`;
delimiter;

UPDATE ld_field SET presence=1 WHERE tablename='ld_projectmilestone' AND columnname IN ('approveby','approvestatus','currentapprover','approvetime')
	AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_value=1 AND deploy_type=275);

UPDATE ld_field SET presence=1 WHERE tablename='ld_vendorcontactrecords' AND columnname IN ('approveby','approvestatus','currentapprover','approvetime')
	AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_value=1 AND deploy_type=276);

UPDATE ld_field SET presence=1 WHERE tablename='ld_attachmentsforbills' AND columnname IN ('approveby','approvestatus','currentapprover','approvetime')
	AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_value=1 AND deploy_type=277);

UPDATE ld_field SET presence=1 WHERE tablename='ld_publicannouncement' AND columnname IN ('approveby','approvestatus','currentapprover','approvetime')
	AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_value=1 AND deploy_type=278);
delimiter;

INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'qianyue', '签约', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'qianyue' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'qianyue', 'sign', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'qianyue' AND Labeltype = 'fixedstr' AND languagetype = 'en' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'dingdan', '订单', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'dingdan' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'dingdan', 'order', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'dingdan' AND Labeltype = 'fixedstr' AND languagetype = 'en' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'kaipiao', '开票', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'kaipiao' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'kaipiao', 'invoice', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'kaipiao' AND Labeltype = 'fixedstr' AND languagetype = 'en' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'zh', 'chuku', '出库', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'chuku' AND Labeltype = 'fixedstr' AND languagetype = 'zh' );
INSERT INTO ld_desk ( languagetype, labelbol, fieldlabel, labeltype) SELECT 'en', 'chuku', 'outbound', 'fixedstr' FROM DUAL WHERE NOT EXISTS ( SELECT 1 FROM ld_desk WHERE labelbol = 'chuku' AND Labeltype = 'fixedstr' AND languagetype = 'en' );
delimiter;
-- 2021-02-25

ALTER TABLE ld_account  MODIFY COLUMN `kis_id` varchar(200) NULL DEFAULT null;
ALTER TABLE ld_products  MODIFY COLUMN `kis_id` varchar(200) NULL DEFAULT null;
ALTER TABLE ld_salesorder  MODIFY COLUMN `kis_id` varchar(200) NULL DEFAULT null;
delimiter;

call AddColumn('ld_contactdetails','kis_id','varchar','200',NULL);
call AddColumn('ld_contactdetails','kis_no','varchar','50',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CopyRows', '复制行','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CopyRows');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CopyRows', 'Copy rows','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CopyRows');
delimiter;
-- 2021-02-26

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

UPDATE ld_version SET old_version='V8.3.9',current_version='V8.3.9',remark='V8.3.9-20210226',wx_version='V8.3.9';
delimiter;