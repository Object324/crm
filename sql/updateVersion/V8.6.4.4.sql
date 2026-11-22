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

SET @blockid=(SELECT blockid FROM ld_settings_blocks WHERE label='LBL_OTHER_SETTINGS' LIMIT 1);
UPDATE ld_settings_field SET sequence=10000,blockid=@blockid WHERE `name`='LBL_WECHATAPPLICATION';
SET @i=0;
UPDATE ld_settings_field SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

update ld_cvcolumnlist set columnname = 'ld_account:upgrade_source:upgrade_source:Accounts_fieldlabel:V' where columnname like  '%ld_account:kis_no:kis_no:Accounts%';
delimiter;

update ld_cvcolumnlist set columnname = 'ld_potential:upgrade_source:upgrade_source:Potentials_fieldlabel:V' where columnname like  '%ld_potential:kis_no:kis_no:Potentials%';
delimiter;

call AddColumn('ld_account','upgrade_source','VARCHAR','50',NULL);
delimiter;

call AddColumn('ld_potential','upgrade_source','VARCHAR','50',NULL);
delimiter;

insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'upgrade_source','upgradeto_potentials','Potentials','UPGRADETOPOTENTIALS' from dual
where not exists(select 1 from ld_translatefield where module='Potentials' and columnname='upgrade_source' and column_dbvalue='upgradeto_potentials');
delimiter;

insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'upgrade_source','upgradeto_potentials','Accounts','UPGRADETOPOTENTIALS' from dual
where not exists(select 1 from ld_translatefield where module='Accounts' and columnname='upgrade_source' and column_dbvalue='upgradeto_potentials');
delimiter;

insert into ld_translatefield(columnname,column_dbvalue,module,labelbol)
select 'upgrade_source','from_leads','Accounts','UPGRADETOACCOUNT' from dual
where not exists(select 1 from ld_translatefield where module='Accounts' and columnname='upgrade_source' and column_dbvalue='from_leads');
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @trantable='ld_field';
SET @tablename='ld_account';
SET @columnname='upgrade_source';
SET @fieldname='upgrade_source';
set @bigtype="translatefield";
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,generatedtype,uitype,@fieldname,fieldlabel,readonly,presence ,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,@bigtype,datarang,maxrowsshow from ld_field 
where  columnname='kis_no' and tabid = @tabid
and  not exists(select * from ld_field where columnname='upgrade_source' and tabid = @tabid);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

select ld_tranlabel.fieldlabel into @zhfieldlabel  from ld_field 
INNER join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where ld_tranlabel.tabid=@tabid  and  columnname='kis_no' and languagetype='zh'
and ld_tranlabel.trantable=@trantable limit 1;

select ld_tranlabel.fieldlabel into @enfieldlabel  from ld_field 
INNER join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where ld_tranlabel.tabid=@tabid  and  columnname='kis_no' and languagetype='en'
and ld_tranlabel.trantable=@trantable limit 1;


INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zhfieldlabel FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@enfieldlabel FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

UPDATE ld_field set presence = 1 where tabid=@tabid  and  columnname='kis_no';
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials');
SET @trantable='ld_field';
SET @tablename='ld_potential';
SET @columnname='upgrade_source';
SET @fieldname='upgrade_source';
SET @bigtype='translatefield';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,generatedtype,uitype,@fieldname,fieldlabel,readonly,presence ,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,@bigtype,datarang,maxrowsshow from ld_field 
where  columnname='kis_no' and tabid = @tabid
and  not exists(select * from ld_field where columnname= @columnname and tabid = @tabid);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

select ld_tranlabel.fieldlabel into @zhfieldlabel  from ld_field 
INNER join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where ld_tranlabel.tabid=@tabid  and  columnname='kis_no' and languagetype='zh'
and ld_tranlabel.trantable=@trantable limit 1;

select ld_tranlabel.fieldlabel into @enfieldlabel  from ld_field 
INNER join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where ld_tranlabel.tabid=@tabid  and  columnname='kis_no' and languagetype='en'
and ld_tranlabel.trantable=@trantable limit 1;

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zhfieldlabel FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@enfieldlabel FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

UPDATE ld_field set presence = 1 where tabid=@tabid  and  columnname='kis_no';
delimiter;

SET @disable_triggers = 'aa';
UPDATE ld_account
SET upgrade_source = kis_no where kis_no in ('from_leads','upgradeto_potentials') and ifnull(upgrade_source, '') = '';
UPDATE ld_potential
SET upgrade_source = kis_no where kis_no in ('from_leads','upgradeto_potentials') and ifnull(upgrade_source, '') = '';
SET @disable_triggers = NULL;
delimiter;


UPDATE ld_homestuffdetail set advance_demand = REPLACE(advance_demand,'kis_no:kis_no','upgrade_source:upgrade_source') where advance_demand like "%ld_account:kis_no:kis_no%" or advance_demand like "%ld_potential:kis_no:kis_no%";

UPDATE ld_homeboard_plate_filter set advance_demand = REPLACE(advance_demand,'kis_no:kis_no','upgrade_source:upgrade_source') where (advance_demand like "%ld_account:kis_no:kis_no%" or advance_demand like "%ld_potential:kis_no:kis_no%") and conditionkey = "highsearch";

UPDATE ld_customreport set advance_demand = REPLACE(advance_demand,'kis_no:kis_no','upgrade_source:upgrade_source') where advance_demand like "%ld_account:kis_no:kis_no%" or advance_demand like "%ld_potential:kis_no:kis_no%";

UPDATE ld_customtable_condition set `columns` = REPLACE(`columns`,'kis_no:kis_no','upgrade_source:upgrade_source') where `columns` like "%ld_account:kis_no:kis_no%" or `columns` like "%ld_potential:kis_no:kis_no%";
delimiter;

SET @labelbol = 'SETEMPTY';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'清空',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Empty',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'Quit';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'离职',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Quit',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'ImgPathNoEmpty';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'图片路径不能为空',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The picture path cannot be empty',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);
delimiter;


DROP PROCEDURE IF EXISTS `lingdang_add_profile2standardpermissions`;
delimiter ||
CREATE PROCEDURE `lingdang_add_profile2standardpermissions`(
    tmp_tabid INT(19),
    tmp_addactionid INT(19),
    tmp_permissions INT(19)
        )
BEGIN

DECLARE tmp_profileid INT(19) DEFAULT 0;
DECLARE THIS_CUSOR CURSOR FOR SELECT profileid FROM ld_profile;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

OPEN THIS_CUSOR;
FETCH THIS_CUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO

	INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions)
	SELECT tmp_profileid,tmp_tabid,tmp_addactionid,IF(tmp_permissions>=1,1,0) FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid=tmp_profileid AND tabid=tmp_tabid AND operation=tmp_addactionid);
FETCH THIS_CUSOR INTO tmp_profileid;
END WHILE;
CLOSE THIS_CUSOR;

END ||
delimiter;


SET @modulename = 'Expense';
SET @tabid = (SELECT tabid FROM ld_tab where `name`=@modulename);
SET @labelbol=UPPER('DownloadInvoice');
SET @labeltype='fixedstr';
SET @zh='下载发票';
SET @en='Download invoice';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@labelbol AND labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@labelbol AND labeltype=@labeltype);
delimiter;

SET @add_actionname='DownloadInvoice';
SET @max_actionid=(SELECT MAX(actionid) FROM ld_actionmapping);
INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @max_actionid+1,@add_actionname,0,UPPER(@add_actionname) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname=@add_actionname);
delimiter;

SET @tmp_actionid=(SELECT actionid FROM ld_actionmapping WHERE actionname=@add_actionname LIMIT 1);
SET @sequence=IFNULL((SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=@tabid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@tmp_actionid,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@tmp_actionid);

CALL lingdang_add_profile2standardpermissions(@tabid,@tmp_actionid,0);
delimiter;


SET @modulename = 'Expense';
SET @tabid = (SELECT tabid FROM ld_tab where `name`=@modulename);
SET @labelbol=UPPER('ViewInvoice');
SET @labeltype='fixedstr';
SET @zh='查看发票';
SET @en='View invoice';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol=@labelbol AND labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol=@labelbol AND labeltype=@labeltype);
delimiter;

SET @add_actionname='ViewInvoice';
SET @max_actionid=(SELECT MAX(actionid) FROM ld_actionmapping);
INSERT INTO ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT @max_actionid+1,@add_actionname,0,UPPER(@add_actionname) FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping WHERE actionname=@add_actionname);
delimiter;

SET @tmp_actionid=(SELECT actionid FROM ld_actionmapping WHERE actionname=@add_actionname LIMIT 1);
SET @sequence=IFNULL((SELECT MAX(sequence) FROM ld_profileallpermission WHERE tabid=@tabid),0);
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,@tmp_actionid,@sequence+1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@tmp_actionid);

CALL lingdang_add_profile2standardpermissions(@tabid,@tmp_actionid,0);
DROP PROCEDURE IF EXISTS `lingdang_add_profile2standardpermissions`;
delimiter;


CALL AddColumn('ld_expense','invoicetotal','decimal','25,2','');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_piaozone` (
    `id` int(11)  NOT NULL AUTO_INCREMENT,
    `crmid` int(19) DEFAULT NULL,
    `invoicetype` tinyint(1) DEFAULT 0,
    `invoicetype_zh` varchar(50) DEFAULT NULL,
    `invoicecode` varchar(50) DEFAULT NULL COMMENT '发票代码',
    `invoiceno` varchar(50) DEFAULT NULL COMMENT '发票号码',
    `invoicedate` date DEFAULT NULL COMMENT '开票日期',
    `totalamount` decimal(25,2) DEFAULT NULL COMMENT '发票金额',
    `buyername` varchar(255) DEFAULT NULL COMMENT '购方名称',
    `salername` varchar(255) DEFAULT NULL COMMENT '销方名称',
    `serialno` varchar(100) DEFAULT NULL COMMENT '发票流水号',
    `downloadurl` varchar(255) DEFAULT NULL,
    `snapshoturl` varchar(255) DEFAULT NULL,
    `invoicedata` text COMMENT '发票票面数据',
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)  USING BTREE,
    UNIQUE INDEX idx_serialno (serialno),
    INDEX idx_crmid (crmid)
    ) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

insert into ld_wx_config (name,description) select 'piaozone_setting','发票云设置' from dual where not exists(select 1 from ld_wx_config where name='piaozone_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ImportInvoice','导入发票','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ImportInvoice' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ImportInvoice','Import invoice','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ImportInvoice' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DeleteInvoice','删除发票','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DeleteInvoice' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DeleteInvoice',"Delete invoice",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DeleteInvoice' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceDetailsInfo','发票明细信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceDetailsInfo' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceDetailsInfo','Invoice details information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceDetailsInfo' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceType','发票类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceType' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceType','Invoice type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceType' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceCode','发票代码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceCode' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceCode','Invoice code','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceCode' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceNumber','发票号码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceNumber' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceNumber','Invoice number','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceNumber' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceDate','开票日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceDate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceDate','Invoice date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceDate' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceTotalAmount','发票金额','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceTotalAmount' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceTotalAmount','Invoice amount','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceTotalAmount' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceBuyername','购方名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceBuyername' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceBuyername',"Purchaser's name",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceBuyername' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','InvoiceTotal','发票合计','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceTotal' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','InvoiceTotal',"Total invoice",'fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='InvoiceTotal' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','InvoiceDetailsCannotEmpty','发票明细项不能为空','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='InvoiceDetailsCannotEmpty' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','InvoiceDetailsCannotEmpty','Invoice details cannot be empty','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='InvoiceDetailsCannotEmpty' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DOWNLOAD','下载','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOWNLOAD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DOWNLOAD','Download','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOWNLOAD' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','VIEW','查看','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='VIEW' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','VIEW','View','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='VIEW' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','InvoiceHelper','发票助手','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='InvoiceHelper' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','InvoiceHelper','Invoice assistant','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='InvoiceHelper' and Labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_reminder`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_reminder`(
    tmp_reporttype VARCHAR(19),
    tmp_userid INT(11),
    tmp_eventdate datetime,
    tmp_nowtime datetime
        )
BEGIN
	DECLARE tmp_rule_range VARCHAR(19) DEFAULT '';
	DECLARE tmp_rule_value VARCHAR(19) DEFAULT '';
	DECLARE tmp_remind_num INT(11) DEFAULT '';
	DECLARE tmp_deadline_date VARCHAR(19) DEFAULT '';
	DECLARE tmp_remind_time time DEFAULT '';
	DECLARE tmp_first_value INT(11) DEFAULT '';
	DECLARE tmp_second_value INT(11) DEFAULT '';
	DECLARE tmp_third_value INT(11) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
SELECT rule_range,rule_value,remind_num,deadline_date,remind_time,`first_value`,second_value,third_value
FROM ld_workreport_rulesettings WHERE type = tmp_reporttype AND `status` = 'yes' and remind_num >0 ORDER BY sequence;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;

-- 	SET @event_interval_value = (select interval_value from information_schema.`EVENTS` where event_schema = DATABASE() AND event_name = CONCAT('task_cooperativework',tmp_reporttype,'_eventreminder'));
-- 	SET @event_interval_field = (select interval_field from information_schema.`EVENTS` where event_schema = DATABASE() AND event_name = CONCAT('task_cooperativework',tmp_reporttype,'_eventreminder'));
-- 	SET @event_minutes = CASE
-- 			WHEN @event_interval_field = 'SECOND' THEN @event_interval_value / 60
-- 			WHEN @event_interval_field = 'MINUTE' THEN @event_interval_value
-- 			WHEN @event_interval_field = 'HOUR' THEN @event_interval_value * 60
-- 			WHEN @event_interval_field = 'DAY' THEN @event_interval_value * 1440
-- 			WHEN @event_interval_field = 'WEEK' THEN @event_interval_value * 10080
-- 			ELSE '10' END;
	SET @event_minutes = '10';

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_rule_range,tmp_rule_value,tmp_remind_num,tmp_deadline_date,tmp_remind_time,tmp_first_value,tmp_second_value,tmp_third_value;
WHILE(tmp_userid IS NOT NULL) DO
			IF tmp_rule_range = 'all' THEN SET @remind_status='yes';
			ELSEIF tmp_rule_range = 'user' AND FIND_IN_SET(tmp_userid,tmp_rule_value)
				THEN SET @remind_status='yes';
			ELSEIF tmp_rule_range = 'group' AND
								tmp_userid IN (SELECT GROUP_CONCAT(userid SEPARATOR ',') AS userid_str FROM ld_users2group WHERE groupid IN (tmp_rule_value))
								THEN SET @remind_status='yes';
			ELSEIF tmp_rule_range = 'role' AND EXISTS(SELECT 1 from ld_users where id=tmp_userid and profileid in (tmp_rule_value))
								THEN SET @remind_status='yes';
ELSE SET @remind_status='no';
END IF;

			IF @remind_status = 'yes' AND tmp_remind_num > 0 THEN
					IF tmp_remind_num > 0 THEN
						-- 第一次提醒提前时间范围
						SET @first_remind_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_SUB(tmp_remind_time, INTERVAL (60 * tmp_first_value) MINUTE)
									ELSE tmp_remind_time END;
						SET @first_end_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_ADD(tmp_remind_time, INTERVAL (60 * tmp_first_value + @event_minutes + 2) MINUTE)
									ELSE DATE_ADD(tmp_remind_time, INTERVAL @event_minutes + 2 MINUTE) END;
						SET @deadline_date = CONVERT(tmp_deadline_date, DECIMAL);
						-- 	第一次提醒日期/星期几
						SET @first_date = CASE
									WHEN tmp_reporttype = 'day' THEN CURDATE()
									WHEN tmp_reporttype = 'week' THEN CAST(tmp_deadline_date AS DECIMAL) - CAST(tmp_first_value AS DECIMAL)
									WHEN tmp_reporttype = 'month' THEN
											CASE
											WHEN @deadline_date >=20 AND @deadline_date <=28
												THEN DATE_SUB(STR_TO_DATE(CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m'), '-', @deadline_date), '%Y-%m-%d'),INTERVAL tmp_first_value DAY)
											WHEN @deadline_date = 40
												THEN DATE_SUB(LAST_DAY(CURDATE()),INTERVAL tmp_first_value DAY)
											WHEN @deadline_date >= 1 AND @deadline_date <= 5
												THEN DATE_SUB(DATE_FORMAT(CURDATE() ,CONCAT('%Y-%m-0',@deadline_date)),INTERVAL tmp_first_value DAY)
END
END;
						-- 提醒处理
							IF (tmp_reporttype = 'day' OR tmp_reporttype = 'month') THEN
								SET @first_remind_datetime = STR_TO_DATE(CONCAT(@first_date, ' ', @first_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @first_end_datetime = STR_TO_DATE(CONCAT(@first_date, ' ', @first_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @first_remind_datetime AND tmp_nowtime >= @first_remind_datetime AND tmp_nowtime < @first_end_datetime
									THEN
										IF tmp_reporttype = 'day' THEN SET @content = CONCAT('日志提交提醒：您该提交日志啦，还有',tmp_first_value,'个小时就到提交期限哦');
										ELSEIF tmp_reporttype = 'month' THEN SET @content = CONCAT('月计划提交提醒：您该提交月计划啦，还有',tmp_first_value,'天就到提交期限哦');
END IF;
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
							ELSEIF tmp_reporttype = 'week' AND DAYOFWEEK(CURDATE()) = @first_date THEN
								SET @first_remind_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @first_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @first_end_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @first_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @first_remind_datetime AND tmp_nowtime >= @first_remind_datetime AND tmp_nowtime< @first_end_datetime
									THEN SET @content = CONCAT('周计划提交提醒：您该提交周计划啦，还有',tmp_first_value,'天就到提交期限哦');
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
END IF;
END IF;

					IF tmp_remind_num > 1 THEN
						-- 第一次提醒提前时间范围
						SET @second_remind_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_SUB(tmp_remind_time, INTERVAL (60 * tmp_second_value) MINUTE)
									ELSE tmp_remind_time END;
						SET @second_end_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_ADD(tmp_remind_time, INTERVAL (60 * tmp_second_value +  @event_minutes + 2) MINUTE)
									ELSE DATE_ADD(tmp_remind_time, INTERVAL @event_minutes + 2 MINUTE) END;
						SET @deadline_date = CONVERT(tmp_deadline_date, DECIMAL);
						-- 	第一次提醒日期/星期几
						SET @second_date = CASE
									WHEN tmp_reporttype = 'day' THEN CURDATE()
									WHEN tmp_reporttype = 'week' THEN CAST(tmp_deadline_date AS DECIMAL) - CAST(tmp_second_value AS DECIMAL)
									WHEN tmp_reporttype = 'month' THEN
											CASE
											WHEN @deadline_date >=20 AND @deadline_date <=28
												THEN DATE_SUB(STR_TO_DATE(CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m'), '-', @deadline_date), '%Y-%m-%d'),INTERVAL tmp_second_value DAY)
											WHEN @deadline_date = 40
												THEN DATE_SUB(LAST_DAY(CURDATE()),INTERVAL tmp_second_value DAY)
											WHEN @deadline_date >= 1 AND @deadline_date <= 5
												THEN DATE_SUB(DATE_FORMAT(CURDATE() ,CONCAT('%Y-%m-0',@deadline_date)),INTERVAL tmp_second_value DAY)
END
END;
						-- 提醒处理
						IF (tmp_reporttype = 'day' OR tmp_reporttype = 'month') THEN
								SET @second_remind_datetime = STR_TO_DATE(CONCAT(@second_date, ' ', @second_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @second_end_datetime = STR_TO_DATE(CONCAT(@second_date, ' ', @second_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @second_remind_datetime AND tmp_nowtime >= @second_remind_datetime AND tmp_nowtime < @second_end_datetime
									THEN
										IF tmp_reporttype = 'day' THEN SET @content = CONCAT('日志提交提醒：您该提交日志啦，还有',tmp_second_value,'个小时就到提交期限哦');
										ELSEIF tmp_reporttype = 'month' THEN SET @content = CONCAT('月计划提交提醒：您该提交月计划啦，还有',tmp_second_value,'天就到提交期限哦');
END IF;
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
							ELSEIF tmp_reporttype = 'week' AND DAYOFWEEK(CURDATE()) = @second_date THEN
								SET @second_remind_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @second_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @second_end_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @second_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @second_remind_datetime AND tmp_nowtime >= @second_remind_datetime AND tmp_nowtime< @second_end_datetime
									THEN SET @content = CONCAT('周计划提交提醒：您该提交周计划啦，还有',tmp_second_value,'天就到提交期限哦');
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
END IF;

END IF;

					IF tmp_remind_num > 2 THEN
						-- 第一次提醒提前时间范围
						SET @third_remind_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_SUB(tmp_remind_time, INTERVAL (60 * tmp_third_value ) MINUTE)
									ELSE tmp_remind_time END;
						SET @third_end_time = CASE
									WHEN tmp_reporttype = 'day' THEN DATE_ADD(tmp_remind_time, INTERVAL (60 * tmp_third_value +  @event_minutes + 2 ) MINUTE)
									ELSE DATE_ADD(tmp_remind_time, INTERVAL @event_minutes + 2 MINUTE) END;
						SET @deadline_date = CONVERT(tmp_deadline_date, DECIMAL);
						-- 	第一次提醒日期/星期几
						SET @third_date = CASE
									WHEN tmp_reporttype = 'day' THEN CURDATE()
									WHEN tmp_reporttype = 'week' THEN CAST(tmp_deadline_date AS DECIMAL) - CAST(tmp_third_value AS DECIMAL)
									WHEN tmp_reporttype = 'month' THEN
											CASE
											WHEN @deadline_date >=20 AND @deadline_date <=28
												THEN DATE_SUB(STR_TO_DATE(CONCAT(DATE_FORMAT(CURDATE(), '%Y-%m'), '-', @deadline_date), '%Y-%m-%d'),INTERVAL tmp_third_value DAY)
											WHEN @deadline_date = 40
												THEN DATE_SUB(LAST_DAY(CURDATE()),INTERVAL tmp_third_value DAY)
											WHEN @deadline_date >= 1 AND @deadline_date <= 5
												THEN DATE_SUB(DATE_FORMAT(CURDATE() ,CONCAT('%Y-%m-0',@deadline_date)),INTERVAL tmp_third_value DAY)
END
END;
						-- 提醒处理
						IF (tmp_reporttype = 'day' OR tmp_reporttype = 'month') THEN
								SET @third_remind_datetime = STR_TO_DATE(CONCAT(@third_date, ' ', @third_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @third_end_datetime = STR_TO_DATE(CONCAT(@third_date, ' ', @third_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @third_remind_datetime AND tmp_nowtime >= @third_remind_datetime AND tmp_nowtime < @third_end_datetime
									THEN
										IF tmp_reporttype = 'day' THEN SET @content = CONCAT('日志提交提醒：您该提交日志啦，还有',tmp_third_value,'个小时就到提交期限哦');
										ELSEIF tmp_reporttype = 'month' THEN SET @content = CONCAT('月计划提交提醒：您该提交月计划啦，还有',tmp_third_value,'天就到提交期限哦');
END IF;
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
							ELSEIF tmp_reporttype = 'week' AND DAYOFWEEK(CURDATE()) = @third_date THEN
								SET @third_remind_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @third_remind_time), '%Y-%m-%d %H:%i:%s');
								SET @third_end_datetime = STR_TO_DATE(CONCAT(DATE_FORMAT(tmp_nowtime,"%Y-%m-%d"), ' ', @third_end_time), '%Y-%m-%d %H:%i:%s');
								IF tmp_eventdate < @third_remind_datetime AND tmp_nowtime >= @third_remind_datetime AND tmp_nowtime< @third_end_datetime
									THEN SET @content = CONCAT('周计划提交提醒：您该提交周计划啦，还有',tmp_third_value,'天就到提交期限哦');
CALL ldcrm_add_reminder_havetype(@content,tmp_userid,'CooperativeWork',0,'WorkReportRemind');
END IF;
END IF;

END IF;

					SET tmp_userid = NULL;
END IF;

FETCH MYCUSOR INTO tmp_rule_range,tmp_rule_value,tmp_remind_num,tmp_deadline_date,tmp_remind_time,tmp_first_value,tmp_second_value,tmp_third_value;
END WHILE ;
CLOSE MYCUSOR;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_cooperativework_reminder_exec`;
delimiter ||
CREATE PROCEDURE `task_cooperativework_reminder_exec`(
    tmp_reporttype VARCHAR(19)
)
BEGIN
	DECLARE tmp_userid INT DEFAULT 0;
	DECLARE MYCUSOR CURSOR FOR
SELECT DISTINCT a.id FROM ld_users a
                              LEFT JOIN ld_profile2standardpermissions c ON c.profileid=a.profileid
                              LEFT JOIN ld_tab d ON d.tabid=c.tabid
WHERE (d.`name`='CooperativeWork' AND permissions=0 AND d.presence in(0,2) AND a.`status`='Active' )
   OR (a.is_admin='on' AND a.`status`='Active');
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;

	SET @eventdatetime = (SELECT eventdate from ld_sys_event where type = CONCAT('task_cooperativework',tmp_reporttype,'_eventreminder'));
	SET @nowdatetime = NOW();
	SET @daytime = DAY(@nowdatetime);

	IF NOT EXISTS (SELECT 1 FROM ld_module_setting_byuser WHERE modulename = 'WorkTemplateRule' AND label = tmp_reporttype AND content = 'no') AND
		 EXISTS (SELECT 1 FROM ld_workreport_rulesettings WHERE type = tmp_reporttype AND `status` = 'yes' LIMIT 1 ) THEN
				OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_userid;
WHILE(tmp_userid IS NOT NULL) DO
					-- 是否已写日周月
					SET @remind_status = CASE
							WHEN tmp_reporttype = 'day'
									 AND NOT EXISTS(SELECT 1 FROM ld_workreport WHERE  DATE_FORMAT(createdtime,"%Y-%m-%d")=CURDATE() AND smcreatorid=tmp_userid and type=1)
							THEN 'yes'
							WHEN tmp_reporttype = 'week'
									 AND NOT EXISTS(SELECT 1 FROM  ld_workreport where createdtime BETWEEN date_sub(curdate(),INTERVAL WEEKDAY(curdate()) + 0 DAY)
									 AND date_sub(curdate(),INTERVAL WEEKDAY(curdate()) - 6 DAY) AND type=2 AND smcreatorid=tmp_userid)
							THEN 'yes'
							WHEN tmp_reporttype = 'month' AND (@daytime <= 5 OR @daytime >= 20)
									 AND NOT EXISTS(SELECT 1 FROM ld_workreport WHERE DATE_FORMAT(createdtime,"%Y-%m")=DATE_FORMAT(CURDATE(),"%Y-%m")  AND smcreatorid=tmp_userid and type=3)
							THEN 'yes'
							ELSE 'no' END;

					IF @remind_status = 'yes' THEN
						CALL task_cooperativework_reminder(tmp_reporttype,tmp_userid,@eventdatetime,@nowdatetime);
END IF;
FETCH MYCUSOR INTO tmp_userid;
END WHILE;
CLOSE MYCUSOR;
END IF;
UPDATE ld_sys_event set eventdate = NOW() where type = CONCAT('task_cooperativework',tmp_reporttype,'_eventreminder');
end ||
delimiter;



DROP PROCEDURE IF EXISTS `ldcrm_reset_nianjianinfo`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_nianjianinfo`(
)
BEGIN

	DECLARE tmp_userid INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT
			a.id
		FROM ld_users a
		WHERE a.hire_date>'1900-01-01'
			AND DATE_FORMAT(a.hire_date,'%m-%d')=DATE_FORMAT(NOW(),'%m-%d');
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_userid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_userid;

	WHILE(tmp_userid IS NOT NULL) DO
		CALL ldcrm_update_sykq_byuserid(tmp_userid);
		FETCH MYCUSOR INTO tmp_userid;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

DROP EVENT IF EXISTS `ldcrm_reset_nianjianinfo_event`;
delimiter ||
CREATE  EVENT `ldcrm_reset_nianjianinfo_event` ON SCHEDULE EVERY 1 DAY STARTS '2024-09-01 00:01:00' ON COMPLETION NOT PRESERVE ENABLE DO 
CALL ldcrm_reset_nianjianinfo();
||
delimiter;

ALTER TABLE ld_users ALTER COLUMN crm_user_type SET DEFAULT 'crm';
delimiter;

ALTER TABLE ld_groups ALTER COLUMN group_type SET DEFAULT 'crm';
delimiter;

update ld_users set crm_user_type = 'crm' where ISNULL(crm_user_type);
delimiter;

update ld_groups set group_type = 'crm' where ISNULL(group_type);
delimiter;

SET @labelbol = 'EDITCONTENTPICKLISTVALUE';
set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑%s下拉框列表值',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,"Edit the %s's value of the drop-down list",@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel="删除%s多选框选项" where labelbol='DELETEMULTIPICKLISTVALUE' and languagetype='zh';
UPDATE ld_desk SET fieldlabel="Delete the %s's smulti-drop-down option" where labelbol='DELETEMULTIPICKLISTVALUE' and languagetype='en';
delimiter;
UPDATE ld_desk SET fieldlabel="删除%s下拉框选项" where labelbol='DELETEPICKLISTVALUE' and languagetype='zh';
UPDATE ld_desk SET fieldlabel="Delete the %s's drop-down option" where labelbol='DELETEPICKLISTVALUE' and languagetype='en';
delimiter;

drop PROCEDURE if EXISTS add_subtotal_field_bill_20240903;
delimiter ||
create PROCEDURE add_subtotal_field_bill_20240903
(
    var_moudule varchar(100)
)
BEGIN
	DECLARE var_module varchar(100);
	DECLARE var_sourcemodule varchar(100);
	DECLARE var_tabid INT(100);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select ld_option_module.tabid as tabid,`name` as sourcemodule from ld_option_module
                                                                                                                                                   INNER JOIN ld_tab ON ld_tab.tabid=ld_option_module.option_tabid
                            where ld_option_module.tabid=(SELECT tabid  from ld_tab WHERE `name`=var_moudule) and option_tabid NOT IN(SELECT tabid from ld_tab where `name` in ('PaymentPlan','SendPayment'));
declare continue handler  for not   found  SET done =1;

OPEN cur1;

Fetch cur1 into var_tabid,var_sourcemodule;
loop1: while  done<>1 DO
		SET @sourcemodule = var_sourcemodule;
		SET @tabid = var_tabid;
		SET @maxproducttoolfieldid = (SELECT max(producttoolfieldid) FROM ld_producttoolfield );
		SET @columnname = 'subtotal';
		SET @tablename = (SELECT tablename FROM ld_field WHERE tabid = @tabid and columnname ='smownerid');
		SET @trantable='ld_producttoolfield';
		SET @zh='小计';
		SET @en='Sub Total';

		SET @maxsequence = (SELECT max(sequence) FROM ld_producttoolfield WHERE tabid=@tabid);
		SET @fieldid = (select fieldid from ld_field where columnname = 'subtotal' and tabid=@tabid);
INSERT INTO `ld_producttoolfield` (`producttoolfieldid`, `columnname`, `allowhide`, `fieldlabel`, `defaultvalue`, `presence`, `uitype`, `typeofdata`, `sequence`, `tabid`, `tablename`, `width`, `edit_permission`, `input_type`, `fieldid`, `newline`, `defaultcolumn`, `is_checkimportfield`, `description`, `nullfield`, `referencemodule`, `datarange`, `approve_demand`, `maxrowsshow`, `bigtype`, `savedatabase`, `fieldvaluecolor`, `fieldplaceholder`, `effectivecondition`, `parentbigtype`, `sourcemodule`, `mobiledetailshow`, `relatedmodulefield`, `showhyperlinks`, `subtotal_attr`, `autowordwrap`, `editpage`)
SELECT @maxproducttoolfieldid+1,@columnname , 'yes', '小计', '0', '0', '33', 'N~O~25,2', @maxsequence+1, @tabid, @tablename, '22', '1', '0', @fieldid, '2', '3', '0', NULL, '1', NULL, NULL, NULL, '0', NULL, 'yes', NULL, NULL, NULL, NULL, @sourcemodule, NULL, 'no', 'yes', NULL, 'yes', NULL FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid = @tabid AND columnname = @columnname AND sourcemodule=@sourcemodule);

SET @relateid=(SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname AND sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
Fetch cur1 into var_tabid,var_sourcemodule;
end while loop1;
close cur1;
end ||
delimiter;
CALL add_subtotal_field_bill_20240903('SendCashBill');
CALL add_subtotal_field_bill_20240903('CashBill');
delimiter;

UPDATE ld_desk set fieldlabel='全部的相关信息' WHERE labelbol='ChangeAllData' and languagetype='zh' and labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='All relevant information' WHERE labelbol='ChangeAllData' and languagetype='en' and labeltype='fixedstr';
delimiter;

update ld_module_setting_byuser set content = 'https://help.51mis.com/' where label = 'HelpUrl_AllHelp';
delimiter;

UPDATE ld_customview set ld_customview.groupid = 0 where ld_customview.groupid > 0 and ld_customview.groupid not in (SELECT ld_customviewgroup.groupid from ld_customviewgroup);
delimiter;

UPDATE ld_module_setting_byuser SET content = 
  	CASE WHEN (SELECT COUNT(1) FROM ld_communicationaccount as com WHERE com.service_tel IS NOT NULL AND com.service_tel != '') > 0 THEN
        CONCAT('{1}为您的灵当软件验证码，请在24小时内完成输入。如非本人操作，请忽略。详询客服', (SELECT com.service_tel FROM ld_communicationaccount as com WHERE com.service_tel IS NOT NULL AND com.service_tel != '' LIMIT 1))
		ELSE '{1}为您的灵当软件验证码，请在24小时内完成输入。如非本人操作，请忽略。'
	END
WHERE label = 'AccountLoginCodeSMS' and modulename = 'SMS';
delimiter;

call AddColumn("ld_workreport_rulesettings",'auto_generate_brief','VARCHAR','10','no');
delimiter;

SET @labelbol = 'AUTOGENERATEBRIEF';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自动生成工作简报',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Automatically generate work briefs',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'pleaseWaitToPublishTips';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'正在生成工作简报详情内容，请稍等...',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Generating work briefing details, please wait...',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

DROP PROCEDURE IF EXISTS `updatedata_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `updatedata_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool where deleted = 0 and active = 'yes';
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_account_public WHERE STATUS = 'yes')  THEN
		call account_updatedata_normal();
		OPEN cur1;
			Fetch cur1 into tmp_pool_id;
				loop1: while  done<>1 DO
					call account_updatedata_highsea_program(tmp_pool_id);
			Fetch cur1 into tmp_pool_id;
		end while loop1;
		close cur1;
		
	end if;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_updatedata_highsea_program`;
delimiter ||
CREATE PROCEDURE `account_updatedata_highsea_program`(IN tmp_from_pool_id INT(11))
BEGIN
	declare done  int  default 0;
	DECLARE target_pool_id varchar(200);
	DECLARE tmp_grammeid varchar(200);
	declare cur1 CURSOR FOR SELECT programmeid,pool_id from ld_module_recovery_programme where modulename = 'Accounts' and active = 'yes' and from_pool_id = tmp_from_pool_id ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
	
	OPEN cur1;
		Fetch cur1 into tmp_grammeid,target_pool_id;
			loop1: while  done<>1 DO
				call account_updatedata_highsea_rule(tmp_from_pool_id,target_pool_id,tmp_grammeid);
		Fetch cur1 into tmp_grammeid,target_pool_id;
	end while loop1;
	close cur1;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_updatedata_highsea_rule`;
DELIMITER ||
CREATE   PROCEDURE `account_updatedata_highsea_rule`(IN tmp_pool_id INT(11),IN target_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_cur_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_relatedcolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;
	

	declare cur1 CURSOR FOR
	select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule
		inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and (ld_field.presence in(0,2))
		where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and programmeid = tmp_grammeid;
	declare continue handler  for not found SET done =1;
	select recycleselect into @recycleselect from ld_module_recovery_programme where programmeid = tmp_grammeid;

	
	set @tmpint=0;
	set @tmp_sql = '';

	OPEN cur1;
	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
				set var_cur_condition = var_condition;
				set	var_smownercolumn='smownerid';
				if var_tablename='ld_singin' THEN
						set	var_relatedcolumn='source_list';
				else
						set	var_relatedcolumn='accountid';
				end if;

				set @where_sql = CONCAT(" and ",var_tablename,".deleted = 0 ");
				if var_otherwhere <> '' then
						set @where_sql = CONCAT(@where_sql,var_otherwhere);
				end if;
				set @tmp_sql = CONCAT(@tmp_sql,"SELECT COUNT(",var_tablename,".",var_relatedcolumn,") as cnt,'",var_iscycle,"' as is_cycle_check,ld_account.accountid from ld_account");
				set @tmp_sql = CONCAT(@tmp_sql," LEFT JOIN ",var_tablename," ON ",var_tablename,".",var_relatedcolumn," = ld_account.accountid and ",var_tablename,".smownerid = ld_account.smownerid ",@where_sql);
				set @tmp_sql = CONCAT(@tmp_sql," where ld_account.deleted = 0 and ld_account.publicaccount in (2,3) and ld_account.pool_id = ",tmp_pool_id," GROUP BY ld_account.accountid");
				set @tmp_sql = CONCAT(@tmp_sql,' union all ');
				
				set @tmpint=@tmpint+1;
	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	end while loop1;
	close cur1;


	
if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmp_sql,CHAR_LENGTH(@tmp_sql)-@len);

	  set @TMPSQL_ONE = " SELECT accountid,COUNT((is_cycle_check='yes' or cnt = 0) or NULL) as cnt_result from ( ";
		set @TMPSQL_ONE = CONCAT(@TMPSQL_ONE,@tmpsql,") tmpdata GROUP BY tmpdata.accountid");
		set @TMPSQL_TWO = concat("UPDATE ld_account INNER JOIN (",@TMPSQL_ONE,") tmp_result on ld_account.accountid = tmp_result.accountid  ");
		if @recycleselect is not null and @recycleselect<>'' then
				set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," INNER JOIN (",@recycleselect,") recyclewheretableset on recyclewheretableset.accountid = ld_account.accountid ");
		end if;
		
		set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," set ld_account.completed = '未完成' ");
		set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," where ld_account.publicaccount in (2,3) and ld_account.pool_id = ",tmp_pool_id);
		set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and ld_account.deleted = 0 ");
		
		if var_cur_condition = 'and' then 
			set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result > 0 ");
		ELSE
			set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result = ",@tmpint);
		END if;
	prepare stmt from @TMPSQL_TWO;
	execute stmt;
	deallocate prepare stmt;

end if;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_updatedata_normal`;
delimiter ||
CREATE  PROCEDURE `account_updatedata_normal`()
BEGIN

	DECLARE normal_id int(11);
	DECLARE var_pool_id int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select id,pool_id from ld_account_normal where active = 'yes' ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
		OPEN cur1;
			Fetch cur1 into normal_id,var_pool_id;
			loop1: while  done<>1 DO

				if normal_id > 0 THEN
						call account_updatedata_normal_rule(normal_id,var_pool_id);
				end IF;

    	Fetch cur1 into normal_id,var_pool_id;
    	end while loop1;
    close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_updatedata_normal_rule`;
delimiter ||
CREATE   PROCEDURE `account_updatedata_normal_rule`(new_normal_id 	int(11),
	new_pool_id 	int(11))
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	DECLARE var_cur_condition varchar(50);
	DECLARE var_relatedcolumn varchar(50);

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
		ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    declare continue handler  for not   found  SET done =1;
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmp_sql='';
    	
			select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

			OPEN cur1;

    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
					
					set var_cur_condition = var_condition;
				set	var_smownercolumn='smownerid';
				if var_tablename='ld_singin' THEN
						set	var_relatedcolumn='source_list';
				else
						set	var_relatedcolumn='accountid';
				end if;
				
				set @where_sql = CONCAT(" and ",var_tablename,".deleted = 0 ");
				if var_otherwhere <> '' then
						set @where_sql = CONCAT(@where_sql,var_otherwhere);
				end if;
				set @tmp_sql = CONCAT(@tmp_sql,"SELECT COUNT(",var_tablename,".",var_relatedcolumn,") as cnt,'",var_iscycle,"' as is_cycle_check,ld_account.accountid from ld_account");
				
				set @tmp_sql = CONCAT(@tmp_sql," LEFT JOIN ",var_tablename," ON ",var_tablename,".",var_relatedcolumn," = ld_account.accountid and ",var_tablename,".smownerid = ld_account.smownerid ",@where_sql);
				set @tmp_sql = CONCAT(@tmp_sql," where ld_account.deleted = 0 and ld_account.publicaccount = 0 and ld_account.pool_id = 0 GROUP BY ld_account.accountid");

				set @tmp_sql = CONCAT(@tmp_sql,' union all ');
				
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;


    	if @tmpint>0 then
					set @len=CHAR_LENGTH(' union all ');
					set @tmpsql=left(@tmp_sql,CHAR_LENGTH(@tmp_sql)-@len);

					set @TMPSQL_ONE = " SELECT accountid,COUNT((is_cycle_check='yes' or cnt = 0) or NULL) as cnt_result from ( ";
					set @TMPSQL_ONE = CONCAT(@TMPSQL_ONE,@tmpsql,") tmpdata GROUP BY tmpdata.accountid");
					
					set @TMPSQL_TWO = concat("UPDATE ld_account INNER JOIN (",@TMPSQL_ONE,") tmp_result on ld_account.accountid = tmp_result.accountid  ");
					if @recycleselect is not null and @recycleselect<>'' then
							set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," INNER JOIN (",@recycleselect,") recyclewheretableset on recyclewheretableset.accountid = ld_account.accountid ");
					end if;
					
					set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," set ld_account.completed = '未完成' ");
					set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," where ld_account.publicaccount = 0 and ld_account.pool_id = 0 ");
					set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and ld_account.deleted = 0 ");
					
					if var_cur_condition = 'and' then 
						set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result > 0 ");
					ELSE
						set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result = ",@tmpint);
					END if;

			
			prepare stmt from @TMPSQL_TWO;
			execute stmt;
			deallocate prepare stmt;

			end if;
    END IF;

end ||
delimiter;

set @disable_triggers = 'aaa';

call updatedata_account_publicoperation();
DROP PROCEDURE IF EXISTS `account_updatedata_highsea_rule`;
DROP PROCEDURE IF EXISTS `account_updatedata_highsea_program`;
DROP PROCEDURE IF EXISTS `account_updatedata_normal`;
DROP PROCEDURE IF EXISTS `account_updatedata_normal_rule`;
DROP PROCEDURE IF EXISTS `updatedata_account_publicoperation`;

UPDATE ld_account set completed = '已完成',protectdate = NULL where ld_account.publicaccount <> 1 and completed <> '未完成';
UPDATE ld_account set completed = '',protectdate = NULL where ld_account.publicaccount = 1;

set @disable_triggers = NULL;
delimiter;

DROP PROCEDURE IF EXISTS `updatedata_leads_publicoperation`;
delimiter ||
CREATE PROCEDURE `updatedata_leads_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_leads_public_pool where deleted = 0 and active = 'yes';
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_leads_public WHERE STATUS = 'yes')  THEN
		call leads_updatedata_normal();
		OPEN cur1;
			Fetch cur1 into tmp_pool_id;
				loop1: while  done<>1 DO
					call leads_updatedata_highsea_program(tmp_pool_id);
			Fetch cur1 into tmp_pool_id;
		end while loop1;
		close cur1;
		
	end if;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `leads_updatedata_highsea_program`;
delimiter ||
CREATE PROCEDURE `leads_updatedata_highsea_program`(IN tmp_from_pool_id INT(11))
BEGIN
	declare done  int  default 0;
	DECLARE target_pool_id varchar(200);
	DECLARE tmp_grammeid varchar(200);
	declare cur1 CURSOR FOR SELECT programmeid,pool_id from ld_module_recovery_programme where modulename = 'Leads' and active = 'yes' and from_pool_id = tmp_from_pool_id ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
	
	OPEN cur1;
		Fetch cur1 into tmp_grammeid,target_pool_id;
			loop1: while  done<>1 DO
				call leads_updatedata_highsea_rule(tmp_from_pool_id,target_pool_id,tmp_grammeid);
		Fetch cur1 into tmp_grammeid,target_pool_id;
	end while loop1;
	close cur1;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `leads_updatedata_highsea_rule`;
DELIMITER ||
CREATE   PROCEDURE `leads_updatedata_highsea_rule`(IN tmp_pool_id INT(11),IN target_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_cur_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_relatedcolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;
	

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
		 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
		 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and (ld_field.presence in(0,2) ) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;

	declare continue handler  for not found SET done =1;
	select recycleselect into @recycleselect from ld_module_recovery_programme where programmeid = tmp_grammeid;

	
	set @tmpint=0;
	set @tmp_sql = '';

	OPEN cur1;
	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO
				set var_cur_condition = var_condition;
				set	var_smownercolumn='smownerid';
				if var_tablename='ld_singin' THEN
						set	var_relatedcolumn='source_list';
				else
						set	var_relatedcolumn='leads_id';
				end if;

				set @where_sql = CONCAT(" and ",var_tablename,".deleted = 0 ");
				if var_otherwhere <> '' then
						set @where_sql = CONCAT(@where_sql,var_otherwhere);
				end if;
				set @tmp_sql = CONCAT(@tmp_sql,"SELECT COUNT(",var_tablename,".",var_relatedcolumn,") as cnt,'",var_iscycle,"' as is_cycle_check,ld_leads.leadsid from ld_leads");
				set @tmp_sql = CONCAT(@tmp_sql," LEFT JOIN ",var_tablename," ON ",var_tablename,".",var_relatedcolumn," = ld_leads.leadsid and ",var_tablename,".smownerid = ld_leads.smownerid ",@where_sql);
				set @tmp_sql = CONCAT(@tmp_sql," where ld_leads.deleted = 0 and ld_leads.publicaccount in (2,3) and ld_leads.pool_id = ",tmp_pool_id," GROUP BY ld_leads.leadsid");
				set @tmp_sql = CONCAT(@tmp_sql,' union all ');
				
				set @tmpint=@tmpint+1;
	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	end while loop1;
	close cur1;


	
if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmp_sql,CHAR_LENGTH(@tmp_sql)-@len);

	  set @TMPSQL_ONE = " SELECT leadsid,COUNT((is_cycle_check='yes' or cnt = 0) or NULL) as cnt_result from ( ";
		set @TMPSQL_ONE = CONCAT(@TMPSQL_ONE,@tmpsql,") tmpdata GROUP BY tmpdata.leadsid");
		set @TMPSQL_TWO = concat("UPDATE ld_leads INNER JOIN (",@TMPSQL_ONE,") tmp_result on ld_leads.leadsid = tmp_result.leadsid  ");
		if @recycleselect is not null and @recycleselect<>'' then
				set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," INNER JOIN (",@recycleselect,") recyclewheretableset on recyclewheretableset.leadsid = ld_leads.leadsid ");
		end if;
		
		set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," set ld_leads.completed = '未完成' ");
		set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," where ld_leads.publicaccount in (2,3) and ld_leads.pool_id = ",tmp_pool_id);
		set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and ld_leads.deleted = 0 ");
		
		if var_cur_condition = 'and' then 
			set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result > 0 ");
		ELSE
			set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result = ",@tmpint);
		END if;
	prepare stmt from @TMPSQL_TWO;
	execute stmt;
	deallocate prepare stmt;

end if;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `leads_updatedata_normal`;
delimiter ||
CREATE  PROCEDURE `leads_updatedata_normal`()
BEGIN

	DECLARE normal_id int(11);
	DECLARE var_pool_id int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select id,pool_id from ld_leads_normal where active = 'yes' ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
		OPEN cur1;
			Fetch cur1 into normal_id,var_pool_id;
			loop1: while  done<>1 DO

				if normal_id > 0 THEN
						call leads_updatedata_normal_rule(normal_id,var_pool_id);
				end IF;

    	Fetch cur1 into normal_id,var_pool_id;
    	end while loop1;
    close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `leads_updatedata_normal_rule`;
delimiter ||
CREATE   PROCEDURE `leads_updatedata_normal_rule`(new_normal_id 	int(11),
	new_pool_id 	int(11))
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	DECLARE var_cur_condition varchar(50);
	DECLARE var_relatedcolumn varchar(50);

		declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
     ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
     ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;


    declare continue handler  for not   found  SET done =1;
    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmp_sql='';
    	
			select recycleselect into @recycleselect from ld_leads_normal where id = new_normal_id;

			OPEN cur1;

    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
					
					set var_cur_condition = var_condition;
				set	var_smownercolumn='smownerid';
				if var_tablename='ld_singin' THEN
						set	var_relatedcolumn='source_list';
				else
						set	var_relatedcolumn='leads_id';
				end if;
				
				set @where_sql = CONCAT(" and ",var_tablename,".deleted = 0 ");
				if var_otherwhere <> '' then
						set @where_sql = CONCAT(@where_sql,var_otherwhere);
				end if;
				set @tmp_sql = CONCAT(@tmp_sql,"SELECT COUNT(",var_tablename,".",var_relatedcolumn,") as cnt,'",var_iscycle,"' as is_cycle_check,ld_leads.leadsid from ld_leads");
				
				set @tmp_sql = CONCAT(@tmp_sql," LEFT JOIN ",var_tablename," ON ",var_tablename,".",var_relatedcolumn," = ld_leads.leadsid and ",var_tablename,".smownerid = ld_leads.smownerid ",@where_sql);
				set @tmp_sql = CONCAT(@tmp_sql," where ld_leads.deleted = 0 and ld_leads.publicaccount = 0 and ld_leads.pool_id = 0 GROUP BY ld_leads.leadsid");

				set @tmp_sql = CONCAT(@tmp_sql,' union all ');
				
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;


    	if @tmpint>0 then
					set @len=CHAR_LENGTH(' union all ');
					set @tmpsql=left(@tmp_sql,CHAR_LENGTH(@tmp_sql)-@len);

					set @TMPSQL_ONE = " SELECT leadsid,COUNT((is_cycle_check='yes' or cnt = 0) or NULL) as cnt_result from ( ";
					set @TMPSQL_ONE = CONCAT(@TMPSQL_ONE,@tmpsql,") tmpdata GROUP BY tmpdata.leadsid");
					
					set @TMPSQL_TWO = concat("UPDATE ld_leads INNER JOIN (",@TMPSQL_ONE,") tmp_result on ld_leads.leadsid = tmp_result.leadsid  ");
					if @recycleselect is not null and @recycleselect<>'' then
							set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," INNER JOIN (",@recycleselect,") recyclewheretableset on recyclewheretableset.leadsid = ld_leads.leadsid ");
					end if;
					
					set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," set ld_leads.completed = '未完成' ");
					set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," where ld_leads.publicaccount = 0 and ld_leads.pool_id = 0 ");
					set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and ld_leads.deleted = 0 ");
					
					if var_cur_condition = 'and' then 
						set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result > 0 ");
					ELSE
						set @TMPSQL_TWO = CONCAT(@TMPSQL_TWO," and tmp_result.cnt_result = ",@tmpint);
					END if;

			prepare stmt from @TMPSQL_TWO;
			execute stmt;
			deallocate prepare stmt;

			end if;
    END IF;

end ||
delimiter;

set @disable_triggers = 'aaa';

call updatedata_leads_publicoperation();
DROP PROCEDURE IF EXISTS `leads_updatedata_highsea_rule`;
DROP PROCEDURE IF EXISTS `leads_updatedata_highsea_program`;
DROP PROCEDURE IF EXISTS `leads_updatedata_normal`;
DROP PROCEDURE IF EXISTS `leads_updatedata_normal_rule`;
DROP PROCEDURE IF EXISTS `updatedata_leads_publicoperation`;

UPDATE ld_leads set completed = '已完成',protectdate = NULL where ld_leads.publicaccount <> 1 and completed <> '未完成';
UPDATE ld_leads set completed = '',protectdate = NULL where ld_leads.publicaccount = 1;

set @disable_triggers = NULL;
delimiter;


DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, 
		`condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule  
		inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')                                                                                                                                                                                                                    INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' 
		and programmeid = tmp_grammeid;
	declare continue handler  for not   found  SET done =1;
		set @tmpint=0;
		set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
		from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and programmeid = tmp_grammeid;

	select beforereminddays into @var_beforereminddays  from ld_module_recovery_programme where  programmeid = tmp_grammeid;


	if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
			leave label_a ;
	end if;

	select recycleselect into @recycleselect from ld_module_recovery_programme where  programmeid = tmp_grammeid;


if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set @old_days=var_days;
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
else
				set	var_smownercolumn='smownerid' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate) BETWEEN ",var_days,' and ' ,@old_days);
end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);
					IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		if var_condition='or'  then
			set @TMP_TMPTable=( select  concat('"(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')"')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' and programmeid = tmp_grammeid ORDER BY ld_account_set_rule.sequence asc );
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',var_days);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
end if;
				set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_account.accountid)
							as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid  from ld_account  inner join ( ',@sql,' ) as lingdangtmp
							on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid ');
end if;
delete from ld_publicaccount_remindtableview ;

set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;
call crm_publicaccount_beforereminds();
end if;
end ||
delimiter;



DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
    new_normal_id 	int(11),
    new_pool_id 	int(11)
        )
    label_a:
BEGIN
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
                                   ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
                                                                                                                                                ,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                                                                                                                                                                                                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_account_set_rule_normal.days) into @maxdays
from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

select beforereminddays into @var_beforereminddays from ld_account_normal where id = new_normal_id;
if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
else
    				set	var_smownercolumn='smownerid' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;

    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
    			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;


if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
						set @TMP_TMPTable= ( select  concat("'(",GROUP_CONCAT(ld_tranlabel.fieldlabel),")'")  from ld_account_set_rule_normal
							INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname
							INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
							and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
							where ld_account_set_rule_normal.`status`="active" and normal_id = new_normal_id ORDER BY ld_account_set_rule_normal.sequence asc ) ;
						
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,'  separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
end if;
SELECT @TMPSQL_TWO;
delete from ld_publicaccount_remindtableview ;
set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_beforereminds();
end if;
END IF;

end ||
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule_beforeremind(IN tmp_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare var_leadsidcolumnname varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
                                 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and  (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                       INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_leads_set_rule.days) into @maxdays
from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;

select beforereminddays,recycleselect into @var_beforereminddays,@recycleselect  from ld_module_recovery_programme where  programmeid = tmp_grammeid;


if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
end if;

set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
						set	var_leadsidcolumnname='record' ;
else
				set	var_smownercolumn='smownerid' ;
				set	var_leadsidcolumnname='leads_id' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,' and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_leads.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    if var_condition='or'  then
			set @TMP_TMPTable= ( select  concat('"(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')"')  from ld_leads_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid ORDER BY ld_leads_set_rule.sequence asc ) ;
			
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>\'');
			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid ') ;
ELSE
					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid') ;
end if;
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id,'  group by ld_leads.smownerid    ');
end if;
delete from ld_publicleads_remindtableview ;
SELECT @TMPSQL_TWO;
set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_beforereminds();
end if;
end ||
delimiter;


drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule_beforeremind(new_normal_id 	int(11),new_pool_id 	int(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
                                   ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
                                                                                                                                                                        ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                                                                                                                                                              INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
	select max(ld_leads_set_rule.days) into @maxdays
	from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;
		
		set @leads_rule_pool_id = new_pool_id;
		select recycleselect,beforereminddays into @recycleselect,@var_beforereminddays from ld_leads_normal where id = new_normal_id;

		if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
						leave label_a ;
		end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO

    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
						  set	var_leadsidcolumnname='record' ;
else
    				set	var_smownercolumn='smownerid' ;
					   set	var_leadsidcolumnname='leads_id' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime , '",var_tabname,"' as remindtabname from ld_leads LEFT JOIN (select ld_leads.leadsid from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',
                    var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leads_id is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads inner join "  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
    			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;


if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
    				 set @TMP_TMPTable= ( select  concat('"(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')"')  from ld_leads_set_rule
    									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
    									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
    										where type='complete' and ld_leads_set_rule.status='active' and ld_leads_set_rule.status='active' and programmeid = new_normal_id ORDER BY ld_leads_set_rule.sequence asc ) ;
						
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");

else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid ') ;
ELSE
    					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountname,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid'  );
end if;

delete from ld_publicleads_remindtableview ;

set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_beforereminds();
end if;
END IF;

end ||
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule(IN tmp_pool_id INT(11),IN target_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
                                 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                       INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and (ld_field.presence in(0,2) ) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	
	select max(ld_leads_set_rule.days) into @maxdays
	from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
													INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
	where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;

	select IF(ld_users.id>0,transfer_users,0) into @allotaccount from 
		ld_module_recovery_programme LEFT join ld_users on ld_users.id=transfer_users
		where modulename = 'Leads' and ld_module_recovery_programme.programmeid = tmp_grammeid;
	
	if  ifnull(@allotaccount,0)=0  then
				set @allotaccount=0;
	end if;
	select recycleselect into @recycleselect from ld_module_recovery_programme where programmeid = tmp_grammeid;

	if @recycleselect is not null and @recycleselect<>'' then
				set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
					set var_leadsidcolumnname='record';
else
				set	var_smownercolumn='smownerid' ;
				set var_leadsidcolumnname='leads_id';
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.allocatedate from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,'
								and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );

				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then

			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id,ld_leads.smownerid,"',tmp_grammeid,'" as log_grammeid  from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
				set @TMPSQL_LOG_ONE=concat(@TMPSQL_LOG_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
		  set @TMPSQL_TWO=concat(' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id =  ',tmp_pool_id);

			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);

			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
			end if;
else
				if @recycleselect is not null and @recycleselect<>'' then

					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
				ELSE
					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
				end if;

			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id,ld_leads.smownerid,"',tmp_grammeid,'" as log_grammeid  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);

end if;
			set @TMPSQL_LOG_TWO = concat(@TMPSQL_LOG_ONE,@TMPSQL_TWO);
			set @TMPSQL_TWO = concat(@TMPSQL_ONE,@TMPSQL_TWO);
	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id,old_smownerid,programmeid) ',@TMPSQL_LOG_TWO);

 prepare stmt from @TMPSQL_THREE;
 execute stmt;
 deallocate prepare stmt;

set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,\'</a>\'';
    if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)   group by ld_leads.smownerid    ');
end if;
delete from ld_publicleads_remindtableview ;

set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_recoveryreminds();

if var_condition='or'  then

			 set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
ELSE

			  set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				if target_pool_id >0 then
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",ld_leads.pool_id=",target_pool_id);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DataScopeforAllocateRelinfo','同时分配相关信息的数据范围','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataScopeforAllocateRelinfo' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DataScopeforAllocateRelinfo','Scope of data for simultaneously allocating relevant information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DataScopeforAllocateRelinfo' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SmownerSettings','负责人设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SmownerSettings' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SmownerSettings','Setting of responsible person','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SmownerSettings' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShareSettings','共享设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ShareSettings' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShareSettings','Share Settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ShareSettings' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_field set uitype=5,bigtype='date' where columnname='distributiondate' and uitype=70 and bigtype='datetime';
delimiter;
-- 2024-09-08

SET @labelbol = 'SELECTTHESOURCEDOCUMENTTYPE';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请选择源单类型后，再选择源单',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please select the source document type before selecting the source document',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRODUCTHELPMANUALSHOWTYPE','帮助手册显示方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PRODUCTHELPMANUALSHOWTYPE' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRODUCTHELPMANUALSHOWTYPE','Help Manual Dispaly Mode','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PRODUCTHELPMANUALSHOWTYPE' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='拥有筛选、搜索和按钮的所有模块列表，均按照所设置布局展示' where labelbol='ld_listviewtop_uisetting_tips' and labeltype = 'fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='所有模块的列表页表格信息字段，均按照所设置布局展示' where labelbol='ld_listviewtable_uisetting_tips' and labeltype = 'fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='所有模块的详情页详细信息中字段，均按照所设置布局展示' where labelbol='ld_detailview_uisetting_tips' and labeltype = 'fixedstr' and languagetype='zh';
delimiter;


insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence)
select 'yes',487,'移动端老看板是否显示:显示yes,不显示no','',0,0,'text',0 from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 487);
delimiter;


set @tabid = (SELECT tabid from ld_tab where `name` = 'SalesOrder');
set @att_tabid = 0;
set @maxid = (SELECT id+1 from ld_relatedlists_seq);
set @max_seq = (SELECT MAX(sequence)+1 from ld_relatedlists where tabid = @tabid);


INSERT into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable)
SELECT @maxid,@tabid,@att_tabid,'get_gjpbalanceofsalesorder',@max_seq,'GuanJiaPoReport',1,'',1,@max_seq,'','' from DUAL
where NOT EXISTS(SELECT 1 from ld_relatedlists where tabid = @tabid and name = 'get_gjpbalanceofsalesorder');

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','GuanJiaPoReport','管家婆订单来往','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='GuanJiaPoReport' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','GuanJiaPoReport','GuanJiaPo Report','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='GuanJiaPoReport' AND Labeltype='fixedstr');
delimiter;
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @tabid=(SELECT tabid from ld_tab where `name` = 'Accounts');
SET @relateid=(SELECT block from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxfieldid=(SELECT MAX(fieldid) FROM ld_field);

SET @presence = (SELECT presence from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @trantable='ld_field';
SET @columnname='protectstartdate'; 
SET @fieldname='protectstartdate'; 
SET @zh='保护开始日期'; 
SET @en='Protection start date'; 
SET @uitype=5;
SET @typeofdata='D~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='date';
SET @datarang='all';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'no';

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxfieldid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

SET @tabid=(SELECT tabid from ld_tab where `name` = 'Leads');
SET @relateid=(SELECT block from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxfieldid=(SELECT MAX(fieldid) FROM ld_field);

SET @presence = (SELECT presence from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @trantable='ld_field';
SET @columnname='protectstartdate'; 
SET @fieldname='protectstartdate'; 
SET @zh='保护开始日期'; 
SET @en='Protection start date'; 
SET @uitype=5;
SET @typeofdata='D~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='date';
SET @datarang='all';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'no';

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxfieldid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

set @disable_triggers = 'aaa';
call AddColumn('ld_account','protectstartdate','date','',NULL);
UPDATE ld_account set protectstartdate = IFNULL(IFNULL(allocatedate,distributiondate),createdtime) where IFNULL(protectstartdate,'') = '' and publicaccount <> 1;

call AddColumn('ld_leads','protectstartdate','date','',NULL);
UPDATE ld_leads set protectstartdate = IFNULL(IFNULL(allocatedate,distributiondate),createdtime) where IFNULL(protectstartdate,'') = '' and publicaccount <> 1;

set @disable_triggers = NULL;
delimiter;

DROP PROCEDURE IF EXISTS `setprmdefaulthomeboard`;
delimiter ||
CREATE PROCEDURE `setprmdefaulthomeboard`(
)
BEGIN

    IF NOT EXISTS (select 1 from ld_homeboard where boardtype = 'prmHome') THEN

				INSERT INTO `ld_homeboard` (`description`, `boardname`, `smcreatorid`, `createdtime`, `modifiedby`, `deleted`, `boardlayout`, `scope`, `timesearchdefault`, `approve_value`, `saleskit_colcount`, `saleskit_height`, `saleskit_isshowpredata`, `boardtype`, `icon_path`, `sequence`) VALUES ('', '经销商看板', '1', '', '1', '0', 'tl2r1', 'all', 'thismonth', '', '0', '0', 'yes', 'prmHome', '', '1');
				set @boardid = LAST_INSERT_ID();

				INSERT INTO `ld_homeboard_plate` (`boardid`, `platetype`, `platewidth`, `sequence`) VALUES (@boardid, 'whole', '1-1', '0');
				set @plateid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('35', @boardid, @plateid, 'defaultstuff', '0', '', '', '');


				INSERT INTO `ld_homeboard_plate` (`boardid`, `platetype`, `platewidth`, `sequence`) VALUES (@boardid, 'left', '2-3', '1');
				set @plateid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('101', @boardid, @plateid, 'defaultstuff', '0', '386px', '', '');
				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('9', @boardid, @plateid, 'defaultstuff', '1', '386px', '', '');
				set @boardstuffid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '9', @boardstuffid, 'can_penetrate', 'yes');
				INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '9', @boardstuffid, 'datalabel', 'none');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'Home', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'SalesOrder', 'SalesOrder', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'Home', 'ServiceContracts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D', 'ServiceContracts', 'ServiceContracts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'ServiceContracts', 'ServiceContracts', '[]', '[]');

				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('4', @boardid, @plateid, 'defaultstuff', '2', '386px', '', '');
				set @boardstuffid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '4', @boardstuffid, 'can_penetrate', 'yes');
				INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '4', @boardstuffid, 'datalabel', 'none');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'Home', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'SalesOrder', 'SalesOrder', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'Home', 'ServiceContracts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D', 'ServiceContracts', 'ServiceContracts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'ServiceContracts', 'ServiceContracts', '[]', '[]');

				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('168', @boardid, @plateid, 'customreport', '3', '386px', '', '');
				set @boardstuffid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'Home', 'Potentials', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT', 'Potentials', 'Potentials', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'Potentials', 'Potentials', '[]', '[]');


				INSERT INTO `ld_homeboard_plate` (`boardid`, `platetype`, `platewidth`, `sequence`) VALUES (@boardid, 'right', '1-3', '2');
				set @plateid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('19', @boardid, @plateid, 'defaultstuff', '0', '386px', '', '');
				set @boardstuffid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '19', @boardstuffid, 'can_penetrate', 'yes');
				INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '19', @boardstuffid, 'datalabel', 'inside');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'Home', 'Potentials', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT', 'Potentials', 'Potentials', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'Potentials', 'Potentials', '[]', '[]');

				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('8', @boardid, @plateid, 'defaultstuff', '1', '386px', '', '');
				set @boardstuffid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'Home', 'Accounts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT', 'Accounts', 'Accounts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'approvestatuscomponent', 'yes', 'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V', 'Accounts', 'Accounts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'Accounts', 'Accounts', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_activity:smownerid:assigned_user_id:Calendar_fieldlabel:V', 'Home', 'Calendar', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_activity:createdtime:createdtime:Calendar_fieldlabel:DT', 'Calendar', 'Calendar', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'Calendar', 'Calendar', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'Home', 'Potentials', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT', 'Potentials', 'Potentials', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'Potentials', 'Potentials', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'Home', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'SalesOrder', 'SalesOrder', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V', 'Home', 'ServiceContracts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_servicecontracts:due_date:due_date:ServiceContracts_fieldlabel:D', 'ServiceContracts', 'ServiceContracts', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'ServiceContracts', 'ServiceContracts', '[]', '[]');
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'Home', 'CashBill', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D', 'CashBill', 'CashBill', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'CashBill', 'CashBill', '[]', '[]');

				INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('139', @boardid, @plateid, 'customreport', '2', '386px', '', '');
				set @boardstuffid = LAST_INSERT_ID();
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'Home', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', NULL, NULL);
				INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid, 'highsearch', 'yes', NULL, 'SalesOrder', 'SalesOrder', '[]', '[]');

    END IF;
end ||
delimiter;

CALL setprmdefaulthomeboard();
DROP PROCEDURE IF EXISTS `setprmdefaulthomeboard`;
delimiter;

SET @labelbol = 'ADDBRIEF';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增简介',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'add brief',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

UPDATE ld_producttoolfield
INNER JOIN ld_field on ld_field.columnname=ld_producttoolfield.columnname AND ld_field.tabid=14 AND ld_field.columnname!='productname'
SET ld_producttoolfield.input_type=1,ld_producttoolfield.fieldid=ld_field.fieldid
WHERE (ld_producttoolfield.tablename = 'ld_products' OR ld_producttoolfield.tablename = 'ld_productscf') AND ld_producttoolfield.input_type =0;
delimiter;

SET @labelbol = 'EditCarousel';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'编辑轮播图',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Edit carousel',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);
delimiter;


call AddColumn('ld_appparenttab','menu_user_type','varchar','5','crm');
call AddColumn('ld_mobile_report_parent_tab','menu_user_type','varchar','5','crm');
delimiter;
call addtableIndex('ld_contactdetails','idx_contactdetails_accountid','accountid');
call addtableIndex('ld_potential','idx_potential_contactid','contactid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUPERIORMAOHAO','上级：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SUPERIORMAOHAO' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUPERIORMAOHAO','Superior:','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SUPERIORMAOHAO' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUBORDINATEMAOHAO','下级：','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SUBORDINATEMAOHAO' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUBORDINATEMAOHAO','Subordinate:','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SUBORDINATEMAOHAO' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_account_public set showpublicmodule = 'yes' where not EXISTS (SELECT 1 from ld_account limit 1);
UPDATE ld_leads_public set showpublicmodule = 'yes' where not EXISTS (SELECT 1 from ld_leads limit 1);
delimiter;



SET @labelbol = 'prm_mobile_customization';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'移动端界面定制',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Mobile Custom Page Customisation',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

call AddColumn('ld_appparenttab','menu_user_type','varchar','5','crm');
call AddColumn('ld_mobile_report_parent_tab','menu_user_type','varchar','5','crm');


update ld_appparenttab set sequence=sequence+1 ;
select max(sequence) into @maxsequence from ld_appparenttab;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label,enblockname,allocateid,allocatetype,menu_user_type)
select 'PRM功能菜单',0,1,'yes' ,'PRMFunctionMenu','PRM Function Menu','','all','prm' from dual
where not exists(select 1 from ld_appparenttab where parenttab_label='PRMFunctionMenu');

SET @i=0;
UPDATE ld_appparenttab SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;

insert into ld_mobile_report_parent_tab(block_name,presence,systemdefault,parenttab_label,allocatetype,enblock_name,menu_user_type)
select 'PRM报表菜单',0,'yes','PRMReportMenu','all','PRM Report Menu','prm' from DUAL
where not exists(select 1 from ld_mobile_report_parent_tab where parenttab_label='PRMReportMenu');
delimiter;

SET @labelbol = 'function_menu_customization';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'功能菜单',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'function menu customization',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;
SET @labelbol = 'report_menu_customization1';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报表菜单',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'report menu customization',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;
DROP PROCEDURE IF EXISTS `setprmdefault_mobile_report`;
delimiter ||
CREATE PROCEDURE `setprmdefault_mobile_report`(
)
BEGIN

    IF NOT EXISTS (select 1 from ld_settings_field where name='prm_mobile_customization') THEN
select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='PRMReportMenu';

INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '1', '19', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '10', '7', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '11', '11', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '12', '10', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '13', '2', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '14', '12', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '16', '4', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '17', '5', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '18', '6', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '2', '20', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '21', '1', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '22', '17', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '24', '18', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '3', '21', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '30', '8', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '31', '9', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '4', '14', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '5', '15', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '6', '16', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '7', '13', 'ld_tab');
INSERT INTO `ld_mobile_report_tab_rel` (`block_id`, `tabid`, `sequence`, `tab_tablename`) VALUES (@block_id, '9', '3', 'ld_tab');

select  blockid into @tabblockid from  ld_appparenttab where parenttab_label='PRMFunctionMenu';
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '138', '1', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '6', '2', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '55', '3', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '142', '4', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '2', '5', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '20', '6', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '22', '7', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '37', '8', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '13', '9', 'ld_tab');
INSERT INTO ld_appparenttabrel (`blockid`, `tabid`, `sequence`, `tab_tablename`) VALUES (@tabblockid, '-1', '10', 'ld_tab');


SELECT blockid into @blockid FROM ld_settings_blocks WHERE active = 0  and label='CUSTOMIZED_DEALER_CHANNELS' ;
select max(fieldid) + 1 into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,`name`,iconpath,description,linkto,sequence,active)
select  @fieldid,@blockid,'prm_mobile_customization','','','index.php?module=Settings&action=prmmobilesettings&parenttab=Settings',1,0
from dual where not exists(select 1 from ld_settings_field where name='prm_mobile_customization');

END IF;
end ||
delimiter;

CALL setprmdefault_mobile_report();
DROP PROCEDURE IF EXISTS `setprmdefault_mobile_report`;
delimiter;



DROP PROCEDURE IF EXISTS `setprmdefaultmobilehomeboard`;
delimiter ||
CREATE PROCEDURE `setprmdefaultmobilehomeboard`(
)
BEGIN

    IF NOT EXISTS (select 1 from ld_homeboard where boardtype = 'prmMobileHome') THEN
        INSERT INTO `ld_homeboard` (`description`, `boardname`, `smcreatorid`, `createdtime`, `modifiedby`, `modifiedtime`, `deleted`, `boardlayout`, `scope`, `timesearchdefault`, `approve_value`, `saleskit_colcount`, `saleskit_height`, `saleskit_isshowpredata`, `boardtype`, `icon_path`, `sequence`) VALUES ('', '经销商移动端看板', '1', '2024-09-11 15:57:54', '1', '2024-09-12 11:14:32', '0', NULL, 'all', 'thismonth', 'unapproved,approving,approved,rejected,dismissed', '2', '120', 'yes', 'prmMobileHome', '', '1');
        set @boardid = LAST_INSERT_ID();

INSERT INTO `ld_homeboard_plate` (`boardid`, `platetype`, `platewidth`, `sequence`) VALUES (@boardid, 'whole', '1-1', '0');
set @plateid = LAST_INSERT_ID();

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('110', @boardid, @plateid, 'defaultstuff', '1', '386px', '合同简报', 'Contract kit');
set @boardstuffid1 = LAST_INSERT_ID();


INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('19', @boardid, @plateid, 'defaultstuff', '2', '386px', '销售漏斗', 'Sales Funnel');
set @boardstuffid2 = LAST_INSERT_ID();
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '19', @boardstuffid2, 'datalabel', 'inside');

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('35', @boardid, @plateid, 'defaultstuff', '0', '', '数据简报', 'Sales Kit');
set @boardstuffid3 = LAST_INSERT_ID();
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '35', @boardstuffid3, 'SalesKit_EqualDuration', 'no');
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '35', @boardstuffid3, 'SalesKit_ShowPercent', 'yes');

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('106', @boardid, @plateid, 'defaultstuff', '3', '386px', '客户来源分布统计', 'Source distribution statistics');
set @boardstuffid4 = LAST_INSERT_ID();
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '106', @boardstuffid4, 'can_penetrate', 'yes');
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '106', @boardstuffid4, 'datalabel', 'none');

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('107', @boardid, @plateid, 'defaultstuff', '4', '386px', '客户类型分布统计', 'Type distribution statistics');
set @boardstuffid5 = LAST_INSERT_ID();
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '107', @boardstuffid5, 'can_penetrate', 'yes');
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '107', @boardstuffid5, 'datalabel', 'none');

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('4', @boardid, @plateid, 'defaultstuff', '5', '386px', '签约额月度同比', 'Orders Amount Year-on-year');
set @boardstuffid6 = LAST_INSERT_ID();
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '4', @boardstuffid6, 'can_penetrate', 'yes');
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '4', @boardstuffid6, 'datalabel', 'none');

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('5', @boardid, @plateid, 'defaultstuff', '6', '386px', '收款额月度同比', 'Received Amount Year-on-year');
set @boardstuffid7 = LAST_INSERT_ID();
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '5', @boardstuffid7, 'can_penetrate', 'yes');
INSERT INTO `ld_homeboard_plate_setting` (`boardid`, `stuffid`, `boardstuffid`, `type`, `setvalue`) VALUES (@boardid, '5', @boardstuffid7, 'datalabel', 'none');

INSERT INTO `ld_homeboard_plate_stuff` (`stuffid`, `boardid`, `plateid`, `stufftype`, `sequence`, `height`, `stufftitle_zh`, `stufftitle_en`) VALUES ('20', @boardid, @plateid, 'defaultstuff', '7', '386px', '关键视图', 'Key Filters');
set @boardstuffid8 = LAST_INSERT_ID();


INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid2, 'usercomponent', 'yes', 'ld_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V', 'Home', 'Potentials', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid2, 'timecomponent', 'yes', 'ld_potential:createdtime:createdtime:Potentials_fieldlabel:DT', 'Potentials', 'Potentials', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid2, 'approvestatuscomponent', 'yes', 'ld_potential:approvestatus:approvestatus:Potentials_fieldlabel:V', 'Potentials', 'Potentials', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid2, 'highsearch', 'yes', NULL, 'Potentials', 'Potentials', '[]', '[]');
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid4, 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'Home', 'Accounts', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid4, 'timecomponent', 'yes', 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT', 'Accounts', 'Accounts', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid4, 'approvestatuscomponent', 'yes', 'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V', 'Accounts', 'Accounts', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid4, 'highsearch', 'yes', NULL, 'Accounts', 'Accounts', '[]', '[]');
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid5, 'usercomponent', 'yes', 'ld_account:smownerid:assigned_user_id:Accounts_fieldlabel:V', 'Home', 'Accounts', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid5, 'timecomponent', 'yes', 'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT', 'Accounts', 'Accounts', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid5, 'approvestatuscomponent', 'yes', 'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V', 'Accounts', 'Accounts', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid5, 'highsearch', 'yes', NULL, 'Accounts', 'Accounts', '[]', '[]');
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid6, 'usercomponent', 'yes', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V', 'Home', 'SalesOrder', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid6, 'timecomponent', 'yes', 'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D', 'SalesOrder', 'SalesOrder', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid6, 'approvestatuscomponent', 'yes', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_fieldlabel:V', 'SalesOrder', 'SalesOrder', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid6, 'highsearch', 'yes', NULL, 'SalesOrder', 'SalesOrder', '[]', '[]');
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid7, 'usercomponent', 'yes', 'ld_cashbill:smownerid:assigned_user_id:CashBill_fieldlabel:V', 'Home', 'CashBill', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid7, 'timecomponent', 'yes', 'ld_cashbill:cashbilldate:cashbilldate:CashBill_fieldlabel:D', 'CashBill', 'CashBill', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid7, 'approvestatuscomponent', 'yes', 'ld_cashbill:approvestatus:approvestatus:CashBill_fieldlabel:V', 'CashBill', 'CashBill', NULL, NULL);
INSERT INTO `ld_homeboard_plate_filter` (`boardstuffid`, `conditionkey`, `isrelated`, `filters`, `filtermodule`, `stuffmodule`, `advance_demand`, `advance_demand_groups`) VALUES (@boardstuffid7, 'highsearch', 'yes', NULL, 'CashBill', 'CashBill', '[]', '[]');


select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewAccounts' limit 1;
INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '1', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewContacts' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '2', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewContactRecords' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '3', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewServiceContractsAmount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '4', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='SignContractAmount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '5', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='SignContractAmount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '6', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewInvoiceAmount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '6', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewOutboundOrderAmount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '7', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewCashBillAmount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '8', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewPotentialsCount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '9', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewSignCount' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '10', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='NewSalesOrderReceipts' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '10', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='SignContractBalanceReceivable' limit 1;

INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '11', NULL, NULL);
select id into @homestuffdetailid from ld_homestuffdetail where stufflabel='SignContractBalanceReceivable' limit 1;
INSERT INTO `ld_homestuffsaleskit2board` (`boardid`, `homestuffdetailid`, `sequence`, `relatedid`, `relatedtablename`) VALUES (@boardid, @homestuffdetailid, '12', NULL, NULL);


END IF;
end ||
delimiter;

CALL setprmdefaultmobilehomeboard();
DROP PROCEDURE IF EXISTS `setprmdefaultmobilehomeboard`;
delimiter;

update ld_desk set fieldlabel='帮助中心' where labelbol='PRODUCTHELPMANUAL' and labeltype = 'fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Help Centre' where labelbol='PRODUCTHELPMANUAL' and labeltype = 'fixedstr' and languagetype='en';
update ld_desk set fieldlabel='帮助中心' where labelbol='PRODUCTHELPMANUAL' and labeltype = 'jspop' and languagetype='zh';
update ld_desk set fieldlabel='Help Centre' where labelbol='PRODUCTHELPMANUAL' and labeltype = 'jspop' and languagetype='en';
update ld_desk set fieldlabel='帮助中心显示方式' where labelbol='PRODUCTHELPMANUALSHOWTYPE' and labeltype = 'fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Help Centre Dispaly Mode' where labelbol='PRODUCTHELPMANUALSHOWTYPE' and labeltype = 'fixedstr' and languagetype='en';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatsession_conf` (
	`id` int(11) unsigned NOT NULL,
	`corpindex` varchar(50) NOT NULL COMMENT 'wx_crop的主键id',
	`corpid` varchar(50) NOT NULL COMMENT 'corpid',
	`corp_link` varchar(255) NOT NULL COMMENT 'crm地址',
	`secret` varchar(255) NOT NULL COMMENT '会话存档的secret',
	`seq` int(11) DEFAULT '0' COMMENT '会话消息的seq',
	`is_enable` varchar(25) DEFAULT 'no' COMMENT '是否启用 yes启用 no不启用',
	`upload_way` varchar(25) DEFAULT 'local' COMMENT '上传方式 cos local',
	`created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
	`updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
	`thread` varchar(25) DEFAULT '1',
	`uploadthread` varchar(25) DEFAULT '1',
	`secretid` varchar(55) DEFAULT NULL,
	`secretkey` varchar(55) DEFAULT NULL,
	`bucketname` varchar(255) DEFAULT NULL,
	`region` varchar(55) DEFAULT NULL,
	`enable_remind` varchar(10) DEFAULT 'yes' COMMENT '是否开启程序异常提醒',
	`receiverids` varchar(255) DEFAULT '1' COMMENT '接收人账号，多个逗号隔开',
	`remind_content` varchar(255) DEFAULT '会话存档有进程超过6个小时未更新，请您排查是否出现异常！',
	PRIMARY KEY (`id`)
	) ENGINE=InnoDB;
delimiter;
CREATE TABLE IF NOT EXISTS `ld_wechatsession_thread_status` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`thread` varchar(25) DEFAULT '1' COMMENT '线程',
	`status` varchar(25) DEFAULT 'no' COMMENT '线程状态 yes no',
	`threadtype` varchar(25) DEFAULT 'pull' COMMENT '线程状态类型 pull upload',
	`created_at` timestamp NULL DEFAULT '0000-00-00 00:00:00',
	`updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`)
	) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;
CREATE TABLE IF NOT EXISTS `ld_wechatsession_file` (
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	`corpid` varchar(255) NOT NULL COMMENT '企业微信的corpid',
	`secret` varchar(255) NOT NULL COMMENT '会话存档的secret',
	`seq` int(11) DEFAULT '0' COMMENT '会话消息的seq',
	`filepath` text COMMENT '文件路径',
	`filename` varchar(255) DEFAULT NULL COMMENT '文件名称',
	`msgtype` varchar(100) DEFAULT NULL COMMENT '消息类型,生成cos对象键时用到',
	`msgid` varchar(255) DEFAULT NULL COMMENT '消息id',
	`upload_way` varchar(25) DEFAULT NULL COMMENT '上传方式 cos local',
	`requesturl` varchar(255) DEFAULT NULL COMMENT '请求接口地址',
	`thread` int(11) DEFAULT '1' COMMENT '线程',
	`uploadthread` varchar(25) DEFAULT NULL,
	`insertid` int(11) DEFAULT '0' COMMENT 'ld_wechatsession的id',
	`is_finished` varchar(25) DEFAULT 'no' COMMENT '是否上传完成 yes是 no否',
	`send_count` tinyint(2) DEFAULT '0' COMMENT '上传次数',
	`created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY `idx_msgid` (`msgid`),
	KEY `thread` (`thread`,`is_finished`),
	KEY `tthread` (`thread`,`seq`),
	KEY `seq` (`seq`)
	) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wechatsession_all` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`corpid` varchar(255) NOT NULL COMMENT '企业微信的corpid',
	`secret` varchar(255) NOT NULL COMMENT '会话存档的secret',
	`requesturl` varchar(255) DEFAULT NULL COMMENT '请求接口地址',
	`thread` int(11) DEFAULT '1' COMMENT '线程',
	`uploadthread` varchar(25) DEFAULT NULL,
	`is_finished` varchar(25) DEFAULT 'no' COMMENT '是否上传完成 yes是 no否',
	`send_count` tinyint(2) DEFAULT '0' COMMENT '上传次数',
	`seq` int(11) DEFAULT NULL COMMENT '会话消息seq',
	`msgid` varchar(255) DEFAULT NULL COMMENT '消息id，可用此去重',
	`filepath` text COMMENT '文件cos地址',
	`filename` varchar(255) DEFAULT NULL COMMENT '文件名称',
	`action` varchar(100) DEFAULT NULL COMMENT '消息动作，目前有send(发送消息)/recall(撤回消息)/switch(切换企业日志)三种类型',
	`fromid` varchar(255) DEFAULT NULL COMMENT '消息发送方id',
	`tolist` text COMMENT '消息接收方列表',
	`roomid` varchar(100) DEFAULT NULL COMMENT '群聊消息的群id',
	`msgtype` varchar(100) DEFAULT NULL COMMENT '消息类型',
	`content` text COMMENT '消息内容',
	`sdkfileid` text COMMENT '媒体资源的id信息',
	`md5sum` varchar(100) DEFAULT NULL COMMENT '资源的md5值',
	`filesize` varchar(100) DEFAULT NULL COMMENT '资源的文件大小',
	`fileext` varchar(200) DEFAULT NULL COMMENT '文件类型后缀',
	`upload_way` varchar(25) DEFAULT NULL COMMENT '上传方式 cos local',
	`play_length` varchar(255) DEFAULT NULL COMMENT '视频播放长度',
	`corpname` varchar(255) DEFAULT NULL COMMENT '名片所有者所在的公司名称',
	`userid` varchar(255) DEFAULT NULL COMMENT '名片所有者的id',
	`longitude` varchar(255) DEFAULT NULL COMMENT '纬度',
	`latitude` varchar(255) DEFAULT NULL COMMENT '经度',
	`address` text COMMENT '地址信息',
	`title` text COMMENT '标题',
	`zoom` varchar(255) DEFAULT NULL COMMENT '缩放比例',
	`description` text COMMENT '描述',
	`link_url` text COMMENT '链接url地址',
	`image_url` text COMMENT '链接图片url',
	`username` varchar(255) DEFAULT NULL COMMENT '用户名称',
	`displayname` varchar(255) DEFAULT NULL COMMENT '小程序名称',
	`item` text COMMENT '消息记录内的消息内容，批量数据',
	`msgtime` datetime DEFAULT '0000-00-00 00:00:00' COMMENT '消息发送时间戳',
	`createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
	`modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
	`topic` text COMMENT '会议邀请消息：会议主题',
	`starttime` datetime DEFAULT NULL COMMENT '会议开始时间',
	`endtime` datetime DEFAULT NULL COMMENT '会议结束时间',
	`remarks` text COMMENT '会议备注',
	`meetingtype` varchar(255) DEFAULT NULL COMMENT '会议消息类型。101发起会议邀请消息、102处理会议邀请消息',
	`meetingid` varchar(255) DEFAULT NULL COMMENT '会议id。方便将发起、处理消息进行对照',
	`meetingstatus` varchar(255) DEFAULT NULL COMMENT '会议邀请处理状态。1 参加会议、2 拒绝会议、3 待定、4 未被邀请、5 会议已取消、6 会议已过期、7 不在房间内。只有meetingtype为102的时候此字段才有内容',
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE KEY `threadname` (`thread`,`seq`) USING BTREE,
	UNIQUE KEY `idx_msgid` (`msgid`),
	KEY `idx_seq` (`seq`),
	KEY `thread` (`thread`,`is_finished`)
	) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

INSERT INTO ld_wechatsession_thread_status(thread,threadtype)
SELECT '1','pull' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_wechatsession_thread_status WHERE thread = '1' and threadtype='pull');
INSERT INTO ld_wechatsession_thread_status(thread,threadtype)
SELECT '1','pullfile' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_wechatsession_thread_status WHERE thread = '1' and threadtype='pullfile');
INSERT INTO ld_wechatsession_thread_status(thread,threadtype)
SELECT '1','upload' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_wechatsession_thread_status WHERE thread = '1' and threadtype='upload');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder_havetype`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder_havetype`(
	tmp_content text,
	tmp_recieverid INT(19),
	tmp_reltab VARCHAR(100),
	tmp_related_to INT(19),
	tmp_remindstype VARCHAR(100)

		)
BEGIN

	SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
		IF EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds WHERE remindsid=@max_remindid+1) OR EXISTS (SELECT 1 FROM ld_reminds_accepted WHERE remindsid=@max_remindid+1) THEN
			SET @max_remindid=(SELECT MAX(crmid)+10 FROM ld_crmentity);
END IF;

INSERT INTO ld_crmentity(crmid,setype)
SELECT @max_remindid+1,'Reminds';

UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);

INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted,remindstype)
SELECT @max_remindid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0,tmp_remindstype;

end ||
delimiter;

update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/B2pGYY' where label = 'HelpUrl_MultiApproveList';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/uWK9Hr' where label = 'HelpUrl_ListRoles';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/oI3biY' where label = 'HelpUrl_ScopeAuthority';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/lI1agf' where label = 'HelpUrl_TemplatePrintList';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/JUL6VT' where label = 'HelpUrl_ModuleManager';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/kE4sLKzd' where label = 'HelpUrl_OrgSharingDetailView';
update ld_module_setting_byuser set content = 'https://help.51mis.com/docs/XHUCHy' where label = 'HelpUrl_PublicPoolParam';
delimiter;
-- 2024-09-18

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

UPDATE ld_version SET old_version='V8.6.4.4',current_version='V8.6.4.4',remark='V8.6.4.4-20240918',wx_version='V8.6.4.0';
delimiter;