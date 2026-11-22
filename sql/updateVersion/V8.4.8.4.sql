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

update ld_linkmodulecustom
set url=REPLACE(url,'module=OftenUseReport','module=ReportAnalysis');
delimiter;
update ld_linkmodulecustom
set url=REPLACE(url,'action=OftenUseReportAjax','action=ReportAnalysisAjax');
delimiter;

drop PROCEDURE  if EXISTS ldcrm_add_mappingfield;
delimiter ||
create PROCEDURE ldcrm_add_mappingfield
(
	var_lead_id int(19),
	var_account_id int(19),
	var_uitype int(11)
)
BEGIN
	SET @lead_file_fieldid = (select fieldid from ld_field where tabid = var_lead_id and uitype = var_uitype AND presence in (0,2) ORDER BY fieldid asc limit 1);
	IF @lead_file_fieldid>0 THEN
		SET @lead_file_column = (select columnname from ld_field where fieldid = @lead_file_fieldid);
		SET @account_file_column = (select columnname from ld_field where tabid = var_account_id and uitype = var_uitype AND presence in (0,2) ORDER BY fieldid asc limit 1);
		IF @account_file_column != '' THEN
			insert into ld_module_mappingfields(tabid,fieldid,columnname,mapping_module,mapping_columnname,is_disabled)
			SELECT var_lead_id,@lead_file_fieldid,@lead_file_column,'Accounts',@account_file_column,0 from DUAL
			where NOT EXISTS(SELECT 1 from ld_module_mappingfields where columnname = @lead_file_column);
		END if;
	END if;
end ||
delimiter;

set @lead_id = (SELECT tabid from ld_tab where `name` = 'Leads');
set @account_id = (SELECT tabid from ld_tab where `name` = 'Accounts');
call ldcrm_add_mappingfield(@lead_id,@account_id,1109);
call ldcrm_add_mappingfield(@lead_id,@account_id,69);
drop PROCEDURE if EXISTS ldcrm_add_mappingfield;
delimiter;

SET @tmp_str = 'The administrator has set that it is not allowed to sign in beyond the error range. Your sign in error has exceeded {metre} meters. Please sign in within the specified range!';
UPDATE ld_desk SET fieldlabel = @tmp_str where labelbol = 'Theadministratorhassetthatitisnotallowedtosign' AND languagetype = 'en';
delimiter;

SET @labelbol = 'VISITADDRESSISINCOMPLETE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您的拜访地址不完整，可能会影响签到距离计算，请完善地址信息！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Your visit address is incomplete, which may affect the calculation of sign in distance. Please complete the address information','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'COMPLETEADDRESSINFORMATION';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'管理员已设置超出误差范围不允许签到，请完善您的拜访对象地址信息(%s)','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The administrator has set that it is not allowed to sign in beyond the error range. Please complete your visitor address information(%s)','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHMESSAGETOCLOUDHUB';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推送的通知和消息到个人的云之家中','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push notifications and messages to personal Cloud Hub','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'PUSHMESSAGETODING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'推送的通知和消息到个人的钉钉中','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Push notifications and messages to personal DingTalk','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'WECHATRECEVIEREMINDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'企业微信是否接收CRM消息通知','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether enterprise WeChat receives CRM message notification','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DINGTALKRECEVIEREMINDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'钉钉是否接收CRM消息通知','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether DingTalk receives CRM message notification','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CLOUDHUBRECEVIEREMINDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'云之家是否接收CRM消息通知','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether Cloud Hub receives CRM message notification','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_report_analysis_folder_log` (
    `browse_id` int(19) AUTO_INCREMENT COMMENT '最近浏览报表记录自增id，主键',
    `reportid` int (19) NOT NULL,
    `module` VARCHAR(100) default '' COMMENT '模块',
    `userid` int (19) NOT NULL COMMENT '浏览人id',
    `view_time` datetime COMMENT '浏览时间',
    `visible` varchar(10) default 'yes' COMMENT '是否显示  显示:yes  隐藏：no',
    PRIMARY KEY  (`browse_id` )
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELDISPLAY','取消显示','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANCELDISPLAY' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELDISPLAY',"Cancel Display",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANCELDISPLAY' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECENTBROWSING','最近浏览','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RECENTBROWSING' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECENTBROWSING',"Recent Browsing",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RECENTBROWSING' and labeltype='jspop');
delimiter;

call AddColumn('ld_producttoolfield','mobiledetailshow','char',10,null);
delimiter;
call AddColumn('ld_tabdetailfield','mobiledetailshow','char',10,null);
delimiter;

UPDATE ld_producttoolfield LEFT JOIN ld_tab on ld_producttoolfield.tabid = ld_tab.tabid
SET mobiledetailshow = 'yes'
where IFNULL(mobiledetailshow,'') = ''
AND (case 
	when  ld_tab.`name` = 'Checks' AND FIND_IN_SET(columnname,'productname,product_no,paperquantity,firmoffer') THEN 'yes' 
	when  ld_tab.`name` <> 'Checks' AND FIND_IN_SET(columnname,'productname,quantity,taxprice,discount_percent,tax_amount') THEN 'yes' 
	ELSE 'no'
END) = 'yes';
delimiter;

update ld_tabdetailfield LEFT JOIN ld_tab on ld_tabdetailfield.tabid = ld_tab.tabid
set mobiledetailshow = 'yes'
where IFNULL(mobiledetailshow,'') = ''
AND (case 
	when  ld_tab.`name` = 'TimeSheet' AND FIND_IN_SET(columnname,'workdate,indirectcharge,costtime') THEN 'yes' 
	when  ld_tab.`name` = 'AddJobBill' AND FIND_IN_SET(columnname,'starttime,endtime,costtime') THEN 'yes' 
	when  ld_tab.`name` = 'MinusJobBill' AND FIND_IN_SET(columnname,'starttime,endtime,costtime') THEN 'yes' 
	when  ld_tab.`name` = 'BusinessApply' AND FIND_IN_SET(columnname,'source,destination,total') THEN 'yes' 
	when  ld_tab.`name` = 'Commission' AND FIND_IN_SET(columnname,'entitytypeid,source_total,rate,amount') THEN 'yes' 
	when  ld_tab.`name` = 'Expense' AND FIND_IN_SET(columnname,'expenseuse,expensetype,entitytypeid,rmb_total') THEN 'yes' 
	when  FIND_IN_SET(ld_tab.`name`,'TimeSheet,AddJobBill,MinusJobBill,BusinessApply,Commission,Expense') < 1
		AND FIND_IN_SET(columnname,'entitytype,entitytypeid,source_total,amount') THEN 'yes' 
	ELSE 'no'
END) = 'yes';
delimiter;

SET @labelbol = 'MOBILEDETAILSHOW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'移动端明细列表显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Details list display of mobile terminal','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DETAILSISCOLLAPSEDISPLAY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据分录明细是否折叠显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether details is Collapse Display','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FIELDDISPLAYINMOBILEDETAIL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'若开启此参数，则该字段将在移动端分录表单详情界面的明细页签列表显示','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'If this parameter is enabled, this field will be displayed in the details tab list of the mobile end entry form details interface','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_customreport_info','smcreatorid','int','19',1);
CALL AddColumn('ld_customreport_info','createdtime','datetime','',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ChannelLabelSaveError','请先前往后台设置->接口设置->企业微信渠道码设置中，查看接收事件服务器设置参数是否正确！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ChannelLabelSaveError' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ChannelLabelSaveError','Please first go to the background Settings->Interface Settings->Enterprise wechat channel code Settings, check whether the receiving event server Settings are correct!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ChannelLabelSaveError' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,'{"module":"ServiceContracts","column":"receivable_balance","columntype":"detail"}','{"module":"ServiceContracts","column":"receivable_balance","columntype":"main"}') where modulename='CashBill' and trigger_columnname='entitytypeid' and effect_columnname='amount';
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
UPDATE ld_field SET issmownerid = 0 where tabid = @tabid AND columnname = 'servicecasher';
delimiter;
-- 2022-12-07

SET @labelbol = 'OPENANEWTAB';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'打开新页签','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' Open a new tab ','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @disable_triggers=1;
UPDATE ld_salesorder
INNER JOIN (
	SELECT
		id,
		SUM(quantity) AS sumqty
	FROM ld_salesorderdetail
	GROUP BY id
) AS tmp ON tmp.id = ld_salesorder.salesorderid
SET ld_salesorder.totalquantity=tmp.sumqty;
SET @disable_triggers=NULL;
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractAmount' and compute_columns='ld_salesorder.total';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:sostatus:sostatus:SalesOrder_订单状态:V','n','已作废' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:sostatus:sostatus:SalesOrder_%') ;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractAmount' and compute_columns='ld_servicecontracts.total';
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:contract_status:contract_status:ServiceContracts_订单状态:V','n','已作废' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:contract_status:contract_status:ServiceContracts_%') ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORTUPDATEALL','覆盖(全部)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORTUPDATEALL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORTUPDATEALL','Update(All)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IMPORTUPDATEALL' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_operation_log` (
	`id` int(20) unsigned NOT NULL AUTO_INCREMENT,
    `module` varchar(50) DEFAULT NULL,
	`crmid` int(20) DEFAULT NULL,
	`action` varchar(50) DEFAULT NULL,
	`operator` int(20) DEFAULT NULL,
	`operation_time` datetime DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
	KEY `crmid` (`crmid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CALL AddColumn('ld_operation_log','actiontwo','varchar','50',NULL);
delimiter;

UPDATE ld_systems_deploy SET deploy_value=2,roottype=0 WHERE deploy_type=51;
delimiter;

UPDATE ld_desk SET fieldlabel = '修改个人资料' where labelbol = 'PERSONALDATA' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Modify profile' where labelbol = 'PERSONALDATA' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

SET @labelbol = 'CHANGELOGINPASSWORD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'修改登录密码','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Change Login Password','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='是空值' WHERE labelbol='ISNULL' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='不是空值' WHERE labelbol='ISNOTNULL' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='是当前操作员' WHERE labelbol='CURUSER' AND languagetype='zh';

UPDATE ld_entityname SET fieldname='contactrecord_no',tablename='ld_contactrecords' WHERE modulename='ContactRecords' AND fieldname='subject';
-- 2022-12-09

UPDATE ld_desk SET fieldlabel='Update(Include approved)' WHERE labelbol= 'IMPORTUPDATEALL' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='覆盖(含已审批)' WHERE labelbol= 'IMPORTUPDATEALL' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

CALL AddColumn('ld_field','keyword_sseq','int','10','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETDISPLAYFIELDS','设置显示字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETDISPLAYFIELDS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETDISPLAYFIELDS',"Set Display Fields",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETDISPLAYFIELDS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','KEYINFORMATION','关键信息栏','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='KEYINFORMATION' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','KEYINFORMATION','Key information','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='KEYINFORMATION' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','checktoday','今日','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='checktoday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','checktoday','Today','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='checktoday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','checkyesterday','昨日','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='checkyesterday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','checkyesterday','Yesterday','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='checkyesterday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thisyear1','本年度','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='thisyear1' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thisyear1','This Year','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='thisyear1' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','lastyear1','上年度','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='lastyear1' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','lastyear1',' Last Year','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='lastyear1' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortSunday','日','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortSunday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortSunday','Sun','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortSunday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortMonday','一','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortMonday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortMonday','Mon','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortMonday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortTuesday','二','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortTuesday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortTuesday','Tues','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortTuesday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortWednesday','三','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortWednesday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortWednesday','Wed','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortWednesday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortThursday','四','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortThursday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortThursday','Thur','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortThursday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortFriday','五','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortFriday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortFriday','Fri','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortFriday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShortSaturday','六','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortSaturday' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShortSaturday','Sat','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ShortSaturday' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dYear','年','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='dYear' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dYear','  -','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='dYear' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','dMonth','月','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='dMonth' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','dMonth',' ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='dMonth' and Labeltype='jspop' and languagetype='en');
delimiter;

update ld_field set typeofdata = 'V~O~LE' where typeofdata = 'V~OLE';
update ld_field set typeofdata = 'V~M~LE' where typeofdata = 'V~MLE';
set @system_351 = (select deploy_value from ld_systems_deploy where deploy_type = 351);
update ld_field set typeofdata = concat("N~O~25,",@system_351)  where (typeofdata = 'N~O25,2' or typeofdata = 'N~O') and  parentbigtype='currency';
update ld_field set typeofdata = concat("N~M~25,",@system_351)  where (typeofdata = 'N~M25,2' or typeofdata = 'N~M') and  parentbigtype='currency';
update ld_field set typeofdata = "N~O~25,2"  where typeofdata = 'N~O25,2';
update ld_field set typeofdata = "N~M~25,2" where typeofdata = 'N~M25.2' ;
delimiter;


CALL AddColumn('ld_field','relatedmodulefield','varchar','20','no');
CALL AddColumn('ld_cfoperationlog','relatedmodulefield','varchar','20','no');
CALL AddColumn('ld_producttoolfield','relatedmodulefield','varchar','20','no');
CALL AddColumn('ld_tabdetailfield','relatedmodulefield','varchar','20','no');
delimiter;
update ld_cfoperationlog set relatedmodulefield='yes' where bigtype='relatedmodulefield';
update ld_field set relatedmodulefield='yes' where bigtype='relatedmodulefield';
update ld_producttoolfield set relatedmodulefield='yes' where bigtype='relatedmodulefield';
update ld_tabdetailfield set relatedmodulefield='yes' where bigtype='relatedmodulefield';
delimiter;

update ld_field a left join (
select uitype,bigtype from ld_field where bigtype!='relatedmodulefield' and uitype>0 and ifnull(bigtype,'')<>''  group by uitype
)b on a.uitype=b.uitype
set a.bigtype=b.bigtype
where a.bigtype='relatedmodulefield'; 
delimiter;

update  ld_cfoperationlog 
INNER join ld_field on ld_field.fieldid=ld_cfoperationlog.fieldid
set ld_cfoperationlog.bigtype=ld_field.bigtype
where ld_cfoperationlog.bigtype='relatedmodulefield';
delimiter;

update ld_producttoolfield set bigtype='text' where bigtype='relatedmodulefield' and (uitype=1 or uitype=101);
update ld_producttoolfield set bigtype='datetime'  where bigtype='relatedmodulefield' and uitype=52;
update ld_producttoolfield set bigtype='num'  where bigtype='relatedmodulefield' and uitype=10;
update ld_producttoolfield set bigtype='number'  where bigtype='relatedmodulefield' and uitype=20;
update ld_producttoolfield set bigtype='boolean'  where bigtype='relatedmodulefield' and uitype=56;
update ld_producttoolfield set bigtype='amount'  where bigtype='relatedmodulefield' and uitype=50;
update ld_producttoolfield set bigtype='date'  where bigtype='relatedmodulefield' and uitype=51;
update ld_producttoolfield set bigtype='time'  where bigtype='relatedmodulefield' and uitype=53;
update ld_producttoolfield set bigtype='textarea'  where bigtype='relatedmodulefield' and uitype=2;
update ld_producttoolfield set bigtype='reference'  where bigtype='relatedmodulefield' and uitype=100;
update ld_producttoolfield set bigtype=''  where bigtype='relatedmodulefield' and uitype=220;
update ld_producttoolfield set bigtype=''  where bigtype='relatedmodulefield' and uitype=221;
delimiter;

update ld_tabdetailfield set fieldtype='Date_Ymd'  where fieldtype='date';
update ld_tabdetailfield set bigtype='text'  where bigtype='relatedmodulefield' and (fieldtype='Text' or fieldtype='RelatedModuleField');
update ld_tabdetailfield set bigtype='datetime'  where bigtype='relatedmodulefield' and fieldtype='Date_YmdHms';
update ld_tabdetailfield set bigtype='number'  where bigtype='relatedmodulefield' and fieldtype='Num';
update ld_tabdetailfield set bigtype='num'  where bigtype='relatedmodulefield' and fieldtype='Number';
update ld_tabdetailfield set bigtype='boolean'  where bigtype='relatedmodulefield' and fieldtype='CheckBox';
update ld_tabdetailfield set bigtype='amount'  where bigtype='relatedmodulefield' and fieldtype='Amount';
update ld_tabdetailfield set bigtype='date'  where bigtype='relatedmodulefield' and fieldtype='Date_Ymd';
update ld_tabdetailfield set bigtype='time'  where bigtype='relatedmodulefield' and fieldtype='Date_Hm';
update ld_tabdetailfield set bigtype='textarea'  where bigtype='relatedmodulefield' and fieldtype='TextArea';
update ld_tabdetailfield set bigtype='reference'  where bigtype='relatedmodulefield' and fieldtype='Reference';
update ld_tabdetailfield set bigtype=''  where bigtype='relatedmodulefield' and fieldtype='entitytype';
update ld_tabdetailfield set bigtype=''  where bigtype='relatedmodulefield' and fieldtype='SelectSource';
update ld_tabdetailfield set bigtype='amount'  where bigtype='relatedmodulefield' and fieldtype='SourceAmount';
delimiter;

update ld_tabdetailfield set bigtype='amount'  where bigtype='Amount';
delimiter;
-- 2022-12-12

DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_Signin`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule_Signin`(
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100),
	tmp_parenttabid INT(19)
)
BEGIN
		
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		UPDATE ld_tranlabel SET fieldlabel = tmp_zhmoudulename WHERE tabid=@tabid AND languagetype='zh' AND trantable='ld_tab'; 
		UPDATE ld_tranlabel SET fieldlabel = tmp_enmoudulename WHERE tabid=@tabid AND languagetype='en' AND trantable='ld_tab';

		IF EXISTS (SELECT 1 from ld_appparenttabrel where tabid = -2) THEN
			SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid),0);
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid AND tabid=@tabid);

			INSERT into ld_profile2tab(profileid,tabid,permissions)
			SELECT profileid,@tabid,0 from ld_profile 
			where not EXISTS(SELECT 1 from ld_profile2tab where ld_profile2tab.profileid = ld_profile.profileid and tabid = @tabid);
			
			INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
			SELECT profileid,@tabid,3,0,1 from ld_profile 
			where not EXISTS(SELECT 1 from ld_profile2standardpermissions 
				where ld_profile2standardpermissions.profileid = ld_profile.profileid and tabid = @tabid and operation = 3);

			INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
			SELECT profileid,@tabid,2,0,2 from ld_profile 
			where not EXISTS(SELECT 1 from ld_profile2standardpermissions 
				where ld_profile2standardpermissions.profileid = ld_profile.profileid and tabid = @tabid and operation = 2);
			
			INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
			SELECT profileid,@tabid,4,0,3 from ld_profile 
			where not EXISTS(SELECT 1 from ld_profile2standardpermissions 
				where ld_profile2standardpermissions.profileid = ld_profile.profileid and tabid = @tabid and operation = 4);
		END if;

		INSERT INTO ld_modtracker_tabs(tabid,visible)
		SELECT @tabid,1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);
		
		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence)
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
			('index','Detailview','Delete','Export','CustomView','DownLoad','Preview','FileReadHistory');

		INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
		SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),'address','signid','signid' FROM DUAl
		WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);
		
		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
		
		SET @i=0;
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		DELETE from ld_field where tabid=@tabid AND columnname='createdtime' and bigtype = 'reference';
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow,defaultvalue,allowedit)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,86,'createdtime','签到时间',1,0,(@i:=@i+1),@blockid ,1,'DT~O',1,0,1,2,'datetime',NULL,0,'thistoday','no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'签到时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Sign in Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );		
		
    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='address');
		UPDATE ld_field set displaytype = 2,fieldlabel='签到地址',block = @blockid,sequence=(@i:=@i+1) where columnname = 'address' and tabid = @tabid;
		UPDATE ld_tranlabel SET fieldlabel = '签到地址' WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field';
		UPDATE ld_tranlabel SET fieldlabel = 'Sign in Address' WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field';
		
		SET @value_143 =  (SELECT deploy_value from ld_systems_deploy where deploy_type = 143);	
		IF @value_143 = 1 then
			SET @field_presence = 2;
			SET @typeofdata = 'V~M';
		ELSEIF @value_143 = 2 then
			SET @field_presence = 2;
			SET @typeofdata = 'V~O';
		ELSE 
			SET @field_presence = 1;
			SET @typeofdata = 'V~O';
		END IF;
		UPDATE ld_field set bigtype = 'selectsource',block = @blockid,sequence=(@i:=@i+1),columnname='source_list',fieldname='selectlistval',presence=@field_presence,typeofdata=@typeofdata where (columnname = 'record' or columnname='source_list') and tabid = @tabid;
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='source_list');
		UPDATE ld_tranlabel SET fieldlabel = '拜访对象' WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field';
		UPDATE ld_tranlabel SET fieldlabel = 'Customer Name' WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field';
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
		SELECT @tabid,@maxfieldid+1,'entityaddress','no',CONCAT('ld_',LOWER(tmp_modulename)),1,2,'entityaddress','拜访地址',0,@field_presence,(@i:=@i+1),@blockid ,1,'V~O',1,0,1,1,'text',NULL,0,'yes','no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='entityaddress');
		
    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='entityaddress');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'拜访地址' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Visiting address' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		UPDATE ld_related_field SET effect_fieldid = @fieldid where trigger_fieldid = 2201 AND fromvalue_type = 'sql';

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,1,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'director' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,1,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow,savedatabase,auto_signin)
		SELECT @tabid,@maxfieldid+1,'signin_address','no',CONCAT('ld_',LOWER(tmp_modulename)),2,306,'signin_address','签到',0,0,(@i:=@i+1),@blockid ,2,'V~M',0,0,2,0,'signin',NULL,0,'no','yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='signin_address');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='signin_address');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'签到' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Signin' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );		
		
		SET @value_348 =  (SELECT deploy_value from ld_systems_deploy where deploy_type = 348);	
		IF @value_348 = 1 then
			SET @typeofdata = 'V~O';
		ELSE 
			SET @typeofdata = 'V~M';
		END IF;

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'content','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,19,'content','备注',1,0,(@i:=@i+1),@blockid ,1,@typeofdata,1,0,1,2,'longtextarea',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='content');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='content');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'备注' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Description' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );		
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow,savedatabase)
		SELECT @tabid,@maxfieldid+1,'distince','yes',CONCAT('ld_',LOWER(tmp_modulename)),2,1,'distince','误差(米)',0,2,(@i:=@i+1),@blockid ,2,'V~O',1,0,2,0,'text',NULL,0,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='distince');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='distince');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'误差(米)' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Distance(m)' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );		
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow,savedatabase)
		SELECT @tabid,@maxfieldid+1,'uuid','yes',CONCAT('ld_',LOWER(tmp_modulename)),2,1,'uuid','手机设备号',0,2,(@i:=@i+1),@blockid ,2,'V~O',1,0,2,0,'text',NULL,0,'yes' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='uuid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='uuid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'手机设备号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Mobile ID' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );		
		
		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,'LBL_FILE_INFORMATION',1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_FILE_INFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_FILE_INFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'附件信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Attachments Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
		
		SET @take_photo_only = (SELECT deploy_value from ld_systems_deploy where deploy_type = 114);
		
		SET @value_200 =  (SELECT deploy_value from ld_systems_deploy where deploy_type = 200);	
		IF @value_200 = 1 then
			SET @typeofdata = 'V~O';
		ELSE 
			SET @typeofdata = 'V~M';
		END IF;

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow,savedatabase,take_photo_only)
		SELECT @tabid,@maxfieldid+1,'imagename','yes',CONCAT('ld_',LOWER(tmp_modulename)),2,69,'imagename','照片',0,2,(@i:=@i+1),@blockid ,1,@typeofdata,1,0,2,0,'fileattachment',NULL,0,'yes',@take_photo_only FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='imagename');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='imagename');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'照片' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Photo' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );		
		
		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);
		
		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');
			
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+2,'本周内创建',0,0,tmp_modulename,3,1,2 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='本周内创建');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+3,'本月内创建',0,0,tmp_modulename,3,1,3 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='本月内创建');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+4,'本年内创建',0,0,tmp_modulename,3,1,4 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='本年内创建');
		
		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);

		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,0,CONCAT('ld_singin:address:address:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,1,CONCAT('ld_singin:source_list:selectlistval:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,2,CONCAT('ld_singin:entityaddress:entityaddress:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,3,CONCAT('ld_singin:smownerid:assigned_user_id:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,4,CONCAT('ld_singin:createdtime:createdtime:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,5,CONCAT('ld_singin:content:content:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,6,CONCAT('ld_singin:distince:distince:Singin_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,7,CONCAT('ld_singin:imagename:imagename:Singin_fieldlabel:V');
		
		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='本周内创建');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_singin:createdtime:createdtime:Singin_fieldlabel:V','thisweek','2022-12-12 00:00:00,2022-12-18 23:59:59',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		
		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='本月内创建');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_singin:createdtime:createdtime:Singin_fieldlabel:V','thismonth','2022-12-01 00:00:00,2022-12-31 23:59:59',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='本年内创建');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,'ld_singin:createdtime:createdtime:Singin_fieldlabel:V','thisfy','2022-01-01 00:00:00,2022-12-31 23:59:59',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 0,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=0);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 1,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=1);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 2,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=2);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 3,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=3);

		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);
		
		
SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `signid` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`signid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;

		DROP PREPARE stmt;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addSignin`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addSignin`(
)
BEGIN
   SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Accounts');
   CALL ldcrm_addnewmoudule_Signin('Singin','拜访签到','Outside Sign',@myparenttabid);
end ||
delimiter;
CALL ldcrm_addSignin();
DROP PROCEDURE IF EXISTS `ldcrm_addSignin`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_Signin`;
delimiter;

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

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Singin';
CALL ldcrm_add_cvcolumnlist_wx('Singin','source_list','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Singin','address','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Singin','distince','3','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Singin','createdtime','4','1','no','yes');
CALL ldcrm_add_cvcolumnlist_wx('Singin','smownerid','4','2','no','yes');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Singin');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'selectlistval',1,'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='accountname');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'address',2,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'distince',3,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='distince');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'createdtime',4,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'smownerid',5,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='userid');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter;

CALL AddColumn('ld_singin','signid','int','19',NULL);
CALL AddColumn('ld_singin','source_list','int','19',NULL);
CALL AddColumn('ld_singin','smownerid','int','19',NULL);
CALL AddColumn('ld_singin','smcreatorid','int','19',NULL);
CALL AddColumn('ld_singin','modifiedtime','datetime','',NULL);
CALL AddColumn('ld_singin','signin_address','varchar','255',NULL);
CALL AddColumn('ld_singin','imagename','varchar','255',NULL);
CALL AddColumn('ld_singin','entitytype','varchar','255',NULL);
CALL AddColumn('ld_singin','modifiedby','int','19',NULL);
delimiter;

UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
SELECT MAX(crmid) into @maxcrmid FROM ld_crmentity;
SELECT MAX(id) into @maxsignid FROM ld_singin;
UPDATE ld_crmentity_seq set id = @maxcrmid+@maxsignid;

INSERT INTO ld_crmentity(crmid,setype)
SELECT id+@maxcrmid,'Singin' FROM ld_singin where IFNULL(ld_singin.signid,0)=0;

UPDATE ld_singin SET signid = id+@maxcrmid where IFNULL(ld_singin.signid,0)=0;
UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
delimiter;

INSERT into ld_singinscf(signid)
SELECT signid from ld_singin 
where NOT EXISTS(SELECT 1 from ld_singinscf where signid = ld_singin.signid);
delimiter;

UPDATE ld_singin SET smcreatorid = userid,smownerid = userid;
delimiter;

UPDATE ld_singin INNER JOIN ld_tab on ld_singin.tabid = ld_tab.tabid
SET ld_singin.entitytype = ld_tab.`name`,ld_singin.source_list = ld_singin.record;

UPDATE ld_tab SET mobilepresence = 'mobile,weixin' where name = 'Singin';
UPDATE ld_appparenttabrel SET tabid = 142 where tabid = -2;
UPDATE ld_appuiset set tabid = 142,setname='Singin' where tabid = -2;
delimiter;

UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
SELECT MAX(crmid) into @maxcrmid FROM ld_crmentity;
SELECT MAX(id) into @maxattmentid FROM ld_attachmentsforsign;
UPDATE ld_crmentity_seq set id = @maxcrmid+@maxattmentid;

CALL AddColumn('ld_attachmentsforsign','newattachmentsid','int','19',NULL);
UPDATE ld_attachmentsforsign SET newattachmentsid = id+@maxcrmid where IFNULL(newattachmentsid,0)=0;

INSERT INTO ld_crmentity(crmid,setype)
SELECT newattachmentsid,'Singin Image' FROM ld_attachmentsforsign 
where not EXISTS(SELECT 1 from ld_crmentity where crmid = newattachmentsid);

INSERT into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)
SELECT ld_singin.signid,ld_attachmentsforsign.newattachmentsid,'imagename' from ld_attachmentsforsign INNER JOIN ld_singin 
	on ld_attachmentsforsign.signid = ld_singin.id 
where NOT EXISTS(SELECT 1 from ld_seattachmentsrel where ld_seattachmentsrel.attachmentsid = ld_attachmentsforsign.newattachmentsid);

INSERT into ld_attachments(attachmentsid,`name`,description,type,path,`subject`,size,newfile_name,imagefromtype,
	storage_location,upload_from,cloud_path)
SELECT newattachmentsid,filename,'',type,path,'',size,filename,case imagefromtype WHEN '手机拍照' then 'Takephoto' ELSE 'Computer' END
,storage_location,'',cloud_path from ld_attachmentsforsign 
where NOT EXISTS(SELECT 1 from ld_attachments where ld_attachments.attachmentsid = ld_attachmentsforsign.newattachmentsid);
delimiter;

UPDATE ld_systems_deploy SET roottype = '' where deploy_type in (114,143,200,348);
delimiter;

SET @labelbol = 'RECALCULATEERROR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'重算误差','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Recalculate error','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'RECALCULATEERRORJS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'重算误差','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Recalculate error','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','KEYWORDSSAVE','关键字段数量超出20个会影响界面效果,请问是否继续?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='KEYWORDSSAVE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','KEYWORDSSAVE',"If the number of key fields exceeds 20, the interface effect will be affected. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='KEYWORDSSAVE' and labeltype='jspop');
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

	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

		IF IFNULL(@tablename,'')<>'' THEN
			CALl AddColumn(@tablename,'approvesubmitter','INT','19',0);
			CALl AddColumn(@tablename,'approvesubmittedtime','DATETIME','',0);
			CALl AddColumn(@tablename,'currentapprovestepid','INT','19',0);
			CALL AddColumn(@tablename,'approveurgent','varchar','10','');
			CALL AddColumn(@tablename,'approveexpediting','varchar','10','');


			SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

			SET @maxseq=IFNULL((SELECT sequence FROM ld_field WHERE tabid=@tabid AND block=@relateid AND columnname='smownerid'),0);
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
			SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


			SET @i=0;
			UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@relateid ORDER BY sequence;

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
			SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,'approveby','INT','19',NULL);


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
			SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,'currentapprover','TEXT','100',NULL);


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
			SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
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
			SELECT 0,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
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
	END IF;

end ||
delimiter;

CALL ldcrm_add_approveforbill('CashBack',352);
CALL ldcrm_add_approveforbill('PurchaseBack',353);
CALL ldcrm_add_approveforbill('PurchaseCashBack',354);
CALL ldcrm_add_approveforbill('Checks',355);
CALL ldcrm_add_approveforbill('WareHouseTransfer',356);
DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter;


UPDATE ld_purchaseback SET purchasebackstatus='已出库' WHERE purchasebackstatus='结束';
UPDATE ld_purchaseback SET purchasebackstatus='未出库' WHERE purchasebackstatus='中止' OR IFNULL(purchasebackstatus,'')='';
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
select actionid into @actionid from  ld_actionmapping where actionname='EndreturnGood';
delete from ld_profileallpermission where tabid=@tabid and operation=@actionid;
delete from ld_profile2standardpermissions where tabid=@tabid and operation=@actionid;
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseBack';
select actionid into @actionid from  ld_actionmapping where actionname='WarehouseConfirmed';
delete from ld_profileallpermission where tabid=@tabid and operation=@actionid;
delete from ld_profile2standardpermissions where tabid=@tabid and operation=@actionid;
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseBack';
select actionid into @actionid from  ld_actionmapping where actionname='Reteacement';
delete from ld_profileallpermission where tabid=@tabid and operation=@actionid;
delete from ld_profile2standardpermissions where tabid=@tabid and operation=@actionid;
delimiter;


select tabid into @tabid from ld_tab where name='PurchaseBack';
update ld_field set displaytype=1,uitype=15,defaultvalue='未出库',allowedit='yes' where tabid=@tabid and columnname='purchasebackstatus';
delimiter;
insert into ld_picklist_set(listname,relatetable,parent_listname,parent_relatetable)
select 'purchasebackstatus','ld_field','','' from dual
where not exists(select 1 from ld_picklist_set where listname='purchasebackstatus' and relatetable='ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname='purchasebackstatus' and relatetable='ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'未出库' ,1 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=1);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'已出库' ,2 from dual where not exists(select 1 from ld_picklist_values where listid=@listid and sequence=2);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUDONOTHAVEPERMISSIONTOTHISDOCUMENT','您对该单据的仓库没有操作权限！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='YOUDONOTHAVEPERMISSIONTOTHISDOCUMENT！' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUDONOTHAVEPERMISSIONTOTHISDOCUMENT','You do not have access to the warehouse for this document','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='YOUDONOTHAVEPERMISSIONTOTHISDOCUMENT' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = '移动端分录折叠显示' where languagetype = 'zh' and labelbol = 'MOBILEDETAILSHOW' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Folding display of entries on mobile terminal' where languagetype = 'en' and labelbol = 'MOBILEDETAILSHOW' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '若开启此参数，则该字段允许在移动端明细页签的折叠列表显示' where languagetype = 'zh' and labelbol = 'FIELDDISPLAYINMOBILEDETAIL' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'If this parameter is enabled, this field can be displayed in the collapsed list of the mobile terminal details tab' where languagetype = 'en' and labelbol = 'FIELDDISPLAYINMOBILEDETAIL' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_settings_field SET active = 1 where `name` = 'LBL_Optionalmodule_Customization';
delimiter;


update ld_systems_deploy set presence=1 where deploy_type=137;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_update_questionnaire_historyjson`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_questionnaire_historyjson`(

)BEGIN
	IF NOT EXISTS (select 1 from information_schema.`COLUMNS` where TABLE_SCHEMA=database() and TABLE_NAME='ld_questionnaire_topic' and column_name='telregexp') THEN
UPDATE ld_questionnaire_topic set topic_json_old = 'yes';
END IF;
end ||
delimiter;
CALL ldcrm_update_questionnaire_historyjson();delimiter;
CALL AddColumn('ld_questionnaire_topic','telregexp','varchar','10','no');
delimiter;

call AddColumn('ld_field','adddetails','varchar','20','no');
delimiter;

SET @labelbol = 'COPYFORME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'抄送给我的','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cc to me','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-12-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LoadLocalStorage','确定后，将会覆盖现有信息，是否继续？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LoadLocalStorage' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LoadLocalStorage','After confirmation, the existing information will be overwritten. Do you want to continue?','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LoadLocalStorage' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','GetStaging','获取暂存信息','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='GetStaging' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','GetStaging','Get Staging Information','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='GetStaging' and Labeltype='jspop');
delimiter;

SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=122 LIMIT 1);
SET @sequence=(SELECT sequence FROM ld_systems_deploy WHERE deploy_type=122 LIMIT 1);
UPDATE ld_systems_deploy SET sequence=sequence+5 WHERE sequence>@sequence-1 AND roottype=@roottype;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,357,'设置单据新建界面是否启用暂存功能','',@sequence-1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 357);
delimiter;

SET @i=0;
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=@roottype ORDER BY sequence;
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',357,357,'设置单据新建界面是否启用暂存功能' from dual
where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=357);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',357,357,'Set whether to enable the temporary storage function on the create page' from dual
where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=357);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NotStaging','没有暂存信息','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NotStaging' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NotStaging','No staging information','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NotStaging' and Labeltype='jspop');
delimiter;

UPDATE ld_field SET keywords=NULL,keyword_sseq=NULL;
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_activity' AND columnname='subject';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_activity' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_activity' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=1 WHERE tablename='ld_salesorder' AND columnname='accountid';
UPDATE ld_field SET keywords='yes',keyword_sseq=2 WHERE tablename='ld_salesorder' AND columnname='total';
UPDATE ld_field SET keywords='yes',keyword_sseq=3 WHERE tablename='ld_salesorder' AND columnname='received_amount';
UPDATE ld_field SET keywords='yes',keyword_sseq=4 WHERE tablename='ld_salesorder' AND columnname='have_invoicetotal';
UPDATE ld_field SET keywords='yes',keyword_sseq=5 WHERE tablename='ld_salesorder' AND columnname='signed_data';
UPDATE ld_field SET keywords='yes',keyword_sseq=6 WHERE tablename='ld_salesorder' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=7 WHERE tablename='ld_salesorder' AND columnname='receivable_balance';
UPDATE ld_field SET keywords='yes',keyword_sseq=8 WHERE tablename='ld_salesorder' AND columnname='nothave_invoicetotal';
UPDATE ld_field SET keywords='yes',keyword_sseq=2 WHERE tablename='ld_users' AND columnname='user_password';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_reminds' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_reminds' AND columnname='content';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_bankaccountset' AND columnname='accountname';
UPDATE ld_field SET keywords='yes',keyword_sseq=1 WHERE tablename='ld_cashdeposit' AND columnname='cashdepositdate';
UPDATE ld_field SET keywords='yes',keyword_sseq=2 WHERE tablename='ld_cashdeposit' AND columnname='outaccount';
UPDATE ld_field SET keywords='yes',keyword_sseq=3 WHERE tablename='ld_cashdeposit' AND columnname='inaccount';
UPDATE ld_field SET keywords='yes',keyword_sseq=4 WHERE tablename='ld_cashdeposit' AND columnname='cashmoney';
UPDATE ld_field SET keywords='yes',keyword_sseq=1 WHERE tablename='ld_purchaseback' AND columnname='vendorid';
UPDATE ld_field SET keywords='yes',keyword_sseq=2 WHERE tablename='ld_purchaseback' AND columnname='purchasebackstatus';
UPDATE ld_field SET keywords='yes',keyword_sseq=3 WHERE tablename='ld_purchaseback' AND columnname='purchasebackdate';
UPDATE ld_field SET keywords='yes',keyword_sseq=4 WHERE tablename='ld_purchaseback' AND columnname='total';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_rate' AND columnname='ratename';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_rate' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_bankbranch' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_bankbranch' AND columnname='bankname';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_dividendorder' AND columnname='dividend_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_dividendorder' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_net' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_net' AND columnname='fund_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_reward' AND columnname='reward_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_reward' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_reward_commission' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_reward_commission' AND columnname='rewardcommission_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_management' AND columnname='management_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_management' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_management_commission' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_fund_management_commission' AND columnname='managementcommission_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform02' AND columnname='customform02_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform02' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform03' AND columnname='customform03_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform03' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform04' AND columnname='customform04_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform04' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform05' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform05' AND columnname='customform05_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform06' AND columnname='customform06_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform06' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform07' AND columnname='customform07_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform07' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform08' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform08' AND columnname='customform08_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform09' AND columnname='customform09_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform09' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform10' AND columnname='customform10_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform10' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform11' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform11' AND columnname='customform11_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform12' AND columnname='customform12_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform12' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform13' AND columnname='customform13_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform13' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform14' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform14' AND columnname='customform14_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform15' AND columnname='customform15_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform15' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform16' AND columnname='customform16_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform16' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform17' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform17' AND columnname='customform17_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform18' AND columnname='customform18_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform18' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform19' AND columnname='customform19_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform19' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform20' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform20' AND columnname='customform20_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform21' AND columnname='customform21_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform21' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform22' AND columnname='customform22_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform22' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform23' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform23' AND columnname='customform23_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform24' AND columnname='customform24_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform24' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform25' AND columnname='customform25_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_customform25' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_socialpromotion' AND columnname='smownerid';
UPDATE ld_field SET keywords='yes',keyword_sseq=0 WHERE tablename='ld_socialpromotion' AND columnname='socialpromotion_no';
UPDATE ld_field SET keywords='yes',keyword_sseq=1 WHERE tablename='ld_customform46' AND columnname='projectid';
UPDATE ld_field SET keywords='yes',keyword_sseq=2 WHERE tablename='ld_customform46scf' AND columnname='cf_5206';
UPDATE ld_field SET keywords='yes',keyword_sseq=3 WHERE tablename='ld_customform46' AND columnname='approvestatus';
UPDATE ld_field SET keywords='yes',keyword_sseq=4 WHERE tablename='ld_customform46' AND columnname='smownerid';
delimiter;

SET @labelbol = 'ENABLEQUICKRETURNHOME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否启用快捷返回页签首页按钮','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Enable Quick Return Tab Home Button','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2022-12-27

SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT '0',359,'客户地址是否使用使用天眼查接口1：是，0：否','',@sequence+1,NULL,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 359);
delimiter;
-- 2022-12-29

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

UPDATE ld_version SET old_version='V8.4.8.4',current_version='V8.4.8.4',remark='V8.4.8.4-20221229',wx_version='V8.4.8.4';
delimiter;