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

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=10;
-- 2022-06-16

update ld_purchaseorder LEFT JOIN ld_currency_info ON ld_currency_info.id = ld_purchaseorder.currency_id
set ld_purchaseorder.currency_symbol=ld_currency_info.currency_symbol ,ld_purchaseorder.conversion_rate=ld_currency_info.conversion_rate 
where currency_id>0 and ld_purchaseorder.currency_symbol is null and ld_purchaseorder.conversion_rate is null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','selectabatch','选择批次，批次数量自动覆盖产品数量','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='selectabatch' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','selectabatch','Select a batch, and the batch quantity automatically overwrites the product quantity','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='selectabatch' and Labeltype='fixedstr');
delimiter;


CREATE TABLE IF NOT EXISTS`ld_batchqtysetting` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(50) DEFAULT NULL,
  `userid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CALl AddColumn('ld_option_module','advance_demand','text','','');
CALl AddColumn('ld_option_module','advance_demand_groups','text','','');
delimiter;

UPDATE ld_field SET tablename = 'ld_potential' where columnname = 'total' and tabid = 2;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_module_calledlog` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `modulename` varchar(50) DEFAULT NULL COMMENT '对应模块',
  `record` int(19) DEFAULT NULL COMMENT '关联单据信息',
	`fieldname` varchar(50) DEFAULT NULL COMMENT '拨打电话选择的字段名称',
	`calleduserid` int(19) DEFAULT NULL COMMENT '拨打用户',
	`calledtime` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Dial','打','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Dial' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Dial','dial','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Dial' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '设置出库和入库类单据更新库存数量和出/入库状态的触发点' where Relateid=48 and languagetype = 'zh' and trantable = 'ld_systems_deploy';

update ld_tranlabel set fieldlabel = 'Set the trigger point for updating inventory quantity and issue / receipt status for issue and receipt documents'  where Relateid=48 and languagetype = 'en' and trantable = 'ld_systems_deploy';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_detailattachments` (
  `id` int(19) unsigned NOT NULL AUTO_INCREMENT,
  `crmid` int(19) NOT NULL,
  `lineitem_id` int(19) NOT NULL,
  `columnname` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL COMMENT '原文件名',
  `description` text,
  `type` varchar(100) DEFAULT NULL,
  `path` text,
  `subject` varchar(255) DEFAULT NULL,
  `size` varchar(100) DEFAULT NULL,
  `newfile_name` varchar(255) DEFAULT NULL,
  `imagefromtype` varchar(100) DEFAULT 'Computer',
  `storage_location` varchar(100) DEFAULT NULL,
  `upload_from` varchar(100) DEFAULT NULL,
  `cloud_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CALL addtableIndex('ld_detailattachments','crmid_idx','crmid');
CALL addtableIndex('ld_detailattachments','lineitem_id_idx','lineitem_id');
CALL addtableIndex('ld_detailattachments','columnname_idx','columnname');
delimiter;
-- 2022-06-21


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

UPDATE ld_version SET old_version='V8.4.6.6.3',current_version='V8.4.6.6.3',remark='V8.4.6.6.3-20220621',wx_version='V8.4.6.6.3';
delimiter;