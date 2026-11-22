DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

end ||
delimiter;

ALTER TABLE ld_cfoperationlog MODIFY createdtime DATETIME; 
ALTER TABLE ld_cfoperationlog MODIFY deletedtime DATETIME; 
ALTER TABLE ld_cfoperationlog MODIFY modifiedtime DATETIME; 

DELETE ld_tranlabel from ld_tranlabel 
LEFT JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid=Relateid
WHERE ld_tranlabel.trantable='ld_producttoolfield' AND ld_tranlabel.fieldlabel='已收总额' AND (ld_producttoolfield.producttoolfieldid IS NULL OR (ld_producttoolfield.fieldlabel <> ld_tranlabel.fieldlabel));
delimiter;
-- 2022-08-29

update ld_producttoolfield set typeofdata='N~O~25,2',edit_permission=1,input_type=0,fieldid=0,savedatabase='yes',width=22 where
columnname in ('havereceivedamount','havepayamount','balancereceivedamount','balancepayamount');
delimiter;

update ld_producttoolfield set newline=0 where columnname in('product_received_amount','product_pay_amount') and sourcemodule is not null;
delimiter;

call AddColumn('ld_qrcode_fieldsdetail','fieldidtype','varchar','50','');
delimiter;

UPDATE ld_qrcode_fieldsdetail SET fieldidtype = 'normal' where IFNULL(fieldidtype,'') = ''; 
delimiter;
-- 2022-08-31

CALL AddColumn('ld_customtable','isshow_search','varchar','10','yes');
delimiter;

CALL AddColumn('ld_customreport','isshow_search','varchar','10','yes');
delimiter;

CALL AddColumn('ld_customreport','isshow_table','varchar','10','yes');
delimiter;
-- 2022-09-01

DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedfield_20220902`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_relatedfield_20220902`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_fieldid INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			a.tabid,
			a.fieldid
		FROM ld_field a
		WHERE a.columnname='source_list'
			AND a.tablename LIKE 'ld_customform%'
			AND a.tabid>0
		ORDER BY a.tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_fieldid;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @this_accountid=(SELECT fieldid FROM ld_field WHERE tabid=tmp_tabid AND columnname='accountid' LIMIT 1);
		IF @this_accountid>0 THEN
			INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
			SELECT 'main',tmp_fieldid,@this_accountid,'column','accountid' FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=tmp_fieldid AND effect_fieldid=@this_accountid);
		END IF;
		FETCH MYCUSOR INTO tmp_tabid,tmp_fieldid;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_relatedfield_20220902();
DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedfield_20220902`;

UPDATE ld_tabdetailfield SET tablename='ld_sendcashbill' WHERE tablename='ld_sendcashbill2payment' AND columnname='total';
UPDATE ld_tabdetailfield SET tablename='ld_cashbill' WHERE tablename='ld_cashbill2paymentplan' AND columnname='total';
UPDATE ld_tabdetailfield SET fieldlabel='实际付款金额' WHERE tablename='ld_sendcashbill2payment' AND columnname='total' AND fieldlabel='实际收款金额';

DROP PROCEDURE IF EXISTS `ldcrm_reset_tranlabel_20220902`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_tranlabel_20220902`(
)
BEGIN

	DECLARE tmp_relateid INT(19) DEFAULT 0;
	DECLARE tmp_language VARCHAR(10) DEFAULT '';
	DECLARE tmp_minid INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			Relateid,
			languagetype,
			MIN(tranlabelid) AS min_id
		FROM ld_tranlabel 
		WHERE trantable='ld_producttoolfield' 
		GROUP BY Relateid,languagetype
		HAVING COUNT(tranlabelid)>1;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_relateid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_relateid,tmp_language,tmp_minid;
	WHILE(tmp_relateid IS NOT NULL) DO
		DELETE FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND Relateid=tmp_relateid AND languagetype=tmp_language AND tranlabelid>tmp_relateid;
		FETCH MYCUSOR INTO tmp_relateid,tmp_language,tmp_minid;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_tranlabel_20220902();
DROP PROCEDURE IF EXISTS `ldcrm_reset_tranlabel_20220902`;
delimiter;

DELETE FROM ld_tranlabel WHERE IFNULL(Relateid,0)=0 AND trantable='ld_producttoolfield';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_tranlabel_20220902`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_tranlabel_20220902`(
)
BEGIN

	DECLARE tmp_relateid INT(19) DEFAULT 0;
	DECLARE tmp_language VARCHAR(10) DEFAULT '';
	DECLARE tmp_minid INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			Relateid,
			languagetype,
			MIN(tranlabelid) AS min_id
		FROM ld_tranlabel 
		WHERE trantable='ld_tabdetailfield' 
		GROUP BY Relateid,languagetype
		HAVING COUNT(tranlabelid)>1;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_relateid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_relateid,tmp_language,tmp_minid;
	WHILE(tmp_relateid IS NOT NULL) DO
		DELETE FROM ld_tranlabel WHERE trantable='ld_tabdetailfield' AND Relateid=tmp_relateid AND languagetype=tmp_language AND tranlabelid>tmp_relateid;
		FETCH MYCUSOR INTO tmp_relateid,tmp_language,tmp_minid;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_tranlabel_20220902();
DROP PROCEDURE IF EXISTS `ldcrm_reset_tranlabel_20220902`;
delimiter;

DELETE FROM ld_tranlabel WHERE IFNULL(Relateid,0)=0 AND trantable='ld_tabdetailfield';
delimiter;


select tabid into @tabid from ld_tab where name='CustomTables';
update ld_tranlabel set fieldlabel='自定义报表' where tabid=@tabid and trantable='ld_tab' and languagetype='zh';


select tabid into @tabid from ld_tab where name='CustomEcharts';
update ld_tranlabel set fieldlabel='自定义统计图' where tabid=@tabid and trantable='ld_tab' and languagetype='zh';

update ld_desk set fieldlabel='报表' where labelbol='Table' and languagetype='zh';
update ld_desk set fieldlabel='新建报表' where labelbol='NewT' and languagetype='zh';
delimiter;
CALL AddColumn('ld_groups','realgroupname','varchar','100','');
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkweek,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '周计划提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork';

	IF @remindtime<>'no' AND WEEKDAY(NOW())IN (@remindtime-2,@remindtime-1) AND @cnt=0 THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO
			IF NOT EXISTS (SELECT 1 FROM  ld_workreport where createdtime BETWEEN date_sub(curdate(),INTERVAL WEEKDAY(curdate()) + 0 DAY) and date_sub(curdate(),INTERVAL WEEKDAY(curdate()) - 6 DAY) and  type=2 AND smcreatorid=tmp_id) THEN
				IF WEEKDAY(NOW())=@remindtime-2 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，明天是最后一天期限哦');
				ELSEIF WEEKDAY(CURDATE())=@remindtime-1 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，今天是最后一天期限哦');
				END IF;
				CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			END IF;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;

update ld_tranlabel LEFT JOIN ld_tabdetailfield on ld_tabdetailfield.tabdetailfieldid=ld_tranlabel.Relateid
set ld_tranlabel.fieldlabel='Date of Contract'
where ld_tabdetailfield.columnname='billdate' and ld_tranlabel.languagetype='en' and ld_tranlabel.trantable='ld_tabdetailfield'
and ld_tranlabel.fieldlabel='Orignal Bill';
delimiter;

update ld_tranlabel LEFT JOIN ld_tabdetailfield on ld_tabdetailfield.tabdetailfieldid=ld_tranlabel.Relateid
set ld_tranlabel.fieldlabel='The amount collected'
where ld_tabdetailfield.columnname='amount' and ld_tranlabel.languagetype='en' and ld_tranlabel.trantable='ld_tabdetailfield'
and ld_tranlabel.fieldlabel='Received Amount';
delimiter;
-- 2022-09-02

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill' LIMIT 1);
UPDATE ld_tabdetailfield SET fieldlabel='实际付款金额' WHERE tabid=@tabid AND fieldlabel='实际收款金额';
UPDATE ld_tranlabel SET fieldlabel='实际付款金额' WHERE tabid=@tabid AND fieldlabel='实际收款金额';
delimiter;

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

UPDATE ld_version SET old_version='V8.4.7.3',current_version='V8.4.7.3',remark='V8.4.7.3-20220902',wx_version='V8.4.7.3';
delimiter;