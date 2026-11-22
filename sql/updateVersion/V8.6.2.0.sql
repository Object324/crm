DROP FUNCTION IF EXISTS `func_changeToCapitalRMB`;
delimiter ||
CREATE  FUNCTION `func_changeToCapitalRMB`(MONEY decimal(14,2)) RETURNS varchar(150) CHARSET utf8
BEGIN

	DECLARE  RESULT      VARCHAR(100); 	
	DECLARE  NUM_ROUND   VARCHAR(100); 	
	DECLARE  NUM_LEFT    VARCHAR(100); 	
	DECLARE  NUM_RIGHT   VARCHAR(2); 		
	DECLARE  STR1        VARCHAR(10); 	
	DECLARE  STR2        VARCHAR(16); 	
	DECLARE  NUM_PRE     INT; 					
	DECLARE  NUM_CURRENT INT; 					
	DECLARE  NUM_COUNT   INT; 					
	DECLARE  NUM1        INT;

	SET NUM_ROUND=CONCAT(MONEY, '');
	SET STR1='零壹贰叁肆伍陆柒捌玖'; 
	SET STR2='元拾佰仟万拾佰仟亿拾佰仟万拾佰仟';
	SET NUM_PRE=1;
	SET NUM_COUNT=0;
	SET NUM_LEFT=FLOOR(MONEY);
	SET NUM_RIGHT=REPLACE(NUM_ROUND,CONCAT(NUM_LEFT,'.'),'');


	
	IF MONEY IS NULL THEN
		SET RESULT=NULL;
	END IF; 	

	IF LENGTH(NUM_LEFT)>=8 THEN 
		SET NUM1=CAST(SUBSTR(NUM_LEFT, -8, 4) AS SIGNED);
	ELSE 
		SET NUM1=CAST(SUBSTR(NUM_LEFT, -LENGTH(NUM_LEFT), LENGTH(NUM_LEFT) - 4) AS SIGNED);
	END IF;

	
	IF LENGTH(NUM_LEFT) > 16 THEN 
		SET RESULT='**********';
	END IF; 


	
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

	
	myloop:LOOP
		SET NUM_COUNT=NUM_COUNT+1; 
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
					
					SET RESULT  = CONCAT(SUBSTR(STR2, NUM_COUNT, 1) , RESULT); 
					SET  NUM_PRE = 0; 
				END IF;
			END IF;

			IF NUM_PRE > 0 OR LENGTH(NUM_LEFT) = 1 THEN
				
				SET RESULT = CONCAT(SUBSTR(STR1, NUM_CURRENT + 1, 1) , RESULT);
			END IF;
		END IF;

		SET NUM_PRE = NUM_CURRENT;
		IF NUM_COUNT>=LENGTH(NUM_LEFT) THEN 
			LEAVE myloop;
		END IF;
	END LOOP myloop; 

	IF MONEY < 0 THEN
		
		SET RESULT =CONCAT( '负' , RESULT);
	END IF;
		SET RESULT=REPLACE(RESULT,'零零分','整');
		SET RESULT=REPLACE(RESULT,'零分','整');
		SET RESULT=REPLACE(RESULT,'元整','元整');
	RETURN RESULT;

end ||
delimiter;


CALL AddColumn('ld_users','fanwei_userid','varchar','100','');
delimiter;

SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='user_name' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='user_name' LIMIT 1);
SET @columnname='fanwei_userid';
SET @fieldname='fanwei_userid';
SET @zh='泛微通讯录账号';
SET @en='fanwei userid';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='text';
SET @datarang='all';
SET @maxrowsshow=0;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,0,NULL,1,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,'yes','yes','yes','yes' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

ALTER TABLE ld_users MODIFY COLUMN fanwei_userid varchar(100) AFTER yunzhijia_wbuserid;
delimiter;

update ld_picklist_presetcolor set color='#C00000' where type='preset' and sequence=1;
update ld_picklist_presetcolor set color='#FFFF00' where type='preset' and sequence=2;
update ld_picklist_presetcolor set color='#9ADFBF' where type='preset' and sequence=3;
update ld_picklist_presetcolor set color='#00B0F0' where type='preset' and sequence=4;
update ld_picklist_presetcolor set color='#A6A6A6' where type='preset' and sequence=5;
delimiter;

update ld_picklist_presetcolor set color='#FF0000' where type='preset' and sequence=6;
update ld_picklist_presetcolor set color='#FFD699' where type='preset' and sequence=7;
update ld_picklist_presetcolor set color='#92D050' where type='preset' and sequence=8;
update ld_picklist_presetcolor set color='#58B6E5' where type='preset' and sequence=9;
update ld_picklist_presetcolor set color='#7F7F7F' where type='preset' and sequence=10;
delimiter;

update ld_picklist_presetcolor set color='#EC5F74' where type='preset' and sequence=11;
update ld_picklist_presetcolor set color='#FFC000' where type='preset' and sequence=12;
update ld_picklist_presetcolor set color='#00B050' where type='preset' and sequence=13;
update ld_picklist_presetcolor set color='#6096E6' where type='preset' and sequence=14;
update ld_picklist_presetcolor set color='#002060' where type='preset' and sequence=15;
delimiter;

update ld_picklist_presetcolor set color='#F18870' where type='preset' and sequence=16;
update ld_picklist_presetcolor set color='#FFBA55' where type='preset' and sequence=17;
update ld_picklist_presetcolor set color='#56CA95' where type='preset' and sequence=18;
update ld_picklist_presetcolor set color='#0070C0' where type='preset' and sequence=19;
update ld_picklist_presetcolor set color='#000000' where type='preset' and sequence=20;
delimiter;
-- 2023-12-26

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

UPDATE ld_version SET old_version='V8.6.2.0',current_version='V8.6.2.0',remark='V8.6.2.0-20231226',wx_version='V8.6.2.0';
delimiter;