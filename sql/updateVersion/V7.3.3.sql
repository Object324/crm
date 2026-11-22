DROP PROCEDURE IF EXISTS `ldcrm_picklist_DROPTABLE`;
delimiter ||
CREATE PROCEDURE `ldcrm_picklist_DROPTABLE`(
  listname varchar(100)
)
BEGIN

	SET @sqlstr = CONCAT("DROP TABLE IF EXISTS ld_",listname);
	PREPARE stmt1 FROM @sqlstr;
	EXECUTE stmt1;

	SET @sqlstr = CONCAT("DROP TABLE IF EXISTS ld_",listname,"_seq");
	PREPARE stmt1 FROM @sqlstr;
	EXECUTE stmt1;

	DEALLOCATE PREPARE stmt1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_field_20180329`;
delimiter ||
CREATE PROCEDURE `ldcrm_initial_picklist_field_20180329`(
)
BEGIN

	DECLARE tmp_listname varchar(100) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT fieldname FROM ld_field WHERE uitype=33 AND fieldname NOT IN (SELECT listname FROM ld_picklist_set) ORDER BY fieldname;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_listname = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_listname;
	WHILE (tmp_listname IS NOT NULL) DO

		INSERT INTO ld_picklist_set(listname,relatetable)
		SELECT tmp_listname,'ld_field';

		IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN 
			SET @i=0;
			SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_field' LIMIT 1);
			SET @sqlstr = CONCAT("INSERT INTO ld_picklist_values(listid,listvalue,sequence) ",
													 "SELECT ",@listid,",",tmp_listname,",(@i:=@i+1) ",
													 "FROM ld_",tmp_listname," ",
													 "ORDER BY picklist_valueid");

			PREPARE stmt1 FROM @sqlstr;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;

			CALL ldcrm_picklist_DROPTABLE(tmp_listname);
		END IF;

		FETCH MYCUSOR INTO tmp_listname;
	END WHILE;
	CLOSE MYCUSOR;
end ||
delimiter;

CALL ldcrm_initial_picklist_field_20180329();
DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_field_20180329`;
DROP PROCEDURE IF EXISTS `ldcrm_picklist_DROPTABLE`;

select wx_sequence into @wxsequence from ld_dashboard_app where name='Returnamount';
update ld_dashboard_app set wx_sequence=wx_sequence+4 where wx_sequence>@wxsequence;
update ld_dashboard_app set wx_presence=1,wx_sequence=@wxsequence+1 where name='signednumber';
update ld_dashboard_app set wx_presence=1,wx_sequence=@wxsequence+2 where name='signedamount';
update ld_dashboard_app set wx_presence=1,wx_sequence=@wxsequence+3 where name='cashbillamount';
update ld_dashboard_app set wx_presence=1,wx_sequence=@wxsequence+4 where name='expense_commission';
set @i=0;
update ld_dashboard_app set wx_sequence=(@i:=@i+1) where wx_presence=1 order by wx_sequence;
delimiter;
-- 2018-03-29

update ld_field set uitype=21 where tabid=6 and columnname='lastcontent';
delimiter;

update ld_desk set fieldlabel='新增仓库需进行库存初始化后，才能使用（系统预置的仓库已经初始化，可直接使用）。' where labelbol='SHOULDINITWAREINVENTORY' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel=' The new warehouse needs to be initialized to use(The preset of the system has been initialized and can be used directly).' where labelbol='SHOULDINITWAREINVENTORY' and languagetype='en' and Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PRIVILEGECANOTEMPTY','权限名称不能为空！','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PRIVILEGECANOTEMPTY' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PRIVILEGECANOTEMPTY','Role name can not be empty!','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PRIVILEGECANOTEMPTY' and Labeltype = 'jspop');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_attachmentsforsign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `signid` int(11) DEFAULT NULL,
  `filename` varchar(100) DEFAULT NULL,
  `size` varchar(100) DEFAULT NULL,
  `path` text,
  `type` varchar(100) DEFAULT NULL,
  `imagefromtype` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
delimiter;

SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Sales');
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'),(SELECT IFNULL(max(sequence),0)+1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='BankAccountSet'))
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype=56)
	AND EXISTS (SELECT 1 FROM ld_tab WHERE `name`='BankAccountSet' AND presence=1);
SET @i=0;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) WHERE parenttabid=@parenttabid ORDER BY sequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND columnname IN ('accountname','contactname','leadsource','mobile','status','smownerid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LBL_ROLENAME_EXIST','角色已存在，请重新录入！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_ROLENAME_EXIST' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LBL_ROLENAME_EXIST','Profilename lready exists, please re-entry!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_ROLENAME_EXIST' and Labeltype = 'fixedstr');
delimiter;

update ld_systems_deploy set inputvalue='[{"value":"1","text":"YES"},{"value":"2","text":"NO"},{"sql":""},{"relatedmodule":"PaymentPlan,Project"},{"relatedfield":"Project.projectstatus"}]' where deploy_type=53;
UPDATE ld_systems_deploy SET inputvalue='[{"value":"sales_stage","text":"sales_stage"},{"field":"sales_stage","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"SalesOrder,Potentials"},{"isSelectValue":"yes"}]' WHERE deploy_type=38;
UPDATE ld_systems_deploy SET inputvalue='[{"value":"rating","text":"rating"},{"field":"rating","type":"picklist","relatetable":"ld_field"},{"relatedmodule":"SalesOrder,Accounts"},{"isSelectValue":"yes"}]' WHERE deploy_type=37;
delimiter;

UPDATE ld_desk SET fieldlabel='您勾选了$##$条记录，最多可合并10条记录，请重新勾选需要合并的单据！'
WHERE labelbol='MASSELECTTEN' AND languagetype='zh' AND Labeltype='jspop';
UPDATE ld_desk SET fieldlabel='You have checked $##$ records and can merge up to 10 records. Please re-check the documents that need to be merged！'
WHERE labelbol='MASSELECTTEN' AND languagetype='en' AND Labeltype='jspop';
delimiter;

update ld_desk set fieldlabel='字段名称' where languagetype='zh' and labelbol='LISTFIELDS' and Labeltype='fixedstr';
delimiter;
-- 2018-04-03

update ld_tranlabel set fieldlabel='税（服务）' where trantable='ld_producttoolfield' and languagetype='zh' and Relateid in(SELECT producttoolfieldid FROM ld_producttoolfield where  columnname='tax3');
update ld_tranlabel set fieldlabel='Tax(Sales)' where trantable='ld_producttoolfield' and languagetype='en' and Relateid in(SELECT producttoolfieldid FROM ld_producttoolfield where  columnname='tax3');
delimiter;
-- 2018-04-04

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.3.3',current_version='V7.3.3',remark='V7.3.3-20180404',wx_version='V7.3.3';
delimiter;