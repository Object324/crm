DROP PROCEDURE IF EXISTS `ldcrm_delete_field`;
delimiter ||
CREATE  PROCEDURE `ldcrm_delete_field`(
	tmp_modulename VARCHAR(100),
	tmp_columnname VARCHAR(100)
)
BEGIN

	IF TRIM(IFNULL(tmp_modulename,''))<>'' AND TRIM(IFNULL(tmp_columnname,''))<>'' THEN 
		SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename LIMIT 1);
		SET @my_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@my_tabid AND columnname=tmp_columnname LIMIT 1);
		SET @my_tablename=(SELECT tablename FROM ld_field WHERE tabid=@my_tabid AND columnname=tmp_columnname LIMIT 1);

		DELETE FROM ld_tranlabel WHERE Relateid=@my_fieldid AND tabid=@my_tabid AND trantable='ld_field';
		DELETE FROM ld_field WHERE fieldid=@my_fieldid;

		IF IFNULL(@my_tablename,'')<>'' THEN
			CALL DelColumn(@my_tablename,tmp_columnname);
		END IF;

		IF tmp_modulename='Accounts' THEN
			SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge' LIMIT 1);
			SET @my_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@my_tabid AND columnname=tmp_columnname LIMIT 1);
			SET @my_tablename=(SELECT tablename FROM ld_field WHERE tabid=@my_tabid AND columnname=tmp_columnname LIMIT 1);

			DELETE FROM ld_tranlabel WHERE Relateid=@my_fieldid AND tabid=@my_tabid AND trantable='ld_field';
			DELETE FROM ld_field WHERE fieldid=@my_fieldid;
		ELSEIF tmp_modulename='ServiceCharge' THEN
			SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts' LIMIT 1);
			SET @my_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@my_tabid AND columnname=tmp_columnname LIMIT 1);
			SET @my_tablename=(SELECT tablename FROM ld_field WHERE tabid=@my_tabid AND columnname=tmp_columnname LIMIT 1);

			DELETE FROM ld_tranlabel WHERE Relateid=@my_fieldid AND tabid=@my_tabid AND trantable='ld_field';
			DELETE FROM ld_field WHERE fieldid=@my_fieldid;
		END IF;

	END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200410`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200410`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		CALL ldcrm_delete_field('Accounts','email1');
		CALL ldcrm_delete_field('Accounts','promoter');
		CALL ldcrm_delete_field('Accounts','promotionalpartner');
		CALL ldcrm_delete_field('Accounts','tickersymbol');
		CALL ldcrm_delete_field('Accounts','fax');

		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=6 AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=6 AND columnname='faxx');
		DELETE FROM ld_field WHERE tabid=6 AND columnname='faxx';

		CALL ldcrm_delete_field('Contacts','leadsource');

		CALL ldcrm_delete_field('Products','vendor_part_no');
		CALL ldcrm_delete_field('Products','weight');
		CALL ldcrm_delete_field('Products','mfr_part_no');
		CALL ldcrm_delete_field('Products','glacct');
		CALL ldcrm_delete_field('Products','commissionrate');
		CALL ldcrm_delete_field('Products','qty_per_unit');
		CALL ldcrm_delete_field('Products','reorderlevel');
		CALL ldcrm_delete_field('Products','qtyindemand');
		CALL ldcrm_delete_field('Products','sales_start_date');
		CALL ldcrm_delete_field('Products','sales_end_date');
		CALL ldcrm_delete_field('Products','expiry_date');
		CALL ldcrm_delete_field('Products','manufacturer');
		CALL ldcrm_delete_field('Products','start_date');
		CALL ldcrm_delete_field('Products','serialno');

		DELETE FROM ld_tranlabel WHERE trantable='ld_producttoolfield'
			AND Relateid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname IN ('grossprofit','rmb_taxprice','rmb_taxamount','rmbprice','eur_price','tax_rate','sendarea'));
		DELETE FROM ld_producttoolfield WHERE columnname IN ('grossprofit','rmb_taxprice','rmb_taxamount','rmbprice','eur_price','tax_rate','sendarea');

		SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense' LIMIT 1);
		DELETE FROM ld_tranlabel WHERE trantable='ld_tabdetailfield' AND tabid=@my_tabid
			AND Relateid IN (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE columnname IN ('currency_id','conversion_rate','money'));
		DELETE FROM ld_tabdetailfield WHERE tabid=67 AND columnname IN ('currency_id','conversion_rate','money');
	END IF;

	
	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR (SELECT COUNT(1) FROM ld_purchaseorder)<1 THEN 
		CALL ldcrm_delete_field('PurchaseOrder','requisition_no');
		CALL ldcrm_delete_field('PurchaseOrder','tracking_no');
		CALL ldcrm_delete_field('PurchaseOrder','salescommission');
		CALL ldcrm_delete_field('PurchaseOrder','exciseduty');
		CALL ldcrm_delete_field('PurchaseOrder','bill_street');
		CALL ldcrm_delete_field('PurchaseOrder','ship_street');
		CALL ldcrm_delete_field('PurchaseOrder','bill_city');
		CALL ldcrm_delete_field('PurchaseOrder','ship_city');
		CALL ldcrm_delete_field('PurchaseOrder','bill_state');
		CALL ldcrm_delete_field('PurchaseOrder','ship_state');

		CALL ldcrm_delete_field('PurchaseOrder','bill_code');
		CALL ldcrm_delete_field('PurchaseOrder','ship_code');
		CALL ldcrm_delete_field('PurchaseOrder','bill_country');
		CALL ldcrm_delete_field('PurchaseOrder','ship_country');
		CALL ldcrm_delete_field('PurchaseOrder','bill_pobox');
		CALL ldcrm_delete_field('PurchaseOrder','ship_pobox');
	END IF;

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR (SELECT COUNT(1) FROM ld_servicecontracts)<1 THEN 
		DELETE FROM ld_tranlabel WHERE tabid=37 AND trantable='ld_field' 
			AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=37 AND columnname IN ('tracking_unit','used_units'));
		DELETE FROM ld_field WHERE tabid=37 AND columnname IN ('tracking_unit','used_units');
	END IF;

	DELETE FROM ld_tranlabel WHERE trantable='ld_producttoolfield'
		AND Relateid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE presence=1 AND columnname IN ('grossprofit','rmb_taxprice','rmb_taxamount','rmbprice','eur_price','tax_rate','sendarea'));
	DELETE FROM ld_producttoolfield WHERE presence=1 AND columnname IN ('grossprofit','rmb_taxprice','rmb_taxamount','rmbprice','eur_price','tax_rate','sendarea');

	SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense' LIMIT 1);
	DELETE FROM ld_tranlabel WHERE trantable='ld_tabdetailfield' AND tabid=@my_tabid 
		AND Relateid IN (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE presence=1 AND columnname IN ('currency_id','conversion_rate','money'));
	DELETE FROM ld_tabdetailfield WHERE tabid=@my_tabid AND presence=1 AND columnname IN ('currency_id','conversion_rate','money');

end ||
delimiter;

CALL reset_newdemoaccount_20200410();
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200410`;

DROP PROCEDURE IF EXISTS `ldcrm_delete_field`;

update ld_relatedlists  set related_coltable='customform21detail.entitytypeid', type='datacategory_sql'
where tabid=6 and name='get_customform21'
 and exists(select 1 from ld_version  where trade='edu');
delimiter;

update ld_relatedlists set related_coltable='lessionplan.projectid' where tabid=48 and name='get_lessionplan';
delimiter;

SET @my_scnt=(SELECT COUNT(1) FROM ld_servicecontracts);
update ld_servicecontracts set service_units=(select count(1) from ld_troubletickets 
where servicecontractsid=ld_servicecontracts.servicecontractsid and deleted=0 and IFNULL(approvestatus,'')<>'已拒绝')
where not exists (select 1 from ld_field where tabid=6 and columnname='service_units')
	AND @my_scnt<1000;
delimiter;

update ld_producttoolfield set uitype=163 ,defaultcolumn=1,input_type=0 ,fieldid=0 where columnname='productcost';
delimiter;


DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200410_edu`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200410_edu`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='edu') AND EXISTS (SELECT 1 FROM ld_relatedlists WHERE `name`='account_lessonplan.mrt') THEN
		SET @i=0;
		UPDATE ld_relatedlists SET sequence=sequence+1 WHERE tabid=6 AND sequence>5;
		UPDATE ld_relatedlists SET sequence=6 WHERE tabid=6 AND `name`='account_lessonplan.mrt';
		UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=6 ORDER BY sequence;

		DELETE FROM ld_relatedlists WHERE tabid=6 AND related_tabid IN (37,47,48);
		DELETE FROM  ld_relatedlists WHERE tabid=48 AND related_tabid IN (37,47,0,4);
		DELETE FROM  ld_relatedlists WHERE tabid=48 AND label='ProjectProgress';

		SET @i=0;
		UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=48
		ORDER BY FIELD(label,'SharedUsers','Accounts','LessionPlan','CustomForm21','Attachment','ChangeView','ViewHistory');
	END IF;

end ||
delimiter;

CALL reset_newdemoaccount_20200410_edu();
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200410_edu`;
-- 2020-04-10


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

UPDATE ld_version SET old_version='V8.0.0.6',current_version='V8.0.0.6',remark='V8.0.0.6-20200410',wx_version='V8.0.0.6';
delimiter;