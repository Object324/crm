SET @disable_triggers='abcdefg';
UPDATE ld_purchaseinvoice 
LEFT JOIN ld_currency_info ON ld_currency_info.id = ld_purchaseinvoice.currency_id
SET 
  ld_purchaseinvoice.currency_symbol=ld_currency_info.currency_symbol,
	ld_purchaseinvoice.conversion_rate=ld_currency_info.conversion_rate 
WHERE currency_id>0 
	AND ld_purchaseinvoice.currency_symbol IS NULL 
	AND ld_purchaseinvoice.conversion_rate IS NULL;
SET @disable_triggers=NULL;
delimiter;

SET @sequence = (SELECT sequence FROM ld_systems_deploy WHERE deploy_type = 200);
SET @maxsequence = (SELECT max(sequence) FROM ld_systems_deploy WHERE roottype = 8);
UPDATE ld_systems_deploy SET sequence = sequence + 1 WHERE sequence >=@sequence AND roottype = 8 AND @maxsequence < 10;

INSERT INTO ld_systems_deploy (deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue) 
SELECT '1',348,'设置移动端拜访签到选择备注是否为必填字段' ,@sequence,'8','select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 348);

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',348,348,'设置移动端拜访签到备注是否为必填字段' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=348 and relateid=348 and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',348,348,'Whether the remarks is a required field for the field attendance from mobile' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=348 and relateid=348 and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel='选择批次后更新产品数量为批次数量' WHERE labelbol='selectabatch' AND languagetype='zh';
delimiter;
-- 2022-06-23

DELETE FROM ld_tranlabel WHERE Relateid IN (SELECT fieldid FROM ld_field WHERE columnname='checkoutstatus' AND tablename IN ('ld_cashbill','ld_sendcashbill')) AND trantable='ld_field';
DELETE FROM ld_field WHERE columnname='checkoutstatus' AND tablename IN ('ld_cashbill','ld_sendcashbill');

UPDATE ld_cvcolumnlist SET columnname='ld_cashbill:approvestatus:approvestatus:CashBill_审批状态:V' WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='CashBill')
	AND columnname LIKE '%checkoutstatus%';
UPDATE ld_cvcolumnlist SET columnname='ld_sendcashbill:approvestatus:approvestatus:SendCashBill_审批状态:V' WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='SendCashBill')
	AND columnname LIKE '%checkoutstatus%';

UPDATE ld_tabwithproductview SET columns='ld_cashbill:approvestatus:approvestatus:CashBill_审批状态:V' WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='CashBill')
	AND columns LIKE '%checkoutstatus%';
UPDATE ld_tabwithproductview SET columns='ld_sendcashbill:approvestatus:approvestatus:SendCashBill_审批状态:V' WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='SendCashBill')
	AND columns LIKE '%checkoutstatus%';
delimiter;
-- 2022-06-24

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

UPDATE ld_version SET old_version='V8.4.6.6.4',current_version='V8.4.6.6.4',remark='V8.4.6.6.4-20220624',wx_version='V8.4.6.6.4';
delimiter;