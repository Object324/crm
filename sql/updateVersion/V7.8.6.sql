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

UPDATE ld_desk SET fieldlabel='After editing, click the Save button and the new rule will take effect.' WHERE labelbol='AFTERMAKINGMODIFIPRESS' AND languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHARERULE_EXPLAIN','说明：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHARERULE_EXPLAIN' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARERULE_EXPLAIN','Explain:','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHARERULE_EXPLAIN' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHARERULE_ONE','1、私有：对象中所有数据遵循相关团队成员（包括负责人）及其上级对数据可见，且对这条数据具备同样的权限[只读、可编辑]；上级部门的部门负责人可以看到下级部门的所有数据。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHARERULE_ONE' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARERULE_ONE','1.Private: All data in the object is visible to the data by the relevant team members (including the person in charge) and their superiors, and has the same authority [read-only, editable] for this data; the department heads of the higher departments can see all data of the lower departments.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHARERULE_ONE' and labeltype='fixedstr');


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHARERULE_TWO','2、公开只读：对象中所有数据对全公司公开。单条数据的负责人及其上级、以及相关团队具备编辑权限的成员可以编辑该数据。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHARERULE_TWO' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARERULE_TWO','2.Public Read Only: All data in the object is open to the whole company. The person in charge of the individual data and his superiors, as well as members of the relevant team with editing authority, can edit the data.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHARERULE_TWO' and labeltype='fixedstr');


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHARERULE_THREE','3、公开读写：对象中所有数据对全公司公开，全员可编辑。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SHARERULE_THREE' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHARERULE_THREE','3.Public Read/Edit: All data in the object is open to the whole company and editable by the whole staff.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SHARERULE_THREE' and labeltype='fixedstr');

CALL AddColumn('ld_related_field','frommodule','varchar','100',NULL);
delimiter;

create table if not exists `ld_wx_checkin_reissue`(
  `id` int(19) auto_increment primary key comment '企业微信补卡表主键',
  `sp_num` varchar(255)  comment '审批单号',
  `userid` varchar(255) comment '微信成员ID',
  `sp_status` varchar(255)  comment '审批状态：1审批中；2 已通过；3已驳回；4已取消；6通过后撤销；10已支付',
  `checkin_time` int comment '补卡时间',
  `checkin_time_date` datetime comment '格式化的补卡时间'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select usereportid into @id from ld_usereport where name='checkin_monthly';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'reissue_card', 8, 1, '补卡(次)','Card reissue(Times)'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='reissue_card');
update ld_usereportcolumns set Sequence=9 where columns='signin_days' and usereportid=@id;
select usereportid into @id from ld_usereport where name='checkin_abnormal';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'reissue_card', 9, 1, '补卡(次)','Card reissue(Times)'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='reissue_card');
update ld_usereportcolumns set Sequence=10 where columns='condition' and usereportid=@id;
update ld_usereportcolumns set realcolumns='打卡(次)',realencolumns='Checkin(Times)' where usereportid=@id and columns='frequency';
delimiter;
-- 2019-08-28

update ld_desk set fieldlabel='企业微信企业ID' where labelbol = 'CHECKINSETTING_TITLE1'
     and languagetype='zh' and labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_TITLE3','企业微信审批应用Secret','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE3' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_TITLE3','Approve App Secret','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE3' and languagetype='en' and labeltype = 'fixedstr');
select tabid into @tabid from ld_tab where `name` = 'OftenUseReport';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
  select @tabid,'OftenUseReport','checkin_monthly','http://51mis.com.cn/forum.php?mod=viewthread&tid=533&fromuid=1','常用报表-月度考勤表' from DUAL
  where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'OftenUseReport' and linklabel = 'checkin_monthly');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_TITLE4','请确认企业微信打卡参数配置是否正确，详细设置方法请点击右上角“帮助”按钮！','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE4' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_TITLE4','Please confirm whether the enterprise WeChat card parameter configuration is correct. For detailed setting method, please click the “Help” button in the upper right corner!','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE4' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_TITLE5','同步记录的时间跨度不能超过30天，请缩小时间范围!','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE5' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_TITLE5','The time span of synchronous record should not exceed 30 days, please reduce the time range!','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE5' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_REMIND1','正在同步数据，请勿刷新或关闭浏览器！','jspop' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_REMIND1' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_REMIND1','Synchronizing data, do not refresh or close the browser','jspop' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_REMIND1' and languagetype='en' and labeltype = 'jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_REMIND2','同步成功，正在重新载入报表内容...','jspop' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_REMIND2' and languagetype='zh' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_REMIND2','Synchronization successful, reloading report content...','jspop' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_REMIND2' and languagetype='en' and labeltype = 'jspop');
delimiter;

SET @modulename='Products';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='glacct' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='made_in'; 
SET @fieldname='made_in'; 
SET @zh='产地'; 
SET @en='Made IN'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'VARCHAR','100',0);
CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);


SET @tabid=14;
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='glacct' LIMIT 1);
SET @seq=(SELECT sequence FROM ld_field WHERE tabid=@tabid AND columnname='glacct' LIMIT 1);
UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@blockid AND sequence>@seq;
UPDATE ld_field SET sequence=@seq+1 WHERE tabid=@tabid AND block=@blockid AND sequence=@seq;
UPDATE ld_field SET sequence=@seq,block=@blockid,presence=1 WHERE tabid=@tabid AND columnname='made_in';

SET @i=0;
UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@blockid ORDER BY sequence;
delimiter;
-- 2019-08-29

update ld_field set typeofdata='V~O' 
where uitype in(select uitype from ld_ws_fieldtype INNER JOIN ld_ws_referencetype
on ld_ws_fieldtype.fieldtypeid=ld_ws_referencetype.fieldtypeid) 
and (typeofdata is null or typeofdata='') ;
delimiter;

update ld_field set columnname='competitors',fieldname='competitors' where tabid=2 and columnname like '%competitors%';
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','拖动','drag','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='drag' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Drag','drag','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='drag' and labeltype='fixedstr');
delimiter;

select usereportid into @reportid from ld_usereport where name='InventoryQuery';
select Sequence into @sequence from ld_usereportcolumns where columns like 'ld_products:unit_price:unit_price%' and Usereportid=@reportid limit 1;
update ld_usereportcolumns set Sequence=Sequence+2 where Usereportid=@reportid and Sequence > @sequence;
insert into ld_usereportcolumns (Usereportid,columns, Sequence,columnshow, realcolumns, realencolumns, is_advanced)
  select @reportid,'ld_products:made_in:made_in:Products_产地#:V',@sequence+1,0,
    'ld_products:made_in:made_in:Products_产地:V','ld_products:made_in:made_in:Products_Made_IN:V',0 from dual where not exists(
      select 1 from ld_usereportcolumns where columns like 'ld_products:made_in:made_in%' and Usereportid=@reportid);
insert into ld_usereportcolumns (Usereportid,columns, Sequence,columnshow, realcolumns, realencolumns, is_advanced)
  select @reportid,'ld_products:productdate:productdate:Products_生产日期#:V',@sequence+2,0,
    'ld_products:productdate:productdate:Products_生产日期:V','ld_products:productdate:productdate:Products_Date of manufacture:V',0 from dual where not exists(
      select 1 from ld_usereportcolumns where columns like 'ld_products:productdate:productdate%' and Usereportid=@reportid);
set @i = 0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid=@reportid order by  Sequence asc ;

select usereportid into @reportid from ld_usereport where name='InventoryAccount';
select Sequence into @sequence from ld_usereportcolumns where columns like 'ld_warehouse:warhouse:warhouse%' and Usereportid=@reportid limit 1;
update ld_usereportcolumns set Sequence=Sequence+2 where Usereportid=@reportid and Sequence > @sequence;
insert into ld_usereportcolumns (Usereportid,columns, Sequence,columnshow, realcolumns, realencolumns, is_advanced)
  select @reportid,'ld_products:made_in:made_in:Products_产地#:V',@sequence+1,0,
    'ld_products:made_in:made_in:Products_产地:V','ld_products:made_in:made_in:Products_Made_IN:V',0 from dual where not exists(
      select 1 from ld_usereportcolumns where columns like 'ld_products:made_in:made_in%' and Usereportid=@reportid);
insert into ld_usereportcolumns (Usereportid,columns, Sequence,columnshow, realcolumns, realencolumns, is_advanced)
  select @reportid,'ld_products:productdate:productdate:Products_生产日期#:V',@sequence+2,0,
    'ld_products:productdate:productdate:Products_生产日期:V','ld_products:productdate:productdate:Products_Date of manufacture:V',0 from dual where not exists(
      select 1 from ld_usereportcolumns where columns like 'ld_products:productdate:productdate%' and Usereportid=@reportid);
set @i = 0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid=@reportid order by  Sequence asc ;
delimiter;

update ld_tabdetailfield set edit_permission=0 where columnname='entitytypeid';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_validatasave` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `module` varchar(100) DEFAULT NULL,
  `relatedtable` varchar(50) DEFAULT NULL,
  `fieldname` varchar(50) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `formulavalue` text,
  `comparatordescription` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_validatasavedetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `relateid` int(19) DEFAULT NULL,
  `relateformulavalue` text,
  `relatefieldname` varchar(19) DEFAULT NULL,
  `sequence` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_reset_validatasave_20190830`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_validatasave_20190830`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_validatasave) THEN
		DELETE FROM ld_validatasavedetail;

		INSERT INTO `ld_validatasave` VALUES ('33', 'Expense', 'ld_field', 'expensedate', 'm', null, '小于等于');
		INSERT INTO `ld_validatasave` VALUES ('34', 'CashBill', 'ld_field', 'cashbilldate', 'm', null, '小于等于');
		INSERT INTO `ld_validatasave` VALUES ('35', 'Commission', 'ld_field', 'expensedate', 'm', null, '小于等于');
		INSERT INTO `ld_validatasave` VALUES ('36', 'ContactRecords', 'ld_field', 'contactdate', 'm', null, '小于等于');
		INSERT INTO `ld_validatasave` VALUES ('37', 'Commission', 'ld_tabdetailfield', 'amount', 'notempty', null, '不能为空');
		INSERT INTO `ld_validatasave` VALUES ('38', 'Expense', 'ld_tabdetailfield', 'money', 'notempty', null, '不能为空');
		INSERT INTO `ld_validatasave` VALUES ('39', 'Expense', 'ld_tabdetailfield', 'startdate', 'm', null, '小于等于');
		INSERT INTO `ld_validatasave` VALUES ('40', 'Contacts', 'ld_field', 'birthday', 'm', null, '小于等于');
		INSERT INTO `ld_validatasave` VALUES ('41', 'Project', 'ld_field', 'actualenddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('42', 'Project', 'ld_field', 'targetenddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('43', 'ProjectTask', 'ld_field', 'enddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('44', 'ProjectTask', 'ld_field', 'actualenddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('45', 'Campaigns', 'ld_field', 'closingdate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('46', 'HelpDesk', 'ld_field', 'hopetime_end', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('47', 'PublicAnnouncement', 'ld_field', 'enddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('48', 'ProjectProgress', 'ld_field', 'enddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('49', 'Rate', 'ld_field', 'enddate', 'h', null, '大于等于');
		INSERT INTO `ld_validatasave` VALUES ('50', 'DividendOrder', 'ld_field', 'enddate', 'h', null, '大于等于');

		INSERT INTO `ld_validatasavedetail` VALUES ('27', '33', 'curdate', '', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('28', '34', 'curdate', '', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('29', '35', 'curdate', '', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('30', '36', 'curdatetime', '', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('31', '39', '', 'enddate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('32', '40', 'curdate', '', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('33', '41', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('34', '42', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('35', '43', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('36', '44', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('37', '45', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('38', '46', '', 'hopetime', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('39', '47', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('40', '48', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('41', '49', '', 'startdate', '1');
		INSERT INTO `ld_validatasavedetail` VALUES ('42', '50', '', 'startdate', '1');
	END IF;

END ||
delimiter;


CALL ldcrm_reset_validatasave_20190830();
DROP PROCEDURE IF EXISTS `ldcrm_reset_validatasave_20190830`;
delimiter;
-- 2019-08-30

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

UPDATE ld_version SET old_version='V7.8.6',current_version='V7.8.6',remark='V7.8.6-20190830',wx_version='V7.8.6';
delimiter;