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


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge' LIMIT 1);
SET @i=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @j=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable)
SELECT
	@i:=@i+1,
	@tabid,
	related_tabid,
	`name`,
	(@j:=@j+1),
	label,
	presence,
	actions,
	mobile_presence,
	mobile_sequence,
	type,
	related_coltable
FROM ld_relatedlists
WHERE tabid=6
	AND `name` LIKE 'get_customform%'
	AND related_tabid NOT IN (SELECT related_tabid FROM ld_relatedlists WHERE tabid=@tabid AND `name` LIKE 'get_customform%')
	ORDER BY sequence;

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge' LIMIT 1);
SET @i=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @j=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable)
SELECT
	@i:=@i+1,
	@tabid,
	related_tabid,
	`name`,
	(@j:=@j+1),
	label,
	presence,
	actions,
	mobile_presence,
	mobile_sequence,
	type,
	related_coltable
FROM ld_relatedlists
WHERE tabid=6
	AND related_tabid IN (47,48)
	AND related_tabid NOT IN (SELECT related_tabid FROM ld_relatedlists WHERE tabid=@tabid)
	ORDER BY sequence;
-- 2022-10-09

SET @modulename='ServiceContracts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='lastservicedate'; 
SET @fieldname='lastservicedate'; 
SET @zh='最晚服务到期日'; 
SET @en='Last Servicedate'; 
SET @uitype=5; 
SET @typeofdata='D~O';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='date';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @presence=1;
SET @editpage='listview';
SET @inputtype='formula';
SET @allowedit='no';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,editpage,input_type,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@editpage,@inputtype,@allowedit FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_field_formula(fieldid,columnstring,functiontype,created_at,updated_at)
SELECT @relateid,'servicecontracts_end_date','Max',NOW(),NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field_formula WHERE fieldid=@relateid);

CALl AddColumn(@tablename,@columnname,'DATE','10',NULL);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
delimiter;

SET @disable_triggers='abcdefg';
UPDATE ld_servicecontracts a
LEFT JOIN (
	SELECT 
		id,
		MAX(servicecontracts_end_date) AS lastservicedate 
	FROM ld_servicecontractsdetail 
	GROUP BY id
) b ON b.id=a.servicecontractsid
SET a.lastservicedate=b.lastservicedate;
SET @disable_triggers=NULL;
delimiter;

SET @modulename='LoanApply';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='accountid'; 
SET @fieldname='account_id'; 
SET @zh='客户名称'; 
SET @en='Account Name'; 
SET @uitype=73; 
SET @typeofdata='V~M';
SET @quickcreate=1;
SET @displaytype=1;
SET @bigtype='reference';
SET @datarang='permit';
SET @maxrowsshow=10;
SET @presence=1;
SET @editpage=NULL;
SET @inputtype=NULL;
SET @allowedit='yes';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,editpage,input_type,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0,@bigtype,@datarang,@maxrowsshow,@editpage,@inputtype,@allowedit FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

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
delimiter;
-- 2022-10-13

SET @Parent_id = (select Parent_id from ld_usereport where name='Sign_in_track');
SET @sequence = (select sequence from ld_usereport where name='Sign_in_track');
SET @maxsequence = (SELECT max(sequence) FROM ld_usereport WHERE Parent_id = @Parent_id);
update ld_usereport SET sequence = sequence + 1 WHERE sequence > @sequence AND Parent_id = @Parent_id AND @maxsequence < 7;
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,Parent_id, sequence, reporttype, pagewidthpercent, presence)
select 'SignDistribution','签到分布表',0,1,0,1,@Parent_id,@sequence+1,52,100,0 from dual
where not exists(select 1 from ld_usereport where name='SignDistribution');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SignDistribution','签到分布表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SignDistribution' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SignDistribution','Sign in distribution table','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SignDistribution' and labeltype='fixedstr');

SET @usereportid = (select usereportid from ld_usereport where name="SignDistribution");
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_singin:createdtime:signedtime:Singin_CreatedTime:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_singin:createdtime:signedtime:Singin_CreatedTime:D');
delimiter;
update ld_field set bigtype='currency' where tablename='ld_worksheet' and columnname='total';
delimiter;
call AddColumn('ld_groups', 'kis_id', 'varchar', '100', null);
delimiter;

update ld_desk set fieldlabel='CRM小程序' 
where languagetype='zh' and labelbol='LBI_MINI_SETTINGS' and labeltype='fixedstr';
update ld_desk set fieldlabel='CRM Applet' 
where languagetype='en' and labelbol='LBI_MINI_SETTINGS' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='CRM小程序' 
where languagetype='zh' and labelbol='WECHATAPPLETHEADER1' and labeltype='jspop';
update ld_desk set fieldlabel='CRM Applet' 
where languagetype='en' and labelbol='WECHATAPPLETHEADER1' and labeltype='jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ActualPay','实际付款金额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ActualPay' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ActualPay',"Actual Receipts",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ActualPay' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_customtable','istemplate','char','4','no');
CALL AddColumn('ld_customtable','isfolder','char','4','no');
CALL AddColumn('ld_customtable','templateid','int','11','0');
CALL AddColumn('ld_customtable','level','int','5',null);
delimiter;

update ld_customtable set isfolder='yes' where parent_id=0;
update ld_customtable set `level`='1' where parent_id=0;
update ld_customtable set `level`='2' where parent_id>0 and `level` is null;
delimiter;

DROP PROCEDURE IF EXISTS `reset_reportinfo_20221010`;
delimiter ||
CREATE  PROCEDURE `reset_reportinfo_20221010`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_customtable where report_name='模板报表' and deleted=0 and istemplate='yes' and parent_id=0) THEN
		select max(sequence) into @sequence from ld_customtable where deleted=0  and parent_id=0 ;
		INSERT INTO `ld_customtable` VALUES (null,'模板报表', 0, '', @sequence+1, NULL, NULL, NULL, NULL, NOW(),  NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,1);
		select report_id into @report_id from ld_customtable where report_name='模板报表' and deleted=0  and parent_id=0 and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'商机分析模板', @report_id, '', 2, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @shangji_id from ld_customtable where report_name='商机分析模板' and deleted=0 and parent_id=@report_id and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'客户分析模板', @report_id, '', 1, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @kehu_id from ld_customtable where report_name='客户分析模板' and deleted=0  and parent_id=@report_id and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'线索分析模板', @report_id, '', 0, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @xiansuo_id from ld_customtable where report_name='线索分析模板' and deleted=0  and parent_id=@report_id and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'订单分析模板', @report_id, '', 3, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @dingdan_id from ld_customtable where report_name='订单分析模板' and deleted=0  and parent_id=@report_id and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'采购分析模板', @report_id, '', 5, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @caigou_id from ld_customtable where report_name='采购分析模板' and deleted=0  and parent_id=@report_id and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'产品分析模板', @report_id, '', 6, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @chanpin_id from ld_customtable where report_name='产品分析模板' and deleted=0  and parent_id=@report_id and istemplate='yes' limit 1;

		INSERT INTO `ld_customtable` VALUES (null,'服务分析模板', @report_id, '', 4, NULL, NULL, NULL, NULL, NOW(), NOW(), 0, NULL, 1, 0, 'selectfield', NULL, 'yes','yes','yes',0,2);
		select report_id into @fuwu_id from ld_customtable where report_name='服务分析模板' and deleted=0  and parent_id=@report_id and istemplate='yes' limit 1;


		INSERT INTO `ld_customtable` VALUES (null,'产品采购汇总表', @chanpin_id, '', 10, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id87 from ld_customtable where report_name='产品采购汇总表' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id87, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '产品名称', 'ld_products:productname:productname:PurchaseOrder_产品名称:V', 'PurchaseOrder', 'yes', 'no', 'yes', '', 'left', 0, '产品名称', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '采购数量', 'ld_purchaseorderdetail:quantity:quantity:PurchaseOrder_数量:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', 1, '数量', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '采购单价', 'ld_purchaseorderdetail:taxprice:taxprice:PurchaseOrder_含税单价:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', 2, '含税单价', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '合计金额', 'ld_purchaseorderdetail:tax_amount:tax_amount:PurchaseOrder_价税合计:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', 3, '价税合计', 'g', '', 0, '', '', 'yes', NULL, NULL, 'yes', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '采购订单编号', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 4, '采购订单编号', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '采购负责人', 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 5, '采购负责人', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '供应商名称', 'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_供应商名称:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 6, '供应商名称', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '采购订单签约日期', 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 7, '签约日期', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id87, '目前入库状态', 'ld_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 8, '入库状态', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='PurchaseOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id87, @tabid, 'PurchaseOrder', 0);
		INSERT INTO `ld_customtable_sorting` VALUES (@report_id87, 'bycolumnname', 'PurchaseOrder', 'ld_products:productname:productname:PurchaseOrder_产品名称:V', 'asc', '', 0);

		INSERT INTO `ld_customtable` VALUES (null,'产品销量统计(按订单）', @chanpin_id, '', 12, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id88 from ld_customtable where report_name='产品销量统计(按订单）' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id88, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', 0, '产品名称', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '产品编号', 'ld_products:product_no:product_no:SalesOrder_产品编号:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 1, '产品编号', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '售出数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 2, '数量', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '单价', 'ld_salesorderdetail:taxprice:taxprice:SalesOrder_含税单价:N', 'SalesOrder', 'no', 'no', 'no', '', 'right', 3, '含税单价', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '售出总价', 'ld_salesorderdetail:tax_amount:tax_amount:SalesOrder_价税合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 4, '价税合计', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', 5, '签约日期', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 6, '销售负责人', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id88, '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', 7, '合同编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='SalesOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id88, @tabid, 'SalesOrder', 0);
		INSERT INTO `ld_customtable_sorting` VALUES (@report_id88, 'bycolumnname', 'SalesOrder', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'asc', '', 0);


		INSERT INTO `ld_customtable` VALUES (null,'线索状态统计', @xiansuo_id, '', 5, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id94 from ld_customtable where report_name='线索状态统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id94, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '线索状态', 'ld_leads:status:status:Leads_线索状态:V', 'Leads', 'yes', 'no', 'yes', '', 'left', 0, '线索状态', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#3fd4c5;font-size:13px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '线索负责人', 'ld_leads:smownerid:assigned_user_id:Leads_负责人:V', 'Leads', 'no', 'no', 'yes', '', 'left', 1, '负责人', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '线索编号', 'ld_leads:leads_no:leads_no:Leads_销售线索编号:V', 'Leads', 'no', 'no', 'no', 'count', 'left', 2, '销售线索编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '单位名称', 'ld_leads:accountname:accountname:Leads_客户名称:V', 'Leads', 'no', 'no', 'no', 'count', 'left', 3, '客户名称', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '联系人姓名', 'ld_leads:contactname:contactname:Leads_联系人姓名:V', 'Leads', 'no', 'no', 'no', '', 'left', 4, '联系人姓名', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '线索来源', 'ld_leads:leadsource:leadsource:Leads_商机来源:V', 'Leads', 'no', 'no', 'no', '', 'left', 5, '商机来源', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '意向产品', 'ld_leads:productcategory:productcategory:Leads_意向产品:V', 'Leads', 'no', 'no', 'no', '', 'left', 6, '意向产品', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '线索创建时间', 'ld_leads:createdtime:createdtime:Leads_创建时间:DT', 'Leads', 'no', 'no', 'no', '', 'left', 7, '创建时间', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '公海状态', 'ld_leads:publicaccount:publicaccount:Leads_公海状态:V', 'Leads', 'no', 'no', 'no', 'count', 'left', 8, '公海状态', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '最新进展', 'ld_leads:lastcontent:lastcontent:Leads_最新进展:V', 'Leads', 'no', 'no', 'no', '', 'left', 9, '最新进展', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id94, '未联系天数', 'ld_leads:nolinkdays:nolinkdays:Leads_未联系天数:NN', 'Leads', 'no', 'no', 'no', 'sum', 'right', 10, '未联系天数', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Leads';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id94, @tabid, 'Leads', 0);


		INSERT INTO `ld_customtable` VALUES (null,'按负责人统计线索状态', @xiansuo_id, '', 1, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id95 from ld_customtable where report_name='按负责人统计线索状态' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id95, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '线索负责人', 'ld_leads:smownerid:assigned_user_id:Leads_负责人:V', 'Leads', 'yes', 'no', 'yes', '', 'left', 0, '负责人', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#2bc4bf;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '线索状态', 'ld_leads:status:status:Leads_商机状态:V', 'Leads', 'no', 'no', 'yes', '', 'left', 1, '商机状态', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '线索编号', 'ld_leads:leads_no:leads_no:Leads_销售线索编号:V', 'Leads', 'no', 'no', 'no', 'count', 'left', 2, '销售线索编号', 'f', '', 0, '', '', 'yes', NULL, NULL, 'yes', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '单位名称', 'ld_leads:accountname:accountname:Leads_客户名称:V', 'Leads', 'no', 'no', 'no', '', 'left', 3, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '联系人姓名', 'ld_leads:contactname:contactname:Leads_联系人姓名:V', 'Leads', 'no', 'no', 'no', '', 'left', 4, '联系人姓名', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '联系人职务', 'ld_leads:contact_job:contact_job:Leads_联系人职务:V', 'Leads', 'no', 'no', 'no', '', 'left', 5, '联系人职务', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '线索来源', 'ld_leads:leadsource:leadsource:Leads_商机来源:V', 'Leads', 'no', 'no', 'no', '', 'left', 6, '商机来源', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '创建时间', 'ld_leads:createdtime:createdtime:Leads_创建时间:DT', 'Leads', 'no', 'no', 'no', '', 'left', 7, '创建时间', 'n', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '最新进展', 'ld_leads:lastcontent:lastcontent:Leads_最新进展:V', 'Leads', 'no', 'no', 'no', '', 'left', 8, '最新进展', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '最新联系日期', 'ld_leads:lastcontactdate:lastcontactdate:Leads_最新联系日期:DT', 'Leads', 'no', 'no', 'no', '', 'left', 9, '最新联系日期', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id95, '关闭原因', 'ld_leads:failurereason:failurereason:Leads_关闭原因:V', 'Leads', 'no', 'no', 'no', '', 'left', 10, '关闭原因', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Leads';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id95, @tabid, 'Leads', 0);

		INSERT INTO `ld_customtable` VALUES (null,'按来源汇总线索', @xiansuo_id, '', 3, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id96 from ld_customtable where report_name='按来源汇总线索' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id96, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '线索来源', 'ld_leads:leadsource:leadsource:Leads_商机来源:V', 'Leads', 'yes', 'no', 'yes', '', 'left', 0, '商机来源', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#3ac9c5;font-size:13px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '线索状态', 'ld_leads:status:status:Leads_商机状态:V', 'Leads', 'no', 'no', 'yes', '', 'left', 1, '商机状态', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '公司名称', 'ld_leads:accountname:accountname:Leads_客户名称:V', 'Leads', 'no', 'no', 'no', '', 'left', 2, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'yes', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '销售线索编号', 'ld_leads:leads_no:leads_no:Leads_销售线索编号:V', 'Leads', 'no', 'no', 'no', 'count', 'left', 3, '销售线索编号', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '联系人姓名', 'ld_leads:contactname:contactname:Leads_联系人姓名:V', 'Leads', 'no', 'no', 'no', '', 'left', 4, '联系人姓名', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '手机号码', 'ld_leads:mobile:mobile:Leads_手机号码:V', 'Leads', 'no', 'no', 'no', '', 'left', 5, '手机号码', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '负责人员', 'ld_leads:smownerid:assigned_user_id:Leads_负责人:V', 'Leads', 'no', 'no', 'no', '', 'left', 6, '负责人', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '线索创建时间', 'ld_leads:createdtime:createdtime:Leads_创建时间:DT', 'Leads', 'no', 'no', 'no', '', 'left', 7, '创建时间', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '未联系天数', 'ld_leads:nolinkdays:nolinkdays:Leads_未联系天数:NN', 'Leads', 'no', 'no', 'no', '', 'right', 8, '未联系天数', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id96, '最新进展', 'ld_leads:lastcontent:lastcontent:Leads_最新进展:V', 'Leads', 'no', 'no', 'no', '', 'left', 9, '最新进展', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Leads';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id96, @tabid, 'Leads', 0);


		INSERT INTO `ld_customtable` VALUES (null,'线索跟进动态统计', @xiansuo_id, '', 4, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id99 from ld_customtable where report_name='线索跟进动态统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id99, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '线索客户', 'ld_contactrecords:leads_id:leads_id:ContactRecords_销售线索:V', 'ContactRecords', 'yes', 'no', 'yes', '', 'left', 0, '销售线索', 'p', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '联系日期', 'ld_contactrecords:contactdate:contactdate:ContactRecords_联系日期:DT', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 1, '联系日期', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '跟进负责人', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_负责人:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 2, '负责人', 'm', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '线索联系人', 'ld_leads:contactname:contactname:Leads_联系人姓名:V', 'Leads', 'no', 'no', 'no', '', 'left', 3, '联系人姓名', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '跟进方式', 'ld_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_联系方式:V', 'ContactRecords', 'no', 'no', 'yes', '', 'left', 4, '联系方式', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '主题', 'ld_contactrecords:subject:subject:ContactRecords_主题:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 5, '主题', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '跟进内容', 'ld_contactrecords:content:content:ContactRecords_跟进记录:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 6, '跟进记录', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#29d6d0;font-size:13px;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '下次回访日期', 'ld_contactrecords:nextcontactdate:nextcontactdate:ContactRecords_下次回访日期:DT', 'ContactRecords', 'no', 'no', 'no', '', 'left', 7, '下次回访日期', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '线索来源', 'ld_leads:leadsource:leadsource:Leads_商机来源:V', 'Leads', 'no', 'no', 'yes', '', 'left', 8, '商机来源', 'o', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '线索状态', 'ld_leads:status:status:Leads_线索状态:V', 'Leads', 'no', 'no', 'yes', '', 'left', 9, '线索状态', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '线索创建时间', 'ld_leads:createdtime:createdtime:Leads_创建时间:DT', 'Leads', 'no', 'no', 'yes', '', 'left', 10, '创建时间', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id99, '跟进记录编号', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 11, '跟进记录编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Leads';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id99, @tabid, 'Leads', 0);
		select tabid into @tabid from ld_tab where name='ContactRecords';
		select id into @parent_id from ld_customtable_module where report_id=@report_id99 and modulename='Leads' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id99, @tabid, 'ContactRecords', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '员工客户数量统计', @kehu_id, '', 2, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id102 from ld_customtable where report_name='员工客户数量统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id102, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', 0, '销售负责人', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#41c4c0;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '客户状态', 'ld_account:rating:rating:Accounts_客户状态:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 1, '客户状态', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', 2, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '客户来源', 'ld_accountscf:leadsource:leadsource:Accounts_客户来源:V', 'Accounts', 'no', 'no', 'no', '', 'left', 3, '客户来源', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '重要级别', 'ld_accountscf:important_level:important_level:Accounts_重要级别:V', 'Accounts', 'no', 'no', 'no', '', 'left', 4, '重要级别', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '客户类型', 'ld_account:account_type:accounttype:Accounts_客户类型:V', 'Accounts', 'no', 'no', 'no', '', 'left', 5, '客户类型', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '所属公海', 'ld_account:pool_id:pool_id:Accounts_所属公海:V', 'Accounts', 'no', 'no', 'no', '', 'left', 6, '所属公海', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '客户创建时间', 'ld_account:createdtime:createdtime:Accounts_创建时间:DT', 'Accounts', 'no', 'no', 'no', '', 'left', 7, '创建时间', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '未联系天数', 'ld_account:nolinkdays:nolinkdays:Accounts_未联系天数:NN', 'Accounts', 'no', 'no', 'no', '', 'right', 8, '未联系天数', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '最新进展', 'ld_account:lastcontent:lastcontent:Accounts_最新进展:V', 'Accounts', 'no', 'no', 'no', '', 'left', 9, '最新进展', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '下次回访日期', 'ld_account:nextcontactdate:nextcontactdate:Accounts_下次回访日期:DT', 'Accounts', 'no', 'no', 'no', '', 'left', 10, '下次回访日期', 'l', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id102, '客户编号', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'no', 'no', '', 'left', 11, '客户编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id102, @tabid, 'Accounts', 0);

		INSERT INTO `ld_customtable` VALUES (null, '客户按来源分类统计', @kehu_id, '', 4, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'no','yes','no',0,3);
		select report_id into @report_id106 from ld_customtable where report_name='客户按来源分类统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id106, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '客户来源', 'ld_accountscf:leadsource:leadsource:Accounts_客户来源:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', 0, '客户来源', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#44e3bb;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '目前客户状态', 'ld_account:rating:rating:Accounts_客户状态:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 1, '客户状态', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 2, '销售负责人', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', 3, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '重要级别', 'ld_accountscf:important_level:important_level:Accounts_重要级别:V', 'Accounts', 'no', 'no', 'no', '', 'left', 4, '重要级别', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '客户创建时间', 'ld_account:createdtime:createdtime:Accounts_创建时间:DT', 'Accounts', 'no', 'no', 'no', '', 'left', 5, '创建时间', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '最新联系日期', 'ld_account:lastcontactdate:lastcontactdate:Accounts_最新联系日期:DT', 'Accounts', 'no', 'no', 'no', '', 'left', 6, '最新联系日期', 'l', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '最新进展', 'ld_account:lastcontent:lastcontent:Accounts_最新进展:V', 'Accounts', 'no', 'no', 'no', '', 'left', 7, '最新进展', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id106, '客户编号', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'no', 'no', '', 'left', 8, '客户编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id106,@tabid ,'Accounts', 0);

		INSERT INTO `ld_customtable` VALUES (null, '客户按公海分类统计', @kehu_id, '', 3, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id109 from ld_customtable where report_name='客户按公海分类统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id109, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '所属公海', 'ld_account:pool_id:pool_id:Accounts_所属公海:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', 0, '所属公海', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#37d4b2;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '公海状态', 'ld_account:publicaccount:publicaccount:Accounts_公海状态:C', 'Accounts', 'no', 'no', 'yes', '', 'left', 1, '公海状态', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', 2, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'yes', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 3, '销售负责人', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '客户状态', 'ld_account:rating:rating:Accounts_客户状态:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 4, '客户状态', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '公海分配日期', 'ld_account:lastdistributedate:lastdistributedate:Accounts_公海分配日期:D', 'Accounts', 'no', 'no', 'no', '', 'left', 5, '公海分配日期', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '领取日期', 'ld_account:allocatedate:allocatedate:Accounts_领取日期:D', 'Accounts', 'no', 'no', 'no', '', 'left', 6, '领取日期', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '公海目标', 'ld_account:completed:completed:Accounts_公海目标:V', 'Accounts', 'no', 'no', 'no', '', 'left', 7, '公海目标', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '最新进展', 'ld_account:lastcontent:lastcontent:Accounts_最新进展:V', 'Accounts', 'no', 'no', 'no', '', 'left', 8, '最新进展', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id109, '未联系天数', 'ld_account:nolinkdays:nolinkdays:Accounts_未联系天数:NN', 'Accounts', 'no', 'no', 'no', '', 'right', 9, '未联系天数', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_condition` VALUES (null,@report_id109, 'ld_account:publicaccount:publicaccount:Accounts_公海状态:C', 'n', '普通客户', 2, 'and');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id109,@tabid ,'Accounts', 0);


		INSERT INTO `ld_customtable` VALUES (null, '客户跟进动态统计', @kehu_id, '', 6, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id112 from ld_customtable where report_name='客户跟进动态统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id112, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '客户名称', 'ld_contactrecords:accountid:account_id:ContactRecords_客户名称:V', 'ContactRecords', 'yes', 'no', 'yes', 'count', 'left', 0, '客户名称', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '当前客户状态', 'ld_account:rating:rating:Accounts_客户状态:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 1, '客户状态', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '联系日期', 'ld_contactrecords:contactdate:contactdate:ContactRecords_联系日期:DT', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 2, '联系日期', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '负责人员', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_负责人:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 3, '负责人', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '联系方式', 'ld_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_联系方式:V', 'ContactRecords', 'no', 'no', 'yes', '', 'left', 4, '联系方式', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '联系人姓名', 'ld_contactrecords:contactid:contact_id:ContactRecords_联系人姓名:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 5, '联系人姓名', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '跟进内容', 'ld_contactrecords:content:content:ContactRecords_跟进记录:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 6, '跟进记录', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '本次跟进状态', 'ld_contactrecords:rating:rating:ContactRecords_客户状态:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 7, '客户状态', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '下次回访日期', 'ld_contactrecords:nextcontactdate:nextcontactdate:ContactRecords_下次回访日期:DT', 'ContactRecords', 'no', 'no', 'no', '', 'left', 8, '下次回访日期', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id112, '跟进记录编号', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 9, '跟进记录编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id112,@tabid, 'Accounts', 0);
		select tabid into @tabid from ld_tab where name='ContactRecords';
		select id into @parent_id from ld_customtable_module where report_id=@report_id112 and modulename='Accounts' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id112,@tabid, 'ContactRecords', @parent_id);


		INSERT INTO `ld_customtable` VALUES (null, '商机跟进动态统计', @shangji_id, '', 1, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id115 from ld_customtable where report_name='商机跟进动态统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id115, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '销售机会编号', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'yes', 'no', 'yes', '', 'left', 0, '销售机会编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '商机名称', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 1, '机会名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '商机当前阶段', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 2, '销售阶段', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '联系日期', 'ld_contactrecords:contactdate:contactdate:ContactRecords_联系日期:DT', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 3, '联系日期', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '客户名称', 'ld_potential:accountid:account_id:Potentials_客户名称:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 4, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '跟进负责人', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_负责人:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 5, '负责人', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '联系方式', 'ld_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_联系方式:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 6, '联系方式', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '跟进内容', 'ld_contactrecords:content:content:ContactRecords_跟进记录:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 7, '跟进记录', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '下次回访日期', 'ld_contactrecords:nextcontactdate:nextcontactdate:ContactRecords_下次回访日期:DT', 'ContactRecords', 'no', 'no', 'no', '', 'left', 8, '下次回访日期', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id115, '跟进记录编号', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 9, '跟进记录编号', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Potentials';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id115,@tabid, 'Potentials', 0);
		select tabid into @tabid from ld_tab where name='ContactRecords';
		select id into @parent_id from ld_customtable_module where report_id=@report_id115 and modulename='Potentials' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id115,@tabid, 'ContactRecords', @parent_id);


		INSERT INTO `ld_customtable` VALUES (null, '按人员统计商机状态', @shangji_id, '', 3, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id117 from ld_customtable where report_name='按人员统计商机状态' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id117, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '商机负责人', 'ld_potential:smownerid:assigned_user_id:Potentials_销售负责人:V', 'Potentials', 'yes', 'no', 'yes', '', 'left', 0, '销售负责人', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '商机阶段', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 1, '销售阶段', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '商机名称', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', 'Potentials', 'no', 'no', 'yes', 'count', 'left', 2, '机会名称', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '客户名称', 'ld_potential:accountid:account_id:Potentials_客户名称:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 3, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '商机预计金额', 'ld_potential:amount:amount:Potentials_预计合同金额:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', 4, '预计合同金额', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '预计成交日期', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'Potentials', 'no', 'no', 'yes', '', 'left', 5, '预计成交日期', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '成交可能性(%)', 'ld_potentialscf:possibility:possibility:Potentials_可能性(%):V', 'Potentials', 'no', 'no', 'yes', '', 'left', 6, '可能性(%)', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '销售机会编号', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'no', 'no', 'yes', 'count', 'left', 7, '销售机会编号', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '最新进展', 'ld_potential:lastcontent:lastcontent:Potentials_最新进展:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 8, '最新进展', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id117, '最新联系日期', 'ld_potential:lastcontactdate:lastcontactdate:Potentials_最新联系日期:DT', 'Potentials', 'no', 'no', 'yes', '', 'left', 9, '最新联系日期', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Potentials';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id117,@tabid, 'Potentials', 0);

		INSERT INTO `ld_customtable` VALUES (null, '商机状态总体统计', @shangji_id, '', 2, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id118 from ld_customtable where report_name='商机状态总体统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id118, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '商机阶段', 'ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V', 'Potentials', 'yes', 'no', 'yes', '', 'left', 0, '销售阶段', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#43bfb3;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '商机负责人', 'ld_potential:smownerid:assigned_user_id:Potentials_销售负责人:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 1, '销售负责人', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '销售机会编号', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'no', 'no', 'no', 'count', 'left', 2, '销售机会编号', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '商机名称', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', 'Potentials', 'no', 'no', 'yes', 'count', 'left', 3, '机会名称', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '客户名称', 'ld_potential:accountid:account_id:Potentials_客户名称:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 4, '客户名称', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '创建时间', 'ld_potential:createdtime:createdtime:Potentials_创建时间:DT', 'Potentials', 'no', 'no', 'no', '', 'left', 5, '创建时间', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '成交可能性(%)', 'ld_potentialscf:possibility:possibility:Potentials_可能性(%):V', 'Potentials', 'no', 'no', 'no', '', 'left', 6, '可能性(%)', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '预计成交日期', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'Potentials', 'no', 'no', 'no', '', 'left', 7, '预计成交日期', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '预计合同金额', 'ld_potential:amount:amount:Potentials_预计合同金额:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', 8, '预计合同金额', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id118, '最新进展', 'ld_potential:lastcontent:lastcontent:Potentials_最新进展:V', 'Potentials', 'no', 'no', 'no', '', 'left', 9, '最新进展', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Potentials';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id118,@tabid, 'Potentials', 0);

		INSERT INTO `ld_customtable` VALUES (null, '按客户统计商机转化金额', @shangji_id, '', 5, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id119 from ld_customtable where report_name='按客户统计商机转化金额' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id119, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '客户名称', 'ld_potential:accountid:account_id:Potentials_客户名称:V', 'Potentials', 'yes', 'no', 'yes', '', 'left', 0, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '销售机会编号', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 1, '销售机会编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '商机名称', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', 'Potentials', 'no', 'no', 'yes', '', 'left', 2, '机会名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '预计成交日期', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'Potentials', 'no', 'no', 'no', '', 'left', 3, '预计成交日期', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '实际签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', 4, '签约日期', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '预计订单金额', 'ld_potential:amount:amount:Potentials_预计合同金额:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', 5, '预计合同金额', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '实际订单金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 6, '合计', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '订单已收总额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 7, '已收总额', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id119, '销售订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 8, '合同编号', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Potentials';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id119,@tabid, 'Potentials', 0);
		select tabid into @tabid from ld_tab where name='SalesOrder';
		select id into @parent_id from ld_customtable_module where report_id=@report_id119 and modulename='Potentials' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id119,@tabid, 'SalesOrder', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '不同级别客户订单统计', @dingdan_id, '', 6, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id121 from ld_customtable where report_name='不同级别客户订单统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id121, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '重要级别', 'ld_accountscf:important_level:important_level:Accounts_重要级别:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', 0, '重要级别', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 1, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '客户类型', 'ld_account:account_type:accounttype:Accounts_客户类型:V', 'Accounts', 'no', 'no', 'no', '', 'left', 2, '客户类型', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', 'count', 'left', 3, '合同编号', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '订单金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 4, '合计', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#3bd9c1;font-size:14px;', 'color:#38c77b;font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '订单状态', 'ld_salesorder:sostatus:sostatus:SalesOrder_订单状态:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', 5, '订单状态', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '已收总额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 6, '已收总额', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '应收余额', 'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 7, '应收余额', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '已开票金额', 'ld_salesorder:have_invoicetotal:have_invoicetotal:SalesOrder_已开票金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 8, '已开票金额', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id121, '订单负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', 9, '销售负责人', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id121,@tabid, 'Accounts', 0);
		select tabid into @tabid from ld_tab where name='SalesOrder';
		select id into @parent_id from ld_customtable_module where report_id=@report_id121 and modulename='Accounts' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id121,@tabid, 'SalesOrder', @report_id119);


		INSERT INTO `ld_customtable` VALUES (null, '订单跟进动态统计', @dingdan_id, '', 7, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id124 from ld_customtable where report_name='订单跟进动态统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id124, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', 0, '合同编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 1, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '联系日期', 'ld_contactrecords:contactdate:contactdate:ContactRecords_联系日期:DT', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 2, '联系日期', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '联系方式', 'ld_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_联系方式:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 3, '联系方式', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '本次联系负责人', 'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_负责人:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 4, '负责人', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '跟进记录', 'ld_contactrecords:content:content:ContactRecords_跟进记录:V', 'ContactRecords', 'no', 'no', 'no', '', 'left', 5, '跟进记录', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '下次回访日期', 'ld_contactrecords:nextcontactdate:nextcontactdate:ContactRecords_下次回访日期:DT', 'ContactRecords', 'no', 'no', 'no', '', 'left', 6, '下次回访日期', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null,@report_id124, '跟进记录编号', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 'ContactRecords', 'no', 'no', 'no', 'count', 'left', 7, '跟进记录编号', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='SalesOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id124,@tabid, 'SalesOrder', 0);
		select tabid into @tabid from ld_tab where name='ContactRecords';
		select id into @parent_id from ld_customtable_module where report_id=@report_id124 and modulename='Accounts' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id124,@tabid, 'ContactRecords', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '订单退货退款统计', @dingdan_id, '', 5, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id126 from ld_customtable where report_name='订单退货退款统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id126, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '销售订单编号', 'ld_salesback:salesorderid:salesorder_id:SalesBack_合同订单:V', 'SalesBack', 'yes', 'no', 'yes', '', 'left', 0, '合同订单', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退货单编号', 'ld_salesback:salesback_no:salesback_no:SalesBack_销售退货单编号:V', 'SalesBack', 'no', 'no', 'yes', '', 'left', 1, '销售退货单编号', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '客户名称', 'ld_salesback:accountid:account_id:SalesBack_客户名称:V', 'SalesBack', 'no', 'no', 'yes', '', 'left', 2, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退货日期', 'ld_salesback:salesbackdate:salesbackdate:SalesBack_退货日期:D', 'SalesBack', 'no', 'no', 'no', '', 'left', 3, '退货日期', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退货原因', 'ld_salesback:description:description:SalesBack_退货原因:V', 'SalesBack', 'no', 'no', 'no', '', 'left', 4, '退货原因', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退入仓库', 'ld_salesback:wareid:wareid:SalesBack_退入仓库:V', 'SalesBack', 'no', 'no', 'no', '', 'left', 5, '退入仓库', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '状态', 'ld_salesback:salesbackstatus:salesbackstatus:SalesBack_状态:V', 'SalesBack', 'no', 'no', 'no', '', 'left', 6, '状态', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '应退款', 'ld_salesback:total:hdnGrandTotal:SalesBack_应退款:N', 'SalesBack', 'no', 'no', 'no', 'sum', 'right', 7, '应退款', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '已退款', 'ld_salesback:havebackamount:havebackamount:SalesBack_已退款:N', 'SalesBack', 'no', 'no', 'no', 'sum', 'right', 8, '已退款', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退款单编号', 'ld_cashback:cashback_no:cashback_no:CashBack_退款单编号:V', 'CashBack', 'no', 'no', 'no', '', 'left', 9, '退款单编号', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退款日期', 'ld_cashback:cashbackdate:cashbackdate:CashBack_退款日期:D', 'CashBack', 'no', 'no', 'no', '', 'left', 10, '退款日期', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '本次退款金额', 'ld_cashback:total:hdnGrandTotal:CashBack_合计:N', 'CashBack', 'no', 'no', 'no', 'sum', 'right', 11, '合计', 'o', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#cf8730;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '退款方式', 'ld_cashback:crpaymentmethod:crpaymentmethod:CashBack_付款方式:V', 'CashBack', 'no', 'no', 'no', '', 'left', 12, '付款方式', 'l', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id126, '银行账户', 'ld_cashback:bankaccountsetid:bankaccountsetid:CashBack_账户:V', 'CashBack', 'no', 'no', 'no', '', 'left', 13, '账户', 'n', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='SalesBack';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id126,@tabid, 'SalesBack', 0);
		select tabid into @tabid from ld_tab where name='CashBack';
		select id into @parent_id from ld_customtable_module where report_id=@report_id126 and modulename='Accounts' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id126,@tabid, 'CashBack', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '成交客户行业分析', @kehu_id, '', 5, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id144 from ld_customtable where report_name='成交客户行业分析' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id144, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '所属行业', 'ld_account:industry:industry:Accounts_所属行业:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', 0, '所属行业', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '客户编号', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', 1, '客户编号', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', 2, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '重要级别', 'ld_accountscf:important_level:important_level:Accounts_重要级别:V', 'Accounts', 'no', 'no', 'no', '', 'left', 3, '重要级别', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '客户类型', 'ld_account:account_type:accounttype:Accounts_客户类型:V', 'Accounts', 'no', 'no', 'no', '', 'left', 4, '客户类型', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'no', 'no', 'no', '', 'left', 5, '销售负责人', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '最新订单日期', 'ld_account:lastorderdate:lastorderdate:Accounts_最新订单日期:D', 'Accounts', 'no', 'no', 'no', '', 'left', 6, '最新订单日期', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '最新联系日期', 'ld_account:lastcontactdate:lastcontactdate:Accounts_最新联系日期:DT', 'Accounts', 'no', 'no', 'no', '', 'left', 7, '最新联系日期', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id144, '最新进展', 'ld_account:lastcontent:lastcontent:Accounts_最新进展:V', 'Accounts', 'no', 'no', 'no', '', 'left', 8, '最新进展', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_condition` VALUES (null,@report_id144, 'ld_account:rating:rating:Accounts_客户状态:V', 'c', '成交', 2, 'and');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id144, @tabid, 'Accounts', 0);

		INSERT INTO `ld_customtable` VALUES (null, '按人员统计商机转化订单金额', @shangji_id, '', 4, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id149 from ld_customtable where report_name='按人员统计商机转化订单金额' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id149, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '销售负责人', 'ld_potential:smownerid:assigned_user_id:Potentials_销售负责人:V', 'Potentials', 'yes', 'no', 'yes', '', 'left', 0, '销售负责人', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '商机名称', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', 'Potentials', 'no', 'no', 'no', 'count', 'left', 1, '机会名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '客户名称', 'ld_potential:accountid:account_id:Potentials_客户名称:V', 'Potentials', 'no', 'no', 'no', '', 'left', 2, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '预计成交日期', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'Potentials', 'no', 'no', 'no', '', 'left', 3, '预计成交日期', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '实际签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', 4, '签约日期', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '预计订单金额', 'ld_potential:amount:amount:Potentials_预计合同金额:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', 5, '预计合同金额', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '实际订单金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 6, '合计', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#1fbfa7;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '订单已收金额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 7, '已收总额', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '应收余额', 'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 8, '应收余额', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id149, '销售订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', 9, '合同编号', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Potentials';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id149, @tabid, 'Potentials', 0);
		select tabid into @tabid from ld_tab where name='SalesOrder';
		select id into @parent_id from ld_customtable_module where report_id=@report_id149 and modulename='Potentials' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id149, @tabid, 'SalesOrder',  @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '订单回款情况记录', @dingdan_id, '', 2, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id157 from ld_customtable where report_name='订单回款情况记录' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id157, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '销售订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', 0, '合同编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 1, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 2, '签约日期', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '订单金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 3, '合计', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '收款单编号', 'ld_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V', 'CashBill', 'no', 'no', 'yes', '', 'left', 4, '收款单编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '收款负责人', 'ld_cashbill:smownerid:assigned_user_id:CashBill_销售负责人:V', 'CashBill', 'no', 'no', 'yes', '', 'left', 5, '销售负责人', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '收款日期', 'ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D', 'CashBill', 'no', 'no', 'no', '', 'left', 6, '收款日期', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '本次收款金额', 'ld_cashbill:total:hdnGrandTotal:CashBill_实际收款金额:N', 'CashBill', 'no', 'no', 'no', 'sum', 'right', 7, '实际收款金额', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', 'color:#28bf6f;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '收款账户', 'ld_cashbill:bankaccountsetid:bankaccountsetid:CashBill_账户:V', 'CashBill', 'no', 'no', 'no', '', 'left', 8, '账户', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id157, '收款备注', 'ld_cashbill:description:description:CashBill_备注:V', 'CashBill', 'no', 'no', 'no', '', 'left', 9, '备注', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='SalesOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id157, @tabid, 'SalesOrder', 0);
		select tabid into @tabid from ld_tab where name='CashBill';
		select id into @parent_id from ld_customtable_module where report_id=@report_id157 and modulename='SalesOrder' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id157, @tabid, 'CashBill', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '销售订单开票记录', @dingdan_id, '', 3, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id162 from ld_customtable where report_name='销售订单开票记录' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id162, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '销售订单编号', 'ld_invoice:source_list:selectlistval:Invoice_选择源单:V', 'Invoice', 'yes', 'no', 'yes', '', 'left', 0, '选择源单', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '发票单据编号', 'ld_invoice:invoice_no:invoice_no:Invoice_发票编号:V', 'Invoice', 'no', 'no', 'yes', '', 'left', 1, '发票编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '客户名称', 'ld_invoice:accountid:account_id:Invoice_客户名称:V', 'Invoice', 'no', 'no', 'yes', '', 'left', 2, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '开票日期', 'ld_invoice:invoicedate:invoicedate:Invoice_开票日期:D', 'Invoice', 'no', 'no', 'yes', '', 'left', 3, '开票日期', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '本次开票金额', 'ld_invoice:total:hdnGrandTotal:Invoice_合计:N', 'Invoice', 'no', 'no', 'no', 'sum', 'right', 4, '合计', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#30acb3;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '票据类型', 'ld_invoicecf:invoicetype:invoicetype:Invoice_票据类型:V', 'Invoice', 'no', 'no', 'yes', '', 'left', 5, '票据类型', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '发票号码', 'ld_invoicecf:invoice_num:invoice_num:Invoice_发票号码:V', 'Invoice', 'no', 'no', 'yes', '', 'left', 6, '发票号码', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '纳税识别号', 'ld_invoicecf:cf_2026:cf_2026:Invoice_纳税识别号:V', 'Invoice', 'no', 'no', 'yes', '', 'left', 7, '纳税识别号', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id162, '物流单号', 'ld_invoice:express_no:express_no:Invoice_物流单号:V', 'Invoice', 'no', 'no', 'yes', '', 'left', 8, '物流单号', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_condition` VALUES (null, @report_id162, 'ld_invoicedetail:entitytype:entitytype:Invoice_源单类型:V', 'c', '订单', 2, 'and');
		select tabid into @tabid from ld_tab where name='Invoice';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id162, @tabid, 'Invoice', 0);


		INSERT INTO `ld_customtable` VALUES (null, '人员服务记录统计', @fuwu_id, '', 2, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id166 from ld_customtable where report_name='人员服务记录统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id166, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '服务人员', 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_服务人员:V', 'HelpDesk', 'yes', 'no', 'yes', '', 'left', 0, '服务人员', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '处理状态', 'ld_troubletickets:status:ticketstatus:HelpDesk_处理状态:V', 'HelpDesk', 'no', 'no', 'yes', '', 'left', 1, '处理状态', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '客户名称', 'ld_troubletickets:accountid:account_id:HelpDesk_客户名称:V', 'HelpDesk', 'no', 'no', 'yes', '', 'left', 2, '客户名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '实际处理时间', 'ld_troubletickets:realtime:realtime:HelpDesk_实际处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', 3, '实际处理时间', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '问题描述', 'ld_troubletickets:description:description:HelpDesk_问题描述:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', 4, '问题描述', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '希望处理时间', 'ld_troubletickets:hopetime:hopetime:HelpDesk_希望处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', 5, '希望处理时间', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '花费时间', 'ld_troubletickets:consumetime:consumetime:HelpDesk_花费时间:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', 6, '花费时间', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '服务单编号', 'ld_troubletickets:ticket_no:ticket_no:HelpDesk_服务单编号:V', 'HelpDesk', 'no', 'no', 'no', 'count', 'left', 7, '服务单编号', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '满意度', 'ld_servicereturn:satisfaction:satisfaction:ServiceReturn_满意度:V', 'ServiceReturn', 'no', 'no', 'no', '', 'left', 8, '满意度', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#d64f78;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '及时率', 'ld_servicereturn:timelyrate:timelyrate:ServiceReturn_及时率:V', 'ServiceReturn', 'no', 'no', 'no', '', 'left', 9, '及时率', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id166, '解决率', 'ld_servicereturn:resolutionrate:resolutionrate:ServiceReturn_解决率:V', 'ServiceReturn', 'no', 'no', 'no', '', 'left', 10, '解决率', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='HelpDesk';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id166, @tabid, 'HelpDesk', 0);
		select tabid into @tabid from ld_tab where name='ServiceReturn';
		select id into @parent_id from ld_customtable_module where report_id=@report_id166 and modulename='HelpDesk' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id166, @tabid, 'ServiceReturn', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '工单状态总体统计', @fuwu_id, '', 4, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'no','yes','no',0,3);
		select report_id into @report_id167 from ld_customtable where report_name='工单状态总体统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id167, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '工单状态', 'ld_worksheet:worksheet_status:worksheet_status:WorkSheet_工单状态:V', 'WorkSheet', 'yes', 'no', 'yes', '', 'left', 0, '工单状态', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#21cfb5;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '服务人员', 'ld_worksheet:smownerid:assigned_user_id:WorkSheet_服务人员:V', 'WorkSheet', 'no', 'no', 'yes', '', 'left', 1, '服务人员', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '工单编号', 'ld_worksheet:worksheet_no:worksheet_no:WorkSheet_工单编号:V', 'WorkSheet', 'no', 'no', 'no', 'distinct_count', 'left', 2, '工单编号', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '客户名称', 'ld_worksheet:accountid:account_id:WorkSheet_客户名称:V', 'WorkSheet', 'no', 'no', 'no', '', 'left', 3, '客户名称', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '工单创建时间', 'ld_worksheet:createdtime:createdtime:WorkSheet_创建时间:DT', 'WorkSheet', 'no', 'no', 'no', '', 'left', 4, '创建时间', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '工单类型', 'ld_worksheet:worksheet_type:worksheet_type:WorkSheet_工单类型:V', 'WorkSheet', 'no', 'no', 'no', '', 'left', 5, '工单类型', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '问题描述', 'ld_worksheet:description:description:WorkSheet_问题描述:V', 'WorkSheet', 'no', 'no', 'no', '', 'left', 6, '问题描述', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '解决方案', 'ld_worksheet:solution:solution:WorkSheet_解决方案:V', 'WorkSheet', 'no', 'no', 'no', '', 'left', 7, '解决方案', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '工单金额', 'ld_worksheet:total:hdnGrandTotal:WorkSheet_合计:N', 'WorkSheet', 'no', 'no', 'no', '', 'right', 8, '合计', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '催单时间', 'ld_worksheet:urgedtime:urgedtime:WorkSheet_催单时间:DT', 'WorkSheet', 'no', 'no', 'no', '', 'left', 9, '催单时间', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id167, '结单时间', 'ld_worksheet:endedtime:endedtime:WorkSheet_结单时间:DT', 'WorkSheet', 'no', 'no', 'no', '', 'left', 10, '结单时间', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='WorkSheet';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id167, @tabid, 'WorkSheet', 0);


		INSERT INTO `ld_customtable` VALUES (null, '按员工统计服务合同', @fuwu_id, '', 1, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id168 from ld_customtable where report_name='按员工统计服务合同' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id168, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '负责人', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_负责人:V', 'ServiceContracts', 'yes', 'no', 'yes', '', 'left', 0, '负责人', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '客户名称', 'ld_servicecontracts:accountid:account_id:ServiceContracts_客户名称:V', 'ServiceContracts', 'no', 'no', 'yes', '', 'left', 1, '客户名称', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '服务合同编号', 'ld_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V', 'ServiceContracts', 'no', 'no', 'no', 'distinct_count', 'left', 2, '服务合同编号', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '签约日期', 'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', 3, '签约日期', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '合同状态', 'ld_servicecontracts:contract_status:contract_status:ServiceContracts_合同状态:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', 4, '合同状态', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '服务合同金额', 'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N', 'ServiceContracts', 'no', 'no', 'no', 'sum', 'right', 5, '合计', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#40d9db;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '服务开始日期', 'ld_servicecontracts:start_date:start_date:ServiceContracts_服务开始日期:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', 6, '服务开始日期', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '服务到期日', 'ld_servicecontracts:end_date:end_date:ServiceContracts_服务到期日:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', 7, '服务到期日', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '已收总额', 'ld_servicecontracts:received_amount:received_amount:ServiceContracts_已收总额:N', 'ServiceContracts', 'no', 'no', 'no', 'sum', 'right', 8, '已收总额', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id168, '已服务次数', 'ld_servicecontracts:service_units:service_units:ServiceContracts_已服务次数:NN', 'ServiceContracts', 'no', 'no', 'no', 'sum', 'right', 9, '已服务次数', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='ServiceContracts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id168, @tabid, 'ServiceContracts', 0);

		INSERT INTO `ld_customtable` VALUES (null, '采购入库记录', @caigou_id, '', 4, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id169 from ld_customtable where report_name='采购入库记录' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id169, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '采购订单编号', 'ld_stockdetail:entitytypeid:entitytypeid:Stock_源单:V', 'Stock', 'yes', 'no', 'yes', '', 'left', 0, '源单', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '入库日期', 'ld_stock:createdate:createdate:Stock_入库日期:D', 'Stock', 'no', 'no', 'yes', '', 'left', 1, '入库日期', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '入库产品', 'ld_products:productname:productname:Stock_产品名称:V', 'Stock', 'no', 'no', 'yes', '', 'left', 2, '产品名称', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '本次入库数量', 'ld_stockdetail:quantity:quantity:Stock_数量:N', 'Stock', 'no', 'no', 'no', 'sum', 'right', 3, '数量', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '入库金额', 'ld_stockdetail:tax_amount:tax_amount:Stock_价税合计:N', 'Stock', 'no', 'no', 'no', 'sum', 'right', 4, '价税合计', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '入库单编号', 'ld_stock:ware_stock_no:ware_stock_no:Stock_入库单编号:V', 'Stock', 'no', 'no', 'yes', '', 'left', 5, '入库单编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id169, '源单类型', 'ld_stockdetail:entitytype:entitytype:Stock_源单类型:V', 'Stock', 'no', 'no', 'yes', '', 'left', 6, '源单类型', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Stock';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id169, @tabid, 'Stock', 0);

		INSERT INTO `ld_customtable` VALUES (null, '采购发票记录', @caigou_id, '', 3, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id170 from ld_customtable where report_name='采购发票记录' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id170, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '采购订单编号', 'ld_purchaseinvoicedetail:entitytypeid:entitytypeid:PurchaseInvoice_源单:V', 'PurchaseInvoice', 'yes', 'no', 'yes', '', 'left', 0, '源单', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '开票日期', 'ld_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_开票日期:D', 'PurchaseInvoice', 'no', 'no', 'yes', '', 'left', 1, '开票日期', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '发票编号', 'ld_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_发票编号:V', 'PurchaseInvoice', 'no', 'no', 'yes', '', 'left', 2, '发票编号', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '本次开票金额', 'ld_purchaseinvoicedetail:tax_amount:tax_amount:PurchaseInvoice_价税合计:N', 'PurchaseInvoice', 'no', 'no', 'no', 'sum', 'right', 3, '价税合计', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '票据类型', 'ld_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_票据类型:V', 'PurchaseInvoice', 'no', 'no', 'yes', '', 'left', 4, '票据类型', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '发票号码', 'ld_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_发票号码:V', 'PurchaseInvoice', 'no', 'no', 'no', '', 'left', 5, '发票号码', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '运费和物流附加费', 'ld_purchaseinvoice:s_h_amount:hdnS_H_Amount:PurchaseInvoice_运费和物流附加费:N', 'PurchaseInvoice', 'no', 'no', 'no', 'sum', 'right', 6, '运费和物流附加费', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id170, '发票源单类型', 'ld_purchaseinvoicedetail:entitytype:entitytype:PurchaseInvoice_源单类型:V', 'PurchaseInvoice', 'no', 'no', 'yes', '', 'left', 7, '源单类型', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_condition` VALUES (null, @report_id170, 'ld_purchaseinvoicedetail:entitytype:entitytype:PurchaseInvoice_源单类型:V', 'c', '采购', 2, 'and');
		select tabid into @tabid from ld_tab where name='PurchaseInvoice';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id170, @tabid, 'PurchaseInvoice', 0);

		INSERT INTO `ld_customtable` VALUES (null, '采购付款记录', @caigou_id, '', 1, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id171 from ld_customtable where report_name='采购付款记录' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id171, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '采购订单编号', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'PurchaseOrder', 'yes', 'no', 'yes', '', 'left', 0, '采购订单编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '供应商名称', 'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_供应商名称:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 1, '供应商名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '采购负责人', 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 2, '采购负责人', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '采购金额合计', 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_合计:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', 3, '合计', 'm', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '已付总额', 'ld_purchaseorder:pay_amount:pay_amount:PurchaseOrder_已付总额:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', 4, '已付总额', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '当前应付余额', 'ld_purchaseorder:pay_balance:pay_balance:PurchaseOrder_应付余额:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', 5, '应付余额', 'l', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#3ec9ab;font-size:14px;', 'color:#ba2f58;font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '采购入库状态', 'ld_purchaseorder:stockpresence:stockpresence:PurchaseOrder_入库状态:V', 'PurchaseOrder', 'no', 'no', 'yes', '', 'left', 6, '入库状态', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '付款单编号', 'ld_sendcashbill:sendcashbill_no:sendcashbill_no:SendCashBill_付款单编号:V', 'SendCashBill', 'no', 'no', 'yes', '', 'left', 7, '付款单编号', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '付款日期', 'ld_sendcashbill:cashbilldate:cashbilldate:SendCashBill_付款日期:D', 'SendCashBill', 'no', 'no', 'yes', '', 'left', 8, '付款日期', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '本次付款金额', 'ld_sendcashbill:total:hdnGrandTotal:SendCashBill_合计:N', 'SendCashBill', 'no', 'no', 'no', 'sum', 'right', 9, '合计', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '付款方式', 'ld_sendcashbill:crpaymentmethod:crpaymentmethod:SendCashBill_付款方式:V', 'SendCashBill', 'no', 'no', 'yes', '', 'left', 10, '付款方式', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '付款账户', 'ld_sendcashbill:bankaccountsetid:bankaccountsetid:SendCashBill_账户:V', 'SendCashBill', 'no', 'no', 'yes', '', 'left', 11, '账户', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id171, '付款负责人', 'ld_sendcashbill:smownerid:assigned_user_id:SendCashBill_采购负责人:V', 'SendCashBill', 'no', 'no', 'yes', '', 'left', 12, '采购负责人', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='PurchaseOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id171, @tabid, 'PurchaseOrder', 0);
		select tabid into @tabid from ld_tab where name='SendCashBill';
		select id into @parent_id from ld_customtable_module where report_id=@report_id171 and modulename='PurchaseOrder' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id171, @tabid, 'SendCashBill', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '采购退货退款', @caigou_id, '', 2, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id172 from ld_customtable where report_name='采购退货退款' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id172, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '采购订单编号', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', 0, '采购订单编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '签约日期', 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', 1, '签约日期', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '退货时间', 'ld_purchaseback:purchasebackdate:purchasebackdate:PurchaseBack_退货时间:D', 'PurchaseBack', 'no', 'no', 'no', '', 'left', 2, '退货时间', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '采购退货单编号', 'ld_purchaseback:purchaseback_no:purchaseback_no:PurchaseBack_采购退货单编号:V', 'PurchaseBack', 'no', 'no', 'no', '', 'left', 3, '采购退货单编号', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '状态', 'ld_purchaseback:purchasebackstatus:purchasebackstatus:PurchaseBack_状态:V', 'PurchaseBack', 'no', 'no', 'no', '', 'left', 4, '状态', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '已退款', 'ld_purchaseback:havebackamount:havebackamount:PurchaseBack_已退款:N', 'PurchaseBack', 'no', 'no', 'no', 'sum', 'right', 5, '已退款', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '应退款', 'ld_purchaseback:total:hdnGrandTotal:PurchaseBack_应退款:N', 'PurchaseBack', 'no', 'no', 'no', 'sum', 'right', 6, '应退款', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id172, '退货原因', 'ld_purchaseback:description:description:PurchaseBack_退货原因:V', 'PurchaseBack', 'no', 'no', 'no', '', 'left', 7, '退货原因', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='PurchaseOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id172, @tabid, 'PurchaseOrder', 0);
		select tabid into @tabid from ld_tab where name='PurchaseBack';
		select id into @parent_id from ld_customtable_module where report_id=@report_id172 and modulename='PurchaseOrder' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id172, @tabid, 'PurchaseBack',  @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '按公海汇总线索', @xiansuo_id, '', 2, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id173 from ld_customtable where report_name='按公海汇总线索' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id173, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '所属公海', 'ld_leads:pool_id:pool_id:Leads_所属公海:V', 'Leads', 'yes', 'no', 'yes', '', 'left', 0, '所属公海', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '公海状态', 'ld_leads:publicaccount:publicaccount:Leads_公海状态:V', 'Leads', 'no', 'no', 'yes', '', 'left', 1, '公海状态', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '公司名称', 'ld_leads:accountname:accountname:Leads_客户名称:V', 'Leads', 'no', 'no', 'yes', 'count', 'left', 2, '客户名称', 'e', '', 0, '', '', 'yes', NULL, NULL, 'yes', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '联系人姓名', 'ld_leads:contactname:contactname:Leads_联系人姓名:V', 'Leads', 'no', 'no', 'no', '', 'left', 3, '联系人姓名', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '线索来源', 'ld_leads:leadsource:leadsource:Leads_商机来源:V', 'Leads', 'no', 'no', 'no', '', 'left', 4, '商机来源', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '最新进展', 'ld_leads:lastcontent:lastcontent:Leads_最新进展:V', 'Leads', 'no', 'no', 'no', '', 'left', 5, '最新进展', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '线索创建时间', 'ld_leads:createdtime:createdtime:Leads_创建时间:DT', 'Leads', 'no', 'no', 'no', '', 'left', 6, '创建时间', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '公海分配日期', 'ld_leads:lastdistributedate:lastdistributedate:Leads_公海分配日期:D', 'Leads', 'no', 'no', 'no', '', 'left', 7, '公海分配日期', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '线索领取日期', 'ld_leads:allocatedate:allocatedate:Leads_领取日期:D', 'Leads', 'no', 'no', 'no', '', 'left', 8, '领取日期', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '公海目标完成情况', 'ld_leads:completed:completed:Leads_公海目标:V', 'Leads', 'no', 'no', 'no', '', 'left', 9, '公海目标', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '未联系天数', 'ld_leads:nolinkdays:nolinkdays:Leads_未联系天数:NN', 'Leads', 'no', 'no', 'no', '', 'right', 10, '未联系天数', 'k', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id173, '销售线索编号', 'ld_leads:leads_no:leads_no:Leads_销售线索编号:V', 'Leads', 'no', 'no', 'no', '', 'left', 11, '销售线索编号', 'l', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_condition` VALUES (null, @report_id173, 'ld_leads:publicaccount:publicaccount:Leads_公海状态:V', 'n', '普通客户', 2, 'and');
		select tabid into @tabid from ld_tab where name='Leads';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id173, @tabid, 'Leads', 0);

		INSERT INTO `ld_customtable` VALUES (null, '客户销售合同统计', @kehu_id, '', 1, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id174 from ld_customtable where report_name='客户销售合同统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id174, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', 0, '客户名称', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '客户类型', 'ld_account:account_type:accounttype:Accounts_客户类型:V', 'Accounts', 'no', 'no', 'yes', '', 'left', 1, '客户类型', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '销售订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 2, '合同编号', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 3, '签约日期', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '订单负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 4, '销售负责人', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '订单金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 5, '合计', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '已收总额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 6, '已收总额', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#3fd4a7;font-size:14px;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '应收余额', 'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 7, '应收余额', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#c46e2b;font-size:14px;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '已开票金额', 'ld_salesorder:have_invoicetotal:have_invoicetotal:SalesOrder_已开票金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 8, '已开票金额', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id174, '未开票金额', 'ld_salesorder:nothave_invoicetotal:nothave_invoicetotal:SalesOrder_未开票金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 9, '未开票金额', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='Accounts';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id174, @tabid, 'Accounts', 0);
		select tabid into @tabid from ld_tab where name='SalesOrder';
		select id into @parent_id from ld_customtable_module where report_id=@report_id174 and modulename='Accounts' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id174, @tabid, 'SalesOrder',  @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '销售订单出库情况', @dingdan_id, '', 4, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id178 from ld_customtable where report_name='销售订单出库情况' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id178, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '销售订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', 0, '合同编号', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '交付日期', 'ld_salesorder:duedate:duedate:SalesOrder_交付日期:D', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 1, '交付日期', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '订单金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 2, '合计', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '出库日期', 'ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D', 'OutboundOrder', 'no', 'no', 'yes', '', 'left', 3, '出库日期', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '出库状态', 'ld_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 4, '出库状态', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '出库单编号', 'ld_outboundorder:out_no:out_no:OutboundOrder_出库单编号:V', 'OutboundOrder', 'no', 'no', 'yes', '', 'left', 5, '出库单编号', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id178, '出库负责人', 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_负责人:V', 'OutboundOrder', 'no', 'no', 'yes', '', 'left', 6, '负责人', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='SalesOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id178, @tabid, 'SalesOrder', 0);
		select tabid into @tabid from ld_tab where name='OutboundOrder';
		select id into @parent_id from ld_customtable_module where report_id=@report_id178 and modulename='SalesOrder' limit 1;
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id178, @tabid, 'OutboundOrder', @parent_id);

		INSERT INTO `ld_customtable` VALUES (null, '员工订单金额统计', @dingdan_id, '', 1, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id179 from ld_customtable where report_name='员工订单金额统计' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id179, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', 0, '销售负责人', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'yes', '', 'left', 1, '客户名称', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '销售订单编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', 2, '合同编号', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', 3, '签约日期', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '订单总金额', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 4, '合计', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'background-color:#3fc7d4;font-size:14px;font-weight:bolder;', 'font-size:13px;');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '订单审批状态', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', 5, '审批状态', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '已收总额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 6, '已收总额', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '应收余额', 'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 7, '应收余额', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id179, '已开票金额', 'ld_salesorder:have_invoicetotal:have_invoicetotal:SalesOrder_已开票金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', 8, '已开票金额', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='SalesOrder';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id179, @tabid, 'SalesOrder', 0);


		INSERT INTO `ld_customtable` VALUES (null, '客户服务单汇总', @fuwu_id, '', 3, 'no', 'bottom', 'no', 'yes', NOW(), NOW(), 0, 1, 1, 0, 'selectfield', NULL, 'yes','yes','no',0,3);
		select report_id into @report_id181 from ld_customtable where report_name='客户服务单汇总' and deleted=0 and istemplate='yes' limit 1;
		INSERT INTO `ld_customtable2user` VALUES (@report_id181, -1);
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '客户名称', 'ld_troubletickets:accountid:account_id:HelpDesk_客户名称:V', 'HelpDesk', 'no', 'no', 'yes', '', 'left', 0, '客户名称', 'a', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '处理状态', 'ld_troubletickets:status:ticketstatus:HelpDesk_处理状态:V', 'HelpDesk', 'no', 'no', 'yes', '', 'left', 1, '处理状态', 'b', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '服务人员', 'ld_troubletickets:smownerid:assigned_user_id:HelpDesk_服务人员:V', 'HelpDesk', 'no', 'no', 'yes', '', 'left', 2, '服务人员', 'c', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '收费金额', 'ld_troubletickets:fees:fees:HelpDesk_收费金额:N', 'HelpDesk', 'no', 'no', 'no', 'sum', 'right', 3, '收费金额', 'd', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '产品名称', 'ld_troubletickets:product_id:product_id:HelpDesk_产品名称:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', 4, '产品名称', 'e', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '故障类别', 'ld_troubletickets:category:ticketcategories:HelpDesk_故障类别:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', 5, '故障类别', 'f', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '希望处理时间', 'ld_troubletickets:hopetime:hopetime:HelpDesk_希望处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', 6, '希望处理时间', 'g', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '实际处理时间', 'ld_troubletickets:realtime:realtime:HelpDesk_实际处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', 7, '实际处理时间', 'h', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '问题描述', 'ld_troubletickets:description:description:HelpDesk_问题描述:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', 8, '问题描述', 'i', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		INSERT INTO `ld_customtable_columns` VALUES (null, @report_id181, '解决方法', 'ld_troubletickets:solution:solution:HelpDesk_解决方法:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', 9, '解决方法', 'j', '', 0, '', '', 'yes', NULL, NULL, 'no', 'font-weight:bolder;', '');
		select tabid into @tabid from ld_tab where name='HelpDesk';
		INSERT INTO `ld_customtable_module` VALUES (null,@report_id181, @tabid, 'HelpDesk', 0);
	END IF;
end ||
delimiter;

CALL reset_reportinfo_20221010();
DROP PROCEDURE IF EXISTS `reset_reportinfo_20221010`;
delimiter;

CALL AddColumn('ld_field','allowdelete','varchar','20',null);
delimiter;

update ld_field set allowdelete='yes' where fieldname like 'cf_%';
update ld_field set allowdelete='no' where fieldname not like 'cf_%';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Pleaseselectatleaposition','请至少选择一个职位级别！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Pleaseselectatleaposition' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Pleaseselectatleaposition',"Please select at least one Position level!",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Pleaseselectatleaposition' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','msgRemindDisplaySet','消息提醒显示设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='msgRemindDisplaySet' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','msgRemindDisplaySet',"Message reminder display settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='msgRemindDisplaySet' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='保存为查询分类' 
where languagetype='zh' and labelbol='SAVEASDATACLASS' and labeltype='fixedstr';
update ld_desk set fieldlabel='Saved as filters' 
where languagetype='en' and labelbol='SAVEASDATACLASS' and labeltype='fixedstr';
delimiter;

CALL AddColumn ( "ld_business_backfillfield", 'sequence', 'tinyint', '4', '0' );
delimiter;

SET @i=0;
set @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
UPDATE ld_business_backfillfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

SET @i=0;
set @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
UPDATE ld_business_backfillfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

SET @i=0;
set @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
UPDATE ld_business_backfillfield SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;
delimiter;

update ld_business_backfillfield set sequence=0 where tianyanchaname='name';

set @sequence=(SELECT sequence FROM ld_business_backfillfield WHERE `tianyanchaname`='regCapital' LIMIT 1);
update ld_business_backfillfield set sequence=@sequence where tianyanchaname='actualCapital';
delimiter;

UPDATE ld_desk SET fieldlabel='导入明细' WHERE labelbol='IMPORTENTRY' AND languagetype='zh' AND fieldlabel='导入单据分录';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPLAINTREE','说明：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPLAINTREE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPLAINTREE','Explain:','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPLAINTREE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DetailedDescriptionTree1','1、树结构“分组字段”可在页面设置中新增“下拉框”字段类型添加；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DetailedDescriptionTree1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DetailedDescriptionTree1','1. The tree structure "grouping field" can be added with the "drop-down box" field type in the page setting;','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DetailedDescriptionTree1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DetailedDescriptionTree2','2、级联字段定制，可设置“分组字段的树节点，下级“级联字段”；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DetailedDescriptionTree2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DetailedDescriptionTree2','2. Cascade field Customization: you can set the tree node of "group field" and the lower level "cascade field";','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DetailedDescriptionTree2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DetailedDescriptionTree3','3、“分组字段”选项值为“一级分类”，“分组字段”的下级“级联字段”树节点选项值为“子分类”；','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DetailedDescriptionTree3' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DetailedDescriptionTree3','3、“3. The option value of "group field" is "primary classification", and the option value of the lower level "cascade field" tree node of "group field" is "sub classification";','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DetailedDescriptionTree3' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TREEIMGEXPLAIN1','单级树节点分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TREEIMGEXPLAIN1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TREEIMGEXPLAIN1','Single level tree node classification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TREEIMGEXPLAIN1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TREEIMGEXPLAIN2','多级树节点分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TREEIMGEXPLAIN2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TREEIMGEXPLAIN2','Multilevel tree node classification','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TREEIMGEXPLAIN2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnableTreeStructure','（启用后，根据“分组字段”和“级联字段”树节点选项值在左侧显示）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EnableTreeStructure' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnableTreeStructure','(when enabled, it is displayed on the left according to the option values of "group field" and "cascade field" tree nodes)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EnableTreeStructure' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','msgsend_typeld','使用灵当CRM小程序和微信公众号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='msgsend_typeld' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','msgsend_typeld',"Use Lingdang CRM applet and WeChat official account",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='msgsend_typeld' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','msgsend_typeoem','使用OEM小程序和微信公众号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='msgsend_typeoem' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','msgsend_typeoem',"Use OEM applet and WeChat official account",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='msgsend_typeoem' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','msgsend_type','消息通知发送方式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='msgsend_type' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','msgsend_type',"Message notification sending method",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='msgsend_type' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectTemplate','模板类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectTemplate' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectTemplate',"Select Template",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectTemplate' and labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_invoice','triggercount','INT','19',0);
CALl AddColumn('ld_customform11','triggercount','INT','19',0);
CALl AddColumn('ld_customform13','triggercount','INT','19',0);
CALl AddColumn('ld_customform17','triggercount','INT','19',0);
delimiter;

SET @modulename='ServiceCharge';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='nolinkdays'; 
SET @fieldname='nolinkdays'; 
SET @zh='未联系天数'; 
SET @en='Nolinked Days'; 
SET @uitype=7; 
SET @typeofdata='NN~O~13,0';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='number';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @presence=1;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'INT','11',NULL);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
delimiter;
-- 2022-10-17

CALl AddColumn('ld_customform12','triggercount','INT','19',0);
CALl AddColumn('ld_expense','triggercount','INT','19',0);
CALl AddColumn('ld_outboundorder','triggercount','INT','19',0);
CALl AddColumn('ld_stock','triggercount','INT','19',0);
CALl AddColumn('ld_cashbill','triggercount','INT','19',0);
delimiter;
-- 2022-10-19

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

UPDATE ld_version SET old_version='V8.4.7.7',current_version='V8.4.7.7',remark='V8.4.7.7-20221019',wx_version='V8.4.7.7';
delimiter;