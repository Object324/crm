SET @disable_triggers=1;
ALTER TABLE ld_account MODIFY COLUMN lastcontactdate DATETIME;
UPDATE ld_field SET uitype=86,typeofdata='DT~O' WHERE tabid=6 AND columnname='lastcontactdate';

UPDATE ld_account a
INNER JOIN (
	SELECT
		accountid,
		MAX(contactdate) AS contactdate
	FROM ld_contactrecords
	WHERE deleted=0
		AND accountid>0
		AND approvestatus<>'已拒绝'
	GROUP BY accountid
) b ON b.accountid=a.accountid
SET a.lastcontactdate=contactdate;

DROP PROCEDURE IF EXISTS `lingdang_resetdemo_20200526`;
delimiter ||
CREATE  PROCEDURE `lingdang_resetdemo_20200526`(
)
BEGIN
	
	SET @ld_module='Potentials';
	SET @ld_tabid=2;
	SET @ld_columnname='sales_stage';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='Quotes';
	SET @ld_tabid=20;
	SET @ld_columnname='quotestage';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='SalesOrder';
	SET @ld_tabid=22;
	SET @ld_columnname='sostatus';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='ServiceContracts';
	SET @ld_tabid=37;
	SET @ld_columnname='contract_status';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='HelpDesk';
	SET @ld_tabid=13;
	SET @ld_columnname='ticketstatus';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='Project';
	SET @ld_tabid=48;
	SET @ld_columnname='progress';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='PaymentPlan';
	SET @ld_tabid=(SELECT tabid FROM ld_tab WHERE name=@ld_module);
	SET @ld_columnname='paymentstatus';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;


	SET @ld_module='SendPayment';
	SET @ld_tabid=(SELECT tabid FROM ld_tab WHERE name=@ld_module);
	SET @ld_columnname='cpstatus';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;

	SET @ld_module='PurchaseOrder';
	SET @ld_tabid=(SELECT tabid FROM ld_tab WHERE name=@ld_module);
	SET @ld_columnname='postatus';
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@ld_tabid AND columnname=@ld_columnname AND presence<>1) THEN
		IF NOT EXISTS (SELECT 1 FROM ld_settings_advance WHERE tabid=@ld_tabid) THEN
			INSERT INTO ld_settings_advance(tabid,module,`enable`,method,module_field,showadvancelog,showadvancemobile)
			SELECT @ld_tabid,@ld_module,'yes','field',@ld_columnname,'yes','yes';
		END IF;
	END IF;

end ||
delimiter;

CALL lingdang_resetdemo_20200526();
DROP PROCEDURE IF EXISTS `lingdang_resetdemo_20200526`;

SET GLOBAL log_bin_trust_function_creators=1;

DROP FUNCTION IF EXISTS `func_changeToCapitalRMB`;
delimiter ||
CREATE  FUNCTION `func_changeToCapitalRMB`(MONEY decimal(14,2)) RETURNS varchar(150) CHARSET utf8
BEGIN

	DECLARE  RESULT      VARCHAR(100); 	-- 返回字符串
	DECLARE  NUM_ROUND   VARCHAR(100); 	-- 转换数字为小数点后2位的字符(正数)
	DECLARE  NUM_LEFT    VARCHAR(100); 	-- 小数点左边的数字
	DECLARE  NUM_RIGHT   VARCHAR(2); 		-- 小数点右边的数字
	DECLARE  STR1        VARCHAR(10); 	-- 数字大写
	DECLARE  STR2        VARCHAR(16); 	-- 数字位数(从低至高)
	DECLARE  NUM_PRE     INT; 					-- 前一位上的数字
	DECLARE  NUM_CURRENT INT; 					-- 当前位上的数字
	DECLARE  NUM_COUNT   INT; 					-- 当前数字位数
	DECLARE  NUM1        INT;

	SET NUM_ROUND=CONCAT(MONEY, '');
	SET STR1='零壹贰叁肆伍陆柒捌玖'; 
	SET STR2='圆拾佰仟万拾佰仟亿拾佰仟万拾佰仟';
	SET NUM_PRE=1;
	SET NUM_COUNT=0;
	SET NUM_LEFT=FLOOR(MONEY);
	SET NUM_RIGHT=REPLACE(NUM_ROUND,CONCAT(NUM_LEFT,'.'),'');


	-- 转换数字为 NULL 时返回 NULL
	IF MONEY IS NULL THEN
		SET RESULT=NULL;
	END IF; 	

	IF LENGTH(NUM_LEFT)>=8 THEN 
		SET NUM1=CAST(SUBSTR(NUM_LEFT, -8, 4) AS SIGNED);
	ELSE 
		SET NUM1=CAST(SUBSTR(NUM_LEFT, -LENGTH(NUM_LEFT), LENGTH(NUM_LEFT) - 4) AS SIGNED);
	END IF;

	-- 数字整数部分超过16位时
	IF LENGTH(NUM_LEFT) > 16 THEN 
		SET RESULT='**********';
	END IF; 


	-- 采用从低至高的算法，先处理小数点右边的数字
	IF LENGTH(NUM_RIGHT) = 2 THEN
		 IF CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) = 0 THEN
				SET RESULT = CONCAT('零',SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 2, 1) AS SIGNED) + 1, 1) , '分');
		 ELSE
				SET RESULT = CONCAT(SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) + 1, 1) , '角',SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 2, 1) AS SIGNED) + 1, 1) , '分');
		 END IF;
	ELSE 
		 IF LENGTH(NUM_RIGHT) = 1 THEN
				SET RESULT = CONCAT(SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) + 1, 1) , '角整');
		 ELSE
				SET RESULT = '整';
		 END IF;
	END IF;

	-- 再处理小数点左边的数字
	myloop:LOOP
		SET NUM_COUNT=NUM_COUNT+1; -- 当前数字位数
		SET NUM_CURRENT=CAST(SUBSTR(NUM_LEFT, LENGTH(NUM_LEFT)-NUM_COUNT+1, 1) AS SIGNED);

		IF  NUM_CURRENT > 0 THEN 
			SET RESULT=CONCAT(SUBSTR(STR1,NUM_CURRENT + 1, 1),SUBSTR(STR2, NUM_COUNT, 1),RESULT);
		ELSE
			IF NUM_COUNT = 5 THEN
				IF MOD(NUM_COUNT - 1, 4) = 0 AND NUM1 <> 0 THEN 
					SET RESULT = CONCAT(SUBSTR(STR2, NUM_COUNT, 1) , RESULT); 
					SET NUM_PRE = 0;
				END IF;
			ELSE
				IF MOD(NUM_COUNT - 1, 4) = 0 THEN 
					-- 元、万,亿前不准加零
					SET RESULT  = CONCAT(SUBSTR(STR2, NUM_COUNT, 1) , RESULT); 
					SET  NUM_PRE = 0; 
				END IF;
			END IF;

			IF NUM_PRE > 0 OR LENGTH(NUM_LEFT) = 1 THEN
				-- 上一位数字不为0或只有个位时
				SET RESULT = CONCAT(SUBSTR(STR1, NUM_CURRENT + 1, 1) , RESULT);
			END IF;
		END IF;

		SET NUM_PRE = NUM_CURRENT;
		IF NUM_COUNT>=LENGTH(NUM_LEFT) THEN 
			LEAVE myloop;
		END IF;
	END LOOP myloop; 

	IF MONEY < 0 THEN
		-- 转换数字是负数时
		SET RESULT =CONCAT( '负' , RESULT);
	END IF;
		SET RESULT=REPLACE(RESULT,'零零分','整');
		SET RESULT=REPLACE(RESULT,'零分','整');
		SET RESULT=REPLACE(RESULT,'元整','圆整');
	RETURN RESULT;

end ||
delimiter;
-- 2020-05-26

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

UPDATE ld_version SET old_version='V8.0.1',current_version='V8.0.1',remark='V8.0.1-20200526',wx_version='V8.0.1.5';
delimiter;