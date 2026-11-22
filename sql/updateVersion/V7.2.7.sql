DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180126`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetfields_20180126`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx17%' THEN
		UPDATE ld_field SET quickcreate=0 WHERE tabid=4 AND columnname='pphone';
		UPDATE ld_field SET quickcreate=1 WHERE tabid=4 AND columnname='title';
		UPDATE ld_field SET quickcreate=1 WHERE tabid=6 AND columnname='title' AND tablename='ld_contactdetails';
		UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=29;
	END IF;

end ||
delimiter;

CALL ldcrm_resetfields_20180126();
DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180126`;
delimiter;
-- 2018-01-26

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.2.7',current_version='V7.2.7',remark='V7.2.7-20180126',wx_version='V7.2.7';
delimiter;