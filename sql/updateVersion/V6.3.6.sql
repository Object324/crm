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

select tabid into @tabid from ld_tab where name='ServiceReturn';
insert into ld_modtracker_tabs(tabid,visible) 
select @tabid,1 from dual 
where not exists(select 1 from ld_modtracker_tabs where tabid = @tabid);
delimiter;

update ld_tranlabel set trantable = 'ld_systems_deploy' where trantable = 'ld_system_deploy';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
insert into ld_profileallpermission(tabid,operation)
select @tabid,5 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=5);
delimiter;

call DelColumn('ld_users','supportname');
delimiter;
delete from ld_field where tabid=29 and columnname='supportname';
delimiter;
-- 2016-05-24

call altercolumn('ld_bangwo8','vendorid','vendorid','varchar(100)');
delimiter;

update ld_desk set fieldlabel='Shared users' where labelbol='ShareUsers' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

update ld_desk set  fieldlabel='公海客户已经被领取，领取失败' where labelbol='THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE' and labeltype='jspop' and languagetype='zh';

update ld_desk set  fieldlabel='公海客户已经被分配，分配失败' where labelbol='THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION' and labeltype='jspop' and languagetype='zh';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','THEHIGHTSEAHASBEENALLOCATE','公海客户已经被分配，领取失败','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol='THEHIGHTSEAHASBEENALLOCATE' and languagetype='zh' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','THEHIGHTSEAHASBEENALLOCATE','The high seas, the customer has been assigned,receive failure','jspop' from DUAL
where not exists(select 1 from ld_desk where labelbol='THEHIGHTSEAHASBEENALLOCATE' and languagetype='en' and labeltype='jspop');
delimiter;
-- 2016-05-25

ALTER TABLE ld_dividendorder MODIFY COLUMN createdtime datetime;
ALTER TABLE ld_dividendorder MODIFY COLUMN modifiedtime datetime;
update ld_systems_deploy set deploy_value=1 where deploy_type=103;
update ld_tranlabel set fieldlabel='Call high(见老板)' where trantable='ld_field' and tabid=2 and languagetype='zh'
and Relateid=(select fieldid from ld_field where tabid=2 and columnname='callhigh') and fieldlabel='是否见老板';

update ld_systems_deploy set presence=0,inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',inputtype='select',roottype=2 where deploy_type=50 AND setype='PurchaseInvoice';
delimiter;
-- 2016-05-26

update ld_blocks set sequence=100 where tabid=29 and blocklabel='LBL_ATTACHMENTS_INFOMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=29 order by sequence;
delimiter;
-- 2016-05-27

update ld_field set typeofdata='V~M' where tabid=29 and columnname in ('user_password','confirm_password');
-- 2016-05-30

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

update ld_version set old_version='V6.3.6' ,current_version='V6.3.6' ,remark='V6.3.6-20160530';
delimiter;