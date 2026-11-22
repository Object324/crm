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

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	declare str varchar(250);  
  set @sql1=concat('drop index ',indexname,' on ',tablename);   
	
	select database() into @datebase;
	set @sql2=concat('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	if @cnt>0 then 
		PREPARE statement_name FROM @sql1;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
	end if;
  
  set @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
  PREPARE statement_name FROM @sql3;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;
	
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

update ld_field set typeofdata='V~M' where tabid=29 and columnname in ('user_password','confirm_password');
-- 2016-05-30

update ld_inventorytaxinfo set deleted=0 where deleted is null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_DISTRIBUT_HIGHSEAS','公海分配','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'LBL_DISTRIBUT_HIGHSEAS' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_DISTRIBUT_HIGHSEAS','High sea distribut','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'LBL_DISTRIBUT_HIGHSEAS' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','ANSWER','来电','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='ANSWER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','ANSWER','Answer','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='ANSWER' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','CALL','去电','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='CALL' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','CALL','call','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='CALL' and languagetype='en' and labeltype='fixedstr');
delimiter;
-- 2016-05-31

set @trackpostion_id=1;
select trackpostion_id into @trackpostion_id from ld_trackpostion where trackpostion='不定位组(Non track group)';
update ld_users set trackgroupid=@trackpostion_id where trackgroupid<1;

update ld_field set defaultvalue=@trackpostion_id where tabid=29 and columnname='trackgroupid';
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
update ld_field set presence=0 where tabid=@tabid and columnname in ('discount_percent','discount_amount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,4,0 from DUAL
where not exists(select 1 from ld_quickactions where tabid = @tabid and related_tabid = -5);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTAFILE','请选择文件!','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASESELECTAFILE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTAFILE','Please select a file !','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASESELECTAFILE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

UPDATE ld_desk SET fieldlabel = 'The last day of this month'
WHERE labelbol = 'ENDOFMONTH' AND languagetype='en' AND labeltype = 'fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','JIUWEIPHONEANSWER','接通','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONEANSWER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','JIUWEIPHONEANSWER','Answer','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONEANSWER' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','JIUWEIPHONENOANSWER','无人接听','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONENOANSWER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','JIUWEIPHONENOANSWER','NoAnswer','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONENOANSWER' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','JIUWEIPHONECANCEL','无人接听','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONECANCEL' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','JIUWEIPHONECANCEL','Cancel','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONECANCEL' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','JIUWEIPHONEBUSY','占线','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONEBUSY' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','JIUWEIPHONEBUSY','Busy','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONEBUSY' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','JIUWEIPHONEOTHER','其他','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONEOTHER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','JIUWEIPHONEOTHER','Other','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='JIUWEIPHONEOTHER' and languagetype='en');

UPDATE ld_desk SET fieldlabel = 'The last day of this month' WHERE labelbol = 'ENDOFMONTH' AND languagetype='en' AND labeltype = 'fixedstr';

select sequence into @sequence from ld_systems_deploy where deploy_type= 94;
update ld_systems_deploy set sequence = sequence+1 where roottype = 2 and sequence > @sequence;
update ld_systems_deploy set sequence = @sequence+1 where roottype = 2 and deploy_type=99;
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = 2 order by sequence;
delimiter;

update ld_systems_deploy set inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"PurchaseOrder,SendPayment"}]' where deploy_type=15;
update ld_systems_deploy set inputvalue='[{"value":"0","text":"NOLIMITS"},{"value":"1","text":"WARNNING"},{"value":"2","text":"FORBID"},{"sql":""},{"relatedmodule":"Attachment"}]' where deploy_type=77;
update ld_systems_deploy set inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Accounts"}]' where deploy_type=69;
-- 2016-06-01

select tabid into @tabid from ld_tab where `name` = 'Rate';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and tabid = @tabid and relateid = @fieldid);

update ld_tranlabel set fieldlabel='创建人' where trantable='ld_field' and tabid=@tabid and Relateid=@fieldid and languagetype='zh' and length(fieldlabel)<1;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','SETUPCOLUMNHEADER','显示列字段','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='SETUPCOLUMNHEADER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','SETUPCOLUMNHEADER',' display column field','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='SETUPCOLUMNHEADER' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','SETUPCOLUMNHEADERREMIND','至少设置3个显示列字段','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='SETUPCOLUMNHEADERREMIND' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','SETUPCOLUMNHEADERREMIND','Set at least three display field','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='SETUPCOLUMNHEADERREMIND' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','JIUWEICALLER','主叫号码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='JIUWEICALLER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','JIUWEICALLER','Caller','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='JIUWEICALLER' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','JIUWEICALLEE','被叫号码','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='JIUWEICALLEE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','JIUWEICALLEE','Callee','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='JIUWEICALLEE' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_jiuweiak_phonerecord`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `userid`     TINYINT(4),
  `usernum`     VARCHAR(25),
  `callid` INT(11),
  `is_bombscreen` VARCHAR(25),
  `type`      VARCHAR(25),
  `caller`  VARCHAR(25),
  `callee` VARCHAR(25),
  `accountid` INT(11),
  `contactid` INT(11),
  `recordnum` VARCHAR(25),
  `starttime` DATETIME,
  `deadline` DATETIME,
  `talktime` INT(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2016-06-02

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update ld_autotask_seq set id = (select MAX(autotaskid) from ld_autotask);
update ld_currency_info_seq set id=(select max(id) from ld_currency_info);
update ld_users_seq set id=(select max(id) from ld_users);
delimiter;

update ld_version set old_version='V6.3.7' ,current_version='V6.3.7' ,remark='V6.3.7-20160602';
delimiter;