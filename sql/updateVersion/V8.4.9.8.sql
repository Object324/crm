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

DROP PROCEDURE IF EXISTS `ldcrm_addtable_fieldwxdetailinfo`;
delimiter ||
CREATE PROCEDURE `ldcrm_addtable_fieldwxdetailinfo`(
)
BEGIN

DECLARE tableExists INT DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'ld_fieldwxdetailinfo' AND TABLE_SCHEMA=DATABASE()) THEN
	CALL AddColumn('ld_tab','mobiledetailinfoshowtype','char','10','tile');

	CREATE TABLE if not EXISTS `ld_fieldwxdetailinfo` (
		`id` int(11) NOT NULL AUTO_INCREMENT,
		`tabid` int(11) DEFAULT 0 COMMENT '模块表ld_tab表id',
		`relatedtable` varchar(100) DEFAULT '' COMMENT '关联表ld_producttoolfield/ld_tabdetailfield',
		`columnname` varchar(100) DEFAULT NULL COMMENT '字段名对应ld_producttoolfield/ld_tabdetailfield的columnname',
		`sequence` int(4) DEFAULT 1 COMMENT '排序',
		`mobiledetailinfoshowtype` char(10) DEFAULT '' COMMENT '字段显示类型 fold折叠，table表格',
		PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;

	insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)select tabid,'ld_producttoolfield',columnname,sequence,'fold' from ld_producttoolfield where mobiledetailshow='yes';
	update ld_producttoolfield set mobiledetailshow='no' where mobiledetailshow='yes';
	insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)select tabid,'ld_tabdetailfield',columnname,sequence,'fold' from ld_tabdetailfield where mobiledetailshow='yes';
	update ld_tabdetailfield set mobiledetailshow='no' where mobiledetailshow='yes';

    update ld_tab set ld_tab.mobiledetailinfoshowtype='tile';
END IF;

END ||
delimiter;

call ldcrm_addtable_fieldwxdetailinfo();
DROP PROCEDURE IF EXISTS `ldcrm_addtable_fieldwxdetailinfo`;
delimiter;

SET @labelbol = 'NOCONTENT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'暂无内容','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'No Content','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ICON','图标','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ICON' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ICON','Icon','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ICON' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ICON','图标','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ICON' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ICON','Icon','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ICON' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHETHERTOENABLE','是否启用','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WHETHERTOENABLE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHETHERTOENABLE','Whether to activate','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='WHETHERTOENABLE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHCAPITAL','搜索','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHCAPITAL' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHCAPITAL','Search ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHCAPITAL' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHCAPITAL','搜索','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHCAPITAL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHCAPITAL','Search ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SEARCHCAPITAL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

DELETE FROM ld_settings_field WHERE name='LBL_PAGE_SET';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RestoreAllDefaultIcon','恢复全部默认图标','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RestoreAllDefaultIcon' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RestoreAllDefaultIcon','Restore all default icon','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RestoreAllDefaultIcon' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_groups','group_no','varchar','100',0);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','GROUPNO','部门编号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GROUPNO' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','GROUPNO','Group No','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GROUPNO' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LBL_SUPEGROUPNO','上级部门编号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_SUPEGROUPNO' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LBL_SUPEGROUPNO','Superior Department No','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_SUPEGROUPNO' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LBL_SUPEGROUPNO','上级部门编号','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_SUPEGROUPNO' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LBL_SUPEGROUPNO','Superior Department No','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_SUPEGROUPNO' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel = '上级部门名称' where languagetype = 'zh' and labelbol = 'LBL_SUPEGROUP' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Superior Department Name' where languagetype = 'en' and labelbol = 'LBL_SUPEGROUP' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_groups SET group_no=REPLACE(parentgroup,'::','.');
delimiter;

UPDATE ld_tab SET mobiledetailinfoshowtype='tile' WHERE mobiledetailinfoshowtype='title' OR mobiledetailinfoshowtype IS NULL;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_biaoqian161to200`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_biaoqian161to200`(
)
BEGIN
DECLARE i int DEFAULT 161;
WHILE i<=200 DO
SET @tmp_tabid=(SELECT tabid FROM ld_field WHERE tablename=CONCAT('ld_customform',i) AND fieldname='tag');
SET @blockid=(SELECT blockid FROM ld_blocks WHERE tabid=@tmp_tabid AND blocklabel='LBL_LABEL');

UPDATE ld_field SET block=@blockid WHERE tabid=@tmp_tabid AND fieldname='tag';


SET i=i+1;
END WHILE;

end ||
delimiter;

CALL ldcrm_reset_biaoqian161to200();
DROP PROCEDURE IF EXISTS `ldcrm_reset_biaoqian161to200`;
delimiter;

SET @labelbol = 'RICHTEXTHIDE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'隐藏富文本框的修改日志','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Hide modification log of rich text box','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

update ld_field set bigtype='currency' where fieldname='hdnGrandTotal' and (tablename like '%ld_customform1%' or tablename like '%ld_customform2%');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TRYREFRESHING','刷新试试','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TRYREFRESHING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TRYREFRESHING','Try refreshing','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TRYREFRESHING' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid TEXT,
	tmp_reltab VARCHAR(100),
	tmp_related_to INT(19)
)
BEGIN

	DECLARE tmp_userid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			DISTINCT substring_index(substring_index(a.mytext,',', b.seq+1 ),',',- 1) AS mytext
		FROM (SELECT tmp_recieverid AS mytext) a
		LEFT JOIN sequence b ON b.seq <(length(a.mytext) - length( REPLACE(a.mytext,',',''))+1) 
		WHERE substring_index(substring_index(a.mytext,',', b.seq+1 ),',',- 1)+0>0
		ORDER BY b.seq;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;


	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_userid;
	WHILE(tmp_userid IS NOT NULL) DO
	
		SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
		INSERT INTO ld_crmentity(crmid,setype)
		SELECT @max_remindid+1,'Reminds';		

		UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
		
		INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
		SELECT @max_remindid+1,tmp_content,now(),tmp_userid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;
		
		FETCH MYCUSOR INTO tmp_userid;
	END WHILE;
	CLOSE MYCUSOR;


end ||
delimiter;
-- 2023-04-20

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

UPDATE ld_version SET old_version='V8.4.9.8',current_version='V8.4.9.8',remark='V8.4.9.8-20230420',wx_version='V8.4.9.8';
delimiter;