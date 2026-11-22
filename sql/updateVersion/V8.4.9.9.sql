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

select id into @tabid from ld_linkmodulecustom where url='index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=stock_report';
delete from ld_appparenttabrel where tab_tablename='ld_linkmodulecustom' and tabid=@tabid;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_complete_approvefield`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_approvefield`(
)
BEGIN
DECLARE i int DEFAULT 161;
WHILE i<=200 DO

SET @tablename=(SELECT tablename FROM ld_field WHERE tablename=CONCAT('ld_customform',i) and columnname='smownerid' LIMIT 1);

CALl AddColumn(@tablename,'approvesubmitter','INT','19',0);
CALl AddColumn(@tablename,'approvesubmittedtime','DATETIME','',0);
CALl AddColumn(@tablename,'currentapprovestepid','INT','19',0);
CALL AddColumn(@tablename,'approveurgent','varchar','10','');
CALL AddColumn(@tablename,'approveexpediting','varchar','10','');

SET i=i+1;
END WHILE;

end ||
delimiter;

CALL ldcrm_complete_approvefield();
DROP PROCEDURE IF EXISTS `ldcrm_complete_approvefield`;
delimiter;

UPDATE ld_relatedlists SET presence=1 WHERE `name`='account_buy_products.mrt' and 
not EXISTS (select 1 from ld_tab where `name` = 'OutboundOrder' and presence in (0,2,5));
delimiter;

update ld_desk set fieldlabel = '开始日期不能晚于结束日期！' where languagetype = 'zh' and labelbol = 'STARTDATECANOTGREATERENDDATEAPP' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'The start date cannot be later than the end date!' where languagetype = 'en' and labelbol = 'STARTDATECANOTGREATERENDDATEAPP' and Labeltype = 'fixedstr';
delimiter;

set @tmptypeofdata=(select typeofdata from ld_field where tablename='ld_customform12' and fieldname='hdnGrandTotal');
update ld_field set typeofdata=@tmptypeofdata where bigtype="currency" and (uitype = 71 or uitype=72) and columnname!="unit_price" and columnname!="costprice";
delimiter;

update ld_desk set fieldlabel = '按钮增加一条记录' where labelbol = 'ADDARECORD' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = ' to add a record' where labelbol = 'ADDARECORD' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

SET @labelbol = 'ACTIVITYADDREMOVEFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'添加/移除字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add/Remove Fields','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

ALTER TABLE `ld_purchaseinquiryorder` MODIFY COLUMN currentapprover VARCHAR(255);
delimiter;

SET @labelbol = 'NOTMEETCONDITIONSPLEASERESUBMIT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'此单据不符合审批流程条件，请重新提交！','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This document does not meet the approval process conditions. Please resubmit!','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='SalesOrder');
set @relatedtabid = (select tabid from ld_tab where `name`='CashBack');
update ld_relatedlists set type='entitytype_datacategory_sql',related_coltable='tmpsourcedetail.id' where tabid=@tabid and related_tabid=@relatedtabid and type='salesordercashback_datacategory_sql';
delimiter;

CALL AddColumn('ld_picklist_values','win_rate','int','10',NULL);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','WinRate','赢率','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='WinRate' and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','WinRate','Win rate','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='WinRate' and Labeltype='fixedstr');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='Ambassador');
update ld_field set uitype=1101,bigtype='mobile' where tabid=@tabid and fieldname='apply_phone';
delimiter;

select blockid into @blockid from ld_settings_field where `name`='wxselfbuiltapp_setting';
select sequence into @sequence from ld_settings_field where blockid = @blockid and name = 'wxselfbuiltapp_setting';
update ld_settings_field set sequence = sequence + 10000 where blockid = @blockid and sequence > @sequence;
select max(fieldid) + 1 into @max_fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @max_fieldid,@blockid,'weixinpay_setting','picklistdependency.png','weixinpay_setting','index.php?module=Settings&action=MerchantNoSettings&parenttab=Settings',@sequence+1,0 from DUAL
where not exists(select 1 from ld_settings_field where `name` = 'weixinpay_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','weixinpay_setting','微信支付商户号设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='weixinpay_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','weixinpay_setting','WeChat payment merchant account settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='weixinpay_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_wx_config (name,description) select 'weixinpay_setting','微信支付商户号设置' from dual where not exists(select 1 from ld_wx_config where name='weixinpay_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','application_setting','应用设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='application_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','application_setting','application setting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='application_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','application_type','应用类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='application_type' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','application_type','application type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='application_type' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WeChatofficialaccount','微信公众号','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WeChatofficialaccount' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WeChatofficialaccount','WeChat official account','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WeChatofficialaccount' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
SET @tabid=(SELECT tabid from ld_tab where name='WorkSheet');
select block into @blockid from ld_field where columnname='worksheet_no' and tabid=@tabid;
SET @maxsequence=(SELECT MAX(sequence) from ld_field where tabid=@tabid and block=@blockid);

INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow,isenablepresence)
SELECT @tabid,@maxfieldid+1,'payment_status','yes','ld_worksheet',1,1,'payment_status','支付状态',1,2,@maxsequence+1,@blockid,1,'V~O',0,0,1,2,'no','no','no','no','translatefield',NULL,0,'no' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='payment_status');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='payment_status');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'支付状态' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'Payment status' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field');

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'payment_status','WorkSheet','Unpaid','Unpaid' from dual
where not exists(select 1 from ld_translatefield where module='WorkSheet' and columnname='payment_status' and column_Dbvalue='Unpaid');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'payment_status','WorkSheet','HavePaid','HavePaid' from dual
where not exists(select 1 from ld_translatefield where module='WorkSheet' and columnname='payment_status' and column_Dbvalue='HavePaid');
delimiter;

CALL AddColumn('ld_worksheet','payment_status','varchar','20','Unpaid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Unpaid','未支付','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Unpaid' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Unpaid','Unpaid','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Unpaid' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HavePaid','已支付','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HavePaid' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HavePaid','Paid','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='HavePaid' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_weixinpay_native` (
	`nativeid` int(19) NOT NULL AUTO_INCREMENT primary key,
	`modulename` varchar(100) NOT NULL  COMMENT'模块名称',
	`record` int(19) NOT NULL COMMENT'存单据id 加索引',
	`total` decimal(15,2) NOT NULL COMMENT'总金额',
	`currency` char(5) NOT NULL default 'CNY' COMMENT'币种，默认CNY，境内商户只允许CNY',
	`apptype` varchar(100) NOT NULL COMMENT'应用类型，如小程序，公众号，app等',
	`appid` varchar(32) NOT NULL COMMENT'appid',
	`mchid` varchar(32) NOT NULL COMMENT'商户号，微信支付必填',
	`description` varchar(127) NOT NULL COMMENT'商品描述，微信支付必填',
	`out_trade_no` varchar(32) NOT NULL COMMENT'商户系统内部订单号，只能是数字、大小写字母_-*且在同一个商户号下唯一,string[6,32]   ',
	`code_url` text NOT NULL COMMENT'二维码链接',
	`code_url_createdtime` datetime NOT NULL COMMENT'二维码链接创建时间',
	`code_url_expiredtime` datetime NOT NULL COMMENT'二维码链接过期时间  创建时间+90min(微信支付要求是2H )',
	`code_url_requeststatus` varchar(100) NOT NULL COMMENT'下单状态码 ',
	`userid` int(19) NOT NULL COMMENT'创建人id',
	INDEX record(record)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_weixinpay_notify` (
	`notifyid` int(19) NOT NULL AUTO_INCREMENT,
	`out_trade_no` varchar(32) NOT NULL COMMENT'商户系统内部订单号，只能是数字、大小写字母_-*且在同一个商户号下唯一,string[6,32]   ',
	`transaction_id` varchar(32) NOT NULL COMMENT'微信支付订单号',
	`trade_type` varchar(16) NOT NULL COMMENT'交易类型，枚举值：JSAPI：公众号支付NATIVE：扫码支付APP：APP支付MICROPAY：付款码支付MWEB：H5支付FACEPAY：刷脸支付示例值：MICROPAY',
	`trade_state` varchar(32) NOT NULL COMMENT'交易状态，枚举值：SUCCESS：支付成功REFUND：转入退款NOTPAY：未支付CLOSED：已关闭REVOKED：已撤销（付款码支付）USERPAYING：用户支付中（付款码支付）PAYERROR：支付失败(其他原因，如银行返回失败)示例值：SUCCESS',
	`trade_state_desc` varchar(256) NOT NULL COMMENT'交易状态描述 ',
	`bank_type` varchar(32) NOT NULL COMMENT'银行类型，采用字符串类型的银行标识 ',
	`attach` varchar(128) NOT NULL COMMENT'附加数据，在查询API和支付通知中原样返回，可作为自定义参数使用，实际情况下只有支付完成状态才会返回该字段 ',
	`success_time` datetime NOT NULL COMMENT'支付完成时间 ',
	`payer_openid` varchar(128) NOT NULL COMMENT'支付者信息,用户在直连商户appid下的唯一标识。 ',
	`payer_total` decimal(15,2) NOT NULL COMMENT'支付金额',
	PRIMARY KEY  (`notifyid`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GeneratePaymentCode','生成收款码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GeneratePaymentCode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GeneratePaymentCode','Generate payment code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='GeneratePaymentCode' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','SELFSERVICEQRCODEEXPLAIN1','支持右键保存图片','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODEEXPLAIN1' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','SELFSERVICEQRCODEEXPLAIN1','Right click to save pictures','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SELFSERVICEQRCODEEXPLAIN1' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','Nopaymentrequired','无需支付','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Nopaymentrequired' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','Nopaymentrequired','No payment required','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Nopaymentrequired' and languagetype='en' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','Incompletefilling','未填写完整','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Incompletefilling' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','Incompletefilling','Incomplete filling','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Incompletefilling' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','Expirationtime','过期时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Expirationtime' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','Expirationtime','Expiration time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Expirationtime' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','Expirationtime','过期时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Expirationtime' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','Expirationtime','Expiration time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Expirationtime' and languagetype='en' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'zh','Regeneratepaymentcode','重新生成收款码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Regeneratepaymentcode' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
select 'en','Regeneratepaymentcode','Regenerate payment code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Regeneratepaymentcode' and languagetype='en' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Executor','执行人：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Executor' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Executor',"Executor：",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Executor' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RESETTING','重置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RESETTING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RESETTING','Resetting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RESETTING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPLICATION','应用','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='APPLICATION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPLICATION','Application','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='APPLICATION' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDMODIFIEDCLOSECHECk','字段设置已修改，是否需要保存？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FIELDMODIFIEDCLOSECHECk' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDMODIFIEDCLOSECHECk','The field settings have been modified. Do you want to save them?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='FIELDMODIFIEDCLOSECHECk' and Labeltype='jspop' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11))
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

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and pool_id = tmp_pool_id;

    select beforereminddays into @var_beforereminddays  from ld_account_public_pool where  id = tmp_pool_id;


 if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
	end if;
  select userid_after_release into @allotaccount from ld_account_public_pool where id = tmp_pool_id;
	select recycleselect into @recycleselect from ld_account_public_pool where id = tmp_pool_id;
	

	if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	OPEN cur1;

	Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
		 set @old_days=var_days;
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
		   else
				set	var_smownercolumn='smownerid' ;
			end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate) BETWEEN ",var_days,' and ' ,@old_days);
					end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);
					IF var_iscycle = 'yes' then 
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					ELSE
						set @tmpthree=@tmpsqltwo;
					end if;
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
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
			Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;

	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
	

    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";

			 set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',var_days);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			if @recycleselect is not null and @recycleselect<>'' then

					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
				ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
				end if;

			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  
			as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp
  on  lingdangtmp.accountid=ld_account.accountid ') ;

				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid    ');
		end if;
  select @TMPSQL_TWO;
		delete from ld_publicaccount_remindtableview ;
        set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

        call crm_publicaccount_beforereminds();
	end if;
end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotApprovedNotSignedByForm','您的单据还未审批通过，合同不允许发起签署！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotApprovedNotSignedByForm' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotApprovedNotSignedByForm','Your documents has not been approved yet. The documents cannot be signed!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NotApprovedNotSignedByForm' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QUICKFIND','全局查找','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='QUICKFIND' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QUICKFIND','Global search','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='QUICKFIND' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Topping','置顶','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Topping' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Topping','Topping','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Topping' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel = '企业微信组织架构同步' where labelbol = 'addressbook_setting' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Synchronize enterprise WeChat organizational structure' where labelbol = 'addressbook_setting' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTIONCRITERIA','选择条件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTIONCRITERIA' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTIONCRITERIA','Selection criteria ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTIONCRITERIA' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2023-04-28

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

UPDATE ld_version SET old_version='V8.4.9.9',current_version='V8.4.9.9',remark='V8.4.9.9-20230428',wx_version='V8.4.9.9';
delimiter;