UPDATE ld_appparenttabrel SET tab_tablename='ld_tab' WHERE tabid IN (SELECT tabid FROM ld_tab) AND tab_tablename IS NULL;
UPDATE ld_parenttabrel SET tab_tablename='ld_tab' WHERE tabid IN (SELECT tabid FROM ld_tab) AND tab_tablename IS NULL;

ALTER TABLE ld_appparenttabrel ALTER COLUMN tab_tablename SET DEFAULT 'ld_tab';
ALTER TABLE ld_parenttabrel ALTER COLUMN tab_tablename SET DEFAULT 'ld_tab';
-- 2020-02-10

CALl AddColumn('ld_activity','cc_email','VARCHAR','50',NULL);
ALTER TABLE ld_activity MODIFY COLUMN cc_email TEXT AFTER to_email;


DROP PROCEDURE IF EXISTS `ldcrm_add_emali_cc`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_emali_cc`(
	tmp_subject text,
	tmp_content text,
	tmp_toemail text,
	tmp_ccemail text,
	tmp_sendtime datetime,
	tmp_sender int(19)
)
BEGIN
	
		IF LENGTH(tmp_toemail)>5 THEN 

			SET @tmpcrmid=(SELECT MAX(crmid) FROM ld_crmentity);
			
			INSERT INTO ld_crmentity(crmid,setype) SELECT @tmpcrmid+1,'Emails';

			UPDATE ld_crmentity_seq SET id=(SELECT max(crmid) FROM ld_crmentity); 

			INSERT INTO ld_activity(activityid,`subject`,description,to_email,cc_email,date_start,smownerid,smcreatorid,activitytype,visibility,deleted)
			SELECT @tmpcrmid+1,tmp_subject,tmp_content,tmp_toemail,tmp_ccemail,tmp_sendtime,tmp_sender,tmp_sender,'Emails','公共',0;
			
			INSERT INTO ld_activitycf(activityid) SELECT @tmpcrmid+1;

			INSERT INTO ld_activity_reminder(activity_id,email_remind)
			SELECT @tmpcrmid+1,tmp_sendtime;
			
		END IF;

end ||
delimiter;
-- 2020-02-13

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

UPDATE ld_version SET old_version='V7.9.9.9',current_version='V7.9.9.9',remark='V7.9.9.9-20200213',wx_version='V7.9.9.8';
delimiter;