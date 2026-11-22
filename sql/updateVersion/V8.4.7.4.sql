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

UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'组件模板','数据看板') WHERE labelbol IN ('LBL_TEMPLATES','TEMLATENAME','TemplatesCustomization');
UPDATE ld_desk SET fieldlabel='管理首页数据看板、设置看板关联的角色' WHERE labelbol='LBL_TEMPLATES_DESCRIPTION' AND fieldlabel='管理首页组件模板、设置模板关联角色';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlists_20220905`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_relatedlists_20220905`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_table VARCHAR(100) DEFAULT '';
	DECLARE tmp_module VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.tabid,
				CASE
					WHEN c.name='CashBill' THEN 'ld_cashbill2paymentplan'
					WHEN c.name='SendCashBill' THEN 'ld_sendcashbill2payment'
					WHEN c.name='Checks' THEN 'ld_checksdetail'
					ELSE b.tablename
				END AS tablename,
				c.name
			FROM (
				SELECT
					tabid,
					tablename
				FROM ld_producttoolfield
				WHERE columnname='productname'
					AND tabid>0
				GROUP BY tabid
			) a
			LEFT JOIN (
				SELECT
					tabid,
					tablename
				FROM ld_producttoolfield
				WHERE columnname='quantity'
					AND tabid>0
				GROUP BY tabid
			) b ON b.tabid=a.tabid
			LEFT JOIN ld_tab c ON c.tabid=a.tabid
			WHERE 1=1
				AND a.tabid NOT IN (SELECT related_tabid FROM ld_relatedlists WHERE tabid=14)
				AND (
					CASE
						WHEN c.name='CashBill' THEN 'ld_cashbill2paymentplan'
						WHEN c.name='SendCashBill' THEN 'ld_sendcashbill2payment'
						WHEN c.name='Checks' THEN 'ld_checksdetail'
						ELSE b.tablename
					END) IS NOT NULL;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_table,tmp_module;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @module='Products';
		SET @related_module=tmp_module;
		SET @actions='add';
		SET @type='datacategory_sql';
		SET @related_coltable=CONCAT(RIGHT(tmp_table,LENGTH(tmp_table)-3),'.productid');
		SET @tabid=14;
		SET @rel_tabid=tmp_tabid;
		SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);

		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
		SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@related_module)),@seq+1,@related_module,0,@actions,@type,@related_coltable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@related_module);

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		FETCH MYCUSOR INTO tmp_tabid,tmp_table,tmp_module;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_relatedlists_20220905();
DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlists_20220905`;

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

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill' LIMIT 1);
UPDATE ld_tabdetailfield SET fieldlabel='实际付款金额' WHERE tabid=@tabid AND fieldlabel='实际收款金额';
UPDATE ld_tranlabel SET fieldlabel='实际付款金额' WHERE tabid=@tabid AND fieldlabel='实际收款金额';
delimiter;

UPDATE ld_producttoolfield SET tablename='ld_sendcashbill' WHERE tablename='ld_sendcashbill2payment' AND columnname='total';
UPDATE ld_producttoolfield SET tablename='ld_cashbill' WHERE tablename='ld_cashbill2paymentplan' AND columnname='total';
delimiter;

SET @labelbol = 'chartName';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'统计图名称','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Name of statistical chart','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','areyousouryouwanttorecalcualte','确定要重算明细所有行？','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='areyousouryouwanttorecalcualte' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','areyousouryouwanttorecalcualte','Are you sure you want to recalculate all lines of details? ','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='areyousouryouwanttorecalcualte' and Labeltype='jspop');
delimiter;

SET @labelbol = 'Freezetothiscolumn';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'冻结至本列','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Freeze to this column','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'Unfreezecolumns';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'取消冻结','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Unfreeze columns','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

CALL AddColumn('ld_customtable_columns','issticky','varchar','10','no');
delimiter;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractBalanceReceivable' and compute_columns='ld_salesorder.receivable_balance' LIMIT 1;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N','n','0' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_salesorder:receivable_balance:receivable_balance%') ;

select id into @homestuffdetailid from ld_homestuffdetail where stuffid=35 and stufflabel='SignContractBalanceReceivable' and compute_columns='ld_servicecontracts.receivable_balance' LIMIT 1;
insert into ld_homestuffdetailcondition(homestuffdetailid,groupid, `columns`,comparator,value)
select @homestuffdetailid,1,'ld_servicecontracts:receivable_balance:receivable_balance:ServiceContracts_应收余额:N','n','0' from dual
where not exists(select 1 from ld_homestuffdetailcondition where homestuffdetailid=@homestuffdetailid and COLUMNS like '%ld_servicecontracts:receivable_balance:receivable_balance%') ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','curcashbillstrictcontrol','本次收款金额不超过产品应收余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr'
and labelbol='curcashbillstrictcontrol');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','curcashbillstrictcontrol','本次收款金额不超过产品应收余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr'
and labelbol='curcashbillstrictcontrol');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','cursendcashbillstrictcontrol','本次付款金额不超过产品应付余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr'
and labelbol='cursendcashbillstrictcontrol');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','cursendcashbillstrictcontrol','本次付款金额不超过产品应付余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr'
and labelbol='cursendcashbillstrictcontrol');
 
DELETE from ld_paymentplanscf where IFNULL(paymentplanid,0) = 0 ;
delimiter;

call AddPrimaryKey('ld_paymentplanscf','paymentplanid');
delimiter;

update ld_related_detailfield set fromvalue_info = REPLACE(fromvalue_info,'{"module":"ServiceContracts","column":"received_amount","columntype":"detail"}','{"module":"ServiceContracts","column":"received_amount","columntype":"main"}')
where modulename='CashBill' and trigger_columnname='entitytypeid' and effect_columnname='received_amount';
delimiter;

update ld_field set allowhide='yes' where columnname='sign_location_address' or columnname='location_address';
delimiter;
-- 2022-09-09


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

UPDATE ld_version SET old_version='V8.4.7.4',current_version='V8.4.7.4',remark='V8.4.7.4-20220909',wx_version='V8.4.7.4';
delimiter;