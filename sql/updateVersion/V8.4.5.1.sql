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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RichTextBox','富文本框','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RichTextBox' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RichTextBox','Rich text box','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RichTextBox' and labeltype='fixedstr');
delimiter;

set @tabid = (SELECT tabid FROM ld_tab WHERE `name`='Documents');
update ld_field set presence = 1 where tabid=@tabid and uitype=56 and columnname='filestatus';
delimiter;

set @tabid = (SELECT tabid FROM ld_tab WHERE `name`='Attachment');
update ld_field set presence = 1 where tabid=@tabid and uitype=56 and columnname='isenabled';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MobileTerminal','移动端','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MobileTerminal' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MobileTerminal',"Mobile terminal",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MobileTerminal' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_customtable_columns','tdheader_label_en','varchar','255','');
call AddColumn('ld_customtable_columns','alias','varchar','255','');
call AddColumn('ld_customtable_columns','suffix','varchar','10','');
call AddColumn('ld_customtable_columns','decimal_places','int','5','2');
call AddColumn('ld_customtable_columns','columnstring','text','0','');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CustomTables');
delete from ld_profileallpermission where tabid=@tabid;
SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
    ('index','Create','Delete','Allocate','EditView','Detailview');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE','未授权工商查询接口，请联系供应商授权或使用自有key','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE',"Unauthorized industrial and commercial query interface, please contact the supplier for authorization or use your own key",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UNAUTHORIZEDINDUSTRIALANDCOMMERCIALQUERYINTERFACE' and labeltype='jspop');
delimiter;

update ld_customtable set show_detail='yes'
where not EXISTS(select count(*) from information_schema.columns where table_name = 'ld_customtable_columns' and column_name = 'prefix');
call AddColumn('ld_customtable_columns','prefix','varchar','10','');
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Events');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='advance_stage'; 
SET @fieldname='advance_stage'; 
SET @zh='推进阶段'; 
SET @en='Advance Stage'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='text';
SET @datarang='';
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
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

SET @tabid = (SELECT tabid from ld_tab where name = 'Potentials');
SET @sequence_start = (SELECT sequence from ld_profileallpermission where tabid = @tabid and operation = 22);
SET @sequence_end = (SELECT sequence from ld_profileallpermission where tabid = @tabid and operation = 37);
UPDATE ld_profileallpermission set sequence = sequence-1 where sequence > @sequence_start and sequence <= @sequence_end and tabid = @tabid and @sequence_end >@sequence_start;
UPDATE ld_profileallpermission set sequence = @sequence_end where tabid = @tabid and operation = 22 and @sequence_end >@sequence_start;
delimiter;

SET @tabid = (SELECT tabid from ld_tab where name = 'Leads');
SET @sequence_start = (SELECT sequence from ld_profileallpermission where tabid = @tabid and operation = 22);
SET @sequence_end = (SELECT sequence from ld_profileallpermission where tabid = @tabid and operation = 37);
UPDATE ld_profileallpermission set sequence = sequence-1 where sequence > @sequence_start and sequence <= @sequence_end and tabid = @tabid and @sequence_end >@sequence_start;
UPDATE ld_profileallpermission set sequence = @sequence_end where tabid = @tabid and operation = 22 and @sequence_end >@sequence_start;
delimiter;

select usereportid into @usereportid from ld_usereport where name="Salesforecastandanalysistable";
delete from ld_usereportbasic where usereportid=@usereportid;

insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_potential:closingdate:closingdate:Potentials_closingdate:D','thismonth',8 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_potential:closingdate:closingdate:Potentials_closingdate:D');

insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_receivablesforecast:receivablesforecastdate:receivablesforecastdate:Potentials_receivablesforecastdate:D','thismonth',9 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_receivablesforecast:receivablesforecastdate:receivablesforecastdate:Potentials_receivablesforecastdate:D');

insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'F4:accountname:accountname:Accounts_accountname:I','',10 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'F4:accountname:accountname:Accounts_accountname:I');
delimiter;

alter table ld_stock modify ware_stock_no  varchar(100) ;
alter table ld_outboundorder modify out_no  varchar(100) ;
delimiter;
-- 2021-11-07

CREATE TABLE IF NOT EXISTS `00_stylechangelog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(19) DEFAULT NULL,
  `changetime` datetime DEFAULT NULL,
  `menuback_color` varchar(100) DEFAULT NULL,
  `menuhover_color` varchar(100) DEFAULT NULL,
  `menustyle` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(sequence) into @sequence from ld_parenttab;
select max(parenttabid) into @parenttabid from ld_parenttab;
insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype,allocateid)
select @parenttabid+1,'ShopSettings',@sequence+1,1,'all','' from DUAL
where not exists(select 1 from ld_parenttab where parenttab_label = 'ShopSettings');
delimiter;
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'ShopSettings';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_parenttab',@parenttabid,@parenttabid,'商城设置' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_parenttab' and tabid = @parenttabid and Relateid = @parenttabid);
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_parenttab',@parenttabid,@parenttabid,'Shop Settings' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_parenttab' and tabid = @parenttabid and Relateid = @parenttabid);
delimiter;


SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @tabsequence=(SELECT tabsequence FROM ld_tab WHERE `name`='Products' LIMIT 1);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,'ShopSettings',1,@tabsequence,'ShopSettings',0,'商城设置' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ShopSettings');
SET @i=0;
UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ShopSettings');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,'商城设置' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,'Shop settings' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ShopSettings');
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'ShopSettings';
SET @sequence=1;
INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
SELECT @parenttabid,@tabid,@sequence FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
SET @i=0;
UPDATE ld_parenttabrel SET sequence=(@i:=@i+1) where parenttabid = @parenttabid ORDER BY sequence;
delimiter;

drop PROCEDURE  if EXISTS crm_addtab_intoprofile;
delimiter ||
create PROCEDURE crm_addtab_intoprofile
(
tabname varchar(100),
operation int(10)
)
BEGIN
	declare var_profileid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql='select tabid into @tabid from ld_tab  where ';
	set @sql=CONCAT(@sql, " name='",tabname,"'");
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
	open cur1;
	Fetch cur1 into var_profileid;
	loop1: while  done<>1 DO

        set @sql=" insert into ld_profile2tab(profileid,tabid,permissions) select ";
        set @sql=concat(@sql,var_profileid,",",@tabid,",",0 ," from dual where not exists(select 1 from ld_profile2tab where tabid=",@tabid," and profileid=",var_profileid,")");
        prepare stmt from @sql;
        execute stmt;
        deallocate prepare stmt;

        set @sql=" insert into ld_profileallpermission(tabid,operation,sequence) select ";
        set @sql=concat(@sql,@tabid,",",operation ,",",0, " from dual where not exists(select 1 from ld_profileallpermission where tabid=",@tabid ,' and operation=',operation,")");
        prepare stmt from @sql;
        execute stmt;
        deallocate prepare stmt;

        set @sql=" insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select ";
        set @sql=concat(@sql,var_profileid,',',@tabid,",",operation ,",",0,",",0, " from dual where not exists(select 1 from ld_profile2standardpermissions where profileid=" ,var_profileid," and tabid=",@tabid ,' and operation=',operation,")");
        prepare stmt from @sql;
        execute stmt;
        deallocate prepare stmt;

        Fetch cur1 into var_profileid;
	end while loop1;
	close cur1;
end ||
delimiter;

call crm_addtab_intoprofile('ShopSettings',3);
drop PROCEDURE  if EXISTS crm_addtab_intoprofile;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_shop_homepagetopic` (
    `topicid` int(11) NOT NULL AUTO_INCREMENT,
    `topic_name` varchar(255)  DEFAULT NULL COMMENT '专题名称',
    `sequence` int(11) DEFAULT NULL COMMENT '显示顺序',
    `presence` varchar(20) DEFAULT 'yes' COMMENT 'yes 启用专题  no 不启用',
    `deleted` tinyint(1) DEFAULT 0,
	`created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`topicid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
insert into ld_shop_homepagetopic(topic_name,sequence) select '精选商品',0 from dual where not exists(select 1 from ld_shop_homepagetopic where topic_name = '精选商品');
insert into ld_shop_homepagetopic(topic_name,sequence) select '人气商品',1 from dual where not exists(select 1 from ld_shop_homepagetopic where topic_name = '人气商品');

CREATE TABLE IF NOT EXISTS `ld_shop_homepagetopic_products` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `topicid` int(11) NOT NULL COMMENT '专题id',
    `productid` int(11) NOT NULL COMMENT '产品id',
    `sequence` int(11) NOT NULL COMMENT '排序',
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS `addtableuniqueIndex`;
delimiter ||
CREATE  PROCEDURE `addtableuniqueIndex`(
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
		SET @sql3=CONCAT('alter  table ',tablename,' add  unique ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;
		EXECUTE statement_name;
		DEALLOCATE PREPARE statement_name;
  END IF;

end ||
delimiter;

CALL addtableuniqueIndex('ld_shop_homepagetopic_products','topicid_productid','topicid,productid');
DROP PROCEDURE IF EXISTS `addtableuniqueIndex`;
delimiter;


CREATE TABLE IF NOT EXISTS `ld_shop_productproperty` (
  `id` int(11) NOT NULL auto_increment ,
  `productid` int(11) NOT NULL,
	`productstatus` varchar(255) DEFAULT NULL,
	`putontime`	DATETIME DEFAULT NULL,
    PRIMARY KEY(id,productid)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @modulename='Products';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(select block from ld_field where columnname = 'productname' and tabid = @tabid);
SET @maxseq=(select max(sequence) from ld_field where block = @blockid and tabid = @tabid);
SET @trantable='ld_field';
SET @tablename='ld_shop_productproperty';
SET @columnname='productstatus';
SET @fieldname='productstatus';
SET @zh='商品状态';
SET @en='Commodity status';
SET @uitype=15;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='picklist';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
SET @defaultvalue='下架';

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,1,@defaultvalue,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual
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


call getallprofile("Products");
CALL fieldprofile('Products');
delimiter;

call AddColumn('ld_picklist_set','picklist_allowdelete','varchar','20','yes');
delimiter;


insert into ld_picklist_set(listname,relatetable,picklist_allowedit,picklist_allowdelete)
select 'productstatus','ld_field','no','no' from dual
where not EXISTS(select 1 from ld_picklist_set where listname='productstatus' and relatetable='ld_field');
delimiter;

set @listid=(select listid from ld_picklist_set where listname='productstatus' and relatetable='ld_field');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'上架',1 from dual
where not EXISTS(select 1 from ld_picklist_values where listid=@listid and listvalue='上架');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'下架',2 from dual
where not EXISTS(select 1 from ld_picklist_values where listid=@listid and listvalue='下架');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','pulloffshelf','下架','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='pulloffshelf' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','pulloffshelf','Pull off shelf','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='pulloffshelf' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','putonshelf','上架','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='putonshelf' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','putonshelf','Put on shelf','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='putonshelf' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Batchonshelves','批量上架','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Batchonshelves' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Batchonshelves','Batch on shelves','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Batchonshelves' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Batchoffshelves','批量下架','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Batchoffshelves' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Batchoffshelves','Batch off shelves','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Batchoffshelves' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_shop_settings` (
    `id` int(11) NOT NULL auto_increment PRIMARY KEY,
    `name` varchar(100) NOT NULL,
	`description` varchar(255) DEFAULT NULL,
	`input_content` text(0) DEFAULT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_shop_settings (`name`,description)
select 'InterfaceSettings','小程序接口设置' from dual
where not exists(select 1 from ld_shop_settings where `name`='InterfaceSettings');
delimiter;

insert into ld_shop_settings (`name`,description)
select 'MerchantNoSettings','商户号设置' from dual
where not exists(select 1 from ld_shop_settings where `name`='MerchantNoSettings');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','InterfaceSetting','小程序接口设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='InterfaceSetting' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','InterfaceSetting','Applet interface setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='InterfaceSetting' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MerchantNumberSetting','商户号设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MerchantNumberSetting' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MerchantNumberSetting','Merchant number setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MerchantNumberSetting' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RotationChartSetting','轮播图设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RotationChartSetting' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RotationChartSetting','Rotation chart setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RotationChartSetting' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AppletInterfaceParam','小程序接口参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AppletInterfaceParam' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AppletInterfaceParam','Applet interface parameters','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AppletInterfaceParam' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MerchantInterfaceParam','商户号接口参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MerchantInterfaceParam' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MerchantInterfaceParam','Merchant number interface parameters','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MerchantInterfaceParam' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ApiInterfaceParam','API接口参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ApiInterfaceParam' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ApiInterfaceParam','API interface parameters','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ApiInterfaceParam' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MerchantNum','商户号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MerchantNum' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MerchantNum','Merchant number','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MerchantNum' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MerchantCertificateNum','商户证书序列号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MerchantCertificateNum' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MerchantCertificateNum','Merchant certificate serial number','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MerchantCertificateNum' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APIKEY','api密钥','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APIKEY' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APIKEY','API Key','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APIKEY' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APIV3KEY','apiv3密钥','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APIV3KEY' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APIV3KEY','APIV3 Key','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APIV3KEY' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ShowOnlyTheFirst5Carousels','仅显示前5张轮播图','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ShowOnlyTheFirst5Carousels' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ShowOnlyTheFirst5Carousels','Show only the first 5 carousels','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ShowOnlyTheFirst5Carousels' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NavigationLinkType','导航链接类型','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NavigationLinkType' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NavigationLinkType','Navigation link type','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NavigationLinkType' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NavigationPicture','导航图片','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NavigationPicture' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NavigationPicture','Navigation picture','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NavigationPicture' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_shop_carousels` (
    `carouselid` int(11) NOT NULL auto_increment PRIMARY KEY,
    `linktype` varchar(100) NOT NULL,
	`linkid` int(11) DEFAULT NULL,
	`status` varchar(100) NOT NULL DEFAULT 'yes',
	`carouselseq` int(11) DEFAULT NULL,
	`uploadfile_name` varchar(255) DEFAULT NULL,
	`file_type` varchar(100) DEFAULT NULL,
	`file_path` text(0) DEFAULT NULL,
	`file_size` varchar(100) DEFAULT NULL,
	`newfile_name` varchar(255) DEFAULT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Carousel_ProductCategoryList','产品类别列表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Carousel_ProductCategoryList' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Carousel_ProductCategoryList','Product Category List','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Carousel_ProductCategoryList' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Carousel_Productdetails','产品明细','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Carousel_Productdetails' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Carousel_Productdetails','Product details','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Carousel_Productdetails' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SelectProducts','选择产品','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectProducts' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SelectProducts','Select product','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectProducts' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CreateCarousel','新建轮播图','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateCarousel' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CreateCarousel','Create Carousel','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateCarousel' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Carousel','轮播图','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Carousel' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Carousel','Carousel','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Carousel' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CarouselSetting','轮播图设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CarouselSetting' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CarouselSetting','Carousel setting','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CarouselSetting' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WeChatUser';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'userfrom','yes','ld_wechatuser',1,1,'userfrom','来源',1,2,NULL,NULL,20,746,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'userfrom');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'userfrom';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'来源' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'来源' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call AddColumn('ld_wechatuser','userfrom','varchar','100',NULL);
call AddColumn('ld_wechatuser','userfromvalue','varchar','100',NULL);
delimiter;
-- 2021-11-10

DROP PROCEDURE IF EXISTS `fenbiao_createtables_20190911`;
DROP PROCEDURE IF EXISTS `ldcrm_add_choosebillfield`;
DROP PROCEDURE IF EXISTS `ldcrm_add_chooseaccount`;
DROP PROCEDURE IF EXISTS `ldcrm_add_selectbill_bymodule`;
DROP PROCEDURE IF EXISTS `ldcrm_delete_related_field_by_module`;

DROP PROCEDURE IF EXISTS `ldcrm_delete_related_field_by_module`;
DROP PROCEDURE IF EXISTS `ldcrm_update_attachments_notes`;
DROP PROCEDURE IF EXISTS `reverseproducttooldiscount`;
DROP PROCEDURE IF EXISTS `reverseproducttoolprice`;

DROP PROCEDURE IF EXISTS `altercolumn`;
DROP PROCEDURE IF EXISTS `altercolumnfor_primarykey`;
DROP PROCEDURE IF EXISTS `CopyModuleBlocks`;
DROP PROCEDURE IF EXISTS `CopyModuleQuickActions`;
DROP PROCEDURE IF EXISTS `CopyModuleRelatedLists`;
DROP PROCEDURE IF EXISTS `CopyPicklistDependency`;
DROP PROCEDURE IF EXISTS `CopyProducttoolfield`;
DROP PROCEDURE IF EXISTS `addTranLabel`;
DROP PROCEDURE IF EXISTS `AddRole2Picklist`;

DROP PROCEDURE IF EXISTS `delete_proc_lingdang_nochange_pssword`;
DROP PROCEDURE IF EXISTS `deletebasecolumnformula`;
DROP PROCEDURE IF EXISTS `downloadorpreviewprofile`;

DELETE FROM ld_autotask WHERE presence=1 AND autotaskid<3;
DELETE FROM ld_autotaskquery WHERE autotaskid NOT IN (SELECT autotaskid FROM ld_autotask);
delimiter;


update ld_field set typeofdata='D~O' where columnname='registration_time' and typeofdata='V~O';
update ld_field set typeofdata='D~M' where columnname='registration_time' and typeofdata='V~M';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Receive_mail','收取邮件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Receive_mail' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Receive_mail','Receive mail','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Receive_mail' and labeltype='fixedstr' and languagetype='en');
delimiter;

SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='Documents');
SET @columnname = 'filestatus';
DELETE FROM ld_field where tabid=@tabid and uitype=56 and columnname=@columnname;
delimiter;

SET @tabid = (SELECT tabid FROM ld_tab WHERE `name`='Attachment');
SET @columnname = 'isenabled';
DELETE FROM ld_field where tabid=@tabid and uitype=56 and columnname=@columnname;
delimiter;

DROP PROCEDURE IF EXISTS `reset_reportinfo_20211112`;
delimiter ||
CREATE  PROCEDURE `reset_reportinfo_20211112`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_customtable) THEN
        TRUNCATE TABLE ld_customtable;
        INSERT INTO `ld_customtable` VALUES ('1', '默认报表（默认）', '0', '', null, null, null, null, null, '2021-11-05 16:32:18', null, '0', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('2', '未来一月商机看板', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-05 16:36:54', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('3', '客户全景统计表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-05 16:43:14', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('4', '未来商机看板', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-05 16:50:29', '2021-11-11 14:08:50', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('5', '客户全景统计表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-05 16:57:05', '2021-11-11 14:14:07', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('6', '客户年度服务报告', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-05 17:30:34', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('7', '客户年度服务报告', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-05 17:35:06', '2021-11-11 14:01:16', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('8', '合同跟踪表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-05 17:39:38', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('9', '客户服务汇总表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 09:24:55', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('10', '客户服务汇总表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 09:24:58', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('11', '客户收款金额明细表', '1', '', null, 'yes', 'bottom', 'no', 'yes', '2021-11-08 09:28:30', '2021-11-15 17:26:12', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('12', '客户签约金额明细表', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-08 09:35:10', '2021-11-15 17:26:28', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('13', '客户类型分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 09:37:52', '2021-11-11 15:32:37', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('14', '客户状态分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 09:41:08', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('15', '合同跟踪表-合同订单', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 13:30:14', '2021-11-11 15:45:51', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('16', '合同跟踪表-服务合同', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 13:41:38', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('17', '客户所属行业分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 13:52:03', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('18', '客户人员规模分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 13:58:15', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('19', '客户人员规模分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:00:13', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('20', '客户人员规模分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:05:05', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('21', '客户注册资金分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:09:37', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('22', '客户联系次数排行榜', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:13:03', '2021-11-15 17:27:34', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('23', '客户服务单故障类别统计表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:20:08', '2021-11-15 17:27:57', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('24', '客户公司性质分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:24:34', '2021-11-15 17:28:04', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('25', '客户省份分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:25:42', '2021-11-15 14:44:44', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('26', '客户销售负责人分布统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 14:26:52', '2021-11-15 18:04:56', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('27', '收款业绩统计表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 15:15:01', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('28', '收款业绩统计表', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 15:17:26', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('29', '应收款统计表_按收款计划统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 15:45:07', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('30', '应收款统计表_按收款计划统计', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 15:50:33', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('31', '122', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-08 15:59:56', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('32', '采购订单跟踪表', '69', '', null, 'no', 'top', 'no', 'yes', '2021-11-08 16:20:09', '2021-11-15 15:23:56', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('33', '应付款统计表-按付款计划统计', '69', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-08 16:31:30', '2021-11-15 14:51:19', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('34', '销售排行榜（按合同订单数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 17:12:22', '2021-11-15 15:39:25', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('35', '产品销售排行榜（按合同数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 17:23:01', '2021-11-15 10:07:57', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('36', '产品销售排行榜（按合同金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 17:34:41', '2021-11-11 17:35:13', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('37', '产品销售排行榜', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-08 17:37:04', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('38', 'CESHI11', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 13:48:12', '2021-11-11 13:48:42', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('39', '客户全景测试', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 13:53:17', '2021-11-11 13:55:47', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('40', '客户全景统计表', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 14:16:29', '2021-11-11 14:17:21', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('41', '444', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 14:25:24', '2021-11-11 14:25:27', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('42', '应收款统计表-按收款计划统计', '68', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 17:03:36', '2021-11-15 17:00:31', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('43', '收款计划统计表', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 17:05:10', '2021-11-11 17:05:41', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('44', '产品销量排行榜（按出库单数量）', '70', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 17:38:30', '2021-11-15 16:18:01', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('45', '产品销量排行榜（按出库金额）', '70', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-11 17:40:43', '2021-11-15 16:18:22', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('46', '测试', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 09:49:50', '2021-11-15 09:56:36', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('47', '测试', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 09:50:31', '2021-11-15 09:52:11', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('48', '111', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 09:54:27', '2021-11-15 09:54:33', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('49', 'www', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 10:03:11', '2021-11-15 10:03:13', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('50', 'vvv', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 10:03:48', '2021-11-15 10:03:51', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('51', 'fff', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 10:04:50', '2021-11-15 10:04:52', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('52', 'www', '1', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 10:05:33', '2021-11-15 10:06:55', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('53', '销售排行榜（按服务合同数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:40:24', '2021-11-15 16:54:24', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('54', '销售排行榜（按合同订单金额）', '70', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 15:42:51', '2021-11-15 18:00:22', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('55', '销售排行榜（按服务合同金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:45:27', '2021-11-15 17:58:58', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('56', '销售排行榜（按收款金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:46:46', '2021-11-15 15:47:08', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('57', '销售排行榜（按开票金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:48:17', '2021-11-15 15:48:47', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('58', '销售排行榜（按出库金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:49:30', '2021-11-15 15:49:54', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('59', '产品销量排行榜（按订单数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:51:37', '2021-11-15 17:08:12', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('60', '产品销量排行榜（按订单金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:53:10', '2021-11-15 15:53:48', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('61', '产品销量排行榜（按开票金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:55:33', '2021-11-15 15:56:17', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('62', '产品销量排行榜（按服务合同数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:57:11', '2021-11-15 15:57:33', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('63', '产品销量排行榜（按服务合同金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 15:57:56', '2021-11-15 15:58:22', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('64', '123', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 16:00:15', null, '1', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('65', '应收款统计表_按合同统计', '68', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 16:02:53', '2021-11-15 16:08:39', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('66', '应收款统计表_按出库单统计', '68', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 16:09:41', '2021-11-15 16:10:27', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('67', '应付款统计表_按采购订单统计', '69', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 16:11:45', '2021-11-15 16:12:25', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('68', '销售报表（默认）', '0', '', null, null, null, null, null, '2021-11-15 16:13:31', null, '0', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('69', '采购报表（默认）', '0', '', null, null, null, null, null, '2021-11-15 16:13:43', null, '0', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('70', '统计排名（默认）', '0', '', null, null, null, null, null, '2021-11-15 16:14:11', null, '0', null, '1', '0');
        INSERT INTO `ld_customtable` VALUES ('71', '销售排行榜（按服务合同数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 16:56:21', '2021-11-15 17:58:40', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('72', '产品销量排行榜（按订单数量）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 17:09:43', '2021-11-15 18:01:48', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('73', '78', '70', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 17:15:25', '2021-11-15 17:15:26', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('74', '出库', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 17:37:54', '2021-11-15 17:40:34', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('75', '销售排行榜（按开票金额）', '70', '', null, 'no', 'bottom', 'no', 'no', '2021-11-15 17:42:48', '2021-11-15 17:43:21', '0', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('76', '服务', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 17:53:49', '2021-11-15 17:54:19', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('77', '111', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 17:55:03', '2021-11-15 17:55:04', '1', '1', '1', '0');
        INSERT INTO `ld_customtable` VALUES ('78', '服务', '1', '', null, 'no', 'bottom', 'no', 'yes', '2021-11-15 17:56:06', '2021-11-15 17:58:00', '1', '1', '1', '0');
        
        
        
        TRUNCATE TABLE ld_customtable_columns;
        INSERT INTO `ld_customtable_columns` VALUES ('181', '2', '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('182', '2', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('183', '2', '交付日期', 'ld_salesorder:duedate:duedate:SalesOrder_交付日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('184', '2', '应收余额', 'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('185', '2', '已收总额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('186', '2', '已开票金额', 'ld_salesorder:have_invoicetotal:have_invoicetotal:SalesOrder_已开票金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('187', '2', '未开票金额', 'ld_salesorder:nothave_invoicetotal:nothave_invoicetotal:SalesOrder_未开票金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '6', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('188', '2', '已发货金额', 'ld_salesorder:haveoutboundamount:haveoutboundamount:SalesOrder_已发货金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '7', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('189', '2', '未发货金额', 'ld_salesorder:balanceoutboundamount:balanceoutboundamount:SalesOrder_未发货金额:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '8', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('190', '2', '计划收款日期', 'ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '9', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('191', '2', '最新收款日期', 'ld_paymentplan:actualdate:acutaldate:PaymentPlan_最新收款日期:D', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '10', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('192', '2', '期次', 'ld_paymentplan:periodtime:periodtime:PaymentPlan_期次:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '11', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('193', '2', '已收金额', 'ld_paymentplan:actualamount:actualamount:PaymentPlan_已收金额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '12', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('194', '2', '应收余额', 'ld_paymentplan:receivable_balance:receivable_balance:PaymentPlan_应收余额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '13', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('225', '3', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('226', '3', '客户编号', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('227', '3', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('228', '3', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('229', '3', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('230', '3', '合同状态', 'ld_salesorder:flowstatus:flowstatus:SalesOrder_合同状态:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('231', '3', '审批状态', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '6', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('426', '6', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('427', '6', '详细地址', 'ld_account:bill_street:bill_street:Accounts_详细地址:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('428', '6', '联系人姓名', 'ld_contactdetails:lastname:lastname:Accounts_联系人姓名:V', 'Accounts', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('429', '6', '联系人职务', 'ld_contactdetails:title:title:Accounts_联系人职务:V', 'Accounts', 'no', 'no', 'no', '', 'left', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('430', '6', '办公电话', 'ld_contactdetails:pphone:pphone:Accounts_办公电话:V', 'Accounts', 'no', 'no', 'no', '', 'left', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('431', '6', '联系人手机', 'ld_contactdetails:mobile:mobile:Accounts_联系人手机:V', 'Accounts', 'no', 'no', 'no', '', 'left', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('432', '6', '联系人 Email', 'ld_contactdetails:email:email:Accounts_联系人 Email:V', 'Accounts', 'no', 'no', 'no', '', 'left', '6', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('433', '6', '服务单编号', 'ld_troubletickets:ticket_no:ticket_no:HelpDesk_服务单编号:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '7', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('434', '6', '服务方式', 'ld_troubletickets:servicetype:servicetype:HelpDesk_服务方式:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '8', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('435', '6', '希望处理时间', 'ld_troubletickets:hopetime:hopetime:HelpDesk_希望处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', '9', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('436', '6', '实际处理时间', 'ld_troubletickets:realtime:realtime:HelpDesk_实际处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', '10', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('437', '6', '故障类别', 'ld_troubletickets:category:ticketcategories:HelpDesk_故障类别:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '11', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('438', '6', '处理状态', 'ld_troubletickets:status:ticketstatus:HelpDesk_处理状态:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '12', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('628', '9', '客户名称', 'ld_servicecontracts:accountid:account_id:ServiceContracts_客户名称:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('629', '9', '服务开始日期', 'ld_servicecontracts:start_date:start_date:ServiceContracts_服务开始日期:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('648', '10', '客户名称', 'ld_servicecontracts:accountid:account_id:ServiceContracts_客户名称:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('649', '10', '服务开始日期', 'ld_servicecontracts:start_date:start_date:ServiceContracts_服务开始日期:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('650', '10', '服务到期日', 'ld_servicecontracts:end_date:end_date:ServiceContracts_服务到期日:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('651', '10', '已服务次数', 'ld_servicecontracts:service_units:service_units:ServiceContracts_已服务次数:NN', 'ServiceContracts', 'no', 'no', 'no', 'sum', 'right', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('652', '10', '应服务次数', 'ld_servicecontracts:total_units:total_units:ServiceContracts_应服务次数:NN', 'ServiceContracts', 'no', 'no', 'no', 'sum', 'right', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('653', '10', '合同类型', 'ld_servicecontracts:contract_type:contract_type:ServiceContracts_合同类型:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('726', '14', '客户状态', 'ld_account:rating:rating:Accounts_客户状态:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('727', '14', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('735', '8', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('736', '8', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('936', '16', '负责人', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_负责人:V', 'ServiceContracts', 'yes', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('937', '16', '签约日期', 'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('938', '16', '服务合同编号', 'ld_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('939', '16', '客户名称', 'ld_servicecontracts:accountid:account_id:ServiceContracts_客户名称:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('940', '16', '合计', 'ld_servicecontracts:total:total:ServiceContracts_合计:N', 'ServiceContracts', 'nono', 'no', 'no', 'sum', 'right', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('941', '16', '已收总额', 'ld_servicecontracts:received_amount:received_amount:ServiceContracts_已收总额:N', 'ServiceContracts', 'nono', 'no', 'no', 'sum', 'right', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('942', '16', '应收余额', 'ld_servicecontracts:receivable_balance:receivable_balance:ServiceContracts_应收余额:N', 'ServiceContracts', 'nono', 'no', 'no', 'sum', 'right', '6', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('943', '16', '已开票金额', 'ld_servicecontracts:have_invoicetotal:have_invoicetotal:ServiceContracts_已开票金额:N', 'ServiceContracts', 'nono', 'no', 'no', 'sum', 'right', '7', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('944', '16', '未开票金额', 'ld_servicecontracts:nothave_invoicetotal:nothave_invoicetotal:ServiceContracts_未开票金额:N', 'ServiceContracts', 'nono', 'no', 'no', 'sum', 'right', '8', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1002', '18', '客户规模', 'ld_accountscf:accountsize:accountsize:Accounts_客户规模:V', 'Accounts', 'yes', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1003', '18', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1010', '19', '客户规模', 'ld_accountscf:accountsize:accountsize:Accounts_客户规模:V', 'Accounts', 'yes', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1011', '19', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1016', '17', '所属行业', 'ld_account:industry:industry:Accounts_所属行业:V', 'Accounts', 'yes', 'no', 'no', 'count', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1017', '17', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1032', '20', '客户规模', 'ld_accountscf:accountsize:accountsize:Accounts_客户规模:V', 'Accounts', 'yes', 'no', 'no', 'count', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1033', '20', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1045', '21', '注册资金', 'ld_accountscf:registeredcapital:registeredcapital:Accounts_注册资金:V', 'Accounts', 'yes', 'desc', 'no', 'count', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1046', '21', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1133', '27', '销售负责人', 'ld_cashbill:smownerid:assigned_user_id:CashBill_销售负责人:V', 'CashBill', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1134', '27', '收款单编号', 'ld_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V', 'CashBill', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1135', '27', '客户名称', 'ld_cashbill:accountid:account_id:CashBill_客户名称:V', 'CashBill', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1136', '27', '收款日期', 'ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D', 'CashBill', 'no', 'no', 'no', '', 'left', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1137', '27', '本次收款金额', 'ld_cashbill2paymentplan:amount:amount:CashBill_本次收款金额:N', 'CashBill', 'nono', 'no', 'no', 'sum', 'right', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1138', '27', '收款方式', 'ld_cashbill:paymentmethod:paymentmethod:CashBill_收款方式:V', 'CashBill', 'no', 'no', 'no', '', 'left', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1139', '27', '选择源单', 'ld_cashbill:source_list:selectlistval:CashBill_选择源单:V', 'CashBill', 'no', 'no', 'no', '', 'left', '6', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1147', '28', '销售负责人', 'ld_cashbill:smownerid:assigned_user_id:CashBill_销售负责人:V', 'CashBill', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1148', '28', '收款单编号', 'ld_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V', 'CashBill', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1149', '28', '收款日期', 'ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D', 'CashBill', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1150', '28', '客户名称', 'ld_cashbill:accountid:account_id:CashBill_客户名称:V', 'CashBill', 'no', 'no', 'no', '', 'left', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1152', '29', '负责人', 'ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_负责人:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1153', '29', '客户名称', 'ld_paymentplan:accountid:account_id:PaymentPlan_客户名称:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1231', '30', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1232', '30', '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1233', '30', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1234', '30', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1235', '30', '合计', 'ld_salesorder:total:total:SalesOrder_合计:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '4', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1236', '30', '计划收款日期', 'ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '5', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1237', '30', '收款计划编号', 'ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_收款计划编号:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '6', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1238', '30', '期次', 'ld_paymentplan:periodtime:periodtime:PaymentPlan_期次:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '7', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1239', '30', '金额', 'ld_paymentplan:amount:amount:PaymentPlan_金额:N', 'PaymentPlan', 'nono', 'no', 'no', 'sum', 'right', '8', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1240', '30', '状态', 'ld_paymentplan:paymentstatus:paymentstatus:PaymentPlan_状态:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '9', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1241', '30', '应收余额', 'ld_paymentplan:receivable_balance:receivable_balance:PaymentPlan_应收余额:N', 'PaymentPlan', 'nono', 'no', 'no', 'sum', 'right', '10', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1243', '31', '客户名称', 'ld_leads:accountname:accountname:Leads_客户名称:V', 'Leads', 'no', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1489', '37', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1490', '37', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '1', null, null, null, '0', null, null);
        INSERT INTO `ld_customtable_columns` VALUES ('1797', '38', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1798', '38', '客户编号', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', '客户编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1799', '38', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', '合同编号', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1800', '38', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', '销售负责人', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1801', '38', '合计', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '4', '合计', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1867', '39', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1868', '39', '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', '销售负责人', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1869', '39', '联系人姓名', 'ld_contactdetails:lastname:lastname:Contacts_联系人姓名:V', 'Contacts', 'no', 'no', 'no', '', 'left', '2', '联系人姓名', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1870', '39', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', '合同编号', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1871', '39', '合计', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '4', '合计', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1900', '7', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1901', '7', '服务合同编号', 'ld_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '1', '服务合同编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1902', '7', '服务方式', 'ld_troubletickets:servicetype:servicetype:HelpDesk_服务方式:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '2', '服务方式', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1903', '7', '故障类别', 'ld_troubletickets:category:ticketcategories:HelpDesk_故障类别:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '3', '故障类别', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1904', '7', '希望处理时间', 'ld_troubletickets:hopetime:hopetime:HelpDesk_希望处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', '4', '希望处理时间', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1905', '7', '实际处理时间', 'ld_troubletickets:realtime:realtime:HelpDesk_实际处理时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', '5', '实际处理时间', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1906', '7', '处理状态', 'ld_troubletickets:status:ticketstatus:HelpDesk_处理状态:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '6', '处理状态', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1907', '4', '机会名称', 'ld_potential:potentialname:potentialname:Potentials_机会名称:V', 'Potentials', 'no', 'no', 'no', '', 'left', '0', '机会名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1908', '4', '销售机会编号', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'no', 'no', 'no', '', 'left', '1', '销售机会编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1909', '4', '销售负责人', 'ld_potential:smownerid:assigned_user_id:Potentials_销售负责人:V', 'Potentials', 'no', 'no', 'no', '', 'left', '2', '销售负责人', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1910', '4', '预计成交日期', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'Potentials', 'no', 'no', 'no', '', 'left', '3', '预计成交日期', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1911', '4', '预计合同金额', 'ld_potential:amount:amount:Potentials_预计合同金额:N', 'Potentials', 'no', 'no', 'no', 'sum', 'right', '4', '预计合同金额', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1947', '5', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1948', '5', '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', '销售负责人', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1949', '5', '新建联系人数', 'ld_contactdetails:lastname:lastname:Contacts_联系人姓名:V', 'Contacts', 'no', 'no', 'no', 'count', 'left', '2', '新建联系人数', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1950', '5', '新建机会数', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'no', 'no', 'no', 'count', 'left', '3', '新建机会数', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1951', '5', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '4', '合同编号', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1952', '5', '合计', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '5', '合计', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1953', '5', '服务合同编号', 'ld_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '6', '服务合同编号', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1969', '40', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1970', '40', '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'no', 'no', 'no', '', 'left', '1', '销售负责人', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1971', '40', '联系人编号', 'ld_contactdetails:contact_no:contact_no:Contacts_联系人编号:V', 'Contacts', 'no', 'no', 'no', '', 'left', '2', '联系人编号', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1972', '40', '销售机会编号', 'ld_potential:potential_no:potential_no:Potentials_销售机会编号:V', 'Potentials', 'no', 'no', 'no', '', 'left', '3', '销售机会编号', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1973', '40', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '4', '合同编号', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1974', '40', '合计', 'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N', 'SalesOrder', 'no', 'no', 'no', 'sum', 'right', '5', '合计', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1976', '41', '客户名称', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('1977', '41', '服务合同编号', 'ld_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '1', '服务合同编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2358', '13', '客户类型', 'ld_account:account_type:accounttype:Accounts_客户类型:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '0', '客户类型', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2359', '13', '数量', 'ld_account:accountname:accountname:Accounts_客户名称:V', 'Accounts', 'no', 'no', 'no', 'count', 'left', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2834', '43', '负责人', 'ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_负责人:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2835', '43', '客户名称', 'ld_paymentplan:accountid:account_id:PaymentPlan_客户名称:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '1', '客户名称', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2836', '43', '收款计划编号', 'ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_收款计划编号:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '2', '收款计划编号', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2837', '43', '计划收款日期', 'ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '3', '计划收款日期', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2838', '43', '选择源单', 'ld_paymentplan:entitytypeid:entitytypeid:PaymentPlan_选择源单:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '4', '选择源单', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2839', '43', '最新收款日期', 'ld_paymentplan:actualdate:acutaldate:PaymentPlan_最新收款日期:D', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '5', '最新收款日期', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2840', '43', '期次', 'ld_paymentplan:periodtime:periodtime:PaymentPlan_期次:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '6', '期次', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2841', '43', '金额', 'ld_paymentplan:amount:amount:PaymentPlan_金额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '7', '金额', 'h', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2842', '43', '应收余额', 'ld_paymentplan:receivable_balance:receivable_balance:PaymentPlan_应收余额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '8', '应收余额', 'i', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2843', '43', '已收金额', 'ld_paymentplan:actualamount:actualamount:PaymentPlan_已收金额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '9', '已收金额', 'j', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('2844', '43', '状态', 'ld_paymentplan:paymentstatus:paymentstatus:PaymentPlan_状态:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '10', '状态', 'k', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4036', '36', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4037', '36', '合同金额', 'ld_salesorderdetail:tax_amount:tax_amount:SalesOrder_价税合计:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '合同金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4382', '47', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'no', 'no', 'no', 'count,distinct_count', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4383', '47', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4394', '48', '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4395', '48', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '1', '合同编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4396', '48', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '2', '产品名称', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4397', '48', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '3', '数量', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4404', '46', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4405', '46', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4409', '49', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4410', '49', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4421', '50', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4422', '50', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4423', '50', '计量单位', 'ld_products:usageunit:usageunit:SalesOrder_计量单位:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '2', '计量单位', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4424', '50', '含税单价', 'ld_salesorderdetail:taxprice:taxprice:SalesOrder_含税单价:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '3', '含税单价', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4431', '51', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4432', '51', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4433', '51', '计量单位', 'ld_products:usageunit:usageunit:SalesOrder_计量单位:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '2', '计量单位', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4463', '52', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4464', '52', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4487', '35', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'no', 'count,distinct_count', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4488', '35', '合同数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '合同数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4659', '25', '省份', 'ld_account:bill_state:bill_state:Accounts_省份:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', '0', '省份', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4660', '25', '数量', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'desc', 'no', 'count', 'left', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4870', '33', '采购负责人', 'ld_sendpayment:smownerid:assigned_user_id:SendPayment_采购负责人:V', 'SendPayment', 'yes', 'no', 'no', '', 'left', '0', '采购负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4871', '33', '选择源单', 'ld_sendpayment:purchaseorder_id:purchaseorder_id:SendPayment_选择源单:I', 'SendPayment', 'no', 'no', 'no', '', 'left', '1', '选择源单', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4872', '33', '供应商名称', 'ld_sendpayment:vendorid:vendor_id:SendPayment_供应商名称:V', 'SendPayment', 'no', 'no', 'no', '', 'left', '2', '供应商名称', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4873', '33', '计划付款日期', 'ld_sendpayment:plandate:plandate:SendPayment_计划付款日期:D', 'SendPayment', 'no', 'no', 'no', '', 'left', '3', '计划付款日期', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4874', '33', '付款计划编号', 'ld_sendpayment:sendpayment_no:sendpayment_no:SendPayment_付款计划编号:V', 'SendPayment', 'no', 'no', 'no', '', 'left', '4', '付款计划编号', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4875', '33', '金额', 'ld_sendpayment:amount:amount:SendPayment_金额:N', 'SendPayment', 'no', 'no', 'no', 'sum', 'right', '5', '金额', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4876', '33', '已付金额', 'ld_sendpayment:actualamount:actualamount:SendPayment_已付金额:N', 'SendPayment', 'no', 'no', 'no', 'sum', 'right', '6', '已付金额', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4877', '33', '状态', 'ld_sendpayment:cpstatus:cpstatus:SendPayment_状态:V', 'SendPayment', 'no', 'no', 'no', '', 'left', '7', '状态', 'h', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4878', '33', '应付余额', 'ld_sendpayment:pay_balance:pay_balance:SendPayment_应付余额:N', 'SendPayment', 'no', 'no', 'no', 'sum', 'right', '8', '应付余额', 'i', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4901', '32', '采购负责人', 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V', 'PurchaseOrder', 'yes', 'no', 'no', '', 'left', '0', '采购负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4902', '32', '交付日期', 'ld_purchaseorder:duedate:duedate:PurchaseOrder_交付日期:D', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '1', '交付日期', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4903', '32', '订单状态', 'ld_purchaseorder:postatus:postatus:PurchaseOrder_订单状态:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '2', '订单状态', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4904', '32', '采购订单编号', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '3', '采购订单编号', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4905', '32', '签约日期', 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '4', '签约日期', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4906', '32', '已付总额', 'ld_purchaseorder:pay_amount:pay_amount:PurchaseOrder_已付总额:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', '5', '已付总额', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4907', '32', '应付余额', 'ld_purchaseorder:pay_balance:pay_balance:PurchaseOrder_应付余额:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', '6', '应付余额', 'h', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4908', '32', '未开票金额', 'ld_purchaseorder:nothave_invoicetotal:nothave_invoicetotal:PurchaseOrder_未开票金额:N', 'PurchaseOrder', 'no', 'no', 'no', 'sum', 'right', '7', '未开票金额', 'i', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4909', '32', '供应商名称', 'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_供应商名称:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '8', '供应商名称', 'j', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4910', '32', '创建时间', 'ld_purchaseorder:createdtime:createdtime:PurchaseOrder_创建时间:DT', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '9', '创建时间', 'k', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4911', '32', '合计', 'ld_purchaseorder:total:total:PurchaseOrder_合计:N', 'PurchaseOrder', 'nono', 'no', 'no', 'sum', 'right', '10', '合计', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4924', '34', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('4925', '34', '合同订单_数量', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'desc', 'no', 'count', 'left', '1', '合同订单_数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5005', '56', '销售负责人', 'ld_cashbill:smownerid:assigned_user_id:CashBill_销售负责人:V', 'CashBill', 'yes', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5006', '56', '实际收款金额', 'ld_cashbill:total:hdnGrandTotal:CashBill_实际收款金额:N', 'CashBill', 'no', 'desc', 'no', 'sum', 'right', '1', '实际收款金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5020', '57', '销售负责人', 'ld_invoice:smownerid:assigned_user_id:Invoice_销售负责人:V', 'Invoice', 'yes', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5021', '57', '开票金额', 'ld_invoicedetail:tax_amount:tax_amount:Invoice_价税合计:N', 'Invoice', 'nono', 'desc', 'no', 'sum', 'right', '1', '开票金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5037', '58', '负责人', 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_负责人:V', 'OutboundOrder', 'yes', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5038', '58', '出库金额', 'ld_outboundorderdetail:tax_amount:tax_amount:OutboundOrder_价税合计:N', 'OutboundOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '出库金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5093', '60', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5094', '60', '订单金额', 'ld_salesorderdetail:tax_amount:tax_amount:SalesOrder_价税合计:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '订单金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5114', '61', '产品名称', 'ld_products:productname:productname:Invoice_产品名称:V', 'Invoice', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5115', '61', '开票金额', 'ld_invoicedetail:tax_amount:tax_amount:Invoice_价税合计:N', 'Invoice', 'nono', 'desc', 'no', 'sum', 'right', '1', '开票金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5129', '62', '产品名称', 'ld_products:productname:productname:ServiceContracts_产品名称:V', 'ServiceContracts', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5130', '62', '数量', 'ld_servicecontractsdetail:quantity:quantity:ServiceContracts_数量:N', 'ServiceContracts', 'nono', 'desc', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5146', '63', '产品名称', 'ld_products:productname:productname:ServiceContracts_产品名称:V', 'ServiceContracts', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5147', '63', '价税合计', 'ld_servicecontractsdetail:tax_amount:tax_amount:ServiceContracts_价税合计:N', 'ServiceContracts', 'nono', 'desc', 'no', 'sum', 'right', '1', '价税合计', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5148', '64', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5271', '65', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5272', '65', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '1', '合同编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5273', '65', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', '签约日期', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5274', '65', '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', '客户名称', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5275', '65', '应收余额', 'ld_salesorder:receivable_balance:receivable_balance:SalesOrder_应收余额:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '4', '应收余额', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5276', '65', '已收总额', 'ld_salesorder:received_amount:received_amount:SalesOrder_已收总额:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '5', '已收总额', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5277', '65', '合计', 'ld_salesorder:total:total:SalesOrder_合计:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '6', '合计', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5346', '66', '负责人', 'ld_outboundorder:smownerid:assigned_user_id:OutboundOrder_负责人:V', 'OutboundOrder', 'yes', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5347', '66', '出库单编号', 'ld_outboundorder:out_no:out_no:OutboundOrder_出库单编号:V', 'OutboundOrder', 'no', 'no', 'no', '', 'left', '1', '出库单编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5348', '66', '出库日期', 'ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D', 'OutboundOrder', 'no', 'no', 'no', '', 'left', '2', '出库日期', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5349', '66', '客户名称', 'ld_outboundorder:accountid:account_id:OutboundOrder_客户名称:V', 'OutboundOrder', 'no', 'no', 'no', '', 'left', '3', '客户名称', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5350', '66', '出库状态', 'ld_outboundorder:presence:presence:OutboundOrder_出库状态:V', 'OutboundOrder', 'no', 'no', 'no', '', 'left', '4', '出库状态', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5351', '66', '合计', 'ld_outboundorder:total:total:OutboundOrder_合计:N', 'OutboundOrder', 'nono', 'no', 'no', 'sum', 'right', '5', '合计', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5352', '66', '应收余额', 'ld_outboundorder:receivable_balance:receivable_balance:OutboundOrder_应收余额:N', 'OutboundOrder', 'nono', 'no', 'no', 'sum', 'right', '6', '应收余额', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5353', '66', '已收总额', 'ld_outboundorder:received_amount:received_amount:OutboundOrder_已收总额:N', 'OutboundOrder', 'nono', 'no', 'no', 'sum', 'right', '7', '已收总额', 'h', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5425', '67', '采购负责人', 'ld_purchaseorder:smownerid:assigned_user_id:PurchaseOrder_采购负责人:V', 'PurchaseOrder', 'yes', 'no', 'no', '', 'left', '0', '采购负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5426', '67', '采购订单编号', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '1', '采购订单编号', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5427', '67', '签约日期', 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:D', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '2', '签约日期', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5428', '67', '订单状态', 'ld_purchaseorder:postatus:postatus:PurchaseOrder_订单状态:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '3', '订单状态', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5429', '67', '供应商名称', 'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_供应商名称:V', 'PurchaseOrder', 'no', 'no', 'no', '', 'left', '4', '供应商名称', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5430', '67', '合计', 'ld_purchaseorder:total:total:PurchaseOrder_合计:N', 'PurchaseOrder', 'nono', 'no', 'no', 'sum', 'right', '5', '合计', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5431', '67', '应付余额', 'ld_purchaseorder:pay_balance:pay_balance:PurchaseOrder_应付余额:N', 'PurchaseOrder', 'nono', 'no', 'no', 'sum', 'right', '6', '应付余额', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5432', '67', '已付总额', 'ld_purchaseorder:pay_amount:pay_amount:PurchaseOrder_已付总额:N', 'PurchaseOrder', 'nono', 'no', 'no', 'sum', 'right', '7', '已付总额', 'h', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5433', '44', '产品名称', 'ld_products:productname:productname:OutboundOrder_产品名称:V', 'OutboundOrder', 'yes', 'no', 'yes', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5434', '44', '出库数量', 'ld_outboundorderdetail:quantity:quantity:OutboundOrder_数量:N', 'OutboundOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '出库数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5435', '45', '产品名称', 'ld_products:productname:productname:OutboundOrder_产品名称:V', 'OutboundOrder', 'no', 'no', 'yes', 'count', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5436', '45', '出库金额', 'ld_outboundorderdetail:tax_amount:tax_amount:OutboundOrder_价税合计:N', 'OutboundOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '出库金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5439', '53', '负责人', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_负责人:V', 'ServiceContracts', 'yes', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5440', '53', '服务合同_数量', 'ld_servicecontracts:contract_no:contract_no:ServiceContracts_服务合同编号:V', 'ServiceContracts', 'no', 'desc', 'no', 'count,distinct_count', 'left', '1', '服务合同_数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5463', '42', '负责人', 'ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_负责人:V', 'PaymentPlan', 'yes', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5464', '42', '客户名称', 'ld_paymentplan:accountid:account_id:PaymentPlan_客户名称:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '1', '客户名称', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5465', '42', '计划收款日期', 'ld_paymentplan:plandate:plandate:PaymentPlan_计划收款日期:D', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '2', '计划收款日期', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5466', '42', '收款计划编号', 'ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_收款计划编号:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '3', '收款计划编号', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5467', '42', '期次', 'ld_paymentplan:periodtime:periodtime:PaymentPlan_期次:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '4', '期次', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5468', '42', '金额', 'ld_paymentplan:amount:amount:PaymentPlan_金额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '5', '金额', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5469', '42', '应收余额', 'ld_paymentplan:receivable_balance:receivable_balance:PaymentPlan_应收余额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '6', '应收余额', 'g', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5470', '42', '已收金额', 'ld_paymentplan:actualamount:actualamount:PaymentPlan_已收金额:N', 'PaymentPlan', 'no', 'no', 'no', 'sum', 'right', '7', '已收金额', 'h', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5471', '42', '选择源单', 'ld_paymentplan:entitytypeid:entitytypeid:PaymentPlan_选择源单:V', 'PaymentPlan', 'no', 'no', 'no', '', 'left', '8', '选择源单', 'i', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5530', '59', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5531', '59', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5553', '73', '联系人编号', 'ld_contactdetails:contact_no:contact_no:Contacts_联系人编号:V', 'Contacts', 'no', 'no', 'no', '', 'left', '0', '联系人编号', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5707', '11', '客户名称', 'ld_cashbill:accountid:account_id:CashBill_客户名称:V', 'CashBill', 'yes', 'no', 'yes', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5708', '11', '销售负责人', 'ld_cashbill:smownerid:assigned_user_id:CashBill_销售负责人:V', 'CashBill', 'no', 'no', 'no', '', 'left', '1', '销售负责人', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5709', '11', '实际收款金额', 'ld_cashbill:total:hdnGrandTotal:CashBill_实际收款金额:N', 'CashBill', 'nono', 'desc', 'no', 'sum', 'right', '2', '实际收款金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5710', '11', '收款日期', 'ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D', 'CashBill', 'no', 'no', 'yes', '', 'left', '3', '收款日期', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5711', '11', '收款单编号', 'ld_cashbill:cashbill_no:cashbill_no:CashBill_收款单编号:V', 'CashBill', 'no', 'no', 'yes', '', 'left', '4', '收款单编号', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5712', '11', '审批状态', 'ld_cashbill:approvestatus:approvestatus:CashBill_审批状态:V', 'CashBill', 'no', 'no', 'yes', '', 'left', '5', '审批状态', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5713', '12', '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'yes', 'no', 'yes', '', 'left', '0', '客户名称', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5714', '12', '签约金额', 'ld_salesorderdetail:tax_amount:tax_amount:SalesOrder_价税合计:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '签约金额', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5715', '12', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', '销售负责人', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5716', '12', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', '合同编号', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5717', '12', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '4', '签约日期', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5718', '12', '审批状态', 'ld_salesorder:approvestatus:approvestatus:SalesOrder_审批状态:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '5', '审批状态', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5725', '22', '客户名称', 'ld_contactrecords:accountid:account_id:ContactRecords_客户名称:V', 'ContactRecords', 'yes', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5726', '22', '跟进频次', 'ld_contactrecords:contactrecord_no:contactrecord_no:ContactRecords_跟进记录编号:V', 'ContactRecords', 'no', 'desc', 'no', 'count', 'left', '1', '跟进频次', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5727', '23', '故障类别', 'ld_troubletickets:category:ticketcategories:HelpDesk_故障类别:V', 'HelpDesk', 'yes', 'no', 'yes', '', 'left', '0', '故障类别', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5728', '23', '数量', 'ld_troubletickets:ticket_no:ticket_no:HelpDesk_服务单编号:V', 'HelpDesk', 'no', 'desc', 'no', 'count', 'left', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5731', '24', '公司性质', 'ld_accountscf:accountproperty:accountproperty:Accounts_公司性质:V', 'Accounts', 'yes', 'no', 'yes', '', 'left', '0', '公司性质', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5732', '24', '数量', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'desc', 'no', 'count', 'left', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5763', '74', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5764', '74', '签约日期', 'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D', 'SalesOrder', 'no', 'no', 'no', '', 'left', '1', '签约日期', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5765', '74', '合同编号', 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_合同编号:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '2', '合同编号', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5766', '74', '客户名称', 'ld_salesorder:accountid:account_id:SalesOrder_客户名称:V', 'SalesOrder', 'no', 'no', 'no', '', 'left', '3', '客户名称', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5767', '74', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'nono', 'no', 'no', '', 'left', '4', '产品名称', 'e', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5768', '74', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'no', 'no', 'sum', 'right', '5', '数量', 'f', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5782', '75', '销售负责人', 'ld_invoice:smownerid:assigned_user_id:Invoice_销售负责人:V', 'Invoice', 'yes', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5783', '75', '开票金额', 'ld_invoicedetail:tax_amount:tax_amount:Invoice_价税合计:N', 'Invoice', 'nono', 'desc', 'no', 'sum', 'right', '1', '开票金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5787', '76', '客户名称', 'ld_troubletickets:accountid:account_id:HelpDesk_客户名称:V', 'HelpDesk', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5788', '76', '创建时间', 'ld_troubletickets:createdtime:createdtime:HelpDesk_创建时间:DT', 'HelpDesk', 'no', 'no', 'no', '', 'left', '1', '创建时间', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5789', '76', '收费金额', 'ld_troubletickets:fees:fees:HelpDesk_收费金额:N', 'HelpDesk', 'no', 'no', 'no', 'sum', 'right', '2', '收费金额', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5793', '77', '手机号码', 'ld_leads:mobile:mobile:Leads_手机号码:V', 'Leads', 'no', 'no', 'no', '', 'left', '0', '手机号码', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5794', '77', '商机来源', 'ld_leads:leadsource:leadsource:Leads_商机来源:V', 'Leads', 'no', 'no', 'no', '', 'left', '1', '商机来源', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5795', '77', '负责人', 'ld_leads:smownerid:assigned_user_id:Leads_负责人:V', 'Leads', 'no', 'no', 'no', '', 'left', '2', '负责人', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5812', '78', '客户名称', 'ld_servicecontracts:accountid:account_id:ServiceContracts_客户名称:V', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '0', '客户名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5813', '78', '签约日期', 'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '1', '签约日期', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5814', '78', '小计', 'ld_servicecontracts:subtotal:hdnSubTotal:ServiceContracts_小计:N', 'ServiceContracts', 'no', 'no', 'no', 'sum', 'right', '2', '小计', 'c', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5815', '78', '服务到期日', 'ld_servicecontracts:end_date:end_date:ServiceContracts_服务到期日:D', 'ServiceContracts', 'no', 'no', 'no', '', 'left', '3', '服务到期日', 'd', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5820', '71', '负责人', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_负责人:V', 'ServiceContracts', 'yes', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5821', '71', '数量', 'ld_servicecontractsdetail:quantity:quantity:ServiceContracts_数量:N', 'ServiceContracts', 'nono', 'desc', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5824', '55', '负责人', 'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_负责人:V', 'ServiceContracts', 'yes', 'no', 'no', '', 'left', '0', '负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5825', '55', '服务合同_金额', 'ld_servicecontractsdetail:tax_amount:tax_amount:ServiceContracts_价税合计:N', 'ServiceContracts', 'nono', 'desc', 'no', 'sum', 'right', '1', '服务合同_金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5838', '54', '销售负责人', 'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5839', '54', '合同订单_金额', 'ld_salesorderdetail:tax_amount:tax_amount:SalesOrder_价税合计:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '合同订单_金额', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5842', '72', '产品名称', 'ld_products:productname:productname:SalesOrder_产品名称:V', 'SalesOrder', 'yes', 'no', 'no', '', 'left', '0', '产品名称', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5843', '72', '数量', 'ld_salesorderdetail:quantity:quantity:SalesOrder_数量:N', 'SalesOrder', 'nono', 'desc', 'no', 'sum', 'right', '1', '数量', 'b', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5858', '26', '销售负责人', 'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V', 'Accounts', 'yes', 'no', 'no', '', 'left', '0', '销售负责人', 'a', '', '0', '', '');
        INSERT INTO `ld_customtable_columns` VALUES ('5859', '26', '数量', 'ld_account:account_no:account_no:Accounts_客户编号:V', 'Accounts', 'no', 'asc', 'no', 'count', 'left', '1', '数量', 'b', '', '0', '', '');
        
        
        
        
        TRUNCATE TABLE ld_customtable_condition;
        INSERT INTO `ld_customtable_condition` VALUES ('9', '4', 'ld_potential:closingdate:closingdate:Potentials_预计成交日期  :D', 'g', '2021-11-11');
        INSERT INTO `ld_customtable_condition` VALUES ('16', '32', 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_采购订单编号:V', 'c', '');
        INSERT INTO `ld_customtable_condition` VALUES ('18', '42', 'ld_paymentplan:paymentstatus:paymentstatus:PaymentPlan_状态:V', 'n', '已收');
        
        
        
        TRUNCATE TABLE ld_customtable_module;
        INSERT INTO `ld_customtable_module` VALUES ('1', '2', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('2', '2', '64', 'PaymentPlan', '1');
        INSERT INTO `ld_customtable_module` VALUES ('3', '3', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('4', '3', '22', 'SalesOrder', '3');
        INSERT INTO `ld_customtable_module` VALUES ('5', '3', '65', 'CashBill', '4');
        INSERT INTO `ld_customtable_module` VALUES ('6', '4', '2', 'Potentials', '0');
        INSERT INTO `ld_customtable_module` VALUES ('7', '5', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('8', '5', '4', 'Contacts', '7');
        INSERT INTO `ld_customtable_module` VALUES ('9', '5', '2', 'Potentials', '8');
        INSERT INTO `ld_customtable_module` VALUES ('10', '5', '22', 'SalesOrder', '9');
        INSERT INTO `ld_customtable_module` VALUES ('11', '5', '37', 'ServiceContracts', '10');
        INSERT INTO `ld_customtable_module` VALUES ('12', '6', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('13', '6', '13', 'HelpDesk', '12');
        INSERT INTO `ld_customtable_module` VALUES ('14', '7', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('15', '7', '37', 'ServiceContracts', '14');
        INSERT INTO `ld_customtable_module` VALUES ('16', '7', '13', 'HelpDesk', '15');
        INSERT INTO `ld_customtable_module` VALUES ('17', '8', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('18', '8', '94', 'Commission', '17');
        INSERT INTO `ld_customtable_module` VALUES ('19', '9', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('20', '9', '13', 'HelpDesk', '19');
        INSERT INTO `ld_customtable_module` VALUES ('21', '10', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('22', '10', '13', 'HelpDesk', '21');
        INSERT INTO `ld_customtable_module` VALUES ('23', '11', '65', 'CashBill', '0');
        INSERT INTO `ld_customtable_module` VALUES ('24', '12', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('25', '13', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('26', '14', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('27', '15', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('28', '15', '37', 'ServiceContracts', '27');
        INSERT INTO `ld_customtable_module` VALUES ('29', '16', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('30', '17', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('31', '18', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('32', '19', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('33', '20', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('34', '21', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('35', '22', '55', 'ContactRecords', '0');
        INSERT INTO `ld_customtable_module` VALUES ('36', '23', '13', 'HelpDesk', '0');
        INSERT INTO `ld_customtable_module` VALUES ('37', '24', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('38', '25', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('39', '26', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('40', '27', '65', 'CashBill', '0');
        INSERT INTO `ld_customtable_module` VALUES ('41', '28', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('42', '28', '65', 'CashBill', '41');
        INSERT INTO `ld_customtable_module` VALUES ('43', '29', '64', 'PaymentPlan', '0');
        INSERT INTO `ld_customtable_module` VALUES ('44', '30', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('45', '30', '64', 'PaymentPlan', '44');
        INSERT INTO `ld_customtable_module` VALUES ('46', '31', '138', 'Leads', '0');
        INSERT INTO `ld_customtable_module` VALUES ('47', '31', '55', 'ContactRecords', '46');
        INSERT INTO `ld_customtable_module` VALUES ('48', '32', '21', 'PurchaseOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('49', '33', '79', 'SendPayment', '0');
        INSERT INTO `ld_customtable_module` VALUES ('50', '34', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('51', '35', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('52', '36', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('53', '37', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('54', '38', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('55', '38', '22', 'SalesOrder', '54');
        INSERT INTO `ld_customtable_module` VALUES ('56', '39', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('57', '39', '4', 'Contacts', '56');
        INSERT INTO `ld_customtable_module` VALUES ('58', '39', '22', 'SalesOrder', '57');
        INSERT INTO `ld_customtable_module` VALUES ('59', '39', '37', 'ServiceContracts', '58');
        INSERT INTO `ld_customtable_module` VALUES ('60', '40', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('61', '40', '4', 'Contacts', '60');
        INSERT INTO `ld_customtable_module` VALUES ('62', '40', '2', 'Potentials', '61');
        INSERT INTO `ld_customtable_module` VALUES ('63', '40', '22', 'SalesOrder', '62');
        INSERT INTO `ld_customtable_module` VALUES ('64', '40', '37', 'ServiceContracts', '63');
        INSERT INTO `ld_customtable_module` VALUES ('65', '40', '64', 'PaymentPlan', '64');
        INSERT INTO `ld_customtable_module` VALUES ('66', '40', '65', 'CashBill', '65');
        INSERT INTO `ld_customtable_module` VALUES ('67', '41', '6', 'Accounts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('68', '41', '37', 'ServiceContracts', '67');
        INSERT INTO `ld_customtable_module` VALUES ('69', '41', '13', 'HelpDesk', '68');
        INSERT INTO `ld_customtable_module` VALUES ('70', '42', '64', 'PaymentPlan', '0');
        INSERT INTO `ld_customtable_module` VALUES ('71', '43', '64', 'PaymentPlan', '0');
        INSERT INTO `ld_customtable_module` VALUES ('72', '44', '70', 'OutboundOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('73', '45', '70', 'OutboundOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('74', '46', '21', 'PurchaseOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('75', '47', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('76', '48', '70', 'OutboundOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('77', '49', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('78', '53', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('79', '54', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('80', '55', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('81', '56', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('82', '57', '65', 'CashBill', '0');
        INSERT INTO `ld_customtable_module` VALUES ('83', '58', '23', 'Invoice', '0');
        INSERT INTO `ld_customtable_module` VALUES ('84', '59', '70', 'OutboundOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('85', '46', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('86', '47', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('87', '48', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('88', '49', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('89', '50', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('90', '51', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('91', '52', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('92', '53', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('93', '54', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('94', '55', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('95', '56', '65', 'CashBill', '0');
        INSERT INTO `ld_customtable_module` VALUES ('96', '57', '23', 'Invoice', '0');
        INSERT INTO `ld_customtable_module` VALUES ('97', '58', '70', 'OutboundOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('98', '59', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('99', '60', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('100', '61', '23', 'Invoice', '0');
        INSERT INTO `ld_customtable_module` VALUES ('101', '62', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('102', '63', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('103', '64', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('104', '65', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('105', '66', '70', 'OutboundOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('106', '67', '21', 'PurchaseOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('107', '71', '37', 'ServiceContracts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('108', '72', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('109', '73', '4', 'Contacts', '0');
        INSERT INTO `ld_customtable_module` VALUES ('110', '74', '22', 'SalesOrder', '0');
        INSERT INTO `ld_customtable_module` VALUES ('111', '74', '70', 'OutboundOrder', '110');
        INSERT INTO `ld_customtable_module` VALUES ('112', '75', '23', 'Invoice', '0');
        INSERT INTO `ld_customtable_module` VALUES ('113', '76', '13', 'HelpDesk', '0');
        INSERT INTO `ld_customtable_module` VALUES ('114', '77', '138', 'Leads', '0');
        INSERT INTO `ld_customtable_module` VALUES ('115', '78', '37', 'ServiceContracts', '0');
        
        
        
        TRUNCATE TABLE ld_customtable2user;
        INSERT INTO `ld_customtable2user` VALUES ('2', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('3', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('4', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('5', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('6', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('7', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('8', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('9', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('10', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('11', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('12', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('13', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('14', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('15', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('16', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('17', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('18', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('19', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('20', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('21', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('22', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('23', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('24', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('25', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('26', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('27', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('28', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('29', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('30', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('31', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('32', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('33', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('34', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('35', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('36', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('37', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('38', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('39', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('40', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('41', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('42', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('43', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('44', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('45', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('46', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('47', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('48', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('49', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('53', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('54', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('55', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('56', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('57', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('58', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('59', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('46', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('47', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('48', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('49', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('50', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('51', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('52', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('53', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('54', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('55', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('56', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('57', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('58', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('59', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('60', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('61', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('62', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('63', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('64', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('65', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('66', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('67', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('71', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('72', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('73', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('74', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('75', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('76', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('77', '-1');
        INSERT INTO `ld_customtable2user` VALUES ('78', '-1');

        DELETE FROM ld_customtable_columns WHERE `columns` LIKE 'ld_cashbill:approvestatus:%' AND NOT EXISTS (SELECT 1 FROM ld_field WHERE tablename='ld_cashbill' AND columnname='approvestatus' AND presence<>1);
	END IF;


end ||
delimiter;


CALL reset_reportinfo_20211112();
DROP PROCEDURE IF EXISTS `reset_reportinfo_20211112`;
delimiter;
-- 2021-11-12

update ld_desk set fieldlabel = '已添加' where languagetype = 'zh' and labelbol = 'SUCCESSADDCART' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Added' where languagetype = 'en' and labelbol = 'SUCCESSADDCART' and Labeltype = 'fixedstr';
delimiter;
-- 2021-11-15

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

UPDATE ld_version SET old_version='V8.4.5.1',current_version='V8.4.5.1',remark='V8.4.5.1-20211115',wx_version='V8.4.5.2';
delimiter;