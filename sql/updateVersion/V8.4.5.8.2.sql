SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress' LIMIT 1);
SET @tablabel=(SELECT fieldlabel FROM ld_tranlabel WHERE tabid=@tabid AND Relateid=@tabid AND languagetype='zh' AND trantable='ld_tab' LIMIT 1);
SET @filedid=(SELECT fieldid FROM ld_field WHERE tablename='ld_projectprogress' AND columnname='projectprogress_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='项目日志编号' WHERE Relateid=@filedid AND trantable='ld_field' AND languagetype='zh' AND @tablabel='项目日志';
delimiter;

UPDATE ld_desk SET fieldlabel='导入明细' WHERE labelbol='IMPORTENTRY' AND languagetype='zh';
delimiter

UPDATE ld_desk SET fieldlabel='全局快速授权' WHERE labelbol='SELECTTHESELECTEDPERMISSIONS' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='授权' WHERE labelbol='OPENMODULE' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='除权' WHERE labelbol='CLOSE' AND languagetype='zh' AND Labeltype='jspop';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_ADDTABLE_LIKETABLE`;
delimiter ||
CREATE PROCEDURE `ldcrm_ADDTABLE_LIKETABLE`(
)
BEGIN

	CREATE TABLE IF NOT EXISTS ld_reminds_accepted LIKE ld_reminds;

end ||
delimiter;

CALL ldcrm_ADDTABLE_LIKETABLE();
DROP PROCEDURE IF EXISTS `ldcrm_ADDTABLE_LIKETABLE`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_remindsdata_transfer`;
delimiter ||
CREATE PROCEDURE `ldcrm_remindsdata_transfer`(
)
BEGIN

	DECLARE tmp_dataids MEDIUMTEXT DEFAULT NULL;

	
	DECLARE REMIND_CUSOR CURSOR FOR 
		SELECT
			GROUP_CONCAT(remindsid) AS ids
		FROM (
			SELECT 
				remindsid
			FROM ld_reminds 
			WHERE date_time<DATE_SUB(CURDATE(),INTERVAL 1 MONTH)
				AND (
					status_rmd='已读' 
					OR push_to_yzj=3
					OR push_to_weixin=3 
					OR push_to_ding=3
			)
			LIMIT 1000
		) a;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_dataids = NULL;

	OPEN REMIND_CUSOR; 
	FETCH REMIND_CUSOR INTO tmp_dataids;
	WHILE(tmp_dataids IS NOT NULL) DO
		INSERT INTO ld_reminds_accepted
		SELECT * FROM ld_reminds WHERE FIND_IN_SET(remindsid,tmp_dataids);

		DELETE FROM ld_reminds WHERE FIND_IN_SET(remindsid,tmp_dataids);

		FETCH REMIND_CUSOR INTO tmp_dataids;
	END WHILE;
	CLOSE REMIND_CUSOR;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_clean_reminds`;
delimiter ||
CREATE  PROCEDURE `ldcrm_clean_reminds`(
	tmp_date DATE
)
BEGIN

	DECLARE i INT(19) DEFAULT 0;
	
	SET @this_tmpdate=tmp_date;
	
	WHILE(i>=0) DO
		IF EXISTS (SELECT 1 FROM ld_reminds WHERE date_time<=@this_tmpdate LIMIT 1) THEN
			DELETE FROM ld_reminds WHERE date_time<=@this_tmpdate LIMIT 5000;
			DELETE FROM ld_reminds_accepted WHERE date_time<@this_tmpdate LIMIT 5000;
			DELETE FROM ld_crmentity WHERE setype='Reminds' AND crmid NOT IN (SELECT remindsid FROM ld_reminds UNION SELECT remindsid FROM ld_reminds_accepted) LIMIT 10000;		
		
			SET i=i+1;
		ELSE
			SET i=-1;
		END IF;
		
	END WHILE;


end ||
delimiter;


CALL ldcrm_clean_reminds(DATE_SUB(CURDATE(),INTERVAL 6 MONTH));
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_remindsdata_delete`;
delimiter ||
CREATE PROCEDURE `ldcrm_remindsdata_delete`(
)
BEGIN

	DECLARE tmp_deldataids MEDIUMTEXT DEFAULT NULL;

	
	DECLARE REMIND_DELCUSOR CURSOR FOR 
		SELECT
			GROUP_CONCAT(remindsid) AS ids
		FROM (
			SELECT 
				remindsid
			FROM ld_reminds_accepted 
			WHERE date_time<DATE_SUB(CURDATE(),INTERVAL 3 MONTH)
			LIMIT 200
		) a;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_deldataids = NULL;

	OPEN REMIND_DELCUSOR; 
	FETCH REMIND_DELCUSOR INTO tmp_deldataids;
	WHILE(tmp_deldataids IS NOT NULL) DO
		DELETE FROM ld_reminds_accepted WHERE FIND_IN_SET(remindsid,tmp_deldataids);
		DELETE FROM ld_crmentity WHERE setype='Reminds' AND FIND_IN_SET(crmid,tmp_deldataids);
		FETCH REMIND_DELCUSOR INTO tmp_deldataids;
	END WHILE;
	CLOSE REMIND_DELCUSOR;

end ||
delimiter;

DROP EVENT IF EXISTS `ldcrm_remindsdata_transfer_every1mintue`;
delimiter ||
CREATE  EVENT `ldcrm_remindsdata_transfer_every1mintue` ON SCHEDULE EVERY 1 MINUTE STARTS NOW() ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_remindsdata_transfer();
||
delimiter;

DROP EVENT IF EXISTS `ldcrm_remindsdata_delete_every5mintue`;
DROP EVENT IF EXISTS `ldcrm_remindsdata_delete_every10second`;
delimiter ||
CREATE  EVENT `ldcrm_remindsdata_delete_every10second` ON SCHEDULE EVERY 10 SECOND STARTS NOW() ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_remindsdata_delete();
||
delimiter;
-- 2022-04-01

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

UPDATE ld_version SET old_version='V8.4.5.8.2',current_version='V8.4.5.8.2',remark='V8.4.5.8.2-20220401',wx_version='V8.4.5.8.2';
delimiter;