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

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
	tabname varchar(50),
	permissions int(19)
)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `fieldprofile`;
delimiter ||
CREATE  PROCEDURE `fieldprofile`(
 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;

UPDATE ld_field SET fieldonly=1 WHERE tabid=14 AND columnname='productcode';
-- 2020-03-20

DROP PROCEDURE IF EXISTS `reset_demoaccount_2020324`;
delimiter ||
CREATE  PROCEDURE `reset_demoaccount_2020324`(
)
BEGIN

	IF (SELECT COUNT(crmid) FROM (SELECT crmid FROM ld_crmentity WHERE setype<>'Reminds' LIMIT 1000) a)<500 THEN 
		ALTER TABLE ld_cashbackdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform11detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform12detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform13detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform14detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform15detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform16detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform17detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform18detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform19detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_customform20detail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_invoicedetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_outboundorderdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_potentialsdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_purchasebackdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_purchasecashbackdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_purchaseinquiryorderdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_purchaseinvoicedetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_purchaseorderdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_quoteschangedetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_quotesdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_salesbackdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_salesorderdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_servicecontractsdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_stockdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
		ALTER TABLE ld_warehousetransferdetail MODIFY COLUMN discount_percent DECIMAL(25,8);
	END IF;

end ||
delimiter;

CALL reset_demoaccount_2020324();
DROP PROCEDURE IF EXISTS `reset_demoaccount_2020324`;
-- 2020-03-24

DROP PROCEDURE IF EXISTS `reset_demoaccount_2020326`;
delimiter ||
CREATE  PROCEDURE `reset_demoaccount_2020326`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_tranlabel WHERE fieldlabel='淘宝订单信息' AND tabid=22 AND trantable='ld_blocks') THEN 
		SET @my_blockid=(SELECT Relateid FROM ld_tranlabel WHERE fieldlabel='淘宝订单信息' AND tabid=22 AND trantable='ld_blocks' LIMIT 1);
		UPDATE ld_blocks SET visible=1 WHERE blockid=@my_blockid AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=22 AND block=@my_blockid AND presence<>1);
	END IF;
    
  IF (SELECT COUNT(1) FROM ld_field WHERE tabid=23 AND columnname IN ('express_no','express_company'))=1 THEN
		SET @modulename='Invoice';
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='express_no' LIMIT 1);
		SET @seq=(SELECT sequence FROM ld_field WHERE tabid=@tabid AND block=@relateid AND columnname='express_no');
		SET @mypresence=(SELECT presence FROM ld_field WHERE tabid=@tabid AND block=@relateid AND columnname='express_no');
		SET @trantable='ld_field';
		SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='express_no' LIMIT 1);
		SET @columnname='express_company'; 
		SET @fieldname='express_company'; 
		SET @zh='物流公司'; 
		SET @en='Logistics Company'; 
		SET @uitype=15; 
		SET @typeofdata='V~O';
		SET @quickcreate=0;
		SET @displaytype=1;
		SET @bigtype='picklist';
		SET @datarang=NULL;
		SET @maxrowsshow=0;

		SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
	
		UPDATE ld_field SET sequence=sequence+2 WHERE tabid=@tabid AND block=@relateid AND sequence>=@seq;
		INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@mypresence,NULL,100,@seq,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

		UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

		SET @i=0;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@relateid ORDER BY sequence;

		SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

		CALl AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);

		CALL getallprofile(@modulename);
		CALL fieldprofile(@modulename);

	END IF;

end ||
delimiter;

CALL reset_demoaccount_2020326();
DROP PROCEDURE IF EXISTS `reset_demoaccount_2020326`;


SET @report_name='条码打印表_EAN8';
SET @report_type='template_js';
SET @report_template='default_barcode_ean8.mrt';
SET @setype='';
SET @report_describe='EAN8商品条码是纯数字，由7位数字和最后一位校验码组成8位数字，主要用于各种商品零售行业包装印刷。';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;

SET @report_name='条码打印表_EAN13';
SET @report_type='template_js';
SET @report_template='default_barcode_ean13.mrt';
SET @setype='';
SET @report_describe='EAN13商品条码是纯数字，由12位数字和最后一位校验码组成13位数字，主要用于各种商品零售行业包装印刷。';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;


SET @report_name='条码打印表_Code128b';
SET @report_type='template_js';
SET @report_template='default_barcode_code128b.mrt';
SET @setype='';
SET @report_describe='Code128b条码无固定位数，包括大小写字母、数字、常用标点符号。';
SET @report_url='';
SET @id=(SELECT id FROM ld_customreport_folder WHERE description='Tabular Data Reports');
SET @seq=(SELECT MAX(sequence) FROM ld_customreport_info WHERE folder_id=@id);

UPDATE ld_customreport_info SET sequence=sequence+1 WHERE folder_id=@id AND sequence>@seq;
INSERT INTO ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe,databaselinktype)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@seq+1,0,1,0,@setype,@report_describe,'crmlink' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_customreport_info WHERE report_template=@report_template AND systemdefault=1);
delimiter;
-- 2020-03-26

DROP PROCEDURE IF EXISTS `ldcrm_shujuzidian`;
delimiter ||
CREATE  PROCEDURE `ldcrm_shujuzidian`(
	tmp_modulelabel VARCHAR(100)
)
BEGIN

	SET @my_tabid=(
		SELECT
			GROUP_CONCAT(a.tabid) AS tabids
		FROM ld_tab a
		INNER JOIN ld_tranlabel b ON b.Relateid=a.tabid AND b.trantable='ld_tab'
		WHERE a.`name`=tmp_modulelabel
			OR b.fieldlabel=tmp_modulelabel
		GROUP BY a.tabid
	);

	SELECT
		bill_name AS '表单名称',
		block_name AS '区块名称',
		field_name AS '字段名称',
		filed_type AS '字段类型',
		table_name AS '数据库表名',
		show_name AS '显示名称（CH）'
	FROM (
		(SELECT
			1 AS type_seq,
			c.sequence AS block_seq,
			b.sequence AS field_seq,
			f.fieldlabel AS bill_name,
			CONCAT('单据表头-',e.fieldlabel) AS block_name,
			b.columnname AS field_name,
			s.COLUMN_TYPE AS filed_type,
			b.tablename AS table_name,
			d.fieldlabel AS show_name
		FROM ld_tab a
		LEFT JOIN ld_field b ON a.tabid=b.tabid
		LEFT JOIN ld_blocks c ON c.blockid=b.block
		LEFT JOIN ld_tranlabel d ON d.trantable='ld_field' AND d.Relateid=b.fieldid AND d.languagetype='zh'
		LEFT JOIN ld_tranlabel e ON e.trantable='ld_blocks' AND e.Relateid=c.blockid AND e.languagetype='zh'
		LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
		INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
		WHERE FIND_IN_SET(a.tabid,@my_tabid)
			AND b.presence<>1)
		UNION ALL
		(SELECT
			2 AS type_seq,
			1000000 AS block_seq,
			b.sequence AS field_seq,
			f.fieldlabel AS '表单名称',
			'单据分录-字段信息' AS '区块名称',
			b.columnname AS '字段名称',
			s.COLUMN_TYPE AS '字段类型',
			b.tablename AS '数据库表名',
			d.fieldlabel AS '显示名称（CH）'
		FROM ld_tab a
		LEFT JOIN ld_producttoolfield b ON a.tabid=b.tabid
		LEFT JOIN ld_tranlabel d ON d.trantable='ld_producttoolfield' AND d.Relateid=b.producttoolfieldid AND d.languagetype='zh'
		LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
		INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
		WHERE FIND_IN_SET(a.tabid,@my_tabid)
			AND b.presence<>1)
		UNION ALL
		(SELECT
			3 AS type_seq,
			1000001 AS block_seq,
			b.sequence AS field_seq,
			f.fieldlabel AS '表单名称',
			'单据分录-字段信息' AS '区块名称',
			b.columnname AS '字段名称',
			s.COLUMN_TYPE AS '字段类型',
			b.tablename AS '数据库表名',
			d.fieldlabel AS '显示名称（CH）'
		FROM ld_tab a
		LEFT JOIN ld_tabdetailfield b ON a.tabid=b.tabid
		LEFT JOIN ld_tranlabel d ON d.trantable='ld_tabdetailfield' AND d.Relateid=b.tabdetailfieldid AND d.languagetype='zh'
		LEFT JOIN ld_tranlabel f ON f.trantable='ld_tab' AND f.Relateid=a.tabid AND f.languagetype='zh'
		INNER JOIN information_schema.COLUMNS s ON s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME=b.tablename AND s.COLUMN_NAME=b.columnname
		WHERE FIND_IN_SET(a.tabid,@my_tabid)
			AND b.presence<>1)
	) tmp_zidan
	ORDER BY type_seq,block_seq,field_seq;

END ||
delimiter;


CALl AddColumn('ld_relatecreatecondition','contenttype','VARCHAR','100','db');
alter table ld_relatecreatecondition alter column contenttype set default 'db';

DROP PROCEDURE IF EXISTS `ldcrm_add_pricebooksid`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_pricebooksid`(
)
BEGIN
  
	DECLARE tmp_tabid INT(19) DEFAULT 0; 
	DECLARE tmp_module VARCHAR(100) DEFAULT ''; 

	DECLARE MYCUSOR CURSOR FOR 
		SELECT
			a.tabid,
			a.`name` AS modulename
		FROM ld_tab a
		INNER JOIN (SELECT tabid FROM ld_producttoolfield WHERE tabid>0 GROUP BY tabid) b ON b.tabid=a.tabid
		WHERE a.`name`<>'Productbom';

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	IF (SELECT COUNT(1) FROM ld_field WHERE columnname='pricebooksid' AND uitype=281)<10 AND NOT EXISTS (SELECT 1 FROM ld_version WHERE account='haige') THEN
		OPEN MYCUSOR; 
		FETCH MYCUSOR INTO tmp_tabid,tmp_module;
		WHILE(tmp_tabid IS NOT NULL) DO
			SET @modulename=tmp_module;
			SET @tabid=tmp_tabid;
			SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
			SET @trantable='ld_field';
			SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
			SET @columnname='pricebooksid'; 
			SET @fieldname='pricebooksid'; 
			SET @zh='价格表'; 
			SET @en='Price Book'; 
			SET @uitype=281; 
			SET @typeofdata='V~O';
			SET @quickcreate=1;
			SET @displaytype=3;
			SET @bigtype='reference';
			SET @datarang=NULL;
			SET @maxrowsshow=20;
			SET @presence=1;

			SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

			INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'INT','19',0);


		INSERT INTO ld_relatecreatecondition(modulename,columnname,comparator,content,relatecreatemodule,sequence,contenttype)
		SELECT 'PriceBooks','validfrom','m','today',@modulename,1,'db' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatecreatecondition WHERE modulename='PriceBooks' AND relatecreatemodule=@modulename AND columnname='validfrom');

		INSERT INTO ld_relatecreatecondition(modulename,columnname,comparator,content,relatecreatemodule,sequence,contenttype)
		SELECT 'PriceBooks','validtill','h','today',@modulename,1,'db' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatecreatecondition WHERE modulename='PriceBooks' AND relatecreatemodule=@modulename AND columnname='validtill');


			CALL getallprofile(@modulename);
			CALL fieldprofile(@modulename);
			
			FETCH MYCUSOR INTO tmp_tabid,tmp_module;
		END WHILE;
		CLOSE MYCUSOR;

		UPDATE ld_field SET allowedit='yes' WHERE columnname='pricebooksid';
	END IF;

END ||
delimiter;


CALL ldcrm_add_pricebooksid();
DROP PROCEDURE IF EXISTS `ldcrm_add_pricebooksid`;


insert into ld_ws_fieldtype(uitype,fieldtype)
select '281','reference' from dual 
where not exists(select * from ld_ws_referencetype where type='PriceBooks');
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=281;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'PriceBooks' from dual 
where not exists(select * from ld_ws_referencetype where type='PriceBooks');
delimiter;


CALl AddColumn('ld_pricebook','approvestatus','VARCHAR','100','');
CALl AddColumn('ld_pricebook','currentapprover','varchar','1000','');
CALl AddColumn('ld_pricebook','approvetime','datetime','10','');
CALl AddColumn('ld_pricebook','approveby','int','19','');
delimiter;
-- 2020-03-27


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

UPDATE ld_version SET old_version='V8.0.0.1',current_version='V8.0.0.1',remark='V8.0.0.1-20200330',wx_version='V8.0.0.1';
delimiter;