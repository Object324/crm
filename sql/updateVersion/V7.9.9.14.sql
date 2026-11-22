UPDATE ld_producttoolfield SET defaultcolumn=1 WHERE columnname='discount_percent';

DROP PROCEDURE IF EXISTS `reset_newdemoaccount_202003016`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_202003016`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		SET @i=0;
		SET @tabid=6;
		SET @my_seq=(SELECT sequence FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=22 LIMIT 1);
		UPDATE ld_relatedlists SET sequence=sequence+10 WHERE tabid=@tabid AND sequence>@my_seq;
		UPDATE ld_relatedlists SET sequence=@my_seq+1,presence=0 WHERE tabid=@tabid AND `name`='get_balanceofaccount';
		UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		UPDATE ld_field SET presence=1 WHERE tabid=20 AND columnname='source_list';

		UPDATE ld_relatedlists SET presence=1 WHERE `name`='get_CallButler' AND NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=55 AND LENGTH(deploy_value)>0);

		UPDATE ld_relatedlists SET presence=1 WHERE `name`='account_buy_products.mrt';

		UPDATE ld_tab SET isduplicate='yes' WHERE `name`='Reminds';

		SET @my_fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_contactrecords' AND columnname='salesorderid' LIMIT 1);
		DELETE FROM ld_related_field WHERE trigger_fieldid=@my_fieldid AND fromvalue_info IN ('accountid','contactid');


		UPDATE ld_account_set SET normalconvertbuttonprofile='yes';

		UPDATE ld_tab SET isduplicate='yes' WHERE `name`='PriceBooks';

		UPDATE ld_field SET defaultvalue=1 WHERE tabid=19 AND columnname='active' AND defaultvalue IS NULL;

	END IF;

end ||
delimiter;

CALL reset_newdemoaccount_202003016();
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_202003016`;
-- 2020-03-17

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

UPDATE ld_version SET old_version='V7.9.9.14',current_version='V7.9.9.14',remark='V7.9.9.14-20200317',wx_version='V7.9.9.8';
delimiter;