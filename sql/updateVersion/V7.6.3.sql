DROP PROCEDURE IF EXISTS `ldcrm_add_chooseaccount`;
DROP PROCEDURE IF EXISTS `ldcrm_add_choosebillfield`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_choosebillfield`(
	tmp_modulename VARCHAR(100),
	tmp_uitype INT(19)
)
BEGIN

	-- 73 	单选客户
	-- 57 	单选联系人
	-- 76 	单选销售机会
	-- 82		单选项目
	-- 240 	单选服务单
	-- 241 	单选项目任务
	-- 59		单选产品
	-- 81   单选供应商
	-- 96		单选供应商联系人

	IF EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename) AND tmp_uitype IN (73,57,76,82,240,241,59,81,96) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
		SET @trantable='ld_field';
		
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND presence<>1 AND uitype IN (53,52) ORDER BY block,sequence LIMIT 1);
		SET @columnname=(SELECT columnname FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1);
		SET @fieldname=(SELECT fieldname FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1);
		SET @zh=(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_field' AND languagetype='zh' AND Relateid=(SELECT fieldid FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1) LIMIT 1); 
		SET @en=(SELECT fieldlabel FROM ld_tranlabel WHERE trantable='ld_field' AND languagetype='en' AND Relateid=(SELECT fieldid FROM ld_field WHERE uitype=tmp_uitype AND tablename IN ('ld_salesorder','ld_troubletickets','ld_purchaseorder','ld_contactrecords') LIMIT 1) LIMIT 1);  
		
		SET @uitype=tmp_uitype; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @presence=2;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@blockid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND uitype=@uitype LIMIT 1);
		SET @cnt=(SELECT COUNT(1) FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid);
		DELETE FROM ld_tranlabel WHERE trantable=@trantable AND tabid = @tabid AND relateid=@fieldid AND @cnt>2; 
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@fieldid,@zh FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid AND languagetype='zh');

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@fieldid,@en FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND trantable=@trantable AND relateid=@fieldid AND languagetype='en');

		CALl AddColumn(@tablename,@columnname,'INT','19',NULL);
		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

		IF tmp_uitype=73 THEN
			SET @choosetabid=6;
		ELSEIF tmp_uitype=57 THEN
			SET @choosetabid=4;
		ELSEIF tmp_uitype=76 THEN
			SET @choosetabid=2;
		ELSEIF tmp_uitype=82 THEN
			SET @choosetabid=48;
		ELSEIF tmp_uitype=240 THEN
			SET @choosetabid=13;
		ELSEIF tmp_uitype=241 THEN
			SET @choosetabid=47;
		ELSEIF tmp_uitype=59 THEN
			SET @choosetabid=14;
		ELSEIF tmp_uitype=81 THEN
			SET @choosetabid=18;
		ELSEIF tmp_uitype=81 THEN
			SET @choosetabid=(SELECT tabid FROM ld_tab WHERE name='VendorContact' LIMIT 1);
		END IF;

		SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@choosetabid);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@choosetabid,@tabid,LOWER(CONCAT('get_',tmp_modulename)),@seq+1,tmp_modulename,1,'add',LOWER(CONCAT(tmp_modulename,'.',@columnname)),'datacategory_sql' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@choosetabid AND related_tabid=@tabid);
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
	END IF;
end ||
delimiter;

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

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step1','http://51mis.com.cn/forum.php?mod=viewthread&tid=417&fromuid=1','采购发票模块导入第一页，选择导入文件' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step1');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step2','http://51mis.com.cn/forum.php?mod=viewthread&tid=417&fromuid=1','采购发票模块导入第二页，设置查重、映射字段，导入方式' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step2');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step3','http://51mis.com.cn/forum.php?mod=viewthread&tid=417&fromuid=1','采购发票模块导入第三页，导出结果' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step3');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step1','http://51mis.com.cn/forum.php?mod=viewthread&tid=416&fromuid=1','销售发票模块导入第一页，选择导入文件' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step1');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step2','http://51mis.com.cn/forum.php?mod=viewthread&tid=416&fromuid=1','销售发票模块导入第二页，设置查重、映射字段，导入方式' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step2');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step3','http://51mis.com.cn/forum.php?mod=viewthread&tid=416&fromuid=1','销售发票模块导入第三页，导出结果' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step3');
delimiter;

call AddColumn('ld_usereportcolumns','tabname','varchar',50,null );
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RETRACENotsubmitted','执行后，该单据将被还原到“未提交”状态，确定要撤销吗？','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='jspop' and labelbol='RETRACENotsubmitted');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','RETRACENotsubmitted','After execution, the document will be restored to the "Notsubmitted" state. Are you sure you want to do this?','jspop' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='jspop' and labelbol='RETRACENotsubmitted');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVERETRACERESULT','回撤到原始状态','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='APPROVERETRACERESULT');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVERETRACERESULT','Retreat to the original state','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='APPROVERETRACERESULT');
delimiter;

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','LOGINMODE','登录方式','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='LOGINMODE' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','LOGINMODE','Login mode','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='LOGINMODE' and languagetype='en' and Labeltype='fixedstr');

CALL AddColumn('ld_loginhistory','login_type','varchar','200',null);
delimiter;

UPDATE ld_desk SET fieldlabel='是否手机验证' WHERE labelbol='WHETHERTHEMOBILELANGING' AND languagetype='zh' AND Labeltype='fixedstr';
-- 2018-12-20

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOCREATEBILLNO','重复，已自动生成新的编号','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOCREATEBILLNO' and labeltype='jspop' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOCREATEBILLNO','is repetitive, a new one has been created automatically.','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOCREATEBILLNO' and labeltype='jspop' );
delimiter;
-- 2018-12-21


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

UPDATE ld_version SET old_version='V7.6.3',current_version='V7.6.3',remark='V7.6.3-20181221',wx_version='V7.6.3';
delimiter;