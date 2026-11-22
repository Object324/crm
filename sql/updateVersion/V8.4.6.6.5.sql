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

DROP PROCEDURE IF EXISTS insert_tmp_date;
delimiter ||
CREATE  PROCEDURE insert_tmp_date(
)
BEGIN

	DECLARE tmpdate date default NULL;

	SET @cnt=0;
	SET @maxdate=(SELECT IFNULL(max(date),CURDATE()) FROM tmp_date);
	SET @mindate=(
		SELECT
			DATE_SUB(IFNULL(MIN(mindate),CURDATE()),INTERVAL 1 YEAR) 
		FROM (
				SELECT MIN(cashbilldate) AS mindate FROM ld_cashbill
				UNION
				SELECT DATE_FORMAT(MIN(createdtime),'%Y-%m-%d') AS mindate FROM ld_cashbill
				UNION
				SELECT MIN(signed_data) AS mindate FROM ld_salesorder
				UNION
				SELECT DATE_FORMAT(MIN(createdtime),'%Y-%m-%d') AS mindate FROM ld_salesorder
				UNION 
				SELECT MIN(due_date) AS mindate FROM ld_servicecontracts
				UNION
				SELECT DATE_FORMAT(MIN(createdtime),'%Y-%m-%d') AS mindate FROM ld_salesorder
			) a
		);
	SET @enddate=(SELECT CONCAT(YEAR(NOW())+1,'-12-31'));

	SET @cnt=(SELECT COUNT(1) FROM tmp_date);

	IF @cnt=0 THEN
		SET tmpdate=@mindate;
	ELSE
		SET tmpdate=DATE_ADD(@maxdate,INTERVAL 1 DAY);
	END IF;

	WHILE tmpdate<=@enddate DO
			INSERT INTO tmp_date(date) SELECT tmpdate;
			set tmpdate=DATE_ADD(tmpdate,INTERVAL 1 DAY);
	end while;

END ||
delimiter;

CALL insert_tmp_date;
delimiter;

DROP EVENT IF EXISTS insert_tmp_date;
delimiter ||
CREATE EVENT insert_tmp_date ON SCHEDULE EVERY 1 DAY STARTS '2016-10-14 00:30:00' ON COMPLETION NOT PRESERVE ENABLE DO 
CALL insert_tmp_date()
||
delimiter;
-- 2022-06-27

CALl AddColumn('ld_producttoolfield','effectivecondition','TEXT','','');
CALl AddColumn('ld_tabdetailfield','effectivecondition','TEXT','','');
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

UPDATE ld_version SET old_version='V8.4.6.6.5',current_version='V8.4.6.6.5',remark='V8.4.6.6.5-20220627',wx_version='V8.4.6.6.4';
delimiter;