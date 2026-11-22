DROP PROCEDURE IF EXISTS `reset_demoaccount_20200306`;
delimiter ||
CREATE  PROCEDURE `reset_demoaccount_20200306`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		UPDATE ld_field SET maxrowsshow=10 WHERE maxrowsshow=5;

        UPDATE ld_field SET typeofdata='V~M' WHERE tabid IN (4,6,102) AND columnname IN ('lastname','mobile');
        UPDATE ld_field SET fieldonly=1 WHERE tabid IN (4,6,102) AND columnname IN ('mobile');

    	UPDATE ld_wx_config SET switch='close' WHERE `name`='external_contact';
    	UPDATE ld_account_set SET buttontype=1;
    	UPDATE ld_account_set_rule SET `status`='active' WHERE labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDS/Days';


	END IF;

end ||
delimiter;

CALL reset_demoaccount_20200306();
DROP PROCEDURE IF EXISTS `reset_demoaccount_20200306`;

DROP PROCEDURE IF EXISTS `reset_kh001account_20200306`;
delimiter ||
CREATE  PROCEDURE `reset_kh001account_20200306`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		DELETE FROM ld_parenttabrel WHERE tabid=-1 AND parenttabid=3;
		SET @my_usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='SalesOrderTrack');
		UPDATE ld_usereportcolumns SET columnshow=0 WHERE Usereportid=@my_usereportid AND `columns` LIKE 'ld_salesorder:stockpresence%';
        
        UPDATE ld_tab SET presence=0 WHERE `name`='BankAccountSet';
	END IF;

end ||
delimiter;

-- CALL reset_kh001account_20200306();
DROP PROCEDURE IF EXISTS `reset_kh001account_20200306`;
-- 2020-03-06


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

UPDATE ld_version SET old_version='V7.9.9.11',current_version='V7.9.9.11',remark='V7.9.9.11-20200306',wx_version='V7.9.9.8';
delimiter;