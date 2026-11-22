update ld_field set bigtype='users' where fieldname='approveby' and ifnull(bigtype,'')='';
delimiter;

DROP FUNCTION IF EXISTS `func_changeToCapitalRMB`;
delimiter ||
CREATE FUNCTION func_changeToCapitalRMB (MONEY DECIMAL(14,2)) 
RETURNS VARCHAR(150)
BEGIN
	DECLARE RESULT VARCHAR(100) DEFAULT ''; 	
	DECLARE NUM_ROUND VARCHAR(100); 	
	DECLARE NUM_LEFT VARCHAR(100); 	
	DECLARE NUM_RIGHT VARCHAR(2); 		
	DECLARE STR1 VARCHAR(10); 	
	DECLARE STR2 VARCHAR(16); 	
	DECLARE NUM_PRE INT DEFAULT 1; 					
	DECLARE NUM_CURRENT INT; 					
	DECLARE NUM_COUNT INT DEFAULT 0; 					
	DECLARE NUM1 INT;

	SET NUM_ROUND = CONCAT(MONEY, '');
	SET STR1 = '零壹贰叁肆伍陆柒捌玖'; 
	SET STR2 = '元拾佰仟万拾佰仟亿拾佰仟万拾佰仟';
	SET NUM_LEFT = FLOOR(MONEY);
	SET NUM_RIGHT = SUBSTR(NUM_ROUND, LOCATE('.', NUM_ROUND) + 1);

	IF MONEY IS NULL THEN
		SET RESULT = NULL;
		RETURN RESULT;
	END IF;

	IF LENGTH(NUM_LEFT) >= 8 THEN 
		SET NUM1 = CAST(SUBSTR(NUM_LEFT, -8, 4) AS SIGNED);
	ELSE 
		SET NUM1 = CAST(SUBSTR(NUM_LEFT, -LENGTH(NUM_LEFT), LENGTH(NUM_LEFT) - 4) AS SIGNED);
	END IF;

	IF LENGTH(NUM_LEFT) > 16 THEN 
		SET RESULT = '**********';
		RETURN RESULT;
	END IF;

	IF LENGTH(NUM_RIGHT) = 2 THEN
		IF CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) = 0 THEN
			SET RESULT = CONCAT('零', SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 2, 1) AS SIGNED) + 1, 1), '分');
		ELSE
			SET RESULT = CONCAT(SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) + 1, 1), '角', SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 2, 1) AS SIGNED) + 1, 1), '分');
		END IF;
	ELSE 
		IF LENGTH(NUM_RIGHT) = 1 THEN
			SET RESULT = CONCAT(SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) + 1, 1), '角整');
		ELSE
			SET RESULT = '整';
		END IF;
	END IF;

	myloop: LOOP
		SET NUM_COUNT = NUM_COUNT + 1; 
		IF LENGTH(NUM_LEFT) - NUM_COUNT + 1 > 0 THEN
			SET NUM_CURRENT = CAST(SUBSTR(NUM_LEFT, LENGTH(NUM_LEFT) - NUM_COUNT + 1, 1) AS SIGNED);
		ELSE
			SET NUM_CURRENT = 0;
		END IF;

		IF NUM_CURRENT > 0 THEN 
			SET RESULT = CONCAT(SUBSTR(STR1, NUM_CURRENT + 1, 1), SUBSTR(STR2, NUM_COUNT, 1), RESULT);
		ELSE
			IF NUM_COUNT = 5 THEN
				IF MOD(NUM_COUNT - 1, 4) = 0 AND NUM1 <> 0 THEN 
					SET RESULT = CONCAT(SUBSTR(STR2, NUM_COUNT, 1), RESULT); 
					SET NUM_PRE = 0;
				END IF;
			ELSE
				IF MOD(NUM_COUNT - 1, 4) = 0 THEN 
					SET RESULT = CONCAT(SUBSTR(STR2, NUM_COUNT, 1), RESULT); 
					SET NUM_PRE = 0; 
				END IF;
			END IF;

			IF NUM_PRE > 0 OR LENGTH(NUM_LEFT) = 1 THEN
				SET RESULT = CONCAT(SUBSTR(STR1, NUM_CURRENT + 1, 1), RESULT);
			END IF;
		END IF;

		SET NUM_PRE = NUM_CURRENT;
		IF NUM_COUNT >= LENGTH(NUM_LEFT) THEN 
			LEAVE myloop;
		END IF;
	END LOOP myloop; 

	IF MONEY < 0 THEN
		SET RESULT = CONCAT('负', RESULT);
	END IF;

	SET RESULT = REPLACE(RESULT, '零零分', '整');
	SET RESULT = REPLACE(RESULT, '零分', '整');
	SET RESULT = REPLACE(RESULT, '元整', '元整');
	RETURN RESULT;
END ||
delimiter;
-- 2024-08-30

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

UPDATE ld_version SET old_version='V8.6.3.3.10',current_version='V8.6.3.3.10',remark='V8.6.3.3.10-20240830',wx_version='V8.6.4.0';
delimiter;