DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
BEGIN
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

CREATE TABLE  if not EXISTS `ld_upgrade_external_userid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactid` int(11) DEFAULT NULL,
  `upgrade` varchar(20) DEFAULT NULL,
  `upgradedatetime` datetime DEFAULT NULL,
  `external_userid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `upgrade` (`upgrade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

ALTER TABLE ld_contactdetails MODIFY COLUMN unionid VARCHAR(255);
ALTER TABLE ld_wechatuser MODIFY COLUMN unionid VARCHAR(255);
ALTER TABLE ld_wechatuser MODIFY COLUMN open_id VARCHAR(255);
CALL addtableIndex('ld_contactdetails','unionid','unionid');
CALL addtableIndex('ld_wechatuser','unionid','unionid');
CALL addtableIndex('ld_wechatuser_sign','sign_date','sign_date');
CALL addtableIndex('ld_wechatuser_sign','channelcode_id','channelcode_id');
delimiter;
-- 2022-03-07


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

UPDATE ld_version SET old_version='V8.4.5.8',current_version='V8.4.5.8',remark='V8.4.5.8-20220307',wx_version='V8.4.5.8';
delimiter;