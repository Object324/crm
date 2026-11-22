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

UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,'组件模板','数据看板') WHERE labelbol IN ('LBL_TEMPLATES','TEMLATENAME','TemplatesCustomization');
UPDATE ld_desk SET fieldlabel='管理首页数据看板、设置看板关联的角色' WHERE labelbol='LBL_TEMPLATES_DESCRIPTION' AND fieldlabel='管理首页组件模板、设置模板关联角色';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlists_20220905`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_relatedlists_20220905`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_table VARCHAR(100) DEFAULT '';
	DECLARE tmp_module VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR 
			SELECT
				a.tabid,
				CASE
					WHEN c.name='CashBill' THEN 'ld_cashbill2paymentplan'
					WHEN c.name='SendCashBill' THEN 'ld_sendcashbill2payment'
					WHEN c.name='Checks' THEN 'ld_checksdetail'
					ELSE b.tablename
				END AS tablename,
				c.name
			FROM (
				SELECT
					tabid,
					tablename
				FROM ld_producttoolfield
				WHERE columnname='productname'
					AND tabid>0
				GROUP BY tabid
			) a
			LEFT JOIN (
				SELECT
					tabid,
					tablename
				FROM ld_producttoolfield
				WHERE columnname='quantity'
					AND tabid>0
				GROUP BY tabid
			) b ON b.tabid=a.tabid
			LEFT JOIN ld_tab c ON c.tabid=a.tabid
			WHERE 1=1
				AND a.tabid NOT IN (SELECT related_tabid FROM ld_relatedlists WHERE tabid=14)
				AND (
					CASE
						WHEN c.name='CashBill' THEN 'ld_cashbill2paymentplan'
						WHEN c.name='SendCashBill' THEN 'ld_sendcashbill2payment'
						WHEN c.name='Checks' THEN 'ld_checksdetail'
						ELSE b.tablename
					END) IS NOT NULL;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_tabid,tmp_table,tmp_module;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @module='Products';
		SET @related_module=tmp_module;
		SET @actions='add';
		SET @type='datacategory_sql';
		SET @related_coltable=CONCAT(RIGHT(tmp_table,LENGTH(tmp_table)-3),'.productid');
		SET @tabid=14;
		SET @rel_tabid=tmp_tabid;
		SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);

		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
		SELECT @relation_id+1,@tabid,@rel_tabid,CONCAT('get_',LOWER(@related_module)),@seq+1,@related_module,0,@actions,@type,@related_coltable FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND label=@related_module);

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		FETCH MYCUSOR INTO tmp_tabid,tmp_table,tmp_module;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_relatedlists_20220905();
DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlists_20220905`;

DROP PROCEDURE IF EXISTS `task_cooperativework_weekreport_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_weekreport_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR
		SELECT DISTINCT
			a.id
		FROM ld_users a
		LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
		LEFT JOIN ld_tab d ON d.tabid=c.tabid
		WHERE (d.`name`='CooperativeWork'
			AND permissions=0
			and d.presence in(0,2)
			AND a.`status`='Active' ) or (a.is_admin='on' AND a.`status`='Active');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	SET @remindtime='no';
	SELECT IFNULL(cooperativeworkweek,'no') INTO @remindtime FROM ld_workremindset LIMIT 1;

	SELECT count(1) into @cnt FROM ld_reminds WHERE content LIKE '周计划提交提醒：%' AND DATE_FORMAT(date_time,'%Y-%m-%d')=CURDATE() and reltab='CooperativeWork';

	IF @remindtime<>'no' AND WEEKDAY(NOW())IN (@remindtime-2,@remindtime-1) AND @cnt=0 THEN
		OPEN Mycur;
		FETCH Mycur INTO tmp_id;
		WHILE (tmp_id IS NOT NULL) DO
			IF NOT EXISTS (SELECT 1 FROM  ld_workreport where createdtime BETWEEN date_sub(curdate(),INTERVAL WEEKDAY(curdate()) + 0 DAY) and date_sub(curdate(),INTERVAL WEEKDAY(curdate()) - 6 DAY) and  type=2 AND smcreatorid=tmp_id) THEN
				IF WEEKDAY(NOW())=@remindtime-2 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，明天是最后一天期限哦');
				ELSEIF WEEKDAY(CURDATE())=@remindtime-1 THEN
					SET @content=CONCAT('周计划提交提醒：您该提交周计划啦，今天是最后一天期限哦');
				END IF;
				CALL ldcrm_add_reminder(@content,tmp_id,'CooperativeWork',0);
			END IF;
		FETCH Mycur INTO tmp_id;
		END WHILE;
		CLOSE Mycur;	
	END IF;

end ||
delimiter;

update ld_field set allowhide='yes' where columnname='sign_location_address' or columnname='location_address';
delimiter;

CALL AddColumn('ld_tab','detail_issticky','tinyint','2','3');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Exportstyles','导出样式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Exportstyles' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Exportstyles',"Export styles",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Exportstyles' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Exportmulticolheader','导出明细：单据头字段显示多行','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Exportmulticolheader' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Exportmulticolheader',"Export details: multiple lines are displayed in the document header field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Exportmulticolheader' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Exportfirstcolheader','导出明细：单据头字段仅显示首行','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Exportfirstcolheader' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Exportfirstcolheader',"Export details: only the first line is displayed in the document header field",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Exportfirstcolheader' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Exportonlycolheader','不导出明细：仅显示单据头字段（一行）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Exportonlycolheader' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Exportonlycolheader',"Do not export details: only display the document header field (one line)",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Exportonlycolheader' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetExportStyledefault','设置导出样式默认值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetExportStyledefault' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetExportStyledefault',"Set export style defaults",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetExportStyledefault' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='文本框' where labelbol='Inputbox' and languagetype='zh';
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tablesourcetype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单类型';
SET @zh='源单源单类型';
SET @en='Source Type';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tablesourceid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单';
SET @zh='源单源单';
SET @en='Source Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单日期';
SET @zh='源单日期';
SET @en='Source Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单金额';
SET @zh='源单金额';
SET @en='Source Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'pay_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单已付总额';
SET @zh='源单已付总额';
SET @en='Pay Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际付款金额';
SET @zh='实际付款金额';
SET @en='Actual payment amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill';
SET @sourcemodule = 'Stock';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'Stock';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'Stock';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'Stock';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'product_pay_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已付总额';
SET @zh='产品已付总额';
SET @en='Pay Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','product_pay_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际付款金额';
SET @zh='实际付款金额';
SET @en='Actual payment amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill';
SET @sourcemodule = 'Stock';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'billdate';
SET @curmodule_columninfo = 'billdate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"purchaseinvoicedate","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"purchaseinvoicedate","columntype":"main"},{"module":"Stock","column":"createdate","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;
SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'source_total';
SET @curmodule_columninfo = 'source_total';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"total","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"total","columntype":"main"},{"module":"Stock","column":"total","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;
SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'pay_amount';
SET @curmodule_columninfo = 'pay_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"pay_amount","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"pay_amount","columntype":"main"},{"module":"Stock","column":"pay_amount","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'amount';
SET @curmodule_columninfo = 'amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"pay_balance","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"pay_balance","columntype":"main"},{"module":"Stock","column":"pay_balance","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'productsourceid';
SET @curmodule_columninfo = 'productsourceid';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"entitytypeid","columntype":"detail"}]';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"entitytypeid","columntype":"detail"},{"module":"Stock","column":"entitytypeid","columntype":"detail"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'product_pay_amount';
SET @curmodule_columninfo = 'product_pay_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"havepayamount","columntype":"detail"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"havepayamount","columntype":"detail"},{"module":"Stock","column":"havepayamount","columntype":"detail"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'tablesourcetype';
SET @curmodule_columninfo = 'tablesourcetype';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"source_list","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"source_list","columntype":"main"},{"module":"Stock","column":"source_list","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'tablesourceid';
SET @curmodule_columninfo = 'tablesourceid';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"source_list","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"source_list","columntype":"main"},{"module":"Stock","column":"source_list","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'lastinvoicedate';
SET @curmodule_columninfo = 'lastinvoicedate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"purchaseinvoicedate","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"purchaseinvoicedate","columntype":"main"},{"module":"Stock","column":"purchaseinvoicedate","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'amount';
SET @curmodule_columninfo = 'amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '{"module":"PurchaseInvoice","column":"pay_balance","columntype":"main"}';
SET @fromvalue_info_new = '{"module":"PurchaseInvoice","column":"pay_balance","columntype":"main"},{"module":"Stock","column":"pay_balance","columntype":"main"}';
SET @frommodule = '';
update ld_related_detailfield set fromvalue_info=replace(fromvalue_info,@fromvalue_info,@fromvalue_info_new) WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type
and fromvalue_info LIKE CONCAT('%',@fromvalue_info,'%') and fromvalue_info not like '%Stock%';
delimiter;

UPDATE ld_tab SET mobilepresence = 'mobile,weixin',main_tablename = 'ld_checks',custom_tablename='ld_checkscf',primary_key = 'id' where name = 'Checks';
delimiter;

SET @blockid = (SELECT blockid from ld_appparenttab where parenttab_label = 'Inventory' LIMIT 1);
SET @sequence = (SELECT max(sequence) from ld_appparenttabrel where blockid = @blockid);
SET @tabid = (SELECT tabid from ld_tab where name = 'Checks');
INSERT into ld_appparenttabrel(blockid,tabid,sequence,relatename,tab_tablename)
SELECT @blockid,@tabid,@sequence+1,'','ld_tab' from dual
where not EXISTS(SELECT 1 from ld_appparenttabrel where tabid = @tabid and blockid = @blockid);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
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

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='Checks';
CALL ldcrm_add_cvcolumnlist_wx('Checks',CONCAT(LOWER('Checks'),'_no'),'1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Checks','smownerid','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx('Checks','checksdate','3','1','yes','yes');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Checks');
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,CONCAT(LOWER('Checks'),'_no'),1,'title',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname=CONCAT(LOWER('Checks'),'_no'));
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'checksdate',2,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='checksdate');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'wareid',3,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='wareid');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
SELECT @tabid,'assigned_user_id',4,'normal',0,'yes' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter;

UPDATE ld_cashbill SET entitytype=NULL,source_list=NULL WHERE cashtype='debuction' AND IFNULL(source_list,'')='' AND entitytype='SalesOrder';
ALTER TABLE ld_cashbill MODIFY COLUMN entitytype VARCHAR(100) DEFAULT NULL;
delimiter;
CALL AddColumn('ld_customtable_columns','styleset_header','text','','');
CALL AddColumn('ld_customtable_columns','styleset_body','text','','');
delimiter;
set @labelbol="HeaderStyleSettings";
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'表头样式设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol=@labelbol and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,"Header Style Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol=@labelbol and labeltype='fixedstr');
delimiter;


set @labelbol="TableBodyStyleSettings";
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'表体样式设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol=@labelbol and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,"Table Body Style Settings",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol=@labelbol and labeltype='fixedstr');
delimiter;

set @labelbol="Backgroundcolor";
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'背景色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol=@labelbol and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,"Background color",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol=@labelbol and labeltype='fixedstr');
delimiter;

set @labelbol="fontsize";
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'字体大小','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol=@labelbol and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,"font size",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol=@labelbol and labeltype='fixedstr');
delimiter;

set @labelbol="FontColor";
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'字体颜色','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol=@labelbol and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,"Font Color",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol=@labelbol and labeltype='fixedstr');
delimiter;

set @labelbol="BoldFont";
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'字体加粗','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol=@labelbol and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,"Bold Font",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol=@labelbol and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='The Sign-in field already exists in the module' WHERE labelbol= 'Labeltypefieldalreadyexistsinmodule' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='模块中已存在《签到》类型字段，保存失败！' WHERE labelbol= 'Labeltypefieldalreadyexistsinmodule' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

alter table ld_project modify targetbudget decimal(25,2) null;
delimiter;

update ld_field set bigtype='number'  where savedatabase='yes' and uitype=7 and input_type='formula';
delimiter;
-- 2022-09-16


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

UPDATE ld_version SET old_version='V8.4.7.5',current_version='V8.4.7.5',remark='V8.4.7.5-20220916',wx_version='V8.4.7.5';
delimiter;