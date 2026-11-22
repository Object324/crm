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


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SyncSMSTemplate','同步短信模板','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SyncSMSTemplate' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SyncSMSTemplate',"Synchronous SMS template",'fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SyncSMSTemplate' and labeltype='fixedstr');
delimiter;


CALL AddColumn('ld_productbom', 'approvestatus', 'varchar', '200', null);
delimiter;
-- 2024-12-13

SET @labelbol = 'SET_SUBORDINATE_VISIBLE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置客户相关信息可以看见下级单据的数据','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Set customer related information to see the data of subordinate documents','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'DEFAULTNOTSUPPORTMOBILE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'默认查询接口不支持移动端使用，请自行前往快递100购买接口','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The default enquiry interface does not support the use of mobile, please go to the Express 100 purchase interface by yourself','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
SET @labelbol = 'KUAIDI100USETIPSTHREE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'默认查询接口不支持移动端的使用','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The default query interface does not support the use of mobile devices','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CREATE TABLE if not EXISTS `ld_picklist_changelog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(19) DEFAULT NULL,
	`modulename` VARCHAR(100) DEFAULT NULL,
	`fieldname` VARCHAR(100) DEFAULT NULL,
	`prevalue` VARCHAR(100) DEFAULT NULL,
	`postvalue` VARCHAR(100) DEFAULT NULL,
	`changetype` VARCHAR(20) DEFAULT NULL,
	`picklist_valueid` int(19) DEFAULT NULL,
  `createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB; 
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','SetLoginSMSTemplate','设置登录短信验证码模板','fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='SetLoginSMSTemplate' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','SetLoginSMSTemplate',"Set the SMS verification code template",'fixedstr' from dual
where not exists(select 1 from ld_desk where  languagetype='en' and labelbol='SetLoginSMSTemplate' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='2、默认查询接口不支持移动端的使用' where labelbol='KUAIDI100USETIPSTHREE' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='2、The default query interface does not support the use of mobile devices' where labelbol='KUAIDI100USETIPSTHREE' and languagetype='en' and Labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel='3、使用自购快递100Key，会弹出对应弹窗接口。' where labelbol='KUAIDI100USETIPSTWO' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='3、When using the self-purchased express 100Key, the corresponding pop-up window interface will pop up.' where labelbol='KUAIDI100USETIPSTWO' and languagetype='en' and Labeltype='fixedstr';
delimiter;

SET @labelbol = 'CustomerIndustryStatistic';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'{$Accounts.Accounts}{$Accounts.industry}分布统计','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$Accounts.Accounts} {$Accounts.industry} Distribution Statistics','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SELECT count(1) INTO @i FROM ld_stuff WHERE stufftitle = 'CustomerIndustryStatistic';
SELECT max(mobile_sequence) INTO @max_mobile_sequence FROM ld_stuff WHERE stufftitle = 'CUSTOMERTYPEDISSTATIS';
SELECT max(pc_sequence) INTO @max_pc_sequence FROM ld_stuff WHERE stufftitle = 'CUSTOMERTYPEDISSTATIS';
UPDATE ld_stuff SET pc_sequence = pc_sequence + 1 WHERE @i = 0 AND pc_sequence > @max_pc_sequence;
UPDATE ld_stuff SET mobile_sequence = mobile_sequence + 1 WHERE @i = 0 AND mobile_sequence > @max_mobile_sequence;
delimiter;

INSERT INTO ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show,charttype,mobile_sequence,pc_sequence)
SELECT 119,'CustomerIndustryStatistic','chart','Accounts','Accounts','yes','yes','pie', 8 , 7 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_stuff WHERE stufftitle = 'CustomerIndustryStatistic' AND relatedmodule='Accounts');
delimiter;


update ld_desk set fieldlabel='统计表位置' where labelbol ='ReportLocation'  and languagetype='zh' and labeltype='jspop';
update ld_desk set fieldlabel='Location of statistical table' where labelbol ='ReportLocation'  and languagetype='en' and labeltype='jspop';
delimiter;


DROP PROCEDURE IF EXISTS `addworkreportdelete`;
delimiter ||
CREATE PROCEDURE `addworkreportdelete`(
)

BEGIN
		set @tabid = (select tabid from ld_tab where `name` = 'WorkReportList');
		set @actionid = (select actionid from ld_actionmapping where actionname = 'Delete');

		IF NOT EXISTS(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid) THEN
				set @sequence = (select sequence from ld_profileallpermission where operation = (select actionid from ld_actionmapping where actionname = 'Export') and tabid = @tabid);
update ld_profileallpermission set sequence = sequence+1 where sequence > @sequence;
insert into ld_profileallpermission(tabid,operation,sequence) VALUE(@tabid,@actionid,@sequence+1);
call AddColumn('ld_workreport','modifiedtime','datetime','','');
call AddColumn('ld_workreport','modifiedby','int',11,0);
call AddColumn('ld_workreport','smownerid','int',11,0);
update ld_workreport set smownerid = smcreatorid;
END IF;

end ||
delimiter;

CALL addworkreportdelete();
DROP PROCEDURE IF EXISTS `addworkreportdelete`;
delimiter;

update  ld_field set fieldname='deductionreceivedamount'  where
columnname ='deductionreceived_amount' and tabid in(select tabid from ld_tab where name='cashbill');
delimiter;

SET @labelbol = 'ANTIAPPROVALAUTHORITY';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'反审批权限',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Anti approval authority',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CANCELAPPROVEPROFILECOMMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'说明：赋予用户等同于管理员的反审批权限',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Explanation: Granting users the same anti approval authority as administrators',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

call AddColumn('ld_related_scope','related_scopetype','varchar','20',NULL);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_related_scope_changelog` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `modulename` varchar(50) DEFAULT NULL,
    `type` varchar(50) DEFAULT NULL,
    `viewid` int(19) NOT NULL,
    `relatedid` int(19) NOT NULL,
		`related_scopetype` varchar(20) DEFAULT NULL,
		`changemode` varchar(20) DEFAULT NULL,
		`creator` int(19) NOT NULL,
		`createdtime` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;
delimiter;

update ld_producttoolfield set bigtype = 'num' where columnname = 'discount_percent' and bigtype = 'picklist' and uitype = 15;
delimiter;
-- 2024-12-20

UPDATE ld_tabdetailfield a
LEFT JOIN ld_tranlabel b ON b.Relateid=a.tabdetailfieldid AND b.trantable='ld_tabdetailfield' AND b.languagetype='zh'
SET 
	a.fieldlabel='金额',
	b.fieldlabel='金额'
WHERE a.columnname='amount'
	AND a.tablename LIKE 'ld_customform%'
	AND b.fieldlabel='佣金';
delimiter;

DELETE FROM ld_tranlabel WHERE tabid=14 AND trantable='ld_field' AND Relateid IN (
	SELECT fieldid FROM ld_field WHERE tabid=14 AND columnname IN ('sales_start_date','sales_end_date','expiry_date','expiry_date','mfr_part_no','vendor_part_no','serial_no','manufacturer') AND presence=1
);
DELETE FROM ld_field WHERE tabid=14 AND columnname IN ('sales_start_date','sales_end_date','expiry_date','expiry_date','mfr_part_no','vendor_part_no','serial_no','manufacturer') AND presence=1;
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

UPDATE ld_version SET old_version='V8.6.5.0',current_version='V8.6.5.0',remark='V8.6.5.0-20241220',wx_version='V8.6.5.0';
delimiter;