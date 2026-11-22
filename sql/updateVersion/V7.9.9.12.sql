SET @my_value='光明区';
SET @my_listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area');
SET @my_seq=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@my_listid);
INSERT ld_picklist_values(listid,listvalue,sequence)
SELECT @my_listid,@my_value,@my_seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@my_listid AND listvalue=@my_value);

SET @my_value='龙华区';
SET @my_listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area');
SET @my_seq=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@my_listid);
INSERT ld_picklist_values(listid,listvalue,sequence)
SELECT @my_listid,@my_value,@my_seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@my_listid AND listvalue=@my_value);

SET @my_value='坪山区';
SET @my_listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area');
SET @my_seq=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@my_listid);
INSERT ld_picklist_values(listid,listvalue,sequence)
SELECT @my_listid,@my_value,@my_seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@my_listid AND listvalue=@my_value);

SET @my_value='大鹏新区';
SET @my_listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area');
SET @my_seq=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@my_listid);
INSERT ld_picklist_values(listid,listvalue,sequence)
SELECT @my_listid,@my_value,@my_seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@my_listid AND listvalue=@my_value);

SET @my_value='深汕特别合作区';
SET @my_listid=(SELECT listid FROM ld_picklist_set WHERE listname='bill_area');
SET @my_seq=(SELECT MAX(sequence) FROM ld_picklist_values WHERE listid=@my_listid);
INSERT ld_picklist_values(listid,listvalue,sequence)
SELECT @my_listid,@my_value,@my_seq+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid=@my_listid AND listvalue=@my_value);

UPDATE ld_picklist_dependency 
SET targetvalues='["市辖区","福田区","罗湖区","宝安区","光明区","南山区","龙华区","龙岗区","盐田区","坪山区","大鹏新区","深汕特别合作区"]'
WHERE targetfield='bill_area' AND sourcefield='bill_city' AND sourcevalue='深圳市';
-- 2020-03-09

DROP PROCEDURE IF EXISTS `reset_demoaccount_202003010`;
delimiter ||
CREATE  PROCEDURE `reset_demoaccount_202003010`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		UPDATE ld_field SET presence=0 WHERE tabid=6 AND columnname='nolinkdays';

		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Accounts' AND viewname='ALL' AND customcategory='ALLACCOUNT');
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
		SET @i=-1;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:accountname:accountname:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:account_no:account_no:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:account_type:accounttype:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:industry:industry:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:phone:phone:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:nextcontactdate:nextcontactdate:Accounts_fieldlabel:D';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:nolinkdays:nolinkdays:Accounts_fieldlabel:NN';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:publicaccount:publicaccount:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_contactdetails:lastname:lastname:Contacts_fieldlabel:V';

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,(@i:=@i+1),'ld_contactdetails:mobile:mobile:Contacts_fieldlabel:V';

		UPDATE ld_field SET presence=0 WHERE tabid=2 AND columnname LIKE '5w2p_%';
	END IF;

end ||
delimiter;

CALL reset_demoaccount_202003010();
DROP PROCEDURE IF EXISTS `reset_demoaccount_202003010`;
-- 2020-03-10


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

UPDATE ld_version SET old_version='V7.9.9.12',current_version='V7.9.9.12',remark='V7.9.9.12-20200310',wx_version='V7.9.9.8';
delimiter;