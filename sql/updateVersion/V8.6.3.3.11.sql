drop PROCEDURE if EXISTS add_subtotal_field_bill_20240903;
delimiter ||
create PROCEDURE add_subtotal_field_bill_20240903
(
	var_moudule varchar(100)
)
BEGIN
	DECLARE var_module varchar(100);
	DECLARE var_sourcemodule varchar(100);
	DECLARE var_tabid INT(100);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select ld_option_module.tabid as tabid,`name` as sourcemodule from ld_option_module
	INNER JOIN ld_tab ON ld_tab.tabid=ld_option_module.option_tabid
  where ld_option_module.tabid=(SELECT tabid  from ld_tab WHERE `name`=var_moudule) and option_tabid NOT IN(SELECT tabid from ld_tab where `name` in ('PaymentPlan','SendPayment'));
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;

	Fetch cur1 into var_tabid,var_sourcemodule;
	loop1: while  done<>1 DO
		SET @sourcemodule = var_sourcemodule;
		SET @tabid = var_tabid;
		SET @maxproducttoolfieldid = (SELECT max(producttoolfieldid) FROM ld_producttoolfield );
		SET @columnname = 'subtotal';
		SET @tablename = (SELECT tablename FROM ld_field WHERE tabid = @tabid and columnname ='smownerid');
		SET @trantable='ld_producttoolfield';
		SET @zh='小计';
		SET @en='Sub Total';

		SET @maxsequence = (SELECT max(sequence) FROM ld_producttoolfield WHERE tabid=@tabid);
		SET @fieldid = (select fieldid from ld_field where columnname = 'subtotal' and tabid=@tabid);
		INSERT INTO `ld_producttoolfield` (`producttoolfieldid`, `columnname`, `allowhide`, `fieldlabel`, `defaultvalue`, `presence`, `uitype`, `typeofdata`, `sequence`, `tabid`, `tablename`, `width`, `edit_permission`, `input_type`, `fieldid`, `newline`, `defaultcolumn`, `is_checkimportfield`, `description`, `nullfield`, `referencemodule`, `datarange`, `approve_demand`, `maxrowsshow`, `bigtype`, `savedatabase`, `fieldvaluecolor`, `fieldplaceholder`, `effectivecondition`, `parentbigtype`, `sourcemodule`, `mobiledetailshow`, `relatedmodulefield`, `showhyperlinks`, `subtotal_attr`, `autowordwrap`, `editpage`) 
		SELECT @maxproducttoolfieldid+1,@columnname , 'yes', '小计', '0', '0', '33', 'N~O~25,2', @maxsequence+1, @tabid, @tablename, '22', '1', '0', @fieldid, '2', '3', '0', NULL, '1', NULL, NULL, NULL, '0', NULL, 'yes', NULL, NULL, NULL, NULL, @sourcemodule, NULL, 'no', 'yes', NULL, 'yes', NULL FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid = @tabid AND columnname = @columnname AND sourcemodule=@sourcemodule);

		SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname AND sourcemodule=@sourcemodule LIMIT 1);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
	Fetch cur1 into var_tabid,var_sourcemodule;
	end while loop1;
	close cur1;
end ||
delimiter;

CALL add_subtotal_field_bill_20240903('SendCashBill');
CALL add_subtotal_field_bill_20240903('CashBill');
delimiter;

SET @labelbol = 'EDITCONTENTPICKLISTVALUE';
set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑%s下拉框列表值',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Edit the %s's value of the drop-down list",@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel="删除%s多选框选项" where labelbol='DELETEMULTIPICKLISTVALUE' and languagetype='zh';
UPDATE ld_desk SET fieldlabel="Delete the %s's smulti-drop-down option" where labelbol='DELETEMULTIPICKLISTVALUE' and languagetype='en';
delimiter;
UPDATE ld_desk SET fieldlabel="删除%s下拉框选项" where labelbol='DELETEPICKLISTVALUE' and languagetype='zh';
UPDATE ld_desk SET fieldlabel="Delete the %s's drop-down option" where labelbol='DELETEPICKLISTVALUE' and languagetype='en';
delimiter;

UPDATE ld_module_setting_byuser SET content = 
  CASE WHEN (SELECT COUNT(1) FROM ld_communicationaccount as com WHERE com.service_tel IS NOT NULL AND com.service_tel != '') > 0 THEN
        CONCAT('{1}为您的灵当软件验证码，请在24小时内完成输入。如非本人操作，请忽略。详询客服', (SELECT com.service_tel FROM ld_communicationaccount as com WHERE com.service_tel IS NOT NULL AND com.service_tel != '' LIMIT 1))
		ELSE '{1}为您的灵当软件验证码，请在24小时内完成输入。如非本人操作，请忽略。'
	END
WHERE label = 'AccountLoginCodeSMS' and modulename = 'SMS';
delimiter;
-- 2024-09-18


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

UPDATE ld_version SET old_version='V8.6.3.3.11',current_version='V8.6.3.3.11',remark='V8.6.3.3.11-20240918',wx_version='V8.6.4.0';
delimiter;