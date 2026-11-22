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

UPDATE ld_desk SET fieldlabel = '是否接收CRM消息通知' where labelbol = 'WECHATRECEVIEREMINDS' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Whether to receive CRM message notifications' where labelbol = 'WECHATRECEVIEREMINDS' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;
UPDATE ld_desk SET fieldlabel = '查找以下地址（详细地址）' where labelbol = 'FINDTHEFOLLOWINGADDRESS' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Find the following address (detailed address)' where labelbol = 'FINDTHEFOLLOWINGADDRESS' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;
UPDATE ld_desk SET fieldlabel = '请输入详细地址' where labelbol = 'PLEASEENTERTHEADDRESS' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Please enter detailed address' where labelbol = 'PLEASEENTERTHEADDRESS' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

set @profile_Checkout = (select actionid from ld_actionmapping where actionname = 'Checkout');
set @profile_ACheckout = (select actionid from ld_actionmapping where actionname = 'ACheckout');
set @tabid1 = (select tabid from ld_tab where `name` = 'WareHouseTransfer');
update ld_profileallpermission set sequence = 1000000 where tabid = @tabid1 and operation = @profile_Checkout;
update ld_profileallpermission set sequence = 1000001 where tabid = @tabid1 and operation = @profile_ACheckout;
SET @i=0;
UPDATE ld_profileallpermission SET sequence=(@i:=@i+1) WHERE  tabid = @tabid1 ORDER by sequence;
delimiter;

set @profile_Confirminventory = (select actionid from ld_actionmapping where actionname = 'Confirminventory');
set @profile_RevocationInventory = (select actionid from ld_actionmapping where actionname = 'RevocationInventory');
set @tabid2 = (select tabid from ld_tab where `name` = 'Checks');
update ld_profileallpermission set sequence = 1000000 where tabid = @tabid2 and operation = @profile_Confirminventory;
update ld_profileallpermission set sequence = 1000001 where tabid = @tabid2 and operation = @profile_RevocationInventory;
SET @i=0;
UPDATE ld_profileallpermission SET sequence=(@i:=@i+1) WHERE  tabid = @tabid2 ORDER by sequence;
delimiter;

UPDATE ld_desk SET fieldlabel = '条' where labelbol = 'RECORDNUMS' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;

DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND Relateid IN (SELECT fieldid FROM ld_field WHERE columnname='promotionalpartner' AND tablename IN ('ld_leads','ld_account'));
DELETE FROM ld_field WHERE columnname='promotionalpartner' AND tablename IN ('ld_leads','ld_account');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MORE','更多','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MORE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MORE','More','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MORE' and Labeltype='jspop' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `reset_accountname_halfangle`;
delimiter ||
CREATE  PROCEDURE `reset_accountname_halfangle`(
)
BEGIN
	
	WHILE( EXISTS (SELECT 1 FROM ld_account WHERE TRIM(IFNULL(accountname,''))<>'' AND accountname_halfangle IS NULL) ) DO
		SET @disable_triggers=1;
		UPDATE ld_account SET accountname_halfangle=func_changeToHalfAngle(accountname) WHERE TRIM(IFNULL(accountname,''))<>'' AND accountname_halfangle IS NULL LIMIT 1000;
		SET @disable_triggers=NULL;
	END WHILE;


end ||
delimiter;

CALL reset_accountname_halfangle();
DROP PROCEDURE IF EXISTS `reset_accountname_halfangle`;
delimiter;

CALL AddColumn('ld_field','editview_signin','char','10',NULL);
CALL AddColumn('ld_field','editview_resignin','char','10',NULL);
CALL AddColumn('ld_singin','from_module','varchar','100',NULL);
delimiter;

SET @labelbol = 'EDITVIEWSIGNIN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑单据时允许签到','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Allow sign-in when editing documents','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'EDITVIEWRESIGNIN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑单据时允许重签','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Allow resign-in when editing documents','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_singin LEFT JOIN (SELECT MAX(id) as max_id,record from ld_singin GROUP by record ) as tmpdata
on tmpdata.max_id = ld_singin.id
set from_module = (case when IFNULL(tmpdata.max_id,0) >0 then entitytype else 'Singin' END);
delimiter;

UPDATE ld_field set fieldvaluecolor = '#286CCC' WHERE uitype = 11 and (IFNULL(fieldvaluecolor,'') = '' or fieldvaluecolor = '#286CCC') ;
UPDATE ld_field set fieldvaluecolor = '#286CCC' WHERE uitype = 1101 and (IFNULL(fieldvaluecolor,'') = '' or fieldvaluecolor = '#286CCC') ;
delimiter;
-- 2023-05-10


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OldKanban','旧看板列表','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OldKanban' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OldKanban','Old Kanban List','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='OldKanban' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','KANBANVIEW','看板视图','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='KANBANVIEW' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','KANBANVIEW','Kanban View','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='KANBANVIEW' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MapFields','映射字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MapFields' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MapFields','Map Fields','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MapFields' and labeltype='fixedstr');
delimiter;


call AddColumn('ld_customreportsql_filter','filter_relatedtab','varchar','200','');
delimiter;

call AddColumn('ld_customreportsql_filter','uses','varchar','200','');
delimiter;

UPDATE ld_relatedlists SET actions = 'add' where related_tabid = 83 and tabid in (22,6);
delimiter;
UPDATE ld_relatedlists SET actions = 'add' where related_tabid = 82 and tabid = 6;
delimiter;

UPDATE ld_field set bigtype = 'fileattachment' where bigtype = 'picture' and uitype = 69;
delimiter;
UPDATE ld_field set bigtype = 'boolean' where bigtype = 'checkbox' and uitype = 56;
delimiter;

SET @labelbol = 'NOOPTIONALLABEL';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'无可选标签','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No Optional Label','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;
-- 2023-05-12

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

UPDATE ld_version SET old_version='V8.5.0.1',current_version='V8.5.0.1',remark='V8.5.0.1-20230512',wx_version='V8.5.0.1';
delimiter;