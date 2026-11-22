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

DROP PROCEDURE IF EXISTS `AddPrimaryKey`;
delimiter ||
CREATE  PROCEDURE `AddPrimaryKey`(
	tmp_tablename varchar(100),
	tmp_prikeyname varchar(100)
)
BEGIN
 

	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND CONSTRAINT_NAME='PRIMARY' AND TABLE_NAME=tmp_tablename) THEN
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` DROP PRIMARY KEY,ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	ELSE
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `DelColumn`;
delimiter ||
CREATE  PROCEDURE `DelColumn`(
	tablename varchar(50),
	columnname varchar(50)
)
begin

	select database() into @tableschema;

	set tablename=lower(tablename);
	set @colName='';
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

	prepare stmt from @tsql;
	execute stmt;

	set @coldel=IFNULL(@colName,'-1');

	IF @coldel <> '-1'  and  @coldel=columnname THEN

		set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);
		prepare stalter from @altercolumn;
		execute stalter;
		deallocate prepare stalter;
	END IF;

	deallocate prepare stmt;

end ||
delimiter;

SET GLOBAL group_concat_max_len = 1024000;
SET GLOBAL table_open_cache=16384;
SET GLOBAL table_definition_cache=16384;

DROP PROCEDURE IF EXISTS `ldcrm_add_primarykey_detailscf_20190701`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_primarykey_detailscf_20190701`(
)
BEGIN

	DECLARE mytmp_tablename VARCHAR(100) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
				SELECT 
					TABLE_NAME
				FROM information_schema.COLUMNS
				WHERE TABLE_SCHEMA = DATABASE()
					AND COLUMN_NAME='lineitem_id'
					AND TABLE_NAME LIKE '%detailscf'
					AND COLUMN_KEY<>'PRI'
				ORDER BY TABLE_NAME;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET mytmp_tablename = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO mytmp_tablename;
	WHILE(mytmp_tablename IS NOT NULL) DO
		SET @mytmp_tablename=mytmp_tablename;

		SET @sql_tmptable=CONCAT('SELECT COUNT(lineitem_id) INTO @cnt_tmptable FROM (SELECT lineitem_id FROM ',@mytmp_tablename, ' GROUP BY lineitem_id HAVING COUNT(lineitem_id)>1) tmp');
		PREPARE stmt_tmptable FROM @sql_tmptable;
		EXECUTE stmt_tmptable;
		DEALLOCATE PREPARE stmt_tmptable;

		IF @cnt_tmptable>=1 THEN
			CALl AddColumn(@mytmp_tablename,'cf_seq','INT','19',0);

			SET @x=0;
			SET @sql_tmptable1=CONCAT('UPDATE ',@mytmp_tablename, ' SET cf_seq=(@x:=@x+1)');
			PREPARE stmt_tmptable1 FROM @sql_tmptable1;
			EXECUTE stmt_tmptable1;
			DEALLOCATE PREPARE stmt_tmptable1;


			SET @mytmp_lineitem_id=0;
			SET @sql_tmptable2=CONCAT('SELECT GROUP_CONCAT(lineitem_id) INTO @mytmp_lineitem_id FROM (SELECT lineitem_id FROM ',@mytmp_tablename, ' GROUP BY lineitem_id HAVING COUNT(lineitem_id)>1) tmp');
			PREPARE stmt_tmptable2 FROM @sql_tmptable2;
			EXECUTE stmt_tmptable2;
			DEALLOCATE PREPARE stmt_tmptable2;

			
			SET @mytmp_maxid=0;
			SET @sql_tmptable3=CONCAT('SELECT  GROUP_CONCAT(maxid) INTO @mytmp_maxid FROM (SELECT MAX(cf_seq) AS maxid FROM ',@mytmp_tablename, ' GROUP BY lineitem_id HAVING COUNT(lineitem_id)>1) tmp');
			PREPARE stmt_tmptable3 FROM @sql_tmptable3;
			EXECUTE stmt_tmptable3;
			DEALLOCATE PREPARE stmt_tmptable3;

			SET @sql_tmptable4=CONCAT('DELETE FROM ',@mytmp_tablename, ' WHERE lineitem_id IN (',@mytmp_lineitem_id,') AND cf_seq NOT IN (',@mytmp_maxid,')');
			PREPARE stmt_tmptable4 FROM @sql_tmptable4;
			EXECUTE stmt_tmptable4;
			DEALLOCATE PREPARE stmt_tmptable4;

			CALL AddPrimaryKey(@mytmp_tablename,'lineitem_id');
			CALL DelColumn(@mytmp_tablename,'cf_seq');
		ELSE
			CALL AddPrimaryKey(@mytmp_tablename,'lineitem_id');
		END IF;

		FETCH MYCUSOR INTO mytmp_tablename;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_add_primarykey_detailscf_20190701();
DROP PROCEDURE IF EXISTS `ldcrm_add_primarykey_detailscf_20190701`;

call AddPrimaryKey('ld_commissionscf','commission_id');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_primarykey_commission2paymentscf_20190702`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_primarykey_commission2paymentscf_20190702`(
)
BEGIN

	DELETE FROM ld_commission2paymentscf WHERE commission2payment_id=0;

	IF EXISTS (SELECT 1 FROM ld_commission2paymentscf GROUP BY commission2payment_id HAVING COUNT(commission2payment_id)>1) THEN
		CALl AddColumn('ld_commission2paymentscf','cf_seq','INT','19',0);

		SET @y=0;
		UPDATE ld_commission2paymentscf SET cf_seq=(@y:=@y+1);

		SET @exists_lineitem_id=(SELECT GROUP_CONCAT(lineitem_id) FROM (SELECT commission2payment_id AS lineitem_id FROM ld_commission2paymentscf GROUP BY commission2payment_id HAVING COUNT(commission2payment_id)>1) tmp);
		SET @exists_maxid=(SELECT GROUP_CONCAT(maxid) FROM (SELECT MAX(cf_seq) AS maxid FROM ld_commission2paymentscf GROUP BY commission2payment_id HAVING COUNT(commission2payment_id)>1) tmp);
		
		
		SET @sql_tmptable4=CONCAT('DELETE FROM ld_commission2paymentscf WHERE commission2payment_id IN (',@exists_lineitem_id,') AND cf_seq NOT IN (',@exists_maxid,')');
		PREPARE stmt_tmptable4 FROM @sql_tmptable4;
		EXECUTE stmt_tmptable4;
		DEALLOCATE PREPARE stmt_tmptable4;

		CALL AddPrimaryKey('ld_commission2paymentscf','commission2payment_id');
		CALL DelColumn('ld_commission2paymentscf','cf_seq');

	ELSE
		CALL AddPrimaryKey('ld_commission2paymentscf','commission2payment_id');
	END IF;

end ||
delimiter;

CALL ldcrm_add_primarykey_commission2paymentscf_20190702();
DROP PROCEDURE IF EXISTS `ldcrm_add_primarykey_commission2paymentscf_20190702`;

update ld_desk set fieldlabel='正在导出数据，请不要关闭或刷新浏览器' where labelbol='EXPORTINGDATA' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Exporting data, please do not close or refresh the browser' where labelbol='EXPORTINGDATA' and Labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_relatedlists set actions='add' where tabid in(select tabid from ld_tab where name='ServiceContracts') and name='get_paymentplan';

UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'V~0','V~O');
UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'~o','~O');
-- 2019-07-01

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

UPDATE ld_version SET old_version='V7.8.1',current_version='V7.8.1',remark='V7.8.1-20190701',wx_version='V7.7.9';
delimiter;