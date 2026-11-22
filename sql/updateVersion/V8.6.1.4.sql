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

update ld_desk set fieldlabel = '驳回，返回初始状态' where labelbol = 'NOTPASSRETURNCHARGE' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Reject, return to initial state' where labelbol = 'NOTPASSRETURNCHARGE' and languagetype = 'en';
delimiter;

update ld_homestuffdetail set viewrange='' ,advance_demand='',advance_demand_groups='' where stuffid=2 and stufflabel="signNewAccount_Sales";
update ld_homestuffdetail set viewrange='' ,advance_demand='',advance_demand_groups='' where stuffid=2 and stufflabel="signNewAccount_Service";
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT 'zh','PleaseEnterColumnSearchFor','请输入要查找的栏目', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'PleaseEnterColumnSearchFor' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT 'en','PleaseEnterColumnSearchFor','Please enter the category you are looking for', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'PleaseEnterColumnSearchFor' AND labeltype = 'jspop' );
delimiter;
-- 2023-11-17

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='lastservicedate' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

SET @columnname='earlyservicedate';
SET @fieldname='earlyservicedate';
SET @zh='最早服务到期日';
SET @en='Early Service Date';

SET @uitype=5;
SET @typeofdata='D~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='date';
SET @datarang='all';
SET @maxrowsshow=5;

SET @sequence = (SELECT sequence FROM ld_field WHERE tabid = @tabid and columnname = 'lastservicedate');
set @have_field = (SELECT 1 FROM ld_field WHERE tabid = @tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field SET sequence = sequence + 1 WHERE tabid = @tabid AND block = @relateid AND sequence >= @sequence AND IFNULL(@have_field, 0) = 0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@sequence,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

call AddColumn(@tablename,@columnname,'date','','');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='lastservicedate' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);

SET @columnname='earlyservicedate';
SET @fieldname='earlyservicedate';
SET @zh='最早服务到期日';
SET @en='Early Service Date';

SET @uitype=5;
SET @typeofdata='D~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='date';
SET @datarang='all';
SET @maxrowsshow=5;

SET @sequence = (SELECT sequence FROM ld_field WHERE tabid = @tabid and columnname = 'lastservicedate');
set @have_field = (SELECT 1 FROM ld_field WHERE tabid = @tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field SET sequence = sequence + 1 WHERE tabid = @tabid AND block = @relateid AND sequence >= @sequence AND IFNULL(@have_field, 0) = 0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@sequence,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

call AddColumn(@tablename,@columnname,'date','','');
delimiter;

CREATE TABLE IF NOT EXISTS ld_minservicedate (
   `inventoryid` int(19) DEFAULT NULL,
   `productid` int(19) DEFAULT NULL,
   `accountid` int(19) DEFAULT NULL,
   `service_enddate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from  ld_relatedlists_seq;
set @id=@id+1;
select tabid into @mintabid from ld_tab where name='customform100';
select tabid into @maxtabid from ld_tab where name='customform200';
select max(sequence) into  @maxsequence from ld_relatedlists where tabid=6;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
select @id:=@id+1,6,tabid `name`,1,@maxsequence:=@maxsequence+1,`name`,1,'add','datacategory_sql',concat(`name`,'.accountid')
from ld_tab   where      tabid not in 
(select related_tabid from ld_relatedlists where tabid=6 and related_tabid >=@mintabid and related_tabid<=@maxtabid)
and  tabid >=@mintabid and tabid<=@maxtabid;
update ld_relatedlists_seq set  id=@id;
delimiter;
 
CALL AddColumn('ld_field','autowordwrap','varchar','20','no');
delimiter;

CALL AddColumn('ld_producttoolfield','autowordwrap','varchar','20','yes');
delimiter;

CALL AddColumn('ld_tabdetailfield','autowordwrap','varchar','20','yes');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AutoWordWrap','内容过多自动换行','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AutoWordWrap' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AutoWordWrap','Automatically wrap when too much content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='AutoWordWrap' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_field
SET autowordwrap = 'yes'
WHERE (bigtype = 'textarea' OR bigtype = 'longtextarea')
  AND (
    SELECT deploy_value FROM ld_systems_deploy
    WHERE deploy_type = 206
  ) = 0;
delimiter;

SET @stufftitle = 'LeadsFunnel';
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
select '113',@stufftitle,'chart','Leads','Leads,Accounts,Potentials,SalesOrder,CashBill' from dual
where not exists(select 1 from ld_stuff where stuffid='113' and stufftitle=@stufftitle and stufftype='chart');
delimiter;

SET @labelbol = 'LeadsFunnel';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'线索漏斗','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Funnel Of Leads','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'dingtalk_tabid_not_null';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'所属模块不能为空！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Dingtalk group message moudule can not be empty!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

set @labelbol = 'AmountReceived';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'已收金额','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Amount Received','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @labelbol = 'AmountNotReceived';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'未收金额','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Amount Not Received','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @labelbol = 'BILLNUM';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'单据数量','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Bill Num','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @labelbol = 'TransitionRate';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'转换率','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Conversion Rate','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @labelbol = 'TransitionRateMethod';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'转换率计算方式','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Conversion Rate Calculation','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @labelbol = 'CategoricalFields';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,'线索分类字段','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,'Categorical Fields','jspop' from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype='jspop' and languagetype='en');
delimiter;

set @tabid = (SELECT tabid FROM ld_tab WHERE `name` = "Products");
UPDATE ld_field SET uitype = 69 WHERE columnname = 'appshareimage' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LEGANENTITYTYPE','法人类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LEGANENTITYTYPE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LEGANENTITYTYPE','Legal entity type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='LEGANENTITYTYPE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENTERPRISERATING','企业评分','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTERPRISERATING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENTERPRISERATING','Enterprise rating','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENTERPRISERATING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','isMicroEnt','是否是小微企业 ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='isMicroEnt' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','isMicroEnt','Is it a  micro enterprise','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='isMicroEnt' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENGLISHNAME','英文名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENGLISHNAME' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENGLISHNAME','English name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ENGLISHNAME' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURRENCYREGISTEREDCAPITAL','注册资本币种','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CURRENCYREGISTEREDCAPITAL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURRENCYREGISTEREDCAPITAL','Currency of registered capital','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CURRENCYREGISTEREDCAPITAL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PAIDIDREGISTERED','实收注册资本币种','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PAIDIDREGISTERED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PAIDIDREGISTERED','Paid-in registered capital currency','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PAIDIDREGISTERED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @i = 0;
set @tabid = (select tabid from ld_tab where `name`='Accounts');
update ld_business_backfillfield set sequence=(@i:=@i+1) where tabid=@tabid ORDER BY sequence;
delimiter;
SET @tabid = (select tabid from ld_tab where `name`='Accounts');
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'LEGANENTITYTYPE', 'type', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'type' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'ENTERPRISERATING', 'percentileScore', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'percentileScore' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'isMicroEnt', 'isMicroEnt', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'isMicroEnt' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'ENGLISHNAME', 'property3', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'property3' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'CURRENCYREGISTEREDCAPITAL', 'regCapitalCurrency', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'regCapitalCurrency' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'PAIDIDREGISTERED', 'actualCapitalCurrency', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'actualCapitalCurrency' and tabid = @tabid);
delimiter;

SET @i = 0;
set @tabid = (select tabid from ld_tab where `name`='ServiceCharge');
update ld_business_backfillfield set sequence=(@i:=@i+1) where tabid=@tabid ORDER BY sequence;
delimiter;
SET @tabid = (select tabid from ld_tab where `name`='ServiceCharge');
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'LEGANENTITYTYPE', 'type', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'type' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'ENTERPRISERATING', 'percentileScore', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'percentileScore' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'isMicroEnt', 'isMicroEnt', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'isMicroEnt' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'ENGLISHNAME', 'property3', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'property3' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'CURRENCYREGISTEREDCAPITAL', 'regCapitalCurrency', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'regCapitalCurrency' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'PAIDIDREGISTERED', 'actualCapitalCurrency', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'actualCapitalCurrency' and tabid = @tabid);
delimiter;

SET @i = 0;
set @tabid = (select tabid from ld_tab where `name`='Vendors');
update ld_business_backfillfield set sequence=(@i:=@i+1) where tabid=@tabid ORDER BY sequence;
delimiter;
SET @tabid = (select tabid from ld_tab where `name`='Vendors');
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'LEGANENTITYTYPE', 'type', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'type' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'ENTERPRISERATING', 'percentileScore', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'percentileScore' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'isMicroEnt', 'isMicroEnt', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'isMicroEnt' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'ENGLISHNAME', 'property3', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'property3' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'CURRENCYREGISTEREDCAPITAL', 'regCapitalCurrency', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'regCapitalCurrency' and tabid = @tabid);
set @maxsequence = (select max(sequence)+1 from ld_business_backfillfield where tabid = @tabid);
INSERT INTO `ld_business_backfillfield` (`tabid`, `tianyanchalabel`, `tianyanchaname`, `trancolumnname`, `defaultvalue`, `trancoltype`, `sequence`)
select @tabid, 'PAIDIDREGISTERED', 'actualCapitalCurrency', '', 'null', '', @maxsequence FROM DUAL
where not EXISTS(select 1 from ld_business_backfillfield where tianyanchaname = 'actualCapitalCurrency' and tabid = @tabid);
delimiter;

INSERT INTO ld_desk (languagetype, labelbol, fieldlabel, labeltype )
SELECT'zh','dragstuff','请从左侧拖拽报表组件至此处', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'dragstuff' AND labeltype = 'jspop' );
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype )
SELECT'en','dragstuff','Please drag the stuff from the left to this point', 'jspop' FROM DUAL
where NOT EXISTS ( SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = 'dragstuff' AND labeltype = 'jspop' );
delimiter;

SET @module='Products';
SET @rel_module='Campaigns';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Campaigns');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
DELETE FROM ld_relatedlists
WHERE tabid=@tabid  AND related_tabid=@rel_tabid AND `name`=@template AND type='datacategory_sql' AND related_coltable='campaign.product_id';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,1,'add','datacategory_sql','campaign.product_id' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

SET @fieldtypeid=(SELECT MAX(fieldtypeid) FROM ld_ws_fieldtype);
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @fieldtypeid+1,52,'createuser' from dual
where not exists(select 1 from ld_ws_fieldtype where uitype=52);
insert into ld_ws_referencetype(fieldtypeid,type)
select ld_ws_fieldtype.fieldtypeid,'Users' from ld_ws_fieldtype
where  ld_ws_fieldtype.uitype=52 and not exists(select 1 from ld_ws_referencetype where ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid);

SET @fieldtypeid=(SELECT MAX(fieldtypeid) FROM ld_ws_fieldtype);
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @fieldtypeid+1,153,'selectoneuser' from dual
where not exists(select 1 from ld_ws_fieldtype where uitype=153);
insert into ld_ws_referencetype(fieldtypeid,type)
select ld_ws_fieldtype.fieldtypeid,'Users' from ld_ws_fieldtype
where  ld_ws_fieldtype.uitype=153 and not exists(select 1 from ld_ws_referencetype where ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEINPUTYOUWANTTOFINDTHELEVEL','请输入要查找的职位','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASEINPUTYOUWANTTOFINDTHELEVEL' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEINPUTYOUWANTTOFINDTHELEVEL',"please input you want to find the level",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASEINPUTYOUWANTTOFINDTHELEVEL' and labeltype='jspop');
delimiter;
-- 2023-11-23

CALL DelColumn('ld_troubletickets','parent_id');
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
delete from ld_field where tabid=@tabid and columnname='parent_id';
delimiter;
call AddColumn('ld_users', 'kis_id', 'varchar', '100', null);
call AddColumn('ld_users', 'kis_no', 'varchar', '100', null);
CALL AddColumn('ld_users', 'exchtime', 'datetime', '', '');
CALL AddColumn('ld_users', 'exchmsg', 'text', '', '');
delimiter;

UPDATE ld_desk
SET fieldlabel='不允许直接新增，可通过费用预算单关联新建'
WHERE  labelbol='How_to_create_budgetchange_infos' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

UPDATE ld_desk
SET fieldlabel='Direct addition is not allowed, but can be created through association with expense budget documents'
WHERE  labelbol='How_to_create_budgetchange_infos' and Labeltype='fixedstr' and languagetype='en';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LINK2ERP','连接ERP','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'LINK2ERP' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LINK2ERP','Connect to ERP','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'LINK2ERP' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOREFERENCEWORKCONTENTS','自动引用工作内容','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOREFERENCEWORKCONTENTS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOREFERENCEWORKCONTENTS',"Automatically reference work contents",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOREFERENCEWORKCONTENTS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTREFERENCETIME','选择引用时间','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTREFERENCETIME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTREFERENCETIME',"Select reference time",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTREFERENCETIME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTREFERENCEMODULE','选择引用对象','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTREFERENCEMODULE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTREFERENCEMODULE',"Select related module",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTREFERENCEMODULE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTREFERENCEFIELDS','选择引用字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTREFERENCEFIELDS' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTREFERENCEFIELDS',"Select reference fields",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTREFERENCEFIELDS' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCORDINGTODATARANGEOFWORKREPORT','根据工作汇报所属日期范围显示','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ACCORDINGTODATARANGEOFWORKREPORT' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCORDINGTODATARANGEOFWORKREPORT',"According to the date range of the work report",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ACCORDINGTODATARANGEOFWORKREPORT' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LATESTTIME','最新一次','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LATESTTIME' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LATESTTIME',"Latest",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LATESTTIME' and labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_workreport_field','relatedmodulefield','VARCHAR','10','no');
CALl AddColumn('ld_workreport_field','related_time','VARCHAR','100','');
CALl AddColumn('ld_workreport_field','related_fieldid','VARCHAR','100','');
update ld_workreport_field set related_time = 'latest',related_fieldid = 2 where name='worksummary' and type=1 and id=1;
update ld_workreport_field set related_time = 'thisweek',related_fieldid = 1 where name='worksummary' and type=2 and id=3;
update ld_workreport_field set related_time = 'thismonth',related_fieldid = 4 where name='worksummary' and type=3 and id=7;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplaysOpenNewTabBtn','相关模块显示“打开新页签”按钮','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplaysOpenNewTabBtn' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplaysOpenNewTabBtn','The relevant module displays the "Open New Tab" button','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplaysOpenNewTabBtn' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETSEARCHFIELDSONE','至少设置1个查询字段','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETSEARCHFIELDSONE' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETSEARCHFIELDSONE','Set at least one search field','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETSEARCHFIELDSONE' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETRESULTFIELDS','至少设置3个查重内容显示字段','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETRESULTFIELDS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETRESULTFIELDS','Set at least one result field','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol = 'SETRESULTFIELDS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetQueryFields','设置查询字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetQueryFields' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetQueryFields','Set query fields','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetQueryFields' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetDisplayFieldsForDuplicate','设置查重内容显示字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetDisplayFieldsForDuplicate' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetDisplayFieldsForDuplicate','Set the display field of the duplicate content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetDisplayFieldsForDuplicate' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SetAtLeastOneQueryField','至少设置1个查询字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAtLeastOneQueryField' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SetAtLeastOneQueryField','Set at least one query field for duplicate','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='SetAtLeastOneQueryField' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WhetherQueryBasedOnField','是否根据此字段查询','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherQueryBasedOnField' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WhetherQueryBasedOnField','Whether to query based on this field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='WhetherQueryBasedOnField' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALL AddColumn('ld_cvcolumnlist_wx','isforsearch','varchar','20','yes');
delimiter;

UPDATE ld_field SET allowdelete='no' WHERE fieldname='cf_7551'
	AND tabid=(SELECT tabid FROM ld_tab WHERE name='Accounts') 
	AND EXISTS (SELECT 1 FROM ld_version WHERE account = 'zhongsi');

UPDATE ld_field SET allowdelete='no' WHERE fieldname IN ('cf_7754','cf_7829','cf_7830','cf_7816','cf_7755','cf_7756','cf_7757','cf_7759','cf_7758','cf_7760','cf_7763') 
	AND tabid=(SELECT tabid FROM ld_tab WHERE name='CustomForm54')
	AND EXISTS (SELECT 1 FROM ld_version WHERE account = 'zhongsi');
delimiter;
-- 2023-11-24

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

UPDATE ld_version SET old_version='V8.6.1.4',current_version='V8.6.1.4',remark='V8.6.1.4-20231124',wx_version='V8.6.1.4';
delimiter;