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

DROP PROCEDURE IF EXISTS `reset_newdemo_20200609`;
delimiter ||
CREATE  PROCEDURE `reset_newdemo_20200609`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT templateid FROM ld_templates;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	DELETE FROM ld_templatesstuff;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (35, tmp_id, 'saleskit', '0', 'saleskit', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (19, tmp_id, 'chart', '1', 'SALESFUNNEL', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (34, tmp_id, 'transaction', '2', 'transaction', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (20, tmp_id, 'default', '3', 'CRITICALVIEW', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (33, tmp_id, 'transaction', '4', 'SALESCHARTS', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (1, tmp_id, 'chart', '5', 'SALESSIXMONTH', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (9, tmp_id, 'chart', '6', 'INDIVIDUALSIXMONTH', '0');
		INSERT INTO ld_templatesstuff(`stuffid`, `templateid`, `stufftype`, `stuffsequence`, `stufftitle`, `presence`) VALUES (13, tmp_id, 'default', '7', 'TODAYCONTACTCUSTOMER', '0');
				
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;
	
	IF (SELECT COUNT(1) FROM ld_account)<=1 THEN
		UPDATE ld_homestuffdetail SET presence='no';
		UPDATE ld_homestuffdetail SET presence='yes' WHERE stufflabel IN ('NewContacts','NewSignCount','SignContractAmount','NewInvoiceAmount',
			'NewCashBillAmount','NewOutboundOrderAmount','NewAccounts','NewContactRecords','NewPotentialsCount','NewPotentialsAmount');

		SET @i=0;
		SET @j=0;
		UPDATE ld_homestuffdetail SET sequence=sequence+100;
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='SignContractAmount' AND compute_columns='ld_salesorder.total';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='SignContractAmount' AND compute_columns='ld_servicecontracts.total';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewInvoiceAmount';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewCashBillAmount';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewOutboundOrderAmount';

		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewAccounts';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewContactRecords';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewPotentialsCount';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewPotentialsAmount';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewContacts';
		UPDATE ld_homestuffdetail SET sequence=(@i:=@i+1) WHERE stufflabel='NewSignCount';

		UPDATE ld_homestuffdetail SET sequence=(@j:=@j+1) ORDER BY sequence;

	END IF;
	
END ||
delimiter;

CALL reset_newdemo_20200609();
DROP PROCEDURE IF EXISTS `reset_newdemo_20200609`;
-- 2020-06-09

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','smailllogname','小LOGO名称','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='smailllogname' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','smailllogname','Small LOGO name','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='smailllogname' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','selectsmalllogo','选择小Logo','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='selectsmalllogo' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','selectsmalllogo','Select Small Logo','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='selectsmalllogo' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','suggestedsize','建议尺寸大小为：36*36（像素）','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='suggestedsize' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','suggestedsize','Suggested size:36*36(pixel)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='suggestedsize' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_organizationdetails','small_logoname','varchar','255',null);
delimiter;

update ld_organizationdetails set small_logoname = logoname where small_logoname is NULL;
delimiter;
-- 2016-06-10

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

UPDATE ld_version SET old_version='V8.0.6',current_version='V8.0.6',remark='V8.0.6-20200610',wx_version='V8.0.5';
delimiter;