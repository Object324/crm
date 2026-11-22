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

DROP PROCEDURE IF EXISTS `DelColumn`;
delimiter ||
CREATE  PROCEDURE `DelColumn`(
	tablename varchar(50),
	columnname varchar(50)
)
begin

	select database() into @tableschema;

	set tablename=lower(tablename);
	set @colName='';
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

	prepare stmt from @tsql;
	execute stmt;

	set @coldel=IFNULL(@colName,'-1');

	IF @coldel <> '-1'  and  @coldel=columnname THEN

		set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);
		prepare stalter from @altercolumn;
		execute stalter;
		deallocate prepare stalter;
	END IF;

	deallocate prepare stmt;

end ||
delimiter;

CREATE TABLE IF NOT EXISTS `ld_articles` (
	`id` INT (11) UNSIGNED AUTO_INCREMENT COMMENT '自增ID',
	`title` varchar(100) COMMENT '文章标题',
	`create_time` datetime COMMENT '创建时间',
	`smownerid` int(11) COMMENT 'crm的创建人id，若仅是微信用户则无',
	`wx_user_id` int(11) COMMENT 'wx的创建人id，若仅是crm用户则无',
	`origin_url` text COMMENT '文章来源url',
	`origin_id` int(11) COMMENT '文章来源id',
	`cover_url` text COMMENT '封面图',
	`content` text COMMENT '文章内容',
	`like_nums` text COMMENT '点赞次数',
	`share_nums` text COMMENT '分享次数',
	`copy_nums` text COMMENT '转载次数',
	`look_nums` text COMMENT '浏览次数',
	PRIMARY KEY (`id`)
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

call AddColumn('ld_articles','deleted','int',11,0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wx_users` (
	`id` INT (11) UNSIGNED AUTO_INCREMENT COMMENT '自增ID',
	`avatar` text COMMENT '头像',
	`crm_user_id` int(11) COMMENT 'crm用户id',
	`nickname` varchar(20) COMMENT '昵称',
	`tel` varchar(20) COMMENT '电话',
	`open_id` varchar(255) COMMENT '',
	`create_time` datetime COMMENT '创建时间',
	`subscribe` varchar(10) COMMENT '是否关注 yes no',
	`subscribe_time` datetime COMMENT '关注时间',
	PRIMARY KEY (`id`)
) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;


SELECT
	max(tabid) INTO @maxtabid
FROM
	ld_tab;

SELECT
	tabsequence INTO @tabsequence
FROM
	ld_tab
WHERE
	`name` = 'Accounts';

UPDATE ld_tab
SET tabsequence = tabsequence + 1000
WHERE
	tabsequence >= @tabsequence;

INSERT INTO ld_tab (
	tabid,
	NAME,
	presence,
	tabsequence,
	tablabel,
	parent,
	printtab,
	isduplicate
) 
SELECT
	@maxtabid + 1,
	'Articles',
	0 ,@tabsequence + 1,
	'Articles',
	null,1,'yes'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE NAME = 'Articles');
delimiter;

SET @i = 0;
UPDATE ld_tab SET tabsequence = (@i :=@i + 1) ORDER BY tabsequence;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Articles';
INSERT INTO ld_tranlabel (
	languagetype,
	trantable,
	tabid,
	relateid,
	fieldlabel
) 
SELECT
	'zh',
	'ld_tab' ,@tabid ,@tabid,
	'获客文章'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_tranlabel
		WHERE
			tabid =@tabid
		AND relateid =@tabid
		AND languagetype = 'zh'
		AND trantable = 'ld_tab'
	);

INSERT INTO ld_tranlabel (
	languagetype,
	trantable,
	tabid,
	relateid,
	fieldlabel
) SELECT
	'en',
	'ld_tab' ,@tabid ,@tabid,
	'Articles'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_tranlabel
		WHERE
			tabid =@tabid
		AND relateid =@tabid
		AND languagetype = 'en'
		AND trantable = 'ld_tab'
	);

INSERT INTO ld_parenttabrel (
	parenttabid,
	tabid,
	tab_tablename
) SELECT
	2,
	@tabid ,
	'ld_tab'
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_parenttabrel
		WHERE
			parenttabid =2
		AND tabid =@tabid
		AND tab_tablename = 'ld_tab'
	);
delimiter;


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='title' LIMIT 1);
SET @trantable='ld_field';
SET @zh='文章标题';
SET @en='Article Title';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='create_time' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建时间';
SET @en='Creation time';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='负责人';
SET @en='smownerid';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='wx_user_id' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创作者';
SET @en='wx_user_id';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='origin_url' LIMIT 1);
SET @trantable='ld_field';
SET @zh='来源网址';
SET @en='origin_url';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='origin_id' LIMIT 1);
SET @trantable='ld_field';
SET @zh='来源文章';
SET @en='origin_id';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='cover_url' LIMIT 1);
SET @trantable='ld_field';
SET @zh='封面';
SET @en='cover_url';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='content' LIMIT 1);
SET @trantable='ld_field';
SET @zh='内容';
SET @en='content';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='like_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='点赞次数';
SET @en='like_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='share_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='分享次数';
SET @en='share_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='copy_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='转载次数';
SET @en='copy_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='look_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='浏览次数';
SET @en='look_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

select tabid into @tabid from ld_tab where `name`='Articles';
select blockid into @blockid from ld_BLOCKS where tabid=@tabid and blocklabel='LBL_ARTICLES_INFO';
set @tablename='ld_articles';
set @columnname='create_time';
set @fieldname='create_time';
set @zh='创建时间';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='title';
set @fieldname='title';
set @zh='文章标题';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smownerid';
set @fieldname='smownerid';
set @zh='负责人';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='wx_user_id';
set @fieldname='wx_user_id';
set @zh='创作者';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='origin_url';
set @fieldname='origin_url';
set @zh='来源网址';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='origin_id';
set @fieldname='origin_id';
set @zh='来源文章';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='cover_url';
set @fieldname='cover_url';
set @zh='封面';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='content';
set @fieldname='content';
set @zh='内容';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='like_nums';
set @fieldname='like_nums';
set @zh='点赞次数';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='share_nums';
set @fieldname='share_nums';
set @zh='分享次数';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='copy_nums';
set @fieldname='copy_nums';
set @zh='转载次数';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);


set @columnname='look_nums';
set @fieldname='look_nums';
set @zh='浏览次数';
set @uitype=15;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);
SELECT
	tabid INTO @tabid
FROM
	ld_tab
WHERE
	`name` = 'Articles';

INSERT INTO ld_blocks (
	blockid,
	tabid,
	blocklabel,
	sequence
) SELECT
	(
		SELECT
			max(blockid)
		FROM
			ld_blocks
	) + 1 ,@tabid,
	'LBL_ARTICLES_INFO',
	1
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			*
		FROM
			ld_blocks
		WHERE
			tabid = @tabid
		AND blocklabel = 'LBL_ARTICLES_INFO'
		AND sequence = 1
	);
delimiter;


SELECT
	MAX(cvid) INTO @maxcvid
FROM
	ld_customview;

INSERT INTO ld_customview (
	cvid,
	viewname,
	setdefault,
	setmetrics,
	entitytype,
	STATUS,
	userid,
	sequence
) SELECT
	@maxcvid + 1,
	'All',
	1,
	0,
	'Articles',
	3,
	1,
	1
FROM
	DUAL
WHERE
	NOT EXISTS (
		SELECT
			1
		FROM
			ld_customview
		WHERE
			entitytype = 'Articles'
		AND viewname = 'All'
	);


SET @cvid = (
	SELECT
		cvid
	FROM
		ld_customview
	WHERE
		entitytype = 'Articles'
	AND viewname = 'All'
);

INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	0,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'title',
		':',
		'title',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=0);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	1,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'create_time',
		':',
		'create_time',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=1);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	2,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'smownerid',
		':',
		'smownerid',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=2);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	3,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'wx_user_id',
		':',
		'wx_user_id',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=3)
;


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	4,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'origin_url',
		':',
		'origin_url',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=4)
;

INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	5,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'origin_id',
		':',
		'origin_id',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=5);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	6,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'cover_url',
		':',
		'cover_url',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=6);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	7,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'content',
		':',
		'content',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=7);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	8,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'like_nums',
		':',
		'like_nums',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=8);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	9,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'share_nums',
		':',
		'share_nums',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=9);



INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	10,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'copy_nums',
		':',
		'copy_nums',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=10);


INSERT INTO ld_cvcolumnlist (
	cvid,
	columnindex,
	columnname
) SELECT
	@cvid,
	11,
	CONCAT(
		'ld_',
		LOWER('Articles'),
		':',
		'look_nums',
		':',
		'look_nums',
		':',
		'Articles',
		'_fieldlabel:V'
	)from dual
where not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnindex=11);
delimiter;


DROP  TABLE  IF EXISTS  ld_articles;
CREATE TABLE IF NOT EXISTS ld_articles (
	`articlesid` int(19) NOT NULL DEFAULT '0' COMMENT '自增ID',
	`articles_no` varchar(255) DEFAULT NULL,
	`smownerid` int(19) DEFAULT NULL COMMENT 'crm的创建人id，若仅是微信用户则无',
	`smcreatorid` int(19) DEFAULT NULL,
	`createdtime` datetime DEFAULT NULL,
	`modifiedby` int(19) DEFAULT NULL,
	`modifiedtime` datetime DEFAULT NULL,
	`approvestatus` varchar(50) DEFAULT '未提交',
	`approvetime` datetime DEFAULT NULL,
	`approveby` int(19) DEFAULT NULL,
	`currentapprover` text,
	`deleted` int(19) NOT NULL DEFAULT '0',
	`advance_stage` varchar(20) DEFAULT NULL,
	`approvesubmitter` int(19) DEFAULT '0',
	`approvesubmittedtime` datetime DEFAULT NULL,
	`currentapprovestepid` int(19) DEFAULT '0',
	`title` varchar(100) DEFAULT NULL COMMENT '文章标题',
	`wx_user_id` int(11) DEFAULT NULL COMMENT 'wx的创建人id，若仅是crm用户则无',
	`origin_url` text COMMENT '文章来源url',
	`origin_id` int(11) DEFAULT NULL COMMENT '文章来源id',
	`cover_url` text COMMENT '封面图',
	`description` VARCHAR(255) COMMENT  '简介',
	`content` text COMMENT '文章内容',
	`like_nums` text COMMENT '点赞次数',
	`share_nums` text COMMENT '分享次数',
	`copy_nums` text COMMENT '转载次数',
	`look_nums` text COMMENT '浏览次数',
	PRIMARY KEY (`articlesid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;
delimiter;

set @moduleName = 'Articles';
SET  @tabid = (select tabid from ld_tab where name ='Articles');

DELETE from ld_tranlabel where tabid =@tabid and trantable='ld_field' and IFNULL(relateid,'') ='';
DELETE  from ld_field where tabid =@tabid and fieldname='create_time';
set @parenttabid = (select parenttabid from ld_parenttab where parenttab_label= 'Marketing');
INSERT INTO `ld_parenttabrel` (`parenttabid`, `tabid`, `sequence`, `tab_tablename`) select @parenttabid, @tabid, 0, 'ld_tab' from dual where not exists (select 1 from ld_parenttabrel where tabid = @tabid and parenttabid = @parenttabid);

SET @modentity_num_seq = (select id+1 from ld_modentity_num_seq);
INSERT INTO  `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`) select @modentity_num_seq, 'Articles', 'ART', '0001', '0001', '1', 'yyyy-mm-dd-', 0, 0, 0  from dual where not exists (select 1 from ld_modentity_num where  semodule ='Articles');
update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );

INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
SELECT @tabid, @moduleName, 'ld_articles', 'title', 'articlesid', 'articlesid' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_ARTICLES_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='基本信息');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Basic Information');

set @table = 'ld_articles';
set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`)
select @tabid, @fieldid, 'smcreatorid', 'yes', @table, '1', '52', 'smcreatorid', '创建人', '1', '0', NULL, NULL, '3', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='smcreatorid');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='smcreatorid');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_field', @tabid, @fieldid, '创建人' from dual
where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='创建人');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'en', 'ld_field', @tabid, @fieldid, 'Creator' from dual
where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Creator');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`)
select @tabid, @fieldid, 'createdtime', 'yes', @table, '1', '70', 'createdtime', '创建时间', '1', '0', NULL, NULL, '4', @blockid, '2', 'DT~O', '1', NULL, NULL, '1', NULL, '0', '0', 1, 1, '0', '0', NULL, NULL, '2', '0', 'no', 'no', 'no', 'no', 'yes', '0', '0', 'yes', 'datetime', NULL, '0', NULL, 'yes', NULL from dual
where not exists( select 1 from ld_field where tabid= @tabid and fieldname='createdtime');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='createdtime');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='Created Time' or fieldlabel ='创建时间');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field',  @tabid, @fieldid, '创建时间' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='创建时间');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_field',  @tabid, @fieldid, 'Created Time' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Created Time');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'modifiedby', 'yes', @table, '1', '52', 'modifiedby', '最新更新人', '1', '0', NULL, NULL, '5', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='modifiedby');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='modifiedby');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='Modified By' or fieldlabel ='最新更新人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_field', @tabid, @fieldid, '最新更新人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='最新更新人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Modified By' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Modified By');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'modifiedtime', 'yes', @table, '1', '70', 'modifiedtime', '更新时间', '1', '0', NULL, NULL, '6', @blockid, '2', 'DT~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', 'datetime', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='modifiedtime');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='modifiedtime');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='更新时间' or fieldlabel ='Modified Time');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '更新时间' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='更新时间');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Modified Time' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Modified Time');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'approvestatus', 'yes', @table, '1', '609', 'approvestatus', '审批状态', '1', '0', NULL, NULL, '7', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='approvestatus');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='approvestatus');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='审批状态' or fieldlabel ='Approve Status');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '审批状态' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='审批状态');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Approve Status' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Approve Status');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'approvetime', 'yes', @table, '1', '70', 'approvetime', '最新审批时间', '1', '0', NULL, NULL, '8', @blockid, '2', 'DT~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', 'datetime', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='approvetime');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='最新审批时间' or fieldlabel ='Last Approval Time');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='approvetime');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '最新审批时间' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='最新审批时间');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Last Approval Time' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Last Approval Time');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'approveby', 'yes', @table, '1', '131', 'approveby', '上一步审批人', '1', '0', NULL, NULL, '9', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='approveby');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='上一步审批人' or fieldlabel ='The Last Approver');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='approveby');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '上一步审批人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='上一步审批人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'The Last Approver' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='The Last Approver');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'currentapprover', 'yes', @table, '1', '132', 'currentapprover', '当前审批人', '1', '0', NULL, NULL, '10', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='currentapprover');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='当前审批人' or fieldlabel ='Current Approver');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='currentapprover');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '当前审批人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='当前审批人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Current Approver' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Current Approver');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'advance_stage', 'yes', @table, '1', '1', 'advance_stage', '推进阶段', '1', '1', NULL, '100', '13', @blockid, '3', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '1', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', '', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='advance_stage');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='推进阶段' or fieldlabel ='Advance Stage');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='advance_stage');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '推进阶段' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='推进阶段');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Advance Stage' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Advance Stage');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'articles_no', 'yes', @table, '1', '4', 'articles_no', '单据编号', '1', '1', NULL, '100', '13', @blockid, '3', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '1', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', '', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='articles_no');
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='单据编号' or fieldlabel ='Articles No');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='articles_no');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '单据编号' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='单据编号');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Articles No' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Articles No');

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='title' LIMIT 1);
SET @trantable='ld_field';
SET @zh='文章标题';
SET @en='Article Title';
delete  from ld_tranlabel where tabid =@tabid and trantable='ld_field' and ( fieldlabel ='Article Title' or fieldlabel ='文章标题');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='负责人';
SET @en='smownerid';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='wx_user_id' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创作者';
SET @en='wx_user_id';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='origin_url' LIMIT 1);
SET @trantable='ld_field';
SET @zh='来源网址';
SET @en='origin_url';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='origin_id' LIMIT 1);
SET @trantable='ld_field';
SET @zh='来源文章';
SET @en='origin_id';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='cover_url' LIMIT 1);
SET @trantable='ld_field';
SET @zh='封面';
SET @en='cover_url';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='content' LIMIT 1);
SET @trantable='ld_field';
SET @zh='内容';
SET @en='content';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='like_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='点赞次数';
SET @en='like_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='share_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='分享次数';
SET @en='share_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='copy_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='转载次数';
SET @en='copy_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='look_nums' LIMIT 1);
SET @trantable='ld_field';
SET @zh='浏览次数';
SET @en='look_nums';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


UPDATE  ld_field set allowedit='no',generatedtype=1,uitype=53,fieldname='assigned_user_id',typeofdata='V~M',masseditable=0,issmownerid=1,associatedsequence=2,allowedit_presence='yes',allowcreate='yes',allowcreate_presence='yes',allowedit_presence='yes',bigtype='users',keywords='yes'  where tabid= @tabid and columnname ='smownerid';

update ld_field set displaytype=2 ,allowedit=null WHERE  tabid=@tabid AND columnname in('like_nums','share_nums','copy_nums','look_nums');

SET  @max_blockid = (select max(blockid)+1 from ld_blocks);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ARTICLES_CONTENT',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ARTICLES_CONTENT');

set @tabid=(select tabid from ld_tab where name="Articles");
SET @relateid=(SELECT blockid from ld_blocks  where tabid = @tabid and blocklabel = 'LBL_ARTICLES_CONTENT');
SET @trantable='ld_blocks';
SET @zh='文章内容';
SET @en='Content';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

UPDATE     ld_field SET  block = (SELECT blockid from ld_blocks  where tabid = @tabid and blocklabel = 'LBL_ARTICLES_CONTENT' ) where tabid=@tabid and columnname ='content';


INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 1, 1 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=1);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 2, 2 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=2 );
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 3, 3  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=3);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 4, 4  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=4);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 5, 5  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=5);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 6, 6  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=6);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 11, 7  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=11);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 12, 8  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=12);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 13, 9  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=13);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 14, 10  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=14);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 22, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=22);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 25, 11  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=25);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 37, 12  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=37);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 49, 14  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=49);
delimiter;

set @tabid=(select tabid from ld_tab where name="Articles");
update ld_field set block = (SELECT blockid from ld_blocks where tabid =@tabid and blocklabel='LBL_ARTICLES_INFO') where tabid =@tabid and columnname != 'content';

UPDATE ld_field set uitype=1 where tabid =@tabid and columnname in('title','wx_user_id','origin_url','origin_id' ,'cover_url','like_nums','share_nums','copy_nums','look_nums');
UPDATE ld_field set uitype=230 where  tabid =@tabid  and columnname='content';

set @tabid=(select tabid from ld_tab where name="Articles");
SET  @max_blockid = (select max(blockid)+1 from ld_blocks);
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_IMAGE_INFORMATION',2,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_IMAGE_INFORMATION');


SET @relateid=(SELECT blockid from ld_blocks  where tabid = @tabid and blocklabel = 'LBL_IMAGE_INFORMATION');
SET @trantable='ld_blocks';
SET @zh='封面';
SET @en='Picture';

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

update ld_field set uitype =69,block=(SELECT blockid from ld_blocks  where tabid = @tabid and blocklabel = 'LBL_IMAGE_INFORMATION' ) where tabid =@tabid and columnname ='cover_url';
delimiter;

call addcolumn('ld_articles','publicaccount','varchar','5','');
delimiter;

set @tabid=(select tabid from ld_tab where name="Articles");
set @blockid =(select blockid from ld_blocks where blocklabel ='LBL_ARTICLES_INFO');
set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'publicaccount', 'yes', 'ld_articles', 2, '15', 'publicaccount', '是否公海', 0, 2, NULL, 100, 4, @blockid, 1, 'V~O', 1, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 2, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', NULL, NULL, 0, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='publicaccount');
set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='publicaccount');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '是否公海' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='是否公海');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Is Public' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Is Public');


INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`) select  'publicaccount', 'ld_field', NULL, NULL from dual  where not exists (select 1 from ld_picklist_set where listname ='publicaccount');
set @listid = (select listid  from ld_picklist_set where listname ='publicaccount');

select tabid into @tabid from ld_tab where name='Articles';
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '是', 1 from dual where not exists (select 1 from ld_picklist_values where listvalue='是' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '否', 2 from dual where not exists (select 1 from ld_picklist_values where listvalue='否' and listid =@listid);
delimiter;

set @tabid=(select tabid from ld_tab where name="Articles");
set @blockid =(select blockid from ld_blocks where blocklabel ='LBL_ARTICLES_INFO');
set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'description', 'yes', 'ld_articles', 2, '19', 'description', '描述', 0, 2, NULL, 100, 4, @blockid, 1, 'V~O', 1, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 2, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', NULL, NULL, 0, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='description');

set @fieldid = (select fieldid from ld_field where tabid=@tabid and columnname='description');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '简介' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='简介');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Description' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Description');
delimiter;

DROP PROCEDURE IF EXISTS `insert_profileallpermission`;
delimiter ||
CREATE  PROCEDURE `insert_profileallpermission`(
	operationid VARCHAR(50)
)
BEGIN

	declare done  int  default 0;
	declare ttabid  int ;
	declare cur1 CURSOR FOR select tabid from ld_profileallpermission where operation = 1 GROUP BY tabid;
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ttabid;
 	loop1: while  done<>1 DO
			set @sql=Concat('insert into ld_profileallpermission(tabid,operation,sequence) select ',ttabid,',',operationid,',',1000,' from dual where not exists(select 1 from ld_profileallpermission where tabid=',ttabid,' and operation=',operationid,')');
			prepare stmt from @sql;
			execute stmt;
			deallocate  prepare  stmt;
			set @i = 0;
			update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=ttabid order by  Sequence asc ;
		Fetch cur1 into ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

call insert_profileallpermission(22);
delimiter;


CALL DelColumn('ld_articles','like_nums');
CALL AddColumn('ld_articles', 'like_nums', 'int', '19', 0);
CALL DelColumn('ld_articles','share_nums');
CALL AddColumn('ld_articles', 'share_nums', 'int', '19', 0);
CALL DelColumn('ld_articles','copy_nums');
CALL AddColumn('ld_articles', 'copy_nums', 'int', '19', 0);
CALL DelColumn('ld_articles','look_nums');
CALL AddColumn('ld_articles', 'look_nums', 'int', '19', 0);
delimiter;

UPDATE ld_field set allowedit='no',displaytype='2' where tabid =204 and columnname in('wx_user_id','origin_url','origin_id');
delimiter;

DELETE from ld_cvcolumnlist where cvid =(select cvid from ld_customview where entitytype='Articles') and columnname='ld_articles:content:content:Articles_fieldlabel:V';
delimiter;

UPDATE ld_field_seq SET  id=(SELECT MAX(fieldid) FROM  ld_field );
set @tabid = (SELECT  tabid from ld_tab where name='Articles');
UPDATE ld_field
SET defaultvalue=0
WHERE tabid = @tabid
  AND columnname IN ('like_nums', 'share_nums', 'copy_nums', 'look_nums');
UPDATE ld_field set bigtype ='fileattachment' where tabid =@tabid and uitype=69;
delimiter;

set @tabid = (SELECT  tabid from ld_tab where name='Articles');
UPDATE ld_field set typeofdata ='V~M' WHERE tabid =@tabid and  columnname in ('title','publicaccount','content');
delimiter;

DELETE FROM ld_tranlabel WHERE Relateid IS NULL;
-- 2020-10-26

set @tabid = (SELECT  tabid from ld_tab where name='Articles');
UPDATE ld_field set typeofdata ='V~M' WHERE tabid =@tabid and  columnname in ('description','cover_url');
delimiter


alter table ld_articles alter column look_nums set default 0;
alter table ld_articles alter column like_nums set default 0;
alter table ld_articles alter column share_nums set default 0;
alter table ld_articles alter column copy_nums set default 0;
delimiter;

call addcolumn('ld_wx_users','last_name','varchar','20','');
call addcolumn('ld_wx_users','weixin','varchar','20','');
call addcolumn('ld_wx_users','position','varchar','20','');
call addcolumn('ld_wx_users','company','varchar','20','');
delimiter;
-- 2020-10-27

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

UPDATE ld_version SET old_version='V8.2.8',current_version='V8.2.8',remark='V8.2.8-20201026',wx_version='V8.2.6';
delimiter;