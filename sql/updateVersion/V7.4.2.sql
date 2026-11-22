DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
delimiter ||
CREATE PROCEDURE `rest_kehu001_caidan`(
)
begin
	
	IF DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		UPDATE ld_tab SET presence=0 WHERE `name` IN ('CashBill');

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Service');
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @parenttabid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),20000 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill'));

		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),
				(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;


		SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Service' AND systemdefault='yes' LIMIT 1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),20000 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill'));

		SET @i=0;
		UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid 
			ORDER BY FIELD(tabid,
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge'),
				(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk'),
				(SELECT tabid FROM ld_tab WHERE `name`='Faq'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn'),
				(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts'),
				(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),
				(SELECT tabid FROM ld_tab WHERE `name`='Products'),
				(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork')
			),sequence;

	END IF;

end ||
delimiter;

CALL rest_kehu001_caidan();
DROP PROCEDURE IF EXISTS `rest_kehu001_caidan`;
-- 2018-06-27

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

update ld_version set old_version='V7.4.2',current_version='V7.4.2',remark='V7.4.2-20180627',wx_version='V7.4.2';
delimiter;