DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180129`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetfields_20180129`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx17%' THEN
        UPDATE ld_field SET presence=1 WHERE tabid=2 AND columnname='nextstep';
        UPDATE ld_field SET quickcreate=1 WHERE tabid IN (SELECT tabid FROM ld_tab WHERE name IN ('NormalApprove','AddJobBill','MinusJobBill','LoanApply'));
        UPDATE ld_field SET quickcreate=1,displaytype=2,presence=1 WHERE tabid=2 AND columnname='cf_1308';
        UPDATE ld_cvcolumnlist SET columnname='ld_potential:potential_no:potential_no:Potentials_fieldlabel:V' WHERE columnname LIKE 'ld_potential:potentialname:potentialname:%';
        
        UPDATE ld_option_module SET `default`=0 WHERE tabid = (SELECT tabid FROM ld_tab WHERE `name` = 'Invoice');
        UPDATE ld_option_module SET `default`=0 WHERE tabid = (SELECT tabid FROM ld_tab WHERE `name` = 'CashBill');
        UPDATE ld_option_module SET `default`=0 WHERE tabid = (SELECT tabid FROM ld_tab WHERE `name` = 'Commission');
        UPDATE ld_option_module SET `default`=0 WHERE tabid = (SELECT tabid FROM ld_tab WHERE `name` = 'Expense');
        
        UPDATE ld_customview SET setdefault=0 WHERE entitytype='Expense';
        UPDATE ld_customview SET setdefault=1 WHERE entitytype='Expense' AND viewname='All'; 
        
        UPDATE ld_customview SET setdefault=0 WHERE entitytype='PutCash';
        UPDATE ld_customview SET setdefault=1 WHERE entitytype='PutCash' AND viewname='All'; 
        
        UPDATE ld_customview SET setdefault=0 WHERE entitytype='CashDeposit';
        UPDATE ld_customview SET setdefault=1 WHERE entitytype='CashDeposit' AND viewname='All'; 
        
        UPDATE ld_customview SET setdefault=0 WHERE entitytype='CashBack';
        UPDATE ld_customview SET setdefault=1 WHERE entitytype='CashBack' AND viewname='All'; 
        
        UPDATE ld_customview SET setdefault=0 WHERE entitytype='PublicAnnouncement';
        UPDATE ld_customview SET setdefault=1 WHERE entitytype='PublicAnnouncement' AND viewname='All'; 
        
        UPDATE ld_customview SET setdefault=0 WHERE entitytype='Commission';
        UPDATE ld_customview SET setdefault=1 WHERE entitytype='Commission' AND viewname='All'; 
        
        UPDATE ld_relatedlists SET presence=0,sequence=100 WHERE `name`='get_SharedUsers';
	END IF;
    

end ||
delimiter;

CALL ldcrm_resetfields_20180129();
DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180129`;
delimiter;
-- 2018-01-29

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

update ld_version set old_version='V7.2.8',current_version='V7.2.8',remark='V7.2.8-20180126',wx_version='V7.2.8';
delimiter;