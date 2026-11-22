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

SET @modulename='Singin';
SET @trigger_columnname='source_list';
SET @effect_columnname='entityaddress';
SET @fromvalue_type='sql';
SET @fromvalue_info='SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_account
WHERE ld_account.deleted = 0 AND accountid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_contactdetails
INNER JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
WHERE ld_account.deleted = 0 AND ld_contactdetails.contactid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_contactrecords
INNER JOIN ld_account ON ld_account.accountid = ld_contactrecords.accountid
WHERE ld_account.deleted = 0 AND ld_contactrecords.contactrecordID = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_potential
INNER JOIN ld_account ON ld_account.accountid = ld_potential.accountid
WHERE ld_account.deleted = 0 AND ld_potential.potentialid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_troubletickets
INNER JOIN ld_account ON ld_account.accountid = ld_troubletickets.accountid
WHERE ld_account.deleted = 0 AND ld_troubletickets.ticketid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_project
INNER JOIN ld_account ON ld_account.accountid = ld_project.accountid
WHERE ld_account.deleted = 0 AND ld_project.projectid = ?
UNION
SELECT CONCAT(ld_leads.bill_state,ld_leads.bill_city,IFNULL(ld_leads.bill_area,""),ld_leads.bill_street) AS address
FROM ld_leads
WHERE deleted = 0 AND leadsid = ?';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);

INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
SELECT 'main',@trigger_fieldid,@effect_fieldid,@fromvalue_type,@fromvalue_info FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid)
	AND @trigger_fieldid>0 AND @effect_fieldid>0;
delimiter;
	
SET @modulename='Contacts';
SET @trigger_columnname='accountid';
SET @effect_columnname='parentid';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @trigger_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@trigger_columnname);
SET @effect_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@effect_columnname);

DELETE FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid;
delimiter;
-- 2023-01-13

CREATE TABLE IF NOT EXISTS `ld_qrcode_operatelog_detail` (
	`qrcodedetaillogid` int(19) NOT NULL auto_increment PRIMARY KEY,
	`qrcodebasicid` int(19),
	`wechatuserid` int(19),
	`viewtime` datetime,
	`type` varchar(20),
	`trackid` int(19),
	`crmid` int(19)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call addtableIndex('ld_qrcode_operatelog_detail','detail_qrcodedetaillogid','qrcodedetaillogid');
delimiter;

CREATE TABLE if not EXISTS `ld_validatasavemain` (
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`rulename` varchar(100) DEFAULT NULL,
	`module` varchar(100) DEFAULT NULL,
	`status` char(10) DEFAULT 'active',
	`actionprevent` char(10) DEFAULT NULL,
	`tipzhtype` char(10) DEFAULT NULL,
	`tipzh` varchar(255) DEFAULT NULL,
	`tipentype` char(10) DEFAULT NULL,
	`tipen` varchar(255) DEFAULT NULL,
	`validatasavetype` char(10) DEFAULT 'php',
	`isshowlist` char(10) DEFAULT 'yes',
	`conditiongroup` varchar(255) DEFAULT NULL,
	`validataapplication` varchar(100) DEFAULT NULL,
	`relatedtable` char(30) DEFAULT NULL,
	`sequence` int(11) DEFAULT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_validatasave','validatasavemainid','int','19',NULL);
delimiter;

call AddColumn('ld_validatasave','conditiongroupid','smallint','6',NULL);
delimiter;

call AddColumn('ld_validatasave','valid_condition','char','10',NULL);
delimiter;

UPDATE ld_validatasave INNER JOIN ld_validatasavedetail on ld_validatasave.id = ld_validatasavedetail.relateid
set ld_validatasave.funtype = IF(IFNULL(ld_validatasave.funtype,'')='','fields',ld_validatasave.funtype),
		ld_validatasavedetail.funtype = IF(IFNULL(ld_validatasavedetail.funtype,'')='','fields',ld_validatasavedetail.funtype)
where ld_validatasave.validatasavetype = 'php';

drop PROCEDURE  if EXISTS update_validatarule;
delimiter ||
create PROCEDURE update_validatarule
(
)
BEGIN
	declare var_validataid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_validatasave where validatasavetype = 'php' and isshowlist = 'yes' AND IFNULL(validatasavemainid,0) = 0;

	declare continue handler  for not   found  SET done =1;
	
	open cur1;
	Fetch cur1 into var_validataid;
	loop1: while  done<>1 DO
				INSERT into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence)
				SELECT rulename,module,`status`,case when allowsave = 'no' then 'yes' ELSE 'no' END,tipzh,tipen,'',validatacheckbutton,relatedtable,sequence from ld_validatasave where id = var_validataid;
				SELECT MAX(id) into @max_mainid from ld_validatasavemain;

				UPDATE ld_validatasave SET conditiongroupid = 1,validatasavemainid = @max_mainid where id = var_validataid;
				Fetch cur1 into var_validataid;
	end while loop1;
	close cur1;
end ||
delimiter;

call update_validatarule();
drop PROCEDURE if EXISTS update_validatarule;
delimiter;

SET @labelbol = 'BLOCKEDAFTERPROMPT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'验证提示后是否阻断操作','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Verify whether the operation is blocked after the prompt','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENTDOCUMENTFIELDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前单据的字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Fields of the current document','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'ONLYDOCUMENTHEADERFIELD';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'限单据头字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'only the document header field','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CURRENTDOCUMENTID';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前单据的ID','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'ID of the current document','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NOVALUEWHENCREATING';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增时没有值','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'no value when creating','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'LINENUMBERMESSAGE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'提示信息中分录行号','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Entry line number in prompt message','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'QUERYRESULTRENAMED';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'SQL查询结果需要重命名为tmp_value','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The SQL query result needs to be renamed as tmp_value','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'INSTRUCTIONSWILDCARDCHARACTERS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'SQL通配符使用说明','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The instructions for SQL Wildcard Characters','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DOCUMENTFIELDS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单据字段','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Document fields','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'FIXEDTMP';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'固定%s','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Fixed %s','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'NUMERICALVALUE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'数值','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'numerical value','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'SQLQUERY';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'SQL查询','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'SQL Query','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET keywords=null,keyword_sseq=null WHERE tablename='ld_articles' AND columnname='tag';
delimiter;
-- 2023-01-29

CALL AddColumn('ld_customform45','triggercount','INT','19',0);
delimiter;

UPDATE ld_producttoolfield SET defaultcolumn=1  WHERE columnname IN ('entitytype','entitytypeid');

SET @labelbol='Hyperlink';
SET @labeltype='fixedstr';
SET @zh='单据超链';
SET @en='Hyperlink';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@labelbol AND labeltype=@labeltype);
delimiter;
-- 2023-01-30

UPDATE ld_desk SET fieldlabel='变更公海' WHERE labelbol='Transfer' AND languagetype='zh' AND fieldlabel='转换公海';
UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'转换公海','变更公海') WHERE labelbol IN ('EXTENDPUBLICCUSTOMER','TOTHEHIGNSEASCUSTOMERERROR1','AllowmembersTransfer') AND fieldlabel LIKE '%转换公海%';
UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'转公海','变更公海') WHERE labelbol IN ('CONVERTEDHIGHSEASCUST','TURNHIGHSEAS','TransferToCommonCustomerError','TransferToCommonCustomerError1','TransferToCommonLeadsError','TransferToCommonLeadsError1') AND fieldlabel LIKE '%转公海%';
delimiter;

CALL AddColumn('ld_potential','triggercount','INT','19',0);
delimiter;

UPDATE ld_desk SET fieldlabel = '3、The option value of "group field" is "primary classification", and the option value of the lower level "cascade field" tree node of "group field" is "sub classification";' where labelbol = 'DetailedDescriptionTree3' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

SET @labelbol = 'ClearCache';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'清除缓存','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Clear Cache','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'SystemSettings';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'系统设置','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'System Settings','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'SystemSettingsCacheDesc';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'包含系统参数，数据分类，页面设置等','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Including system parameters, data classification, page settings, etc','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'OpcacheCacheDesc';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'适用于打补丁或程序文件更新','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Applicable to patch or program file update','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'TimeSheet');
UPDATE ld_tabdetailfield SET fieldtype = 'entitytype' where tabid = @tabid and columnname = 'entitytype';
delimiter;
-- 2023-02-03

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

UPDATE ld_version SET old_version='V8.4.8.8',current_version='V8.4.8.8',remark='V8.4.8.8-20230203',wx_version='ceshi';
delimiter;