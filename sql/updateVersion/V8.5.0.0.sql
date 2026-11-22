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

DROP FUNCTION IF EXISTS `func_account_repeatinfo`;
delimiter ||
CREATE FUNCTION `func_account_repeatinfo`(in_account TEXT,in_tiptype VARCHAR(10)) RETURNS TEXT
BEGIN  

	SET @thishalf_accountname=func_changeToHalfAngle(in_account);

	IF in_tiptype='en' THEN
		SET @this_tips=(
			SELECT
				GROUP_CONCAT(tips SEPARATOR '<br>') AS tips
			FROM (
				SELECT
					CONCAT(
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='accountname') AND languagetype='en' AND trantable='ld_field' LIMIT 1),
						'『',
						a.accountname,
						'』 already exists, The ',
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='smownerid') AND languagetype='en' AND trantable='ld_field' LIMIT 1),
						'『',
						b.last_name,
						'』'
					) AS tips
				FROM ld_account a
				LEFT JOIN ld_users b ON b.id=a.smownerid  
				WHERE a.deleted=0 
					AND a.accountname_halfangle=@thishalf_accountname
					GROUP BY a.accountname,a.smownerid
			) a
		);
	ELSE
		SET @this_tips=(
			SELECT
				GROUP_CONCAT(tips SEPARATOR '<br>') AS tips
			FROM (
				SELECT
					CONCAT(
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='accountname') AND languagetype='zh' AND trantable='ld_field' LIMIT 1),
						'『',
						a.accountname,
						'』已存在，当前',
						(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=(SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='smownerid') AND languagetype='zh' AND trantable='ld_field' LIMIT 1),
						'『',
						b.last_name,
						'』'
					) AS tips
				FROM ld_account a
				LEFT JOIN ld_users b ON b.id=a.smownerid  
				WHERE a.deleted=0 
					AND a.accountname_halfangle=@thishalf_accountname
					GROUP BY a.accountname,a.smownerid
			) a
		);
	END IF;

	RETURN(@this_tips);

END || 
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0504_1`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_customform0504_1`(
)
BEGIN
DECLARE i int DEFAULT 161;
WHILE i<=180 DO

SET @tablename=(SELECT tablename FROM ld_field WHERE tablename=CONCAT('ld_customform',i) and columnname='smownerid' LIMIT 1);

CALl AddColumn(@tablename,'source_list','varchar','500','');
CALl AddColumn(@tablename,'entitytype','varchar','50','');
CALl AddColumn(@tablename,'pricebooksid','INT','19',0);
CALL AddColumn(@tablename,'advance_stage','varchar','100','');
CALL AddColumn(@tablename,'team_memberid','text','','');
CALL AddColumn(@tablename,'kis_id','varchar','200','');
CALL AddColumn(@tablename,'kis_no','varchar','200','');
CALL AddColumn(@tablename,'exchtime','datetime','','');
CALL AddColumn(@tablename,'exchmsg','text','','');
CALL AddColumn(@tablename,'latestpushtime','datetime','','');
CALL AddColumn(@tablename,'received_amount','decimal','25,8','');
CALL AddColumn(@tablename,'receivable_balance','decimal','25,8','');
CALL AddColumn(@tablename,'pay_amount','decimal','25,8','');
CALL AddColumn(@tablename,'pay_balance','decimal','25,8','');
CALL AddColumn(@tablename,'triggercount','INT','19',0);

SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_complete_customform0504_1();
DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0504_1`;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0504_2`;
delimiter ||
CREATE PROCEDURE `ldcrm_complete_customform0504_2`(
)
BEGIN
DECLARE i int DEFAULT 181;
WHILE i<=200 DO

SET @tablename=(SELECT tablename FROM ld_field WHERE tablename=CONCAT('ld_customform',i) and columnname='smownerid' LIMIT 1);

CALl AddColumn(@tablename,'source_list','varchar','500','');
CALl AddColumn(@tablename,'entitytype','varchar','50','');
CALL AddColumn(@tablename,'advance_stage','varchar','100','');
CALL AddColumn(@tablename,'team_memberid','text','','');
CALL AddColumn(@tablename,'kis_id','varchar','200','');
CALL AddColumn(@tablename,'kis_no','varchar','200','');
CALL AddColumn(@tablename,'exchtime','datetime','','');
CALL AddColumn(@tablename,'exchmsg','text','','');
CALL AddColumn(@tablename,'latestpushtime','datetime','','');
CALL AddColumn(@tablename,'triggercount','INT','19',0);

SET i=i+1;
END WHILE;

end ||
delimiter;
CALL ldcrm_complete_customform0504_2();
DROP PROCEDURE IF EXISTS `ldcrm_complete_customform0504_2`;
delimiter;

UPDATE ld_tab SET presence=5 WHERE presence=0 AND tabid BETWEEN 258 AND 357 AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>5);
-- 2023-05-06

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

UPDATE ld_version SET old_version='V8.5.0.0',current_version='V8.5.0.0',remark='V8.5.0.0-20230506',wx_version='V8.5.0.0';
delimiter;