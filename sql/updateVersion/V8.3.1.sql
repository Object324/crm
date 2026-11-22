DROP PROCEDURE IF EXISTS `ldcrm_reset_demodata_20201120`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_demodata_20201120`(
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Articles');

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Articles');
	SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
	SET @sequence =0;
	insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
	select @maxblockid+1,@tabid,'LBL_ARTICLES_INFO',@sequence,null,0,0,0,0,1,0 from dual
	where not exists(select 1 from ld_blocks where blocklabel='LBL_ARTICLES_INFO' and tabid=@tabid);

	UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM  ld_blocks);

	SET @blocks =(SELECT  blockid FROM  ld_blocks WHERE blocklabel='LBL_ARTICLES_INFO' AND  tabid =@tabid LIMIT 1);
	INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) 
	SELECT  'zh', 'ld_blocks', @tabid, @blocks, '基本信息' FROM DUAL
	WHERE NOT exists( SELECT  1 FROM  ld_tranlabel WHERE  tabid=@tabid AND Relateid=@blocks AND languagetype='zh');

	INSERT INTO ld_tranlabel( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) 
	SELECT  'en', 'ld_blocks', @tabid, @blocks, 'Basic Information' FROM DUAL   
	WHERE NOT exists( SELECT  1 FROM  ld_tranlabel WHERE tabid=@tabid AND Relateid=@blocks AND languagetype='en');


	IF EXISTS (SELECT 1 FROm ld_field WHERE tabid=@tabid AND block IS NULL) THEN
		UPDATE ld_field SET block=@blocks WHERE tabid=@tabid AND block IS NULL AND tablename='ld_articles';
		SET @i=100;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@blocks AND sequence IS NULL;

		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@blocks ORDER BY sequence;
	END IF;

END ||
delimiter;

CALL ldcrm_reset_demodata_20201120();
DROP PROCEDURE IF EXISTS `ldcrm_reset_demodata_20201120`;

update ld_relatedlists set actions='add' where  tabid=23 and name='get_paymentplan';

SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Articles' AND viewname='All' LIMIT 1);
DELETE FROM ld_cvcolumnlist WHERE cvid=@my_cvid;
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '0', 'ld_articles:description:description:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '1', 'ld_articles:customers:customers:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '2', 'ld_articles:weixin:weixin:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '3', 'ld_articles:channelcode_id:channelcode_id:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '4', 'ld_articles:publicaccount:publicaccount:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '5', 'ld_articles:approvestatus:approvestatus:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '6', 'ld_articles:smcreatorid:smcreatorid:Articles_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist` (`cvid`, `columnindex`, `columnname`) VALUES (@my_cvid, '7', 'ld_articles:modifiedtime:modifiedtime:Articles_fieldlabel:DT');
-- 2020-11-20

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

UPDATE ld_version SET old_version='V8.3.1',current_version='V8.3.1',remark='V8.3.1-20201120',wx_version='V8.3.1';
delimiter;