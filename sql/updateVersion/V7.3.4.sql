UPDATE ld_field SET presence=1 WHERE columnname='print_times' AND NOT EXISTS (SELECT 1 FROM ld_version WHERE account='jiangjing');
-- 2018-04-04

update ld_desk set fieldlabel='我负责的' where labelbol='Mine' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

ALTER TABLE ld_account_set MODIFY COLUMN buttontype VARCHAR(20);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEWBUTTONDROPDOWNOPTIONS','序时簿“新建”功能下拉按钮选项','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NEWBUTTONDROPDOWNOPTIONS' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEWBUTTONDROPDOWNOPTIONS','The new button drop-down option style','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NEWBUTTONDROPDOWNOPTIONS' and labeltype = 'jspop');
delimiter;

DROP PROCEDURE IF EXISTS `del_idx`;
delimiter ||
CREATE PROCEDURE `del_idx`(
 p_idxname varchar(100),
 p_tablename varchar(50)
)
begin  
	DECLARE str VARCHAR(250);  
  SET @str=concat(' drop index ',p_idxname,' on ',p_tablename);   
  SELECT DATABASE() INTO @tableschema;

	SET @strcount=concat('select count(*) into @cnt from information_schema.statistics where table_name=''',p_tablename,''' and index_name=''',p_idxname,'''  and table_schema=''',@tableschema,'''');  

  PREPARE stmtt FROM @strcount;  
  EXECUTE stmtt ;
    
	IF @cnt >0 THEN   
    PREPARE stmt FROM @str;  
    EXECUTE stmt ;  
  END IF;  

end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
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

CALL del_idx('groups_groupname_idx','ld_groups');
CALL addtableIndex('ld_groups','groups_groupname_idx','groupname');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores','绩效基数','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores','Performance Scores','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel='设为主要记录' where languagetype='zh' and Labeltype='fixedstr' and labelbol='SELECTPRIMARYRECORD';
update ld_desk set fieldlabel='set up as primary record' where languagetype='en' and Labeltype='fixedstr' and labelbol='SELECTPRIMARYRECORD';
delimiter;
update ld_desk set fieldlabel='公海成员客户序时簿“全部”页签是否显示公海客户' where languagetype='zh' and Labeltype='fixedstr' and labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES';
update ld_desk set fieldlabel='Does the "all" page sign of the members of the open sea show the high Seas customers?' where languagetype='en' and Labeltype='fixedstr' and labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES';

update ld_desk set fieldlabel='公海成员快速创建客户默认的客户公海状态' where languagetype='zh' and Labeltype='fixedstr' and labelbol='quicklycreatedefaultaccount';
update ld_desk set fieldlabel="The members of the high seas quickly create the customer's default state of the high seas" where languagetype='en' and Labeltype='fixedstr' and labelbol='quicklycreatedefaultaccount';

update ld_desk set fieldlabel='公海成员客户序时簿“新建”功能下拉选项' where languagetype='zh' and Labeltype='fixedstr' and labelbol='NEWBUTTONDROPDOWNOPTIONS';
update ld_desk set fieldlabel='The new member function drop-down button option is in the order of the high seas members' where languagetype='en' and Labeltype='fixedstr' and labelbol='SELECTPRIMARYRECORD';
update ld_desk set fieldlabel='公海成员客户序时簿“新建”功能下拉选项' where languagetype='zh' and Labeltype='fixedstr' and labelbol='NEWBUTTONDROP-DOWNOPTIONS';
update ld_desk set fieldlabel='The new member function drop-down button option is in the order of the high seas members' where languagetype='en' and Labeltype='fixedstr' and labelbol='NEWBUTTONDROP-DOWNOPTIONS';
delimiter;

SET @i=0;
SET @createdtime=(SELECT DATE_SUB(MIN(createdtime),INTERVAL 1 DAY) FROM ld_users WHERE createdtime>'1900-01-01');
UPDATE ld_users SET createdtime=DATE_ADD(@createdtime, INTERVAL (@i:=@i+1) SECOND) WHERE IFNULL(createdtime,'0000-00-00 00:00:00')<'1900-01-01' ORDER BY id;
-- 2018-04-12

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Audited','已审核','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Audited' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Audited','Audited','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Audited' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Unaudited','未审核','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Unaudited' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Unaudited','Unaudited','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Unaudited' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_contpotentialrel` (
  `contactid` int(19) NOT NULL DEFAULT '0',
  `potentialid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`contactid`,`potentialid`),
  KEY `contpotentialrel_potentialid_idx` (`potentialid`) USING BTREE,
  KEY `contpotentialrel_contactid_idx` (`contactid`) USING BTREE,
  CONSTRAINT `ld_contpotentialrel_ibfk_1` FOREIGN KEY (`potentialid`) REFERENCES `ld_potential` (`potentialid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2018-04-17


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

update ld_version set old_version='V7.3.4',current_version='V7.3.4',remark='V7.3.4-20180417',wx_version='V7.3.4';
delimiter;