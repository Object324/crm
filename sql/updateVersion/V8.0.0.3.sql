
update ld_desk set fieldlabel='服务小程序模块列表字段设置' where labelbol='THESETTINGOFSELFSERVICELISTFIELDS' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Service applet module list field settings' where labelbol='THESETTINGOFSELFSERVICELISTFIELDS' and labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='服务小程序详情界面字段设置' where labelbol='THESETTINGOFSELFSERVICEFIELDS' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Service applet details interface field settings' where labelbol='THESETTINGOFSELFSERVICEFIELDS' and labeltype='fixedstr' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMRELATEINFO','自定义相关信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMRELATEINFO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMRELATEINFO','Customize related information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CUSTOMRELATEINFO' and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `reset_newaccount_20200401`;
delimiter ||
CREATE  PROCEDURE `reset_newaccount_20200401`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_moudule VARCHAR(100) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.tabid,
				a.`name` AS moudule
			FROM ld_tab a
			LEFT JOIN ld_relatedlists b ON b.tabid=a.tabid AND b.`name`='get_attachment'
			WHERE a.tabid>0
				AND (a.`name` LIKE 'CustomForm%' OR a.`name` IN ('QuotesChange','LoanApply','CardApply','BusinessApply','AddJobBill','MinusJobBill','NormalApprove'))
				AND b.related_tabid IS NULL;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_moudule;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @my_presence=0;
		SET @my_module=tmp_moudule;
		SET @my_tabid=tmp_tabid;
		SET @my_relmodule='Attachment';
		SET @my_reltabid=(SELECT tabid FROM ld_tab WHERE `name`=@my_relmodule LIMIT 1);
		SET @my_seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@my_tabid);
		SET @my_actions='add';
		SET @my_reltype='datacategory_sql';
		SET @my_relcoltable='attachmentsforbills.related_to';
		SET @my_buttonstatus='yes';

		SET @my_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,buttonstatus)
		SELECT @my_id+1,@my_tabid,@my_reltabid,CONCAT('get_',LOWER(@my_relmodule)),@my_seq,@my_relmodule,@my_presence,@my_actions,0,4,@my_reltype,@my_relcoltable,0,@my_buttonstatus FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@my_tabid AND related_tabid=@my_reltabid);

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		
		FETCH MYCUSOR INTO tmp_tabid,tmp_moudule;
	END WHILE;
	CLOSE MYCUSOR;

 
END ||
delimiter;

CALL reset_newaccount_20200401();
DROP PROCEDURE IF EXISTS `reset_newaccount_20200401`;
-- 2020-04-01

UPDATE ld_producttoolfield SET input_type=0 WHERE tabid=37 AND columnname='servicecontracts_end_date';



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

UPDATE ld_version SET old_version='V8.0.0.3',current_version='V8.0.0.3',remark='V8.0.0.3-20200402',wx_version='V8.0.0.2';
delimiter;