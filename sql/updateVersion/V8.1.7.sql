DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=NULL;
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF columntype='decimal' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, '(',columnlen,',2)',' default 0.00');
		ELSEIF columntype='int' THEN
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default 0');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default null');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

UPDATE ld_related_field
SET fromvalue_info=CONCAT(LEFT(fromvalue_info,CHAR_LENGTH(fromvalue_info)-13),'ld_leads.leadsid = ?')
WHERE effect_fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_singin' AND columnname='address')
	AND fromvalue_info LIKE '%FROM ld_leads%'
	AND RIGHT(fromvalue_info,13)='accountid = ?';
    
DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_attachments_filename_bymodule`(
	tmp_modulename VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);

	IF @tabid>0 THEN
		SELECT MAX(blockid) into @maxid FROM ld_blocks;
		SELECT MAX(sequence) into @maxseq FROM ld_blocks WHERE tabid=@tabid;
		SET @trantable='ld_blocks';
		SET @blocklabel='LBI_ATTACHMENT_FILE';
		SET @zh='附件信息';
		SET @en='Attachments Information';

		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title)
		SELECT @maxid+1,@tabid,@blocklabel,@maxseq+1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);

		UPDATE ld_blocks_seq SET id=(SELECT max(blockid) FROM ld_blocks);

		SELECT blockid INTO @relateid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		SET @maxseq=0;
		SELECT MAX(fieldid) INTO @maxid FROM ld_field;
		SELECT MAX(sequence) INTO @maxseq FROM ld_field WHERE tabid=@tabid AND block=@relateid;
		SET @trantable='ld_field';
		SET @tablename='ld_attachments';
		SET @columnname='filename';
		SET @fieldname='filename';
		SET @zh='附件';
		SET @en='Attachment';
		SET @uitype=1109;

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0 from dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@zh FROM DUAL
		WHERE NOT EXISTS (select 1 from ld_tranlabel  where languagetype = 'en' and trantable =@trantable and tabid = @tabid and relateid=@relateid);

		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

END IF;

end ||
delimiter;



DROP PROCEDURE IF EXISTS `ldcrm_customform_addfilename_20200731`;
delimiter ||
CREATE PROCEDURE `ldcrm_customform_addfilename_20200731`(
)
BEGIN

	DECLARE tmp_name VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
		SELECT `name` FROM ld_tab
		WHERE `name` LIKE 'CustomForm%'
			AND RIGHT(`name`,2)+0 BETWEEN 26 AND 60
			AND tabid NOT IN (SELECT tabid FROM ld_field WHERE columnname='filename' AND uitype=1109)
		ORDER BY tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_name = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_name;
	WHILE(tmp_name IS NOT NULL) DO
		CALL ldcrm_add_attachments_filename_bymodule(tmp_name);
		FETCH MYCUSOR INTO tmp_name;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_customform_addfilename_20200731();
DROP PROCEDURE IF EXISTS `ldcrm_customform_addfilename_20200731`;
DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter;
-- 2020-08-03

UPDATE ld_customreport_info SET report_type='template_js' WHERE report_template='yinshua_salesmanradar.mrt';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SortMenu','菜单排序','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SortMenu' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SortMenu','Sort Menu','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SortMenu' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_yinshuademo_20200804`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_yinshuademo_20200804`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_field WHERE tablename='ld_contactrecords' AND columnname='follow_type')
			AND EXISTS (SELECT 1 FROM ld_field WHERE tablename='ld_customform01' AND columnname='follow_type') THEN

		UPDATE ld_customform01 SET follow_content='礼节性老客户拜访、了解客户动向' WHERE follow_content='礼节性老客户拜访，了解客户动向';
		UPDATE ld_contactrecords SET follow_type='  ' WHERE follow_type='' OR follow_type IS NULL;
	END IF;

end ||
delimiter;

CALL ldcrm_reset_yinshuademo_20200804();
DROP PROCEDURE IF EXISTS `ldcrm_reset_yinshuademo_20200804`;
delimiter;
-- 2020-08-04


CALL AddColumn('ld_leads','longtitude','varchar',200,NULL);
CALL AddColumn('ld_leads','latitude','varchar',200,NULL);

CALL AddColumn('ld_leads','location_address','varchar',200,NULL);
CALL AddColumn('ld_leads','locationaddress','varchar',200,NULL);
CALL AddColumn('ld_leads','locationaddress_map','varchar',200,NULL);
delimiter;

SET @tabid= (SELECT tabid from ld_tab where name ='Leads');
SET @filedid = (SELECT max(fieldid) FROM ld_field );
SET @blockid = (SELECT blockid FROM ld_blocks WHERE tabid =@tabid and blocklabel='LBL_ADDRESS_BASICINFORMATION');

INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) SELECT @tabid, @filedid+1, 'locationaddress', 'yes', 'ld_leads', 1, '65', 'locationaddress', '定位', 1, 2, NULL, NULL, 1, @blockid, 1, 'V~O', 1, NULL, NULL, 1, NULL, 0, 0, 1, 0, 0, 0, NULL, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, 0, 0, 'yes', NULL, NULL, 0, NULL, 'yes', NULL FROM DUAL where not exists(SELECT 1 from ld_field where tabid =@tabid and columnname ='locationaddress');

SET @filedid = (SELECT max(fieldid) FROM ld_field );
INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) SELECT @tabid, @filedid+1, 'locationaddress_map', 'yes', 'ld_leads', 1, '64', 'locationaddress_map', '定位地址地图', 1, 2, NULL, NULL, 1, @blockid, 1, 'V~O', 1, NULL, NULL, 1, NULL, 0, 0, 1, 0, 0, 0, NULL, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, 0, 0, 'yes', NULL, NULL, 0, NULL, 'yes', NULL FROM DUAL WHERE NOT EXISTS(SELECT 1 from ld_field where tabid =@tabid and columnname ='locationaddress_map');

SET @fieldid = (SELECT fieldid FROM ld_field  WHERE  tabid=@tabid and columnname ='locationaddress');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'zh', 'ld_field', @tabid, @fieldid, '定位'  FROM  dual WHERE  NOT  EXISTS (SELECT  1 FROM  ld_tranlabel WHERE  tabid = @tabid AND  Relateid =@fieldid AND  languagetype='zh');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT   'en', 'ld_field', @tabid, @fieldid, 'Location' FROM  dual WHERE  NOT  EXISTS (SELECT  1 FROM  ld_tranlabel WHERE  tabid = @tabid AND  Relateid =@fieldid AND  languagetype='en') ;

SET @fieldid = (SELECT fieldid FROM ld_field  WHERE  tabid=@tabid and columnname ='locationaddress_map');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'zh', 'ld_field', @tabid, @fieldid, '地图'  FROM  dual WHERE  NOT  EXISTS (SELECT  1 FROM  ld_tranlabel WHERE  tabid = @tabid AND  Relateid =@fieldid AND  languagetype='zh');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT   'en', 'ld_field', @tabid, @fieldid, 'Map' FROM  dual WHERE  NOT  EXISTS (SELECT  1 FROM  ld_tranlabel WHERE  tabid = @tabid AND  Relateid =@fieldid AND  languagetype='en') ;
delimiter;

UPDATE  ld_field_seq SET  id =(SELECT  max(fieldid) FROM  ld_field);
UPDATE  ld_blocks_seq SET  id = (SELECT  max(blockid) FROM  ld_blocks);
delimiter;


SET @tabid = (SELECT tabid FROM ld_tab WHERE name ='Leads');
SET @blockid = (SELECT blockid FROM ld_blocks where tabid= @tabid AND blocklabel ='LBL_ADDRESS_BASICINFORMATION');
SET @i=0;
UPDATE ld_field set sequence = -2 WHERE tabid =@tabid AND columnname ='locationaddress';
UPDATE ld_field set sequence = -1 WHERE tabid =@tabid AND columnname ='locationaddress_map';
UPDATE ld_field set sequence=(@i:=@i+1) WHERE tabid = @tabid AND block = @blockid order by sequence;
delimiter;

SET  @tabid = (SELECT  tabid FROM  ld_tab WHERE  name='SocialPromotion');
SET  @blockid = (SELECT  blockid FROM  ld_blocks WHERE  tabid=@tabid AND blocklabel='第一步');
UPDATE ld_field  SET  block =@blockid WHERE  tabid =@tabid AND (columnname='h5pageurl' or columnname='h5pagebutton');
delimiter;

CREATE TABLE if NOT EXISTS `ld_socialpromotionformviewlist` (
	`id` int(19) NOT NULL AUTO_INCREMENT,
	`socialpromotionid` int(19) DEFAULT 0,
	`shareuserid` int(19) DEFAULT 0,
	`viewtime` datetime DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',' NOTMEETMOQORMPQ','第{N}行不符合MOQ或MPQ设定值','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOTMEETMOQORMPQ' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTMEETMOQORMPQ','Line {N} does not meet the set value of MOQ or MPQ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NOTMEETMOQORMPQ' and Labeltype='jspop' and languagetype='en');
delimiter;
-- 2020-08-06

CALL  AddColumn('ld_socialpromotionscf','formheadcolor','varchar','50',NULL);
delimiter;

SET  @tabid = (SELECT tabid FROM  ld_tab WHERE  name='SocialPromotion');
SET  @blockid =(SELECT blockid FROM  ld_blocks WHERE  tabid=@tabid AND  blocklabel='第二步');
SET  @fieldid =(SELECT max(fieldid) FROM  ld_field );

INSERT INTO ld_field(`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) SELECT  @tabid, @fieldid+1, 'formheadcolor', 'yes', 'ld_socialpromotionscf', 2, '1', 'formheadcolor', '表头颜色', 0, 2, '#229fe2', 100, 1000, @blockid, 1, 'V~O', 1, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL FROM  dual WHERE NOT  EXISTS (SELECT  1 FROM ld_field WHERE  tabid=@tabid and columnname = 'formheadcolor');
SET  @i =0;
UPDATE  ld_field set sequence=(@i:=@i+1) WHERE tabid =@tabid and block=@blockid ORDER BY  sequence;
SET @fieldid = (SELECT fieldid FROM ld_field  WHERE  tabid=@tabid and columnname ='formheadcolor');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT  'zh', 'ld_field', @tabid, @fieldid, '表头颜色'  FROM  dual WHERE  NOT  EXISTS (SELECT  1 FROM  ld_tranlabel WHERE  tabid = @tabid AND  Relateid =@fieldid AND  languagetype='zh');
INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT   'en', 'ld_field', @tabid, @fieldid, 'Header color' FROM  dual WHERE  NOT  EXISTS (SELECT  1 FROM  ld_tranlabel WHERE  tabid = @tabid AND  Relateid =@fieldid AND  languagetype='en') ;
UPDATE  ld_field_seq SET  id =(SELECT  max(fieldid) FROM  ld_field);
delimiter;

call AddColumn('ld_checksdetail', 'productbomid','int' ,'19','0');
call AddColumn('ld_checksdetail', 'productbomquantity','int' ,'19','0');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExpiryDate','失效日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExpiryDate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExpiryDate','Expiry Date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ExpiryDate' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2020-08-08

UPDATE ld_dashboard_app SET wx_presence=1,kehu001_presence=1 WHERE `name`='Saleskit';

DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff_20200808`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_templatesstuff_20200808`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR SELECT templateid FROM ld_templatesstuff  GROUP BY templateid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		UPDATE ld_templatesstuff SET stuffsequence=-1 WHERE templateid=tmp_id AND stufftype='saleskit';
		SET @i=0;
		UPDATE ld_templatesstuff SET stuffsequence=(@i:=@i+1) WHERE templateid=tmp_id ORDER BY stuffsequence;
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_templatesstuff_20200808();
DROP PROCEDURE IF EXISTS `ldcrm_reset_templatesstuff_20200808`;

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

UPDATE ld_version SET old_version='V8.1.7',current_version='V8.1.7',remark='V8.1.7-20200807',wx_version='V8.1.7';
delimiter;