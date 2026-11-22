delete from ld_usereportbasic where usereportid in(select usereportid  from ld_usereport  where name='SIGNINSTATISTICS')
and columns like '%ld_account:accountname:accountname%';
delimiter;

update ld_singin
INNER JOIN ld_account on ld_account.accountid=ld_singin.accountid
set ld_singin.entityname=ld_account.accountname,ld_singin.record=ld_singin.accountid
where ld_singin.entityname is null;
delimiter;

DROP PROCEDURE IF EXISTS `rest_producttoolfield_formula_20190103`;
delimiter ||
CREATE PROCEDURE `rest_producttoolfield_formula_20190103`()
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE setype IN ('SalesOrder','ServiceContracts','Quotes','QuotesChange','OutboundOrder','Stock','WareHouseTransfer')) THEN
		UPDATE ld_producttoolfield_formula SET
			formulastring='base_list_amount*c*d/100',
			columnstring="{formulavar:[base_list_amount,{'lettervar':'c','column':'quantity'},{'lettervar':'d','column':'discount_percent'}]}"
		WHERE formulastring='base_list_amount*c*(1-d/100)'
			AND producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname='list_amount');

		UPDATE ld_producttoolfield_formula SET
			formulastring='base_tax_amount*a*c/100',
			columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}"
		WHERE formulastring='a*base_tax_amount*(1-(c/100))'
			AND producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname='tax_amount');

		UPDATE ld_producttoolfield_formula SET
			formulastring='a*b*(100-c)*0.01',
			columnstring="{formulavar:[{'lettervar':'a','column':'quantity'},base_tax_amount,{'lettervar':'c','column':'discount_percent'}]}"
		WHERE formulastring='a*b*(c/100)'
			AND producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE columnname='discount_amount');

		UPDATE ld_producttoolfield SET defaultvalue=100 WHERE columnname='discount_percent' AND defaultvalue=0;
        UPDATE ld_field SET defaultvalue=100 WHERE tabid=6 AND columnname='discount_rate' AND (defaultvalue='' OR IFNULL(defaultvalue,0)=0);
	END IF;

END ||
delimiter;

CALL rest_producttoolfield_formula_20190103();
DROP PROCEDURE IF EXISTS `rest_producttoolfield_formula_20190103`;
delimiter;

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



DROP PROCEDURE IF EXISTS `ldcrm_customform_addfilename_20190103`;
delimiter ||
CREATE PROCEDURE `ldcrm_customform_addfilename_20190103`(
)
BEGIN

	DECLARE tmp_name VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
		SELECT `name` FROM ld_tab
		WHERE `name` LIKE 'CustomForm%'
			AND RIGHT(`name`,2)+0 BETWEEN 1 AND 25
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

CALL ldcrm_customform_addfilename_20190103();
DROP PROCEDURE IF EXISTS `ldcrm_customform_addfilename_20190103`;
DROP PROCEDURE IF EXISTS `ldcrm_add_attachments_filename_bymodule`;
delimiter;

UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'DT~O~','DT~M~'),quickcreate=0 WHERE tabid=13 AND columnname='realtime'
	AND NOT EXISTS (SELECT 1 FROM ld_troubletickets);
-- 2019-01-03

DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttabrel_20190103`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_parenttabrel_20190103`(
)
BEGIN

	IF (SELECT COUNT(accountid) FROM ld_account) < 2 THEN

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=sequence+100 WHERE parenttabid=@parenttabid;
		UPDATE ld_parenttabrel SET sequence=1 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials');
		UPDATE ld_parenttabrel SET sequence=2 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes');
		UPDATE ld_parenttabrel SET sequence=3 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
		UPDATE ld_parenttabrel SET sequence=4 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='QuotesChange');
		UPDATE ld_parenttabrel SET sequence=5 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack');
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;


		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Accounts');
		SET @i=0;
		DELETE FROM ld_parenttabrel WHERE tabid=-1;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence) SELECT @parenttabid,-1,10;
		UPDATE ld_parenttabrel SET sequence=sequence+100 WHERE parenttabid=@parenttabid;
		UPDATE ld_parenttabrel SET sequence=1 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
		UPDATE ld_parenttabrel SET sequence=2 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
		UPDATE ld_parenttabrel SET sequence=3 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts');
		UPDATE ld_parenttabrel SET sequence=4 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
		UPDATE ld_parenttabrel SET sequence=5 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='ChinaMap');
		UPDATE ld_parenttabrel SET sequence=6 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='CooperativeWork');
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;


		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Project');
		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=sequence+100 WHERE parenttabid=@parenttabid;
		UPDATE ld_parenttabrel SET sequence=1 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Project');
		UPDATE ld_parenttabrel SET sequence=2 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectTask');
		UPDATE ld_parenttabrel SET sequence=3 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress');
		UPDATE ld_parenttabrel SET sequence=4 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone');
		UPDATE ld_parenttabrel SET sequence=5 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet');
		UPDATE ld_parenttabrel SET sequence=6 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Rate');
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;


		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Purchase');
		SET @i=0;
		UPDATE ld_parenttabrel SET sequence=sequence+100 WHERE parenttabid=@parenttabid;
		UPDATE ld_parenttabrel SET sequence=1 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder');
		UPDATE ld_parenttabrel SET sequence=2 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
		UPDATE ld_parenttabrel SET sequence=3 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack');
		UPDATE ld_parenttabrel SET sequence=4 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
		UPDATE ld_parenttabrel SET sequence=5 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact');
		UPDATE ld_parenttabrel SET sequence=6 WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords');
		UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;

	END IF;
END ||
delimiter;

CALL ldcrm_reset_parenttabrel_20190103();
DROP PROCEDURE IF EXISTS `ldcrm_reset_parenttabrel_20190103`;
delimiter;

UPDATE ld_tranlabel SET fieldlabel='设置出库类单据是否允许负库存出库（根据参数出库和入库类库单据更新库存数量的触发点在保存或审批通过时判断）' WHERE languagetype='zh' AND Relateid=141 AND trantable='ld_systems_deploy';

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='WareHouseTransfer');
UPDATE ld_tranlabel SET fieldlabel='调拨单' WHERE trantable='ld_tab' AND Relateid=@tabid AND languagetype='zh' AND fieldlabel='库间调拨';
UPDATE ld_tranlabel SET fieldlabel='Transfers' WHERE trantable='ld_tab' AND Relateid=@tabid AND languagetype='en' AND fieldlabel='Warehouse Transfer';

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Checks');
UPDATE ld_tranlabel SET fieldlabel='盘点单' WHERE trantable='ld_tab' AND Relateid=@tabid AND languagetype='zh' AND fieldlabel='盘点';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
  tmp_module VARCHAR(100),
  tmp_column VARCHAR(100),
  tmp_rownum INT(1),
  tmp_colnum INT(1),
  tmp_showtag VARCHAR(20),
  tmp_sysdefault VARCHAR(20)
)
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

  DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
  INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
  SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Leads';
CALL ldcrm_add_cvcolumnlist_wx('Leads','accountname','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Leads','bill_street','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Leads','contactname','3','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Leads','mobile','4','1','yes','yes');
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'accountname',(@i:=@i+1),'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='accountname');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'bill_street',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='bill_street');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'contactname',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='contactname');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'mobile',(@i:=@i+1),'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='mobile');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE','导入数据','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE','Import data','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE2','数据导入','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE2' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE2','Import data','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE2' and languagetype='en' and Labeltype='fixedstr');

update ld_desk set fieldlabel='企业微信客户联系设置'
where labelbol = 'ExternalContactSetting' and languagetype='zh' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='Enterprise WeChat customer contact Settings'
where labelbol = 'ExternalContactSetting' and languagetype='en' and labeltype = 'fixedstr';

update ld_desk set fieldlabel='客户联系适用范围配置'
where labelbol = 'ExternalContactUsersSetting' and languagetype='zh' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='Customer contact use scope configuration'
where labelbol = 'ExternalContactUsersSetting' and languagetype='en' and labeltype = 'fixedstr';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATAREMIND1','正在批量拉取企业微信\'我的客户\'数据,请勿刷新或关闭浏览器','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATAREMIND1' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATAREMIND1','Batch pull enterprise WeChat \' my customer \' data, do not refresh or close browser','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATAREMIND1' and languagetype='en' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATAREMIND2','企业微信\'我的客户\'数据为空，请确认\'客户联系\'使用范围是否配置','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATAREMIND2' and languagetype='zh' and Labeltype='jspop');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATAREMIND2','Enterprise WeChat \'my customer\' data is empty, please confirm whether the use scope of \'customer contact\' is configured','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATAREMIND2' and languagetype='en' and Labeltype='jspop');

update ld_desk set fieldlabel='客户联系使用范围配置'
where labelbol = 'ExternalContactUsersSetting' and languagetype='zh' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='Customer contact use scope configuration'
where labelbol = 'ExternalContactUsersSetting' and languagetype='en' and labeltype = 'fixedstr';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE3','客户联系接口设置','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE3' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE3','Customer contact interface Settings','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE3' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE4','在企业微信管理后台“客户联系”-“配置”-“配置使用范围”页面设置成员适用范围','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE4' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE4','Set the applicable scope of members in the enterprise WeChat management background "customer contact" - "configuration" - "configuration using scope" page','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE4' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE5','前往企业微信管理后台配置','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE5' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE5','Go to WeChat manage the background configuration','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE5' and languagetype='en' and Labeltype='fixedstr');

update ld_desk set fieldlabel='设置的成员，在微信端CRM列表界面可导入客户联系至CRM系统，在CRM系统联系人详情界面可直接进行企业微信聊天。'
where labelbol = 'ExplainOfExternalContact' and languagetype='zh' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='set the member, in the WeChat  CRM list interface can import customer contact to CRM system, in the CRM system contact details interface can directly carry out enterprise WeChat chat.'
where labelbol = 'ExplainOfExternalContact' and languagetype='en' and labeltype = 'fixedstr';

update ld_desk set fieldlabel='原企业微信外部联系人设置'
where labelbol = 'CRMWeatherShowExternalContact' and languagetype='zh' and labeltype = 'fixedstr';
update ld_desk set fieldlabel='Original enterprise WeChat external contact Settings'
where labelbol = 'CRMWeatherShowExternalContact' and languagetype='en' and labeltype = 'fixedstr';
delimiter;

update ld_desk set  labelbol='可见范围设置'
 where languagetype='zh' and labelbol='visiblerangsettings'
and fieldlabel='可见范围内设置'
and labeltype='fixedstr';
delimiter;
-- 2019-01-04

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','ARTICLE','条','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ARTICLE' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','ARTICLE',' ','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ARTICLE' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','RELATIONAL','关联','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='RELATIONAL' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','RELATIONAL','Relational','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='RELATIONAL' and languagetype='en' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','IMPORTDATATTITLE6','企业微信CRM联系人可见范围','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE6' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','IMPORTDATATTITLE6','Enterprise WeChat CRM contact visible scope','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='IMPORTDATATTITLE6' and languagetype='en' and Labeltype='fixedstr');



UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
UPDATE ld_relatedlists_seq set id=(SELECT MAX(relation_id) FROM ld_relatedlists);
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
delimiter;

UPDATE ld_version SET old_version='V7.6.5',current_version='V7.6.5',remark='V7.6.5-20190104',wx_version='V7.6.5';
delimiter;