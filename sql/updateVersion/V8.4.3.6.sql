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


CALL addColumn('ld_customreport_total_column','column_module','varchar','100','');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MemberDepartment','成员所属部门','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MemberDepartment' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MemberDepartment',"Member's Department",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MemberDepartment' and labeltype='fixedstr');
delimiter;


CALL AddColumn('ld_groups','groupseq','int',11,0);
CALL DelColumn('ld_groups','sequence');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectMemberField','选择成员字段','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectMemberField' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectMemberField','Select member field','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectMemberField' and labeltype='fixedstr');
delimiter;

UPDATE ld_groups SET groupseq=0;
DELETE FROM ld_groups WHERE parentid IS NULL;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_groupseq`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_groupseq`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR SELECT parentid FROM ld_groups GROUP BY parentid ORDER BY parentid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		SET @i=0;
		UPDATE ld_groups SET groupseq=(@i:=@i+1) WHERE parentid=tmp_id ORDER BY groupseq,groupid;
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL AddColumn('ld_profile','profileseq','int',11,0);
CALL DelColumn('ld_profile','sequence');
delimiter;

SET @i=0;
UPDATE ld_profile SET profileseq=(@i:=@i+1) ORDER BY profileid;
delimiter;


set @tmp_modulename="Articles";
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@tmp_modulename);
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(@tmp_modulename),'_INFO') AND tabid=@tabid);

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'articles_type','no',CONCAT('ld_',LOWER(@tmp_modulename)),1,1,'articles_type','文章类型',1,0,0,@blockid ,1,'V~M',1,0,0,1,'translatefield',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='articles_type');


CALL AddColumn('ld_articles', 'articles_type', 'varchar', '100', 'textArticles');




SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='articles_type');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'文章类型' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'articles type' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );



insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'articles_type','Articles','textArticles','textArticles' from dual
where not exists(select 1 from ld_translatefield where module='Articles' and columnname='articles_type' and column_Dbvalue='textArticles');
delimiter;


insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'articles_type','Articles','imageArticles','imageArticles' from dual
where not exists(select 1 from ld_translatefield where module='Articles' and columnname='articles_type' and column_Dbvalue='imageArticles');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'articles_type','Articles','PDFArticles','PDFArticles' from dual
where not exists(select 1 from ld_translatefield where module='Articles' and columnname='articles_type' and column_Dbvalue='PDFArticles');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'articles_type','Articles','linkArticles','linkArticles' from dual
where not exists(select 1 from ld_translatefield where module='Articles' and columnname='articles_type' and column_Dbvalue='linkArticles');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','textArticles','文本','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='textArticles' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','textArticles','text','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='textArticles' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','imageArticles','图片','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='imageArticles' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','imageArticles','image','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='imageArticles' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','linkArticles','链接','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='linkArticles' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','linkArticles','link','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='linkArticles' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','PDFArticles','PDF','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PDFArticles' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','PDFArticles','PDF','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PDFArticles' and labeltype='fixedstr');
delimiter;



set @tmp_modulename="Articles";
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@tmp_modulename);
SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel='LBL_ARTICLES_CONTENT' AND tabid=@tabid);

SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'content_link','yes','ld_articles',2,17,'content_link','内容链接',0,1,0,@blockid ,1,'V~M',1,0,0,1,'url',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='content_link');


SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxfieldid+1,'content_file','yes','ld_attachments',2,1109,'content_file','内容附件',0,2,0,@blockid ,1,'V~M',1,0,0,1,'fileattachment',NULL,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='content_file');


CALL AddColumn('ld_articles', 'content_link', 'varchar', '255', '');

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='content_link');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'内容链接' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'content link' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='content_file');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid, @fieldid,'内容附件' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid, @fieldid,'content file' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Articles');

INSERT INTO ld_fieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)
SELECT @tabid,'根据文章类型控制单据头显示','articles_type',NOW(),1,'yes' from dual
where not exists(select 1 from ld_fieldrule where tabid = @tabid and columnname = 'articles_type');

SET @myruleid=(SELECT id FROM ld_fieldrule WHERE tabid=@tabid AND columnname='articles_type' LIMIT 1);

INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
SELECT @myruleid,'e','文本' from dual where not exists(select 1 from ld_fieldrulebasicsearch where ruleid = @myruleid and `value` = '文本');
SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='e' AND `value`='文本' LIMIT 1);
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'content','display',@mysearchid from dual where not exists(select 1 from ld_fieldrule_operate where columnname = 'content' and basicsearchid = @mysearchid);

INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
SELECT @myruleid,'e','链接' from dual where not exists(select 1 from ld_fieldrulebasicsearch where ruleid = @myruleid and `value` = '链接');
SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='e' AND `value`='链接' LIMIT 1);
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'content_link','display',@mysearchid from dual where not exists(select 1 from ld_fieldrule_operate where columnname = 'content_link' and basicsearchid = @mysearchid);


INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
SELECT @myruleid,'e','图片' from dual where not exists(select 1 from ld_fieldrulebasicsearch where ruleid = @myruleid and `value` = '图片');
SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='e' AND `value`='图片' LIMIT 1);
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'content_file','display',@mysearchid from dual where not exists(select 1 from ld_fieldrule_operate where columnname = 'content_file' and basicsearchid = @mysearchid);

INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`)
SELECT @myruleid,'e','PDF'  from dual where not exists(select 1 from ld_fieldrulebasicsearch where ruleid = @myruleid and `value` = 'PDF');
SET @mysearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@myruleid AND comparator='e' AND `value`='PDF' LIMIT 1);
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid)
SELECT 'content_file','display',@mysearchid from dual where not exists(select 1 from ld_fieldrule_operate where columnname = 'content_file' and basicsearchid = @mysearchid);


update ld_field set typeofdata="V~M" WHERE tabid=@tabid and columnname in('content_file','content_link');
update ld_field set typeofdata="V~O" WHERE tabid=@tabid and columnname="cover_url";
delimiter;


SET @i=0;
SET @j=0;
SET @k=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Articles' LIMIT 1);
SET @block=(SELECT block FROM ld_field WHERE tablename='ld_articles' AND columnname='title' LIMIT 1);
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block AND presence<>1 ORDER BY sequence;

UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;
UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='title';
UPDATE ld_field SET sequence=(@j:=@j+1),allowedit='no',allowhide='no' WHERE tabid=@tabid AND block=@block AND columnname='articles_type';
UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='publicaccount';
UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='smownerid';

UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='description';
UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='customers';
UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='weixin';
UPDATE ld_field SET sequence=(@j:=@j+1) WHERE tabid=@tabid AND block=@block AND columnname='channelcode_id';

UPDATE ld_field SET sequence=(@k:=@k+1) WHERE tabid=@tabid AND block=@block AND presence<>1 ORDER BY sequence;
delimiter;



SET @id=(SELECT id FROM ld_fieldrule WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Articles' LIMIT 1) AND columnname='customers' LIMIT 1);
INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`) 
SELECT @id,'e','微信' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_fieldrulebasicsearch WHERE ruleid=@id AND `value`='微信' AND comparator='e') AND @id>0;

INSERT INTO ld_fieldrulebasicsearch(ruleid,comparator,`value`) 
SELECT @id,'e','渠道码' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_fieldrulebasicsearch WHERE ruleid=@id AND `value`='渠道码' AND comparator='e') AND @id>0;

SET @search_id=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@id AND `value`='微信' AND comparator='e' LIMIT 1);
DELETE FROM ld_fieldrule_operate WHERE basicsearchid=@search_id AND columnname='customers' AND @search_id>0;
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid) 
SELECT * FROM (SELECT 'customers','display',@search_id) a WHERE @search_id>1;

SET @search_id=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@id AND `value`='渠道码' AND comparator='e' LIMIT 1);
DELETE FROM ld_fieldrule_operate WHERE basicsearchid=@search_id AND columnname='channelcode_id' AND @search_id>0;
INSERT INTO ld_fieldrule_operate(columnname,type,basicsearchid) 
SELECT * FROM (SELECT 'channelcode_id','display',@search_id) a WHERE @search_id>1;
delimiter;

select tabid into @tabid from ld_tab where name = 'Singin';
update ld_field set uitype=202 where tabid=@tabid and columnname='record' ;
delimiter;



update ld_relatedlists set actions="" where tabid=2 and label="RECEIVABLESFORECAST";
delimiter;


UPDATE ld_desk SET fieldlabel='Scanning Log' WHERE labelbol= 'scanningcustomers' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='扫码日志' WHERE labelbol= 'scanningcustomers' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;




CREATE TABLE IF NOT EXISTS `base_pinyin` (
  `pin_yin_` varchar(255) CHARACTER SET gbk NOT NULL,
  `code_` int(11) NOT NULL,
  PRIMARY KEY (`code_`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
delimiter;

TRUNCATE base_pinyin;
INSERT INTO `base_pinyin` VALUES ('zuo', '10254');
INSERT INTO `base_pinyin` VALUES ('zun', '10256');
INSERT INTO `base_pinyin` VALUES ('zui', '10260');
INSERT INTO `base_pinyin` VALUES ('zuan', '10262');
INSERT INTO `base_pinyin` VALUES ('zu', '10270');
INSERT INTO `base_pinyin` VALUES ('zou', '10274');
INSERT INTO `base_pinyin` VALUES ('zong', '10281');
INSERT INTO `base_pinyin` VALUES ('zi', '10296');
INSERT INTO `base_pinyin` VALUES ('zhuo', '10307');
INSERT INTO `base_pinyin` VALUES ('zhun', '10309');
INSERT INTO `base_pinyin` VALUES ('zhui', '10315');
INSERT INTO `base_pinyin` VALUES ('zhuang', '10322');
INSERT INTO `base_pinyin` VALUES ('zhuan', '10328');
INSERT INTO `base_pinyin` VALUES ('zhuai', '10329');
INSERT INTO `base_pinyin` VALUES ('zhua', '10331');
INSERT INTO `base_pinyin` VALUES ('zhu', '10519');
INSERT INTO `base_pinyin` VALUES ('zhou', '10533');
INSERT INTO `base_pinyin` VALUES ('zhong', '10544');
INSERT INTO `base_pinyin` VALUES ('zhi', '10587');
INSERT INTO `base_pinyin` VALUES ('zheng', '10764');
INSERT INTO `base_pinyin` VALUES ('zhen', '10780');
INSERT INTO `base_pinyin` VALUES ('zhe', '10790');
INSERT INTO `base_pinyin` VALUES ('zhao', '10800');
INSERT INTO `base_pinyin` VALUES ('zhang', '10815');
INSERT INTO `base_pinyin` VALUES ('zhan', '10832');
INSERT INTO `base_pinyin` VALUES ('zhai', '10838');
INSERT INTO `base_pinyin` VALUES ('zha', '11014');
INSERT INTO `base_pinyin` VALUES ('zeng', '11018');
INSERT INTO `base_pinyin` VALUES ('zen', '11019');
INSERT INTO `base_pinyin` VALUES ('zei', '11020');
INSERT INTO `base_pinyin` VALUES ('ze', '11024');
INSERT INTO `base_pinyin` VALUES ('zao', '11038');
INSERT INTO `base_pinyin` VALUES ('zang', '11041');
INSERT INTO `base_pinyin` VALUES ('zan', '11045');
INSERT INTO `base_pinyin` VALUES ('zai', '11052');
INSERT INTO `base_pinyin` VALUES ('za', '11055');
INSERT INTO `base_pinyin` VALUES ('yun', '11067');
INSERT INTO `base_pinyin` VALUES ('yue', '11077');
INSERT INTO `base_pinyin` VALUES ('yuan', '11097');
INSERT INTO `base_pinyin` VALUES ('yu', '11303');
INSERT INTO `base_pinyin` VALUES ('you', '11324');
INSERT INTO `base_pinyin` VALUES ('yong', '11339');
INSERT INTO `base_pinyin` VALUES ('yo', '11340');
INSERT INTO `base_pinyin` VALUES ('ying', '11358');
INSERT INTO `base_pinyin` VALUES ('yin', '11536');
INSERT INTO `base_pinyin` VALUES ('yi', '11589');
INSERT INTO `base_pinyin` VALUES ('ye', '11604');
INSERT INTO `base_pinyin` VALUES ('yao', '11781');
INSERT INTO `base_pinyin` VALUES ('yang', '11798');
INSERT INTO `base_pinyin` VALUES ('yan', '11831');
INSERT INTO `base_pinyin` VALUES ('ya', '11847');
INSERT INTO `base_pinyin` VALUES ('xun', '11861');
INSERT INTO `base_pinyin` VALUES ('xue', '11867');
INSERT INTO `base_pinyin` VALUES ('xuan', '12039');
INSERT INTO `base_pinyin` VALUES ('xu', '12058');
INSERT INTO `base_pinyin` VALUES ('xiu', '12067');
INSERT INTO `base_pinyin` VALUES ('xiong', '12074');
INSERT INTO `base_pinyin` VALUES ('xing', '12089');
INSERT INTO `base_pinyin` VALUES ('xin', '12099');
INSERT INTO `base_pinyin` VALUES ('xie', '12120');
INSERT INTO `base_pinyin` VALUES ('xiao', '12300');
INSERT INTO `base_pinyin` VALUES ('xiang', '12320');
INSERT INTO `base_pinyin` VALUES ('xian', '12346');
INSERT INTO `base_pinyin` VALUES ('xia', '12359');
INSERT INTO `base_pinyin` VALUES ('xi', '12556');
INSERT INTO `base_pinyin` VALUES ('wu', '12585');
INSERT INTO `base_pinyin` VALUES ('wo', '12594');
INSERT INTO `base_pinyin` VALUES ('weng', '12597');
INSERT INTO `base_pinyin` VALUES ('wen', '12607');
INSERT INTO `base_pinyin` VALUES ('wei', '12802');
INSERT INTO `base_pinyin` VALUES ('wang', '12812');
INSERT INTO `base_pinyin` VALUES ('wan', '12829');
INSERT INTO `base_pinyin` VALUES ('wai', '12831');
INSERT INTO `base_pinyin` VALUES ('wa', '12838');
INSERT INTO `base_pinyin` VALUES ('tuo', '12849');
INSERT INTO `base_pinyin` VALUES ('tun', '12852');
INSERT INTO `base_pinyin` VALUES ('tui', '12858');
INSERT INTO `base_pinyin` VALUES ('tuan', '12860');
INSERT INTO `base_pinyin` VALUES ('tu', '12871');
INSERT INTO `base_pinyin` VALUES ('tou', '12875');
INSERT INTO `base_pinyin` VALUES ('tong', '12888');
INSERT INTO `base_pinyin` VALUES ('ting', '13060');
INSERT INTO `base_pinyin` VALUES ('tie', '13063');
INSERT INTO `base_pinyin` VALUES ('tiao', '13068');
INSERT INTO `base_pinyin` VALUES ('tian', '13076');
INSERT INTO `base_pinyin` VALUES ('ti', '13091');
INSERT INTO `base_pinyin` VALUES ('teng', '13095');
INSERT INTO `base_pinyin` VALUES ('te', '13096');
INSERT INTO `base_pinyin` VALUES ('tao', '13107');
INSERT INTO `base_pinyin` VALUES ('tang', '13120');
INSERT INTO `base_pinyin` VALUES ('tan', '13138');
INSERT INTO `base_pinyin` VALUES ('tai', '13147');
INSERT INTO `base_pinyin` VALUES ('ta', '13318');
INSERT INTO `base_pinyin` VALUES ('suo', '13326');
INSERT INTO `base_pinyin` VALUES ('sun', '13329');
INSERT INTO `base_pinyin` VALUES ('sui', '13340');
INSERT INTO `base_pinyin` VALUES ('suan', '13343');
INSERT INTO `base_pinyin` VALUES ('su', '13356');
INSERT INTO `base_pinyin` VALUES ('sou', '13359');
INSERT INTO `base_pinyin` VALUES ('song', '13367');
INSERT INTO `base_pinyin` VALUES ('si', '13383');
INSERT INTO `base_pinyin` VALUES ('shuo', '13387');
INSERT INTO `base_pinyin` VALUES ('shun', '13391');
INSERT INTO `base_pinyin` VALUES ('shui', '13395');
INSERT INTO `base_pinyin` VALUES ('shuang', '13398');
INSERT INTO `base_pinyin` VALUES ('shuan', '13400');
INSERT INTO `base_pinyin` VALUES ('shuai', '13404');
INSERT INTO `base_pinyin` VALUES ('shua', '13406');
INSERT INTO `base_pinyin` VALUES ('shu', '13601');
INSERT INTO `base_pinyin` VALUES ('shou', '13611');
INSERT INTO `base_pinyin` VALUES ('shi', '13658');
INSERT INTO `base_pinyin` VALUES ('sheng', '13831');
INSERT INTO `base_pinyin` VALUES ('shen', '13847');
INSERT INTO `base_pinyin` VALUES ('she', '13859');
INSERT INTO `base_pinyin` VALUES ('shao', '13870');
INSERT INTO `base_pinyin` VALUES ('shang', '13878');
INSERT INTO `base_pinyin` VALUES ('shan', '13894');
INSERT INTO `base_pinyin` VALUES ('shai', '13896');
INSERT INTO `base_pinyin` VALUES ('sha', '13905');
INSERT INTO `base_pinyin` VALUES ('seng', '13906');
INSERT INTO `base_pinyin` VALUES ('sen', '13907');
INSERT INTO `base_pinyin` VALUES ('se', '13910');
INSERT INTO `base_pinyin` VALUES ('sao', '13914');
INSERT INTO `base_pinyin` VALUES ('sang', '13917');
INSERT INTO `base_pinyin` VALUES ('san', '14083');
INSERT INTO `base_pinyin` VALUES ('sai', '14087');
INSERT INTO `base_pinyin` VALUES ('sa', '14090');
INSERT INTO `base_pinyin` VALUES ('ruo', '14092');
INSERT INTO `base_pinyin` VALUES ('run', '14094');
INSERT INTO `base_pinyin` VALUES ('rui', '14097');
INSERT INTO `base_pinyin` VALUES ('ruan', '14099');
INSERT INTO `base_pinyin` VALUES ('ru', '14109');
INSERT INTO `base_pinyin` VALUES ('rou', '14112');
INSERT INTO `base_pinyin` VALUES ('rong', '14122');
INSERT INTO `base_pinyin` VALUES ('ri', '14123');
INSERT INTO `base_pinyin` VALUES ('reng', '14125');
INSERT INTO `base_pinyin` VALUES ('ren', '14135');
INSERT INTO `base_pinyin` VALUES ('re', '14137');
INSERT INTO `base_pinyin` VALUES ('rao', '14140');
INSERT INTO `base_pinyin` VALUES ('rang', '14145');
INSERT INTO `base_pinyin` VALUES ('ran', '14149');
INSERT INTO `base_pinyin` VALUES ('qun', '14151');
INSERT INTO `base_pinyin` VALUES ('que', '14159');
INSERT INTO `base_pinyin` VALUES ('quan', '14170');
INSERT INTO `base_pinyin` VALUES ('qu', '14345');
INSERT INTO `base_pinyin` VALUES ('qiu', '14353');
INSERT INTO `base_pinyin` VALUES ('qiong', '14355');
INSERT INTO `base_pinyin` VALUES ('qing', '14368');
INSERT INTO `base_pinyin` VALUES ('qin', '14379');
INSERT INTO `base_pinyin` VALUES ('qie', '14384');
INSERT INTO `base_pinyin` VALUES ('qiao', '14399');
INSERT INTO `base_pinyin` VALUES ('qiang', '14407');
INSERT INTO `base_pinyin` VALUES ('qian', '14429');
INSERT INTO `base_pinyin` VALUES ('qia', '14594');
INSERT INTO `base_pinyin` VALUES ('qi', '14630');
INSERT INTO `base_pinyin` VALUES ('pu', '14645');
INSERT INTO `base_pinyin` VALUES ('po', '14654');
INSERT INTO `base_pinyin` VALUES ('ping', '14663');
INSERT INTO `base_pinyin` VALUES ('pin', '14668');
INSERT INTO `base_pinyin` VALUES ('pie', '14670');
INSERT INTO `base_pinyin` VALUES ('piao', '14674');
INSERT INTO `base_pinyin` VALUES ('pian', '14678');
INSERT INTO `base_pinyin` VALUES ('pi', '14857');
INSERT INTO `base_pinyin` VALUES ('peng', '14871');
INSERT INTO `base_pinyin` VALUES ('pen', '14873');
INSERT INTO `base_pinyin` VALUES ('pei', '14882');
INSERT INTO `base_pinyin` VALUES ('pao', '14889');
INSERT INTO `base_pinyin` VALUES ('pang', '14894');
INSERT INTO `base_pinyin` VALUES ('pan', '14902');
INSERT INTO `base_pinyin` VALUES ('pai', '14908');
INSERT INTO `base_pinyin` VALUES ('pa', '14914');
INSERT INTO `base_pinyin` VALUES ('ou', '14921');
INSERT INTO `base_pinyin` VALUES ('o', '14922');
INSERT INTO `base_pinyin` VALUES ('nuo', '14926');
INSERT INTO `base_pinyin` VALUES ('nue', '14928');
INSERT INTO `base_pinyin` VALUES ('nuan', '14929');
INSERT INTO `base_pinyin` VALUES ('nv', '14930');
INSERT INTO `base_pinyin` VALUES ('nu', '14933');
INSERT INTO `base_pinyin` VALUES ('nong', '14937');
INSERT INTO `base_pinyin` VALUES ('niu', '14941');
INSERT INTO `base_pinyin` VALUES ('ning', '15109');
INSERT INTO `base_pinyin` VALUES ('nin', '15110');
INSERT INTO `base_pinyin` VALUES ('nie', '15117');
INSERT INTO `base_pinyin` VALUES ('niao', '15119');
INSERT INTO `base_pinyin` VALUES ('niang', '15121');
INSERT INTO `base_pinyin` VALUES ('nian', '15128');
INSERT INTO `base_pinyin` VALUES ('ni', '15139');
INSERT INTO `base_pinyin` VALUES ('neng', '15140');
INSERT INTO `base_pinyin` VALUES ('nen', '15141');
INSERT INTO `base_pinyin` VALUES ('nei', '15143');
INSERT INTO `base_pinyin` VALUES ('ne', '15144');
INSERT INTO `base_pinyin` VALUES ('nao', '15149');
INSERT INTO `base_pinyin` VALUES ('nang', '15150');
INSERT INTO `base_pinyin` VALUES ('nan', '15153');
INSERT INTO `base_pinyin` VALUES ('nai', '15158');
INSERT INTO `base_pinyin` VALUES ('na', '15165');
INSERT INTO `base_pinyin` VALUES ('mu', '15180');
INSERT INTO `base_pinyin` VALUES ('mou', '15183');
INSERT INTO `base_pinyin` VALUES ('mo', '15362');
INSERT INTO `base_pinyin` VALUES ('miu', '15363');
INSERT INTO `base_pinyin` VALUES ('ming', '15369');
INSERT INTO `base_pinyin` VALUES ('min', '15375');
INSERT INTO `base_pinyin` VALUES ('mie', '15377');
INSERT INTO `base_pinyin` VALUES ('miao', '15385');
INSERT INTO `base_pinyin` VALUES ('mian', '15394');
INSERT INTO `base_pinyin` VALUES ('mi', '15408');
INSERT INTO `base_pinyin` VALUES ('meng', '15416');
INSERT INTO `base_pinyin` VALUES ('men', '15419');
INSERT INTO `base_pinyin` VALUES ('mei', '15435');
INSERT INTO `base_pinyin` VALUES ('me', '15436');
INSERT INTO `base_pinyin` VALUES ('mao', '15448');
INSERT INTO `base_pinyin` VALUES ('mang', '15454');
INSERT INTO `base_pinyin` VALUES ('man', '15625');
INSERT INTO `base_pinyin` VALUES ('mai', '15631');
INSERT INTO `base_pinyin` VALUES ('ma', '15640');
INSERT INTO `base_pinyin` VALUES ('luo', '15652');
INSERT INTO `base_pinyin` VALUES ('lun', '15659');
INSERT INTO `base_pinyin` VALUES ('lue', '15661');
INSERT INTO `base_pinyin` VALUES ('luan', '15667');
INSERT INTO `base_pinyin` VALUES ('lv', '15681');
INSERT INTO `base_pinyin` VALUES ('lu', '15701');
INSERT INTO `base_pinyin` VALUES ('lou', '15707');
INSERT INTO `base_pinyin` VALUES ('long', '15878');
INSERT INTO `base_pinyin` VALUES ('liu', '15889');
INSERT INTO `base_pinyin` VALUES ('ling', '15903');
INSERT INTO `base_pinyin` VALUES ('lin', '15915');
INSERT INTO `base_pinyin` VALUES ('lie', '15920');
INSERT INTO `base_pinyin` VALUES ('liao', '15933');
INSERT INTO `base_pinyin` VALUES ('liang', '15944');
INSERT INTO `base_pinyin` VALUES ('lian', '15958');
INSERT INTO `base_pinyin` VALUES ('lia', '15959');
INSERT INTO `base_pinyin` VALUES ('li', '16155');
INSERT INTO `base_pinyin` VALUES ('leng', '16158');
INSERT INTO `base_pinyin` VALUES ('lei', '16169');
INSERT INTO `base_pinyin` VALUES ('le', '16171');
INSERT INTO `base_pinyin` VALUES ('lao', '16180');
INSERT INTO `base_pinyin` VALUES ('lang', '16187');
INSERT INTO `base_pinyin` VALUES ('lan', '16202');
INSERT INTO `base_pinyin` VALUES ('lai', '16205');
INSERT INTO `base_pinyin` VALUES ('la', '16212');
INSERT INTO `base_pinyin` VALUES ('kuo', '16216');
INSERT INTO `base_pinyin` VALUES ('kun', '16220');
INSERT INTO `base_pinyin` VALUES ('kui', '16393');
INSERT INTO `base_pinyin` VALUES ('kuang', '16401');
INSERT INTO `base_pinyin` VALUES ('kuan', '16403');
INSERT INTO `base_pinyin` VALUES ('kuai', '16407');
INSERT INTO `base_pinyin` VALUES ('kua', '16412');
INSERT INTO `base_pinyin` VALUES ('ku', '16419');
INSERT INTO `base_pinyin` VALUES ('kou', '16423');
INSERT INTO `base_pinyin` VALUES ('kong', '16427');
INSERT INTO `base_pinyin` VALUES ('keng', '16429');
INSERT INTO `base_pinyin` VALUES ('ken', '16433');
INSERT INTO `base_pinyin` VALUES ('ke', '16448');
INSERT INTO `base_pinyin` VALUES ('kao', '16452');
INSERT INTO `base_pinyin` VALUES ('kang', '16459');
INSERT INTO `base_pinyin` VALUES ('kan', '16465');
INSERT INTO `base_pinyin` VALUES ('kai', '16470');
INSERT INTO `base_pinyin` VALUES ('ka', '16474');
INSERT INTO `base_pinyin` VALUES ('jun', '16647');
INSERT INTO `base_pinyin` VALUES ('jue', '16657');
INSERT INTO `base_pinyin` VALUES ('juan', '16664');
INSERT INTO `base_pinyin` VALUES ('ju', '16689');
INSERT INTO `base_pinyin` VALUES ('jiu', '16706');
INSERT INTO `base_pinyin` VALUES ('jiong', '16708');
INSERT INTO `base_pinyin` VALUES ('jing', '16733');
INSERT INTO `base_pinyin` VALUES ('jin', '16915');
INSERT INTO `base_pinyin` VALUES ('jie', '16942');
INSERT INTO `base_pinyin` VALUES ('jiao', '16970');
INSERT INTO `base_pinyin` VALUES ('jiang', '16983');
INSERT INTO `base_pinyin` VALUES ('jian', '17185');
INSERT INTO `base_pinyin` VALUES ('jia', '17202');
INSERT INTO `base_pinyin` VALUES ('ji', '17417');
INSERT INTO `base_pinyin` VALUES ('huo', '17427');
INSERT INTO `base_pinyin` VALUES ('hun', '17433');
INSERT INTO `base_pinyin` VALUES ('hui', '17454');
INSERT INTO `base_pinyin` VALUES ('huang', '17468');
INSERT INTO `base_pinyin` VALUES ('huan', '17482');
INSERT INTO `base_pinyin` VALUES ('huai', '17487');
INSERT INTO `base_pinyin` VALUES ('hua', '17496');
INSERT INTO `base_pinyin` VALUES ('hu', '17676');
INSERT INTO `base_pinyin` VALUES ('hou', '17683');
INSERT INTO `base_pinyin` VALUES ('hong', '17692');
INSERT INTO `base_pinyin` VALUES ('heng', '17697');
INSERT INTO `base_pinyin` VALUES ('hen', '17701');
INSERT INTO `base_pinyin` VALUES ('hei', '17703');
INSERT INTO `base_pinyin` VALUES ('he', '17721');
INSERT INTO `base_pinyin` VALUES ('hao', '17730');
INSERT INTO `base_pinyin` VALUES ('hang', '17733');
INSERT INTO `base_pinyin` VALUES ('han', '17752');
INSERT INTO `base_pinyin` VALUES ('hai', '17759');
INSERT INTO `base_pinyin` VALUES ('ha', '17922');
INSERT INTO `base_pinyin` VALUES ('guo', '17928');
INSERT INTO `base_pinyin` VALUES ('gun', '17931');
INSERT INTO `base_pinyin` VALUES ('gui', '17947');
INSERT INTO `base_pinyin` VALUES ('guang', '17950');
INSERT INTO `base_pinyin` VALUES ('guan', '17961');
INSERT INTO `base_pinyin` VALUES ('guai', '17964');
INSERT INTO `base_pinyin` VALUES ('gua', '17970');
INSERT INTO `base_pinyin` VALUES ('gu', '17988');
INSERT INTO `base_pinyin` VALUES ('gou', '17997');
INSERT INTO `base_pinyin` VALUES ('gong', '18012');
INSERT INTO `base_pinyin` VALUES ('geng', '18181');
INSERT INTO `base_pinyin` VALUES ('gen', '18183');
INSERT INTO `base_pinyin` VALUES ('gei', '18184');
INSERT INTO `base_pinyin` VALUES ('ge', '18201');
INSERT INTO `base_pinyin` VALUES ('gao', '18211');
INSERT INTO `base_pinyin` VALUES ('gang', '18220');
INSERT INTO `base_pinyin` VALUES ('gan', '18231');
INSERT INTO `base_pinyin` VALUES ('gai', '18237');
INSERT INTO `base_pinyin` VALUES ('ga', '18239');
INSERT INTO `base_pinyin` VALUES ('fu', '18446');
INSERT INTO `base_pinyin` VALUES ('fou', '18447');
INSERT INTO `base_pinyin` VALUES ('fo', '18448');
INSERT INTO `base_pinyin` VALUES ('feng', '18463');
INSERT INTO `base_pinyin` VALUES ('fen', '18478');
INSERT INTO `base_pinyin` VALUES ('fei', '18490');
INSERT INTO `base_pinyin` VALUES ('fang', '18501');
INSERT INTO `base_pinyin` VALUES ('fan', '18518');
INSERT INTO `base_pinyin` VALUES ('fa', '18526');
INSERT INTO `base_pinyin` VALUES ('er', '18696');
INSERT INTO `base_pinyin` VALUES ('en', '18697');
INSERT INTO `base_pinyin` VALUES ('e', '18710');
INSERT INTO `base_pinyin` VALUES ('duo', '18722');
INSERT INTO `base_pinyin` VALUES ('dun', '18731');
INSERT INTO `base_pinyin` VALUES ('dui', '18735');
INSERT INTO `base_pinyin` VALUES ('duan', '18741');
INSERT INTO `base_pinyin` VALUES ('du', '18756');
INSERT INTO `base_pinyin` VALUES ('dou', '18763');
INSERT INTO `base_pinyin` VALUES ('dong', '18773');
INSERT INTO `base_pinyin` VALUES ('diu', '18774');
INSERT INTO `base_pinyin` VALUES ('ding', '18783');
INSERT INTO `base_pinyin` VALUES ('die', '18952');
INSERT INTO `base_pinyin` VALUES ('diao', '18961');
INSERT INTO `base_pinyin` VALUES ('dian', '18977');
INSERT INTO `base_pinyin` VALUES ('di', '18996');
INSERT INTO `base_pinyin` VALUES ('deng', '19003');
INSERT INTO `base_pinyin` VALUES ('de', '19006');
INSERT INTO `base_pinyin` VALUES ('dao', '19018');
INSERT INTO `base_pinyin` VALUES ('dang', '19023');
INSERT INTO `base_pinyin` VALUES ('dan', '19038');
INSERT INTO `base_pinyin` VALUES ('dai', '19212');
INSERT INTO `base_pinyin` VALUES ('da', '19218');
INSERT INTO `base_pinyin` VALUES ('cuo', '19224');
INSERT INTO `base_pinyin` VALUES ('cun', '19227');
INSERT INTO `base_pinyin` VALUES ('cui', '19235');
INSERT INTO `base_pinyin` VALUES ('cuan', '19238');
INSERT INTO `base_pinyin` VALUES ('cu', '19242');
INSERT INTO `base_pinyin` VALUES ('cou', '19243');
INSERT INTO `base_pinyin` VALUES ('cong', '19249');
INSERT INTO `base_pinyin` VALUES ('ci', '19261');
INSERT INTO `base_pinyin` VALUES ('chuo', '19263');
INSERT INTO `base_pinyin` VALUES ('chun', '19270');
INSERT INTO `base_pinyin` VALUES ('chui', '19275');
INSERT INTO `base_pinyin` VALUES ('chuang', '19281');
INSERT INTO `base_pinyin` VALUES ('chuan', '19288');
INSERT INTO `base_pinyin` VALUES ('chuai', '19289');
INSERT INTO `base_pinyin` VALUES ('chu', '19467');
INSERT INTO `base_pinyin` VALUES ('chou', '19479');
INSERT INTO `base_pinyin` VALUES ('chong', '19484');
INSERT INTO `base_pinyin` VALUES ('chi', '19500');
INSERT INTO `base_pinyin` VALUES ('cheng', '19515');
INSERT INTO `base_pinyin` VALUES ('chen', '19525');
INSERT INTO `base_pinyin` VALUES ('che', '19531');
INSERT INTO `base_pinyin` VALUES ('chao', '19540');
INSERT INTO `base_pinyin` VALUES ('chang', '19715');
INSERT INTO `base_pinyin` VALUES ('chan', '19725');
INSERT INTO `base_pinyin` VALUES ('chai', '19728');
INSERT INTO `base_pinyin` VALUES ('cha', '19739');
INSERT INTO `base_pinyin` VALUES ('ceng', '19741');
INSERT INTO `base_pinyin` VALUES ('ce', '19746');
INSERT INTO `base_pinyin` VALUES ('cao', '19751');
INSERT INTO `base_pinyin` VALUES ('cang', '19756');
INSERT INTO `base_pinyin` VALUES ('can', '19763');
INSERT INTO `base_pinyin` VALUES ('cai', '19774');
INSERT INTO `base_pinyin` VALUES ('ca', '19775');
INSERT INTO `base_pinyin` VALUES ('bu', '19784');
INSERT INTO `base_pinyin` VALUES ('bo', '19805');
INSERT INTO `base_pinyin` VALUES ('bing', '19976');
INSERT INTO `base_pinyin` VALUES ('bin', '19982');
INSERT INTO `base_pinyin` VALUES ('bie', '19986');
INSERT INTO `base_pinyin` VALUES ('biao', '19990');
INSERT INTO `base_pinyin` VALUES ('bian', '20002');
INSERT INTO `base_pinyin` VALUES ('bi', '20026');
INSERT INTO `base_pinyin` VALUES ('beng', '20032');
INSERT INTO `base_pinyin` VALUES ('ben', '20036');
INSERT INTO `base_pinyin` VALUES ('bei', '20051');
INSERT INTO `base_pinyin` VALUES ('bao', '20230');
INSERT INTO `base_pinyin` VALUES ('bang', '20242');
INSERT INTO `base_pinyin` VALUES ('ban', '20257');
INSERT INTO `base_pinyin` VALUES ('bai', '20265');
INSERT INTO `base_pinyin` VALUES ('ba', '20283');
INSERT INTO `base_pinyin` VALUES ('ao', '20292');
INSERT INTO `base_pinyin` VALUES ('ang', '20295');
INSERT INTO `base_pinyin` VALUES ('an', '20304');
INSERT INTO `base_pinyin` VALUES ('ai', '20317');
INSERT INTO `base_pinyin` VALUES ('a', '20319');
delimiter;


DROP FUNCTION IF EXISTS getpinyin;
delimiter ||
CREATE FUNCTION getpinyin (NAME VARCHAR(255) CHARSET GBK) RETURNS VARCHAR (255) CHARSET GBK
BEGIN

	DECLARE mycode INT(19); 
	DECLARE tmp_lcode VARCHAR(2) CHARSET GBK; 
	DECLARE lcode INT(19); 
	DECLARE tmp_rcode VARCHAR(2) CHARSET GBK;
	DECLARE rcode INT(19); 
	DECLARE mypy VARCHAR(255) CHARSET GBK DEFAULT ''; 
	DECLARE lp INT(19); 

	
	SET mycode = 0 ;
	SET lp = 1 ;
	SET NAME = HEX(NAME);

	WHILE lp < length(NAME) DO
		SET tmp_lcode = SUBSTRING(NAME,lp,2);
		SET lcode = CAST(ASCII(UNHEX(tmp_lcode)) AS UNSIGNED);
		SET tmp_rcode = SUBSTRING(NAME,lp+2,2);
		SET rcode = CAST(ASCII(UNHEX(tmp_rcode)) AS UNSIGNED);

		IF lcode > 128 THEN
			SET mycode = 65536 - lcode * 256 - rcode ; 
			SELECT
				CONCAT(mypy,pin_yin_) INTO mypy
			FROM base_pinyin
			WHERE code_ >= abs(mycode)
			ORDER BY code_ ASC
			LIMIT 1 ;

			SET lp = lp + 4 ;
		ELSE
			SET mypy = CONCAT(mypy,CHAR(CAST(ASCII(UNHEX(SUBSTRING(NAME, lp, 2))) AS UNSIGNED)));
			SET lp = lp + 2 ;
		END IF ;
	END WHILE; 
	RETURN lower(mypy) ;
END ||
delimiter;



select tabid into @tabid from ld_tab where name = 'Articles';
update ld_field set presence=2 WHERE tabid=@tabid and columnname="content_link";
delimiter;



DROP PROCEDURE IF EXISTS `reset_caidan_info_20210806`;
delimiter ||
CREATE  PROCEDURE `reset_caidan_info_20210806`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_loginhistory) THEN
		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Reports' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='报表分析' WHERE languagetype='zh' AND trantable='ld_parenttab' AND Relateid=@parenttabid;

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Marketing' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='市场营销' WHERE languagetype='zh' AND trantable='ld_parenttab' AND Relateid=@parenttabid;

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Tools' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='基础资料' WHERE languagetype='zh' AND trantable='ld_parenttab' AND Relateid=@parenttabid;



	END IF;


end ||
delimiter;

CALL reset_caidan_info_20210806();
DROP PROCEDURE IF EXISTS `reset_caidan_info_20210806`;
delimiter;




DROP PROCEDURE IF EXISTS `reset_caidan_info_20210806`;
delimiter ||
CREATE  PROCEDURE `reset_caidan_info_20210806`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_loginhistory) THEN
		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Parent Reports' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='报表分析' WHERE languagetype='zh' AND trantable='ld_parenttab' AND Relateid=@parenttabid;

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Marketing' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='市场营销' WHERE languagetype='zh' AND trantable='ld_parenttab' AND Relateid=@parenttabid;

		SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Tools' LIMIT 1);
		UPDATE ld_tranlabel SET fieldlabel='基础资料' WHERE languagetype='zh' AND trantable='ld_parenttab' AND Relateid=@parenttabid;

	END IF;


end ||
delimiter;

CALL reset_caidan_info_20210806();
DROP PROCEDURE IF EXISTS `reset_caidan_info_20210806`;
delimiter;


INSERT INTO ld_business_wordslist(wordkey,wordtype)
SELECT '协会', 'blackkey' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey='协会' AND wordtype='blackkey');

INSERT INTO ld_business_wordslist(wordkey,wordtype)
SELECT ' 分公司', 'blackkey' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_business_wordslist WHERE wordkey='协会' AND wordtype='blackkey');


SET @i=0;
SET @tabid=6;
UPDATE ld_relatedlists SET presence=0,sequence=-1000 WHERE `name`='get_trends' AND tabid=@tabid;
UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;
delimiter;


SET @i=0;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge' LIMIT 1);
UPDATE ld_relatedlists SET presence=0,sequence=-1000 WHERE `name`='get_trends' AND tabid=@tabid;
UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND presence<>1 ORDER BY sequence;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_groupseq`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_groupseq`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	
	DECLARE MYCUSOR CURSOR FOR SELECT parentid FROM ld_groups GROUP BY parentid ORDER BY parentid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		SET @i=0;
		UPDATE ld_groups SET groupseq=(@i:=@i+1) WHERE parentid=tmp_id ORDER BY groupseq,groupid;
		FETCH MYCUSOR INTO tmp_id;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_reset_groupseq();
DROP PROCEDURE IF EXISTS `ldcrm_reset_groupseq`;
-- 2021-08-06

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

UPDATE ld_version SET old_version='V8.4.3.5',current_version='V8.4.3.6',remark='V8.4.3.6-20210806',wx_version='V8.4.3.6';
delimiter;